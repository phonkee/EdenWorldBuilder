//
//  Globals.h
//  prototype
//
//  Created by Ari Ronen on 10/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"


//#define SCALE_WIDTH 2.0f
//#define SCALE_HEIGHT 2.0f

extern float SCALE_WIDTH;
extern float SCALE_HEIGHT;
typedef signed char block8;
typedef unsigned char color8;
typedef unsigned char ubyte;
typedef signed char sbyte;



extern float P_ZFAR;
//The EAGL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:.
extern float SCREEN_WIDTH; 
extern float SCREEN_HEIGHT;
extern float P_ASPECT_RATIO; 
extern bool IS_IPAD;
extern bool IS_RETINA;
extern bool SUPPORTS_RETINA;
extern bool CREATURES_ON;
extern bool LOW_MEM_DEVICE;
extern bool LOW_GRAPHICS;



extern const int blockTypeFaces[NUM_BLOCKS+1][6];
extern const GLubyte blockColor[NUM_BLOCKS+1][3];
extern const int blockinfo[NUM_BLOCKS+1];



#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)