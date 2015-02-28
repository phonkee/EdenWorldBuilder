//
//  Frustrum.h
//  prototype
//
//  Created by Ari Ronen on 10/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#ifndef Eden_Frustum_h
#define Eden_Frustum_h

#import <Foundation/Foundation.h>


enum ViewTest
{
	VT_INSIDE_0        = (1<<0),      // indicates a plane that we have already tested 'inside' for and don't need to again.
	VT_INSIDE_1        = (1<<1),
	VT_INSIDE_2        = (1<<2),
	VT_INSIDE_3        = (1<<3),
	VT_INSIDE_4        = (1<<4),
	VT_INSIDE_5        = (1<<5),
	VT_OUTSIDE         = (1<<6),
	VT_INSIDE          = (1<<7),
	VT_PARTIAL         = (1<<8)
};





typedef struct{
	int             mIndex[6];
	float           N[3];
	float           D;
}FrustumPlane;

void initFrustum();
void destroyFrustum();

void setFrustum(const float *viewproj);

int ViewTestAABB(const float *bound,int state);



void GetPlane(unsigned int index,float *plane); // retrieve the plane equation as XYZD

int ComputeExtreme(const float *bound,
					const FrustumPlane* plane,int istate,int flag);


#endif
