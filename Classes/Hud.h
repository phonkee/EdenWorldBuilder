//
//  Hud.h
//  prototype
//
//  Created by Ari Ronen on 10/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Input.h"
#import "Util.h"
#import "glu.h"
#import "Terrain.h"
#import "Graphics.h"
#import "World.h"
#import "Gamepad.h"
#import "Joystick.h"
#import "statusbar.h"
#import "Globals.h"
#define MODE_CAMERA 0
#define MODE_PICK_BLOCK 1
#define MODE_BUILD 2
#define MODE_MINE 3
#define MODE_BURN 4
#define MODE_PAINT 5
#define MODE_PICK_COLOR 6
#define MODE_NONE -1


#define NUM_DISPLAY_BLOCKS 35
#define NUM_COLORS (6*9)
@interface Hud : NSObject <UIAlertViewDelegate> {
	int fps;
	int fpsc;
	int mode;
	float test_a;
	BOOL hideui, take_screenshot;
    BOOL underLiquid;
    BOOL inmenu;
    BOOL heartbeat;
    int justLoaded;
	int blocktype;
    int block_paintcolor;
    int holding_creature;
    int creature_color;
    int goldencubes;
    int build_size;
	float flash;
    float fade_out;
    Vector flashcolor;
    int pressed;
	
    Button rburn,rmine,rbuild,rjumphit,rjumprender,rpaint;
    
    Button rcam,rexit,rsave,rhome,rmenu;
    
	int leftymode;
	//Gamepad* gamepad;
	Joystick* joystick;
	statusbar* sb;
    CGRect rpaintframe;
    CGRect rmenuframe;
    Button rtSave,rtHome,rtCam,rtExit;
    
    float var1,var2,var3;
	CGRect blockBounds[NUM_DISPLAY_BLOCKS];
	Texture2D* blockIcons[NUM_DISPLAY_BLOCKS];
    CGRect colorBounds[NUM_COLORS];
    //Vector hudColor[NUM_COLORS];
    color8 paintColor;
    Vector liquidColor;
	//Texture2D* colorIcons[NUM_COLORS];
	float ttime;
	int use_joystick;
}

@property(nonatomic,readonly) int fps;
@property(nonatomic,assign) BOOL m_jump,m_left,m_right,m_fwd,m_back,m_joy,underLiquid,heartbeat;
@property(nonatomic,assign) int mode,build_size;
@property(nonatomic,assign) int leftymode;
@property(nonatomic,assign) int blocktype,block_paintcolor,creature_color;
@property(nonatomic,readonly) color8 paintColor;
@property(nonatomic,assign) Vector liquidColor,flashcolor;
@property(nonatomic,assign) float flash,var1,var2,var3,fade_out;
@property(nonatomic,readonly) float test_a;
@property(nonatomic,assign) BOOL hideui;
@property(nonatomic,readonly) statusbar* sb;
@property(nonatomic,assign) int use_joystick,justLoaded;
@property(nonatomic,assign) BOOL take_screenshot,inmenu;
@property(nonatomic,assign) int holding_creature,goldencubes;
- (BOOL)handlePickBlock:(int)x:(int)y;
- (BOOL)handlePickColor:(int)x:(int)y;
- (BOOL)handlePickMenu:(int)x:(int)y;
- (void)worldLoaded;
- (BOOL)update:(float)etime;
- (void)render;
+(void)genColorTable;
@end
