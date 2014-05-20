//
//  TerrainGenerator.m
//  prototype
//
//  Created by Ari Ronen on 10/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TerrainGenerator.h"
#import "Terrain.h"
#import "Util.h"
#import "TerrainGen2.h"

@implementation TerrainGenerator
@synthesize LEVEL_SEED,genCaves;
float noise3(float vec[3]);
float noise2(float vec[2]);
static void init(void);
static float noiseFast(float x, float y, float z);
static Terrain* ter;
extern block8* blockarray;
const int TREE_SPACING=50;
int boundx;
int boundz;
block8 tblocks[(CHUNKS_PER_COLUMN*CHUNK_SIZE*2)*(CHUNK_SIZE*2)*(CHUNK_SIZE*2)];
block8 tcolors[(CHUNKS_PER_COLUMN*CHUNK_SIZE*2)*(CHUNK_SIZE*2)*(CHUNK_SIZE*2)];
- (id)init:(Terrain*)parent{
    init();
	ter=parent;
	LEVEL_SEED=0;
    genCaves=FALSE;
    
	return self;
	
}
void tgenInit(){
    init();
}
static TerrainChunk* column[CHUNKS_PER_COLUMN];

inline static int getCustomct(int x,int z,int y){
     return  tcolors[x*CHUNKS_PER_COLUMN*CHUNK_SIZE*CHUNK_SIZE*2*2+z*CHUNKS_PER_COLUMN*CHUNK_SIZE*2+y];
    
}
inline static int getCustomt(int x,int z,int y){  
    return  tblocks[x*CHUNKS_PER_COLUMN*CHUNK_SIZE*CHUNK_SIZE*2*2+z*CHUNKS_PER_COLUMN*CHUNK_SIZE*2+y];
    
  
	
}
inline static void setCustomt(int x,int z,int y,int type,int color){  
    
    tblocks[x*CHUNKS_PER_COLUMN*CHUNK_SIZE*CHUNK_SIZE*2*2+z*CHUNKS_PER_COLUMN*CHUNK_SIZE*2+y]=type;
    tcolors[x*CHUNKS_PER_COLUMN*CHUNK_SIZE*CHUNK_SIZE*2*2+z*CHUNKS_PER_COLUMN*CHUNK_SIZE*2+y]=color;         
    
}

inline static int getLandt(int x,int z,int y){  
 
    if(x>=0&&y>=0&&z>=0&&x<CHUNK_SIZE&&z<CHUNK_SIZE&&y<T_HEIGHT)
    
        return column[(int)y/CHUNK_SIZE].pblocks[x*(CHUNK_SIZE*CHUNK_SIZE)+z*(CHUNK_SIZE)+(y-((int)y/CHUNK_SIZE)*CHUNK_SIZE)];
    return 0;
}


inline static void setLandt(int x,int z,int y,int type){  
  
    
    	column[(int)y/CHUNK_SIZE].pblocks[x*(CHUNK_SIZE*CHUNK_SIZE)+z*(CHUNK_SIZE)+(y-((int)y/CHUNK_SIZE)*CHUNK_SIZE)]=type;
	
}

