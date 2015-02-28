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
#import "SimpleAudioEngine_objc.h"
#import "World.h"









#define NUM_SONGS 6
Resources* Resources::getResources=NULL;
static NSString* songFiles[NUM_SONGS]={
    @"Eden_1.mp3",
    @"Eden_2.mp3",
    @"Eden_3.mp3",
    @"Eden_4.mp3",
    @"Eden_5.mp3",
    @"Eden_6.mp3",
       
};

static NSString* ambientFiles[NUM_AMBIENT]={	

[AMBIENT_UNDERWATER]=@"ambience_underwater.wav",
[AMBIENT_RIVER]=@"ambience_river.wav",
[AMBIENT_LAVA]=@"ambience_lava.wav",
[AMBIENT_SKYHIGH]=@"ambience_skyhigh.wav",
[AMBIENT_CAVE]=@"ambience_cave.wav",
[AMBIENT_OPEN]=@"ambience_open.wav",
[AMBIENT_GRASSLANDS]=@"ambience_open.mp3",
[AMBIENT_BEACH]=@"beach_ambience.mp3",
[AMBIENT_GRASSBADLANDS]=@"mountain_grass_badlands_ambience.mp3",
[AMBIENT_MARSHBADLANDS]=@"river_marsh_badlands_ambience.mp3",
[AMBIENT_RIVERLANDS]=@"riverlands_ambience.mp3",
[AMBIENT_PYRAMID]=@"pyramid_ambience.mp3",
[AMBIENT_OASIS]=@"oasis_ambience.mp3",
[AMBIENT_NIGHT]=@"night_time_ambience.mp3",
[AMBIENT_MOUNTAIN]=@"mountain_ambience.mp3",
[AMBIENT_LAVABADLANDS] =@"lava_marsh_badlands_ambience.mp3",
[AMBIENT_SNOWMOUNTAIN]=@"snow_mountain_ambience.mp3",
    
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
    [S_BOUNCE]=1,
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
   
    [   S_CREATURE_VANISH]=5,
    [   S_CREATURE_PICKEDUP]=1,
    [   S_FLAMELOOP]=1,
    [   S_CAMERA]=1,
    
    [S_HIT]=3,
    [S_DOOR_OPEN]=1,
    [S_DOOR_CLOSED]=1,
    [S_FIREWORK_EXPLODE]=5,
    [S_FIREWORK_FUSE]=1,
    [S_FIREWORK_LIFTOFF]=3,
    [S_TREASURE_PICKUP]=1,
    [S_TREASURE_PLACE]=1,
    [S_DEATH_BY_CREATURE]=3,
    [S_DEATH_BY_LAVA]=3,
    [S_DEATH_BY_TNT]=3,
    [S_BUILD_METAL]=1,
    [S_BUILD_LIGHT]=1,
    [S_CHANGE_LIGHT]=1,
    [S_ENTER_PORTAL]=4,
    [S_GOOP_EXPLODE]=1,
    [S_METAL_DESTROY]=1,
    
};
static NSString* soundFiles[NUM_SOUNDS][MAX_VARIATIONS2]={	
	[S_LADDER]={@"wood_ladder_1_v2.caf",@"wood_ladder_2_v2.caf",@"wood_ladder_3_v2.caf",@"wood_ladder_4_v2.caf"},
    [S_VINE]={@"vine_ladder_1_v2.caf",@"vine_ladder_2_v2.caf",@"vine_ladder_3_v2.caf",@"vine_ladder_4_v2.caf"},
    [S_BOUNCE]={@"trampoline_block_bounce_sound.mp3"},
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
    [S_CREATURE_VANISH]={@"creature_destruction_01.mp3",@"creature_destruction_02.mp3",@"creature_destruction_03.mp3",@"creature_destruction_04.mp3",@"creature_destruction_05.mp3"},
    [S_CREATURE_PICKEDUP]={@"creature_pickedup.caf",@"creature_pickedup_2.caf",@"creature_pickedup_3.caf",@"creature_pickedup_4.caf"},
    [S_FLAMELOOP]={@"fire_loop.caf",@"x_2.caf",@"x_3.caf",@"x_4.caf"},
    [S_ICE_LOOP]={@"ice_slide.wav",@"x_2.caf",@"x_3.caf",@"x_4.caf"},

    [S_CAMERA]={@"Grab.aif",@"x_2.caf",@"x_3.caf",@"x_4.caf"},
    [S_HIT]={@"player_hit_1.caf",@"player_hit_2.caf",@"player_hit_3.caf"},
    [S_DOOR_OPEN]={@"door_open.mp3"},
    [S_DOOR_CLOSED]={@"door_close.mp3"},
    [S_FIREWORK_EXPLODE]={@"firework_explode.mp3",@"firework_explode_02.mp3",@"firework_explode_03.mp3",@"firework_explode_04.mp3",@"firework_explode_05.mp3"},
    [S_FIREWORK_FUSE]={@"firework_fuse.mp3"},
    [S_FIREWORK_LIFTOFF]={@"firework_liftoff.mp3",@"firework_liftoff_02.mp3",@"firework_liftoff_03.mp3"},
    [S_TREASURE_PICKUP]={@"treasure_cube_pickup.mp3"},
    [S_TREASURE_PLACE]={@"treasure_cube_place.mp3"},
    [S_DEATH_BY_CREATURE]={@"death_by_creature_01.mp3",@"death_by_creature_02.mp3",@"death_by_creature_03.mp3"},
    [S_DEATH_BY_LAVA]={@"death_by_lava_01.mp3",@"death_by_lava_02.mp3",@"death_by_lava_03.mp3"},
    [S_DEATH_BY_TNT]={@"death_by_tnt_01.mp3",@"death_by_tnt_02.mp3",@"death_by_tnt_03.mp3"},
    [S_BUILD_METAL]={@"metal_block_place.mp3"},
    [S_BUILD_LIGHT]={@"place_electric_light.mp3"},
    [S_CHANGE_LIGHT]={@"change_electric_light_color.mp3"},
    [S_ENTER_PORTAL]={@"go_through_portal_01.mp3",@"go_through_portal_02.mp3",@"go_through_portal_03.mp3",@"go_through_portal_04.mp3"},
    [S_GOOP_EXPLODE]={@"tnt_paint_bomb_explode.mp3"},
    [S_METAL_DESTROY]={@"metal_block_destroy.mp3"},
    
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
    
    
    [M_STALKER][VO_WALKING]={@"Moof_Walking_1.caf",@"Moof_Walking_2.caf",@"Moof_Walking_3.caf",@"Moof_Walking_4.caf",@"Moof_Walking_5.caf"},
   [M_STALKER][VO_STRETCHING]={@"Moof_Stretching_1.caf",@"Moof_Stretching_2.caf",@"Moof_Stretching_3.caf",@"Moof_Stretching_4.caf",@"Moof_Stretching_5.caf"},
    [M_STALKER][VO_SCARED]={@"Moof_Scared_1.caf",@"Moof_Scared_2.caf",@"Moof_Scared_3.caf",@"Moof_Scared_4.caf",@"Moof_Scared_5.caf"},
   [M_STALKER][VO_RELIEVED]={@"Moof_Relieved_1.caf",@"Moof_Relieved_2.caf",@"Moof_Relieved_3.caf",@"Moof_Relieved_4.caf",@"Moof_Relieved_5.caf"},
    [M_STALKER][VO_APPROACH]={@"Moof_PlayerApproaches_1.caf",@"Moof_PlayerApproaches_2.caf",@"Moof_PlayerApproaches_3.caf",@"Moof_PlayerApproaches_4.caf",@"Moof_PlayerApproaches_5.caf"},
    [M_STALKER][VO_ONFIRE]={@"creature_lit_on_fire_01.mp3",@"creature_lit_on_fire_02.mp3",@"creature_lit_on_fire_03.mp3"},
    [M_STALKER][VO_IDLE]={@"creature_idle_01.mp3",@"creature_idle_02.mp3",@"creature_idle_03.mp3"},
    [M_STALKER][VO_HIT]={@"creature_angry_hit_01.mp3",@"creature_angry_hit_02.mp3",@"creature_angry_hit_03.mp3"},
    [M_STALKER][VO_EXCITED]={@"creature_aggro_01.mp3",@"creature_aggro_02.mp3",@"creature_aggro_03.mp3"},
    [M_STALKER][VO_ANGRY]={@"creature_angry_charge_01.mp3",@"creature_angry_charge_02.mp3",@"creature_angry_charge_03.mp3"},
    
    
    [M_CHARGER][VO_WALKING]={@"Moof_Walking_1.caf",@"Moof_Walking_2.caf",@"Moof_Walking_3.caf",@"Moof_Walking_4.caf",@"Moof_Walking_5.caf"},
    [M_CHARGER][VO_STRETCHING]={@"Moof_Stretching_1.caf",@"Moof_Stretching_2.caf",@"Moof_Stretching_3.caf",@"Moof_Stretching_4.caf",@"Moof_Stretching_5.caf"},
    [M_CHARGER][VO_SCARED]={@"Moof_Scared_1.caf",@"Moof_Scared_2.caf",@"Moof_Scared_3.caf",@"Moof_Scared_4.caf",@"Moof_Scared_5.caf"},
    [M_CHARGER][VO_RELIEVED]={@"Moof_Relieved_1.caf",@"Moof_Relieved_2.caf",@"Moof_Relieved_3.caf",@"Moof_Relieved_4.caf",@"Moof_Relieved_5.caf"},
    [M_CHARGER][VO_APPROACH]={@"Moof_PlayerApproaches_1.caf",@"Moof_PlayerApproaches_2.caf",@"Moof_PlayerApproaches_3.caf",@"Moof_PlayerApproaches_4.caf",@"Moof_PlayerApproaches_5.caf"},
    [M_CHARGER][VO_ONFIRE]={@"creature_lit_on_fire_01.mp3",@"creature_lit_on_fire_02.mp3",@"creature_lit_on_fire_03.mp3"},
    [M_CHARGER][VO_IDLE]={@"creature_idle_01.mp3",@"creature_idle_02.mp3",@"creature_idle_03.mp3"},
    [M_CHARGER][VO_HIT]={@"creature_angry_hit_01.mp3",@"creature_angry_hit_02.mp3",@"creature_angry_hit_03.mp3"},
    [M_CHARGER][VO_EXCITED]={@"creature_aggro_01.mp3",@"creature_aggro_02.mp3",@"creature_aggro_03.mp3"},
    [M_CHARGER][VO_ANGRY]={@"creature_angry_charge_01.mp3",@"creature_angry_charge_02.mp3",@"creature_angry_charge_03.mp3"},
    
    
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
    
    [M_CHARGER][VO_WALKING]=3,
    [M_CHARGER][VO_STRETCHING]=2,
    [M_CHARGER][VO_SCARED]=3,
    [M_CHARGER][VO_RELIEVED]=3,
    [M_CHARGER][VO_APPROACH]=3,
    [M_CHARGER][VO_ONFIRE]=3,
    [M_CHARGER][VO_IDLE]=3,
    [M_CHARGER][VO_HIT]=3,
    [M_CHARGER][VO_EXCITED]=3,
    [M_CHARGER][VO_ANGRY]=3,
    
    [M_STALKER][VO_WALKING]=3,
    [M_STALKER][VO_STRETCHING]=2,
    [M_STALKER][VO_SCARED]=3,
    [M_STALKER][VO_RELIEVED]=3,
    [M_STALKER][VO_APPROACH]=3,
    [M_STALKER][VO_ONFIRE]=3,
    [M_STALKER][VO_IDLE]=3,
    [M_STALKER][VO_HIT]=3,
    [M_STALKER][VO_EXCITED]=3,
    [M_STALKER][VO_ANGRY]=3,
}

