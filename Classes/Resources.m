//
//  Resources.m
//  prototype
//
//  Created by Ari Ronen on 10/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Resources.h"
#import "glu.h"
#import "Vector.h"
#import "CDAudioManager.h"
#import "SimpleAudioEngine.h"
#import "World.h"
static Resources* singleton;

@implementation Resources
@synthesize atlas,atlas2,playmusic,playsound;


+ (Resources*)getResources{
	if(!singleton){
		singleton=[[Resources alloc] init];
		
	}	
	return singleton;	
}




#define NUM_SONGS 4

static NSString* songFiles[NUM_SONGS]={
    @"Eden_1.mp3",
    @"Eden_2.mp3",
    @"Eden_3.mp3",
    @"Eden_4.mp3",
       
};

static NSString* ambientFiles[NUM_AMBIENT]={	

[AMBIENT_UNDERWATER]=@"ambience_underwater.wav",
[AMBIENT_RIVER]=@"ambience_river.wav",
[AMBIENT_LAVA]=@"ambience_lava.wav",
[AMBIENT_SKYHIGH]=@"ambience_skyhigh.wav",
[AMBIENT_CAVE]=@"ambience_cave.wav",
[AMBIENT_OPEN]=@"ambience_open.wav",
    
};
/*S_LADDER=0,
S_VINE=1,
S_BOUNCE=2,
S_LAND_SOFT=3,
S_LAND_HARD=4,
S_PAINT_BLOCK=5,
S_LAVA_BURN=6,
S_ICE_LOOP=7,
S_EXPLOOSION=8,
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
S_EXPLOSION=30,
S_CREATURE_VANISH=31,
S_CREATURE_PICKEDUP=32,
S_FLAMELOOP=33,
S_CAMERA=34,
S_JUMP=35,*/

#define MAX_VARIATIONS2 6
static int sfxNumVariations[NUM_SOUNDS]={  
    [S_LADDER]=4,
    [S_VINE]=4,
    [S_BOUNCE]=4,
    [S_LAND_SOFT]=3,
    [S_LAND_HARD]=3,
    [S_PAINT_BLOCK ]=3,
    [ S_LAVA_BURN]=4,
    [ S_ICE_LOOP]=1,
    [ S_EXPLODE]=1,
    [ S_BUILD_WOOD]=4,
    [ S_BUILD_WATER]=4,
    [ S_BUILD_STONE]=4,
    [ S_BUILD_LEAVES]=4,
    [ S_BUILD_LAVA]=4,
    [ S_BUILD_GLASS]=4,
    [ S_BUILD_DIRT]=4,
    [ S_BUILD_GENERIC]=4,
    [ S_BREAK_GENERIC]=4,
    [ S_BREAK_WOOD]=4,
    [ S_BREAK_WATER]=4,
    [S_BREAK_STONE ]=4,
    [  S_BREAK_LEAVES]=4,
    [  S_BREAK_LAVA]=4,
    [  S_BREAK_DIRT]=4,
     [ S_BREAK_GLASS]=4,
    [  S_ATTEMPT_FIRE]=1,
    [  S_SPLASH_BIG]=4,
    [S_SPLASH_SMALL ]=4,
    [   S_FOOTSTEPS_HARD]=6,
    [   S_FOOTSTEPS_SOFT]=6,
    [   S_SWOOSH]=3,
    [   S_FIRE_SUCCEED]=3,
   
    [   S_CREATURE_VANISH]=1,
    [   S_CREATURE_PICKEDUP]=1,
    [   S_FLAMELOOP]=1,
    [   S_CAMERA]=1,
    [S_HIT]=3,
 
    
};
static NSString* soundFiles[NUM_SOUNDS][MAX_VARIATIONS2]={	
	[S_LADDER]={@"wood_ladder_1_v2.caf",@"wood_ladder_2_v2.caf",@"wood_ladder_3_v2.caf",@"wood_ladder_4_v2.caf"},
    [S_VINE]={@"vine_ladder_1_v2.caf",@"vine_ladder_2_v2.caf",@"vine_ladder_3_v2.caf",@"vine_ladder_4_v2.caf"},
    [S_BOUNCE]={@"trampoline_bounce_1_v2.caf",@"trampoline_bounce_2_v2.caf",@"trampoline_bounce_3_v2.caf",@"trampoline_bounce_4_v2.caf"},
    [S_LAND_SOFT]={@"player_land_soft_1_v2.caf",@"player_land_soft_2_v2.caf",@"player_land_soft_3_v2.caf",@"land_soft_4_v2.caf"},
    [S_LAND_HARD]={@"player_land_hard_1.caf",@"player_land_hard_2_v2.caf",@"player_land_hard_3_v2.caf",@"land_hard_4_v2.caf"},
    [S_PAINT_BLOCK]={@"paint_block_1.caf",@"paint_block_2_v2.caf",@"paint_block_3.caf",@"paint_block_4.caf"},
     [S_LAVA_BURN]={@"lava_burn_1_v2.caf",@"lava_burn_2_v2.caf",@"lava_burn_3_v2.caf",@"lava_burn_4_v2.caf"},
    [S_EXPLODE]={@"explosion.caf",@"explosion_2.caf",@"explosion_3.caf",@"explosion_4.caf"},
    [S_BREAK_WOOD]={@"block_break_wood_1_v2.caf",@"block_break_wood_2_v2.caf",@"block_break_wood_3_v2.caf",@"block_break_wood_4_v2.caf"},
    [S_BREAK_WATER]={@"block_break_water_1_v2.caf",@"block_break_water_2_v2.caf",@"block_break_water_3_v2.caf",@"block_break_water_4_v2.caf"},
    [S_BREAK_STONE]={@"block_break_stone_1.caf",@"block_break_stone_2.caf",@"block_break_stone_3.caf",@"block_break_stone_4.caf"},
    [S_BREAK_LEAVES]={@"block break_leaves_1.caf",@"block break_leaves_2.caf",@"block break_leaves_3.caf",@"block break_leaves_4.caf"},
    [S_BREAK_LAVA]={@"block_break_lava_1_v2.caf",@"block_break_lava_2_v2.caf",@"block_break_lava_3_v2.caf",@"block_break_lava_4_v2.caf"},
    [S_BREAK_DIRT]={@"block_break_dirt_1.caf",@"block_break_dirt_2.caf",@"block_break_dirt_3.caf",@"block_break_dirt_4.caf"},
    [S_BREAK_GLASS]={@"block_break_glass_1.caf",@"block_break_glass_2.caf",@"block_break_glass_3.caf",@"block_break_glass_4.caf"},
    [S_BREAK_GENERIC]={@"block_break_generic_1_v2.caf",@"block_break_generic_2_v2.caf",@"block_break_generic_3_v2.caf",@"block_break_generic_4_v2.caf"},
    [S_BUILD_WOOD]={@"block_build_wood_1.caf",@"block_build_wood_2.caf",@"block_build_wood_3.caf",@"block_build_wood_4.caf"},
    [S_BUILD_WATER]={@"block_build_water_1.caf",@"block_build_water_2.caf",@"block_build_water_3.caf",@"block_build_water_4.caf"},
    [S_BUILD_STONE]={@"block_build_stone_1.caf",@"block_build_stone_2.caf",@"block_build_stone_3.caf",@"block_build_stone_4.caf"},
    [S_BUILD_LEAVES]={@"block_build_leaves_1.caf",@"block_build_leaves_2.caf",@"block_build_leaves_3.caf",@"block_build_leaves_4.caf"},
    [S_BUILD_LAVA]={@"block_build_lava_1.caf",@"block_build_lava_2.caf",@"block_build_lava_3.caf",@"block_build_lava_4.caf"},
    [S_BUILD_GLASS]={@"block_build_glass_1.caf",@"block_build_glass_2.caf",@"block_build_glass_3.caf",@"block_build_glass_4.caf"},
    [S_BUILD_DIRT]={@"block_build_dirt_1.caf",@"block_build_dirt_2.caf",@"block_build_dirt_3.caf",@"block_build_dirt_4.caf"},
    [S_BUILD_GENERIC]={@"block_build_generic_1.caf",@"block_build_generic_2.caf",@"block_build_generic_3.caf",@"block_build_generic_4.caf"},
    [S_ATTEMPT_FIRE]={@"matchlight.caf",@"attempt_fire_2.caf",@"attempt_fire_3.caf",@"attempt_fire_4.caf"},
    [S_SPLASH_SMALL]={@"water_splash_small_1.caf",@"water_splash_small_2.caf",@"water_splash_small_3.caf",@"water_splash_small_4.caf"},
    [S_SPLASH_BIG]={@"water_splash_big_1.caf",@"water_splash_big_2.caf",@"water_splash_big_3.caf",@"water_splash_big_4.caf"},
    [S_FOOTSTEPS_HARD]={@"player_footsteps_hard_1.caf",@"player_footsteps_hard_2.caf",@"player_footsteps_hard_3.caf",@"player_footsteps_hard_4.caf",@"player_footsteps_hard_5.caf",@"player_footsteps_hard_6.caf"},
    [S_FOOTSTEPS_SOFT]={@"player_footsteps_grass_1.caf",@"player_footsteps_grass_2.caf",@"player_footsteps_grass_3.caf",@"player_footsteps_grass_4.caf",@"player_footsteps_grass_5.caf",@"player_footsteps_grass_6.caf"},
    [S_SWOOSH]={@"menu_transition_1.caf",@"menu_transition_2.caf",@"menu_transition_3.caf",@"menu_transition_4.caf"},
    [S_FIRE_SUCCEED]={@"fire_succeed_1.caf",@"fire_succeed_2.caf",@"fire_succeed_3.caf",@"menu_transition_4.caf"},
    [S_CREATURE_VANISH]={@"creature_vanish.caf",@"creature_vanish_2.caf",@"creature_vanish_3.caf",@"creature_vanish_4.caf"},
    [S_CREATURE_PICKEDUP]={@"creature_pickedup.caf",@"creature_pickedup_2.caf",@"creature_pickedup_3.caf",@"creature_pickedup_4.caf"},
    [S_FLAMELOOP]={@"fire_loop.caf",@"x_2.caf",@"x_3.caf",@"x_4.caf"},
    [S_ICE_LOOP]={@"ice_slide.wav",@"x_2.caf",@"x_3.caf",@"x_4.caf"},

    [S_CAMERA]={@"Grab.aif",@"x_2.caf",@"x_3.caf",@"x_4.caf"},
    [S_HIT]={@"player_hit_1.caf",@"player_hit_2.caf",@"player_hit_3.caf"}
};


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

