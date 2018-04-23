//
//  EAGLView.m
//  prototype
//
//  Created by Ari Ronen on 10/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "EAGLView.h"
#import "Input.h"
#import "Globals.h"

@interface EAGLView (PrivateMethods)

@end

@implementation EAGLView

@dynamic context;

// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}
extern float P_ZFAR;
//The EAGL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:.
extern float SCREEN_WIDTH; 
extern float SCREEN_HEIGHT;
extern float P_ASPECT_RATIO; 
extern bool IS_IPAD;
extern bool IS_WIDESCREEN;

bool SUPPORTS_OGL2;
extern EAGLView* G_EAGL_VIEW;
/*
 NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
 //Create a shared opengl context so this texture can be shared with main context
 EAGLContext *k_context = [[[EAGLContext alloc]
 initWithAPI:kEAGLRenderingAPIOpenGLES1
 sharegroup:[[[[Director sharedDirector] openGLView] context] sharegroup]] autorelease];
 
 [EAGLContext setCurrentContext:k_context];
 [self doPreloadLevel];
 [autoreleasepool release];
 */
- (id)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];	
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)	{	
        SCALE_WIDTH=2.13333f;
        SCALE_HEIGHT=2.4f;
   
		IS_IPAD=TRUE;
        printg("is ipad");
    }
    else{
        if([[UIScreen mainScreen] respondsToSelector: NSSelectorFromString(@"scale")]&&
        
          [self respondsToSelector: NSSelectorFromString(@"contentScaleFactor")]
           &&[[UIScreen mainScreen] scale]==2)
        {
        IS_IPAD=TRUE;
        IS_RETINA=TRUE;
            SUPPORTS_RETINA=TRUE;
        SCALE_WIDTH=2;
        SCALE_HEIGHT=2;
        }else{
            SUPPORTS_RETINA=TRUE;
            IS_WIDESCREEN=TRUE;

        IS_IPAD=FALSE;
        IS_RETINA=FALSE;
        SCALE_WIDTH=1;
        SCALE_HEIGHT=1;
        }
        
    }
    
	EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (aContext){
		P_ZFAR= 120;
        SUPPORTS_OGL2=TRUE;
	}else{
		P_ZFAR= 20;
        SUPPORTS_OGL2=FALSE;
	}
	[aContext dealloc];
		
		
	if (self)
    {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        //[NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                        nil];
    }
	if(TARGET_IPHONE_SIMULATOR){
	/*UITextField* input_field = [[UITextField alloc] initWithFrame: CGRectMake(1, 1, 1, 1)];
    [input_field becomeFirstResponder];
	[input_field setDelegate:self];
	UIView* invisible_keyboard=[[UIView alloc] init];
	input_field.inputView=invisible_keyboard;
	[self insertSubview: input_field atIndex:0];
	[input_field release];*/
	}
	
   
	/*if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{		
		IS_IPAD=TRUE;
		SCREEN_WIDTH=1024.0f;
		SCREEN_HEIGHT=768.0f;
	}
	else
	{*/
		//1136
    IS_WIDESCREEN =( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.width - ( double )568 ) < DBL_EPSILON );
    if(IS_WIDESCREEN==0){
        IS_WIDESCREEN =( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON );
    }
    printg("is widescreen:%d   check_valeu:%f\n",IS_WIDESCREEN, [[ UIScreen mainScreen ] bounds ].size.width);
    
    
    IS_WIDESCREEN=TRUE;
    
    if(IS_WIDESCREEN)
        SCREEN_WIDTH=IPHONE5_WIDTH;
    else
        SCREEN_WIDTH=IPHONE_WIDTH;
    
        SCREEN_HEIGHT=IPHONE_HEIGHT;
	/*}*/
	
	G_EAGL_VIEW=self;	
	P_ASPECT_RATIO=( (float)IPAD_WIDTH/(float)IPAD_HEIGHT);
    if(IS_WIDESCREEN){
        P_ASPECT_RATIO=(float)SCREEN_WIDTH/SCREEN_HEIGHT;
        
        printf("SW:%f SH:%f  AR:%f  FOV_Y: %f\n",SCREEN_WIDTH,SCREEN_HEIGHT,P_ASPECT_RATIO, P_FOVY);
    }
    
	
	[self setMultipleTouchEnabled:TRUE];
	
	
    return self;
}
- (BOOL)textField:(UITextField *)textField 
		shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
	Input::getInput()->keyTyped(string);
	return FALSE;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	Input::getInput()->touchesBegan(touches,event);
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	Input::getInput()->touchesMoved(touches,event);
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	Input::getInput()->touchesEnded(touches,event);
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
	Input::getInput()->touchesCancelled(touches,event);
	
}
- (BOOL)canBecomeFirstResponder{
	return TRUE;
}

