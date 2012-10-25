//
//  Input.h
//  prototype
//
//  Created by Ari Ronen on 10/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Util.h"
typedef struct{
	int mx,my;
	int pmx,pmy;
	int fx,fy;
	int inuse;
	int down;
	int moved;	
	BOOL movecam;
	int previewtype;
	Point3D preview;
	BOOL placeBlock;
	UITouch* touch_id;
	float etime;
   
    float scalex;
    float scaley;
    int build_size;
}itouch;
#define MAX_TOUCHES 5
enum MSTATE {
	M_DOWN=1,
	M_RELEASE=2,
	M_NONE=0
};

@interface Input : NSObject {
	itouch touches[MAX_TOUCHES];
    int scr_width;
    int scr_height;
}

+ (Input*)getInput;
- (itouch*) getTouches;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)keyTyped:(NSString*) key;
- (void)clearAll;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@end
//@property (nonatomic, retain) EAGLContext *context;