//
//  Portal.h
//  Eden
//
//  Created by Ari Ronen on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>
#import "Util.h"
#import "Terrain.h"
#import "World.h"
#import "Camera.h"
#import "Input.h"
#import "OpenGL_Internal.h"

#define MAX_PORTAL 1000
typedef struct _portal{
    int x,y,z,dir,color;
    
}sportal;

class Portal{
public:
    Portal();
    void addPortal(int x,int y,int z,int dir,int color);
    void paintPortal(int x,int y,int z,int color);
    void removePortal(int x,int y,int z);
    void removeAllPortals();
    Vector2 enterPortal(int x,int y,int z,Vector vel);
private:
   int n_portal;
   sportal portals[MAX_PORTAL];

    
};

