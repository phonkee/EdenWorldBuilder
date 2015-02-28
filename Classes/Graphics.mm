//
//  Graphics.m
//  prototype
//
//  Created by Ari Ronen on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Graphics.h"
#import "Globals.h"
#import "Terrain.h"
#import "VectorUtil.h"

#define M_SQRT3 1.732050808
//static UIFont* thefont=NULL;//move this to resources sometime

#define CUBE_VERTICES 36
extern float SCREEN_WIDTH; 
extern float SCREEN_HEIGHT;
extern float P_ASPECT_RATIO;

extern const GLshort cubeTexture[CUBE_VERTICES*2] ;

extern const GLshort cubeShortVertices[CUBE_VERTICES*3] ;
/*
const static GLfloat skyboxVertices[]={
	// Render the front quad	
	0, 0,   0.5f, -0.5f, -0.5f ,
	1, 0,  -0.5f, -0.5f, -0.5f ,
	1, 1,  -0.5f,  0.5f, -0.5f ,
	0, 1,   0.5f,  0.5f, -0.5f ,
	
	
	// Render the left quad	
	0, 0,   0.5f, -0.5f,  0.5f ,
	1, 0,   0.5f, -0.5f, -0.5f ,
	1, 1,   0.5f,  0.5f, -0.5f ,
	0, 1,   0.5f,  0.5f,  0.5f ,
	
	
	// Render the back quad	
	0, 0,  -0.5f, -0.5f,  0.5f ,
	1, 0,   0.5f, -0.5f,  0.5f ,
	1, 1,   0.5f,  0.5f,  0.5f ,
	0, 1,  -0.5f,  0.5f,  0.5f ,
	
	
	// Render the right quad	
	0, 0,  -0.5f, -0.5f, -0.5f ,
	1, 0,  -0.5f, -0.5f,  0.5f ,
	1, 1,  -0.5f,  0.5f,  0.5f ,
	0, 1,  -0.5f,  0.5f, -0.5f ,
	
	
	// Render the top quad	
	0, 1,  -0.5f,  0.5f, -0.5f ,
	0, 0,  -0.5f,  0.5f,  0.5f ,
	1, 0,   0.5f,  0.5f,  0.5f ,
	1, 1,   0.5f,  0.5f, -0.5f ,
	
	
	// Render the bottom quad	
	0, 0,  -0.5f, -0.5f, -0.5f ,
	0, 1,  -0.5f, -0.5f,  0.5f ,
	1, 1,   0.5f, -0.5f,  0.5f ,
	1, 0,   0.5f, -0.5f, -0.5f ,
	
	
};


const static GLfloat cubeTexture12[] = {
	1, 1, 	//4
	0, 1, 	//3
	1,0,	//7  A front
	0,0, 	//8  B front
	1,1,	//5  C bottom
	0, 1, 	//3  D right
	1, 0,	//1  E right
	1, 1, 	//4  F top
	0, 0,	//2  G top
	1,0, 	//7  H left
	0,1,	//6  I left
	1,1,	//5  J bottom
	0, 0,	//2  K back
	1, 0 	//1  L back
	
};
// 1-------3-------4-------2   Cube = 8 vertices
// |  E __/|\__ A  |  H __/|   =================
// | __/   |   \__ | __/   |   Single Strip: 4 3 7 8 5 3 1 4 2 7 6 5 2 1
// |/   D  |  B   \|/   I  |   12 triangles:     A B C D E F G H I J K L
// 5-------8-------7-------6
//         |  C __/|
//         | __/   |
//         |/   J  |
//         5-------6
//         |\__ K  |
//         |   \__ |
//         |  L   \|         Left  D+E
//         1-------2        Right  H+I
//         |\__ G  |         Back  K+L
//         |   \__ |        Front  A+B
//         |  F   \|          Top  F+G
//         3-------4       Bottom  C+J
//
const static GLfloat cubeVertices12[] = {
	0.5, 0.5, 0.5 ,	//4
	-0.5, 0.5, 0.5 ,	//3
	0.5,-0.5, 0.5 ,	//7  A front
	-0.5,-0.5, 0.5 ,	//8  B front
	-0.5,-0.5,-0.5 ,	//5  C bottom
	-0.5, 0.5, 0.5 ,	//3  D right
	-0.5, 0.5,-0.5 ,	//1  E right
	0.5, 0.5, 0.5 ,	//4  F top
	0.5, 0.5,-0.5 ,	//2  G top
	0.5,-0.5, 0.5 ,	//7  H left
	0.5,-0.5,-0.5 ,	//6  I left
	-0.5,-0.5,-0.5 ,	//5  J bottom
	0.5, 0.5,-0.5 ,	//2  K back
	-0.5, 0.5,-0.5 	//1  L back
	
};

const static GLfloat cubeNormals12[] = {
	0, 0, 0 ,		//4
	0, 0, 0 ,	//3
	0, 0, 1 ,		//7  A front
	0, 0, 1 ,	//8  B front
	0, -1, 0 ,	//5  C bottom
	1, 0, 0 ,	//3  D right
	1, 0, 0 ,	//1  E right
	0, 1, 0 ,		//4  F top
	0, 1, 0 ,		//2  G top
	-1, 0, 0 ,		//7  H left
	-1, 0, 0 ,		//6  I left
	0, -1, 0 ,	//5  J bottom
	0, 0, -1 ,		//2  K back
	0, 0, -1		//1  L back
	
};*/
static vertexStruct vertices[CUBE_VERTICES];


