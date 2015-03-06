//
//  Hud.m
//  prototype
//
//  Created by Ari Ronen on 10/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Hud.h"
#import "Globals.h"
#import "Frustum.h"
#import "TerrainGen2.h"


#import "Alert.h"

extern float SCREEN_WIDTH; 
extern float SCREEN_HEIGHT;
extern float P_ASPECT_RATIO;

static float HUDR_X= 427.0f;
static float HUD_BOX_SIZE= 45.0f;
static float HUDR_NUM= 5.0f;
static int BLOCK_ICON_SPACING =15;
static int BLOCK_ICON_SIZE =38;
static int COLOR_ICON_SPACING =9;
static int COLOR_ICON_SIZE =32;
static int hudBlocks[NUM_DISPLAY_BLOCKS]={	
	TYPE_GRASS,	
	TYPE_FLOWER,
	TYPE_DARK_STONE,
	TYPE_STONE,
	TYPE_DIRT,
	TYPE_SAND,
	TYPE_TNT,
	
	TYPE_WOOD,
	TYPE_SHINGLE,
    TYPE_GLASS,
    TYPE_GRADIENT,
	TYPE_TREE,
	TYPE_LEAVES,
	
	
	TYPE_BRICK,
	TYPE_COBBLESTONE,
    TYPE_VINE,
    TYPE_LADDER,
	TYPE_ICE,

	TYPE_CRYSTAL,
	
	TYPE_TRAMPOLINE,
    TYPE_CLOUD,
    TYPE_STONE_RAMP1,
    TYPE_WOOD_RAMP1,
    TYPE_ICE_RAMP1,
    TYPE_SHINGLE_RAMP1,
    TYPE_WEAVE,
    
    
    
    
   
    
    TYPE_WATER,
    TYPE_LAVA,
    
    TYPE_BLOCK_TNT,
     TYPE_FIREWORK,
    
    TYPE_DOOR_TOP,
    TYPE_GOLDEN_CUBE,
    TYPE_LIGHTBOX,
    TYPE_STEEL,
    TYPE_PORTAL_TOP,
    
};

extern "C" const int hudBlocksMap[NUM_BLOCKS+1]={
    [TYPE_GRASS]=TYPE_BTGRASS,
    [TYPE_FLOWER]=-1,
    [TYPE_DARK_STONE]=TYPE_BTDARKSTONE,
    [TYPE_STONE]=TYPE_BTSTONE,
    [TYPE_DIRT]=TYPE_BTDIRT,
    [TYPE_SAND]=TYPE_BTSAND,
    [TYPE_TNT]=TYPE_BTTNT,
   
    [TYPE_WOOD]=TYPE_BTWOOD,
    [TYPE_SHINGLE]=TYPE_BTSHINGLE,
    [TYPE_GLASS]=TYPE_BTGLASS,
    [TYPE_GRADIENT]=TYPE_BTGRADIENT,
    [TYPE_TREE]=TYPE_BTTREE,
    [TYPE_LEAVES]=TYPE_BTLEAVES,
    
    
    [TYPE_BRICK]=TYPE_BTBRICK,
    [TYPE_COBBLESTONE]=TYPE_BTCOBBLESTONE,
    [TYPE_VINE]=TYPE_BTVINES,
    [TYPE_LADDER]=TYPE_BTLADDER,
    [TYPE_ICE]=TYPE_BTICE,
    
    [TYPE_CRYSTAL]=TYPE_BTCRYSTAL,
    
    [TYPE_TRAMPOLINE]=TYPE_BTTRAMPOLINE,
    [TYPE_CLOUD]=TYPE_BTCLOUD,
    [TYPE_STONE_RAMP1]=TYPE_BTSTONESIDE,
    [TYPE_WOOD_RAMP1]=TYPE_BTWOODSIDE,
    [TYPE_ICE_RAMP1]=TYPE_BTICESIDE,
    [TYPE_SHINGLE_RAMP1]=TYPE_BTSHINGLESIDE,
    
    
    [TYPE_WEAVE]=TYPE_BTFENCE,
    
    
    
    [TYPE_WATER]=TYPE_BTWATER,
    [TYPE_LAVA]=TYPE_BTLAVA,
    
    [TYPE_BLOCK_TNT]=-1,
    [TYPE_FIREWORK]=TYPE_BTFIREWORK,
    
    [TYPE_DOOR_TOP]=-1,
    [TYPE_GOLDEN_CUBE]=-1,
    [TYPE_LIGHTBOX]=TYPE_BTLIGHTBOX,
    [TYPE_STEEL]=TYPE_BTSTEEL,
    [TYPE_PORTAL_TOP]=-1,
    
};

static int marginVert=10;
static int marginLeft=10;
static int marginLeft2=10-6;
//static int marginRight=60;
Vector colorTable[256];
//@implementation Hud
//@synthesize mode,blocktype,leftymode,use_joystick,paintColor,liquidColor,block_paintcolor,heartbeat,goldencubes,build_size,fade_out;
//@synthesize m_jump,m_back,m_fwd,m_left,m_right,test_a,m_joy,fps,justLoaded,flash,flashcolor;
//@synthesize sb,hideui,take_screenshot,underLiquid,holding_creature,creature_color,inmenu,var1,var2,var3;




static Vector test1;
static Vector test2;
static CGRect test1r;
static CGRect test2r;
extern BOOL IS_WIDESCREEN;