inline static void setColort(int x,int z,int y,int color){  
	column[(int)y/CHUNK_SIZE].pcolors[x*(CHUNK_SIZE*CHUNK_SIZE)+z*(CHUNK_SIZE)+(y-((int)y/CHUNK_SIZE)*CHUNK_SIZE)]=color;
	
}
extern int g_offcx,g_offcz;
- (void)generateColumn:(int)cx:(int)cz:(BOOL)bgthread{
	int ocx=cx;
	int ocz=cz;
    boundx=ocx*CHUNK_SIZE;
    boundz=ocz*CHUNK_SIZE;
    memset(tblocks,0,sizeof(block8)*(CHUNKS_PER_COLUMN*CHUNK_SIZE*2)*(CHUNK_SIZE*2)*(CHUNK_SIZE*2));
    memset(tcolors,0,sizeof(block8)*(CHUNKS_PER_COLUMN*CHUNK_SIZE*2)*(CHUNK_SIZE*2)*(CHUNK_SIZE*2));
	for(int cy=0;cy<CHUNKS_PER_COLUMN ;cy++){
		int bounds[6];
		bounds[0]=ocx*CHUNK_SIZE;
		bounds[1]=cy*CHUNK_SIZE;
		bounds[2]=ocz*CHUNK_SIZE;
		bounds[3]=(ocx+1)*CHUNK_SIZE;
		bounds[4]=(cy+1)*CHUNK_SIZE;
		bounds[5]=(ocz+1)*CHUNK_SIZE;
        TerrainChunk* chunk;
        TerrainChunk* old=ter.chunkTable[threeToOne(ocx,cy,ocz)];  //crash count: 1
        if(old){chunk=old;
           [chunk resetForReuse];
            [chunk setBounds:bounds];
             
        }
        else
		chunk=[[TerrainChunk alloc] init:bounds:ocx:ocz:ter];
        
        chunk.needsGen=TRUE;
		column[cy]=chunk;
      /*  if(bgthread){
            if(cy==0){
               // printf("adding from bgthread to chunkmap\n");
            }
        [ter readdChunk:chunk:ocx:cy:ocz];	 
        }else*/
		//[ter addChunk:chunk:ocx:cy:ocz:TRUE];		
	}
    extern block8* blockz;
    extern color8* colorz;
   	if(LEVEL_SEED!=0){
        
        for(int x=0;x<CHUNK_SIZE;x++){
            for(int z=0;z<CHUNK_SIZE;z++){
                for(int y=0;y<T_HEIGHT;y++){
                    setLandt(x,z,y,BLOCK(((x+boundx+g_offcx)%T_SIZE),((g_offcz+z+boundz)%T_SIZE),y));
                    setColort(x,z,y,COLOR(((x+boundx+g_offcx)%T_SIZE),((g_offcz+z+boundz)%T_SIZE),y));
                }
              
                
            }
        }
        
        for(int x=0;x<CHUNK_SIZE;x++){
            for(int z=0;z<CHUNK_SIZE;z++){
                for(int y=0;y<T_HEIGHT;y++){
                    GBLOCK(x+boundx,z+boundz,y)=column[(int)y/CHUNK_SIZE].pblocks[x*(CHUNK_SIZE*CHUNK_SIZE)+z*(CHUNK_SIZE)+(y-((int)y/CHUNK_SIZE)*CHUNK_SIZE)];
                    
                    
                }
            }
        }
        
        for(int cy=0;cy<CHUNKS_PER_COLUMN ;cy++){
            
            
            [ter addChunk:column[cy]:ocx:cy:ocz:TRUE];
        }
        return;
        
    }else
    if(LEVEL_SEED==0){
       for(int x=0;x<CHUNK_SIZE;x++){
            for(int z=0;z<CHUNK_SIZE;z++){
                 setLandt(x ,z ,0,TYPE_BEDROCK);
                for(int y=1;y<T_HEIGHT/4;y++){
                    setLandt(x,z,y,TYPE_STONE);
                }
                for(int y=T_HEIGHT/4;y<T_HEIGHT/2;y++){
                    setLandt(x,z,y,TYPE_DIRT);
                }
              /*  int interval=4;
                if((x/interval)%2==0){
                    if((z/interval)%2==0){
                        setColort(x,z,T_HEIGHT/2,8);

                    }else
                        setColort(x,z,T_HEIGHT/2,44);

                }else{
                    if((z/interval)%2!=0){
                        setColort(x,z,T_HEIGHT/2,8);
                        
                    }else
                        setColort(x,z,T_HEIGHT/2,44);
                }*/
              //  setColort(x,z,T_HEIGHT/2,8);
                setLandt(x,z,T_HEIGHT/2,TYPE_GRASS);
                
            }
        }
      /*  for(int x=0;x<CHUNK_SIZE*2;x++){
         

            for(int z=0;z<CHUNK_SIZE*2;z++){
                int h=sin((x+ocx*CHUNK_SIZE*2)/40.0f)*T_HEIGHT/2+T_HEIGHT+2;
                //int h2=sin((x+1+ocx*CHUNK_SIZE)/40.0f)*T_HEIGHT/4+T_HEIGHT/2+1;
               // int h3=sin((x-1+ocx*CHUNK_SIZE)/40.0f)*T_HEIGHT/4+T_HEIGHT/2+1;
                
                int h2=T_HEIGHT+2-T_HEIGHT/2;
                if(z>=10)h2=h;
                setCustomt(x ,z ,0,TYPE_BEDROCK,0);
                for(int y=1;y<T_HEIGHT/2;y++){
                    setCustomt(x,z,y,TYPE_STONE,0);
                }
               
                for(int y=T_HEIGHT/2;y<h2;y++){
                    setCustomt(x,z,y,TYPE_DIRT,0);
                }
                
                setCustomt(x,z,h2,TYPE_GRASS,0);
                if(h==T_HEIGHT/2+T_HEIGHT+2-1)
                setCustomt(x,z,h,TYPE_GRASS,0);
                
               // if(x==0&&z==0){
               //     for(int y=0;y<CHUNKS_PER_COLUMN;y++)
               //        setLandt(x,z,y*CHUNK_SIZE,TYPE_STONE);
               // }
            }
        }
        
        //   if(!bgthread){
        int dx[]={0,0,0,0,1,1,1,1};
        int dy[]={0,0,1,1,0,0,1,1};
        int dz[]={0,1,0,1,0,1,0,1};
        int n=0;
        for(int x=0;x<CHUNK_SIZE*2;x+=2){
            for(int z=0;z<CHUNK_SIZE*2;z+=2){
                for(int y=0;y<CHUNK_SIZE*CHUNKS_PER_COLUMN*2;y+=2){
                    int sblock=getCustomt(x,z,y);
                    int scolor=getCustomct(x,z,y);
                    BOOL isSolid=TRUE;
                    for(int d=1;d<8;d++){
                        if(getCustomt(x+dx[d],z+dz[d],y+dy[d])!=sblock||
                           getCustomct(x+dx[d],z+dz[d],y+dy[d])!=scolor){
                            isSolid=FALSE;
                            break;
                        }
                        
                    }
                    if(isSolid){
                        setLandt(x/2,z/2,y/2,sblock);
                        setColort(x/2,z/2,y/2,scolor);
                    }else{
                       setLandt(x/2,z/2,y/2,TYPE_STONE);
                        n++;
                        if(FALSE&&n<100){
                          setLandt(x/2,z/2,y/2,TYPE_CUSTOM);
                        int yy=y- ((int)(y/(CHUNK_SIZE*2))) *CHUNK_SIZE*2;
                        TerrainChunk* chunk=column[(int)(y/2/CHUNK_SIZE)];
                        SmallBlock* sb=malloc(sizeof(SmallBlock));
                       // memset(sb,0,sizeof(SmallBlock));
                    
                        chunk.psblocks[(x/2)*CHUNK_SIZE*CHUNK_SIZE+(z/2)*CHUNK_SIZE+yy/2]=sb;
                       
                        for(int d=0;d<8;d++){
                            int xx2=1-((x+dx[d])%2);
                            int zz2=1-((z+dz[d])%2);
                            int yy2=1-((y+dy[d])%2);
                            
                             sb->blocks[xx2*2*2+zz2*2+yy2]=getCustomt(x+dx[d],z+dz[d],y+dy[d]);
                            
                            sb->colors[xx2*2*2+zz2*2+yy2]=getCustomct(x+dx[d],z+dz[d],y+dy[d]);
                            
                            
                        }
                        }
                         
                    }
                    
                    //   return [column[(int)(y/CHUNK_SIZE)] setCustom:x:z:y-((int)(y/2)/CHUNK_SIZE)*CHUNK_SIZE*2];
                }
            }
        }*/
              for(int x=0;x<CHUNK_SIZE;x++){
            for(int z=0;z<CHUNK_SIZE;z++){
                for(int y=0;y<T_HEIGHT;y++)
                    GBLOCK(x+boundx,z+boundz,y)=
                    
                    column[(int)y/CHUNK_SIZE].pblocks[x*(CHUNK_SIZE*CHUNK_SIZE)+z*(CHUNK_SIZE)+(y-((int)y/CHUNK_SIZE)*CHUNK_SIZE)];
                
            }			
        }
        
        for(int cy=0;cy<CHUNKS_PER_COLUMN ;cy++){
           
          
            /*  if(bgthread){
             if(cy==0){
             // printf("adding from bgthread to chunkmap\n");
             }
             [ter readdChunk:chunk:ocx:cy:ocz];	 
             }else*/
            [ter addChunk:column[cy]:ocx:cy:ocz:TRUE];		
        }
      //  }
        return;
    }
    float var=3;  //how much variance in heightmap?
    //LEVEL_SEED=0;
	
	
	const int offsety=T_HEIGHT/2;
		for(int x=0;x<CHUNK_SIZE;x++){ //Heightmap
		for(int z=0;z<CHUNK_SIZE;z++){
            int h;
            
            float n=offsety;
            float FREQ=2.0f;
            float AMPLITUDE=4.0f;			
            for(int i=0;i<10;i++){
                float vec[2]={(float)FREQ*(x+cx*CHUNK_SIZE+LEVEL_SEED)/NOISE_CONSTANT,
                    (float)FREQ*(z+cz*CHUNK_SIZE+LEVEL_SEED)/NOISE_CONSTANT};
                n+=noise2(vec)*(AMPLITUDE)*var;
                FREQ*=2;
                AMPLITUDE/=2;
            }		
            h=(int)roundf(n);
            if(h-1>=T_HEIGHT){
                NSLog(@"NONONO");
            }
            
			int FORMATION_HEIGHT=h-6;//how deep should the 3D noise apply
									//The deeper the 3D noise and the more variance in heightmap,
									//The more intense the terrain is
			
			for(int y=0;y<h;y++){	
				if(y<FORMATION_HEIGHT){
					if(y>(h%2+1)&&y<FORMATION_HEIGHT-16){
                        if(!genCaves){
                            setLandt(x ,z ,y ,TYPE_STONE);
                            continue;
                        }
						float n3=0;
						float FREQ3=4.0f;
						float AMPLITUDE3=0.25f;			
						for(int i=0;i<3;i++){
							float vec[3]={(float)FREQ3*(x+cx*CHUNK_SIZE+LEVEL_SEED)/NOISE_CONSTANT
								,(float)FREQ3*(z+cz*CHUNK_SIZE+LEVEL_SEED)/NOISE_CONSTANT,
								(float)FREQ3*(y+LEVEL_SEED)/NOISE_CONSTANT};
							n3+=noise3(vec)*(AMPLITUDE3);
							FREQ3*=2;
							AMPLITUDE3/=2;
						}	
						
						if(n3>0){		
							if(n3<=0.01f)
								setLandt(x ,z ,y ,TYPE_DARK_STONE);
							else
								setLandt(x ,z ,y ,TYPE_STONE);
							
						}else {
                            
							setLandt(x ,z ,y ,TYPE_NONE);
						}
						
											
					}else{
						setLandt(x ,z ,y ,TYPE_STONE);
					}
				}else{
                    float n3=0;
                   
					
					float FREQ3=3.0f;
					float AMPLITUDE3=0.5f;			
					for(int i=0;i<3;i++){
						float vec[3]={(float)FREQ3*(x+cx*CHUNK_SIZE+LEVEL_SEED)/NOISE_CONSTANT
							,(float)FREQ3*(z+cz*CHUNK_SIZE+LEVEL_SEED)/NOISE_CONSTANT,
							(float)FREQ3*(y+LEVEL_SEED)/NOISE_CONSTANT};
						n3+=noise3(vec)*(AMPLITUDE3);
						FREQ3*=2;
						AMPLITUDE3/=2;
					
                    }
					if(n3<0.07f){				
						setLandt(x ,z ,y ,TYPE_DIRT);				
					}
				}
					
			//	setLandt(x :z :y :TYPE_DIRT];	
				
				
			}
			
			//if(self getLandc(<#int x#>, <#int z#>, <#int y#>)
			//setLandt(x :z :h-1 :TYPE_GRASS];		
						
		}
		
	}
	
	
	/*
	for(int x=0;x<ter.width;x++){
		for(int z=0;z<ter.depth;z++){
			for(int y=0;y<ter.height;y++){
				float n=0;
				float FREQ=4.0f;
				float AMPLITUDE=0.5f;			
				for(int i=0;i<3;i++){
					float vec[3]={(float)FREQ*x/(ter.width),(float)FREQ*z/(ter.depth),(float)FREQ*y/(ter.height)};
					n+=noise3(vec)*(AMPLITUDE);
					FREQ*=2;
					AMPLITUDE/=2;
				}			
				if(n<0.0f){				
				e	[ter setLand:x :z :y :TYPE_DIRT];				
				}			
			}		
		}	
	}*/
	
	for(int x=0;x<CHUNK_SIZE;x++){
		for(int z=0;z<CHUNK_SIZE;z++){
						 setLandt(x ,z ,0,TYPE_BEDROCK);
			
			for(int y=0;y<T_HEIGHT;y++){
				if(getLandt(x ,z ,y)==TYPE_NONE){
					if(getLandt(x ,z ,y-1)==TYPE_DIRT){	
                        if(arc4random()%2==0&&(x+x%10)%20<4&&(z+z%10)%20<4){
							setLandt(x ,z ,y ,TYPE_FLOWER);	
							setLandt(x ,z ,y-1 ,TYPE_GRASS);	
						}else if(arc4random()%2==0){
							setLandt(x ,z ,y-1 ,TYPE_GRASS);	
						}else{							
							setLandt(x ,z ,y-1 ,TYPE_GRASS2);							
						}
                         //setColort(x ,z ,y-1 ,22+18);
                        //setLandt(x ,z ,y-1 ,TYPE_GRASS);	
					}
				}else{
					
					
					
				}
				
			}
			
		}
	}
    
    	for(int x=2;x<CHUNK_SIZE-2;x++){ //Trees
		for(int z=2;z<CHUNK_SIZE-2;z++){
			for(int y=1;y<T_HEIGHT-1;y++){
				if(getLandt(x ,z ,y)==TYPE_GRASS||getLandt(x ,z ,y)==TYPE_GRASS2){
					[self placeTree:x :z :y+1];
				}
			}
		}
	}
    int cloud=arc4random()%5;
   
    if(cloud==0){
        [self generateCloud];
    }
	for(int cy=CHUNKS_PER_COLUMN-1;cy>=0 ;cy--){
       
        //[column[cy] setShadow];
    }
   
       
        for(int x=0;x<CHUNK_SIZE;x++){
            for(int z=0;z<CHUNK_SIZE;z++){
                for(int y=0;y<T_HEIGHT;y++){
                 GBLOCK(x+boundx,z+boundz,y)=column[(int)y/CHUNK_SIZE].pblocks[x*(CHUNK_SIZE*CHUNK_SIZE)+z*(CHUNK_SIZE)+(y-((int)y/CHUNK_SIZE)*CHUNK_SIZE)];
                               
          
                }
            }
        }
  
    for(int cy=0;cy<CHUNKS_PER_COLUMN ;cy++){
        
        
              [ter addChunk:column[cy]:ocx:cy:ocz:TRUE];		
    }

	
}
- (void)generateCloud{
    int num=arc4random()%4+4;
    for(int rep=0;rep<num;rep++){
        int x=arc4random()%7;
        int y=arc4random()%7;
        int w=arc4random()%(CHUNK_SIZE-x);
        int h=arc4random()%(CHUNK_SIZE-y);
        if(w<4)w=4;
        if(h<4)h=4;
        int d=arc4random()%2+2;
        for(int i=0;i<w;i++)
            for(int j=0;j<h;j++){
                setLandt(i+x,j+y,T_HEIGHT-d,TYPE_CLOUD);
            }
    }

}
/*int xs=x/SPACING;
 int xsr=xs+1;
 int zs=z/SPACING;
 int zsr=zs+1;			
 
 float fx=(float)x/SPACING;
 float fz=(float)z/SPACING;
 float dx=xsr-fx;
 float dz=zsr-fz;
 float ww1=(dx+dz)/2;
 float ww2=((1-dx)+dz)/2;
 float ww3=(dx+(1-dz))/2;
 float ww4=((1-dx)+(1-dz))/2;
 
 float h=ww1*heights[xs][zs]+ww2*heights[xsr][zs]+
 ww3*heights[xs][zsr]+ww4*heights[xsr][zsr];
 h/=2;
 
 [ter setLand:x :z :0 :TYPE_BEDROCK];
 for(int k=1;k<n-1;k++){
 [ter setLand:x :z :k :TYPE_DIRT];
 
 }
 
 [ter setLand:x :z :n-1 :TYPE_GRASS];
 */
