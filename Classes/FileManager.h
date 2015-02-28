//
//  FileManager.h
//  prototype
//
//  Created by Ari Ronen on 10/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#ifndef Eden_FileManager_h
#define Eden_FileManager_h

#import <Foundation/Foundation.h>
#import "Terrain.h"



#define FILE_VERSION 4
#define SIZEOF_COLUMN CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE*CHUNKS_PER_COLUMN*(sizeof(block8)+sizeof(color8))


typedef struct{
	int level_seed;
	Vector pos;
	Vector home;
	float yaw;
	unsigned long long directory_offset;
	char name[50];
    
    //below here is post 1.1.1 stuff
    int version;
    char hash[36];
    unsigned char skycolors[16];
    int goldencubes;
	char reserved[100-sizeof(int)-36-16-sizeof(int)];	 //subtract new stuff from reserve bytes,
    //192 bytes(including padding is the correct size, be careful modifying this to not corrupt old maps
}WorldFileHeader;
typedef struct{
	int x, z;
	unsigned long long chunk_offset;
}ColumnIndex;
typedef struct{
	int n_vertices;
	
}ChunkHeader;

class FileManager {
public:
    int chunkOffsetX;
    int chunkOffsetZ;
    
    NSString* documents;
    BOOL convertingWorld;
    BOOL genflat;
    FileManager();
    BOOL worldExists(NSString* name,BOOL appendArchive);
    void saveColumn(int cx,int cz);
    void saveGenColumn(int cx,int cz,int origin);
    void readColumn(int cx,int cz,NSFileHandle* nsfh);
    void saveWorld();
    void saveWorld(Vector warp);
    void loadGenFromDisk();
    void writeGenToDisk();
    void fwriteDirectory();
    void readDirectory();
    void clearDirectory();
    void compressLastPlayed();
    void convertFile(NSString* file_name);
    NSString* getName(NSString* file_name);
    void setName(NSString* file_name,NSString* display_name);
    void setImageHash(NSString* hash);
    void loadWorld(NSString* name,BOOL fromArchive);
    BOOL deleteWorld(NSString* name);
    
private:
    int oldOffsetX;
    int oldOffsetZ;
    void LoadCreatures();
    void saveCreatures();
};

#endif