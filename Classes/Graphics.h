//
//  Graphics.h
//  prototype
//
//  Created by Ari Ronen on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#ifndef Eden_Graphics_h
#define Eden_Graphics_h


#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "Texture2D.h"
#import "glu.h"
#import "Resources.h"


class Graphics{
public:
    static void setZFAR(float zfar);
    static void setCameraFog(float zfar);
    static void initGraphics();
    //static void drawText(NSString* text,float x,float y);
    static void drawRect(float x1,float y1,float x2,float y2);
    static void drawRectOutline(CGRect rect);
    static void prepareScene();
    static void prepareMenu();
    static void endMenu();
    static void setLighting();
    static void drawTexCube(float x,float y,float z,float len, Texture2D* tex);
    static void drawFirework(float x,float y,float z, int color, float scale,float rot);
    static void drawCube(float x,float y,float z,int type,int buildsize);
    static void startPreview();
    static void endPreview();
    static void setPerspective();
    static void beginTerrain();
    static void endTerrain();
    static void beginHud();
    static void drawSkybox();
    
    static void drawTexCubep(float x,float y,float z,float len, Texture2D* tex);
    static void endHud();
    
};



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

#endif
