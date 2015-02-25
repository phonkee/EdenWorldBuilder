//
//  Joystick.m
//  prototype
//
//  Created by Ari Ronen on 12/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Joystick.h"


#import "Joystick.h"
#import "Graphics.h"
#import "Input.h"
#import "Util.h"
#import "Hud.h"


CGRect padbounds;
CGRect joystick_pos,default_pos;
Vector pos;

Joystick::Joystick(){
	padbounds.origin.x=20;padbounds.origin.y=20;
	padbounds.size.width=88;
	padbounds.size.height=88;
	default_pos.size.width=default_pos.size.height=88;
	default_pos.origin.x=(padbounds.size.width/2)-default_pos.size.width/2+20;
	default_pos.origin.y=(padbounds.size.height/2)-default_pos.size.height/2+20;
	joystick_pos=default_pos;
	pos.x=pos.y=pos.z=0;
	
}
static const int usage_id=999;

BOOL Joystick::update(float etime){
	Input* input=Input::getInput();
	//Hud* hud=[World getWorld].hud;
    itouch* touches=input->getTouches();
	BOOL handled=FALSE;	
	for(int i=0;i<MAX_TOUCHES;i++){
			
		
		if((touches[i].inuse==0||touches[i].inuse==usage_id)&&touches[i].down==M_DOWN){
			if(inbox(touches[i].mx,touches[i].my,padbounds)||touches[i].inuse==usage_id){
				if(touches[i].mx>padbounds.origin.x+padbounds.size.width){
					//touches[i].mx=padbounds.origin.x+padbounds.size.width;
				}
				if(touches[i].my>padbounds.origin.y+padbounds.size.height){
					//touches[i].my=padbounds.origin.y+padbounds.size.height;
				}
				joystick_pos.origin.x=touches[i].mx-joystick_pos.size.width/2;
				joystick_pos.origin.y=touches[i].my-joystick_pos.size.height/2;
				//NSLog(@"%f",joystick_pos.origin.x);
				if(joystick_pos.origin.x<-6)joystick_pos.origin.x=-6;
				if(joystick_pos.origin.y<-7)joystick_pos.origin.y=-7;
				if(joystick_pos.origin.x+joystick_pos.size.width>padbounds.size.width+47)
					joystick_pos.origin.x=padbounds.size.width-joystick_pos.size.width+47;
				if(joystick_pos.origin.y+joystick_pos.size.height>padbounds.size.height+47)
					joystick_pos.origin.y=padbounds.size.height-joystick_pos.size.height+47;
				pos.x=touches[i].mx-(default_pos.origin.x+default_pos.size.width/2);
				pos.y=touches[i].my-(default_pos.origin.x+default_pos.size.width/2);
				float mag=sqrt(pos.x*pos.x+pos.y*pos.y);
				//NSLog(@"%f",mag);
				NormalizeVector(&pos);
				mag/=65;
                if(mag>1.3f)mag=1.3f;
				//pos.x*=mag;
				//pos.y*=mag;
				[[World getWorld].player setSpeed:pos:mag];
               // printg("magnitude:%f\n",mag);
				handled=TRUE;	
				touches[i].inuse=usage_id;	
			}		
		}
		if(handled){
						
		}else{
			joystick_pos.origin.x=default_pos.origin.x;
			joystick_pos.origin.y=default_pos.origin.y;
			pos.x=0;
			pos.y=0;
			[[World getWorld].player setSpeed:pos:0];
		}
		
		if(touches[i].inuse==usage_id&&touches[i].down==M_RELEASE){			
			touches[i].down=M_NONE;
		}	
		
	}
	//[[World getWorld].player setSpeed:MakeVector(0,1,0),40];

	return FALSE;
}
void Joystick::render(){
	Resources* res=[Resources getResources];
	
	Texture2D* gamepad=[res getTex:ICO_JOYSTICK_FRONT];
	glColor4f(1.0, 1.0, 1.0, 0.35f);	
	//glDisable(GL_BLEND);
	
	//glBlendFunc (GL_SRC_ALPHA, GL_ONE);
	
	[gamepad drawInRect2:padbounds];
	glColor4f(1.0, 1.0, 1.0, 1.0f);
	Texture2D* joystick=[res getTex:ICO_JOYSTICK_BACK];
	[joystick drawInRect2:joystick_pos];
	//glEnable(GL_BLEND);

	
	
}

