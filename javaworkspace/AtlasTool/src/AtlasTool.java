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
		
		BufferedImage buf=new BufferedImage(size,size2,BufferedImage.TYPE_INT_ARGB);
		BufferedImage scratch=new BufferedImage(size,size,BufferedImage.TYPE_INT_ARGB);
		Graphics2D g=buf.createGraphics();
		Graphics2D g2=scratch.createGraphics();
		int j=0;
		for(int i=0;i<num;i++){
			
			boolean colored=false;
			boolean nobw=false;
			String line=sc.nextLine();
			if(line.startsWith("!")){
				line=line.substring(1);
				colored=true;
			}
			if(line.startsWith("~")){
				line=line.substring(1);
				nobw=true;
				colored=true;
			}
			int frames=1;
			boolean colorCycling=false;
			char c=line.charAt(0);
			if(c>='1'&&c<='9'){
				frames=c-'0';
				if(frames==9){
					frames=8;
				colorCycling=true;
				}
				line=line.substring(1);
				i+=frames-1;
			}
			File fimg=new File(line);
			if(!fimg.exists()){
				System.out.println("\""+fimg.getName()+"\" does not exist");
				return;			   
			}
			Image img=ImageIO.read(fimg);
			if(colored){
				g.drawImage(img,0,size*j,null);
				j++;
				if(nobw)continue;
			}
			//g2.setBackground(new Color(255,255,255,0));
			
			//g2.clearRect(0, 0, 32, 32);
			g2.setComposite(AlphaComposite.getInstance(AlphaComposite.SRC));
			g.setComposite(AlphaComposite.getInstance(AlphaComposite.SRC));
			//g2.fillRect(0, 0, 32, 32);
			g2.drawImage(img,0,0,null);
			float brightest=0;
			int br=0,bg=0,bb=0;
			for(int x=0;x<size;x++){
				for(int y=0;y<size;y++){
					int n=scratch.getRGB(x,y);
					int cb=n&255;
					n>>=8;
					int cg=n&255;
					n>>=8;
					int cr=n&255;
					float[] hsv=Color.RGBtoHSB(cr, cg, cb, null);
					int isbrightest=cr+cg+cb;//(int)(.3f*cr+.59f*cg+.11f*cb));
					//isbrightest=Math.max(isbrightest,cg);
					//isbrightest=Math.max(isbrightest,cb);
					//System.out.println(Arrays.toString(hsv));
					if(hsv[2]>brightest){
						br=cr; 
						bg=cg;
						bb=cb;
						brightest=hsv[2];
					}
				}
			}
			int greyb=(int)(.3f*br+.3f*bg+.3f*bb);
			float dif=1.0f-brightest;
			int total=br+bg+bb;
			float pr=(float)br/255;
			float pg=(float)bg/255;
			float pb=(float)bb/255; 
			System.out.println(br+","+bg+","+bb+" --!"+fimg.getName());
			for(int x=0;x<size;x++){
				for(int y=0;y<size;y++){
					int n=scratch.getRGB(x,y);
					int cb=n&255;
					n>>=8;
					int cg=n&255;
					n>>=8;
					int cr=n&255;
					n>>=8;
					int ca=n&255;
					
					
					//cr+=dif;
					//cg+=dif;
					//cb+=dif;
					float[] hsv=Color.RGBtoHSB(cr, cg, cb, null);
					int grey=(int)(255*(float)(hsv[2])/brightest);
						//(int)(pr*cr+pg*cg+pb*cb);
					
					if(grey>255)System.out.println("wtf");
					n=ca;
					n<<=8;
					n|=grey;
					n<<=8;
					n|=grey;
					n<<=8;
					n|=grey;
					if(!colorCycling)
					scratch.setRGB(x, y, n);
					 
				}
			}
			int[][] sfr=new int[32][32];
			int high=0;
			int low=255;
			for(int ii=0;ii<32;ii++){
				for(int jj=0;jj<32;jj++){
					int rgb=scratch.getRGB(ii,jj)&255;
					if(high<rgb)high=rgb;
					if(low>rgb)low=rgb;
					sfr[ii][jj]=rgb;
					
				}
			}
			int range=high-low;
			for(int frame=0;frame<frames;frame++){
				if(colorCycling){
					for(int ii=0;ii<32;ii++){
						for(int jj=0;jj<32;jj++){
							int rgb=sfr[ii][jj];
							rgb=(rgb+(frame*range/frames));
							if(rgb>high)rgb=low+rgb%high;
							//rgb%=256;
						//	if(rgb>=256)rgb=255-(rgb-256);
							//System.out.print(","+rgb);
							scratch.setRGB(ii,jj,new Color(rgb,rgb,rgb).getRGB());
						}
					}
				}
			g.drawImage(scratch,0,size*j,32,size*j+frame*(32/frames),0,(frames-frame)*(32/frames),32,32,null);
			g.drawImage(scratch,0,size*j+frame*(32/frames),32,size*j+frame*(32/frames)+32,0,0,32,32,null);
			
			j++;
			}
			
		}
		File out=new File(args[1]);
		
		ImageIO.write(buf, "png", out);
		
		}catch(Exception ex){ex.printStackTrace();}
	}
}
