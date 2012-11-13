//
//  TerrainGen2.m
//  Eden
//
//  Created by Ari Ronen on 10/25/12.
//
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "Terrain.h"
#import "glu.h"
#import "Resources.h"
#import "Util.h"
#import "Globals.h"
#import "TerrainGen2.h"
#import "Constants.h"
#import "Globals.h"

#define LEVEL_SEED 400
block8 blockz[BLOCKZ_SIZE];
color8 colorz[BLOCKZ_SIZE];
extern Vector colorTable[256];
void makeHill(int x,int z,int y, int size,int type);
int BC(int i){
    if(i<0)return 0;
    if(i>T_SIZE-1)return T_SIZE-1;
    return i;
}
int colorCycle4(int idx,int c){
   
    idx/=5;
    int color=(idx/12)%(8);
  
    color=c;
    int hue=idx%8;
    if(hue>=4)hue=7-hue;
    hue+=2;
    
    if(hue==6)return 0;
    
    int r=(hue*9+color+1);
    r%=NUM_COLORS;
    if(r>=NUM_COLORS){
        printf("r:%d hue:%d color: %d\n",r,hue,color);
    }
    
    
    return r;
    
}
int colorCycle6(int idx,int c){
    // idx%=6*8;
    // int h=idx%12;
    // if(h>=6)h-=6;
    
    int color=(idx/12)%(8);
    //  if(type==1){
    //     color=8;
    //}
    color=c;
    int hue=idx%8;
    if(hue>=4)hue=7-hue;
    //hue-=2;
    
    if(hue==6)return 0;
    
    int r=(hue*9+color+1);
    r%=NUM_COLORS;
    if(r>=NUM_COLORS){
        printf("r:%d hue:%d color: %d\n",r,hue,color);
    }
    
    
    return r;
    
}
int colorCycle5(int idx,int c){
    // idx%=6*8;
    // int h=idx%12;
    // if(h>=6)h-=6;
    idx/=5;
    int color=(idx/12)%(8);
    //  if(type==1){
    //     color=8;
    //}
    color=c;
    int hue=idx%8;
    if(hue>=4)hue=7-hue;
   //hue-=2;
    
    if(hue==6)return 0;
    
    int r=(hue*9+color+1);
    r%=NUM_COLORS;
    if(r>=NUM_COLORS){
        printf("r:%d hue:%d color: %d\n",r,hue,color);
    }
    
    
    return r;
    
}

int colorCycle3(int idx,int c){
    // idx%=6*8;
    // int h=idx%12;
    // if(h>=6)h-=6;
    idx/=5;
    int color=(idx/12)%(8);
    //  if(type==1){
    //     color=8;
    //}
    color=c;
    int hue=idx%8;
    if(hue>=4)hue=7-hue;
    hue+=3;
    
    if(hue==6)return 0;
    
    int r=(hue*9+color+1);
    r%=NUM_COLORS;
    if(r>=NUM_COLORS){
        printf("r:%d hue:%d color: %d\n",r,hue,color);
    }
    
    
    return r;
    
}

int colorCycle2(int idx,int c){
    // idx%=6*8;
    // int h=idx%12;
    // if(h>=6)h-=6;
    idx/=5;
    int color=(idx/12)%(8);
  //  if(type==1){
   //     color=8;
    //}
    color=c;
    int hue=idx%8;
    if(hue>=4)hue=7-hue;
    
    hue+=1;
    int r=(hue*9+color+1);
    r%=NUM_COLORS;
    if(r>=NUM_COLORS){
        printf("r:%d hue:%d color: %d\n",r,hue,color);
    }
    
    
    return r;
    
}
int colorCycle(int idx,int type){
    // idx%=6*8;
    // int h=idx%12;
    // if(h>=6)h-=6;
    
    int color=(idx/12)%(8);
    if(type==1){
        color=8;
    }
    int hue=idx%8;
    if(hue>=4)hue=7-hue;
    
    hue+=1;
    int r=(hue*9+color+1);
    r%=NUM_COLORS;
    if(r>=NUM_COLORS){
        printf("r:%d hue:%d color: %d\n",r,hue,color);
    }
    
    
    return r;
    
}
void makeTree(int x,int z,int y){
	
	int tree_height=arc4random()%3+6;
	if(y+tree_height>=T_HEIGHT) return;
	/*for(int i=x-1;i<=x+1;i++){
     for(int j=z-1;j<=z+1;j++){
     int type=BLOCK(i ,j ,y-1);
     if(!(type==TYPE_GRASS||type==TYPE_GRASS2||type==TYPE_DIRT))
     return;
     if(BLOCK(i ,j ,y)!=TYPE_NONE)return;
     }
     }*//*
         for(int i=x-1;i<=x+1;i++){
         for(int j=z-1;j<=z+1;j++){
         for(int k=y;k<y+tree_height;k++){
         int type=BLOCK(i ,j ,k);
         if(type==TYPE_NONE||type==TYPE_LEAVES)
         continue;
         break;
         
         
         }
         }
         
         }*/
	
	//NSLog(@"placing tree %d %d %d",x,z,y+i);
	for(int i=0;i<3*tree_height/4;i++){
		BLOCK(x ,z ,y+i )=TYPE_TREE;
        COLOR(x ,z ,y+i )=0;
	}
	int color=arc4random()%4;
	int ct[4]={0,19,20,21};
    int type=TYPE_LEAVES;
	
	for(int i=x-2;i<=x+2;i++){
		for(int j=z-2;j<=z+2;j++){
			for(int k=y+2*tree_height/3;k<tree_height+y;k++){
				if(BLOCK(i ,j ,k)!=TYPE_TREE){
					if(i==x-2||i==x+2||j==z-2||j==z+2){
                        if((i==x-2||i==x+2)&&(j==z-2||j==z+2)&&(k==y+2*tree_height/3||k==y+tree_height-1)){
                        }else
                            if(arc4random()%2==0){
                                BLOCK(i ,j ,k )=type;
                                COLOR(i ,j ,k )=ct[color];
                            }
					}
					else {
						BLOCK(i ,j ,k)=type;
                        COLOR(i ,j ,k)=ct[color];
					}
					
				}
			}
		}
	}
	
}
void makeTree2(int x,int z,int y,int hheight){
	
	int tree_height=arc4random()%4+hheight;
	if(y+tree_height>=T_HEIGHT) return;
	
	for(int i=0;i<3*tree_height/4;i++){
		BLOCK(x ,z ,y+i )=TYPE_TREE;
        COLOR(x ,z ,y+i )=0;
	}
	int color=arc4random()%4;
	int ct[4]={0,31,40,40};
    int type=TYPE_LEAVES;
	
	for(int i=x-2;i<=x+2;i++){
		for(int j=z-2;j<=z+2;j++){
			for(int k=y+2*tree_height/3;k<tree_height+y;k++){
				if(BLOCK(i ,j ,k)!=TYPE_TREE){
					if(i==x-2||i==x+2||j==z-2||j==z+2){
                        if((i==x-2||i==x+2)&&(j==z-2||j==z+2)&&(k==y+2*tree_height/3||k==y+tree_height-1)){
                        }else
                            if(arc4random()%2==0){
                                BLOCK(i ,j ,k )=type;
                                COLOR(i ,j ,k )=ct[color];
                            }
					}
					else {
						BLOCK(i ,j ,k)=type;
                        COLOR(i ,j ,k)=ct[color];
					}
					
				}
			}
		}
	}
	
}

