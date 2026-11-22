package app;

public class SetData {
	Integer Addr, Len, GrNdIdLen;
	Integer[] GrNdId;
	boolean GrNdOpt;
	short[] Values;
	public SetData(Integer addr, Integer len, Integer[] grNdId, Integer grNdIdLen,boolean grNdOpt,short[] values) {
		super();
		Addr = addr;
		Len = len;
		GrNdId = grNdId;
		GrNdIdLen = grNdIdLen;
		GrNdOpt = grNdOpt;
		Values = values;
	}
	public Integer getAddr() {
		return Addr;
	}
	public Integer getLen() {
		return Len;
	}
	public Integer[] getGrNdId() {
		return GrNdId;
	}
	public Integer getGrNdIdLen() {
		return GrNdIdLen;
	}
	public boolean isGrNdOpt() {
		return GrNdOpt;
	}
	public short[] getValues() {
		return Values;
	}
	
	
}
