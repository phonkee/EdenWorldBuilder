//
//  Util.m
//  prototype
//
//  Created by Ari Ronen on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "Globals.h"
#import "Util.h"
#import <OpenGLES/ES1/gl.h>
#import "World.h"
#import "glu.h"
#include <QuartzCore/QuartzCore.h>
#import "EAGLView.h"
#import "md5.h"
#import "Model.h"

@implementation Util
float dotProduct(Vector A,Vector B){
    
    return A.x*B.x + A.y*B.y + A.z*B.z;
}
Vector crossProduct(Vector v1, Vector v2)
{
    Vector result;
    result.x = v1.y*v2.z - v1.z*v2.y;
    result.y = v1.z*v2.x - v1.x*v2.z;
    result.z = v1.x*v2.y - v1.y*v2.x;
    return result;
}
Vector v_mult(Vector v,float scalar){
   
    v.x*=scalar;
    v.y*=scalar;
    v.z*=scalar;
    return v;
}
Vector v_div(Vector vec,float scalar){
    Vector v=vec;
    if(scalar==0)scalar=.0000000001;
    v.x/=scalar;
    v.y/=scalar;
    v.z/=scalar;
    return v;
}
Vector v_add(Vector vec,Vector v2){
     Vector v=vec;
    v.x+=v2.x;
    v.y+=v2.y;
    v.z+=v2.z;
    return v;
}

Vector v_sub(Vector vec,Vector v2){
    Vector v=vec;
    v.x-=v2.x;
    v.y-=v2.y;
    v.z-=v2.z;
    return v;
}
bool v_equals(Vector vec,Vector v2){
    return vec.x==v2.x&&vec.y==v2.y&&vec.z==v2.z;
}
float v_length2(Vector v){
    
    
    return v.x*v.x+v.y*v.y+v.z*v.z;
}
Vector MakeVector(float x,float y,float z){
    Vector v;
    v.x=x;
    v.y=y;
    v.z=z;
    return v;
    
}
int sign(float f){
    
    if(f>0)return 1;
    else return -1;
}
extern GLshort cubeShortVertices[];
const static float cubeFaceNormals[] = {
	0,0,1, //front face
	0,0,-1, //back face
	-1,0,0, //left face
	1,0,0, //right face
	0,-1,0, //bot face
	0,1,0, //top face	
	
};
Polyhedra makeSide(float left,float right,float back,float front,float bot,float top,int type){
    Polyhedra box;
    
    box.n_faces=5;
    box.n_points=6;
    box.points[0]=MakeVector(left,bot,front);
    box.points[1]=MakeVector(left,top,front);
    box.points[2]=MakeVector(right,bot,front);
    box.points[3]=MakeVector(right,top,front);
    box.points[4]=MakeVector(right,bot,back);
    box.points[5]=MakeVector(right,top,back);
    // box.points[6]=MakeVector(left,bot,back);    
    // box.points[7]=MakeVector(left,top,back);
    
    
    int hiddenface=-1;
    int sideface;
    Vector sidenormal;
    
    type=(type+1)%4;
    if(type==0){
        sidenormal=MakeVector(-.707,0,.707);
        hiddenface=1;
        sideface=2;
    }else if(type==1){
        sidenormal=MakeVector(-.707,0,-.707);
        hiddenface=2;
        sideface=0;
        box.points[0]=MakeVector(left,bot,back);    
        box.points[1]=MakeVector(left,top,back);
               
    }else if(type==2){
        sidenormal=MakeVector(.707,0,-.707);
        hiddenface=0;
        sideface=3;
        box.points[2]=MakeVector(left,bot,back);    
        box.points[3]=MakeVector(left,top,back);
        
    }else if(type==3){
        sidenormal=MakeVector(.707,0,.707);
        hiddenface=3;
        sideface=1;
        box.points[4]=MakeVector(left,bot,back);    
        box.points[5]=MakeVector(left,top,back);
      //  NSLog(@"hi");
       
        
    }
    
    
    int i=0;
    for(int j=0;j<6;j++){
        if(j==hiddenface)continue;
        
        box.faces[i].normal=MakeVector(cubeFaceNormals[j*3],
                                       cubeFaceNormals[j*3+1],
                                       cubeFaceNormals[j*3+2]);
        box.faces[i].sharedface=FALSE;
        box.faces[i].n_points=4;
        
        for(int k=0;k<4;k++){
            box.faces[i].points[k]=MakeVector(cubeShortVertices[j*18+k*3],
                                              cubeShortVertices[j*18+k*3+1],
                                              cubeShortVertices[j*18+k*3+2]);
        }
        if(j==sideface){
            box.faces[i].normal=sidenormal;
            if(j==2)
            box.faces[i].points[0]=v_add(box.points[0],v_mult(MakeVector(left,bot,front),-1));
            else if(j==0)
            box.faces[i].points[0]=v_add(box.points[0],v_mult(MakeVector(left,bot,back),-1));
            else if(j==3)
            box.faces[i].points[0]=v_add(box.points[0],v_mult(MakeVector(left,bot,front),-1));  
            else if(j==1)
            box.faces[i].points[0]=v_add(box.points[4],v_mult(MakeVector(left,bot,back),-1));
           
            //box.faces[i].points[0]=box.points[3];
            
        }
        i++;
        
    }
    
    
    
    return box;
}

Polyhedra makeBox(float left,float right,float back,float front,float bot,float top){
    Polyhedra box;
    box.n_faces=6;
    box.n_points=8;
    box.points[0]=MakeVector(left,bot,front);
    box.points[1]=MakeVector(left,bot,back);
    box.points[2]=MakeVector(right,bot,back);
    box.points[3]=MakeVector(right,bot,front);
    box.points[4]=MakeVector(left,top,front);
    box.points[5]=MakeVector(left,top,back);
    box.points[6]=MakeVector(right,top,back);
    box.points[7]=MakeVector(right,top,front); 
    for(int i=0;i<6;i++){
        box.faces[i].normal=MakeVector(cubeFaceNormals[i*3],
                                       cubeFaceNormals[i*3+1],
                                       cubeFaceNormals[i*3+2]);
        box.faces[i].sharedface=FALSE;
        box.faces[i].n_points=4;
        for(int j=0;j<4;j++){
            box.faces[i].points[j]=MakeVector(cubeShortVertices[i*18+j*3],
                                              cubeShortVertices[i*18+j*3+1],
                                              cubeShortVertices[i*18+j*3+2]);
        }
        
    }
    
    
    return box;
}

