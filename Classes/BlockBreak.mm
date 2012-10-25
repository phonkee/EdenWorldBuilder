//
//  BlockBreak.m
//  prototype
//
//  Created by Ari Ronen on 11/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
extern "C" {
#import "BlockBreak.h"
#import "Globals.h"
#import "Terrain.h"
#import "Graphics.h"
}
#import "PVRTVector.h"
//#import "SpecialEffects.h"

#define BREAKP 10
#define VANISHP 60
#define EXPP 1
#define pbuffer_size2 4000
#define max_bparticles pbuffer_size2

#define PT_GRAV 0
#define PT_NOGRAV 1
#define PT_FIREWORK 2
static unsigned short pindices[max_bparticles];
static vertexpBreak pbuffer2[pbuffer_size2];
static vertexpBreak trails[pbuffer_size2];
static int trail_count;
static int pvbi_counter2;

typedef struct{
	Vector pos;
	int pvbi; //particle vertex buffer index
	float vx,vy,vz;	
    int type;
    float size;    
    float rx,rz;
    float vrx,vrz;
}particle;

typedef struct _cnode{
	particle particles[VANISHP];
    int n_particles;
	float life;
    float start_life;
}cnode;



@implementation BlockBreak

static cnode list[max_bparticles];
static int list_size;

static int num_particles;
static int num_vertices;
static BOOL updateIndexes;
static Vector polyp[4];
static Vector polyn[4];
static Vector polyf[4][3];
static Vector polyfn[4][3];
static const float SPEED=2.5;
static const float SPEEDY=10;
const float LIFE=2.0f;
void mf(int i,int p1,int p2,int p3){
    polyf[i][0]=polyp[p1];
    polyf[i][1]=polyp[p2];
    polyf[i][2]=polyp[p3];
    polyfn[i][0]=polyn[p1];
    polyfn[i][1]=polyn[p2];
    polyfn[i][2]=polyn[p3];
}
-(id) init{
	
    trail_count=0;
	updateIndexes=TRUE;
	num_particles=num_vertices=0;
    list_size=0;
    memset(pbuffer2,0,sizeof(vertexpBreak)*pbuffer_size2);
	pvbi_counter2=0;
    polyp[0]=MakeVector(0,.816f,0);
    polyp[1]=MakeVector(0,-.816f,.816f);
    polyp[2]=MakeVector(-.816f,-.816f,-.816f);
    polyp[3]=MakeVector(.816f,-.816f,-.816f);
    
    for(int i=0;i<4;i++){
        polyn[i]=polyp[i];
        NormalizeVector(&polyn[i]);
    }
    mf(0,0,2,1);
    mf(1,0,1,3);
    mf(2,0,3,2);
    mf(3,1,2,3);

	return self;
}

