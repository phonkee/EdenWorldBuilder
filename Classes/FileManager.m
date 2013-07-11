//
//  FileManager.m
//  prototype
//
//  Created by Ari Ronen on 10/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FileManager.h"
#import "hashmap.h"
#import "Util.h"
#import "Terrain.h"
#import "Model.h"
#import "TerrainGen2.h"
//#import "TestFlight.h"
#define FILE_VERSION 3

#define SIZEOF_COLUMN CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE*CHUNKS_PER_COLUMN*(sizeof(block8)+sizeof(color8))
@implementation FileManager
@synthesize chunkOffsetX,chunkOffsetZ,documents,convertingWorld,genflat;

typedef struct{
	int level_seed;
	Vector pos;
	Vector home;
	float yaw;	
	unsigned long long directory_offset;
	char name[50];
    
    //below here is post 1.1.1 stuff
    int version;
    char hash[33];
	char reserved[100-sizeof(int)-33];	 //subtract new stuff from reserve bytes
}WorldFileHeader;
typedef struct{
	int x, z;
	unsigned long long chunk_offset;
}ColumnIndex;
typedef struct{
	int n_vertices;
	
}ChunkHeader;

static map_t indexes;
unsigned long long cur_dir_offset;
static map_t indexes_hmm;
static FileManager* single;

static NSFileHandle* saveFile;
static WorldFileHeader* sfh;
static BOOL writeDirectory;
static NSString* imgHash;
static int file_version;
EntityData creatureData[MAX_CREATURES_SAVED];
-(id)init{
	single=self;
    genflat=FALSE;
    imgHash=NULL;
    convertingWorld=FALSE;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	documents = [paths objectAtIndex:0];
	[documents retain];
	oldOffsetX=oldOffsetZ=chunkOffsetX=chunkOffsetZ=-1;
	indexes=hashmap_new();
    indexes_hmm=indexes;
	
	return self;
}
-(BOOL)worldExists:(NSString*)name{
	NSString* file_name=[NSString stringWithFormat:@"%@/%@",documents,name];
	NSFileManager* fm=[NSFileManager defaultManager];
	if(![fm fileExistsAtPath:file_name]){
		NSLog(@"%@ doesn't exist",file_name);
		return FALSE;	
	}else{	
		NSLog(@"%@ exists",file_name);
		return TRUE;
	}
}
static int count=0;


