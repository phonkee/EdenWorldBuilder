//
//  Liquids.h
//  Eden
//
//  Created by Ari Ronen on 7/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#ifndef Eden_Liquids_h
#define Eden_Liquids_h


#import <Foundation/Foundation.h>
#import "hashmap.h"
#import "Globals.h"


typedef struct wnode{
	int x,y,z;
    
    int spread;
	int feeders;	
	int flowType;
    block8 blockType;
    color8 color;
    int max;
    int flow;
    int heights[4];	
}WetNode;

typedef struct _pnode{
	int x,y,z;
   
	struct _pnode* next;
    struct _pnode* prev;
}PNode;

typedef struct _pnode2{
	int x,y,z;
    int type;
    int level;
    
	struct _pnode2* next;
    struct _pnode2* prev;
}PNode2;

class Liquids{
public:
    Liquids();
    BOOL update(float etime);
    void render();
    void clearLiquids();
    void addSource(int x,int z,int y);
    void removeSource(int x,int z,int y,int type);
    
};

int getLevel(int type);
int getBaseType(int type);
int genLevel(int type,int level);

#endif
