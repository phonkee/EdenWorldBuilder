//
//  BlockBreak.h
//  prototype
//
//  Created by Ari Ronen on 11/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BlockBreak : NSObject {
	
}
- (int)update: (float)etime;
- (void)addBlockBreak:(int)x:(int)z:(int)y:(int)type:(int)color;
- (void)render;
- (void)removeNode:(int)idx;
- (void)clearAllEffects;
- (void)addBlockExplode:(int)x:(int)z:(int)y:(int)type:(int)color;
- (void)addCreatureVanish2:(float)x:(float)z:(float)y:(int)color:(int)type;
- (void)addFirework:(float)x:(float)z:(float)y:(int)color;
@end
