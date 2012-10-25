//
//  Fire.h
//  prototype
//
//  Created by Ari Ronen on 11/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vector.h"

@interface Fire : NSObject {
	
}
- (BOOL)update: (float)etime;
- (int)addFire:(float)x:(float)z:(float)y:(int)type:(float)life;
- (void)render;
-(void)removeFire:(int)ppid;

-(void)removeNode:(int)idx;
-(void)updateFire:(int)idx:(Vector)pos;
- (void)clearAllEffects;
@end
