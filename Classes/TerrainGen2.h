//
//  TerrainGen2.h
//  Eden
//
//  Created by Ari Ronen on 10/25/12.
//
//

#ifndef Eden_TerrainGen2_h
#define Eden_TerrainGen2_h

#define BLOCKZ_SIZE (T_HEIGHT)*(T_SIZE)*(T_SIZE)
#define CAP(y,max) ((y)>=(max)?(max):(y))
#define BLOCK(x,z,y) blockz[(int)((x)*(T_SIZE*T_HEIGHT)+(z)*(T_HEIGHT)+(y))]
#define COLOR(x,z,y) colorz[(int)((x)*(T_SIZE*T_HEIGHT)+(z)*(T_HEIGHT)+(y))]








int tg2_init();


#endif
