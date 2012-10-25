//
//  Menu_background.h
//  prototype
//
//  Created by Ari Ronen on 1/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Menu_background : NSObject {
CGRect clouds[3];
}
-(void)update:(float)etime;
-(void)render;
@end
