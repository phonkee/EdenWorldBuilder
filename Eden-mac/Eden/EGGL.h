//
//  EGGL.h
//  Eden-mac
//
//  Created by Ari Ronen on 10/20/12.
//
//



#ifndef Eden_mac_EGGL_h
#define Eden_mac_EGGL_h
#ifndef EGGL_H_
#define EGGL_H_

#include <OpenGL/gltypes.h>

#if defined(__APPLE__)

/* Apple OS X / iPhone OS */
#include <Availability.h>

#if TARGET_OS_IPHONE
/* iPhone OS */
#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES1/glext.h>
typedef double GLdouble;
#include "glu.h"
//#include "ug.h"

#elif TARGET_OS_MAC

/* Mac OS X */

#include <OpenGL/gl.h>
#include <OpenGL/glext.h>
#include <GLUT/glut.h>
#include <OpenGL/gltypes.h>

#include <OpenGL/glu.h>

#endif

#elif ANDROID

/* Android */
#include <GLES/gl.h>
#include <GLES/glext.h>
typedef double GLdouble;
#include "glu.h"
#include "ug.h"

#elif defined(__unix__) || defined(__linux__)

/* Linux/Unix */
#define GL_GLEXT_PROTOTYPES
#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/glut.h>

#elif defined(WIN32)

/* Windows */
#include "GLee.h"
#include <GL/glut.h>

#endif

#if defined (_WIN32)
#define GLU_CALLBACK (GLvoid (__stdcall *) ())
#else
#define GLU_CALLBACK (GLvoid(*)())
#endif

#endif


#endif