Polyhedra makeRamp(float left,float right,float back,float front,float bot,float top,int type){
    Polyhedra box;
    box.n_faces=5;
    box.n_points=6;
    box.points[0]=MakeVector(left,bot,front);
    box.points[1]=MakeVector(left,bot,back);
    box.points[2]=MakeVector(right,bot,back);
    box.points[3]=MakeVector(right,bot,front);
    int hiddenface=-1;
    Vector topnormal;
    type=(type+3)%4;
    if(type==0){
        box.points[4]=MakeVector(left,top,front);
        box.points[5]=MakeVector(left,top,back);
        topnormal=MakeVector(.707,.707,0);
        hiddenface=3;
    }else if(type==1){
        box.points[4]=MakeVector(left,top,front);
        box.points[5]=MakeVector(right,top,front); 
        topnormal=MakeVector(0,.707,.707);
        hiddenface=1;
    }else if(type==2){
        box.points[4]=MakeVector(right,top,front);
        box.points[5]=MakeVector(right,top,back);  
        topnormal=MakeVector(-.707,.707,0);
        hiddenface=2;
    }else if(type==3){
        box.points[4]=MakeVector(left,top,back);
        box.points[5]=MakeVector(right,top,back);  
        topnormal=MakeVector(0,.707,-.707);
        hiddenface=0;
    }
    
    
    int i=0;
    for(int j=0;j<6;j++){
        if(j==hiddenface)continue;
        
        box.faces[i].normal=MakeVector(cubeFaceNormals[j*3],
                                       cubeFaceNormals[j*3+1],
                                       cubeFaceNormals[j*3+2]);
        box.faces[i].sharedface=FALSE;
        box.faces[i].n_points=4;
        for(int k=0;k<4;k++){
            box.faces[i].points[k]=MakeVector(cubeShortVertices[j*18+k*3],
                                              cubeShortVertices[j*18+k*3+1],
                                              cubeShortVertices[j*18+k*3+2]);
        }
        if(j==4){
            box.faces[i].normal=topnormal;
            //box.faces[i].points[0]=box.points[3];
            
        }
        i++;
        
    }
    
    
    
    return box;
}


NSString* genhash(){
	char str[41];
	for(int i=0;i<41;i++){
		str[i]=arc4random()%26+'a';		
	}
	str[40]='\0';
	
	return [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
}
extern EAGLView* G_EAGL_VIEW;
extern float SCREEN_WIDTH; 
extern float SCREEN_HEIGHT;
void takeScreenshot(){	
	int width=SCREEN_HEIGHT;
    int height=SCREEN_WIDTH;
    if(IS_RETINA){
        width*=2;
        height*=2;
    }else if(IS_IPAD){
        width=IPAD_HEIGHT;
        height=IPAD_WIDTH;
    }
	NSInteger myDataLength = width * height * 4;
	
	// allocate array and read pixels into it.
	GLubyte *buffer = (GLubyte *) malloc(myDataLength);
	glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
	
	// gl renders "upside down" so swap top to bottom into new array.
	// there's gotta be a better way, but this works.
	GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);
	BOOL flip=[World getWorld].FLIPPED;
	for(int y = 0; y < height; y++)
	{
		for(int x = 0; x < width; x++)
		{
			for(int b=0;b<4;b++){
				if(flip)
				buffer2[x * height * 4 + y*4 +b] = buffer[y * 4 * width + x*4 +b];
				else
				buffer2[(width-1-x) * height * 4 + y*4 +b] = buffer[(height-1-y) * 4 * width + x*4 +b];
			}
		}
	}
	free(buffer);
	// make data provider with data.
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer2, myDataLength, NULL);
	
	// prep the ingredients
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * height;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	// make the cgimage
	CGImageRef imageRef = CGImageCreate(height, width, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
	
	// then make the uiimage from that
	UIImage *myImage = [UIImage imageWithCGImage:imageRef];
    if(myImage==NULL)return;
  // UIImageWriteToSavedPhotosAlbum(myImage, nil, nil, nil);
    if(IS_IPAD||IS_RETINA){
        UIGraphicsBeginImageContext(CGSizeMake(SCREEN_WIDTH,SCREEN_HEIGHT));
        
        CGRect thumbnailRect = CGRectZero;
        thumbnailRect.origin = CGPointMake(0,0);
        thumbnailRect.size.width  = SCREEN_WIDTH;
        thumbnailRect.size.height = SCREEN_HEIGHT;
        
        [myImage drawInRect:thumbnailRect];
        
        myImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
     
    NSData* data=UIImagePNGRepresentation(myImage);
    CGImageRelease(imageRef);
    CFRelease(provider);
    free(buffer2);
    Terrain* ter=[[World getWorld] terrain];
	NSString* name=ter.world_name;
    NSString* file_name=[NSString stringWithFormat:@"%@/%@.png",[World getWorld].fm.documents,name];
    NSFileManager* fm=[NSFileManager defaultManager];
	if([fm fileExistsAtPath:file_name])
        if(![fm removeItemAtPath:file_name error:NULL])
            return;
    [data writeToFile:file_name atomically:FALSE];
    
    CFStringRef md5hash = 
    FileMD5HashCreateWithPath((CFStringRef)file_name, 
                              FileHashDefaultChunkSizeForReadingData);
  
    [[World getWorld].fm setImageHash:(NSString *)md5hash];
    //CFRelease(md5hash);

}
// r,g,b values are from 0 to 1
// h = [0,360], s = [0,1], v = [0,1]
//		if s == 0, then h = -1 (undefined)
void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v )
{
	float min, max, delta;
	min = r<g?((r<b)?r:b):(g<b?g:b); //min
	max = r>g?((r>b)?r:b):(g>b?g:b); //max
	*v = max;				// v
	delta = max - min;
	if( max != 0 )
		*s = delta / max;		// s
	else {
		// r = g = b = 0		// s = 0, v is undefined
		*s = 0;
		*h = -1;
		return;
	}
	if( r == max )
		*h = ( g - b ) / delta;		// between yellow & magenta
	else if( g == max )
		*h = 2 + ( b - r ) / delta;	// between cyan & yellow
	else
		*h = 4 + ( r - g ) / delta;	// between magenta & cyan
	*h *= 60;				// degrees
	if( *h < 0 )
		*h += 360;
}

