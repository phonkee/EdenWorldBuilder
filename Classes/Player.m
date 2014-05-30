//
//  Player.m
//  prototype
//
//  Created by Ari Ronen on 10/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Player.h"
#import "Util.h"
#import "Globals.h"
#import "Model.h"
#import "TerrainGen2.h" //for sky color change
#define MOVE_SPEED 120.0f
#define CLIMB_SPEED 3.0f
//#define SPEED_M 4.5f
#define SPEED_M 8.0f

#define YAW_SPEED .4f
#define PITCH_SPEED .4f
#define JUMP_SPEED 6.7f

#define YAW_ANIM_SPEED 360
#define FLOW_SPEED 5
#define THREE_TO_ONE(x,y,z) 

@implementation Player
@synthesize pos,yaw,pitch,move_back,jumping,invertcam,autojump_option,vel,flash,pbox,life,dead,health_option;
static int nest_count;
static bool onground;
static bool onramp;
static bool jumpandbuild;

bool FLY_MODE=TRUE;
bool FLY_UP=false;
bool FLY_DOWN=false;
static Point3D buildpoint;
float yawanimation;
- (id)initWithWorld:(World*) lworld{
	world=lworld;
	boxbase=(BLOCK_SIZE*2.0f)/3.0f;
	boxheight=(BLOCK_SIZE*1.85f);
	autojump_option=TRUE;
	doublejump=FALSE;
	return self;
}

- (void)reset{
	jumpandbuild=FALSE;
	lpos.x=pos.x;
	lpos.y=pos.y;
	lpos.z=pos.z;
	yawanimation=0;
    life=1;
    dead=false;
	pitch=-15;
	jumping=FALSE;
    climbing=FALSE;
    inLiquid=FALSE;
    inPortal=FALSE;
    onramp=FALSE;
    onIce=FALSE;
	vel.x=vel.y=vel.z=0;
    float bot=pos.y-boxheight/2;
	float top=pos.y+boxheight/2;
	float left=pos.x-boxbase/2;
	float right=pos.x+boxbase/2;
	float front=pos.z-boxbase/2;
	float back=pos.z+boxbase/2;
    
    pbox=makeBox(left,right,back,front,bot,top);
    accel=MakeVector(0,0,0);
    walk_force=MakeVector(0,0,0);
    max_walk_speed=0;
    flash=0; 
	
}
extern Vector minTranDist;
- (BOOL)test:(int)tx:(int)ty:(int)tz:(float)r{
    float bot=pos.y-boxheight/2;
	float top=pos.y+boxheight/2;
	float left=pos.x-boxbase/2;
	float right=pos.x+boxbase/2;
	float front=pos.z-boxbase/2;
	float back=pos.z+boxbase/2;
    int type=[World getWorld].hud.blocktype;
    pbox=makeBox(left,right,back,front,bot,top);
    Polyhedra pbox2;
    if(type>=TYPE_STONE_RAMP1&&type<=TYPE_ICE_RAMP4){
        
        pbox2=makeRamp(tx,tx+r,tz+r,tz,ty,ty+r,type%4);
        // NSLog(@"yop");
        
    }else if(type>=TYPE_STONE_SIDE1&&type<=TYPE_ICE_SIDE4){
        pbox2=makeSide(tx,tx+r,tz+r,tz,ty,ty+r,type%4);
        
    }else if(blockinfo[type]&IS_LIQUID){
        pbox2=makeBox(tx,tx+r,tz+r,tz,ty,ty+getLevel(type)/4.0f);
    }else
        pbox2=makeBox(tx,tx+r,tz+r,tz,ty,ty+r);
    
    if(collidePolyhedra(pbox,pbox2))
    {
        if(v_length2(minTranDist)<.1f) 
            return false;
        else
           return true;
    }
       
    return false;/*
    
    
	float minx=pos.x-boxbase/2;
	float maxx=pos.x+boxbase/2;
	float minz=pos.z-boxbase/2;
	float maxz=pos.z+boxbase/2;
	float miny=pos.y-boxheight/2;
	float maxy=pos.y+boxheight/2;
	
	float bminx=x*BLOCK_SIZE;
	float bmaxx=bminx+BLOCK_SIZE;
	float bminy=y*BLOCK_SIZE;
	float bmaxy=bminy+BLOCK_SIZE;
	float bminz=z*BLOCK_SIZE;
	float bmaxz=bminz+BLOCK_SIZE;
	
	if (maxy < bminy) return FALSE;
	if (miny > bmaxy) return FALSE;	
    if (maxx < bminx) return FALSE;
    if (minx > bmaxx) return FALSE;
	if (maxz < bminz) return FALSE;
    if (minz > bmaxz) return FALSE;
	return TRUE;*/
	
}

static const int usage_id=10;
extern int fwc_result;
- (void)setSpeed:(Vector)walk_dir:(float)walk_speed{
    walk_force=walk_dir;
    walk_force.z=walk_force.y;
    walk_force.y=0;
    max_walk_speed=walk_speed*SPEED_M*1.3f;

}

