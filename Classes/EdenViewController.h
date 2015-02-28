//
//  prototypeViewController.h
//  prototype
//
//  Created by Ari Ronen on 10/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#ifndef Eden_ViewController_h
#define Eden_ViewController_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "World.h"

@interface EdenViewController : UIViewController
{
    EAGLContext *context;
       
	    BOOL animating;
    BOOL displayLinkSupported;
    NSInteger animationFrameInterval;
	World *world; 

	NSDate *start;
	NSTimeInterval last,now;
    
    /*
	 Use of the CADisplayLink class is the preferred method for controlling your animation timing.
	 CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.
	 The NSTimer object is used only as fallback when running on a pre-3.1 device where CADisplayLink isn't available.
	 */
    id displayLink;
    NSTimer *animationTimer;	
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

- (void)startAnimation;
- (void)stopAnimation;


@end

#endif