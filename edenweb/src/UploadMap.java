import java.io.*;
import java.nio.*;
import java.nio.channels.FileChannel;

import java.util.*;
import java.util.zip.*;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;



public class UploadMap extends HttpServlet
{
   String path;
   public void init(ServletConfig cfg) throws ServletException{
                super.init(cfg);
                path =cfg.getServletContext().getRealPath("/")+"/";
   }
   
        protected void doGet( HttpServletRequest req, HttpServletResponse resp ) throws ServletException, IOException
    {
        PrintWriter outp = resp.getWriter();
        StringBuffer buff = new StringBuffer();

        File file1 = (File) req.getAttribute( "uploaded" );

        if( file1 == null || !file1.exists() )
        {
            buff.append( "File does not exist" );
        }
        else if( file1.isDirectory())
        {
            buff.append( "File is a directory" );
        }
        else
        {
                long time=System.currentTimeMillis()/1000;
            File outputFile = new File( path+"eden_maps/"+time+".eden" );
          while(outputFile.exists()){
                  outputFile = new File( path+"eden_maps/"+(++time)+".eden" );
           }
          String file_name=time+".eden";
          File temp=new File(path+time);
          GZIPInputStream gzipInputStream =
                  new GZIPInputStream(new FileInputStream(file1));

          // Open the output file               
          OutputStream out = new FileOutputStream(temp);
          // Transfer bytes from the compressed file to the output file
          byte[] buf = new byte[1024];
          int len;
          while ((len = gzipInputStream.read(buf)) >= 0) {
                  out.write(buf, 0, len);
          }
          // Close the file and stream
          gzipInputStream.close();
          out.close();
          
         FileReader fr=new FileReader(temp);
         char[] cbuf=new char[100];
         fr.read(cbuf);
         StringBuffer name=new StringBuffer();
         for(int i=40;i<90;i++){
                 if(cbuf[i]=='\0')break;
                 name.append(cbuf[i]);
         }
         
         fr.close();
         temp.delete();
         String display_name=name.toString();
         FileWriter fw=new FileWriter(path+"file_list.txt",true);
         fw.append(file_name+" "+display_name+"\n");
         List.singleton.parseLine(file_name+" "+display_name);
         List.singleton.updateBuffers();
         fw.close();
          file1.renameTo( outputFile );
          buff.append( "YES" );
        }

        
        outp.write( ""+buff );
    }

    protected void doPost( HttpServletRequest req, HttpServletResponse resp ) throws ServletException, IOException
    {
        doGet( req, resp );
    }

}