static GLuint    vertexBuffer, vertexBuffer2;
bool changedFog=FALSE;
extern float P_ZFAR;
extern BOOL SUPPORTS_OGL2;
void Graphics::initGraphics()
{
	
	for(int f=0;f<6;f++){	
		
		for(int v=0;v<6;v++){
			int v_idx=f*6+v;
			for(int coord=0;coord<3;coord++)
			vertices[v_idx].position[coord]=cubeShortVertices[v_idx*3+coord];
			
			//front face
			//back face
			//left face
			//right face
			//bot face
			//top face
			
			vertices[v_idx].texs[0]=cubeTexture[v_idx*2];
			vertices[v_idx].texs[1]=cubeTexture[v_idx*2+1];
		}
	} 
    glGenBuffers(1, &vertexBuffer);
	glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexStruct)*CUBE_VERTICES, vertices, GL_DYNAMIC_DRAW);
	
	glGenBuffers(1, &vertexBuffer2);
	glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer2);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexStruct)*CUBE_VERTICES, vertices, GL_STATIC_DRAW);
   // glEnable(GL_LIGHTING);
	
	glEnable(GL_CULL_FACE);
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_TEXTURE_2D);
	
	glEnable(GL_COLOR_MATERIAL);
    glLineWidth(6.6f);
	glShadeModel(GL_FLAT);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);	
	//glEnableClientState(GL_NORMAL_ARRAY);
	glEnableClientState(GL_VERTEX_ARRAY);
    //if(!SUPPORTS_OGL2){
	//glFogf(GL_FOG_DENSITY,.3);
    glFogf(GL_FOG_MODE, GL_LINEAR);
	
    Vector v=MakeVector(0.6,0.6,0.9);
    
    float clr2[4]={v.x-.03f, v.y-.03f, v.z-.03f, 1.0f};
    extern Vector colorTable[256];
    if(v_equals(World::getWorld->terrain->final_skycolor,colorTable[14]))
        v=MakeVector(0.5,0.72,0.9);
        glFogfv(GL_FOG_COLOR,clr2);
        
        P_ZFAR--;
    Graphics::setZFAR(P_ZFAR+1);
        //glHint(GL_FOG_HINT,GL_NICEST);
        glFogf(GL_FOG_START, P_ZFAR-P_ZFAR/1.6f);
        glFogf(GL_FOG_END, P_ZFAR-30);
   // }
    
   
   
  
	//changedFog=TRUE:
   
	
}
void Graphics::setCameraFog(float zfar){
     zfar=190;
     changedFog=TRUE;
     P_ZFAR=zfar;
}
void Graphics::setZFAR(float zfar){

    
    if(LOW_MEM_DEVICE){
        zfar=90;
    }else if(LOW_GRAPHICS){
        zfar=115;
    }else{
        zfar=145;
    }
    changedFog=TRUE;
    if(zfar!=P_ZFAR){
        
        P_ZFAR=zfar;
        
    }
}
void Graphics::prepareMenu(){
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);  	
	glMatrixMode(GL_PROJECTION);							
	glLoadIdentity();	
	/*if(World::getWorld->FLIPPED)
	glRotatef(90,0,0,1);
	else
	glRotatef(270,0,0,1);*/
    if(IS_IPAD){
        if(IS_RETINA)
            glOrthof(0, SCREEN_WIDTH*2, 0, SCREEN_HEIGHT*2, -1, 1);
        else
        glOrthof(0, IPAD_WIDTH, 0, IPAD_HEIGHT, -1, 1);		
	}else        
     glOrthof(0, SCREEN_WIDTH, 0, SCREEN_HEIGHT, -1, 1);
    
	glMatrixMode(GL_MODELVIEW);		
    glLoadIdentity();	
	//glDisable(GL_LIGHTING);	
	glDisable(GL_DEPTH_TEST);   
    glEnable(GL_BLEND);
    glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	//glDisableClientState(GL_NORMAL_ARRAY);
}
void Graphics::endMenu(){

	glDisable(GL_BLEND);
    glEnable(GL_DEPTH_TEST);
	//glEnable(GL_LIGHTING);	
	glMatrixMode(GL_MODELVIEW);		
    glMatrixMode(GL_PROJECTION);
	//glEnableClientState(GL_NORMAL_ARRAY);
}

