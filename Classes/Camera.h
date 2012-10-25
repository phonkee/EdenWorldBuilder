//
//  Camera.h
//  prototype
//
//  Created by Ari Ronen on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "Glu.h"
#import "Util.h"

@interface Camera : NSObject {
	float px,py,pz;
	float vx,vy,vz;
	Vector look;
	float yaw,pitch;	
	float speed;
	int mode;
}
@property(nonatomic,assign) float px,py,pz,vx,vy,vz,yaw,pitch,speed;
@property(nonatomic,assign) int mode;
@property(nonatomic,readonly) Vector look;
- (void)reset;
- (BOOL)update:(float)etime;
- (void)render;
- (void)render2;
@end