extern bool hitCustom;
- (void)processInput:(float)etime{
	Input* input=[Input getInput];
	int mode=[World getWorld].hud.mode;
	itouch* touches=[input getTouches];
	
	if(jumpandbuild){
        if(vel.y>0&&jumping&&!onground){
            Point3D testpoint=buildpoint;
            if([World getWorld].hud.build_size==0){
                testpoint.x/=2;
                testpoint.y/=2;
                testpoint.z/=2;
            }
            BOOL collidesWithPlayer=FALSE;
            if([World getWorld].hud.build_size==2)
                collidesWithPlayer=[[World getWorld].player test:testpoint.x:testpoint.y:testpoint.z:2];
            else
                collidesWithPlayer=[[World getWorld].player test:testpoint.x:testpoint.y:testpoint.z:1];
            
            if(!collidesWithPlayer){
                
                int type=[World getWorld].hud.blocktype;
                if(type==TYPE_STONE||type==TYPE_DARK_STONE||type==TYPE_COBBLESTONE||type==TYPE_BRICK||type==TYPE_VINE){
                    
                    [[Resources getResources] playSound:S_BUILD_STONE];
                }else if(type==TYPE_LEAVES){							 
                    [[Resources getResources] playSound:S_BUILD_LEAVES];	 
                }else if(blockinfo[type]&IS_LAVA){							 
                    [[Resources getResources] playSound:S_BUILD_LAVA];	 
                }else if(blockinfo[type]&IS_WATER){							 
                    [[Resources getResources] playSound:S_BUILD_WATER];	 
                }else if(blockinfo[type]&IS_FLAMMABLE&&type!=TYPE_WEAVE&&type!=TYPE_WEAVE&&type!=TYPE_TNT&&type!=TYPE_LADDER&&type!=TYPE_FIREWORK){							 
                    [[Resources getResources] playSound:S_BUILD_WOOD];	 
                }else if(type==TYPE_GLASS){
                    [[Resources getResources] playSound:S_BUILD_GLASS];	
                }else if(blockinfo[type]&IS_GRASS||type==TYPE_DIRT){
                    [[Resources getResources] playSound:S_BUILD_DIRT];	
                }else{
                    [[Resources getResources] playSound:S_BUILD_GENERIC];
                }
                if([World getWorld].hud.build_size==0){
                   // [[World getWorld].terrain buildCustom:buildpoint.x:buildpoint.z:buildpoint.y];
                } else if([World getWorld].hud.build_size==2){
                    [[World getWorld].terrain buildBlock:buildpoint.x:buildpoint.z:buildpoint.y];
                    [[World getWorld].terrain buildBlock:buildpoint.x+1:buildpoint.z:buildpoint.y];
                    [[World getWorld].terrain buildBlock:buildpoint.x:buildpoint.z+1:buildpoint.y];
                    [[World getWorld].terrain buildBlock:buildpoint.x:buildpoint.z:buildpoint.y+1];
                    [[World getWorld].terrain buildBlock:buildpoint.x+1:buildpoint.z+1:buildpoint.y];
                    [[World getWorld].terrain buildBlock:buildpoint.x:buildpoint.z+1:buildpoint.y+1];
                    [[World getWorld].terrain buildBlock:buildpoint.x+1:buildpoint.z:buildpoint.y+1];
                    [[World getWorld].terrain buildBlock:buildpoint.x+1:buildpoint.z+1:buildpoint.y+1];                  
                }else{
                    [[World getWorld].terrain buildBlock:buildpoint.x:buildpoint.z:buildpoint.y];                    
                }
                jumpandbuild=FALSE;
            }
        }else {
            jumpandbuild=FALSE;
        }
    }
    extern int flamecount;
	//BOOL fakebuild=false;
    if(flamecount%2==0){
      //  fakebuild=true;
        
     //   static int c=0;
      /*  for(int i=0;i<200;i++){
            [[World getWorld].terrain buildBlock:c%T_SIZE:(c/T_SIZE)%T_SIZE:T_HEIGHT/2+(c/(T_SIZE*T_SIZE))%T_HEIGHT];
            c++;
        }*/
     //   printf("c:%d\n",c);
        

    
    }
	
	for(int i=0;i<MAX_TOUCHES;i++){
		if(touches[i].inuse==0&&touches[i].down==M_DOWN){
           
			touches[i].inuse=usage_id;
            if(mode==MODE_BUILD){
                Point3D point=findWorldCoords(touches[i].my,touches[i].mx,FC_PLACE);
                if(point.x==-1)continue;
                
                int type=[[World getWorld].terrain getLand:point.x:point.z:point.y];
                if([World getWorld].hud.build_size==0){
                    type=[[World getWorld].terrain getLand:point.x/2:point.z/2:point.y/2];
                
                }
                
                if(type==TYPE_NONE||(type==TYPE_CUSTOM&&[World getWorld].hud.build_size==0)||(blockinfo[type]&IS_LIQUID&&getLevel(type)<4)){
                    touches[i].preview=point;
                    touches[i].previewtype=[World getWorld].hud.blocktype;
                    touches[i].etime=0;
                    touches[i].build_size=[World getWorld].hud.build_size;
                    
                    
                }
            }
            if(mode==MODE_PAINT||mode==MODE_MINE||mode==MODE_BURN){
                Point3D point=findWorldCoords(touches[i].my,touches[i].mx,FC_DESTROY);
                if(point.x==-1)continue;
                /*if(hitCustom){
                    if(getCustomc(point.x,point.z,point.y)==TYPE_NONE)continue;
                    touches[i].preview=point;
                    touches[i].previewtype=TYPE_CLOUD;
                    touches[i].etime=0;
                    touches[i].build_size=0;

                    
                }else{*/
                    if([[World getWorld].terrain getLand:point.x:point.z:point.y]==TYPE_NONE)continue;
                    
                    touches[i].preview=point;
                    touches[i].previewtype=TYPE_CLOUD;
                    touches[i].etime=0;
                    touches[i].build_size=1;
              // }
               
               
            }
          
		}
		
	}
	int num=0;
	for(int i=0;i<MAX_TOUCHES;i++){
		if(touches[i].inuse==usage_id&&touches[i].down==M_DOWN){
			num++;
		}		
	}
	if(num>1){
		for(int i=0;i<MAX_TOUCHES;i++){
			if(touches[i].inuse==usage_id&&touches[i].down==M_DOWN){
				touches[i].movecam=FALSE;
			}		
		}		
	}
	for(int i=0;i<MAX_TOUCHES;i++){
		if(touches[i].inuse==usage_id&&touches[i].down==M_RELEASE){
			touches[i].down=M_NONE;
			touches[i].inuse=0;
			if(mode==MODE_CAMERA){	
				if(touches[i].placeBlock){
					[World getWorld].hud.take_screenshot=TRUE;					
					//[[Resources getResources] playSound:SOUND_CAMERA];	
				}
				continue;
			}
			if(mode==MODE_MINE||mode==MODE_BUILD||mode==MODE_BURN||mode==MODE_PAINT){
				if(touches[i].placeBlock){
					Point3D point;
                    if(fwc_result!=-1)printf("hit model: %d\n",fwc_result);
					if(mode==MODE_BUILD){
						point=findWorldCoords(touches[i].my,touches[i].mx,FC_PLACE);
                        
                        
                        if([World getWorld].hud.holding_creature&&[World getWorld].hud.blocktype==TYPE_CLOUD){
                           
                            Vector v;
                            if(point.x!=-1){
                            v.x=point.x;
                            v.y=point.y;
                            v.z=point.z;
                                if([World getWorld].hud.build_size==0){
                                    v.x/=2;
                                    v.y/=2;
                                    v.z/=2;
                                    
                                }
                            }else{
                                
                            }
                            PlaceModel([World getWorld].hud.holding_creature-1,v);
                            point.x=-1;
                        }else
                        if(fwc_result!=-1){
                            PickupModel(fwc_result);
                            printf("building REALLY?: %d,%d,%d\n",point.x,point.y,point.z);
                           // [[Resources getResources] playSound:S_];	
                            point.x=-1;
                        }
                    }
					else{
						point=findWorldCoords(touches[i].my, touches[i].mx, FC_DESTROY);
					}
                    if(mode==MODE_MINE&&fwc_result!=-1){
                        HitModel(fwc_result,pos);
                        
                        point.x=-1;
                    }
                    if(mode==MODE_PAINT&&fwc_result!=-1){
                         [[Resources getResources] playSound:S_PAINT_BLOCK];	
                        ColorModel(fwc_result,[World getWorld].hud.paintColor);
                        
                        point.x=-1;
                    }
                    if(mode==MODE_BURN&&fwc_result!=-1){
                        [[Resources getResources] playSound:S_ATTEMPT_FIRE];
						
                        BurnModel(fwc_result);
                        
                        point.x=-1;
                    }
                    
					if(point.x==-1&&fwc_result==-1){
                        if(mode==MODE_PAINT){
                            
                            extern Vector colorTable[256];
                            [[Resources getResources] playSound:S_PAINT_BLOCK];
                            
                            [World getWorld].terrain.final_skycolor=
                             colorTable[[World getWorld].hud.paintColor];
                            
                            printf("painting sky %f,%f,%f\n",  [World getWorld].terrain.skycolor.x,  [World getWorld].terrain.skycolor.y,  [World getWorld].terrain.skycolor.z);
                            

                        }
                        
                        continue;
                    }
					int type;
                    if(mode==MODE_BUILD){
                    if([World getWorld].hud.build_size==0)
                        type=[[World getWorld].terrain getLand:point.x/2:point.z/2:point.y/2];
                    else
                        type=[[World getWorld].terrain getLand:point.x:point.z:point.y];
                    }else{
                        if(hitCustom){
                           // type=getCustomc(point.x,point.z,point.y);
                            
                        }else
                            type=getLandc(point.x,point.z,point.y);
                        
                        
                    }
					if(type==-1)continue;
					if(mode==MODE_BUILD){
                     //   printf("building: %d,%d,%d type:%d\n",point.x,point.y,point.z,type);
						if(type==TYPE_NONE||type==TYPE_CUSTOM||(blockinfo[type]&IS_LIQUID&&getLevel(type)<4)){
                            Point3D testpoint=point;
                            if([World getWorld].hud.build_size==0){
                                testpoint.x/=2;
                                testpoint.y/=2;
                                testpoint.z/=2;
                            }
                            BOOL collidesWithPlayer=FALSE;
                            if([World getWorld].hud.build_size==2)
                            collidesWithPlayer=[[World getWorld].player test:testpoint.x:testpoint.y:testpoint.z:2];
                            else
                             collidesWithPlayer=[[World getWorld].player test:testpoint.x:testpoint.y:testpoint.z:1];
                                
							if(!collidesWithPlayer){
                                int type=[World getWorld].hud.blocktype;
                                if(type==TYPE_STONE||type==TYPE_DARK_STONE||type==TYPE_COBBLESTONE||type==TYPE_BRICK||type==TYPE_VINE){
                                    
                                    [[Resources getResources] playSound:S_BUILD_STONE];
                                }else if(type==TYPE_LEAVES){							 
                                    [[Resources getResources] playSound:S_BUILD_LEAVES];	 
                                }else if(blockinfo[type]&IS_LAVA){							 
                                    [[Resources getResources] playSound:S_BUILD_LAVA];	 
                                }else if(blockinfo[type]&IS_WATER){							 
                                    [[Resources getResources] playSound:S_BUILD_WATER];	 
                                }else if(blockinfo[type]&IS_FLAMMABLE&&type!=TYPE_WEAVE&&type!=TYPE_TNT&&type!=TYPE_LADDER&&type!=TYPE_FIREWORK){							 
                                    [[Resources getResources] playSound:S_BUILD_WOOD];	 
                                }else if(type==TYPE_GLASS){
                                    [[Resources getResources] playSound:S_BUILD_GLASS];	
                                }else if(blockinfo[type]&IS_GRASS||type==TYPE_DIRT){
                                    [[Resources getResources] playSound:S_BUILD_DIRT];	
                                }else{
                                    [[Resources getResources] playSound:S_BUILD_GENERIC];	
                                    
                                }
                              //  printf("building: %d,%d,%d\n",point.x,point.y,point.z);
                                if([World getWorld].hud.build_size==1){
								[[World getWorld].terrain buildBlock:point.x:point.z:point.y];
                                }else if([World getWorld].hud.build_size==2){
                                    [[World getWorld].terrain buildBlock:point.x:point.z:point.y];
                                    [[World getWorld].terrain buildBlock:point.x+1:point.z:point.y];
                                    [[World getWorld].terrain buildBlock:point.x:point.z+1:point.y];
                                    [[World getWorld].terrain buildBlock:point.x:point.z:point.y+1];
                                    [[World getWorld].terrain buildBlock:point.x+1:point.z+1:point.y];
                                    [[World getWorld].terrain buildBlock:point.x:point.z+1:point.y+1];
                                    [[World getWorld].terrain buildBlock:point.x+1:point.z:point.y+1];
                                    [[World getWorld].terrain buildBlock:point.x+1:point.z+1:point.y+1];
                                 
                                    
                                }else if([World getWorld].hud.build_size==0){
                                   
                                //    [[World getWorld].terrain buildCustom:point.x:point.z:point.y];
                                   
                                }
							}else{
                                
                                if(pitch<-50&&onground&&!jumping&&![World getWorld].hud.m_jump
                                   &&getLandc2(testpoint.x,testpoint.z,testpoint.y+2)<=0
                                   ){
                                    [World getWorld].hud.m_jump=TRUE;
                                    if([World getWorld].hud.build_size==2)
                                    doublejump=TRUE;
                                    jumpandbuild=TRUE;
                                    buildpoint=point;
                                   // printf("jumping to build\n");
                                }
                            }
							
						}
					}else if(mode==MODE_BURN){
                        if(hitCustom){
                            printf("burning custom??\n");
                        }else
                        printf("burning: %d,%d,%d\n",point.x,point.y,point.z);
						[[Resources getResources] playSound:S_ATTEMPT_FIRE];
                         
						[[World getWorld].terrain burnBlock:point.x	:point.z :point.y];
						if(blockinfo[type]&IS_FLAMMABLE){
							[[Resources getResources] playSound:S_FIRE_SUCCEED];
						}else{
                            [[World getWorld].effects addSmoke:point.x:point.z:point.y];
                        }
					}else if(mode==MODE_MINE){
                       
						if(type!=TYPE_BEDROCK){
							if(type==TYPE_STONE||type==TYPE_DARK_STONE||type==TYPE_COBBLESTONE||type==TYPE_BRICK||type==TYPE_VINE||(type>=TYPE_STONE_RAMP1&&type<=TYPE_STONE_RAMP4)||
                               
                               (type>=TYPE_STONE_SIDE1&&type<=TYPE_STONE_SIDE4)){
								
								[[Resources getResources] playSound:S_BREAK_STONE];
							}else if(type==TYPE_LEAVES){							 
								[[Resources getResources] playSound:S_BREAK_LEAVES];	 
							}else if(blockinfo[type]&IS_LAVA){							 
								[[Resources getResources] playSound:S_BREAK_LAVA];	 
							}else if(blockinfo[type]&IS_WATER){							 
								[[Resources getResources] playSound:S_BREAK_WATER];	 
							}else if(blockinfo[type]&IS_FLAMMABLE){							 
								[[Resources getResources] playSound:S_BREAK_WOOD];	 
							}else if(type==TYPE_GLASS){
                                [[Resources getResources] playSound:S_BREAK_GLASS];	
                            }else if(blockinfo[type]&IS_GRASS||type==TYPE_DIRT||type==TYPE_SAND){
                                 [[Resources getResources] playSound:S_BREAK_DIRT];	
                            }else 
                                 [[Resources getResources] playSound:S_BREAK_GENERIC];	
							//NSLog(@"point: %d %d %d %d",point.x,point.z,point.y,type);
                            if(hitCustom){
                               //[[World getWorld].terrain destroyCustom:point.x:point.z:point.y];
                            }else
                            {
                                printf("removing block: %d %d %d %d\n",point.x,point.z,point.y,type);
                                [[World getWorld].terrain destroyBlock:point.x:point.z:point.y];
                            }
							
						}
					}else if(mode==MODE_PAINT){
                       
                        [[Resources getResources] playSound:S_PAINT_BLOCK];	
                        
                        if(hitCustom){
                           // [[World getWorld].terrain paintCustom:point.x:point.z:point.y:[World getWorld].hud.paintColor];
                        }else
                        {
                            [[World getWorld].terrain paintBlock:point.x:point.z:point.y:[World getWorld].hud.paintColor]; 
                        }
                        
                       
                        
                    }
				}
			}		
			
		}
	}
	const static int cDist=15;
	//const static int minDist=14;
	for(int i=0;i<MAX_TOUCHES;i++){
		if(touches[i].inuse==usage_id&&touches[i].moved){
			if(touches[i].movecam){
				touches[i].moved=FALSE;		
				
                float sx=1;
                float sy=1;
                if(IS_IPAD){
                    sx=2;
                    sy=2;
                }
				int dx=touches[i].pmx-touches[i].mx;
				int dy=touches[i].pmy-touches[i].my;
				if(abs(touches[i].mx-touches[i].fx)>cDist||
				   abs(touches[i].my-touches[i].fy)>cDist){
					touches[i].placeBlock=FALSE;				
				}
				if(abs(touches[i].mx-touches[i].fx)<=cDist&&
				   abs(touches[i].my-touches[i].fy)<=cDist){
					continue;
				}
				
				if(dx!=0){
					if(invertcam)
						yaw+=sx*(float)dx*YAW_SPEED;
					else {
						yaw-=sx*(float)dx*YAW_SPEED;
					}
					
				}
				if(dy!=0){
					//NSLog(@"%f, %f",yaw,pitch);
					if(invertcam)
						pitch+=sy*(float)dy*PITCH_SPEED;
					else
						pitch+=sy*(float)-dy*PITCH_SPEED;
				}				
			}else{
                if(mode==MODE_BUILD){
                    Point3D point=findWorldCoords(touches[i].my,touches[i].mx,FC_PLACE);
                    int type=[[World getWorld].terrain getLand:point.x:point.z:point.y];
                    if([World getWorld].hud.build_size==0){
                        type=[[World getWorld].terrain getLand:point.x/2:point.z/2:point.y/2];
                        
                    }
                    if((type==TYPE_NONE||(type==TYPE_CUSTOM&&[World getWorld].hud.build_size==0)||(blockinfo[type]&IS_LIQUID&&getLevel(type)<4))&&mode==MODE_BUILD){
                        touches[i].preview=point;
                        touches[i].previewtype=[World getWorld].hud.blocktype;
                        touches[i].build_size=[World getWorld].hud.build_size;
                        //touches[i].etime=0;
                        
                    }
                }else{
                    if(mode==MODE_PAINT||mode==MODE_MINE||mode==MODE_BURN){
                        Point3D point=findWorldCoords(touches[i].my,touches[i].mx,FC_DESTROY);
                        if(point.x==-1)continue;
                        if(!hitCustom){
                        if([[World getWorld].terrain getLand:point.x:point.z:point.y]==TYPE_NONE)continue;
                        touches[i].preview=point;
                        touches[i].previewtype=TYPE_CLOUD;
                        touches[i].etime=0;
                            touches[i].build_size=1;
                        }else{
                           /* if(getCustomc(point.x,point.z,point.y)==TYPE_NONE)continue;
                            touches[i].preview=point;
                            touches[i].previewtype=TYPE_CLOUD;
                            touches[i].etime=0; 
                            touches[i].build_size=0;*/
                            
                        }
                        
                        
                        
                    }
                }
			}
            /*if(mode==MODE_PAINT){
                Point3D point=findWorldCoords(touches[i].my,touches[i].mx,FC_DESTROY);
                if(point.x==-1)continue;
                if([[World getWorld].terrain getLand:point.x:point.z:point.y]==TYPE_NONE)continue;
                
                if(speed==0&&hspeed==0)
                [[World getWorld].terrain paintBlock:point.x:point.z:point.y];
            }*/
		}		
	}		
	
}
Vector getFlowDirection(int x,int z,int y){
    Vector dir;
    dir.x=dir.y=dir.z=0;
    int dx[]={-1,1,0,0};
    int dz[]={0,0,1,1};
    
 
    
    if(getBaseType(getLandc(x,z,y+1))==TYPE_WATER)return dir;
    int type=getLandc(x,z,y);
    if(getBaseType(type)!=TYPE_WATER){
        for(int i=0;i<4;i++){
            if(getBaseType(getLandc(x+dx[i],z+dz[i],y))==TYPE_WATER){
                x+=dx[i];
                z+=dz[i];
                break;
            }
        }
        type=getLandc(x,z,y);
        if(getBaseType(type)!=TYPE_WATER)return dir;
    }
    int level=getLevel(type);
    int canflow[4];
    
    int n3=0;
    int n2=0;
    for(int i=0;i<4;i++){
        int ntype=getLandc(x+dx[i],z+dz[i],y);      
        if(getBaseType(ntype)==TYPE_WATER&&getLevel(ntype)<level){            
            canflow[i]=3;         
            n3++;
        }else if(ntype==0){
            canflow[i]=2;
            n2++;
        }else{
            canflow[i]=0;
        }
    }
    
    
    if(n3>0){
        for(int i=0;i<4;i++){
            if(canflow[i]==3){
                dir.x=dx[i];
                dir.z=dz[i];
                return dir;
            }
        }
    }
    if(n2>0){
        for(int i=0;i<4;i++){
            if(canflow[i]==2){
                dir.x=dx[i];
                dir.z=dz[i];
                return dir;
            }
        }
    }
    return dir;
    
    
    
}
//static int once=0;
static  BOOL lastjump;
static float ladderCount=0;
static float walkCount=0;
//static float walkDistance=0;
static BOOL ladderSound=FALSE;
static BOOL ladderIsVine=FALSE;
static BOOL lastOnIce;
- (void)takeDamage:(float)damage{
    life-=damage;
    if(!health_option){
        if(life<.36){
            life=.36f;
        }
    }
    if(life<0){
        dead=TRUE;
        [World getWorld].hud.fade_out=0;
        printf("dead\n");
    }
    
}

