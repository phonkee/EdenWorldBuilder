//
//  Geometry.c
//  Eden
//
//  Created by Ari Ronen on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "Geometry.h"
unsigned short allIndices[INDICES_MAX ];
GLshort cubeTexture[] = {
	
	1,1,
	1,0,
	0,1,	
	0,1,
	1,0,
	0,0,
	
	0,1,
	1,1,
	0,0,	
	0,0,
	1,1,
	1,0,
	
	0,1,
	1,1,
	0,0,	
	0,0,
	1,1,
	1,0,
	
	
	1,1,
	1,0,
	0,1,	
	0,1,
	1,0,
	0,0,
	
	
	
	0,1,
	1,1,
	0,0,	
	0,0,
	1,1,
	1,0,
	
	
	1,1,
	1,0,
	0,1,	
	0,1,
	1,0,
	0,0,	
};
GLshort liquidTexture[2*6*6]={
    1,1,
	1,0,
	0,1,	
	0,1,
	1,0,
	0,0,
	
	0,1,
	1,1,
	0,0,	
	0,0,
	1,1,
	1,0,
	
	0,1,
	1,1,
	0,0,	
	0,0,
	1,1,
	1,0,
	
	
	1,1,
	1,0,
	0,1,	
	0,1,
	1,0,
	0,0,
	
	
	
	0,1,
	1,1,
	0,0,	
	0,0,
	1,1,
	1,0,
	
	
	1,1,
	1,0,
	0,1,	
	0,1,
	1,0,
	0,0,	
};

GLshort side2ShortVertices[3*6*6];
GLshort side3ShortVertices[3*6*6];
GLshort side4ShortVertices[3*6*6];
GLshort side2Texture[2*6*6];
GLshort side3Texture[2*6*6];
GLshort side4Texture[2*6*6];
GLshort side1Texture[] = {
	
	1,1,    //front face
	1,0,
	0,1,	
	0,1,
	1,0,
	0,0,
	
	0,1,    //back face
	1,1,
	0,0,	
	0,0,
	1,1,
	1,0,
	
	1,1,    //left face
	1,0,
	0,1,	
    
	
	0,1,
    1,0,
    0,0,
	
	
    
	1,1,    //right face
	1,0,
	0,1,	
	0,1,
	1,0,
	0,0,
	
	
	
	0,1,    //bot face
	1,1,
	0,0,	
	0,0,
	1,1,
	1,0,
	
	
	1,1,    //top face
	1,0,
	0,1,	
	0,1,
	1,0,
	0,0,
};
GLshort side1ShortVertices[] = {
	-9,-9,-9, //front face
	-9,-9,-9,
	-9,-9,-9,
	-9,-9,-9,
	-9,-9,-9,
	-9,-9,-9,
    
    /* 0,0,0, //front face
     0,1,0,
     1,0,0,
     1,0,0,
     0,1,0,
     1,1,0,*/
	
	
	0,0,1, //back face
	1,0,1,	
	0,1,1,	
	0,1,1,
	1,0,1,
	1,1,1,	
	
	
	0,0,1, //left face
	0,1,1,
	1,0,0,	
	1,0,0,
	0,1,1,
	1,1,0,
	
	
	1,0,0, //right face
	1,1,0,
	1,0,1,
	1,0,1,
	1,1,0,
	1,1,1,	
	
	-9,-9,-9, //bot face
	-9,-9,-9,
	-9,-9,-9,	
	0,0,1,
	1,0,0,
	1,0,1,
	
	
	-9,-9,-9, //top face
	-9,-9,-9,
	-9,-9,-9,
	1,1,0,
	0,1,1,	
	1,1,1
};


GLshort ramp2ShortVertices[3*6*6];
GLshort ramp3ShortVertices[3*6*6];
GLshort ramp4ShortVertices[3*6*6];
GLshort ramp2Texture[2*6*6];
GLshort ramp3Texture[2*6*6];
GLshort ramp4Texture[2*6*6];