void Hud::genColorTable(){
   
    int c;
    int r;
    c=r=0;
    colorTable[0].x=1.0f;
    colorTable[0].y=1.0f;
    colorTable[0].z=1.0f;
    for(int i=0;i<NUM_COLORS;i++){
		
		        float red,g,b;
        if(c==8){
            if(r==5)
                HSVtoRGB(&red,&g,&b,1,0,0.01f);
            else
                HSVtoRGB(&red,&g,&b,1,0,1.0f-r/5.0f);
        }else{
            float hu=c;
            if(c==2)
                hu-=.6f;
            if(r<3)
                HSVtoRGB(&red,&g,&b,360.0f*(float)hu/8,(float)(r+1)/3,1);
            else
                HSVtoRGB(&red,&g,&b,360.0f*(float)hu/8,1,1.0f-(float)(r-2)/4);  /*
                                                                                 int hu=c;
                                                                                 if(r>=3)hu+=8;
                                                                                 if(r==0||r==3)
                                                                                 HSVtoRGB(&red,&g,&b,360.0f*(float)hu/16,0.5f,1);
                                                                                 else if(r==1||r==4)
                                                                                 HSVtoRGB(&red,&g,&b,360.0f*(float)hu/16,1,1);
                                                                                 else
                                                                                 HSVtoRGB(&red,&g,&b,360.0f*(float)hu/16,1,0.5f);*/
        }
        colorTable[i+1].x=red;
        colorTable[i+1].y=g;
        colorTable[i+1].z=b;
        
		c++;
		if(c>8){
			c=0;
			r++;
		}
	}

    
    
}
Hud::Hud(){
    
    fps=60;
	flash=-1;
    build_size=1;
    flashcolor=MakeVector(1.0,1.0,1.0);
     printf("flashcolor memlocation1: %X",(unsigned int)(&flashcolor));
	hideui=FALSE;
	HUDR_X=SCREEN_WIDTH-HUD_BOX_SIZE-13;
	ttime=0;
    blocktype_pressed=-1;
    justLoaded=1;
    
	rjumprender.origin.x=HUDR_X;
	rjumprender.origin.y=0;
	rjumprender.size.width=45;
	rjumprender.size.height=45;
   // if(IS_IPAD){
        rjumprender.origin.y+=23;
        rjumprender.origin.x-=17;
    
    rmenu.origin.x=0;
    rmenu.origin.y=SCREEN_HEIGHT-45;
    rmenu.size.width=45;
    rmenu.size.height=45;
    inmenu=FALSE;
   // }else{
    //    rjumprender.origin.y+=13;
    //    rjumprender.origin.x-=7;
    //}
    rjumphit.origin.x=rjumprender.origin.x-1;
	rjumphit.origin.y=0;
    underLiquid=FALSE;
	rjumphit.size.width=SCREEN_WIDTH- rjumphit.origin.x;
	rjumphit.size.height=45+rjumprender.origin.y;
    fade_out=0;
	test_a=0;
	CGRect sbrect;
	sbrect.origin.x=20;
	sbrect.size.width=SCREEN_WIDTH-40;
    
	sbrect.origin.y=0;
	sbrect.size.height=25;
	
    int roffy=3;
	rbuild.origin.x=HUDR_X;
	rbuild.origin.y=(3*SCREEN_HEIGHT/(HUDR_NUM))-(int)(HUD_BOX_SIZE)-roffy;
	rbuild.size.width=rbuild.size.height=HUD_BOX_SIZE;
	rmine.origin.x=HUDR_X;	
	rmine.origin.y=(4*SCREEN_HEIGHT/(HUDR_NUM))-(int)(HUD_BOX_SIZE)-roffy;
	rmine.size.width=rmine.size.height=HUD_BOX_SIZE;
	rburn.origin.x=HUDR_X;	
	rburn.origin.y=(5*SCREEN_HEIGHT/(HUDR_NUM))-(int)(HUD_BOX_SIZE)-roffy;
	rburn.size.width=rburn.size.height=HUD_BOX_SIZE;
    rpaint.origin.x=HUDR_X;	
	rpaint.origin.y=(2*SCREEN_HEIGHT/(HUDR_NUM))-(int)(HUD_BOX_SIZE)-roffy+5;
	rpaint.size.width=rpaint.size.height=HUD_BOX_SIZE;
	int c=0;
	int r=0;
	/*if(IS_IPAD){
		BLOCK_ICON_SIZE=70;
		BLOCK_ICON_SPACING=50;
		rjumprender.origin.x-=25;
		rjumprender.origin.y+=40;
		marginVert*=2;
		marginLeft*=2;
		marginRight*=1.5;
		sbrect.size.height*=2;
	}*/
    if(IS_WIDESCREEN){
       // printg("It's widescreen homie!\n");
        marginLeft2+=57;
        
    }
	for(int i=0;i<NUM_DISPLAY_BLOCKS;i++){
		
		blockBounds[i].origin.x=7+BLOCK_ICON_SPACING+marginLeft2+(BLOCK_ICON_SPACING+BLOCK_ICON_SIZE)*c;
		blockBounds[i].origin.y=-3+SCREEN_HEIGHT-marginVert-BLOCK_ICON_SPACING-BLOCK_ICON_SIZE-
        (                                                                                                BLOCK_ICON_SPACING+BLOCK_ICON_SIZE)*r;									 ;
		blockBounds[i].size.height=BLOCK_ICON_SIZE;
		blockBounds[i].size.width=BLOCK_ICON_SIZE;

		c++;
		if(c>6){
			c=0;
			r++;
		}
	}
    Hud::genColorTable();
    
  
    c=r=0;
    colorTable[0].x=1.0f;
    colorTable[0].y=1.0f;
    colorTable[0].z=1.0f;
    for(int i=0;i<NUM_COLORS;i++){
		
		colorBounds[i].origin.x=5+4+COLOR_ICON_SPACING+marginLeft2+(COLOR_ICON_SPACING+COLOR_ICON_SIZE)*c;
		colorBounds[i].origin.y=(-5)+(-5)+SCREEN_HEIGHT-marginVert-BLOCK_ICON_SPACING-COLOR_ICON_SIZE-
        (                                                                                                COLOR_ICON_SPACING+COLOR_ICON_SIZE)*r;									 ;
		colorBounds[i].size.height=COLOR_ICON_SIZE;
		colorBounds[i].size.width=COLOR_ICON_SIZE;
        		c++;
		if(c>8){
			c=0;
			r++;
		}
	}
   	rhome.origin.y=rsave.origin.y=rexit.origin.y=rcam.origin.y=marginVert+26;
	int magic_number=40;
	/*if(IS_IPAD){
		magic_number=85;
	}*/
	
	rhome.origin.x=marginLeft+8*magic_number-30;
	rsave.origin.x=marginLeft+2*magic_number-30;
	rexit.origin.x=marginLeft+6*magic_number-30;
	rcam.origin.x=marginLeft+4*magic_number-30;
	rcam.size.width=rhome.size.width=rsave.size.width=rexit.size.width=45;
	rcam.size.height=rhome.size.height=rsave.size.height=rexit.size.height=45;
	mode=MODE_MINE;
	blocktype=TYPE_BRICK;
    holding_creature=FALSE;
    
    block_paintcolor=0;
	sb= new statusbar(sbrect);
	//gamepad=[[Gamepad alloc] init];
    
	joystick=new Joystick();
	
	rpaintframe.origin.x=marginLeft2;
	rpaintframe.origin.y=marginVert+10;
	rpaintframe.size.width=402;
	rpaintframe.size.height=282;
    
    rmenuframe.origin.x=110;
  
	rmenuframe.origin.y=40;
	rmenuframe.size.width=SCREEN_WIDTH-200;
    
    if(IS_WIDESCREEN){
        rmenuframe.origin.x+=50;
        rmenuframe.size.width=SCREEN_WIDTH-300;
    }
	rmenuframe.size.height=SCREEN_HEIGHT-80;
    rsave.origin.x=rmenuframe.origin.x+17;
    rhome.origin.x=rmenuframe.origin.x+17;
    rexit.origin.x=rmenuframe.origin.x+17;
    rcam.origin.x=rmenuframe.origin.x+17;
    int sep=50;
    rsave.origin.y=rmenuframe.origin.y+rmenuframe.size.height-60-sep*0;
    rhome.origin.y=rmenuframe.origin.y+rmenuframe.size.height-60-sep*1;
    rexit.origin.y=rmenuframe.origin.y+rmenuframe.size.height-60-sep*3;
    rcam.origin.y=rmenuframe.origin.y+rmenuframe.size.height-60-sep*2;
    
    
    rtSave=ButtonMake(rsave.origin.x+57,rsave.origin.y+5,180,56/2+10);
    rtHome=ButtonMake(rhome.origin.x+57,rhome.origin.y+5,180,56/2+10);
    rtCam=ButtonMake(rcam.origin.x+57,rcam.origin.y+5,180,56/2+10);
    rtExit=ButtonMake(rexit.origin.x+57,rexit.origin.y+5,180,56/2+10);

    test1r=CGRectMake(0,0,50,50);
    test2r=CGRectMake(0,0,100,100);
    test1=MakeVector(randf(1),randf(1),randf(1));
    test2=colorTable[lookupColor(test1)];
    
	
}
static float at1=0,at2=0,at3=0;
void Hud::worldLoaded(){
    blocktype_pressed=-1;
    inmenu=FALSE;
    pickSecondBlock=FALSE;
    at1=0;
	if(mode==MODE_PICK_BLOCK){
		mode=MODE_BUILD;
	}
    if(mode==MODE_PICK_COLOR){
        mode=MODE_PAINT;
    }
	
}
static const int usage_id=15;
static const int usage_id2=16;
static int delayedaction=0;
static int delayedtimer=0;
extern int chunks_rendered;
extern int chunks_rendered2;
extern int vertices_rendered;
extern int max_vertices;
extern float P_ZFAR;
extern BOOL SUPPORTS_OGL2;

int flamecount=0;
static int lmode=MODE_NONE;
//static int warpCount=0;