- (int)update: (float)etime{
    trail_count=0;
	for(int k=0;k<list_size;k++){
       
		//float tetime=LIFE-node.life;
		for(int i=0;i<list[k].n_particles;i++){
           
			list[k].particles[i].pos.x+=list[k].particles[i].vx*etime;
			list[k].particles[i].pos.y+=list[k].particles[i].vy*etime;			
			list[k].particles[i].pos.z+=list[k].particles[i].vz*etime;
            if(list[k].particles[i].type==PT_GRAV){
                list[k].particles[i].vy-=60*etime;
            }
            list[k].particles[i].rx+=list[k].particles[i].vrx*etime;
            list[k].particles[i].rz+=list[k].particles[i].vrz*etime;
            particle p1=list[k].particles[i];
            if(p1.vy<0&&getLandc(p1.pos.x,p1.pos.z,p1.pos.y-p1.size*.716f)>0){
                float np=(int)(p1.pos.y-p1.size*.716f)+1+p1.size*.716f;
                if(np-p1.pos.y<.5f){
                    list[k].particles[i].pos.y=np;
                    list[k].particles[i].vy=0;
                    list[k].particles[i].vx*=.7f;
                    list[k].particles[i].vz*=.7f;
                    list[k].particles[i].vrx*=.7f;
                    list[k].particles[i].vrz*=.7f;
                }
                
                //node.particles[i].rx*=0;
                //node.particles[i].rz*=0;
            }
			
			//pbuffer2[node.particles[i].pvbi].position[0]=node.particles[i].pos.x;
           // pbuffer2[node.particles[i].pvbi].position[1]=node.particles[i].pos.y;
         //   pbuffer2[node.particles[i].pvbi].position[2]=node.particles[i].pos.z;
             particle p=list[k].particles[i];
            float rsize=p.size;
            if(list[k].life<LIFE/2){
                rsize*=list[k].life/(LIFE/2);
            }
            PVRTMat4 rot= PVRTMat4::RotationX(p.rx)*PVRTMat4::RotationZ(p.rz);
            for (int f=0;f<4;f++){
                for(int v=0;v<3;v++){
                    
                    PVRTVec4 vec=
                   rot*
                    PVRTVec4(polyf[f][v].x*rsize,polyf[f][v].y*rsize,polyf[f][v].z*rsize,1);
                                                                                   
                    pbuffer2[p.pvbi+f*3+v].position[0]=p.pos.x+vec.x;
                     pbuffer2[p.pvbi+f*3+v].position[1]=p.pos.y+vec.y;
                     pbuffer2[p.pvbi+f*3+v].position[2]=p.pos.z+vec.z;
                    
                    
                    vec=rot* PVRTVec4(polyfn[f][v].x,polyfn[f][v].y,polyfn[f][v].z,1);
                    pbuffer2[p.pvbi+f*3+v].normal[0]=vec.x;
                    pbuffer2[p.pvbi+f*3+v].normal[1]=vec.y;
                    pbuffer2[p.pvbi+f*3+v].normal[2]=vec.z;
                     
                }
                
                    
            }
            if(p.type==PT_FIREWORK){
                if(trail_count<pbuffer_size2-2){
                    float elapsed=list[k].start_life-list[k].life;
                    if(elapsed>list[k].life)
                        elapsed=list[k].life;
                    if(elapsed>.5f)elapsed=.5f;
                    trails[trail_count].position[0]=p.pos.x;
                    trails[trail_count].position[1]=p.pos.y;
                    trails[trail_count].position[2]=p.pos.z;
                    trails[trail_count].colors[0]= pbuffer2[p.pvbi].colors[0];   
                    trails[trail_count].colors[1]= pbuffer2[p.pvbi].colors[1];
                    trails[trail_count].colors[2]= pbuffer2[p.pvbi].colors[2];
                    trails[trail_count].colors[3]= pbuffer2[p.pvbi].colors[3];
                    
                    trail_count++;
                    trails[trail_count].position[0]=p.pos.x-p.vx*elapsed;
                    trails[trail_count].position[1]=p.pos.y-p.vy*elapsed;
                    trails[trail_count].position[2]=p.pos.z-p.vz*elapsed;
                    trails[trail_count].colors[0]= pbuffer2[p.pvbi].colors[0];   
                    trails[trail_count].colors[1]= pbuffer2[p.pvbi].colors[1];
                    trails[trail_count].colors[2]= pbuffer2[p.pvbi].colors[2];
                    trails[trail_count].colors[3]= 0;
                    
                    trail_count++;
                }
                
                
                
            }
            
		}
		list[k].life-=etime;
		if(list[k].life<=0){
            [self removeNode:k]; 
						
		}
	}
	
	
	if(updateIndexes){
        
		num_particles=0;
        num_vertices=0;
		for(int k=0;k<list_size;k++)	
			for(int i=0;i<list[k].n_particles;i++){
                for(int j=0;j<12;j++)
                    pindices[num_particles*12+j]=list[k].particles[i].pvbi+j;
				
                num_particles++;
                num_vertices+=12;
			}			
        
    }		
	
    updateIndexes=FALSE;

return FALSE;
}
-(void)removeNode:(int)idx{
   
    updateIndexes=TRUE;
    num_particles-=list[idx].n_particles;
    num_vertices-=12*list[idx].n_particles;
    
    if(idx!=list_size-1){
        list[idx]=list[list_size-1];
        
    }
    list_size--;
	
    
}
static PVRTVec4 lightPosition = PVRTVec4(0.0f,0.0f, 0.0f, 1.0f);
static PVRTVec4 lightAmbient  = PVRTVec4(0.3f, 0.3f, 0.3f, 1.0f);
static PVRTVec4 lightDiffuse  = PVRTVec4(0.7f, 0.7f, 0.7f, 1.0f);
- (void)render{ 
    
   // glEnable(GL_TEXTURE_2D);
   // glEnable(GL_SMOOTH);
    glMatrixMode(GL_TEXTURE);
    glScalef(1,1.0f/32.0f,1);
    glEnable(GL_LIGHTING);
    
    //PVRTVec4 lightSpecular = PVRTVec4(0.2f, 0.2f, 0.2f, 1.0f);
    
    glEnable(GL_LIGHT0);
    glPushMatrix();
    glLoadIdentity();
    glLightfv(GL_LIGHT0, GL_POSITION, lightPosition.ptr());
    glPopMatrix();
    glLightfv(GL_LIGHT0, GL_AMBIENT,  lightAmbient.ptr());
    glLightfv(GL_LIGHT0, GL_DIFFUSE,  lightDiffuse.ptr());
    glEnable(GL_NORMALIZE);
     glBindTexture(GL_TEXTURE_2D, [Resources getResources].atlas.name);
	
     glEnableClientState(GL_NORMAL_ARRAY);
    //glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    //glEnableClientState(GL_COLOR_ARRAY);
    glNormalPointer(GL_FLOAT, sizeof(vertexpBreak),pbuffer2[0].normal);	
    glVertexPointer(3, GL_FLOAT, sizeof(vertexpBreak),pbuffer2[0].position);	
	glColorPointer(4, GL_UNSIGNED_BYTE,  sizeof(vertexpBreak),  pbuffer2[0].colors);
    glTexCoordPointer(2, GL_SHORT,  sizeof(vertexpBreak), pbuffer2[0].texs);
   // glDisable(GL_CULL_FACE);
    // glEnableClientState(GL_TEXTURE_COORD_ARRAY);
   // glColor4f(1.0f,1,1,1.0f);
  
	glDrawElements(GL_TRIANGLES,num_particles*12,GL_UNSIGNED_SHORT,pindices);
    glScalef(1,32.0f,1);
    glMatrixMode(GL_MODELVIEW);

    glDisableClientState(GL_NORMAL_ARRAY);

	// glEnable(GL_CULL_FACE);
   // glEnable(GL_TEXTURE_2D);
    glDisable(GL_LIGHT0);
     glDisable(GL_LIGHTING);
     //glDisable(GL_SMOOTH);
	 glDisable(GL_NORMALIZE);
    
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glShadeModel(GL_SMOOTH);
    glEnable(GL_BLEND);
      glVertexPointer(3, GL_FLOAT, sizeof(vertexpBreak),trails[0].position);	
	glColorPointer(4, GL_UNSIGNED_BYTE,  sizeof(vertexpBreak),  trails[0].colors);
   
    // glDisable(GL_CULL_FACE);
    // glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    // glColor4f(1.0f,1,1,1.0f);
    
    glDrawArrays(GL_LINES,0, trail_count);
    glDisable(GL_BLEND);
	glShadeModel(GL_FLAT);
    
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    
    glEnable(GL_TEXTURE_2D);
	//glEnable(GL_TEXTURE_2D);
}





