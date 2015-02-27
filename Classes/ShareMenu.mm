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

@implementation ShareMenu

extern float SCREEN_WIDTH; 
extern float SCREEN_HEIGHT;
extern float P_ASPECT_RATIO; 
extern EAGLView* G_EAGL_VIEW;
-(id)init{
	world_name_field=[[UITextField alloc] initWithFrame: 
					  CGRectMake(0, 0, 1, 1)];
	world_name_field.keyboardType=UIKeyboardTypeAlphabet;
	world_name_field.returnKeyType=UIReturnKeyDone;
	world_name_field.hidden=TRUE;
	world_name_field.borderStyle = UITextBorderStyleNone;
	world_name_field.autocorrectionType = UITextAutocorrectionTypeNo;
		[world_name_field setDelegate:self];	
	
	[G_EAGL_VIEW insertSubview: world_name_field atIndex:0];
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
	return self;
}
-(void)activate{
	share_explain_lbl->setStatus(@"Note: Players will spawn where you last saved.  The last picture you took is used as a preview picture." ,9999);
	label_bar->setStatus(@"Name your world: ",9999,UITextAlignmentLeft);
    
	
}
-(void)deactivate{
	share_explain_lbl->clear();
	label_bar->clear();
	name_bar->clear();
    
}
-(void)beginShare:(WorldNode*)world{
	node=world;
	/*if(![World getWorld].FLIPPED){
		[UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeRight;
	}
	else{
		[UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeLeft;
		
	}*/
	//starto=[World getWorld].FLIPPED;
	[world_name_field becomeFirstResponder];
	name=[NSMutableString stringWithString:world->display_name];
	[name retain];
	world_name_field.text=@"a";
    displays=[NSMutableString stringWithString:name];
    [displays retain];
    [self trimDisplay];
	name_bar->setStatus(displays,9999,UITextAlignmentLeft);
  

	//[world_name_field release];
	
	
}
- (void) trimDisplay{
    while([displays sizeWithFont:[UIFont systemFontOfSize:14]].width>input_background.size.width-10){
        [displays deleteCharactersInRange:NSMakeRange(0,1)];
    }
	name_bar->setStatus(displays,9999,UITextAlignmentLeft);
    
}

- (BOOL)textField:(UITextField *)textField 
shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
	if([string length]>1)return FALSE;
	if([string length]==0){
		if([name length]>0){
			[name replaceCharactersInRange:NSMakeRange([name length]-1, 1) withString:@""];
		}
	}else if([name length]>35){
		return FALSE;
	}else{
				char c=[string characterAtIndex:0];
		NSLog(@"%d",(int)[name length]);
		if(!isalnum(c)&&c!=' '&&c!='\'')return FALSE;
		[name appendFormat:@"%c",c];	   
	}
    [displays release];
    displays=[NSMutableString stringWithString:name];
     [displays retain];
    [self trimDisplay];
	return FALSE;
}
- (void)textFieldDidEndEditing:(UITextField*)textField
{
	NSLog(@"sup2");
	
	//NSLog(@"%@",[textField text]);
	//[textField endEditing:YES];
	//[textField removeFromSuperview];
}

- (BOOL)textFieldShouldReturn:(UITextField*)texField
{
	NSLog(@"sup");
	[self endShare:FALSE];
    
	// end editing
	//[texField resignFirstResponder];
	return YES;
}

-(void)endShare:(BOOL)cancel{
	[world_name_field resignFirstResponder];
	if(name==NULL||[name length]==0||cancel){
        if(name!=NULL)
		[name release];
        name=NULL;
		[World getWorld].menu->is_sharing=0;
		[World getWorld].menu->sbar->clear();
		return;
	}
	[node->display_name release];
	node->display_name=[NSString stringWithString:name];
    
	[node->display_name retain];
	[name release];
    name=NULL;
    [World getWorld].fm->setName(node->file_name,node->display_name);
    NSString* file_name=[NSString stringWithFormat:@"%@/%@",
                         [World getWorld].fm->documents,node->file_name];
    NSString* image_file_name=[NSString stringWithFormat:@"%@/%@.png",
                               [World getWorld].fm->documents,node->file_name];
    NSFileManager* fm=[NSFileManager defaultManager];
    NSLog(@"Sharing \"%@\"",node->display_name);
    if(![fm fileExistsAtPath:image_file_name]){
        [World getWorld].menu->is_sharing=0;
        [World getWorld].menu->sbar->setStatus(@"Error: No preview picture found",4);
        return;
    }
    
    [[World getWorld].menu->shareutil shareWorld:file_name];
    
    
    [World getWorld].menu->is_sharing=2;
    [World getWorld].menu->refreshfn();

	
				
}
static const int usage_id=9001;
static float cursor_blink=0;
-(void)update:(float)etime{
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
	/*if(starto!=[World getWorld].FLIPPED)
	{
		if(![World getWorld].FLIPPED){
			[UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeRight;
		}
		else{
			[UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeLeft;
		}		
		starto=[World getWorld].FLIPPED;
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
				[self endShare:TRUE];
			}
			if(inbox2(touches[i].mx,touches[i].my,&rect_submit)){	
				[self endShare:FALSE];
			}
			
			touches[i].inuse=0;
			touches[i].down=M_NONE;
		}
	}
	
}
-(void)render{
	glColor4f(1.0f, 0.0f, 0.0f,1.0f);
	[Resources::getResources()->getMenuTex(MENU_CANCEL) drawButton:rect_cancel];
	glColor4f(0.0f, 1.0f, 0.0f,1.0f);
	[Resources::getResources()->getMenuTex(MENU_SEND) drawButton:rect_submit];
	glColor4f(1.0f, 1.0f, 1.0f,1.0f);    
	[Resources::getResources()->getMenuTex(MENU_TEXT_BOX) drawInRect:input_background];
    
	
    
	glColor4f(0.0f, 0.0f, 0.0f,1.0f);
	share_explain_lbl->render();
    glColor4f(0.0f, 0.0f, 0.0f,1.0f);
	name_bar->renderPlain();
	label_bar->render();
	
	
	
}
@end
