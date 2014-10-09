package app;

import java.io.IOException;
import java.io.PrintStream;
import java.net.Socket;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

import com.rapplogic.xbee.api.PacketListener;
import com.rapplogic.xbee.api.XBee;
import com.rapplogic.xbee.api.XBeeAddress16;
import com.rapplogic.xbee.api.XBeeException;
import com.rapplogic.xbee.api.XBeePacket;
import com.rapplogic.xbee.api.XBeeResponse;
import com.rapplogic.xbee.api.wpan.RxResponse16;
import com.rapplogic.xbee.api.wpan.TxRequest16;
import com.rapplogic.xbee.api.wpan.TxStatusResponse;

import messages.*;
import net.tinyos.message.Message;
import net.tinyos.message.MessageListener;
//import net.tinyos.message.MoteIF;
import net.tinyos.packet.BuildSource;
import net.tinyos.packet.PhoenixSource;
import net.tinyos.tools.PrintfMsg;
import net.tinyos.util.Messenger;
import net.tinyos.util.PrintStreamMessenger;

public class ControlCoreXBee
//public class ControlCoreXBee implements MessageListener
{
    XBee xbee;
    XBeeAddress16 target = new XBeeAddress16(0xff,0xff);
    
	private ControlForm controlform;
	private ProgBin progBin; 
	private String port;
	private int baudrate;
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
	
// Control block send
	int startBlockId;
	int nextBlockId;
	int lastBlockId;
	Timer SendBlocktimer;
	int sendBusyID=0;
	boolean sendBlockMultiple=false;

	public ControlCoreXBee(ControlForm Form,String Port,int Baudrate) throws InterruptedException, IOException  {
		super();
		controlform = Form;
		baudrate=Baudrate; // "localhost";
		port=Port; // 9002;
		TCPretries = 0;
//		serviceOFF = true;
		SendBlocktimer = new Timer();
		TCPtimer = new Timer();
		TCPtimer.schedule(new tryConnect(), 0);
	}

	class tryConnect extends TimerTask {
        public void run() {
			controlform.setTCP(false, TCPretries);
        	try {
				retryConnect();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
        }
    }


	public void retryConnect() throws IOException {
		// TCP/IP Connection
		controlform.appendControlMsg("ControlCore: Retry Serial connection.");
		try {
			if (xbee==null) xbee = new XBee();
			xbee.open(port,baudrate);
		} catch (XBeeException e) {
			TCPtimer.schedule(new tryConnect(), 5000);
			return;
			//e.printStackTrace();
		}
		
		
		xbee.addPacketListener(new PacketListener() {
			@Override
			public void processResponse(XBeeResponse arg0) {
				// TODO Auto-generated method stub
				XBeeReceived(arg0);				
			}
		});		controlform.setTCP(true, TCPretries);
/*		
		phoenix = BuildSource.makePhoenix("serial@/dev/ttyUSB0:micaz", PrintStreamMessenger.err);
		mote = new ControlMoteIF(PrintStreamMessenger.err,controlform);
		mote.setPacketErrorHandler();
		mote.registerListener(new reqProgBlockMsg(), this);
		mote.registerListener(new reqDataMsg(), this);
		mote.registerListener(new sendBSMsg(), this);
		mote.registerListener(new PrintfMsg(), this);
		mote.registerListener(new usrMsg(), this);
*/
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


	private void XBeeReceived(XBeeResponse msg){
		System.out.println("##### Received a XBee message API Id="+msg.getApiId());
		switch (msg.getApiId()) {
		case AT_COMMAND:
			break;
		case AT_COMMAND_QUEUE:
			break;
		case AT_RESPONSE:
			break;
		case ERROR_RESPONSE:
			break;
		case MODEM_STATUS_RESPONSE:
			break;
		case REMOTE_AT_REQUEST:
			break;
		case REMOTE_AT_RESPONSE:
			break;
		case RX_16_IO_RESPONSE:
			break;
		case RX_16_RESPONSE:
			RxResponse16 recMsg = (RxResponse16)msg;
			System.out.println("AMID="+recMsg.getData()[0]+" len="+recMsg.getLength().getLength());
			procMsg(recMsg.getData()[0],recMsg.getData(),recMsg.getLength().getLength());
			break;
		case RX_64_IO_RESPONSE:
			break;
		case RX_64_RESPONSE:
			break;
		case TX_REQUEST_16:
			break;
		case TX_REQUEST_64:
			break;
		case TX_STATUS_RESPONSE:
			TxStatusResponse sendDone = (TxStatusResponse)msg;
			System.out.println("SendDone="+sendDone.getStatus()+" sendBusyID="+sendBusyID+" nextBlockId="+nextBlockId+" lastBlockId="+lastBlockId+" BlkMultiple="+sendBlockMultiple);
			if (sendBusyID==newProgBlockMsg.AM_TYPE){
				nextBlockId++;
				if (sendBlockMultiple && nextBlockId <= lastBlockId){
					SendBlocktimer.schedule(new sendNewProgBlockTask(nextBlockId), 100);
					System.out.println("------> Agendei o timer outra vez!");
				} else {
					sendBlockMultiple = false;
					nextBlockId = startBlockId;
				}
			}
			sendBusyID = 0;
			break;
		case UNKNOWN:
			break;
		case ZNET_EXPLICIT_RX_RESPONSE:
			break;
		case ZNET_EXPLICIT_TX_REQUEST:
			break;
		case ZNET_IO_NODE_IDENTIFIER_RESPONSE:
			break;
		case ZNET_IO_SAMPLE_RESPONSE:
			break;
		case ZNET_RX_RESPONSE:
			break;
		case ZNET_TX_REQUEST:
			break;
		case ZNET_TX_STATUS_RESPONSE:
			break;
		default:
			break;
			
		}
		
	}
	

	class message_t{
		int amid;
		int group;
		int source;
		int target;
		int opt;
		int rssi;
		int len;
		int metadata;
		byte data[]=new byte[28];
		
		message_t(int[] data){
			this.amid = data[0];
			this.group = data[1];
			this.source = data[2]*256 + data[3];
			this.target = data[4]*256 + data[5];
			this.opt = data[6];
			this.rssi = data[7];
			this.len = data[8];
			this.metadata = data[9];
			for (int i=0; i< this.len; i++) this.data[i] = (byte)data[10+i];			
		}
		
		message_t(Message Msg){
			this.amid = Msg.amType();
			this.group = 0;
			this.source = 0;
			this.target = 0xffff;
			this.opt = 0;
			this.rssi = 0;
			this.len = Msg.dataLength();
			this.metadata = 0;
			for (int i=0; i< this.len; i++) this.data[i] = Msg.dataGet()[i];
		}
		
		int[] getBuffer(){
			int buf[] = new int[10+this.len];
			buf[0] = this.amid;
			buf[1] = this.group;
			buf[2] = this.source/256; // source H
			buf[3] = this.source%256; // source L
			buf[4] = this.target/256; // target H
			buf[5] = this.target%256; // target L
			buf[6] = this.opt;
			buf[7] = this.rssi;
			buf[8] = this.len;
			buf[9] = this.metadata;
			for (int i=0; i< this.len; i++) buf[10+i] = this.data[i];			
			return buf;
		}
		
		int getBufferLen(){
			return (10+this.len);
		}
	}
	
	class sendNewProgBlockTask extends TimerTask {
		int blkId;
		sendNewProgBlockTask(int BlkId){
			this.blkId = BlkId;
		}
        public void run() {
        	System.out.println("sendNewProgBlockTask():: blkId="+blkId);
			sendNewProgBlock(blkId);				
        }
    }

	
	private void procMsg(int amId, int[] msg, int len) {
		System.out.println("messageReceived:: Type="+ amId + " size="+len);

		// Received a reqProgBlockMsg
		if (amId == reqProgBlockMsg.AM_TYPE) {
			message_t recMsg = new message_t(msg);
			reqProgBlockMsg omsg = new reqProgBlockMsg(recMsg.data,0,recMsg.len);
			System.out.println("ReqOper="+omsg.get_reqOper()+" VersionId="+omsg.get_versionId()+" BlockId="+omsg.get_blockId());
			
			if (omsg.get_versionId() == 0){
				System.out.println("Ignoring a Startup BlockRequest from mote "+recMsg.source);
				return;
			}
			if (omsg.get_blockId() < startBlockId || omsg.get_blockId() > lastBlockId){
				System.out.println("Ignoring a invalid BlockRequest from mote "+recMsg.source);
				return;
			}
			VersionId = omsg.get_versionId();
			System.out.println(omsg.toString());

			if (omsg.get_reqOper() == 2) sendBlockMultiple = true; // 2= RO_DATA_FULL
			if (progBin!=null){
				controlform.recReqProgBlockMsg(progBin.getBlockStart(),omsg.get_blockId(),progBin.getNumBlocks());
				nextBlockId = omsg.get_blockId();
				SendBlocktimer.schedule(new sendNewProgBlockTask(nextBlockId), 10);
				System.out.println("------> Agendei o timer na primeira vez!");
			}

		}

		// Received a reqDataMsg
		if (amId == reqDataMsg.AM_TYPE) {
			message_t recMsg = new message_t(msg);
			reqDataMsg omsg = new reqDataMsg(recMsg.data,0,recMsg.len);
			if (progBin.isValid())
				controlform.recReqDataMsg(omsg.get_versionId(),omsg.get_seq());
			System.out.println(omsg.toString());
			sendNewSetData(omsg.get_seq());
		}

		// Received a sendBS
		if (amId == sendBSMsg.AM_TYPE) {
			message_t recMsg = new message_t(msg);
			sendBSMsg omsg = new sendBSMsg(recMsg.data,0,recMsg.len);
			String Data="";
			for (int i=0;i<16;i++) Data = Data + String.format("%02x,", omsg.getElement_Data(i));
			controlform.sendBSMsg(omsg.get_Sender(),omsg.get_evtId(),omsg.get_seq(),Data);
			System.out.println(omsg.toString());
		}
		// Received a PrintfMsg
		if (amId == PrintfMsg.AM_TYPE) {
			message_t recMsg = new message_t(msg);
			PrintfMsg omsg = new PrintfMsg(recMsg.data,0,recMsg.len);
			controlform.PrintfMsg(omsg.getString_buffer());
		}
		// Received a usrMsg
		if (amId == usrMsg.AM_TYPE) {
			message_t recMsg = new message_t(msg);
			usrMsg omsg = new usrMsg(recMsg.data,0,recMsg.len);
			String Data="";
			System.out.println("MsgType="+controlform.getMsgType());
			if (controlform.getMsgType()) {				
				for (int i=0; i<20; i++) {
					Data = Data + String.format("%02x,",omsg.get_data()[i]); 				
				}
			} else{ 
				for (int i=0; i<4; i++) {
					Data = Data + String.format("%d,",omsg.get_data()[i]); 				
				}
				for (int i=4; i<12; i=i+2) {
					Data = Data + String.format("%d,",(omsg.get_data()[i] << 8) + omsg.get_data()[i+1]); 				
				}
				for (int i=12; i<20; i=i+4) {
					Data = Data + String.format("%d,",(omsg.get_data()[i] << 24) + (omsg.get_data()[i+1] << 16) + (omsg.get_data()[i+2] * 8) + omsg.get_data()[i+3]); 				
				}
			}
			controlform.sendBSMsg(omsg.get_source(),omsg.get_type(),0,Data);
			System.out.println(omsg.toString());
		}

	}
	
	class sendMsg extends TimerTask{
		message_t msg;
		String name;
		public sendMsg(String Name, Message Msg){
			this.name=Name;
			msg = new message_t(Msg);
			sendBusyID = Msg.amType();
		}
		@Override
		public void run() {
			TxRequest16 xMsg = new TxRequest16(target,1, msg.getBuffer());
			try {
				xbee.sendPacket(xMsg.getXBeePacket());
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
/*
	class sendMsg2 extends TimerTask {
		Message msg;
		String name;
		public sendMsg2(String Name, Message Msg){
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
*/
	
	
	/**
	 * Send a specific program block
	 * @param BlockId	Requested data block number
	 */
	void sendNewProgBlock(int BlockId){
		controlform.appendControlMsg("ControlCore: sendNewProgBlock()");

		newProgBlockMsg msg = new newProgBlockMsg();

		msg.set_blockId(BlockId);
		msg.set_versionId(VersionId);
		
		short[] ProgBlock = progBin.getProgBlock(BlockId);
		msg.set_data(ProgBlock);
		System.out.println(">>>> sendNewProgBlock >>>>");
		System.out.println(msg.toString());
		TCPtimer.schedule(new sendMsg("NewProgBlock",msg), 10);
		controlform.updateLoadBar(startBlockId, BlockId);
	}


	void sendNewProgVersion(){
		controlform.appendControlMsg("ControlCore: sendNewProgVersion()");
		newProgVersionMsg msg = new newProgVersionMsg();

		VersionId++;
		msg.set_versionId(VersionId);
		msg.set_blockLen(progBin.getNumBlocks());
		msg.set_blockStart(progBin.getBlockStart());
		msg.set_startProg(progBin.getStartProg());
		msg.set_endProg(progBin.getEndProg());
		msg.set_nTracks(progBin.getNTracks());
		msg.set_wClocks(progBin.getWClocks());
		msg.set_asyncs(progBin.getAsyncs());
		msg.set_wClock0(progBin.getWClock0());
		msg.set_gate0(progBin.getGate0());
		msg.set_inEvts(progBin.getInEvts());
		msg.set_async0(progBin.getAsync0());
		
		startBlockId = progBin.getBlockStart();
		nextBlockId = startBlockId;
		lastBlockId = startBlockId + progBin.getNumBlocks() - 1;

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
			//msg.set_Data(DataBytes);	// comentei porque stava dando erro...
			System.out.println(msg.toString());		
			TCPtimer.schedule(new sendMsg("SetDataND",msg), 10);
		}
	}
	
	void sendGR(sendGRMsg Msg){
		System.out.println(Msg.toString());
		TCPtimer.schedule(new sendMsg("NewProgBlock",Msg), 10);	
	}
}