static int getPVBI2(){
    
	pvbi_counter2+=12;
	if(pvbi_counter2+12>=pbuffer_size2){
		pvbi_counter2=0;	
	}
   
	return pvbi_counter2;
}
extern Vector colorTable[256];
extern const GLubyte blockColor[NUM_BLOCKS+1][3];
extern const GLubyte creatureColor[NUM_CREATURES][3];
extern const int blockTypeFaces[NUM_BLOCKS+1][6];
- (void)addBlockExplode:(int)x:(int)z:(int)y:(int)type:(int)color{
    if(type<=0)return;
	while(num_particles*12+EXPP*12>max_bparticles){
		[self removeNode:arc4random()%list_size];
	}
	    //NSLog(@"%d %d type:%d",x,z,type);
	cnode p;
    p.n_particles=EXPP;
    num_particles+=p.n_particles;
    num_vertices+=12*p.n_particles;

	//p.next=NULL;
	for(int i=0;i<p.n_particles;i++){		
		
		p.particles[i].pos.x=x*BLOCK_SIZE+BLOCK_SIZE/2;
		p.particles[i].pos.y=y*BLOCK_SIZE+BLOCK_SIZE/2;
		p.particles[i].pos.z=z*BLOCK_SIZE+BLOCK_SIZE/2;
		int dx=(arc4random()%200-100);
		int dz=(arc4random()%200-100);
		int dy=(arc4random()%25)+5;
		p.particles[i].vx=dx/100.0f*SPEED*2;
		p.particles[i].vz=dz/100.0f*SPEED*2;
		p.particles[i].vy=dy/25.0f*SPEEDY*4;	
        
        p.particles[i].rx=randf(6.28);
        p.particles[i].rz=randf(6.28);
        p.particles[i].type=PT_GRAV;
        p.particles[i].vrx=randf(20)-10;
        p.particles[i].vrz=randf(20)-10;
        
		int pvbi=getPVBI2();
		p.particles[i].pvbi=pvbi;
		p.particles[i].size=randf(.1f)+.4f;
        BOOL useColorTex=FALSE;
        int bf=blockTypeFaces[type][arc4random()%6];
        if(blockinfo[type]&IS_ATLAS2)
            bf=blockTypeFaces[TYPE_CLOUD][arc4random()%6];
        for(int j=0;j<12;j++){
            if(color==0){
                if(bf==TEX_GRASS_SIDE||type==TYPE_GRASS3||type==TYPE_TNT||type==TYPE_BRICK||type==TYPE_VINE||type==TYPE_FIREWORK)
                {
                    useColorTex=TRUE;
                    pbuffer2[pvbi+j].colors[0]=255;
                    pbuffer2[pvbi+j].colors[1]=255;
                    pbuffer2[pvbi+j].colors[2]=255;
                }else{
                    pbuffer2[pvbi+j].colors[0]=(int)(blockColor[type][0])%256;
                    pbuffer2[pvbi+j].colors[1]=(int)(blockColor[type][1])%256;
                    pbuffer2[pvbi+j].colors[2]=(int)(blockColor[type][2])%256;
                }
            }else{
                Vector clr=colorTable[color];
                pbuffer2[pvbi+j].colors[0]=(int)(clr.x*255)%256;
                pbuffer2[pvbi+j].colors[1]=(int)(clr.y*255)%256;
                pbuffer2[pvbi+j].colors[2]=(int)(clr.z*255)%256;
                
            }
            
            pbuffer2[pvbi+j].colors[3]=255;		
        }
        CGPoint tp;
        
        if(useColorTex){
            if(bf==TEX_GRASS_SIDE)
                bf=TEX_GRASS_SIDE_COLOR;
            else if(bf==TEX_TNT_SIDE)
                bf=TEX_TNT_SIDE_COLOR;
            else if(bf==TEX_TNT_TOP)
                bf=TEX_TNT_TOP_COLOR;
            else if(bf==TEX_BRICK)
                bf=TEX_BRICK_COLOR;
        }
        tp=[[Resources getResources] getBlockTexShort:bf];
        
        static int triTextureCustom[6]={0,0,
            0,1,
            1,1,};
        
        for (int f=0;f<4;f++){
            for(int v=0;v<3;v++){
                pbuffer2[pvbi+f*3+v].texs[0]=triTextureCustom[v*2];
                pbuffer2[pvbi+f*3+v].texs[1]=triTextureCustom[v*2+1]*tp.y+tp.x;
                
            }
            
            
        }
	}
	
	p.start_life=p.life=LIFE;
	updateIndexes=TRUE;	
    for(int i=0;i<p.n_particles;i++){	
        list[list_size].particles[i]=p.particles[i];
    }
	list[list_size]=p;
    list_size++;

	
}
- (void)addFirework:(float)x:(float)z:(float)y:(int)color{
    while(num_particles*12+VANISHP*12>max_bparticles){
		[self removeNode:arc4random()%list_size];
	}
	
    cnode p;
    p.n_particles=VANISHP;
    num_particles+=p.n_particles;
    num_vertices+=12*p.n_particles;
	
	for(int i=0;i<p.n_particles;i++){		
		
		p.particles[i].pos.x=x;
		p.particles[i].pos.y=y;
		p.particles[i].pos.z=z;
		
		int dx=(arc4random()%200-100);
		int dz=(arc4random()%200-100);
		int dy=(arc4random()%200-100);
        Vector vt=MakeVector(dx,dy,dz);
        NormalizeVector(&vt);
        
		p.particles[i].vx=vt.x*SPEED*3;
		p.particles[i].vz=vt.z*SPEED*3;
		p.particles[i].vy=vt.y*SPEED*3;
        
        
        
        p.particles[i].rx=randf(6.28);
        p.particles[i].rz=randf(6.28);
        p.particles[i].type=PT_FIREWORK;
        p.particles[i].vrx=randf(40)-20;
        p.particles[i].vrz=randf(40)-20;
        
		int pvbi=getPVBI2();
		p.particles[i].pvbi=pvbi;
		p.particles[i].size=randf(.1f)+.2f;
               int bf;
        
        bf=blockTypeFaces[TYPE_CLOUD][arc4random()%6]; 
        int ttc=color;
        if(ttc==0)               
            ttc=arc4random()%53+1;
        for(int j=0;j<12;j++){
            
            Vector clr=colorTable[ttc];
                pbuffer2[pvbi+j].colors[0]=(int)(clr.x*255)%256;
                pbuffer2[pvbi+j].colors[1]=(int)(clr.y*255)%256;
                pbuffer2[pvbi+j].colors[2]=(int)(clr.z*255)%256;        
            if(pbuffer2[pvbi+j].colors[0]<100)pbuffer2[pvbi+j].colors[0]=100;
            if(pbuffer2[pvbi+j].colors[1]<100)pbuffer2[pvbi+j].colors[1]=100;
             if(pbuffer2[pvbi+j].colors[2]<100)pbuffer2[pvbi+j].colors[2]=100;
           
            
            pbuffer2[pvbi+j].colors[3]=255;		
        }
        CGPoint tp;
        
        
        tp=[[Resources getResources] getBlockTexShort:bf];
        
        static int triTextureCustom[6]={0,0,
            0,1,
            1,1,};
        
        for (int f=0;f<4;f++){
            for(int v=0;v<3;v++){
                pbuffer2[pvbi+f*3+v].texs[0]=triTextureCustom[v*2];
                pbuffer2[pvbi+f*3+v].texs[1]=triTextureCustom[v*2+1]*tp.y+tp.x;
                
            }
            
            
        }
	}
	
	p.start_life=p.life=(LIFE);
    updateIndexes=TRUE;	
	list[list_size]=p;
    for(int i=0;i<p.n_particles;i++){	
        list[list_size].particles[i]=p.particles[i];
    }
    list_size++;
    
}
- (void)addCreatureVanish2:(float)x:(float)z:(float)y:(int)color:(int)type{
	
    
	while(num_particles*12+VANISHP*12>max_bparticles){
		[self removeNode:arc4random()%list_size];
	}
	
    //NSLog(@"%d %d type:%d",x,z,type);
	cnode p;
    p.n_particles=VANISHP;
    num_particles+=p.n_particles;
    num_vertices+=12*p.n_particles;
	//p.next=NULL;
	for(int i=0;i<p.n_particles;i++){		
		
		p.particles[i].pos.x=x;
		p.particles[i].pos.y=y;
		p.particles[i].pos.z=z;
		
		int dx=(arc4random()%200-100);
		int dz=(arc4random()%200-100);
		int dy=(arc4random()%200-100);
		p.particles[i].vx=dx/100.0f*SPEED*6;
		p.particles[i].vz=dz/100.0f*SPEED*6;
		p.particles[i].vy=dy/100.0f*SPEED*6;
        
        p.particles[i].rx=randf(6.28);
        p.particles[i].rz=randf(6.28);
        p.particles[i].type=PT_NOGRAV;
        p.particles[i].vrx=randf(40)-20;
        p.particles[i].vrz=randf(40)-20;
        
		int pvbi=getPVBI2();
		p.particles[i].pvbi=pvbi;
		p.particles[i].size=randf(.1f)+.6f;
        BOOL useColorTex=FALSE;
        int bf;
        if(type<NUM_CREATURES)
        bf=blockTypeFaces[TYPE_CLOUD][arc4random()%6];
        else{
           bf=blockTypeFaces[TYPE_CLOUD][arc4random()%6]; 
        }
       
        for(int j=0;j<12;j++){
            if(color==0){  
                if(type<NUM_CREATURES){
                pbuffer2[pvbi+j].colors[0]=(int)(creatureColor[type][0])%256;
                pbuffer2[pvbi+j].colors[1]=(int)(creatureColor[type][1])%256;
                pbuffer2[pvbi+j].colors[2]=(int)(creatureColor[type][2])%256;
                }else{
                    pbuffer2[pvbi+j].colors[0]=(int)(blockColor[TYPE_DIRT][0])%256;
                    pbuffer2[pvbi+j].colors[1]=(int)(blockColor[TYPE_DIRT][1])%256;
                    pbuffer2[pvbi+j].colors[2]=(int)(blockColor[TYPE_DIRT][2])%256;
                    
                }
                
            }else{
                Vector clr=colorTable[color];
                pbuffer2[pvbi+j].colors[0]=(int)(clr.x*255)%256;
                pbuffer2[pvbi+j].colors[1]=(int)(clr.y*255)%256;
                pbuffer2[pvbi+j].colors[2]=(int)(clr.z*255)%256;
                
            }
            
            pbuffer2[pvbi+j].colors[3]=255;		
        }
        CGPoint tp;
        
        if(useColorTex){
             if(bf==TEX_GRASS_SIDE)
                bf=TEX_GRASS_SIDE_COLOR;
            else if(bf==TEX_TNT_SIDE)
                bf=TEX_TNT_SIDE_COLOR;
            else if(bf==TEX_TNT_TOP)
                bf=TEX_TNT_TOP_COLOR;
            else if(bf==TEX_BRICK)
                bf=TEX_BRICK_COLOR;
        }
        tp=[[Resources getResources] getBlockTexShort:bf];
        
        static int triTextureCustom[6]={0,0,
            0,1,
            1,1,};
        
        for (int f=0;f<4;f++){
            for(int v=0;v<3;v++){
                pbuffer2[pvbi+f*3+v].texs[0]=triTextureCustom[v*2];
                pbuffer2[pvbi+f*3+v].texs[1]=triTextureCustom[v*2+1]*tp.y+tp.x;
                
            }
            
            
        }
	}
	
	p.start_life=p.life=(LIFE*1.0f/3);
    updateIndexes=TRUE;	
	list[list_size]=p;
    for(int i=0;i<p.n_particles;i++){	
        list[list_size].particles[i]=p.particles[i];
    }
    list_size++;
    
	
}
- (void)addBlockBreak:(int)x:(int)z:(int)y:(int)type:(int)color{
	if(type<=0)return;
    
	while(num_particles*12+BREAKP*12>max_bparticles){
		[self removeNode:arc4random()%list_size];
	}
	
//NSLog(@"%d %d type:%d",x,z,type);
	cnode p;
    p.n_particles=BREAKP;
    num_particles+=p.n_particles;
    num_vertices+=12*p.n_particles;
	//p.next=NULL;
	for(int i=0;i<p.n_particles;i++){		
		
		p.particles[i].pos.x=x*BLOCK_SIZE+BLOCK_SIZE/2;
		p.particles[i].pos.y=y*BLOCK_SIZE+BLOCK_SIZE/2;
		p.particles[i].pos.z=z*BLOCK_SIZE+BLOCK_SIZE/2;
		
		int dx=(arc4random()%200-100);
		int dz=(arc4random()%200-100);
		int dy=(arc4random()%50)+50;
		p.particles[i].vx=dx/100.0f*SPEED;
		p.particles[i].vz=dz/100.0f*SPEED;
		p.particles[i].vy=dy/100.0f*SPEEDY;
        
        p.particles[i].rx=randf(6.28);
        p.particles[i].rz=randf(6.28);
        p.particles[i].type=PT_GRAV;
        p.particles[i].vrx=randf(20)-10;
        p.particles[i].vrz=randf(20)-10;
        
		int pvbi=getPVBI2();
		p.particles[i].pvbi=pvbi;
		p.particles[i].size=randf(.07f)+.05f;
        BOOL useColorTex=FALSE;
         int bf=blockTypeFaces[type][arc4random()%6];
        if(blockinfo[type]&IS_ATLAS2)
            bf=blockTypeFaces[TYPE_CLOUD][arc4random()%6];
        for(int j=0;j<12;j++){
            if(color==0){
                if(bf==TEX_GRASS_SIDE||type==TYPE_GRASS3||type==TYPE_TNT||type==TYPE_BRICK||type==TYPE_VINE||type==TYPE_FIREWORK)
                {
                    useColorTex=TRUE;
                    pbuffer2[pvbi+j].colors[0]=255;
                    pbuffer2[pvbi+j].colors[1]=255;
                    pbuffer2[pvbi+j].colors[2]=255;
                }else{
                    pbuffer2[pvbi+j].colors[0]=(int)(blockColor[type][0])%256;
                    pbuffer2[pvbi+j].colors[1]=(int)(blockColor[type][1])%256;
                    pbuffer2[pvbi+j].colors[2]=(int)(blockColor[type][2])%256;
                }
            }else{
                Vector clr=colorTable[color];
                pbuffer2[pvbi+j].colors[0]=(int)(clr.x*255)%256;
                pbuffer2[pvbi+j].colors[1]=(int)(clr.y*255)%256;
                pbuffer2[pvbi+j].colors[2]=(int)(clr.z*255)%256;
                
            }
            
            pbuffer2[pvbi+j].colors[3]=255;		
        }
        CGPoint tp;
        
        if(useColorTex){
       if(bf==TEX_GRASS_SIDE)
            bf=TEX_GRASS_SIDE_COLOR;
        else if(bf==TEX_TNT_SIDE)
            bf=TEX_TNT_SIDE_COLOR;
        else if(bf==TEX_TNT_TOP)
            bf=TEX_TNT_TOP_COLOR;
        else if(bf==TEX_BRICK)
            bf=TEX_BRICK_COLOR;
        }
        tp=[[Resources getResources] getBlockTexShort:bf];
       
        static int triTextureCustom[6]={0,0,
                                        0,1,
                                        1,1,};
        
        for (int f=0;f<4;f++){
            for(int v=0;v<3;v++){
                pbuffer2[pvbi+f*3+v].texs[0]=triTextureCustom[v*2];
                pbuffer2[pvbi+f*3+v].texs[1]=triTextureCustom[v*2+1]*tp.y+tp.x;
                             
            }
            
            
        }
	}
	
	p.start_life=p.life=LIFE;
    updateIndexes=TRUE;	
	list[list_size]=p;
    for(int i=0;i<p.n_particles;i++){	
        list[list_size].particles[i]=p.particles[i];
    }
    list_size++;
    
	
}
- (void)clearAllEffects{
	updateIndexes=TRUE;
    num_particles=0;
    num_vertices=0;
    list_size=0;
	
	
	
}
@end
