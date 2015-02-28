//
//  Player.h
//  prototype
//
//  Created by Ari Ronen on 10/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>
#import "Util.h"
#import "Terrain.h"
#import "World.h"
#import "Camera.h"
#import "Input.h"
#import "OpenGL_Internal.h"
class World;

class Player {
public:
	float boxbase;
	float boxheight;
    float max_walk_speed;
	Vector pos,lpos,vel,accel;
    Vector walk_force;
	float yaw,pitch;	
	float speed,hspeed,vspeed;	
	BOOL move_back;
	BOOL jumping;
    BOOL doublejump;
	World* world;
    
	int invertcam;
    BOOL inPortal;
    BOOL climbing;
    BOOL inLiquid;
    float flash;
    BOOL onIce;
    BOOL dead;
    BOOL autojump_option;
    BOOL health_option;
    float life;
    
    void groundPlayer();
    void reset();
    void horizc();
    BOOL preupdate(float etime);
    BOOL vertc();
    void processInput(float etime);
    BOOL update(float etime);
    Player(World* world);
    BOOL test(int x,int y,int z,float r);
    void move(float etime);
    void takeDamage(float damage);
    void render();
    void setSpeed(Vector svel,float speed);
    BOOL checkCollision();
    Vector lol[50];
    
    Vector lol1[50];
   // Polyhedra testbox;
    Vector lol2[50];
};


Vector getFlowDirection(int x,int z,int y);