- (void)placeTree:(int)x :(int)z :(int)y{
	//
	if(arc4random()%TREE_SPACING!=0)return;
	int tree_height=arc4random()%3+6;
	if(y+tree_height>=T_HEIGHT) return;
	for(int i=x-1;i<=x+1;i++){
		for(int j=z-1;j<=z+1;j++){
			int type=getLandt(i ,j ,y-1);
			if(!(type==TYPE_GRASS||type==TYPE_GRASS2||type==TYPE_DIRT))
				return;		
            if(getLandt(i ,j ,y)!=TYPE_NONE)return;
		}
	}
	for(int i=x-1;i<=x+1;i++){
		for(int j=z-1;j<=z+1;j++){
			for(int k=y;k<y+tree_height;k++){
				int type=getLandt(i ,j ,k);
				if(type==TYPE_NONE||type==TYPE_LEAVES)
					continue;
				break;
							
				
			}
		}
		
	}
	
	//NSLog(@"placing tree %d %d %d",x,z,y+i);
	for(int i=0;i<3*tree_height/4;i++){
		setLandt(x ,z ,y+i ,TYPE_TREE);
	}
	int color=arc4random()%4;
	int ct[4]={0,19,20,21};
    int type=TYPE_LEAVES;
	
	for(int i=x-2;i<=x+2;i++){
		for(int j=z-2;j<=z+2;j++){
			for(int k=y+2*tree_height/3;k<tree_height+y;k++){
				if(getLandt(i ,j ,k)!=TYPE_TREE){
					if(i==x-2||i==x+2||j==z-2||j==z+2){
                        if((i==x-2||i==x+2)&&(j==z-2||j==z+2)&&(k==y+2*tree_height/3||k==y+tree_height-1)){
                        }else
						if(arc4random()%2==0){
							setLandt(i ,j ,k ,type);
                            setColort(i ,j ,k ,ct[color]);
                        }
					}
					else {
						setLandt(i ,j ,k ,type);
                        setColort(i ,j ,k ,ct[color]);
					}
					
				}
			}
		}
	}
	
}






