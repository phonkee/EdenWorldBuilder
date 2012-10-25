import java.util.*;
import java.awt.*;
import java.awt.image.*;
import java.io.*;

import javax.imageio.ImageIO;
public class AtlasTool {
	public static void main(String[] args){
		if(args.length<2){
			System.out.println("usage: AtlasTool <config>.txt <image output location>");
			System.out.println("config.txt format first line:<num_images> <image_size>");
			System.out.println("followed by num_images paths to images");
			return;
		}
		File f=new File(args[0]);
		if(!f.exists()){
			System.out.println("\""+args[0]+"\" does not exist");
			return;			
		}
		try{
		Scanner sc=new Scanner(f);
		int num=sc.nextInt();
		int size=sc.nextInt();
		sc.nextLine();
		int size2=size;
		for(int i=0;;i++){
		    size2=(1<<i);
		    if(size2>=size*num)
			break;
		}
		BufferedImage buf=new BufferedImage(32,size2,BufferedImage.TYPE_INT_RGB);
		Graphics g=buf.getGraphics();
		//		g.setColor(Color.BLACK);
		//g.fillRect(0,0,size,size2);
		for(int i=0;i<num;i++){
			File fimg=new File(sc.nextLine());
			if(!fimg.exists()){
				System.out.println("\""+fimg.getName()+"\" does not exist");
				return;			
			}
			Image img=ImageIO.read(fimg);
			
			g.drawImage(img,0,size*i,null);
			
			
			
			
			
		}
		File out=new File(args[1]);
		
		ImageIO.write(buf, "png", out);
		
		}catch(Exception ex){ex.printStackTrace();}
	}
}
