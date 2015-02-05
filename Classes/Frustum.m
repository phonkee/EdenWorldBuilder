//
//  Frustrum.m
//  prototype
//
//  Created by Ari Ronen on 10/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <assert.h>

#import "Frustum.h"



enum PlaneBit
{
	PLANE_X = (1<<0),
	PLANE_Y = (1<<1),
	PLANE_Z = (1<<2),
};


//static const float mElement[4][4];




void ComputeIndex(FrustumPlane* p)
{
	int index = 0;
	
	if ( p->N[0] >= 0.0f )
	{
		index|=PLANE_X;
	}
	
	if ( p->N[1] >= 0.0f )
	{
		index|=PLANE_Y;
	}
	
	if ( p->N[2] >= 0.0f )
	{
		index|=PLANE_Z;
	}
	
	switch ( index )
	{
			// x < | y < | z <
		case 0:
			
			p->mIndex[0] = 3+0;
			p->mIndex[1] = 0+0;
			
			p->mIndex[2] = 3+1;
			p->mIndex[3] = 0+1;
			
			p->mIndex[4] = 3+2;
			p->mIndex[5] = 0+2;
			
			break;
			// x >= | y < |  z <
		case 1:
			
			p->mIndex[0]    = 0+0;
			p->mIndex[1]    = 3+0;
			
			p->mIndex[2]    = 3+1;
			p->mIndex[3]    = 0+1;
			
			p->mIndex[4]    = 3+2;
			p->mIndex[5]    = 0+2;
			
			break;
			// x < | y > | z <
		case 2:
			
			p->mIndex[0]    = 3+0;
			p->mIndex[1]    = 0+0;
			
			p->mIndex[2]    = 0+1;
			p->mIndex[3]    = 3+1;
			
			p->mIndex[4]    = 3+2;
			p->mIndex[5]    = 0+2;
			
			break;
			// x > | y > | z <
		case 3:
			
			p->mIndex[0]    = 0+0;
			p->mIndex[1]    = 3+0;
			
			p->mIndex[2]    = 0+1;
			p->mIndex[3]    = 3+1;
			
			p->mIndex[4]    = 3+2;
			p->mIndex[5]    = 0+2;
			
			break;
			// x < | y < | z >
		case 4:
			
			p->mIndex[0]    = 3+0;
			p->mIndex[1]    = 0+0;
			
			p->mIndex[2]    = 3+1;
			p->mIndex[3]    = 0+1;
			
			p->mIndex[4]    = 0+2;
			p->mIndex[5]    = 3+2;
			
			break;
			// x > | y < | z >
		case 5:
			
			p->mIndex[0]    = 0+0;
			p->mIndex[1]    = 3+0;
			
			p->mIndex[2]    = 3+1;
			p->mIndex[3]    = 0+1;
			
			p->mIndex[4]    = 0+2;
			p->mIndex[5]    = 3+2;
			
			break;
			// x < | y > | z >
		case 6:
			
			p->mIndex[0]    = 3+0;
			p->mIndex[1]    = 0+0;
			
			p->mIndex[2]    = 0+1;
			p->mIndex[3]    = 3+1;
			
			p->mIndex[4]    = 0+2;
			p->mIndex[5]    = 3+2;
			
			break;
			// x > | y > | z >
		case 7:
			p->mIndex[0]  = 0+0;
			p->mIndex[1]  = 3+0;
			
			p->mIndex[2]  = 0+1;
			p->mIndex[3]  = 3+1;
			
			p->mIndex[4]  = 0+2;
			p->mIndex[5]  = 3+2;
			break;
	}	
}


void ComputeExtremes(const FrustumPlane* p,const float *source,float *minExtreme,float *maxExtreme) 
{
	const int *idx = p->mIndex;
	
	minExtreme[0] = source[ *idx++ ];
	maxExtreme[0] = source[ *idx++ ];
	
	minExtreme[1] = source[ *idx++ ];
	maxExtreme[1] = source[ *idx++ ];
	
	minExtreme[2] = source[ *idx++ ];
	maxExtreme[2] = source[ *idx   ];
}




static FrustumPlane   *m_frustumPlanes;    // view frustum
static const float    *mViewProjectionMatrix;
const float * GetViewProjectionMatrix(void) { return mViewProjectionMatrix; };
void initFrustum(void)
{
	mViewProjectionMatrix = 0;
	m_frustumPlanes = malloc(sizeof(FrustumPlane)*6);
}

