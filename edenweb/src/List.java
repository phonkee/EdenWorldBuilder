import java.io.*;
import java.util.*;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;



public class List extends HttpServlet
{
        static List singleton;
        Map<Long,String> filesByDate=Collections.synchronizedMap(new TreeMap<Long,String>());
        Map<String,String> filesByName=Collections.synchronizedMap(new TreeMap<String,String>());
        Vector<String> nameList=new Vector<String>();
        Map<Integer,String> filesByPopular=Collections.synchronizedMap(new TreeMap<Integer,String>());
        String[] listBuffers=new String[3];
        Random r;
        public void updateBuffers(){
        	
         
            for(int sort=0;sort<3;sort++){
            	StringBuffer buff = new StringBuffer();
            	Collection<String> list=null;
            	Object sync=null;
            	if(sort==0){
            		list=filesByName.values();
            		sync=filesByName;

            	}else if(sort==1){
            		list=filesByPopular.values();
            		sync=filesByPopular;
            		//filesByPopular;

            	}else if(sort==2){
            		sync=filesByDate;
            		LinkedList<String> c=new LinkedList<String>();
            		c.addAll(filesByDate.values());
            		Collections.reverse(c);    
            		list=c;
            	}
            	if(list==null)return;
            	synchronized(sync){
            		Iterator<String> it=list.iterator();
            		int n=0;
            		while(n<150){
            			if(!it.hasNext())break;
            			buff.append(it.next());
            			n++;
            		}
            	}
            	listBuffers[sort]=buff.toString();
            }
        }
        public void parseLine(String line){
                try{
                String file_name=line.substring(0,line.indexOf(" "));
                String display_name=line.substring(line.indexOf(" ")+1);
                String timestamp=file_name.substring(0,file_name.length()-5);
                String listing=file_name+"\n"+display_name+".name\n";
                filesByDate.put(Long.parseLong(timestamp),listing);
                display_name=display_name.toUpperCase();
                //while(filesByName.containsKey(display_name)){
                //      display_name+="1";                      
                //}
                filesByName.put(display_name,listing);
                if(filesByName.size()>150){
                        String mins="z";
                        Iterator<String> it=filesByName.values().iterator();
                        while(it.hasNext()){
                                String s=it.next();
                                
                                if(s.compareTo(mins)<0){
                                        mins=s;
                                }
                        }
                        filesByName.remove((mins.substring(mins.indexOf("\n")+1,mins.length()-6)).toUpperCase());
                        //if(filesByName.size()>150)System.out.println(mins.substring(mins.indexOf("\n")+1,mins.length()-6));
                        
                }
                
                filesByPopular.put(r.nextInt(), listing);       
                }catch(Exception ex){
                        ex.printStackTrace();
                        
                }
               
        
        }
        public void init(ServletConfig cfg) throws ServletException{
                super.init(cfg);
                
                singleton=this;
                r=new Random();
                r.setSeed(100);//popular just a deterministic random for now
                
                try{            
                        String path = cfg.getServletContext().getRealPath("/")+"/";                     
                        Scanner sc=new Scanner(new File(path+"file_list.txt"));
                        while(sc.hasNextLine()){
                                String line=sc.nextLine();
                                parseLine(line);                        
                        }               
                        sc.close();
                        
                        sc=new Scanner(new File(path+"popular.txt"));
                        int i=0;
                        while(sc.hasNextLine()){
                                String file_name=sc.nextLine();
                                String display_name=sc.nextLine();
                                String listing=file_name+"\n"+display_name+"\n";                                
                                filesByPopular.put(Integer.MIN_VALUE+i, listing);               
                                i++;
                        }               
                        sc.close();
                }catch(IOException ex){
                        ex.printStackTrace();
                }
                updateBuffers();
                //parseLine("1290961151.eden World sharing temporarily unavailable.");
        
        }
    protected void doGet( HttpServletRequest req, HttpServletResponse resp ) throws ServletException, IOException
    {
        PrintWriter outp = resp.getWriter();
        
        String q=req.getQueryString();
        String[] parts=q.split("&");
        int sort=0;
        for(String s:parts){
                if(s.startsWith("sort")){
                        sort=Integer.parseInt(s.substring(s.indexOf("=")+1,s.length()));
                }               
        }
        if(sort>=0&&sort<=3)
        outp.write(listBuffers[sort]);
        
    }

    protected void doPost( HttpServletRequest req, HttpServletResponse resp ) throws ServletException, IOException
    {
        doGet( req, resp );
    }

}