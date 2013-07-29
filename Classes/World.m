//
//  World.m
//  prototype
//
//  Created by Ari Ronen on 10/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "World.h"
#import "OpenGL_Internal.h"
#import "Model.h"
#import "EAGLView.h"
#import "Globals.h"
#import "TerrainGen2.h"

#define JUST_TERRAIN_GEN 0
static	World* singleton;
@implementation World
@synthesize cam, terrain, player, hud,fm/*,FLIPPED*/,effects,realtime,bestGraphics,sf_lock,rebuild_lock;
@synthesize game_mode,menu;
extern EAGLView* G_EAGL_VIEW;
 BOOL exit_to_menu=FALSE;
- (World*)init{
    singleton=self;
    if(JUST_TERRAIN_GEN){
        double start=CFAbsoluteTimeGetCurrent();
        printf("Terrain gen started\n");
        fm=[[FileManager alloc] init];
        tg2_init();
        printf("Terrain gen finished %f\n",(CFAbsoluteTimeGetCurrent()-start));
        start=CFAbsoluteTimeGetCurrent();
         [[World getWorld].fm writeGenToDisk];
        printf("File write finished %f\n",(CFAbsoluteTimeGetCurrent()-start));
        return self;
    }
    tc_initGeometry();
    game_mode=GAME_MODE_MENU;
    
    bestGraphics=TRUE;
    [Graphics initGraphics];
    terrain=[[Terrain alloc] init];	
    cam=[[Camera alloc] init];
    res=[Resources getResources];
    player=[[Player alloc] initWithWorld:self];
    hud=[[Hud alloc] init];
    fm=[[FileManager alloc] init];
    effects=[[SpecialEffects alloc] init];
    menu=[[Menu alloc] init];
    sf_lock=[[NSLock alloc] init];
    rebuild_lock=[[NSLock alloc] init];
          
    [NSThread detachNewThreadSelector:@selector(loadWorldThread2:) toTarget:self withObject:self];
    [terrain startLoadingThread];
  //  FLIPPED=FALSE;
    [[Resources getResources] playMenuTune];
   // [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeRight;
    
     //tg2_init();
   
	/*int crapsize=1;//(16777216);
	int* crap=malloc(sizeof(int)*crapsize);
	for(int i=0;i<crapsize;i++){
		crap[i]=rand();
	}*/
	
    doneLoading=0;
	//NSLog(@"glerr:%s",gluErrorString(glGetError()));	
	return self;
}
- (void)loadWorldThread2:(id)object{    
    World* world=object;
    
    [NSThread setThreadPriority:0.1f];
    printf("Loading thread started, priority: %f\n",[NSThread threadPriority]);  
      int i=0;
    while(true){
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
       // goto cleanup;
        if(world.terrain.loaded){
            int chunkOffsetX=player.pos.x/CHUNK_SIZE-T_RADIUS;
            int chunkOffsetZ=player.pos.z/CHUNK_SIZE-T_RADIUS;
            int r=T_RADIUS;
            bool isloaded[T_RADIUS*2][T_RADIUS*2];
            int count=0;
                       //NSLog(@"player p
            for(int x=0;x<2*r;x++){
                for(int z=0;z<2*r;z++){
                    //	NSLog(@"lch:%d",asdf++);
                    TerrainChunk* chunk;
                    chunk=world.terrain.chunkTable[threeToOne(x+chunkOffsetX,0,z+chunkOffsetZ)];
                   // hashmap_get(world.terrain.chunkMap, threeToOne(x+chunkOffsetX, 0, z+chunkOffsetZ), (any_t)&chunk);
                    if(chunk){
                       
                        
                        if( chunk.pbounds[0]!=(x+chunkOffsetX)*CHUNK_SIZE||
                            chunk.pbounds[2]!=(z+chunkOffsetZ)*CHUNK_SIZE)
                       
                        
                        {
                            
                            //   printf("(%d,%d)=?=(%d,%d)\n",chunk.pbounds[0],chunk.pbounds[2],(x+chunkOffsetX)*CHUNK_SIZE,(z+chunkOffsetZ)*CHUNK_SIZE);  
                          
                            count++;
                            isloaded[x][z]=FALSE;
                          //  printf("overwriting a chunk\n");
                          
                        }
                          else
                        isloaded[x][z]=TRUE;
                      
                    }
                    else{
                        count++;
                        isloaded[x][z]=FALSE;
                    }
                   		
                }
            }
            if(count==0) goto cleanup;
            // printf("chunks to load:%d\n",count);
            NSString* file_name=[NSString stringWithFormat:@"%@/%@",world.fm.documents,world.terrain.world_name];		
            
            [sf_lock lock];
            NSFileHandle* saveFile=[NSFileHandle fileHandleForReadingAtPath:file_name];
            
            for(int x=0;x<2*r;x++){
                for(int z=0;z<2*r;z++){
                    if(!isloaded[x][z]){
                        [world.fm readColumn: x+chunkOffsetX:z+chunkOffsetZ:saveFile];
                    }
                }
            }
             
            [saveFile closeFile];
            [sf_lock unlock];
            
            /*for(int x=0;x<2*r;x++){
                for(int z=0;z<2*r;z++){
                    if(!isloaded[x][z]){
                        int dirx=-T_RADIUS*2;
                        int dirz=-T_RADIUS*2;
                        if(x<r)dirx=-dirx;
                        if(z<r)dirz=-dirz;
                        TerrainChunk* chunk;
                        hashmap_get(world.terrain.chunkMap, threeToOne(x+chunkOffsetX+dirx, 0, z+chunkOffsetZ), (any_t)&chunk);
                        if(chunk){
                           
                                for(int i=0;i<CHUNKS_PER_COLUMN;i++)
                                    [terrain addToDeleteList:x+chunkOffsetX+dirx:i:z+chunkOffsetZ];
                                                            
                        }
                       
                        hashmap_get(world.terrain.chunkMap, threeToOne(x+chunkOffsetX, 0, z+chunkOffsetZ+dirz), (any_t)&chunk);
                        if(chunk){
                            
                            for(int i=0;i<CHUNKS_PER_COLUMN;i++)
                                [terrain addToDeleteList:x+chunkOffsetX+dirx:i:z+chunkOffsetZ+dirz];
                            
                        }

                      //  [rebuild_lock lock];
                      //  [NSThread sleepForTimeInterval:0.10f];
                        
                      //  [rebuild_lock unlock];
                    }
                }
            }*/
            
           
            
        } 
        i+=(int)sqrt(2);;
        //[NSThread sleepForTimeInterval:0.50f];
        
    cleanup: 
        [pool release];
    }
   
    //
    
    
    //do_reload=4;
   
}
- (void)loadWorldThread:(id)object{
    
 
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
   [terrain loadTerrain:object];
    doneLoading=2;
    [pool release];
    
}
extern int chunk_load_count;
- (void)loadWorld:(NSString*)name{
    if(doneLoading==0){
        doneLoading=1;
        [[Resources getResources] stopMenuTune];
        
        [NSThread detachNewThreadSelector:@selector(loadWorldThread:) toTarget:self withObject:name];  
    }else{
        int pct=99*chunk_load_count/(2304/4)+terrain.counter/2;
        
        if(pct>100)pct=100;
        if(fm.convertingWorld){
            [menu.sbar setStatus:@"Converting World...":100];
        }else
            [menu.sbar setStatus:[NSString stringWithFormat:@"Loading World... %d%%",pct]:20];
        
        
        if(doneLoading==2){
         //   printf("done loading !\n");
            [menu deactivate];
            [[Resources getResources] unloadMenuTextures];
            [[Resources getResources] loadGameAssets];
            
            // [terrain loadTerrain:name];
            doneLoading=0;
            [cam reset];
            [player reset];
            game_mode=GAME_MODE_WAIT;
            target_game_mode=GAME_MODE_PLAY;
            menu.loading=0;
            [menu.sbar clear];
            
            
            
             
            if(CREATURES_ON){
               
                LoadModels([[NSString stringWithFormat:@"%@/",[[NSBundle mainBundle] resourcePath]] cStringUsingEncoding:NSUTF8StringEncoding]);
            }
            
        }
    }
	
}
- (void)exitToMenu{	
    exit_to_menu=FALSE;
   // printf("hihihi\n");
	[terrain unloadTerrain:FALSE];
    if(CREATURES_ON){
        UnloadModels();
    }
   // printf("loading menu textures\n");
    [[Resources getResources] unloadGameAssets];
	[[Resources getResources] loadMenuTextures];
    if(SUPPORTS_RETINA&&!IS_RETINA){
      //  printf("menu activated2\n");

        IS_IPAD=TRUE;
        IS_RETINA=TRUE;
       
        SCALE_WIDTH=2;
        SCALE_HEIGHT=2;
        [menu activate];
        IS_IPAD=FALSE;
        IS_RETINA=FALSE;
        SCALE_WIDTH=1;
        SCALE_HEIGHT=1;
        
    }else{
       // printf("menu activated\n");
        [menu activate];
   	}

	[[Resources getResources] playMenuTune];
	target_game_mode=GAME_MODE_WAIT;
    game_mode=GAME_MODE_WAIT;
//printf("hi\n");
	
	
}
+ (World*)getWorld{
	return singleton;
}
- (void)dealloc{
	[terrain release];
	[player release];
	[cam release];
	[res release];
	[hud release];
	[menu release];
	[fm release];
	[effects release];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	[super dealloc];
}
- (BOOL)update: (float)etime{
    if(JUST_TERRAIN_GEN){
        return FALSE;
    }
    if(game_mode==GAME_MODE_WAIT){
        if(SUPPORTS_RETINA&&!bestGraphics){
            return TRUE;
        }
       
        return FALSE;
    }
    realtime=etime;
   // NSLog(@"Hi");
	if([World getWorld].menu.is_sharing!=1){
	/*if([UIDevice currentDevice].orientation==UIDeviceOrientationLandscapeRight){
		//[UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeRight;
        if(FLIPPED==FALSE)
            [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeLeft;
        
		FLIPPED=TRUE;
        
	}
	else if([UIDevice currentDevice].orientation==UIDeviceOrientationLandscapeLeft){
		//[UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeLeft;
        if(FLIPPED==TRUE)
          [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeRight;  
		FLIPPED=FALSE;
         
		
	}*/
	}
    
	
	[[Resources getResources] update:etime];
	if(game_mode==GAME_MODE_MENU){
		[menu update:etime];
	}else if(game_mode==GAME_MODE_PLAY){
		
		if(etime>1.0f/20.0f)etime=1.0f/20.0f;
		[cam update:etime];	
		[terrain update:etime];		
		[hud update:etime];
         if(CREATURES_ON&&![World getWorld].player.dead)
        UpdateModels(etime);
       
		[player preupdate:etime];
         if(![World getWorld].player.dead)
		[effects update:etime];
        [terrain updateAllImportantChunks];
		
	}
	return FALSE;
}


