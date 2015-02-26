//
//  SharedList.m
//  prototype
//
//  Created by Ari Ronen on 11/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SharedList.h"
#import "Graphics.h"
#import "Globals.h"
#import "World.h"
#import "EAGLView.h"

extern float SCREEN_WIDTH; 
extern float SCREEN_HEIGHT;
extern float P_ASPECT_RATIO;

@implementation SharedList
@synthesize cur_sort,sbar,finished_dl,finished_preview_dl,sort_bar,finished_list_dl;
#define NUM_SORTS 3
enum SORT_TYPES{
	SORT_NAME=0,
	SORT_BEST=1,
	SORT_DATE=2	
};

extern EAGLView* G_EAGL_VIEW;
static UIAlertView *alertReportContent;
static UIAlertView *alertReportConfirm;
static float bsize;
-(id)init{
    search_string=[NSMutableString stringWithString:@""];
    [search_string retain];
	search_field=[[UITextField alloc] initWithFrame: 
					  CGRectMake(0, 0, 1, 1)];
	search_field.keyboardType=UIKeyboardTypeAlphabet;
	search_field.returnKeyType=UIReturnKeyDone;
	search_field.hidden=TRUE;
	search_field.borderStyle = UITextBorderStyleNone;
	search_field.autocorrectionType = UITextAutocorrectionTypeNo;
    [search_field setDelegate:self];	
	[G_EAGL_VIEW insertSubview: search_field atIndex:0];
    input_background=CGRectMake(SCREEN_WIDTH/2-100, SCREEN_HEIGHT-80, 200, 30);
    
    sbrrect=ButtonMake(SCREEN_WIDTH/2-230+95-19-85, SCREEN_HEIGHT-87, 500, 35);
	sbrrect.origin.x=SCREEN_WIDTH/2-220+143+90-23-85;
	sbrrect.origin.y-=3;
    
    alertReportContent= [[UIAlertView alloc]
                    initWithTitle:@"Flag Content"
                    message:@"Report this world for offensive or innappropriate content?\n"                                                                              delegate:self
                    cancelButtonTitle:@"Cancel"                                                                           otherButtonTitles:@"Report" , nil];
    
    alertReportConfirm= [[UIAlertView alloc]
                         initWithTitle:@"Report sent, thanks\n"
                         message:@""                                                                              delegate:self
                         cancelButtonTitle:@"Ok"                                                                          otherButtonTitles:nil , nil];
    
	name_bar=new statusbar(RectFromButton(sbrrect),14);
    
   /* input_background=CGRectMake(SCREEN_WIDTH/2-15, SCREEN_HEIGHT-60, 200, 30);
    
    CGRect sbrect=CGRectMake(SCREEN_WIDTH/2-230+95-19, SCREEN_HEIGHT-67, 500, 35);
	sbrect.origin.x=SCREEN_WIDTH/2-220+143+90-23;
	sbrect.origin.y-=3;
	name_bar=[[statusbar alloc] initWithRect:sbrect:14];*/
	
	
    
  
    bsize=43;
    finished_dl=finished_preview_dl=finished_list_dl=FALSE;
	CGRect sbrect2;
	sbrect2.origin.x=50;
    sbrect2.origin.y=SCREEN_HEIGHT-77;
    sbrect2.size.width=SCREEN_WIDTH-100;
    sbrect2.size.height=20;
	sbar=new statusbar(sbrect2,16);
	
	rect_header.size.width=280;
	rect_header.size.height=30;
    if(IS_IPAD)
        rect_header.origin.x=SCREEN_WIDTH/2-rect_header.size.width/2.5f-6;
    else
	rect_header.origin.x=SCREEN_WIDTH/2-rect_header.size.width/2.5f-29;
	rect_header.origin.y=SCREEN_HEIGHT-rect_header.size.height;
	
	rect_arrow_up.size.width=45;
	rect_arrow_up.size.height=25;
	rect_arrow_up.origin.x=SCREEN_WIDTH-rect_arrow_up.size.width-3;
	rect_arrow_up.origin.y=SCREEN_HEIGHT-67;
	
		rect_arrow_down.size.width=45;
	rect_arrow_down.size.height=25;
	rect_arrow_down.origin.x=SCREEN_WIDTH-rect_arrow_down.size.width-3;
	rect_arrow_down.origin.y=3;
	
    preview_box.size.width=SCREEN_WIDTH*.60f;
    preview_box.size.height=SCREEN_HEIGHT*.60f;
    preview_box.origin.y=SCREEN_HEIGHT-preview_box.size.height-57;
    preview_box.origin.x=(SCREEN_WIDTH-preview_box.size.width)/2.0f;
    
    if(IS_IPAD){
    rload_cancel=ButtonMake(95, 17, 90, 33);
    rload_go=ButtonMake(292, 17, 90, 33);
    }else{
        rload_cancel=ButtonMake(95, 25, 90, 33);
        rload_go=ButtonMake(292, 25, 90, 33);
        
    }
    rect_flag=ButtonMake(SCREEN_WIDTH-40-20,SCREEN_HEIGHT-30-10,40,30);
    if(IS_IPAD)rect_flag.origin.y-=5;
	rect_cancel.size.width=40;
	rect_cancel.size.height=30;
	rect_cancel.origin.x=10;
	rect_cancel.origin.y=SCREEN_HEIGHT-rect_cancel.size.height-10;
	if(IS_IPAD)rect_cancel.origin.y-=5;
    extern BOOL IS_WIDESCREEN;
    if(IS_WIDESCREEN){
        rload_cancel.origin.x+=25;
        rload_go.origin.x+=55;
    }
	
	
	sbrect.size.width=320;
	sbrect.size.height=45;
	sbrect.origin.x=SCREEN_WIDTH/2-sbrect.size.width/2;
	sbrect.origin.y=SCREEN_HEIGHT-74;
	sort_left.size.width=8;
	sort_left.size.height=15;
	sort_right.size.width=8;
	sort_right.size.height=15;
	sort_left.origin.y=SCREEN_HEIGHT-50;
	sort_right.origin.y=SCREEN_HEIGHT-50;
	sort_left.origin.x=SCREEN_WIDTH/2-85-sort_left.size.width;
	sort_right.origin.x=SCREEN_WIDTH/2+85;
	cur_sort=SORT_BEST;
	sort_bar=new statusbar(sbrect,20.0f);
	[self setSortStatus];
	
	page_size=5;
	list_selection=-1;
	num_files=0;
	file_list=NULL;
    previewScreenshot=NULL;
    animation_offset=0;
    displays=[NSMutableString stringWithString:@""];
    [displays retain];
	return self;
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
		if([search_string length]>0){
			[search_string replaceCharactersInRange:NSMakeRange([search_string length]-1, 1) withString:@""];
		}
	}else if([search_string length]>35){
		return FALSE;
	}else{
        char c=[string characterAtIndex:0];
		NSLog(@"%d",(int)[search_string length]);
		if(!isalnum(c)&&c!=' '&&c!='\'')return FALSE;
		[search_string appendString:string];	   
	}
    [displays release];
    displays=[NSMutableString stringWithString:search_string];
    [displays retain];
    [self trimDisplay];
	name_bar->setStatus(displays,9999,UITextAlignmentLeft);
	return FALSE;
}
- (void)textFieldDidEndEditing:(UITextField*)textField
{
	NSLog(@"sup2");
	
	
}

