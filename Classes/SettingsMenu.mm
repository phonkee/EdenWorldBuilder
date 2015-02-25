//
//  SettingsMenu.m
//  prototype
//
//  Created by Ari Ronen on 11/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingsMenu.h"
#import "Graphics.h"
#import "Globals.h"
#import "Util.h"
#import "World.h"


enum  {
	
	//S_LEFTY_MODE=1,	
	S_PLAY_MUSIC=4,
	S_PLAY_SOUND=3,
    S_HEALTH=2,
	S_AUTOJUMP=1,
    S_CREATURES=0,
};
static NSString* pnames[NUM_PROP]={
	[S_HEALTH]=@"Health",
//	[S_LEFTY_MODE]=@"Lefty Controls",
	[S_PLAY_MUSIC]=@"Music",
	[S_PLAY_SOUND]=@"Sound Effects",
	[S_AUTOJUMP]=@"Autojump",
    [S_CREATURES]=@"Creatures"
};
static const int pdefaults[NUM_PROP]={
	[S_HEALTH]=TRUE,
//	[S_LEFTY_MODE]=FALSE,
	[S_PLAY_MUSIC]=TRUE,
	[S_PLAY_SOUND]=TRUE,
	[S_AUTOJUMP]=TRUE,
    [S_CREATURES]=TRUE,
};
extern float SCREEN_WIDTH; 
extern float SCREEN_HEIGHT;
extern float P_ASPECT_RATIO;

