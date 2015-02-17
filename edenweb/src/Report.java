import java.io.*;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class Report extends HttpServlet
{
        /** 
	 * 
	 */
	static String path;
	private static final long serialVersionUID = 1L;
		
		public static FileWriter rfh;
        public void init(ServletConfig cfg) throws ServletException{
                super.init(cfg);
                path =cfg.getServletContext().getRealPath("/")+"/";
                try {
					rfh=new FileWriter(path+"report.txt",true);
					
				} catch (IOException e) {				
					e.printStackTrace();
				}
               
        
        }
   
    protected void doGet( HttpServletRequest req, HttpServletResponse resp ) throws ServletException, IOException
    {
    	
        PrintWriter outp = resp.getWriter();
        
        String q=req.getQueryString();
        if(q==null){
        	outp.write(".");
        	return;
        }
        String[] parts=q.split("&");
       String map="";
       String uuid="";
        for(String s:parts){
                if(s.startsWith("map")){
                        map=s.substring(s.indexOf("=")+1,s.length());
                }else if (s.startsWith("uuid")){
                	 uuid=s.substring(s.indexOf("=")+1,s.length());
                }
        }
        if(map.length()==0||uuid.length()==0){
        	outp.write("!");
        	return;
        }
        
        System.out.println("report recieved map:"+map +"  uuid:"+uuid);
        outp.write("report recieved map:"+map +"  uuid:"+uuid);
        synchronized(Moderate.rfhMutex){
        rfh.append(uuid+" "+map+"\n");
        rfh.flush();
    	}
    }

    protected void doPost( HttpServletRequest req, HttpServletResponse resp ) throws ServletException, IOException
    {
        doGet( req, resp );
    }

}