//
//  prototypeAppDelegate.m
//  prototype
//
//  Created by Ari Ronen on 10/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EdenAppDelegate.h"
#import "EdenViewController.h"
#import "Flurry.h"
#import "Appirater.h"
//#import "TestFlight.h"

@implementation EdenAppDelegate

@synthesize window;
@synthesize viewController;

/*void uncaughtExceptionHandler(NSException *exception) {
   // [FlurryAPI logError:@"Uncaught" message:@"Crash!" exception:exception];
}*/
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions { 

    // [TestFlight takeOff:@"04fc0d12-af7e-44ca-852f-bad7a896ba6c"];
	
    // Override point for customization after app launch.
    // Add your cool controller's view to the window.
   // [window addSubview:viewController.view];
    [self.window setRootViewController:viewController];
    [window makeKeyAndVisible];
	//NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	[Flurry startSession:@"LUWB9P4UZU1K1A4YUT9V"];
    
    [Appirater appLaunched:YES];
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    [viewController stopAnimation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	
    [viewController startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [viewController stopAnimation];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Handle any background procedures not related to animation here.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [Appirater appEnteredForeground:YES];
    // Handle any foreground procedures not related to animation here.
}

- (void)dealloc
{
    [viewController release];
    [window release];
    
    [super dealloc];
}

@end
