

import java.io.IOException;
import java.io.OutputStream;
import java.util.Timer;
import java.util.TimerTask;

import com.rapplogic.xbee.api.PacketListener;
import com.rapplogic.xbee.api.XBee;
import com.rapplogic.xbee.api.XBeeAddress16;
import com.rapplogic.xbee.api.XBeeException;
import com.rapplogic.xbee.api.XBeeResponse;
import com.rapplogic.xbee.api.wpan.RxResponse16;
import com.rapplogic.xbee.api.wpan.TxRequest16;
import com.rapplogic.xbee.api.wpan.TxStatusResponse;


public class XBeeSF
{
    XBee xbee;
    XBeeAddress16 target = new XBeeAddress16(0xff,0xff);
    LogMsg log;
    
    private OutputStream tcpOut;
	private Timer SerialTimer;
	private Integer sendBusyID=null;
	private boolean amProtocol=false;
	public boolean isOpen=false;
	
	public XBeeSF() throws InterruptedException, IOException  {
		super();
		SerialTimer = new Timer();
		xbee = new XBee();
//		log = aLog;
	}

	public void open(String port, int baudrate) throws XBeeException{
        LogMsg.logMsg(LogLevel.DEBUG, "XBee.open(): isOpen="+isOpen);
		xbee.open(port,baudrate);
		isOpen = true;
		xbee.addPacketListener(new PacketListener() {
			@Override
			public void processResponse(XBeeResponse arg0) {
				try {
					XBeeReceived(arg0);
				} catch (IOException e) {
					LogMsg.logMsg(LogLevel.ERROR,e.getMessage());
				}				
			}
		});	
	}

	public void close(){
		amProtocol=false;
		isOpen=false;
		if (xbee.isConnected()) xbee.close();
	}
	
	public void connect(OutputStream aTcpOut) throws IOException{
		LogMsg.logMsg(LogLevel.DEBUG, "XBeeSF:connect() .ThreadId="+Thread.currentThread().getId());			
		tcpOut = aTcpOut;
		byte initMsg[] = new byte[2];
		initMsg[0]= 'U';
		initMsg[1]= ' ';
		try {
			tcpOut.write(initMsg, 0, 2);
			tcpOut.flush();
		} catch (Exception e) {
			LogMsg.logMsg(LogLevel.DEBUG, "XBeeSF:connect() ThreadId="+Thread.currentThread().getId());			
			LogMsg.logMsg(LogLevel.DEBUG, e.getMessage());
		}	
	}

	public void resetProtocol(){amProtocol=false;}
	
	public void write(byte[] buffer, int len, int tcpPort){
		int am_len = 0;
		
		if (!amProtocol) {
			if (buffer[0]=='U') {
				amProtocol=true;
				LogMsg.logMsg(LogLevel.INFO, "AM Protocol initialized! port="+tcpPort);
			}
		} else {
			am_len=buffer[0] & 0xFF;
			if (am_len==len-1) { // Received a complete message
				int payload_len = buffer[6] & 0xFF;
				if ((buffer[1] == 0) && (am_len == ((payload_len+8) & 0xFF))){
					LogMsg.logMsg(LogLevel.DEBUG, "XBeeSF::write() SerialTimer(sendMsg) sendBusy="+sendBusyID);
					SerialTimer.schedule(new sendMsg("xxx",buffer), (sendBusyID==null)?10:200);				
				} else {
					String msgStr="";
					LogMsg.logMsg(LogLevel.ERROR,"####### Received an invalid AM Msg.  port="+tcpPort);
					for (int i=0; i< buffer.length; i++) msgStr=msgStr+":"+ buffer[i];
					LogMsg.logMsg(LogLevel.ERROR,msgStr);
				}

			} else {
				LogMsg.logMsg(LogLevel.ERROR,"####### Received an invalid len! am_len="+am_len+" len="+len+" port="+tcpPort);
			}
		}
	}
	

	private void XBeeReceived(XBeeResponse msg) throws IOException{
		LogMsg.logMsg(LogLevel.DEBUG,"##### Received a XBee message API Id="+msg.getApiId());
		switch (msg.getApiId()) {
		case AT_COMMAND: break;
		case AT_COMMAND_QUEUE: break;
		case AT_RESPONSE: break;
		case ERROR_RESPONSE: break;
		case MODEM_STATUS_RESPONSE: break;
		case REMOTE_AT_REQUEST: break;
		case REMOTE_AT_RESPONSE: break;
		case RX_16_IO_RESPONSE: break;
		case RX_16_RESPONSE:
//			System.out.println("1");
			RxResponse16 recMsg = (RxResponse16)msg;
//			System.out.println("2");
			messageData msgt = new messageData(recMsg.getData());
//			System.out.println("3");
			LogMsg.logMsg(LogLevel.DEBUG,"AMID="+msgt.amid+" XBee len="+recMsg.getLength().getLength());
//			System.out.println("4");
			procMsg(msgt.amid,msgt,msgt.getAMBuffer().length);
//			System.out.println("5");
			break;
		case RX_64_IO_RESPONSE: break;
		case RX_64_RESPONSE: break;
		case TX_REQUEST_16: break;
		case TX_REQUEST_64: break;
		case TX_STATUS_RESPONSE:
			TxStatusResponse sendDone = (TxStatusResponse)msg;
			sendBusyID = null;
			LogMsg.logMsg(LogLevel.DEBUG,"TX_STATUS_RESPONSE sendDone="+sendDone.getStatus());
			break;
		case UNKNOWN: break;
		case ZNET_EXPLICIT_RX_RESPONSE: break;
		case ZNET_EXPLICIT_TX_REQUEST: break;
		case ZNET_IO_NODE_IDENTIFIER_RESPONSE: break;
		case ZNET_IO_SAMPLE_RESPONSE: break;
		case ZNET_RX_RESPONSE: break;
		case ZNET_TX_REQUEST: break;
		case ZNET_TX_STATUS_RESPONSE: break;
		default: break;
			
		}
		
	}
	


