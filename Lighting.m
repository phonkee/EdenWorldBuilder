//
//  Lighting.m
//  Eden
//
//  Created by Ari Ronen on 1/21/13.
//
//

#import "Lighting.h"
#import "Terrain.h"
extern Vector* lightarray;
extern block8* blockarray;
@implementation Lighting

extern int g_offcx;
extern int g_offcz;
void addlight(int xx,int zz,int yy,float brightness,Vector color){

 //   printf("light intensities: ");
    for(int x=-LIGHT_RADIUS;x<=LIGHT_RADIUS;x++){
        for(int z=-LIGHT_RADIUS;z<=LIGHT_RADIUS;z++){
            for(int y=-LIGHT_RADIUS;y<=LIGHT_RADIUS;y++){
                if(x*x+z*z+y*y>LIGHT_RADIUS*LIGHT_RADIUS)continue;
                if(y+yy<0||y+yy>=T_HEIGHT)continue;
                float inten=1.0f-sqrtf(x*x+z*z+y*y)/LIGHT_RADIUS;
                
                //if(xx+x<0||xx+x>=T_SIZE||zz+<0||z>=T_SIZE)return;
                int lidx=((xx+x+g_offcx)%T_SIZE)*T_SIZE*T_HEIGHT+((zz+z+g_offcz)%T_SIZE)*T_HEIGHT+yy+y;
                if(inten!=0){
            //        printf("%f ",inten);
                }
                lightarray[lidx].x+=inten*brightness*color.x;
                lightarray[lidx].y+=inten*brightness*color.y;
                lightarray[lidx].z+=inten*brightness*color.z;
                if(lightarray[lidx].x<0)lightarray[lidx].x=0;
                if(lightarray[lidx].y<0)lightarray[lidx].y=0;
                if(lightarray[lidx].z<0)lightarray[lidx].z=0;
               
            }
        }
    }
   // printf("\n");
}
extern Vector colorTable[256];
void calculateLighting(){
    printf("calculating lighting first load\n");
    for(int x=0;x<T_SIZE;x++){
        for(int z=0;z<T_SIZE;z++){
            for(int y=0;y<T_HEIGHT;y++){
                if(getLandc(x,z,y)==TYPE_LIGHTBOX){
                    addlight(x,z,y,1.0f,colorTable[getColorc(x,z,y)]);
                }
            }
        }
    }
}
/*if(getLandc(x,z,y)==TYPE_NONE)continue;
 float ret=y/T_HEIGHT/2+.7f;
 for(int i=1;i<20;i++){
 if(i+y>=T_HEIGHT){
 
 break;
 }
 if(getLandc(x,z,y+i)!=TYPE_NONE){
 
 ret-=.05f;
 
 
 }
 }
 
 
 if(ret<0)ret=0;
 if(ret>1)ret=1;
 lightarray[x*T_SIZE*T_HEIGHT+z*T_HEIGHT+y]=ret;*/

@end
