//
//  Gamepad.m
//  prototype
//
//  Created by Ari Ronen on 11/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Gamepad.h"
#import "Graphics.h"
#import "Input.h"
#import "Util.h"
#import "Hud.h"

@implementation Gamepad
CGRect rects[4];
static CGRect padbounds;

-(id) init{
	padbounds.origin.x=0;padbounds.origin.y=0;
	padbounds.size.width=130;
	padbounds.size.height=130;
	afwd=aback=aright=aleft=FALSE;
	rback.origin.x=47;
	rback.origin.y=0;
	rback.size.width=50;
	rback.size.height=50;
	rfwd.origin.x=47;
	rfwd.origin.y=80;
	rfwd.size.width=50;
	rfwd.size.height=50;
	
	rleft.origin.x=0;
	rleft.origin.y=40;
	rleft.size.width=50;
	rleft.size.height=50;
	
	rright.origin.x=90;
	rright.origin.y=40;
	rright.size.width=50;
	rright.size.height=50;
	
	/*if(IS_IPAD){
		rright.origin.x+=15;
		rleft.origin.x+=15;
		rback.origin.x+=15;
		rfwd.origin.x+=15;
		rright.origin.y+=30;
		rleft.origin.y+=30;
		rback.origin.y+=30;
		rfwd.origin.y+=30;
		
	}*/
	
	rects[0]=rback;
	rects[1]=rfwd;
	rects[2]=rleft;
	rects[3]=rright;
	return self;
}
static const int usage_id=2007;
- (BOOL)update:(float)etime{
	Input* input=[Input getInput];	
	Hud* hud=[World getWorld].hud;
	itouch* touches=[input getTouches];
	hud.m_left=hud.m_right=hud.m_fwd=hud.m_back=FALSE;
	aleft=afwd=aright=aback=false;
	for(int i=0;i<MAX_TOUCHES;i++){
		BOOL handled=FALSE;		
		if(hud.mode!=MODE_PICK_BLOCK){

		if((touches[i].inuse==0||touches[i].inuse==usage_id)&&touches[i].down==M_DOWN){
			if(inbox(touches[i].mx,touches[i].my,padbounds)){
				handled=TRUE;				
			}
			if(inbox(touches[i].mx,touches[i].my,rfwd)){		
				hud.m_fwd=TRUE;
				handled=TRUE;	
				afwd=TRUE;
			}else
			if(inbox(touches[i].mx,touches[i].my,rleft)){
				hud.m_left=TRUE;
				handled=TRUE;	
				aleft=TRUE;				
			}else
			if(inbox(touches[i].mx,touches[i].my,rright)){		
				hud.m_right=TRUE;
				handled=TRUE;	
				aright=TRUE;				
			}else			
			if(inbox(touches[i].mx,touches[i].my,rback)){		
				hud.m_back=TRUE;
				handled=TRUE;	
				aback=TRUE;				
			}			
			if(handled){
				
				touches[i].inuse=usage_id;				
			}	
		}
		}
		if(touches[i].inuse==usage_id&&touches[i].down==M_RELEASE){			
			touches[i].down=M_NONE;
		}	
		
	}
	/*Input* input=[Input getInput];
	if(input.any_down){		
		
	}	*/
	return FALSE;
}
- (void)render{
	Resources* res=[Resources getResources];
	/*Texture2D* tleft=[res getTex:ICO_LEFT];
	Texture2D* tfwd=[res getTex:ICO_FWD];	
	Texture2D* tright=[res getTex:ICO_RIGHT];
	Texture2D* tback=[res getTex:ICO_BACK];*/
	Texture2D* gamepad=[res getTex:ICO_JOYSTICK_BACK];
	glColor4f(1.0, 1.0, 1.0, 1.0f);	
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	[gamepad drawInRect:padbounds];
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	/*if(aleft)
		glColor4f(1.0, 0, 0, 1.0);
	[tleft drawInRect:rleft];
	glColor4f(1.0, 1.0, 1.0, 1.0f);
	if(aright)
		glColor4f(1.0, 0, 0, 1.0);
	[tright drawInRect:rright];
	glColor4f(1.0, 1.0, 1.0, 1.0f);
	if(afwd)
		glColor4f(1.0, 0, 0, 1.0);
	[tfwd drawInRect:rfwd];
	glColor4f(1.0, 1.0, 1.0, 1.0f);
	if(aback)
		glColor4f(1.0, 0, 0, 1.0);
	[tback drawInRect:rback];	*/
	
}
@end
