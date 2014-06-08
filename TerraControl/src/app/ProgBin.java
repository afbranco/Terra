package app;
import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.InputStreamReader;


public class ProgBin {
	static short BLOCK_SIZE = 24;
	static short MAX_BLOCKS = 80; //16;
	static int MAX_TABLE_LEN = BLOCK_SIZE * MAX_BLOCKS;

	
	private short numBlocks;
	private short blockStart;
	private int startProg;
	private int labelTable11;
	private int labelTable12;
	private int labelTable21;
	private int labelTable22;
	private int labelTableEnd;
	private int nTracks;
	private int wClocks;
	private int wClock0;
	private int gate0;
	
	short[][] ProgData= new short[MAX_BLOCKS][BLOCK_SIZE];

	ProgBin(String vmxFile){
		String FileName = vmxFile;
		System.out.printf("ProgBin:file=%s\n",FileName);
		resetProgData();
		ReadFile(FileName);
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
	public int getLabelTable11() {return labelTable11;}
	public int getLabelTable12() {return labelTable12;}
	public int getLabelTable21() {return labelTable21;}
	public int getLabelTable22() {return labelTable22;}
	public int getLabelTableEnd() {return labelTableEnd;}
	public int getNTracks() {return nTracks;}
	public int getWClocks() {return wClocks;}
	public int getWClock0() {return wClock0;}
	public int getGate0() {return gate0;}
	
	public void ReadFile(String FileName) {
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
				if (params.length==10){
					startProg = Integer.decode(params[0]);
					labelTable11 = Integer.decode(params[1]);
					labelTable12 = Integer.decode(params[2]);
					labelTable21 = Integer.decode(params[3]);
					labelTable22 = Integer.decode(params[4]);
					labelTableEnd = Integer.decode(params[5]);					
					nTracks = Integer.decode(params[6]);					
					wClocks = Integer.decode(params[7]);
					wClock0 = Integer.decode(params[8]);
					gate0 = Integer.decode(params[9]);
				}
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
			e.printStackTrace();
		}			
	}


}
