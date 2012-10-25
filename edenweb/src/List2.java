import java.io.*;
import java.net.URLDecoder;
import java.util.*;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;



public class List2 extends HttpServlet
{
	static List2 singleton;
	HashSet<String> badwords=new HashSet<String>();
	Map<Long,String> filesByDate=Collections.synchronizedMap(new TreeMap<Long,String>());
	Map<String,String> filesByName=Collections.synchronizedMap(new TreeMap<String,String>());
	Vector<String> nameList=new Vector<String>();
	Map<Integer,String> filesByPopular=Collections.synchronizedMap(new TreeMap<Integer,String>());
	
	Map<String,Set<EdenMap>> searchTable=Collections.synchronizedMap(new HashMap<String,Set<EdenMap>>());
	Random r;
	 String[] listBuffers=new String[3];
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
		display_name=display_name.toUpperCase();
		if(!addToSearchTable(display_name,listing,Long.parseLong(timestamp)))
			return;
		filesByDate.put(Long.parseLong(timestamp),listing);
		
		
		
		//while(filesByName.containsKey(display_name)){
		//	display_name+="1";			
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
	private boolean addToSearchTable(String display_name, String listing,long date) {
		StringBuilder b=new StringBuilder();
		for(int i=0;i<display_name.length();i++){
			char c=display_name.charAt(i);
			if( (c>='A'&&c<='Z') || (c>='0'&&c<='9') )
				b.append(c);
			else
				b.append(' ');
			
		}
		EdenMap map=new EdenMap();
		map.listing=listing;
		map.date=date;
		map.count=0;
		String[] words=b.toString().split(" ");
		for(String s:words){
			if(s.length()>0){
				if(badwords.contains(s))return false;				
			}
		}
		for(String s:words){
			if(s.length()>0){
				
				if(!searchTable.containsKey(s)){
					searchTable.put(s, Collections.synchronizedSet(new HashSet<EdenMap>()));
					
				}
				
				searchTable.get(s).add(map);
			}
		}
		return true;
		
	}
	public void init(ServletConfig cfg) throws ServletException{
		super.init(cfg);
		
		singleton=this;
		r=new Random();
		r.setSeed(100);//popular just a deterministic random for now
		
		try{	
			System.out.println("Initializing lists ");
			String path = cfg.getServletContext().getRealPath("/")+"/";	
			Scanner sc=new Scanner(new File(path+"asdf.png"));
			while(sc.hasNextLine()){
				String line=sc.nextLine();
				badwords.add(line.toUpperCase().trim());
			}
			sc.close();
			sc=new Scanner(new File(path+"file_list2.txt"));
			int i=0;
			while(sc.hasNextLine()){
				String line=sc.nextLine();
				parseLine(line);	
				i++;
				if(i%5000==0)System.out.println("parsed "+i+ " maps");
			}		
			sc.close();
			
			sc=new Scanner(new File(path+"popular2.txt"));
			i=0;
			while(sc.hasNextLine()){
				String file_name=sc.nextLine();
				String display_name=sc.nextLine();
				String listing=file_name+"\n"+display_name+"\n";				
				filesByPopular.put(Integer.MIN_VALUE+i, listing);		
				i++;
			}	
			System.out.println("Finished loading "+searchTable.size());
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
        StringBuffer buff = new StringBuffer();
        String q=req.getQueryString();
        String[] parts=q.split("&");
        int sort=0;
        String search="";
        for(String s:parts){
        	if(s.startsWith("sort")){
        		sort=Integer.parseInt(s.substring(s.indexOf("=")+1,s.length()));
        	} 
        	if(s.startsWith("search")){
        		search=URLDecoder.decode(s.substring(s.indexOf("=")+1,s.length()),"UTF-8");
        	}
        }
        if(search.length()>0){
        	search=search.toUpperCase();
        	StringBuilder b=new StringBuilder();
    		for(int i=0;i<search.length();i++){
    			char c=search.charAt(i);
    			if( (c>='A'&&c<='Z') || (c>='0'&&c<='9') )
    				b.append(c);
    			else
    				b.append(' ');
    			
    		}
    		
    		String[] words=b.toString().split(" ");
        	Set<EdenMap> partialMatch=new HashSet<EdenMap>();
        	//Set<EdenMap> perfectMatch=new TreeSet<EdenMap>();
    		for(int i=0;i<words.length;i++){
    			//System.out.println(words[i]+":");
        		Set<EdenMap> match=searchTable.get(words[i]);
        		if(match!=null){
        			for(EdenMap map:match){
        				map.count++;
        			}
        			partialMatch.addAll(match);
        			
        		/*	if(i==0)
        				perfectMatch.addAll(match);
        			else{
        				perfectMatch.retainAll(match);
        			}*/
        		}else{
        			//perfectMatch.clear();
        		}
        	}
    		/*int ni=0;
        	if(perfectMatch.size()!=0){

        		Iterator<EdenMap> it=perfectMatch.iterator();
        		int ni=0;
        		while(ni<150){
        			if(!it.hasNext())break;
        			buff.append(it.next().listing);
        			ni++;
        		}
                
        	}
        	partialMatch.removeAll(perfectMatch);*/
    		EdenMap[] results=(EdenMap[]) partialMatch.toArray(new EdenMap[0]);
    		Arrays.sort(results);

    		for(int i=0;i<150;i++){
    			if(i>=results.length)break;
    			buff.append(results[i].listing);
    			//System.out.print(results[i].count+" :::"+results[i].listing);
    		}


        	for(EdenMap map:results){
        		map.count=0;
        	}
        	 outp.write(buff.toString());
        	 return;
        }
        if(sort>=0&&sort<=3)
            outp.write(listBuffers[sort]);
        else
        	outp.write("");
        
    }

    protected void doPost( HttpServletRequest req, HttpServletResponse resp ) throws ServletException, IOException
    {
        doGet( req, resp );
    }

}
class EdenMap implements Comparable<Object>{
	public String listing;
	public long date;
	public int count;
	
	public int compareTo(Object o) {
		EdenMap map=(EdenMap)o;
		if(count!=map.count)
		return map.count-count;
		return (int)(map.date-date);//descending order;
		
		
	}
	
	
		

}