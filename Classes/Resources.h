//
//  Resources.h
//  prototype
//
//  Created by Ari Ronen on 10/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#ifndef Eden_Resources_h
#define Eden_Resources_h



#import "Texture2D.h"
#import <UIKit/UIKit.h>
#import "Sound.h"
#import "Vector.h"
#include <vector>
#define MAX_SOURCES 10
class Resources {
public:
    static Resources *getResources;
    
	Texture2D* atlas;
    Texture2D* atlas2;
    Texture2D* csbkg;
    
    std::vector<Texture2D*> textures;
	std::vector<Texture2D*> menutextures;
	Sound* sound;
	float burnSoundTimer,playing;
	int playmusic,playsound;
	int burn_id;
	float landingEffectTimer;
	
    Resources();
    ~Resources();
    CGPoint getBlockTex(int type);
    Texture2D* getTex(int idx);
    //Texture2D* getPaintedTex(int color);
    Texture2D* getMenuTex(int idx);
    int getSkin(int model_type,int color,int state);
    int playSound(int soundid);
    int startedBurn(float length);
    void endBurnId(int idx);
    void stopSound(int soundId);
    void endBurn();
    CGPoint getBlockTexShort(int type);
    void loadMenuTextures();
    void unloadMenuTextures();
    void loadGameAssets();
    void unloadGameAssets();
    void update(float etime);
    void playMenuTune();
    void stopMenuTune();
    void soundEvent(int actionid);
    void soundEvent(int actionid,Vector location);
    int getDoorTex(int color);
    Texture2D* getPaintTex(int color);
    Texture2D* getPaintedTex(int type,int color);
    void voSound(int action,int type,Vector location);
    //static Resources* getResources();
    
private:
    void unloadGameTextures();
    void loadGameTextures();
};
//@property(nonatomic, readonly) Texture2D* atlas,*atlas2;
//@property(nonatomic, assign) int playmusic,playsound;


#define NUM_AMBIENT 17
#define AMBIENT_NONE -1
#define AMBIENT_UNDERWATER 0
#define AMBIENT_RIVER 1
#define AMBIENT_LAVA 2
#define AMBIENT_SKYHIGH 3
#define AMBIENT_CAVE 4
#define AMBIENT_OPEN 5
#define AMBIENT_GRASSLANDS 6
#define AMBIENT_BEACH 7
#define AMBIENT_GRASSBADLANDS 8
#define AMBIENT_MARSHBADLANDS 9
#define AMBIENT_RIVERLANDS 10
#define AMBIENT_PYRAMID 11
#define AMBIENT_OASIS 12
#define AMBIENT_NIGHT 13
#define AMBIENT_MOUNTAIN 14
#define AMBIENT_LAVABADLANDS 15
#define AMBIENT_SNOWMOUNTAIN 16



#define NUM_VO_ACTIONS 10

#define VO_WALKING 9
#define VO_STRETCHING 1
#define VO_SCARED 2
#define VO_RELIEVED 3
#define VO_APPROACH 4
#define VO_ONFIRE 5
#define VO_IDLE 6
#define VO_HIT 7
#define VO_EXCITED 8
#define VO_ANGRY 0

#define NUM_SOUNDS 53

enum SOUND_TYPES{
    S_LADDER=0,
    S_VINE=1,
    S_BOUNCE=2,
    S_LAND_SOFT=3,
    S_LAND_HARD=4,
    S_PAINT_BLOCK=5,
    S_LAVA_BURN=6,
    S_ICE_LOOP=7,
    S_EXPLODE=8,
    S_BUILD_WOOD=9,
    S_BUILD_WATER=10,
    S_BUILD_STONE=11,
    S_BUILD_LEAVES=12,
    S_BUILD_LAVA=13,
    S_BUILD_GLASS=14,
    S_BUILD_DIRT=15,
    S_BUILD_GENERIC=16,
    S_BREAK_WOOD=17,
    S_BREAK_WATER=18,
    S_BREAK_STONE=19,
    S_BREAK_LEAVES=20,
    S_BREAK_LAVA=21,
    S_BREAK_DIRT=22,
    S_ATTEMPT_FIRE=23,
    S_SPLASH_BIG=24,
    S_SPLASH_SMALL=25,
    S_FOOTSTEPS_HARD=26,
    S_FOOTSTEPS_SOFT=27,
    S_SWOOSH=28,
    S_FIRE_SUCCEED=29,
   
