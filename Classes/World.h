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
class World{
public:
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
    
    World();
    ~World();
    static World* getWorld;
    BOOL update(float etime);
    void loadWorld(NSString* name);
    void render();
    void exitToMenu();
    
    
};

