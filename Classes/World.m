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



static	World* singleton;
@implementation World
@synthesize cam, terrain, player, hud,fm/*,FLIPPED*/,effects,realtime,bestGraphics;
@synthesize game_mode,menu;
extern EAGLView* G_EAGL_VIEW;
 BOOL exit_to_menu=FALSE;

void RLETEST(){
    
    BOOL passed=TRUE;
    printf("rleTest started\n");
    //rand init data;
    for(int test=0;test<100;test++){
    block8 blocks[CHUNK_SIZE3];
    color8 colors[CHUNK_SIZE3];
    
    for(int i=0;i<CHUNK_SIZE3;i++){
        blocks[i]=arc4random()%2;
        colors[i]=arc4random()%2;
    }
    
    //compress
    
    color8 rledata[CHUNK_SIZE3*3];
    int marker=-1;
    int marker_color=-1;
    int count =0;
    int dataidx=0;
    for(int i=0;i<CHUNK_SIZE3;i++){
        int t=blocks[i];
        int c=colors[i];
        if(t==marker&&c==marker_color&&count!=127){
            count++;
            
        }else{
            if(count>0){
                
                
                rledata[dataidx++]=marker;
                rledata[dataidx++]=marker_color;
               
                rledata[dataidx++]=count;
                count=0;
                marker=-1;
                marker_color=-1;
            }
            marker_color=c;
            marker=t;
            count++;
            
            
        }
    }
    if(count>0){
        rledata[dataidx++]=marker;
        rledata[dataidx++]=marker_color;
        rledata[dataidx++]=count;
        count=0;
        marker=-1;
        marker_color=-1;
    }
    
    if(dataidx>CHUNK_SIZE3*3){
        printf("dataidx overflow\n");
    }
    else {
      /*  if(dataidx/CHUNK_SIZE3>1)
            putchar('!');
        else putchar('.');*/
        
        
      //  sfh->directory_offset+=dataidx;
    }
    
    
    ///DECOMPRESS
    
    color8* buf=rledata;
    
    block8 rblocks[CHUNK_SIZE3];
    color8 rcolors[CHUNK_SIZE3];
    
        memset(rblocks,-1,CHUNK_SIZE3*sizeof(block8));
        memset(rcolors,-1,CHUNK_SIZE3*sizeof(block8));
   // NSData* data=[rcfile readDataOfLength:(CHUNK_SIZE3*3*sizeof(block8))];
    int n=CHUNK_SIZE3*3;
    //[data getBytes:buf length:n];
    
    int idx=0;
    int idx2=0;
    while(idx<n){
        int marker=buf[idx++];
        int marker_color=buf[idx++];
        int count=buf[idx++];
        //printf("count %d\n",count);
        for(int i=0;i<count;i++){
            if(idx2>CHUNK_SIZE3){
                printf("data overflow %d\n",idx2);
                //break;
            }
            rblocks[idx2]=marker;
            rcolors[idx2]=marker_color;
            idx2++;
           
            
        }
        if(idx2>=CHUNK_SIZE3){
            
            break;
            
        }
    }
        
        if(idx2>CHUNK_SIZE3)printf("data overflow %d\n",idx2);
    else if(idx2<CHUNK_SIZE3)printf("data underflow\n");
    
    
    for(int i=0;i<CHUNK_SIZE3;i++){
        if(rblocks[i]!=blocks[i]){
            passed=false;
        }
        if(rcolors[i]!=colors[i]){
            passed=FALSE;
        }
    }
   
    
    }
    if(passed)printf("RLE passed\n");
    else printf("rle failed\n");
    
    
}