#define MAX_VARIATIONS 5
static NSString* voFiles[NUM_CREATURES][NUM_VO_ACTIONS][MAX_VARIATIONS]={	
	[M_STUMPY][VO_WALKING]={@"Stumpy_Walking_1.caf",@"Stumpy_Walking_2.caf",@"Stumpy_Walking_3.caf",@"Stumpy_Walking_4.caf",@"Stumpy_Walking_5.caf"},
    [M_STUMPY][VO_STRETCHING]={@"Stumpy_Stretching_1.caf",@"Stumpy_Stretching_2.caf",@"Stumpy_Stretching_3.caf",@"Stumpy_Stretching_4.caf",@"Stumpy_Stretching_5.caf"},
    [M_STUMPY][VO_SCARED]={@"Stumpy_Scared_1.caf",@"Stumpy_Scared_2.caf",@"Stumpy_Scared_3.caf",@"Stumpy_Scared_4.caf",@"Stumpy_Scared_5.caf"},
    [M_STUMPY][VO_RELIEVED]={@"Stumpy_Relieved_1.caf",@"Stumpy_Relieved_2.caf",@"Stumpy_Relieved_3.caf",@"Stumpy_Relieved_4.caf",@"Stumpy_Relieved_5.caf"},
    [M_STUMPY][VO_APPROACH]={@"Stumpy_PlayerApproaches_1.caf",@"Stumpy_PlayerApproaches_2.caf",@"Stumpy_PlayerApproaches_3.caf",@"Stumpy_PlayerApproaches_4.caf",@"Stumpy_PlayerApproaches_5.caf"},
    [M_STUMPY][VO_ONFIRE]={@"Stumpy_OnFire_1.caf",@"Stumpy_OnFire_2.caf",@"Stumpy_OnFire_3.caf",@"Stumpy_OnFire_4.caf",@"Stumpy_OnFire_5.caf"},
    [M_STUMPY][VO_IDLE]={@"Stumpy_Idle_1.caf",@"Stumpy_Idle_2.caf",@"Stumpy_Idle_3.caf",@"Stumpy_Idle_4.caf",@"Stumpy_Idle_5.caf"},
    [M_STUMPY][VO_HIT]={@"Stumpy_Hit_1.caf",@"Stumpy_Hit_2.caf",@"Stumpy_Hit_3.caf",@"Stumpy_Hit_4.caf",@"Stumpy_Hit_5.caf"},
    [M_STUMPY][VO_EXCITED]={@"Stumpy_Excited_1.caf",@"Stumpy_Excited_2.caf",@"Stumpy_Excited_3.caf",@"Stumpy_Excited_4.caf",@"Stumpy_Excited_5.caf"},
    [M_STUMPY][VO_ANGRY]={@"Stumpy_Angry_1.caf",@"Stumpy_Angry_2.caf",@"Stumpy_Angry_3.caf",@"Stumpy_Angry_4.caf",@"Stumpy_Angry_5.caf"},    
    
    [M_MOOF][VO_WALKING]={@"Moof_Walking_1.caf",@"Moof_Walking_2.caf",@"Moof_Walking_3.caf",@"Moof_Walking_4.caf",@"Moof_Walking_5.caf"},
    [M_MOOF][VO_STRETCHING]={@"Moof_Stretching_1.caf",@"Moof_Stretching_2.caf",@"Moof_Stretching_3.caf",@"Moof_Stretching_4.caf",@"Moof_Stretching_5.caf"},
    [M_MOOF][VO_SCARED]={@"Moof_Scared_1.caf",@"Moof_Scared_2.caf",@"Moof_Scared_3.caf",@"Moof_Scared_4.caf",@"Moof_Scared_5.caf"},
    [M_MOOF][VO_RELIEVED]={@"Moof_Relieved_1.caf",@"Moof_Relieved_2.caf",@"Moof_Relieved_3.caf",@"Moof_Relieved_4.caf",@"Moof_Relieved_5.caf"},
    [M_MOOF][VO_APPROACH]={@"Moof_PlayerApproaches_1.caf",@"Moof_PlayerApproaches_2.caf",@"Moof_PlayerApproaches_3.caf",@"Moof_PlayerApproaches_4.caf",@"Moof_PlayerApproaches_5.caf"},
    [M_MOOF][VO_ONFIRE]={@"Moof_OnFire_1.caf",@"Moof_OnFire_2.caf",@"Moof_OnFire_3.caf",@"Moof_OnFire_4.caf",@"Moof_OnFire_5.caf"},
    [M_MOOF][VO_IDLE]={@"Moof_Idle_1.caf",@"Moof_Idle_2.caf",@"Moof_Idle_3.caf",@"Moof_Idle_4.caf",@"Moof_Idle_5.caf"},
    [M_MOOF][VO_HIT]={@"Moof_Hit_1.caf",@"Moof_Hit_2.caf",@"Moof_Hit_3.caf",@"Moof_Hit_4.caf",@"Moof_Hit_5.caf"},
    [M_MOOF][VO_EXCITED]={@"Moof_Excited_1.caf",@"Moof_Excited_2.caf",@"Moof_Excited_3.caf",@"Moof_Excited_4.caf",@"Moof_Excited_5.caf"},
    [M_MOOF][VO_ANGRY]={@"Moof_Angry_1.caf",@"Moof_Angry_2.caf",@"Moof_Angry_3.caf",@"Moof_Angry_4.caf",@"Moof_Angry_5.caf"},   
    
    [M_NERGLE][VO_WALKING]={@"Nergle_Walking_1.caf",@"Nergle_Walking_2.caf",@"Nergle_Walking_3.caf",@"Nergle_Walking_4.caf",@"Nergle_Walking_5.caf"},
    [M_NERGLE][VO_STRETCHING]={@"Nergle_Stretching_1.caf",@"Nergle_Stretching_2.caf",@"Nergle_Stretching_3.caf",@"Nergle_Stretching_4.caf",@"Nergle_Stretching_5.caf"},
    [M_NERGLE][VO_SCARED]={@"Nergle_Scared_1.caf",@"Nergle_Scared_2.caf",@"Nergle_Scared_3.caf",@"Nergle_Scared_4.caf",@"Nergle_Scared_5.caf"},
    [M_NERGLE][VO_RELIEVED]={@"Nergle_Relieved_1.caf",@"Nergle_Relieved_2.caf",@"Nergle_Relieved_3.caf",@"Nergle_Relieved_4.caf",@"Nergle_Relieved_5.caf"},
    [M_NERGLE][VO_APPROACH]={@"Nergle_PlayerApproaches_1.caf",@"Nergle_PlayerApproaches_2.caf",@"Nergle_PlayerApproaches_3.caf",@"Nergle_PlayerApproaches_4.caf",@"Nergle_PlayerApproaches_5.caf"},
    [M_NERGLE][VO_ONFIRE]={@"Nergle_OnFire_1.caf",@"Nergle_OnFire_2.caf",@"Nergle_OnFire_3.caf",@"Nergle_OnFire_4.caf",@"Nergle_OnFire_5.caf"},
    [M_NERGLE][VO_IDLE]={@"Nergle_Idle_1.caf",@"Nergle_Idle_2.caf",@"Nergle_Idle_3.caf",@"Nergle_Idle_4.caf",@"Nergle_Idle_5.caf"},
    [M_NERGLE][VO_HIT]={@"Nergle_Hit_1.caf",@"Nergle_Hit_2.caf",@"Nergle_Hit_3.caf",@"Nergle_Hit_4.caf",@"Nergle_Hit_5.caf"},
    [M_NERGLE][VO_EXCITED]={@"Nergle_Excited_1.caf",@"Nergle_Excited_2.caf",@"Nergle_Excited_3.caf",@"Nergle_Excited_4.caf",@"Nergle_Excited_5.caf"},
    [M_NERGLE][VO_ANGRY]={@"Nergle_Angry_1.caf",@"Nergle_Angry_2.caf",@"Nergle_Angry_3.caf",@"Nergle_Angry_4.caf",@"Nergle_Angry_5.caf"},   
    
    [M_GREEN][VO_WALKING]={@"Green_Walking_1.caf",@"Green_Walking_2.caf",@"Green_Walking_3.caf",@"Green_Walking_4.caf",@"Green_Walking_5.caf"},
    [M_GREEN][VO_STRETCHING]={@"Green_Stretching_1.caf",@"Green_Stretching_2.caf",@"Green_Stretching_3.caf",@"Green_Stretching_4.caf",@"Green_Stretching_5.caf"},
    [M_GREEN][VO_SCARED]={@"Green_Scared_1.caf",@"Green_Scared_2.caf",@"Green_Scared_3.caf",@"Green_Scared_4.caf",@"Green_Scared_5.caf"},
    [M_GREEN][VO_RELIEVED]={@"Green_Relieved_1.caf",@"Green_Relieved_2.caf",@"Green_Relieved_3.caf",@"Green_Relieved_4.caf",@"Green_Relieved_5.caf"},
    [M_GREEN][VO_APPROACH]={@"Green_PlayerApproaches_1.caf",@"Green_PlayerApproaches_2.caf",@"Green_PlayerApproaches_3.caf",@"Green_PlayerApproaches_4.caf",@"Green_PlayerApproaches_5.caf"},
    [M_GREEN][VO_ONFIRE]={@"Green_OnFire_1.caf",@"Green_OnFire_2.caf",@"Green_OnFire_3.caf",@"Green_OnFire_4.caf",@"Green_OnFire_5.caf"},
    [M_GREEN][VO_IDLE]={@"Green_Idle_1.caf",@"Green_Idle_2.caf",@"Green_Idle_3.caf",@"Green_Idle_4.caf",@"Green_Idle_5.caf"},
    [M_GREEN][VO_HIT]={@"Green_Hit_1.caf",@"Green_Hit_2.caf",@"Green_Hit_3.caf",@"Green_Hit_4.caf",@"Green_Hit_5.caf"},
    [M_GREEN][VO_EXCITED]={@"Green_Excited_1.caf",@"Green_Excited_2.caf",@"Green_Excited_3.caf",@"Green_Excited_4.caf",@"Green_Excited_5.caf"},
    [M_GREEN][VO_ANGRY]={@"Green_Angry_1.caf",@"Green_Angry_2.caf",@"Green_Angry_3.caf",@"Green_Angry_4.caf",@"Green_Angry_5.caf"},   
    
    [M_BATTY][VO_WALKING]={@"Batty_Walking_1.caf",@"Batty_Walking_2.caf",@"Batty_Walking_3.caf",@"Batty_Walking_4.caf",@"Batty_Walking_5.caf"},
    [M_BATTY][VO_STRETCHING]={@"Batty_Stretching_1.caf",@"Batty_Stretching_2.caf",@"Batty_Stretching_3.caf",@"Batty_Stretching_4.caf",@"Batty_Stretching_5.caf"},
    [M_BATTY][VO_SCARED]={@"Batty_Scared_1.caf",@"Batty_Scared_2.caf",@"Batty_Scared_3.caf",@"Batty_Scared_4.caf",@"Batty_Scared_5.caf"},
    [M_BATTY][VO_RELIEVED]={@"Batty_Relieved_1.caf",@"Batty_Relieved_2.caf",@"Batty_Relieved_3.caf",@"Batty_Relieved_4.caf",@"Batty_Relieved_5.caf"},
    [M_BATTY][VO_APPROACH]={@"Batty_PlayerApproaches_1.caf",@"Batty_PlayerApproaches_2.caf",@"Batty_PlayerApproaches_3.caf",@"Batty_PlayerApproaches_4.caf",@"Batty_PlayerApproaches_5.caf"},
    [M_BATTY][VO_ONFIRE]={@"Batty_OnFire_1.caf",@"Batty_OnFire_2.caf",@"Batty_OnFire_3.caf",@"Batty_OnFire_4.caf",@"Batty_OnFire_5.caf"},
    [M_BATTY][VO_IDLE]={@"Batty_Idle_1.caf",@"Batty_Idle_2.caf",@"Batty_Idle_3.caf",@"Batty_Idle_4.caf",@"Batty_Idle_5.caf"},
    [M_BATTY][VO_HIT]={@"Batty_Hit_1.caf",@"Batty_Hit_2.caf",@"Batty_Hit_3.caf",@"Batty_Hit_4.caf",@"Batty_Hit_5.caf"},
    [M_BATTY][VO_EXCITED]={@"Batty_Excited_1.caf",@"Batty_Excited_2.caf",@"Batty_Excited_3.caf",@"Batty_Excited_4.caf",@"Batty_Excited_5.caf"},
    [M_BATTY][VO_ANGRY]={@"Batty_Angry_1.caf",@"Batty_Angry_2.caf",@"Batty_Angry_3.caf",@"Batty_Angry_4.caf",@"Batty_Angry_5.caf"},  
};
static int voNumVariations[NUM_CREATURES][NUM_VO_ACTIONS]={  
        [M_STUMPY][VO_WALKING]=5,
        [M_STUMPY][VO_STRETCHING]=3,
        [M_STUMPY][VO_SCARED]=5,
        [M_STUMPY][VO_RELIEVED]=5,
        [M_STUMPY][VO_APPROACH]=5,
        [M_STUMPY][VO_ONFIRE]=5,
        [M_STUMPY][VO_IDLE]=5,
        [M_STUMPY][VO_HIT]=5,
        [M_STUMPY][VO_EXCITED]=5,
        [M_STUMPY][VO_ANGRY]=5,   
    
    [M_NERGLE][VO_WALKING]=3,
    [M_NERGLE][VO_STRETCHING]=2,
    [M_NERGLE][VO_SCARED]=5,
    [M_NERGLE][VO_RELIEVED]=5,
    [M_NERGLE][VO_APPROACH]=5,
    [M_NERGLE][VO_ONFIRE]=5,
    [M_NERGLE][VO_IDLE]=5,
    [M_NERGLE][VO_HIT]=5,
    [M_NERGLE][VO_EXCITED]=5,
    [M_NERGLE][VO_ANGRY]=5,  
    
    [M_MOOF][VO_WALKING]=5,
    [M_MOOF][VO_STRETCHING]=2,
    [M_MOOF][VO_SCARED]=5,
    [M_MOOF][VO_RELIEVED]=5,
    [M_MOOF][VO_APPROACH]=5,
    [M_MOOF][VO_ONFIRE]=5,
    [M_MOOF][VO_IDLE]=5,
    [M_MOOF][VO_HIT]=5,
    [M_MOOF][VO_EXCITED]=5,
    [M_MOOF][VO_ANGRY]=5,  
    
    [M_GREEN][VO_WALKING]=2,
    [M_GREEN][VO_STRETCHING]=3,
    [M_GREEN][VO_SCARED]=5,
    [M_GREEN][VO_RELIEVED]=5,
    [M_GREEN][VO_APPROACH]=5,
    [M_GREEN][VO_ONFIRE]=5,
    [M_GREEN][VO_IDLE]=5,
    [M_GREEN][VO_HIT]=5,
    [M_GREEN][VO_EXCITED]=5,
    [M_GREEN][VO_ANGRY]=5,  
    
    [M_BATTY][VO_WALKING]=3,
    [M_BATTY][VO_STRETCHING]=2,
    [M_BATTY][VO_SCARED]=5,
    [M_BATTY][VO_RELIEVED]=5,
    [M_BATTY][VO_APPROACH]=5,
    [M_BATTY][VO_ONFIRE]=5,
    [M_BATTY][VO_IDLE]=5,
    [M_BATTY][VO_HIT]=5,
    [M_BATTY][VO_EXCITED]=5,
    [M_BATTY][VO_ANGRY]=5,  
};