GLshort ramp1Texture[] = {
	
	1,1,//front face
	1,0,
	0,1,	
	0,1,
	1,0,
	0,0,
	
	0,1,//back face
	1,1,
	0,0,	
	0,0,
	1,1,
	1,0,
	
	0,1,//left face
	1,1,
	0,0,	
	0,1,
	1,1,
	1,0,
	
	
	1,1,//right face
	1,0,
	0,1,	
	0,1,
	1,1,
	0,0,
	
	
	
	0,1,//bot face
	1,1,
	0,0,	
	0,0,
	1,1,
	1,0,
	
	
	1,1,//top face
	1,0,
	0,1,	
	0,1,
	1,0,
	0,0,
	
	
	
	
	
	
	
};
GLshort ramp1ShortVertices[] = {
    /*	0,0,0, //front face
     0,1,0,
     1,0,0,
     1,0,0,
     0,1,0,
     1,1,0,*/
    
    -9,-9,-9, //front face
    -9,-9,-9,
    -9,-9,-9,
    -9,-9,-9,
    -9,-9,-9,
    -9,-9,-9,
	
	
	0,0,1, //back face
	1,0,1,	
	0,1,1,	
	0,1,1,
	1,0,1,
	1,1,1,	
	
	
	-9,-9,-9, //left face
	-9,-9,-9,
	-9,-9,-9,
    0,0,0,
    0,0,1,
	0,1,1,
	
	
	
	
	
	-9,-9,-9, //right face
	-9,-9,-9,
	-9,-9,-9,
	1,0,1,
	1,0,0,
	1,1,1,	
	
	0,0,0, //bot face
	1,0,0,
	0,0,1,	
	0,0,1,
	1,0,0,
	1,0,1,
	
    0,0,0, //top face
	0,1,1,
	1,0,0,
	1,0,0,
	0,1,1,	
	1,1,1
	
	
};


GLshort cubeShortVertices[] = {
	0,0,0, //front face
	0,1,0,
	1,0,0,
	1,0,0,
	0,1,0,
	1,1,0,
	
	
	0,0,1, //back face
	1,0,1,	
	0,1,1,	
	0,1,1,
	1,0,1,
	1,1,1,	
	
	
	0,0,0, //left face
	0,0,1,
	0,1,0,	
	0,1,0,
	0,0,1,
	0,1,1,
	
	
	1,0,0, //right face
	1,1,0,
	1,0,1,
	1,0,1,
	1,1,0,
	1,1,1,	
	
	0,0,0, //bot face
	1,0,0,
	0,0,1,	
	0,0,1,
	1,0,0,
	1,0,1,
	
	
	0,1,0, //top face
	0,1,1,
	1,1,0,
	1,1,0,
	0,1,1,	
	1,1,1
};

GLshort liquidCube[] = {
	0,0,0, //front face
	0,4,0,
	4,0,0,
	4,0,0,
	0,4,0,
	4,4,0,
	
	
	0,0,4, //back face
	4,0,4,	
	0,4,4,	
	0,4,4,
	4,0,4,
	4,4,4,	
	
	
	0,0,0, //left face
	0,0,4,
	0,4,0,	
	0,4,0,
	0,0,4,
	0,4,4,
	
	
	4,0,0, //right face
	4,4,0,
	4,0,4,
	4,0,4,
	4,4,0,
	4,4,4,	
	
	0,0,0, //bot face
	4,0,0,
	0,0,4,	
	0,0,4,
	4,0,0,
	4,0,4,
	
	
	0,4,0, //top face
	0,4,4,
	4,4,0,
	4,4,0,
	0,4,4,	
	4,4,4
};
/*
 const GLfloat cubeVertices[] = {
 0,0,0, //front face
 0,1,0,
 1,0,0,
 1,0,0,
 0,1,0,
 1,1,0,
 
 
 0,0,1, //back face
 1,0,1,	
 0,1,1,	
 0,1,1,
 1,0,1,
 1,1,1,	
 
 
 0,0,0, //left face
 0,0,1,
 0,1,0,	
 0,1,0,
 0,0,1,
 0,1,1,
 
 
 1,0,0, //right face
 1,1,0,
 1,0,1,
 1,0,1,
 1,1,0,
 1,1,1,	
 
 0,0,0, //bot face
 1,0,0,
 0,0,1,	
 0,0,1,
 1,0,0,
 1,0,1,
 
 
 0,1,0, //top face
 0,1,1,
 1,1,0,
 1,1,0,
 0,1,1,	
 1,1,1
 };*/