BOOL Hud::update(float etime){
	if(flash>0){
		flash-=etime;
	}
    if(pickSecondBlock&&mode!=MODE_PICK_BLOCK){
        pickSecondBlock=FALSE;
        sb->clear();
    }
    if(World::getWorld->player->flash>0){
       // World::getWorld->player.flash-=etime;
    }
	if(World::getWorld->player->dead){
        if(fade_out<1){
            fade_out+=etime/4;
        }else if(fade_out>=1){
            printg("warping home\n");
            World::getWorld->terrain->warpToHome();
            printg("finished warping\n");
        }
    }else{
        if(fade_out>0){
            if(etime>.1f)etime=.1f;
            fade_out-=etime/2.5f;
            if(fade_out<0)fade_out=0;
        }
    }
	ttime+=World::getWorld->realtime;
	fpsc++;
    if(justLoaded){
        ttime=0;
        fpsc=0;
        justLoaded++;
        if(justLoaded==3){
            justLoaded=0;
        }
    }
    if(inmenu){
        
        
        at1+=etime*6;
        if(at1>=1){
            at1=1;
        }
        
        
        
    }else {
        at1-=etime*6;
        if(at1<=0)
            at1=0;
    }
   //if(mode==MODE_PICK_BLOCK){
    
    if(mode==MODE_PICK_BLOCK){
        at2+=etime*9;
        if(at2>=1)
            at2=1;
    }else{
        at2-=etime*9;
        if(at2<=0)at2=0;
    }
    
    if(mode==MODE_PICK_COLOR){
        at3+=etime*9;
        if(at3>=1)
            at3=1;
    }else{
        at3-=etime*9;
        if(at3<=0)at3=0;
    }
    
    heartbeat=FALSE;
	if(ttime>=1.0f){
        heartbeat=TRUE;
		fps=fpsc;
       // float fpsf=1/World::getWorld->realtime;
        test1=MakeVector(randf(1),randf(1),randf(1));
        test2=colorTable[lookupColor(test1)];
       //  [sb setStatus:[NSString stringWithFormat:@"FPS: %d chunks:%d vertices:%d",fpsc,var1,var2] :2];
       //[sb setStatus:[NSString stringWithFormat:@"FPS: %d player:(%.1f,%.1f)",fpsc,World::getWorld->player.pos.x,World::getWorld->player.pos.z] :2];
		//printg("Fps:%d   vertices:%d   max_vertices:%d chunks:%d.\n",fpsc,vertices_rendered,max_vertices,chunks_rendered);
       // float pz=P_ZFAR;
        if(!SUPPORTS_OGL2){
           /* if( fpsf<28){
                 if(P_ZFAR>15.0f)
                P_ZFAR-=.1f;
                
            }else if(fpsf>35){
                 if(P_ZFAR<T_SIZE)
                P_ZFAR+=.1f;
            }*/ 
            
        }else{
             //[Graphics setZFAR:T_SIZE];
            //P_ZFAR=T_SIZE;
            if(fpsc<=59){
               
              //  max_vertices-=100*(60-fpsc);
            }else if(fpsc>60&&vertices_rendered>=max_vertices){
                //max_vertices+=100;
            }
            /*
            if( fpsc<59){
                P_ZFAR-=(60-fpsc);
            }else if(fpsc>=60){
                if(P_ZFAR<T_SIZE)
                P_ZFAR+=1;
            }*/
        }
        
    
		fpsc=0;
		ttime=0;
        
	}
	if(delayedtimer==1){
        delayedtimer=0;

        
		if(delayedaction==6){
			World::getWorld->terrain->warpToHome();
			sb->clear();
		}else if(delayedaction==5){
            mode=MODE_NONE;
           // printg("trying to exit\n!!!");
			World::getWorld->fm->saveWorld();
            World::getWorld->exitToMenu();
            
			
			sb->clear();
			
		}
        delayedaction=0;
				return FALSE;
		
	}
  

    
    if(delayedtimer>1){delayedtimer--; return FALSE;}
	
	Input* input=Input::getInput();
    itouch* touches=input->getTouches();
	
	
	
	
	for(int i=0;i<MAX_TOUCHES;i++){
        if(touches[i].inuse==usage_id2&&touches[i].down==M_RELEASE){
            BOOL handled;
            if(inmenu){
                if(handlePickMenu(touches[i].mx,touches[i].my)){
                    
                    handled=TRUE;
                }
                
            }
            if(inbox2(touches[i].mx,touches[i].my,&rmenu)){	
                inmenu=!inmenu;
                if(inmenu==TRUE){
                    rcam.pressed=rtCam.pressed=FALSE;rhome.pressed=rtHome.pressed=FALSE;
                    rsave.pressed=rtSave.pressed=FALSE;rexit.pressed=rtExit.pressed=FALSE;
                    if(mode==MODE_PICK_BLOCK){
                        mode=MODE_BUILD;
                        
                    }
                    if(mode==MODE_PICK_COLOR){
                        mode=MODE_PAINT;
                        
                    }
                    if(mode==MODE_CAMERA){
                        mode=lmode;
                    }
                    blocktype_pressed=-1;
                }else{
                    
                    extern BOOL FLY_MODE;
                  /*  FLY_MODE=!FLY_MODE;
                    printg("Fly mode set to %d\n",FLY_MODE);*/
                    
                    
                    
                   /*
                    int ppx,ppz,ppy;
                    ppy=3*T_HEIGHT/4;
                    ppx=T_SIZE/2+4096*CHUNK_SIZE-GSIZE/2;
                    ppz=T_SIZE/2+4096*CHUNK_SIZE-GSIZE/2;
                    int dwarpx[]={0,      0,      0,        0,GSIZE/4,GSIZE/2,3*GSIZE/4};
                    int dwarpz[]={0,GSIZE/4,GSIZE/2,3*GSIZE/4,0,      0,      0,};
                    ppx+=dwarpx[warpCount];
                    ppz+=dwarpz[warpCount];
                    
                    [World::getWorld->terrain warpToPoint:ppx:ppz:ppy];
                    printg("warping to: %d,%d,%d\n",ppx,ppz,ppy);
                    warpCount++;
                    if(warpCount==7){
                        warpCount=0;
                    }
                    */
                   /* int ppx=player.pos.x-4096*CHUNK_SIZE+GSIZE/2;
                    int ppz=player.pos.z-4096*CHUNK_SIZE+GSIZE/2;
                    ppx=ppx/(GSIZE/4);
                    ppz=ppz/(GSIZE/4);
                    if(ppx>4)ppx=4;
                    if(ppz>4)ppz=4;
                    if(ppx<0)ppx=0;
                    if(ppz<0)ppz=0;*/
                    
                }
              //  printg("menu touched\n");
                handled=TRUE;
            }
                       if(handled){
                           Input::getInput()->clearAll();
                          
                touches[i].down=M_NONE;
            }
             touches[i].down=M_NONE;
            touches[i].inuse=0;
        }
            
        
        if(touches[i].inuse==0&&touches[i].down==M_DOWN){
            if(inmenu){
                if(inbox3(touches[i].mx,touches[i].my,&rcam)||
                   inbox3(touches[i].mx,touches[i].my,&rhome)||
                   inbox3(touches[i].mx,touches[i].my,&rsave)||
                   inbox3(touches[i].mx,touches[i].my,&rexit)||
                   inbox3(touches[i].mx,touches[i].my,&rtCam)||
                   inbox3(touches[i].mx,touches[i].my,&rtHome)||
                   inbox3(touches[i].mx,touches[i].my,&rtSave)||
                   inbox3(touches[i].mx,touches[i].my,&rtExit))
                {
                    printg("something touched in menu\n");
                    inbox3(touches[i].mx,touches[i].my,&rcam);
                    inbox3(touches[i].mx,touches[i].my,&rhome);
                    inbox3(touches[i].mx,touches[i].my,&rsave);
                    inbox3(touches[i].mx,touches[i].my,&rexit);
                    inbox3(touches[i].mx,touches[i].my,&rtCam);
                    inbox3(touches[i].mx,touches[i].my,&rtHome);
                    inbox3(touches[i].mx,touches[i].my,&rtSave);
                    inbox3(touches[i].mx,touches[i].my,&rtExit);
                    touches[i].inuse=usage_id2;
                    touches[i].down=M_NONE;
                }
            }
            if(inbox3(touches[i].mx,touches[i].my,&rmenu)){	
                touches[i].inuse=usage_id2;
                touches[i].down=M_NONE;
            }
        /*    if(inbox3(touches[i].mx,touches[i].my,&rburn)){
                 touches[i].inuse=usage_id2;
            }
            if(inbox3(touches[i].mx,touches[i].my,&rbuild)){
                 touches[i].inuse=usage_id2;
			}
            
            if(inbox3(touches[i].mx,touches[i].my,&rpaint)){
				 touches[i].inuse=usage_id2;
			}
			if(inbox3(touches[i].mx,touches[i].my,&rmine)){	
                touches[i].inuse=usage_id2;
			}*/
        
            extern bool FLY_UP;
            extern bool FLY_DOWN;
            extern BOOL FLY_MODE;
        
			BOOL handled=FALSE;
            if(inbox2(touches[i].mx,touches[i].my,&rburn)){	
                flamecount++;
                if(flamecount==25){
                    flamecount=0;
                    
                }
                printg("flamecount: %d\n",flamecount);
                if(mode==MODE_BURN)mode=MODE_NONE;
                else
                    mode=MODE_BURN;
                
                if(FLY_MODE){
                FLY_UP=!FLY_UP;
				
                }
                inmenu=FALSE;
                    handled=TRUE;
			}
            if(inbox2(touches[i].mx,touches[i].my,&rbuild)){
                if(mode==MODE_PAINT){
                    block_paintcolor=paintColor;
                    mode=MODE_BUILD;
                }else
                    if(mode!=MODE_PICK_BLOCK){
                        mode=MODE_PICK_BLOCK;
                        pickSecondBlock=FALSE;
                        sb->clear();
                        inmenu=FALSE;
                    }else 
                        mode=MODE_BUILD;
                
                blocktype_pressed=-1;
                Input::getInput()->clearAll();
                
                break;
                inmenu=FALSE;
				handled=TRUE;
			}
            
            if(inbox2(touches[i].mx,touches[i].my,&rpaint)){
				if(mode!=MODE_PICK_COLOR){
					mode=MODE_PICK_COLOR;
                    inmenu=FALSE;
                }else 
                    mode=MODE_PAINT;
                blocktype_pressed=-1;
                input->clearAll();
                
                break;
                inmenu=FALSE;
				handled=TRUE;
			}
			if(inbox2(touches[i].mx,touches[i].my,&rmine)){	
                if(mode==MODE_MINE)mode=MODE_NONE;
                else
                    mode=MODE_MINE;
                 if(FLY_MODE){
                FLY_DOWN=!FLY_DOWN;
				
                 }
                inmenu=FALSE;
                handled=TRUE;
			}
            
			if(mode==MODE_PICK_BLOCK){
				if(handlePickBlock(touches[i].mx,touches[i].my)){
                    if(!pickSecondBlock){
                    inmenu=FALSE;
                     sb->clear();
                    }
					handled=TRUE;
                    //printg("handled\n");
				}				
			}
            if(mode==MODE_PICK_COLOR){
                
				if(handlePickColor(touches[i].mx,touches[i].my)){
                    inmenu=FALSE;
					handled=TRUE;
				}				
			}
			
			
            
			if(handled){
				touches[i].inuse=usage_id;
                touches[i].moved=false;
				touches[i].down=M_NONE;	
				break;
			}						
		}
	}
	for(int i=0;i<MAX_TOUCHES;i++){
		if(touches[i].inuse==usage_id&&touches[i].moved){
            if(mode==MODE_PICK_BLOCK){
				//if(handlePickBlock(touches[i].mx,touches[i].my)){
                    
                    
                //        touches[i].inuse=usage_id;
                //    touches[i].moved=FALSE;
                    
					
				//}
			}else if(mode==MODE_PICK_COLOR){
				if(handlePickColor(touches[i].mx,touches[i].my)){
                    touches[i].inuse=usage_id;
                    touches[i].moved=FALSE;
									}				
			}
        }
    }
    
	/*
     */
	m_jump=FALSE;
	for(int i=0;i<MAX_TOUCHES;i++){
		if((touches[i].inuse==0||touches[i].inuse==usage_id)&&touches[i].down==M_DOWN){
			if(inbox2(touches[i].mx,touches[i].my,&rjumphit)){			
				m_jump=TRUE;
                inmenu=FALSE;
				//test_a+=.0001;
				//if(test_a>.005)test_a=0;
				//NSLog(@"attenuation: %f",test_a);
				touches[i].inuse=usage_id;
				//NSLog(@"set touch %d to uid %d",touches[i].touch_id,usage_id);
			}
			
		}
		
	}
	
	if(use_joystick){
		joystick->update((float)etime);
	}else{
		//[gamepad update:(float) etime];
	}
	sb->update(etime);
	for(int i=0;i<MAX_TOUCHES;i++){
		
		if(touches[i].inuse==usage_id&&touches[i].down==M_RELEASE){
			if(blocktype_pressed!=-1){
                if(mode==MODE_PICK_BLOCK&&pickSecondBlock==FALSE){
                    
                    
                    if(blocktype_pressed==TYPE_GOLDEN_CUBE){
                        if(goldencubes>0){
                           
                            block_paintcolor=20;
                            mode=MODE_BUILD;
                            blocktype=blocktype_pressed;
                            printg("set paintcolor %d \n",block_paintcolor);
                          
                        }
                    }else if(blocktype_pressed==TYPE_CUSTOM){
                        /*
                        build_size++;
                        if(build_size==2){
                            build_size=0;
                        }
                        printg("Setting buildsize: %d\n",build_size);
                         */
                    }else if(blocktype_pressed==TYPE_DOOR_TOP){
                      block_paintcolor=20;
                        mode=MODE_BUILD;
                        blocktype=blocktype_pressed;

                        
                    }else{
                        block_paintcolor=0;
                    
                        mode=MODE_BUILD;
                        blocktype=blocktype_pressed;
                        printf("blocktype:%d\n",blocktype);
                    }
                    
                }
                if(mode==MODE_PICK_COLOR){
                    mode=MODE_PAINT;
                    paintColor=blocktype_pressed+1;
                    
                    printg("paint color-1:%d\n",paintColor-1);
                }
                blocktype_pressed=-1;
                
            }
            touches[i].inuse=0;
			touches[i].down=M_NONE;
		}
		
		
	}
	
	
	return FALSE;
}

//extern float P_ZFAR;

extern const GLubyte blockColor[NUM_BLOCKS+1][3];
    
