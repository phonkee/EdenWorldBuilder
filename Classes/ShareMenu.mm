//
//  ShareMenu.m
//  prototype
//
//  Created by Ari Ronen on 11/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ShareMenu.h"
#import "World.h"
#import "Globals.h"
#import "EAGLView.h"
#import "Vkeyboard.h"





extern float SCREEN_WIDTH; 
extern float SCREEN_HEIGHT;
extern float P_ASPECT_RATIO; 

ShareMenu::ShareMenu(){
	
    
	
	CGRect sbrect=CGRectMake(SCREEN_WIDTH/2-230+95-19, SCREEN_HEIGHT-67, 500, 35);
	label_bar=new statusbar(sbrect,17);
	sbrect.origin.x=SCREEN_WIDTH/2-220+143+90-23;
	sbrect.origin.y-=3;
	name_bar=new statusbar(sbrect,14);
	label_bar->setStatus(@"Name your world: ",9999,UITextAlignmentLeft);
	input_background=CGRectMake(SCREEN_WIDTH/2-15, SCREEN_HEIGHT-60, 200, 30);
	rect_cancel.origin.x=100;
	rect_cancel.origin.y=SCREEN_HEIGHT/2+60;
	rect_cancel.size.width=130;
	rect_cancel.size.height=36;
	rect_submit.origin.x=280;
	rect_submit.origin.y=SCREEN_HEIGHT/2+60;
	rect_submit.size.width=130;
	rect_submit.size.height=36;
	share_explain_rect.origin.x=50;
	share_explain_rect.origin.y=SCREEN_HEIGHT/2+15;
	share_explain_rect.size.height=40;
	share_explain_rect.size.width=370;
    extern BOOL IS_WIDESCREEN;
    if(IS_WIDESCREEN){
        rect_submit.origin.x+=45;
        rect_cancel.origin.x+=45;
        share_explain_rect.origin.x+=45;
    }
	share_explain_lbl=new statusbar(share_explain_rect,15);
	share_explain_lbl->setStatus(@"Note: Players will spawn where you last saved.  The last picture you took is used as a preview picture." ,9999);
	//starto=FALSE;
	
}
void ShareMenu::activate(){
	share_explain_lbl->setStatus(@"Note: Players will spawn where you last saved.  The last picture you took is used as a preview picture." ,9999);
	label_bar->setStatus(@"Name your world: ",9999,UITextAlignmentLeft);
    
	
}
void ShareMenu::deactivate(){
	share_explain_lbl->clear();
	label_bar->clear();
	name_bar->clear();
    
}
void ShareMenu::keyTyped(char c){
    
    if(c==-1){
        if([name length]>0){
            [name replaceCharactersInRange:NSMakeRange([name length]-1, 1) withString:@""];
        }
    }else if([name length]>35){
        return;
    }else{
       // char c=c;
        NSLog(@"%d",(int)[name length]);
        if(!isalnum(c)&&c!=' '&&c!='\'')return;
        [name appendFormat:@"%c",c];
    }
    [displays release];
    displays=[NSMutableString stringWithString:name];
    [displays retain];
    trimDisplay();
    
}
void ShareMenu::beginShare(WorldNode* world){
	node=world;
	/*if(!World::getWorld->FLIPPED){
		[UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeRight;
	}
	else{
		[UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeLeft;
		
	}*/
	//starto=World::getWorld->FLIPPED;
    vkeyboard_begin(0);
    
	
	name=[NSMutableString stringWithString:world->display_name];
	[name retain];
	
    displays=[NSMutableString stringWithString:name];
    [displays retain];
    trimDisplay();
	name_bar->setStatus(displays,9999,UITextAlignmentLeft);
  

	//[world_name_field release];
	
	
}
void ShareMenu::trimDisplay(){
    while([displays sizeWithFont:[UIFont systemFontOfSize:14]].width>input_background.size.width-10){
        [displays deleteCharactersInRange:NSMakeRange(0,1)];
    }
	name_bar->setStatus(displays,9999,UITextAlignmentLeft);
    
}