;

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


#define SKIN_CACHE_SIZE 200
CTexture skin_cache[SKIN_CACHE_SIZE];

Texture2D* door_cache[100];

Texture2D* paint_cache;
int paint_cache_color;
Texture2D* build_cache;
int build_cache_color;
int build_cache_type;

void clearSkinCache(){
    if(paint_cache){
        delete paint_cache;
        
        
    }
    paint_cache=NULL;
    paint_cache_color=0;
    if(build_cache){
        delete build_cache;
        
        
       
    }
    build_cache=NULL;
    build_cache_color=0;
    build_cache_type=0;
    for(int i=0;i<100;i++){
        if(i<100){
            if(door_cache[i]){
                delete door_cache[i];
                
                
                
            }
            door_cache[i]=NULL;
        }
    }
    for(int i=0;i<SKIN_CACHE_SIZE;i++){
        if(skin_cache[i].tex){
            delete skin_cache[i].tex;
            
        }
        skin_cache[i].tex=NULL;
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
Texture2D* Resources::getPaintedTex(int type,int color){
   
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
        return getTex(tid);
    }else if(build_cache!=NULL&&build_cache_color==color&&build_cache_type==type){
        return build_cache;
    }
    if(build_cache!=NULL){
        delete build_cache;
        build_cache=NULL;
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
    build_cache = new Texture2D([uiImage2 CGImage],[uiImage2 imageOrientation],FALSE,kTexture2DPixelFormat_Automatic,FALSE);
    
    //[uiImage2 release];
    printg("initing build texture ;o");
    return build_cache;
}

Texture2D* Resources::getPaintTex(int color){
    if(color==0)return getTex(ICO_PAINT);
    if(paint_cache!=NULL&&color==paint_cache_color)return paint_cache;
    
    if(paint_cache!=NULL){
        
        delete paint_cache;
        paint_cache=NULL;
    }
    
    paint_cache_color=color;
        CGImageRef img=[storedPaintMask CGImage];
        CGImageRef img2=[storedPaint CGImage];
        Vector clr=colorTable[color];
        int rgba= ((int)(255*clr.z)<<24) | ((int)(255*clr.y)<<16) | ((int)(255*clr.x) <<8)  | 0xFF;
        UIImage* uiImage2=[UIImage imageWithCGImage:ManipulateImagePixelData(img2,img,rgba)];
        //UIImage* uiImage2=[UIImage imageWithCGImage:ManipulateImagePixelData2(img,rgba,1)];
        paint_cache =
        new Texture2D([uiImage2 CGImage],[uiImage2 imageOrientation],FALSE,kTexture2DPixelFormat_Automatic,FALSE);
     //[uiImage2 release];
    printg("initing paint texture ;o");
        return paint_cache;
    
    
    
}
int Resources::getDoorTex(int color){
    if(color==0)color=25;
    if(door_cache[color]!=NULL){
        
        return door_cache[color]->name;
    }
    else{
       
        CGImageRef img=[storedDoorMask CGImage];
         CGImageRef img2=[storedDoor CGImage];
        Vector clr=colorTable[color];
        int rgba= ((int)(255*clr.z)<<24) | ((int)(255*clr.y)<<16) | ((int)(255*clr.x) <<8)  | 0xFF;
        UIImage* uiImage2=[UIImage imageWithCGImage:ManipulateImagePixelData(img2,img,rgba)];
        //UIImage* uiImage2=[UIImage imageWithCGImage:ManipulateImagePixelData2(img,rgba,1)];
        door_cache[color] =
       new Texture2D([uiImage2 CGImage],[uiImage2 imageOrientation],FALSE,kTexture2DPixelFormat_Automatic,FALSE);
       //  [uiImage2 release];
        printg("initing texture ;o");
        return door_cache[color]->name;
    }
    
    return getTex(ICO_DOOR)->name;
}
int Resources::getSkin(int model_type,int color,int state){
    for(int i=0;i<SKIN_CACHE_SIZE;i++){
        if(skin_cache[i].tex!=NULL&&skin_cache[i].model_type==model_type&&skin_cache[i].color==color&&skin_cache[i].state==state){
            return skin_cache[i].tex->name;
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
        if(skin_cache[cidx].tex){
            delete skin_cache[cidx].tex;
            
        }
        skin_cache[cidx].tex=NULL;
    }
    
    
  //  extern UIImage* storeMask;
    CGImageRef img=[storedMasks[model_type][1-state] CGImage];
    CGImageRef img2=[storedSkins[model_type][state] CGImage];
    
    Vector clr=colorTable[color];
    int rgba= ((int)(255*clr.z)<<24) | ((int)(255*clr.y)<<16) | ((int)(255*clr.x) <<8)  | 0xFF;
    UIImage* uiImage2=[UIImage imageWithCGImage:ManipulateImagePixelData(img2,img,rgba)];
    skin_cache[cidx].tex =
    new Texture2D([uiImage2 CGImage],[uiImage2 imageOrientation],FALSE,kTexture2DPixelFormat_Automatic,FALSE);
    // [uiImage2 release];
    skin_cache[cidx].model_type=model_type;
    skin_cache[cidx].color=color;
    skin_cache[cidx].state=state;
    
    printg("storing skin in cache idx: %d\n",cidx);
    return skin_cache[cidx].tex->name;
}

void Resources::voSound(int action,int type,Vector location){
    if(!playsound)return;
   
    
    
    float distance=v_length2(v_sub(location,World::getWorld->player->pos));
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
        
        [[SimpleAudioEngine sharedEngine] playEffect:voFiles[type][action][variation] loop:FALSE pitch:1.0f pan:0.0f gain:vol*1.4f];
    }
 
    
}

void Resources::loadGameAssets(){
    if(LOW_MEM_DEVICE){
        loadGameTextures();
    }
  
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
void Resources::unloadGameAssets(){
    if(LOW_MEM_DEVICE){
        unloadGameTextures();
    }
   // [World::getWorld->terrain deallocateMemory];
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
int Resources::playSound(int soundid){
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
            
        return [[SimpleAudioEngine sharedEngine] playEffect:soundFiles[soundid][variation] loop:FALSE];
	}
    
	
	return 0;
}
extern int flamecount;
void Resources::soundEvent(int actionid){
   /* if(actionid==AMBIENT_OPEN){
        actionid+=flamecount;
        if(actionid>=NUM_AMBIENT){actionid=AMBIENT_OPEN;
            flamecount=0;
        }
    }*/
    soundEvent(actionid,World::getWorld->player->pos);
}
static int target_ambient;
static BOOL songisplaying=FALSE;
static int current_ambient=TYPE_NONE;
static float bkgvolume=2.0f;
static float bkgtargetvolume=0;

void Resources::soundEvent(int actionid,Vector location){
    if(!playmusic||songisplaying||World::getWorld->game_mode!=GAME_MODE_PLAY)return;
    if(actionid>=-1&&actionid<NUM_AMBIENT){
        target_ambient=actionid;
    }
    if(target_ambient!=current_ambient){
        bkgtargetvolume=0.0f;
    }
    if(target_ambient!=current_ambient&&(bkgvolume==0||target_ambient==AMBIENT_UNDERWATER)){
        float distance=sqrtf(v_length2(v_sub(location,World::getWorld->player->pos)));
        float distance_fade=12.0f;
        
        if(distance>distance_fade)distance=distance_fade;
        bkgtargetvolume=2.0f*(distance_fade-distance)/distance_fade;
        if(target_ambient!=AMBIENT_RIVER&&target_ambient!=AMBIENT_OPEN)
            bkgtargetvolume*=2;
        //printg("ambient triggered:%d\n",target_ambient);
        current_ambient=target_ambient;
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        if(target_ambient!=AMBIENT_NONE)
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:ambientFiles[target_ambient]
                                                     loop:-1];
    }else if(target_ambient==current_ambient){
        float distance=sqrtf(v_length2(v_sub(location,World::getWorld->player->pos)));
        float distance_fade=12.0f;
         if(distance>distance_fade)distance=distance_fade;
        bkgtargetvolume=2.0f*(distance_fade-distance)/distance_fade;
        if(target_ambient!=AMBIENT_RIVER&&target_ambient!=AMBIENT_OPEN&&target_ambient<6)
            bkgtargetvolume*=2;
        if(target_ambient>=6||target_ambient==AMBIENT_OPEN){
            bkgtargetvolume*=.35f;
            if(target_ambient==AMBIENT_OASIS){
                bkgtargetvolume*=.2f;

            }
        }
    }
    
}
#define NS_BURN 300
static float burnin[NS_BURN]={};
static int sidx=0;
extern BOOL SUPPORTS_OGL2;

Resources::Resources(){
   	landingEffectTimer=0;
	//textures=[[NSMutableArray alloc] init];
	//menutextures=[[NSMutableArray alloc] init];
    textures.clear();
    menutextures.clear();
	
	if(!SUPPORTS_OGL2||LOW_MEM_DEVICE){
        for(int i=0;i<NUM_CREATURES;i++){
            for(int j=0;j<NUM_VO_ACTIONS;j++){
                if(voNumVariations[i][j]>3) voNumVariations[i][j]=3;
            }
        }
	}
	
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
    
    csbkg=new Texture2D(@"colorpick_background.png" ,FALSE);
    
    if(!LOW_MEM_DEVICE){
        loadGameTextures();
    }
   
    
	loadMenuTextures();
	
	atlas=new Texture2D(@"atlas.png" ,TRUE ,kTexture2DPixelFormat_RGB565 ,TRUE);
    atlas2=new Texture2D(@"atlas2.png",TRUE,kTexture2DPixelFormat_RGBA8888,TRUE);
	//[textures addObject:atlas];
    
	
	burnSoundTimer=playing=-1;
	[[CDAudioManager sharedManager] setMode:kAMM_FxPlusMusicIfNoOtherAudio];
	
	[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:1.0];
	
	
	
	
}
void Resources::playMenuTune(){
	if(playmusic){
		[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Eden_title.mp3"
												   loop:-1];
        bkgvolume=1.0f;
        bkgtargetvolume=1.0f;
	}
	
}

void Resources::stopMenuTune(){
     bkgtargetvolume=0.0f;
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
     current_ambient=target_ambient=AMBIENT_NONE;
	
}
void Resources::loadMenuTextures(){
	Texture2D* temp=
		  new Texture2D(@"menu_autojump.png" , FALSE);
    
    menutextures.push_back(temp);
	
   	temp=
		  new Texture2D(@"eden_menu_header.png" , FALSE);
   
	menutextures.push_back(temp);
	temp=
		  new Texture2D(@"arrow_left.png" , FALSE);
	menutextures.push_back(temp);
	temp=
		  new Texture2D(@"arrow_right.png" , FALSE);
	menutextures.push_back(temp);
	temp=
		  new Texture2D(@"create_world.png" , FALSE);
	menutextures.push_back(temp);
	temp=
		  new Texture2D(@"delete_world.png" , FALSE);
	menutextures.push_back(temp);
	temp=
		  new Texture2D(@"share_world.png" , FALSE);
	menutextures.push_back(temp);
	temp=
		  new Texture2D(@"ground.png" , FALSE);
	menutextures.push_back(temp);
	temp=
		  new Texture2D(@"world_selected.png" , FALSE);
	menutextures.push_back(temp);
	temp=
		  new Texture2D(@"world_unselected.png" , FALSE);
	menutextures.push_back(temp);
	temp=
		  new Texture2D(@"load_world.png" , FALSE);
	menutextures.push_back(temp);
	temp=
		  new Texture2D(@"options.png" , FALSE);
	menutextures.push_back(temp);
	
	temp=
		  new Texture2D(@"arrow_up.png" , FALSE);
	menutextures.push_back(temp);	
	temp=
		  new Texture2D(@"arrow_down.png" , FALSE);
	menutextures.push_back(temp);
	temp=
		  new Texture2D(@"back.png" , FALSE);
	menutextures.push_back(temp);	
	temp=
		  new Texture2D(@"menu_shared_worlds.png" , FALSE);
	menutextures.push_back(temp);	
	temp=
		  new Texture2D(@"cloud_SM.png" , FALSE);
	menutextures.push_back(temp);	
	temp=
		  new Texture2D(@"menu_cancel.png" , FALSE);
	menutextures.push_back(temp);
	temp=
		  new Texture2D(@"menu_health.png" , FALSE);
	menutextures.push_back(temp);
	temp=
		  new Texture2D(@"menu_music.png" , FALSE);
	menutextures.push_back(temp);
	temp=
		  new Texture2D(@"menu_off.png" , FALSE);
	menutextures.push_back(temp);
	temp=
		  new Texture2D(@"menu_on.png" , FALSE);
	menutextures.push_back(temp);
	temp=
		  new Texture2D(@"menu_options.png" , FALSE);
	menutextures.push_back(temp);
	temp=
		  new Texture2D(@"menu_save.png" , FALSE);
	menutextures.push_back(temp);
	temp=
		  new Texture2D(@"menu_send.png" , FALSE);
	menutextures.push_back(temp);
	temp=
		  new Texture2D(@"menu_sound_effects.png" , FALSE);
	menutextures.push_back(temp);
	temp=
		  new Texture2D(@"menu_text_box.png" , FALSE);
	menutextures.push_back(temp);
	
	temp=
		  new Texture2D(@"sky.png" , FALSE);
	menutextures.push_back(temp);
	temp=
		  new Texture2D(@"pinwheel.png" , FALSE);
	menutextures.push_back(temp);
	temp=
		  new Texture2D(@"mountains.png" , FALSE);
	menutextures.push_back(temp);
    temp=
		  new Texture2D(@"menu_text_load.png" , FALSE);
	menutextures.push_back(temp);
    temp=
		  new Texture2D(@"menu_text_back.png" , FALSE);
	menutextures.push_back(temp);
    temp=
		  new Texture2D(@"cloud_MD.png" , FALSE);
	menutextures.push_back(temp);
    temp=
		  new Texture2D(@"cloud_LG.png" , FALSE);
	menutextures.push_back(temp);
    
	temp=
		  new Texture2D(@"shared_world_selected.png" , FALSE);
	menutextures.push_back(temp);
	temp=
		  new Texture2D(@"shared_world_unselected.png" , FALSE);
	menutextures.push_back(temp);
    
    temp=
		  new Texture2D(@"menu_fast.png" , FALSE);
	menutextures.push_back(temp);
	temp=
		  new Texture2D(@"menu_best.png" , FALSE);
	menutextures.push_back(temp);
	temp=
		  new Texture2D(@"menu_creatures.png" , FALSE);
	menutextures.push_back(temp);
	
    temp=new Texture2D(@"treelayerleft.png" , FALSE);
	menutextures.push_back(temp);
    
    temp=new Texture2D(@"treelayerright.png" , FALSE);
	menutextures.push_back(temp);
    
    temp= new Texture2D(@"report_flag.png" , FALSE);
    menutextures.push_back(temp);
	
}
static float cuetimer=0;

void Resources::unloadMenuTextures(){
    cuetimer=0;
   
	while(menutextures.size()>0){
        Texture2D* t=menutextures.back();
        delete t;
        menutextures.pop_back();
	}
	
}

void Resources::unloadGameTextures(){
    if(!LOW_MEM_DEVICE){
        return;
    }
    while(textures.size()>0){
        Texture2D* t=textures.back();
        if(t!=csbkg){
            delete t;
        }
        textures.pop_back();
    }
}

void Resources::loadGameTextures(){
    clearSkinCache();
   
    
    Texture2D* temp;
  
    temp=
          new Texture2D(@"moof_icon.png",FALSE);
    
    textures.push_back(temp);
    temp=
          new Texture2D(@"build.png",FALSE);
    textures.push_back(temp);
    temp=
          new Texture2D(@"destroy.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"burn.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"save.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"cancel.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"home.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"jump.png",FALSE);
    textures.push_back(temp);
    
    
    
    temp=
          new Texture2D(@"smoke_tex.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"analog_top.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"analog_bottom.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"camera.png",FALSE);
    textures.push_back(temp);
    
    
    temp=
          new Texture2D(@"block_border.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"block_background.png",FALSE);
    textures.push_back(temp);
    
    temp=csbkg;
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"palette.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"block_border_pressed.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"color_border_pressed.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"color_border.png",FALSE);
    textures.push_back(temp);
    temp=
          new Texture2D(@"sky_box.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"triangle_border_pressed.png",FALSE);
    textures.push_back(temp);
    temp=
          new Texture2D(@"triangle_border.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"build2.png",FALSE);
    textures.push_back(temp);
    temp=
          new Texture2D(@"build3.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"destroy_active.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"paint_active.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"build2_active.png",FALSE);
    textures.push_back(temp);
    temp=
          new Texture2D(@"build3_active.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"burn_active.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"jump_depressed.png",FALSE);
    textures.push_back(temp);
    
    
    extern int storedSkinCounter;
    extern int realStoredSkinCounter;
    realStoredSkinCounter=0;
    storedSkinCounter=0;
    
    temp=
          new Texture2D(@"Moof_Default.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"Moof_Rage.png",FALSE);
    textures.push_back(temp);
    temp=
          new Texture2D(@"Moof_Blink.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"Batty_Default.png",FALSE);
    textures.push_back(temp);
    temp=
          new Texture2D(@"Batty_Rage.png",FALSE);
    textures.push_back(temp);
    temp=
          new Texture2D(@"Batty_Blink.png",FALSE);
    textures.push_back(temp);
    
    
    temp=
          new Texture2D(@"Green_Default.png",FALSE);
    textures.push_back(temp);
    temp=
          new Texture2D(@"Green_Rage.png",FALSE);
    textures.push_back(temp);
    temp=
          new Texture2D(@"Green_Blink.png",FALSE);
    textures.push_back(temp);
    
    
    temp=
          new Texture2D(@"Nergle_Default.png",FALSE);
    textures.push_back(temp);
    temp=
          new Texture2D(@"Nergle_Rage.png",FALSE);
    textures.push_back(temp);
    temp=
          new Texture2D(@"Nergle_Blink.png",FALSE);
    textures.push_back(temp);
    
    
    temp=
          new Texture2D(@"Stumpy_Default.png",FALSE);
    textures.push_back(temp);
    temp=
          new Texture2D(@"Stumpy_Rage.png",FALSE);
    textures.push_back(temp);
    temp=
          new Texture2D(@"Stumpy_Blink.png",FALSE);
    textures.push_back(temp);
    
    
    temp=
          new Texture2D(@"shadow.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"menu_icon.png",FALSE);
    textures.push_back(temp);
    temp=
          new Texture2D(@"door.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"sky_box_bw.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"golden_cube.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"golden_cube_bw.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"door_mask.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"flower_tex.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"portal.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"sphere_map.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"build2_top.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"buildplus.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"uisave.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"uihome.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"uiphoto.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"uiexit.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"portal_twirl.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"build3_top.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"blocktoggle1.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"blocktoggle2.png",FALSE);
    textures.push_back(temp);
    
    
    temp=
          new Texture2D(@"flower_icon.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"block_border2.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"block_border_pressed2.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"triangle_border2.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"triangle_border_pressed2.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"build_under2.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"build_over2.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"build2_active2.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"build2_under2.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"build3_top2.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"build3_active2.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"digits.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"goldcube_icon.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"portal_icon2.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"door_icon2.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"Charger_Default.png",FALSE);
    textures.push_back(temp);
    temp=
          new Texture2D(@"Charger_Rage.png",FALSE);
    textures.push_back(temp);
    temp=
          new Texture2D(@"Charger_Blink.png",FALSE);
    textures.push_back(temp);
    
    temp=
          new Texture2D(@"Stalker_Default.png",FALSE);
    textures.push_back(temp);
    temp=
          new Texture2D(@"Stalker_Default.png",FALSE);
    textures.push_back(temp);
    temp=
          new Texture2D(@"Stalker_Blink.png",FALSE);
    textures.push_back(temp);
    temp=
          new Texture2D(@"Moof_DefaultMASK.png",FALSE);
    textures.push_back(temp);
    if(LOW_MEM_DEVICE){
    temp=
          new Texture2D(@"Flame_256.png",FALSE);
    textures.push_back(temp);
        
    }else{
        temp=
              new Texture2D(@"Flame_512.png",FALSE);
        textures.push_back(temp);
        
    }
    
    temp=new Texture2D(@"text_numbers.png",FALSE);
    textures.push_back(temp);
    
    temp=new Texture2D(@"paint_mask.png",FALSE);
    textures.push_back(temp);
    
    temp=new Texture2D(@"goldcube_icon_mask.png",FALSE);
    textures.push_back(temp);
    temp=new Texture2D(@"flower_icon_mask.png",FALSE);
    textures.push_back(temp);
    temp=new Texture2D(@"door_icon2_mask.png",FALSE);
    textures.push_back(temp);
    temp=new Texture2D(@"portal_icon2_mask.png",FALSE);
    textures.push_back(temp);
    
    temp=new Texture2D(@"goldcube_icon_active.png",FALSE);
    textures.push_back(temp);
    temp=new Texture2D(@"flower_icon_active.png",FALSE);
    textures.push_back(temp);
    temp=new Texture2D(@"door_icon2_active.png",FALSE);
    textures.push_back(temp);
    temp=new Texture2D(@"portal_icon2_active.png",FALSE);
    textures.push_back(temp);
    //////////MASKS
    extern int storedMaskCounter;
    storedMaskCounter=0;
    
    temp=new Texture2D(@"Moof_BlinkMASK.png",FALSE);
    textures.push_back(temp);
    temp=new Texture2D(@"Moof_DefaultMASK.png",FALSE);
    textures.push_back(temp);
    temp=new Texture2D(@"Batty_BlinkMASK.png",FALSE);
    textures.push_back(temp);
    temp=new Texture2D(@"Batty_DefaultMASK.png",FALSE);
    textures.push_back(temp);
    temp=new Texture2D(@"Green_BlinkMASK.png",FALSE);
    textures.push_back(temp);
    temp=new Texture2D(@"Green_DefaultMASK.png",FALSE);
    textures.push_back(temp);
    
    temp=new Texture2D(@"Nergle_BlinkMASK.png",FALSE);
    textures.push_back(temp);
    temp=new Texture2D(@"Nergle_DefaultMASK.png",FALSE);
    textures.push_back(temp);
    temp=new Texture2D(@"Stumpy_BlinkMASK.png",FALSE);
    textures.push_back(temp);
    temp=new Texture2D(@"Stumpy_DefaultMASK.png",FALSE);
    textures.push_back(temp);
}

int Resources::startedBurn(float length){
	if(burnSoundTimer<length){
		burnSoundTimer=length;
	}
	sidx=(sidx+1)%NS_BURN;
	burnin[sidx]=length;
	
	return sidx;
	
}
void Resources::endBurnId(int idx){
	if(idx<0||idx>=NS_BURN)return;
	burnin[idx]=-1;
	float max=-1;
	for(int i=0;i<NS_BURN;i++){
		if(burnin[i]>max)
			max=burnin[i];
	}
	burnSoundTimer=max;
	
	if(max<=0){
		endBurn();
	}
	
}
void Resources::stopSound(int soundId){
    [[SimpleAudioEngine sharedEngine] stopEffect:soundId];	
}
void Resources::endBurn(){
	[[SimpleAudioEngine sharedEngine] stopEffect:burn_id];	
	playing=burnSoundTimer=0;
}

#define FADE_SPEED .1f
#define TIME_BETWEEN_SONGS (60*5)
static int lastsongplayed=-1;


void Resources::update(float etime){
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
        if([[SimpleAudioEngine sharedEngine] backgroundMusicVolume]!=bkgvolume)  //crash tally: 1
          [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:bkgvolume];
        
    }
    // printg("volume:%f\n",[[SimpleAudioEngine sharedEngine] backgroundMusicVolume]);
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
					
					burn_id=playSound(S_FLAMELOOP);
					playing=10;
				}
			
		}
	}
	
}

Texture2D* Resources::getTex(int idx){
    if(idx==ICO_COLOR_SELECT_BACKGROUND){
       return csbkg;
    }
	return textures[idx];
}

Texture2D* Resources::getMenuTex(int idx){
	
	return menutextures[idx];
}
CGPoint Resources::getBlockTex(int type){
	if(type<0||type>31)type=0;
	CGPoint p;	
	
    p.x=(double)type/32.0f;
    p.y=(double)1.0f/32.0f-.00001f;
	//p.x=(32.0f/1024.0f)*type+0.5f/1024.0f;
	//p.y=(32.0f/1024.0f-1.0f/1024.0f);
	
	return p;
}

CGPoint Resources::getBlockTexShort(int type){
	if(type<0||type>31)type=0;
	CGPoint p;	
	
    p.x=type;
    p.y=1;
	//p.x=(32.0f/1024.0f)*type+0.5f/1024.0f;
	//p.y=(32.0f/1024.0f-1.0f/1024.0f);
	
	return p;
}
Resources::~Resources(){
    while(menutextures.size()>0){
        Texture2D* t=menutextures.back();
        delete t;
        menutextures.pop_back();
    }
    while(textures.size()>0){
        Texture2D* t=textures.back();
        delete t;
        textures.pop_back();
    }

	
	//[sound release];
	
}



