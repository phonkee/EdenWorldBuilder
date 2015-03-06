//
//  Vector.h
//  Eden
//
//  Created by Ari Ronen on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef Eden_Vector_h
#define Eden_Vector_h

#include <OpenGLES/ES1/gl.h>

extern "C" {
struct Vector{
	float    x;
	float    y;
	float    z;
};
typedef struct Vector Vector;
    
}

typedef struct {
	GLubyte    x;
	GLubyte    y;
	GLubyte    z;
}Vector8;
typedef struct {
	float    x;
	float    y;
	float    z;
    float x2;
    float y2;
    float z2;
}Vector2;

typedef struct{
    Vector pos;
    Vector vel;
    float angle;
    int type;
    int color;
    float touched;
    float extra2;
    float extra3;
    Vector extra4;
    
}EntityData;

typedef struct _vertexObject
{
    float position[3];
    float normal[3];
    GLubyte colors[4]; 
	float texs[2];
    
} vertexObject;

#endif
