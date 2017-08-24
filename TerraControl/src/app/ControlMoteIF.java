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

import java.io.IOException;

import net.tinyos.message.MoteIF;
import net.tinyos.packet.PhoenixError;
import net.tinyos.packet.PhoenixSource;
import net.tinyos.util.Messenger;

public class ControlMoteIF extends MoteIF {

	ControlForm wdForm;
	
	public ControlMoteIF( ControlForm form) {
		super();
		wdForm = form;
	}

	public ControlMoteIF(Messenger arg0, ControlForm form) {
		super(arg0);
		wdForm = form;
	}

	public ControlMoteIF(PhoenixSource arg0, ControlForm form) {
		super(arg0);
		wdForm = form;
	}

	
	public void setPacketErrorHandler(){
		WDPhoenixError eh = new WDPhoenixError(this.source);
		this.source.setPacketErrorHandler(eh);
	}
	
	private class WDPhoenixError implements PhoenixError{
//		PhoenixSource Source;
		
		WDPhoenixError(PhoenixSource source){
//			Source = source;
		}
		
		@Override
		public void error(IOException e) {
			System.out.println("WDPhoenixError: "+e.getMessage());
			source.shutdown();
			try {
				wdForm.restartTCP();
			} catch (IOException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}
		
	}
	
}