- (World*)init{
   
    singleton=self;
    
    if(JUST_TERRAIN_GEN){
        RLETEST();
        double start=CFAbsoluteTimeGetCurrent();
        printf("Terrain gen started\n");
        fm=[[FileManager alloc] init];
        [Hud genColorTable];
        [[World getWorld].fm loadGenFromDisk];
        tg2_init();
        
        printf("Terrain gen finished %f\n",(CFAbsoluteTimeGetCurrent()-start));
        start=CFAbsoluteTimeGetCurrent();
         [[World getWorld].fm writeGenToDisk];
        printf("File write finished %f\n",(CFAbsoluteTimeGetCurrent()-start));
        
        
        bestGraphics=TRUE;
        [Graphics initGraphics];
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
   
          
    [NSThread detachNewThreadSelector:@selector(loadWorldThread2:) toTarget:self withObject:self];
    [terrain startLoadingThread];
  //  FLIPPED=FALSE;
    [[Resources getResources] playMenuTune];
   // [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
   // [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeRight;
    
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
    return;
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
            
           
            NSFileHandle* saveFile=[NSFileHandle fileHandleForReadingAtPath:file_name];
            
            for(int x=0;x<2*r;x++){
                for(int z=0;z<2*r;z++){
                    if(!isloaded[x][z]){
                        [world.fm readColumn: x+chunkOffsetX:z+chunkOffsetZ:saveFile];
                    }
                }
            }
             
            [saveFile closeFile];
           
            
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
    [terrain loadTerrain:object:TRUE];
    doneLoading=2;
    [pool release];
    
}
extern int chunk_load_count;
- (void)loadWorld:(NSString*)name{
    if(doneLoading==0){
        
        doneLoading=1;
        [[Resources getResources] stopMenuTune];
        if(LOW_MEM_DEVICE){
            [menu deactivate];
            
            [[Resources getResources] unloadMenuTextures];
            [[World getWorld].terrain allocateMemory];
            [terrain loadTerrain:name:TRUE];
            doneLoading=2;
            [World getWorld].hud.fade_out=1;


        }else{
            [[World getWorld].terrain allocateMemory];
            [NSThread detachNewThreadSelector:@selector(loadWorldThread:) toTarget:self withObject:name];
        }
        
        
    }
    if(doneLoading>=1){
        int pct=100.0f*(float)(terrain.counter)/324.0f;
        
        if(pct>100)pct=100;
        if(fm.convertingWorld){
            [menu.sbar setStatus:@"Converting World...":100];
        }else{
            //if(pct==100){
               // [menu.sbar setStatus:[NSString stringWithFormat:@"Reticulating Splines... "]:20];
           // }else{
                [menu.sbar setStatus:[NSString stringWithFormat:@"Loading World... %d%%",pct]:20];
           // }
        }
        
        
        
        if(doneLoading==2){
         //   printf("done loading !\n");
            
            if(!LOW_MEM_DEVICE){
            [menu deactivate];
        
            [[Resources getResources] unloadMenuTextures];
            }
            
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
	[terrain unloadTerrain:TRUE];
    if(CREATURES_ON){
        UnloadModels();
    }
   // printf("loading menu textures\n");
    [[Resources getResources] unloadGameAssets];
      [[World getWorld].terrain deallocateMemory];
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
    
    [fm compressLastPlayed];
   
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
        if(game_mode==GAME_MODE_WAIT){
            return FALSE;
        }
         if(CREATURES_ON&&![World getWorld].player.dead)
        UpdateModels(etime);
       
		[player preupdate:etime];
         if(![World getWorld].player.dead)
		[effects update:etime];
        
        
        [terrain prepareAndLoadGeometry];
        [terrain updateAllImportantChunks];
       
		
	}
	return FALSE;
}


- (void)render{
    if(JUST_TERRAIN_GEN){
        glClearColor(.39f, .25f, .39f, 1.0f);
        [Graphics prepareScene];
        [Graphics prepareMenu];
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glColor4f(1.0,0.0, 0.0, 1.0f);
        glDisable(GL_TEXTURE_2D);
        
        tg2_render();
        /* int size=1;
        for(int x=0;x<1024;x++){
            for(int y=0;y<768;y++){
                glColor4f(randf(1.0f),0,0,.05f);
                [Graphics drawRect:x*size:y*size:x*size+15:y*size+15];
            }
        }*/
        
        
        glEnable(GL_TEXTURE_2D);
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
      //  glDisable(GL_TEXTURE_2D);
		[terrain render];
       // glEnable(GL_TEXTURE_2D);
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