static int voLastVariation[NUM_CREATURES][NUM_VO_ACTIONS];
static int sfxLastVariation[NUM_SOUNDS];
typedef struct{
	Texture2D* tex;
    int color;
    int model_type;
    int state;
}CTexture;
UIImage* storedSkins[5][2];
UIImage* storedMasks[5][2];
UIImage* storedDoor;
UIImage* storedDoorMask;
UIImage* storedPaint;
UIImage* storedPaintMask;
UIImage* storedCube;
UIImage* storedCubeMask;
UIImage* storedFlowerico;
UIImage* storedFlowericoMask;
UIImage* storedDoorico;
UIImage* storedDooricoMask;
UIImage* storedPortalico;
UIImage* storedPortalicoMask;


#define SKIN_CACHE_SIZE 50
CTexture skin_cache[SKIN_CACHE_SIZE];

Texture2D* door_cache[100];

Texture2D* paint_cache;
int paint_cache_color;
Texture2D* build_cache;
int build_cache_color;
int build_cache_type;

void clearSkinCache(){
    if(paint_cache){
        [paint_cache release];
        paint_cache=NULL;
        paint_cache_color=0;
    }
    if(build_cache){
        [build_cache release];
        build_cache=NULL;
        build_cache_color=0;
        build_cache_type=0;
    }
    for(int i=0;i<100;i++){
        if(i<100){
            if(door_cache[i]){
                [door_cache[i] release];
                door_cache[i]=NULL;
                
                
            }
        }
    }
    for(int i=0;i<SKIN_CACHE_SIZE;i++){
        if(skin_cache[i].tex){
            [skin_cache[i].tex release];
            skin_cache[i].tex=NULL;
        }
    }
}
extern Vector colorTable[256];
/*
 UIImage* storedCube;
 UIImage* storedCubeMask;
 UIImage* storedFlowerico;
 UIImage* storedFlowericoMask;
 UIImage* storedDoorico;
 UIImage* storedDooricoMask;
 UIImage* storedPortalico;
 UIImage* storedPortalicoMask;
 */