	class messageData{
		int target;
		int source;
		int len;
		int group;
		int amid;
		int opt;
		int rssi;
		int metadata;
		byte data[]=new byte[500]; //28
		
		int AMFullLen=0;
		
		// Instantiate from XBee int[] data buffer
		messageData(int[] data){
//			System.out.println("2.1");
			this.target = data[0]*256 + data[1];
			this.source = data[2]*256 + data[3];
			this.len = data[4];
			this.group = data[5];
			this.amid = data[6];
			this.opt = data[7];
			this.rssi = data[8];
			this.metadata = data[9];
//			System.out.println("2.2 len="+this.len);
			LogMsg.logMsg(LogLevel.DEBUG,"messageData::messageData(int[]): len="+this.len);
			for (int i=0; i< this.len; i++) this.data[i] = (byte)data[10+i];			
//			System.out.println("2.3");
		}
		// Instantiate from AM byte[] buffer
		messageData(byte[] data){
			int am_len = data[0];
			int am_zero = data[1];
			this.target = data[2]*256 + data[3];
			this.source = data[4]*256 + data[5];
			this.len = data[6] & 0xFF;
			this.group = data[7] & 0xFF;
			this.amid = data[8] & 0xFF;
			this.opt = 0;
			this.rssi = 0;
			this.metadata = 0;
			LogMsg.logMsg(LogLevel.DEBUG,"messageData::messageData(byte[]): len="+this.len);
			for (int i=0; i< this.len; i++) this.data[i] = (byte)(data[9+i] & 0xFF);			
		}
		
		int[] getXBeeBuffer(){
			int x=0;
			int buf[] = new int[10+this.len];
			buf[x++] = this.target/256; // target H
			buf[x++] = this.target%256; // target L
			buf[x++] = this.source/256; // source H
			buf[x++] = this.source%256; // source L
			buf[x++] = this.len;
			buf[x++] = this.group;
			buf[x++] = this.amid;
			buf[x++] = this.opt;
			buf[x++] = this.rssi;
			buf[x++] = this.metadata;
			for (int i=0; i< this.len; i++) buf[x+i] = this.data[i];			
			return buf;
		}

		byte[] getAMBuffer(){
			byte x=0;
			byte buf[] = new byte[1+1+7+this.len];
			buf[x++] = (byte) (1+7+this.len);
			buf[x++] = 0;
			buf[x++] = (byte) (this.target/256); // target H
			buf[x++] = (byte) (this.target%256); // target L
			buf[x++] = (byte) (this.source/256); // source H
			buf[x++] = (byte) (this.source%256); // source L
			buf[x++] = (byte) this.len;
			buf[x++] = 0x22; //(byte) this.group;
			buf[x++] = (byte) this.amid;
			for (int i=0; i< this.len; i++) buf[x+i] = this.data[i];
			return buf;
		}
	}
	

	
	private void procMsg(int amId, messageData msg, int len) throws IOException {
		LogMsg.logMsg(LogLevel.DEBUG,"messageReceived:: Type="+ amId + " size="+msg.getAMBuffer().length +":"+ msg.len+" ThreadId="+Thread.currentThread().getId());
		String msgStr = "";
		byte buffer[] = msg.getAMBuffer();
		for (int i=0; i< msg.getAMBuffer().length; i++) msgStr=msgStr+":"+ buffer[i];
		LogMsg.logMsg(LogLevel.DEBUG,msgStr);
		try {
			tcpOut.write(msg.getAMBuffer(), 0, msg.getAMBuffer().length);
			tcpOut.flush();
		} catch (Exception e) {
			LogMsg.logMsg(LogLevel.ERROR, "procMsg(): ThreadId="+Thread.currentThread().getId());
			LogMsg.logMsg(LogLevel.ERROR, e.getMessage());
		}
	}
	
	class sendMsg extends TimerTask{
		messageData msg;
		String name;
		public sendMsg(String Name, byte[] Msg){
			this.name=Name;
			msg = new messageData(Msg);
			LogMsg.logMsg(LogLevel.DEBUG,"Send2XBee:: len="+(msg.len));
			String msgStr = "";
			for (int i=0; i < (Msg[0] & 0xFF); i++) msgStr=msgStr+":"+ (Msg[i+1]);
			LogMsg.logMsg(LogLevel.DEBUG,msgStr);
			sendBusyID = msg.amid;
		}
		@Override
		public void run() {
			TxRequest16 xMsg = new TxRequest16(target,1, msg.getXBeeBuffer());
			LogMsg.logMsg(LogLevel.DEBUG, "sendMsg:run() len="+msg.len + " XBeeBufferLen="+msg.getXBeeBuffer().length);
			try {
				xbee.sendPacket(xMsg.getXBeePacket());
			} catch (IOException e) {
				LogMsg.logMsg(LogLevel.ERROR, "sendMsg:run()");
				LogMsg.logMsg(LogLevel.ERROR, e.getMessage());
			}
		}
	}
}