-(BOOL) preupdate:(float)etime{
    if(life<0){
        flash=1;
        
    }else
    if(life<1){
        life+=.1*etime;
        flash=1-life;
    }else{
        flash=0;
    }
    
    if(!dead)
        return [self update:etime];
    else
        return TRUE;
}
- (BOOL)update:(float)etime{
  
	//if(etime>1.0f/30.0f)etime=1.0f/30.0f;
    float displacement=etime*sqrt(v_length2(vel));
    if(displacement>.1f&&1.0f/etime<500/*180*/){
        if(v_length2(vel)>JUMP_SPEED*15*JUMP_SPEED*15){
            NormalizeVector(&vel);
            vel=v_mult(vel,JUMP_SPEED*15);
        }
        
        [self update:etime/2.0f];
        [self update:etime/2.0f];
        /*
         */
        return TRUE;
    }
   // NSLog(@"displacement: %f cps:%f",displacement,1/etime);
	static float gravity=GRAVITY;
	[self processInput:etime];
    
    if(yawanimation!=0){
        float dyaw=0;
        float edyaw=YAW_ANIM_SPEED*etime;
        if(yawanimation>0){
            if(yawanimation>edyaw){
                dyaw=edyaw;
                yawanimation-=edyaw;
            }else{
                dyaw=yawanimation;           
                yawanimation=0;
            }
            
            
        }else{
            if(yawanimation<-edyaw){
                dyaw=-edyaw;
                 yawanimation+=edyaw;
            }else{
                dyaw=yawanimation;           
                yawanimation=0;

            }
            
            
        }
        yaw+=dyaw;
        
        
    }
	Hud* hud=[World getWorld].hud;

	speed=hspeed=vspeed=0;	
	if(!hud.use_joystick){
		if(hud.m_fwd){
			
			speed+=MOVE_SPEED;
		}
		if(hud.m_back){
			speed-=MOVE_SPEED;
		}
		hspeed=0;
		if(hud.m_left){
			hspeed-=MOVE_SPEED;		
		}else if(hud.m_right){
			hspeed+=MOVE_SPEED;		
		}
	}else{
		if(hud.m_joy){
            
            if(onIce||!onground){
                speed=walk_force.z*MOVE_SPEED/2;
                hspeed=walk_force.x*MOVE_SPEED/2;
            }else{
			speed=walk_force.z*MOVE_SPEED;
			hspeed=walk_force.x*MOVE_SPEED;
            }
            
		}
	}
    if(climbing){
        vspeed=speed*.66f;
        speed*=.66f;
        hspeed*=.66f;
        if(speed<0){
            speed=-speed;
            //vel.z=-vel.z;
        }
    }else if(onramp){
        speed*=1.38f;
        
            
    } else if(inLiquid){
            float f=speed;
            speed=f*cos(D2R(pitch));
            vspeed=f*sin(D2R(pitch));
            speed*=.66f;
            hspeed*=.66f;

            vspeed*=.66f;
    }else if(FLY_MODE){
        speed*=10;
        hspeed*=10;
    }
    
	
	/*if([World getWorld].hud.mode==MODE_BURN){
	speed=MOVE_SPEED*10;
	vel.y=0;
	[[World getWorld].terrain buildBlock:arc4random()%T_SIZE:arc4random()%T_SIZE:arc4random()%T_HEIGHT];
	[[World getWorld].terrain destroyBlock:arc4random()%T_SIZE:arc4random()%T_SIZE:arc4random()%T_HEIGHT];
	[[World getWorld].terrain burnBlock:arc4random()%T_SIZE:arc4random()%T_SIZE:arc4random()%T_HEIGHT];
	}*/
	/*if(once<=0){
	for(int i=0;i<10000;i++){
		[[World getWorld].terrain buildBlock:arc4random()%T_SIZE:arc4random()%T_SIZE:arc4random()%T_HEIGHT];
		
	}
		once++;
	}*/
	
	if(yaw>=360)yaw-=360;
	if(yaw<=-360)yaw+=360;
	if(pitch<=-80)pitch=-80;
	if(pitch>=80)pitch=80;
	//NSLog(@"yaw: %f",yaw);
	float cosYaw=cos(D2R(yaw));
	float sinYaw=sin(D2R(yaw));
	float cosYaw90=cos(D2R(yaw+90));
	float sinYaw90=sin(D2R(yaw+90));
	//float sinPitch=2*sin(D2R(pitch));	
	accel.x=cosYaw*speed;
	accel.z=sinYaw*speed;	
	accel.x+=cosYaw90*hspeed;
	accel.z+=sinYaw90*hspeed;
    if(!onIce&&!inLiquid&&!climbing&&onground&&speed>hspeed){
        int x=pos.x+cosYaw*1.25f;
        int z=pos.z+sinYaw*1.25f;
        int y=pos.y-boxheight/2+.01;
        int type=getLandc2(x,z,y);
        if(autojump_option&&onground&&!jumping&&![World getWorld].hud.m_jump&&type!=TYPE_NONE&&type!=TYPE_LADDER&&type!=TYPE_VINE&&type!=TYPE_LAVA&&type!=TYPE_GOLDEN_CUBE&&type>0&&!(type>=TYPE_STONE_RAMP1&&type<=TYPE_ICE_SIDE4)&&!(blockinfo[type]&IS_WATER)&&getLandc2(x,z,y+1)<=0){
            
            if(getLandc2(x,z,y+2)<=0&&getLandc2(pos.x,pos.z,pos.y+2)<=0&&speed>18){
               hud.m_jump=TRUE;
               // printf("speed:%f",speed);
            }
        }
            
    }
    if(hud.m_jump||doublejump)
	{
		if ((lastjump!=TRUE && !jumping)||climbing){
            if(doublejump){
                if(vel.y<JUMP_SPEED*2){
                    vel.y=JUMP_SPEED*2;
                }
                doublejump=FALSE;
            }else
            if(vel.y<JUMP_SPEED)
                vel.y=JUMP_SPEED;
            if(onground){
                vel.x*=.9;
                vel.z*=.9;
            }
			jumping=TRUE;
            climbing=FALSE;
		}
		
	}
    lastjump=jumping;

    accel.y=0;
    
    if(v_length2(vel)>max_walk_speed*max_walk_speed){
        if(jumping){
            if(sign(vel.x)==sign(accel.x))
            accel.x=0;
            if(sign(vel.z)==sign(vel.z))
            accel.z=0;
        }else if(!onIce&&onground&&max_walk_speed!=0){
        NormalizeVector(&vel);
        vel.x*=max_walk_speed;
        vel.z*=max_walk_speed;
        vel.y*=max_walk_speed;
        }
       // NSLog(@"vlength: %f, max_walk %f",sqrt(v_length2(vel)),max_walk_speed);
    }
        
        
   
    
    if(!onIce&&(onground||climbing)){
        vel.x*=.90;
       vel.z*=.90;
    }else if(onIce&&onground){
        vel.x*=.99;
        vel.z*=.99;
    }else if(inLiquid){
        vel.x*=.95;
        vel.z*=.95;
        
        Vector flowdir=getFlowDirection(pos.x,pos.z,pos.y-boxheight/2+.01);
       // printf("flowdir (%f,%f)\n",flowdir.x,flowdir.z);
        vel.x+=flowdir.x*FLOW_SPEED*etime;
        vel.z+=flowdir.z*FLOW_SPEED*etime;
        
    }else if(FLY_MODE){
        vel.x*=.995;
        vel.z*=.995;
    }
    
	//if(sinPitch*speed>0)vy=sinPitch*speed;
    if(climbing){
       
        accel.y+=vspeed;
        if(accel.y==0||sign(accel.y)!=sign(vel.y)){
            vel.y=0+sign(vel.y)/1000.0f;
        }
        if(absf(vel.y)>0.5f){
            ladderCount+=etime;
            if(ladderCount>=.4f){
                ladderCount=0;
                if(ladderSound){
                    //NSLog(@"1");
                    if(ladderIsVine)
                        [[Resources getResources] playSound:S_VINE];
                    else
                    [[Resources getResources] playSound:S_LADDER];
                }else{
                   // NSLog(@"2");
                    if(ladderIsVine)
                        [[Resources getResources] playSound:S_VINE];
                    else
                        [[Resources getResources] playSound:S_LADDER];
                }
                ladderSound=!ladderSound;
                    
            }
        }else{
            ladderCount=0;
            if(accel.y>0)ladderSound=TRUE;
            else ladderSound=FALSE;
        }
    }
    else if(inLiquid){
       
        accel.y+=vspeed;
        accel.y+=gravity/3;
    
        if(vel.y>JUMP_SPEED/4)
        vel.y=JUMP_SPEED/4;
        if(vel.y<-JUMP_SPEED*2)
            vel.y=-JUMP_SPEED*2;
    }else if(FLY_MODE){
        vel.y=0;
        if(FLY_UP){
            vel.y+=JUMP_SPEED*3;
            
        }if (FLY_DOWN) {
            vel.y+=-JUMP_SPEED*3;
            
        }
    }
    else{
        if(onground)
            accel.y+=-gravity/2;
        else
            accel.y+=-gravity;
    }
    //if(!v_equals(pos,lpos)){
        //player pos log
    //    printf("player pos: %f, %f, %f\n",pos.x,pos.z,pos.y);
    //}
	
	lpos.x=pos.x;
	lpos.y=pos.y;
	lpos.z=pos.z;
	[self move:etime];
    if([World getWorld].terrain.tgen.LEVEL_SEED==DEFAULT_LEVEL_SEED){
        if(pos.x<4096*CHUNK_SIZE-GSIZE/2){
           pos.x=4096*CHUNK_SIZE-GSIZE/2;
        }else if(pos.x>=4096*CHUNK_SIZE+GSIZE/2){
            pos.x=4096*CHUNK_SIZE+GSIZE/2;
        }
        
        if(pos.z<4096*CHUNK_SIZE-GSIZE/2){
            pos.z=4096*CHUNK_SIZE-GSIZE/2;
        }else if(pos.z>=4096*CHUNK_SIZE+GSIZE/2){
            pos.z=4096*CHUNK_SIZE+GSIZE/2;
        }
    }
    updateSkyColor(self);
	//NSLog(@"%f %f %f",pos.x,pos.y,pos.z);
	
	Camera* cam=world.cam;
	cam.px=pos.x;
	cam.py=pos.y+3*boxheight/10;
	cam.pz=pos.z;
	cam.yaw=yaw;
	cam.pitch=pitch;
    
	cam.mode=0;
	//NSLog(@"%d %d %d",pos.x,pos.y,pos.z);
	if(THIRD_PERSON){
	cam.pitch=0;
	cam.mode=1;
	}
	
	itouch* touches=[[Input getInput] getTouches];
	for(int i=0;i<MAX_TOUCHES;i++){
		if(touches[i].inuse==usage_id&&
		   touches[i].down==M_DOWN&&
		   touches[i].placeBlock&&
		   touches[i].previewtype!=TYPE_NONE){
			
		   touches[i].etime+=etime;
			
		}
		
	}
    if([World getWorld].hud.underLiquid){
        [[Resources getResources] soundEvent:AMBIENT_UNDERWATER];
    }else if(pos.y>T_HEIGHT-9){
        Vector v=pos;
        v.y=T_HEIGHT-1;
        [[Resources getResources] soundEvent:AMBIENT_SKYHIGH:v];
    }else{
        int x=pos.x;
        int z=pos.z;    
        int y=pos.y;
        Vector spos;
        for(int h=-1;h<=2;h++){
            for(int size=0;size<8;size++){
                for(int xx=x-size;xx<=x+size;xx++){
                    for(int zz=z-size;zz<=z+size;zz++){
                        
                        int type=getLandc2(xx,zz,y+h);
                        if(type>=0&&((blockinfo[type]&IS_WATER)||blockinfo[type]&IS_LAVA)){
                            //  foundWater=TRUE;
                            spos.x=xx+.5f;
                            spos.y=y+h+.5f;
                            spos.z=zz+.5f;
                            if(blockinfo[type]&IS_WATER){
                                 [[Resources getResources] soundEvent:AMBIENT_RIVER:spos];
                            }else{
                                [[Resources getResources] soundEvent:AMBIENT_LAVA:spos];
                            }
                            goto found;
                        }//else 
                        // [World getWorld].terrain setColor:x,z,y+h)
                    }
                }
            }
        }
        if(pos.y<15){
            Vector v=pos;
            v.y=6;
            [[Resources getResources] soundEvent:AMBIENT_CAVE:v];
        }else         
         [[Resources getResources] soundEvent:AMBIENT_OPEN];
    found:
        ;
    }
	return FALSE;
}