BOOL Hud::handlePickColor(int x,int y){
    BOOL handled=FALSE;
    
    
   
    for(int i=0;i<NUM_COLORS;i++){
     if(inbox(x,y,colorBounds[i])){
         blocktype_pressed=i;
         
        // NSLog(@"picked color: %d",pressed);
   
         handled=TRUE;
     }
     }
    return handled;
}
BOOL Hud::handlePickMenu(int x,int y){
    BOOL handled=FALSE;
    if(inbox2(x,y,&rcam)||inbox2(x,y,&rtCam)){
        
        rcam.pressed=rtCam.pressed=FALSE;
        
		mode=MODE_CAMERA;
		if(!SUPPORTS_OGL2){
            Graphics::setZFAR(75);
           
        }
		else Graphics::setZFAR(120);
        inmenu=false;
		handled=TRUE;
	}
	if(inbox2(x,y,&rhome)||inbox2(x,y,&rtHome)){	
        rhome.pressed=rtHome.pressed=FALSE;
    /*    if(!World::getWorld->FLIPPED){
            [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeRight;
        }
        else{
            [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeLeft;
            
        }*/
        showAlertWarpHome();
        
		inmenu=false;
		handled=TRUE;
	}
	if(inbox2(x,y,&rsave)||inbox2(x,y,&rtSave)){	
        rsave.pressed=rtSave.pressed=FALSE;
		World::getWorld->fm->saveWorld();
        //[World::getWorld->terrain updateAllImportantChunks];
      //  NSLog(@"saving..");
        Input::getInput()->clearAll();
        
        World::getWorld->terrain->startDynamics();
		sb->setStatus(@"World Saved" ,3);
        
        
        
        
        inmenu=false;
		handled=TRUE;
	}
	if(inbox2(x,y,&rexit)||inbox2(x,y,&rtExit)){	
        rexit.pressed=rtExit.pressed=FALSE;
		delayedtimer=1;
		delayedaction=5;
		sb->setStatus(@"Saving and quitting..." ,999);
        inmenu=false;
		handled=TRUE;
        
	}
	

    
    return handled;
}

BOOL Hud::handlePickBlock(int x,int y){
	BOOL handled=FALSE;
	
	for(int i=0;i<NUM_DISPLAY_BLOCKS;i++){
		if(inbox(x,y,blockBounds[i])){
            if(hudBlocks[i]==TYPE_BLOCK_TNT){
               // sb->setStatus(@"Pick second block type",999);
                pickSecondBlock=TRUE;
                handled=TRUE;
               // printf("no custom\n");
            }else{
                /*
                 TYPE_BTGRASS=82,
                 TYPE_BTDARKSTONE=83,
                 TYPE_BTSTONE=84,
                 TYPE_BTDIRT=85,
                 TYPE_BTSAND=86,
                 TYPE_BTTNT=87,
                 TYPE_BTWOOD=88,
                 TYPE_BTSHINGLE=89,
                 TYPE_BTGLASS=90,
                 TYPE_BTGRADIENT=91,
                 TYPE_BTTREE=92,
                 TYPE_BTLEAVES=93,
                 TYPE_BTBRICK=94,
                 TYPE_BTCOBBLESTONE=95,
                 TYPE_BTVINES=96,
                 TYPE_BTLADDER=97,
                 TYPE_BTICE=98,
                 TYPE_BTCRYSTAL=99,
                 TYPE_BTTRAMPOLINE=100,
                 TYPE_BTCLOUD=101,
                 TYPE_BTSTONESIDE=102,
                 TYPE_BTWOODSIDE=103,
                 TYPE_BTICESIDE=104,
                 TYPE_BTSHINGLESIDE=105,
                 TYPE_BTFENCESIDE=106,
                 TYPE_BTWATERSIDE=107,
                 TYPE_BTLAVASIDE=108,
                 TYPE_BTFIREWORKSIDE=109,
                 TYPE_BTLIGHTBOX=110,
                 TYPE_BTSTEEL=111,*/
                if(pickSecondBlock){
                    int nr=hudBlocksMap[hudBlocks[i]];
                    
                    
                    if(nr==-1){
                        blocktype_pressed=hudBlocks[i];
                        printf("derp: %d\n",nr);
                    }else{ blocktype_pressed=nr;
                        printf("derp: %d\n",nr);
                    }
                    
                    pickSecondBlock=FALSE;
                        
                    
                    
                }else{
                    blocktype_pressed=hudBlocks[i];
                    printf("derp: %d\n",blocktype_pressed);
                }
                // printg("set pressed: %d\n",i);
            }
           
			 handled=TRUE;
            break;
		}
	}
		return handled;
    
}

