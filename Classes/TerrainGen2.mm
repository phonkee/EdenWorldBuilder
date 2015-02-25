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

#define TG_SEED 400
#define TG_SEED2 123

block8* biomez;
block8* blockz;
color8* colorz;

block8* elevation;




extern Vector colorTable[256];
void makeHill(int x,int z,int y, int size,int type);
int BC(int i){
    if(i<0)return 0;
    if(i>GSIZE-1)return GSIZE-1;
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
        printg("r:%d hue:%d color: %d\n",r,hue,color);
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
        printg("r:%d hue:%d color: %d\n",r,hue,color);
    }
    
    
    return r;
    
}
int colorCycle7(int idx,int c){
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
    if(hue>=5)hue=8-hue;
    //hue-=2;
    
    if(hue==6)return 0;
    
    int r=(hue*9+color+1);
    r%=NUM_COLORS;
    if(r>=NUM_COLORS){
        printg("r:%d hue:%d color: %d\n",r,hue,color);
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
        printg("r:%d hue:%d color: %d\n",r,hue,color);
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
    
    if(hue==6)hue=5;
    
    int r=(hue*9+color+1);
    r%=NUM_COLORS;
    if(r>=NUM_COLORS){
        printg("r:%d hue:%d color: %d\n",r,hue,color);
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
        printg("r:%d hue:%d color: %d\n",r,hue,color);
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
        printg("r:%d hue:%d color: %d\n",r,hue,color);
    }
    
    
    return r;
    
}
void makeVolcano(int x,int z,int y,int start_radius){
    
    
    int h=1;
    for(int radius=start_radius;radius>0;radius--){
        h++;
        
        int waves=5;
        int radius2=radius+waves;
    for(int i=-radius2;i<=radius2;i++){
        for(int j=-radius2;j<=radius2;j++){
            float radius_here=radius2;
            float angle=atan2f(i,j);
            radius_here+=3*sinf(12*angle);
            int lava_radius=radius2;
            if(radius_here<0)radius_here=0;
          
            if(radius>2&&i*i+j*j<radius_here*radius_here){
                BLOCK(x+i,z+j,y+h)=TYPE_STONE;
                COLOR(x+i,z+j,y+h)=36;
            }else if(i*i+j*j<lava_radius*lava_radius){
                BLOCK(x+i,z+j,y+h)=TYPE_LAVA;
                COLOR(x+i,z+j,y+h)=0;

            }
            
        }
    }
    }
    
    for(int iy=0;iy<h/2;iy++){
        
        int radius=iy+1;
        for(int i=-radius;i<=radius;i++){
            for(int j=-radius;j<=radius;j++){
                if(i*i+j*j<radius*radius+randi(8)){
                    BLOCK(x+i,z+j,y+h-iy)=TYPE_LAVA;
                    COLOR(x+i,z+j,y+h-iy)=0;
                }
            }
        }
    }
    
   /* Vector pos=MakeVector(x,y+h+1,z);
    int look;
    for(int i=0;i<405;i++){
        BLOCK(pos.x,pos.z,pos.y)=TYPE_LAVA;
        COLOR(pos.x,pos.z,pos.y)=0;
        
        if(BLOCK(pos.x,pos.z,pos.y-1)==TYPE_STONE&&
         (BLOCK(pos.x,pos.z,pos.y)==TYPE_NONE||BLOCK(pos.x,pos.z,pos.y)==TYPE_LAVA)){
            pos.y--;
            continue;
        }
        
        Vector new_pos=pos;

        if(arc4random()%2==0){
            if(arc4random()%2==0){
                new_pos.x+=1;
            }else{
                new_pos.x-=1;
        
            }
        }else{
            if(arc4random()%2==0){
                new_pos.z+=1;
            }else{
                new_pos.z-=1;
                
            }
        }
        if(BLOCK(new_pos.x,new_pos.z,new_pos.y)==TYPE_NONE){
            pos=new_pos;
            look=0;
            continue;
        }
            
        
        
        look++;

    }*/


    
    
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
    
    int ct2[4]={0,31,40,40};
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
                                if(z>GSIZE/2){
                                    COLOR(i ,j ,k )=ct2[color];
                                }else
                                COLOR(i ,j ,k )=ct[color];
                            }
					}
					else {
						BLOCK(i ,j ,k)=type;
                        if(z>GSIZE/2){
                            COLOR(i ,j ,k )=ct2[color];
                        }else
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
          //  printg("making leaf:(%d,%d,%d)\n",tx+dx[d]*i,tz+dz[d]*i,ty+ypattern[i]);
            COLOR(tx+dx[d]*i,tz+dz[d]*i,ty+ypattern[i])=color;
            
            if(i==1){
                BLOCK(tx+dx[d]*i,tz+dz[d]*i,ty+ypattern[i]-1)=type;
                //  printg("making leaf:(%d,%d,%d)\n",tx+dx[d]*i,tz+dz[d]*i,ty+ypattern[i]);
                COLOR(tx+dx[d]*i,tz+dz[d]*i,ty+ypattern[i]-1)=color;
            }
            /*if(i==4){
                BLOCK(tx+dx[d]*i,tz+dz[d]*i,ty+ypattern[i]+1)=type;
                //  printg("making leaf:(%d,%d,%d)\n",tx+dx[d]*i,tz+dz[d]*i,ty+ypattern[i]);
                COLOR(tx+dx[d]*i,tz+dz[d]*i,ty+ypattern[i]+1)=color;
            }*/
        }
    }
    
	
}
Vector makeWorm(int x,int z,int yy,int size){
    int h=-1;
    for(int i=2;i<T_HEIGHT-1;i++){
        BOOL valid_spot=FALSE;
      
              if(BLOCK(x,z,i)==TYPE_NONE||blockinfo[BLOCK(x,z,i)]&IS_LIQUID||BLOCK(x,z,i+1)==TYPE_NONE){
                    
                    valid_spot=TRUE;
                 //   break;
                }
        
        
        if(valid_spot){
            h=i-2;
            break;
        }
    }
   // h=15;
    
    if(h==-1)   {  //printg("no valid spot %d, %d,%d\n",h,x,z);
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
                    xc=MIN(xc,GSIZE-1);
                    int zc=MAX((int)(pos.z+b),0);
                    zc=MIN(zc,GSIZE-1);
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
            if(TM(x,z)!=TM_UNICORN)continue;
            for(int y=ys;y<sizey;y++){
                float n3=0;
                float FREQ3=4.0f;
                float AMPLITUDE3=0.25f;
                for(int i=0;i<3;i++){
                    float vec[3]={(float)FREQ3*(x+TG_SEED)/NOISE_CONSTANT
                        ,(float)FREQ3*(z+TG_SEED)/NOISE_CONSTANT,
                        (float)FREQ3*(y+TG_SEED)/NOISE_CONSTANT};
                    n3+=noise3(vec)*(AMPLITUDE3);
                    FREQ3*=2;
                    AMPLITUDE3/=2;
                }
                
                if(n3>0){
                    BLOCK(x,z,y)=TYPE_STONE;
                    if(y==sizey-1&&colorScheme==1){
                        COLOR(x,z,y)=25;
                    }else
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
    //TG_SEED=0;
	
	
	const int offsety=T_HEIGHT/2;
    for(int x=0;x<GSIZE;x++){ //Heightmap
		for(int z=0;z<GSIZE;z++){
            if(TM(x,z)!=TM_GRASS)continue;
            int h;
            
            float n=offsety;
            float FREQ=2.0f;
            //float FREQ3=4.0f;
            float AMPLITUDE=4.0f;
            for(int i=0;i<10;i++){
                float vec[2]={(float)FREQ*(x+TG_SEED)/NOISE_CONSTANT
                    ,(float)FREQ*(z+TG_SEED)/NOISE_CONSTANT};
                n+=noise2(vec)*(AMPLITUDE)*var;
                FREQ*=2;
                AMPLITUDE/=2;
            }
            h=(int)roundf(n);
            if(h-1>=T_HEIGHT){
                NSLog(@"NONONO1");
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
							float vec[3]={(float)FREQ3*(x+TG_SEED)/NOISE_CONSTANT
                                ,(float)FREQ3*(z+TG_SEED)/NOISE_CONSTANT,
                                (float)FREQ3*(y+TG_SEED)/NOISE_CONSTANT};
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
						float vec[3]={(float)FREQ3*(x+TG_SEED)/NOISE_CONSTANT
                            ,(float)FREQ3*(z+TG_SEED)/NOISE_CONSTANT,
                            (float)FREQ3*(y+TG_SEED)/NOISE_CONSTANT};
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
    
    for(int x=0;x<GSIZE;x++){
		for(int z=0;z<GSIZE;z++){
            if(TM(x,z)!=TM_GRASS)continue;
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
            if(TM(x,z)!=TM_GRASS)continue;
			for(int y=1;y<T_HEIGHT-1;y++){
				if(BLOCK(x ,z ,y)==TYPE_GRASS||BLOCK(x ,z ,y)==TYPE_GRASS2){
					//[self placeTree:x :z :y+1];
				}
			}
		}
	}
	
}

void makeMars(int x1,int z1,int x2,int z2){
    float var=3;  //how much variance in heightmap?
    //TG_SEED=0;
	
	
	int offsety=T_HEIGHT/8;
    for(int x=x1;x<x2;x++){ //Heightmap
		for(int z=z1;z<z2;z++){
            if(TM(x,z)!=TM_MARS)continue;
            int h;
            offsety=T_HEIGHT/8;
            if(z>3*GSIZE/4){
                if(x<3*GSIZE/4+20){
                    //offsety=T_HEIGHT/8;
                    //offsety+=ABS(3*GSIZE/4-x);
                }else
                if(x<3*GSIZE/4+35){
                    //offsety+=ABS(3*GSIZE/4+10-x);
                    
                }
                
            }
            float n=offsety;
            float FREQ=2.0f;
            //float FREQ3=4.0f;
            float AMPLITUDE=4.0f;
            for(int i=0;i<10;i++){
                float vec[2]={(float)FREQ*(x+TG_SEED)/NOISE_CONSTANT
                    ,(float)FREQ*(z+TG_SEED)/NOISE_CONSTANT};
                n+=noise2(vec)*(AMPLITUDE)*var;
                FREQ*=2;
                AMPLITUDE/=2;
            }
            h=(int)roundf(n);
            if(h-1>=T_HEIGHT){
                NSLog(@"NONONO2");
            }
            if(z>3*GSIZE/4){
                if(x<3*GSIZE/4+35){
                    if(h>=22){
                        h=22;
                    }
                }
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
                        //COLOR(x,z,y)=colorCycle6(y,COLOR_BWG3-1);
                        COLOR(x,z,y)=colorCycle2(h,0);
                        continue;
                        
                        
					}else{
                        BLOCK(x,z,y)=TYPE_STONE;
					}
				}else{
                    float n3=0;
                    
					
					float FREQ3=3.0f;
					float AMPLITUDE3=0.5f;
					for(int i=0;i<3;i++){
						float vec[3]={(float)FREQ3*(x+TG_SEED)/NOISE_CONSTANT
                            ,(float)FREQ3*(z+TG_SEED)/NOISE_CONSTANT,
                            (float)FREQ3*(y+TG_SEED)/NOISE_CONSTANT};
						n3+=noise3(vec)*(AMPLITUDE3);
						FREQ3*=2;
						AMPLITUDE3/=2;
                        
                    }
					if(n3<0.07f){
                        BLOCK(x,z,y)=TYPE_DIRT;
					}
				}
                
               
				
				
			}
	
            
		}
		
	}
    
    for(int x=x1;x<x2;x++){
		for(int z=z1;z<z2;z++){
            if(TM(x,z)!=TM_MARS)continue;
            BLOCK(x ,z ,0)=TYPE_SAND;
			
			for(int y=0;y<5;y++){
				if(BLOCK(x ,z ,y)==TYPE_NONE){
                    if(BLOCK(x,z,y)!=TYPE_WATER){
                    BLOCK(x,z,y)=TYPE_LAVA;
                    COLOR(x,z,y)=0;
                    }
									}else{
					
					
					
				}
				
			}
			
		}
	}
    
   
    for(int i=0;i<80;i++){
        int x=randi(GSIZE/4-10)+5+3*GSIZE/4;
        int z=randi(GSIZE/4-10)+5+3*GSIZE/4;
        // int color=randi(53);
        
        Vector pos;
        do{
            pos= makeWorm(x,z,15,randi(2)+3);
        }while(pos.x==-1);
        
    }

  //  makeVolcano((x1+x2)/2,(z1+z2)/2,1,30);
 
    [World getWorld].terrain.final_skycolor=  colorTable[10];
   
   // printg("sky %f,%f,%f\n",  [World getWorld].terrain.final_skycolor.x,  [World getWorld].terrain.final_skycolor.y,  [World getWorld].terrain.final_skycolor.z);
	
}
int clampy(int h){
    if(h>T_HEIGHT-1)    return T_HEIGHT-1;
    if(h<1) return 1;
    return h;
}
void floodFill(int x,int z,int y);
int ff_capy;
int ff_type=TYPE_WATER;
int ff_color=15;
void makeMix(){
    makeGreenHills(T_HEIGHT/3);
    
    float var=3;  //how much variance in heightmap?
    //TG_SEED=0;
	[World getWorld].terrain.final_skycolor=colorTable[6];
	
	int offsety=T_HEIGHT/2-10;
   
   
		for(int z=0;z<GSIZE;z++){
             for(int x=0;x<GSIZE;x++){ //Heightmap
                 offsety=T_HEIGHT/2-10;
            //float value=((TEMP(x,z)+128.0f)/255.0f);
            int h;
                 if(x<(GSIZE/4+10)&&z>=GSIZE/4&&z<(GSIZE/2+10)){
                    offsety=T_HEIGHT/2-10;
                     
                     if(z>GSIZE/2+10)continue;
                     if(z>GSIZE/2-10){
                         offsety=(T_HEIGHT/2-10)-(20-((GSIZE/2+10)-z));
                     }
                     
                     if(x>GSIZE/4-10){
                         offsety=(T_HEIGHT/2-10)-(20-((GSIZE/4+10)-x));
                     }
                     
                     

                 }else{
                     if(z>GSIZE/4+10)continue;
                     if(z>GSIZE/4-10){
                         offsety=(T_HEIGHT/2-10)-(20-((GSIZE/4+10)-z));
                     }
                     if(x>3*GSIZE/4-10){
                          offsety=(T_HEIGHT/2-10)-ABS((3*GSIZE/4-10)-x);
                         if(offsety<T_HEIGHT/12)offsety=T_HEIGHT/12;
                     }
                 }
            float n=offsety;
            float FREQ=1.0f;
            //float FREQ3=4.0f;
            float AMPLITUDE=20.0f;
            for(int i=0;i<10;i++){
                float vec[2]={(float)FREQ*(x+TG_SEED)/NOISE_CONSTANT
                    ,(float)FREQ*(z+TG_SEED)/NOISE_CONSTANT};
                n+=noise2(vec)*(AMPLITUDE)*var;
                FREQ*=2;
                AMPLITUDE/=2;
            }
            h=(int)roundf(n);
            h=clampy(h);
                        
			int FORMATION_HEIGHT=h-6;
            //how deep should the 3D noise apply
            //The deeper the 3D noise and the more variance in heightmap,
            //The more intense the terrain is
            
            FORMATION_HEIGHT=T_HEIGHT-1;
			
			for(int y=0;y<h;y++){
				
                 if(y>(h%2+1)&&y<FORMATION_HEIGHT-16){
                ///if(value>0){
                    BLOCK(x,z,y)=TYPE_STONE;
               
                
                    COLOR(x,z,y)=colorCycle7(y+10,8);//colorCycle3(y+30,8);
                // }//COLOR(x,z,y)=colorCycle3(y+30,1);
                 }
            }
		}
    }
    
    
    //  int sea_level=-14;
 
   
    makeBeach();
   
    makeMars(GSIZE*3/4,0,GSIZE,GSIZE);
    for(int x=3*GSIZE/4;x<GSIZE;x++){
		for(int z=0;z<=3*GSIZE/4;z++){
            
            
            //BLOCK(x ,z ,0)=TYPE_SAND;
			
			for(int y=3;y<6;y++){
				if(BLOCK(x ,z ,y)==TYPE_NONE||BLOCK(x ,z ,y)==TYPE_LAVA){
                    for(int iy=1;iy<3;iy++){
                        if(z==3*GSIZE/4){
                            ff_capy=4;
                            ff_type=TYPE_WATER;
                            ff_color=0;
                            floodFill(x,z,4);
                        }else{
                            
                            BLOCK(x,z,y-iy)=TYPE_WATER;
                            COLOR(x,z,y-iy)=0;
                            
                        }
                    }
                    
                }else{
					
					
					
				}
				
			}
			
		}
	}
    ;
    makeBeach();
   /* for(int x=3*GSIZE/4;x<GSIZE;x++){
		int z=3*GSIZE/4;
            
            //BLOCK(x ,z ,0)=TYPE_SAND;
			
			for(int y=3;y<6;y++){
				if(BLOCK(x ,z ,y)==TYPE_LAVA){
                    for(int iy=1;iy<3;iy++){
                        if(z==3*GSIZE/4){
                            for(int zz=z;zz<z+550;zz++){
                                if(BLOCK(x,zz,y-iy)==TYPE_NONE||BLOCK(x,zz,y-iy)==TYPE_LAVA||BLOCK(x,zz,y-iy)==TYPE_WATER){
                                    BLOCK(x,zz,y-iy)=TYPE_WATER;
                                    COLOR(x,zz,y-iy)=0;
                                }else break;
                            }
                        }else{
                           
                        }
                    }
                }else{
					
					
					
				}
				
			}
			
		
	}*/
   
    makePonies();
    makeClassicGen();
    makeDesert();
    
    
    
    makeMountains(0,0,GSIZE/4,GSIZE/4,TG_SEED);
    for(int i=0;i<PYRAMID_FREQ;i++){//38 oj, 45 black
        int rh=arc4random()%30+15;
        int rx=arc4random()%(GSIZE/4-(rh+3)/2)+(rh+3);
        int rz=arc4random()%(GSIZE/2+GSIZE/4-(rh+3)/2)+(rh+3);
        int rc;
        if(rx<GSIZE/4&&rz<3*GSIZE/4&&rz>GSIZE/4){}else{ continue;}
        
        rc=45;
        makePyramid2(rx,rz,rh,rc,-1);
    }
  
    makePyramid2(GSIZE/4,3*GSIZE/4,25,22,17);
     makePyramid2(3*GSIZE/4+15,3*GSIZE/4,35,55,6);
    
     makePyramid2(GSIZE/4-15,GSIZE/4,35,55,16);
    
    
    int sx=0;
    int endx=GSIZE/4;
    int sz=GSIZE/2;
    int endz=3*GSIZE/4;
    void placeTree(int x,int z,int y);
    for(int x=sx+2;x<endx-2;x++){
		for(int z=sz+2;z<endz-2;z++){
			for(int y=1;y<T_HEIGHT-1;y++){
				if(BLOCK(x ,z ,y)==TYPE_GRASS||BLOCK(x ,z ,y)==TYPE_GRASS2){
                    
                    placeTree(x,z,y+1);
					//[self placeTree:x :z :y+1];
				}
			}
		}
	}
    
    
    
    for(int i=0;i<40;i++){
        int rs=arc4random()%20+5;
        int rx=arc4random()%(GSIZE/2-rs)+rs+GSIZE/4;
        int rz=arc4random()%(GSIZE/8-rs)+rs+3*GSIZE/4+GSIZE/8;
        
        makeSkyIsland(rx,rz,55-arc4random()%10,rs);
    }
    for(int i=0;i<WORM_FREQ;i++){
        int x=randi(GSIZE-10)+5;
        int z=randi(GSIZE-10)+5;
        // int color=randi(53);
        
        Vector pos;
        do{
            pos= makeWorm(x,z,15,randi(2)+3);
        }while(pos.x==-1);
        
    }
    for(int i=0;i<VOLCANO_FREQ;i++){
        int rh=arc4random()%10+25;
        int x=randi(GSIZE/4-rh*2-50)+3*GSIZE/4+50;
        int z=randi(3*GSIZE/4-rh*2)+rh*2+GSIZE/4;
        
         makeVolcano(x,z,1,rh);
    }
   
    for(int x=0;x<GSIZE;x++){
        for(int z=0;z<GSIZE;z++){
            BLOCK(x,z,0)=TYPE_BEDROCK;
            
           /* int d=MAX(ABS(x-GSIZE/2),ABS(z-GSIZE/2));
            
            if(d>GSIZE/2-10){
                
                for(int y=1;y<T_HEIGHT-3*ABS(GSIZE/2-d);y++){
                    if( BLOCK(x,z,y)==TYPE_NONE||(blockinfo[BLOCK(x,z,y)]&IS_LIQUID) ){
                        BLOCK(x,z,y)=TYPE_DARK_STONE;
                        COLOR(x,z,y)=0;
                    }
                }
            }*/
        }
    }
    for(int x=0;x<GSIZE/2;x++){
        for(int z=0;z<GSIZE;z++){
            for(int y=0;y<T_HEIGHT;y++){
                if(BLOCK(x,z,y)==TYPE_NONE)COLOR(x,z,y)=0;
              /*  int t=BLOCK(GSIZE-x-1,z,y);
                int c=COLOR(GSIZE-x-1,z,y);
                BLOCK(GSIZE-x-1,z,y)=BLOCK(x,z,y);
               // COLOR(GSIZE-x-1,z,y)=COLOR(x,z,y);
                BLOCK(x,z,y)=t;
               // COLOR(x,z,y)=c;*/
            }
        }
    }
    /*for(int x=3*GSIZE/4+GSIZE/8;x<GSIZE;x++){
        for(int z=3*GSIZE/4+GSIZE/8;z<GSIZE;z++){
            for(int y=1;y<T_HEIGHT;y++){
                BLOCK(x,z,y)=0;
            }
        }
    }*/
    
    for(int x=4;x<GSIZE-4;x++){ //Trees
        for(int z=4;z<GSIZE-4;z++){
            for(int y=4;y<T_HEIGHT-10;y++){
                if(BLOCK(x ,z ,y)==TYPE_GRASS&&BLOCK(x ,z ,y+1)==TYPE_NONE){
                    if(randi(300)==0){
                        // printg("making a tree\n");
                        makeTree2(x,z,y,12);
                    }
                }
            }
        }
    }
    
    //makeSkyIsland(GSIZE/2,3*GSIZE/4+GSIZE/8,50,35);
}
void makeBeach(){
    float var=3;  //how much variance in heightmap?
    
    [World getWorld].terrain.final_skycolor=colorTable[17];
    //TG_SEED=0;
	
	int sealevel=19;
    int slideh;
	 int offsety=T_HEIGHT/2-14;
    for(int x=GSIZE/4;x<3*GSIZE/4+65;x++){ //Heightmap
        if(x>=3*GSIZE/4-35){
            
            offsety++;
        }
        if(x>=3*GSIZE/4){
            offsety-=2;
        }
		for(int z=3*GSIZE/4;z<GSIZE;z++){
            if(TM(x,z)!=TM_BEACH)continue;
            int h;
            
            float n=offsety;
            float FREQ=1.0f;
            //float FREQ3=4.0f;
            float AMPLITUDE=18.0f;
            for(int i=0;i<10;i++){
                float vec[2]={(float)FREQ*(x+TG_SEED)/NOISE_CONSTANT
                    ,(float)FREQ*(z+TG_SEED)/NOISE_CONSTANT};
                n+=noise2(vec)*(AMPLITUDE)*var;
                
                FREQ*=2;
                AMPLITUDE/=2;
            }
            if(n-offsety>0){
                n=(n-offsety)/9+offsety;
            }
            h=(int)roundf(n);
            if(h-1>=T_HEIGHT){
                NSLog(@"NONONO3");
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
            if(h>sealevel+2){
                h=sealevel+2;
            }
            if(h<2)h=2;
			for(int y=0;y<h;y++){
				
                
                if(h>=sealevel+2&&x<3*GSIZE/4-35){
                    BLOCK(x,z,y)=TYPE_GRASS;
                    COLOR(x,z,y)=0;//colorCycle2(h,2);
                }else{
                BLOCK(x,z,y)=TYPE_SAND;
                    
                COLOR(x,z,y)=colorCycle6(h-1+14,1);
                }
                
                
                
				
			}
            slideh=h;
			
            
		}
        
        
		
	}
    int tsealevel=sealevel;
    for(int x=GSIZE/4;x<3*GSIZE/4;x++){
        
		for(int z=3*GSIZE/4;z<GSIZE;z++){
            if(TM(x,z)!=TM_BEACH)continue;
            //BLOCK(x ,z ,0)=TYPE_SAND;
			
            
			for(int y=1;y<tsealevel;y++){
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
#define AREALOOP(left,right,top,bot) for(int x(left);x<(right);x++)   for(int z=(top);z<(bot);z++)

        
   
    for(int x=GSIZE/4+4;x<3*GSIZE/4-4;x++){ //trees
		for(int z=3*GSIZE/4+4;z<GSIZE-4;z++){

            if(TM(x,z)!=TM_BEACH)continue;
            for(int y=sealevel;y<T_HEIGHT-10;y++){
                if((BLOCK(x ,z ,y)==TYPE_GRASS)&&BLOCK(x ,z ,y+1)==TYPE_NONE){
                    if(randi(90)==0){
                        // printg("making a tree\n");
                        makePalmTree(x,z,y,4);
                    }
                }
            }
        }
    }
    [World getWorld].terrain.final_skycolor=colorTable[9];
}

void makeClassicGen(){
    int sx=0;
    int endx=GSIZE/4;
    int sz=GSIZE/2;
    int endz=3*GSIZE/4;
    const int offsety=T_HEIGHT/2-10;
    float var=3;
    BOOL genCaves=FALSE;
    for(int x=sx;x<endx;x++){ //Heightmap
		for(int z=sz;z<endz;z++){
            int h;
            
            float n=offsety;
            float FREQ=2.0f;
            float AMPLITUDE=4.0f;
            for(int i=0;i<10;i++){
                float vec[2]={(float)FREQ*(x+TG_SEED)/NOISE_CONSTANT,
                    (float)FREQ*(z+TG_SEED)/NOISE_CONSTANT};
                n+=noise2(vec)*(AMPLITUDE)*var;
                FREQ*=2;
                AMPLITUDE/=2;
            }
            h=(int)roundf(n);
            if(h-1>=T_HEIGHT){
                NSLog(@"NONONO9");
            }
            
			int FORMATION_HEIGHT=h-6;//how deep should the 3D noise apply
            //The deeper the 3D noise and the more variance in heightmap,
            //The more intense the terrain is
			
			for(int y=0;y<h;y++){
				if(y<FORMATION_HEIGHT){
					if(y>(h%2+1)&&y<FORMATION_HEIGHT-16){
                        if(!genCaves){
                            BLOCK(x ,z ,y )=TYPE_STONE;
                            continue;
                        }
						float n3=0;
						float FREQ3=4.0f;
						float AMPLITUDE3=0.25f;
						for(int i=0;i<3;i++){
							float vec[3]={(float)FREQ3*(x+TG_SEED)/NOISE_CONSTANT
								,(float)FREQ3*(z+TG_SEED)/NOISE_CONSTANT,
								(float)FREQ3*(y+TG_SEED)/NOISE_CONSTANT};
							n3+=noise3(vec)*(AMPLITUDE3);
							FREQ3*=2;
							AMPLITUDE3/=2;
						}
						
						if(n3>0){
							if(n3<=0.01f)
                                BLOCK(x ,z ,y )=TYPE_DARK_STONE;
								
							else
								BLOCK(x ,z ,y )=TYPE_STONE;
							
						}else {
                            
							BLOCK(x ,z ,y)=TYPE_NONE;
						}
						
                        
					}else{
						BLOCK(x ,z ,y)=TYPE_STONE;
					}
				}else{
                    float n3=0;
                    
					
					float FREQ3=3.0f;
					float AMPLITUDE3=0.5f;
					for(int i=0;i<3;i++){
						float vec[3]={(float)FREQ3*(x+TG_SEED)/NOISE_CONSTANT
							,(float)FREQ3*(z+TG_SEED)/NOISE_CONSTANT,
							(float)FREQ3*(y+TG_SEED)/NOISE_CONSTANT};
						n3+=noise3(vec)*(AMPLITUDE3);
						FREQ3*=2;
						AMPLITUDE3/=2;
                        
                    }
					if(n3<0.07f){
						BLOCK(x ,z ,y)=TYPE_DIRT;;
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
	
	for(int x=sx;x<endx;x++){
		for(int z=sz;z<endz;z++){
            BLOCK(x ,z ,0)=TYPE_BEDROCK;
			
			for(int y=0;y<T_HEIGHT;y++){
				if(BLOCK(x ,z ,y)==TYPE_NONE){
					if(BLOCK(x ,z ,y-1)==TYPE_DIRT){
                        if(arc4random()%2==0&&(x+x%10)%20<4&&(z+z%10)%20<4){
							BLOCK(x ,z ,y)=TYPE_FLOWER;
							BLOCK(x ,z ,y-1)=TYPE_GRASS;
						}else if(arc4random()%2==0){
							BLOCK(x ,z ,y-1)=TYPE_GRASS;
						}else{
							BLOCK(x ,z ,y-1)=TYPE_GRASS2;
						}
                        //setColort(x ,z ,y-1 ,22+18);
                        //setLandt(x ,z ,y-1 ,TYPE_GRASS);
					}
				}else{
					
					
					
				}
				
			}
			
		}
	}
    
}
static const int TREE_SPACING=50;
void placeTree(int x,int z,int y){
	
	if(arc4random()%TREE_SPACING!=0)return;
	int tree_height=arc4random()%3+6;
	if(y+tree_height>=T_HEIGHT) return;
	for(int i=x-1;i<=x+1;i++){
		for(int j=z-1;j<=z+1;j++){
			int type=BLOCK(i ,j ,y-1);
			if(!(type==TYPE_GRASS||type==TYPE_GRASS2||type==TYPE_DIRT))
				return;
            if(BLOCK(i ,j ,y)!=TYPE_NONE)return;
		}
	}
	for(int i=x-1;i<=x+1;i++){
		for(int j=z-1;j<=z+1;j++){
			for(int k=y;k<y+tree_height;k++){
				int type=BLOCK(i ,j ,k);
				if(type==TYPE_NONE||type==TYPE_LEAVES)
					continue;
				break;
                
				
			}
		}
		
	}
	
	//NSLog(@"placing tree %d %d %d",x,z,y+i);
	for(int i=0;i<3*tree_height/4;i++){
		BLOCK(x ,z ,y+i)=TYPE_TREE;
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
                                BLOCK(i ,j ,k)=type;
                                COLOR(i ,j ,k)=ct[color];
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

void makeDesert(){
    float var=3;  //how much variance in heightmap?
    
    [World getWorld].terrain.final_skycolor=colorTable[17];
    //TG_SEED=0;
	
	
    int slideh;
	int offsety=T_HEIGHT/2-10;
    for(int x=0;x<GSIZE/4+20;x++){ //Heightmap
		for(int z=GSIZE/4-20;z<3*GSIZE/4;z++){
            
            if(z<GSIZE/4){
                offsety=T_HEIGHT/2-10-ABS(GSIZE/4-z);
            }else if(x>GSIZE/4){
                 offsety=T_HEIGHT/2-10-ABS(GSIZE/4-x);
            }else{
                offsety=T_HEIGHT/2-10;
            }
            int h;
            
            float n=offsety;
            float FREQ=1.0f;
            //float FREQ3=4.0f;
            float AMPLITUDE=0.0f;
            for(int i=0;i<10;i++){
                float vec[2]={(float)FREQ*(x+TG_SEED)/NOISE_CONSTANT
                    ,(float)FREQ*(z+TG_SEED)/NOISE_CONSTANT};
                n+=noise2(vec)*(AMPLITUDE)*var;
                FREQ*=2;
                AMPLITUDE/=2;
            }
            h=(int)roundf(n);
            if(h-1>=T_HEIGHT){
                NSLog(@"NONONO4");
            }
            
			int FORMATION_HEIGHT=h-6;//how deep should the 3D noise apply
            //The deeper the 3D noise and the more variance in heightmap,
            //The more intense the terrain is
            //
            FORMATION_HEIGHT=T_HEIGHT-1;
        
			for(int y=0;y<h;y++){
				
               
                if(z<GSIZE/2&&BLOCK(x,z,y)==TYPE_NONE){
                BLOCK(x,z,y)=TYPE_SAND;
                COLOR(x,z,y)=11;//colorCycle2(h,2);
                }else
               
                if(BLOCK(x,z,y)!=TYPE_NONE){
                    BLOCK(x,z,y)=TYPE_SAND;
                    COLOR(x,z,y)=colorCycle6(y-1+14,1);
                }
				
			}
            slideh=h;
			
            
		}
        
        
		
	}
    int tsealevel=17;
    for(int x=0;x<GSIZE/4;x++){
        
		for(int z=GSIZE/4;z<3*GSIZE/4;z++){
            if(TM(x,z)!=TM_BEACH)continue;
            //BLOCK(x ,z ,0)=TYPE_SAND;
			
            
			for(int y=1;y<tsealevel;y++){
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
   /* int sx=GSIZE/8;
    int sz=GSIZE/4+GSIZE/8;
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
        
        if(sv.x>=GSIZE-5){
            sv.x=GSIZE-6;
            dv.x=0;
        }else if(sv.x<5){
            sv.x=5;
            dv.x=0;
        }
        if(sv.z>=GSIZE-5){
            sv.z=GSIZE-6;
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
    */
    [World getWorld].terrain.final_skycolor=colorTable[9];
}


void makePonies(){
    float var=3;  //how much variance in heightmap?
    
     [World getWorld].terrain.final_skycolor=colorTable[17];
    //TG_SEED=0;
	
	
	int offsety=T_HEIGHT/2-10;
    for(int x=0;x<GSIZE/4+15;x++){
		for(int z=3*GSIZE/4-15;z<GSIZE;z++){
            offsety=T_HEIGHT/2-10;
            if(x>GSIZE/4-10){
                offsety=T_HEIGHT/2-10+ABS(GSIZE/4-10-x);
                if(x>GSIZE/4){
                     offsety=T_HEIGHT/2-10+ABS(GSIZE/4-10-x)-2*ABS(GSIZE/4-x);;
                }
            }
            if(z<3*GSIZE/4+10){
                offsety=T_HEIGHT/2-10+ABS(3*GSIZE/4+10-z);
                
            }
            if(z<3*GSIZE/4){
                offsety=T_HEIGHT/2-10+ABS(3*GSIZE/4+10-z)-2*ABS(3*GSIZE/4-z);;
               
            }
            if(TM(x,z)!=TM_UNICORN)continue;
            int h;
            
            float n=offsety;
            
            
            float FREQ=2.0f;
            //float FREQ3=4.0f;
            float AMPLITUDE=4.0f;
            for(int i=0;i<10;i++){
                float vec[2]={(float)FREQ*(x+TG_SEED)/NOISE_CONSTANT
                    ,(float)FREQ*(z+TG_SEED)/NOISE_CONSTANT};
                n+=noise2(vec)*(AMPLITUDE)*var;
                FREQ*=2;
                AMPLITUDE/=2;
            }
            h=(int)roundf(n);
            if(h-1>=T_HEIGHT){
                NSLog(@"NONONO5");
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
   
    
    makeCave(0,3*GSIZE/4,2,GSIZE/4,GSIZE,T_HEIGHT/2-15,1);
        [World getWorld].terrain.final_skycolor=colorTable[17];
    
    for(int x=0;x<GSIZE/4;x++){
		for(int z=3*GSIZE/4;z<GSIZE;z++){
            for(int y=1;y<T_HEIGHT/5;y++){
                if(BLOCK(x,z,y)==TYPE_NONE){
                    BLOCK(x,z,y)=TYPE_WATER;
                    COLOR(x,z,y)=6;
                }
            }
        }
    }
}
void makeSkyIsland(int cx,int cz,int cy,int r){
  //  int grasslevel=cy-r/2;
    
    for(int x=-r;x<=r;x++)
        for(int z=-r;z<=r;z++){
           int  y=-r/2;
            if(x*x+z*z+y*y<=r*r){
                //sealevel
                if(BLOCK(cx+x,cz+z,18)!=TYPE_WATER)return;
            }
                
            
        }
    cy=18+r-r/4-r/8;
    for(int x=-r;x<=r;x++)
        for(int z=-r;z<=r;z++){
            for(int y=-r;y<=-r/2;y++){
                
                if(x*x+z*z+y*y<=r*r){
                    if(cy+y>=T_HEIGHT){printg("skyisland hit upper bound\n");}
                    if(cy+y<=1)printg("skyisland hit lower bound)\n");
                    if(y==-r/2){
                        BLOCK(cx+x,cz+z,cy+y)=TYPE_GRASS;
                        COLOR(cx+x,cz+z,cy+y)=0;
                        
                            if((x*x+z*z+y*y)<(r-1)*(r-1)&&randi(90)==0){
                                // printg("making a tree\n");
                                makePalmTree(cx+x,cz+z,cy+y,4);
                            }
                        
                    } else{
                    BLOCK(cx+x,cz+z,cy+y)=TYPE_SAND;
                    COLOR(cx+x,cz+z,cy+y)=colorCycle3(cy+y,1);;
                    }
                }
            }
        }
    

    
}
void makePyramid2(int x,int z,int h,int color,int sy){
    int r=h;
    int starty=T_HEIGHT-1;
    BOOL solidground=FALSE;
    if(sy==-1){
    for(;starty>5;starty--){
        solidground=TRUE;
        for(int sx=x-r;sx<=x+r;sx++){
            
            for(int sz=z-r;sz<=z+r;sz++){
                if(ABS(sx-x)+ABS(sz-z)<=r){
                    
                
                //if(BLOCK(sx,sz,starty)==TYPE_NONE||(blockinfo[BLOCK(sx,sz,starty)]&IS_LIQUID)){
                if(BLOCK(sx,sz,starty)!=TYPE_SAND){
                    if(BLOCK(sx,sz,starty)!=TYPE_NONE)return;
                    solidground=FALSE;
                    break;
                }
                }
            }
            if(!solidground)break;
            
        }
        if(solidground)break;
    }
    if(!solidground)return;
    }else starty=sy;
   // printg("making pyramid\n");
    for(int y=starty;y<=starty+h;y++){
        if(y>T_HEIGHT-4)continue;
        for(int sx=x-r;sx<=x+r;sx++){
            for(int sz=z-r;sz<=z+r;sz++){
                if(ABS(sx-x)+ABS(sz-z)<=r){
                BLOCK(sx,sz,y)=TYPE_DARK_STONE;
                
                
                COLOR(sx,sz,y)=0;
                }
            }
        }
        r--;
    }
    
    
}

void makePyramid(int x,int z,int h,int color){
    int r=h;
    int starty=T_HEIGHT-1;
    BOOL solidground=FALSE;
    for(;starty>5;starty--){
        solidground=TRUE;
        for(int sx=x-r;sx<x+r;sx++){
            
            for(int sz=z-r;sz<z+r;sz++){
                //if(BLOCK(sx,sz,starty)==TYPE_NONE||(blockinfo[BLOCK(sx,sz,starty)]&IS_LIQUID)){
                if(BLOCK(sx,sz,starty)!=TYPE_SAND){
                    if(BLOCK(sx,sz,starty)!=TYPE_NONE)return;
                    solidground=FALSE;
                    break;
                }
            }
            if(!solidground)break;
            
        }
        if(solidground)break;
    }
    if(!solidground)return;
   // printg("making pyramid\n");
    for(int y=starty;y<starty+h;y++){
        if(y>T_HEIGHT-8)continue;
        for(int sx=x-r;sx<x+r;sx++){
            for(int sz=z-r;sz<z+r;sz++){
                BLOCK(sx,sz,y)=TYPE_DARK_STONE;
                
                
                COLOR(sx,sz,y)=0;
            }
        }
        r--;
    }
    
    
}
int ff_depth=0;
int max_depth=0;

Point3D nodeList[5000];
int nNodeList=0;

void floodFill(int x,int z,int y){
    
    if(x>3*GSIZE/4&&z>7*GSIZE/8){
        printg("node (%d,%d,%d)\n",x,z,y);
    }

    
    BLOCK(x,z,y)=ff_type;
    COLOR(x,z,y)=ff_color;
    nodeList[0].x=x;
    nodeList[0].y=y;
    nodeList[0].z=z;
    nNodeList=1;
    int dx[]={-1,1,0,0,0,0,0};
    int dy[]={0,0,-1,1,0,0};
    int dz[]={0,0,0,0,-1,1};
    while(nNodeList>0){
        Point3D node=nodeList[0];
        
                for(int i=0;i<nNodeList-1;i++){
            nodeList[i]=nodeList[i+1];
           
        }
         nNodeList--;
        if(node.x<0||node.x>=GSIZE||node.z<0||node.z>=GSIZE||node.y<=0||node.y>ff_capy||node.y>=T_HEIGHT)continue;
      
        
        
        for(int d=0;d<6;d++){
            Point3D node2=node;
            node2.x+=dx[d];
            node2.y+=dy[d];
            node2.z+=dz[d];
            
            if(node2.x<0||node2.x>=GSIZE||node2.z<0||node2.z>=GSIZE||node2.y<=0||node2.y>ff_capy||node2.y>=T_HEIGHT)continue;
            if(BLOCK(node2.x,node2.z,node2.y)!=TYPE_NONE&&BLOCK(node2.x,node2.z,node2.y)!=TYPE_LAVA)continue;
            
            BLOCK(node2.x,node2.z,node2.y)=ff_type;
            COLOR(node2.x,node2.z,node2.y)=ff_color;
            if(BLOCK(node2.x,node2.z,node2.y-1)==TYPE_GRASS){
                BLOCK(node2.x,node2.z,node2.y-1)=TYPE_DIRT;
                COLOR(node2.x,node2.z,node2.y-1)=0;
            }

            if(nNodeList==5000){
                printg("node List overflow");
                return;
            }
            nodeList[nNodeList]=node2;
            nNodeList++;
            
        }
        
        
      
       
        
        
    }

    /*if(x<0||x>=GSIZE||z<0||z>=GSIZE||y<=0||y>ff_capy||y>=T_HEIGHT)return;
    if(BLOCK(x,z,y)!=TYPE_NONE)return;
    else {
        
       
       
        if(ff_depth>5035){
            return;
         //   max_depth
            //  ff_depth=0;
          //  return;
        }
         ff_depth++;
        floodFill(x,z,y-1);
        floodFill(x,z,y+1);
        floodFill(x+1,z,y);
        floodFill(x-1,z,y);
        floodFill(x,z+1,y);
        floodFill(x,z-1,y);
       
         ff_depth--;
        
        
    }*/
    
}
void makeGreenHills(int height){
    float var=3;  //how much variance in heightmap?
    //TG_SEED=0;
	[World getWorld].terrain.final_skycolor=colorTable[15];
	
	int offsety=height;;
    for(int x=0;x<GSIZE;x++){ //Heightmap
        if(x<GSIZE/4-15)continue;
       
		for(int z=0;z<3*GSIZE/4+15;z++){
            
            offsety=height;
            
            if(x<GSIZE/4+15&&z>GSIZE/4){
                offsety=height+ABS(GSIZE/4+15-x);
                
                offsety=clampy(offsety);
            }
            if(x<GSIZE/4&&z>GSIZE/4) {
                offsety=height-(ABS(GSIZE/4-x))+15;
                offsety=clampy(offsety);
            }
            if(x<GSIZE/4&&z<=GSIZE/4) {
                offsety=height-(ABS(GSIZE/4-x));
                offsety=clampy(offsety);
                
            }
            if(x>GSIZE*3/4){
                offsety=height-(x-GSIZE*3/4);
                offsety=clampy(offsety);
            }
            
            if(z>GSIZE/2&&x>=3*GSIZE/4+35)continue;
            
            if(z>3*GSIZE/4-7&&x<3*GSIZE/4){
                offsety=height+ABS(3*GSIZE/4-7-z);
                
                offsety=clampy(offsety);
            }
            if(z>3*GSIZE/4&&x<3*GSIZE/4){
                offsety=height-ABS(3*GSIZE/4-z)+7;
                
                offsety=clampy(offsety);
            }
            
            int h;
            
            float n=offsety;
            float FREQ=1.0f;
            //float FREQ3=4.0f;
            float AMPLITUDE=8.0f;
            for(int i=0;i<10;i++){
                float vec[2]={(float)FREQ*(x+TG_SEED2)/NOISE_CONSTANT
                    ,(float)FREQ*(z+TG_SEED2)/NOISE_CONSTANT};
                n+=noise2(vec)*(AMPLITUDE)*var;
                FREQ*=2;
                AMPLITUDE/=2;
            }
            h=(int)roundf(n);
            if(h>height+10)h=height+10;
            if(h-1>=T_HEIGHT){
                NSLog(@"NONONO6");
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
    
    for(int x=0;x<GSIZE;x++){
		for(int z=0;z<GSIZE;z++){
           // BLOCK(x ,z ,0)=TYPE_SAND;
			
			for(int y=0;y<T_HEIGHT;y++){
				if(BLOCK(x ,z ,y)==TYPE_NONE){
					if(BLOCK(x ,z ,y-1)==TYPE_DIRT){
                        
							BLOCK(x ,z ,y-1 )=TYPE_GRASS;
                        COLOR(x ,z ,y-1 )=colorCycle3(y+30,3);
					}
				}else{
					
					
					
				}
				
			}
			
		}
	}
    int sea_level=0;
    for(int x=GSIZE/4;x<=GSIZE/2-60;x++){
		for(int z=0;z<3*GSIZE/4;z++){
            //BLOCK(x ,z ,0)=TYPE_SAND;
            //if(x<GSIZE/2&&z<GSIZE/4)continue;
           
            if(x==GSIZE/2-60){
                ff_capy=17;
                floodFill(x,z,17);
                continue;
                //sea_level=((GSIZE/2-120)-x)/6.0f;
               // floodFill(x,z,19,TYPE_WATER);
            }else sea_level=0;
            
			for(int y=6;y<19+sea_level;y++){
				if(BLOCK(x ,z ,y)==TYPE_NONE){
                    for(int iy=1;iy<6;iy++){
                    BLOCK(x,z,y-iy)=TYPE_WATER;
                        if(z<GSIZE/2&&z>GSIZE/4)
                             COLOR(x,z,y-iy)=15;//0
                            else
                    COLOR(x,z,y-iy)=15;
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
void makeRiverTrees(int sx,int sz,int ex,int ez,int SEED){
    float var=3;  //how much variance in heightmap?
    //TG_SEED=0;
	[World getWorld].terrain.final_skycolor=colorTable[9];
	
	const int offsety=T_HEIGHT/2-10;
    for(int x=sx;x<ex;x++){
		for(int z=sz;z<ez;z++){
            if(TM(x,z)!=TM_RIVERS)continue;
            int h;
            
            float n=offsety;
            float FREQ=1.0f;
            //float FREQ3=4.0f;
            float AMPLITUDE=20.0f;
            for(int i=0;i<10;i++){
                float vec[2]={(float)FREQ*(x+SEED)/NOISE_CONSTANT
                    ,(float)FREQ*(z+SEED)/NOISE_CONSTANT};
                n+=noise2(vec)*(AMPLITUDE)*var;
                FREQ*=2;
                AMPLITUDE/=2;
            }
            h=(int)roundf(n);
            if(h-1>=T_HEIGHT){
                NSLog(@"NONONO bad height river trees gen");
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
    
    for(int x=sx;x<ex;x++){
		for(int z=sz;z<ez;z++){
             if(TM(x,z)!=TM_RIVERS)continue;
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
    for(int x=sx;x<ex;x++){
		for(int z=sz;z<ez;z++){
             if(TM(x,z)!=TM_RIVERS)continue;
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
     int x=randi(GSIZE-10)+5;
     int z=randi(GSIZE-10)+5;
     // int color=randi(53);
     
     Vector pos;
     do{
     pos= makeWorm(x,z,15,randi(2)+3);
     }while(pos.x==-1);
     
     }
     */
   
    
     for(int x=sx+4;x<ex-4;x++){ //Trees
     for(int z=sz+4;z<ez-4;z++){
          if(TM(x,z)!=TM_RIVERS)continue;
     for(int y=4;y<T_HEIGHT-10;y++){
     if(BLOCK(x ,z ,y)==TYPE_DIRT&&BLOCK(x ,z ,y+1)==TYPE_NONE){
         if(randi(70)==0){
        // printg("making a tree\n");
         makeTree2(x,z,y,12);
         }
     }
     }
     }
     }
    
    
}
void makeTransition(int sx,int sz,int ex,int ez){
    for(int z=sz;z<ez;z++){
        int lh=0,rh=0;
        int ltype,rtype;
        int lcolor,rcolor;
        for(int i=T_HEIGHT-1;i>=0;i--){
            if(BLOCK(sx-1,z,i)!=TYPE_NONE&&BLOCK(sx-1,z,i)!=TYPE_CLOUD){
                lh=i+1;
                ltype=BLOCK(sx-1,z,i);
                lcolor=COLOR(sx-1,z,i);
                //  printg("found type: %d  height: %d\n",BLOCK(sx-1,z,i),i);
                break;
            }
        }
        for(int i=T_HEIGHT-1;i>=0;i--){
            if(BLOCK(ex,z,i)!=TYPE_NONE&&BLOCK(sx-1,z,i)!=TYPE_CLOUD){
                rh=i+1;
                rtype=BLOCK(ex,z,i);
                rcolor=COLOR(ex,z,i);
                break;
            }
        }
        int deltay=rh-lh;
        Vector lvcolor=colorTable[lcolor];
        if(lcolor==0)lvcolor=MakeVector(blockColor[ltype][0]/255.0f,blockColor[ltype][1]/255.0f,blockColor[ltype][2]/255.0f);
        
        Vector rvcolor=colorTable[rcolor];
        if(rcolor==0)rvcolor=MakeVector(blockColor[rtype][0]/255.0f,blockColor[rtype][1]/255.0f,blockColor[rtype][2]/255.0f);
        
        Vector deltacolor=MakeVector(rvcolor.x-lvcolor.x,rvcolor.y-lvcolor.y,rvcolor.z-lvcolor.z);
        
        
        
        for(int x=sx;x<ex;x++){
            
            
            
            float fx=(float)(x-sx)/(ex-sx);
           // printg("fx:%f\n",fx);
            //int h=(lh*fx+rh*(1-fx))/2.0f;
            int h=deltay*fx+lh;//(lh+rh)/2;
            float cx=1-fx;
            if(cx>1.0f||cx<0){
                printg("error color interpolating\n");
            }
            Vector mcolor=MakeVector(rvcolor.x-deltacolor.x*cx,rvcolor.y-deltacolor.y*cx,rvcolor.z-deltacolor.z*cx);
            
            for(int y=1;y<h;y++){
                
                if(getBaseType(ltype)==TYPE_WATER||getBaseType(rtype)==TYPE_WATER){
                    if(getBaseType(ltype)==getBaseType(rtype)){
                     BLOCK(x,z,y)=ltype;
                     COLOR(x,z,y)=lookupColor(mcolor);
                    }else if(getBaseType(ltype)==TYPE_WATER){
                        BLOCK(x,z,y)=rtype;
                        COLOR(x,z,y)=rcolor;

                    }else if(getBaseType(rtype)==TYPE_WATER){
                        BLOCK(x,z,y)=ltype;
                        COLOR(x,z,y)=lcolor;
                        
                    }
                }else if(ltype==rtype){
                    BLOCK(x,z,y)=ltype;
                    COLOR(x,z,y)=lookupColor(mcolor);
                    
                }else if(fx<.5f){
                    
                    BLOCK(x,z,y)=ltype;
                    COLOR(x,z,y)=lookupColor(mcolor);
                    
                    
                }else if(fx>=.5f){
                    BLOCK(x,z,y)=rtype;
                    COLOR(x,z,y)=lookupColor(mcolor);
                }
            }
            
        
        }
    }
}
void makeMountains(int sx,int sz,int ex,int ez,int SEED){
    float var=3;  //how much variance in heightmap?
    //TG_SEED=0;
	[World getWorld].terrain.final_skycolor=colorTable[6];
	
    
    
	const int offsety=T_HEIGHT/2-10;
    for(int x=sx;x<ex;x++){
		for(int z=sz;z<ez;z++){
            if(TM(x,z)!=TM_MOUNTAINS)continue;
            int h;
            
            float n=offsety;
            float FREQ=1.0f;
            //float FREQ3=4.0f;
            float AMPLITUDE=20.0f;
            for(int i=0;i<10;i++){
                float vec[2]={(float)FREQ*(x+SEED)/NOISE_CONSTANT
                    ,(float)FREQ*(z+SEED)/NOISE_CONSTANT};
                n+=noise2(vec)*(AMPLITUDE)*var;
                FREQ*=2;
                AMPLITUDE/=2;
            }
            h=(int)roundf(n);
            if(h-1>=T_HEIGHT){
                //NSLog(@"NONONO7");
                h=T_HEIGHT-1;
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
    
    for(int x=sx;x<ex;x++){ 
		for(int z=sz;z<ez;z++){
            if(TM(x,z)!=TM_MOUNTAINS)continue;
         //   BLOCK(x ,z ,0)=TYPE_SAND;
			int snowlevel=34;
			for(int y=snowlevel;y<T_HEIGHT;y++){
                if(y==34||y==35)if(arc4random()%2==0)continue;
                
                if(y==36||y==37)if(arc4random()%2==0)continue;
                
                if(y==38||y==39)if(arc4random()%2==0&&arc4random()%2==0)continue;
                
				if(BLOCK(x ,z ,y)==TYPE_NONE){
					if(BLOCK(x ,z ,y-1)==TYPE_STONE){
                        
                        BLOCK(x ,z ,y-1 )=TYPE_CLOUD;
                        COLOR(x ,z ,y-1 )=0;
                        if(BLOCK(x,z,y-2)==TYPE_STONE){
                            BLOCK(x,z,y-2)=TYPE_CLOUD;
                            COLOR(x,z,y-2)=0;
                        }
					}
				}else{
					
					
					
				}
				
			}
			
		}
	}
  //  int sea_level=-14;
    for(int x=sx;x<ex;x++){ 
		for(int z=sz;z<ez;z++){
            if(TM(x,z)!=TM_MOUNTAINS)continue;
            //BLOCK(x ,z ,0)=TYPE_SAND;
			
			for(int y=3;y<6;y++){
				if(BLOCK(x ,z ,y)==TYPE_NONE){
                    for(int iy=1;iy<3;iy++){
                        if(x<=GSIZE/4-(GSIZE/4/4)&&z<=GSIZE/4-(GSIZE/4/4))
                        {
                            if(x==GSIZE/4-(GSIZE/4/4)||z==GSIZE/4-(GSIZE/4/4)){
                                
                                if(arc4random()%2==0){
                                    BLOCK(x,z,y-iy)=TYPE_ICE;
                                    COLOR(x,z,y-iy)=6;
                                }else{
                                    BLOCK(x,z,y-iy)=TYPE_WATER;
                                    COLOR(x,z,y-iy)=6;
                                }
                            }else{
                                BLOCK(x,z,y-iy)=TYPE_ICE;
                                COLOR(x,z,y-iy)=6;
                            }
                            
                        } else{
                            BLOCK(x,z,y-iy)=TYPE_WATER;
                            COLOR(x,z,y-iy)=6;
                        }                    }
                }else{
					
					
					
				}
				
			}
			
		}
	}
    /*
     
     for(int i=0;i<20;i++){
     int x=randi(GSIZE-10)+5;
     int z=randi(GSIZE-10)+5;
     // int color=randi(53);
     
     Vector pos;
     do{
     pos= makeWorm(x,z,15,randi(2)+3);
     }while(pos.x==-1);
     
     }
     */
    
    /*for(int x=4;x<GSIZE-4;x++){ //Trees
        for(int z=4;z<GSIZE-4;z++){
            for(int y=4;y<T_HEIGHT-10;y++){
                if(BLOCK(x ,z ,y)==TYPE_DIRT&&BLOCK(x ,z ,y+1)==TYPE_NONE){
                    if(randi(70)==0){
                        // printg("making a tree\n");
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
int g_terrain_type=7;
void clear(){
    [World getWorld].terrain.final_skycolor=colorTable[9];
    
    memset(elevation,0,sizeof(block8)*(GSIZE*GSIZE));
    if(NOBLOCKGEN)return;
    memset(blockz,0,sizeof(block8)*(BLOCKZ_SIZE));
    memset(colorz,0,sizeof(color8)*(BLOCKZ_SIZE));
    for(int x=0;x<GSIZE;x++){
        for(int z=0;z<GSIZE;z++){
            for(int y=0;y<2;y++){
                BLOCK(x,z,y)=TYPE_BEDROCK;
                
            }
            // for(int y=2;y<T_HEIGHT;y++){
            //    BLOCK(x,z,y)=TYPE_NONE;
            //}
        }
    }
}
void genTemperatureMap(){
    float var=3;
    int offset=T_HEIGHT/2;
    int mwidth=16;
    int mheight=16;
    float map[mwidth+2][mheight+2];
    memset(map,0,sizeof(map));
    for(int x=0;x<mwidth;x++){ //Heightmap
        for(int z=0;z<mheight;z++){
            int h;
            
            float n=0;
            float FREQ=16.0f;
            //float FREQ3=4.0f;
            float AMPLITUDE=16.0f;
            for(int i=0;i<10;i++){
                float vec[2]={(float)FREQ*(x+TG_SEED2)/NOISE_CONSTANT
                    ,(float)FREQ*(z+TG_SEED2)/NOISE_CONSTANT};
                n+=noise2(vec)*(AMPLITUDE)*var;
                FREQ*=2;
                AMPLITUDE/=2;
            }
            h=(int)roundf(n)+offset;
            if(h-1>=T_HEIGHT){
                NSLog(@"NONONO8");
            }
           
			
            int y;
            y=clampy(h);
            map[x][z]=y/64.0f;
            
                 
           
                
				
			
			
            
		}
		
	}
    float mwr=GSIZE/(float)mwidth;
    float mhr=GSIZE/(float)mheight;
    for(int x=0;x<GSIZE;x++){
        for(int z=0;z<GSIZE;z++){
            float fx=(float)x/mwr;
            float fz=(float)z/mhr;
            float f00=map[(int)fx][(int)fz];
            float f10=map[(int)fx+1][(int)fz];
            float f01=map[(int)fx][(int)fz+1];
            float f11=map[(int)fx+1][(int)fz+1];
            
            float px=fx-(int)fx;
            float pz=fz-(int)fz;
         /*
            float d00=sqrtf((1-px)*(1-px)+(1-pz)*(1-pz));
            float d10=sqrtf(px*px+(1-pz)*(1-pz));
            float d01=sqrtf((1-px)*(1-px)+pz*pz);
            float d11=sqrtf(px*px+pz*pz);*/
            
           // float r=(f00*d00+f10*d10)/(d00+d10);//+f10*d10+f11*d11+f01*d01)/(d00+d01+d10+d11);
            
                            
            float r=f00*(1-px)+f10*px;
            float r2=f01*(1-px)+f11*px;
            
            
            r=(r*(1-pz)+r2*pz);
            
            float r3=f00*(1-pz)+f01*pz;
            float r4=f10*(1-pz)+f11*pz;
            r3=(r3*(1-px)+r4*px);
           
           
            TEMP(x,z)=((r+r3)/2.0f)*255.0f-128.0f;
        }
    }
    
}
void makeOcean(){
    int sealevel=33;
    for(int x=0;x<GSIZE;x++){
		for(int z=0;z<GSIZE;z++){
            if(TM(x,z)!=TM_WATER)continue;
            for(int y=1;y<sealevel;y++){
				if(BLOCK(x ,z ,y)==TYPE_NONE){
                    
                    
                    BLOCK(x,z,y)=TYPE_WATER;
                    COLOR(x,z,y)=0;
                    
                    
                	
				}
				
			}
			
		}
        
    }
}
int tg2_init(){
    //clear();
    elevation=(block8*)malloc(sizeof(block8)*GSIZE*GSIZE);
    
    if(!NOBLOCKGEN){
    blockz=(block8*)malloc(sizeof(block8)*BLOCKZ_SIZE);
    colorz=(color8*)malloc(sizeof(color8)*BLOCKZ_SIZE);
    if(!blockz)printg("couldn't allocate mem for blockz\n");
    if(!colorz)printg("couldn't allocate mem for colorz\n");
        
    }
    
    tgenInit();
    
   
    /*  for(int x=0;x<GSIZE;x++){
        for(int z=0;z<GSIZE;z++){
            int h=x;
            if(h>=T_HEIGHT)h=T_HEIGHT-1;
            BLOCK( x,z, h)=TYPE_STONE;
        }
    }*/
       
    for(int i=0;i<100;i++){
    //    makeHill(randi(GSIZE),randi(GSIZE),3,randi(35),0);
    }
      clear();
    genTemperatureMap();
    if(NOBLOCKGEN){
        
        
        
        return 0;
        
    }
   /* for(int i=0;i<NUM_TERRAIN_MARKERS;i++){
        if(i==TM_BEACH){
            makeBeach();
        }else if(i==TM_MARS){
            makeMars(0,0,GSIZE,GSIZE);
        }else if(i==TM_GRASS){
            makeDirt();
        }else if(i==TM_UNICORN){
            makePonies();
        }else if(i==TM_RIVERS){
            makeRiverTrees(0,0,GSIZE,GSIZE,550);
        }else if(i==TM_MOUNTAINS){
            makeMountains(0,0,GSIZE,GSIZE,550);
        }else if(i==TM_WATER){
            makeOcean();
        }
    }*/
      g_terrain_type=7;
      if(g_terrain_type==0){
      makeDirt();
      }else if(g_terrain_type==1){
      makeMars(0,0,GSIZE,GSIZE);
      }else if(g_terrain_type==2){
      makeRiverTrees(0,0,GSIZE,GSIZE,550);
      }else if(g_terrain_type==3){
      makeRiverTrees(GSIZE/2,0,GSIZE,GSIZE,550);
      makeMountains(0,0,GSIZE/2-32,GSIZE,550);
      makeTransition(GSIZE/2-32,0,GSIZE/2,GSIZE);
      }else if(g_terrain_type==4){
      makeDesert();
      }else if(g_terrain_type==5){
      makePonies();
      }else if(g_terrain_type==6){
      makeBeach();
      }else if(g_terrain_type==7){
      makeMix();
      }else if(g_terrain_type==8){
          
      //genflat=TRUE;
      }
   /* int sx=0;
    int sz=0;
    int increment=1;
    for(float x=0;x<1024;x+=increment){
        sx++;
        sz=0;
        for(float z=0;z<1024;z+=increment){
            sz++;
            int ix=x;
            int iz=z;
            
            
            // glColor4f(value,value,value,1.0f);
            // [Graphics drawRect:sx:sz:sx+1:sz+1];
           // float value=(TEMP(ix,iz)+128.0f)/255.0f;
            
            int biome=TM(ix,iz);
            if(biome==TM_GRASS){
                for(int y=0;y<T_HEIGHT;y++){
                    if(BLOCK(ix,iz,y)){
                        BLOCK(ix,iz,y)=TYPE_GRASS;
                        COLOR(ix,iz,y)=0;
                    }
                }
            }else if(biome==TM_WATER){
                for(int y=0;y<T_HEIGHT;y++){
                    if(BLOCK(ix,iz,y)){
                        BLOCK(ix,iz,y)=TYPE_WATER;
                        COLOR(ix,iz,y)=0;
                    }
                }
            }
            //COLOR(ix,iz,T_HEIGHT-1)=0;

            
        }
        
    }*/
   //printg("creating biome: %d\n",g_terrain_type);

    return 0;
    
}



int lrx=-1;
int lrz=-1;
BOOL loaded_new_terrain=FALSE;
extern int regionSkyColors[4][4];
void updateSkyColor1(Player* player,BOOL force){
    updateSkyColor2(player,force,0);
}
//static float timeSinceLastChange=0;
void updateSkyColor2(Player* player,BOOL force,float etime){
    extern int g_offcx;
    if(force){
        lrx=lrz=-1;
        loaded_new_terrain=TRUE;
    }
   
    if(!loaded_new_terrain)return;
     loaded_new_terrain=FALSE;
    //if([World getWorld].terrain.tgen.LEVEL_SEED==DEFAULT_LEVEL_SEED){
       
        int ppx=player.pos.x-4096*CHUNK_SIZE+GSIZE/2;
        int ppz=player.pos.z-4096*CHUNK_SIZE+GSIZE/2;
        ppx=ppx/(GSIZE/4);
        ppz=ppz/(GSIZE/4);
        if(ppx>4)ppx=4;
        if(ppz>4)ppz=4;
        if(ppx<0)ppx=0;
        if(ppz<0)ppz=0;
                   
        
        //printg("region: %d,%d\n",(int)ppx,(int)ppz);
        
        if(lrx!=ppx||lrz!=ppz){
            if(lrx==-1||regionSkyColors[ppz][ppx]!=regionSkyColors[lrz][lrx]){
                
                //timeSinceLastChange=0;
                int rct=regionSkyColors[(int)(ppz+64)%4][(int)(ppx+64)%4];
                if(!LOW_MEM_DEVICE)
                if((v_equals([World getWorld].terrain.final_skycolor,colorTable[54])&&rct!=54)||
                   (!v_equals([World getWorld].terrain.final_skycolor,colorTable[54])&&rct==54)){
                    extern BOOL* chunksToUpdate;
                    extern BOOL* columnsToUpdate;
                    
                    memset(chunksToUpdate,TRUE,sizeof(BOOL)*CHUNKS_PER_SIDE*CHUNKS_PER_SIDE*CHUNKS_PER_COLUMN);
                    memset(columnsToUpdate,TRUE,sizeof(BOOL)*CHUNKS_PER_SIDE*CHUNKS_PER_SIDE);
                }
                [World getWorld].terrain.final_skycolor=colorTable[rct];
                if(force){
                    [World getWorld].terrain.skycolor=MakeVector([World getWorld].terrain.final_skycolor.x,[World getWorld].terrain.final_skycolor.y,[World getWorld].terrain.final_skycolor.z+.03f);
                    
                }
                
                
            }
            lrx=ppx;
            lrz=ppz;
        }
        
    //}



    
    
}
void paintSky(int color){
    if( v_equals([World getWorld].terrain.final_skycolor,colorTable[color]))return;
   // timeSinceLastChange=0;
    if(!LOW_MEM_DEVICE)
    if((v_equals([World getWorld].terrain.final_skycolor,colorTable[54])&&color!=54)||
        (!v_equals([World getWorld].terrain.final_skycolor,colorTable[54])&&color==54)){
        extern BOOL* chunksToUpdate;
        extern BOOL* columnsToUpdate;
        
        memset(chunksToUpdate,TRUE,sizeof(BOOL)*CHUNKS_PER_SIDE*CHUNKS_PER_SIDE*CHUNKS_PER_COLUMN);
        memset(columnsToUpdate,TRUE,sizeof(BOOL)*CHUNKS_PER_SIDE*CHUNKS_PER_SIDE);
    }
    [World getWorld].terrain.final_skycolor=colorTable[color];
    
    int ppx=[World getWorld].player.pos.x-4096*CHUNK_SIZE+GSIZE/2;
    int ppz=[World getWorld].player.pos.z-4096*CHUNK_SIZE+GSIZE/2;
    ppx=ppx/(GSIZE/4);
    ppz=ppz/(GSIZE/4);
    if(ppx>4)ppx=4;
    if(ppz>4)ppz=4;
    if(ppx<0)ppx=0;
    if(ppz<0)ppz=0;
   
    lrx=ppx;
    lrz=ppz;
    regionSkyColors[lrz][lrx]=color;
    
    
    
}
void tg2_render(){
    float increment=1;
    if(GSIZE>768){
       increment=GSIZE/768.0f;
    }
    int sx=0;
    int sz=0;
    for(float x=0;x<GSIZE;x+=increment){
        sx++;
        sz=0;
        for(float z=0;z<GSIZE;z+=increment){
            sz++;
            int ix=x;
            int iz=z;
            
           
           // glColor4f(value,value,value,1.0f);
           // [Graphics drawRect:sx:sz:sx+1:sz+1];
             //float value=(TEMP(ix,iz)+128.0f)/255.0f;
         /*
            int biome=BIOME(ix,iz);
            if(biome==1)
                BLOCK(ix,iz,T_HEIGHT-1)=TYPE_GRASS;
            else if(biome==2)
                BLOCK(ix,iz,T_HEIGHT-1)=TYPE_WATER;
            COLOR(ix,iz,T_HEIGHT-1)=0;
        */
            for(int y=T_HEIGHT-1;y>0;y--){
               
                if(BLOCK(ix,iz,y)==0)continue;
                
                
                    int icolor=COLOR(ix,iz,y);
                    
                    Vector color;
                    if(icolor==0){
                        int type=BLOCK(ix,iz,y);
                        
                        color.x=blockColor[type][0]/255.0f;
                        color.z=blockColor[type][2]/255.0f;
                        color.y=blockColor[type][1]/255.0f;
                        //color.x=1.0f;
                        
                        
                    }else{
                        color=colorTable[icolor];
                    }
                //color=colorTable[10];
                    glColor4f(color.x,color.y,color.z,1.0f);
                    [Graphics drawRect:sx:GSIZE/increment-sz:sx+1:GSIZE/increment-sz+1];
                    
                    
                    break;
                    
               
           }
        }
        
        

    }
    
}