    S_CREATURE_VANISH=30,
    S_CREATURE_PICKEDUP=31,
    S_FLAMELOOP=32,
    S_CAMERA=33,
    S_BREAK_GLASS=34,
    
    S_HIT=35,
    S_BREAK_GENERIC=36,
    S_DOOR_OPEN=37,
    S_DOOR_CLOSED=38,
    S_FIREWORK_EXPLODE=39,
    S_FIREWORK_FUSE=40,
    S_FIREWORK_LIFTOFF=41,
    S_TREASURE_PICKUP=42,
    S_TREASURE_PLACE=43,
    S_DEATH_BY_LAVA=44,
    S_DEATH_BY_CREATURE=45,
    S_DEATH_BY_TNT=46,
    S_BUILD_METAL=47,
    S_BUILD_LIGHT=48,
    S_CHANGE_LIGHT=49,
    S_ENTER_PORTAL=50,
    S_GOOP_EXPLODE=51,
    S_METAL_DESTROY=52,
};
enum MENU_TYPES{
	MENU_AUTOJUMP=0,
	MENU_LOGO=1,
	MENU_ARROW_LEFT=2,
	MENU_ARROW_RIGHT=3,
	MENU_CREATE_WORLD=4,
	MENU_DELETE_WORLD=5,
	MENU_SHARE_WORLD=6,
	MENU_GROUND=7,
	MENU_BLOCK_SELECTED=8,
	MENU_BLOCK_UNSELECTED=9,
	MENU_LOAD_WORLD=10,
	MENU_OPTIONS=11,
	MENU_ARROW_UP=12,
	MENU_ARROW_DOWN=13,
	MENU_BACK=14,
	MENU_SHARED_HEADER=15,
	MENU_CLOUD=16,
	MENU_CANCEL=17,
	MENU_HEALTH=18,
	MENU_MUSIC=19,
	MENU_OFF=20,
	MENU_ON=21,
	MENU_OPTIONS_HEADER=22,
	MENU_SAVE=23,
	MENU_SEND=24,
	MENU_SOUND_EFFECTS=25,
	MENU_TEXT_BOX=26,
	
	MENU_SKY=27,
	MENU_PINWHEEL=28,
	MENU_MOUNTAINS=29,
   
    MENU_LOAD_TEXT=30,
     MENU_BACK_TEXT=31,
    MENU_CLOUD2=32,
    MENU_CLOUD3=33,
    MENU_SHARED_BLOCK_SELECTED=34,
	MENU_SHARED_BLOCK_UNSELECTED=35,
    
    MENU_AUTOSAVE=36,
	MENU_BEST=37,
    MENU_CREATURES=38,
    
    MENU_TREESLEFT=39,
    MENU_TREESRIGHT=40,
    MENU_FLAG=41,
	
};

enum ICON_TYPES{
	ICO_MOOF=0,
	ICO_BUILD=1,
	ICO_MINE=2,
	ICO_BURN=3,
	ICO_SAVE=4,
	ICO_EXIT=5,
	ICO_HOME=6,
	ICO_JUMP=7,
	
	ICO_SMOKE=8,
	
	ICO_JOYSTICK_BACK=9,
	ICO_JOYSTICK_FRONT=10,
	ICO_SCREENSHOT=11,
	
	ICO_BLOCK_BORDER=12,
	ICO_BLOCK_SELECT_BACKGROUND=13,
    ICO_COLOR_SELECT_BACKGROUND=14,
    ICO_PAINT=15,    
    ICO_BLOCK_BORDER_PRESSED=16,
    ICO_COLOR_BLOCK_BORDER_PRESSED=17,
    ICO_COLOR_BLOCK_BORDER=18,
    ICO_SKY_BOX=19,
    ICO_TRIANGLE_BORDER_PRESSED=20,
    ICO_TRIANGLE_BORDER=21,
    ICO_BUILD2=22,
    ICO_BUILD3=23,
    ICO_MINE_ACTIVE=24,
    ICO_PAINT_ACTIVE=25,
    ICO_BUILD2_ACTIVE=26,
    ICO_BUILD3_ACTIVE=27,
    ICO_BURN_ACTIVE=28,
    ICO_JUMP_ACTIVE=29,
    SKIN_MOOF=30,
    SKIN_MOOFRAGE=31,
    SKIN_MOOFBLINK=32,  
    
