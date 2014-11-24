
import java.io.*; 
import java.net.*;


enum LogLevel {ERROR,INFO,DEBUG}

/** 
 * TCPForwardServer is a simple TCP bridging software that 
 * allows a TCP port on some host to be transparently forwarded 
 * to some other TCP port on some other host. TCPForwardServer 
 * continuously accepts client connections on the listening TCP 
 * port (source port) and starts a thread (ClientThread) that 
 * connects to the destination host and starts forwarding the 
 * data between the client socket and destination socket. 
 */ 
public class XBeeForward {

    public static boolean logFlagNoOutput=false;
    public static boolean logFlagQuiet=false;
    public static boolean logFlagDebug=false;
    public static boolean displayHelp=false;
    
    public static int baudrate = 57600;
    public static String serialPort= "/dev/ttyUSB0";
    public static int serverPort = 9002;//9001;
    
    public static LogMsg log;
    public static boolean connectionOpen=false;
    static int clientCount=0;
    
    public static void main(String[] args) throws IOException, InterruptedException { 
    	LogMsg.logMsg(LogLevel.DEBUG, "main()");
    	// Add shutdown signal
    	Runtime.getRuntime().addShutdownHook(new Thread() {
            @Override
                public void run() {
                    System.out.println("Received signal to exit.");
                }   
            }); 
    	
    	//    	log = new LogMsg();

    	LogMsg.logMsg(LogLevel.INFO, "------  XBeeForward Tool  ------");
    	ProcessCommandLineArgs(args);
    	if (displayHelp) {
    		printHelp();
    		System.exit(2);
    	}
    	ServerSocket serverSocket;
		try {
			serverSocket = new ServerSocket(serverPort);
	        XBeeSF xbee = new XBeeSF();
	        while (true) {
	            Socket clientSocket = serverSocket.accept();
	            clientCount++;
		        LogMsg.logMsg(LogLevel.DEBUG, "serverSocket.accept() clientCount="+clientCount+"");
	            // Connect to the destination server 
	        	if (!xbee.isOpen) xbee.open(XBeeForward.serialPort,XBeeForward.baudrate); 
	            ClientThread clientThread = new ClientThread(clientSocket, xbee); 
	            clientThread.start(); 
	        } 
		} catch (Exception e) {
            LogMsg.logMsg(LogLevel.DEBUG, " new ServerSocket(serverPort)/new XBeeSF()");
			LogMsg.logMsg(LogLevel.ERROR,e.getMessage());
    		System.exit(2);
		} 
    } 

    
static void ProcessCommandLineArgs(String[] args) {
	for (int i = 0; i < args.length; i++) {
		if(args[i].equals("-no-output")) {
			logFlagNoOutput=true;
		} else if (args[i].equals("-port")) {
			i++;
			if (i < args.length) {
				try {
					baudrate = Integer.parseInt(args[i]);
				} catch (NumberFormatException e) {
					displayHelp = true;
					LogMsg.logMsg(LogLevel.ERROR,"Invalid local TCP port.");
				}
			} else {
				displayHelp = true;
			}
		} else if (args[i].equals("-baud")) {
			i++;
			if (i < args.length) {
				try {
					baudrate = Integer.parseInt(args[i]);
				} catch (NumberFormatException e) {
					displayHelp = true;
					LogMsg.logMsg(LogLevel.ERROR,"Invalid baudrate value.");
				}
			} else {
				displayHelp = true;
			}

		} else if (args[i].equals("-serial")) {
			i++;
			if (i < args.length) {
				serialPort = args[i];
			} else {
				displayHelp = true;
			}
		} else if (args[i].equals("-quiet")) {
			logFlagQuiet = false;
		} else if (args[i].equals("-debug")) {
			logFlagDebug = true;
		} else {
			displayHelp = true;
		}
	}
}

      private static void printHelp() {
        System.err.println("optional arguments:");
        System.err.println("-serial [USB port] (default " + serialPort + ")");
        System.err.println("-baud [Serial baudrate] (default "+ baudrate + ")");
        System.err.println("-port [TCP port] (default "+ serverPort + ")");
        System.err.println("-no-output");
        System.err.println("-quiet       = non-verbose mode");
        System.err.println("-debug       = display debug messages");
      }
      
} 
 

class LogMsg {
	   public static void logMsg(LogLevel level, String msg){
	    	boolean log=false;
	    	String preMsg="";
	    	if (!XBeeForward.logFlagNoOutput){
	    		switch (level){
	    		case DEBUG:
	    			if (XBeeForward.logFlagDebug) {
	        			preMsg="DBG: ";
	    				log=true;
	    			}
	    			break;
	    		case ERROR:
	    			preMsg="ERROR: ";
	    			log=true;
	    			break;
	    		case INFO:
	    			preMsg=" ";
	    			if (!XBeeForward.logFlagQuiet) log=true;
	    			break;
	    		default:
	    			break;
	    		}
	    	}
	    	if (log) System.out.println(preMsg+msg);
	    }
	 	
}