void Hud::renderColorPickScreen(){
    glColor4f(1.0, 1.0, 1.0, at3);	
    Resources::getResources->getTex( ICO_COLOR_SELECT_BACKGROUND)->drawInRect(rpaintframe);
   
    for(int i=0;i<NUM_COLORS;i++){
        if(blocktype_pressed==i)
           Resources::getResources->getTex(ICO_COLOR_BLOCK_BORDER_PRESSED)->drawInRect2(colorBounds[i]);
            else
		Resources::getResources->getTex(ICO_COLOR_BLOCK_BORDER)->drawInRect2(colorBounds[i]);
	}
   // 
	glBindTexture(GL_TEXTURE_2D, Resources::getResources->atlas->name);
	for(int i=0;i<NUM_COLORS;i++){
		
		CGRect rect=colorBounds[i];
		CGPoint tp;
		 tp=Resources::getResources->getBlockTex(blockTypeFaces[TYPE_CLOUD][5]);
		GLfloat				coordinates[] = {
			0,			tp.y+tp.x,
			1,			tp.y+tp.x,
			0,				tp.x,
			1,				tp.x,
		};
        
        int bb=0;
        if(blocktype_pressed==i){
            bb=2;
        }
        int size=29;
        float off=3;
        if(IS_IPAD){
            rect.origin.x*=SCALE_WIDTH;
            rect.origin.y*=SCALE_HEIGHT;
            size*=2;
            bb*=2;
            off*=2;
        }
		GLfloat				vertices[] = {
			rect.origin.x+off+bb,							rect.origin.y+off-bb,							0,
			rect.origin.x + size+bb,		rect.origin.y+off-bb,							0,
			rect.origin.x+off+bb,							rect.origin.y + size-bb,		0,
			rect.origin.x + size+bb,		rect.origin.y + size-bb,		0
		};
		
		Vector hudColor=colorTable[i+1];
        //if(i%9>3)hudColor=colorTable[i-9+5+1];
        
       // if(i%9 ==8){
         //   hudColor=colorTable[i+1];
           // printg("i:%d\n",i);
           // if(i==13||i==22)
           // hudColor=MakeVector(1.0f,1,1);
        //}
        
        
        glColor4f(hudColor.x,hudColor.y,hudColor.z,at3);
		
        
		glVertexPointer(3, GL_FLOAT, 0, vertices);
		glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
       
	}
    glEnable(GL_BLEND);
    
}
void Hud::renderBlockAndBorder(CGRect recto){
    int type=blocktype;
    
    
	glColor4f(1.0f,1.0f,1.0f,1.0f);
    if(type==TYPE_FLOWER||type==TYPE_GOLDEN_CUBE||type==TYPE_DOOR_TOP||type==TYPE_PORTAL_TOP){
        float offsetx;
        float offsety;
        float osize=90;
        if(type!=TYPE_FLOWER)osize=70;
        if(IS_IPAD&&!SUPPORTS_RETINA){
            offsetx=(128-osize)/2.0f/SCALE_WIDTH;
            offsety=(128-osize)/2.0f/SCALE_HEIGHT;
        }else{
            offsetx=(128-osize)/2.0f/2.0f;
            offsety=(128-osize)/2.0f/2.0f;
        }
        
        if(mode==MODE_BUILD||mode==MODE_PICK_BLOCK){
            /*
             ICOICO_GOLDCUBE_ACTIVE=94,
             ICOICO_FLOWER_ACTIVE=95,
             ICOICO_DOOR_ACTIVE=96,
             ICOICO_PORTAL_ACTIVE=97,
             */
            int tid;
            if(type==TYPE_FLOWER){
                tid=ICOICO_FLOWER_ACTIVE;
            }else if(type==TYPE_GOLDEN_CUBE){
                tid=ICOICO_GOLDCUBE_ACTIVE;
            }else if(type==TYPE_PORTAL_TOP){
                tid=ICOICO_PORTAL_ACTIVE;
            }else if(type==TYPE_DOOR_TOP){
                tid=ICOICO_DOOR_ACTIVE;
            }
            CGRect offrect=recto;
            offrect.origin.x-=offsetx;
            offrect.origin.y-=offsety;
            Resources::getResources->getTex(tid)->drawTextHalfsies(offrect);
            Resources::getResources->getPaintedTex(type,block_paintcolor)->drawTextHalfsies(recto);
          
        }else{
            
            int tid;
            if(type==TYPE_FLOWER){
                tid=ICO_FLOWER_ICO;
            }else if(type==TYPE_GOLDEN_CUBE){
                tid=ICO_GOLDCUBE;
            }else if(type==TYPE_PORTAL_TOP){
                tid=ICO_PORTAL2;
            }else if(type==TYPE_DOOR_TOP){
                tid=ICO_DOOR2;
            }

            Resources::getResources->getPaintedTex(type,block_paintcolor)->drawTextHalfsies(recto);
            
            
        }
        Resources::getResources->getTex(ICO_BUILD_PLUS)->drawTextHalfsies(recto);
        if(type==TYPE_GOLDEN_CUBE){
           // printg("wtf\n");
            CGRect num_rect=recto;
            //recto.origin.x/=2;
            //recto.origin.y/=2;
            num_rect.origin.x+=18;
            if(goldencubes!=10){
                num_rect.origin.x+=3;
            }
            num_rect.origin.y-=2;
            if(goldencubes==0){
                glColor4f(1.0f,1.0f,1.0f,.3f);
                Resources::getResources->getTex(TEXT_NUMBERS)->drawNumbers(num_rect,goldencubes);
                glColor4f(1.0f,1.0f,1.0f,1.0f);
            }else{
                Resources::getResources->getTex(TEXT_NUMBERS)->drawNumbers(num_rect,goldencubes);
                
            }
        }
        return;
    }else
    if(type>=TYPE_STONE_RAMP1&&type<=TYPE_ICE_RAMP4){
        float offsetx;
        float offsety;
        if(IS_IPAD&&!SUPPORTS_RETINA){
            offsetx=(128-90)/2.0f/SCALE_WIDTH;
            offsety=(128-90)/2.0f/SCALE_HEIGHT;
            
            
        }else{
            offsetx=(128-90)/2.0f/2.0f;
            offsety=(128-90)/2.0f/2.0f;
            
        }
       // CGRect rdigits=CGRectMake(50,50,50,50);
       //  Resources::getResources->getTex:ICO_DIGITS]->drawText(rdigits);
        if(mode==MODE_BUILD||mode==MODE_PICK_BLOCK){
            
            recto.origin.x-=offsetx;
           recto.origin.y-=offsety;
            if(build_size!=0)
                Resources::getResources->getTex(ICO_BUILD3_ACTIVE)->drawTextHalfsies(recto);
            else {
                Resources::getResources->getTex(ICO_BUILD3_ACTIVE2)->drawTextHalfsies(recto);
            }
            
            recto.origin.x+=offsetx;
            recto.origin.y+=offsety;
        }else{
            if(build_size==0)
                Resources::getResources->getTex(ICO_BUILD2_UNDER2)->drawTextHalfsies(recto);
            else {
                Resources::getResources->getTex(ICO_BUILD3)->drawTextHalfsies(recto);
            }
            
        }
    }else{
        float offsetx;
        float offsety;
        
        if(IS_IPAD&&!SUPPORTS_RETINA){
            offsetx=(128-90)/2.0f/SCALE_WIDTH;
            offsety=(128-90)/2.0f/SCALE_HEIGHT;
            
            
        }else{
            offsetx=(128-90)/2.0f/2.0f;
            offsety=(128-90)/2.0f/2.0f;
            
        }
        
        if(mode==MODE_BUILD||mode==MODE_PICK_BLOCK){
            
            recto.origin.x-=offsetx;
            recto.origin.y-=offsety;
           // Resources::getResources->getTex:ICO_BUILD2_ACTIVE]->drawTextHalfsies(recto);
            if(build_size==0){
            Resources::getResources->getTex(ICO_BUILD2_ACTIVE2)->drawTextHalfsies(recto);
            }else{
                Resources::getResources->getTex(ICO_BUILD2_ACTIVE)->drawTextHalfsies(recto);
            }
            
            recto.origin.x+=offsetx;
            recto.origin.y+=offsety;
        }else{
            if(build_size==0)
            Resources::getResources->getTex(ICO_BUILD_UNDER2)->drawTextHalfsies(recto);
            else {
                Resources::getResources->getTex(ICO_BUILD2)->drawTextHalfsies(recto);
            }
        }
    }
	//glDisable(GL_BLEND);
	
    
    if(blockinfo[type]&IS_ATLAS2){
        glBindTexture(GL_TEXTURE_2D, Resources::getResources->atlas2->name);
    }else{
        glBindTexture(GL_TEXTURE_2D, Resources::getResources->atlas->name);
    }
    CGPoint tp;
    if(type==TYPE_TNT||type==TYPE_FIREWORK||type==TYPE_LADDER||type==TYPE_BLOCK_TNT){
        if(type==TYPE_TNT){
            if (block_paintcolor!=0)
                tp=Resources::getResources->getBlockTex(TEX_TNT_SIDE);
            else
                tp=Resources::getResources->getBlockTex(TEX_TNT_SIDE_COLOR);
            
        }else if(type==TYPE_FIREWORK){
            if (block_paintcolor!=0)
                tp=Resources::getResources->getBlockTex(TEX_FIREWORK);
            else
                tp=Resources::getResources->getBlockTex(TEX_FIREWORK);

            
        }else if(type==TYPE_BLOCK_TNT){
            if (block_paintcolor!=0)
                tp=Resources::getResources->getBlockTex(TEX_BLOCKTNT);
            else
                tp=Resources::getResources->getBlockTex(TEX_BLOCKTNT);
        }else
            tp=Resources::getResources->getBlockTex(blockTypeFaces[type][3]);
    }else{
        
        if (block_paintcolor==0){
          if(type==TYPE_BRICK)
                tp=Resources::getResources->getBlockTex(TEX_BRICK_COLOR);
            else
                tp=Resources::getResources->getBlockTex(blockTypeFaces[type][5]);
        }else
            tp=Resources::getResources->getBlockTex(blockTypeFaces[type][5]);
    }
    if(blockinfo[type]&IS_BLOCKTNT){
        tp=Resources::getResources->getBlockTex(TEX_BLOCKTNT);
    }
    GLfloat				coordinates[] = {
        0,			tp.y+tp.x,
        1,			tp.y+tp.x,
        0,				tp.x,
        1,				tp.x,
        
        0,			tp.y+tp.x,
        1,			tp.y+tp.x,
        0,				tp.x,
        1,				tp.x,
        
        0,			tp.y+tp.x,
        1,			tp.y+tp.x,
        0,				tp.x,
        1,				tp.x,
    };
  /*  1,1,//top face
	1,0,
	0,1,	
	
	0,0,
*/
        GLfloat				coordinates2[] = {
            0,			tp.y+tp.x,
            1,			tp.y+tp.x,
            0,				tp.x,
            1,				tp.x,
            
            
            1,			tp.y+tp.x,
            1,			tp.x,
            0,			tp.y+tp.x	,
            0,				tp.x,

            
            
            0,			tp.y+tp.x,
            1,			tp.y+tp.x,
            0,				tp.x,
            1,				tp.x,
		};
        int bb=0;
        int size=29;
   
        float off=2;
    float offx=0;
    float offy=4;
    int depth=24;
    if(build_size==0){
        depth=17;
        if(type>=TYPE_STONE_RAMP1&&type<=TYPE_ICE_RAMP4)depth=19;
        size=24;
        offx+=9;
        offy+=9;
    }
    if(build_size==2)size=45;
    
    //if(blockinfo[type]&IS_RAMP)
    //    offy=-1;
    
    CGRect rect=recto;
    if(!IS_RETINA&&SUPPORTS_RETINA){
     //   bb/=2;
      //  size;
        depth/=2;
        offy-=2;
        
    }
    
        if(IS_IPAD){
            rect.origin.x*=SCALE_WIDTH;
            rect.origin.y*=SCALE_HEIGHT;
            size*=2;
            bb*=2;
            off*=2;
        }
   
		/*GLfloat				vertices[] = {
			rect.origin.x+off+bb-offx,							rect.origin.y+off-bb-offy,							0,
			rect.origin.x + size+bb-offx,		rect.origin.y+off-bb-offy,							0,
			rect.origin.x+off+bb-offx,							rect.origin.y + size-bb-offy,		0,
			rect.origin.x + size+bb-offx,		rect.origin.y + size-bb-offy,		0
		};*/
    
    GLfloat				bvertices[] = {
        off+bb+offx,			off-bb+offy,							0,
        size+bb+offx,		off-bb+offy,							0,
        off+bb+offx,			size-bb+offy,                        0,
        size+bb+offx,		size-bb+offy,                        0,
        
        //off+bb,			off-bb,							0,
        //size+bb,		off-bb,							0,
        off+bb+offx,			size-bb+offy,                        0,
        size+bb+offx,		size-bb+offy,                        0,
        off+bb+depth+offx,			size-bb+depth+offy,          0,
        size+bb+depth+offx,		size-bb+depth+offy,              0,
        
        size+bb+offx,			off-bb+offy,							0,
        size+bb+depth+offx,		off-bb+depth+offy,							0,
        size+bb+offx,			size-bb+offy,                        0,
        size+bb+depth+offx,		size-bb+depth+offy,                        0,
        
    };
    
    
    GLfloat				vertices[3*6*3]; 
    for(int i=0;i<3*6*2;i+=3){
        vertices[i]=bvertices[i]+rect.origin.x;
        vertices[i+1]=bvertices[i+1]+rect.origin.y;
        vertices[i+2]=bvertices[i+2];
    }    
    int cory=-3;
    GLfloat				bvertices2[] = {
        off+bb+offx,			off-bb+offy,					 0,
        size+bb+offx,		off-bb+offy,						 0,
        off+bb+offx,			size-bb+offy+cory,                    0,
        size+bb+offx,		size-bb+offy+cory,                        0,
        
        //off+bb,			off-bb,							0,
        //size+bb,		off-bb,							0,
        off+bb+offx,			size-bb+offy+cory,                    0,
        size+bb+offx,		off-bb+offy,                        0,
        off+bb+depth+offx,			size-bb+depth+offy+cory,          0,
        size+bb+depth+offx+1,		off-bb+depth+offy,              0,
        
       // size+bb+offx,			off-bb+offy,					 0,
       // size+bb+depth+offx,		off-bb+depth+offy,				 0,
      //  size+bb+offx,			size-bb+offy,                    0,
      //  size+bb+depth+offx,		size-bb+depth+offy,              0,
        
    };
    
    GLfloat				vertices2[3*6*3];
    
    /*= {
        rect.origin.x+off+bb-offx,							rect.origin.y+off-bb-offy,			0,
        rect.origin.x + size+bb-offx,		rect.origin.y+off-bb-offy,							0,
        //rect.origin.x+off+bb,							rect.origin.y + size-bb,		0,
        rect.origin.x + size+bb-offx,		rect.origin.y + size-bb-offy,		0
    };*/
    
    for(int i=0;i<3*6*2;i+=3){
        vertices2[i]=bvertices2[i]+rect.origin.x;
        vertices2[i+1]=bvertices2[i+1]+rect.origin.y;
        vertices2[i+2]=bvertices2[i+2];
    }
    
    if (block_paintcolor!=0) {
        Vector clr=colorTable[block_paintcolor];
        glColor4f(clr.x,clr.y,clr.z,1.0f);
    }
    else if(type==TYPE_GRASS2||type==TYPE_GRASS3||type==TYPE_TNT||type==TYPE_FIREWORK||type==TYPE_BRICK||type==TYPE_VINE)
        glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
    else
        glColor4ub(blockColor[type][0], blockColor[type][1], blockColor[type][2], 255);
    
    if(type==TYPE_CLOUD&&holding_creature){
        glVertexPointer(3, GL_FLOAT, 0, vertices);
        glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
        Resources::getResources->getTex(ICO_MOOF)->drawTextNoScale(
         CGRectMake(rect.origin.x+off+bb-offx, rect.origin.y+off-bb-offy,32, 32));
    }else
    if(type>=TYPE_STONE_RAMP1&&type<=TYPE_ICE_RAMP4){
       // glVertexPointer(3, GL_FLOAT, 0, vertices2);
       // glTexCoordPointer(2, GL_FLOAT, 0, coordinates2);
       // glDrawArrays(GL_TRIANGLE_STRIP, 0, 3);
        
        glVertexPointer(3, GL_FLOAT, 0, vertices2);
        glTexCoordPointer(2, GL_FLOAT, 0, coordinates2);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 3);        
        glDrawArrays(GL_TRIANGLE_STRIP, 4, 4);
       // glDrawArrays(GL_TRIANGLE_STRIP, 8, 4);
    }else{
        glVertexPointer(3, GL_FLOAT, 0, vertices);
        glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
        if(blockinfo[type]&IS_BLOCKTNT){
             glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
                       glDrawArrays(GL_TRIANGLE_STRIP, 8, 4);
            
             glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
            extern  int blockTntMap[NUM_BLOCKS+1];
            int subtype=blockTntMap[type];
            if (block_paintcolor!=0) {
                Vector clr=colorTable[block_paintcolor];
                glColor4f(clr.x,clr.y,clr.z,1.0f);
            }
           // else if(subtype==TYPE_GRASS2||subtype==TYPE_GRASS3||subtype==TYPE_TNT||subtype==TYPE_FIREWORK||subtype==TYPE_BRICK||subtype==TYPE_VINE)
            //    glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
            else{
                glColor4ub(blockColor[subtype][0], blockColor[subtype][1], blockColor[subtype][2], 255);
            }
            if(subtype==TYPE_TNT||subtype==TYPE_FIREWORK||subtype==TYPE_LADDER){
                 tp= Resources::getResources->getBlockTex(blockTypeFaces[subtype][3]);
                if(subtype==TYPE_TNT){
                     tp= Resources::getResources->getBlockTex(TEX_TNT_SIDE_COLOR);
                }
            }else
           tp= Resources::getResources->getBlockTex(blockTypeFaces[subtype][5]);
            if(subtype==TYPE_GLASS){
                  tp= Resources::getResources->getBlockTex(TEX_CLOUD);
            }else if(subtype==TYPE_WATER){
                 tp= Resources::getResources->getBlockTex(TEX_DIRT);
            }else if(subtype==TYPE_LAVA){
                 tp= Resources::getResources->getBlockTex(TEX_DIRT);
            }else if(subtype==TYPE_WEAVE){
                 tp= Resources::getResources->getBlockTex(TEX_CLOUD);
            }
            GLfloat				coordinates3[] = {
                0,			tp.y+tp.x,
                1,			tp.y+tp.x,
                0,				tp.x,
                1,				tp.x,
                
                
                1,			tp.y+tp.x,
                 0,			tp.y+tp.x	,
                1,			tp.x,
               
                0,				tp.x,
                
                
                
                0,			tp.y+tp.x,
                1,			tp.y+tp.x,
                0,				tp.x,
                1,				tp.x,
            };

             glTexCoordPointer(2, GL_FLOAT, 0, coordinates3);
            
             glDrawArrays(GL_TRIANGLE_STRIP, 4, 4);
        }else{
       glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        glDrawArrays(GL_TRIANGLE_STRIP, 4, 4);
        glDrawArrays(GL_TRIANGLE_STRIP, 8, 4);
        }
    }
    
    glColor4f(1.0f,1.0f,1.0f,1.0f);
    if(type>=TYPE_STONE_RAMP1&&type<=TYPE_ICE_RAMP4){
             
        if(build_size!=0)
        Resources::getResources->getTex(ICO_BUILD3_TOP)->drawTextHalfsies(recto);
        else
         Resources::getResources->getTex(ICO_BUILD3_TOP2)->drawTextHalfsies(recto);
        Resources::getResources->getTex(ICO_BUILD_PLUS)->drawTextHalfsies(recto);
    }else{
        if(build_size!=0)
        Resources::getResources->getTex(ICO_BUILD2_TOP)->drawTextHalfsies(recto);
        else {
             Resources::getResources->getTex(ICO_BUILD_OVER2)->drawTextHalfsies(recto);
        }
        
         Resources::getResources->getTex(ICO_BUILD_PLUS)->drawTextHalfsies(recto);
    }
    //vertices[v_idx].texs[0]=cubeTexture[st]*size;		
    
    //vertices[v_idx].texs[1]=cubeTexture[st+1]*tp.y+tp.x;
    
   
	
}

