//
//  EAGLView.h
//  prototype
//
//  Created by Ari Ronen on 10/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#ifndef Eden_EAGLView_h
#define Eden_EAGLView_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@class EAGLContext;
// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
@interface EAGLView : UIView <UITextFieldDelegate>
{
@private
    EAGLContext *context;
    
    // The pixel dimensions of the CAEAGLLayer.
    GLint framebufferWidth;
    GLint framebufferHeight;
    
    // The OpenGL ES names for the framebuffer and renderbuffer used to render to this view.
    GLuint defaultFramebuffer, colorRenderbuffer;
}

@property (nonatomic, retain) EAGLContext *context;

- (void)setFramebuffer;
- (BOOL)presentFramebuffer;
- (void)createFramebuffer;
- (void)deleteFramebuffer;

@end

#endif