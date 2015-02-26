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
#import "FileArchive.h"
#import "FileManagerHelper.h"

//#import "TestFlight.h"






static map_t indexes;
static unsigned long long cur_dir_offset;
static map_t indexes_hmm;
static FileManager* single;

static NSFileHandle* saveFile;
static WorldFileHeader* sfh;
static BOOL writeDirectory;
static NSString* imgHash;
static int file_version;

const int defaultRegionSkyColors[4][4]={
     {COLOR_BWG1,COLOR_BLUE1,COLOR_GREEN1,COLOR_RED1},
    {COLOR_ORANGE2,COLOR_NORMAL_BLUE,COLOR_NORMAL_BLUE,COLOR_NORMAL_BLUE},
    {COLOR_NORMAL_BLUE,COLOR_NORMAL_BLUE,COLOR_NORMAL_BLUE,COLOR_ORANGE1},
    {COLOR_PURPLE1,COLOR_NORMAL_BLUE,COLOR_NORMAL_BLUE,COLOR_RED5}};
int regionSkyColors[4][4]={
    {COLOR_BWG1,COLOR_BLUE1,COLOR_GREEN1,COLOR_RED1},
    {COLOR_ORANGE2,COLOR_NORMAL_BLUE,COLOR_NORMAL_BLUE,COLOR_NORMAL_BLUE},
    {COLOR_NORMAL_BLUE,COLOR_NORMAL_BLUE,COLOR_NORMAL_BLUE,COLOR_ORANGE1},
    {COLOR_PURPLE1,COLOR_NORMAL_BLUE,COLOR_NORMAL_BLUE,COLOR_RED5}};

EntityData creatureData[MAX_CREATURES_SAVED];
FileManager::FileManager(){
	single=this;
    genflat=FALSE;
    imgHash=NULL;
    convertingWorld=FALSE;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	documents = [paths objectAtIndex:0];
	[documents retain];
    printg("!!!!!! %s\n",[documents cStringUsingEncoding:NSUTF8StringEncoding]);
	oldOffsetX=oldOffsetZ=chunkOffsetX=chunkOffsetZ=-1;
	indexes=hashmap_new();
    indexes_hmm=indexes;
    
    fmh_init(this);
	
	
}
BOOL FileManager::worldExists(NSString* name,BOOL appendArchive){
	NSString* file_name=appendArchive?[NSString stringWithFormat:@"%@/%@",documents,name]:[NSString stringWithFormat:@"%@/%@",documents,name];
	NSFileManager* fm=[NSFileManager defaultManager];
	if(![fm fileExistsAtPath:file_name]){
	//	NSLog(@"%@ doesn't exist",file_name);
		return FALSE;	
	}else{	
	//	NSLog(@"%@ exists",file_name);
		return TRUE;
	}
}
static int count=0;

BOOL FileManager::deleteWorld(NSString* name){
    NSFileManager* fm=[NSFileManager defaultManager];
    NSString* img_name=[NSString stringWithFormat:@"%@/%@.png",documents,name];
    if([fm fileExistsAtPath:img_name]){
        [fm removeItemAtPath:img_name error:NULL];
    }
   // removeFromIndex(name);
	NSString* file_name=[NSString stringWithFormat:@"%@/%@",documents,name];
	
	
	if([fm fileExistsAtPath:file_name]){
		if([fm removeItemAtPath:file_name error:NULL])
			return TRUE;
		else 
			return FALSE;

	}
	return FALSE;
	
	
}
void FileManager::LoadCreatures(){
    printg("start load:%d\n",1);
   
    if(sfh->version<3){
        for(int i=0;i<MAX_CREATURES_SAVED;i++){
            creatureData[i].type=-1;
        }
    }else{
        [saveFile seekToFileOffset:sfh->directory_offset-sizeof(EntityData)*MAX_CREATURES_SAVED];
        for(int i=0;i<MAX_CREATURES_SAVED;i++){
            NSData* data=[saveFile readDataOfLength:sizeof(EntityData)];
            
            [data getBytes:&creatureData[i] length:sizeof(EntityData)];
          //  creatureData[i].pos.x-=CHUNK_SIZE*chunkOffsetX;
           // creatureData[i].pos.z-=CHUNK_SIZE*chunkOffsetZ;
            //  printg("type: %d\n  pos(%f,%f,%f)",creatureData[i].type,creatureData[i].pos.x,creatureData[i].pos.z,creatureData[i].pos.y);
        }
    }
    

    LoadModels2();
     printg("end load:%d\n",2);
}
void FileManager::saveCreatures(){
  //  printg("start save:%d\n",sfh->version);
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
        //data.pos.x+=CHUNK_SIZE*chunkOffsetX;
       // data.pos.z+=CHUNK_SIZE*chunkOffsetZ;
        NSData* dh=[NSData dataWithBytesNoCopy:&data length:sizeof(EntityData)
                                  freeWhenDone:FALSE];
        [saveFile writeData:dh];

    }
     
//	 printg("end save:%d\n",sfh->version);
}

