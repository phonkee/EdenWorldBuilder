import java.io.*;
import java.security.MessageDigest;
import java.util.*;
import java.util.zip.*;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import org.jets3t.service.*;
import org.jets3t.service.acl.*;
import org.jets3t.service.impl.rest.httpclient.*;
import org.jets3t.service.model.*;
import org.jets3t.service.security.*;


public class UploadMap2 extends HttpServlet implements Runnable
{
   /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
   String path;
   String awsAccessKey;
   String awsSecretKey;
   
   static int openc=0;
   AWSCredentials awsCredentials;
   S3Service s3Service;
   S3Bucket bucket;
   int activeupload=0;
   static long mostrecent;
   static long filesuploaded=0;
   Vector<UploadObject> filelist=new Vector<UploadObject>();
   public void init(ServletConfig cfg) throws ServletException{
		super.init(cfg);
		mostrecent=0;
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
		new Thread(this).start();
   } 
   
	protected void doGet( HttpServletRequest req, HttpServletResponse resp ) throws ServletException, IOException
    {
		activeupload++;
		PrintWriter outp = resp.getWriter();
		StringBuilder buff = new StringBuilder();

		Collection<Part> parts=req.getParts();
		
		
		if(parts.size()<2){
		
				buff.append("Less than 2 files");
			outp.write( ""+buff );
			activeupload--;
			return;
		}
		Iterator<Part> itp=parts.iterator();
		Part file1=itp.next();
		Part file2=itp.next();
		boolean corrupt=false;
		
		if(file1==null||file2==null){
			System.out.println("missing a part");
			outp.write( ""+buff );
			activeupload--;
			return;
		}
		else
		{
			long time=System.currentTimeMillis()/1000;
			if(time<=mostrecent){
				time=++mostrecent;
				System.out.println("\nupload rate higher than 1 per second!\n");
			}
			mostrecent=time;
			File outputFile = new File( path+"eden_maps2/"+time+".eden" );
			while(outputFile.exists()){
				outputFile = new File( path+"eden_maps2/"+(++time)+".eden" );
			}
			
			File outputFile2=new File( path+"eden_maps2/"+(time)+".eden.png" );

			String file_name=time+".eden";
			// File temp=new File(path+"2"+time);
			GZIPInputStream gzipInputStream=null;
			InputStream fstream=null;
			byte[] buf = new byte[1024];
			int len=0;
			try{
				fstream=file1.getInputStream();
				gzipInputStream=
					new GZIPInputStream(fstream);
			openc++;
			// Open the output file            	
			//  OutputStream out = new FileOutputStream(temp);
			// Transfer bytes from the compressed file to the output file
			

			
			len = gzipInputStream.read(buf);
			}catch(IOException ex){
				ex.printStackTrace();
			}finally{
				openc--;
				if(fstream!=null)
					fstream.close();
				if(gzipInputStream!=null){
				gzipInputStream.close();
				
				}
			}
			//  out.write(buf, 0, len);

			// Close the file and stream
			
			//out.close();
			char[] cbuf=new char[1024];
			for(int i=0;i<1024;i++){
				cbuf[i]=(char)buf[i];
			}
			StringBuilder name=new StringBuilder();
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
				System.out.println("\nname:'"+name+"'"+" toString:'"+name.toString()+"'");
				int version=(int)cbuf[92];
				if(version!=2&&version!=3){
					version=(int)cbuf[91];

				}
				System.out.println("version:"+(int)cbuf[94]+','+(int)cbuf[93]+','+(int)cbuf[92]+','+(int)cbuf[91]+','+(int)cbuf[90]);
				StringBuilder hash=new StringBuilder();
				for(int i=95;i<95+33;i++){
					hash.append(cbuf[i]);
				}
				// fr.close();
				// temp.delete();
				file2.write(outputFile2.getName());
				try{
					String real_hash=getMD5Checksum(outputFile2.getAbsolutePath());
					
					if(real_hash.trim().equals(hash.toString().trim())&&(version==2||version==3)){
						System.out.println("hash checks out '"+hash+"=="+real_hash+"'"); 
						System.out.println("openhandle count:"+openc +" filesuploaded count: "+filesuploaded);
						System.out.println("Active uploads: "+activeupload+"  Active searches and req:"+List2.singleton.activereq.get());
					}else{
					 
						System.out.println("version:"+version+ " hashes:'"+hash+"=?="+real_hash+"'");
						corrupt=true;
						//936d55d3f620b9c2bc2447dcfcff2794!=
						//936d55d3f620b9c2bc2447dcfcff2794
					}
				}catch(Exception ex){
					System.out.println("--err: hash, version mismatch or couldnt open file:outputFile2.getAbsolutePath()");
					corrupt=true;
					
					ex.printStackTrace();

				}
			}
			if(corrupt) {
				outputFile.delete();
				outputFile2.delete();
				buff.append("NOTHX");
				outp.write( ""+buff );
				activeupload--;
				return;
			}

			String display_name=name.toString();
			synchronized(List2.singleton){
				
				FileWriter fw=null;
				try{
					openc++;
					fw=new FileWriter(path+"file_list2.txt",true);
					
					fw.append(file_name+" "+display_name+"\n");
				}catch(IOException ex){
					ex.printStackTrace();
				}finally{
					openc--;
					if(fw!=null)
					fw.close();
				}
			}
			file1.write( outputFile.getName() );


			UploadObject o=new UploadObject();
			o.display_name=display_name;
			o.file_name=file_name;
			o.file1=outputFile;
			o.file2=outputFile2;
			System.out.println("Adding:"+outputFile.getName()+ " and "+ outputFile2.getName()+ " to list. "+
			" Display_name:"+display_name+"  File name:"+file_name);
			synchronized(filelist){
			filelist.add(o);
			if(filelist.size()>200){
				System.out.println("filelist not being cleared");
			}
			}
			buff.append( "YES" );
		}

