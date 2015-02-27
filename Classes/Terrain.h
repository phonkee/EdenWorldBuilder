//
//  Terrain.h
//  prototype
//
//  Created by Ari Ronen on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "Texture2D.h"
#import "Graphics.h"
#import "TerrainChunk.h"
#import "Player.h"
#import "Util.h"
#import "TerrainGenerator.h"
#import "hashmap.h"
#import "Globals.h"
#import "Liquids.h"
#import "Portal.h"
#import "Firework.h"
//#import "Constants.h"
class Player;
class TerrainChunk;
class TerrainGenerator;
class Portal;
class Firework;

#define GBLOCKIDXCLEAN(x,z,y)  ((x+g_offcx)%T_SIZE)*(T_SIZE*T_HEIGHT) + ((z+g_offcz)%T_SIZE)*T_HEIGHT + y
#define GBLOCKIDX(x,z,y) GBLOCKIDXCLEAN((x),(z),(y))
#define GBLOCK(x,z,y) blockarray[GBLOCKIDX(x,z,y)]
#define GBLOCK_SAFE(x,z,y) blockarray[(GBLOCKIDX(x,z,y)+T_BLOCKS)%T_BLOCKS]
#define GBLOCKR(x,z,y) GBLOCK((int)(x),(int)(z),(int)(y))

class Terrain  {
public:
	TerrainGenerator* tgen;
	int n_chunks;
	BOOL loaded;
	Vector home;
	int level_seed;
	int nburn;
    Vector skycolor,final_skycolor;
    TerrainChunk **chunkTable;

	NSString* world_name;
    Liquids* liquids;
    Portal* portals;
    Firework* fireworks;
    int counter;
    
    Terrain();
    ~Terrain();
    void loadTerrain(NSString* name,BOOL fromArchive);
    BOOL update(float etime);
    void setLand(int x,int z,int y,int type, BOOL chunkToo);
    BOOL setColor(int x,int z,int y, color8 color);
    void buildBlock(int x,int z,int y);
    void paintBlock(int x,int z,int y, int color);
    void destroyBlock(int x,int z,int y);
    void burnBlock(int x,int z,int y, BOOL causedByExplosion);
    void updateChunks(int x,int z,int y,int type);
    int getLand(int x,int z,int y);
    int getColor(int x,int z,int y);
    void refreshChunksInRadius(int x,int z,int y,int radius);
    void warpToPoint(float x,float z,float y);
    void blocktntexplode(int x,int z,int y,int type);
    void addToUpdateList(int cx,int cy,int cz);
    void addToUpdateList2(int cx,int cy,int cz);
    void updateAllImportantChunks();
    void prepareAndLoadGeometry();
    void addChunk(TerrainChunk* chunk,int cx,int cy,int cz, BOOL rebuild);
    void render();
    void render2();
    void unloadTerrain(BOOL exitToMenu);
    void warpToHome();
    void clearBlocks();
    void colort(float r,float g,float b);
    void endDynamics(BOOL endLiquids);
    void startDynamics();
    void explodeBlock(int x,int z,int y);
    void allocateMemory();
    void deallocateMemory();
    void shootFirework(int x,int z,int y);
    
    
private:
    void explode(int x,int z,int y);
    void reloadIfNeeded();
};

float getShadow(int x,int z,int y);
float calcLight(int x,int z,int y,float shadow,int coord);
 int getLandc(int x,int z,int y);
 int getLandc2(int x,int z,int y);
int getColorc(int x,int z,int y);
bool isOnFire(int x ,int z, int y);
int getRampType(int x,int z,int y, int t);

//int getCustomc(int x,int z,int y);
/*
@property(nonatomic, assign) NSString* world_name;
@property(nonatomic, assign) Vector home,skycolor,final_skycolor;
@property(nonatomic, assign) BOOL loaded;
@property(nonatomic, assign) int level_seed,counter;

@property(nonatomic,readonly) TerrainChunk** chunkTable;

@property(nonatomic,readonly) TerrainGenerator* tgen;
@property(nonatomic,readonly) Portal* portals;
@property(nonatomic,readonly) Firework* fireworks;*/




