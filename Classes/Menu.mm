//
//  Menu.m
//  prototype
//
//  Created by Ari Ronen on 10/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Menu.h"
#import "Graphics.h"
#import "Globals.h"
#import "Util.h"
#import "World.h"
#import "zpipe.h"
#import "FileArchive.h"
#import "Alert.h"


//@synthesize loading,showsettings,sbar,is_sharing,
//			showlistscreen,selected_world,shared_list,shareutil;
extern float SCREEN_WIDTH; 
extern float SCREEN_HEIGHT;
extern float P_ASPECT_RATIO;
#define AUTO_LOAD false


static float fade_out=0;
Menu::Menu(){
   
    fade_out=0;
    settings=new SettingsMenu();
    menu_back=new Menu_background();
	delete_mode=FALSE;
	rect_name.size.width=284*.77f;
	rect_name.size.height=83*.77f;
	rect_name.origin.x=SCREEN_WIDTH/2-rect_name.size.width/2;
    rect_name.origin.y=SCREEN_HEIGHT-rect_name.size.height-10;
    if(IS_IPAD&&!IS_RETINA){
        rect_name.origin.x=SCREEN_WIDTH/2-(591/SCALE_WIDTH)/2.0f;
        rect_name.origin.y-=10;
    }
	

	rect_loading.size.width=150;
	rect_loading.size.height=40;
	rect_loading.origin.x=SCREEN_WIDTH/2-rect_loading.size.width/2;
	rect_loading.origin.y=SCREEN_HEIGHT-123;
	rect_loading.size.width=SCREEN_WIDTH;
	rect_loading.origin.x=0;
    if(IS_IPAD){
        rect_loading.origin.y-=10;
    }
	sbar=new statusbar(rect_loading);
	rect_loading.origin.y=SCREEN_HEIGHT-233;
	fnbar=new statusbar(rect_loading);
    share_menu=new ShareMenu();
	fnbar->clear();
	
	
	world_list=NULL;
	selected_world=NULL;
	this->loadWorlds();
	
	WorldNode* node=world_list;
	while(node!=NULL){
		node->rect.size.width=70;
		node->rect.size.height=70;
		node->rect.origin.x=(SCREEN_WIDTH/2);
		node->rect.origin.y=130;
		node->tex=Resources::getResources->getMenuTex(MENU_BLOCK_UNSELECTED);
		node->anim=node->rect;
		node=node->next;
	}
	
	left_arrow.size.width=36;
	left_arrow.size.height=89;
   // if(IS_IPAD)
	//left_arrow.origin.x=20;
   // else
    left_arrow.origin.x=0;
	left_arrow.origin.y=SCREEN_HEIGHT/2-45;
	
	right_arrow.size.width=36;
	right_arrow.size.height=89;
     if(IS_IPAD)
	right_arrow.origin.x=SCREEN_WIDTH-41;
    else
       right_arrow.origin.x=SCREEN_WIDTH-36; 
	right_arrow.origin.y=SCREEN_HEIGHT/2-45;
	
	
	
	rect_options.size.width=180;
	rect_options.size.height=62;
	rect_options.origin.x=(SCREEN_WIDTH)/2-90;
    
	rect_options.origin.y=5;
	
	rect_share.size.width=70;
	rect_share.size.height=70;
    if(!IS_IPAD)
	rect_share.origin.x=0;
    else{
    rect_share.origin.x=20;    
    }
	rect_share.origin.y=11;
	
	
	rect_loadshared.size.width=70;
	rect_loadshared.size.height=70;
	rect_loadshared.origin.x=SCREEN_WIDTH-70;
	rect_loadshared.origin.y=11;
	
	
	
	rect_delete.size.width=70;
	rect_delete.size.height=70;
    if(!IS_IPAD)
        rect_delete.origin.x=0;
    else{
        rect_delete.origin.x=20;    
    }
	rect_delete.origin.y=(SCREEN_HEIGHT-70);
	
	
	rect_create.size.width=70;
	rect_create.size.height=70;
	rect_create.origin.x=(SCREEN_WIDTH-70);
	rect_create.origin.y=(SCREEN_HEIGHT-70);
	
	
	shareutil=[[ShareUtil alloc] init];
	showsettings=FALSE;
	is_sharing=FALSE;
    showlistscreen=FALSE;
    loading=FALSE;
	loading_world_list=0;
	
    shared_list=new SharedList();
	
    
   /*  WorldNode* new_world;
    
    ///sample terrain gens
   new_world=malloc(sizeof(WorldNode));
    memset(new_world,0,sizeof(WorldNode));
    new_world->display_name=@"Mountains";
    new_world->file_name=[NSString stringWithFormat:@"%@.eden",genhash()];
    [new_world->file_name retain];
    [new_world->display_name retain];
    [self addWorld:new_world];
    selected_world=new_world;
    [sbar setStatus:[NSString stringWithFormat:@"%@ created",new_world->display_name]
                   :2];
    [fnbar setStatus:selected_world->display_name :9999];
    
    
  // WorldNode* new_world;
    new_world=malloc(sizeof(WorldNode));
    memset(new_world,0,sizeof(WorldNode));
    new_world->display_name=@"Red planet";
    new_world->file_name=[NSString stringWithFormat:@"%@.eden",genhash()];
    [new_world->file_name retain];
    [new_world->display_name retain];
    [self addWorld:new_world];
    selected_world=new_world;
    [sbar setStatus:[NSString stringWithFormat:@"%@ created",new_world->display_name]
                   :2];
    [fnbar setStatus:selected_world->display_name :9999];
    
    new_world=malloc(sizeof(WorldNode));
    memset(new_world,0,sizeof(WorldNode));
    new_world->display_name=@"River Trees";
    new_world->file_name=[NSString stringWithFormat:@"%@.eden",genhash()];
    [new_world->file_name retain];
    [new_world->display_name retain];
    [self addWorld:new_world];
    selected_world=new_world;
    [sbar setStatus:[NSString stringWithFormat:@"%@ created",new_world->display_name]
                   :2];
    [fnbar setStatus:selected_world->display_name :9999];
    
    
    new_world=malloc(sizeof(WorldNode));
    memset(new_world,0,sizeof(WorldNode));
    new_world->display_name=@"Ice slides";
    new_world->file_name=[NSString stringWithFormat:@"%@.eden",genhash()];
    [new_world->file_name retain];
    [new_world->display_name retain];
    [self addWorld:new_world];
    selected_world=new_world;
    [sbar setStatus:[NSString stringWithFormat:@"%@ created",new_world->display_name]
                   :2];
    [fnbar setStatus:selected_world->display_name :9999];
    
    new_world=malloc(sizeof(WorldNode));
    memset(new_world,0,sizeof(WorldNode));
    new_world->display_name=@"Ponies";
    new_world->file_name=[NSString stringWithFormat:@"%@.eden",genhash()];
    [new_world->file_name retain];
    [new_world->display_name retain];
    [self addWorld:new_world];
    selected_world=new_world;
    [sbar setStatus:[NSString stringWithFormat:@"%@ created",new_world->display_name]
                   :2];
    [fnbar setStatus:selected_world->display_name :9999];*/
    
    
    /*
     if(g_terrain_type==0){
     makeDirt();
     }else if(g_terrain_type==1){
     makeMars();
     }else if(g_terrain_type==2){
     makePonyWorld();
     }else if(g_terrain_type==3){
     makeMountains();
     }else if(g_terrain_type==4){
     makeDesert();
     }*/
    
	
}
void Menu::activate(){
    NSLog(@"entering menu");
    autosavetracktouches(false);
    fade_out=0;
	sbar->setStatus(@"Choose world to load" ,99999);
	if(selected_world!=NULL)
	fnbar->setStatus(selected_world->display_name ,9999);
	share_menu->activate();
	shared_list->activate();
}
void Menu::deactivate(){
    NSLog(@"exiting menu");
    autosavetracktouches(true);
    sbar->clear();
    fnbar->clear();
    share_menu->deactivate();
	shared_list->deactivate();
	
}
void Menu::loadWorlds(){
	world_list=NULL;
	selected_world=NULL;
	NSError* err;
	NSArray* dirContents = [[NSFileManager defaultManager] 
							
							contentsOfDirectoryAtPath:World::getWorld->fm->documents error:&err];
    
    
    //readIndex();
	world_list_end=world_list;
    int dirc=(int)[dirContents count];
    BOOL reloadDir=FALSE;
    
  /*  for(int i=0;i<dirc;i++){
		NSString* file_name=[dirContents objectAtIndex:i];
        if([file_name hasSuffix:@".eden"]){
            if([file_name isEqualToString:@"Eden.eden"])continue;
            CompressWorld([file_name cStringUsingEncoding:NSUTF8StringEncoding]);
            reloadDir=TRUE;
        }
        
    }*/
    if(reloadDir){
        dirContents=[[NSFileManager defaultManager]
         
         contentsOfDirectoryAtPath:World::getWorld->fm->documents error:&err];
        dirc=(int)[dirContents count];
    }
    
	for(int i=0;i<dirc;i++){
		NSString* file_name=[dirContents objectAtIndex:i];
        NSLog(@"%@",file_name);
        if([file_name isEqualToString:@"Eden.eden.archive"])continue;
		//NSString* real_name=[NSString stringWithFormat:@"test%d",i];
        
        NSString* wut=[file_name pathExtension];
        wut=[wut uppercaseString];
        if([wut isEqualToString:@"PNG"]){
            continue;
        }
        if(![wut isEqualToString:@"EDEN"])
            continue;
        
		NSString* real_name=World::getWorld->fm->getName(file_name);
        if(real_name==NULL){
            real_name=@"Unknown World";
        }
        
		NSLog(@"'%@'",real_name);
        if([real_name isEqualToString:@"error~"]){
            continue;
        }
        
       // file_name=[file_name stringByDeletingPathExtension];
		WorldNode* node=(WorldNode*)malloc(sizeof(WorldNode));
		memset(node, 0, sizeof(WorldNode));
		node->display_name=real_name;
		node->file_name=file_name;
		[node->display_name retain];
		[node->file_name retain];
		if(world_list_end==NULL){
			world_list_end=node;
			world_list=node;
			selected_world=node;
			fnbar->setStatus(selected_world->display_name ,9999);
		}else{
			world_list_end->next=node;
			node->prev=world_list_end;
			world_list_end=node;			
		}
		
		
	}
	if(world_list==NULL){
		WorldNode* new_world;
		new_world=(WorldNode*)malloc(sizeof(WorldNode));
		memset(new_world,0,sizeof(WorldNode));
		new_world->display_name=settings->getNewWorldName();
		new_world->file_name=[NSString stringWithFormat:@"%@.eden",genhash()];
		[new_world->file_name retain];
		[new_world->display_name retain];
        addWorld(new_world);
		if(selected_world)
		fnbar->setStatus(selected_world->display_name ,9999);
	}
}
void Menu::addWorld(WorldNode* node){
	if(world_list_end==NULL){
		world_list_end=node;
		world_list=node;
		selected_world=node;		
	}else{
		world_list_end->next=node;
		node->prev=world_list_end;
		world_list_end=node;			
	}
}
void Menu::removeWorld(WorldNode* node){
	if(node==NULL)return;
	if(node==selected_world){
		if(node->prev)
			selected_world=node->prev;
		else {
			selected_world=node->next;
		}
	}
	if(node==world_list_end)world_list_end=node->prev;
	if(node==world_list)world_list=node->next;
	if(node->prev){
		node->prev->next=node->next;
	}
	if(node->next){
		node->next->prev=node->prev;
	}
	
	free(node);
	if(selected_world)
		fnbar->setStatus(selected_world->display_name ,9999);
	else{
		fnbar->setStatus(@"" ,9999);
	}
}
static const int usage_id=7;
#define SPACE 75
void Menu::update(float etime){
	menu_back->update(etime);
	if(is_sharing){
		share_menu->update(etime);
		return;
	}
    if(loading){
        if(loading>=4&&LOW_MEM_DEVICE)
        fade_out+=etime/2;
        return;
    }
	if(loading_world_list){
		loading_world_list=0;
        shared_list->finished_list_dl=FALSE;
        
		[shareutil getSharedWorldList];
		showlistscreen=TRUE;
        
	}
	if(showsettings){
		settings->update(etime);
		return;
	}
	if(showlistscreen){
		shared_list->update(etime);
		
	}
	WorldNode* node=world_list;
	while(node!=NULL){
		node->rect.size.width=0;
		node->rect.size.height=0;
		//node->rect.origin.x=-1;
		//node->rect.origin.y=-1;
		node->tex=Resources::getResources->getMenuTex(MENU_BLOCK_UNSELECTED);
		node=node->next;
	}
	activeRightArrow=FALSE;
	activeLeftArrow=FALSE;
	if(selected_world!=NULL){
		selected_world->rect.size.width=85;
		selected_world->rect.size.height=85;
		selected_world->rect.origin.x=(SCREEN_WIDTH/2-selected_world->rect.size.width/2);
		selected_world->rect.origin.y=130;
		selected_world->tex=Resources::getResources->getMenuTex(MENU_BLOCK_SELECTED);
		if(selected_world->prev!=NULL){
			activeLeftArrow=TRUE;
			selected_world->prev->rect.size.width=85;
			selected_world->prev->rect.size.height=85;
			selected_world->prev->rect.origin.x=
				(SCREEN_WIDTH/2-selected_world->rect.size.width/2)-SPACE;
			selected_world->prev->rect.origin.y=130;	
			if(selected_world->prev->prev!=NULL){
				selected_world->prev->prev->rect.size.width=85;
				selected_world->prev->prev->rect.size.height=85;
				selected_world->prev->prev->rect.origin.x=
				(SCREEN_WIDTH/2-selected_world->rect.size.width/2)-SPACE*2;
				selected_world->prev->prev->rect.origin.y=130;					
			}
		}
		if(selected_world->next!=NULL){
			activeRightArrow=TRUE;	
			selected_world->next->rect.size.width=85;
			selected_world->next->rect.size.height=85;
			selected_world->next->rect.origin.x=(SCREEN_WIDTH/2-selected_world->rect.size.width/2)
												+SPACE;
			selected_world->next->rect.origin.y=130;	
			if(selected_world->next->next!=NULL){
				selected_world->next->next->rect.size.width=85;
				selected_world->next->next->rect.size.height=85;
				selected_world->next->next->rect.origin.x=(SCREEN_WIDTH/2-selected_world->rect.size.width/2)
				+SPACE*2;
				selected_world->next->next->rect.origin.y=130;	
				
				if(selected_world->next->next->next!=NULL){		
					selected_world->next->next->next->rect.origin.x=(SCREEN_WIDTH/2-selected_world->rect.size.width/2)
					+SPACE*3;
				}
			}
		}
	}
	while(node!=NULL){
		if(!node->rect.size.width){
			node->anim.size.width=0;
			node->anim.size.height=0;
		}
		
	}
	Input* input=Input::getInput();
    itouch* touches=input->getTouches();
	sbar->update(etime);
    
   
    
	for(int i=0;i<MAX_TOUCHES;i++){
		if(touches[i].inuse==0&&touches[i].down==M_DOWN){
			touches[i].inuse=usage_id;
			inbox3(touches[i].mx,touches[i].my,&right_arrow);            
			inbox3(touches[i].mx,touches[i].my,&rect_options);
			inbox3(touches[i].mx,touches[i].my,&rect_create);
			inbox3(touches[i].mx,touches[i].my,&left_arrow)	;		
            inbox3(touches[i].mx,touches[i].my,&rect_delete);
			inbox3(touches[i].mx,touches[i].my,&rect_share);
			inbox3(touches[i].mx,touches[i].my,&rect_loadshared);                
            WorldNode* node=world_list;
			while(node!=NULL){
                inbox3(touches[i].mx,touches[i].my,&(node->anim));
                node=node->next;
            }
		}			
		if(touches[i].inuse==usage_id&&touches[i].down==M_RELEASE){
			
			WorldNode* node=world_list;
			while(node!=NULL){
                inbox2(touches[i].mx,touches[i].my,&(node->anim));
				if(inbox2(touches[i].mx,touches[i].my,&(node->rect))){	
					if(node==selected_world){					
						if(delete_mode){	
							if(selected_world){
                               /* if(!World::getWorld->FLIPPED){
                                    [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeRight;
                                }
                                else{
                                    [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeLeft;
                                    
                                }*/
                                showAlertDeleteConfirm([NSString stringWithFormat:@"Are you sure you want to delete \"%@\"?",selected_world->display_name]);
                                 
                                

                                delete_mode=FALSE;
							}
							break;
							
						}else if(share_mode){
							share_mode=FALSE;
							
							
							if(World::getWorld->fm->worldExists(cpstring(node->file_name),TRUE)){
								sbar->setStatus(@"Sharing world..." ,2);
								is_sharing=TRUE;
								share_menu->beginShare(node);
							}else{
								sbar->setStatus(@"World is empty" ,2);
							}
							
							
						
						}else{
                            if(loading==0){
							loading=1;
							sbar->setStatus(@"Loading " ,9999);
                            }
						}	
					}else{
						selected_world=node;
						fnbar->setStatus(selected_world->display_name ,9999);
					}
				}
				node=node->next;
			}
			if(delete_mode){
				sbar->clear();
				delete_mode=FALSE;
			}
			if(share_mode){
				sbar->clear();
				share_mode=FALSE;
			}
			
			if(inbox2(touches[i].mx,touches[i].my,&rect_options)){				
				showsettings=TRUE;				
			}
			if(inbox2(touches[i].mx,touches[i].my,&rect_create)){
				WorldNode* new_world;
				new_world=(WorldNode*)malloc(sizeof(WorldNode));
				memset(new_world,0,sizeof(WorldNode));
				new_world->display_name=settings->getNewWorldName();
				new_world->file_name=[NSString stringWithFormat:@"%@.eden",genhash()];
				[new_world->file_name retain];
				[new_world->display_name retain];
				addWorld(new_world);
				selected_world=new_world;				
				sbar->setStatus([NSString stringWithFormat:@"%@ created",new_world->display_name]
							   ,2);
				fnbar->setStatus(selected_world->display_name ,9999);
			}
			if(inbox2(touches[i].mx,touches[i].my,&left_arrow)){
				if(selected_world&&selected_world->prev){
					selected_world=selected_world->prev;
					fnbar->setStatus(selected_world->display_name ,9999);
				}
			}
			if(inbox2(touches[i].mx,touches[i].my,&right_arrow)){
				if(selected_world&&selected_world->next){
					selected_world=selected_world->next;
					fnbar->setStatus(selected_world->display_name ,9999);
				}
			}
			if(inbox2(touches[i].mx,touches[i].my,&rect_delete)){
				sbar->setStatus(@"Choose world to delete" ,9999);
				delete_mode=TRUE;					
			}
			if(inbox2(touches[i].mx,touches[i].my,&rect_share)){
				sbar->setStatus(@"Choose world to share" ,9999);
				share_mode=TRUE;					
			}
			if(inbox2(touches[i].mx,touches[i].my,&rect_loadshared)){		
				sbar->setStatus(@"Getting world list. ",2);
				loading_world_list=1;
							
			}
			touches[i].inuse=0;
			touches[i].down=M_NONE;
		}
	}
			
	/*Input* input=[Input getInput];
	if(input.click){
		
		
	}*/
	
}

