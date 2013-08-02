//
//  Menu_background.m
//  prototype
//
//  Created by Ari Ronen on 1/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Menu_background.h"
#import "Graphics.h"
#import "Globals.h"
extern float SCREEN_WIDTH; 
extern float SCREEN_HEIGHT;

float pinwheelr=0;
float groundx=0;
float mountainx=0;

typedef struct _cloud{
	CGRect rect;
	struct _cloud* next;	
	int type;
	float speed;
}cloud;

static cloud* cloud_list;


@implementation Menu_background
-(id)init{
	cloud_list=NULL;
	clouds[0].origin.x=15;
    clouds[1].origin.x=300;
    clouds[2].origin.x=150;
    clouds[0].origin.y=150;
    clouds[1].origin.y=175;
    clouds[2].origin.y=90;
    for(int i=0;i<150;i++)
        [self update:1.0f];
	return self;
}
static float counter=0;
-(void)update:(float)etime{
	pinwheelr+=10*etime;
	groundx+=22*etime;
	if(groundx>480)groundx-=480;
    if(!IS_IPAD){
        mountainx+=10*etime;
        if(mountainx>835*2)mountainx-=835*2;
    }
    else{
	mountainx+=11*etime;
        if(mountainx>835*2)mountainx-=835*2;

    }
    clouds[2].origin.x+=12*etime;
    clouds[1].origin.x+=18*etime;
    clouds[0].origin.x+=20*etime;
	for(int i=0;i<3;i++){
        if(clouds[i].origin.x>480){
            clouds[i].origin.x=-75;
        }
    }
	cloud* node=cloud_list;
	cloud* prev=NULL;
	while(node!=NULL){
		node->rect.origin.x+=node->speed*etime;
        if(node->rect.origin.x>SCREEN_WIDTH){			
			if(prev){
				prev->next=node->next;
			}else{
                cloud_list=node->next;
            }
            cloud* next=node->next;

			free(node);	
            node=next;
		}else{
            prev=node;
            node=node->next;
        }
    }
    counter+=etime;
	if(counter>5){
        counter=0;
		int cloudoffsety=115;
		cloud* new_cloud=malloc(sizeof(cloud));
		new_cloud->next=cloud_list;
		new_cloud->type=arc4random()%3;
		//new_cloud->rect.origin.x=-122;
		//new_cloud->rect.origin.y=arc4random()%((int)(SCREEN_HEIGHT-85-44))+85;
		new_cloud->rect.origin.x=-175;
        if(new_cloud->type==0){
		new_cloud->rect.origin.y=cloudoffsety+(float)arc4random()/UINT_MAX*30;
            new_cloud->speed=12;
        }
        if(new_cloud->type==1){
        new_cloud->rect.origin.y=cloudoffsety+30+(float)arc4random()/UINT_MAX*40;
             new_cloud->speed=16;
        }
        if(new_cloud->type==2){
            new_cloud->rect.origin.y=cloudoffsety+80+(float)arc4random()/UINT_MAX*60;
             new_cloud->speed=20;
        }
		
		
		cloud_list=new_cloud;
		
	}
    
}
extern BOOL IS_WIDESCREEN;
-(void)render{
	
	CGRect bkg;
	bkg.origin.x=0;
	bkg.origin.y=0;
	bkg.size.width=SCREEN_WIDTH;
	bkg.size.height=SCREEN_HEIGHT;
	/*
	MENU_SKY=27,
	MENU_PINWHEEL=28,
	MENU_MOUNTAINS=29,
	MENU_GROUND=30,
	MENU_CLOUD_SM=31,
	MENU_CLOUD_MD=32,
	MENU_CLOUD_LG=33,*/
	[[[Resources getResources] getMenuTex:MENU_SKY] drawInRect:bkg];
	glPushMatrix();
	glBlendFunc (GL_SRC_ALPHA, GL_ONE);
    if(!IS_IPAD)
        glTranslatef(SCREEN_WIDTH/2,0,0);
    else if(IS_WIDESCREEN){
      //  printf("Wtf\n");
        glTranslatef(SCREEN_WIDTH,130,0);
    }else
        glTranslatef(IPAD_WIDTH/2,0,0);
	glRotatef(pinwheelr,0,0,-1);
	glScalef(2.5,2.5,2.5);
	bkg.origin.x-=SCREEN_WIDTH/2;
	bkg.origin.y-=SCREEN_HEIGHT/2;
    glColor4f(1.0,1.0,1.0,1.0f);
	[[[Resources getResources] getMenuTex:MENU_PINWHEEL] drawInRect:bkg];
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glPopMatrix();
	glColor4f(1.0,1.0,1.0,1.0);
    
    
    //642 c 85
    // for(int i=0;i<3;i++){
    //    [[[Resources getResources] getMenuTex:MENU_CLOUD] drawText:clouds[i]];
    //}
    cloud* node=cloud_list;
	if(node)
        
        while(node!=NULL){
            // NSLog(@" x:%f y:%f width:%f height:%f",node->rect.origin.x,node->rect.origin.y,
            //       node->rect.size.width,node->rect.size.height);
            Texture2D* tex=NULL;
            if(node->type==0)tex=[[Resources getResources] getMenuTex:MENU_CLOUD];
            if(node->type==1)tex=[[Resources getResources] getMenuTex:MENU_CLOUD2];
            if(node->type==2)tex=[[Resources getResources] getMenuTex:MENU_CLOUD3];
            
            [tex drawText:node->rect];
            node=node->next;
        }
    
    CGRect mountain;
	mountain.origin.x=mountainx;
    
	mountain.origin.y=0;
    mountain.size.height=456;
    mountain.size.width=835;
    
    [[[Resources getResources] getMenuTex:MENU_TREESLEFT] drawTextNoScale:mountain];
    mountain.origin.x+=835;
    [[[Resources getResources] getMenuTex:MENU_TREESRIGHT] drawTextNoScale:mountain];
    mountain.origin.x-=835;
    
    mountain.origin.x-=835*2;
    [[[Resources getResources] getMenuTex:MENU_TREESLEFT] drawTextNoScale:mountain];
    mountain.origin.x+=835;
    [[[Resources getResources] getMenuTex:MENU_TREESRIGHT] drawTextNoScale:mountain];
    mountain.origin.x-=835;
    
    mountain.origin.x+=835*2;
    
    
	CGRect ground;
	ground.origin.x=groundx;
	ground.origin.y=0;
	ground.size.height=25;
	ground.size.width=481;
	[[[Resources getResources] getMenuTex:MENU_GROUND] drawTextM:ground];
	ground.origin.x-=480;
	[[[Resources getResources] getMenuTex:MENU_GROUND] drawTextM:ground];
    if(IS_WIDESCREEN){
        ground.origin.x+=480*2;
        [[[Resources getResources] getMenuTex:MENU_GROUND] drawTextM:ground];
         ground.origin.x-=480*2;

    }
	ground.origin.x+=480;
	
    
   
    
    
    

    
    /*else{
        mountain.origin.y=139.0f/SCALE_HEIGHT;
        mountain.size.height=85;
        mountain.size.width=1025.0f/SCALE_WIDTH;
   
        [[[Resources getResources] getMenuTex:MENU_MOUNTAINS] drawTextNoScale:mountain];
        mountain.origin.x-=1024.0f/SCALE_WIDTH;
        [[[Resources getResources] getMenuTex:MENU_MOUNTAINS] drawTextNoScale:mountain];
        
        if(IS_WIDESCREEN){
            mountain.origin.x+=2*1024.0f/SCALE_WIDTH;
            [[[Resources getResources] getMenuTex:MENU_MOUNTAINS] drawTextNoScale:mountain];
            mountain.origin.x-=2*1024.0f/SCALE_WIDTH;
        }
        mountain.origin.x+=1025.0f/SCALE_WIDTH;
   
    }
    */
   
    
   
	
}
@end