- (void)dealloc
{
    [self deleteFramebuffer];    
    [context release];
    
    [super dealloc];
}

- (EAGLContext *)context
{
    return context;
}

- (void)setContext:(EAGLContext *)newContext
{
    if (context != newContext)
    {
        [self deleteFramebuffer];
        
        [context release];
        context = [newContext retain];
        
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)createFramebuffer
{
    if (context && !defaultFramebuffer)
    {
		
        [EAGLContext setCurrentContext:context];
        if(IS_RETINA)
        [self.layer setContentsScale:2.0f];
        else if(!IS_IPAD)
            if([[UIScreen mainScreen] respondsToSelector: NSSelectorFromString(@"scale")]&&
               
               [self respondsToSelector: NSSelectorFromString(@"contentScaleFactor")]
               )
          [self.layer setContentsScale:1.0f];  
       
        // Create default framebuffer object.
        glGenFramebuffersOES(1, &defaultFramebuffer);
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
        
        // Create color render buffer and allocate backing store.
        glGenRenderbuffersOES(1, &colorRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
        [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer *)self.layer];
        glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &framebufferWidth);
        glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &framebufferHeight);
       
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, colorRenderbuffer);
       
		GLuint depthRenderbuffer;
		glGenRenderbuffersOES(1, &depthRenderbuffer);
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
		glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, framebufferWidth, framebufferHeight);
		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
        printg("framebuffer dimensions %d x %d\n",framebufferWidth,framebufferHeight);
        if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
            NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		
		
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
        
       // printf("glviewport!: %d, %d\n",framebufferWidth,framebufferHeight);
        glViewport(0, 0, framebufferWidth, framebufferHeight);
	
	}
}

- (void)textFieldDidEndEditing:(UITextField*)textField
{
	//NSLog(@"%@",[textField text]);
	//[textField endEditing:YES];
	//[textField removeFromSuperview];
}

- (BOOL)textFieldShouldReturn:(UITextField*)texField
{
	// end editing
	//[texField resignFirstResponder];
	return YES;
}


- (void)deleteFramebuffer
{
    if (context)
    {
        [EAGLContext setCurrentContext:context];
        
        if (defaultFramebuffer)
        {
            glDeleteFramebuffersOES(1, &defaultFramebuffer);
            defaultFramebuffer = 0;
        }
        
        if (colorRenderbuffer)
        {
            glDeleteRenderbuffersOES(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
    }
}

- (void)setFramebuffer
{
    if (context)
    {
        [EAGLContext setCurrentContext:context];
        
        if (!defaultFramebuffer){
            [self createFramebuffer];
        
       
        }
    }
}

- (BOOL)presentFramebuffer
{
    BOOL success = FALSE;
    
    if (context)
    {
        [EAGLContext setCurrentContext:context];
        
        const GLenum discards[]  = {GL_DEPTH_ATTACHMENT_OES};
                // glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
       glDiscardFramebufferEXT(GL_FRAMEBUFFER_OES,1,discards);
        
        success = [context presentRenderbuffer:GL_RENDERBUFFER_OES];
            }
    
    return success;
}

- (void)layoutSubviews
{
    // The framebuffer will be re-created at the beginning of the next setFramebuffer method call.
    [self deleteFramebuffer];
}

@end