void Graphics::beginTerrain(){
			
	//glBindBuffer(GL_ARRAY_BUFFER, 0);
   // glDisable(GL_CULL_FACE);
   // glDisable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
    glBindTexture(GL_TEXTURE_2D, Resources::getResources->atlas->name);
    //if(!World::getWorld->hud.mode==MODE_CAMERA){
       // if(!SUPPORTS_OGL2){
    glEnable(GL_FOG);
    //if(changedFog){
        changedFog=FALSE;
    glFogf(GL_FOG_START, P_ZFAR-P_ZFAR/1.6f);
    glFogf(GL_FOG_END, P_ZFAR-30);
    
  //  }
     //   }
        
   // }
    //
    glDisable(GL_BLEND);
	glPushMatrix();
	glScalef(.25f,.25f,.25f);
    //glDisable(GL_DEPTH_TEST); 
	//glScalef(BLOCK_SIZE, BLOCK_SIZE, BLOCK_SIZE);
	//glEnable(GL_ALPHA_TEST);
	//glAlphaFunc(GL_GREATER, 0.50f);
	
}
void Graphics::endTerrain(){
	//glDisable(GL_ALPHA_TEST);
    glDisable(GL_BLEND);
    glPopMatrix();
   // if(!SUPPORTS_OGL2)
       glDisable(GL_FOG);
	//glDisable(GL_FOG);
	glDisableClientState(GL_COLOR_ARRAY);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	
}
void Graphics::endHud(){

    glDisable(GL_BLEND);
    glEnable(GL_DEPTH_TEST);
   
    
   
    
	//glEnable(GL_LIGHTING);	
	glMatrixMode(GL_MODELVIEW);		
	glPopMatrix();
    glMatrixMode(GL_PROJECTION);			
	glPopMatrix();	
	//glEnableClientState(GL_NORMAL_ARRAY);
	
}

void Graphics::beginHud(){
    
    glMatrixMode(GL_PROJECTION);			
	glPushMatrix();							
	glLoadIdentity();	
	/*if(World::getWorld->FLIPPED)
		glRotatef(90,0,0,1);
	else
		glRotatef(270,0,0,1);
	*/
   // NSLog(@"zf:%f",P_ZFAR);
    if(IS_IPAD){
        if(IS_RETINA)
            glOrthof(0, SCREEN_WIDTH*2, 0, SCREEN_HEIGHT*2, -1, P_ZFAR);
        else
            glOrthof(0, IPAD_WIDTH, 0, IPAD_HEIGHT, -1, P_ZFAR);		
	}else        
        glOrthof(0, SCREEN_WIDTH, 0, SCREEN_HEIGHT, -1, P_ZFAR);	
	glMatrixMode(GL_MODELVIEW);		
	glPushMatrix();
    glLoadIdentity();	
	//glDisable(GL_LIGHTING);	
    
    glColor4f(1.0, 1.0, 1.0, 1.0);
    
   // [[[Resources getResources] getTex:ICO_SKY_BOX] drawSky:CGRectMake(0,0, SCREEN_WIDTH,SCREEN_HEIGHT) depth:-P_ZFAR/1.000001];
    
	glDisable(GL_DEPTH_TEST);   
    glEnable(GL_BLEND);
    glBlendFunc (GL_ONE, GL_ONE);
	//glDisableClientState(GL_NORMAL_ARRAY);
}

