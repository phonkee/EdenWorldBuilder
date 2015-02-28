//
//  Firework.h
//  Eden
//
//  Created by Ari Ronen on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

//
#ifndef Eden_Firework_h
#define Eden_Firework_h

//#import <Foundation/Foundation.h>

#import "Vector.h"

#define MAX_FIREWORK 80
typedef struct _firework{
    Vector pos;
    int color;
    float fuse;
    Vector vel;
    
}sfirework;


class Firework{
public:
    Firework();
    void addFirework(int x,int y,int z,int color);
    void removeAllFireworks();
    void update(float etime);
    void render();
    void removeFirework(int i);
private:
    int n_firework;
    sfirework fireworks[MAX_FIREWORK];
    float frot;
    
};

#endif