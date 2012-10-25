//
//  Gamepad.h
//  prototype
//
//  Created by Ari Ronen on 11/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Gamepad : NSObject {
	
	BOOL aleft,aright,afwd,aback;
	CGRect rleft,rright,rfwd,rback;
	
}
- (BOOL)update:(float)etime;
- (void)render;
@end