void makePalmTree(int x,int z,int y,int hheight){
	int dx[4]={-1,1,0,0};
    int dz[4]={0,0,-1,1};
    
    
	int tree_height=randi(4)+hheight;
	if(y+tree_height>=T_HEIGHT) return;
	
    int ctt[4]={2,0,29,38};
    int colort=ctt[randi(4)];
	for(int i=0;i<tree_height;i++){
		BLOCK(x ,z ,y+i )=TYPE_WOOD;
        COLOR(x ,z ,y+i )=colort;
	}
	
	int ct[4]={0,31,22,40};
    int color=ct[randi(4)];
    int type=TYPE_LEAVES;
	
    int ypattern[5]={0,1,1,1,1};
    int tx=x;
    int tz=z;
    int ty=y+tree_height;
    
    for(int i=0;i<4;i++){
        for(int d=0;d<4;d++){
            BLOCK(tx+dx[d]*i,tz+dz[d]*i,ty+ypattern[i])=type;
          //  printf("making leaf:(%d,%d,%d)\n",tx+dx[d]*i,tz+dz[d]*i,ty+ypattern[i]);
            COLOR(tx+dx[d]*i,tz+dz[d]*i,ty+ypattern[i])=color;
            
            if(i==1){
                BLOCK(tx+dx[d]*i,tz+dz[d]*i,ty+ypattern[i]-1)=type;
                //  printf("making leaf:(%d,%d,%d)\n",tx+dx[d]*i,tz+dz[d]*i,ty+ypattern[i]);
                COLOR(tx+dx[d]*i,tz+dz[d]*i,ty+ypattern[i]-1)=color;
            }
            /*if(i==4){
                BLOCK(tx+dx[d]*i,tz+dz[d]*i,ty+ypattern[i]+1)=type;
                //  printf("making leaf:(%d,%d,%d)\n",tx+dx[d]*i,tz+dz[d]*i,ty+ypattern[i]);
                COLOR(tx+dx[d]*i,tz+dz[d]*i,ty+ypattern[i]+1)=color;
            }*/
        }
    }
    
	
}
Vector makeWorm(int x,int z,int yy,int size){
    int h=-1;
    for(int i=2;i<T_HEIGHT;i++){
        BOOL valid_spot=FALSE;
      
              if(BLOCK(x,z,i)==TYPE_NONE){
                    
                    valid_spot=TRUE;
                 //   break;
                }
        
        
        if(valid_spot){
            h=i-2;
            break;
        }
    }
   // h=15;
    
    if(h==-1)   {  printf("no valid spot %d, %d,%d\n",h,x,z);
    return MakeVector(-1,-1,-1);
    }
  
       
    int i=h;
  /*  for(i=10;i<T_HEIGHT;i++){
        if(BLOCK(x,z,i)==TYPE_NONE)
            break;
    }*/
    
    Vector pos=MakeVector(x,i,z);
    Vector vel=MakeVector((randf(1.2f)-.6f)*10,10.0f,(randf(1.2f)-.6f)*10);
    
    float fy=randf(.30f)+.20f;
   // float spy=pos.y;
    Vector accel=MakeVector(0,-fy*10,0);
    float fetime=(1/100.0f);
    for(int c=0;c<8000;c++){
        
       // if(i+h<T_HEIGHT){
        pos.y+=vel.y*fetime;
       // if(pos.y<spy-30)break;
        
        
        pos.x+=vel.x*fetime;
        pos.z+=vel.z*fetime;
        
        if(pos.y<=1)break;
       // if(pos.y<spy+10)break;
        //if( BLOCK(pos.x,pos.z,pos.y)==TYPE_STONE && BLOCK(pos.x,pos.z,pos.y+1)==TYPE_STONE )
            
        //{break;}
        vel.x+=accel.x*fetime;
        vel.y+=accel.y*fetime;
        vel.z+=accel.z*fetime;
            for(int a=-size;a<=size;a++){
                for(int b=-size;b<=size;b++){
                    if(a*a+b*b>size*size)continue;
                    int yc=MIN(pos.y,T_HEIGHT-1);
                    yc=MAX(pos.y,0);
                    yc-=1;
                    int xc=MAX((int)(pos.x+a),0);
                    xc=MIN(xc,T_SIZE-1);
                    int zc=MAX((int)(pos.z+b),0);
                    zc=MIN(zc,T_SIZE-1);
                    BLOCK(xc,zc,yc)=TYPE_STONE;
                    COLOR(xc,zc,yc)=45;//colorCycle2(abs(size*4),8);
                }
            }
       // }else
       //     break;
    }
    return pos;
}