void ShareMenu::endShare(BOOL cancel){
    vkeyboard_end(0);
	
	if(name==NULL||[name length]==0||cancel){
        if(name!=NULL)
		[name release];
        name=NULL;
		World::getWorld->menu->is_sharing=0;
		World::getWorld->menu->sbar->clear();
		return;
	}
	[node->display_name release];
	node->display_name=[NSString stringWithString:name];
    
	[node->display_name retain];
	[name release];
    name=NULL;
    World::getWorld->fm->setName(cpstring(node->file_name),cpstring(node->display_name));
    NSString* file_name=[NSString stringWithFormat:@"%@/%@",
                         World::getWorld->fm->documents,node->file_name];
    NSString* image_file_name=[NSString stringWithFormat:@"%@/%@.png",
                               World::getWorld->fm->documents,node->file_name];
    NSFileManager* fm=[NSFileManager defaultManager];
    NSLog(@"Sharing \"%@\"",node->display_name);
    if(![fm fileExistsAtPath:image_file_name]){
        World::getWorld->menu->is_sharing=0;
        World::getWorld->menu->sbar->setStatus(@"Error: No preview picture found",4);
        return;
    }
    
    [World::getWorld->menu->shareutil shareWorld:file_name];
    
    
    World::getWorld->menu->is_sharing=2;
    World::getWorld->menu->refreshfn();

	
				
}
static const int usage_id=9001;
static float cursor_blink=0;

void ShareMenu::update(float etime){
    if(cursor_blink>=0&&cursor_blink-etime<0){
         name_bar->setStatus(displays,9999,UITextAlignmentLeft);
    }
	cursor_blink-=etime;
    if(cursor_blink<-.3f){
        cursor_blink=.4f;
        
        name_bar->setStatus([NSString stringWithFormat:@"%@|",displays],9999,UITextAlignmentLeft);
     }
    
	name_bar->update(etime);
	label_bar->update(etime);
	/*if(starto!=World::getWorld->FLIPPED)
	{
		if(!World::getWorld->FLIPPED){
			[UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeRight;
		}
		else{
			[UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeLeft;
		}		
		starto=World::getWorld->FLIPPED;
		[world_name_field resignFirstResponder];
		[world_name_field becomeFirstResponder];
	}*/
	Input* input=Input::getInput();
    itouch* touches=input->getTouches();
	
	for(int i=0;i<MAX_TOUCHES;i++){
		if(touches[i].inuse==0&&touches[i].down==M_DOWN){
			touches[i].inuse=usage_id;
			inbox3(touches[i].mx,touches[i].my,&rect_cancel);
            inbox3(touches[i].mx,touches[i].my,&rect_submit);
		}			
		if(touches[i].inuse==usage_id&&touches[i].down==M_RELEASE){
			
			if(inbox2(touches[i].mx,touches[i].my,&rect_cancel)){	
				endShare(TRUE);
			}
			if(inbox2(touches[i].mx,touches[i].my,&rect_submit)){	
				endShare(FALSE);
			}
			
			touches[i].inuse=0;
			touches[i].down=M_NONE;
		}
	}
	
}
void ShareMenu::render(){
	glColor4f(1.0f, 0.0f, 0.0f,1.0f);
	Resources::getResources->getMenuTex(MENU_CANCEL)->drawButton(rect_cancel);
	glColor4f(0.0f, 1.0f, 0.0f,1.0f);
	Resources::getResources->getMenuTex(MENU_SEND)->drawButton(rect_submit);
	glColor4f(1.0f, 1.0f, 1.0f,1.0f);    
	Resources::getResources->getMenuTex(MENU_TEXT_BOX)->drawInRect(input_background);
    
	
    
	glColor4f(0.0f, 0.0f, 0.0f,1.0f);
	share_explain_lbl->render();
    glColor4f(0.0f, 0.0f, 0.0f,1.0f);
	name_bar->renderPlain();
	label_bar->render();
	
	
	
}