-(Texture2D*)getPaintedTex:(int)type:(int)color{
   
    if(color==0||(type==TYPE_GOLDEN_CUBE&&color==20)){
        int tid;
        if(type==TYPE_FLOWER){
            tid=ICO_FLOWER_ICO;
        }else if(type==TYPE_GOLDEN_CUBE){
            tid=ICO_GOLDCUBE;
        }else if(type==TYPE_PORTAL_TOP){
            tid=ICO_PORTAL2;
        }else if(type==TYPE_DOOR_TOP){
            tid=ICO_DOOR2;
        }
        return [self getTex:tid];
    }else if(build_cache!=NULL&&build_cache_color==color&&build_cache_type==type){
        return build_cache;
    }
    if(build_cache!=NULL){
        [build_cache release];
    }
    build_cache_color=color;
    build_cache_type=type;
    UIImage* ui1;
    UIImage* ui2;
    if(type==TYPE_FLOWER){
        ui1=storedFlowerico;
        ui2=storedFlowericoMask;
        
    }else if(type==TYPE_GOLDEN_CUBE){
        ui1=storedCube;
        ui2=storedCubeMask;
    }else if(type==TYPE_PORTAL_TOP){
        ui1=storedPortalico;
        ui2=storedPortalicoMask;
    }else if(type==TYPE_DOOR_TOP){
        ui1=storedDoorico;
        ui2=storedDooricoMask;
    }
    
    CGImageRef img=[ui2 CGImage];
    CGImageRef img2=[ui1 CGImage];
    Vector clr=colorTable[color];
    int rgba= ((int)(255*clr.z)<<24) | ((int)(255*clr.y)<<16) | ((int)(255*clr.x) <<8)  | 0xFF;
    UIImage* uiImage2=[UIImage imageWithCGImage:ManipulateImagePixelData(img2,img,rgba)];
    //UIImage* uiImage2=[UIImage imageWithCGImage:ManipulateImagePixelData2(img,rgba,1)];
    build_cache =
    [[Texture2D alloc] initWithCGImage:[uiImage2 CGImage] orientation:[uiImage2 imageOrientation] sizeToFit:FALSE pixelFormat:kTexture2DPixelFormat_Automatic generateMips:FALSE];
    printf("initing build texture ;o");
    return build_cache;
}
- (Texture2D*)getPaintTex:(int)color{
    if(color==0)return [self getTex:ICO_PAINT];
    if(color==paint_cache_color)return paint_cache;
    
    if(paint_cache!=NULL){
        
        [paint_cache release];
    }
    
    paint_cache_color=color;
        CGImageRef img=[storedPaintMask CGImage];
        CGImageRef img2=[storedPaint CGImage];
        Vector clr=colorTable[color];
        int rgba= ((int)(255*clr.z)<<24) | ((int)(255*clr.y)<<16) | ((int)(255*clr.x) <<8)  | 0xFF;
        UIImage* uiImage2=[UIImage imageWithCGImage:ManipulateImagePixelData(img2,img,rgba)];
        //UIImage* uiImage2=[UIImage imageWithCGImage:ManipulateImagePixelData2(img,rgba,1)];
        paint_cache =
        [[Texture2D alloc] initWithCGImage:[uiImage2 CGImage] orientation:[uiImage2 imageOrientation] sizeToFit:FALSE pixelFormat:kTexture2DPixelFormat_Automatic generateMips:FALSE];
        printf("initing paint texture ;o");
        return paint_cache;
    
    
    
}
- (int)getDoorTex:(int)color{
    if(color==0)color=25;
    if(door_cache[color]!=NULL){
        
        return door_cache[color].name;
    }
    else{
       
        CGImageRef img=[storedDoorMask CGImage];
         CGImageRef img2=[storedDoor CGImage];
        Vector clr=colorTable[color];
        int rgba= ((int)(255*clr.z)<<24) | ((int)(255*clr.y)<<16) | ((int)(255*clr.x) <<8)  | 0xFF;
        UIImage* uiImage2=[UIImage imageWithCGImage:ManipulateImagePixelData(img2,img,rgba)];
        //UIImage* uiImage2=[UIImage imageWithCGImage:ManipulateImagePixelData2(img,rgba,1)];
        door_cache[color] =
        [[Texture2D alloc] initWithCGImage:[uiImage2 CGImage] orientation:[uiImage2 imageOrientation] sizeToFit:FALSE pixelFormat:kTexture2DPixelFormat_Automatic generateMips:FALSE];
        printf("initing texture ;o");
        return door_cache[color].name;
    }
    
    return [self getTex:ICO_DOOR].name;
}
- (int)getSkin:(int)model_type:(int)color:(int)state{
    for(int i=0;i<SKIN_CACHE_SIZE;i++){
        if(skin_cache[i].tex!=NULL&&skin_cache[i].model_type==model_type&&skin_cache[i].color==color&&skin_cache[i].state==state){
            return skin_cache[i].tex.name;
        }
    }
    
    int cidx=-1;
    for(int i=0;i<SKIN_CACHE_SIZE;i++){
        if(skin_cache[i].tex==NULL){
            cidx=i;
            break;
        }
    }
    if(cidx==-1){
        cidx=randi(SKIN_CACHE_SIZE);
        if(skin_cache[cidx].tex)[skin_cache[cidx].tex release];
    }
    
    
  //  extern UIImage* storeMask;
    CGImageRef img=[storedMasks[model_type][1-state] CGImage];
    CGImageRef img2=[storedSkins[model_type][state] CGImage];
    
    Vector clr=colorTable[color];
    int rgba= ((int)(255*clr.z)<<24) | ((int)(255*clr.y)<<16) | ((int)(255*clr.x) <<8)  | 0xFF;
    UIImage* uiImage2=[UIImage imageWithCGImage:ManipulateImagePixelData(img2,img,rgba)];
    skin_cache[cidx].tex =
    [[Texture2D alloc] initWithCGImage:[uiImage2 CGImage] orientation:[uiImage2 imageOrientation] sizeToFit:FALSE pixelFormat:kTexture2DPixelFormat_Automatic generateMips:FALSE];
    skin_cache[cidx].model_type=model_type;
    skin_cache[cidx].color=color;
    skin_cache[cidx].state=state;
    
    printf("storing skin in cache idx: %d\n",cidx);
    return skin_cache[cidx].tex.name;
}

