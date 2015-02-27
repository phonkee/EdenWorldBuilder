//
//  FileManagerHelper.m
//  Eden
//
//  Created by Ari Ronen on 5/20/14.
//
//

#import "FileManagerHelper.h"
#import "FileManager.h"
#import "FileArchive.h"
#import "World.h"
#import "hashmap.h"


FileManager* fm;

//This helper opens up the default world gen and keeps it open, then loads data from it when default world gen chunks are needed.
//All file handles refer to the default world gen, NOT the currently active world, even though the names are the same as FileManager
static NSFileHandle* saveFile;
static WorldFileHeader* sfh;
static map_t indexes;

static void fmh_read_directory();
void fmh_init(FileManager* t_fm){
    if(JUST_TERRAIN_GEN)return;
    
    fm=t_fm;
     //Terrain* ter=[[World getWorld] terrain];
    
     //Player* player=[[World getWorld] player];
    printg("fmh init...\n");
   
    indexes=hashmap_new();
     
 //  NSString* file_name=[NSString stringWithFormat:@"%@/Eden.eden",fm.documents];
    
    NSString* file_name=[[NSBundle mainBundle] pathForResource:@"Eden.eden" ofType:nil];
    
   /*  if(TRUE){
     DecompressWorld([file_name cStringUsingEncoding:NSUTF8StringEncoding]);
     }
     */
    
     saveFile=[NSFileHandle fileHandleForReadingAtPath:file_name];
    [saveFile retain];
     sfh=(WorldFileHeader*)[[saveFile readDataOfLength:sizeof(WorldFileHeader)] bytes];
    //[sfh retain];
    
   
    
    fmh_read_directory();
    
    
    
}
static void fmh_read_directory(){
	
	[saveFile seekToFileOffset:sfh->directory_offset];
	while(TRUE){
		NSData* data=[saveFile readDataOfLength:sizeof(ColumnIndex)];
		if(data==NULL||[data length]<sizeof(ColumnIndex))break;
		
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
void fmh_readColumnFromDefault(int cx,int cz){
    
    
    Terrain* ter=[World getWorld].terrain;
    TerrainChunk* columns[CHUNKS_PER_COLUMN];
    ColumnIndex* colIndex=NULL;
	int n= twoToOne(cx,cz);
	if(n==0){
		NSLog(@"mm");
		return;
	}
  
	hashmap_get(indexes,n, (any_t*)&colIndex);
    
    
	if(colIndex==NULL){
        ter->tgen->generateEmptyColumn(cx,cz);
        return;
     /*   int fcx=cx;
        if(fcx<=4041||fcx>=4150||){
            fcx-=4042;
            
            fcx+=108*1000;
            fcx%=108;
            fcx+=4042;
        }
        int fcz=cz;
        if(fcz<=4041||fcz>=4150){
            fcz-=4042;
            
            fcz+=108*1000;
            fcz%=108;
            fcz+=4042;
        }
        hashmap_get(indexes,twoToOne(fcx,fcz), (any_t)&colIndex);
        */
        
        
        if(colIndex==NULL){
       // printg("col index null at (%d,%d) converted to: (%d,%d) \n",cx, cz, fcx,fcz);
        
        //4150
        //4041
        
        return;
        }
       //
        
        
    }
    
    [saveFile seekToFileOffset:colIndex->chunk_offset];
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
        TerrainChunk* old=ter->chunkTable[threeToOne(cx,cy,cz)];
        if(old){chunk=old;
            chunk->setBounds(bounds);
            
        }
        else{
          //  chunk=new TerrainChunk(bounds,cx,cz,ter,TRUE);
            printf("crittcler error re-allocating terrain chunk\n");
        }
        
        columns[cy]=chunk;
        
        
        BOOL rle=true;
        if(rle){
            
            block8 tblocks[CHUNK_SIZE3];
            color8 tcolors[CHUNK_SIZE3];
            color8 buf[CHUNK_SIZE3*3];
            //too much read
            NSData* datat=[saveFile readDataOfLength:2];
            color8 buft[2];
            [datat getBytes:buft length:2];
            int chunk_data_length= buft[0]*256+buft[1]-2;
            NSData* data=[saveFile readDataOfLength:chunk_data_length];
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
            
            
        }
       
       /* for(int i=0;i<CHUNK_SIZE3;i++){
            if(i%255==0){
                chunk.pblocks[i]=TYPE_BRICK;
                chunk.pcolors[i]=0;
            }else{
                chunk.pblocks[i]=0;
                chunk.pcolors[i]=0;
            }
        }*/
        
        
        extern int g_offcx;
        extern int g_offcz;
        extern block8* blockarray;
        
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
        
        
        ter->addChunk(chunk,cx,cy,cz,TRUE);
        
    }

}