void HSVtoRGB( float *r, float *g, float *b, float h, float s, float v )
{
	int i;
	float f, p, q, t;
	if( s == 0 ) {
		// achromatic (grey)
		*r = *g = *b = v;
		return;
	}
	h /= 60;			// sector 0 to 5
	i = floor( h );
	f = h - i;			// factorial part of h
	p = v * ( 1 - s );
	q = v * ( 1 - s * f );
	t = v * ( 1 - s * ( 1 - f ) );
	switch( i ) {
		case 0:
			*r = v;
			*g = t;
			*b = p;
			break;
		case 1:
			*r = q;
			*g = v;
			*b = p;
			break;
		case 2:
			*r = p;
			*g = v;
			*b = t;
			break;
		case 3:
			*r = p;
			*g = q;
			*b = v;
			break;
		case 4:
			*r = t;
			*g = p;
			*b = v;
			break;
		default:		// case 5:
			*r = v;
			*g = p;
			*b = q;
			break;
	}
}
int fwc_result;
Vector fpoint;
int offsetdir;
bool hitCustom;
Point3D findWorldCoords(int mx,int my,int mode){
     if(IS_IPAD){
         mx*=SCALE_HEIGHT;
         my*=SCALE_WIDTH;
     }
    fwc_result=-1;
	Point3D point;
	point.x=-1;
	GLint viewport[4];
	GLdouble modelview[16];
	GLdouble projection[16];
	GLfloat modelviewf[16];
	GLfloat projectionf[16];
	GLfloat winX, winY;
	GLdouble posX, posY, posZ;
	GLdouble posX2, posY2, posZ2;
	glMatrixMode(GL_MODELVIEW);
	
	glLoadIdentity();
	glRotatef(270,0,0,1);
	[[World getWorld].cam render2];
	
	glGetFloatv( GL_MODELVIEW_MATRIX, modelviewf );
	glGetFloatv( GL_PROJECTION_MATRIX, projectionf );
	glGetIntegerv( GL_VIEWPORT, viewport );
	for(int i=0;i<16;i++){
		modelview[i]=modelviewf[i];
		projection[i]=projectionf[i];
	}
	
	winX = (float)mx;
	winY = (float)viewport[3] - (float)my;
	
	gluUnProject( winX, winY, 0, modelview, projection, viewport, &posX, &posY, &posZ);
	gluUnProject( winX, winY, 1, modelview, projection, viewport, &posX2, &posY2, &posZ2);
	
	
	
	Vector wp1,wp2;
	wp1.x=posX;
	wp1.y=posY;
	wp1.z=posZ;
	wp2.x=posX2;
	wp2.y=posY2;
	wp2.z=posZ2;
	Vector dir;
	
	
	
	//NSLog(@"wp1(%.2f,%.2f,%.2f) wp2(%.2f,%.2f,%.2f)",wp1.x,wp1.y,wp1.z,wp2.x,wp2.y,wp2.z);
	
	dir.x=wp2.x-wp1.x;
	dir.y=wp2.y-wp1.y;
	dir.z=wp2.z-wp1.z;
	dir.x=dir.x;
	dir.y=dir.y;
	dir.z=dir.z;
	wp1.x/=BLOCK_SIZE;
	wp1.y/=BLOCK_SIZE;
	wp1.z/=BLOCK_SIZE;
	
	//printf("wp1.x: %f wp1.z: %f \n",wp1.x,wp1.z);
	NormalizeVector(&dir);
	
	
	for(int i=0;i<8*10;i++){
        fpoint.x=wp1.x+dir.x*i/8.0f;
        fpoint.y=wp1.y+dir.y*i/8.0f;
        fpoint.z=wp1.z+dir.z*i/8.0f;
		int tx=(int)(fpoint.x);
		int ty=(int)(fpoint.y);
		int tz=(int)(fpoint.z);
    //    if([World getWorld].hud.build_size==2){
     //       tx=roundf(fpoint.x);
      //      ty=roundf(fpoint.y);
       //     tz=roundf(fpoint.z);
        //}

       // if(i%5==0){
            int idx=PointTestModels(wp1.x+dir.x*i/8.0f,wp1.y+dir.y*i/8.0f,wp1.z+dir.z*i/8.0f);
            if(idx!=-1){
                fwc_result=idx;
                point.x=fpoint.x;
                point.y=fpoint.y;
                point.z=fpoint.z;
              //  printf("hit!!! %d\n",idx);
                return point;
            }
            
       // }
        hitCustom=FALSE;
		int type=[[World getWorld].terrain getLand:tx :tz :ty];
     /*   BOOL build2solid=FALSE;
        int dx[]={0,0,0,0,1,1,1,1};
        int dy[]={0,0,1,1,0,0,1,1};
        int dz[]={0,1,0,1,0,1,0,1};*/
        
		if((type!=TYPE_NONE&&type!=-1))	{
            Polyhedra pbox2;
            Polyhedra pbox=makeBox(fpoint.x,fpoint.x+.001,
                                   
                                   fpoint.z+.001,fpoint.z,
                                   fpoint.y,fpoint.y+.001);
            if(type==TYPE_CUSTOM){
                
                if(([World getWorld].hud.build_size==0&&mode==FC_PLACE)||mode==FC_DESTROY){
                   
                    pbox2=makeBox(tx,tx+1,tz+1,tz,ty,ty+1);
               
                    if(!collidePolyhedra(pbox,pbox2))
                        continue;
                    float ftx=fpoint.x-tx;
                    float fty=fpoint.y-ty;
                    float ftz=fpoint.z-tz;
                    if(ftx>.6)ftx-=.00001;
                    if(fty>.6)fty-=.00001;
                    if(ftz>.6)ftz-=.00001;
                   // printf("prerounding: (%f,%f,%f)\n",ftx,ftz,fty);
                    ftx=roundf(ftx);
                    fty=roundf(fty);
                    ftz=roundf(ftz);
                    
                    int typec=getCustomc(tx*2+ftx,tz*2+ftz,ty*2+fty);
                        
                    if(typec==TYPE_NONE){
                      
                       // printf("passing through custom block(%f,%f,%f)\n",tx*2+ftx,tz*2+ftz,ty*2+fty);
                        continue;
                        
                       
                    }else{
                       //  printf("Collided with custom block: %d\n",typec);
                       /* point.x=(((float)tx*2));
                        point.y=(((float)ty*2));
                        point.z=(((float)tz*2));
                        printf("building custom block(%d,%d,%d), (%f,%f,%f)\n",tx*2,tz*2,ty*2,ftx,ftz,fty);
                        break;*/  
                    }
                                  
                    ftx/=2.0f;
                    fty/=2.0f;
                    ftz/=2.0f;
                    
                    pbox2=makeBox(tx+ftx,tx+ftx+.5f,tz+ftz+.5f,tz+ftz,ty+fty,ty+fty+.5f);
                   
                    if(!collidePolyhedra(pbox,pbox2))
                        continue;
                    
                     //printf("hit smallblock (%f,%f,%f)\n",tx+ftx,ty+fty,tz+ftz);
                    hitCustom=TRUE;
                    tx=(((float)tx*2)+ftx*2);
                    ty=(((float)ty*2)+fty*2);
                   tz=(((float)tz*2)+ftz*2);
                    
                   // printf("building custom block(%d,%d,%d), (%f,%f,%f)\n",tx*2,tz*2,ty*2,ftx,ftz,fty);

                }
                else{
                    pbox2=makeBox(tx,tx+1,tz+1,tz,ty,ty+1);
                    
                    if(!collidePolyhedra(pbox,pbox2))
                        continue;
                }
                    
            }else{
                if(type>=TYPE_STONE_RAMP1&&type<=TYPE_ICE_RAMP4){
                    
                    pbox2=makeRamp(tx,tx+1,tz+1,tz,ty,ty+1,type%4);
                    // NSLog(@"yop");
                    
                }else if(type>=TYPE_STONE_SIDE1&&type<=TYPE_ICE_SIDE4){
                    pbox2=makeSide(tx,tx+1,tz+1,tz,ty,ty+1,type%4);
                    
                }else if(blockinfo[type]&IS_LIQUID){
                    //printf("sup\n");
                    pbox2=makeBox(tx,tx+1,tz+1,tz,ty,ty+getLevel(type)/4.0f);
                }else
                    pbox2=makeBox(tx,tx+1,tz+1,tz,ty,ty+1);
                
                if(!collidePolyhedra(pbox,pbox2))
                    continue;
            }
            
			
			if(mode==FC_DESTROY||(mode==FC_PLACE&&(blockinfo[type]&IS_LIQUID&&getLevel(type)<4))){	
                
                
				point.x=tx;
				
				point.y=ty;
				point.z=tz;		
                
                
			}else if(mode==FC_PLACE){
				float min=999999999999999999999.0f;
                int mini=-1;
				int fx[]={-1,1,0,0,0,0};
				int fy[]={0,0,-1,1,0,0};
				int fz[]={0,0,0,0,-1,1};
                Vector mintersect;
				Vector norm;
				float D;
               /* if([World getWorld].hud.build_size==2){
                    tx=roundf(fpoint.x);
                    ty=roundf(fpoint.y);
                    tz=roundf(fpoint.z);
                }*/
                if(hitCustom){
                    wp1.x*=2;
                    wp1.y*=2;
                    wp1.z*=2;
                }
				for(int i=0;i<6;i++){
					norm.x=fx[i];
					norm.y=fy[i];
					norm.z=fz[i];
					if(i%2==0){
                        //if([World getWorld].hud.build_size==2)
                       //  D=-norm.x*(tx-1)-norm.y*(ty-1)-norm.z*(tz-1);   
                       //     else
						D=-norm.x*tx-norm.y*ty-norm.z*tz;
					}else {
						D=-norm.x*(tx+1)-norm.y*(ty+1)-norm.z*(tz+1);
					}				
					float a=dir.x*norm.x+dir.y*norm.y+dir.z*norm.z;					
					float rayPosDist2plane=wp1.x*norm.x+wp1.y*norm.y+wp1.z*norm.z+D;
					Vector intersect;
					
					if(rayPosDist2plane>0){
						intersect.x=wp1.x;
						intersect.y=wp1.y;
						intersect.z=wp1.z;	
						intersect.x-=dir.x*rayPosDist2plane/a;
						intersect.y-=dir.y*rayPosDist2plane/a;
						intersect.z-=dir.z*rayPosDist2plane/a;
						
						if(intersect.x>=tx&&intersect.y>=ty
						   &&intersect.z>=tz&&intersect.x<=tx+1
						   &&intersect.y<=ty+1&&intersect.z<=tz+1){
							
							
							float distToRay=intersect.x*intersect.x+
							intersect.y*intersect.y+
							intersect.z*intersect.z;
							//printf("hello builder: %f  %f (%f,%f,%f)  (%f,%f,%f)  dist2plane: %f  a:%f\n",distToRay,min,intersect.x,intersect.y,intersect.z,wp1.x,wp1.y,wp1.z,rayPosDist2plane,a);
							if(distToRay<min){
								mini=i;
                                mintersect=intersect;
								min=distToRay;
							}
						}
					}
				}
                //printf("hello builder: %d\n",mini);
                offsetdir=mini;
				int rx=tx+fx[mini];
				int ry=ty+fy[mini];
				int rz=tz+fz[mini];
                mintersect.x-=rx;
                mintersect.y-=ry;
                mintersect.z-=rz;
                point.x=rx;
				point.y=ry;
				point.z=rz;
                if([World getWorld].hud.build_size==0&&!hitCustom){
                  //  mintersect.x=mintersect.x;
                  //   mintersect.z=mintersect.z;
                   //  mintersect.y=mintersect.y;
                    if(mintersect.x>.5f)mintersect.x-=.01f;
                    if(mintersect.y>.5f)mintersect.y-=.01f;
                    if(mintersect.z>.5f)mintersect.z-=.01f;
                    point.x=(2.0f*((float)point.x+mintersect.x));
                    point.y=(2.0f*((float)point.y+mintersect.y));
                    point.z=(2.0f*((float)point.z+mintersect.z));
                    
                    
                }
				if([World getWorld].hud.build_size==2){
                    float rfx=fpoint.x+fx[mini];
                    float rfy=fpoint.y+fy[mini];
                    float rfz=fpoint.z+fz[mini];
                    point.x=roundf(rfx-1);
                    point.y=roundf(rfy-1);
                    point.z=roundf(rfz-1);
                    printf("fpoint: (%f,%f,%f)\n",fpoint.x,fpoint.y,fpoint.z);
                }
				
               // printf("pt: %d,%d,%d type:%d\n",rx,ry,rz,getLandc(rx,rz,ry));
				
			}
			
		
			break;
		}
		
	}
	if([World getWorld].hud.holding_creature&&[World getWorld].hud.blocktype==TYPE_CLOUD&&mode==FC_PLACE){
        point.x=wp1.x+dir.x*30/8.0f;
        point.y=wp1.y+dir.y*30/8.0f;
        point.z=wp1.z+dir.z*30/8.0f;
        
    }
	
	return point;
}
float randf(float max){
	float a=(float)arc4random()/UINT_MAX;
	

	return a*max;
	
}