-(void)voSound:(int)action:(int)type:(Vector)location{
    if(!playsound)return;
   
    
    
    float distance=v_length2(v_sub(location,[World getWorld].player.pos));
    float distance_fade=12.0f;
    if(distance<distance_fade*distance_fade){
       // distance=sqrtf(distance);
        int variation;
        //type=M_STUMPY;
        variation=arc4random()%voNumVariations[type][action];
        if(variation==voLastVariation[type][action])
            variation=(voLastVariation[type][action]+1)%voNumVariations[type][action];
        voLastVariation[type][action]=variation;
        distance_fade=sqrtf(distance_fade);
        float vol=(distance_fade-sqrtf(sqrtf(distance)))/(distance_fade);
        
         [[SimpleAudioEngine sharedEngine] playEffect:voFiles[type][action][variation] pitch:1.0f pan:0.0f gain:vol*1.4f];
    }
    
    
    
    
   
    
    
    
}

-(void)loadGameAssets{
   /*for(int i=0;i<NUM_SOUNDS;i++){
        for(int j=0;j<sfxNumVariations[i];j++)
        [[SimpleAudioEngine sharedEngine] preloadEffect:soundFiles[i][j]];
    }
    
    if(CREATURES_ON)
    for(int i=0;i<NUM_CREATURES;i++){
        for(int j=0;j<NUM_VO_ACTIONS;j++){
            for(int k=0;k<voNumVariations[i][j];k++){
               
                    [[SimpleAudioEngine sharedEngine] preloadEffect:voFiles[i][j][k]];
                
            }
        }
    }*/
}
-(void)unloadGameAssets{
    for(int i=0;i<NUM_SOUNDS;i++)
         for(int j=0;j<sfxNumVariations[i];j++)
        [[SimpleAudioEngine sharedEngine] unloadEffect:soundFiles[i][j]];
    
    if(CREATURES_ON)
    for(int i=0;i<NUM_CREATURES;i++){
        for(int j=0;j<NUM_VO_ACTIONS;j++){
            for(int k=0;k<voNumVariations[i][j];k++){
              
                    [[SimpleAudioEngine sharedEngine] unloadEffect:voFiles[i][j][k]];
               
            }
        }
    }
}


