package app;
import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.InputStreamReader;


public class ProgBin {
	static short BLOCK_SIZE = 24;
	static short MAX_BLOCKS = 80; //16;
	static int MAX_TABLE_LEN = BLOCK_SIZE * MAX_BLOCKS;

	private String lastError;
	
	private short numBlocks;
	private short blockStart;
	private int startProg;
	private int endProg;
	private int nTracks;
	private int wClocks;
	private int asyncs;
	private int wClock0;
	private int gate0;
	private int inEvts;
	private int async0;
	
	short[][] ProgData= new short[MAX_BLOCKS][BLOCK_SIZE];

	ProgBin(String vmxFile){
		String FileName = vmxFile;
		System.out.printf("ProgBin:file=%s\n",FileName);
		resetProgData();
		lastError = ReadFile(FileName);
	}

	private void resetProgData(){
		for (short blk=0; blk<MAX_BLOCKS; blk++)
			for (short x=0; x<BLOCK_SIZE; x++)
				ProgData[blk][x]=0;
	}
	
	public short getNumBlocks(){return numBlocks;}
	public short[] getProgBlock(short Block){return ProgData[Block];}
	public short getBlockStart() {return blockStart;}
	public int getStartProg() {return startProg;}
	public int getEndProg() {return endProg;}
	public int getNTracks() {return nTracks;}
	public int getWClocks() {return wClocks;}
	public int getAsyncs() {return asyncs;}
	public int getWClock0() {return wClock0;}
	public int getGate0() {return gate0;}
	public int getInEvts() {return inEvts;}
	public int getAsync0() {return async0;}

	public String getLastError() {return lastError;}
	
	public String ReadFile(String FileName) {
		short blockCount = 0;
		int byteCount;
		try {
			FileInputStream fstream = new FileInputStream(FileName);
			DataInputStream in = new DataInputStream(fstream);
			BufferedReader br = new BufferedReader(new InputStreamReader(in));
			String strLine;
			// Read first line to get environment parameters
			if (((strLine = br.readLine()) != null)){
				String params[] = strLine.split(" ");
				if (params.length==9){
					startProg = Integer.decode(params[0]);
					endProg = Integer.decode(params[1]);
					nTracks = Integer.decode(params[2]);					
					wClocks = Integer.decode(params[3]);
					asyncs = Integer.decode(params[4]);
					wClock0 = Integer.decode(params[5]);
					gate0 = Integer.decode(params[6]);
					inEvts = Integer.decode(params[7]);
					async0 = Integer.decode(params[8]);
				} else {
					br.close();
					return (String)(".vmx format error - incompatible header line.");	
				}
			} else {
				br.close();
				return (String)(".vmx format error - empty file.");	
			}

			
			//Read File Line By Line
			blockStart = (short)Math.floor(startProg/BLOCK_SIZE);
			while ((strLine = br.readLine()) != null)   {
				short xByte = Short.decode("0x"+strLine.substring(0,2));
				short xAddr = (short) (Short.decode("1"+strLine.substring(5,9)) - 10000);
				System.out.println(xAddr+" "+xByte+" |"+strLine);
				blockCount = (short)Math.floor(xAddr/BLOCK_SIZE);
				byteCount = (short) (xAddr%BLOCK_SIZE);
				ProgData[blockCount][byteCount]=xByte;;
			}
			numBlocks = (short)(blockCount+1-blockStart);
			//Close the input stream
			in.close();
		} catch (Exception e) {
			return (String)(".vmx format error."+ e.getMessage());	
		}			
		return (String)("");
	}


}
