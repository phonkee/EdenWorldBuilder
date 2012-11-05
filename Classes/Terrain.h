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
@class Player;
@class TerrainChunk;
@class TerrainGenerator;
@class Portal;
@class Firework;


@interface Terrain : NSObject {
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
}
- (void)loadTerrain:(NSString*)name;
- (BOOL)update:(float)etime;
- (void)setLand:(int)x :(int)z :(int)y :(int)type :(BOOL)chunkToo;
- (BOOL)setColor:(int)x :(int)z :(int)y :(color8)color;
- (void)buildBlock:(int)x :(int)z :(int)y;
- (void)buildCustom:(int)x :(int)z :(int)y;
- (void)paintBlock:(int)x :(int)z :(int)y: (int)color;
- (void)destroyBlock:(int)x :(int)z :(int)y;
- (void)burnBlock:(int)x :(int)z :(int)y;
- (void)updateChunks:(int)x :(int)z :(int)y:(int)type;
- (void)updateCustom:(int)x :(int)z :(int)y:(int)type:(int)color;
- (int)getLand:(int)x :(int)z :(int)y;
- (int)getColor:(int)x :(int)z :(int)y;

- (void)addToUpdateList:(int)cx:(int)cy:(int)cz;

- (void)addToUpdateList2:(int)cx:(int)cy:(int)cz;

//- (void)initialGenChunks;
- (void)updateAllImportantChunks;
- (void)chunkBuildingThread:(id)object;

- (void)addChunk:(TerrainChunk*)chunk:(int)cx:(int)cy:(int)cz:(BOOL)rebuild;
//- (void)readdChunk:(TerrainChunk*)chunk:(int)cx:(int)cy:(int)cz;
- (void)render;

-(void)render2;
- (void)unloadTerrain:(BOOL)partial;
- (void)warpToHome;
- (void)destroyBlock:(int)x :(int)z :(int)y;
- (void)clearBlocks;
- (void)colort:(float)r :(float)g :(float)b;
- (void)destroyCustom:(int)x :(int)z :(int)y;
- (void)endDynamics:(BOOL)endLiquids;
- (void)paintCustom:(int)x :(int)z :(int)y :(int)color;
-(void) startLoadingThread;
-(void)startDynamics;

int getShadow(int x,int z,int y);
int getLandc(int x,int z,int y);
int getLandc2(int x,int z,int y);
bool isOnFire(int x ,int z, int y);
int getRampType(int x,int z,int y, int t);
int getCustomc(int x,int z,int y);

@property(nonatomic, assign) NSString* world_name;
@property(nonatomic, assign) Vector home,skycolor,final_skycolor;
@property(nonatomic, assign) BOOL loaded;
@property(nonatomic, assign) int level_seed,counter;

@property(nonatomic,readonly) TerrainChunk** chunkTable;

@property(nonatomic,readonly) TerrainGenerator* tgen;
@property(nonatomic,readonly) Portal* portals;
@property(nonatomic,readonly) Firework* fireworks;
@end



