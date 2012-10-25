//
//  Clouds.m
//  prototype
//
//  Created by Ari Ronen on 11/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Clouds.h"
#import "Globals.h"
#import "Terrain.h"
#import "SpecialEffects.h"
#import "Util.h"

#define n_particles 400
//static GLuint    cloudVBO;
static vertexStruct cbuffer[n_particles];
@implementation Clouds
-(id)init{
	for(int i=0;i<n_particles;i++){
		
	/*	cbuffer[i].position[0]=randf(T_SIZE*BLOCK_SIZE);
		cbuffer[i].position[2]=randf(T_SIZE*BLOCK_SIZE);
		cbuffer[i].position[1]=T_HEIGHT*BLOCK_SIZE/1.4;*/
		cbuffer[i].colors[0]=255;
		cbuffer[i].colors[1]=255;
		cbuffer[i].colors[2]=255;
		cbuffer[i].colors[3]=255;
		
			
	}
	
	return self;
}
- (void)initClouds{
	
}
- (BOOL)update: (float)etime{
	
	return FALSE;
}

- (void)render{
	//glVertexPointer(3, GL_FLOAT, sizeof(vertexStruct),cbuffer[0].position);	
	glColorPointer(4, GL_UNSIGNED_BYTE,  sizeof(vertexStruct),  cbuffer[0].colors);
	glDrawArrays(GL_POINTS, 0, n_particles);
	
}
- (void)freeClouds{
	
}
@end
