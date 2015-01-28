//
//  Lighting.m
//  Eden
//
//  Created by Ari Ronen on 1/21/13.
//
//

#import "Lighting.h"
#import "Terrain.h"
extern Vector8* lightarray;
extern block8* blockarray;
@implementation Lighting

extern int g_offcx;
extern int g_offcz;
void addlight(int xx,int zz,int yy,float brightness,Vector color){
    if(LOW_MEM_DEVICE)return;

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
               
                lightarray[lidx].x=MAX(0,MIN(255,lightarray[lidx].x+255.0f*inten*brightness*color.x));
                lightarray[lidx].y=MAX(0,MIN(255,lightarray[lidx].y+255.0f*inten*brightness*color.y));
                lightarray[lidx].z=MAX(0,MIN(255,lightarray[lidx].z+255.0f*inten*brightness*color.z));
                

               
               
               
            }
        }
    }
   // printf("\n");
}
extern Vector colorTable[256];
void calculateLighting(){
    //printf("calculating lighting first load\n");
    if(LOW_MEM_DEVICE)return;
        memset(lightarray,0,sizeof(Vector8)*T_SIZE*T_SIZE*T_HEIGHT);
    extern TerrainChunk** chunkTablec;
    
    for(int cx=0;cx<CHUNKS_PER_SIDE;cx++){
        for(int cz=0;cz<CHUNKS_PER_SIDE;cz++){
                for(int cy=0;cy<CHUNKS_PER_COLUMN;cy++){
                    TerrainChunk* chunk=chunkTablec[threeToOne(cx,cy,cz)];
                   
                    if(chunk&&chunk.has_light)
                    for(int y=chunk.pbounds[1];y<CHUNK_SIZE+chunk.pbounds[1];y++){
                        for(int x=chunk.pbounds[0];x<CHUNK_SIZE+chunk.pbounds[0];x++){
                            for(int z=chunk.pbounds[2];z<CHUNK_SIZE+chunk.pbounds[2];z++){
                                
                                if(getLandc(x,z,y)==TYPE_LIGHTBOX){
                                    addlight(x,z,y,1.0f,colorTable[getColorc(x,z,y)]);
                                    [[World getWorld].terrain refreshChunksInRadius:x:z:y:LIGHT_RADIUS];
                                }
                            }
                        }
                    }
                }
        }
    }
    
    
    //printf("calculating lighting first load end\n");
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
