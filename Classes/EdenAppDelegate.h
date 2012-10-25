//
//  prototypeAppDelegate.h
//  prototype
//
//  Created by Ari Ronen on 10/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@class EdenViewController;


@interface EdenAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    EdenViewController *viewController;
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EdenViewController *viewController;


@end