void Hud::renderMenuScreen(){
    
	//glDisable(GL_TEXTURE_2D);
	//glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
          glColor4f(1.0,1.0,1.0,at1);
	
    if(rcam.pressed||rtCam.pressed)rcam.pressed=rtCam.pressed=TRUE;
    if(rsave.pressed||rtSave.pressed)rsave.pressed=rtSave.pressed=TRUE;
    if(rexit.pressed||rtExit.pressed)rexit.pressed=rtExit.pressed=TRUE;
    if(rhome.pressed||rtHome.pressed)rhome.pressed=rtHome.pressed=TRUE;
    
    //if(!IS_WIDESCREEN)
	Resources::getResources->getTex(ICO_COLOR_SELECT_BACKGROUND)->drawInRect(rmenuframe);
	//
	
		Resources* res=Resources::getResources;
	Texture2D* tsave=res->getTex(ICO_SAVE);
	Texture2D* thome=res->getTex(ICO_HOME);
	Texture2D* texit=res->getTex(ICO_EXIT);
	Texture2D* tcam=res->getTex(ICO_SCREENSHOT);
    
    
    

		tsave->drawButton(rsave);
  
   // printg("rtExit.x:%f  rtCam.x:%f\n",rtExit.origin.x, rtCam.origin.x);
    res->getTex(ICOT_SAVE)->drawButton(rtSave);
    res->getTex(ICOT_HOME)->drawButton(rtHome);
    res->getTex(ICOT_PHOTO)->drawButton(rtCam);
    res->getTex(ICOT_EXIT)->drawButton(rtExit);
	thome->drawButton( rhome);
	texit->drawButton( rexit);
	tcam->drawButton( rcam);
	
	
	return;
}