- (void)render{
    if(JUST_TERRAIN_GEN){
        [Graphics prepareMenu];
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glColor4f(1.0, 1.0, 1.0, 1.0f);
        [Graphics drawRect:-5:-5:5:5];
        glDisable(GL_BLEND);
        [Graphics endMenu];
        
        //printf("hi");
    }
    if(game_mode==GAME_MODE_WAIT){
       
        game_mode=target_game_mode;
        if(target_game_mode==GAME_MODE_WAIT)target_game_mode=GAME_MODE_MENU;
        return;
    }
	if(game_mode==GAME_MODE_MENU){
       // [[World getWorld] loadWorld:menu.selected_world->file_name];	
		[menu render];
	}else if(game_mode==GAME_MODE_PLAY){	
		[Graphics prepareScene];	
        
		
		[cam render];
       
       // [Graphics setLighting];	
       // glShadeModel(GL_SMOOTH);
		[terrain render];
        if(CREATURES_ON)
            RenderModels();
        [terrain render2];
      //  glShadeModel(GL_FLAT);
       
       // glTranslatef([World getWorld].fm.chunkOffsetZ*CHUNK_SIZE,0,[World getWorld].fm.chunkOffsetZ*CHUNK_SIZE);
        glBindBuffer(GL_ARRAY_BUFFER,0);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,0);
        glPushMatrix();
        glTranslatef(-[World getWorld].fm.chunkOffsetX*CHUNK_SIZE,0,-[World getWorld].fm.chunkOffsetZ*CHUNK_SIZE);
		[effects render];
        [[World getWorld].terrain.fireworks render];
		[player render];		
         glPopMatrix();
		[hud render]; //render hud last
		
	}
	
	if(exit_to_menu)
        [self exitToMenu];
	
}
@end
