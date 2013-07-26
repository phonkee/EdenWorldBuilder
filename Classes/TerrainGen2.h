//
//  TerrainGen2.h
//  Eden
//
//  Created by Ari Ronen on 10/25/12.
//
//

#ifndef Eden_TerrainGen2_h
#define Eden_TerrainGen2_h

#define GSIZE (T_SIZE*4)
#define GEN_CWIDTH (GSIZE/CHUNK_SIZE)
#define GEN_CDEPTH (GSIZE/CHUNK_SIZE)

#define BLOCKZ_SIZE (T_HEIGHT)*(GSIZE)*(GSIZE)
#define CAP(y,max) ((y)>=(max)?(max):(y))
#define BLOCK(x,z,y) blockz[((int)(x)*(GSIZE*T_HEIGHT)+(int)(z)*(T_HEIGHT)+(int)(y))]
#define COLOR(x,z,y) colorz[((int)(x)*(GSIZE*T_HEIGHT)+(int)(z)*(T_HEIGHT)+(int)(y))]


block8* blockz;
color8* colorz;




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
void clear();
void makeCave(int xs,int zs,int ys,int sizex,int sizez,int sizey,int colorScheme);

int tg2_init();


#endif
