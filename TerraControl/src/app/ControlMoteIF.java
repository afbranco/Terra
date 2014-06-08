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
			wdForm.restartTCP();
		}
		
	}
	
}
