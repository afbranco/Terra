package app;

import java.io.IOException;
import java.io.PrintStream;
import java.net.Socket;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

import messages.*;
import net.tinyos.message.Message;
import net.tinyos.message.MessageListener;
//import net.tinyos.message.MoteIF;
import net.tinyos.packet.BuildSource;
import net.tinyos.packet.PhoenixSource;
import net.tinyos.tools.PrintfMsg;
import net.tinyos.util.Messenger;
import net.tinyos.util.PrintStreamMessenger;

public class ControlCore implements MessageListener
{
	private ControlMoteIF mote;
    PhoenixSource phoenix;

	private ControlForm controlform;
	private ProgBin progBin; 
	private String host;
	private int port;
//	private boolean serviceOFF;
	private int TCPretries;
	
	private int VersionId=0;
	private int setDataSeq=0;

	private Integer lastSetDataIdx=0;
	private Map<Integer,List<SetData>> setData=new HashMap<Integer,List<SetData>>();

//	private boolean pauseConfig=true;
	int erroCount=0;
	int CurrentBlockId=-1;
	Timer TCPtimer;
	Timer Sendtimer;

	public ControlCore(ControlForm Form,String Host,int Port) throws InterruptedException, IOException  {
		super();
		controlform = Form;
		host=Host; // "localhost";
		port=Port; // 9002;
		TCPretries = 0;
//		serviceOFF = true;
		TCPtimer = new Timer();
		TCPtimer.schedule(new tryConnect(), 0);
	}

	class tryConnect extends TimerTask {
        public void run() {
			controlform.setTCP(false, TCPretries);
        	retryConnect();
        }
    }
	
