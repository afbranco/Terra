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

/**
 * 
 */
package app;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import javax.swing.table.AbstractTableModel;

/**
 * @author abranco
 *
 */
public class ControlTableModel extends AbstractTableModel {
	
	/**
	 * 
	 */
	private static final long serialVersionUID = -8276776409203498473L;
	private Map<Integer,String[]> DataTab = new HashMap<Integer,String[]>();
	private String [] Header = null;
	private ArrayList<Integer> moteList = new ArrayList<Integer>();
	
	/**
	 * @param header
	 */
	public ControlTableModel(String[] header) {
		super();
		Header = header;
	}
	

	/**
	 * Remove all data from TableModel and call fireTableDataChanged()
	 */
	public void clear(){
		DataTab.clear();
		moteList.clear();
		fireTableDataChanged();
	}

	/* (non-Javadoc)
	 * @see javax.swing.table.TableModel#getColumnCount()
	 */
	@Override
	public int getColumnCount() {
		return Header.length;
	}

	/* (non-Javadoc)
	 * @see javax.swing.table.TableModel#getRowCount()
	 */
	@Override
	public int getRowCount() {
		return DataTab.size();
	}

	/* (non-Javadoc)
	 * @see javax.swing.table.TableModel#getValueAt(int, int)
	 */
	@Override
	public Object getValueAt(int rowIndex, int columnIndex) {
		int moteID = moteList.get(rowIndex);
		if (DataTab.containsKey(moteID)) {
			String[] dataLine = DataTab.get(moteID);
			return dataLine[columnIndex];
		}
		return null;
	}

	/* (non-Javadoc)
	 * @see javax.swing.table.TableModel#getValueAt(int, int)
	 */
	@Override
	public void setValueAt(Object Val, int rowIndex, int columnIndex) {
		int moteID = moteList.get(rowIndex);
		if (DataTab.containsKey(moteID)) {
			String[] dataLine = DataTab.get(moteID);
			dataLine[columnIndex]=(String) Val;
		}
	}
	
	/**
	 * Set data value
	 * @param Value
	 * @param moteID 
	 * @param columnIndex
	 */
	public void setValue(String Value, int moteID, int columnIndex){
		if (DataTab.containsKey(moteID)) {
			String[] dataLine = DataTab.get(moteID);
			dataLine[columnIndex] = Value;
			DataTab.put(moteID, dataLine);
		    fireTableCellUpdated(moteList.indexOf(moteID),columnIndex);
		} else {
			String[] dataLine = new String[]{"","","","",""};
			dataLine[0] = String.format(" %03d",moteID);
			dataLine[columnIndex] = Value;
			moteList.add(moteID);
			DataTab.put(moteID, dataLine);
			fireTableDataChanged();
		}
	}

	public Object getValue(int moteID, int columnIndex){
		if (DataTab.containsKey(moteID)) {
			String[] dataLine = DataTab.get(moteID);
			return dataLine[columnIndex];
		} else {
			return "";
		}
	}

	
	/** 
	 * Return the Column title 
	 * @see javax.swing.table.TableModel#getColumnName(int) 
	 */  
	public String getColumnName(int columnIndex){  
	    return Header[columnIndex];  
	}  
}