/*static short ramptopface[]={	
 0,1,0, //high left to low right
 0,1,1,
 1,0,0,
 1,0,0,
 0,1,1,	
 1,0,1,
 
 
 0,1,0, //high front to low back
 0,0,1,
 1,1,0,
 1,1,0,
 0,0,1,	
 1,0,1,
 
 
 0,0,0, //high right to low left
 0,0,1,
 1,1,0,
 1,1,0,
 0,0,1,	
 1,1,1,
 
 0,0,0, //high back to low front
 0,1,1,
 1,0,0,
 1,0,0,
 0,1,1,	
 1,1,1,
 };*/
GLubyte cubeColors[] = {
	216,216,216, 
	140,140,140,
	191,191,191,
	114,114,114,
	153,153,153,
	255,255,255,
	
    
};
GLfloat zzzzColors[] = {
	1,1,1, //front face
	1,1,1,
	1,1,1,
	1,1,1,
	1,1,1,
	1,1,1,
	
	.5f,.5f,.5f, //back face
	.5f,.5f,.5f,
	.5f,.5f,.5f,
	.5f,.5f,.5f,
	.5f,.5f,.5f,
	.5f,.5f,.5f,
    
	
	.7f,.7f,.7f, //left face
	.7f,.7f,.7f,
	.7f,.7f,.7f,
	.7f,.7f,.7f,
	.7f,.7f,.7f,
	.7f,.7f,.7f,
	
	.4f,.4f,.4f, //right face
	.4f,.4f,.4f,
	.4f,.4f,.4f,
	.4f,.4f,.4f,
	.4f,.4f,.4f,
	.4f,.4f,.4f,
	
	.3f,.3f,.3f, //bot face
	.3f,.3f,.3f,
	.3f,.3f,.3f,
	.3f,.3f,.3f,
	.3f,.3f,.3f,
	.3f,.3f,.3f,
	
	.9f,.9f,.9f, //top face
	.9f,.9f,.9f,
	.9f,.9f,.9f,
	.9f,.9f,.9f,
	.9f,.9f,.9f,
	.9f,.9f,.9f
    
	
};

GLfloat cubeNormals[] = {
	0,0,-1, //front face
	0,0,-1,
	0,0,-1,
	0,0,-1,
	0,0,-1,
	0,0,-1,	
	
	0,0,1, //back face
	0,0,1,
	0,0,1,
	0,0,1,
	0,0,1,
	0,0,1,	
	
	-1,0,0, //left face
	-1,0,0,
	-1,0,0,
	-1,0,0,
	-1,0,0,
	-1,0,0,	
	
	1,0,0, //right face
	1,0,0,
	1,0,0,
	1,0,0,
	1,0,0,
	1,0,0,	
	
	0,-1,0, //bot face
	0,-1,0,
	0,-1,0,
	0,-1,0,
	0,-1,0,
	0,-1,0,	
	
	0,1,0, //top face
	0,1,0,
	0,1,0,
	0,1,0,
	0,1,0,
	0,1,0
	
};