void Graphics::prepareScene(){
	//glClearColor(.29f, .65f, .79f, 1.0f);
	glClear(GL_DEPTH_BUFFER_BIT);  
	//glClear();
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	//static int c=0;
    //if(c==0){c++;
       // printg("ar: %f, fovy:%f\n",P_ASPECT_RATIO,P_FOVY);}
	gluPerspective(P_FOVY,P_ASPECT_RATIO,P_ZNEAR,P_ZFAR-25);
	glMatrixMode(GL_MODELVIEW);		
	glLoadIdentity();
/*	if(World::getWorld->FLIPPED)
		glRotatef(90,0,0,1);
	else
		glRotatef(270,0,0,1);	*/
	
	
	
}
void Graphics::setLighting(){
	const float ambientLight[]={0.2f,0.2f,0.2f,1.0f};
	//float ambientLightModel[]={1.0f,1.0f,1.0f,1.0f};
	//glLightModelfv(GL_LIGHT_MODEL_AMBIENT,ambientLightModel);
	const float diffuseLight[]={1.0f,1.0f,1.0f,1.0f};
	const float lightPos[]={1.0f,1000.0f,300.0f,1.0f};
	glLightfv(GL_LIGHT0,GL_AMBIENT, ambientLight);
	glLightfv(GL_LIGHT0,GL_DIFFUSE, diffuseLight);
	glLightfv(GL_LIGHT0,GL_POSITION, lightPos);
	glEnable(GL_LIGHT0);
	
}


/*void Graphics::drawText(NSString* text,float x,float y){
	
	
		
	if(!thefont){
		thefont=[UIFont systemFontOfSize:12.0]	;
		[thefont retain];
	}
	

    Texture2D *textTex = new Texture2D(text,CGSizeMake(200,15.0),UITextAlignmentCenter,thefont);
	///NSLog(@"%@",textTex);
	textTex->drawAtPoint(CGPointMake(x, y),0 ,FALSE);
	
    delete textTex;
	
	
}*/
void Graphics::setPerspective(){
	glLoadIdentity();
	//GLAPI void GLAPIENTRY gluPerspective (GLdouble fovy, GLdouble aspect, GLdouble zNear, GLdouble zFar);

	//gluPerspective(60,P_ASPECT_RATIO,P_ZNEAR,P_ZFAR-25);
}


void Graphics::drawRect(float x1,float y1,float x2,float y2){
	GLfloat rectVertices[] = {
		x1	  ,y1	 ,-.5   ,
		x2    ,y1    ,-.5   ,		
		x1	  ,y2    ,-.5   ,
        x2 	  ,y2    ,-.5       
    };   
	glVertexPointer(3, GL_FLOAT, 0, rectVertices);   
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}
void Graphics::drawRectOutline(CGRect rect){
	int x1=rect.origin.x;
	int x2=rect.origin.x+rect.size.width;
	int y1=rect.origin.y;
	int y2=rect.origin.y+rect.size.height;
	GLfloat lineVertices[] = {
		x1	  ,y1	 ,-.5   ,
		x2    ,y1    ,-.5   ,		
		x2	  ,y2    ,-.5   ,
        x1 	  ,y2    ,-.5       
    };   
	glVertexPointer(3, GL_FLOAT, 0, lineVertices);   
    glDrawArrays(GL_LINE_LOOP, 0, 4);
	
}

