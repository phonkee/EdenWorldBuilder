//
//  Lighting.h
//  Eden
//
//  Created by Ari Ronen on 1/21/13.
//
//

#import <Foundation/Foundation.h>
#import "Vector.h"


@interface Lighting : NSObject

void calculateLighting();
void addlight(int xx,int zz,int yy,float brightness,Vector color);


@end