void Hud::renderBlockScreen(){
    float alpha=at2;
	//glDisable(GL_TEXTURE_2D);
	//glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glColor4f(1.0, 1.0, 1.0, at2);	
	CGRect rblocksframe;
	rblocksframe.origin.x=marginLeft2;
    
	rblocksframe.origin.y=marginVert+10;
	rblocksframe.size.width=402;
	rblocksframe.size.height=282;
    
	Resources::getResources->getTex(ICO_COLOR_SELECT_BACKGROUND)->drawInRect(rblocksframe);
	//
	
	glColor4f(1.0, 1.0, 1.0, at2);	
	//glEnable(GL_TEXTURE_2D);
    
	int golden_cubei;
	for(int i=0;i<NUM_DISPLAY_BLOCKS;i++){
        int type=hudBlocks[i];
        if(pickSecondBlock&&hudBlocksMap[hudBlocks[i]]==-1){
            alpha=0.5f;
             glColor4f(1.0f,1.0f,1.0f,alpha);
        }else{
            alpha=at2;
             glColor4f(1.0f,1.0f,1.0f,alpha);
        }
        if(build_size==0){/*blockBounds[i].size.width-=10;
            blockBounds[i].size.height-=10;
            blockBounds[i].origin.x+=0;
            blockBounds[i].origin.y+=1;*/
        }
        if(build_size==2){blockBounds[i].size.width+=10;
            blockBounds[i].size.height+=10;
        }
        if(type>=TYPE_STONE_RAMP1&&type<=TYPE_ICE_RAMP4){
            
            
            if(blocktype_pressed==hudBlocks[i]){
                 if(build_size==0){
                      Resources::getResources->getTex(ICO_TRIANGLE_BORDER_PRESSED2)->drawText(blockBounds[i]);
                 }else{
                     
                      Resources::getResources->getTex(ICO_TRIANGLE_BORDER_PRESSED)->drawText(blockBounds[i]);
                     
                 }
            }
               
            else{
                if(build_size==0){
                    Resources::getResources->getTex(ICO_TRIANGLE_BORDER2)->drawText(blockBounds[i]);
                } else {
                    if(pickSecondBlock&&hudBlocksMap[hudBlocks[i]]!=-1){
                        if(IS_IPAD&&!SUPPORTS_RETINA){
                            blockBounds[i].origin.x-=26/SCALE_WIDTH;
                            blockBounds[i].origin.y-=26/SCALE_HEIGHT;
                            
                            Resources::getResources->getTex(ICO_TRIANGLE_BORDER_ACTIVE)->drawText(blockBounds[i]);
                            blockBounds[i].origin.x+=26/SCALE_WIDTH;
                            blockBounds[i].origin.y+=26/SCALE_HEIGHT;
                            
                        }else{
                        blockBounds[i].origin.x-=13;
                        blockBounds[i].origin.y-=13;
                       
                        Resources::getResources->getTex(ICO_TRIANGLE_BORDER_ACTIVE)->drawText(blockBounds[i]);
                        blockBounds[i].origin.x+=13;
                        blockBounds[i].origin.y+=13;
                            
                        }
                    }else{
                     Resources::getResources->getTex(ICO_TRIANGLE_BORDER)->drawText(blockBounds[i]);
                        }
                }
            }
               
        }else if(type==TYPE_FLOWER||type==TYPE_GOLDEN_CUBE||type==TYPE_PORTAL_TOP||type==TYPE_DOOR_TOP){
            Button b=ButtonFromRect(blockBounds[i]);
            
            if(blocktype_pressed==hudBlocks[i])
                b.pressed=TRUE;
            else {
                b.pressed=FALSE;
            } 
            int tid;
            if(type==TYPE_FLOWER){
                tid=ICO_FLOWER_ICO;
            }else if(type==TYPE_GOLDEN_CUBE){
                golden_cubei=i;
                
                tid=ICO_GOLDCUBE;
        }else if(type==TYPE_PORTAL_TOP){
                tid=ICO_PORTAL2;
               // glColor4f(2000/255.0,150/255.0,255/255.0f,at2);
            }else if(type==TYPE_DOOR_TOP){
                tid=ICO_DOOR2;
            }
            if(tid==ICO_GOLDCUBE&&goldencubes==0){
                glColor4f(1.0f,1.0f,1.0f,.3f);
                Resources::getResources->getTex(tid)->drawButton(b);
                glColor4f(1.0f,1.0f,1.0f,alpha);
            }else{
                Resources::getResources->getTex(tid)->drawButton(b);
            }
        }else if(type==TYPE_CUSTOM){
           
        }else{
            if(blocktype_pressed==hudBlocks[i])
                if(build_size==0){
                    
                    Resources::getResources->getTex(ICO_BLOCK_BORDER_PRESSED2)->drawText(blockBounds[i]);
                }else{
                Resources::getResources->getTex(ICO_BLOCK_BORDER_PRESSED)->drawInRect2(blockBounds[i]);
                }
            else{
                if(build_size==0){
                    Resources::getResources->getTex(ICO_BLOCK_BORDER2)->drawText(blockBounds[i]);
                }else{
                    if(pickSecondBlock&&hudBlocksMap[hudBlocks[i]]!=-1){
                        if(IS_IPAD&&!SUPPORTS_RETINA){
                            blockBounds[i].origin.x-=26/SCALE_WIDTH;
                            blockBounds[i].origin.y-=26/SCALE_HEIGHT;
                            
                             Resources::getResources->getTex(ICO_BLOCK_BORDER_ACTIVE)->drawText(blockBounds[i]);
                            blockBounds[i].origin.x+=26/SCALE_WIDTH;
                            blockBounds[i].origin.y+=26/SCALE_HEIGHT;
                            
                        }else{
                        blockBounds[i].origin.x-=13;
                        blockBounds[i].origin.y-=13;
                        Resources::getResources->getTex(ICO_BLOCK_BORDER_ACTIVE)->drawText(blockBounds[i]);
                        blockBounds[i].origin.x+=13;
                        blockBounds[i].origin.y+=13;
                        }
                    }else{
                    Resources::getResources->getTex(ICO_BLOCK_BORDER)->drawText(blockBounds[i]);
                    }
                }
            }
        }
        if(type==TYPE_PORTAL_TOP){
           
            glColor4f(1.0,1.0,1.0f,alpha);
        }
        if(build_size==0){/*blockBounds[i].size.width+=10;
            blockBounds[i].size.height+=10;
            blockBounds[i].origin.x-=0;
            blockBounds[i].origin.y-=1;*/
        }
        if(build_size==2){blockBounds[i].size.width-=10;
            blockBounds[i].size.height-=10;
        }
		
	}
	//glDisable(GL_BLEND);
    glBindTexture(GL_TEXTURE_2D, Resources::getResources->atlas->name);
	for(int i=0;i<NUM_DISPLAY_BLOCKS;i++){
        if(pickSecondBlock&&hudBlocksMap[hudBlocks[i]]==-1){
            alpha=0.5f;
             glColor4f(1.0f,1.0f,1.0f,alpha);
        }else {alpha=at2;
            
             glColor4f(1.0f,1.0f,1.0f,alpha);
        }
        
		int type=hudBlocks[i];
        if(type==TYPE_FLOWER||type==TYPE_GOLDEN_CUBE||type==TYPE_DOOR_TOP||type==TYPE_PORTAL_TOP||type==TYPE_CUSTOM)continue;
            
        if(blockinfo[type]&IS_ATLAS2){
            glBindTexture(GL_TEXTURE_2D, Resources::getResources->atlas2->name);
        }else{
            glBindTexture(GL_TEXTURE_2D, Resources::getResources->atlas->name);
        }
		CGRect rect=blockBounds[i];
		CGPoint tp;
		if(type==TYPE_TNT||type==TYPE_LADDER||type==TYPE_FIREWORK||type==TYPE_BLOCK_TNT){
            if(type==TYPE_TNT)
                tp=Resources::getResources->getBlockTex(TEX_TNT_SIDE_COLOR);
            else if(type==TYPE_FIREWORK){
                
                tp=Resources::getResources->getBlockTex(TEX_FIREWORK);
            }else if(type==TYPE_BLOCK_TNT){
                 tp=Resources::getResources->getBlockTex(TEX_BLOCKTNT);
            }else
            tp=Resources::getResources->getBlockTex(blockTypeFaces[type][3]);
		}else{
             if(type==TYPE_BRICK)
                 tp=Resources::getResources->getBlockTex(TEX_BRICK_COLOR);
            else
            tp=Resources::getResources->getBlockTex(blockTypeFaces[type][5]);
		}
		GLfloat				coordinates[] = {
			0,			tp.y+tp.x,
			1,			tp.y+tp.x,
			0,				tp.x,
			1,				tp.x,
            
            0,			tp.y+tp.x,
			1,			tp.y+tp.x,
			0,				tp.x,
			1,				tp.x,
            
            0,			tp.y+tp.x,
			1,			tp.y+tp.x,
			0,				tp.x,
			1,				tp.x,
		};
        GLfloat				coordinates2[] = {
			0,			tp.y+tp.x,
			1,			tp.y+tp.x,
			//0,				tp.x,
			0,				tp.x,
		};
        
        int bb=0;
        if(blocktype_pressed==hudBlocks[i]){
            bb=2;
        }
        int size=35;
        if(build_size==0){size=25;
            rect.origin.x+=5;
            rect.origin.y+=5;
        }
        if(build_size==2)size=45;
        float off=3;
        if(IS_IPAD){
            rect.origin.x*=SCALE_WIDTH;
            rect.origin.y*=SCALE_HEIGHT;
            if(IS_RETINA&&build_size==0){rect.origin.x+=1;
                rect.origin.y+=2;}
            size*=2;
            bb*=2;
            off*=2;
        }
        int depth=25;
        GLfloat				bvertices[] = {
			off+bb,			off-bb,							0,
			size+bb,		off-bb,							0,
			off+bb,			size-bb,                        0,
			size+bb,		size-bb,                        0,
            
            //off+bb,			off-bb,							0,
			//size+bb,		off-bb,							0,
			off+bb,			size-bb,                        0,
			size+bb,		size-bb,                        0,
            off+bb+depth,			size-bb+depth,          0,
			size+bb+depth,		size-bb+depth,              0,
            
            size+bb,			off-bb,							0,
			size+bb+depth,		off-bb+depth,							0,
			size+bb,			size-bb,                        0,
			size+bb+depth,		size-bb+depth,                        0,

		};
        
        
		GLfloat				vertices[3*6*3]; 
        for(int i=0;i<3*6*2;i+=3){
            vertices[i]=bvertices[i]+rect.origin.x;
            vertices[i+1]=bvertices[i+1]+rect.origin.y;
            vertices[i+2]=bvertices[i+2];
        }
      
        GLfloat				vertices2[] = {
			rect.origin.x+off+bb,							rect.origin.y+off-bb,			0,
			rect.origin.x + size+bb,		rect.origin.y+off-bb,							0,
			//rect.origin.x+off+bb,							rect.origin.y + size-bb,		0,
			rect.origin.x + off+bb,		rect.origin.y + size-bb,		0
		};
		 if(type==TYPE_FIREWORK||type==TYPE_GRASS2||type==TYPE_GRASS3||type==TYPE_TNT||type==TYPE_BLOCK_TNT||type==TYPE_BRICK||type==TYPE_VINE)
             glColor4f(1.0f, 1.0f, 1.0f, alpha);
        else
		glColor4ub(blockColor[type][0], blockColor[type][1], blockColor[type][2], alpha*255);
        
        
		if(type==TYPE_CLOUD&&holding_creature){
            glVertexPointer(3, GL_FLOAT, 0, vertices);
            glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            glColor4f(1.0f, 1.0f, 1.0f, alpha);
            
            Resources::getResources->getTex(ICO_MOOF)->drawTextNoScale(
            CGRectMake(rect.origin.x+off+bb, rect.origin.y+off-bb,32, 32));
        }else
        if(type>=TYPE_STONE_RAMP1&&type<=TYPE_ICE_RAMP4){
		glVertexPointer(3, GL_FLOAT, 0, vertices2);
		glTexCoordPointer(2, GL_FLOAT, 0, coordinates2);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 3);
        }else{
            glVertexPointer(3, GL_FLOAT, 0, vertices);
            glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
           glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
         //   glDrawArrays(GL_TRIANGLE_STRIP, 4, 4);
          //  glDrawArrays(GL_TRIANGLE_STRIP, 8, 4);
        }
        
       
		//vertices[v_idx].texs[0]=cubeTexture[st]*size;		
        
		//vertices[v_idx].texs[1]=cubeTexture[st+1]*tp.y+tp.x;
	}
    if(TRUE){
       
        CGRect num_rect=blockBounds[golden_cubei];
        num_rect.origin.x+=18;
        if(goldencubes!=10){
            num_rect.origin.x+=3;
        }
        num_rect.origin.y-=2;
        if(goldencubes==0){
            glColor4f(1.0f,1.0f,1.0f,.3f);
        Resources::getResources->getTex(TEXT_NUMBERS)->drawNumbers(num_rect,goldencubes);
            glColor4f(1.0f,1.0f,1.0f,1.0f);
        }else{
            Resources::getResources->getTex(TEXT_NUMBERS)->drawNumbers(num_rect,goldencubes);
            
        }
    }
	/*
    glColor4f(1.0, 1.0, 1.0, 1.0f);
    glEnable(GL_BLEND);
    for(int i=0;i<NUM_DISPLAY_BLOCKS;i++){
        int type=hudBlocks[i];
        if(build_size==0){blockBounds[i].size.width-=10;
            blockBounds[i].size.height-=10;
        }
               if(build_size==2){blockBounds[i].size.width+=10;
            blockBounds[i].size.height+=10;
        }
        if(type>=TYPE_STONE_RAMP1&&type<=TYPE_ICE_RAMP4){
            if(pressed==i)
                Resources::getResources->getTex:ICO_TRIANGLE_BORDER_PRESSED] drawInRect2:blockBounds[i]];
            else
                Resources::getResources->getTex:ICO_TRIANGLE_BORDER] drawInRect2:blockBounds[i]];
        }else{
            if(pressed==i)
                Resources::getResources->getTex:ICO_BLOCK_BORDER_PRESSED] drawInRect2:blockBounds[i]];
            else
                Resources::getResources->getTex:ICO_BLOCK_BORDER]->drawText(blockBounds[i]];
        }
                if(build_size==0){blockBounds[i].size.width+=10;
            blockBounds[i].size.height+=10;
        }
        if(build_size==2){blockBounds[i].size.width-=10;
            blockBounds[i].size.height-=10;
        }
        
    }*/

	/*
     Resources* res=Resources getResources];
     Texture2D* tsave=[res getTex:ICO_SAVE];	
     Texture2D* thome=[res getTex:ICO_HOME];	
     Texture2D* texit=[res getTex:ICO_EXIT];	
     Texture2D* tcam=[res getTex:ICO_SCREENSHOT];
     [tsave drawInRect2: rsave];		
	[thome drawInRect2: rhome];		
	[texit drawInRect2: rexit];	
	[tcam drawInRect2: rcam];*/
	
	
	return;
}
//extern float P_ZFAR;