#define lerp(q, w, y) ( w + q * (y - w) )


static inline float grad(int hash, float x, float y, float z) {
    int h = hash & 15;                      // CONVERT LO 4 BITS OF HASH CODE
    float u = h<8 ? x : y,                 // INTO 12 GRADIENT DIRECTIONS.
    v = h<4 ? y : h==12||h==14 ? x : z;
    return ((h&1) == 0 ? u : -u) + ((h&2) == 0 ? v : -v);
}
#define fade(t) (t * t * t * (t * (t * 6 - 15) + 10))


static int pp[512];


static const int permutation[] = { 151,160,137,91,90,15,
    131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
    190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
    88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
    77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
    102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
    135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
    5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
    223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
    129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
    251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
    49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
    138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
};


static inline float noiseFast(float x, float y, float z) {
    
        int X = (int)floorf(x) & 255,                  // FIND UNIT CUBE THAT
        Y = (int)floorf(y) & 255,                  // CONTAINS POINT.
        Z = (int)floorf(z) & 255;
        x -= floorf(x);                                // FIND RELATIVE X,Y,Z
        y -= floorf(y);                                // OF POINT IN CUBE.
        z -= floorf(z);
        float u = fade(x),                                // COMPUTE FADE CURVES
        v = fade(y),                                // FOR EACH OF X,Y,Z.
        w = fade(z);
    int A = pp[X  ]+Y;
    int AA = pp[A]+Z;
    int AB = pp[A+1]+Z;      // HASH COORDINATES OF
    int BVAR = pp[X+1]+Y;
    int BA = pp[BVAR]+Z;
    int BB = pp[BVAR+1]+Z;      // THE 8 CUBE CORNERS,
        
        return lerp(w, lerp(v, lerp(u, grad(pp[AA  ], x  , y  , z   ),  // AND ADD
                                    grad(pp[BA  ], x-1, y  , z   )), // BLENDED
                            lerp(u, grad(pp[AB  ], x  , y-1, z   ),  // RESULTS
                                 grad(pp[BB  ], x-1, y-1, z   ))),// FROM  8
                    lerp(v, lerp(u, grad(pp[AA+1], x  , y  , z-1 ),  // CORNERS
                                 grad(pp[BA+1], x-1, y  , z-1 )), // OF CUBE
                         lerp(u, grad(pp[AB+1], x  , y-1, z-1 ),
                              grad(pp[BB+1], x-1, y-1, z-1 ))));
    
}


