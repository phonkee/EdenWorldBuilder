//
//  Terrain.m
//  prototype
//
//  Created by Ari Ronen on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Terrain.h"
#import "Frustum.h"
#import "Globals.h"
#import "Model.h"
#import "VectorUtil.h"
@implementation Terrain
@synthesize home,loaded,world_name,level_seed,tgen,counter,skycolor,final_skycolor,chunkTable,portals,fireworks;

#define BEDROCK_LEVEL 3;
int vertices_rendered=0;
int max_vertices=100000;
static int faces_rendered=0;
int chunks_rendered=0;
int chunks_rendered2=0;

static Terrain* singleton;

static BOOL* columnsToUpdate;
static BOOL* chunksToUpdate;
static BOOL* chunksToUpdatefg;

static BOOL* chunksToUpdateImmediatley;

block8* blockarray;
static color8* shadowarray;
//static map_t chunkMapc;
static TerrainChunk** chunkTablec;
static BOOL secondPass;
static NSDate* start;
extern bool firstframe;




//front face
//back face
//left face
//right face
//bot face
//top face
BurnNode* burnList;
static TreeNode troot={};
static int do_reload=0;

-(void) startLoadingThread{
    [NSThread detachNewThreadSelector:@selector(chunkBuildingThread:) toTarget:self withObject:self];
}
void genChildren(TreeNode* node){
	//NSLog(@"%d %d %d    %d %d %d",node->bounds[0],node->bounds[1],node->bounds[2]
	//	  ,node->bounds[3],node->bounds[4],node->bounds[5]);
	
	node->hasChildren=TRUE;
	if(node->bounds[3]-node->bounds[0]<=1&&
	   node->bounds[4]-node->bounds[1]<=1&&
	   node->bounds[5]-node->bounds[2]<=1){
		return;
	}
	int half[3];
	for(int i=0;i<3;i++){
		half[i]=(node->bounds[i+3]+node->bounds[i])/2;
	}
	
	for(int j=0;j<8;j++){
		
		BOOL toosmall=FALSE;
		TreeNode* child=malloc(sizeof(TreeNode));
		memset(child,0,sizeof(TreeNode));
		child->dataList=NULL;
		for(int k=0;k<3;k++){
			
			if( ((j+1)/(k+1))%2==0&&!(j==5&&k==2)){//picks an octrant 
				child->bounds[k]=node->bounds[k];
				child->bounds[k+3]=half[k];
			}else{
				
				child->bounds[k]=half[k];
				child->bounds[k+3]=node->bounds[k+3];
			}
			if(child->bounds[k]==child->bounds[k+3])toosmall=TRUE;
			
		}
		//NSLog(@"%d %d %d    %d %d %d",child->bounds[0],child->bounds[1],child->bounds[2]
		//	  ,child->bounds[3],child->bounds[4],child->bounds[5]);
		
		for(int i=0;i<6;i++){
			child->rbounds[i]=child->bounds[i]*BLOCK_SIZE;	
		}
		if(!toosmall){
			
			//gentree(child);
			node->children[j]=child;
		}
		
	}
	
	
}
void removeFromTree(TreeNode* tnode,ListNode* node){
    ListNode* prev=NULL;
    ListNode* cur=tnode->dataList;
    while(cur!=NULL){
        if(cur==node){
            if(prev!=NULL){
                prev->next=cur->next;
            }else
                tnode->dataList=NULL;
           // [(NSNumber*)cur->data release];
           // free(cur);
           // printf("found and removed node\n");
            break;
        }
        prev=cur;
        cur=cur->next;
    }
}

TreeNode* addToTree(TreeNode* node,int* bounds,NSNumber* data){
	//const static int childLocation[3][8]={{0,0,0,0,1,1,1,1},
	//								     {1,1,0,0,1,1,0,0},
	//									 {1,0,1,0,1,0,1,0}};
	
	if(!node->hasChildren)genChildren(node);
	
	/*for(int i=0;i<8;i++){
		TreeNode* child=node->children[i];
		if(child==NULL)continue;
		BOOL contained=TRUE;
		for(int j=0;j<3;j++){
			if(!(child->bounds[j]<=bounds[j]&&child->bounds[j+3]>=bounds[j+3])){
				contained=FALSE;
			}
		}
		if(contained){
			return addToTree(child,bounds,data);
			
			break;
		}		
	}*/
	
		ListNode* newNode=malloc(sizeof(ListNode));
    
		memset(newNode,0,sizeof(ListNode));
    newNode->dead=FALSE;
        [data retain];
		newNode->data=data;
		newNode->next=node->dataList;
		node->dataList=newNode;
        return node;
	
   
}
void freeTree(TreeNode* node){
	if(node==NULL)return;
	ListNode* n=node->dataList;
	while(n!=NULL){		
		[(NSNumber*)n->data release];
		ListNode* t=n->next;
		free(n);
		n=t;
	}
	node->dataList=NULL;
	if(node->hasChildren)
	for(int i=0;i<8;i++){
		freeTree(node->children[i]);
	}
}
void initTree(TreeNode* node){
	node->bounds[0]=node->bounds[2]=-T_SIZE*3;
    node->bounds[1]=-20;
	node->bounds[3]=node->bounds[5]=T_SIZE*3;
	node->bounds[4]=T_HEIGHT+20;
	
	
	for(int i=0;i<6;i++){
		node->rbounds[i]=node->bounds[i]*BLOCK_SIZE;	
	}
	
}
-(void) clearBlocks{
	
	memset(blockarray,0,sizeof(block8)*T_SIZE*T_SIZE*T_HEIGHT);
    memset(shadowarray,0,sizeof(color8)*T_SIZE*T_SIZE);
}



// PVRShell functions

extern int g_offcx;
extern int g_offcz;
- (id)init{
    g_offcx=T_SIZE*100;
    g_offcz=T_SIZE*100;
    start = [NSDate date];
    [start retain];
	tgen=[[TerrainGenerator alloc] init:self];
	//chunkMapc=chunkMap=hashmap_new();		
    chunkTablec=chunkTable=malloc(sizeof(TerrainChunk*)*CHUNKS_PER_SIDE*CHUNKS_PER_SIDE*CHUNKS_PER_COLUMN);
    memset(chunkTable,0,sizeof(TerrainChunk*)*CHUNKS_PER_SIDE*CHUNKS_PER_SIDE*CHUNKS_PER_COLUMN);
	chunksToUpdate=malloc(sizeof(BOOL)*CHUNKS_PER_SIDE*CHUNKS_PER_SIDE*CHUNKS_PER_COLUMN);
    chunksToUpdatefg=malloc(sizeof(BOOL)*CHUNKS_PER_SIDE*CHUNKS_PER_SIDE*CHUNKS_PER_COLUMN);
    columnsToUpdate=malloc(sizeof(BOOL)*CHUNKS_PER_SIDE*CHUNKS_PER_SIDE);
   	//oldChunkMap=NULL;
	chunksToUpdateImmediatley=malloc(sizeof(BOOL)*CHUNKS_PER_SIDE*CHUNKS_PER_SIDE*CHUNKS_PER_COLUMN);
    liquids=[[Liquids alloc] init];
    portals=[[Portal alloc] init];
    fireworks=[[Firework alloc] init];
	 initTree(&troot);
	blockarray=malloc(sizeof(block8)*(T_SIZE+1)*(T_SIZE+1)*(T_HEIGHT+1));
    shadowarray=malloc(sizeof(block8)*T_SIZE*T_SIZE);
	singleton=self;
	loaded=FALSE;
	world_name=NULL;
	do_reload=0;
	nburn=0;
   
	return self;
}

int freeOldChunks(any_t passedIn,any_t chunkToUnload){	
	TerrainChunk* chunk=chunkToUnload;
	[chunk release];
	return MAP_OK;
}
int unloadChunk(any_t passedIn,any_t chunkToUnload){
	//BOOL partial=(BOOL)(int)passedIn;
	//if(partial)NSLog(@"lololol");
	TerrainChunk* chunk=chunkToUnload;
	[chunk release];
	return MAP_OK;
}

	
	
	


-(void)unloadTerrain:(BOOL)partial{
    loaded=FALSE;
    [portals removeAllPortals];
    [fireworks removeAllFireworks];
	if(!partial){
	//	hashmap_iterate(chunkMap, unloadChunk, NULL);
	//	hashmap_remove_all(chunkMap,FALSE);
	}
	//freeTree(&troot);
    
	//initTree(
	
	//release ur memz!
		
}

int extraGeneration(any_t passedIn,any_t chunkToGen){
	
	TerrainChunk* chunk=chunkToGen;
    if(chunk.needsGen){
       // [chunk doGen];
    //    chunk.needsGen=FALSE;
    }
	
	return MAP_OK;
}
- (void)loadTerrain:(NSString*)name{
    
    double start_time=-[start timeIntervalSinceNow];
	if(loaded)[self unloadTerrain:FALSE];
   
    [World getWorld].hud.goldencubes=10;
	counter=0;
	//skycolor=MakeVector(-1,-1,-1);
    
    Vector v=[World getWorld].terrain.skycolor=MakeVector(1.0,1.0,1.0);
    
    float clr2[4]={v.x-.2f, v.y-.2f, v.z-.2f, 1.0f};
    glFogfv(GL_FOG_COLOR,clr2);
    
	burnList=NULL;
	nburn=0;
   
    
	world_name=name;
	[world_name retain];
	[[World getWorld].fm loadWorld:name];
   
    firstframe=TRUE;
    //hashmap_iterate(chunkMap,extraGeneration,NULL);
	//[self startDynamics];
    double end_time=-[start timeIntervalSinceNow];
    for(int x=0;x<T_SIZE;x++){
        for(int z=0;z<T_SIZE;z++){
            for(int y=T_HEIGHT-1;y>=0;y--){
                if(blockarray[x*T_SIZE*T_HEIGHT+z*T_HEIGHT+y]>0&&blockarray[x*T_SIZE*T_HEIGHT+z*T_HEIGHT+y]!=TYPE_CLOUD){
                    shadowarray[x*T_SIZE+z]=y;
                    break;
                }
            }
        }
    }
    
	loaded=1;
    [World getWorld].hud.justLoaded=1;
    
	//NSLog(@"dict entries: %d",hashmap_length(chunkMap));
	//NSLog(@"%f",[NSThread threadPriority]);
    
    
    float ttime=end_time-start_time;
    ttime++;
  // printf("loadtime: %f  \n",ttime);
	
	
}
- (void)warpToHome{
	Vector pp;
	pp.x=BLOCK_SIZE*(home.x*CHUNK_SIZE+.5f);
	pp.z=BLOCK_SIZE*(home.z*CHUNK_SIZE+.5f);
	pp.y=BLOCK_SIZE*(home.y+1);
	[World getWorld].player.pos=pp;
	[[World getWorld].fm saveWorld];
	[self unloadTerrain:FALSE];
    
	[self loadTerrain:world_name];
    [[World getWorld].player groundPlayer];	
}
- (void)addToUpdateList:(int)cx:(int)cy:(int)cz{
    
    chunksToUpdate[threeToOne(cx,cy,cz)]=TRUE;
    columnsToUpdate[getColIndex(cx,cz)]=TRUE;
    }

