//
//  Input.m
//  prototype
//
//  Created by Ari Ronen on 10/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Input.h"
#import "Globals.h"
#import "World.h"
#import "Hud.h"
static Input* singleton;
@implementation Input
extern float SCREEN_WIDTH; 
extern float SCREEN_HEIGHT;
extern float P_ASPECT_RATIO;
extern BOOL IS_WIDESCREEN;

+ (Input*)getInput{
	if(!singleton){
		singleton=[[Input alloc] init];
	}	
	return singleton;	
}
- (id)init{
	[self clearAll];	
    if(IS_IPAD&&!IS_RETINA){
        scr_width=IPAD_WIDTH;
        scr_height=IPAD_HEIGHT;
        
    }else{
        if(IS_WIDESCREEN)
        scr_width=IPHONE5_WIDTH;
        else
            scr_width=IPHONE_WIDTH;
        //IPHONE_WIDTH;
        scr_height=IPHONE_HEIGHT;
    }
	return self;
}
- (void)clearAll{
	
	for(int i=0;i<MAX_TOUCHES;i++){
		touches[i].mx=touches[i].my=0;	
		touches[i].pmx=touches[i].pmy=0;	
		touches[i].inuse=0;
		touches[i].down=M_NONE;
		touches[i].moved=0;
		touches[i].touch_id=NULL;
		touches[i].placeBlock=FALSE;	
	}
}

/*- (void)clearMove:(int)i{
	pmx=mx;
	pmy=my;
}*/

- (void)keyTyped:(NSString*) key{
	char ch=[key characterAtIndex:0];
	if(ch=='h'){
		[World getWorld].hud.hideui=![World getWorld].hud.hideui;	
	}
	
}
- (itouch*) getTouches{
	return touches;
	
}
- (void)touchesBegan:(NSSet *)mtouches withEvent:(UIEvent *)event{
	for(UITouch* touch in mtouches){	
		
		int idx=-1;
		for(int i=0;i<MAX_TOUCHES;i++){
			if(touches[i].down==M_NONE){
				idx=i;
				break;
			}
		}
		if(idx==-1){ //Too many touches, ignore
			continue;			
		}
		
		touches[idx].touch_id=touch;
		CGPoint point=[touch locationInView:touch.view];
        point.y=scr_height-point.y;
        printf("touch (%f,%f)\n",point.x,point.y);
		/*if([World getWorld].FLIPPED){
			//point.x+=11;
			point.x=scr_width-point.x;
			point.y=scr_height-point.y;
		}*/		
		touches[idx].down=M_DOWN;
     
		touches[idx].inuse=0;
		touches[idx].etime=0;
		touches[idx].moved=YES;
        if(IS_IPAD&&!IS_RETINA){
            touches[idx].mx=(float)point.x/SCALE_WIDTH;
            touches[idx].my=(float)point.y/SCALE_HEIGHT;
        }else{
            touches[idx].mx=point.x;
            touches[idx].my=point.y;
        }
		
		touches[idx].pmx=touches[idx].mx;
		touches[idx].pmy=touches[idx].my;
		touches[idx].fx=touches[idx].mx;
		touches[idx].fy=touches[idx].my;
		touches[idx].placeBlock=TRUE;	
		touches[idx].previewtype=TYPE_NONE;
		touches[idx].movecam=TRUE;
	}
}

- (void)touchesMoved:(NSSet *)mtouches withEvent:(UIEvent *)event{
	for(UITouch* touch in mtouches){			
	//	NSLog(@"touchm %@",touch);
		int idx=-1;
		for(int i=0;i<MAX_TOUCHES;i++){
			if(touches[i].touch_id==touch){
				idx=i;
				break;
			}
		}
		if(idx==-1){
			continue;
		}
		CGPoint point=[touch locationInView:touch.view];
        point.y=scr_height-point.y;
		/*if([World getWorld].FLIPPED){
			//point.x+=11;
			point.x=scr_width-point.x;
			point.y=scr_height-point.y;
		}*/
		touches[idx].moved=TRUE;
		touches[idx].pmx=touches[idx].mx;
		touches[idx].pmy=touches[idx].my;
		if(IS_IPAD&&!IS_RETINA){
            touches[idx].mx=(float)point.x/SCALE_WIDTH;
            touches[idx].my=(float)point.y/SCALE_HEIGHT;
        }else{
            touches[idx].mx=point.x;
            touches[idx].my=point.y;
        }
	}		
}
- (void)touchesEnded:(NSSet *)mtouches withEvent:(UIEvent *)event{
	for(UITouch* touch in mtouches){			
		//
		int idx=-1;
		for(int i=0;i<MAX_TOUCHES;i++){
			if(touches[i].touch_id==touch){
				idx=i;
				break;
			}
		}
		if(idx==-1){
			continue;
		}
        if(!touch)continue;
		CGPoint point=[touch locationInView:touch.view];
        point.y=scr_height-point.y;
		/*if([World getWorld].FLIPPED){
		//	point.x+=11;
			point.x=scr_width-point.x;
			point.y=scr_height-point.y;
		}	*/
		touches[idx].moved=TRUE;
		touches[idx].pmx=touches[idx].mx;
		touches[idx].pmy=touches[idx].my;
		if(IS_IPAD&&!IS_RETINA){
            touches[idx].mx=(float)point.x/SCALE_WIDTH;
            touches[idx].my=(float)point.y/SCALE_HEIGHT;
        }else{
            touches[idx].mx=point.x;
            touches[idx].my=point.y;
        }
		touches[idx].touch_id=0;
		if(touches[idx].inuse)
			touches[idx].down=M_RELEASE;
		else
			touches[idx].down=M_NONE;

	}
}
- (void)touchesCancelled:(NSSet *)mtouches withEvent:(UIEvent *)event{
	[self clearAll];	
}
@end