int randi(int max){
	int a=arc4random()%max;
	
    
	return a;
	
}

int O(int r,int c){
	return c*4+r;
}
void MatrixMultiplyBy4x (float *src1, float *src2, float *dest)
{
    *(dest+O(0,0)) = (*(src1+O(0,0)) * *(src2+O(0,0))) + (*(src1+O(0,1)) * *(src2+O(1,0))) + (*(src1+O(0,2)) * *(src2+O(2,0))) + (*(src1+O(0,3)) * *(src2+O(3,0)));	
    *(dest+O(0,1)) = (*(src1+O(0,0)) * *(src2+O(0,1))) + (*(src1+O(0,1)) * *(src2+O(1,1))) + (*(src1+O(0,2)) * *(src2+O(2,1))) + (*(src1+O(0,3)) * *(src2+O(3,1)));	
    *(dest+O(0,2)) = (*(src1+O(0,0)) * *(src2+O(0,2))) + (*(src1+O(0,1)) * *(src2+O(1,2))) + (*(src1+O(0,2)) * *(src2+O(2,2))) + (*(src1+O(0,3)) * *(src2+O(3,2)));	
    *(dest+O(0,3)) = (*(src1+O(0,0)) * *(src2+O(0,3))) + (*(src1+O(0,1)) * *(src2+O(1,3))) + (*(src1+O(0,2)) * *(src2+O(2,3))) + (*(src1+O(0,3)) * *(src2+O(3,3)));	
    *(dest+O(1,0)) = (*(src1+O(1,0)) * *(src2+O(0,0))) + (*(src1+O(1,1)) * *(src2+O(1,0))) + (*(src1+O(1,2)) * *(src2+O(2,0))) + (*(src1+O(1,3)) * *(src2+O(3,0)));	
    *(dest+O(1,1)) = (*(src1+O(1,0)) * *(src2+O(0,1))) + (*(src1+O(1,1)) * *(src2+O(1,1))) + (*(src1+O(1,2)) * *(src2+O(2,1))) + (*(src1+O(1,3)) * *(src2+O(3,1)));	
    *(dest+O(1,2)) = (*(src1+O(1,0)) * *(src2+O(0,2))) + (*(src1+O(1,1)) * *(src2+O(1,2))) + (*(src1+O(1,2)) * *(src2+O(2,2))) + (*(src1+O(1,3)) * *(src2+O(3,2)));	
    *(dest+O(1,3)) = (*(src1+O(1,0)) * *(src2+O(0,3))) + (*(src1+O(1,1)) * *(src2+O(1,3))) + (*(src1+O(1,2)) * *(src2+O(2,3))) + (*(src1+O(1,3)) * *(src2+O(3,3)));	
    *(dest+O(2,0)) = (*(src1+O(2,0)) * *(src2+O(0,0))) + (*(src1+O(2,1)) * *(src2+O(1,0))) + (*(src1+O(2,2)) * *(src2+O(2,0))) + (*(src1+O(2,3)) * *(src2+O(3,0)));	
    *(dest+O(2,1)) = (*(src1+O(2,0)) * *(src2+O(0,1))) + (*(src1+O(2,1)) * *(src2+O(1,1))) + (*(src1+O(2,2)) * *(src2+O(2,1))) + (*(src1+O(2,3)) * *(src2+O(3,1)));	
    *(dest+O(2,2)) = (*(src1+O(2,0)) * *(src2+O(0,2))) + (*(src1+O(2,1)) * *(src2+O(1,2))) + (*(src1+O(2,2)) * *(src2+O(2,2))) + (*(src1+O(2,3)) * *(src2+O(3,2)));	
    *(dest+O(2,3)) = (*(src1+O(2,0)) * *(src2+O(0,3))) + (*(src1+O(2,1)) * *(src2+O(1,3))) + (*(src1+O(2,2)) * *(src2+O(2,3))) + (*(src1+O(2,3)) * *(src2+O(3,3)));	
    *(dest+O(3,0)) = (*(src1+O(3,0)) * *(src2+O(0,0))) + (*(src1+O(3,1)) * *(src2+O(1,0))) + (*(src1+O(3,2)) * *(src2+O(2,0))) + (*(src1+O(3,3)) * *(src2+O(3,0)));	
    *(dest+O(3,1)) = (*(src1+O(3,0)) * *(src2+O(0,1))) + (*(src1+O(3,1)) * *(src2+O(1,1))) + (*(src1+O(3,2)) * *(src2+O(2,1))) + (*(src1+O(3,3)) * *(src2+O(3,1)));	
    *(dest+O(3,2)) = (*(src1+O(3,0)) * *(src2+O(0,2))) + (*(src1+O(3,1)) * *(src2+O(1,2))) + (*(src1+O(3,2)) * *(src2+O(2,2))) + (*(src1+O(3,3)) * *(src2+O(3,2)));	
    *(dest+O(3,3)) = (*(src1+O(3,0)) * *(src2+O(0,3))) + (*(src1+O(3,1)) * *(src2+O(1,3))) + (*(src1+O(3,2)) * *(src2+O(2,3))) + (*(src1+O(3,3)) * *(src2+O(3,3)));	
}
void NormalizeVector(Vector* v){
	float rsqrt=sqrtf(v->x*v->x + v->y*v->y + v->z*v->z);
	if(rsqrt<.0000000001f&&rsqrt>-.0000000001f)rsqrt=.0000000001f;
	v->x=v->x/rsqrt;
	v->y=v->y/rsqrt;
	v->z=v->z/rsqrt;
}
BOOL inbox(float x,float y,CGRect rect){
//NSLog(@"%f, %f",x,y);
	float extra=4;
		if(x+extra>=rect.origin.x&&y+extra>=rect.origin.y&&
		   x-extra<=rect.origin.x+rect.size.width&&
		   y-extra<=rect.origin.y+rect.size.height)
			return TRUE;
	

	
		
	
	return FALSE;
}
BOOL inbox3(float x,float y,Button* rect){
    //NSLog(@"%f, %f",x,y);
	float extra=4;
    if(x+extra>=rect->origin.x&&y+extra>=rect->origin.y&&
       x-extra<=rect->origin.x+rect->size.width&&
       y-extra<=rect->origin.y+rect->size.height){
        rect->pressed=TRUE;
        return TRUE;
    }
	
    
	
    
	
	return FALSE;
}
CGRect RectFromButton(Button button){
    CGRect r;
  /*  if(button.pressed){
    float offx=button.size.width*.08f;
    float offy=button.size.height*.08f;
   r=CGRectMake(button.origin.x+offx,button.origin.y+offy,
                           button.size.width-offx*2,button.size.height-offy*2);
    }else{
    */
    r.origin.x=button.origin.x;
    r.origin.y=button.origin.y;
    r.size.width=button.size.width;
    r.size.height=button.size.height;
  //  }
    
    return r;
}
Button ButtonFromRect(CGRect b){
    Button r;
    r.origin.x=b.origin.x;
    r.origin.y=b.origin.y;
    r.size.width=b.size.width;
    r.size.height=b.size.height;
    r.pressed=FALSE;
    
    return r;
}
Button ButtonMake(float x,float y,float width,float height){
    Button b;
    b.origin.x=x;
    b.origin.y=y;
    b.size.width=width;
    b.size.height=height;
    return b;
}