- (void)addToUpdateList2:(int)cx:(int)cy:(int)cz{
    
    chunksToUpdate[threeToOne(cx,cy,cz)]=TRUE;
    columnsToUpdate[getColIndex(cx,cz)]=TRUE;
}

int compare_front2back (const void *a, const void *b);
int compare_rebuild_order (const void *a, const void *b);
int compare_back2front (const void *a, const void *b);

 int idxrl=0;
static int sanity_test=0;
- (void)chunkBuildingThread:(id)object{
    //Terrain* ter=object;
    [NSThread setThreadPriority:.2];
    printf("Chunk Building thread started, priority: %f \n",[NSThread threadPriority]);
	//[NSThread sleepForTimeInterval:2.00f];
	
	while(TRUE){
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        if([self loaded]){
            int num=0;
            int list[10000];
          
          
            for(int x=0;x<CHUNKS_PER_SIDE;x++){
                for(int z=0;z<CHUNKS_PER_SIDE;z++){
                    if(columnsToUpdate[getColIndex(x,z)]){
                        for(int y=0;y<CHUNKS_PER_COLUMN;y++){
                            if(chunksToUpdate[threeToOne(x,y,z)]){
                                
                                int n=threeToOne(x,y,z);
                                
                                if(n>576){
                                  //  printf("how: %d\n",n);
                                }
                                list[num++]=n;
                                
                                chunksToUpdate[threeToOne(x,y,z)]=FALSE;
                            }
                            
                        }
                        columnsToUpdate[getColIndex(x,z)]=FALSE;
                       // if(num>=1000){printf("1234overflow\n");break;}
                        
                    }
                }
            }
           
                
               
               
          
            
            TerrainChunk* rebuildList[40000];
           
            for(int i=0;i<num;i++){
            TerrainChunk* chunk=NULL;
                if(list[i]<0||list[i]>576){
                   // printf("list[%d]=%d  num: %d idxrl: %d\n",i,list[i],num,idxrl);
                }
                chunk=chunkTable[list[i]];
           
                if(chunk){
                    rebuildList[idxrl++]=chunk;
                    chunk.idxn=list[i];
                }
            }
           // printf("rebuild %d\n",idx);
            if(idxrl>0){
             qsort (rebuildList, idxrl, sizeof (TerrainChunk*), compare_rebuild_order);
            
               /* for(int x=0;x<CHUNKS_PER_SIDE;x++){
                    for(int z=0;z<CHUNKS_PER_SIDE;z++){
                        // if(columnsToUpdate[getColIndex(x,z)]){
                        for(int y=0;y<CHUNKS_PER_COLUMN;y++){
                            if(chunksToUpdatefg[threeToOne(x,y,z)])
                            {
                                TerrainChunk* chunk;
                                
                                chunk=chunkTable[threeToOne(x,y,z)];
                                [chunk rebuild2:FALSE];
                                
                                if(chunk){
                                    chunksToUpdateImmediatley[threeToOne(x,y,z)]=TRUE;
                                }
                                chunksToUpdatefg[threeToOne(x,y,z)]=FALSE;
                            }
                        }
                        
                    }
                }*/
                
                
            for(int i=0;i<35;i++){
            
                idxrl--;
                if(idxrl!=0&&rebuildList[idxrl-1]==rebuildList[idxrl]){
                    i--;
                    continue;
                    printf("really???\n");
                }
               // printf("hi\n");
                if(rebuildList[idxrl]){
                    sanity_test++;
                    if(sanity_test!=1){
                        printf("sanity test failed\n");
                    }
                    if([rebuildList[idxrl] rebuild2]==-1){
                        chunksToUpdate[rebuildList[idxrl].idxn]=TRUE;
                        columnsToUpdate[rebuildList[idxrl].idxn/CHUNKS_PER_COLUMN]=TRUE;
                    }else{
                    
                        rebuildList[idxrl].needsRebuild=FALSE;
                        
                        
                        chunksToUpdateImmediatley[rebuildList[idxrl].idxn]=TRUE; 
                    }
                    sanity_test--;
                }
                
                if(idxrl==0)break;
                
            }
            }
		}
    cleanup:
        [pool release];
        
	}
}

/*-(void) initialGenChunks{
	for(int x=0;x<T_SIZE/CHUNK_SIZE;x++){
		for(int z=0;z<T_SIZE/CHUNK_SIZE;z++){
			[tgen generateColumn:x:z];	
			
		}
	}
	
//	NSLog(@"generated: %d chunks",n_chunks);
	
	
	
}*/
/*- (void)readdChunk:(TerrainChunk*)chunk:(int)cx:(int)cy:(int)cz{
	
	NSNumber* chunkIdx=[NSNumber numberWithInt:threeToOne(cx,cy,cz)];
	TerrainChunk* old=chunkTable[threeToOne(cx,cy,cz)];
    if(old)printf("overwriting something2\n");
    chunkTable[threeToOne(cx,cy,cz)]=chunk;

	//hashmap_put(chunkMap,threeToOne(cx,cy,cz),chunk);
	
	addToTree(&troot,chunk.pbounds,chunkIdx);
	
}*/
- (void)addChunk:(TerrainChunk*)chunk:(int)cx:(int)cy:(int)cz:(BOOL)rebuild{
	
	NSNumber* chunkIdx=[NSNumber numberWithInt:threeToOne(cx,cy,cz)];
	
    TerrainChunk* old=chunkTable[threeToOne(cx,cy,cz)];
    BOOL readdtree=TRUE;
    if(old){
        if(old==chunk){
           //chunk.m_listnode->dead=TRUE;
            readdtree=FALSE;
            //removeFromTree(chunk.m_treenode,chunk.m_listnode);
          //  printf("reusing chunk\n");
        }else
        printf("ERROR:chunk overwrite error\n");
        
        //[old release];
        
    }
    chunkTable[threeToOne(cx,cy,cz)]=chunk;
	//hashmap_put(chunkMap,threeToOne(cx,cy,cz),chunk);
	if(readdtree){
	chunk.m_treenode=addToTree(&troot,chunk.pbounds,chunkIdx);
    if(chunk.m_treenode){
        chunk.m_listnode=chunk.m_treenode->dataList;
    }
    }
	//@synchronized(chunksToUpdate){
	if(rebuild){
        [self addToUpdateList:cx:cy:cz];
       
        
       
             [self addToUpdateList:cx+1:cy:cz];
        
             [self addToUpdateList:cx-1:cy:cz];
       
             [self addToUpdateList:cx:cy:cz+1];;
       
             [self addToUpdateList:cx:cy:cz-1];
	}
	//}
}

- (BOOL)setCustom:(int)x :(int)z :(int)y :(int)type :(int)color{
    if(type!=TYPE_NONE){
        if(getLandc(x/2,z/2,y/2)!=TYPE_CUSTOM){
            [self setLand:x/2:z/2:y/2:TYPE_CUSTOM:FALSE];
        }
    }
    int cx=x/2/CHUNK_SIZE;
    int cy=y/2/CHUNK_SIZE;
    int cz=z/2/CHUNK_SIZE;
    TerrainChunk* chunk;
    chunk=chunkTable[threeToOne(cx,cy,cz)];
    if(!chunk)return FALSE;
    
    int r=[chunk setCustom:x-cx*CHUNK_SIZE*2:z-cz*CHUNK_SIZE*2:y-cy*CHUNK_SIZE*2:type:color];
    if(r!=-1){
        [self setLand:x/2:z/2:y/2:r:FALSE];
        return TRUE;
    }else{
        return FALSE;
    }
    
    
    
}
- (void)setLand:(int)x :(int)z :(int)y :(int)type :(BOOL)chunkToo{
	
	if(y<0||y>=T_HEIGHT)return;
   
    
	blockarray[((x+g_offcx)%T_SIZE)*T_SIZE*T_HEIGHT+((z+g_offcz)%T_SIZE)*T_HEIGHT+y]=type;
	if(chunkToo){
	int cx=x/CHUNK_SIZE;
	int cy=y/CHUNK_SIZE;
	int cz=z/CHUNK_SIZE;
	
	TerrainChunk* chunk;
        chunk=chunkTable[threeToOne(cx,cy,cz)];
	//hashmap_get(chunkMap, threeToOne(cx,cy,cz),(any_t)&chunk);
	if(!chunk){
		return;
		
	}
	
	x-=cx*CHUNK_SIZE;
	y-=cy*CHUNK_SIZE;
	z-=cz*CHUNK_SIZE;
        
        if(chunk.pblocks[x*CHUNK_SIZE*CHUNK_SIZE+z*CHUNK_SIZE+y]==TYPE_CUSTOM){
            SmallBlock* sb=chunk.psblocks[x*CHUNK_SIZE*CHUNK_SIZE+z*CHUNK_SIZE+y];           
            if(sb){
                printf("clearing blocks");
                for(int i=0;i<8;i++){
                    sb->blocks[i]=0;
                    sb->colors[i]=0;
                }
                
            }
        }
	chunk.pblocks[x*(CHUNK_SIZE*CHUNK_SIZE)+z*(CHUNK_SIZE)+y]=type;
		
	}
	
}
- (BOOL)setColor:(int)x :(int)z :(int)y :(color8)color{
    if(y<0||y>=T_HEIGHT)return FALSE;
    
   
    int cx=x/CHUNK_SIZE;
    int cy=y/CHUNK_SIZE;
    int cz=z/CHUNK_SIZE;
    
    TerrainChunk* chunk;
     chunk=chunkTable[threeToOne(cx,cy,cz)];
    //hashmap_get(chunkMap, threeToOne(cx,cy,cz),(any_t)&chunk);
    if(!chunk){
        return FALSE;
        
    }
    
    x-=cx*CHUNK_SIZE;
    y-=cy*CHUNK_SIZE;
    z-=cz*CHUNK_SIZE;
    color8 c1=chunk.pcolors[x*(CHUNK_SIZE*CHUNK_SIZE)+z*(CHUNK_SIZE)+y];
    if(c1==color) return FALSE;
    chunk.pcolors[x*(CHUNK_SIZE*CHUNK_SIZE)+z*(CHUNK_SIZE)+y]=color;
		
	// NSLog(@"hi! %f,%f,%f",color.x,color.y,color.z);
    return TRUE;

    
    
}
- (void)destroyCustom:(int)x :(int)z :(int)y{
    [[World getWorld].effects addBlockBreak:x/2.0f :z/2.0f :y/2.0f :getCustomc(x ,z ,y) :0];
	[self updateCustom: x: z: y: TYPE_NONE :0];
    

}
- (void)destroyBlock:(int)x :(int)z :(int)y{
    NSLog(@"%d, %d, %d",x,z,y);
    int cur=getLandc(x,z,y);
    if(blockinfo[cur]&IS_LIQUID){
        [liquids removeSource:x:z:y:cur];
    }else{
       // [liquids checkPoint:x:z:y];
    }
    int paint=0;
    if((cur==TYPE_TNT||cur==TYPE_FIREWORK)||isOnFire(x,z,y)){
        paint=[self getColor:x:z:y];//save color so it can be used when explosion is triggered
    }
	[[World getWorld].effects addBlockBreak:x :z :y :[self getLand:x :z :y]:[self getColor:x:z:y]];
	[self updateChunks:x :z :y :TYPE_NONE];
    [self setColor:x:z:y:paint];//add color attribute back in after updatechunks clears it
    
    if(blockinfo[cur]&IS_DOOR){
        if(cur==TYPE_DOOR_TOP){
            [self updateChunks:x :z :y-1 :TYPE_NONE];
            [self setColor:x:z:y-1:paint];
        }else{
            [self updateChunks:x :z :y+1 :TYPE_NONE];
            [self setColor:x:z:y+1:paint];
        }
    }
    if(blockinfo[cur]&IS_PORTAL){
        printf("trying to remove portal\n");
        if(cur==TYPE_PORTAL_TOP){
            [self updateChunks:x :z :y-1 :TYPE_NONE];
            [self setColor:x:z:y-1:paint];
            [portals removePortal:x:y:z];
        }else{
            [self updateChunks:x :z :y+1 :TYPE_NONE];
            [self setColor:x:z:y+1:paint];
            [portals removePortal:x :y+1 :z];
            
        }
    }
}
- (void)explodeBlock:(int)x :(int)z :(int)y{
    int cur=getLandc(x,z,y);
    if(blockinfo[cur]&IS_LIQUID){
        [liquids removeSource:x:z:y:cur];
    }else{
      //  [liquids checkPoint:x:z:y];
    }
	[[World getWorld].effects addBlockExplode:x :z :y :[self getLand:x :z :y] :[self getColor:x:z:y]];
	[self updateChunks:x :z :y :TYPE_NONE];
}