- (BOOL)textFieldShouldReturn:(UITextField*)texField
{
	NSLog(@"sup");
	[self searchAndHide:FALSE];
	
	return YES;
}

-(void)searchAndHide:(BOOL)nosearch{
	[search_field resignFirstResponder];
	if([search_string length]==0||nosearch){
		return;
	}
    NSString* list=[[World getWorld].menu->shareutil searchSharedWorlds:search_string];
    
    if([list length]==0){
        sbar->setStatus(@"No Results Found. ",4);
    }else{
        sbar->clear();
        [self setWorldList:list];
        
    }
	    
	
    
}

-(void)activate{
	[self setSortStatus];
    
}
-(void)deactivate{
	sort_bar->clear();
	sbar->clear();
    name_bar->clear();
    
}
static const int usage_id=42;
-(void)setSortStatus{
	if(cur_sort==SORT_NAME){
		sort_bar->setStatus(@"Search" ,99999);
	}else if(cur_sort==SORT_DATE){
		sort_bar->setStatus(@"Recent" ,99999);
	}else if(cur_sort==SORT_BEST){
		sort_bar->setStatus(@"Featured" ,99999);
	}	
}
-(void)clearWorldList{
    for(int i=0;i<num_files;i++){
		[file_list[i].name release];
        [file_list[i].file_name release];
        if(file_list[i].nametex)[file_list[i].nametex release];
        if(file_list[i].datetex)[file_list[i].datetex release];
        file_list[i].nametex=file_list[i].datetex=NULL;
		
	}
	free(file_list);
	file_list=NULL;
    num_files=0;
    animation_offset=0;

}
-(void)setWorldList:(NSString*)wlist{
    animation_offset=0;
    [self setSortStatus];
	[self clearWorldList];
		NSArray* list=[wlist componentsSeparatedByString:@"\n"];
	cur_page=0;
	int n=0;
	for(NSString* temp in list){
		//NSLog(@":::%@",temp);
		if([temp hasSuffix:@".eden"]){
			n++;
         //   NSLog(@"%d sup",n);
		}
	}
	list_selection=0;
	if(n==0){
		file_list=NULL;
		num_files=0;
		return;
	}
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"MM/dd/yyyy"];

	num_files=n;
	file_list=(SharedListNode*)malloc(sizeof(SharedListNode)*num_files);
	int idx=0;
	for(int i=0;i<[list count];i++){
		NSString* temp=[list objectAtIndex:i];
		
		if([temp hasSuffix:@".eden"]){
            BOOL was_reported=FALSE;
            for(int r=0;r<rwc_count;r++){
                if([temp isEqualToString:reportedWorlds[r]]){
                    //printg("culled reported world from list: %s\n",[reportedWorlds[r] cStringUsingEncoding:NSUTF8StringEncoding]);
                    was_reported=TRUE;
                    break;
                    
                }
            }
            if(was_reported){
                num_files--;
                continue;
            }
			file_list[idx].file_name=[list objectAtIndex:i];
			file_list[idx].name=[list objectAtIndex:i+1];
			file_list[idx].name=[file_list[idx].name 
								 substringToIndex:[file_list[idx].name length]-5];
			
			temp=[temp substringToIndex:[temp length]-5];
			file_list[idx].date=atoi([temp cStringUsingEncoding:NSUTF8StringEncoding]);
			
			
			
			[file_list[idx].name retain];
			[file_list[idx].file_name retain];
			
			file_list[idx].namerect.origin.x=80;
			file_list[idx].namerect.size.width=SCREEN_WIDTH-240;
			file_list[idx].namerect.size.height=40;
			file_list[idx].namerect.origin.y=SCREEN_HEIGHT-
							((idx%page_size)*(file_list[idx].namerect.size.height+3)+125);
			
			/*file_list[idx].nametex=
            [[Texture2D alloc] initWithString:file_list[idx].name
                                   dimensions:CGSizeMake(
                                              file_list[idx].namerect.size.width
                                            , file_list[idx].namerect.size.height)
                                    alignment:UITextAlignmentLeft
                                    font:[UIFont systemFontOfSize:17.0]];*/
            
            
			
			file_list[idx].daterect.origin.x=320;
			file_list[idx].daterect.size.width=150;
			file_list[idx].daterect.size.height=40;
			file_list[idx].daterect.origin.y=SCREEN_HEIGHT-
					((idx%page_size)*(file_list[idx].daterect.size.height+3)+125);
            file_list[idx].datetex=NULL;
            file_list[idx].nametex=NULL;
			/*NSString* fdate;
			NSDate *date = [NSDate dateWithTimeIntervalSince1970:file_list[idx].date]; 
			fdate=[dateFormat stringFromDate:date];
			if(IS_IPAD){
                
                file_list[idx].nametex=[[Texture2D alloc] initWithString:file_list[idx].name
                                                              dimensions:CGSizeMake(
                                                                                    file_list[idx].namerect.size.width*SCALE_WIDTH
                                                                                    , file_list[idx].namerect.size.height*SCALE_HEIGHT)
                                                               alignment:UITextAlignmentLeft
                                                                    font:[UIFont systemFontOfSize:17.0*2]];
            }
            else{
                file_list[idx].nametex= [[Texture2D alloc] initWithString:file_list[idx].name
                                                               dimensions:CGSizeMake(
                                                                                     file_list[idx].namerect.size.width
                                                                                     , file_list[idx].namerect.size.height)
                                                                alignment:UITextAlignmentLeft
                                                                     font:[UIFont systemFontOfSize:17.0]];
            }
            
            if(IS_IPAD){
                
        file_list[idx].datetex=[[Texture2D alloc] initWithString:fdate
                                        dimensions:CGSizeMake(
                                file_list[idx].daterect.size.width*SCALE_WIDTH
                                , file_list[idx].daterect.size.height*SCALE_HEIGHT)
                            alignment:UITextAlignmentRight
                                font:[UIFont systemFontOfSize:17.0*2]];
            }
            else{
                file_list[idx].datetex= [[Texture2D alloc] initWithString:fdate
                                                               dimensions:CGSizeMake(
                file_list[idx].daterect.size.width
            , file_list[idx].daterect.size.height)
                alignment:UITextAlignmentRight
                            font:[UIFont systemFontOfSize:17.0]];
            }*/
            
			file_list[idx].blockrect.origin.x=20;
            file_list[idx].blockrect.pressed=FALSE;
            if(IS_IPAD){
                file_list[idx].blockrect.size.width=40;
                file_list[idx].blockrect.size.height=40;  
                
            }else{
			file_list[idx].blockrect.size.width=50;
			file_list[idx].blockrect.size.height=50;
			}file_list[idx].blockrect.origin.y=SCREEN_HEIGHT-
					((idx%page_size)*(file_list[idx].namerect.size.height+3)+116);
			
			file_list[idx].blocktex=[[Resources getResources] getMenuTex:MENU_BLOCK_UNSELECTED];
			
			idx++;
		}
	}
	[dateFormat release];
    [wlist release];
}
static int is_loading=0;
static int loading_world=0;
static float cursor_blink=0;
-(void)activateKB{
    [self clearWorldList];
    sbar->setStatus(@"" ,9999);
   /* if(![World getWorld].FLIPPED){
        [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeRight;
    }
    else{
        [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeLeft;
        
    }*/
    //  starto=[World getWorld].FLIPPED;
    [search_field becomeFirstResponder];
    
    
    search_field.text=@"a";
    
}
-(void)update:(float)etime{
	if(is_loading>0){
		if(cur_sort==SORT_NAME){
            [self searchAndHide:TRUE];
        }
        if(previewScreenshot!=NULL){
            [previewScreenshot release];
            previewScreenshot=NULL;
        }
        if(is_loading!=2)
		cur_sort=(cur_sort+1)%NUM_SORTS;
		[self setSortStatus];
        if(cur_sort==SORT_NAME){
            [self activateKB];
            


        }else{
             finished_list_dl=FALSE;
           [[World getWorld].menu->shareutil getSharedWorldList];
            if(is_loading==2){
                sbar->setStatus(@"Report sent, thank you" ,5);
                is_loading=-1;
                return;
            }
           
          
		}
		is_loading=0;
		return;
	}
    if( finished_list_dl){
        finished_list_dl=FALSE;
        NSString* list=[World getWorld].menu->shareutil.listresult;
        
        if([list length]==0){
            sbar->setStatus(@"Connection error getting world list. ",2);
        }else{
            if(is_loading!=-1)//just don't clear report confirm if coming from there
            sbar->clear();
            [self setWorldList:list];
        }
        is_loading=0;
        return;
    }
	if(finished_preview_dl){
        finished_preview_dl=FALSE;
        if(previewScreenshot!=NULL){
            [previewScreenshot release];
        }
        previewScreenshot=[[Texture2D alloc] 
                         initWithImagePath:[NSString stringWithFormat:@"%@/temp",[World getWorld].fm->documents] sizeToFit:FALSE];
        if(previewScreenshot==NULL){
            sbar->setStatus(@"Error: map not found",4);
        }else{
        if(loading_world-1>=0&&loading_world-1<num_files)
        sort_bar->setStatus(file_list[loading_world-1].name,9999);
        sbar->clear();
        }
		/**/
        
		return;
	}else if(finished_dl){
        finished_dl=FALSE;
        if(previewScreenshot!=NULL){
            
            [previewScreenshot release];
            previewScreenshot=NULL;
        }
        [self setSortStatus];
        
        previewScreenshot=NULL;
        if(![World getWorld].menu->loadShared(&file_list[loading_world-1])){
            
            sbar->setStatus(@"Error: map not found",4);
        }else{
            [World getWorld].menu->showlistscreen=FALSE;
            [self clearWorldList];
            sbar->clear();
            num_files=0;
            loading_world=0;  
            
        }

               
    }
    if(cur_sort==SORT_NAME){
        
        if(cursor_blink>=0&&cursor_blink-etime<0){
            name_bar->setStatus(displays,9999,UITextAlignmentLeft);
        }
        cursor_blink-=etime;
        if(cursor_blink<-.3f){
            cursor_blink=.4f;
            
            name_bar->setStatus([NSString stringWithFormat:@"%@|",displays],9999,UITextAlignmentLeft);
        }

    }
	Input* input=Input::getInput();
    itouch* touches=input->getTouches();
	sbar->update(etime);
	sort_bar->update(etime);
    name_bar->update(etime);
	for(int i=0;i<MAX_TOUCHES;i++){
		if(touches[i].inuse==0&&touches[i].down==M_DOWN){
			touches[i].inuse=usage_id;
            
            inbox3(touches[i].mx,touches[i].my,&rect_cancel);				
			
            if(previewScreenshot==NULL){
                inbox3(touches[i].mx,touches[i].my,&rect_arrow_up);	
               
                inbox3(touches[i].mx,touches[i].my,&rect_arrow_down);
                
                if(cur_sort==SORT_NAME)inbox3(touches[i].mx,touches[i].my,&sbrrect);                
                
                for(int j=cur_page*page_size;j<cur_page*page_size+page_size;j++){
                    if(j>=num_files)break;
                    if(j==list_selection)
                    if(inbox(touches[i].mx,touches[i].my,file_list[j].namerect)||
                       inbox(touches[i].mx,touches[i].my,file_list[j].daterect)||
                       inbox3(touches[i].mx,touches[i].my,&(file_list[j].blockrect))){
                        file_list[j].blockrect.pressed=TRUE;
                        
                    }
                }                     
                        
               
            }else{
                inbox3(touches[i].mx,touches[i].my,&rload_cancel);	               
                inbox3(touches[i].mx,touches[i].my,&rload_go);
                inbox3(touches[i].mx,touches[i].my,&rect_flag);
            }
		}			
		if(touches[i].inuse==usage_id&&touches[i].down==M_RELEASE){
			
			
            
			
            if(inbox2(touches[i].mx,touches[i].my,&rect_cancel)){					
				[World getWorld].menu->showlistscreen=FALSE;
                [self searchAndHide:TRUE];
                [[World getWorld].menu->shareutil canceldl];
                if(previewScreenshot!=NULL){
                    [previewScreenshot release];
                    previewScreenshot=NULL;
                }
			}
            if(previewScreenshot==NULL){
                if(inbox2(touches[i].mx,touches[i].my,&rect_arrow_up)){
                    if(cur_page!=0)
                        cur_page--;
                }
                if(inbox2(touches[i].mx,touches[i].my,&rect_arrow_down)){
                    if(page_size*cur_page+page_size<num_files){
                        cur_page++;
                    }
					
                }
                if(cur_sort==SORT_NAME&&inbox2(touches[i].mx,touches[i].my,&sbrrect)){
                    [self activateKB];
                }else
                    if(inbox(touches[i].mx,touches[i].my,sbrect)){
                        if(cur_sort==SORT_NAME)
                            sbar->setStatus(@"\nLoading list.." ,9999);
                        else
                            sbar->setStatus(@"Loading list.." ,9999);
                        is_loading=1;
                        
                    }
                
                for(int j=cur_page*page_size;j<cur_page*page_size+page_size;j++){
                    if(j>=num_files)break;
                    if(inbox(touches[i].mx,touches[i].my,file_list[j].namerect)||
                       inbox(touches[i].mx,touches[i].my,file_list[j].daterect)||
                       inbox2(touches[i].mx,touches[i].my,&(file_list[j].blockrect))){
                        file_list[j].blockrect.pressed=FALSE;
                        if(j==list_selection){
                            loading_world=j+1;
                            sbar->setStatus(@"Downloading preview..." ,9999);
                            finished_preview_dl=false;
                            [[World getWorld].menu->shareutil loadSharedPreview:file_list[loading_world-1].file_name];
                            
                            
                        }else{
                            list_selection=j;
                        }
                    }
                }
            }else{
                
                if(inbox2(touches[i].mx,touches[i].my,&rload_cancel)){
                    if(previewScreenshot!=NULL){
                        [self setSortStatus];
                        [previewScreenshot release];
                        previewScreenshot=NULL;
                    }
                    // NSLog(@"hi");
                }
                if(inbox2(touches[i].mx,touches[i].my,&rload_go)){
                    finished_dl=false;
                    [[World getWorld].menu->shareutil loadShared:file_list[loading_world-1].file_name];
                    
                    
                    
                }
                if(inbox2(touches[i].mx,touches[i].my,&rect_flag)){
                    [alertReportContent show];
                    

                }

            }
			touches[i].inuse=0;
			touches[i].down=M_NONE;
		}
	}
    float anim_speed=200.0f;
    etime=1.0f/45.0f;
    float destination_offset=cur_page*(page_size*bsize);
    if(animation_offset<destination_offset){
        animation_offset+=anim_speed*etime;
        if(animation_offset>destination_offset){
            animation_offset=destination_offset;
        }
    }else if(animation_offset>destination_offset){
        animation_offset-=anim_speed*etime;
        if(animation_offset<destination_offset){
            animation_offset=destination_offset;
        }
    }
	
}
NSString* reportedWorlds[100];
int rwc_count=0;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	//NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if(alertView==alertReportContent){
        switch (buttonIndex) {
            case 0:
            {
               
                break;
            }
            case 1:
            {
                if(previewScreenshot!=NULL){
                    
                    [previewScreenshot release];
                    previewScreenshot=NULL;
                    is_loading=2;
                }
               
                if(rwc_count==100){
                    sbar->setStatus(@"Report limit reached, try again later" ,5);
                }else{
                    
                    sbar->setStatus(@"Report sent, thank you" ,5);
                    [[World getWorld].menu->shareutil reportWorld:file_list[loading_world-1].file_name];
                    reportedWorlds[rwc_count]=[file_list[loading_world-1].file_name copy];
                    rwc_count++;
                    
                    [alertReportConfirm show];
                
                }
                break;
            }
           
            default:
                break;
        }
    }
}
-(void)render{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"MM/dd/yyyy"];
	glColor4f(0.0, 0.0, 0.0, 1.0f);
    // if(previewScreenshot==NULL)
	
	glColor4f(1.0, 1.0, 1.0, 1.0f);
	
	[[[Resources getResources] getMenuTex:MENU_SHARED_HEADER] drawText:rect_header];	
	
	
	[[[Resources getResources] getMenuTex:MENU_BACK] drawButton:rect_cancel];
	
	
	
	glColor4f(1.0, 1.0, 1.0, 0.5f);
	if(cur_page!=0){
		glColor4f(1.0, 1.0, 1.0, 1.0f);
	}
    if(previewScreenshot==NULL){
        if(IS_IPAD)
        [[[Resources getResources] getMenuTex:MENU_ARROW_UP] drawButton:rect_arrow_up];
        else
        [[[Resources getResources] getMenuTex:MENU_ARROW_UP] drawButton2:rect_arrow_up];
    }
	glColor4f(1.0, 1.0, 1.0, 0.5f);	
	if(page_size*cur_page+page_size<num_files){		
		glColor4f(1.0, 1.0, 1.0, 1.0f);
	}	
     if(previewScreenshot==NULL)
         {
             if(IS_IPAD)
                 [[[Resources getResources] getMenuTex:MENU_ARROW_DOWN] drawButton:rect_arrow_down];
             else
                 [[[Resources getResources] getMenuTex:MENU_ARROW_DOWN] drawButton2:rect_arrow_down];
         }
	
	glColor4f(1.0, 1.0, 1.0, 1.0f);
	//[tex_load drawInRect:rect_load];
     if(previewScreenshot==NULL)
	for(int i=cur_page*page_size;i<cur_page*page_size+page_size;i++){
		if(i>=num_files)break;
		
	}

	glColor4f(1.0, 1.0, 1.0, 1.0f);

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	 if(previewScreenshot==NULL)
	[[[Resources getResources] getMenuTex:MENU_ARROW_LEFT] drawInRect:sort_left];
     if(previewScreenshot==NULL)
	[[[Resources getResources] getMenuTex:MENU_ARROW_RIGHT] drawInRect:sort_right];
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    // if(previewScreenshot==NULL)
	sort_bar->render();
   
     if(previewScreenshot==NULL)
      for(int i=0;i<num_files;i++){
          
		//if(i<cur_page*page_size||i>=cur_page*page_size+page_size)continue;
        file_list[i].namerect.origin.y+=animation_offset-
          i*(file_list[i].namerect.size.height+3)+
          (i%page_size)*(file_list[i].namerect.size.height+3);
          file_list[i].daterect.origin.y+=animation_offset-
          i*(file_list[i].namerect.size.height+3)+
          (i%page_size)*(file_list[i].namerect.size.height+3);
          file_list[i].blockrect.origin.y+=animation_offset-
          i*(file_list[i].namerect.size.height+3)+
          (i%page_size)*(file_list[i].namerect.size.height+3);
          
          //int n=i+(int)(animation_offset/bsize);
          float uplimit=195+9;
          float downlimit=23+9;
          
          if( file_list[i].blockrect.origin.y<uplimit+bsize&&
             file_list[i].blockrect.origin.y>downlimit-bsize){
              if(file_list[i].nametex==NULL){
                  if(IS_IPAD){
                      
                      file_list[i].nametex=[[Texture2D alloc] initWithString:file_list[i].name
                                                                    dimensions:CGSizeMake(
                                                                                          file_list[i].namerect.size.width*SCALE_WIDTH
                                                                                          , file_list[i].namerect.size.height*SCALE_HEIGHT)
                                                                     alignment:UITextAlignmentLeft
                                                                          font:[UIFont systemFontOfSize:17.0*2]];
                  }
                  else{
                      file_list[i].nametex= [[Texture2D alloc] initWithString:file_list[i].name
                                                                     dimensions:CGSizeMake(
                                                                                           file_list[i].namerect.size.width
                                                                                           , file_list[i].namerect.size.height)
                                                                      alignment:UITextAlignmentLeft
                                                                           font:[UIFont systemFontOfSize:17.0]];                  }
                  
                    }
              if(file_list[i].datetex==NULL){
                  NSString* fdate;
                  NSDate *date = [NSDate dateWithTimeIntervalSince1970:file_list[i].date]; 
                  fdate=[dateFormat stringFromDate:date];
                  if(IS_IPAD){
                      
                      file_list[i].datetex=[[Texture2D alloc] initWithString:fdate
                                                                    dimensions:CGSizeMake(
                                                                                          file_list[i].daterect.size.width*SCALE_WIDTH
                                                                                          , file_list[i].daterect.size.height*SCALE_HEIGHT)
                                                                     alignment:UITextAlignmentRight
                                                                          font:[UIFont systemFontOfSize:17.0*2]];
                  }
                  else{
                      file_list[i].datetex= [[Texture2D alloc] initWithString:fdate
                                                                     dimensions:CGSizeMake(
                                                                                           file_list[i].daterect.size.width
                                                                                           , file_list[i].daterect.size.height)
                                                                      alignment:UITextAlignmentRight
                                                                           font:[UIFont systemFontOfSize:17.0]];
                  }

              }
              float alpha=1.0;
              if( file_list[i].blockrect.origin.y>uplimit){
                  alpha=1-(file_list[i].blockrect.origin.y-uplimit)/bsize;
                  alpha*=alpha;
              }
              if( file_list[i].blockrect.origin.y<downlimit){
                  alpha=1-(downlimit-file_list[i].blockrect.origin.y)/bsize;
                  alpha*=alpha;
                  
                  
              }
              glColor4f(1.0, 1.0, 1.0, alpha);		
              if(list_selection==i)
                  [[[Resources getResources] getMenuTex:MENU_SHARED_BLOCK_SELECTED]
                   drawButton:file_list[i].blockrect];
              else
                  [[[Resources getResources] getMenuTex:MENU_SHARED_BLOCK_UNSELECTED]
                   drawButton:file_list[i].blockrect];
              glColor4f(0.0, 0.0, 0.0, alpha);
              
              CGPoint p=CGPointMake(file_list[i].namerect.origin.x,file_list[i].namerect.origin.y);
              if(IS_IPAD){
                  p.x*=SCALE_WIDTH;
                  p.y*=SCALE_HEIGHT;
                  p.y+=file_list[i].namerect.size.height;
              }else
                  p.y+=file_list[i].namerect.size.height/2;
              [file_list[i].nametex drawAtPoint:p];       
              p.x-=1;
              p.y+=1;
              glColor4f(1.0, 1.0, 1.0,alpha);
              [file_list[i].nametex drawAtPoint:p];
              
              glColor4f(0.0, 0.0, 0.0, alpha);
              
              p=CGPointMake(file_list[i].daterect.origin.x,file_list[i].daterect.origin.y);
              if(IS_IPAD){
                  p.x*=SCALE_WIDTH;
                  p.y*=SCALE_HEIGHT;
                  p.y+=file_list[i].daterect.size.height;
              }else
                  p.y+=file_list[i].daterect.size.height/2;
              [file_list[i].datetex drawAtPoint:p];       
              p.x-=1;
              p.y+=1;
              glColor4f(1.0, 1.0, 1.0, alpha);
              [file_list[i].datetex drawAtPoint:p];
          }else{
              if(file_list[i].nametex)[file_list[i].nametex release];
              if(file_list[i].datetex)[file_list[i].datetex release];
              file_list[i].nametex=file_list[i].datetex=NULL;
              
          }
          file_list[i].namerect.origin.y-=animation_offset-
          i*(file_list[i].namerect.size.height+3)+
          (i%page_size)*(file_list[i].namerect.size.height+3);
          
          file_list[i].daterect.origin.y-=animation_offset-
          i*(file_list[i].namerect.size.height+3)+
          (i%page_size)*(file_list[i].namerect.size.height+3);
          file_list[i].blockrect.origin.y-=animation_offset-
          i*(file_list[i].namerect.size.height+3)+
          (i%page_size)*(file_list[i].namerect.size.height+3);
      }
    if(previewScreenshot==NULL)
    if(cur_sort==SORT_NAME){        
        
        glColor4f(1.0f, 1.0f, 1.0f,1.0f);        
        [[[Resources getResources] getMenuTex:MENU_TEXT_BOX] drawInRect:input_background];
        glColor4f(0.0f, 0.0f, 0.0f,1.0f);        
        name_bar->renderPlain();
    }
    
    if(previewScreenshot!=NULL){
        CGRect border=CGRectMake(preview_box.origin.x-2,preview_box.origin.y-7,preview_box.size.width+8,preview_box.size.height+8);
        [[[Resources getResources] getTex:ICO_COLOR_SELECT_BACKGROUND] drawInRect:border];
        [previewScreenshot drawInRect:preview_box];
        glColor4f(1.0, 0.0, 0.0, 1.0f);
        [[[Resources getResources] getMenuTex:MENU_BACK_TEXT] drawButton:rload_cancel];
        glColor4f(0.0, 1.0, 0.0, 1.0f);
        [[[Resources getResources] getMenuTex:MENU_LOAD_TEXT] drawButton:rload_go];
        
        glColor4f(1.0,1.0,1.0,1.0);
        [[[Resources getResources] getMenuTex:MENU_FLAG] drawButton:rect_flag];
    }
    glColor4f(1.0, 1.0, 1.0, 1.0f);
    if(cur_sort==SORT_NAME&&previewScreenshot==NULL){
        CGRect sbrect2;
        sbrect2.origin.x=50;
        sbrect2.origin.y=12;
        sbrect2.size.width=SCREEN_WIDTH-100;
        sbrect2.size.height=20;
        
        sbar->pos=sbrect2;
         sbar->render();
         sbrect2.origin.y=SCREEN_HEIGHT-77;
        sbar->pos=sbrect2;
        
    }
    else
     sbar->render();
	glDisable(GL_BLEND);
	
	glDisable(GL_TEXTURE_2D);
	glColor4f(1.0, 1.0, 1.0, 1.0f);
	//[Graphics drawRectOutline:rect_cancel];
	//[Graphics drawRectOutline:rect_load];
    	/*CGRect rselect=file_list[list_selection].namerect;
	rselect.origin.x=0;
	rselect.size.width=SCREEN_WIDTH;
	rselect.origin.y+=5;
	*/
	glEnable(GL_TEXTURE_2D);
 [dateFormat release];
    
}
@end
