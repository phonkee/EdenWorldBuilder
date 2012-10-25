//
//  TerrainGenerator.h
//  prototype
//
//  Created by Ari Ronen on 10/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Terrain.h"

@interface TerrainGenerator : NSObject {
	int LEVEL_SEED;
    bool genCaves;
}
- (id)init:(Terrain*)parent;
- (void)generateColumn:(int)x:(int)z:(BOOL)bgthread;
- (void)generateCloud;
- (void)placeTree:(int)x :(int)z :(int)y;

@property(nonatomic,assign) int LEVEL_SEED;
@property(nonatomic,assign) bool genCaves;
@end