-(BOOL)deleteWorld:(NSString*)name{
    NSFileManager* fm=[NSFileManager defaultManager];
    NSString* img_name=[NSString stringWithFormat:@"%@/%@.png",documents,name];
    if([fm fileExistsAtPath:img_name]){
        [fm removeItemAtPath:img_name error:NULL];
    }
    
	NSString* file_name=[NSString stringWithFormat:@"%@/%@",documents,name];
	
	
	if([fm fileExistsAtPath:file_name]){
		if([fm removeItemAtPath:file_name error:NULL])
			return TRUE;
		else 
			return FALSE;

	}
	return FALSE;
	
	
}
-(void)LoadCreatures{
    printf("start load:%d\n",1);
    if(sfh->version<3){
        for(int i=0;i<MAX_CREATURES_SAVED;i++){
            creatureData[i].type=-1;
        }
    }else{
        [saveFile seekToFileOffset:sfh->directory_offset-sizeof(EntityData)*MAX_CREATURES_SAVED];
        for(int i=0;i<MAX_CREATURES_SAVED;i++){
            NSData* data=[saveFile readDataOfLength:sizeof(EntityData)];
            
            [data getBytes:&creatureData[i] length:sizeof(EntityData)];
            creatureData[i].pos.x-=CHUNK_SIZE*chunkOffsetX;
            creatureData[i].pos.z-=CHUNK_SIZE*chunkOffsetZ;
            //  printf("type: %d\n  pos(%f,%f,%f)",creatureData[i].type,creatureData[i].pos.x,creatureData[i].pos.z,creatureData[i].pos.y);
        }
    }
    

    LoadModels2();
     printf("end load:%d\n",2);
}
-(void)saveCreatures{
    printf("start save:%d\n",sfh->version);
    if(sfh->version<3){
    [saveFile seekToFileOffset:sfh->directory_offset];
        sfh->directory_offset+=sizeof(EntityData)*MAX_CREATURES_SAVED;
        writeDirectory=TRUE;
    }
    else
      [saveFile seekToFileOffset:sfh->directory_offset-sizeof(EntityData)*MAX_CREATURES_SAVED];  
    SaveModels();
    for(int i=0;i<MAX_CREATURES_SAVED;i++){
        EntityData data=creatureData[i];
        data.pos.x+=CHUNK_SIZE*chunkOffsetX;
        data.pos.z+=CHUNK_SIZE*chunkOffsetZ;
        NSData* dh=[NSData dataWithBytesNoCopy:&data length:sizeof(EntityData)
                                  freeWhenDone:FALSE];
        [saveFile writeData:dh];

    }
     
	 printf("end save:%d\n",sfh->version);
    
}
-(void)saveWorld{
    return;
   // [TestFlight passCheckpoint:[NSString stringWithFormat:@"header_size:%d",(int)sizeof(WorldFileHeader)]];
    //printf("sizeof(WFH)=%d",(int)sizeof(WorldFileHeader));
	[[World getWorld].terrain endDynamics:TRUE];
	//[[World getWorld].terrain updateAllImportantChunks];
	writeDirectory=FALSE;
	Terrain* ter=[[World getWorld] terrain];
	NSString* name=ter.world_name;
	NSString* file_name=[NSString stringWithFormat:@"%@/%@",documents,name];
	
	sfh=malloc(sizeof(WorldFileHeader));
	//NSLog(@"saving level_seed: %d",ter.level_seed);
	sfh->level_seed=ter.level_seed;
	sfh->directory_offset=cur_dir_offset;
	sfh->home=ter.home;
	sfh->pos=[World getWorld].player.pos;
	sfh->pos.x/=BLOCK_SIZE;
	sfh->pos.z/=BLOCK_SIZE;
	sfh->pos.x+=CHUNK_SIZE*chunkOffsetX;
	sfh->pos.z+=CHUNK_SIZE*chunkOffsetZ;
	sfh->yaw=[World getWorld].player.yaw;
    sfh->version=file_version;
	[[World getWorld].menu.selected_world->display_name getCString:sfh->name
														 maxLength:49
														  encoding:NSUTF8StringEncoding];
    if(imgHash==NULL)imgHash=@""; 
    [imgHash getCString:sfh->hash
        maxLength:33
        encoding:NSUTF8StringEncoding];
    
	NSFileManager* fm=[NSFileManager defaultManager];
	if(![fm fileExistsAtPath:file_name]){	
        sfh->version=2;
		sfh->directory_offset=sizeof(WorldFileHeader);
		
		[fm createFileAtPath:file_name 
					contents:[NSData dataWithBytesNoCopy:sfh 
						length:sizeof(WorldFileHeader) freeWhenDone:FALSE]
			attributes:nil];
	
	}
	
    [[World getWorld].sf_lock lock];
	saveFile=[NSFileHandle fileHandleForUpdatingAtPath:file_name];	
	
    
	count=0;
	[self readDirectory];
	NSLog(@"read %d colidx's",count);
	
	[self saveCreatures];
    
    sfh->version=FILE_VERSION;
    file_version=FILE_VERSION;
    NSData* dh=[NSData dataWithBytesNoCopy:sfh length:sizeof(WorldFileHeader) freeWhenDone:FALSE];
     
    
	[saveFile seekToFileOffset:0];
    [saveFile writeData:dh];
	if(writeDirectory){
		
		
		count=0;
		[self writeDirectory];
		NSLog(@"wrote %d colidx's",count);
	}
	cur_dir_offset=sfh->directory_offset;
	[self readDirectory];
	free(sfh);
	[saveFile closeFile];
     [[World getWorld].sf_lock unlock];
	//[file writeData:[[NSData 
		
}
int saveColIdx(any_t passedIn,any_t colToSave){
	count++;
	ColumnIndex* colIndex=colToSave;
	if(colIndex&&colIndex->chunk_offset<sfh->directory_offset){
		int n=twoToOne(colIndex->x, colIndex->z);
		if(n==0){
		//	NSLog(@"corrupted col:%d",colIndex->chunk_offset);
		}
		
	NSData* dh=[NSData dataWithBytesNoCopy:colIndex length:sizeof(ColumnIndex)
				freeWhenDone:FALSE];
	[saveFile writeData:dh];
	}else{
		NSLog(@"WTF MATE");
	}
	return MAP_OK;
}
-(void)writeDirectory{
	[saveFile seekToFileOffset:sfh->directory_offset];
	hashmap_iterate(indexes, saveColIdx, NULL);
		
	
}
-(void)readDirectory{
	[self clearDirectory];
	[saveFile seekToFileOffset:sfh->directory_offset];
	while(TRUE){		
		NSData* data=[saveFile readDataOfLength:sizeof(ColumnIndex)];		
		if(data==NULL||[data length]<sizeof(ColumnIndex))break;
		count++;
		ColumnIndex* colIdx=malloc(sizeof(ColumnIndex));
		[data getBytes:colIdx length:sizeof(ColumnIndex)];
		int n=twoToOne(colIdx->x, colIdx->z);
		if(n!=0){
		hashmap_put(indexes,n, (any_t)colIdx);
           // printf("reading dir\n");
        }else {
			free(colIdx);
		}

		 
		
	}
}
-(void)clearDirectory{
	hashmap_remove_all(indexes,TRUE);
	//NSLog(@"hash %d",hashmap_length(indexes));
}	
	/*
 – offsetInFile
 – seekToEndOfFile
 – seekToFileOffset:
 – availableData
 – readDataToEndOfFile
 – readDataOfLength:
 – writeData:
 */