void FileManager::saveWorld(){
    this->saveWorld([World getWorld].player->pos);
    
    
}
void FileManager::compressLastPlayed(){
  //  NSString* name=[World getWorld].terrain.world_name;
	//NSString* file_name=[NSString stringWithFormat:@"%@/%@",documents,name];
   // CompressWorld([name cStringUsingEncoding:NSUTF8StringEncoding]);
    
}
void FileManager::loadGenFromDisk(){
    NSString *path =@"test.png";
    
   
    
    if (path != nil)
    {
        //UIImage *image = [UIImage imageNamed:path];
        
        if(![path isAbsolutePath])
            path = [[NSBundle mainBundle] pathForResource:path ofType:nil];
       
        UIImage *image = [UIImage imageWithContentsOfFile:path];
       
        if(image != NULL)printg("loaded image\n");
        
       
        
        // First get the image into your data buffer
        CGImageRef imageRef = [image CGImage];
        NSUInteger width = CGImageGetWidth(imageRef);
        NSUInteger height = CGImageGetHeight(imageRef);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
        NSUInteger bytesPerPixel = 4;
        NSUInteger bytesPerRow = bytesPerPixel * width;
        NSUInteger bitsPerComponent = 8;
        CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                     bitsPerComponent, bytesPerRow, colorSpace,
                                                     kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGColorSpaceRelease(colorSpace);
        
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
        CGContextRelease(context);
       
        extern block8* biomez;
        biomez=(block8*)malloc(height*width*sizeof(block8));
        memset(biomez,0,height*width*sizeof(block8));
        /*
        int xx=0;
        int yy=0;
        int count=width*height;
        
        // Now your rawData contains the image data in the RGBA8888 pixel format.
        int x=0;
        int y=0;
        int byteIndex = (bytesPerRow * yy) + xx * bytesPerPixel;
        //BOOL onetime=false;
        //int waterc=0;
        //int landc=0;

    int marker_colors[NUM_TERRAIN_MARKERS][3]={
            [TM_WATER]={0,0,255},
            [TM_GRASS]={0,255,0},
            [TM_BEACH]={255,255,0},
            [TM_MOUNTAINS]={255,255,255},
            [TM_MARS]={255,0,0},
            [TM_RIVERS]={0,255,255},
            [TM_UNICORN]={255,0,255}
            
        };
        for (int ii = 0 ; ii < count ; ++ii)
        {
            int red   = (rawData[byteIndex]     * 1.0);
            int green = (rawData[byteIndex + 1] * 1.0);
            int blue  = (rawData[byteIndex + 2] * 1.0);
           // int alpha = (rawData[byteIndex + 3] * 1.0);
            byteIndex += 4;
            x++;
            if(x==width){
                x=0;
                y++;
            }
            for(int i=0;i<NUM_TERRAIN_MARKERS;i++){
                if(red==marker_colors[i][0]&&green==marker_colors[i][1]&&blue==marker_colors[i][2]){
                    TM(x,y)=i;
                    break;
                }
            }
            
        }*/
        //printg("landc:%d waterc:%d total:%d\n",landc,waterc, count);
        free(rawData);
        
       
    
    }
    
    
}
void FileManager::writeGenToDisk(){
    printg("writing gen to disk\n");
    NSString* name=@"Eden.eden";
	NSString* file_name=[NSString stringWithFormat:@"%@/%@",documents,name];
    
    sfh=(WorldFileHeader*)malloc(sizeof(WorldFileHeader));
    
    NSFileManager* fm=[NSFileManager defaultManager];
	if([fm fileExistsAtPath:file_name]){
       

        BOOL success = [fm removeItemAtPath:file_name error:NULL];
        if(success){
            printg("removed existing world file\n");
        }else
            printg("error removing world file\n");
		
        
	}
	sfh->directory_offset=sizeof(WorldFileHeader)+sizeof(EntityData)*MAX_CREATURES_SAVED;;
    
	sfh->level_seed=0;
    
    int centerChunk=4096;
    int r=GSIZE/CHUNK_SIZE/2;
    Vector temp;
    temp.x=centerChunk*CHUNK_SIZE+CHUNK_SIZE/2;
    temp.z=centerChunk*CHUNK_SIZE+CHUNK_SIZE/2;
    temp.y=T_HEIGHT-10;
    sfh->home=temp;
    Vector temp2;
    temp2.x=BLOCK_SIZE*(sfh->home.x+.5f);
    temp2.y=BLOCK_SIZE*(sfh->home.y+1);
    temp2.z=BLOCK_SIZE*(sfh->home.z+.5f);
    sfh->pos=temp2;
    
    
	//sfh->home=MakeVector(5000,50,5000);
	//sfh->pos=MakeVector(5000,50,5000);
    
	sfh->yaw=90;
    sfh->version=FILE_VERSION;
    
    for(int i=0;i<4;i++){
        for(int j=0;j<4;j++){
            regionSkyColors[i][j]=defaultRegionSkyColors[i][j];
        }
    }
    
    for(int i=0;i<4;i++){
        for(int j=0;j<4;j++){
            sfh->skycolors[i*4+j]=regionSkyColors[i][j];
        }
    }
    
   
	strcpy(sfh->name,"Eden");
    
    [fm createFileAtPath:file_name
                contents:[NSData dataWithBytesNoCopy:sfh
                 length:sizeof(WorldFileHeader) freeWhenDone:FALSE]
              attributes:nil];
    
    saveFile=[NSFileHandle fileHandleForUpdatingAtPath:file_name];
    
    
	//////////////////////////
	count=0;
	this->readDirectory();
	
    
    
    
 
    
 
    if(!NOBLOCKGEN)
    for(int x=0;x<GEN_CWIDTH;x++){
        for(int z=0;z<GEN_CDEPTH;z++){
            this->saveGenColumn(x+centerChunk-r,z+centerChunk-r,centerChunk-r);
        }
    }
    
    
	
	//[self saveCreatures];
    
   
    NSData* dh=[NSData dataWithBytesNoCopy:sfh length:sizeof(WorldFileHeader) freeWhenDone:FALSE];
    
    
	[saveFile seekToFileOffset:0];
    [saveFile writeData:dh];
	if(writeDirectory){
		
		
		count=0;
		this->fwriteDirectory();
		
	}
	
	this->readDirectory();
	free(sfh);
	[saveFile closeFile];
    printg("finished writing gen to disk\n");

}