bool isOnFire(int x ,int z, int y){
    BurnNode* n=burnList;
    while(n!=NULL){
        if(n->x==x&&n->y==y&&n->z==z){
            return TRUE;
        }
        n=n->next;
    }
    
    return FALSE;
}
- (void)burnBlock:(int)x :(int)z :(int)y{
	int type=getLandc(x, z, y);
	if(type<0)return;
	if(blockinfo[type]&IS_FLAMMABLE){
		BurnNode* n=burnList;
		while(n!=NULL){
			if(n->x==x&&n->y==y&&n->z==z){
				return;
			}
			n=n->next;
		}
		nburn++;
		
		BurnNode* node=malloc(sizeof(BurnNode));	
		node->x=x;
		node->y=y;
		node->z=z;
		node->type=type;
		if(type==TYPE_TNT||type==TYPE_FIREWORK)
			node->life=3;
		else
			node->life=6;
		node->sid=[[Resources getResources] startedBurn:node->life];
		node->time=node->life;	
		
		node->pid=[[World getWorld].effects addFire:x :z :y :0 :node->life+.3];
		node->next=NULL;
		[self updateChunks:x :z :y :type];
		BurnNode* front=burnList;
		if(front!=NULL)
			node->next=front;
		burnList=node;
		
	 }
}
/*0,0,1, //front face
0,0,-1, //back face
-1,0,0, //left face
1,0,0, //right face
0,-1,0, //bot face
0,1,0, //top face	*/
bool isRampFaceSolid[4][6]={
    {false,false,false,true,false,true},
    {true,false,false,false,false,true},
    {false,true,false,false,false,true},
    {false,false,true,false,false,true},
};
bool isSideFaceSolid[4][6]={
    {false,false,true,true,false,false},
    {true,false,false,true,false,false},
    {true,true,false,false,false,false},
    {false,true,true,false,false,false}, 
};
bool isFaceSolid(int x,int z,int y, int d){
    int dx[]={1,0,-1,0,0,0};
    int dz[]={0,1,0,-1,0,0};
    int dy[]={0,0,0,0,-1,1};
    int type=getLandc(x+dx[d],z+dz[d],y+dy[d]);
    if(type>0&&type!=TYPE_NONE){
        if(type>=TYPE_STONE_RAMP1&&type<=TYPE_ICE_RAMP4){            
            return isRampFaceSolid[type%4][d];
        }else if(type>=TYPE_STONE_SIDE1&&type<=TYPE_ICE_SIDE4){           
            return isSideFaceSolid[type%4][d];
        }else 
            return true;
    }
    return false;
}
int getRampType(int x,int z,int y, int t){
    int type=t;
   
    bool sides[4];
     int n=0;
    for(int i=0;i<4;i++){        
        sides[i]=isFaceSolid(x,z,y,i);
        if(sides[i])n++;
    }
    
    if(n==2)
    for(int i=0;i<4;i++){
        
        if(sides[i]&&sides[(i+1)%4]){
            type+=(TYPE_STONE_SIDE1-TYPE_STONE_RAMP1)+i;
           // NSLog(@"s:%d",i);
            return type;
        }
    }
    int yaw=[World getWorld].player.yaw;
    int r=0;
    yaw+=360;
    yaw%=360;
    if(yaw>=45&&yaw<=90+45){
        r=0;
    }else if(yaw>=90+45&&yaw<=180+45){
        r=1;
    }else if(yaw>=180+45&&yaw<=270+45){
        r=2;
    }else if(yaw>=270||yaw<45){
        r=3;
    }
    //NSLog(@"r:%d",r);
    type+=r;
    return type;
}
- (void)buildCustom:(int)x :(int)z :(int)y{
    int build=[World getWorld].hud.blocktype;
   // int type=getLandc(x,z,y);
    [self updateCustom:x :z :y :build :[World getWorld].hud.block_paintcolor];
    
    
}
- (void)paintCustom:(int)x :(int)z :(int)y :(int)color{
     [self updateCustom:x :z :y :getCustomc(x,z,y) :color];
    
}
- (void)buildBlock:(int)x :(int)z :(int)y{
    if([World getWorld].hud.blocktype==TYPE_GOLDEN_CUBE){
        if([World getWorld].hud.goldencubes<=0)return;
         printf("goldencubes %d paint color: %d\n",[World getWorld].hud.goldencubes, [World getWorld].hud.block_paintcolor);
        [World getWorld].hud.goldencubes--;
       
    }
    if(y<0||y>=T_HEIGHT)return;
    int cur=getLandc(x,z,y);
    if((blockinfo[cur]&IS_LIQUID&&getLevel(cur)<4)){
        [liquids removeSource:x:z:y:cur];
    }
	int type=[World getWorld].hud.blocktype;
    if(type==TYPE_WATER||type==TYPE_LAVA)
       [liquids addSource:x:z:y];
    
    if(type==TYPE_ICE_RAMP1||type==TYPE_STONE_RAMP1||type==TYPE_WOOD_RAMP1||type==TYPE_SHINGLE_RAMP1)
    {
        type=getRampType(x,z,y,type);
        if(type%4==0)
            NSLog(@"type 1 yo");
        
    }
    if(type==TYPE_DOOR_TOP){
        int boty=y;
        if(getLandc(x,z,y-1)==TYPE_NONE){
            boty=y-1;
        }else if(getLandc(x,z,y+1)==TYPE_NONE){
            boty=y;
        }else return;
        
        [self updateChunks:x :z :boty+1 :TYPE_DOOR_TOP];
        [self setColor:x :z :boty+1 : [World getWorld].hud.block_paintcolor ];
        
        int yaw=[World getWorld].player.yaw;
        int r=0;
        yaw+=360;
        yaw%=360;
        if(yaw>=45&&yaw<=90+45){
            r=0;
        }else if(yaw>=90+45&&yaw<=180+45){
            r=1;
        }else if(yaw>=180+45&&yaw<=270+45){
            r=2;
        }else if(yaw>=270||yaw<45){
            r=3;
        }

        [self updateChunks:x :z :boty :TYPE_DOOR1+r];
        [self setColor:x :z :boty : [World getWorld].hud.block_paintcolor ];
        
        return;
    }else if(type==TYPE_PORTAL_TOP){
        int boty=y;
        if(getLandc(x,z,y-1)==TYPE_NONE){
            boty=y-1;
        }else if(getLandc(x,z,y+1)==TYPE_NONE){
            boty=y;
        }else return;
        
        [self updateChunks:x :z :boty+1 :TYPE_PORTAL_TOP];
        [self setColor:x :z :boty+1 : [World getWorld].hud.block_paintcolor ];
        
        int yaw=[World getWorld].player.yaw;
        int r=0;
        yaw+=360;
        yaw%=360;
        if(yaw>=45&&yaw<=90+45){
            r=0;
        }else if(yaw>=90+45&&yaw<=180+45){
            r=1;
        }else if(yaw>=180+45&&yaw<=270+45){
            r=2;
        }else if(yaw>=270||yaw<45){
            r=3;
        }
        
        [self updateChunks:x :z :boty :TYPE_PORTAL1+r];
        [self setColor:x :z :boty : [World getWorld].hud.block_paintcolor ];
        
        return; 
    }else{
	[self updateChunks:x :z :y :type];
   [self setColor:x :z :y : [World getWorld].hud.block_paintcolor ];
    }
}

- (void)paintBlock:(int)x :(int)z :(int)y :(int)color{
    
    int pos[3]={x,y,z};
	int cx,cy,cz;
	
	
	if([self setColor:x :z :y :color]){
	cx=pos[0]/CHUNK_SIZE;
	cy=pos[1]/CHUNK_SIZE;
	cz=pos[2]/CHUNK_SIZE;
	 [self addToUpdateList2:cx:cy:cz];
    }
    int cur=getLandc(x,z,y);
    if(blockinfo[cur]&IS_PORTAL){
        if(cur==TYPE_PORTAL_TOP){
            
            [self setColor:x:z:y-1:color];
            [portals paintPortal:x:z:y:color];
            pos[1]--;
            cx=pos[0]/CHUNK_SIZE;
            cy=pos[1]/CHUNK_SIZE;
            cz=pos[2]/CHUNK_SIZE;
            [self addToUpdateList2:cx:cy:cz];
        }else{
            
            [self setColor:x:z:y+1:color];
            [portals paintPortal:x :z :y+1:color];
            
            pos[1]++;
            cx=pos[0]/CHUNK_SIZE;
            cy=pos[1]/CHUNK_SIZE;
            cz=pos[2]/CHUNK_SIZE;
            [self addToUpdateList2:cx:cy:cz];
            
        }
    }
    
}