void Graphics::drawTexCubep(float x,float y,float z,float len,Texture2D* tex){

	
	glBindTexture(GL_TEXTURE_2D, tex->name);
	glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
	glVertexPointer(3, GL_FLOAT, sizeof(vertexStruct), (void*)offsetof(vertexStruct,position));
	//glNormalPointer( GL_FLOAT, sizeof(vertexStruct),  (void*)offsetof(vertexStruct,norms));
	glTexCoordPointer(2, GL_FLOAT,  sizeof(vertexStruct),  (void*)offsetof(vertexStruct,texs));
	/*
	 glVertexPointer(3, GL_FLOAT, sizeof(vertexStruct), vertices[0].position);
	 glNormalPointer( GL_FLOAT, sizeof(vertexStruct),  vertices[0].norms);
	 glTexCoordPointer(2, GL_FLOAT,  sizeof(vertexStruct),  vertices[0].texs);*/
	
	
	
	glPushMatrix();
	
	
	glTranslatef(x, y, z);
	glScalef(len,len, len);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 14);	
	
	glPopMatrix();
	
}

void Graphics::drawTexCube(float x,float y,float z,float len,Texture2D* tex){
    
	
	glBindTexture(GL_TEXTURE_2D, tex->name);
	glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
	glVertexPointer(3, GL_FLOAT, sizeof(vertexStruct), (void*)offsetof(vertexStruct,position));
	//glNormalPointer( GL_FLOAT, sizeof(vertexStruct),  (void*)offsetof(vertexStruct,norms));
	glTexCoordPointer(2, GL_FLOAT,  sizeof(vertexStruct),  (void*)offsetof(vertexStruct,texs));
	/*
	glVertexPointer(3, GL_FLOAT, sizeof(vertexStruct), vertices[0].position);
	glNormalPointer( GL_FLOAT, sizeof(vertexStruct),  vertices[0].norms);
	glTexCoordPointer(2, GL_FLOAT,  sizeof(vertexStruct),  vertices[0].texs);*/
	
	
	   
	glPushMatrix();
	float len2=len/2;
	
	glTranslatef(x+len2, y+(BLOCK_SIZE*1.85f)/2, z+len2);
	glScalef(len, (BLOCK_SIZE*1.85f), len);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 14);	
	
	glPopMatrix();
	
}
void Graphics::startPreview(){
	glEnable(GL_BLEND);
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
   
	
	glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
	
}
void Graphics::endPreview(){
	glDisable(GL_BLEND);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}
void Graphics::drawSkybox(){
	
	glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer2);
	glColor4f(1.0, 1.0, 1.0, 1.0f);
	glDisable(GL_DEPTH_TEST);
	
	glDisable(GL_CULL_FACE);
	/*Resources* res=[Resources getResources];
	//front face
	//back face
	//left face
	//right face
	//bot face
	//top face
	//glBufferSubData(GL_ARRAY_BUFFER,0,sizeof(vertexStruct)*CUBE_VERTICES,vertices);
	glEnable(GL_TEXTURE_2D);
	 glTranslatef(-0.5f, -0.5f, -0.5f);	
	
	for(int f=0;f<6;f++){	
		if(f==0)
			//glBindTexture(GL_TEXTURE_2D, [res getTex:ICO_SKYFRONT].name);
			glBindTexture(GL_TEXTURE_2D, [res getTex:ICO_SKYSIDE].name);
		if(f==1)
			//glBindTexture(GL_TEXTURE_2D, [res getTex:ICO_SKYBACK].name);
			glBindTexture(GL_TEXTURE_2D, [res getTex:ICO_SKYSIDE].name);
		if(f==2)
			//glBindTexture(GL_TEXTURE_2D, [res getTex:ICO_SKYRIGHT].name);
			glBindTexture(GL_TEXTURE_2D, [res getTex:ICO_SKYSIDE].name);
		if(f==3)
			//glBindTexture(GL_TEXTURE_2D, [res getTex:ICO_SKYLEFT].name);
			glBindTexture(GL_TEXTURE_2D, [res getTex:ICO_SKYSIDE].name);
		if(f==4)
			glBindTexture(GL_TEXTURE_2D, [res getTex:ICO_SKYBOT].name);
		if(f==5)
			glBindTexture(GL_TEXTURE_2D, [res getTex:ICO_SKYTOP].name);
						  
			
						  
		glVertexPointer(3, GL_FLOAT, sizeof(vertexStruct), (void*)offsetof(vertexStruct,position)
						);	
						  
						  
						  
		glTexCoordPointer(2, GL_FLOAT,  sizeof(vertexStruct),  (void*)offsetof(vertexStruct,texs)
						 );
						  
						  
						  
						  
						
						  
						  
						 
					  
		 glDrawArrays(GL_TRIANGLES, f*6, 6);	
						  
						  			
	}*/
	
	
	glEnable(GL_CULL_FACE);
	glEnable(GL_DEPTH_TEST);
	
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	
}