BOOL inbox2(float x,float y,Button* rect){
    //NSLog(@"%f, %f",x,y);
	float extra=4;
    if(x+extra>=rect->origin.x&&y+extra>=rect->origin.y&&
       x-extra<=rect->origin.x+rect->size.width&&
       y-extra<=rect->origin.y+rect->size.height){
        rect->pressed=FALSE;
        return TRUE;
    }
	rect->pressed=FALSE;
    
	
    
	
	return FALSE;
}
int getColIndex(int cx,int cz){
    cx+=CHUNKS_PER_SIDE*50;
    cz+=CHUNKS_PER_SIDE*50;
    
    int num=(cx%CHUNKS_PER_SIDE)*CHUNKS_PER_SIDE+(cz%CHUNKS_PER_SIDE);
    
    return num;
}
float rsqrt( float number )
{
    long i;
    float x2, y;
    const float threehalfs = 1.5F;
    
    x2 = number * 0.5F;
    y  = number;
    i  = * ( long * ) &y;                       // evil floating point bit level hacking
    i  = 0x5f3759df - ( i >> 1 );               // what the fuck?
    y  = * ( float * ) &i;
    y  = y * ( threehalfs - ( x2 * y * y ) );   // 1st iteration
    //      y  = y * ( threehalfs - ( x2 * y * y ) );   // 2nd iteration, this can be removed
    
    return y;
}
int threeToOne(int cx,int cy,int cz){
    cx+=CHUNKS_PER_SIDE*50;
    cz+=CHUNKS_PER_SIDE*50;
    
    int num=(cx%CHUNKS_PER_SIDE)*CHUNKS_PER_SIDE*CHUNKS_PER_COLUMN+(cz%CHUNKS_PER_SIDE)*CHUNKS_PER_COLUMN+cy;
   
    return num;
    cx+=64;
    cy+=64;
    cz+=64;
	if(cx<0||cy<0||cz<0){
		NSLog(@"overflowing! %d,%d,%d ",cx,cz,cy);
		return 0;		
	}
	int n=(cx<<19)+(cz<<7)+cy;
	if(n<0){
		NSLog(@"overflowing! %d,%d,%d %X",cx,cz,cy,n);
		return 0;
	}
	return n;
}
int twoToOne(int cx,int cz){
	if(cx<0||cz<0||cx>=(1<<15)||cz>=(1<<15)){
		printf("overflowing! %d,%d \n",cx,cz);	
		return 0;
	}
	int n=(cx<<15)+cz;
	if(n<0){
		printf("overflowing! %d,%d %X \n",cx,cz,n);
		return 0;
	}
	return n;
}
void VectorMatrixMultiply(Vector* vDest, Vector vSrc,const float mat[16]){
	//untrustworthy/untested!
	float W=0;	
	W = 1.0f / (vSrc.x * mat[3] + vSrc.y * mat[7] + vSrc.z * mat[11] + mat[15]);
	vDest->x = (vSrc.x * mat[0] + vSrc.y * mat[4] + vSrc.z * mat[8] + mat[12]) * W;
	vDest->y = (vSrc.x * mat[1] + vSrc.y * mat[5] + vSrc.z * mat[9] + mat[13]) * W;
	vDest->z = (vSrc.x * mat[2] + vSrc.y * mat[6] + vSrc.z * mat[10] + mat[14]) * W;
	
	
}