void Hud::render(){
	//if(mode==MODE_MINE)return;
    Graphics::beginHud();
   
	if(mode==MODE_CAMERA){
        Graphics::setCameraFog(40);
        
		if(take_screenshot){
			if(!SUPPORTS_OGL2){
                Graphics::setZFAR(40);
                
              
                if(World::getWorld->terrain->tgen->LEVEL_SEED== 0){
                     Graphics::setZFAR(55);
                    
                }
            }
			//else P_ZFAR=70.0f;
			takeScreenshot();
			flash=1.0;
            flashcolor=MakeVector(1.0,1.0,1.0);
			take_screenshot=FALSE;
			mode=MODE_BUILD;
			Resources::getResources->playSound(S_CAMERA);
		}
        glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        sb->render();
        Graphics::endHud();
		
		return;
	}else{
        if(!SUPPORTS_OGL2){
            Graphics::setZFAR(40);
            
            
            if(World::getWorld->terrain->tgen->LEVEL_SEED== 0){
                Graphics::setZFAR(55);
                
            }
        }else{
            Graphics::setZFAR(40);
            
        }
       // if(!SUPPORTS_OGL2)P_ZFAR= 20.0f;
       // else P_ZFAR=70.0f;
    }
    lmode=mode;
	if(hideui){
        Graphics::endHud();
       
      return;  
    }
	
	
	
	glColor4f(1.0, 1.0, 1.0, 1.0f);
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	//NSString* sfps=[NSString stringWithFormat:@"FPS:%3d",(int)fps];
	
	//[Graphics->drawText(sfps:10:10];
    
	
	
   	
	//glDisable(GL_TEXTURE_2D);
	//glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
    Resources* res=Resources::getResources;
	
	//Texture2D* tcam=[res getTex:ICO_CAMERA];
	//Texture2D* tbuild=[res getTex:ICO_BUILD];	
	Texture2D* tmine=res->getTex(ICO_MINE);
	Texture2D* tburn=res->getTex(ICO_BURN);
	Texture2D* tjump=res->getTex(ICO_JUMP);
    Texture2D* tpaint=res->getPaintTex(paintColor);
	//Texture2D* tback=[res getTex:ICO_BACK];
	
	glColor4f(1.0, 1.0, 1.0, 1.0f);
    Button glowbox;
	if(mode==MODE_PICK_BLOCK||mode==MODE_BUILD){
        glowbox=rbuild;
        
    }else if(mode==MODE_BURN){
        glowbox=rburn;
        
    }else if(mode==MODE_PAINT||mode==MODE_PICK_COLOR){
        glowbox=rpaint;
    }else if(mode==MODE_MINE){
        glowbox=rmine;
    }
    
    if(mode!=MODE_NONE){
       /* glowbox.origin.x-=glowbox.size.width/2;
        glowbox.origin.y-=glowbox.size.height/2;
        glowbox.size.width*=2;
        glowbox.size.height*=2;       */ 
      //  [[res getTex:ICO_HIGHLIGHT] drawInRect2:glowbox];
    }
	glColor4f(1.0, 1.0, 1.0, 1.0f);
	if(mode==MODE_PICK_BLOCK){
		//glColor4f(1.0, 0.0, 0.0, 1.0f);
        renderBlockAndBorder(RectFromButton(rbuild));
	//[tbuild drawInRect2: rbuild];
    }else {
        renderBlockAndBorder(RectFromButton(rbuild));
        
    }
	glColor4f(1.0, 1.0, 1.0, 1.0f);
    float offsetx;
    float offsety;

    if(IS_IPAD&&!SUPPORTS_RETINA){
       offsetx=(128-90)/2.0f/SCALE_WIDTH;
        offsety=(128-90)/2.0f/SCALE_HEIGHT;

        
    }else{
        offsetx=(128-90)/2.0f/2.0f;
      offsety=(128-90)/2.0f/2.0f;

    }
       if(IS_IPAD&&!SUPPORTS_RETINA){
      //  offsetx-=1;
     //   offsety-=2;
    }
	if(mode==MODE_MINE){
        glowbox=rmine;
        glowbox.origin.x-=offsetx;
        glowbox.origin.y-=offsety;
        res->getTex(ICO_MINE_ACTIVE)->drawButton(glowbox);
    }else
	tmine->drawButton( rmine);
	
    if(rmine.origin.x!=HUDR_X){
        
        printf("wtf: %f  chek1:%x  check2:%x\n",rmine.origin.x,(unsigned int)(&flashcolor),(unsigned int)&(World::getWorld->hud->flashcolor));
        
        printf("break here");
    }
    
	if(mode==MODE_BURN){
        glowbox=rburn;
        glowbox.origin.x-=offsetx;
        glowbox.origin.y-=offsety;
        res->getTex(ICO_BURN_ACTIVE)->drawButton(glowbox);
    }else
	tburn->drawButton(rburn);
    
    
	if(mode==MODE_PAINT||mode==MODE_PICK_COLOR){
        glowbox=rpaint;
        glowbox.origin.x-=offsetx;
        glowbox.origin.y-=offsety;
        res->getTex(ICO_PAINT_ACTIVE)->drawButton(glowbox);
        tpaint->drawButton( rpaint);
    }else
   	tpaint->drawButton( rpaint);
    
	
	if(m_jump){
        rjumprender.pressed=TRUE;
        res->getTex(ICO_JUMP_ACTIVE)->drawButton(rjumprender);
	}else{
        rjumprender.pressed=FALSE;
        tjump->drawButton(rjumprender);
    }
	
	
	
	res->getTex(ICO_OPEN_MENU)->drawButton(rmenu);
    if(inmenu||at1>0){
        
      
        renderMenuScreen();
    }
	
	if(use_joystick){
		glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		joystick->render();
	}
	else{
		glBlendFunc (GL_SRC_ALPHA, GL_ONE);
		//[gamepad render);
		glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	}
	
	glColor4f(1.0, 1.0, 1.0, 1.0);
    
	sb->render();
	if(mode==MODE_PICK_BLOCK||at2>0){
		renderBlockScreen();
	}
    if(mode==MODE_PICK_COLOR||at3>0){
       renderColorPickScreen();
    }
    if(underLiquid){
        //NSLog(@"%f",flash);
		glDisable(GL_TEXTURE_2D);
		glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glColor4f(liquidColor.x, liquidColor.y, liquidColor.z, 0.5f);
        if(IS_IPAD){
            if(IS_RETINA){
                Graphics::drawRect(0,0,SCREEN_WIDTH*2,SCREEN_HEIGHT*2);
                
            }else
                Graphics::drawRect(0,0,IPAD_WIDTH,IPAD_HEIGHT);
            
           
        }else
            Graphics::drawRect(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
        
		glEnable(GL_TEXTURE_2D);

    }
	if(flash>0||World::getWorld->player->flash>0){
        printf("hello\n");
        /*
		//NSLog(@"%f",flash);
		glDisable(GL_TEXTURE_2D);
		glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        if(flash>0){
           
            
		glColor4f(flashcolor.x, flashcolor.y, flashcolor.z, flash);
        }else
         glColor4f(1.0, 0.0, 0.0, World::getWorld->player->flash);
        
        if(IS_IPAD){
            if(IS_RETINA){
                Graphics::drawRect(0,0,SCREEN_WIDTH*2,SCREEN_HEIGHT*2);
                
            }else{
            
                Graphics::drawRect(0,0,IPAD_WIDTH,IPAD_HEIGHT);
            }
            
        }else
            Graphics::drawRect(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
		glEnable(GL_TEXTURE_2D);*/
        
		
	}
    if(fade_out>0){
        glColor4f(0,0,0,fade_out);
        glDisable(GL_TEXTURE_2D);
		glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        if(IS_IPAD){
            if(IS_RETINA){
                Graphics::drawRect(0,0,SCREEN_WIDTH*2,SCREEN_HEIGHT*2);
                
            }else{
                
                Graphics::drawRect(0,0,IPAD_WIDTH,IPAD_HEIGHT);
            }
        }else
            Graphics::drawRect(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
		glEnable(GL_TEXTURE_2D);

    }
  /*  glDisable(GL_TEXTURE_2D);
    glColor4f(test2.x,test2.y,test2.z,1.0f);
    
    [Graphics drawRect:test2r.origin.x:test2r.origin.y:test2r.size.width:test2r.size.height);
    glColor4f(test1.x,test1.y,test1.z,1.0f);
   
     [Graphics drawRect:test1r.origin.x:test1r.origin.y:test1r.size.width:test1r.size.height);
   */

    glColor4f(1.0f,1.0f,1.0f,1.0f);
  
    glEnable(GL_TEXTURE_2D);
    
    Graphics::endHud();
    
}

void Hud::asetHome(){
    
    Vector thome;
    Vector pp=World::getWorld->player->pos;
    thome.x=pp.x-.5f;
    thome.z=pp.z-.5f;
    thome.y=pp.y-1;
    World::getWorld->terrain->home=thome;
    World::getWorld->fm->saveWorld();
    //[World::getWorld->terrain updateAllImportantChunks);
    //NSLog(@"saving..");
    Input::getInput()->clearAll();
    
    World::getWorld->terrain->startDynamics();
    sb->setStatus(@"World Saved",3);

}
void Hud::awarpHome(){
    delayedtimer=2;
    delayedaction=6;
    
    
    sb->setStatus(@"Saving and warping home.." ,999);
}

//@end
