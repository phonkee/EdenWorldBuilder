//
//  prototypeViewController.m
//  prototype
//
//  Created by Ari Ronen on 10/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "EdenViewController.h"
#import "EAGLView.h"
#import "Globals.h"


@interface EdenViewController ()
@property (nonatomic, retain) EAGLContext *context;
@end

@implementation EdenViewController

@synthesize animating, context;

- (void)awakeFromNib
{
	//[UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeRight;
	
	EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    if (!aContext){
        NSLog(@"Failed to create ES context");	
    }else if (![EAGLContext setCurrentContext:aContext])
        NSLog(@"Failed to set ES context current");
    
	self.context = aContext;
	[aContext release];
	
    [(EAGLView *)self.view setContext:context];
    [(EAGLView *)self.view setFramebuffer];
    unsigned long long memtotal=[NSProcessInfo processInfo].physicalMemory;
    if(memtotal<504572800||(memtotal<654572800&&!SUPPORTS_RETINA)){
        
        LOW_GRAPHICS=TRUE;
        printf("low graphics device\n");
        if(memtotal<314572800){
            printg("low mem device=true\n");
            LOW_MEM_DEVICE=TRUE;
            }else{
                LOW_MEM_DEVICE=FALSE;
            }
    }else LOW_GRAPHICS=FALSE;
    printg("mem total: %llu\n",memtotal);
    
    
    world=new World();
    
    animating = FALSE;
    displayLinkSupported = FALSE;
    animationFrameInterval = 1;
    displayLink = nil;
    animationTimer = nil;
    
    // Use of CADisplayLink requires iOS version 3.1 or greater.
	// The NSTimer object is used as fallback when it isn't available.
    NSString *reqSysVer = @"3.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
        displayLinkSupported = TRUE;
	
	//NSLog(@"%@",[vc_settings view]);
	//[viewController setView:[vc_settings view]];
	

}

- (void)dealloc
{   
    delete world;
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    
    [context release];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self startAnimation];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopAnimation];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
	[super viewDidUnload];    

    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	self.context = nil;	
}

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    /*
	 Frame interval defines how many display frames must pass between each time the display link fires.
	 The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
	 */
    if (frameInterval >= 1)
    {
        animationFrameInterval = frameInterval;
        
        if (animating)
        {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!animating)
    {
		start = [NSDate date];		
		[start retain];
		last=-[start timeIntervalSinceNow];
        //NSLog(@"hi");

		

        if (displayLinkSupported)
        {
            /*
			 CADisplayLink is API new in iOS 3.1. Compiling against earlier versions will result in a warning, but can be dismissed if the system version runtime check for CADisplayLink exists in -awakeFromNib. The runtime check ensures this code will not be called in system versions earlier than 3.1.
            */
            displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawFrame)];
            [displayLink setFrameInterval:animationFrameInterval];
            
            // The run loop will retain the display link on add.
            [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
        else
            animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(drawFrame) userInfo:nil repeats:TRUE];
        
        animating = TRUE;
    }
}

- (void)stopAnimation
{
    if (animating)
    {
        if (displayLinkSupported)
        {
            [displayLink invalidate];
            displayLink = nil;
        }
        else
        {
            [animationTimer invalidate];
            animationTimer = nil;
        }
        
        animating = FALSE;
    }
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation

{
    return (interfaceOrientation != UIInterfaceOrientationPortrait && interfaceOrientation !=UIInterfaceOrientationPortraitUpsideDown);
}

- (void)drawFrame
{
	

	now=-[start timeIntervalSinceNow];
      
    BOOL retinaSwap=FALSE;
	float etime=(float)(now-last);
	last=now;	
    [(EAGLView *)self.view setFramebuffer];
	 NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    if(world->update(etime)){
        retinaSwap=TRUE;
    }
	world->render();
	[pool release];
    
    
    [(EAGLView *)self.view presentFramebuffer];
    if(retinaSwap){
       // printg("sup\n");
    if(IS_RETINA){
        [(EAGLView *)self.view deleteFramebuffer];
        
        IS_IPAD=FALSE;
        IS_RETINA=FALSE;
        SCALE_WIDTH=1;
        SCALE_HEIGHT=1;
        [(EAGLView *)self.view createFramebuffer];
    }else{
        [(EAGLView *)self.view deleteFramebuffer];
        
        IS_IPAD=TRUE;
        IS_RETINA=TRUE;
        SCALE_WIDTH=2;
        SCALE_HEIGHT=2;
        [(EAGLView *)self.view createFramebuffer];

    }
    }
	
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}






@end