bool firstframe=FALSE;
- (int)playSound:(int)soundid{
	if(playsound&&!firstframe){
		
		if(soundid==S_LAND_SOFT||soundid==S_LAND_HARD||soundid==S_BOUNCE||soundid==S_LAVA_BURN){
			if(landingEffectTimer>0)
				return 0;
			landingEffectTimer=.3;
		}
        
        int variation;
        //type=M_STUMPY;
        if(soundid==S_FOOTSTEPS_HARD||soundid==S_FOOTSTEPS_SOFT||soundid==S_LADDER||soundid==S_VINE)
            variation=(sfxLastVariation[soundid]+1)%sfxNumVariations[soundid];
        else{
        variation=arc4random()%sfxNumVariations[soundid];
        if(variation==sfxLastVariation[soundid])
            variation=(sfxLastVariation[soundid]+1)%sfxNumVariations[soundid];
        }
        sfxLastVariation[soundid]=variation;
            
		return [[SimpleAudioEngine sharedEngine] playEffect:soundFiles[soundid][variation]];
	}
    
	
	return 0;
}
-(void)soundEvent:(int)actionid{ 
    [self soundEvent:actionid:[World getWorld].player.pos];
}
static int target_ambient;
static BOOL songisplaying=FALSE;
static int current_ambient=TYPE_NONE;
static float bkgvolume=2.0f;
static float bkgtargetvolume=0;
-(void)soundEvent:(int)actionid:(Vector)location{
    if(!playmusic||songisplaying||[World getWorld].game_mode!=GAME_MODE_PLAY)return;
    if(actionid>=-1&&actionid<NUM_AMBIENT){
        target_ambient=actionid;
    }
    if(target_ambient!=current_ambient){
        bkgtargetvolume=0.0f;
    }
    if(target_ambient!=current_ambient&&(bkgvolume==0||target_ambient==AMBIENT_UNDERWATER)){
        float distance=sqrtf(v_length2(v_sub(location,[World getWorld].player.pos)));
        float distance_fade=12.0f;
        
        if(distance>distance_fade)distance=distance_fade;
        bkgtargetvolume=2.0f*(distance_fade-distance)/distance_fade;
        if(target_ambient!=AMBIENT_RIVER&&target_ambient!=AMBIENT_OPEN)
            bkgtargetvolume*=2;
        //printf("ambient triggered:%d\n",target_ambient);
        current_ambient=target_ambient;
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        if(target_ambient!=AMBIENT_NONE)
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:ambientFiles[target_ambient]
                                                     loop:-1];
    }else if(target_ambient==current_ambient){
        float distance=sqrtf(v_length2(v_sub(location,[World getWorld].player.pos)));
        float distance_fade=12.0f;
         if(distance>distance_fade)distance=distance_fade;
        bkgtargetvolume=2.0f*(distance_fade-distance)/distance_fade;
        if(target_ambient!=AMBIENT_RIVER&&target_ambient!=AMBIENT_OPEN)
            bkgtargetvolume*=2;
    }
    
}
#define NS_BURN 300
static float burnin[NS_BURN]={};
static int sidx=0;
extern BOOL SUPPORTS_OGL2;

