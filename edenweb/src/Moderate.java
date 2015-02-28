import java.io.*;
import java.util.*;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


public class Moderate extends HttpServlet
{
        /** 
	 * 
	 */
	String path;
	static Object rfhMutex=new Object();
	private static final long serialVersionUID = 1L;
		FileWriter whitelistfw;
		FileWriter removedlistfw;
		FileWriter bannedlistfw;
		FileWriter ignoredmapsfw;
		HashMap<String,Integer> reportCard=new HashMap<String,Integer>();
	    public static ArrayList<String> whitelist=new ArrayList<String>();
	    public static ArrayList<String> removedlist=new ArrayList<String>();
	    public static ArrayList<String> bannedlist=new ArrayList<String>();
	    public static ArrayList<String> ignoredlist=new ArrayList<String>();
        public void init(ServletConfig cfg) throws ServletException{
                super.init(cfg);
                path =cfg.getServletContext().getRealPath("/")+"/";
               
                try{
                	Scanner sc=new Scanner(new File(path+"whitelist.txt"));
                	while(sc.hasNextLine()){
                		whitelist.add(sc.nextLine());
                	}
                	sc.close();
                	sc=new Scanner(new File(path+"removedmaps.txt"));
                	while(sc.hasNextLine()){
                		removedlist.add(sc.nextLine());
                	}
                	sc.close();
                	sc=new Scanner(new File(path+"bannedlist.txt"));
                	while(sc.hasNextLine()){
                		bannedlist.add(sc.nextLine());
                	}
                	sc.close();
                	
                	sc=new Scanner(new File(path+"ignoredlist.txt"));
                	while(sc.hasNextLine()){
                		ignoredlist.add(sc.nextLine());
                	}
                	sc.close();
                	
                	
                	
                whitelistfw=new FileWriter(path+"whitelist.txt",true);
                removedlistfw=new FileWriter(path+"removedmaps.txt",true);
                bannedlistfw=new FileWriter(path+"bannedlist.txt",true);
                ignoredmapsfw=new FileWriter(path+"ignoredlist.txt",true);
                }catch(IOException ex){
                	ex.printStackTrace();
                }
        System.out.println("removal lists initialized!!");
        }
        
       
    protected void genReport(){
    	synchronized(rfhMutex){
    	try{
    	Report.rfh.close();
    
    	Scanner sc=new Scanner(new File(path+"report.txt"));
    reportCard.clear();
    	while(sc.hasNextLine()){
    		//System.err.println("added report\n");
    		String line = sc.nextLine();
    		boolean flag=true;
    		if(line.startsWith("server")){
    			flag=false;
    		}
    		int idx=line.indexOf(" ");
    		if(idx==-1)continue;
    		String uuid=line.substring(0,idx);
    		String map=line.substring(idx+1);
    		int reports=0;
    		if(reportCard.containsKey(map)){
    			reports=reportCard.get(map);
    		}
    		if(flag)
    		reportCard.put(map, reports+10);
    		else
    		reportCard.put(map, reports+1);
    		
    	}
    	sc.close();
    	Report.rfh=new FileWriter(path+"report.txt",true);
    	}catch(IOException ex){
    		ex.printStackTrace();
    	}
    	}
    }
    protected void clearReports(){
    	synchronized(rfhMutex){
        	try{
        	Report.rfh.close();
        	File f=new File(path+"report.txt");
        	f.delete();
        	f.createNewFile();
        	
        	Report.rfh=new FileWriter(path+"report.txt",true);
        	}catch(IOException ex){
        		ex.printStackTrace();
        	}
        	}
    	//ignoredlist.clear();
    	
    }
    protected void doGet( HttpServletRequest req, HttpServletResponse resp ) throws ServletException, IOException
    {
        PrintWriter outp = resp.getWriter();
        String q=req.getQueryString();
        if(q!=null&&q.startsWith("action")){
        	
        	String map="";
           int action=-1;
           String uuid="";
           String[] parts=q.split("&");
             for(String s:parts){
                     if(s.startsWith("map")){
                             map=s.substring(s.indexOf("=")+1,s.length());
                     }else if (s.startsWith("action")){
                     	 action=Integer.parseInt(s.substring(s.indexOf("=")+1,s.length()));
                     }else if (s.startsWith("uuid")){
                    	 uuid=s.substring(s.indexOf("=")+1,s.length());
                     }
             }
        	
        	if(action==2){
        		System.out.println("Removing map");
        		removedlist.add(map);
        		removedlistfw.write(map+"\n");
        		removedlistfw.flush();
        		List2.singleton.updateBuffers();
        	}
        	if(action==4){
        		
        		System.out.println("Removing map");
        		removedlist.add(map);
        		removedlistfw.write(map+"\n");
        		removedlistfw.flush();
        		List2.singleton.updateBuffers();
        		if(uuid.length()!=0){
        			bannedlist.add(uuid);
        			//bannedlistfw.write(uuid+"\n");
        			//bannedlistfw.flush();
        		}
        		
        	}
        	
        	if(action==3){
        		System.out.println("Banning map uploader:"+uuid);
        		if(uuid.length()!=0){
        			bannedlist.add(uuid);
        			bannedlistfw.write(uuid+"\n");
        			bannedlistfw.flush();
        			ArrayList<String> usermaps=List2.mapUUID.get(uuid);
        			for(String m:usermaps){
        				removedlist.add(m);
                		removedlistfw.write(m+"\n");
                		removedlistfw.flush();
        			}
        			List2.singleton.updateBuffers();
        		}
        	}
        	if(action==1){
        		System.out.println("Approve");
        		whitelist.add(map);
        		whitelistfw.write(map+"\n");
        		whitelistfw.flush();
        	}
        	if(action==0){
        		System.out.println("Ignore");
        		ignoredlist.add(map);
        		ignoredmapsfw.write(map+"\n");
        		ignoredmapsfw.flush();
        	}
        	if(action==5){
        		clearReports();
        	}
        }
        
        
        
        outp.write("<html><head><title>Eden - Map Moderation</title></head><body><center><h1>Eden - Map Moderation</h1>");
        genReport();
       boolean donemoderating=true;
        for(String map:reportCard.keySet()){
        	if(whitelist.contains(map))continue;
        	if(ignoredlist.contains(map))continue;
        	if(removedlist.contains(map))continue;
        	if(reportCard.get(map)<20) continue;
        	donemoderating=false;
        	
        	String uuid=List2.uuidlookup.get(map);
        	outp.write("<br><br><img src='http://files.edengame.net/"+map+".png'></img><br>");
        	outp.write("<br><b> "+List2.mapTitles.get(map)  +"</b>   reports:<b> "+reportCard.get(map)+"</b><br>");
        	outp.write("<a href='http://app.edengame.net/moderate.php?action=3&map="+map+"&uuid="+uuid+"'>Remove and Ban</a>");
        	outp.write(" ... <a href='http://app.edengame.net/moderate.php?action=4&map="+map+"&uuid="+uuid+"'>Remove and Temp Ban</a>");
        	
        	outp.write(" ... <a href='http://app.edengame.net/moderate.php?action=2&map="+map+"'>Remove</a>");
        	
        	outp.write(" ... <a href='http://app.edengame.net/moderate.php?action=0&map="+map+"'>Ignore</a><br><br>");
        	//outp.write("<a href=");
        	
        	
        	
        }
        if(donemoderating){
        	outp.write("<b>done moderating, pick maps to recent?!</b>  <a href='http://app.edengame.net/moderate.php?action=5'>... Clear all ...</a><br><br>");
        	  for(String map:reportCard.keySet()){
              	//if(reportCard.get(map)<=1) continue;
              	donemoderating=false;
              	if(whitelist.contains(map))continue;
              	if(ignoredlist.contains(map))continue;
              	if(removedlist.contains(map))continue;
              	if(reportCard.get(map)!=1) continue;
              	String uuid=List2.uuidlookup.get(map);
              	outp.write("<br><br><img src='http://files.edengame.net/"+map+".png'></img><br>");
              	outp.write("<br><b> "+List2.mapTitles.get(map)  +"</b>   reports:<b> "+reportCard.get(map)+"</b><br>");
              	outp.write("<a href='http://app.edengame.net/moderate.php?action=3&map="+map+"&uuid="+uuid+"'>Remove and Ban</a>");
            	outp.write(" ... <a href='http://app.edengame.net/moderate.php?action=4&map="+map+"&uuid="+uuid+"'>Remove and Temp Ban</a>");
            	outp.write(" ... <a href='http://app.edengame.net/moderate.php?action=2&map="+map+"'>Remove</a>");
              	outp.write(" ... <a href='http://app.edengame.net/moderate.php?action=0&map="+map+"' ... >Ignore</a>");
              	outp.write(" ... <a href='http://app.edengame.net/moderate.php?action=1&map="+map+"'>Approve and recent</a><br><br>");
              	//outp.write("<a href=");
              	
              	
              	
              }
        }
        
        outp.write("</html>");
       
    }

    protected void doPost( HttpServletRequest req, HttpServletResponse resp ) throws ServletException, IOException
    {
        doGet( req, resp );
    }

}