    SKIN_BATTY=33,
    SKIN_BATTYRAGE=34,
    SKIN_BATTYBLINK=35,
    
    SKIN_GREEN=36,
    SKIN_GREENRAGE=37,
    SKIN_GREENBLINK=38,
    
    SKIN_NERGLE=39,
    SKIN_NERGLERAGE=40,
    SKIN_NERGLEBLINK=41,
    
    
    
    SKIN_STUMPY=42,
    SKIN_STUMPYRAGE=43,
    SKIN_STUMPYBLINK=44,
    
    ICO_SHADOW=45,
    ICO_OPEN_MENU=46,
    ICO_DOOR=47,
    ICO_SKY_BOX_BW=48,
    ICO_GOLDEN_CUBE=49,
    ICO_GOLDEN_CUBE_BW=50,
    ICO_DOOR_MASK=51,
    ICO_FLOWER=52,
    ICO_PORTAL=53,
    ICO_SPHEREMAP=54,
    ICO_BUILD2_TOP=55,
    ICO_BUILD_PLUS=56,
    ICOT_SAVE=57,
    ICOT_HOME=58,
    ICOT_PHOTO=59,
    ICOT_EXIT=60,
    ICO_SWIRL=61,
    ICO_BUILD3_TOP=62,
    ICO_SIZETOGGLE1=63,
    ICO_SIZETOGGLE2=64,
    ICO_FLOWER_ICO=65,
    ICO_BLOCK_BORDER2=66,
    ICO_BLOCK_BORDER_PRESSED2=67,
    ICO_TRIANGLE_BORDER2=68,
    ICO_TRIANGLE_BORDER_PRESSED2=69,
    ICO_BUILD_UNDER2=70,
    ICO_BUILD_OVER2=71,
    ICO_BUILD2_ACTIVE2=72,
    ICO_BUILD2_UNDER2=73,
    ICO_BUILD3_TOP2=74,
    ICO_BUILD3_ACTIVE2=75,
    ICO_DIGITS=76,
    ICO_GOLDCUBE=77,
    ICO_PORTAL2=78,
    ICO_DOOR2=79,
    
    SKIN_CHARGER=80,
    SKIN_CHARGERRAGE=81,
    SKIN_CHARGERBLINK=82,
    
    SKIN_STALKER=83,
    SKIN_STALKERRAGE=84,
    SKIN_STALKERBLINK=85,
    SKIN_MOOFMASK=86,
    SPRITE_FLAME=87,
    
    TEXT_NUMBERS=88,
    ICO_PAINT_MASK=89,
    
    SMALL_ICO_MASK1=90,
    SMALL_ICO_MASK2=91,
    SMALL_ICO_MASK3=92,
    SMALL_ICO_MASK4=93,
    /*
     temp=[[Texture2D alloc] initWithImagePath:@"goldcube_icon_active.png" sizeToFit:FALSE];
     [textures addObject:temp];
     temp=[[Texture2D alloc] initWithImagePath:@"flower_icon_active.png" sizeToFit:FALSE];
     [textures addObject:temp];
     temp=[[Texture2D alloc] initWithImagePath:@"door_icon2_active.png" sizeToFit:FALSE];
     [textures addObject:temp];
     temp=[[Texture2D alloc] initWithImagePath:@"portal_icon2_active.png" sizeToFit:FALSE];
     [textures addObject:temp];
*/
    ICOICO_GOLDCUBE_ACTIVE=94,
    ICOICO_FLOWER_ACTIVE=95,
    ICOICO_DOOR_ACTIVE=96,
    ICOICO_PORTAL_ACTIVE=97,
     ICO_BLOCK_BORDER_ACTIVE=98,
     ICO_TRIANGLE_BORDER_ACTIVE=99,
    
    //10 texs after this reserved for coloring
    
};

#endif