void makeCave(int xs,int zs,int ys,int sizex,int sizez,int sizey,int colorScheme){
    
    for(int x=xs;x<sizex;x++){
        for(int z=zs;z<sizez;z++){
            for(int y=ys;y<sizey;y++){
                float n3=0;
                float FREQ3=4.0f;
                float AMPLITUDE3=0.25f;
                for(int i=0;i<3;i++){
                    float vec[3]={(float)FREQ3*(x+LEVEL_SEED)/NOISE_CONSTANT
                        ,(float)FREQ3*(z+LEVEL_SEED)/NOISE_CONSTANT,
                        (float)FREQ3*(y+LEVEL_SEED)/NOISE_CONSTANT};
                    n3+=noise3(vec)*(AMPLITUDE3);
                    FREQ3*=2;
                    AMPLITUDE3/=2;
                }
                
                if(n3>0){
                    BLOCK(x,z,y)=TYPE_STONE;
                    if(colorScheme==0){
                        COLOR(x,z,y)=0;
                    }else if(colorScheme==1){
                        COLOR(x,z,y)=colorCycle(z+x,0);

                    }else if(colorScheme==2){
                        COLOR(x,z,y)=colorCycle(z+x,2);
                        
                    }
                    
                }else {
                    BLOCK(x,z,y)=TYPE_NONE;
                    // setLandt(x ,z ,y ,TYPE_NONE);
                }
                
            }
        }
    }
    
    
}
void makeHill(int x,int z,int y, int size,int type){
    
    
    for(int yy=0;yy<size;yy++){
        int radius=size-yy;
        
        if(radius<0)break;
        for(int xx=x-radius;xx<x+radius;xx++){
            for(int zz=z-radius;zz<z+radius;zz++){
                int xx2=BC(xx);
                int zz2=BC(zz);
                BLOCK(xx2,zz2,yy)=TYPE_GRASS;
            }
        }
    }
    
    
}
void makeDirt(){
    float var=3;  //how much variance in heightmap?
    //LEVEL_SEED=0;
	
	
	const int offsety=T_HEIGHT/2;
    for(int x=0;x<T_SIZE;x++){ //Heightmap
		for(int z=0;z<T_SIZE;z++){
            int h;
            
            float n=offsety;
            float FREQ=2.0f;
            //float FREQ3=4.0f;
            float AMPLITUDE=4.0f;
            for(int i=0;i<10;i++){
                float vec[2]={(float)FREQ*(x+LEVEL_SEED)/NOISE_CONSTANT
                    ,(float)FREQ*(z+LEVEL_SEED)/NOISE_CONSTANT};
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
            //FORMATION_HEIGHT=T_HEIGHT-1;
			
			for(int y=0;y<h;y++){
				if(y<FORMATION_HEIGHT){
					if(y>(h%2+1)&&y<FORMATION_HEIGHT-16){
                        //if(!genCaves){
                             BLOCK(x,z,y)=TYPE_STONE;
                        COLOR(x,z,y)=colorCycle2(h,6);
                         //   continue;
                        //}
						/*float n3=0;
						float FREQ3=4.0f;
						float AMPLITUDE3=0.25f;
						for(int i=0;i<3;i++){
							float vec[3]={(float)FREQ3*(x+LEVEL_SEED)/NOISE_CONSTANT
                                ,(float)FREQ3*(z+LEVEL_SEED)/NOISE_CONSTANT,
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
						}*/
						
                        
					}else{
						 BLOCK(x,z,y)=TYPE_STONE;
                        COLOR(x,z,y)=colorCycle2(h,8);
					}
				}else{
                    float n3=0;
                    
					
					float FREQ3=3.0f;
					float AMPLITUDE3=0.5f;
					for(int i=0;i<3;i++){
						float vec[3]={(float)FREQ3*(x+LEVEL_SEED)/NOISE_CONSTANT
                            ,(float)FREQ3*(z+LEVEL_SEED)/NOISE_CONSTANT,
                            (float)FREQ3*(y+LEVEL_SEED)/NOISE_CONSTANT};
						n3+=noise3(vec)*(AMPLITUDE3);
						FREQ3*=2;
						AMPLITUDE3/=2;
                        
                    }
					if(n3<0.07f){
						 BLOCK(x,z,y)=TYPE_DIRT;
					}
				}
                
                //	setLandt(x :z :y :TYPE_DIRT];
				
				
			}
			
			//if(self getLandc(<#int x#>, <#int z#>, <#int y#>)
			//setLandt(x :z :h-1 :TYPE_GRASS];		
            
		}
		
	}
    
    for(int x=0;x<T_SIZE;x++){
		for(int z=0;z<T_SIZE;z++){
            BLOCK(x ,z ,0)=TYPE_SAND;
			
			for(int y=0;y<T_HEIGHT;y++){
				if(BLOCK(x ,z ,y)==TYPE_NONE){
					if(BLOCK(x ,z ,y-1)==TYPE_DIRT){
                        if(arc4random()%2==0&&(x+x%10)%20<4&&(z+z%10)%20<4){
							BLOCK(x ,z ,y)=TYPE_FLOWER;
							BLOCK(x ,z ,y-1 )=TYPE_GRASS;
						}else if(arc4random()%2==0){
							BLOCK(x ,z ,y-1 )=TYPE_GRASS;
						}else{
							BLOCK(x ,z ,y-1 )=TYPE_GRASS2;
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
				if(BLOCK(x ,z ,y)==TYPE_GRASS||BLOCK(x ,z ,y)==TYPE_GRASS2){
					//[self placeTree:x :z :y+1];
				}
			}
		}
	}
	
}

void makeMars(){
    float var=3;  //how much variance in heightmap?
    //LEVEL_SEED=0;
	
	
	const int offsety=T_HEIGHT/8;
    for(int x=0;x<T_SIZE;x++){ //Heightmap
		for(int z=0;z<T_SIZE;z++){
            int h;
            
            float n=offsety;
            float FREQ=2.0f;
            //float FREQ3=4.0f;
            float AMPLITUDE=4.0f;
            for(int i=0;i<10;i++){
                float vec[2]={(float)FREQ*(x+LEVEL_SEED)/NOISE_CONSTANT
                    ,(float)FREQ*(z+LEVEL_SEED)/NOISE_CONSTANT};
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
            FORMATION_HEIGHT=T_HEIGHT-1;
			
			for(int y=0;y<h;y++){
				if(y<FORMATION_HEIGHT){
					if(y>(h%2+1)&&y<FORMATION_HEIGHT-16){
                        //if(!genCaves){
                        BLOCK(x,z,y)=TYPE_STONE;
                        COLOR(x,z,y)=colorCycle2(h,0);
                        continue;
                        //}
						/*float n3=0;
                         float FREQ3=4.0f;
                         float AMPLITUDE3=0.25f;
                         for(int i=0;i<3;i++){
                         float vec[3]={(float)FREQ3*(x+LEVEL_SEED)/NOISE_CONSTANT
                         ,(float)FREQ3*(z+LEVEL_SEED)/NOISE_CONSTANT,
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
                         }*/
						
                        
					}else{
                        BLOCK(x,z,y)=TYPE_STONE;
					}
				}else{
                    float n3=0;
                    
					
					float FREQ3=3.0f;
					float AMPLITUDE3=0.5f;
					for(int i=0;i<3;i++){
						float vec[3]={(float)FREQ3*(x+LEVEL_SEED)/NOISE_CONSTANT
                            ,(float)FREQ3*(z+LEVEL_SEED)/NOISE_CONSTANT,
                            (float)FREQ3*(y+LEVEL_SEED)/NOISE_CONSTANT};
						n3+=noise3(vec)*(AMPLITUDE3);
						FREQ3*=2;
						AMPLITUDE3/=2;
                        
                    }
					if(n3<0.07f){
                        BLOCK(x,z,y)=TYPE_DIRT;
					}
				}
                
                //	setLandt(x :z :y :TYPE_DIRT];
				
				
			}
			
			//if(self getLandc(<#int x#>, <#int z#>, <#int y#>)
			//setLandt(x :z :h-1 :TYPE_GRASS];
            
		}
		
	}
    
    for(int x=0;x<T_SIZE;x++){
		for(int z=0;z<T_SIZE;z++){
            BLOCK(x ,z ,0)=TYPE_SAND;
			
			for(int y=0;y<5;y++){
				if(BLOCK(x ,z ,y)==TYPE_NONE){
                    BLOCK(x,z,y)=TYPE_LAVA;
                    COLOR(x,z,y)=0;
									}else{
					
					
					
				}
				
			}
			
		}
	}
    
    for(int i=0;i<20;i++){
        int x=randi(T_SIZE-10)+5;
        int z=randi(T_SIZE-10)+5;
        // int color=randi(53);
        
        Vector pos;
        do{
            pos= makeWorm(x,z,15,randi(2)+3);
        }while(pos.x==-1);
        
    }
   /* for(int zz=0;zz<3;zz++){
    int x=randi(T_SIZE-10)+5;
    int z=randi(T_SIZE-10)+5;
    // int color=randi(53);
    
       Vector pos;
    do{
    pos= makeWorm(x,z,15,randi(4)+1);
    }while(pos.x==-1);

    for(int i=0;i<15;i++){
        printf("worm: %f,%f,%f",pos.x,pos.z,pos.y);
        if(pos.x<0)pos.x+=T_SIZE;
        if(pos.x>=T_SIZE)pos.x-=T_SIZE;
        if(pos.z<0)pos.z+=T_SIZE;
        if(pos.z>=T_SIZE)pos.z-=T_SIZE;
        pos=makeWorm(pos.x,pos.z,pos.y,randi(2)+3);
        
    }
    }*/
    
    
   /* for(int x=2;x<CHUNK_SIZE-2;x++){ //Trees
		for(int z=2;z<CHUNK_SIZE-2;z++){
			for(int y=1;y<T_HEIGHT-1;y++){
				if(BLOCK(x ,z ,y)==TYPE_GRASS||BLOCK(x ,z ,y)==TYPE_GRASS2){
					//[self placeTree:x :z :y+1];
				}
			}
		}
	}*/
    [World getWorld].terrain.final_skycolor=  colorTable[10];
    printf("sky %f,%f,%f\n",  [World getWorld].terrain.final_skycolor.x,  [World getWorld].terrain.final_skycolor.y,  [World getWorld].terrain.final_skycolor.z);
	
}
void makeBeach(){
    float var=3;  //how much variance in heightmap?
    
    [World getWorld].terrain.final_skycolor=colorTable[17];
    //LEVEL_SEED=0;
	
	int sealevel=33;
    int slideh;
	const int offsety=T_HEIGHT/2;
    for(int x=0;x<T_SIZE;x++){ //Heightmap
		for(int z=0;z<T_SIZE;z++){
            int h;
            
            float n=offsety;
            float FREQ=1.0f;
            //float FREQ3=4.0f;
            float AMPLITUDE=18.0f;
            for(int i=0;i<10;i++){
                float vec[2]={(float)FREQ*(x+LEVEL_SEED)/NOISE_CONSTANT
                    ,(float)FREQ*(z+LEVEL_SEED)/NOISE_CONSTANT};
                n+=noise2(vec)*(AMPLITUDE)*var;
                
                FREQ*=2;
                AMPLITUDE/=2;
            }
            if(n-offsety>0){
                n=(n-offsety)/9+offsety;
            }
            h=(int)roundf(n);
            if(h-1>=T_HEIGHT){
                NSLog(@"NONONO");
            }
            
			int FORMATION_HEIGHT=h-6;//how deep should the 3D noise apply
            //The deeper the 3D noise and the more variance in heightmap,
            //The more intense the terrain is
            //
            FORMATION_HEIGHT=T_HEIGHT-1;
            if(h<sealevel){
               // if(h<=31)
                //    h-=2;
            }
			for(int y=0;y<h;y++){
				
                
                if(h>=sealevel+2){
                    BLOCK(x,z,y)=TYPE_GRASS;
                    COLOR(x,z,y)=0;//colorCycle2(h,2);
                }else{
                BLOCK(x,z,y)=TYPE_SAND;
                    
                COLOR(x,z,y)=colorCycle6(h-1,1);
                }
                
                
                
				
			}
            slideh=h;
			
            
		}
        
        
		
	}
    
    for(int x=0;x<T_SIZE;x++){
		for(int z=0;z<T_SIZE;z++){
            //BLOCK(x ,z ,0)=TYPE_SAND;
			
			for(int y=4;y<sealevel;y++){
				if(BLOCK(x ,z ,y)==TYPE_NONE){
                   
                        
                        BOOL isSand=FALSE;
                        if(BLOCK(x,z,y)==TYPE_SAND){
                            
                            isSand=TRUE;
                        }
                        BLOCK(x,z,y)=TYPE_WATER;
                        COLOR(x,z,y)=23;
                        
                        if(isSand){
                            break;
                        }
                	
				}
				
			}
			
		}
	}
    for(int x=4;x<T_SIZE-4;x++){ //Trees
        for(int z=4;z<T_SIZE-4;z++){
            for(int y=sealevel;y<T_HEIGHT-10;y++){
                if((BLOCK(x ,z ,y)==TYPE_GRASS)&&BLOCK(x ,z ,y+1)==TYPE_NONE){
                    if(randi(90)==0){
                        // printf("making a tree\n");
                        makePalmTree(x,z,y,4);
                    }
                }
            }
        }
    }
    [World getWorld].terrain.final_skycolor=colorTable[9];
}



void makeDesert(){
    float var=3;  //how much variance in heightmap?
    
    [World getWorld].terrain.final_skycolor=colorTable[17];
    //LEVEL_SEED=0;
	
	
    int slideh;
	const int offsety=T_HEIGHT/2;
    for(int x=0;x<T_SIZE;x++){ //Heightmap
		for(int z=0;z<T_SIZE;z++){
            int h;
            
            float n=offsety;
            float FREQ=1.0f;
            //float FREQ3=4.0f;
            float AMPLITUDE=0.0f;
            for(int i=0;i<10;i++){
                float vec[2]={(float)FREQ*(x+LEVEL_SEED)/NOISE_CONSTANT
                    ,(float)FREQ*(z+LEVEL_SEED)/NOISE_CONSTANT};
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
            //
            FORMATION_HEIGHT=T_HEIGHT-1;
        
			for(int y=0;y<h;y++){
				
               
                    
                BLOCK(x,z,y)=TYPE_SAND;
                COLOR(x,z,y)=11;//colorCycle2(h,2);
                    
               
                
				
			}
            slideh=h;
			
            
		}
        
        
		
	}
    int sx=T_SIZE/2;
    int sz=T_SIZE/2;
    Vector sv=MakeVector(sx,slideh,sz);
    Vector dv=MakeVector(1,0,0);
    int sc=0;
    
    Vector vcd=MakeVector(0,0,0);
    for(int i=0;i<10000;i++){
        sc++;
        BOOL changeDirection=FALSE;
        if(sc>15&&arc4random()%6==0){
            sc=0;
            if(dv.x!=0){
                changeDirection=TRUE;
                if(arc4random()%2==0){
                    dv.z=-1;
                    
                }else{
                    dv.z=1;
                    
                }
                vcd.x=-dv.x;
                vcd.z=dv.z;
                dv.x=0;
            }else
            if(dv.z!=0){
                changeDirection=TRUE;
                if(arc4random()%2==0){
                    dv.x=-1;
                    
                }else{
                    dv.x=1;
                }
                vcd.z=-dv.z;
                vcd.x=dv.x;
                dv.z=0;
                
            }
        }
        if(changeDirection){
            int bt=0;
            if(vcd.x<0&&vcd.z<0){
                bt=0;
               
            }else if(vcd.x>0&&vcd.z<0){
                bt=1;
            }else if(vcd.x>0&&vcd.z>0){
                bt=2;
            }else if(vcd.x<0&&vcd.z>0){
                bt=3;
            }
            
            BLOCK(sv.x,sv.z,sv.y+1)=(TYPE_ICE_SIDE1+bt%4);
            BLOCK(sv.x+vcd.x,sv.z+vcd.z,sv.y)=TYPE_ICE;
            BLOCK(sv.x+vcd.x,sv.z+vcd.z,sv.y+1)=TYPE_NONE;
            
        }
        sv=v_add(sv,dv);
        
        if(sv.x>=T_SIZE-5){
            sv.x=T_SIZE-6;
            dv.x=0;
        }else if(sv.x<5){
            sv.x=5;
            dv.x=0;
        }
        if(sv.z>=T_SIZE-5){
            sv.z=T_SIZE-6;
            dv.z=0;
        }else if(sv.z<5){
            sv.z=5;
            dv.z=0;
        }
        if(BLOCK(sv.x,sv.z,sv.y+1)!=TYPE_NONE) BLOCK(sv.x,sv.z,sv.y+1)=TYPE_NONE;
         if(BLOCK(sv.x,sv.z,sv.y+2)!=TYPE_NONE) BLOCK(sv.x,sv.z,sv.y+2)=TYPE_NONE;
        
        
          BLOCK(sv.x,sv.z,sv.y)=TYPE_ICE;
        
       //    if(dv.x!=0){
            if(BLOCK(sv.x,sv.z+1,sv.y)!=TYPE_ICE)
               BLOCK(sv.x,sv.z+1,sv.y+1)=TYPE_ICE;
            if(BLOCK(sv.x,sv.z-1,sv.y)!=TYPE_ICE)
               BLOCK(sv.x,sv.z-1,sv.y+1)=TYPE_ICE;
       //   }
       // else if(dv.z!=0){
            if(BLOCK(sv.x+1,sv.z,sv.y)!=TYPE_ICE)
               BLOCK(sv.x+1,sv.z,sv.y+1)=TYPE_ICE;
            if(BLOCK(sv.x-1,sv.z,sv.y)!=TYPE_ICE)
               BLOCK(sv.x-1,sv.z,sv.y+1)=TYPE_ICE;
       //   }
        
    }
    
    [World getWorld].terrain.final_skycolor=colorTable[9];
}


void makePonies(){
    float var=3;  //how much variance in heightmap?
    
     [World getWorld].terrain.final_skycolor=colorTable[17];
    //LEVEL_SEED=0;
	
	
	const int offsety=T_HEIGHT/2;
    for(int x=0;x<T_SIZE;x++){ //Heightmap
		for(int z=0;z<T_SIZE;z++){
            int h;
            
            float n=offsety;
            float FREQ=2.0f;
            //float FREQ3=4.0f;
            float AMPLITUDE=4.0f;
            for(int i=0;i<10;i++){
                float vec[2]={(float)FREQ*(x+LEVEL_SEED)/NOISE_CONSTANT
                    ,(float)FREQ*(z+LEVEL_SEED)/NOISE_CONSTANT};
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
            //
            FORMATION_HEIGHT=T_HEIGHT-1;
			
			for(int y=0;y<h;y++){
				
                if(y>(h%2+1)&&y<FORMATION_HEIGHT-16){
                    
                    BLOCK(x,z,y)=TYPE_STONE;
                    COLOR(x,z,y)=colorCycle2(h,6);
                    
                    
                }else{
                    BLOCK(x,z,y)=TYPE_STONE;
                    COLOR(x,z,y)=colorCycle2(h,6);
                }
                
				
			}
			
            
		}
		
	}
    makeCave(0,0,2,T_SIZE,T_SIZE,T_HEIGHT/2,1);
        [World getWorld].terrain.final_skycolor=colorTable[17];
}
void makeGreenHills(){
    float var=3;  //how much variance in heightmap?
    //LEVEL_SEED=0;
	[World getWorld].terrain.final_skycolor=colorTable[15];
	
	const int offsety=T_HEIGHT/2;
    for(int x=0;x<T_SIZE;x++){ //Heightmap
		for(int z=0;z<T_SIZE;z++){
            int h;
            
            float n=offsety;
            float FREQ=1.0f;
            //float FREQ3=4.0f;
            float AMPLITUDE=8.0f;
            for(int i=0;i<10;i++){
                float vec[2]={(float)FREQ*(x+LEVEL_SEED)/NOISE_CONSTANT
                    ,(float)FREQ*(z+LEVEL_SEED)/NOISE_CONSTANT};
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
            //
            FORMATION_HEIGHT=T_HEIGHT-1;
			
			for(int y=0;y<h;y++){
				
					if(y>(h%2+1)&&y<FORMATION_HEIGHT-16){
                       
                        BLOCK(x,z,y)=TYPE_DIRT;
                        COLOR(x,z,y)=colorCycle3(y,1);
                        
                        
					}else{
                        BLOCK(x,z,y)=TYPE_DIRT;
                        COLOR(x,z,y)=colorCycle3(h,1);
					}
                            
				
			}
			
			            
		}
		
	}
    
    for(int x=0;x<T_SIZE;x++){
		for(int z=0;z<T_SIZE;z++){
           // BLOCK(x ,z ,0)=TYPE_SAND;
			
			for(int y=0;y<T_HEIGHT;y++){
				if(BLOCK(x ,z ,y)==TYPE_NONE){
					if(BLOCK(x ,z ,y-1)==TYPE_DIRT){
                        
							BLOCK(x ,z ,y-1 )=TYPE_GRASS;
                        COLOR(x ,z ,y-1 )=colorCycle3(y-1,3);
					}
				}else{
					
					
					
				}
				
			}
			
		}
	}
    int sea_level=7;
    for(int x=0;x<T_SIZE;x++){
		for(int z=0;z<T_SIZE;z++){
            //BLOCK(x ,z ,0)=TYPE_SAND;
			
			for(int y=6;y<23+sea_level;y++){
				if(BLOCK(x ,z ,y)==TYPE_NONE){
                    for(int iy=1;iy<6;iy++){
                    BLOCK(x,z,y-iy)=TYPE_WATER;
                    COLOR(x,z,y-iy)=0;
                    }
                }else{
					
					
					
				}
				
			}
			
		}
	}
    /*
    for(int x=2;x<CHUNK_SIZE-2;x++){ //Trees
		for(int z=2;z<CHUNK_SIZE-2;z++){
			for(int y=1;y<T_HEIGHT-1;y++){
				if(BLOCK(x ,z ,y)==TYPE_GRASS||BLOCK(x ,z ,y)==TYPE_GRASS2){
					//[self placeTree:x :z :y+1];
				}
			}
		}
	}*/
    
    
}
void makeRiverTrees(){
    float var=3;  //how much variance in heightmap?
    //LEVEL_SEED=0;
	[World getWorld].terrain.final_skycolor=colorTable[9];
	
	const int offsety=T_HEIGHT/2-10;
    for(int x=0;x<T_SIZE;x++){ //Heightmap
		for(int z=0;z<T_SIZE;z++){
            int h;
            
            float n=offsety;
            float FREQ=1.0f;
            //float FREQ3=4.0f;
            float AMPLITUDE=20.0f;
            for(int i=0;i<10;i++){
                float vec[2]={(float)FREQ*(x+LEVEL_SEED)/NOISE_CONSTANT
                    ,(float)FREQ*(z+LEVEL_SEED)/NOISE_CONSTANT};
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
            //
            FORMATION_HEIGHT=T_HEIGHT-1;
			
			for(int y=0;y<h;y++){
				
                if(y>(h%2+1)&&y<FORMATION_HEIGHT-16){
                    
                    BLOCK(x,z,y)=TYPE_DIRT;
                    COLOR(x,z,y)=colorCycle3(y+30,1);
                    
                    
                }else{
                    BLOCK(x,z,y)=TYPE_DIRT;
                    COLOR(x,z,y)=colorCycle3(h+30,1);
                }
                
				
			}
			
            
		}
		
	}
    
    for(int x=0;x<T_SIZE;x++){
		for(int z=0;z<T_SIZE;z++){
           // BLOCK(x ,z ,0)=TYPE_SAND;
			int dirtlevel=25;
			for(int y=0;y<T_HEIGHT-dirtlevel;y++){
				if(BLOCK(x ,z ,y)==TYPE_NONE){
					if(BLOCK(x ,z ,y-1)==TYPE_DIRT){
                        
                        BLOCK(x ,z ,y-1 )=TYPE_GRASS;
                        COLOR(x ,z ,y-1 )=colorCycle4(y-1+30,3);
					}
				}else{
					
					
					
				}
				
			}
			
		}
	}
    int sea_level=-8;
    for(int x=0;x<T_SIZE;x++){
		for(int z=0;z<T_SIZE;z++){
            //BLOCK(x ,z ,0)=TYPE_SAND;
			
			for(int y=6;y<23+sea_level;y++){
				if(BLOCK(x ,z ,y)==TYPE_NONE){
                    for(int iy=1;iy<6;iy++){
                        BLOCK(x,z,y-iy)=TYPE_WATER;
                        COLOR(x,z,y-iy)=0;
                    }
                }else{
					
					
					
				}
				
			}
			
		}
	}
    /*
     
     for(int i=0;i<20;i++){
     int x=randi(T_SIZE-10)+5;
     int z=randi(T_SIZE-10)+5;
     // int color=randi(53);
     
     Vector pos;
     do{
     pos= makeWorm(x,z,15,randi(2)+3);
     }while(pos.x==-1);
     
     }
     */
    
     for(int x=4;x<T_SIZE-4;x++){ //Trees
     for(int z=4;z<T_SIZE-4;z++){
     for(int y=4;y<T_HEIGHT-10;y++){
     if(BLOCK(x ,z ,y)==TYPE_DIRT&&BLOCK(x ,z ,y+1)==TYPE_NONE){
         if(randi(70)==0){
        // printf("making a tree\n");
         makeTree2(x,z,y,12);
         }
     }
     }
     }
     }
    
    
}

void makeMountains(){
    float var=3;  //how much variance in heightmap?
    //LEVEL_SEED=0;
	[World getWorld].terrain.final_skycolor=colorTable[6];
	
	const int offsety=T_HEIGHT/2-10;
    for(int x=0;x<T_SIZE;x++){ //Heightmap
		for(int z=0;z<T_SIZE;z++){
            int h;
            
            float n=offsety;
            float FREQ=1.0f;
            //float FREQ3=4.0f;
            float AMPLITUDE=20.0f;
            for(int i=0;i<10;i++){
                float vec[2]={(float)FREQ*(x+LEVEL_SEED)/NOISE_CONSTANT
                    ,(float)FREQ*(z+LEVEL_SEED)/NOISE_CONSTANT};
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
            //
            FORMATION_HEIGHT=T_HEIGHT-1;
			
			for(int y=0;y<h;y++){
				
               // if(y>(h%2+1)&&y<FORMATION_HEIGHT-16){
                    
                    BLOCK(x,z,y)=TYPE_STONE;
                COLOR(x,z,y)=colorCycle5(y+50,8);//colorCycle3(y+30,8);
                    //COLOR(x,z,y)=colorCycle3(y+30,1);
                    
                    
              
                
				
			}
			
            
		}
		
	}
    
    for(int x=0;x<T_SIZE;x++){
		for(int z=0;z<T_SIZE;z++){
         //   BLOCK(x ,z ,0)=TYPE_SAND;
			int snowlevel=34;
			for(int y=snowlevel;y<T_HEIGHT;y++){
                if(y==34||y==35)if(arc4random()%2==0)continue;
                
                if(y==36||y==37)if(arc4random()%2==0)continue;
                
                if(y==38||y==39)if(arc4random()%2==0&&arc4random()%2==0)continue;
                
				if(BLOCK(x ,z ,y)==TYPE_NONE){
					if(BLOCK(x ,z ,y-1)==TYPE_STONE){
                        
                        BLOCK(x ,z ,y-1 )=TYPE_CLOUD;
                        COLOR(x ,z ,y-1 )=9;
                        if(BLOCK(x,z,y-2)==TYPE_STONE){
                            BLOCK(x,z,y-2)=TYPE_CLOUD;
                            COLOR(x,z,y-2)=9;
                        }
					}
				}else{
					
					
					
				}
				
			}
			
		}
	}
  //  int sea_level=-14;
    for(int x=0;x<T_SIZE;x++){
		for(int z=0;z<T_SIZE;z++){
            //BLOCK(x ,z ,0)=TYPE_SAND;
			
			for(int y=3;y<6;y++){
				if(BLOCK(x ,z ,y)==TYPE_NONE){
                    for(int iy=1;iy<3;iy++){
                        BLOCK(x,z,y-iy)=TYPE_WATER;
                        COLOR(x,z,y-iy)=6;
                    }
                }else{
					
					
					
				}
				
			}
			
		}
	}
    /*
     
     for(int i=0;i<20;i++){
     int x=randi(T_SIZE-10)+5;
     int z=randi(T_SIZE-10)+5;
     // int color=randi(53);
     
     Vector pos;
     do{
     pos= makeWorm(x,z,15,randi(2)+3);
     }while(pos.x==-1);
     
     }
     */
    
    /*for(int x=4;x<T_SIZE-4;x++){ //Trees
        for(int z=4;z<T_SIZE-4;z++){
            for(int y=4;y<T_HEIGHT-10;y++){
                if(BLOCK(x ,z ,y)==TYPE_DIRT&&BLOCK(x ,z ,y+1)==TYPE_NONE){
                    if(randi(70)==0){
                        // printf("making a tree\n");
                        makeTree2(x,z,y,12);
                    }
                }
            }
        }
    }*/
    
    
}
/*
 if(y>(h%2+1)&&y<FORMATION_HEIGHT-16){
 
 BLOCK(x,z,y)=TYPE_STONE;
 COLOR(x,z,y)=colorCycle3(y+30,8);
 //COLOR(x,z,y)=colorCycle3(y+30,1);
 
 
 }else{
 BLOCK(x,z,y)=TYPE_STONE;
 COLOR(x,z,y)=colorCycle3(y+30,8);
 //  COLOR(x,z,y)=colorCycle3(h+30,1);
 */
int g_terrain_type=0;
void clear(){
    [World getWorld].terrain.final_skycolor=colorTable[9];
    
    memset(blockz,0,sizeof(block8)*(BLOCKZ_SIZE));
    memset(colorz,0,sizeof(color8)*(BLOCKZ_SIZE));
    for(int x=0;x<T_SIZE;x++){
        for(int z=0;z<T_SIZE;z++){
            for(int y=0;y<2;y++){
                BLOCK(x,z,y)=TYPE_BEDROCK;
            }
            // for(int y=2;y<T_HEIGHT;y++){
            //    BLOCK(x,z,y)=TYPE_NONE;
            //}
        }
    }
}
int tg2_init(){
    //clear();
    
    //
    
    
    
   
    
   
    /*  for(int x=0;x<T_SIZE;x++){
        for(int z=0;z<T_SIZE;z++){
            int h=x;
            if(h>=T_HEIGHT)h=T_HEIGHT-1;
            BLOCK( x,z, h)=TYPE_STONE;
        }
    }*/
       
    for(int i=0;i<100;i++){
    //    makeHill(randi(T_SIZE),randi(T_SIZE),3,randi(35),0);
    }
    return 0;
    
}