BOOL endClimb=FALSE;



static BOOL lastInLiquid;


BOOL hitLadder=FALSE;
BOOL ladderExists=FALSE;
extern Vector colorTable[256];
extern Vector tranDist;
//extern Vector minTranDist;
extern const GLubyte blockColor[NUM_BLOCKS+1][3];
- (BOOL)vertc{
    nest_count++;
    if(nest_count>10)return false;
	Terrain* ter=world.terrain;
    float bot=pos.y-boxheight/2;
	float top=pos.y+boxheight/2;
	float left=pos.x-boxbase/2;
	float right=pos.x+boxbase/2;
	float front=pos.z-boxbase/2;
	float back=pos.z+boxbase/2;
    
    pbox=makeBox(left,right,back,front,bot,top);
    if(nest_count==1){
        hitLadder=FALSE;
        ladderExists=FALSE;
    }
        
    for(int x=(int)left-1;x<=(int)right+1;x++){
        for(int z=(int)front-1;z<=(int)back+1;z++){
            for(int y=(int)bot-1;y<=(int)top+1;y++){
                int type=getLandc2(x,z,y);
                if(type<=0)continue;
                if(type==TYPE_LADDER||
                  type==TYPE_VINE){
                    ladderExists=TRUE;
                    
                }
               // [ter updateChunks:x :z :y :TYPE_GRASS];
                
            }
        }
    }
    
  Vector minminTranDist=MakeVector(0,0,0);
    int collided=0;
    for(int x=(int)left;x<=(int)right;x++){
        for(int z=(int)front;z<=(int)back;z++){
            for(int y=(int)bot;y<=(int)top;y++){
                int type=getLandc2(x,z,y);
                if(type<=0)continue;
                
                int bleft=x;
				int bright=x+1;
				int bfront=z;
				int bback=z+1;
                int bbot=y;
                int btop=y+1;
                Polyhedra pbox2;
                if(type>=TYPE_STONE_RAMP1&&type<=TYPE_ICE_RAMP4){
                   
                    pbox2=makeRamp(bleft,bright,bback,bfront,bbot,btop,type%4);
                   // NSLog(@"yop");
                    
                }else if(type>=TYPE_STONE_SIDE1&&type<=TYPE_ICE_SIDE4){
                    pbox2=makeSide(bleft,bright,bback,bfront,bbot,btop,type%4);
                    
                }else if(blockinfo[type]&IS_LIQUID){
                    pbox2=makeBox(bleft,bleft+1,bback,bfront,bbot,bbot+getLevel(type)/4.0f);
                }else
                pbox2=makeBox(bleft,bright,bback,bfront,bbot,btop);
               /* int cx=x/CHUNK_SIZE;
                int cy=y/CHUNK_SIZE;
                int cz=z/CHUNK_SIZE;
                
                TerrainChunk* chunk;
                hashmap_get([World getWorld].terrain.chunkMap, threeToOne(cx,cy,cz),(any_t)&chunk);
                if(!chunk){
                    continue;                    
                }
                int vis=[chunk getVisibility:x :y :z];
                for(int f=0;f<6;f++){                    
                    if(vis&(1<<f)){
                        pbox2.faces[f].sharedface=true;
                    }else{
                        pbox2.faces[f].sharedface=false; 
                       // NSLog(@"a;sdkfj");
                    }
                }
                Vector bp;
                bp.x=bleft+.5f;
                bp.z=bfront+.5f;
                bp.y=bbot+.5f;
                bp.x-=pos.x;
                bp.y-=pos.y;
                bp.z-=pos.z;*/
               /* if(fabs(bp.x) <= (boxbase/2 + .5f)
                &&                
                fabs(bp.y) <= (boxheight/2 + .5f)                
                &&                
                fabs(bp.z) <= (boxbase/2 + .5f))*/
                
                if(collidePolyhedra(pbox,pbox2)){
                    if(type==TYPE_LADDER||type==TYPE_VINE){
                        if(accel.x!=0||vspeed!=0||accel.z!=0)
                        hitLadder=TRUE;
                        
                    }
                    if(blockinfo[type]&IS_WATER){
                        if(!lastInLiquid&&minTranDist.y>0&&vel.y<-5){
                            lastInLiquid=TRUE;
                            if(vel.y<-8)
                            [[Resources getResources] playSound:S_SPLASH_BIG];
                            else
                            [[Resources getResources] playSound:S_SPLASH_SMALL];
                        }
                        inLiquid=TRUE;
                        int color=[ter getColor:x :z :y];
                        Vector clr=colorTable[color];
                        if(color==0){
                            
                                clr.x=(float)blockColor[TYPE_WATER][0]/255;
                            clr.y=(float)blockColor[TYPE_WATER][1]/255;
                            clr.z=(float)blockColor[TYPE_WATER][2]/255;
                        }
                        [World getWorld].hud.liquidColor=clr;
                        continue;
                    }else if(type==TYPE_GOLDEN_CUBE){
                        
                        [World getWorld].hud.goldencubes++;
                        [World getWorld].hud.flash=.95f;
                        int coli=[[World getWorld].terrain getColor:x :z:y];
                        if(coli==0)
                            [World getWorld].hud.flashcolor=MakeVector(blockColor[TYPE_GOLDEN_CUBE][0]/255.0f,blockColor[TYPE_GOLDEN_CUBE][1]/255.0f,blockColor[TYPE_GOLDEN_CUBE][2]/255.0f);
                            else
                        [World getWorld].hud.flashcolor=colorTable[coli];
                        [[World getWorld].terrain updateChunks:x:z:y:TYPE_NONE];
                    }else if(type==TYPE_FLOWER){
                        continue;
                    }else if(blockinfo[type]&IS_DOOR){
                        continue;
                    }else if(blockinfo[type]&IS_PORTAL){
                        if(absf(v_length2(minTranDist)>.000000000001)){
                            float eps=.000000000001;
                            int pt=type;
                            if(type==TYPE_PORTAL_TOP){
                                pt=getLandc2(x,z,y-1);
                            }
                            
                            if(pt== TYPE_PORTAL1&&minTranDist.z<-eps){
                                continue;
                            }else if(pt==TYPE_PORTAL2&&minTranDist.x>eps){
                                continue;
                            }else if(pt==TYPE_PORTAL3&&minTranDist.z>eps){
                                continue;
                            }else if(pt==TYPE_PORTAL4&&minTranDist.x<-eps){
                                continue;
                            }
                     //   printf("mtd: (%f, %f, %f) pt: %d\n",minTranDist.x,minTranDist.y,minTranDist.z,pt);
                        }
                       // continue;
                    }

                    if(v_length2(minTranDist)>v_length2(minminTranDist)){
                        if(type>=TYPE_STONE_RAMP1&&type<=TYPE_ICE_RAMP4){
                            
                           // NSLog(@"points: %d   faces:%d",pbox2.n_points,pbox2.n_faces);
                        }
                       
                        
                        collided=type;
                        minminTranDist=minTranDist;
                    }
                    
                    
               // [ter updateChunks:x :z :y :TYPE_CRYSTAL];
                                   }
            }
        }
    }
    
    
    if(collided){
        
       
        
        if(minminTranDist.y>0){
            if(collided==TYPE_ICE||(collided>=TYPE_ICE_RAMP1&&collided<=TYPE_ICE_RAMP4)||(collided>=TYPE_ICE_SIDE1&&collided<=TYPE_ICE_SIDE4)){
                onIce=TRUE;
            }
        }
        
        
      
          pos=v_add(pos,minminTranDist);     
        Vector normal=minminTranDist;
        NormalizeVector(&normal);
        float n=dotProduct(vel,normal);
        
      //  NSLog(@"before-vel:(%f,%f,%f)  normal:(%f,%f,%f) dotp: %f",vel.x,vel.y,vel.z,normal.x,normal.y,normal.z,n);
        if(blockinfo[collided]&IS_LAVA){
            
            [self takeDamage:.08f];
            n*=1.8;
            
            [[Resources getResources] playSound:S_LAVA_BURN];	
            NSLog(@"n:%f",n);
            if(minminTranDist.y>0){
                if(n>-10&&n<0)n=-5;
                jumping=false;
            }
        }
        if(collided==TYPE_TRAMPOLINE){
            n*=2;
              [[Resources getResources] playSound:S_BOUNCE];	
            NSLog(@"n:%f vel.y:%f",n,vel.y);

            if(minminTranDist.y>0){
                
                 if(n>-12&&n<0)n=-6;
                jumping=false;
            }
        }
        
        Vector vel2=v_mult(normal,n);
        
       // if(!onIce&&!lastOnIce){
            vel=v_sub(vel,vel2);
        
           // NSLog(@"after-vel:(%f,%f,%f)  vel2:(%f,%f,%f)",vel.x,vel.y,vel.z,vel2.x,vel2.y,vel2.z);
       // }
        if(minminTranDist.y>0&&(vel.y<=0||(collided>=TYPE_STONE_RAMP1&&collided<=TYPE_ICE_RAMP4))){
            
            if(collided>=TYPE_STONE_RAMP1&&collided<=TYPE_ICE_RAMP4){
                if(collided>=TYPE_ICE_RAMP1&&collided<=TYPE_ICE_RAMP4){
                    //onIce=TRUE;
                    //onIceRamp=TRUE;
                }
                if(absf(lpos.y-pos.y)<.1||(collided<TYPE_ICE_RAMP1||collided>TYPE_ICE_RAMP4)){
                    if(!onIce){
                        onramp=TRUE;
                        //NSLog(@"hit");
                       // vel.y=0;
                        onground=true;
                        
                    }
                    
                }
                    
                
            }else{
                if(!onIce){
                    //NSLog(@"t.t2");
                   // vel.y=0;
                    onground=true;
                }
                
            }
            if(climbing){
                climbing=FALSE;
                endClimb=TRUE;
            }
     
             
            if(jumping||vel.y<-1.0f){
                if(collided==TYPE_STONE||collided==TYPE_DARK_STONE||
                   collided==TYPE_WOOD||collided==TYPE_LADDER||
                   collided==TYPE_VINE||collided==TYPE_CRYSTAL||
                   collided==TYPE_COBBLESTONE||collided==TYPE_BRICK||
                   collided==TYPE_TREE||collided==TYPE_TNT||
                   collided==TYPE_FIREWORK||collided==TYPE_BEDROCK||
                   (blockinfo[collided]&IS_RAMPORSIDE)) {
                    if(!(blockinfo[collided]&IS_ICE)){
              [[Resources getResources] playSound:S_LAND_HARD];	
                    }else{
                     [[Resources getResources] playSound:S_LAND_SOFT];
                    }
                }
              jumping=FALSE;
            }
        }
       
       
      
        //pbox=makeBox(left,right,back,front,bot,top);
        [self vertc];
        nest_count--;
        
    }
    if(nest_count==1){
    if((climbing&&vspeed!=0&&!hitLadder)||ladderExists==FALSE){
        if(climbing&&!ladderExists&&vspeed>0){
            // vel.y=GRAVITY*-0.2f;
            NSLog(@"dismount");
        }
        climbing=FALSE;
        
        
    }
    
    if(!endClimb&&hitLadder){
       // NSLog(@"hitladder");
        if(speed<0&&!climbing)
            climbing=FALSE ;
        else if(!inLiquid){
            if(collided==TYPE_VINE)ladderIsVine=TRUE;
            else
                ladderIsVine=FALSE;
            climbing=TRUE;
        }
    }
    endClimb=FALSE;
    }
    
	return collided;
    
    /*
	int bh=(int)floorf(bot/BLOCK_SIZE);
	int th=(int)floorf(top/BLOCK_SIZE);
   
	
	left=pos.x-boxbase/2;
	right=pos.x+boxbase/2;
	front=pos.z-boxbase/2;
	back=pos.z+boxbase/2;
	float ddirx[4]={
        left,right,right,left
    };
	int underBlocksx[4];
	int underBlocksz[4];
	underBlocksx[0]=(int)(left);
	underBlocksz[0]=(int)(front);
	underBlocksx[1]=(int)(right);
	underBlocksz[1]=(int)(front);
	underBlocksx[2]=(int)(right);
	underBlocksz[2]=(int)(back);
	underBlocksx[3]=(int)(left);
	underBlocksz[3]=(int)(back);
	const float PUSH=boxbase/4;
	left+=PUSH;
	right-=PUSH;
	front+=PUSH;
	back-=PUSH;
	int overBlocksx[4];
	int overBlocksz[4];
	overBlocksx[0]=(int)roundf(left/BLOCK_SIZE-.5f);
	overBlocksz[0]=(int)roundf(front/BLOCK_SIZE-.5f);
	overBlocksx[1]=(int)roundf(right/BLOCK_SIZE-.5f);
	overBlocksz[1]=(int)roundf(front/BLOCK_SIZE-.5f);
	overBlocksx[2]=(int)roundf(right/BLOCK_SIZE-.5f);
	overBlocksz[2]=(int)roundf(back/BLOCK_SIZE-.5f);
	overBlocksx[3]=(int)roundf(left/BLOCK_SIZE-.5f);
	overBlocksz[3]=(int)roundf(back/BLOCK_SIZE-.5f);
	
//	int mx=(int)nearbyintf(pos.x/BLOCK_SIZE-.5f);
	//int mz=(int)nearbyintf(pos.z/BLOCK_SIZE-.5f);
	
	if(vel.y<0){
		
		for(int i=0;i<4;i++){	
			
            int type=[ter getLand:underBlocksx[i] :underBlocksz[i] :bh];
            int type2=[ter getLand:underBlocksx[i] :underBlocksz[i] :bh+1];
            if(type2==TYPE_WATER||type2==TYPE_LAVA)inLiquid=TRUE;
			if(type<=0||(type2>0&&type2!=TYPE_WATER&&type2!=TYPE_LAVA)){
			   // NSLog(@"dcvc(%d,%f)",[ter getLand:overBlocksx[i] :overBlocksz[i] :bh],vel.y);

				continue;
			}
            if(type==TYPE_WATER||type==TYPE_LAVA){
                inLiquid=TRUE;
                continue;
            }
            float h=BLOCK_SIZE*(bh+1);
			//[ter setLand:underBlocksx[i] :underBlocksz[i] :bh :STONE];
            if(type>=TYPE_STONE_RAMP1&&type<=TYPE_ICE_RAMP4){
               // float rtop=h;
                float rbot=bh;
                float pct=ddirx[i]-underBlocksx[i];
                if(pct<0)pct=0;
                if(pct>1)pct=1;
                
                h=rbot+pct;
                
                NSLog(@"bot:%f  rbot:%f h:%f",bot,rbot,h);
               
            }
				
			//NSLog(@"%f %f",bot,h);
			if(pos.y-boxheight/2<=h&&((lpos.y-boxheight/2)>=h)||(type>=TYPE_STONE_RAMP1&&type<=TYPE_ICE_RAMP4)){
				if(jumping){
					[[Resources getResources] playSound:SOUND_LAND];			
				}
				jumping=FALSE;
                //NSLog(@"vc(%d,%f)",i,vel.y);

                if(climbing){
                    climbing=FALSE;
                    endClimb=TRUE;
                }
				pos.y+=h-(pos.y-boxheight/2)+.001f;
				//	NSLog(@"vel.y:%f",vel.y);
				bot=pos.y-boxheight/2;
				vel.y=0;
				break;
			}		
		}
	}else{
		 

		for(int i=0;i<4;i++){	
            int type2=[ter getLand:underBlocksx[i] :underBlocksz[i] :bh];
            if(type2==TYPE_WATER||type2==TYPE_LAVA){
                inLiquid=TRUE;
            }
            
            int type=[ter getLand:overBlocksx[i] :overBlocksz[i] :th];
			if(type>0){
				if(type2==TYPE_WATER||type2==TYPE_LAVA){
                    inLiquid=TRUE;
                    continue;
                }
				float h=BLOCK_SIZE*(th);	
				if(top>=h&&lpos.y+boxheight/2<=h){
					
					pos.y=lpos.y;
					
					//NSLog(@"vel.y:%f",vel.y);
					top=pos.y+boxheight/2;
					vel.y=0;
					break;
				}		
			}
			
		}
	}*/
	
	
}