- (void)updateChunks:(int)x :(int)z :(int)y:(int)type{
    int pos[3]={x,y,z};
	int cx,cy,cz;
	
    if(type==TYPE_NONE)
        [self setColor:x:z:y:0];
	[self setLand:x :z :y :type :TRUE];
    
	cx=pos[0]/CHUNK_SIZE;
	cy=pos[1]/CHUNK_SIZE;
	cz=pos[2]/CHUNK_SIZE;
    [self addToUpdateList2:cx:cy:cz];
	
	int cx2,cy2,cz2;
	for(int i=0;i<3;i++){
		pos[i]++;
        
		cx2=pos[0]/CHUNK_SIZE;
		cy2=pos[1]/CHUNK_SIZE;
		cz2=pos[2]/CHUNK_SIZE;
        [self addToUpdateList2:cx2:cy2:cz2];
		
		pos[i]-=2;
		cx2=pos[0]/CHUNK_SIZE;
		cy2=pos[1]/CHUNK_SIZE;
		cz2=pos[2]/CHUNK_SIZE;
        [self addToUpdateList2:cx2:cy2:cz2];
		
		pos[i]++;
		
	}
	
    
    
    
    
}
- (void)updateCustom:(int)x :(int)z :(int)y:(int)type:(int)color{
   	int pos[3]={x/2,y/2,z/2};
	int cx,cy,cz;
	
   // if(type==TYPE_NONE)
	//[self setColor:x:z:y:0];
	BOOL rebuildNeighbors=[self setCustom:x :z :y :type :color];
    
	cx=pos[0]/CHUNK_SIZE;
	cy=pos[1]/CHUNK_SIZE;
	cz=pos[2]/CHUNK_SIZE;
	 [self addToUpdateList2:cx:cy:cz];
	
    if(rebuildNeighbors){
	int cx2,cy2,cz2;
	for(int i=0;i<3;i++){
		pos[i]++;
				
		cx2=pos[0]/CHUNK_SIZE;
		cy2=pos[1]/CHUNK_SIZE;
		cz2=pos[2]/CHUNK_SIZE;
		 [self addToUpdateList2:cx2:cy2:cz2];
		
		pos[i]-=2;
		cx2=pos[0]/CHUNK_SIZE;
		cy2=pos[1]/CHUNK_SIZE;
		cz2=pos[2]/CHUNK_SIZE;
		 [self addToUpdateList2:cx2:cy2:cz2];
		
		pos[i]++;
		
	}
    }
	
	
	
	
}

int getShadow(int x,int z,int y){
    //if(x<=0||z<=0||y<0||x>=T_SIZE-1||z>=T_SIZE-1||y>=T_HEIGHT)return 0;
    
    int count=0;
    for(int dx=-1;dx<=1;dx++)
        for(int dz=-1;dz<=1;dz++){
            //if(x+dx>=0&&x+dx<CHUNK_SIZE&&z+dz>=0&&z+dz<CHUNK_SIZE)
            if(shadowarray[((x+dx+g_offcx)%T_SIZE)*T_SIZE+((z+dz+g_offcz)%T_SIZE)]>y)count++;
        }
    return 100.0f*count/9.0f; 
    
}
inline int getLandc2(int x,int z,int y){	
    if(y<0||y>=T_HEIGHT)return -1;
    return blockarray[((x+g_offcx)%T_SIZE)*T_SIZE*T_HEIGHT+((z+g_offcz)%T_SIZE)*T_HEIGHT+y];
}
int getCustomc(int x,int z,int y){
   
        if(getLandc(x/2,z/2,y/2)!=TYPE_CUSTOM){
            int n=getLandc(x/2,z/2,y/2);
           // printf("get custom on non-custom\n");
           return n;
            
            
        }
   
    int cx=x/2/CHUNK_SIZE;
    int cy=y/2/CHUNK_SIZE;
    int cz=z/2/CHUNK_SIZE;
    TerrainChunk* chunk;
    chunk=chunkTablec[threeToOne(cx,cy,cz)];
    if(!chunk)return FALSE;
    
    return [chunk getCustom:x-cx*CHUNK_SIZE*2:z-cz*CHUNK_SIZE*2:y-cy*CHUNK_SIZE*2];
}
inline int getLandc(int x,int z,int y){	
	//if(x<0||z<0||y<0||x>=T_SIZE||z>=T_SIZE||y>=T_HEIGHT)return -1;	
   
	return blockarray[((x+g_offcx)%T_SIZE)*T_SIZE*T_HEIGHT+((z+g_offcz)%T_SIZE)*T_HEIGHT+y];
	/*int cx=x/CHUNK_SIZE;
	int cy=y/CHUNK_SIZE;
	int cz=z/CHUNK_SIZE;
	TerrainChunk* chunk;
	hashmap_get(chunkMapc,threeToOne(cx,cy,cz),(any_t)&chunk);
	if(!chunk)return -1;
	x-=cx*CHUNK_SIZE;
	y-=cy*CHUNK_SIZE;
	z-=cz*CHUNK_SIZE;
	return chunk.blocks[x*(CHUNK_SIZE*CHUNK_SIZE)+z*(CHUNK_SIZE)+y];	*/													
	
}
- (int)getLand:(int)x :(int)z :(int)y{
	//return -1;
     if(y<0||y>=T_HEIGHT)return -1;
	//if(x<0||z<0||y<0||x>=T_SIZE||z>=T_SIZE||y>=T_HEIGHT)return -1;	
    if(x+g_offcx<0||z+g_offcz<0){
        printf("under/overflow (%d,%d)\n",x,z);
    }
	return blockarray[((x+g_offcx)%T_SIZE)*T_SIZE*T_HEIGHT+((z+g_offcz)%T_SIZE)*T_HEIGHT+y];
	int cx=x/CHUNK_SIZE;
	int cy=y/CHUNK_SIZE;
	int cz=z/CHUNK_SIZE;
	TerrainChunk* chunk;
     chunk=chunkTable[threeToOne(cx,cy,cz)];
	//hashmap_get(chunkMap,threeToOne(cx,cy,cz),(any_t)&chunk);
	if(!chunk)return -1;
	x-=cx*CHUNK_SIZE;
	y-=cy*CHUNK_SIZE;
	z-=cz*CHUNK_SIZE;
	return chunk.pblocks[x*(CHUNK_SIZE*CHUNK_SIZE)+z*(CHUNK_SIZE)+y];													 
	
}
- (int)getColor:(int)x :(int)z :(int)y{
	//return -1;
	if(y<0||y>=T_HEIGHT)return 0;	
	
	int cx=x/CHUNK_SIZE;
	int cy=y/CHUNK_SIZE;
	int cz=z/CHUNK_SIZE;
	TerrainChunk* chunk;
     chunk=chunkTable[threeToOne(cx,cy,cz)];
	//hashmap_get(chunkMap,threeToOne(cx,cy,cz),(any_t)&chunk);
	if(!chunk)return 0;
	x-=cx*CHUNK_SIZE;
	y-=cy*CHUNK_SIZE;
	z-=cz*CHUNK_SIZE;
	return chunk.pcolors[x*(CHUNK_SIZE*CHUNK_SIZE)+z*(CHUNK_SIZE)+y];													 
	
}
- (void)shootFirework:(int)x :(int)z :(int)y{
    [fireworks addFirework:x:y:z:[self getColor:x:z:y]];
   // [[World getWorld].effects addCreatureVanish:x+.5f:z+.5f:y+5:[self getColor:x:z:y]:TYPE_TNT];
    
    [self destroyBlock:x :z :y];
    printf("shooting firework, color:%d\n",[self getColor:x:z:y]);
}

- (void)explode:(int)x :(int)z :(int)y{
	[[Resources getResources] playSound:S_EXPLODE];
    Vector v=MakeVector(x+.5f,y+.5f,z+.5f);
    ExplodeModels(v);
    [[World getWorld].effects addCreatureVanish:x+.5f:z+.5f:y+.5f:[self getColor:x:z:y]:TYPE_TNT];
    int color=[self getColor:x:z:y];
    BOOL painting=false;
    if(color!=0)painting=true;
	//[self destroyBlock:x :z :y];
   	for(int i=1;i<=EXPLOSION_RADIUS;i++){
		for(int j=x-EXPLOSION_RADIUS;j<=x+EXPLOSION_RADIUS;j++){
			for(int k=z-EXPLOSION_RADIUS;k<=z+EXPLOSION_RADIUS;k++){
				int yy=EXPLOSION_RADIUS-i;

				int ox=j-x;
				int oz=k-z;
				int oy=yy;
				if(ox*ox+oz*oz+oy*oy>EXPLOSION_RADIUS*EXPLOSION_RADIUS)
					continue;
                if(painting){
                    int type=getLandc(j, k, y-yy);
                    if(type!=-1)
                        if(type!=TYPE_TNT||[self getColor:j:k:y-yy]==0)
                            [self paintBlock:j :k :y-yy:color];
                        
                    type=getLandc(j, k, y+yy);
                    
                     if(type!=TYPE_TNT||[self getColor:j:k:y-yy]==0)     
                         [self paintBlock:j :k :y+yy:color];
                    
                }else{
                    int type=getLandc(j, k, y-yy);
                    if(type!=-1){
                        if(blockinfo[type]&IS_FLAMMABLE){
                            if(isOnFire(j,k,y-yy)){continue;}
                            //if(type==TYPE_TNT)
                            //	[self explode:j:k:y-yy];
                            //else
                            [self burnBlock:j :k :y-yy];
                        }else{
                            if(type!=TYPE_BEDROCK&&type!=TYPE_STEEL){
                                [self explodeBlock:j :k :y-yy];
                            }
                        }
                    }
				type=getLandc(j, k, y+yy);
				
				if(blockinfo[type]&IS_FLAMMABLE){
                    if(isOnFire(j,k,y+yy))continue;
					
						[self burnBlock:j :k :y+yy];
				}else{
					if(type!=TYPE_BEDROCK&&type!=TYPE_STEEL)
					[self explodeBlock:j :k :y+yy];
				}
                }
				
			}
		}
		
	}	
}
/*-(void)addColumnsIfNeeded{
	Vector ppos=[World getWorld].player.pos;
	ppos.x/=BLOCK_SIZE;
	ppos.z/=BLOCK_SIZE;
	ppos.x+=CHUNK_SIZE/2;
	ppos.z+=CHUNK_SIZE/2;
	ppos.x/=CHUNK_SIZE;
	ppos.z/=CHUNK_SIZE;
	int cx=ppos.x;
	int cz=ppos.z;
	int CVRADIUS=2;
	for(int i=cx-CVRADIUS;i<cx+CVRADIUS;i++){
		for(int j=cz-CVRADIUS;j<cz+CVRADIUS;j++){
			if(i<0||j<0)continue;
			TerrainChunk* chunk;
			hashmap_get(chunkMap, threeToOne(cx,0,cz),(any_t)&chunk);
			if(!chunk){
			[tgen generateColumn:i :j];				
			}
		}
	}
}*/
extern float P_ZFAR;
-(void)reloadIfNeeded{
    return;
	float radius=T_SIZE/8;//(P_ZFAR/2)/BLOCK_SIZE;
	Player* player=[World getWorld].player;
	if(player.pos.x/BLOCK_SIZE-radius<0||player.pos.x/BLOCK_SIZE+radius>T_SIZE||
	   player.pos.z/BLOCK_SIZE-radius<0||player.pos.z/BLOCK_SIZE+radius>T_SIZE){
		do_reload=1;
		[[World getWorld].hud.sb setStatus:@"Loading..." :999];
       
            
		
	}
}
Vector gcrot={0};
Vector portal_rot={0};
const int BURN_SPREAD_TIME=1;
int chunk_load_count=0;
BOOL doingsomeloading=FALSE;