@end
float Determinant4f(const float m[16])
{
	return
	m[12]*m[9]*m[6]*m[3]-
	m[8]*m[13]*m[6]*m[3]-
	m[12]*m[5]*m[10]*m[3]+
	m[4]*m[13]*m[10]*m[3]+
	m[8]*m[5]*m[14]*m[3]-
	m[4]*m[9]*m[14]*m[3]-
	m[12]*m[9]*m[2]*m[7]+
	m[8]*m[13]*m[2]*m[7]+
	m[12]*m[1]*m[10]*m[7]-
	m[0]*m[13]*m[10]*m[7]-
	m[8]*m[1]*m[14]*m[7]+
	m[0]*m[9]*m[14]*m[7]+
	m[12]*m[5]*m[2]*m[11]-
	m[4]*m[13]*m[2]*m[11]-
	m[12]*m[1]*m[6]*m[11]+
	m[0]*m[13]*m[6]*m[11]+
	m[4]*m[1]*m[14]*m[11]-
	m[0]*m[5]*m[14]*m[11]-
	m[8]*m[5]*m[2]*m[15]+
	m[4]*m[9]*m[2]*m[15]+
	m[8]*m[1]*m[6]*m[15]-
	m[0]*m[9]*m[6]*m[15]-
	m[4]*m[1]*m[10]*m[15]+
	m[0]*m[5]*m[10]*m[15];
}
float absf(float f){
	if(f<0)f*=-1;
	return f;
}
BOOL GenerateInverseMatrix4f(float i[16], const float m[16])
{
	float x=Determinant4f(m);
	if (x==0) return FALSE;
	
	i[0]= (-m[13]*m[10]*m[7] +m[9]*m[14]*m[7] +m[13]*m[6]*m[11]
		   -m[5]*m[14]*m[11] -m[9]*m[6]*m[15] +m[5]*m[10]*m[15])/x;
	i[4]= ( m[12]*m[10]*m[7] -m[8]*m[14]*m[7] -m[12]*m[6]*m[11]
		   +m[4]*m[14]*m[11] +m[8]*m[6]*m[15] -m[4]*m[10]*m[15])/x;
	i[8]= (-m[12]*m[9]* m[7] +m[8]*m[13]*m[7] +m[12]*m[5]*m[11]
		   -m[4]*m[13]*m[11] -m[8]*m[5]*m[15] +m[4]*m[9]* m[15])/x;
	i[12]=( m[12]*m[9]* m[6] -m[8]*m[13]*m[6] -m[12]*m[5]*m[10]
		   +m[4]*m[13]*m[10] +m[8]*m[5]*m[14] -m[4]*m[9]* m[14])/x;
	i[1]= ( m[13]*m[10]*m[3] -m[9]*m[14]*m[3] -m[13]*m[2]*m[11]
		   +m[1]*m[14]*m[11] +m[9]*m[2]*m[15] -m[1]*m[10]*m[15])/x;
	i[5]= (-m[12]*m[10]*m[3] +m[8]*m[14]*m[3] +m[12]*m[2]*m[11]
		   -m[0]*m[14]*m[11] -m[8]*m[2]*m[15] +m[0]*m[10]*m[15])/x;
	i[9]= ( m[12]*m[9]* m[3] -m[8]*m[13]*m[3] -m[12]*m[1]*m[11]
		   +m[0]*m[13]*m[11] +m[8]*m[1]*m[15] -m[0]*m[9]* m[15])/x;
	i[13]=(-m[12]*m[9]* m[2] +m[8]*m[13]*m[2] +m[12]*m[1]*m[10]
		   -m[0]*m[13]*m[10] -m[8]*m[1]*m[14] +m[0]*m[9]* m[14])/x;
	i[2]= (-m[13]*m[6]* m[3] +m[5]*m[14]*m[3] +m[13]*m[2]*m[7]
		   -m[1]*m[14]*m[7] -m[5]*m[2]*m[15] +m[1]*m[6]* m[15])/x;
	i[6]= ( m[12]*m[6]* m[3] -m[4]*m[14]*m[3] -m[12]*m[2]*m[7]
		   +m[0]*m[14]*m[7] +m[4]*m[2]*m[15] -m[0]*m[6]* m[15])/x;
	i[10]=(-m[12]*m[5]* m[3] +m[4]*m[13]*m[3] +m[12]*m[1]*m[7]
		   -m[0]*m[13]*m[7] -m[4]*m[1]*m[15] +m[0]*m[5]* m[15])/x;
	i[14]=( m[12]*m[5]* m[2] -m[4]*m[13]*m[2] -m[12]*m[1]*m[6]
		   +m[0]*m[13]*m[6] +m[4]*m[1]*m[14] -m[0]*m[5]* m[14])/x;
	i[3]= ( m[9]* m[6]* m[3] -m[5]*m[10]*m[3] -m[9]* m[2]*m[7]
		   +m[1]*m[10]*m[7] +m[5]*m[2]*m[11] -m[1]*m[6]* m[11])/x;
	i[7]= (-m[8]* m[6]* m[3] +m[4]*m[10]*m[3] +m[8]* m[2]*m[7]
		   -m[0]*m[10]*m[7] -m[4]*m[2]*m[11] +m[0]*m[6]* m[11])/x;
	i[11]=( m[8]* m[5]* m[3] -m[4]*m[9]* m[3] -m[8]* m[1]*m[7]
		   +m[0]*m[9]* m[7] +m[4]*m[1]*m[11] -m[0]*m[5]* m[11])/x;
	i[15]=(-m[8]* m[5]* m[2] +m[4]*m[9]* m[2] +m[8]* m[1]*m[6]
		   -m[0]*m[9]* m[6] -m[4]*m[1]*m[10] +m[0]*m[5]* m[10])/x;
	
	return TRUE;
} 