void FileManager::saveWorld(Vector warp){
    //[TestFlight passCheckpoint:[NSString stringWithFormat:@"header_size:%d",(int)sizeof(WorldFileHeader)]];
    printf("sizeof(WFH)=%d",(int)sizeof(WorldFileHeader));
	[[World getWorld].terrain endDynamics:TRUE];
	//[[World getWorld].terrain updateAllImportantChunks];
	writeDirectory=FALSE;
	Terrain* ter=[[World getWorld] terrain];
	NSString* name=ter.world_name;
	NSString* file_name=[NSString stringWithFormat:@"%@/%@",documents,name];
	
	sfh=(WorldFileHeader*)malloc(sizeof(WorldFileHeader));
	//NSLog(@"saving level_seed: %d",ter.level_seed);
	sfh->level_seed=ter.level_seed;
    sfh->goldencubes=[World getWorld].hud->goldencubes;
	sfh->directory_offset=cur_dir_offset;
	sfh->home=ter.home;
	sfh->pos=[World getWorld].player->pos;
	//sfh->pos.x/=BLOCK_SIZE;
	//sfh->pos.z/=BLOCK_SIZE;
	//sfh->pos.x+=CHUNK_SIZE*chunkOffsetX;
	//sfh->pos.z+=CHUNK_SIZE*chunkOffsetZ;
    printg("saving at player pos: %f,%f   co: %d,%d wfh_size:%d\n",sfh->pos.x,sfh->pos.z,chunkOffsetX,chunkOffsetZ,(int)sizeof(WorldFileHeader));
	sfh->yaw=[World getWorld].player->yaw;
    sfh->version=file_version;
    
    for(int i=0;i<4;i++){
        for(int j=0;j<4;j++){
            sfh->skycolors[i*4+j]=regionSkyColors[i][j];
        }
    }
    
	[[World getWorld].menu->selected_world->display_name getCString:sfh->name
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
        writeDirectory=TRUE;
	
	}
	
   
	saveFile=[NSFileHandle fileHandleForUpdatingAtPath:file_name];	
	
    
	count=0;
	this->readDirectory();
	NSLog(@"read %d colidx's",count);
 //   Player* player=[World getWorld].player;
  //  int scox=player.pos.x/CHUNK_SIZE-T_RADIUS;
   // int scoz=player.pos.z/CHUNK_SIZE-T_RADIUS;
   
    sfh->pos=warp;
    
    
    //NSLog(@"player pos load: %f %f %f",player.pos.x,player.pos.y,player.pos.z);
    //int r=T_RADIUS;
	//	int asdf=0;
   // printg("saving at co(%d,%d)",scox,scoz);
   // printg("save player pos(%d,%d)\n",(int)warp.x,(int)warp.z);
 //   for(int x=scox;x<scox+2*r;x++){
  //      for(int z=scoz;z<scoz+2*r;z++){
			//	NSLog(@"lch:%d",asdf++);
        //   [[World getWorld].fm saveColumn:x:z];
//        }
 //   }
    
    for(int x=0;x<CHUNKS_PER_SIDE;x++){
        for(int z=0;z<CHUNKS_PER_SIDE;z++)
        {
            TerrainChunk* chunk=ter.chunkTable[threeToOne(x,0,z)];
            
            if(chunk->pbounds[1]==0){
                this->saveColumn(chunk->pbounds[0]/CHUNK_SIZE
                                  ,chunk->pbounds[2]/CHUNK_SIZE);
                
            }else{
                printg("trying to save column with unexpected chunk bound[1]: %d\n",chunk->pbounds[1]);
            
            }
        }
    }
   

  
	//hashmap_iterate(ter.chunkMap, saveChunk, NULL);
	saveCreatures();
    
    sfh->version=FILE_VERSION;
    file_version=FILE_VERSION;
    NSData* dh=[NSData dataWithBytesNoCopy:sfh length:sizeof(WorldFileHeader) freeWhenDone:FALSE];
     
    
	[saveFile seekToFileOffset:0];
    [saveFile writeData:dh];
	if(writeDirectory){
		
		
		count=0;
		fwriteDirectory();
		NSLog(@"wrote %d colidx's",count);
	}
	cur_dir_offset=sfh->directory_offset;
	readDirectory();
	free(sfh);
	[saveFile closeFile];
   
	//[file writeData:[[NSData 
		
}
int saveColIdx(any_t passedIn,any_t colToSave){
	count++;
	ColumnIndex* colIndex=(ColumnIndex*)colToSave;
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
void FileManager::fwriteDirectory(){
	[saveFile seekToFileOffset:sfh->directory_offset];
	hashmap_iterate(indexes, saveColIdx, NULL);
		
	
}
void FileManager::readDirectory(){
	this->clearDirectory();
	[saveFile seekToFileOffset:sfh->directory_offset];
	while(TRUE){		
		NSData* data=[saveFile readDataOfLength:sizeof(ColumnIndex)];		
		if(data==NULL||[data length]<sizeof(ColumnIndex))break;
		count++;
		ColumnIndex* colIdx=(ColumnIndex*)malloc(sizeof(ColumnIndex));
		[data getBytes:colIdx length:sizeof(ColumnIndex)];
		int n=twoToOne(colIdx->x, colIdx->z);
		if(n!=0){
		hashmap_put(indexes,n, (any_t)colIdx);
           // printg("reading dir\n");
        }else {
			free(colIdx);
		}

		 
		
	}
}
void FileManager::clearDirectory(){
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

/*-(void)saveGenColumn:(int)cx:(int)cz:(int)origin{  // NO RUN LENGTH ENCODING VERSION
    
	
	ColumnIndex* colIndex=NULL;
	

	
    colIndex=malloc(sizeof(ColumnIndex));
    colIndex->chunk_offset=sfh->directory_offset-sizeof(EntityData)*MAX_CREATURES_SAVED;
    sfh->directory_offset+=SIZEOF_COLUMN;
    writeDirectory=TRUE;
    colIndex->x=cx;
    colIndex->z=cz;
    int n=twoToOneTest(cx,cz);
	hashmap_put(indexes, n, colIndex);
        
	
	[saveFile seekToFileOffset:colIndex->chunk_offset];
    block8 blocks[CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE];
    block8 colors[CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE];
	
    extern block8* blockz;
    extern color8* colorz;
    
    int xoffset=CHUNK_SIZE*(cx-origin);
    int zoffset=CHUNK_SIZE*(cz-origin);
   
    for(int cy=0;cy<CHUNKS_PER_COLUMN ;cy++){
        int yoffset=cy*CHUNK_SIZE;
        
            for(int x=0;x<CHUNK_SIZE;x++){
            for(int y=0;y<CHUNK_SIZE;y++){
            for(int z=0;z<CHUNK_SIZE;z++){
                blocks[x*CHUNK_SIZE*CHUNK_SIZE+z*CHUNK_SIZE+y]=BLOCK(x+xoffset,z+zoffset,y+yoffset);
                colors[x*CHUNK_SIZE*CHUNK_SIZE+z*CHUNK_SIZE+y]=COLOR(x+xoffset,z+zoffset,y+yoffset);
            }}}
      
        
			NSData* data=[NSData dataWithBytesNoCopy:blocks
											  length:(CHUNK_SIZE3*sizeof(block8))
										freeWhenDone:FALSE];
			[saveFile writeData:data];
            data=[NSData dataWithBytesNoCopy:colors
                                      length:(CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE*sizeof(color8))
                                freeWhenDone:FALSE];
			[saveFile writeData:data];
		
	}
	
}*/

void FileManager::saveGenColumn(int cx,int cz,int origin){
  
	
	ColumnIndex* colIndex=NULL;
	
    
	
    colIndex=(ColumnIndex*)malloc(sizeof(ColumnIndex));
    colIndex->chunk_offset=sfh->directory_offset-sizeof(EntityData)*MAX_CREATURES_SAVED;
    
    writeDirectory=TRUE;
    colIndex->x=cx;
    colIndex->z=cz;
    int n=twoToOneTest(cx,cz);
	hashmap_put(indexes, n, colIndex);
    
	
	[saveFile seekToFileOffset:colIndex->chunk_offset];
    block8 blocks[CHUNK_SIZE3];
    color8 colors[CHUNK_SIZE3];
	
    extern block8* blockz;
    extern color8* colorz;
    
    int xoffset=CHUNK_SIZE*(cx-origin);
    int zoffset=CHUNK_SIZE*(cz-origin);
 
    for(int cy=0;cy<CHUNKS_PER_COLUMN ;cy++){
        int yoffset=cy*CHUNK_SIZE;
        
        for(int x=0;x<CHUNK_SIZE;x++){
            for(int y=0;y<CHUNK_SIZE;y++){
                for(int z=0;z<CHUNK_SIZE;z++){
                    //unusual coordinate order to maximize compression
                   /* blocks[y*CHUNK_SIZE*CHUNK_SIZE+x*CHUNK_SIZE+z]=BLOCK(x+xoffset,z+zoffset,y+yoffset);
                    colors[y*CHUNK_SIZE*CHUNK_SIZE+x*CHUNK_SIZE+z]=COLOR(x+xoffset,z+zoffset,y+yoffset);*/
                    
                    blocks[y*CHUNK_SIZE*CHUNK_SIZE+z*CHUNK_SIZE+x]=BLOCK(x+xoffset,z+zoffset,y+yoffset);
                    colors[y*CHUNK_SIZE*CHUNK_SIZE+z*CHUNK_SIZE+x]=COLOR(x+xoffset,z+zoffset,y+yoffset);
                    
                    
                
                }}}
        
       // memset(blocks,0,CHUNK_SIZE3);
       // memset(colors,0,CHUNK_SIZE3);
        
        /*int y=arc4random()%CHUNK_SIZE;
        for(int x=0;x<CHUNK_SIZE;x++){

                for(int z=0;z<CHUNK_SIZE;z++){
                    //if(y%2==0){
                    if(arc4random()%2==0){
                        blocks[x*CHUNK_SIZE*CHUNK_SIZE+z*CHUNK_SIZE+y]=TYPE_BRICK;
                        
                        colors[x*CHUNK_SIZE*CHUNK_SIZE+z*CHUNK_SIZE+y]=y%NUM_COLORS;
                    }
                        // }
                }
        }*/
       
        
        color8 rledata[CHUNK_SIZE3*3+2];
        int marker=-1;
        int marker_color=-1;
        int count =0;
        int dataidx=2;
        for(int i=0;i<CHUNK_SIZE3;i++){
            int t=blocks[i];
            int c=colors[i];
            if(t<0||c<0)printg("wtf mate");
            if(t==marker&&c==marker_color&&count!=127){
                count++;
                
            }else{
                if(count>0){
 
                   // printg("count: %d\n",count);
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
            //printg("count: %d\n",count);
            rledata[dataidx++]=marker;
            rledata[dataidx++]=marker_color;
            rledata[dataidx++]=count;
            count=0;
            marker=-1;
            marker_color=-1;
        }
        
       
        if(dataidx>CHUNK_SIZE3*3){
            printg("dataidx overflow\n");
        }else{
            rledata[0]=dataidx/256;
            rledata[1]=dataidx%256;
            
            
           
            
            sfh->directory_offset+=dataidx;
        }
        
        NSData* data=[NSData dataWithBytesNoCopy:rledata
                                          length:(dataidx*sizeof(color8))
                                    freeWhenDone:FALSE];
        [saveFile writeData:data];
               //[saveFile writeData:data];
		
	}
	
}
void FileManager::saveColumn(int cx,int cz){
	Terrain* ter=[[World getWorld] terrain];
	ColumnIndex* colIndex=NULL;
	
    BOOL needsSave=FALSE;
    for(int cy=0;cy<CHUNKS_PER_COLUMN ;cy++){
		TerrainChunk* chunk;
        //issue #3 continued
        chunk=ter.chunkTable[threeToOne(cx, cy, cz)];
        if(chunk->modified){needsSave=TRUE; chunk->modified=FALSE;}
    }
    if(!needsSave)return;
    
    //printg("saving column: %d,%d\n",cx,cz);
	int n=twoToOneTest(cx,cz);
	if(n==0){
		return;
	}
	hashmap_get(indexes, n, (any_t*)&colIndex);
	if(colIndex==NULL){
		colIndex=(ColumnIndex*)malloc(sizeof(ColumnIndex));
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
       
	}
	if((colIndex->chunk_offset-192)%SIZEOF_COLUMN!=0||colIndex->chunk_offset>=sfh->directory_offset){
        if((colIndex->chunk_offset-192)%SIZEOF_COLUMN!=0){
		printg("BAD BAD OFFSET!! %d\n",(int)sizeof(WorldFileHeader));
        }else if(colIndex->chunk_offset>=sfh->directory_offset)
        NSLog(@"OFFSET OVERFLOWS DIRECTORY!");
	}
	[saveFile seekToFileOffset:colIndex->chunk_offset];
    
	for(int cy=0;cy<CHUNKS_PER_COLUMN ;cy++){
		TerrainChunk* chunk;
         //issue #3 continued
        chunk=ter.chunkTable[threeToOne(cx, cy, cz)];
		//hashmap_get(ter.chunkMap, threeToOne(cx-chunkOffsetX, cy, cz-chunkOffsetZ), (any_t)&chunk);
        //co(16316,16395),co(16316,16395)
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
            
			NSData* data=[NSData dataWithBytesNoCopy:chunk->pblocks
											  length:(CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE*sizeof(block8))
										freeWhenDone:FALSE];
			[saveFile writeData:data];
            data=[NSData dataWithBytesNoCopy:chunk->pcolors
                                      length:(CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE*sizeof(color8))
                                freeWhenDone:FALSE];
			[saveFile writeData:data];
		}else{
			printg("NULL CHUNK O SHIT\n");
		}
	}
	
}
extern block8* blockarray;
extern int g_offcx;
extern int g_offcz;
void FileManager::readColumn(int cx,int cz,NSFileHandle* rcfile){
	Terrain* ter=[[World getWorld] terrain];
	ColumnIndex* colIndex=NULL;
	int n= twoToOne(cx,cz);
	if(n==0){
		NSLog(@"mm");
		return;	
	}
    if(indexes_hmm!=indexes)printg("FATAL ERROR: indexes pointer corrupted!!!!\n");
	hashmap_get(indexes,n, (any_t*)&colIndex);
   
	if(colIndex==NULL){
		
		Terrain* ter=[[World getWorld] terrain];
     //   int cx2=cx-chunkOffsetX;
      //  int cz2=cz-chunkOffsetZ;
     //   if(rcfile==saveFile){
        //printg("loading column from gen %d,%d \n",cx,cz);
     if(ter.tgen->LEVEL_SEED==DEFAULT_LEVEL_SEED){
         fmh_readColumnFromDefault(cx,cz);
            
            return;
     }else{
         ter.tgen->generateColumn(cx,cz,FALSE);
      		return;
     }
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
        
		printg("nononono123 abort!\n");
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
                //printg("adding background loaded chunk\n");
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
      //  printg("loading column from file\n");
       /* if(saveFile==rcfile)
        printg("loading column from file\n");
        else 
            printg("attempting to load col from file for bgthread\n");
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
             //issue #3 continued
            TerrainChunk* old=ter.chunkTable[threeToOne(cx,cy,cz)];
            if(old){chunk=old;
                chunk->setBounds(bounds);

            }
            else{
                printf("crittcler error re-allocating terrain chunk\n");
          // chunk=new TerrainChunk(bounds,cx,cz,ter,TRUE);
            }
             
             
            columns[cy]=chunk;
            
           
             BOOL rle=false;
             if(rle){
                 
                 block8 tblocks[CHUNK_SIZE3];
                 color8 tcolors[CHUNK_SIZE3];
                 color8 buf[CHUNK_SIZE3*3];
                 //too much read
                 NSData* datat=[rcfile readDataOfLength:2];
                 color8 buft[2];
                 [datat getBytes:buft length:2];
                 int chunk_data_length= buft[0]*256+buft[1]-2;
                 NSData* data=[rcfile readDataOfLength:chunk_data_length];
                 int n=(int)[data length];
                 if(n<chunk_data_length){
                     printg("not enough file left, only read %d bytes\n",n);
                 }//else
                  //   printg("all good %d, %d  sizeofcolor8:%d\n",(int)n,(int)chunk_data_length,(int)sizeof(color8));
                 [data getBytes:buf length:n];
                 
                 int idx=0;
                 int idx2=0;
                 while(idx<n){
                     int marker=(block8)buf[idx++];
                     int marker_color=(color8)buf[idx++];
                     int count=(color8)buf[idx++];
                    // printg("count: %d\n",count);
                     if(count<0||count>127)printg("strange count %d\n ",count);
                     for(int i=0;i<count;i++){
                         if(idx2>CHUNK_SIZE3){
                            // printg("data overflow1 %d  n:%d\n",idx2,n);
                             break;
                         }
                         tblocks[idx2]=marker;
                         tcolors[idx2]=marker_color;
                         idx2++;
                        
                         
                     }
                     if(idx2>=CHUNK_SIZE3){
                         
                         break;
                         
                     }
                 }
                 if(idx2>CHUNK_SIZE3)putchar('>');
                 else if(idx2<CHUNK_SIZE3)putchar('<');
                 else if(idx2==CHUNK_SIZE3){
                   //  putchar('=');
                     for(int z=0;z<CHUNK_SIZE;z++)
                     for(int x=0;x<CHUNK_SIZE;x++)
                         for(int y=0;y<CHUNK_SIZE;y++){
                             chunk->pblocks[CC(x,z,y)]=tblocks[CC(y,z,x)];
                             chunk->pcolors[CC(x,z,y)]=tcolors[CC(y,z,x)];
                         }
                             
                     
                 }
                
                 
             }else{
                 NSData* data=[rcfile readDataOfLength:(CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE*sizeof(block8))];
                 [data getBytes:chunk->pblocks length:(CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE*sizeof(block8))];
                 
                 NSData* data2=[rcfile readDataOfLength:(CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE*sizeof(color8))];
                 [data2 getBytes:chunk->pcolors length:(CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE*sizeof(color8))];
             }
            
           /*
            chunk.needsGen=TRUE;*/
            
           
                for(int x=0;x<CHUNK_SIZE;x++){
                    for(int z=0;z<CHUNK_SIZE;z++){
                        if((x+bounds[0]+g_offcx)<0||(z+bounds[0]+g_offcz)<0){
                            printg("over/underflowing...\n");
                        }
                        memcpy(
                               
                blockarray+
            ((x+bounds[0]+g_offcx)%T_SIZE)*T_SIZE*T_HEIGHT+
                ((z+bounds[2]+g_offcz)%T_SIZE)*T_HEIGHT+bounds[1],
                               chunk->pblocks+(x*CHUNK_SIZE*CHUNK_SIZE+z*CHUNK_SIZE),
                               CHUNK_SIZE);
                        
                    }			
                }
                
                  
                [ter addChunk:chunk:cx:cy:cz:TRUE];	
             
        }
        
	}
    
    [pool release];
    
	
}
void FileManager::setName(NSString* file_name,NSString* display_name){
   //file_name=[file_name stringByDeletingPathExtension];
    NSLog(@"set name request on:%@",file_name);
   // NSString* nofp=file_name;
    file_name=[NSString stringWithFormat:@"%@/%@",documents,file_name];
   // DecompressWorld([file_name cStringUsingEncoding:NSUTF8StringEncoding]);
  
	
	
	saveFile=[NSFileHandle fileHandleForUpdatingAtPath:file_name];
    if(saveFile==NULL){
        NSLog(@"file to rename not found\n");
        return;
    }
	WorldFileHeader* fh=(WorldFileHeader*)[[saveFile readDataOfLength:sizeof(WorldFileHeader)] bytes];
	WorldFileHeader* fh2=(WorldFileHeader*)malloc(sizeof(WorldFileHeader));
	memcpy(fh2,fh,sizeof(WorldFileHeader));
	[display_name getCString:fh2->name
								 maxLength:49
								  encoding:NSUTF8StringEncoding];
	NSData* dh=[NSData dataWithBytesNoCopy:fh2 length:sizeof(WorldFileHeader) freeWhenDone:TRUE];
	[saveFile seekToFileOffset:0];
	[saveFile writeData:dh];
	
	[saveFile closeFile];
	 
    
   // CompressWorld([nofp cStringUsingEncoding:NSUTF8StringEncoding]);
	
}
void FileManager::setImageHash(NSString* hash){
    NSString* name=[World getWorld].terrain.world_name;
	NSString* file_name=[NSString stringWithFormat:@"%@/%@",documents,name];
    if(imgHash!=NULL){
        [imgHash release];
        imgHash=NULL;
    }
    imgHash=hash;
   
    saveFile=[NSFileHandle fileHandleForUpdatingAtPath:file_name];
    if(!saveFile){
        printg("err gettin save file: %s\n",[file_name cStringUsingEncoding:NSUTF8StringEncoding]);
        return;
    }
	WorldFileHeader* fh=(WorldFileHeader*)[[saveFile readDataOfLength:sizeof(WorldFileHeader)] bytes];
    if(fh==NULL){
        printg("err reading has from file\n");
        return;
    }
	WorldFileHeader* fh2=(WorldFileHeader*)malloc(sizeof(WorldFileHeader));
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
   
}
/*-(NSString*)getArchiveName:(NSString*)name{
	if(![[World getWorld].fm worldExists:name:FALSE]) return @"error~";
    return getArchiveName(name);
	//NSString* file_name=[NSString stringWithFormat:@"%@/%@",documents,name];
    
	//return fname;
	
	
}*/

NSString* FileManager::getName(NSString* name){
	if(!this->worldExists(name,FALSE)) return @"error~";
	NSString* file_name=[NSString stringWithFormat:@"%@/%@",documents,name];	
	
	saveFile=[NSFileHandle fileHandleForReadingAtPath:file_name];		
    NSData* data=[saveFile readDataOfLength:sizeof(WorldFileHeader)];
                  if([data length]<sizeof(WorldFileHeader)){
                    
                      [saveFile closeFile];
                     
                       return @"error~";
                  }
	WorldFileHeader* fh=(WorldFileHeader*)[data bytes];
  
   
	//NSLog(@"fn:%s",fh->name);
	NSString* fname=[NSString stringWithCString:fh->name encoding:NSUTF8StringEncoding];
	if([fname length]==0){
        fname=@"error~";
       // [saveFile closeFile];
        //[[World getWorld].sf_lock unlock];
        //return @"error3~";
    }
	[saveFile closeFile];
    
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
   
	ColumnIndex* colIndex=(ColumnIndex*)colToConvert;
	if(colIndex&&colIndex->chunk_offset+SIZEOF_OLDCOLUMN<=sfh->directory_offset){
        [oldFile seekToFileOffset:colIndex->chunk_offset];
        colIndex->chunk_offset=convert_offset;
        convert_offset+=SIZEOF_COLUMN;
        
        
        for(int cy=0;cy<CHUNKS_PER_COLUMN ;cy++){  	
            block8* blocks=(block8*)malloc(SIZEOF_OLDCHUNK);
            color8* colors=(color8*)malloc(SIZEOF_OLDCHUNK);
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
void FileManager::convertFile(NSString* file_name){
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
	this->readDirectory();
	NSLog(@"read %d old colidx's newfile: %@",count,newFile);  
    
    
    convert_offset=sizeof(WorldFileHeader);
    [newFile seekToFileOffset:convert_offset];
	hashmap_iterate(indexes, convertColumnIdx, NULL);
    
    sfh->directory_offset=convert_offset;    
    saveFile=newFile;
    this->fwriteDirectory();
    
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
  static int last_spawn_location=-1;

void FileManager::loadWorld(NSString* name,BOOL fromArchive){
    
	Terrain* ter=[[World getWorld] terrain];
		[ter clearBlocks];
	Player* player=[[World getWorld] player];
    if(imgHash!=NULL){
        [imgHash release];
        imgHash=NULL;
    }
    [World getWorld].player->reset();
	if(!this->worldExists(name,fromArchive)){
     
        
        extern int g_terrain_type;
        
        printg("making new world : %d\n",g_terrain_type);
        
      //  clear();
        BOOL gen_default=FALSE;
       g_terrain_type=9;
        if(g_terrain_type==0){
            makeDirt();
        }else if(g_terrain_type==1){
           // makeMars();
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
        }else if(g_terrain_type==9){
            gen_default=TRUE;
        }

		this->clearDirectory();
        if(genflat)ter.tgen->LEVEL_SEED= 0;
        else if(gen_default){
           
            
            ter.tgen->LEVEL_SEED=DEFAULT_LEVEL_SEED;
            
        }else{
             ter.tgen->LEVEL_SEED=arc4random()%300000;
            
            
        }
		int centerChunk=4096;
        int r=T_SIZE/CHUNK_SIZE/2;

		ter.level_seed=ter.tgen->LEVEL_SEED;
		
        
        
        
	
		
		Vector temp;
		
        int tempyaw=90;
      
        if(gen_default){
            int spawn_location=arc4random()%10;
            while(spawn_location==last_spawn_location){
                spawn_location=arc4random()%10;
            }
            last_spawn_location=spawn_location;
            int spx[10]={/*64036+(700),*/64736,64629,66370, 66286,64919,65415,64763,64949,64233, 65555};
            int spz[10]={/*64036+(1700),*/65731,66306,65496,66286,64866,66296,66224,64254,64234, 65537};
            int spy[10]={/*25,     */ 22,24,14,22,30, 21,23,22,34,25};
            int spyaw[10]={/*0,    */ -176,-85,1,22,88, 176,-138,91,271,91};
            temp.x=spx[spawn_location];
            temp.z=spz[spawn_location];
            temp.y=spy[spawn_location];
            tempyaw=spyaw[spawn_location];
            
            chunkOffsetX=centerChunk-r;
            chunkOffsetZ=centerChunk-r;
            chunkOffsetX=temp.x/CHUNK_SIZE-T_RADIUS;
            chunkOffsetZ=temp.z/CHUNK_SIZE-T_RADIUS;
            
        }else{
            chunkOffsetX=centerChunk-r;
            chunkOffsetZ=centerChunk-r;
            temp.x=centerChunk*CHUNK_SIZE+CHUNK_SIZE/2;
            temp.z=centerChunk*CHUNK_SIZE+CHUNK_SIZE/2;
            temp.y=T_HEIGHT-10;
        }
        
        
        
        for(int x=centerChunk-r;x<centerChunk+r;x++){
            
            for(int z=centerChunk-r;z<centerChunk+r;z++){
                
                readColumn(x,z,saveFile);
                [World getWorld].terrain.counter++;
            }
        }
        
        
		ter.home=temp;
		Vector temp2;		
		temp2.x=BLOCK_SIZE*(ter.home.x+.5f);
		temp2.y=BLOCK_SIZE*(ter.home.y+1);	
		temp2.z=BLOCK_SIZE*(ter.home.z+.5f);
            player->pos=temp2;
        
        if(ter.tgen->LEVEL_SEED==0){
            temp2.x=BLOCK_SIZE*(ter.home.x+.5f);
            temp2.y=34;
            temp2.z=BLOCK_SIZE*(ter.home.z+.5f);
            player->pos=temp2;
            for(int i=0;i<4;i++){
                for(int j=0;j<4;j++){
                    regionSkyColors[i][j]=COLOR_NORMAL_BLUE;
                }
            }
            printg("sup!!!\n!");
        }else{
            for(int i=0;i<4;i++){
                for(int j=0;j<4;j++){
                    regionSkyColors[i][j]=defaultRegionSkyColors[i][j];
                }
            }
        }
        //(player.pos).y=1;
        
		//printg("player pos init save: %f %f %f",player.pos.x,player.pos.y,player.pos.z);
		//NSLog(@"chunkOffsets: %d %d",chunkOffsetX,chunkOffsetZ);
        player->yaw=tempyaw;
        file_version=2;
		//[ter updateAllImportantChunks];
		
        for(int i=0;i<MAX_CREATURES_SAVED;i++){
            creatureData[i].type=-1;
        }
        
        LoadModels2();
		this->saveWorld();
		//[ter unloadTerrain:FALSE];
		//[self loadWorld:name];
	}else{
              
		NSString* file_name=[NSString stringWithFormat:@"%@/%@",documents,name];
        
        if(fromArchive){
          //  DecompressWorld([file_name cStringUsingEncoding:NSUTF8StringEncoding]);
        }

       
		saveFile=[NSFileHandle fileHandleForUpdatingAtPath:file_name];		
		sfh=(WorldFileHeader*)[[saveFile readDataOfLength:sizeof(WorldFileHeader)] bytes];
        file_version=sfh->version;
        printg("FILE VERSION: %d\n",file_version);
        if(sfh->version<1||sfh->version>1000){  //old legacy convert code, no longer really supported
            [saveFile closeFile];
           
            NSLog(@"converting file");
            convertingWorld=TRUE;
            convertFile(file_name);
            
            NSLog(@"done converting file");
          
            saveFile=[NSFileHandle fileHandleForUpdatingAtPath:file_name];		
            sfh=(WorldFileHeader*)[[saveFile readDataOfLength:sizeof(WorldFileHeader)] bytes];
            convertingWorld=FALSE;
        }
        if(file_version==3){
            file_version=4;
            sfh->version=4;
            sfh->goldencubes=10;
            for(int i=0;i<4;i++){
                for(int j=0;j<4;j++){
                    sfh->skycolors[i*4+j]=COLOR_NORMAL_BLUE;
                }
            }
        }
        if(sfh->hash[32]==0)
            NSLog(@"image hash is %s",sfh->hash);
        if(imgHash!=NULL){
            [imgHash release];
            imgHash=NULL;
        }
        imgHash=[[NSString alloc] initWithCString:sfh->hash encoding:NSUTF8StringEncoding];
		ter.level_seed=sfh->level_seed;
		ter.tgen->LEVEL_SEED=ter.level_seed;
		cur_dir_offset=sfh->directory_offset;
       [World getWorld].hud->goldencubes= sfh->goldencubes;
		ter.home=sfh->home;
		player->pos=sfh->pos;
		player->yaw=sfh->yaw;
         extern Vector colorTable[256];
       /* if(sfh->skycolor<=0||sfh->skycolor>NUM_COLORS){
           [World getWorld].terrain.final_skycolor=colorTable[14];
            printg("skycolor oob setting sky color to beautiful blue\n");
        }else{
             printg("skycolor setting sky color to : %d\n",sfh->skycolor);
        */
       // [World getWorld].terrain.final_skycolor=colorTable[sfh->skycolor];
        
        for(int i=0;i<4;i++){
            for(int j=0;j<4;j++){
                regionSkyColors[i][j]=(int)(sfh->skycolors[i*4+j]);
            }
        }
        

        
        
		this->readDirectory();
		//NSLog(@"indexes: %d",hashmap_length(indexes));
		//NSLog(@"loading level_seed: %d",ter.level_seed);
		//NSLog(@"directory offset: %d entries: %d",(int)sfh->directory_offset,hashmap_length(indexes));
		oldOffsetX=chunkOffsetX;
		oldOffsetZ=chunkOffsetZ;
		
		chunkOffsetX=player->pos.x/CHUNK_SIZE-T_RADIUS;
		chunkOffsetZ=player->pos.z/CHUNK_SIZE-T_RADIUS;
		//NSLog(@"chunkOffsets: %d %d",chunkOffsetX,chunkOffsetZ);
		/*sfh->pos.x-=chunkOffsetX*CHUNK_SIZE;
		sfh->pos.z-=chunkOffsetZ*CHUNK_SIZE;
		sfh->pos.x*=BLOCK_SIZE; 
		sfh->pos.z*=BLOCK_SIZE;
          
		*/player->pos=sfh->pos;
       
        printg("reading at co %d, %d    player pos %d, %d)\n",chunkOffsetX,chunkOffsetZ,(int)player->pos.x,(int)player->pos.z);
        		//NSLog(@"player pos load: %f %f %f",player.pos.x,player.pos.y,player.pos.z);
		int r=T_RADIUS;
	//	int asdf=0;
        
		for(int x=chunkOffsetX;x<chunkOffsetX+2*r;x++){
			for(int z=chunkOffsetZ;z<chunkOffsetZ+2*r;z++){
			//	NSLog(@"lch:%d",asdf++);
				readColumn(x,z,saveFile);
                [World getWorld].terrain.counter++;
			}
		}
        //if(CREATURES_ON)
        this->LoadCreatures();
		//[ter updateAllImportantChunks];
		NSLog(@"done");
		[saveFile closeFile];
        
		
		
	}
    if(!SUPPORTS_OGL2){
        if(ter.tgen->LEVEL_SEED== 0)
            Graphics::setZFAR(55);
       
        else 
         Graphics::setZFAR(40);
    }else{
        if(ter.tgen->LEVEL_SEED== 0)
         Graphics::setZFAR(120);
        else 
        Graphics::setZFAR(120);
    }

    Input::getInput()->clearAll();
    [World getWorld].effects->clearAllEffects();
    [World getWorld].hud->worldLoaded();
	updateSkyColor1([World getWorld].player,TRUE);
    extern BOOL loaded_new_terrain;
    loaded_new_terrain=TRUE;

}