/** 
 * ClientThread is responsible for starting forwarding between 
 * the client and the server. It keeps track of the client and 
 * servers sockets that are both closed on input/output error 
 * durinf the forwarding. The forwarding is bidirectional and 
 * is performed by two ForwardThread instances. 
 */ 
class ClientThread extends Thread { 
    private Socket mClientSocket; 
    private XBeeSF xbee; 
    private boolean mForwardingActive = false; 
 
    public ClientThread(Socket aClientSocket, XBeeSF aXbee) { 
        mClientSocket = aClientSocket; 
        xbee = aXbee;
    } 
 
    /** 
     * Establishes connection to the destination server and 
     * starts bidirectional forwarding of data between the 
     * client and the server. 
     */ 
    public void run() { 
        LogMsg.logMsg(LogLevel.DEBUG, "ClientThread:run() ThreadId="+Thread.currentThread().getId());
        InputStream clientIn; 
        OutputStream clientOut;  
        try { 
            // Turn on keep-alive for the sockets 
        	if (mClientSocket.isConnected()){
        		mClientSocket.setKeepAlive(true);
            // Obtain client & server input & output streams 
            clientIn = mClientSocket.getInputStream(); 
            clientOut = mClientSocket.getOutputStream(); 
            mForwardingActive = true; 
            XBeeForward.connectionOpen=true;
            ForwardThread clientForward = new ForwardThread(this, clientIn, xbee,mClientSocket.getPort()); 
            clientForward.start(); 
            ForwardThread serverForward = new ForwardThread(this, xbee, clientOut,mClientSocket.getPort());
            serverForward.start(); 
     
            LogMsg.logMsg(LogLevel.INFO,"Connection " + 
                mClientSocket.getInetAddress().getHostAddress() + 
                ":" + mClientSocket.getPort()+"["+mClientSocket.getLocalPort()+"] <--> " + 
                XBeeForward.serialPort + 
                ":" + XBeeForward.baudrate + " started."); 
        	} else {
        		connectionBroken();
        	}
        } catch (IOException ioe) { 
        	LogMsg.logMsg(LogLevel.ERROR, ioe.getMessage());
        	LogMsg.logMsg(LogLevel.ERROR,"Can not connect to " + XBeeForward.serialPort + ":" + XBeeForward.baudrate); 
            connectionBroken(); 
            return; 
        } 
 
        // Start forwarding data between server and client 
    } 
 
    /** 
     * Called by some of the forwarding threads to indicate 
     * that its socket connection is brokean and both client 
     * and server sockets should be closed. Closing the client 
     * and server sockets causes all threads blocked on reading 
     * or writing to these sockets to get an exception and to 
     * finish their execution. 
     */ 
    public synchronized void connectionBroken() { 
        XBeeForward.clientCount--;
        LogMsg.logMsg(LogLevel.DEBUG, "connectionBroken(): clientCount="+XBeeForward.clientCount+" ThreadId="+Thread.currentThread().getId());

        if (XBeeForward.clientCount==0){
        try {
    		xbee.close();
        } catch (Exception e) {
        	LogMsg.logMsg(LogLevel.ERROR, "xbee.close()");
        	LogMsg.logMsg(LogLevel.ERROR, e.getMessage());
        } 
        }
        try { 
        	if (!mClientSocket.isClosed()) mClientSocket.close();  
        } catch (Exception e) {
        	LogMsg.logMsg(LogLevel.ERROR, "mClientSocket.close()");
        	LogMsg.logMsg(LogLevel.ERROR, e.getMessage());
        } 
 
        if (mForwardingActive) { 
        	LogMsg.logMsg(LogLevel.INFO,"Connection " + 
                mClientSocket.getInetAddress().getHostAddress() 
                + ":" + mClientSocket.getPort()+"["+mClientSocket.getLocalPort()+"] <--> " + 
                XBeeForward.serialPort 
                + ":" + XBeeForward.baudrate + " stopped."); 
            mForwardingActive = false;
            XBeeForward.connectionOpen=false;
        } 
    } 
} 
 
/** 
 * ForwardThread handles the TCP forwarding between a socket 
 * input stream (source) and a socket output stream (dest). 
 * It reads the input stream and forwards everything to the 
 * output stream. If some of the streams fails, the forwarding 
 * stops and the parent is notified to close all its sockets. 
 */ 
class ForwardThread extends Thread { 
    private static final int BUFFER_SIZE = 512;
    enum fDir {X2TCP, TCP2X};
    private fDir direction;
 
    InputStream mInputStream;
    OutputStream mOutputStream; 
    XBeeSF xbee; 
    ClientThread mParent;
    static int tcpPort;
 
    /** 
     * Creates a new traffic redirection thread specifying 
     * its parent, input stream and output stream. 
     */ 
    public ForwardThread(ClientThread aParent, InputStream aInputStream, XBeeSF axbee, int aTcpPort) { 
        LogMsg.logMsg(LogLevel.DEBUG, "ForwardThread(TCP2X) TcpPort="+ aTcpPort+ " ThreadId="+Thread.currentThread().getId());
        mParent = aParent; 
        mInputStream = aInputStream; 
        xbee = axbee;
        direction = fDir.TCP2X;
        tcpPort=aTcpPort;
    } 