#define B 0x100
#define BM 0xff

#define N 0x1000
#define NP 12   /* 2^N */
#define NM 0xfff

static int p[B + B + 2];
static float g3[B + B + 2][3];
static float g2[B + B + 2][2];
static float g1[B + B + 2];
static int start = 0;

#define s_curve(t) ( t * t * (3. - 2. * t) )
#define setup(i,b0,b1,r0,r1)\
t = vec[i] + N;\
b0 = ((int)t) & BM;\
b1 = (b0+1) & BM;\
r0 = t - (int)t;\
r1 = r0 - 1.;

double noise1(double arg)
{
	int bx0, bx1;
	float rx0, rx1, sx, t, u, v, vec[1];
	
	vec[0] = arg;
	if (start) {
		start = 0;
		init();
	}
	
	setup(0, bx0,bx1, rx0,rx1);
	
	sx = s_curve(rx0);
	
	u = rx0 * g1[ p[ bx0 ] ];
	v = rx1 * g1[ p[ bx1 ] ];
	
	return lerp(sx, u, v);
}

float noise2(float vec[2])
{
	int bx0, bx1, by0, by1, b00, b10, b01, b11;
	float rx0, rx1, ry0, ry1, *q, sx, sy, a, b, t, u, v;
	register int i, j;
	
	if (start) {
		start = 0;
		init();
	}
	
	setup(0, bx0,bx1, rx0,rx1);
	setup(1, by0,by1, ry0,ry1);
	
	i = p[ bx0 ];
	j = p[ bx1 ];
	
	b00 = p[ i + by0 ];
	b10 = p[ j + by0 ];
	b01 = p[ i + by1 ];
	b11 = p[ j + by1 ];
	
	sx = s_curve(rx0);
	sy = s_curve(ry0);
	
#define at2(rx,ry) ( rx * q[0] + ry * q[1] )
	
	q = g2[ b00 ] ; u = at2(rx0,ry0);
	q = g2[ b10 ] ; v = at2(rx1,ry0);
	a = lerp(sx, u, v);
	
	q = g2[ b01 ] ; u = at2(rx0,ry1);
	q = g2[ b11 ] ; v = at2(rx1,ry1);
	b = lerp(sx, u, v);
	
	return lerp(sy, a, b);
}

