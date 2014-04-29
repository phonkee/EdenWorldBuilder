import java.io.*;
import java.util.*;

import javax.xml.stream.events.Namespace;
public class Stats {
	/*static int nlength=100000000;
	static boolean[] names=new boolean[nlength];
	public static boolean ncontains(String n){
		return names[Math.abs(n.hashCode())%nlength];
	}
	public static void nadd(String n){
		names[Math.abs(n.hashCode())%nlength]=true;
	}*/
	public static void main(String[] args){
		File f=new File("file_list2.txt");
		if(f.exists()){
			System.out.println("Opening file list..");
			long btime=0;
			long interval=60*60*24*30;
			long total=0;
			long counter=0;
			int n=0;
			int m=1;
			try {
				Scanner sc=new Scanner(f);
				
				while(sc.hasNextLine()){
					String line=sc.nextLine();
					long time;
					int si=line.indexOf(".");
					String name=line.substring(si+6);
					counter++;
					/*if(ncontains(name)){
						continue;
					}
					nadd(name);
					*/total++;
					try{
					time=Long.parseLong(line.substring(0,si));
					}catch (NumberFormatException ex){
						System.err.println("error parsing: "+line);
						time=0;
					}
					n++;
					if(time>btime){
						btime=time+interval;
						System.out.println(m+": "+n);
						n=0;
						m++;
					}
					
					
					
					
				}
				System.out.println(m+": "+n);
				System.out.println("total:"+total);
				System.out.println("dupes:"+(counter-total));
				sc.close();
			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
		}
		
	}
}
