//
//  World.h
//  prototype
//
//  Created by Ari Ronen on 10/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "Texture2D.h"
#import "Terrain.h"
#import "Graphics.h"
#import "Camera.h"
#import "Resources.h"
#import "Player.h"
#import "Hud.h"
#import "Menu.h"
#import "FileManager.h"
#import "SpecialEffects.h"
class FileManager;
class Player;
class Terrain;
class Hud;
class Menu;
#define GAME_MODE_MENU 0
#define GAME_MODE_WAIT 2
#define GAME_MODE_PLAY 1
#define JUST_TERRAIN_GEN 0
@interface World : NSObject {
	Terrain* terrain;
	Camera* cam;
	Resources* res;
	Player* player;
	Hud* hud;
	Menu* menu;
	FileManager* fm;
	SpecialEffects* effects;
    int target_game_mode;
	int game_mode;
	//BOOL FLIPPED;
    int doneLoading;
    float realtime;
    BOOL bestGraphics;
    BOOL sanityCheck;
   
   
    
}
- (World*)init;
+ (World*)getWorld;
- (BOOL)update: (float)etime;
- (void)loadWorld:(NSString*)name;
- (void)render;
- (void)exitToMenu;
- (void)loadWorldThread:(id)object;
//- (void)reloadWorld:(NSString*)name :(int)callback;

@property (nonatomic, assign) float realtime;
@property (nonatomic, assign) BOOL bestGraphics;
@property (nonatomic, readonly) Terrain* terrain;
@property (nonatomic, readonly) Camera* cam;
@property (nonatomic, readonly) Player* player;
@property (nonatomic, readonly) Hud* hud;
@property (nonatomic, readonly) FileManager* fm;
@property (nonatomic, readonly) SpecialEffects* effects;
@property (nonatomic, readonly) Menu* menu;
@property (nonatomic, readonly) int game_mode;
@property (nonatomic, readonly) BOOL FLIPPED;
@property (nonatomic, readonly) NSLock* sf_lock,*rebuild_lock;

@end