void tc_initGeometry(){
    
    for(int i=0;i<INDICES_MAX;i++)allIndices[i]=i;
    for(int f=0;f<6;f++)
        for(int i=0,j=0;i<6*3;i+=3,j+=2){
            int v=f*(6*3)+i;
            int v2;
            int nf=f;
            if(f==0)nf=2;
            if(f==1)nf=3;
            if(f==2)nf=1;
            if(f==3)nf=0;
            v2=nf*(6*3)+i;
            side2ShortVertices[v2]=side1ShortVertices[v+2];
            side2ShortVertices[v2+2]=-side1ShortVertices[v]+1;
            side2ShortVertices[v2+1]=side1ShortVertices[v+1];
            ramp2ShortVertices[v2]=ramp1ShortVertices[v+2];
            ramp2ShortVertices[v2+2]=-ramp1ShortVertices[v]+1;
            ramp2ShortVertices[v2+1]=ramp1ShortVertices[v+1];
            ramp2Texture[nf*(6*2)+j]=ramp1Texture[f*(6*2)+j];
            ramp2Texture[nf*(6*2)+j+1]=ramp1Texture[f*(6*2)+j+1];
            side2Texture[nf*(6*2)+j]=side1Texture[f*(6*2)+j];
            side2Texture[nf*(6*2)+j+1]=side1Texture[f*(6*2)+j+1];
            if(f==5){
                side2Texture[nf*(6*2)+j]=side1Texture[f*(6*2)+j+1];
                side2Texture[nf*(6*2)+j+1]=-side1Texture[f*(6*2)+j]+1;
            }else if(f==4){
                side2Texture[nf*(6*2)+j]=-side1Texture[f*(6*2)+j+1]+1;
                side2Texture[nf*(6*2)+j+1]=side1Texture[f*(6*2)+j];
            }
            
            nf=f;
            if(f==0)nf=1;
            if(f==1)nf=0;
            if(f==2)nf=3;
            if(f==3)nf=2;
            v2=nf*(6*3)+i;
            side3ShortVertices[v2]=-side1ShortVertices[v]+1;
            side3ShortVertices[v2+2]=-side1ShortVertices[v+2]+1;
            side3ShortVertices[v2+1]=side1ShortVertices[v+1];
            ramp3ShortVertices[v2]=-ramp1ShortVertices[v]+1;
            ramp3ShortVertices[v2+2]=-ramp1ShortVertices[v+2]+1;
            ramp3ShortVertices[v2+1]=ramp1ShortVertices[v+1];
            ramp3Texture[nf*(6*2)+j]=ramp1Texture[f*(6*2)+j];
            ramp3Texture[nf*(6*2)+j+1]=ramp1Texture[f*(6*2)+j+1];
            side3Texture[nf*(6*2)+j]=side1Texture[f*(6*2)+j];
            side3Texture[nf*(6*2)+j+1]=side1Texture[f*(6*2)+j+1];
            if(f==4||f==5){
                side3Texture[nf*(6*2)+j]=-side1Texture[f*(6*2)+j]+1;
                side3Texture[nf*(6*2)+j+1]=-side1Texture[f*(6*2)+j+1]+1;
            }
            
            nf=f;
            if(f==0)nf=3;
            if(f==1)nf=2;
            if(f==2)nf=0;
            if(f==3)nf=1;
            
            v2=nf*(6*3)+i;
            side4ShortVertices[v2]=-side1ShortVertices[v+2]+1;
            side4ShortVertices[v2+2]=side1ShortVertices[v];
            side4ShortVertices[v2+1]=side1ShortVertices[v+1];
            ramp4ShortVertices[v2]=-ramp1ShortVertices[v+2]+1;
            ramp4ShortVertices[v2+2]=ramp1ShortVertices[v];
            ramp4ShortVertices[v2+1]=ramp1ShortVertices[v+1];
            ramp4Texture[nf*(6*2)+j]=ramp1Texture[f*(6*2)+j];
            ramp4Texture[nf*(6*2)+j+1]=ramp1Texture[f*(6*2)+j+1];
            side4Texture[nf*(6*2)+j]=side1Texture[f*(6*2)+j];
            side4Texture[nf*(6*2)+j+1]=side1Texture[f*(6*2)+j+1];
            if(f==5){
                side4Texture[nf*(6*2)+j]=-side1Texture[f*(6*2)+j+1]+1;
                side4Texture[nf*(6*2)+j+1]=side1Texture[f*(6*2)+j];
            }else if(f==4){
                side4Texture[nf*(6*2)+j]=side1Texture[f*(6*2)+j+1];
                side4Texture[nf*(6*2)+j+1]=-side1Texture[f*(6*2)+j]+1;
            }
            
        }
    
}