float noise3(float vec[3])
{
	int bx0, bx1, by0, by1, bz0, bz1, b00, b10, b01, b11;
	float rx0, rx1, ry0, ry1, rz0, rz1, *q, sy, sz, a, b, c, d, t, u, v;
	register int i, j;
	
	if (start) {
		start = 0;
		init();
	}
	
	setup(0, bx0,bx1, rx0,rx1);
	setup(1, by0,by1, ry0,ry1);
	setup(2, bz0,bz1, rz0,rz1);
	
	i = p[ bx0 ];
	j = p[ bx1 ];
	
	b00 = p[ i + by0 ];
	b10 = p[ j + by0 ];
	b01 = p[ i + by1 ];
	b11 = p[ j + by1 ];
	
	t  = s_curve(rx0);
	sy = s_curve(ry0);
	sz = s_curve(rz0);
	
#define at3(rx,ry,rz) ( rx * q[0] + ry * q[1] + rz * q[2] )
	
	q = g3[ b00 + bz0 ] ; u = at3(rx0,ry0,rz0);
	q = g3[ b10 + bz0 ] ; v = at3(rx1,ry0,rz0);
	a = lerp(t, u, v);
	
	q = g3[ b01 + bz0 ] ; u = at3(rx0,ry1,rz0);
	q = g3[ b11 + bz0 ] ; v = at3(rx1,ry1,rz0);
	b = lerp(t, u, v);
	
	c = lerp(sy, a, b);
	
	q = g3[ b00 + bz1 ] ; u = at3(rx0,ry0,rz1);
	q = g3[ b10 + bz1 ] ; v = at3(rx1,ry0,rz1);
	a = lerp(t, u, v);
	
	q = g3[ b01 + bz1 ] ; u = at3(rx0,ry1,rz1);
	q = g3[ b11 + bz1 ] ; v = at3(rx1,ry1,rz1);
	b = lerp(t, u, v);
	
	d = lerp(sy, a, b);
	
	return lerp(sz, c, d);
}

