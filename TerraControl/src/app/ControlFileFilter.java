package app;

import java.io.File;
import java.io.FilenameFilter;

public class ControlFileFilter implements FilenameFilter  {
	String EndsWith;
	
	ControlFileFilter(String endsWith){
		EndsWith = endsWith.toLowerCase();
	}
	
	public boolean accept(File dir, String name){
//		System.out.println(name);
		return name.toLowerCase().endsWith(EndsWith);
	}
}