float last_etime;
- (BOOL)update:(float)etime{
    last_etime=etime;
    if(do_reload==-1){
        int pct=99*chunk_load_count/(2304/4)+counter/2;
        
        if(pct>100)pct=100;
        
            [[World getWorld].hud.sb setStatus:[NSString stringWithFormat:@"Loading World... %d%%",pct]:20];
        
        
        return FALSE;
    }
    etime/=4;
    portal_rot.z+=5*etime;
    if(portal_rot.z>2*M_PI)portal_rot.z-=2*M_PI;
    
    gcrot.x+=2*etime;
    if(gcrot.x>2*M_PI)gcrot.x-=2*M_PI;
    gcrot.y+=1*etime;
    if(gcrot.y>2*M_PI)gcrot.y-=2*M_PI;
    gcrot.z+=.5f*etime;
    if(gcrot.z>2*M_PI)gcrot.z-=2*M_PI;
   etime*=4;
	BurnNode* prev=NULL;
	BurnNode* node=burnList;
	while(node!=NULL){
		if(node->time > node->life-BURN_SPREAD_TIME &&node->time-etime<=node->life-BURN_SPREAD_TIME){
			[self burnBlock:node->x+1 :node->z :node->y];
			[self burnBlock:node->x-1 :node->z :node->y];
			[self burnBlock:node->x :node->z+1 :node->y];
			[self burnBlock:node->x :node->z-1 :node->y];
			[self burnBlock:node->x :node->z :node->y+1];
			[self burnBlock:node->x :node->z :node->y-1];

		}
		
		if(nburn>300){			
			[self endDynamics:FALSE];
            
			break;
		}
		node->time-=etime;
		int tz=getLandc(node->x ,node->z ,node->y);
		if(node->time<=0||tz==TYPE_NONE){
			if(prev==NULL)
				burnList=node->next;
			else
				prev->next=node->next;
			if(node->type==TYPE_TNT){
					
				[self explode:node->x :node->z :node->y];
				
			}else if(node->type==TYPE_FIREWORK){
            
                [self shootFirework:node->x :node->z :node->y];
            }
			nburn--;
			[[Resources getResources] endBurnId:node->sid];
			[[World getWorld].effects removeFire:node->pid];
			if(tz!=TYPE_NONE)
			[self updateChunks:node->x :node->z :node->y :TYPE_NONE];
			free(node);			
			node=NULL;
			if(prev!=NULL)
			node=prev->next;
		}else {
			prev=node;
			node=node->next;
		}		
	}
    [liquids update:etime];
    [fireworks update:etime];
    if(interpolatev(&skycolor,final_skycolor,1.0,etime)){
         
        Vector v=[World getWorld].terrain.skycolor;
        float clr[4]={v.x-.2f, v.y-.2f, v.z-.2f, 1.0f};
        glFogfv(GL_FOG_COLOR,clr);
       // printf("TRUE\n");
    }
   if(do_reload==3){
       [[World getWorld].hud.sb clear];
        do_reload=0;
    }
	else if(do_reload==2){
        do_reload=0;
		[[World getWorld].fm saveWorld];
		[self unloadTerrain:TRUE];
		//oldChunkMap=chunkMap;	
		//chunkMapc=chunkMap=hashmap_new();
       
        [self loadTerrain:world_name];
        //hashmap_iterate(oldChunkMap,freeOldChunks,NULL);
		//iterate oldchunkmap and release chunks that arent reused
		//hashmap_remove_all(oldChunkMap, FALSE);
		
		do_reload=3;
        
				
		
		return FALSE;
	}else if(do_reload==1){
        do_reload++;
    }else
	[self reloadIfNeeded];
	
	return FALSE;
}


-(void)endDynamics:(BOOL)endLiquids{
	nburn=0;
    if(endLiquids)
    [liquids clearLiquids];
	while(burnList!=NULL){
		BurnNode* node=burnList->next;
		burnList->next=NULL;
		[self updateChunks:burnList->x :burnList->z :burnList->y :TYPE_NONE];
		free(burnList);
		
		burnList=node;
		
	}
    [[World getWorld].effects clearAllEffects];
	[[Resources getResources] endBurn];
	
}
-(void)startDynamics{/*
    for(int i=0;i<T_SIZE*T_SIZE*T_HEIGHT;i++){
        if(blockarray[i]==TYPE_WATER||blockarray[i]==TYPE_LAVA){
            int n=i;
            int y=n%T_HEIGHT;
            n/=T_HEIGHT;
            int z=n%T_SIZE;
            n/=T_SIZE;
            int x=n;
            [liquids addSource:x:z:y:blockarray[i]:[self getColor:x:z:y]];
        }
    }*/
               
}

- (void)updateAllImportantChunks{
	double start_time=-[start timeIntervalSinceNow];
        
    
   
   
    int count=0;
   
    for(int x=0;x<CHUNKS_PER_SIDE;x++){
        for(int z=0;z<CHUNKS_PER_SIDE;z++){
            // if(columnsToUpdate[getColIndex(x,z)]){
            for(int y=0;y<CHUNKS_PER_COLUMN;y++){
                if(chunksToUpdateImmediatley[threeToOne(x,y,z)]){
                    TerrainChunk* chunk;
                    
                    chunk=chunkTable[threeToOne(x,y,z)];
                    
                    
                    if(chunk){
                        
                        [chunk prepareVBO];
                        count++;
                        
                    }
                    
                    chunksToUpdateImmediatley[threeToOne(x,y,z)]=FALSE;
                }
                
            }
            //     columnsToUpdate[getColIndex(x,z)]=FALSE;
        }
    }


    		
	
  
    if(count>0){
       
        double end_time=-[start timeIntervalSinceNow];
        float etime=end_time-start_time;
        etime+=.0001f;
  //  NSLog(@"chunk updates: %d  etime: %f  etime/count: %f\n",count,etime,etime/count);
	
    }
   
    
}
- (void)colort:(float)r :(float)g :(float)b{
	glColor4f(r,g,b,1);
}
static TerrainChunk* renderList[(T_SIZE/CHUNK_SIZE)*(T_SIZE/CHUNK_SIZE)*(T_HEIGHT/CHUNK_SIZE)];
void renderTree(TreeNode* node,int state){
	int istate=ViewTestAABB(node->rbounds,state);
    if(node==&troot){
        istate=VT_INSIDE;
        
    }
	if(istate&VT_OUTSIDE) return;
	//if(istate&VT_)return;	
	ListNode* list=node->dataList;
    int leafnodes=0;
	while(list!=NULL){
		leafnodes++;
        if(!list->dead){
            
        
		NSNumber* chunkIdx=list->data;		
		TerrainChunk* chunk;
        chunk=chunkTablec[[chunkIdx intValue]];
		//hashmap_get(chunkMapc, [chunkIdx intValue],(any_t)&chunk);
            if(chunk){
               
                chunk.in_view=FALSE;
                if((chunk.rtn_vertices>0||chunk.rtn_vertices2>0)){
                    int cstate=ViewTestAABB(chunk->rbounds,state);
                    if(!(cstate&VT_OUTSIDE)) {
                        chunk.in_view=TRUE;
                        if(secondPass){
                            if(chunk.rtn_vertices2>0){
                                renderList[chunks_rendered2]=chunk;
                                //[chunk render2];
                                chunks_rendered2+=1;
                                
                            }
                        }
                        else{
                            if(chunk.rtn_vertices>0||chunk.rtnum_objects>0){
                                renderList[chunks_rendered]=chunk;
                                // [chunk render];
                                
                                chunks_rendered+=1;
                                
                                // faces_rendered+=chunk.n_faces;
                                //vertices_rendered+=chunk.n_vertices;
                            }
                        }
                        
                        
                    }
                }
            }
        }
		list=list->next;
	}
    //if(leafnodes!=0)
    //printf("chunks in this node: %d\n",leafnodes);
	for(int i=0;i<8;i++){
		if(node->children[i])
		renderTree(node->children[i],istate);
	}
}
int compare_rebuild_order (const void *a, const void *b)
{
    TerrainChunk* first=*((TerrainChunk**)(a));
    TerrainChunk* second=*((TerrainChunk**)(b));
    Vector cam=[World getWorld].player.pos;
    Vector center=MakeVector((first.pbounds[3]+first.pbounds[0])/2.0f,
                             (first.pbounds[4]+first.pbounds[1])/2.0f,
                             (first.pbounds[5]+first.pbounds[2])/2.0f);
    
    float dist=(cam.x-center.x)*(cam.x-center.x)+
    (cam.y-center.y)*(cam.y-center.y)+
    (cam.z-center.z)*(cam.z-center.z);
    
    if(first.in_view)dist/=4;
    
    center=MakeVector((second.pbounds[3]+second.pbounds[0])/2.0f,
                      (second.pbounds[4]+second.pbounds[1])/2.0f,
                      (second.pbounds[5]+second.pbounds[2])/2.0f);
    float dist2=((cam.x-center.x)*(cam.x-center.x)+
           (cam.y-center.y)*(cam.y-center.y)+
           (cam.z-center.z)*(cam.z-center.z));
    
    if(second.in_view)dist2/=4;
    dist-=dist2;
    
    if (dist > 0)
        return -1;
    else if (dist < 0)
        return 1;
    else
        return 0;
    
   
}

int compare_front2back (const void *a, const void *b)
{
    TerrainChunk* first=*((TerrainChunk**)(a));
    TerrainChunk* second=*((TerrainChunk**)(b));
    Vector cam=[World getWorld].player.pos;
    Vector center=MakeVector((first.pbounds[3]+first.pbounds[0])/2.0f,
                             (first.pbounds[4]+first.pbounds[1])/2.0f,
                             (first.pbounds[5]+first.pbounds[2])/2.0f);
    
    float dist=(cam.x-center.x)*(cam.x-center.x)+
             (cam.y-center.y)*(cam.y-center.y)+
    (cam.z-center.z)*(cam.z-center.z);
    
    center=MakeVector((second.pbounds[3]+second.pbounds[0])/2.0f,
                      (second.pbounds[4]+second.pbounds[1])/2.0f,
                      (second.pbounds[5]+second.pbounds[2])/2.0f);
    dist-=((cam.x-center.x)*(cam.x-center.x)+
    (cam.y-center.y)*(cam.y-center.y)+
    (cam.z-center.z)*(cam.z-center.z));
 
    if (dist > 0)
        return 1;
    else if (dist < 0)
        return -1;
    else
        return 0;
}
int compare_back2front (const void *a, const void *b)
{
    TerrainChunk* first=*((TerrainChunk**)(a));
    TerrainChunk* second=*((TerrainChunk**)(b));
    Vector cam=[World getWorld].player.pos;
    Vector center=MakeVector((first.pbounds[3]+first.pbounds[0])/2.0f,
                             (first.pbounds[4]+first.pbounds[1])/2.0f,
                             (first.pbounds[5]+first.pbounds[2])/2.0f);
    
    float dist=(cam.x-center.x)*(cam.x-center.x)+
    (cam.y-center.y)*(cam.y-center.y)+
    (cam.z-center.z)*(cam.z-center.z);
    
    center=MakeVector((second.pbounds[3]+second.pbounds[0])/2.0f,
                      (second.pbounds[4]+second.pbounds[1])/2.0f,
                      (second.pbounds[5]+second.pbounds[2])/2.0f);
    dist-=((cam.x-center.x)*(cam.x-center.x)+
           (cam.y-center.y)*(cam.y-center.y)+
           (cam.z-center.z)*(cam.z-center.z));
    
    if (dist > 0)
        return -1;
    else if (dist < 0)
        return 1;
    else
        return 0;
}