extern const GLubyte blockColor[NUM_BLOCKS+1][3];
extern const int blockTypeFaces[NUM_BLOCKS+1][6];
extern Vector colorTable[256];
//extern GLshort cubeShortVertices[];
extern GLshort ramp2ShortVertices[3*6*6];
extern GLshort ramp3ShortVertices[3*6*6];
extern GLshort ramp4ShortVertices[3*6*6];
extern const GLshort ramp1ShortVertices[];
extern GLshort side2ShortVertices[3*6*6];
extern GLshort side3ShortVertices[3*6*6];
extern GLshort side4ShortVertices[3*6*6];
extern const GLshort side1ShortVertices[];
extern const GLfloat cubeNormals[36*3];

void Graphics::drawFirework(float x,float y,float z, int color, float scale, float rot){
   
        glBindTexture(GL_TEXTURE_2D, Resources::getResources->atlas->name);
  
	Resources* res=Resources::getResources;
	
    
	for(int f=0;f<6;f++){	
        int bf=blockTypeFaces[TYPE_CLOUD][f];
          CGPoint tp;
        tp=res->getBlockTex(bf);
        for(int v=0;v<6;v++){
			int v_idx=f*6+v;
			vertices[v_idx].texs[0]=cubeTexture[v_idx*2];
			vertices[v_idx].texs[1]=cubeTexture[v_idx*2+1]*tp.y+tp.x;
            
            for(int coord=0;coord<3;coord++){             
                 vertices[v_idx].position[coord]=cubeShortVertices[v_idx*3+coord]-.5f;                    
               
                
            } 
            Vector vc=rotateVertice(MakeVector(rot,rot,0),MakeVector( vertices[v_idx].position[0],
                                                                        vertices[v_idx].position[1],
                                                                       vertices[v_idx].position[2]));
            vertices[v_idx].position[0]=vc.x*scale+.5f;
            vertices[v_idx].position[1]=vc.y*scale+.5f;
            vertices[v_idx].position[2]=vc.z*scale+.5f;
            Vector vn=MakeVector(cubeNormals[v_idx*3],cubeNormals[v_idx*3+1],cubeNormals[v_idx*3+2]);
            
            vn=rotateVertice(MakeVector(rot,rot,0),vn);
            vertices[v_idx].normal[0]=vn.x;
            vertices[v_idx].normal[1]=vn.y;
            vertices[v_idx].normal[2]=vn.z;

            
       	}
    }
   
  
    glPushMatrix();
    if(color==0){
           glColor4ub(blockColor[TYPE_FIREWORK][0], blockColor[TYPE_FIREWORK][1], blockColor[TYPE_FIREWORK][2], 255);
    }else{   
        Vector vclr=colorTable[color];       
        glColor4f(vclr.x, vclr.y, vclr.z, 1.0f);
    }
     
              
             
        
        
  
    glBindBuffer(GL_ARRAY_BUFFER,vertexBuffer);
	glBufferSubData(GL_ARRAY_BUFFER,0,sizeof(vertexStruct)*CUBE_VERTICES,vertices);
	glVertexPointer(3, GL_FLOAT, sizeof(vertexStruct), (void*)offsetof(vertexStruct,position));	
     glNormalPointer( GL_FLOAT, sizeof(vertexObject), (void*)offsetof(vertexStruct,normal));
    glTexCoordPointer(2, GL_FLOAT,  sizeof(vertexStruct),  (void*)offsetof(vertexStruct,texs));
	
    
	
	
	
	
    //glScalef(scale,scale,scale);

	glTranslatef(x,y,z); 
    
       glDrawArrays(GL_TRIANGLES, 0, CUBE_VERTICES);	
	
    
	glPopMatrix();
    
}
void Graphics::drawCube(float x,float y,float z,int type,int buildsize){
    // printg("drawCube: %f, %f, %f\n",x,y,z);
    if(!(blockinfo[type]&IS_ATLAS2))
        glBindTexture(GL_TEXTURE_2D, Resources::getResources->atlas->name);
    else
        glBindTexture(GL_TEXTURE_2D, Resources::getResources->atlas2->name);
    
    if(type==TYPE_ICE_RAMP1||type==TYPE_STONE_RAMP1||type==TYPE_WOOD_RAMP1||type==TYPE_SHINGLE_RAMP1)
    {
        type=getRampType(x,z,y,type);
        
        
    }
 
/*	1, 1, 	//4
	0, 1, 	//3
	1,0,	//7  A front
	0,0, 	//8  B front
	1,1,	//5  C bottom
	0, 1, 	//3  D right
	1, 0,	//1  E right
	1, 1, 	//4  F top
	0, 0,	//2  G top
	1,0, 	//7  H left
	0,1,	//6  I left
	1,1,	//5  J bottom
	0, 0,	//2  K back
	1, 0 	//1  L back*/
    Resources* res=Resources::getResources;
	BOOL coloring=FALSE;
    if(type==TYPE_GRASS||type==TYPE_GRASS2||type==TYPE_GRASS3||type==TYPE_TNT||type==TYPE_BRICK||type==TYPE_VINE||type==TYPE_FIREWORK){
        if(!World::getWorld->hud->block_paintcolor)
        coloring=TRUE;
    }
    int btype=World::getWorld->terrain->getLand(x,z,y);
  //  if(buildsize==0)btype=getCustomc(x,z,y);
    if(btype!=TYPE_NONE){
       
       // type=btype;
       // coloring=FALSE;
    }else{
        btype=type;
        
    }
   // int cc=World::getWorld->hud.paintColor;
  //  Vector clr=colorTable[cc];
    Vector center=MakeVector(0,0,0);
    int count=0;
	for(int f=0;f<6;f++){	
        int bf=blockTypeFaces[type][f];
        //if(btype!=TYPE_NONE){
        //    bf=blockTypeFaces[TYPE_CLOUD][f];
       // }
        if(coloring){
            
            
            if(bf==TEX_GRASS_SIDE)
                bf=TEX_GRASS_SIDE_COLOR;
            else if(bf==TEX_TNT_SIDE)
                bf=TEX_TNT_SIDE_COLOR;
            else if(bf==TEX_TNT_TOP)
                bf=TEX_TNT_TOP_COLOR;
            else if(bf==TEX_BRICK)
                bf=TEX_BRICK_COLOR;
            
            
        }
        CGPoint tp;
        tp=res->getBlockTex(bf);
				for(int v=0;v<6;v++){
			int v_idx=f*6+v;
			vertices[v_idx].texs[0]=cubeTexture[v_idx*2];
			vertices[v_idx].texs[1]=cubeTexture[v_idx*2+1]*tp.y+tp.x;
            
            for(int coord=0;coord<3;coord++){
                if(btype>=TYPE_STONE_SIDE1&&btype<=TYPE_ICE_SIDE4){
                    if(btype%4==0){
                        vertices[v_idx].position[coord]=side1ShortVertices[v_idx*3+coord];
                    }else if((btype+1)%4==0){
                        vertices[v_idx].position[coord]=side2ShortVertices[v_idx*3+coord]; 
                    }else if((btype+2)%4==0){
                        vertices[v_idx].position[coord]=side3ShortVertices[v_idx*3+coord]; 
                    }else if((btype+3)%4==0){
                        vertices[v_idx].position[coord]=side4ShortVertices[v_idx*3+coord]; 
                    }
                    
                }else if(btype>=TYPE_STONE_RAMP1&&btype<=TYPE_ICE_RAMP4){
                    if(btype%4==0){
                        vertices[v_idx].position[coord]=ramp1ShortVertices[v_idx*3+coord];
                    }else if((btype+1)%4==0){
                        vertices[v_idx].position[coord]=ramp2ShortVertices[v_idx*3+coord]; 
                    }else if((btype+2)%4==0){
                        vertices[v_idx].position[coord]=ramp3ShortVertices[v_idx*3+coord]; 
                    }else if((btype+3)%4==0){
                        vertices[v_idx].position[coord]=ramp4ShortVertices[v_idx*3+coord]; 
                    }                
                }
                else{
                    vertices[v_idx].position[coord]=cubeShortVertices[v_idx*3+coord];                    
                }
                
            }
            if(btype>=TYPE_STONE_RAMP1&&btype<=TYPE_ICE_SIDE4){
                if(absf(vertices[v_idx].position[0])>2)continue;
                count++;
                center.x+=vertices[v_idx].position[0];
                center.y+=vertices[v_idx].position[1];
                center.z+=vertices[v_idx].position[2];
            }			
            
       	}
    }
    center.x/=count;
    center.y/=count;
    center.z/=count; 
    //NSLog(@"count:%d",count);
     if(btype>=TYPE_STONE_RAMP1&&btype<=TYPE_ICE_SIDE4)
    for(int i=0;i<CUBE_VERTICES;i++){
        vertices[i].position[0]-=center.x;
        vertices[i].position[1]-=center.y;
        vertices[i].position[2]-=center.z;
    }
        //if(type>=TYPE_BLANK_RED&&type<=TYPE_BLANK_PINK){
        //	glColor4ub(blockColor[type][0], blockColor[type][1], blockColor[type][2], 255/2);
        //}else{
    glPushMatrix();
    if(!coloring){
        if(World::getWorld->hud->block_paintcolor&&(World::getWorld->hud->mode==MODE_BUILD)){
            Vector vclr=colorTable[World::getWorld->hud->block_paintcolor];
            
            if(type==TYPE_CLOUD)
                glColor4f(vclr.x, vclr.y, vclr.z, 1.0f/6);
            else{            
                glColor4f(vclr.x, vclr.y, vclr.z, 1.0f/2);
            }
        }
        else{
        
        if(type==TYPE_CLOUD)
            glColor4ub(blockColor[type][0], blockColor[type][1], blockColor[type][2], 255/6);
        else{            
            glColor4ub(blockColor[type][0], blockColor[type][1], blockColor[type][2], 255/2);
        }
        }
    }else{
        if(type==TYPE_CLOUD)
            glColor4f(1.0f,1.0f,1.0f,0.15f);
        else {
            
            glColor4f(1.0f,1.0f,1.0f,0.5f);
        }
    }
   // glColor4f(1.0f,0.0f,0.0f,1.0f);
	//}
    glBindBuffer(GL_ARRAY_BUFFER,vertexBuffer);
	glBufferSubData(GL_ARRAY_BUFFER,0,sizeof(vertexStruct)*CUBE_VERTICES,vertices);
	
	glVertexPointer(3, GL_FLOAT, sizeof(vertexStruct), (void*)offsetof(vertexStruct,position));	
	


	glTexCoordPointer(2, GL_FLOAT,  sizeof(vertexStruct),  (void*)offsetof(vertexStruct,texs));
	
  
	
	
	
	
	if(buildsize==0){
        glScalef(.5f,.5f,.5f);
    }
	glTranslatef(x, y, z); 
   // printg("working tanslate: %f,%f,%f\n",x,y,z);
    if(buildsize==2){
        glScalef(2,2,2);
    }
    x=(int)x;
    y=(int)y;
    z=(int)z;
    if(THIRD_PERSON&&type==TYPE_CLOUD){
        glScalef(.6666f, 1.85f, .66666f);
    }else{
        glScalef(BLOCK_SIZE, BLOCK_SIZE, BLOCK_SIZE);
        if(btype!=TYPE_NONE){
            // NSLog(@"drawing on something");
            if(btype>=TYPE_STONE_RAMP1&&btype<=TYPE_ICE_SIDE4){
                glTranslatef(center.x,center.y,center.z);
                glScalef(1.01f,1.01f,1.01f);
                
                
                   
                
            }else{
                glTranslatef(-.005f,-.005f,-.005f);
                glScalef(1.01f,1.01f,1.01f);
            }
            //glDisable(GL_DEPTH_TEST); 
        }
    }
    glDrawArrays(GL_TRIANGLES, 0, CUBE_VERTICES);	
	
    
	glPopMatrix();
	
	
	
}