	public void retryConnect() {
		// TCP/IP Connection
		controlform.appendControlMsg("ControlCore: Retry TCP connection.");
		Socket socket = null;
		try {
			socket = new Socket(host, port);
		} catch (IOException e) {
			TCPretries++;
			TCPtimer.schedule(new tryConnect(), 5000);			
			// e.printStackTrace();
			return;
		}
//		serviceOFF = true;
		
		if (socket!=null) {
//			serviceOFF=false;
			try {
				socket.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		

	    
		phoenix = BuildSource.makePhoenix("serial@/dev/ttyUSB0:micaz", PrintStreamMessenger.err);
		mote = new ControlMoteIF(PrintStreamMessenger.err,controlform);
		mote.setPacketErrorHandler();
		controlform.setTCP(true, TCPretries);
		mote.registerListener(new reqProgBlockMsg(), this);
		mote.registerListener(new reqDataMsg(), this);
		mote.registerListener(new sendBSMsg(), this);
		mote.registerListener(new PrintfMsg(), this);
		mote.registerListener(new usrMsg(), this);
	}

	static class TerraMessenger implements Messenger {
		  private PrintStream ps;

		  public TerraMessenger(PrintStream ps) {
		    this.ps = ps;
		  }

		  public void message(String s) {
		    ps.println(s);
		  }

//		  public static Messenger err = new Messenger(System.out);
//		  public TerraMessenger out = new TerraMessenger(System.out);
		}
	

	public void newData(ProgBin Binary){
		progBin = Binary;
//		pauseConfig=false;
		erroCount=0;
		CurrentBlockId=-1;
		controlform.appendControlMsg("ControlCore: newData button.");
		sendNewProgVersion();
	}
	
	public void newSetData(List<SetData> SetDataArray){
		setDataSeq++;
		setData.put(setDataSeq, SetDataArray);
		lastSetDataIdx=setDataSeq;
		if (setData.size() > 10) setData.remove(lastSetDataIdx-10);
		controlform.appendControlMsg("ControlCore: newSetData button.");
		sendNewSetData(lastSetDataIdx);
	}

	public void pauseConfig(){ 
		//pauseConfig=true;
	}


	@Override
	public void messageReceived(int dest_addr, Message msg) {
		System.out.println("messageReceived:: Type="+ msg.amType() + " size="+msg.dataLength());
		// Received a reqProgBlockMsg
		if (msg instanceof reqProgBlockMsg) {
			reqProgBlockMsg omsg = (reqProgBlockMsg)msg;
			VersionId = omsg.get_versionId();
			controlform.recReqProgBlockMsg(progBin.getBlockStart(),omsg.get_blockId(),progBin.getNumBlocks());
			System.out.println(omsg.toString());
			sendNewProgBlock(omsg.get_blockId());
		}
		// Received a reqDataMsg
		if (msg instanceof reqDataMsg) {
			reqDataMsg omsg = (reqDataMsg)msg;
			controlform.recReqDataMsg(omsg.get_versionId(),omsg.get_seq());
			System.out.println(omsg.toString());
			sendNewSetData(omsg.get_seq());
		}
		// Received a sendBS
		if (msg instanceof sendBSMsg) {
			sendBSMsg omsg = (sendBSMsg)msg;
			String Data="";
			for (int i=0;i<16;i++) Data = Data + String.format("%02x,", omsg.getElement_Data(i));
			controlform.sendBSMsg(omsg.get_Sender(),omsg.get_evtId(),omsg.get_seq(),Data);
			System.out.println(omsg.toString());
		}
		// Received a PrintfMsg
		if (msg instanceof PrintfMsg) {
			PrintfMsg omsg = (PrintfMsg)msg;
			controlform.PrintfMsg(omsg.getString_buffer());
		}
		// Received a usrMsg
		if (msg instanceof usrMsg) {
			usrMsg omsg = (usrMsg)msg;
			String Data;
			Data = String.format("%d %d %d %d | %d %d %d %d | %d %d", 
					omsg.get_d8_1(),omsg.get_d8_2(),omsg.get_d8_3(),omsg.get_d8_4(),
					omsg.get_d16_1(),omsg.get_d16_2(),omsg.get_d16_3(),omsg.get_d16_4(),
					omsg.get_d32_1(),omsg.get_d32_2() );
			controlform.sendBSMsg(omsg.get_source(),omsg.get_id(),0,Data);
			System.out.println(omsg.toString());
		}

	}

	class sendMsg extends TimerTask {
		Message msg;
		String name;
		public sendMsg(String Name, Message Msg){
			this.msg = Msg;
			this.name=Name;
		}
        public void run() {
    		try {
    			mote.send(1, msg);
    		}
    		catch (IOException e) {
    			erroCount++;
    			System.out.println("sendMsg::"+name+": Can not send message to Base Station");
    		}
        }
    }	
	
	/**
	 * Send a specific program block
	 * @param BlockId	Requested data block number
	 */
	void sendNewProgBlock(short BlockId){
		controlform.appendControlMsg("ControlCore: sendNewProgBlock()");

		newProgBlockMsg msg = new newProgBlockMsg();

		msg.set_blockId(BlockId);
		msg.set_versionId(VersionId);
		
		short[] ProgBlock = progBin.getProgBlock(BlockId);
		msg.set_data(ProgBlock);
		System.out.println(msg.toString());
		TCPtimer.schedule(new sendMsg("NewProgBlock",msg), 10);
	}


	void sendNewProgVersion(){
		controlform.appendControlMsg("ControlCore: sendNewProgVersion()");
		newProgVersionMsg msg = new newProgVersionMsg();

		VersionId++;
		msg.set_versionId(VersionId);
		msg.set_blockLen(progBin.getNumBlocks());
		msg.set_blockStart(progBin.getBlockStart());
		msg.set_startProg(progBin.getStartProg());
		msg.set_lblTable11(progBin.getLabelTable11());
		msg.set_lblTable12(progBin.getLabelTable12());
		msg.set_lblTable21(progBin.getLabelTable21());
		msg.set_lblTable22(progBin.getLabelTable22());
		msg.set_lblTableEnd(progBin.getLabelTableEnd());
		msg.set_nTracks(progBin.getNTracks());
		msg.set_wClocks(progBin.getWClocks());
		msg.set_asyncs(progBin.getAsyncs());
		msg.set_wClock0(progBin.getWClock0());
		msg.set_gate0(progBin.getGate0());
		msg.set_inEvts(progBin.getInEvts());
		msg.set_async0(progBin.getAsync0());
		
		System.out.println(msg.toString());		
		TCPtimer.schedule(new sendMsg("NewProgVersion",msg), 10);
	}

	void sendNewSetData(Integer idx){
		controlform.appendControlMsg("ControlCore: sendNewSetData()");
		List<SetData> Data = setData.get(idx);
		short[] DataBytes = new short[18];
		int ix=0;
		Integer grMask=0;
		if (Data.get(0).GrNdOpt) { // true = to some Groups
			setDataGRMsg msg = new setDataGRMsg();
			msg.set_nSections((short)Data.size());
			for (int i=0;i<Data.get(0).GrNdIdLen;i++) {
				grMask = grMask | (1<<Data.get(0).GrNdId[i]);
				System.out.println("len="+Data.get(0).GrNdIdLen+" i="+i+" grid="+Data.get(0).GrNdId[i]+" mask="+Integer.toBinaryString(grMask));
			}
			msg.set_grIdBitMask(grMask);
			msg.set_versionId(VersionId);
			msg.set_seq(idx);
			for (int i=0;i<Data.size();i++){
				System.out.println("Sections="+Data.size()+" section="+i+" Addr="+Data.get(i).Addr);
				// Addr
				DataBytes[ix++]=(short)(Data.get(i).Addr & 0x00ff);
				DataBytes[ix++]=(short)((Data.get(i).Addr & 0xff00)>>8);
				// length
				DataBytes[ix++]=Data.get(i).Len.shortValue();
				// Data
				for (int j=0; j< Data.get(i).Len; j++) DataBytes[ix++] = Data.get(i).Values[j];
			}
			msg.set_Data(DataBytes);
			System.out.println(msg.toString());		
			TCPtimer.schedule(new sendMsg("SetDataGR",msg), 10);
		} else { // to Specific node
			setDataNDMsg msg = new setDataNDMsg();
			msg.set_nSections((short)Data.size());
			msg.set_targetMote(Data.get(0).GrNdId[0]);
			msg.set_versionId(VersionId);
			msg.set_seq(idx);
			for (int i=0;i<Data.size();i++){
				// Addr
				DataBytes[ix++]=(short)(Data.get(i).Addr & 0x00ff);
				DataBytes[ix++]=(short)((Data.get(i).Addr & 0xff00)>>8);
				// length
				DataBytes[ix++]=Data.get(i).Len.shortValue();
				// Data
				for (int j=0; j< Data.get(i).Len; j++) DataBytes[ix++] = Data.get(i).Values[j];
			}
			msg.set_Data(DataBytes);			
			System.out.println(msg.toString());		
			TCPtimer.schedule(new sendMsg("SetDataND",msg), 10);
		}
	}
	
	void sendGR(sendGRMsg Msg){
		System.out.println(Msg.toString());
		TCPtimer.schedule(new sendMsg("NewProgBlock",Msg), 10);	
	}
}