- (id)init{
    for(int i=0;i<SKIN_CACHE_SIZE;i++){
        skin_cache[i].tex=NULL;
    }
    for(int i=0;i<100;i++){
        door_cache[i]=NULL;
    }
    paint_cache=NULL;
    paint_cache_color=0;
    
        build_cache=NULL;
        build_cache_color=0;
    build_cache_type=0;
    
	landingEffectTimer=0;
	textures=[[NSMutableArray alloc] init];
	menutextures=[[NSMutableArray alloc] init];
	Texture2D* temp;
	if(!SUPPORTS_OGL2){
        for(int i=0;i<NUM_CREATURES;i++){
            for(int j=0;j<NUM_VO_ACTIONS;j++){
                if(voNumVariations[i][j]>3) voNumVariations[i][j]=3;
            }
        }
	}
	temp=[[Texture2D alloc]
          initWithImagePath:@"moof_icon.png" sizeToFit:FALSE];
		 
	[textures addObject:temp];
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"build.png" sizeToFit:FALSE];
	[textures addObject:temp];
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"destroy.png" sizeToFit:FALSE];
	[textures addObject:temp];
	
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"burn.png" sizeToFit:FALSE];
	[textures addObject:temp];
	
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"save.png" sizeToFit:FALSE];
	[textures addObject:temp];
	
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"cancel.png" sizeToFit:FALSE];
	[textures addObject:temp];
	
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"home.png" sizeToFit:FALSE];
	[textures addObject:temp];	
	
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"jump.png" sizeToFit:FALSE];
	[textures addObject:temp];
	

	
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"smoke_tex.png" sizeToFit:FALSE];
	[textures addObject:temp];
	
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"analog_top.png" sizeToFit:FALSE];
	[textures addObject:temp];
	
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"analog_bottom.png" sizeToFit:FALSE];
	[textures addObject:temp];
	
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"camera.png" sizeToFit:FALSE];
	[textures addObject:temp];
	
		
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"block_border.png" sizeToFit:FALSE];
	[textures addObject:temp];
	
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"block_background.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"colorpick_background.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"palette.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"block_border_pressed.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"color_border_pressed.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"color_border.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"sky_box.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"triangle_border_pressed.png" sizeToFit:FALSE];
    [textures addObject:temp];
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"triangle_border.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"build2.png" sizeToFit:FALSE];
    [textures addObject:temp];
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"build3.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"destroy_active.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"paint_active.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"build2_active.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"build3_active.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"burn_active.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"jump_depressed.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    
    extern int storedSkinCounter;
    extern int realStoredSkinCounter;
    realStoredSkinCounter=0;
    storedSkinCounter=0;
    
    temp=[[Texture2D alloc] 
		   initWithImagePath:@"Moof_Default.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"Moof_Rage.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"Moof_Blink.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    temp=[[Texture2D alloc]
		  initWithImagePath:@"Batty_Default.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc]
		  initWithImagePath:@"Batty_Rage.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc]
		  initWithImagePath:@"Batty_Blink.png" sizeToFit:FALSE];
	[textures addObject:temp];

    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"Green_Default.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"Green_Rage.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"Green_Blink.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"Nergle_Default.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"Nergle_Rage.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"Nergle_Blink.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
        
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"Stumpy_Default.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"Stumpy_Rage.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"Stumpy_Blink.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"shadow.png" sizeToFit:FALSE];
	[textures addObject:temp];
   
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"menu_icon.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"door.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"sky_box_bw.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"golden_cube.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"golden_cube_bw.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"door_mask.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"flower_tex.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"portal.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"sphere_map.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"build2_top.png" sizeToFit:FALSE];
    [textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"buildplus.png" sizeToFit:FALSE];
    [textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"uisave.png" sizeToFit:FALSE];
    [textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"uihome.png" sizeToFit:FALSE];
    [textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"uiphoto.png" sizeToFit:FALSE];
    [textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"uiexit.png" sizeToFit:FALSE];
    [textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"portal_twirl.png" sizeToFit:FALSE];
    [textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"build3_top.png" sizeToFit:FALSE];
    [textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"blocktoggle1.png" sizeToFit:FALSE];
    [textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"blocktoggle2.png" sizeToFit:FALSE];
    [textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"flower_icon.png" sizeToFit:FALSE];
    [textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"block_border2.png" sizeToFit:FALSE];
    [textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"block_border_pressed2.png" sizeToFit:FALSE];
    [textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"triangle_border2.png" sizeToFit:FALSE];
    [textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"triangle_border_pressed2.png" sizeToFit:FALSE];
    [textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"build_under2.png" sizeToFit:FALSE];
    [textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"build_over2.png" sizeToFit:FALSE];
    [textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"build2_active2.png" sizeToFit:FALSE];
    [textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"build2_under2.png" sizeToFit:FALSE];
    [textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"build3_top2.png" sizeToFit:FALSE];
    [textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"build3_active2.png" sizeToFit:FALSE];
    [textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"digits.png" sizeToFit:FALSE];
    [textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"goldcube_icon.png" sizeToFit:FALSE];
    [textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"portal_icon2.png" sizeToFit:FALSE];
    [textures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"door_icon2.png" sizeToFit:FALSE];
    [textures addObject:temp];
    
    temp=[[Texture2D alloc]
		  initWithImagePath:@"Charger_Default.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc]
		  initWithImagePath:@"Charger_Rage.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc]
		  initWithImagePath:@"Charger_Blink.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    temp=[[Texture2D alloc]
		  initWithImagePath:@"Stalker_Default.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc]
		  initWithImagePath:@"Stalker_Default.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc]
		  initWithImagePath:@"Stalker_Blink.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc]
		  initWithImagePath:@"Moof_DefaultMASK.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc]
		  initWithImagePath:@"Flame_1024b.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    temp=[[Texture2D alloc] initWithImagePath:@"text_numbers.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    temp=[[Texture2D alloc] initWithImagePath:@"paint_mask.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    temp=[[Texture2D alloc] initWithImagePath:@"goldcube_icon_mask.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc] initWithImagePath:@"flower_icon_mask.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc] initWithImagePath:@"door_icon2_mask.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc] initWithImagePath:@"portal_icon2_mask.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    temp=[[Texture2D alloc] initWithImagePath:@"goldcube_icon_active.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc] initWithImagePath:@"flower_icon_active.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc] initWithImagePath:@"door_icon2_active.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc] initWithImagePath:@"portal_icon2_active.png" sizeToFit:FALSE];
	[textures addObject:temp];
    //////////MASKS    
    extern int storedMaskCounter;
    storedMaskCounter=0;
    
    temp=[[Texture2D alloc] initWithImagePath:@"Moof_BlinkMASK.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc] initWithImagePath:@"Moof_DefaultMASK.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc] initWithImagePath:@"Batty_BlinkMASK.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc] initWithImagePath:@"Batty_DefaultMASK.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc] initWithImagePath:@"Green_BlinkMASK.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc] initWithImagePath:@"Green_DefaultMASK.png" sizeToFit:FALSE];
	[textures addObject:temp];
    
    temp=[[Texture2D alloc] initWithImagePath:@"Nergle_BlinkMASK.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc] initWithImagePath:@"Nergle_DefaultMASK.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc] initWithImagePath:@"Stumpy_BlinkMASK.png" sizeToFit:FALSE];
	[textures addObject:temp];
    temp=[[Texture2D alloc] initWithImagePath:@"Stumpy_DefaultMASK.png" sizeToFit:FALSE];
	[textures addObject:temp];
       ////////END MASKS\\\\\\\\\\
    

    
	[self loadMenuTextures];			  
	
	atlas=[[Texture2D alloc]
		   initWithImagePath:@"atlas.png" sizeToFit:TRUE pixelFormat:kTexture2DPixelFormat_RGB565 generateMips:TRUE];
    atlas2=[[Texture2D alloc]
		   initWithImagePath:@"atlas2.png" sizeToFit:TRUE pixelFormat:kTexture2DPixelFormat_RGBA8888 generateMips:TRUE];
	[textures addObject:atlas];
	
	burnSoundTimer=playing=-1;
	[[CDAudioManager sharedManager] setMode:kAMM_FxPlusMusicIfNoOtherAudio];
	
	[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:1.0];
	
	
	
	return self;
}
-(void)playMenuTune{
	if(playmusic){
		[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Eden_title.mp3"
												   loop:-1];
        bkgvolume=1.0f;
        bkgtargetvolume=1.0f;
	}
	
}