BOOL Menu::loadShared(SharedListNode* sharedNode){
    NSString* rfile_name=[NSString stringWithFormat:@"%@/%@",World::getWorld->fm->documents,sharedNode->file_name];

    const char* fname=[rfile_name cStringUsingEncoding:NSUTF8StringEncoding];
  //  NSString* new_name=[NSString stringWithFormat:@"%@/%@.archive",World::getWorld->fm.documents,sharedNode->file_name];
   // const char* cnewname=[new_name cStringUsingEncoding:NSUTF8StringEncoding];
    
    
  //  rename(fname,cnewname);
    NSString* temp_name=[NSString stringWithFormat:@"%@/temp",World::getWorld->fm->documents];
    const char* tname=[temp_name cStringUsingEncoding:NSUTF8StringEncoding];
    
    
   FILE* fsource = fopen(fname, "rb");
    if(!fsource){
        NSLog(@"cant open %s",fname);
        return FALSE;
    }
    
    FILE* fdest = fopen(tname, "wb");
    if(!fdest)
    {
        NSLog(@"cant open temp");
        fclose(fsource);
        return FALSE;
    }
    NSLog(@"source: %s\ndest: %s\n",fname,tname);
     int ret=decompressFile(fsource, fdest);
  
    
    fclose(fsource);
    fclose(fdest);
    remove(fname);
    rename(tname,fname);
    if (ret != Z_OK){
        zerr(ret);
        remove(fname);
        return FALSE;
    }
    
    
	WorldNode* new_world;
	new_world=(WorldNode*)malloc(sizeof(WorldNode));
	memset(new_world,0,sizeof(WorldNode));
	new_world->display_name=sharedNode->name;
	new_world->file_name=sharedNode->file_name;
	[new_world->file_name retain];
	[new_world->display_name retain];
	addWorld(new_world);
	selected_world=new_world;
    fnbar->setStatus(selected_world->display_name ,9999);
    
    
   // addToIndex([selected_world->file_name cStringUsingEncoding:NSUTF8StringEncoding],selected_world->display_name);
   
   // addToIndex([selected_world->file_name cStringUsingEncoding:NSUTF8StringEncoding],selected_world->display_name);
	
   
	//[shareutil loadShared:sharedNode->file_name];
	return TRUE;	
	
}
void Menu::refreshfn(){
 fnbar->setStatus(selected_world->display_name ,9999);
	
}
void Menu::render(){
    Graphics::prepareMenu();
	
    
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    
    
		glColor4f(1.0, 1.0, 1.0, 1.0f);
	menu_back->render();
	
	
	
	if(showsettings){
		settings->render();
        Graphics::endMenu();
		
		return;
	}
	if(showlistscreen){
		shared_list->render();
        Graphics::endMenu();
		
		return;
	}
	if(is_sharing==1){
		share_menu->render();
        Graphics::endMenu();
		
		return;
	}
		glColor4f(1.0, 1.0, 1.0, 1.0f);
	//[Graphics drawRect:20:20:SCREEN_WIDTH-20:SCREEN_HEIGHT-20];
	
    if(IS_IPAD&&!IS_RETINA)
        Resources::getResources->getMenuTex(MENU_LOGO)->drawText(rect_name);
    else
	Resources::getResources->getMenuTex(MENU_LOGO)->drawInRect2(rect_name);
	glColor4f(1.0, 1.0, 1.0, 1.0f);
	WorldNode* node=world_list;
	
	while(node!=NULL){		
		if(node->anim.size.width||node->rect.size.width){
			Vector vec;
			vec.z=0;
			vec.x=node->rect.origin.x-node->anim.origin.x;
			vec.y=node->rect.origin.y-node->anim.origin.y;
			NormalizeVector(&vec);
			
			float d=node->rect.size.width-node->anim.size.width;
			if(d<.00001&&d>-.00001)d=0.00001;
			d=d/absf(d);
			d*=10;
			node->anim.size.width+=d;
			node->anim.size.height+=d;
			float d2=node->rect.size.width-node->anim.size.width;
			if((d>=0&&d2<=0)||(d<=0&&d2>=0)){
				node->anim.size.width=node->rect.size.width;
				node->anim.size.height=node->rect.size.height;
			}

			
		
			node->anim.origin.x+=(vec.x*10);
			node->anim.origin.y+=(vec.y*10);
			
			Vector vec2;
			vec2.z=0;
			vec2.x=node->rect.origin.x-node->anim.origin.x;
			vec2.y=node->rect.origin.y-node->anim.origin.y;
			if((vec2.x>=0&&vec.x<=0)||(vec2.x<=0&&vec.x>=0)){
				node->anim.origin.x=node->rect.origin.x;
				node->anim.origin.y=node->rect.origin.y;
			}
            float nn=85;
            if(IS_IPAD)
                nn=115/SCALE_HEIGHT;
            if(node->anim.size.width<nn){
               
                if(node==selected_world)
                    Resources::getResources->getMenuTex(MENU_BLOCK_SELECTED)->drawButton2(node->anim);
                else {
                    Resources::getResources->getMenuTex(MENU_BLOCK_UNSELECTED)->drawButton2(node->anim);
                }
               
                
            }else{
			if(node==selected_world)
			Resources::getResources->getMenuTex(MENU_BLOCK_SELECTED)->drawButton(node->anim);
			else {
				Resources::getResources->getMenuTex(MENU_BLOCK_UNSELECTED)->drawButton(node->anim);
			}
            }

		}
		node=node->next;
	}
	Resources::getResources->getMenuTex(MENU_OPTIONS)->drawButton(rect_options);
	Resources::getResources->getMenuTex(MENU_DELETE_WORLD)->drawButton(rect_delete);
	Resources::getResources->getMenuTex(MENU_CREATE_WORLD)->drawButton(rect_create);
	Resources::getResources->getMenuTex(MENU_SHARE_WORLD)->drawButton(rect_share);
	Resources::getResources->getMenuTex(MENU_LOAD_WORLD)->drawButton(rect_loadshared);
	glColor4f(1.0, 1.0, 1.0, 1.0f);
	if(!activeLeftArrow)
		glColor4f(1.0, 1.0, 1.0, 0.3f);
	Resources::getResources->getMenuTex(MENU_ARROW_LEFT)->drawButton(left_arrow);
	glColor4f(1.0, 1.0, 1.0, 1.0f);
	if(!activeRightArrow)
		glColor4f(1.0, 1.0, 1.0, 0.3f);
	Resources::getResources->getMenuTex(MENU_ARROW_RIGHT)->drawButton(right_arrow);
	glDisable(GL_TEXTURE_2D);
	if(delete_mode)
		glColor4f(1.0, 0.0, 0.0, 1.0f);
	else if(share_mode){
		glColor4f(0.0, 1.0, 0.0, 1.0f);
	}
	
	glColor4f(0.0, 0.0, 0.0, 1.0f);
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_TEXTURE_2D);
	sbar->render();
	fnbar->render();
    if(AUTO_LOAD&&loading==0){
       
        
        loading=2;
    }
	if(loading){
		if(loading==2){
			if(selected_world!=NULL){
				
				//NSString* wname=selected_world->file_name;
                if(World::getWorld->fm->worldExists(cpstring(selected_world->file_name),TRUE)){
				//[[World getWorld] loadWorld:wname];
                    loading=4;
                }
                else{
                    extern int g_terrain_type;
                        
                    g_terrain_type=0;
                    if([selected_world->display_name isEqualToString:@"Mountains"]){
                        g_terrain_type=3;
                    }else if([selected_world->display_name isEqualToString:@"Red planet"]){
                        g_terrain_type=1;
                    }else if([selected_world->display_name isEqualToString:@"River Trees"]){
                        g_terrain_type=2;
                    }else if([selected_world->display_name isEqualToString:@"Desert"]){
                        g_terrain_type=4;
                    }else if([selected_world->display_name isEqualToString:@"Ponies"]){
                        g_terrain_type=5;
                    }else if([selected_world->display_name isEqualToString:@"Normal"]){
                        g_terrain_type=0;
                    }
                  //  g_terrain_type=2;
                   
                    //loading=4;
                    /*new world prompt
                    if(!World::getWorld->FLIPPED){
                        [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeRight;
                    }
                    else{
                        [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeLeft;
                        
                    }*/
                    
                    showAlertWorldType();
                    
                    loading++;
                }
				
				//[sbar clear];
			}
		}else if(loading==4){
            if(LOW_MEM_DEVICE){
                if(fade_out>=1.0f){
                    NSString* wname=selected_world->file_name;
           
                    World::getWorld->loadWorld(wname);
                }
            }else{
                NSString* wname=selected_world->file_name;
                
                World::getWorld->loadWorld(wname);
            }

            
        }else if(loading<2){
            //NSLog(@"load world %@",selected_world->file_name);
            loading++;
        }
		
	}
    
    if(fade_out>0){
        glColor4f(0,0,0,fade_out);
        glDisable(GL_TEXTURE_2D);
        glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        if(IS_IPAD){
            if(IS_RETINA){
                Graphics::drawRect(0,0,SCREEN_WIDTH*2,SCREEN_HEIGHT*2);
            }else
                Graphics::drawRect(0,0,IPAD_WIDTH,IPAD_HEIGHT);
        }else{
            Graphics::drawRect(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
            
        }
        glEnable(GL_TEXTURE_2D);
        sbar->render();
    }
	glDisable(GL_BLEND);
    Graphics::endMenu();
    
}

void Menu::a_genFlat(BOOL b){
    World::getWorld->fm->genflat=b;
    loading++;
}
void Menu::a_deleteCancel(){
    sbar->setStatus(@"" ,2);
}
void Menu::a_deleteConfirm(){
     NSString* wname=selected_world->file_name;
     removeWorld(selected_world);
     
     if(World::getWorld->fm->deleteWorld(wname))
     sbar->setStatus(@"World deleted" ,2);
     else{
     NSLog(@"delete failed\n");
     sbar->setStatus(@"World deleted"  ,2);
     }
    
}