extern float SCREEN_WIDTH; 
extern BOOL SUPPORTS_OGL2;
extern float SCREEN_HEIGHT;
static int frame_counter=0;
static int frame=0;
int lolc=0;
- (void)render{		
    if(do_reload==-1)return;
   //  NSLog(@"rendering!!");
	[Graphics beginTerrain];
	vertices_rendered=0;
	faces_rendered=0;
	chunks_rendered=chunks_rendered2=0;
    
    glMatrixMode(GL_TEXTURE);
    glScalef(1,1.0f/32.0f,1);
   // glPushMatrix();
    glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	//float pushx=[World getWorld].fm.chunkOffsetX*CHUNK_SIZE*BLOCK_SIZE;
	//float pushz=[World getWorld].fm.chunkOffsetZ*CHUNK_SIZE*BLOCK_SIZE;
	//glTranslatef(-pushx, 0, -pushz);
   // printf("-------------start renderTree------------\n");
	renderTree(&troot,0);
   //printf("--------x--x--x----end----x--x--x--------\n");
    
    qsort (renderList, chunks_rendered, sizeof (TerrainChunk*), compare_front2back);
  //  glDisable(GL_TEXTURE_2D);
    int chunksr=chunks_rendered;
    for(int i=0;i<chunks_rendered;i++){
        
        vertices_rendered+=[renderList[i] render];
        /*if(vertices_rendered>=max_vertices&&[World getWorld].hud.fps<40){
            if([World getWorld].hud.mode!=MODE_CAMERA){
            [Graphics setZFAR:P_ZFAR-.5f];
            chunks_rendered-=(chunks_rendered-i+1);
            break;
            }
        }*/
    }
#define max_render_objects 300
    glEnable(GL_LIGHTING);
    
    glShadeModel(GL_SMOOTH);
   
    float lightPosition[4] = {0.0f,0.0f, 0.0f, 1.0f};
    float lightAmbient[4]  = {0.3f, 0.3f, 0.3f, 1.0f};
    float lightDiffuse[4]  = {0.7f, 0.7f, 0.7f, 1.0f};
    
    float lightPosition2[4] = {1.0f,1.0f, 0.0f, 1.0f};
    float lightAmbient2[4]  = {0.3f, 0.3f, 0.3f, 1.0f};
    float lightDiffuse2[4]  = {0.3f, 0.3f, 0.3f, 1.0f};
    
    //PVRTVec4 lightSpecular = PVRTVec4(0.2f, 0.2f, 0.2f, 1.0f);
    
    glEnable(GL_LIGHT0);
    glPushMatrix();
    glLoadIdentity();
    glLightfv(GL_LIGHT0, GL_POSITION, lightPosition);
    glLightfv(GL_LIGHT1, GL_POSITION, lightPosition2);
    glPopMatrix();
    glLightfv(GL_LIGHT0, GL_AMBIENT,  lightAmbient);
    glLightfv(GL_LIGHT0, GL_DIFFUSE,  lightDiffuse);
    glLightfv(GL_LIGHT1, GL_AMBIENT,  lightAmbient2);
    glLightfv(GL_LIGHT1, GL_DIFFUSE,  lightDiffuse2);
    
    
    glEnableClientState(GL_NORMAL_ARRAY);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glEnable(GL_NORMALIZE);
    vertexObject objVertices[max_render_objects*6*6];
    extern const GLshort cubeShortVertices[36*3];
    extern const GLshort cubeTexture[36*2];
    extern const GLfloat cubeNormals[36*3];
    const GLshort* cubeVertices=cubeShortVertices;
    const GLshort* cubeTextureCustom=cubeTexture;
    int vert=0;
    int object=0;
        setViewNow();
    Vector ppos=[World getWorld].player.pos;
    for(int i=0;i<chunksr;i++){
        for(int j=0;j<renderList[i].rtnum_objects;j++){
            if(renderList[i].rtobjects[j].type!=TYPE_DOOR_TOP)continue;
            int dir=renderList[i].rtobjects[j].dir;
            Vector v1=renderList[i].rtobjects[j].pos;
            v1.x+=.5f;
            v1.z+=.5f;
            v1.y=ppos.y;
            Vector vdist=v_sub(ppos,v1);
            
            int dist=v_length2(vdist);
            
            if(ppos.y>=renderList[i].rtobjects[j].pos.y&&ppos.y<=renderList[i].rtobjects[j].pos.y+2&&dist<2*2){                
                renderList[i].rtobjects[j].ani=-1;
            }else
                renderList[i].rtobjects[j].ani=1;
            float rot=renderList[i].rtobjects[j].rot;
            /*if(renderList[i].rtobjects[j].ani==0){
                renderList[i].rtobjects[j].ani=1;
            }*/
            if(renderList[i].rtobjects[j].ani==1){
                renderList[i].rtobjects[j].rot+=6*last_etime;
            }else if(renderList[i].rtobjects[j].ani==-1){
                renderList[i].rtobjects[j].rot-=6*last_etime;
            }
            if(renderList[i].rtobjects[j].rot<0){
                renderList[i].rtobjects[j].rot=0;
               // renderList[i].rtobjects[j].ani=1;
            }
            if(renderList[i].rtobjects[j].rot>M_PI/2){
                renderList[i].rtobjects[j].rot=M_PI/2;
                //renderList[i].rtobjects[j].ani=-1;
            }
            Vector offsets=MakeVector(0,0,0);
            if(dir==0){
                offsets.x=4;
                rot+=M_PI/2;
            }else if(dir==1){
                rot+=M_PI;
                offsets.z=4;
                offsets.x=4;
                
                
            }else if(dir==2){
                 rot+=M_PI+M_PI/2; 
                offsets.z=4;
               
            }else if(dir==3){
                
            }
           
            if(rot>2*M_PI)rot-=(int)(rot/(2*M_PI))*(2*M_PI);
           
            
            for(int k=0;k<6*6;k++){
                Vector vc;
                
                vc=MakeVector(cubeVertices[k*3]*4,cubeVertices[k*3+1]*2*4,cubeVertices[k*3+2]*.50f-.25);
                               
                
                
                vc=rotateVertice(MakeVector(0,rot,0),vc);
                vc.x+=offsets.x;
                vc.z+=offsets.z;
                if(vc.x<0)vc.x=0;
                if(vc.z<0)vc.z=0;
                if(vc.x>4)vc.x=4;
                if(vc.z>4)vc.z=4;
                /*if(vc.x>4)vc.x=4;
                if(vc.z>4)vc.z=4;*/
                objVertices[vert].position[0]=4*(renderList[i].rtobjects[j].pos.x-[World getWorld].fm.chunkOffsetX*CHUNK_SIZE)+vc.x;
                objVertices[vert].position[1]=4*renderList[i].rtobjects[j].pos.y+vc.y;
                objVertices[vert].position[2]=4*(renderList[i].rtobjects[j].pos.z-[World getWorld].fm.chunkOffsetZ*CHUNK_SIZE)+vc.z;
                if(k==0){
                   /* printf("door objVertices[%d]= (%d,%d,%d) suggested offsets(%d,%d),\n",j,renderList[i].rtobjects[j].pos[0]
                           ,renderList[i].rtobjects[j].pos[1]
                           ,renderList[i].rtobjects[j].pos[2],
                           -[World getWorld].fm.chunkOffsetX,-[World getWorld].fm.chunkOffsetZ);*/
                    
                }
                Vector vn=MakeVector(cubeNormals[k*3],cubeNormals[k*3+1],cubeNormals[k*3+2]);
                
                vn=rotateVertice(MakeVector(0,rot,0),vn);
                objVertices[vert].normal[0]=vn.x;
                objVertices[vert].normal[1]=vn.y;
                objVertices[vert].normal[2]=vn.z;
                /*
                for(int coord=0;coord<3;coord++){
                    if(coord==1)
                        objVertices[vert].position[coord]=4*renderList[i].objects[j].pos[coord]+4*cubeVertices[k*3+coord]*2; 
                        else if (coord==2)
                          objVertices[vert].position[coord]=4*renderList[i].objects[j].pos[coord]+.5f*cubeVertices[k*3+coord];     
                            else
                    objVertices[vert].position[coord]=4*renderList[i].objects[j].pos[coord]+4*cubeVertices[k*3+coord];
                }*/
                if(k>=12){
                     objVertices[vert].texs[0]=cubeTextureCustom[k*2+0];     
                    objVertices[vert].texs[1]=0;
                }else{
                    if(k>=6){
                objVertices[vert].texs[0]=cubeTextureCustom[k*2+0];
                objVertices[vert].texs[1]=cubeTextureCustom[k*2+1]*32;
                    }
                    else{
                        objVertices[vert].texs[0]=1-cubeTextureCustom[k*2+0];
                        objVertices[vert].texs[1]=cubeTextureCustom[k*2+1]*32;

                        
                    }
                }
                extern Vector colorTable[256];
                Vector color=colorTable[renderList[i].rtobjects[j].color];
                if(renderList[i].rtobjects[j].color==0){
                    color.x=color.y=color.z=1;
                    
                }
                objVertices[vert].colors[0]=color.x*255;
                 objVertices[vert].colors[1]=color.y*255;
                 objVertices[vert].colors[2]=color.z*255;
                 objVertices[vert].colors[3]=255;
                vert++;
            }
            object++;
            if(object==max_render_objects)break;
        }
        if(object==max_render_objects)break;
    }
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,0);
    glBindBuffer(GL_ARRAY_BUFFER,0);

    glBindTexture(GL_TEXTURE_2D, [[Resources getResources] getTex:ICO_DOOR].name);
    glVertexPointer(3, GL_FLOAT, sizeof(vertexObject), objVertices[0].position);
    glNormalPointer( GL_FLOAT, sizeof(vertexObject), objVertices[0].normal);
	glTexCoordPointer(2, GL_FLOAT,  sizeof(vertexObject),  objVertices[0].texs);
	glColorPointer(	4, GL_UNSIGNED_BYTE, sizeof(vertexObject), objVertices[0].colors);
	
  
        glDrawArrays(GL_TRIANGLES, 0,vert);
    
    //float lightDiffuse[4]  = {0.7f, 0.7f, 0.7f, 1.0f};
    glLightfv(GL_LIGHT0, GL_DIFFUSE,  lightDiffuse);
    
    cubeVertices=cubeShortVertices;
   cubeTextureCustom=cubeTexture;
    vert=0;
    object=0;
    lolc++;
    
    int tess=2;
    
    float tessf=1.0f/(float)tess;
    for(int i=0;i<chunksr;i++){
        for(int j=0;j<renderList[i].rtnum_objects;j++){
            if(renderList[i].rtobjects[j].type!=TYPE_GOLDEN_CUBE)continue;
            for(int f=0;f<6;f++)
                
                for(int x=0;x<tess;x++){
                    float xoff=x*tessf;
                    for(int y=0;y<tess;y++){
                        float yoff=y*tessf;
                        for(int qc=0;qc<6;qc++){
                            
                            
                            int k=f*6+qc;
                            Vector vc;
                            if(f==0||f==1){
                            vc=MakeVector(cubeVertices[k*3]*tessf+xoff-.5f,cubeVertices[k*3+1]*tessf+yoff-.5f,cubeVertices[k*3+2]-.5f);
                            }else if(f==2||f==3){
                                 vc=MakeVector(cubeVertices[k*3]-.5f,cubeVertices[k*3+1]*tessf+yoff-.5f,cubeVertices[k*3+2]*tessf+xoff-.5f);
                               
                            }else if(f==4||f==5){
                               vc=MakeVector(cubeVertices[k*3]*tessf+yoff-.5f,cubeVertices[k*3+1]-.5f,cubeVertices[k*3+2]*tessf+xoff-.5f);
                            }
                            vc=rotateVertice(gcrot,vc);
                            vc.x+=.5f;
                            vc.y+=.5f;
                            vc.z+=.5f;
                            Vector vn=MakeVector(cubeNormals[k*3],cubeNormals[k*3+1],cubeNormals[k*3+2]);
                            
                            vn=rotateVertice(gcrot,vn);
                            objVertices[vert].normal[0]=vn.x;
                            objVertices[vert].normal[1]=vn.y;
                            objVertices[vert].normal[2]=vn.z;
                            
                            
                            objVertices[vert].position[0]=4*(renderList[i].rtobjects[j].pos.x-[World getWorld].fm.chunkOffsetX*CHUNK_SIZE)+1+2.3*vc.x;
                            objVertices[vert].position[1]=4*renderList[i].rtobjects[j].pos.y+1+2.3*vc.y;
                            objVertices[vert].position[2]=4*(renderList[i].rtobjects[j].pos.z-[World getWorld].fm.chunkOffsetZ*CHUNK_SIZE)+1+2.3*vc.z;
                            
                            CalcEnvMap(&objVertices[vert]);
                            
                            
                           
                            
                            
                            extern Vector colorTable[256];
                            Vector color=colorTable[renderList[i].rtobjects[j].color];
                            if(renderList[i].rtobjects[j].color==0){
                                color.x=color.y=color.z=1;
                                
                            }
                            objVertices[vert].colors[0]=color.x*255;
                            objVertices[vert].colors[1]=color.y*255;
                            objVertices[vert].colors[2]=color.z*255;
                            objVertices[vert].colors[3]=255;
                            vert++;
                        } 
                    }
                }
            
            object++;
            if(object==max_render_objects)break;
        }
        if(object==max_render_objects)break;
    }
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,0);
    glBindBuffer(GL_ARRAY_BUFFER,0);
    float coloursp[4] ={1.0f, 1.0f, 1.0f, 1.0f};
    
    float colourspm[4] ={1.0f, 1.0f, 1.0f, 1.0f};
   
    glEnable(GL_LIGHT1);
    glDisable(GL_LIGHT0);
    glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,colourspm) ;
       glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, 100.0f);
    glLightfv(GL_LIGHT1,GL_SPECULAR,coloursp);
                    
   // glDisable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, [[Resources getResources] getTex:ICO_SPHEREMAP].name);
    glVertexPointer(3, GL_FLOAT, sizeof(vertexObject), objVertices[0].position);
    glNormalPointer( GL_FLOAT, sizeof(vertexObject), objVertices[0].normal);
	glTexCoordPointer(2, GL_FLOAT,  sizeof(vertexObject),  objVertices[0].texs);
	glColorPointer(	4, GL_UNSIGNED_BYTE, sizeof(vertexObject), objVertices[0].colors);
	
    
    glDrawArrays(GL_TRIANGLES, 0,vert);
        float coloursp2[4] = {0,0,0,0};
    glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,coloursp2) ;
    glLightfv(GL_LIGHT0,GL_SPECULAR,coloursp2);
   // glEnable(GL_TEXTURE_2D);
    glDisable(GL_LIGHTING);
    glDisable(GL_NORMALIZE);
    glShadeModel(GL_FLAT);
     glDisable(GL_LIGHT1);
    
    glDisable(GL_LIGHT0);
    
    glDisableClientState(GL_NORMAL_ARRAY);
    
    cubeVertices=cubeShortVertices;
     cubeTextureCustom=cubeTexture;
    vert=0;
   object=0;
    for(int i=0;i<chunksr;i++){
        for(int j=0;j<renderList[i].rtnum_objects;j++){
            if(renderList[i].rtobjects[j].type!=TYPE_PORTAL_TOP)continue;
           // printf("drawing portal\n");
            
            float rot=0;
            int dir=(renderList[i].rtobjects[j].dir+3)%4;
            Vector offsets=MakeVector(0,0,0);
            if(dir==0){
                offsets.x=4;
                rot+=M_PI/2;
            }else if(dir==1){
                rot+=M_PI;
                offsets.z=4;
                offsets.x=4;
                
                
            }else if(dir==2){
                rot+=M_PI+M_PI/2; 
                offsets.z=4;
                
            }else if(dir==3){
                
            }
            
            if(rot>2*M_PI)rot-=(int)(rot/(2*M_PI))*(2*M_PI);
            
            
          //  for(int k=0;k<6*6;k++){
               // Vector vc;
                
                //vc=MakeVector(cubeVertices[k*3]*4,cubeVertices[k*3+1]*2*4,cubeVertices[k*3+2]*.50f-.25);
                
                
               
            
            
            for(int k=0;k<6*6;k++){
                Vector vc=MakeVector(cubeVertices[k*3]*4,cubeVertices[k*3+1]*2*4,cubeVertices[k*3+2]*.45f-.45f);
                
                vc=rotateVertice(MakeVector(0,rot,0),vc);
                vc.x+=offsets.x;
                vc.z+=offsets.z;
               // if(vc.x<0)vc.x=0;
                //if(vc.z<0)vc.z=0;
                //if(vc.x>4)vc.x=4;
                //if(vc.z>4)vc.z=4;
               // vc=rotateVertice(MakeVector(0,rot,0),vc);
                objVertices[vert].position[0]=4*(renderList[i].rtobjects[j].pos.x-[World getWorld].fm.chunkOffsetX*CHUNK_SIZE)+vc.x;
                objVertices[vert].position[1]=4*renderList[i].rtobjects[j].pos.y+vc.y;
                objVertices[vert].position[2]=4*(renderList[i].rtobjects[j].pos.z-[World getWorld].fm.chunkOffsetZ*CHUNK_SIZE)+vc.z;
                
               
                if(k>=12){
                    objVertices[vert].texs[0]=cubeTextureCustom[k*2+0];     
                    objVertices[vert].texs[1]=0;
                }else{
                    if(k>=6){
                        objVertices[vert].texs[0]=cubeTextureCustom[k*2+0];
                        objVertices[vert].texs[1]=cubeTextureCustom[k*2+1]*32;
                    }
                    else{
                        objVertices[vert].texs[0]=1-cubeTextureCustom[k*2+0];
                        objVertices[vert].texs[1]=cubeTextureCustom[k*2+1]*32;
                        
                        
                    }
                }
                extern Vector colorTable[256];
                Vector color=colorTable[renderList[i].rtobjects[j].color];
                if(renderList[i].rtobjects[j].color==0){
                    color.x=color.y=color.z=1;
                    
                }
                objVertices[vert].colors[0]=color.x*255;
                objVertices[vert].colors[1]=color.y*255;
                objVertices[vert].colors[2]=color.z*255;
                objVertices[vert].colors[3]=255;
                vert++;
            }
            
            object++;
            if(object==max_render_objects)break;
        }
        if(object==max_render_objects)break;
    }
    
  
    
    glBindTexture(GL_TEXTURE_2D, [[Resources getResources] getTex:ICO_PORTAL].name);
    glVertexPointer(3, GL_FLOAT, sizeof(vertexObject), objVertices[0].position);
   
	glTexCoordPointer(2, GL_FLOAT,  sizeof(vertexObject),  objVertices[0].texs);
	glColorPointer(	4, GL_UNSIGNED_BYTE, sizeof(vertexObject), objVertices[0].colors);
	
    
    glDrawArrays(GL_TRIANGLES, 0,vert);
    
    vert=0;
    object=0;
    for(int i=0;i<chunksr;i++){
        for(int j=0;j<renderList[i].rtnum_objects;j++){
            if(renderList[i].rtobjects[j].type!=TYPE_PORTAL_TOP)continue;
                        
            float rot=0;
            int dir=(renderList[i].rtobjects[j].dir+3)%4;
            Vector offsets=MakeVector(0,0,0);
            if(dir==0){
                offsets.x=4;
                rot+=M_PI/2;
            }else if(dir==1){
                rot+=M_PI;
                offsets.z=4;
                offsets.x=4;
                
                
            }else if(dir==2){
                rot+=M_PI+M_PI/2; 
                offsets.z=4;
                
            }else if(dir==3){
                
            }
            
            if(rot>2*M_PI)rot-=(int)(rot/(2*M_PI))*(2*M_PI);
            
                        
            
            
            
            for(int k=0;k<6;k++){
                
                Vector vc=MakeVector((cubeVertices[k*3]-cubeVertices[k*3]*20.0f/64.0f+10.0f/64.0f)*4,
                                     (cubeVertices[k*3+1]*2-(cubeVertices[k*3+1]*(6.0f/64.0f+4.0f/64.0f))+4.0f/64.0f)*4,cubeVertices[k*3+2]*.45f-.5f);
                
                vc=rotateVertice(MakeVector(0,rot,0),vc);
                vc.x+=offsets.x;
                vc.z+=offsets.z;
                
                
                objVertices[vert].position[0]=4*(renderList[i].rtobjects[j].pos.x-[World getWorld].fm.chunkOffsetX*CHUNK_SIZE)+vc.x;
                objVertices[vert].position[1]=4*renderList[i].rtobjects[j].pos.y+vc.y;
                objVertices[vert].position[2]=4*(renderList[i].rtobjects[j].pos.z-[World getWorld].fm.chunkOffsetZ*CHUNK_SIZE)+vc.z;
                
                
                vc=MakeVector((cubeTextureCustom[k*2+0]*(.723-.276f)+.276f)-.5f,(cubeTextureCustom[k*2+1]*(.947-.053f)+.053f)-.5f,0);
                vc=rotateVertice(portal_rot,vc);
                objVertices[vert].texs[0]=vc.x+.5f;
                objVertices[vert].texs[1]=(vc.y+.5f)*32;
                        
                
                extern Vector colorTable[256];
                Vector color=colorTable[renderList[i].rtobjects[j].color];
                if(renderList[i].rtobjects[j].color==0){
                    color.x=color.y=color.z=1;
                    
                }
                objVertices[vert].colors[0]=color.x*255;
                objVertices[vert].colors[1]=color.y*255;
                objVertices[vert].colors[2]=color.z*255;
                objVertices[vert].colors[3]=255;
                vert++;
                
            }
           
        }
        if(object==max_render_objects)break;
    }
    
    
    
    glBindTexture(GL_TEXTURE_2D, [[Resources getResources] getTex:ICO_SWIRL].name);
    glVertexPointer(3, GL_FLOAT, sizeof(vertexObject), objVertices[0].position);
    
	glTexCoordPointer(2, GL_FLOAT,  sizeof(vertexObject),  objVertices[0].texs);
	glColorPointer(	4, GL_UNSIGNED_BYTE, sizeof(vertexObject), objVertices[0].colors);
	
    
    glDrawArrays(GL_TRIANGLES, 0,vert);
    


    
    
    cubeVertices=cubeShortVertices;
    cubeTextureCustom=cubeTexture;
    vert=0;
    object=0;
    for(int i=0;i<chunksr;i++){
        for(int j=0;j<renderList[i].rtnum_objects;j++){
            if(renderList[i].rtobjects[j].type!=TYPE_FLOWER)continue;
            for(int k=0;k<6;k++){
                Vector vc=MakeVector(cubeVertices[k*3]-.5f,cubeVertices[k*3+1],cubeVertices[k*3+2]);
                Vector dir;
                dir.y=0;
                dir.x=renderList[i].rtobjects[j].pos.x+.5f-[World getWorld].player.pos.x;
                dir.z=renderList[i].rtobjects[j].pos.z+.5f-[World getWorld].player.pos.z;
            
            float targetangle=(atan2(dir.z,dir.x)-atan2(0,1))-M_PI_2;
            
              //  guys[i].targetangle=(atan2(dir.z,dir.x)-atan2(0,1))-M_PI_2;
            
            
            
                vc=rotateVertice(MakeVector(0,targetangle,0),vc);
                vc.x+=.5f;
               
               /*
                Vector vn=MakeVector(cubeNormals[k*3],cubeNormals[k*3+1],cubeNormals[k*3+2]);
                
                vn=rotateVertice(gcrot,vn);
                objVertices[vert].normal[0]=vn.x;
                objVertices[vert].normal[1]=vn.y;
                objVertices[vert].normal[2]=vn.z;*/
                
                objVertices[vert].position[0]=4*renderList[i].rtobjects[j].pos.x+4*vc.x;
                objVertices[vert].position[1]=4*renderList[i].rtobjects[j].pos.y+2*vc.y;
                objVertices[vert].position[2]=4*renderList[i].rtobjects[j].pos.z+4*vc.z+2;
                
                
                objVertices[vert].texs[0]=cubeTextureCustom[k*2+0];
                objVertices[vert].texs[1]=cubeTextureCustom[k*2+1]*32;
                
                extern Vector colorTable[256];
                Vector color=colorTable[renderList[i].rtobjects[j].color];
                if(renderList[i].rtobjects[j].color==0){
                    color.x=color.y=color.z=1;
                    
                }
                objVertices[vert].colors[0]=color.x*255;
                objVertices[vert].colors[1]=color.y*255;
                objVertices[vert].colors[2]=color.z*255;
                objVertices[vert].colors[3]=255;
                vert++;
            }
            object++;
            if(object==max_render_objects)break;
        }
        if(object==max_render_objects)break;
    }
    
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,0);
    glBindBuffer(GL_ARRAY_BUFFER,0);
    
    glBindTexture(GL_TEXTURE_2D, [[Resources getResources] getTex:ICO_FLOWER].name);
    glVertexPointer(3, GL_FLOAT, sizeof(vertexObject), objVertices[0].position);
   
	glTexCoordPointer(2, GL_FLOAT,  sizeof(vertexObject),  objVertices[0].texs);
	glColorPointer(	4, GL_UNSIGNED_BYTE, sizeof(vertexObject), objVertices[0].colors);
    glEnable(GL_BLEND);
   glDepthMask(GL_FALSE);
    glDrawArrays(GL_TRIANGLES, 0,vert);
    glDepthMask(GL_TRUE);
    glDisable(GL_BLEND);
    // glEnable(GL_TEXTURE_2D);
    /*if([World getWorld].hud.fps<55){
        if([World getWorld].hud.mode!=MODE_CAMERA){
            [Graphics setZFAR:P_ZFAR-.4f];
            
            
        }
    }*/
	glPopMatrix();
    
    //if(!SUPPORTS_OGL2)
    glDisable(GL_FOG);
	glDisableClientState(GL_COLOR_ARRAY);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
    glMatrixMode(GL_PROJECTION);			
	glPushMatrix();							
	glLoadIdentity();	
	if([World getWorld].FLIPPED)
		glRotatef(90,0,0,1);
	else
		glRotatef(270,0,0,1);
	
   
    if(IS_IPAD){
        if(IS_RETINA)
            glOrthof(0, SCREEN_WIDTH*2, 0, SCREEN_HEIGHT*2, -1, P_ZFAR);
        else
            glOrthof(0, IPAD_WIDTH, 0, IPAD_HEIGHT, -1, P_ZFAR);		
	}else        
        glOrthof(0, SCREEN_WIDTH, 0, SCREEN_HEIGHT, -1, P_ZFAR);		
	glMatrixMode(GL_MODELVIEW);		
	glPushMatrix();
    glLoadIdentity();	
	
    //skycolor.x=0;
    
    if(skycolor.x==1.0&&skycolor.y==1.0&&skycolor.z==1.0){
    glColor4f(1.0, 1.0, 1.0, 1.0);
    
    [[[Resources getResources] getTex:ICO_SKY_BOX] drawSky:CGRectMake(0,0, SCREEN_WIDTH,SCREEN_HEIGHT) depth:-P_ZFAR/1.000001];
    }else{
    //    extern Vector colorTable[256];
        Vector v=skycolor;
        glColor4f(v.x, v.y, v.z, 1.0);
        
        [[[Resources getResources] getTex:ICO_SKY_BOX_BW] drawSky:CGRectMake(0,0, SCREEN_WIDTH,SCREEN_HEIGHT) depth:-P_ZFAR/1.000001];
         glColor4f(1.0, 1.0, 1.0, 1.0);
    }
    glPopMatrix();
    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
    glMatrixMode(GL_TEXTURE);
        glScalef(1,32.0f,1);
    
    glMatrixMode(GL_MODELVIEW);
   	frame_counter++;
   
    
    firstframe=FALSE;
	if(frame_counter==120){
	//printf("chunks: %d, faces: %d, vertices: %d\n",chunks_rendered,faces_rendered,vertices_rendered);
		frame_counter=0;
	}
	[Graphics endTerrain];	
}

