//
//  TerrainGen2.h
//  Eden
//
//  Created by Ari Ronen on 10/25/12.
//
//

#ifndef Eden_TerrainGen2_h
#define Eden_TerrainGen2_h

#define GSIZE (T_SIZE*6)  //12 norm
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
void makePyramid(int x,int z,int h,int color);
void makeSkyIsland(int cx,int cz,int cy,int r);
void updateSkyColor(Player* player);
void clear();
void makeCave(int xs,int zs,int ys,int sizex,int sizez,int sizey,int colorScheme);

int tg2_init();
void tg2_render();

#endif