void destroyFrustum(void)
{
	free(m_frustumPlanes);
}

typedef struct
{
	float mElement[4][4];
} FrustumMatrix;
//** Plane Extraction method by Klaus 'Niki' Hartman
void setFrustum(const float *viewproj)
{
	mViewProjectionMatrix = viewproj;
	FrustumMatrix* vp = (FrustumMatrix *) viewproj;
	// Left clipping plane
	m_frustumPlanes[0].N[0] = -(vp->mElement[0][3] + vp->mElement[0][0]);
	m_frustumPlanes[0].N[1] = -(vp->mElement[1][3] + vp->mElement[1][0]);
	m_frustumPlanes[0].N[2] = -(vp->mElement[2][3] + vp->mElement[2][0]);
	m_frustumPlanes[0].D   = -(vp->mElement[3][3] + vp->mElement[3][0]);
	ComputeIndex(&m_frustumPlanes[0]);
	
	// Right clipping plane
	m_frustumPlanes[1].N[0] = -(vp->mElement[0][3] - vp->mElement[0][0]);
	m_frustumPlanes[1].N[1] = -(vp->mElement[1][3] - vp->mElement[1][0]);
	m_frustumPlanes[1].N[2] = -(vp->mElement[2][3] - vp->mElement[2][0]);
	m_frustumPlanes[1].D   = -(vp->mElement[3][3] - vp->mElement[3][0]);
	ComputeIndex(&m_frustumPlanes[1]);
	
	// Top clipping plane
	m_frustumPlanes[2].N[0] = -(vp->mElement[0][3] - vp->mElement[0][1]);
	m_frustumPlanes[2].N[1] = -(vp->mElement[1][3] - vp->mElement[1][1]);
	m_frustumPlanes[2].N[2] = -(vp->mElement[2][3] - vp->mElement[2][1]);
	m_frustumPlanes[2].D   = -(vp->mElement[3][3] - vp->mElement[3][1]);
	ComputeIndex(&m_frustumPlanes[2]);
	
	// Bottom clipping plane
	m_frustumPlanes[3].N[0] = -(vp->mElement[0][3] + vp->mElement[0][1]);
	m_frustumPlanes[3].N[1] = -(vp->mElement[1][3] + vp->mElement[1][1]);
	m_frustumPlanes[3].N[2] = -(vp->mElement[2][3] + vp->mElement[2][1]);
	m_frustumPlanes[3].D   = -(vp->mElement[3][3] + vp->mElement[3][1]);
	ComputeIndex(&m_frustumPlanes[3]);
	// Near clipping plane
	//** Comments from Klaus Hartman regarding a bug in the initial release
	//** now fixed below.
	//  Hello, John,
	//I downloaded nxodf.zip last night and wanted to have a quick look at it
	//before I go to bed. Unfortunately, I don't have the latest DirectX 9
	//installed, yet, so it didn't work for me (will do that today). Instead I
	//took at quick look at the source code and detected a problem in your frustum
	//plane extraction code. It is partially my fault that people use wrong
	//extraction code for Direct3D, because I once provided an incorrect sample. I
	//tried to undo this error by writing a paper about the extraction algorithm
	//(together with Gil Gribb), even posted about it on the GD Algorithms list.
	//But there are people who missed that, so sometimes I find incorrect versions
	//of the plane extraction. So let me fix my bug in your code...
	//
	//Transforming a point P=(x, y, z, w=1) with the perspective projection matrix
	//results in a point P'=(x', y', z', w'). In OpenGL, this point is within the
	//viewing frustum, if all of the following inequalities are true:
	//
	//-w' < x' < w'
	//-w' < y' < w'
	//-w' < z' < w'
	//
	//The use of w' here already hints that the fourth column of the projection
	//matrix is involved in extracting the view frustum planes. However, these
	//inequalities are different for Direct3D:
	//
	//-w' < x' < w'
	//-w' < y' < w'
	//0 < z' < w' (different near plane)
	//
	//This means that the plane extraction is identical for OpenGL and Direct3D,
	//except for the near plane. When using Direct3D, the 4th column is not part
	//of the near plane extraction.
	//
	//This is correct for OpenGL, but not for Direct3D. For Direct3D the code
	//becomes (eliminate the use of the 4th column):
	
#if 0 // this version for OpenGL
	m_frustumPlanes[4].N[0] = -(vp->mElement[0][3] + vp->mElement[0][2]);
	m_frustumPlanes[4].N[1] = -(vp->mElement[1][3] + vp->mElement[1][2]);
	m_frustumPlanes[4].N[2] = -(vp->mElement[2][3] + vp->mElement[2][2]);
	m_frustumPlanes[4].D = -(vp->mElement[3][3] + vp->mElement[3][2]);
#else
	m_frustumPlanes[4].N[0] = -vp->mElement[0][2];
	m_frustumPlanes[4].N[1] = -vp->mElement[1][2];
	m_frustumPlanes[4].N[2] = -vp->mElement[2][2];
	m_frustumPlanes[4].D   =  -vp->mElement[3][2];
	ComputeIndex(&m_frustumPlanes[4]);
#endif
	//  Far clipping plane
	m_frustumPlanes[5].N[0] = -(vp->mElement[0][3] - vp->mElement[0][2]);
	m_frustumPlanes[5].N[1] = -(vp->mElement[1][3] - vp->mElement[1][2]);
	m_frustumPlanes[5].N[2] = -(vp->mElement[2][3] - vp->mElement[2][2]);
	m_frustumPlanes[5].D   = -(vp->mElement[3][3] - vp->mElement[3][2]);
	ComputeIndex(&m_frustumPlanes[5]);
	
}

