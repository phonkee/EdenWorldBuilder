import java.io.*;
import java.nio.*;
import java.nio.channels.FileChannel;

import java.security.MessageDigest;
import java.util.*;
import java.util.zip.*;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.jets3t.service.*;


import org.jets3t.service.acl.*;
import org.jets3t.service.impl.rest.httpclient.*;
import org.jets3t.service.model.*;
import org.jets3t.service.security.*;
import org.jets3t.service.utils.*;


public class UploadMap2 extends HttpServlet
{
   String path;
   String awsAccessKey;
   String awsSecretKey;
   AWSCredentials awsCredentials;
   S3Service s3Service;

 S3Bucket bucket;
   public void init(ServletConfig cfg) throws ServletException{
		super.init(cfg);
		System.out.println("trying to init");
		path =cfg.getServletContext().getRealPath("/")+"/";
		
		
		awsAccessKey = "AKIAI7H7GSPLFNQVQ7UA";
       awsSecretKey = "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";
         awsCredentials = 
            new AWSCredentials(awsAccessKey, awsSecretKey);
        
		try {
			s3Service = new RestS3Service(awsCredentials);
      bucket=new S3Bucket("edenmaps");
		}catch(Exception e){
			e.printStackTrace();
		
		}
   } 
   
	protected void doGet( HttpServletRequest req, HttpServletResponse resp ) throws ServletException, IOException
    {
        PrintWriter outp = resp.getWriter();
        StringBuffer buff = new StringBuffer();

       
        @SuppressWarnings({  "rawtypes" })
		ArrayList files = (ArrayList) req.getAttribute( "org.eclipse.jetty.servlet.MultiPartFilter.files" );
        
        if(files==null||files.size()<2){
        	if(files==null)
        		buff.append("files is null what else is new");
        	else
        	buff.append("Less than 2 files");
        	 outp.write( ""+buff );
        	return;
        }
        boolean corrupt=false;
        File file1 =(File) files.get(0);
        File file2= (File) files.get(1);
        if( file1 == null || !file1.exists() )
        {
            buff.append( "File does not exist" );
        }        
        else if( file1.isDirectory())
        {
            buff.append( "File is a directory" );
        }else if( file2 == null || !file2.exists() ){
        	buff.append("img does not exist");
        }
        else
        {
        	long time=System.currentTimeMillis()/1000;
        	
            File outputFile = new File( path+"eden_maps2/"+time+".eden" );
          while(outputFile.exists()){
        	  outputFile = new File( path+"eden_maps2/"+(++time)+".eden" );
           }
          File outputFile2=new File( path+"eden_maps2/"+(time)+".eden.png" );
          
          String file_name=time+".eden";
         // File temp=new File(path+"2"+time);
          GZIPInputStream gzipInputStream =
        	  new GZIPInputStream(new FileInputStream(file1));

          // Open the output file            	
        //  OutputStream out = new FileOutputStream(temp);
          // Transfer bytes from the compressed file to the output file
          byte[] buf = new byte[1024];
          int len;
         
          
          len = gzipInputStream.read(buf);
        	//  out.write(buf, 0, len);
        	
          // Close the file and stream
          gzipInputStream.close();
          //out.close();
          char[] cbuf=new char[1024];
          for(int i=0;i<1024;i++){
        	  cbuf[i]=(char)buf[i];
          }
          StringBuffer name=new StringBuffer();
          if(len<150)corrupt=true;
          else{
         //FileReader fr=new FileReader(temp);
         //char[] cbuf=new char[200];
         //fr.read(cbuf);
         
         for(int i=40;i<89;i++){
        	 if(cbuf[i]=='\0')break;
        	 char c=(char)cbuf[i];
        	 if(Character.isLetterOrDigit(c)||c==' '||c=='\'')
        	 name.append(cbuf[i]);
        	 
         }
         System.out.println("name:'"+name+"'"+" toString:'"+name.toString()+"'");
         int version=(int)cbuf[92];
         if(version!=2){
        	 version=(int)cbuf[91];
        	 
         }
         System.out.println("version:"+(int)cbuf[94]+','+(int)cbuf[93]+','+(int)cbuf[92]+','+(int)cbuf[91]+','+(int)cbuf[90]);
         StringBuffer hash=new StringBuffer();
         for(int i=95;i<95+33;i++){
        	 hash.append(cbuf[i]);
         }
        // fr.close();
        // temp.delete();
         file2.renameTo(outputFile2);
         try{
         String real_hash=getMD5Checksum(outputFile2.getAbsolutePath());
         	if(real_hash.trim().equals(hash.toString().trim())&&version==2){
         		System.out.println("hash checks out '"+hash+"=="+real_hash+"'");
         	}else{
         		System.out.println("bad hash or version '");
         		System.out.println("version:"+version+ " hashes:'"+hash+"=?="+real_hash+"'");
         		corrupt=true;
         		//936d55d3f620b9c2bc2447dcfcff2794!=
         		//936d55d3f620b9c2bc2447dcfcff2794
         	}
         }catch(Exception ex){
        	 corrupt=true;
        	 System.out.println(outputFile2.getAbsolutePath());
        	 ex.printStackTrace();
        	 
         }
          }
         if(corrupt) {
        	 outputFile.delete();
             outputFile2.delete();
             buff.append("NOTHX");
             outp.write( ""+buff );
             return;
        }
         
         String display_name=name.toString();
         FileWriter fw=new FileWriter(path+"file_list2.txt",true);
         fw.append(file_name+" "+display_name+"\n");
         
         fw.close();
         file1.renameTo( outputFile );
      
       try{
    	   
    	   
         S3Object object = new S3Object(outputFile);
         object.setAcl(AccessControlList.REST_CANNED_PUBLIC_READ);
        // System.out.println("S3Object before upload: " + object);

         // Upload the object to our test bucket in S3.
         object = s3Service.putObject(bucket, object);

         // Print the details about the uploaded object, which contains more information.
        // System.out.println("S3Object after upload: " + object);
         
         object = new S3Object(outputFile2);
         object.setAcl(AccessControlList.REST_CANNED_PUBLIC_READ);
         

         // Upload the object to our test bucket in S3.
        object = s3Service.putObject(bucket, object);
        // System.out.println("IMAGE uploaded: " + object);
         buff.append( "YES" );
         
         outputFile.delete();
         outputFile2.delete();
         List2.singleton.parseLine(file_name+" "+display_name);
         List2.singleton.updateBuffers();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			 outputFile.delete();
	         outputFile2.delete();
			e.printStackTrace();
			buff.append("NOTHX");
		}
          
         
        }

        
        outp.write( ""+buff );
    }

    protected void doPost( HttpServletRequest req, HttpServletResponse resp ) throws ServletException, IOException
    {
        doGet( req, resp );
    }
    
    public byte[] createChecksum(String filename) throws
    Exception
{
  InputStream fis =  new FileInputStream(filename);

  byte[] buffer = new byte[1024];
  MessageDigest complete = MessageDigest.getInstance("MD5");
  int numRead;
  long total=0;
  do {
   numRead = fis.read(buffer);
   if (numRead > 0) {
	   total+=numRead;
     complete.update(buffer, 0, numRead);
     }
   } while (numRead != -1&&total<(1024*1024*5));
  if(numRead)
  fis.close();
  return complete.digest();
}

// see this How-to for a faster way to convert
// a byte array to a HEX string
public  String getMD5Checksum(String filename) throws Exception {
  byte[] b = createChecksum(filename);
  String result = "";
  for (int i=0; i < b.length; i++) {
    result +=
       Integer.toString( ( b[i] & 0xff ) + 0x100, 16).substring( 1 );
   }
  return result;
}
}