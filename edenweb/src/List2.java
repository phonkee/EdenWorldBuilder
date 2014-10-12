import java.io.*;
import java.net.URLDecoder;
import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;



public class List2 extends HttpServlet
{
	static List2 singleton;
	public AtomicInteger activereq=new AtomicInteger(0); 
	long time;
	int uploads;
	int listrequests;
	int searches;
	static Set<String> badwords=new HashSet<String>();
	static Map<Long,String> filesByDate=new ConcurrentSkipListMap<Long,String>();
	static Map<String,String> filesByName=new ConcurrentSkipListMap<String,String>();
	
	
	
	static Map<String,ArrayList<EdenMap>> searchTable=new ConcurrentHashMap<String,ArrayList<EdenMap>>();
	Random r;
	static  String[] listBuffers=new String[3];
	public void printMapSizes(){
		System.out.println("------SIZES-----"); 
		System.out.println("filesbyDate:"+filesByDate.size() + 
				"  filesByName:"+filesByName.size()+ "  searchTable:"+searchTable.size()+"  badwords:"+badwords.size());
		
		System.out.println("-----------------");
	}
	public void updateBuffers(){
    	
        
        for(int sort=0;sort<3;sort++){
        	if(sort==2)continue;
        	StringBuilder buff = new StringBuilder();
        	Collection<String> list=null;
        	Object sync=null;
        	if(sort==0){
        		list=filesByName.values();
        		sync=filesByName;

        	}else if(sort==1){
        		list=filesByName.values();
        		sync=filesByName;
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
        	//listBuffers[sort]=buff.toString();
        }
    }
	public void parseLine(String line){
		if(true)return;
		try{
			long newtime=System.currentTimeMillis();
			if(newtime-time>5000){
				float etime=(newtime-time)/1000.0f;
				time=newtime;
				System.out.println("Uploads/s:"+(uploads/etime)+"  Searches/s:"+(searches/etime)+"  ListRequests/s:"+(listrequests/etime));
				uploads=searches=listrequests=0;
			}
			uploads++;
		String file_name=line.substring(0,line.indexOf(" "));
		String display_name=line.substring(line.indexOf(" ")+1);
		
		
		
		String timestamp=file_name.substring(0,file_name.length()-5);
		String listing=file_name+"\n"+display_name+".name\n";
		display_name=display_name.toUpperCase();
		if(filesByDate.containsKey(Long.parseLong(timestamp)))return;
		if(!addToSearchTable(display_name,listing,Long.parseLong(timestamp)))
			return;
		filesByDate.put(Long.parseLong(timestamp),listing);
		if(filesByDate.size()>150){
			synchronized(filesByDate){
				Iterator<Long> iterator=filesByDate.keySet().iterator();
				filesByDate.remove(iterator.next());
			}
		}
			
		
		
		//while(filesByName.containsKey(display_name)){
		//	display_name+="1";			
		//}
		filesByName.put(display_name,listing);
		if(filesByName.size()>150){
			String mins="z";
			synchronized(filesByName){
			Iterator<String> it=filesByName.values().iterator();
			while(it.hasNext()){
				String s=it.next();
				
				if(s.compareTo(mins)<0){
					mins=s;
				}
			}
			}
			filesByName.remove((mins.substring(mins.indexOf("\n")+1,mins.length()-6)).toUpperCase());
			//if(filesByName.size()>150)System.out.println(mins.substring(mins.indexOf("\n")+1,mins.length()-6));
			
		}
		
		
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
					searchTable.put(s, new ArrayList<EdenMap>());
					
				}
				 
				ArrayList<EdenMap> entry=searchTable.get(s);
				synchronized(entry){
					if(!entry.contains(map)){
						entry.add(map);
						if(entry.size()>2000){
							Collections.sort(entry);
							for(int i=0;i<1000;i++)
							entry.remove(entry.size()-1);
						}
					}
				}
				
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
			Set<String> tempset=new HashSet<String>();
			while(sc.hasNextLine()){
				String line=sc.nextLine();
				tempset.add(line.toUpperCase().trim());
			}
			badwords.addAll(tempset);
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
			
			
			StringBuilder buff = new StringBuilder();
			sc=new Scanner(new File(path+"popularlist.txt"));
			while(sc.hasNextLine()){
				buff.append(sc.nextLine()+"\n");
			}
			sc.close();
			listBuffers[2]=listBuffers[0]=listBuffers[1]=buff.toString();
			
			
			System.out.println("Finished loading "+searchTable.size());
			
		}catch(IOException ex){
			ex.printStackTrace();
		}
		updateBuffers();
		//parseLine("1290961151.eden World sharing temporarily unavailable.");
	
	}
	
    protected void doGet( HttpServletRequest req, HttpServletResponse resp ) throws ServletException, IOException
    {
    	activereq.getAndIncrement();
    	try{
        PrintWriter outp = resp.getWriter();
        StringBuilder buff = new StringBuilder();
        String q=req.getQueryString();
        String[] parts=q.split("&");
        if(true){
    	outp.write("");
        return;
        }
        int sort=0;
        String search="";
        for(String s:parts){
        	if(s.startsWith("sort")){
        		listrequests++;
        		sort=Integer.parseInt(s.substring(s.indexOf("=")+1,s.length()));
        	} 
        	if(s.startsWith("search")){
        		searches++;
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
        		ArrayList<EdenMap> match=searchTable.get(words[i]);
        		if(match!=null){
        			synchronized(match){
        			for(EdenMap map:match){
        				map.count++;
        			}
        			partialMatch.addAll(match);
        			}
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
        if(sort>=0&&sort<3){ 
        	if(listBuffers[sort]!=null)
            outp.write(listBuffers[sort]);
        }else      	
        	
        	outp.write("");
    	}catch(Exception ex){
    		ex.printStackTrace();
    	}finally{
    		 activereq.getAndDecrement();
    	}
       
        
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
	
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + count;
		result = prime * result + (int) (date ^ (date >>> 32));
		result = prime * result + ((listing == null) ? 0 : listing.hashCode());
		return result;
		}

		public boolean equals(Object obj) {
		if (this == obj)
		return true;
		if (obj == null)
		return false;
		if (getClass() != obj.getClass())
		return false;
		EdenMap other = (EdenMap) obj;
		if (count != other.count)
		return false;
		if (date != other.date)
		return false;
		if (listing == null) {
		if (other.listing != null)
		return false;
		} else if (!listing.equals(other.listing))
		return false;
		return true;
		}
		

}