-(void)stopMenuTune{
     bkgtargetvolume=0.0f;
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
     current_ambient=target_ambient=AMBIENT_NONE;
	
}
- (void)loadMenuTextures{
	Texture2D* temp=[[Texture2D alloc] 
		  initWithImagePath:@"menu_graphics.png" sizeToFit:FALSE];
    
  
	[menutextures addObject:temp];
   	temp=[[Texture2D alloc] 
		  initWithImagePath:@"eden_menu_header.png" sizeToFit:FALSE];
   
	[menutextures addObject:temp];
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"arrow_left.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"arrow_right.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"create_world.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"delete_world.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"share_world.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"ground.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"world_selected.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"world_unselected.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"load_world.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"options.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
	
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"arrow_up.png" sizeToFit:FALSE];
	[menutextures addObject:temp];	
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"arrow_down.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"back.png" sizeToFit:FALSE];
	[menutextures addObject:temp];	
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"menu_shared_worlds.png" sizeToFit:FALSE];
	[menutextures addObject:temp];	
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"cloud_SM.png" sizeToFit:FALSE];
	[menutextures addObject:temp];	
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"menu_cancel.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
	temp=[[Texture2D alloc]
		  initWithImagePath:@"menu_health.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"menu_music.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"menu_off.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"menu_on.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"menu_options.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"menu_save.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"menu_send.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"menu_sound_effects.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"menu_text_box.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
	
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"sky.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"pinwheel.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"mountains.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"menu_text_load.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"menu_text_back.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"cloud_MD.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"cloud_LG.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
    
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"shared_world_selected.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"shared_world_unselected.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
    
    temp=[[Texture2D alloc] 
		  initWithImagePath:@"menu_fast.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"menu_best.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
	temp=[[Texture2D alloc] 
		  initWithImagePath:@"menu_creatures.png" sizeToFit:FALSE];
	[menutextures addObject:temp];
	
	
}
static float cuetimer=0;
- (void) unloadMenuTextures{
    cuetimer=0;
	while([menutextures count]>0){
		Texture2D* t=[menutextures lastObject];
		[t release];
		[menutextures removeLastObject];
	}
	
}
- (int)startedBurn:(float)length{
	if(burnSoundTimer<length){
		burnSoundTimer=length;
	}
	sidx=(sidx+1)%NS_BURN;
	burnin[sidx]=length;
	
	return sidx;
	
}
- (void)endBurnId:(int) idx{
	if(idx<0||idx>=NS_BURN)return;
	burnin[idx]=-1;
	float max=-1;
	for(int i=0;i<NS_BURN;i++){
		if(burnin[i]>max)
			max=burnin[i];
	}
	burnSoundTimer=max;
	
	if(max<=0){
		[self endBurn];
	}
	
}
-(void)stopSound:(int)soundId{
    [[SimpleAudioEngine sharedEngine] stopEffect:soundId];	
}
- (void)endBurn{
	[[SimpleAudioEngine sharedEngine] stopEffect:burn_id];	
	playing=burnSoundTimer=0;
}

#define FADE_SPEED .1f
#define TIME_BETWEEN_SONGS (60*5)
static int lastsongplayed=-1;

- (void)update:(float)etime{
    if(playmusic){
        
           
        if(bkgvolume<bkgtargetvolume){
            bkgvolume+=FADE_SPEED;
            if(bkgvolume>bkgtargetvolume)
                bkgvolume=bkgtargetvolume;
           
          
        }else if(bkgvolume>bkgtargetvolume){
            bkgvolume-=FADE_SPEED;
            if(bkgvolume<bkgtargetvolume)
                bkgvolume=bkgtargetvolume;
            
        }
        if(songisplaying){
            if(![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying]){
                songisplaying=FALSE;
                cuetimer=0;
                current_ambient=target_ambient=AMBIENT_NONE;
            }
        }else{
            cuetimer+=etime;
            if(cuetimer>TIME_BETWEEN_SONGS){
                cuetimer=0;
                int song=arc4random()%NUM_SONGS;
                if(song==lastsongplayed)song=(song+1)%NUM_SONGS;
                lastsongplayed=song;
                [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
                [[SimpleAudioEngine sharedEngine] playBackgroundMusic:songFiles[song]                
                                                                 loop:0];
                bkgvolume=1.0f;
                bkgtargetvolume=1.0f;
                songisplaying=TRUE;
            }
        }
        if([[SimpleAudioEngine sharedEngine] backgroundMusicVolume]!=bkgvolume)
          [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:bkgvolume];
        
    }
    // printf("volume:%f\n",[[SimpleAudioEngine sharedEngine] backgroundMusicVolume]);
    //fadetimer+=etime;
    //float volume=1-(sinf(fadetimer)+1.0f)/2.0f;
    //[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:volume];
	for(int i=0;i<NS_BURN;i++){
		burnin[i]-=etime;
	}
	playing-=etime;
	landingEffectTimer-=etime;
	if(burnSoundTimer>0){
		burnSoundTimer-=etime;
		
		if(burnSoundTimer<0){
			[[SimpleAudioEngine sharedEngine] stopEffect:burn_id];
		}else{
				if(playing<0)
				{
					
					burn_id=[self playSound:S_FLAMELOOP];
					playing=10;
				}
			
		}
	}
	
}

- (Texture2D*)getTex:(int)idx{	
	return [textures objectAtIndex:(0+idx)];
}
- (Texture2D*)getMenuTex:(int)idx{
	
	return [menutextures objectAtIndex:(0+idx)];
}
- (CGPoint)getBlockTex:(int)type{
	if(type<0||type>31)type=0;
	CGPoint p;	
	
    p.x=(double)type/32.0f;
    p.y=(double)1.0f/32.0f-.00001f;
	//p.x=(32.0f/1024.0f)*type+0.5f/1024.0f;
	//p.y=(32.0f/1024.0f-1.0f/1024.0f);
	
	return p;
}
- (CGPoint)getBlockTexShort:(int)type{
	if(type<0||type>31)type=0;
	CGPoint p;	
	
    p.x=type;
    p.y=1;
	//p.x=(32.0f/1024.0f)*type+0.5f/1024.0f;
	//p.y=(32.0f/1024.0f-1.0f/1024.0f);
	
	return p;
}
- (void)dealloc{
	while([textures count]>0){
		Texture2D* t=[textures lastObject];
		[t release];
		[textures removeLastObject];
	}
	while([menutextures count]>0){
		Texture2D* t=[menutextures lastObject];
		[t release];
		[menutextures removeLastObject];
	}
	[sound release];
	[super dealloc];
}


@end