    public ForwardThread(ClientThread aParent, XBeeSF axbee, OutputStream aOutputStream, int aTcpPort) { 
        LogMsg.logMsg(LogLevel.DEBUG, "ForwardThread(X2TCP)TcpPort="+ aTcpPort + " ThreadId="+Thread.currentThread().getId());
        mParent = aParent; 
        xbee = axbee; 
        mOutputStream = aOutputStream; 
        direction = fDir.X2TCP;
        tcpPort=aTcpPort;
    } 

    /** 
     * Runs the thread. Continuously reads the input stream and 
     * writes the read data to the output stream. If reading or 
     * writing fail, exits the thread and notifies the parent 
     * about the failure. 
     */ 
    public void run() { 
        LogMsg.logMsg(LogLevel.DEBUG, "ForwardThread:run() TcpPort="+ tcpPort+ " ThreadId="+Thread.currentThread().getId());
    	if (direction == fDir.X2TCP){
    		try {
				xbee.connect(mOutputStream);
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
    	} else {
	        byte[] buffer = new byte[BUFFER_SIZE]; 
	        try { 
	        	while (true) { 
	        		int len = mInputStream.read();
	        		//LogMsg.logMsg(LogLevel.DEBUG, "1st byte="+len);
	        		if (len == -1) break; // End of stream is reached --> exit
	        		if (len == 'U'){ 
	        			int blank = mInputStream.read();
	        			//LogMsg.logMsg(LogLevel.DEBUG, "U 2nd byte="+blank);
	        			if (blank == -1) break; // End of stream is reached --> exit
	        			if (blank==' '){ // AM startup protocol
	        				LogMsg.logMsg(LogLevel.DEBUG, "Reset protocol");
	        				xbee.resetProtocol();
	        				buffer[0]='U'; buffer[1]=(byte) blank; 
	        				xbee.write(buffer,2,tcpPort); 	                
	        			} else if (blank==0){ // May be an AM message
	        				buffer[0]=(byte)len; buffer[1]=(byte) blank;
		        			//LogMsg.logMsg(LogLevel.DEBUG, "n 2nd byte="+blank);
	        				int pendLen=len-1;
	        				int offSet=2;
	        				int bytesRead=0;
	        				while (pendLen>0){
	    	        			//LogMsg.logMsg(LogLevel.DEBUG, "< pendLen="+pendLen+" offSet="+offSet);
	        					bytesRead = mInputStream.read(buffer, offSet, pendLen);
		    	        		if (bytesRead == -1) break; // End of stream is reached --> exit
	        					pendLen = pendLen - bytesRead;
	        					offSet = offSet + bytesRead;
	    	        			//LogMsg.logMsg(LogLevel.DEBUG, "> pendLen="+pendLen+" offSet="+offSet);
	    	        			//LogMsg.logMsg(LogLevel.DEBUG, "n +bytes="+bytesRead);
	        				}
	    	        		if (bytesRead == -1) break; // End of stream is reached --> exit
		        			LogMsg.logMsg(LogLevel.DEBUG, "SF->XBeeSF write "+ (len+1));
	    	        		xbee.write(buffer,len+1,tcpPort); 
	        			}
	        		} else if (len>0) { // Normal AM message
        				buffer[0]=(byte)len;
        				int pendLen=len;
        				int offSet=1;
        				int bytesRead=0;
        				while (pendLen>0){
    	        			//LogMsg.logMsg(LogLevel.DEBUG, "[ pendLen="+pendLen+" offSet="+offSet);
        					bytesRead = mInputStream.read(buffer, offSet, pendLen);
	    	        		if (bytesRead == -1) break; // End of stream is reached --> exit
        					pendLen = pendLen -bytesRead;
        					offSet = offSet + bytesRead;
    	        			//LogMsg.logMsg(LogLevel.DEBUG, "] pendLen="+pendLen+" offSet="+offSet);
    	        			//LogMsg.logMsg(LogLevel.DEBUG, "n +bytes="+bytesRead);
        				}
    	        		if (bytesRead == -1) break; // End of stream is reached --> exit
	        			LogMsg.logMsg(LogLevel.DEBUG, "SF->XBeeSF write "+ (len+1));
    	        		xbee.write(buffer,len+1,tcpPort); 
	        		} else {
	        			LogMsg.logMsg(LogLevel.DEBUG, "Invalid len=0");
	        		}
	        	} 
	        } catch (IOException e) { 
	            // Read/write failed --> connection is broken 
	        } 
	        LogMsg.logMsg(LogLevel.DEBUG, "Client thread exit  TcpPort="+ tcpPort);
	        // Notify parent thread that the connection is broken 
	        mParent.connectionBroken(); 
    	}
    } 



}

