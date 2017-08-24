/*
  	Terra IoT System - A small Virtual Machine and Reactive Language for IoT applications.
  	Copyright (C) 2014-2017  Adriano Branco
	
	This file is part of Terra IoT.
	
	Terra IoT is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Terra IoT is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Terra IoT.  If not, see <http://www.gnu.org/licenses/>.  
*/ 
package app;
import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.InputStreamReader;


public class ProgBin {
	static short BLOCK_SIZE = 22;
	static int MAX_BLOCKS = 500; //16;
	static int MAX_TABLE_LEN = BLOCK_SIZE * MAX_BLOCKS;
	private boolean validProg=false;

	private String lastError;
	
	private int numBlocks;
	private int blockStart;
	private int startProg;
	private int endProg;
	private int nTracks;
	private int wClocks;
	private int asyncs;
	private int wClock0;
	private int gate0;
	private int inEvts;
	private int async0;
	private int appSize;
	private boolean persistFlag;
	
	short[][] ProgData= new short[MAX_BLOCKS][BLOCK_SIZE];

	ProgBin(String vmxFile){
		String FileName = vmxFile;
		System.out.printf("ProgBin:file=%s\n",FileName);
		resetProgData();
		lastError = ReadFile(FileName);
		if (lastError=="") validProg=true;
	}

	private void resetProgData(){
		validProg=false;
		for (int blk=0; blk<MAX_BLOCKS; blk++)
			for (int x=0; x<BLOCK_SIZE; x++)
				ProgData[blk][x]=0;
	}
	
	public boolean isValid(){return validProg;}
	public int getNumBlocks(){return numBlocks;}
	public short[] getProgBlock(int Block){return ProgData[Block];}
	public int getBlockStart() {return blockStart;}
	public int getStartProg() {return startProg;}
	public int getEndProg() {return endProg;}
	public int getNTracks() {return nTracks;}
	public int getWClocks() {return wClocks;}
	public int getAsyncs() {return asyncs;}
	public int getWClock0() {return wClock0;}
	public int getGate0() {return gate0;}
	public int getInEvts() {return inEvts;}
	public int getAsync0() {return async0;}
	public int getAppSize() {return appSize;}
	public boolean getPersistFlag() {return persistFlag;}
	public void setPersistFlag(boolean flag) {persistFlag=flag;}

	public String getLastError() {return lastError;}
	
	public String ReadFile(String FileName) {
		int blockCount = 0;
		int byteCount;
		try {
			FileInputStream fstream = new FileInputStream(FileName);
			DataInputStream in = new DataInputStream(fstream);
			BufferedReader br = new BufferedReader(new InputStreamReader(in));
			String strLine;
			// Read first line to get environment parameters
			if (((strLine = br.readLine()) != null)){
				String params[] = strLine.split(" ");
				if (params.length==9 || params.length==10){
					startProg = Integer.decode(params[0]);
					endProg = Integer.decode(params[1]);
					nTracks = Integer.decode(params[2]);					
					wClocks = Integer.decode(params[3]);
					asyncs = Integer.decode(params[4]);
					wClock0 = Integer.decode(params[5]);
					gate0 = Integer.decode(params[6]);
					inEvts = Integer.decode(params[7]);
					async0 = Integer.decode(params[8]);
					if (params.length==10)
						appSize = Integer.decode(params[9]);
					else
						appSize = endProg;
				} else {
					br.close();
					return (String)(".vmx format error - incompatible header line.");	
				}
			} else {
				br.close();
				return (String)(".vmx format error - empty file.");	
			}

			
			//Read File Line By Line
			blockStart = (int)Math.floor(startProg/BLOCK_SIZE);
			while ((strLine = br.readLine()) != null)   {
				short xByte = Short.decode("0x"+strLine.substring(0,2));
				int xAddr = (int) (Integer.decode("1"+strLine.substring(5,10)) - 100000);
				System.out.println(xAddr+" "+xByte+" |"+strLine);
				blockCount = (int)Math.floor(xAddr/BLOCK_SIZE);
				byteCount = (int) (xAddr%BLOCK_SIZE);
				ProgData[blockCount][byteCount]=xByte;;
			}
			numBlocks = (int)(blockCount+1-blockStart);
			//Close the input stream
			in.close();
		} catch (Exception e) {
			return (String)(".vmx format error."+ e.getMessage());	
		}			
		return (String)("");
	}


}