SettingsMenu::SettingsMenu(){
	for(int i=0;i<NUM_PROP;i++){
		properties[i].name=pnames[i];
		properties[i].value=pdefaults[i];
       
       
		properties[i].box.origin.x=37-10+30;
		
		properties[i].box.size.height=30;
		properties[i].box.origin.y=i*40+68;
		
		if(i==S_HEALTH){
			properties[i].box.size.width=200;
			properties[i].tex=[[Resources getResources] getMenuTex:MENU_HEALTH];
		}else if(i==S_PLAY_MUSIC){
			properties[i].box.size.width=105;
			properties[i].tex=[[Resources getResources] getMenuTex:MENU_MUSIC];			
		}
		else if(i==S_PLAY_SOUND){
		properties[i].box.size.width=200;
		properties[i].tex=[[Resources getResources] getMenuTex:MENU_SOUND_EFFECTS];			
		}else if(i==S_AUTOJUMP){
			properties[i].box.size.width=120;
			
			properties[i].tex=[[Resources getResources] getMenuTex:MENU_AUTOJUMP];
			
		}else if(i==S_AUTOJUMP){
            properties[i].box.size.width=120;
			
			properties[i].tex=[[Resources getResources] getMenuTex:MENU_CREATURES];	
            
        }
			
			
		
	}
    
    extern BOOL IS_WIDESCREEN;
	rect_settings.size.width=246;
	rect_settings.size.height=45;
    if(IS_IPAD)
        rect_settings.origin.x=SCREEN_WIDTH/2-rect_settings.size.width/3;
    else
	rect_settings.origin.x=SCREEN_WIDTH/2-rect_settings.size.width/2;
	rect_settings.origin.y=SCREEN_HEIGHT-rect_settings.size.height-3;
	
	
	rect_save.size.width=102;
	rect_save.size.height=45;
	rect_save.origin.x=SCREEN_WIDTH/2-rect_save.size.width/2;
	rect_save.origin.y=20;
	
	for(int j=0;j<NUM_PROP;j++){
        rect_on[j].origin.y=properties[j].box.origin.y-2;
	rect_on[j].size.width=135/2*1.5f;
	rect_on[j].size.height=40/2*1.5f;
        if(IS_WIDESCREEN){
           // printg("adjusting options because widescreen");
          rect_on[j].origin.x=300+115;
        }
        else
	rect_on[j].origin.x=300+35;
	//rect_on[j].origin.y=0;
    }
	
	
	rect_off.size.width=70;
	rect_off.size.height=30;
	rect_off.origin.x=305;
	rect_off.origin.y=0;
	
    if(LOW_MEM_DEVICE){
        //properties[S_GRAPHICS].value=false;
        properties[S_CREATURES].value=false;
    }
	
	this->load();
    
    
	
}
static const int usage_id=3;
void SettingsMenu::update(float etime){

	Input* input=Input::getInput();
    itouch* touches=input->getTouches();
	
	for(int i=0;i<MAX_TOUCHES;i++){
		if(touches[i].inuse==0&&touches[i].down==M_DOWN){
			touches[i].inuse=usage_id;
            inbox3(touches[i].mx,touches[i].my,&rect_save);
            for(int j=0;j<NUM_PROP;j++)
                inbox3(touches[i].mx,touches[i].my,&rect_on[j]);
		}			
		if(touches[i].inuse==usage_id&&touches[i].down==M_RELEASE){
			
			if(inbox2(touches[i].mx,touches[i].my,&rect_save)){	
                this->save();
				[World getWorld].menu.showsettings=FALSE;
			}
			for(int j=0;j<NUM_PROP;j++){
				
				rect_off.origin.y=properties[j].box.origin.y;
				if(inbox2(touches[i].mx,touches[i].my,&rect_on[j])){
					properties[j].value=!properties[j].value;		
					if(j==S_PLAY_MUSIC){
                        if(properties[j].value){
                        [Resources getResources].playmusic=TRUE;
						[[Resources getResources] playMenuTune];
                        }else{
                            [Resources getResources].playmusic=FALSE;
                            [[Resources getResources] stopMenuTune];

                        }
					}
				}
				
				
			}
			
			touches[i].inuse=0;
			touches[i].down=M_NONE;
		}
	}
	
}
void SettingsMenu::load(){
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    for(int i=0;i<NUM_PROP;i++){
		NSNumber* n=[prefs objectForKey:properties[i].name]; 
		if(n!=nil){
			properties[i].value=[n intValue];
		}
	}
	world_counter=0;
	NSNumber* n=[prefs objectForKey:@"new_world_counter"];
	if(n!=nil)
	world_counter=[n intValue];
	[Resources getResources].playmusic=properties[S_PLAY_MUSIC].value;
	[Resources getResources].playsound=properties[S_PLAY_SOUND].value;
	//[World getWorld].hud.leftymode=properties[S_LEFTY_MODE].value;
   [World getWorld].player.autojump_option=properties[S_AUTOJUMP].value;
    [World getWorld].player.health_option=properties[S_HEALTH].value;
	[World getWorld].player.invertcam=FALSE;
	[World getWorld].hud.use_joystick=TRUE;
    [World getWorld].terrain.tgen->genCaves=FALSE;
    [World getWorld].bestGraphics=properties[S_AUTOJUMP].value;
    CREATURES_ON=properties[S_CREATURES].value;
    
    [World getWorld].bestGraphics=TRUE;
    if(LOW_MEM_DEVICE||LOW_GRAPHICS){
        [World getWorld].bestGraphics=FALSE;
    }
    extern BOOL IS_WIDESCREEN;
    if(IS_WIDESCREEN){
        [World getWorld].bestGraphics=TRUE;
    }
}
void SettingsMenu::save(){
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	for(int i=0;i<NUM_PROP;i++){
		[prefs setObject:[NSNumber numberWithInt:properties[i].value] forKey:properties[i].name];
	}
	[prefs synchronize];
    this->load();
	
}
NSString* SettingsMenu::getNewWorldName(){
	world_counter++;
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:[NSNumber numberWithInt:world_counter] forKey:@"new_world_counter"];
	[prefs synchronize];
	return [NSString stringWithFormat:@"World %d",world_counter];
}
void SettingsMenu::render(){
	glColor4f(1.0, 1.0, 1.0, 1.0f);
	[[[Resources getResources] getMenuTex:MENU_OPTIONS_HEADER] drawText:rect_settings];	
	
	[[[Resources getResources] getMenuTex:MENU_SAVE] drawButton:rect_save];
	for(int i=0;i<NUM_PROP;i++){
		glColor4f(0.97, 0.97, 0.97, 1.0f);
		if(i==S_HEALTH){
			[[[Resources getResources] getMenuTex:MENU_HEALTH] drawText:properties[i].box];
		}else if(i==S_PLAY_MUSIC){
			[[[Resources getResources] getMenuTex:MENU_MUSIC] drawText:properties[i].box];
		}
		else if(i==S_PLAY_SOUND){
			[[[Resources getResources] getMenuTex:MENU_SOUND_EFFECTS] drawText:properties[i].box];			
		}else if(i==S_AUTOJUMP){
			[[[Resources getResources] getMenuTex:MENU_AUTOJUMP] drawText:properties[i].box];
			
		}else if(i==S_CREATURES){
            [[[Resources getResources] getMenuTex:MENU_CREATURES] drawText:properties[i].box];	
        }
	//	[properties[i].tex drawInRect:properties[i].box];
		rect_off.origin.y=properties[i].box.origin.y;
	
		glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	//	if(properties[i].value){
//			glColor4f(0.0, 1.0, 0.0, 1.0f);	
//		}
      //  if(i==S_GRAPHICS)
       //     [[[Resources getResources] getMenuTex:MENU_BEST]  drawText:rect_on];
       // else
        if(properties[i].value)
            [[[Resources getResources] getMenuTex:MENU_ON]  drawButton:rect_on[i]];
        else
            [[[Resources getResources] getMenuTex:MENU_OFF]  drawButton:rect_on[i]];
		glColor4f(0.7, 0.7, 0.7, 1.0f);
		if(!properties[i].value){
			glColor4f(1.0, 0.0, 0.0, 1.0f);	
		}
	//	if(i==S_GRAPHICS)
     //       [[[Resources getResources] getMenuTex:MENU_FAST]  drawText:rect_off];
     //   else
	//	[[[Resources getResources] getMenuTex:MENU_OFF] drawText:rect_off];
	}

	
}