- (void)horizc{/*
	int bx=(int)roundf(pos.x/BLOCK_SIZE-.5f);
	int bz=(int)roundf(pos.z/BLOCK_SIZE-.5f);
	Terrain* ter=world.terrain;
	float left=pos.x-boxbase/2;
	float right=pos.x+boxbase/2;
	float front=pos.z-boxbase/2;
	float back=pos.z+boxbase/2;
	float bot=pos.y-boxheight/2;
	int bh=(int)floorf(bot/BLOCK_SIZE);
	BOOL hitLadder=FALSE;
    BOOL ladderExists=FALSE;
	for(int k=0;k<2;k++){
		int ih=bh+k;//[ter getHeight:bx :bz];
		for(int i=0;i<3;i++){
			for(int j=0;j<3;j++){
				int cx=i+bx-1;
				int cz=j+bz-1;
                int type=[ter getLand:cx :cz :ih];
				if(type<=0)continue;
                if(type>=TYPE_STONE_RAMP1&&type<=TYPE_ICE_RAMP4)continue;
				float bleft=cx*BLOCK_SIZE;
				float bright=(cx+1)*BLOCK_SIZE;
				float bfront=cz*BLOCK_SIZE;
				float bback=(cz+1)*BLOCK_SIZE;
				//if(i==1&&j==0)
				
				//else
			//	[ter setLand:cx :cz :ih :SAND];
				if(
				   (
					(left<bleft&&bleft<right)  || (right>bright&&bright>left))&&back>bfront&&front<bback
				   ||(
					  (front<bfront&&bfront<back)||(back>bback&&bback>front))&&right>bleft&&left<bright)
				{
                    if(type==TYPE_LADDER||
                       type==TYPE_VINE){
                        hitLadder=TRUE;
                        
                    }
                    if(type==TYPE_WATER||type==TYPE_LAVA){
                        inLiquid=TRUE;
                        continue;
                    }

                  // NSLog(@"truedog %f",pos.y);					if(i==1&&j==1)
						assert("Zomg wtf");
					//[ter setLand:cx :cz :ih :BEDROCK];
					
					if(i!=1&&j!=1){
						int idx=-1;					
						float min=0;
						float mmin=999;					
						min=absf(pos.z-(bz*BLOCK_SIZE+boxbase/2));	
                        int type=[ter getLand:cx :cz+1 :ih];
						if(j==0&&min<mmin&&type<=0&&type!=TYPE_WATER&&type!=TYPE_LAVA){idx=0; mmin=min;}			
                        type=[ter getLand:cx :cz-1 :ih];
						min=absf(pos.z-((bz+1)*BLOCK_SIZE-boxbase/2));
						if(j==2&&min<mmin&&&type<=0&&type!=TYPE_WATER&&type!=TYPE_LAVA){idx=1; mmin=min;}
                        type=[ter getLand:cx+1 :cz :ih];
						min=absf(pos.x-(bx*BLOCK_SIZE+boxbase/2));
						if(i==0&&min<mmin&&&type<=0&&type!=TYPE_WATER&&type!=TYPE_LAVA){idx=2; mmin=min;}
                        type=[ter getLand:cx-1 :cz :ih];
						min=absf(pos.x-((bx+1)*BLOCK_SIZE-boxbase/2)); 
						if(i==2&&min<mmin&&&type<=0&&type!=TYPE_WATER&&type!=TYPE_LAVA){idx=3; mmin=min;}
						
						
						if(idx==0)     pos.z=bz*BLOCK_SIZE+boxbase/2;
						else if(idx==1)pos.z=(bz+1)*BLOCK_SIZE-boxbase/2;
						else if(idx==2)pos.x=bx*BLOCK_SIZE+boxbase/2;
						else if(idx==3)pos.x=(bx+1)*BLOCK_SIZE-boxbase/2;  
                        
                       					}
					if(i==1){			
                       

						if(j==0)
							pos.z=bz*BLOCK_SIZE+boxbase/2;
						else if(j==2)
							pos.z=(bz+1)*BLOCK_SIZE-boxbase/2;
					} 
					if(j==1){
                       
						if(i==0)
							pos.x=bx*BLOCK_SIZE+boxbase/2;
						else if(i==2)
							pos.x=(bx+1)*BLOCK_SIZE-boxbase/2;  
					}
				}
				
				
			}
		}
		
		
	}
    if((climbing&&vspeed!=0&&!hitLadder)||ladderExists==FALSE){
        if(climbing&&!ladderExists&&vspeed>0){
           // vel.y=GRAVITY*-0.2f;
            NSLog(@"dismount");
        }
        climbing=FALSE;
         NSLog(@"drop like its hot");
       
    }
   
    if(!endClimb&&hitLadder){
       
        if(speed<0&&!climbing)
           climbing=FALSE ;
        else if(!inLiquid)
        climbing=TRUE;
    }
    endClimb=FALSE;
    */
}
-(BOOL) checkCollision{
    int bx=(int)roundf(pos.x/BLOCK_SIZE-.5f);
	int bz=(int)roundf(pos.z/BLOCK_SIZE-.5f);
	Terrain* ter=world.terrain;

	float bot=pos.y-boxheight/2;
	int bh=(int)floorf(bot/BLOCK_SIZE);
	for(int k=0;k<2;k++){
		int ih=bh+k;//[ter getHeight:bx :bz];
		for(int i=0;i<3;i++){
			for(int j=0;j<3;j++){
				int cx=i+bx-1;
				int cz=j+bz-1;
				if([ter getLand:cx :cz :ih]<=0){continue;}
                
               
                return TRUE;
				
				
			}
		}
		
		
	}
   
    return FALSE;

}
-(void)groundPlayer{
    while(![self checkCollision]&&pos.y>=0){
        pos.y-=1;
    }
    while([self checkCollision]&&pos.y<=100){
        pos.y+=1;
    }
}
static int icesound=0;
- (void)move:(float)etime{
    
//	Terrain* ter=world.terrain;
	
	
	BOOL last=lastInLiquid=inLiquid;
    lastOnIce=onIce;
	inLiquid=FALSE;
    onIce=FALSE;
    [World getWorld].hud.underLiquid=FALSE;
    
    Vector lvel=vel;
    vel.x+=accel.x*etime;
    vel.y+=accel.y*etime;
    vel.z+=accel.z*etime;
  //  NSLog(@"vel(%f,%f,%f) acc(%f,%f,%f)",vel.x,vel.y,vel.z,accel.x,accel.y,accel.z);

    if(climbing&&vel.y>CLIMB_SPEED)vel.y=CLIMB_SPEED;
    if(climbing&&vel.y<-CLIMB_SPEED)vel.y=-CLIMB_SPEED;
    if(climbing){
        if(vel.x>.30f)vel.x=.30f;
        if(vel.z>.30f)vel.z=.30;
        if(vel.x<-.30f)vel.x=-.30f;
        if(vel.z<-.30f)vel.z=-.30f;
       // NSLog(@"vel.y: %f",vel.y);
    }
    if(onground){
        if(absf(vel.x)>.1f||absf(vel.z)>.1f)
        walkCount+=etime;
        float vv2=sqrtf(vel.x*vel.x+vel.z*vel.z);
        //printf("(%f,%f)\n",vv2,vel.z);
        if(walkCount>.35+(6.0f-vv2)/12.0f){
            
          
            int x=pos.x;
            int z=pos.z;
            int y=pos.y-boxheight/2+.01;
            int collided=getLandc2(x,z,y-1);
            
            if(collided==TYPE_STONE||collided==TYPE_DARK_STONE||
               collided==TYPE_WOOD||collided==TYPE_LADDER||
               collided==TYPE_VINE||collided==TYPE_CRYSTAL||
               collided==TYPE_COBBLESTONE||collided==TYPE_BRICK||
               collided==TYPE_TREE||collided==TYPE_TNT||collided==TYPE_FIREWORK||collided==TYPE_BEDROCK||(blockinfo[collided]&IS_RAMPORSIDE))    {
                if(!blockinfo[collided]&IS_ICE)
                    [[Resources getResources] playSound:S_FOOTSTEPS_HARD];
                else
                    [[Resources getResources] playSound:S_FOOTSTEPS_SOFT];
                
            }
           
            walkCount=0;

        }
        /*if(absf(vel.x)<.0001)vel.x=0;
        if(absf(vel.z)<.0001)vel.z=0;
        if(vel.y<-.0000000000001){
            vel.y=-.001;
             //NSLog(@"STOP RIGHT THERE");
        }*/
        
       
        
    }
       
    
    float mag=0;
    mag=sqrt(v_length2(vel));
   // NSLog(@"speed: %f, hspeed: %f",accel.z, hspeed);
    extern int flamecount;
    // BURN FLY if(flamecount%2==0)vel.y=0;
	pos.y+=vel.y*etime;
    pos.x+=vel.x*etime;
	pos.z+=vel.z*etime;
    nest_count=0;
    onground=FALSE;
    onramp=FALSE;
    [self vertc];
   // if(onground)NSLog(@"grounded sucka");
    if(!onIce&&lastOnIce){
        [[Resources getResources] stopSound:icesound];
    }
    if((vel.x!=0||vel.z!=0)&&(onIce)){
        Vector vdir=vel;
        Vector volddir=lvel;
        vdir.y=0;
        volddir.y=0;
        NormalizeVector(&vdir);
        NormalizeVector(&volddir);
        Vector crossp=crossProduct(vdir,volddir);
        
        if(absf(absf(crossp.y)-.707107f)<.00001f){
            if(crossp.y>0)yawanimation+=45;
            else yawanimation-=45;
            
        }
        if(yawanimation>360)yawanimation-=360;
        if(yawanimation<-360)yawanimation+=360;
        
        
    }
    if(mag!=0&&onIce){
        if(!lastOnIce){
            [[Resources getResources] stopSound:icesound];
            icesound=[[Resources getResources] playSound:S_ICE_LOOP];
            lastOnIce=TRUE;
        }
        //Vector dir=v_sub(pos,lpos);
        float dp=dotProduct(lvel,vel);
        if(dp>0){
        NormalizeVector(&vel);
        vel.x*=mag;
        vel.z*=mag;
        vel.y*=mag;
        //vel=dir;
        }else{
             //vel=v_div(v_sub(pos,lpos),etime);
        }
       // NSLog(@"icy");
        //if(!onground)NSLog(@"wtf");
    }else if(!onground){
       /* Vector vel2=v_div(v_sub(pos,lpos),etime);
        if(v_length2(vel2)<v_length2(vel)){
            vel=vel2;
        }*/
       // if(onground)
       
    }else{
        if(onground&& accel.x==0&&accel.z==0&&v_length2(v_sub(pos,lpos))<.002&&mag<2){
            pos=lpos;
            vel.x=0;
            vel.z=0;
            vel.y=0;
           // NSLog(@"stopping"); 
        }
       // 
    }
	//[self horizc];
    if(last){
        jumping=FALSE;
    }
    float cosYaw=cos(D2R(yaw));
	float sinYaw=sin(D2R(yaw));
	
	Vector dirv;

	dirv.x=cosYaw;
	dirv.z=sinYaw;	
    //  NormalizeVector(&blah);
    int type=[[World getWorld].terrain getLand:pos.x 
                                              :pos.z 
                                              :pos.y+boxbase/2];
    if(blockinfo[type]&IS_WATER){
        [World getWorld].hud.underLiquid=TRUE;
    }
   
    if(type==TYPE_PORTAL_TOP){
        if(!inPortal){
            inPortal=TRUE;
            printf("entering portal (%d, %d, %d)  ", (int)pos.x,(int)(pos.y+boxbase/2),(int)pos.z);
            
            Vector2 ret=[[World getWorld].terrain.portals enterPortal:pos.x 
                                             :pos.y+boxbase/2 
                                                                     :pos.z:vel];
            
            [World getWorld].hud.flash=1;
            int color=[[World getWorld].terrain getColor:pos.x
                                             :pos.z
                                             :pos.y+boxbase/2];
            
            if(color==0){
                [World getWorld].hud.flashcolor=MakeVector(1.0,1.0,1.0);
            }else
            [World getWorld].hud.flashcolor=colorTable[color];
            
            pos.x=ret.x;
            pos.y=ret.y;
            pos.z=ret.z;
            vel.x=ret.x2;
            vel.y=ret.y2;
            vel.z=ret.z2;
            printf("exiting at:(%d, %d, %d) \n",(int)pos.x,(int)(pos.y+boxbase/2),(int)pos.z);
            
        }
    }else inPortal=FALSE;
    
	//[self horizc];
		
		
	if(pos.y <-10){ //darn, popped out of bounds
		pos.y=T_HEIGHT+3;
        vel.y=0;
		
	}else if(pos.y>T_HEIGHT*3){
        if(vel.y>0)vel.y=0;
    }
    
}
extern Vector fpoint;
- (void)render{
    [Graphics startPreview];
	if(THIRD_PERSON){
	float bx= pos.x-boxbase/2;
	float by= pos.y-boxheight/2;
	float bz= pos.z-boxbase/2;
        
	glColor4f(1.0f,1.0f,1.0f,1.0f);
        glDisable(GL_CULL_FACE);
	//glScalef(0, <#GLfloat y#>, <#GLfloat z#>)
        glPushMatrix();
      
        [Graphics drawCube:bx
                          :by
                          :bz
                          :TYPE_CLOUD:1];	
        glPopMatrix();
	//[Graphics drawTexCube:bx:by:bz:boxbase:[[Resources getResources] getTex:0]];

	glEnable(GL_CULL_FACE);
	}
	Input* input=[Input getInput];
	itouch* touches=[input getTouches];
	glColor4f(1.0, 1.0, 1.0, .4f);
	
	
	for(int i=0;i<MAX_TOUCHES;i++){
		if(touches[i].inuse==usage_id&&
		   touches[i].down==M_DOWN&&
		   touches[i].placeBlock&&
		   touches[i].previewtype!=TYPE_NONE&&touches[i].etime>0){
            if([World getWorld].hud.holding_creature&&touches[i].previewtype==TYPE_CLOUD&&[World getWorld].hud.mode==MODE_BUILD){
                PlaceModel(-1,fpoint);
            }else{
			[Graphics drawCube:touches[i].preview.x*BLOCK_SIZE
							  :touches[i].preview.y*BLOCK_SIZE
							  :touches[i].preview.z*BLOCK_SIZE
							  :touches[i].previewtype
                              :touches[i].build_size];	
                //printf("%d:(%d,%d)\n",i,touches[i].preview.x,touches[i].preview.z);
            }
        }
		
	}
	[Graphics endPreview];
	

}
@end