-(void)render2{
    glEnableClientState(GL_COLOR_ARRAY);
	
     glEnable(GL_FOG);
	glPushMatrix();
	glScalef(.25f,.25f,.25f);
    
    
    
    glMatrixMode(GL_TEXTURE);
    glScalef(1,1.0f/32.0f,1);
    // glPushMatrix();
    
    glMatrixMode(GL_MODELVIEW);
    glEnableClientState(GL_COLOR_ARRAY);
    // if(!SUPPORTS_OGL2)
  //  glEnable(GL_FOG);
    
    
    glEnable(GL_BLEND);
    glPushMatrix();
    
    glBindTexture(GL_TEXTURE_2D, [Resources getResources].atlas2.name);
    glMatrixMode(GL_TEXTURE);
    
    frame=(frame+1)%128;
  
    glTranslatef(0,(int)(frame/16),0);
    glMatrixMode(GL_MODELVIEW);
    
	//float pushx=[World getWorld].fm.chunkOffsetX*CHUNK_SIZE*BLOCK_SIZE;
	//float pushz=[World getWorld].fm.chunkOffsetZ*CHUNK_SIZE*BLOCK_SIZE;
	//glTranslatef(-pushx, 0, -pushz);
    secondPass=TRUE;
	renderTree(&troot,0);
    qsort (renderList, chunks_rendered2, sizeof (TerrainChunk*), compare_back2front);
    
    for(int i=0;i<chunks_rendered2;i++){
        [renderList[i] render2];
    }
    glMatrixMode(GL_TEXTURE);
    glTranslatef(0,-(int)(frame/16),0);
    glScalef(1,32.0f,1);
    
    glMatrixMode(GL_MODELVIEW);
    secondPass=FALSE;
	glPopMatrix();
    [Graphics endTerrain];	
    
}
- (void)dealloc{
	if(loaded)
		[self unloadTerrain:FALSE];
	//free(landscape);
	//landscape=NULL;
	[super dealloc];
}
@end

