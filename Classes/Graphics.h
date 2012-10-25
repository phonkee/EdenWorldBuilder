//
//  Graphics.h
//  prototype
//
//  Created by Ari Ronen on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "Texture2D.h"
#import "glu.h"
#import "Resources.h"


@interface Graphics : NSObject {

}
+(void)setZFAR:(float)zfar;
+ (void)initGraphics;
+ (void)drawText:(NSString*)text :(float)x :(float)y;
+ (void)drawRect:(float)x1 :(float)y1 :(float)x2 :(float)y2;
+ (void)drawRectOutline:(CGRect)rect;
+ (void)prepareScene;
+ (void)prepareMenu;
+ (void)endMenu;
+ (void)setLighting;
+ (void)drawTexCube:(float)x :(float)y :(float)z :(float)len :(Texture2D*)tex;
+ (void)drawFirework:(float)x :(float)y :(float)z :(int) color :(float) scale: (float) rot;
+ (void)drawCube:(float)x :(float)y :(float)z :(int)type :(int)buildsize;
+ (void)startPreview;
+ (void)endPreview;
+ (void)setPerspective;
+ (void)beginTerrain;
+ (void)endTerrain;
+ (void)beginHud;
+ (void)drawSkybox;
+ (void)drawTexCubep:(float)x :(float)y :(float)z :(float)len :(Texture2D*)tex;
+ (void)endHud;
@end

typedef struct _vertexStruct
{
    float position[3];
    float normal[3];
    GLubyte colors[4];  
	float texs[2];
	  
} vertexStruct;

typedef struct _vertexStructSmall
{
    GLshort position[3];
    GLshort pad;
    GLubyte colors[4];  
	GLshort texs[2];
	  
} vertexStructSmall;

typedef struct _vertexpStruct
{
    float position[3];
    GLubyte colors[4]; 
    float size[1];
	    
} vertexpStruct;

typedef struct _vertexpBreak
{
    float position[3];
    float normal[3];
    GLubyte colors[4]; 
	GLshort texs[2];
	    
} vertexpBreak;


