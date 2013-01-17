//
//  TerrainChunk.h
//  prototype
//
//  Created by Ari Ronen on 10/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "Terrain.h"
#import "glu.h"
#import "Resources.h"
#import "Util.h"
#import "Globals.h"

@class Terrain;
typedef struct _static_object{
    Vector pos;
    int type;
    int ani;
    int dir;
    BOOL open;
    color8 color;
    float rot;
}StaticObject;

typedef struct _small_block{
    block8 blocks[8];
    color8 colors[8];
    
}SmallBlock;
#define CC(x,z,y) ((int)(x)*(CHUNK_SIZE*CHUNK_SIZE)+(int)(z)*(CHUNK_SIZE)+(int)(y))

@interface TerrainChunk : NSObject {
	
	
	//block8 blocks[CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE];
    
    block8* blocks;
    block8 blocks1[CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE];
    block8 blocks2[CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE];
    color8 colors[CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE];
    float lightsf[CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE];
    
    block8* pblocks;
    color8* pcolors;
    SmallBlock* sblocks[CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE];
    SmallBlock** psblocks;
    
    
    vertexStructSmall* verticesbg;
    vertexStructSmall* verticesbg2;
    
    unsigned short* indices;
    unsigned short* rtindices;
    	int rcx,rcz;
    BOOL loaded;
    StaticObject* objects;
     StaticObject* rtobjects;
     int num_objects;
	int n_vertices,n_vertices2;
    int num_vertices[7];
    int face_idx[7];
    int num_vertices2[7];
    int face_idx2[7];
    bool visibleFaces[7];
    int vis_vertices;
    
    int idxn;
    int rtnum_objects;
	int rtn_vertices,rtn_vertices2;
    int rtnum_vertices[7];
    int rtface_idx[7];
    int rtnum_vertices2[7];
    int rtface_idx2[7];
    bool rtvisibleFaces[7];
    int rtvis_vertices;
    TreeNode* m_treenode;
	ListNode* m_listnode;
    BOOL needsGen;
    BOOL needsVBO;
    BOOL clearOldVerticesOnly;
    
    BOOL in_view;
    int isTesting;
    GLuint query
    ;
	GLuint    vertexBuffer,vertexBuffer2,elementBuffer;
    BOOL needsRebuild;
@public
	int bounds[6];
    int rtbounds[6];
	float rbounds[6];	
    int* pbounds;
    float* prbounds;
}
typedef struct bnode{
	int x,y,z;
	float time;	
	float life;
	int pid;
	int sid;
	int type;
	struct bnode* next;
}BurnNode;
@property(nonatomic,assign) BOOL needsRebuild,needsGen,loaded,in_view;
@property(nonatomic,readonly) int* pbounds;
@property(nonatomic,assign) block8* pblocks;
@property(nonatomic,assign) color8* pcolors;

@property(nonatomic,readonly) SmallBlock** psblocks;

@property(nonatomic,assign) StaticObject* rtobjects;
@property(nonatomic,assign) int idxn;
@property(nonatomic,readonly) int rtn_vertices,rtn_vertices2,rtnum_objects;
@property(nonatomic,readonly) float* prbounds;
@property(nonatomic,assign) TreeNode* m_treenode;
@property(nonatomic,assign) ListNode* m_listnode;


- (id)init:(const int*)boundz:(int)rcx:(int)rcy:(Terrain*)terrain;
- (id)initWithBlocks:(const int*)boundz:(int)rcx:(int)rcy:(Terrain*)terrain:(BOOL)genblocks;
- (int)getLand:(int)x:(int)z:(int)y;
- (void)setLand:(int)x:(int)z:(int)y:(int)type;
-(void) resetForReuse;

- (int)getCustom:(int)x:(int)z:(int)y;
- (int)getCustomColor:(int)x:(int)z:(int)y;
- (int) setCustom:(int)x:(int)z:(int)y:(int)type:(int)color;
- (int)rebuild2;
-(void)setBounds:(int*) boundz;
- (void)clearMeshes;
- (int)render;
- (void)render2;

-(void) unbuild;
- (void)prepareVBO;

void tc_initGeometry();

@end