/*- (BOOL)isVisible:(int)x:(int)z:(int)y{
 Camera* cam=[World getWorld].cam;
 Vector cpos,bpos;
 Vector a;
 //cdir.x=cam.look.x-cam.px;
 //cdir.y=cam.look.y-cam.py;
 //cdir.z=cam.look.z-cam.pz;
 cpos.x=cam.px/BLOCK_SIZE;
 cpos.y=cam.py/BLOCK_SIZE;
 cpos.z=cam.pz/BLOCK_SIZE;
 bpos.x=x;
 bpos.y=y;
 bpos.z=z;
 a.x=cpos.x-bpos.x;
 a.y=cpos.y-bpos.y;
 a.z=cpos.z-bpos.z;
 
 int hidden=0;
 
 if(a.y>0){		
 if(getLandc(x, z, y+1)>0)
 hidden++;			
 }else{
 if(getLandc(x, z, y-1)>0)
 hidden++;			
 }
 if(a.x>0){
 if(getLandc(x+1, z, y)>0)
 hidden++;			
 }else{
 if(getLandc(x-1, z, y)>0)
 hidden++;			
 }
 if(a.z>0){
 if(getLandc(x, z+1, y)>0)
 hidden++;			
 }else{
 if(getLandc(x, z-1, y)>0)
 hidden++;			
 }
 
 if(hidden==3)
 return FALSE;
 
 
 return TRUE;
 
 
 }*/