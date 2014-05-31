//
//  TerrainGen2.h
//  Eden
//
//  Created by Ari Ronen on 10/25/12.
//
//

#ifndef Eden_TerrainGen2_h
#define Eden_TerrainGen2_h

#define GSIZE (T_SIZE*10)  //12 norm
#define WORM_FREQ 300
#define PYRAMID_FREQ 175
#define VOLCANO_FREQ 20
 

/*#define GSIZE (T_SIZE*6)  //12 norm
#define WORM_FREQ 80
#define PYRAMID_FREQ 80
 #define VOLCANO_FREQ 8*/


#define GEN_CWIDTH (GSIZE/CHUNK_SIZE)
#define GEN_CDEPTH (GSIZE/CHUNK_SIZE)

#define DEFAULT_LEVEL_SEED 333333

#define BLOCKZ_SIZE (T_HEIGHT)*(GSIZE)*(GSIZE)
#define CAP(y,max) ((y)>=(max)?(max):(y))
#define BLOCK(x,z,y) blockz[((int)(x)*(GSIZE*T_HEIGHT)+(int)(z)*(T_HEIGHT)+(int)(y))]
#define COLOR(x,z,y) colorz[((int)(x)*(GSIZE*T_HEIGHT)+(int)(z)*(T_HEIGHT)+(int)(y))]
#define TEMP(x,z) elevation[((int)(x)*(GSIZE)+(int)(z))]
#define TM(x,z) biomez[((int)((x)*1024/GSIZE)*(1024)+(int)((z)*1024/GSIZE))]

/*#define TM_WATER 0
#define TM_GRASS 1
#define TM_BEACH 2
#define TM_MOUNTAINS 3
#define TM_MARS 4
#define TM_RIVERS 5
#define TM_UNICORN 6
#define NUM_TERRAIN_MARKERS 7
*/

//no terrain markers
#define TM_WATER 0
#define TM_GRASS 0
#define TM_BEACH 0
#define TM_MOUNTAINS 0
#define TM_MARS 0
#define TM_RIVERS 0
#define TM_UNICORN 0
#define NUM_TERRAIN_MARKERS 1

#define NOBLOCKGEN 0



#define COLOR_RED1 1
#define COLOR_ORANGE1 2
#define COLOR_YELLOW1 3
#define COLOR_GREEN1 4
#define COLOR_CYAN1 5
#define COLOR_BLUE1 6
#define COLOR_PURPLE1  7
#define COLOR_PINK1  8
#define COLOR_BWG1  9
#define COLOR_RED2 10
#define COLOR_ORANGE2  11
#define COLOR_YELLOW2  12
#define COLOR_GREEN2  13
#define COLOR_NORMAL_BLUE  14
#define COLOR_BLUE2  15
#define COLOR_PURPLE2  16
#define COLOR_PINK2  17
#define COLOR_BWG2  18
#define COLOR_RED3  19
#define COLOR_ORANGE3  20
#define COLOR_YELLOW3  21
#define COLOR_GREEN3  22
#define COLOR_CYAN3  23
#define COLOR_BLUE3  24
#define COLOR_PURPLE3  25
#define COLOR_PINK3  26
#define COLOR_BWG3  27
#define COLOR_RED4 28
#define COLOR_ORANGE4  29
#define COLOR_YELLOW4  30
#define COLOR_GREEN4  31
#define COLOR_CYAN4  32
#define COLOR_BLUE4  33
#define COLOR_PURPLE4  34
#define COLOR_PINK4  35
#define COLOR_BWG4  36
#define COLOR_RED5 37
#define COLOR_ORANGE5  38
#define COLOR_YELLOW5  39
#define COLOR_GREEN5  40
#define COLOR_CYAN5  41
#define COLOR_BLUE5  42
#define COLOR_PURPLE5  43
#define COLOR_PINK5  44
#define COLOR_BWG5  45
#define COLOR_RED6 46
#define COLOR_ORANGE6  47
#define COLOR_YELLOW6  48
#define COLOR_GREEN6  49
#define COLOR_CYAN6  50
#define COLOR_BLUE6  51
#define COLOR_PURPLE6  52
#define COLOR_PINK6  53
#define COLOR_BWG6  54


void makeDirt();
void makeMars();
void makeRiverTrees(int sx,int sz,int ex,int ez,int SEED);
void makeMountains(int sx,int sz,int ex,int ez,int SEED);
void makeTransition(int sx,int sz,int ex,int ez);
void makeDesert();
void makeBeach();
void makePonies();
void makeMix();
void makeVolcano();
void makeGreenHills(int height);
void makeClassicGen();
void makePyramid2(int x,int z,int h,int color, int sy);
void makePyramid(int x,int z,int h,int color);
void makeSkyIsland(int cx,int cz,int cy,int r);
void updateSkyColor(Player* player);
void clear();
void makeCave(int xs,int zs,int ys,int sizex,int sizez,int sizey,int colorScheme);

int tg2_init();
void tg2_render();

#endif
