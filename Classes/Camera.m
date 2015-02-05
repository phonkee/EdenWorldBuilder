//
//  Camera.m
//  prototype
//
//  Created by Ari Ronen on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Camera.h"
#import "Util.h"
#import <math.h>
#import "OpenGL_Internal.h"
#import "input.h"
#import "Frustum.h"
#import "Graphics.h"
#import "Terrain.h"

#define CAM_SPEED 4.0f
#define YAW_SPEED .5f
#define PITCH_SPEED .5f

@implementation Camera
@synthesize px,py,pz,vx,vy,vz,yaw,pitch,speed,mode,look;
- (id)init{	
	
	initFrustum();
	
	
	return self;
}
- (void)reset{
	px=py=pz=vx=vy=vz=yaw=pitch=0;
	yaw=90;
	pz=-15;
	py=25;
	px=10;
	pitch=0;
	mode=0;
	GLfloat projviewf[16];
	glGetFloatv( GL_PROJECTION_MATRIX, projviewf );
	GLfloat modelviewf[16];
	glGetFloatv( GL_MODELVIEW_MATRIX, modelviewf );
	float rview[16];
	MatrixMultiplyBy4x(projviewf,modelviewf,rview);
	setFrustum(rview);
}
- (void)dealloc{
	destroyFrustum();
	[super dealloc];
}
- (BOOL)update:(float)etime{
	//FREE Movement/ NO COLLISION DETECTION/GRAVITY
	/*Input* input=[Input getInput];
	if(input.down){
		if(input.taps>1)
		speed=CAM_SPEED*etime;
		if(input.taps>2)
			speed*=-1;
		int dx=input.mx-input.pmx;
		int dy=input.my-input.pmy;
		[input clearMove];
		if(dy!=0){
		 	yaw+=-dy*YAW_SPEED;
		}
		if(dx!=0){
			pitch+=-dx*PITCH_SPEED;
		}
	}else{
		speed=0;
	}
	if(yaw>=360)yaw-=360;
	if(yaw<=-360)yaw+=360;
	//if(pitch > 89) pitch=89;
	//if(pitch < -89) pitch=-89;
	
	float cosYaw=cos(D2R(yaw));
	float sinYaw=sin(D2R(yaw));
	float sinPitch=2*sin(D2R(pitch));
	
	px+=cosYaw*speed;
	pz+=sinYaw*speed;
	py+=sinPitch*speed;
	*/
	return FALSE;
}
- (void)move:(float)d{
	
		
}
-(void)render2{
    //NSLog(@"speed:%f",speed);
	//yaw+=1;
	float cosYaw=cos(D2R(yaw));
	float sinYaw=sin(D2R(yaw));
	
	float sinPitch=sin(D2R(pitch));
	Vector alook;
	alook.x=px+cosYaw*(1.0f-absf(sinPitch));
	alook.y=py+sinPitch;
	alook.z=pz+sinYaw*(1.0f-absf(sinPitch));
	
		
	/*glPushMatrix();
     
     // Reset and transform the matrix.
     glLoadIdentity();
     if([World getWorld].FLIPPED)
     glRotatef(90,0,0,1);
     else
     glRotatef(270,0,0,1);	
     
     gluLookAt(
     0,0,0,
     look.x-px,look.y-py,look.z-pz,
     0,1,0);
     
     [Graphics drawSkybox];
     glPopMatrix();*/
    
	if(mode==1){
		
		//glLoadIdentity();
		//glRotatef(270,0,0,1);
		
		cosYaw=cos(D2R(yaw+180));
		sinYaw=sin(D2R(yaw+180));
		/*float sinPitch=2*sin(D2R(pitch));
         float lx=px+cosYaw;
         float ly=py+sinPitch;
         float lz=pz+sinYaw;*/
		float n=8;
		gluLookAt(px+n*cosYaw, py+15, pz+n*sinYaw, px, py, pz, 0, 1, 0);	
	}else{
         gluLookAt(px, py, pz, alook.x, alook.y, alook.z, 0, 1, 0);	
        
		//gluLookAt(px-[World getWorld].fm.chunkOffsetX*CHUNK_SIZE, py, pz-[World getWorld].fm.chunkOffsetZ*CHUNK_SIZE, look.x-[World getWorld].fm.chunkOffsetX*CHUNK_SIZE, look.y, look.z-[World getWorld].fm.chunkOffsetZ*CHUNK_SIZE, 0, 1, 0);	
	}


}
- (void)render{
	//NSLog(@"speed:%f",speed);
	//yaw+=1;
	float cosYaw=cos(D2R(yaw));
	float sinYaw=sin(D2R(yaw));
	
	float sinPitch=sin(D2R(pitch));
	//printg("pitch: %f\n",pitch);
	look.x=px+cosYaw*(1.0f-absf(sinPitch));
	look.y=py+sinPitch;
	look.z=pz+sinYaw*(1.0f-absf(sinPitch));
	
	
	glPushMatrix();
	gluLookAt(px, py, pz, look.x, look.y, look.z, 0, 1, 0);	
	GLfloat projviewf[16];
	glGetFloatv( GL_PROJECTION_MATRIX, projviewf );
	GLfloat modelviewf[16];
	glGetFloatv( GL_MODELVIEW_MATRIX, modelviewf );
	float rview[16];
	MatrixMultiplyBy4x(projviewf,modelviewf,rview);
	setFrustum(rview);
	
	glPopMatrix();
	
	glPushMatrix();
	
    // Reset and transform the matrix.
    glLoadIdentity();
		
	
		gluLookAt(
			 0,0,0,
			  look.x-px,look.y-py,look.z-pz,
			  0,1,0);
	
	[Graphics drawSkybox];
	glPopMatrix();

	if(mode==1){
		
		//glLoadIdentity();
		//glRotatef(270,0,0,1);
		
		cosYaw=cos(D2R(yaw+180));
		sinYaw=sin(D2R(yaw+180));
		/*float sinPitch=2*sin(D2R(pitch));
		float lx=px+cosYaw;
		float ly=py+sinPitch;
		float lz=pz+sinYaw;*/
		float n=0.5f;
		gluLookAt(px+n*cosYaw-[World getWorld].fm.chunkOffsetX*CHUNK_SIZE, py+0.5f, pz+n*sinYaw-[World getWorld].fm.chunkOffsetZ*CHUNK_SIZE, px-[World getWorld].fm.chunkOffsetX*CHUNK_SIZE, py, pz-[World getWorld].fm.chunkOffsetZ*CHUNK_SIZE, 0, 1, 0);
	}else{
       // gluLookAt(px, py, pz, look.x, look.y, look.z, 0, 1, 0);	
        
		gluLookAt(px-[World getWorld].fm.chunkOffsetX*CHUNK_SIZE, py, pz-[World getWorld].fm.chunkOffsetZ*CHUNK_SIZE, look.x-[World getWorld].fm.chunkOffsetX*CHUNK_SIZE, look.y, look.z-[World getWorld].fm.chunkOffsetZ*CHUNK_SIZE, 0, 1, 0);
	}
		
}
@end
