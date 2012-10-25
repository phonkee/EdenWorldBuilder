//
//  Clouds.h
//  prototype
//
//  Created by Ari Ronen on 11/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Clouds : NSObject {

}
- (BOOL)update: (float)etime;
- (void)initClouds;
- (void)render;
- (void)freeClouds;
@end