CGPoint CalculateInterval(Vector Axis, Vector* P,int p_length)
{
    float d = dotProduct(Axis,P[0]);   
    CGPoint minMax;
    minMax.x=minMax.y=d;
    for(int i = 0; i < p_length; i ++)
    {
        d =dotProduct(Axis,P[i]);
        if (d < minMax.x)
            minMax.x = d;
        else
    		if(d > minMax.y)
            	minMax.y = d;
    }
    return minMax;
}

Vector tranDist;
Vector minTranDist;
BOOL AxisSeparatePolygons(Vector Axis, Vector* A,int a_length, Vector* B,int b_length)
{
    CGPoint minMaxa;
    CGPoint minMaxb;
    
    minMaxa=CalculateInterval(Axis, A,a_length);
    minMaxb=CalculateInterval(Axis, B,b_length);
    
    if (minMaxa.x > minMaxb.y || minMaxb.x > minMaxa.y)
        return true;
    
    float d0 = minMaxa.y - minMaxb.x;
    float d1 = minMaxb.y - minMaxa.x;
    float depth = (d0 < d1)? d0 : d1;
    
    float axis_length_squared =dotProduct(Axis,Axis);
    Axis=v_mult(Axis,depth / axis_length_squared);
    tranDist=Axis;
    return false;
}



