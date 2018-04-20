//
//  Input.h
//  prototype
//
//  Created by Ari Ronen on 10/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#ifndef Eden_Input_h
#define Eden_Input_h



#import "Util.h"
#import "Autosave.h"



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

class Input{
public:
    Input();
    itouch touches[MAX_TOUCHES];
    int scr_width;
    int scr_height;
    static Input* getInput();
    itouch* getTouches();
    void touchesBegan(NSSet* touches,UIEvent* event);
    void touchesMoved(NSSet* touches,UIEvent* event);
    void touchesEnded(NSSet* touches,UIEvent* event);
    void keyTyped(NSString* key);
    void clearAll();
    void touchesCancelled(NSSet* touches,UIEvent* event);
    
};

#endif

