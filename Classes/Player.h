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
@class World;

@interface Player : NSObject {
	
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
    Polyhedra pbox;
	int invertcam;
    BOOL inPortal;
    BOOL climbing;
    BOOL inLiquid;
    float flash;
    BOOL onIce;
    BOOL autojump_option;
    //BOOL onIceRamp;
}
- (void)groundPlayer;
- (void)reset;
- (void)horizc;
- (BOOL)vertc;
- (void)processInput:(float)etime;
- (BOOL)update:(float)etime;
- (id)initWithWorld:(World*)world;
- (BOOL)test:(int)x:(int)y:(int)z:(float)r; 
- (void)move:(float)etime;
- (void)render;
- (void)setSpeed:(Vector)svel,float speed;

@property(nonatomic,assign) int invertcam;
@property(nonatomic,assign) Vector pos,vel;
@property(nonatomic,assign) float yaw,pitch,flash;
@property(nonatomic,assign) BOOL move_back,jumping;
@property(nonatomic,assign) BOOL autojump_option;
@property(nonatomic,assign) Polyhedra pbox;

Vector getFlowDirection(int x,int z,int y);

@end