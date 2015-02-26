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

class TerrainChunk {
	
public:
	
	//block8 blocks[CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE];
    
    block8* blocks;
    block8 blocks1[CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE];
    //block8 blocks2[CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE];
    color8 colors[CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE];
    //float lightsf[CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE];
    
    block8* pblocks;
  //  block8* pblocks2;
    color8* pcolors;
   // SmallBlock* sblocks[CHUNK_SIZE*CHUNK_SIZE*CHUNK_SIZE];
   // SmallBlock** psblocks;
    
    
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
    int rebuildCounter;
    
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
    BOOL has_light;
    BOOL modified;
    int isTesting;
    GLuint query
    ;
	GLuint    vertexBuffer,vertexBuffer2,elementBuffer;
   // BOOL needsRebuild;

	int bounds[6];
    int rtbounds[6];
	float rbounds[6];	
    int* pbounds;
    float* prbounds;
    
    TerrainChunk(const int* boundz,int rcx,int rcy,Terrain* terrain);
    TerrainChunk(const int* boundz,int rcx,int rcy,Terrain* terrain,BOOL genblocks);
    ~TerrainChunk();
    int getLand(int x,int z,int y);
    void setLand(int x,int z,int y,int type);
    void resetForReuse();
    int rebuild2();
    void setBounds(int* boundz);
    void clearMeshes();
    int render();
    void render2();
    void unbuild();
    void prepareVBO();
};

typedef struct bnode{
	int x,y,z;
	float time;	
	float life;
	int pid;
	int sid;
	int type;
	struct bnode* next;
}BurnNode;


void tc_initGeometry();