-(void)saveColumn:(int)cx:(int)cz{
    printf("saving column??");
	Terrain* ter=[[World getWorld] terrain];
	ColumnIndex* colIndex=NULL;
	
	int n=twoToOne(cx,cz);
	if(n==0){
		return;
	}
	hashmap_get(indexes, n, (any_t)&colIndex);
	if(colIndex==NULL){
		colIndex=malloc(sizeof(ColumnIndex));
        if(sfh->version>=3){
		colIndex->chunk_offset=sfh->directory_offset-sizeof(EntityData)*MAX_CREATURES_SAVED;
		
		
        }else{
            colIndex->chunk_offset=sfh->directory_offset;
        }
        sfh->directory_offset+=SIZEOF_COLUMN;
		writeDirectory=TRUE;
		colIndex->x=cx;
		colIndex->z=cz;
		hashmap_put(indexes, n, colIndex);
        printf("saving col?!!!!\n");
	}
	if((colIndex->chunk_offset-192)%SIZEOF_COLUMN!=0||colIndex->chunk_offset>=sfh->directory_offset){
		NSLog(@"BAD BAD OFFSET!!");
	}
	[saveFile seekToFileOffset:colIndex->chunk_offset];
    
	for(int cy=0;cy<CHUNKS_PER_COLUMN ;cy++){
		TerrainChunk* chunk;
        chunk=ter.chunkTable[threeToOne(cx-chunkOffsetX, cy, cz-chunkOffsetZ)];
		//hashmap_get(ter.chunkMap, threeToOne(cx-chunkOffsetX, cy, cz-chunkOffsetZ), (any_t)&chunk);
		if(chunk!=NULL){
			/*ChunkHeader ch;
			ch.n_vertices=chunk.n_vertices;
			NSData* data=[NSData dataWithBytesNoCopy:&ch
											  length:sizeof(ChunkHeader)
										freeWhenDone:FALSE];
			[saveFile writeData:data];
			
			int mesh_bytes=ch.n_vertices*sizeof(vertexStruct);
			sfh->directory_offset+=sizeof(ChunkHeader)+mesh_bytes;
			NSLog(@"vertices: %d",chunk.n_vertices);
			data=[NSData dataWithBytesNoCopy:chunk.vertices
									  length:mesh_bytes
								freeWhenDone:FALSE];
			[saveFile writeData:data];*/
            
			NSData* data=[NSData dataWithBytesNoCopy:chunk.pblocks
											  length:(CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE*sizeof(block8))
										freeWhenDone:FALSE];
			[saveFile writeData:data];
            data=[NSData dataWithBytesNoCopy:chunk.pcolors
                                      length:(CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE*sizeof(color8))
                                freeWhenDone:FALSE];
			[saveFile writeData:data];
		}else{
			NSLog(@"NULL CHUNK O SHIT");
		}
	}
	
}
extern block8* blockarray;
extern int g_offcx;
extern int g_offcz;
-(void)readColumn:(int)cx:(int)cz:(NSFileHandle*)rcfile{
     
	Terrain* ter=[[World getWorld] terrain];
	ColumnIndex* colIndex=NULL;
	int n= twoToOne(cx,cz);
	if(n==0){
		NSLog(@"mm");
		return;	
	}
    if(indexes_hmm!=indexes)printf("indexes pointer corrupted!!!!\n");
	hashmap_get(indexes,n, (any_t)&colIndex);
   
	if(colIndex==NULL){
		
		Terrain* ter=[[World getWorld] terrain];
     //   int cx2=cx-chunkOffsetX;
      //  int cz2=cz-chunkOffsetZ;
     //   if(rcfile==saveFile){
       //   printf("loading column from gen\n");
         [ter.tgen generateColumn:cx:cz:FALSE];
      //   }else{
             // printf("loading column from gen for bgthread\n");
        //     [ter.tgen generateColumn:cx:cz:TRUE];
       //  }
		return;
	}
	//NSLog(@"reading col: %d, %d, %d",cx,cz,colIndex->chunk_offset);
		
	//cx-=chunkOffsetX;
	//cz-=chunkOffsetZ;
	
	 NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];   
	TerrainChunk* chunk=NULL;
	//int oldcx,oldcz;
	/*if(ter.oldChunkMap!=NULL){
		oldcx=cx+(chunkOffsetX-oldOffsetX);
		oldcz=cz+(chunkOffsetZ-oldOffsetZ);
		
		hashmap_get(ter.oldChunkMap, threeToOne(oldcx, 0, oldcz), (any_t)&chunk);
		
	}*/
	
	if(chunk!=NULL){
        
		printf("nononono123 abort!\n");
		/*for(int cy=0;cy<CHUNKS_PER_COLUMN ;cy++){
			//hashmap_get(ter.oldChunkMap, threeToOne(oldcx, cy, oldcz), (any_t)&chunk);
			[chunk retain];
			int bounds[6];			
			bounds[0]=cx*CHUNK_SIZE;
			bounds[1]=cy*CHUNK_SIZE;
			bounds[2]=cz*CHUNK_SIZE;
			bounds[3]=(cx+1)*CHUNK_SIZE;
			bounds[4]=(cy+1)*CHUNK_SIZE;
			bounds[5]=(cz+1)*CHUNK_SIZE;		
			[chunk setBounds:bounds];
            if(chunk.needsGen){
                //printf("adding background loaded chunk\n");
                [ter addChunk:chunk:cx:cy:cz:TRUE];
            }else
			[ter readdChunk:chunk:cx:cy:cz];	
			
			for(int x=0;x<CHUNK_SIZE;x++){
				for(int z=0;z<CHUNK_SIZE;z++){
                    memcpy(blockarray+((x+bounds[0])*T_SIZE*T_HEIGHT+(z+bounds[2])*T_HEIGHT+bounds[1]),
                           chunk.pblocks+(x*CHUNK_SIZE*CHUNK_SIZE+z*CHUNK_SIZE),
                           CHUNK_SIZE);
                    
                    
					
				}			
			}
            
		}*/
		
		
		
	}else{
      //  printf("loading column from file\n");
       /* if(saveFile==rcfile)
        printf("loading column from file\n");
        else 
            printf("attempting to load col from file for bgthread\n");
*/
		[rcfile seekToFileOffset:colIndex->chunk_offset];
        TerrainChunk* columns[CHUNKS_PER_COLUMN];
         for(int cy=0;cy<CHUNKS_PER_COLUMN ;cy++){
            int bounds[6];
            
            bounds[0]=cx*CHUNK_SIZE;
            bounds[1]=cy*CHUNK_SIZE;
            bounds[2]=cz*CHUNK_SIZE;
            bounds[3]=(cx+1)*CHUNK_SIZE;
            bounds[4]=(cy+1)*CHUNK_SIZE;
            bounds[5]=(cz+1)*CHUNK_SIZE;
            
            TerrainChunk* chunk;
            
            TerrainChunk* old=ter.chunkTable[threeToOne(cx,cy,cz)];
            if(old){chunk=old;
                [chunk setBounds:bounds];

            }
            else
           chunk=[[TerrainChunk alloc] initWithBlocks:
                                                              bounds:cx:cz:ter:TRUE];
            columns[cy]=chunk;
            
            /*ChunkHeader ch;
             NSData* data=[saveFile readDataOfLength:sizeof(ChunkHeader)];
             [data getBytes:&ch length:sizeof(ChunkHeader)];		
             int mesh_bytes=ch.n_vertices*sizeof(vertexStruct);
             data=[saveFile readDataOfLength:mesh_bytes];
             vertexStruct* mesh=malloc(mesh_bytes);
             [data getBytes:mesh length:mesh_bytes];
             [chunk setVertices:mesh :ch.n_vertices];
             */	
            
            NSData* data=[rcfile readDataOfLength:(CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE*sizeof(block8))];
       		[data getBytes:chunk.pblocks length:(CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE*sizeof(block8))];
            
            NSData* data2=[rcfile readDataOfLength:(CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE*sizeof(color8))];
            [data2 getBytes:chunk.pcolors length:(CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE*sizeof(color8))];
            chunk.needsGen=TRUE;
            
           // if(rcfile==saveFile){
                for(int x=0;x<CHUNK_SIZE;x++){
                    for(int z=0;z<CHUNK_SIZE;z++){
                        if((x+bounds[0]+g_offcx)<0||(z+bounds[0]+g_offcz)<0){
                            printf("over/underflowing...\n");
                        }
                        memcpy(
                               
                blockarray+
            ((x+bounds[0]+g_offcx)%T_SIZE)*T_SIZE*T_HEIGHT+
                ((z+bounds[2]+g_offcz)%T_SIZE)*T_HEIGHT+bounds[1],
                               chunk.pblocks+(x*CHUNK_SIZE*CHUNK_SIZE+z*CHUNK_SIZE),
                               CHUNK_SIZE);
                        
                    }			
                }
                
                  
                [ter addChunk:chunk:cx:cy:cz:TRUE];	
           /* }else{
                [ter readdChunk:chunk:cx:cy:cz];
            }*/
            
        }
        
	}
    
    [pool release];
    
	
}
-(void)setName:(NSString*)file_name:(NSString*)display_name{
	file_name=[NSString stringWithFormat:@"%@/%@",documents,file_name];	
	 [[World getWorld].sf_lock lock];
	saveFile=[NSFileHandle fileHandleForUpdatingAtPath:file_name];		
	WorldFileHeader* fh=(WorldFileHeader*)[[saveFile readDataOfLength:sizeof(WorldFileHeader)] bytes];
	WorldFileHeader* fh2=malloc(sizeof(WorldFileHeader));
	memcpy(fh2,fh,sizeof(WorldFileHeader));
	[display_name getCString:fh2->name
								 maxLength:49
								  encoding:NSUTF8StringEncoding];
	NSData* dh=[NSData dataWithBytesNoCopy:fh2 length:sizeof(WorldFileHeader) freeWhenDone:TRUE];
	[saveFile seekToFileOffset:0];
	[saveFile writeData:dh];
	
	[saveFile closeFile];
	 [[World getWorld].sf_lock unlock];
	
}
-(void)setImageHash:(NSString*)hash{
    NSString* name=[World getWorld].terrain.world_name;
	NSString* file_name=[NSString stringWithFormat:@"%@/%@",documents,name];
    if(imgHash!=NULL){
        [imgHash release];
        imgHash=NULL;
    }
    imgHash=hash;
     [[World getWorld].sf_lock lock];
    saveFile=[NSFileHandle fileHandleForUpdatingAtPath:file_name];
    if(!saveFile){
        printf("err gettin save file: %s\n",[file_name cStringUsingEncoding:NSUTF8StringEncoding]);
        return;
    }
	WorldFileHeader* fh=(WorldFileHeader*)[[saveFile readDataOfLength:sizeof(WorldFileHeader)] bytes];
    if(fh==NULL){
        printf("err reading has from file\n");
        return;
    }
	WorldFileHeader* fh2=malloc(sizeof(WorldFileHeader));
	memcpy(fh2,fh,sizeof(WorldFileHeader));
	[hash getCString:fh2->hash
                   maxLength:33
                    encoding:NSUTF8StringEncoding];
    NSLog(@"MD5 hash of file  \"%@\": %s", 
          hash, fh2->hash);
	NSData* dh=[NSData dataWithBytesNoCopy:fh2 length:sizeof(WorldFileHeader) freeWhenDone:TRUE];
	[saveFile seekToFileOffset:0];
	[saveFile writeData:dh];
	
	[saveFile closeFile];	
     [[World getWorld].sf_lock unlock];
}
-(NSString*)getName:(NSString*)name{
	if(![[World getWorld].fm worldExists:name]) return @"error~";
	NSString* file_name=[NSString stringWithFormat:@"%@/%@",documents,name];	
	 [[World getWorld].sf_lock lock];
	saveFile=[NSFileHandle fileHandleForReadingAtPath:file_name];		
    NSData* data=[saveFile readDataOfLength:sizeof(WorldFileHeader)];
                  if([data length]<sizeof(WorldFileHeader)){
                    
                      [saveFile closeFile];
                      [[World getWorld].sf_lock unlock];
                       return @"error~";
                  }
	WorldFileHeader* fh=(WorldFileHeader*)[data bytes];
  
   
	//NSLog(@"fn:%s",fh->name);
	NSString* fname=[NSString stringWithCString:fh->name encoding:NSUTF8StringEncoding];
	if([fname length]==0){
        [saveFile closeFile];
        [[World getWorld].sf_lock unlock];
        return @"error~";
    }
	[saveFile closeFile];
     [[World getWorld].sf_lock unlock];
	return fname;
	
	
}
static unsigned long long convert_offset;
static NSFileHandle* oldFile;
static NSFileHandle* newFile;
#define SIZEOF_OLDCOLUMN CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE*CHUNKS_PER_COLUMN*(sizeof(block8))
#define SIZEOF_OLDCHUNK CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE*sizeof(block8)
enum OLD_BLOCK_TYPES{
    oTYPE_NONE=0,
    oTYPE_BEDROCK=1,
    oTYPE_STONE=2,
    oTYPE_DIRT=3,
    oTYPE_SAND=4,
    oTYPE_GREEN_LEAVES=5,
    oTYPE_TREE=6,
    oTYPE_WOOD=7,
    oTYPE_GRASS=8,
    oTYPE_TNT=9,
    oTYPE_DARK_WOOD=10,
    oTYPE_ORANGE_LEAVES=11,
    oTYPE_YELLOW_LEAVES=12,
    oTYPE_DARK_STONE=13,
    oTYPE_GRASS2=14,
    oTYPE_GRASS3=15,
    oTYPE_BRICK=16,
    oTYPE_COBBLESTONE=17,
    oTYPE_GLASS=18,
    oTYPE_GREEN_CRYSTAL=19,
    oTYPE_PINK_CRYSTAL=20,
    oTYPE_PURPLE_CRYSTAL=21,
    oTYPE_WHITE_CRYSTAL=22,
    oTYPE_RED_LEAVES=23,
    oTYPE_BLANK_RED=24,
    oTYPE_BLANK_ORANGE=25,
    oTYPE_BLANK_YELLOW=26,
    oTYPE_BLANK_GREEN=27,
    oTYPE_BLANK_BLUE=28,
    oTYPE_BLANK_PURPLE=29,
    oTYPE_BLANK_PINK=30
};
int convertType[31]={
    [oTYPE_NONE]=TYPE_NONE,
    [oTYPE_BEDROCK]=TYPE_BEDROCK,
    [oTYPE_STONE]=TYPE_STONE,
    [oTYPE_DIRT]=TYPE_DIRT,
    [oTYPE_SAND]=TYPE_SAND,
    [oTYPE_GREEN_LEAVES]=TYPE_LEAVES,
    [oTYPE_TREE]=TYPE_TREE,
    [oTYPE_WOOD]=TYPE_WOOD,
    [oTYPE_GRASS]=TYPE_GRASS,
    [oTYPE_TNT]=TYPE_TNT,
    [oTYPE_DARK_WOOD]=TYPE_WOOD,
    [oTYPE_ORANGE_LEAVES]=TYPE_LEAVES,
    [oTYPE_YELLOW_LEAVES]=TYPE_LEAVES,
    [oTYPE_DARK_STONE]=TYPE_DARK_STONE,
    [oTYPE_GRASS2]=TYPE_GRASS2,
    [oTYPE_GRASS3]=TYPE_GRASS3,
    [oTYPE_BRICK]=TYPE_BRICK,
    [oTYPE_COBBLESTONE]=TYPE_COBBLESTONE,
    [oTYPE_GLASS]=TYPE_GLASS,
    [oTYPE_GREEN_CRYSTAL]=TYPE_CRYSTAL,
    [oTYPE_PINK_CRYSTAL]=TYPE_CRYSTAL,
    [oTYPE_PURPLE_CRYSTAL]=TYPE_CRYSTAL,
    [oTYPE_WHITE_CRYSTAL]=TYPE_CRYSTAL,
    [oTYPE_RED_LEAVES]=TYPE_LEAVES,
    [oTYPE_BLANK_RED]=TYPE_SAND,
    [oTYPE_BLANK_ORANGE]=TYPE_SAND,
    [oTYPE_BLANK_YELLOW]=TYPE_SAND,
    [oTYPE_BLANK_GREEN]=TYPE_SAND,
    [oTYPE_BLANK_BLUE]=TYPE_SAND,
    [oTYPE_BLANK_PURPLE]=TYPE_SAND,
    [oTYPE_BLANK_PINK]=TYPE_SAND
};
int convertColor[31]={
    [oTYPE_NONE]=0,
    [oTYPE_BEDROCK]=0,
    [oTYPE_STONE]=0,
    [oTYPE_DIRT]=0,
    [oTYPE_SAND]=0,
    [oTYPE_GREEN_LEAVES]=0,
    [oTYPE_TREE]=0,
    [oTYPE_WOOD]=0,
    [oTYPE_GRASS]=0,
    [oTYPE_TNT]=0,
    [oTYPE_DARK_WOOD]=38,
    [oTYPE_ORANGE_LEAVES]=20,
    [oTYPE_YELLOW_LEAVES]=21,
    [oTYPE_DARK_STONE]=0,
    [oTYPE_GRASS2]=0,
    [oTYPE_GRASS3]=0,
    [oTYPE_BRICK]=0,
    [oTYPE_COBBLESTONE]=0,
    [oTYPE_GLASS]=0,
    [oTYPE_GREEN_CRYSTAL]=22,
    [oTYPE_PINK_CRYSTAL]=26,
    [oTYPE_PURPLE_CRYSTAL]=25,
    [oTYPE_WHITE_CRYSTAL]=0,
    [oTYPE_RED_LEAVES]=19,
    [oTYPE_BLANK_RED]=19,
    [oTYPE_BLANK_ORANGE]=20,
    [oTYPE_BLANK_YELLOW]=21,
    [oTYPE_BLANK_GREEN]=22,
    [oTYPE_BLANK_BLUE]=24,
    [oTYPE_BLANK_PURPLE]=25,
    [oTYPE_BLANK_PINK]=26
};