int ComputeExtreme(const float *bound,const FrustumPlane* plane,int istate, int flag)
{
	float minExtreme[3];
	float maxExtreme[3];
		ComputeExtremes(plane,bound,minExtreme,maxExtreme);
	float d1 = plane->N[0] * minExtreme[0] + plane->N[1] * minExtreme[1] + plane->N[2] * minExtreme[2] + plane->D;
	if ( d1 > 0.0f)
	{
		istate|=(VT_INSIDE_0 | VT_INSIDE_1 | VT_INSIDE_2 | VT_INSIDE_3 | VT_INSIDE_4 | VT_INSIDE_5 | VT_OUTSIDE | VT_PARTIAL);
	}
	else
	{
		float d2 = plane->N[0] * maxExtreme[0] + plane->N[1] * maxExtreme[1] +  plane->N[2] * maxExtreme[2] + plane->D;
		if ( d2 >= 0.0f )
			istate|=VT_PARTIAL;
		else
			istate|=flag;  // inside this plane->..
	}
	return istate;
}



int ViewTestAABB(const float *bound,int state)
{
    //return VT_INSIDE;
	unsigned int istate = state;
	istate&=~VT_PARTIAL; // turn off the partial bit...
	
	if ( !(istate & VT_INSIDE_0) ) istate=ComputeExtreme(bound,&m_frustumPlanes[0],istate,VT_INSIDE_0);
	if ( !(istate & VT_INSIDE_1) ) istate=ComputeExtreme(bound,&m_frustumPlanes[1],istate,VT_INSIDE_1);
	if ( !(istate & VT_INSIDE_2) ) istate=ComputeExtreme(bound,&m_frustumPlanes[2],istate,VT_INSIDE_2);
	if ( !(istate & VT_INSIDE_3) ) istate=ComputeExtreme(bound,&m_frustumPlanes[3],istate,VT_INSIDE_3);
	if ( !(istate & VT_INSIDE_4) ) istate=ComputeExtreme(bound,&m_frustumPlanes[4],istate,VT_INSIDE_4);
	if ( !(istate & VT_INSIDE_5) ) istate=ComputeExtreme(bound,&m_frustumPlanes[5],istate,VT_INSIDE_5);
	
	if ( !(istate & VT_PARTIAL) )
		istate = VT_INSIDE;
	
	return istate;
}


void GetPlane(unsigned int index,float *plane)  // retrieve the plane equation as XYZD
{
	assert( index >= 0 && index < 6 );
	plane[0] = m_frustumPlanes[index].N[0];
	plane[1] = m_frustumPlanes[index].N[1];
	plane[2] = m_frustumPlanes[index].N[2];
	plane[3] = m_frustumPlanes[index].D;
}