		activeupload--;
		outp.write( ""+buff );
    }

    protected void doPost( HttpServletRequest req, HttpServletResponse resp ) throws ServletException, IOException
    {
        doGet( req, resp );
    }
    
    public byte[] createChecksum(String filename) throws
    Exception
{
  InputStream fis = null; 
  MessageDigest complete=null;
try{
	openc++;
	fis=new FileInputStream(filename);
	
  byte[] buffer = new byte[1024];
  complete = MessageDigest.getInstance("MD5");
  int numRead;
  long total=0;
  do {
   numRead = fis.read(buffer);
   if (numRead > 0) {
	   total+=numRead;
     complete.update(buffer, 0, numRead);
     }
   } while (numRead != -1&&total<(1024*1024*5));
}catch(IOException ex){
	ex.printStackTrace();
}finally{
	openc--;
	
	if(fis!=null)
		fis.close();
}
	if(complete!=null)
  return complete.digest();
	else return new byte[1024];
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

float timert=500;
long curtime=System.currentTimeMillis();
@Override
public void run() {
	

	while(true){
	try {
		float etime=System.currentTimeMillis()-curtime;
		if(etime/1000.0f>20){
			System.out.println("Took longer than 20 seconds to upload a map");
		}
		timert+=System.currentTimeMillis()-curtime;
		curtime=System.currentTimeMillis();
		if(timert/1000.0f>500){
			System.out.println("gcing");
			System.gc();System.gc();System.gc();
			timert=0;
			System.out.println("Free heap:"+Runtime.getRuntime().freeMemory() + " / " + Runtime.getRuntime().totalMemory());
			
			synchronized(List2.singleton){
			List2.singleton.printMapSizes();
			}
		}
		Thread.sleep(50);
	} catch (InterruptedException e1) {
		// TODO Auto-generated catch block
		e1.printStackTrace();
	}
	while(filelist.size()>0){
		if(filelist.size()>200){
			System.out.println("filelist not being cleared");
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}
		UploadObject o=null;
		synchronized(filelist){
		o=filelist.remove(0);
		}

		S3Object object=null,object2=null;
		try{

			openc++;
			object = new S3Object(o.file1);
			object.setAcl(AccessControlList.REST_CANNED_PUBLIC_READ);
			// System.out.println("S3Object before upload: " + object);

			// Upload the object to our test bucket in S3.
			object = s3Service.putObject(bucket, object);

			// Print the details about the uploaded object, which contains more information.
			// System.out.println("S3Object after upload: " + object);

			object2 = new S3Object(o.file2);
			object2.setAcl(AccessControlList.REST_CANNED_PUBLIC_READ);


			// Upload the object to our test bucket in S3.
			object2 = s3Service.putObject(bucket, object2);
			// System.out.println("IMAGE uploaded: " + object);




			synchronized(List2.singleton){
				List2.singleton.parseLine(o.file_name+" "+o.display_name);
				List2.singleton.updateBuffers();
				filesuploaded++;
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			
			e.printStackTrace();

		}finally{
			openc--;
			try{
				if(object!=null)
				object.closeDataInputStream();
				}catch(Exception ex){
					
				}
			try{
				if(object2!=null)
				object2.closeDataInputStream();
				}catch(Exception ex){
					
				}
			o.file1.delete();
			o.file2.delete();


		}

	}
	}

}
}
class UploadObject{
	public String file_name,display_name;
	public File file1,file2;
	
	
	
	
	
		

}