Vector calcCenter(Vector* points,int  n_points)
{
    Vector min=MakeVector(points[0].x,points[0].y,points[0].z);
    Vector max=MakeVector(points[0].x,points[0].y,points[0].z);
    
    for(int i=1;i<n_points;i++)
    {
        if(points[i].x<min.x)
            min.x=points[i].x;
        if(points[i].x>max.x)
            max.x=points[i].x;
        if(points[i].y<min.y)
            min.y=points[i].y;
        if(points[i].y>max.y)
            max.y=points[i].y;
        if(points[i].z<min.z)
            min.z=points[i].z;
        if(points[i].z>max.z)
            max.z=points[i].z;
    }
    
    return MakeVector((min.x+max.x)/2,(min.y+max.y)/2,(min.z+max.z)/2);
}
BOOL TestPoint(Polyhedra* A,float x,float y,float z){
    return collidePolyhedra(makeBox(x,x+.001,                                      
                                            z+.001,z,
                                            y,y+.001),*A);
}
BOOL collidePolyhedra(Polyhedra A,Polyhedra B)
{
    minTranDist=MakeVector(9999,9999,9999);
    float minLength=v_length2(minTranDist);
    for(int i=0;i<A.n_faces;i++)
    {
        //if(A.faces[i].sharedface)continue;
        Vector positionedNormal=v_add(A.faces[i].normal,A.faces[i].points[0]);
        if (AxisSeparatePolygons(positionedNormal, A.points,A.n_points, B.points,B.n_points))
            return false;
        
        if(v_length2(tranDist)<minLength){
            minLength=v_length2(tranDist);
            minTranDist=tranDist;
        }
    }
    for(int i=0;i<B.n_faces;i++)
    {
        // if(B.faces[i].sharedface)continue;
        Vector positionedNormal=v_add(B.faces[i].normal,B.faces[i].points[0]);
        if (AxisSeparatePolygons(positionedNormal, A.points,A.n_points, B.points,B.n_points))
            return false;
        
        
        if(v_length2(tranDist)<minLength){
            minLength=v_length2(tranDist);
            minTranDist=tranDist;
        }
        
    }
    
    Vector D = v_sub(calcCenter(A.points,A.n_points),calcCenter(B.points,B.n_points));
    if (dotProduct(D,minTranDist) < 0.0f)
        minTranDist=v_mult(minTranDist,-1);//MTD.set(MTD.mult(-1));
    ////
    // Test cross product of pairs of edges, one from each polyhedron.
    /*for (i = 0; i < C0.M; i++)
     {
     for (j = 0; j < C1.M; j++)
     {
     D = Cross(C0.E(i),C1.E(j));
     5int side0 = WhichSide(C0.V,D,C0.E(i).vertex);
     if ( side0 == 0)
     {
     continue;
     }
     int side1 = WhichSide(C1.V,D,C0.E(i).vertex);
     if ( side1 == 0 )
     {
     continue;
     }
     if ( side0*side1 < 0 )
     { // C0 and C1 are on ‘opposite’ sides of line C0.E(i).vertex+t*D
     return false;
     }
     }
     }*/
    
    return true;
}
/*static BOOL convexPolygon(Vector* A,int A_length, Vector* B, int B_length)
 {
 ArrayList<CVector> Axis=new ArrayList<CVector>();
 Vector E;
 Vector N;
 
 
 for(int J = A.length-1, I = 0; I < A.length; J = I, I ++)
 {
 E = A[I].vector().sub(A[J].vector());
 N = new CVector(-E.y, E.x);
 Axis.add(N);
 if (AxisSeparatePolygons(N, A, B))
 return false;
 }
 for(int J = B.length-1, I = 0; I < B.length; J = I, I ++)
 {
 E = B[I].vector().sub(B[J].vector());
 N = new CVector(-E.y, E.x);
 Axis.add(N);
 if (AxisSeparatePolygons(N, A, B))
 return false;
 }
 
 FindMTD(Axis);
 
 
 CVector D = calcCenter(A).sub(calcCenter(B));
 if (D.dot(MTD) < 0.0f)
 MTD.set(MTD.mult(-1));
 
 return true;
 }*/