int convertColumnIdx(any_t passedIn,any_t colToConvert){
	
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];   
   
	ColumnIndex* colIndex=colToConvert;
	if(colIndex&&colIndex->chunk_offset+SIZEOF_OLDCOLUMN<=sfh->directory_offset){
        [oldFile seekToFileOffset:colIndex->chunk_offset];
        colIndex->chunk_offset=convert_offset;
        convert_offset+=SIZEOF_COLUMN;
        
        
        for(int cy=0;cy<CHUNKS_PER_COLUMN ;cy++){  	
            block8* blocks=malloc(SIZEOF_OLDCHUNK); 
            color8* colors=malloc(SIZEOF_OLDCHUNK);
            memset(colors,0,SIZEOF_OLDCHUNK);
        
            NSData* data=[oldFile readDataOfLength:SIZEOF_OLDCHUNK];
            [data getBytes:blocks length:SIZEOF_OLDCHUNK];
            for(int i=0;i<SIZEOF_OLDCHUNK;i++){
                int type=blocks[i];
                if(type>30)type=oTYPE_STONE;
                blocks[i]=convertType[type];
                colors[i]=convertColor[type];
            }
            
			data=[NSData dataWithBytesNoCopy:blocks length:SIZEOF_OLDCHUNK freeWhenDone:FALSE];
			[newFile writeData:data];
            data=[NSData dataWithBytesNoCopy:colors length:SIZEOF_OLDCHUNK freeWhenDone:FALSE];
			[newFile writeData:data];        
            free(blocks);
            free(colors);
        }	
	}
     [pool release];
	return MAP_OK;
}
-(void)convertFile:(NSString*) file_name{
    NSFileManager* fm=[NSFileManager defaultManager];
    oldFile=[NSFileHandle fileHandleForReadingAtPath:file_name];    
    NSString* temp_name=[NSString stringWithFormat:@"%@/temp.map",documents];
    [fm removeItemAtPath:temp_name error:NULL];
    [fm createFileAtPath:temp_name contents:nil attributes:nil];
    newFile=[NSFileHandle fileHandleForWritingAtPath:temp_name];
    
    sfh=(WorldFileHeader*)[[oldFile readDataOfLength:sizeof(WorldFileHeader)] bytes];
    sfh->version=2;
    file_version=2;
    saveFile=oldFile;
    count=0;
	[self readDirectory];
	NSLog(@"read %d old colidx's newfile: %@",count,newFile);  
    
    
    convert_offset=sizeof(WorldFileHeader);
    [newFile seekToFileOffset:convert_offset];
	hashmap_iterate(indexes, convertColumnIdx, NULL);
    
    sfh->directory_offset=convert_offset;    
    saveFile=newFile;
    [self writeDirectory];
    
    [newFile seekToFileOffset:0];
    NSData* dh=[NSData dataWithBytesNoCopy:sfh length:sizeof(WorldFileHeader) freeWhenDone:FALSE];
    [newFile writeData:dh];
    
    [oldFile closeFile];
    [newFile closeFile];    
    
    [fm removeItemAtPath:file_name error:NULL];
    NSError* err=nil;
    [fm moveItemAtPath:temp_name toPath:file_name error:&err];
    
    NSLog(@"err:%@",[err localizedDescription]);

    
}
extern bool SUPPORTS_OGL2;
extern float P_ZFAR;
-(void)loadWorld:(NSString*)name{

	Terrain* ter=[[World getWorld] terrain];
		[ter clearBlocks];
	Player* player=[[World getWorld] player];
    if(imgHash!=NULL){
        [imgHash release];
        imgHash=NULL;
    }
    [[World getWorld].player reset];
	if(![[World getWorld].fm worldExists:name]){
        
        extern int g_terrain_type;
        
        printf("loading sup2: %d\n",g_terrain_type);
        
        clear();
        
       // g_terrain_type=8;
        if(g_terrain_type==0){
            makeDirt();
        }else if(g_terrain_type==1){
            makeMars();
        }else if(g_terrain_type==2){
            makeRiverTrees(T_SIZE/2,0,T_SIZE,T_SIZE,550);
        }else if(g_terrain_type==3){
             makeRiverTrees(T_SIZE/2,0,T_SIZE,T_SIZE,550);
            makeMountains(0,0,T_SIZE/2-16,T_SIZE,400);
            makeTransition(T_SIZE/2-16,0,T_SIZE/2,T_SIZE);
        }else if(g_terrain_type==4){
            makeDesert();
        }else if(g_terrain_type==5){
            makePonies();
        }else if(g_terrain_type==6){
            makeBeach();
        }else if(g_terrain_type==7){
            makeMix();
        }else if(g_terrain_type==8){
            genflat=TRUE;
        }
        
		[self clearDirectory];
        if(genflat)ter.tgen.LEVEL_SEED= 0;
        else
		ter.tgen.LEVEL_SEED=arc4random()%300000;
		int centerChunk=4096;
		int r=T_SIZE/CHUNK_SIZE/2;

		chunkOffsetX=centerChunk-r;
		chunkOffsetZ=centerChunk-r;
		ter.level_seed=ter.tgen.LEVEL_SEED;
		
		for(int x=centerChunk-r;x<centerChunk+r;x++){
			for(int z=centerChunk-r;z<centerChunk+r;z++){
				
				[[World getWorld].fm readColumn:x:z:saveFile];	
				
			}
		}
		
		Vector temp;
		temp.x=centerChunk*CHUNK_SIZE+CHUNK_SIZE/2;
		temp.z=centerChunk*CHUNK_SIZE+CHUNK_SIZE/2;
		temp.y=T_HEIGHT-10;
		ter.home=temp;
		Vector temp2;		
		temp2.x=BLOCK_SIZE*(ter.home.x+.5f);
		temp2.y=BLOCK_SIZE*(ter.home.y+1);	
		temp2.z=BLOCK_SIZE*(ter.home.z+.5f);
            player.pos=temp2;
        

		//NSLog(@"player pos init save: %f %f %f",player.pos.x,player.pos.y,player.pos.z);
		//NSLog(@"chunkOffsets: %d %d",chunkOffsetX,chunkOffsetZ);
		player.yaw=90;	
        file_version=2;
		//[ter updateAllImportantChunks];
		[[World getWorld].player groundPlayer];
        
      
        for(int i=0;i<MAX_CREATURES_SAVED;i++){
            creatureData[i].type=-1;
        }
        
        LoadModels2();
		[[World getWorld].fm saveWorld];
		//[ter unloadTerrain:FALSE];
		//[self loadWorld:name];
	}else{
               
		NSString* file_name=[NSString stringWithFormat:@"%@/%@",documents,name];	
        [[World getWorld].sf_lock lock];
		saveFile=[NSFileHandle fileHandleForUpdatingAtPath:file_name];		
		sfh=(WorldFileHeader*)[[saveFile readDataOfLength:sizeof(WorldFileHeader)] bytes];
        file_version=sfh->version;
        if(sfh->version!=1&&sfh->version!=2&&sfh->version!=3){
            [saveFile closeFile];
            [[World getWorld].sf_lock unlock];
        NSLog(@"converting file");
            convertingWorld=TRUE;
            [self convertFile:file_name];
            
             NSLog(@"done converting file");
            [[World getWorld].sf_lock lock];
            saveFile=[NSFileHandle fileHandleForUpdatingAtPath:file_name];		
            sfh=(WorldFileHeader*)[[saveFile readDataOfLength:sizeof(WorldFileHeader)] bytes];
            convertingWorld=FALSE;
        }
        if(sfh->hash[32]==0)
        NSLog(@"image hash is %s",sfh->hash);
        if(imgHash!=NULL){
            [imgHash release];
            imgHash=NULL;
        }
        imgHash=[[NSString alloc] initWithCString:sfh->hash encoding:NSUTF8StringEncoding];
		ter.level_seed=sfh->level_seed;
		ter.tgen.LEVEL_SEED=ter.level_seed;
		cur_dir_offset=sfh->directory_offset;
		ter.home=sfh->home;
		player.pos=sfh->pos;
		player.yaw=sfh->yaw;
		[self readDirectory];
		//NSLog(@"indexes: %d",hashmap_length(indexes));
		//NSLog(@"loading level_seed: %d",ter.level_seed);
		//NSLog(@"directory offset: %d entries: %d",(int)sfh->directory_offset,hashmap_length(indexes));
		oldOffsetX=chunkOffsetX;
		oldOffsetZ=chunkOffsetZ;
		
		chunkOffsetX=player.pos.x/CHUNK_SIZE-T_RADIUS;
		chunkOffsetZ=player.pos.z/CHUNK_SIZE-T_RADIUS;
		//NSLog(@"chunkOffsets: %d %d",chunkOffsetX,chunkOffsetZ);
		/*sfh->pos.x-=chunkOffsetX*CHUNK_SIZE;
		sfh->pos.z-=chunkOffsetZ*CHUNK_SIZE;
		sfh->pos.x*=BLOCK_SIZE; 
		sfh->pos.z*=BLOCK_SIZE;
          
		*/player.pos=sfh->pos;
       
        
		//NSLog(@"player pos load: %f %f %f",player.pos.x,player.pos.y,player.pos.z);
		int r=T_RADIUS;
	//	int asdf=0;
        
		for(int x=chunkOffsetX;x<chunkOffsetX+2*r;x++){
			for(int z=chunkOffsetZ;z<chunkOffsetZ+2*r;z++){
			//	NSLog(@"lch:%d",asdf++);
				[[World getWorld].fm readColumn:x:z:saveFile];				
			}
		}
        [self LoadCreatures];
		//[ter updateAllImportantChunks];
		NSLog(@"done");
		[saveFile closeFile];
         [[World getWorld].sf_lock unlock];
		
		
	}
    if(!SUPPORTS_OGL2){
        if(ter.tgen.LEVEL_SEED== 0)
        [Graphics setZFAR:55];
        else 
        [Graphics setZFAR:40];
    }else{
        if(ter.tgen.LEVEL_SEED== 0)
        [Graphics setZFAR:120];
        else 
        [Graphics setZFAR:120];
    }

           [[Input getInput] clearAll];
    [[World getWorld].effects clearAllEffects];
    [[World getWorld].hud worldLoaded];
	

}
@end