static void normalize2(float v[2])
{
	float s;
	
	s = sqrt(v[0] * v[0] + v[1] * v[1]);
	v[0] = v[0] / s;
	v[1] = v[1] / s;
}

static void normalize3(float v[3])
{
	float s;
	
	s = sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
	v[0] = v[0] / s;
	v[1] = v[1] / s;
	v[2] = v[2] / s;
}

static void init(void)
{
    for (int i=0; i < 256 ; i++) pp[256+i] = pp[i] = permutation[i];
	int i, j, k;
	
	for (i = 0 ; i < B ; i++) {
		p[i] = i;
		
		g1[i] = (float)((random() % (B + B)) - B) / B;
		
		for (j = 0 ; j < 2 ; j++)
			g2[i][j] = (float)((random() % (B + B)) - B) / B;
		normalize2(g2[i]);
		
		for (j = 0 ; j < 3 ; j++)
			g3[i][j] = (float)((random() % (B + B)) - B) / B;
		normalize3(g3[i]);
	}
	
	while (--i) {
		k = p[i];
		p[i] = p[j = random() % B];
		p[j] = k;
	}
	
	for (i = 0 ; i < B + 2 ; i++) {
		p[B + i] = p[i];
		g1[B + i] = g1[i];
		for (j = 0 ; j < 2 ; j++)
			g2[B + i][j] = g2[i][j];
		for (j = 0 ; j < 3 ; j++)
			g3[B + i][j] = g3[i][j];
	}
}
@end
