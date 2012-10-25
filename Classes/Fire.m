//
//  Fire.m
//  prototype
//
//  Created by Ari Ronen on 11/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Fire.h"
#import "Globals.h"
#import "Terrain.h"
#import "SpecialEffects.h"

@implementation Fire

#define n_particles 7
#define max_fparticles 1000
static unsigned short pindices[max_fparticles];
typedef struct{
	Vector pos;
	int pvbi; //particle vertex buffer index
	float vx,vy,vz;
	float life;
	float slife;   
	
}particle;

typedef struct _bnode{
	particle particles[n_particles];	
	float life;
	int pid;
	float x,z,y;
}bnode;

static bnode list[max_fparticles/2];
static int list_size;
static int num_particles;
static BOOL updateIndexes;

- (id)init{
	list_size=0;
	updateIndexes=TRUE;
	num_particles=0;
	return self;
	
}
-(void)removeNode:(int)idx{
    
    updateIndexes=TRUE;
    num_particles-=n_particles;   
    
    if(idx!=list_size-1){
        list[idx]=list[list_size-1];
        
    }
    list_size--;
	
    
}

static const int SPEED=1;
static const int SPEEDY=6;
extern vertexpStruct pbuffer[pbuffer_size];
- (BOOL)update: (float)etime{
	for(int k=0;k<list_size;k++){
        bnode* node=&list[k];
        
		
		for(int i=0;i<n_particles;i++){
			if(node->particles[i].life<0){
				node->particles[i].pos.x=node->x;
				node->particles[i].pos.y=node->y-BLOCK_SIZE/2;
				node->particles[i].pos.z=node->z;
				
				int dps=arc4random()%4;
				
				int dpx[4]={0,1,0,-1};
				int dpz[4]={-1,0,1,0};				
				node->particles[i].pos.x+=dpx[dps]*BLOCK_SIZE/1.7;
				node->particles[i].pos.z+=dpz[dps]*BLOCK_SIZE/1.7;
				int dpai=(arc4random()%200-100);
				float dpa=dpai/100.0f;
				//NSLog(@"a:%f",dpa);
				if(dps%2==0){
					node->particles[i].pos.x+=dpa*BLOCK_SIZE/2;	
					
				}else{					
					node->particles[i].pos.z+=dpa*BLOCK_SIZE/2;	
				
				}
				int dx=(arc4random()%200-100);
				int dz=(arc4random()%200-100);
				int dy=(arc4random()%50)+50;				
				node->particles[i].vx=dx/100.0f*SPEED;
				node->particles[i].vz=dz/100.0f*SPEED;
				node->particles[i].vy=dy/100.0f*SPEEDY;
				int dlife=(arc4random()%60);
				node->particles[i].life=dlife/60.0f*1;
				node->particles[i].slife=node->particles[i].life;
			}else{
				pbuffer[node->particles[i].pvbi].colors[3]=255;
                 if(IS_RETINA){
                pbuffer[node->particles[i].pvbi].size[0]=150*node->particles[i].life/node->particles[i].slife;
                 }else{
                     pbuffer[node->particles[i].pvbi].size[0]=75*node->particles[i].life/node->particles[i].slife;
                     
                 }
                //if( pbuffer[node->particles[i].pvbi].colors[1])
                     pbuffer[node->particles[i].pvbi].colors[1]=60*(node->particles[i].life/node->particles[i].slife);
				node->particles[i].life-=etime;
				node->particles[i].pos.x+=node->particles[i].vx*etime;
				node->particles[i].pos.y+=node->particles[i].vy*etime;			
				node->particles[i].pos.z+=node->particles[i].vz*etime;
				setParticle(node->particles[i].pos,node->particles[i].pvbi);
			}
		}
		node->life-=etime;
		if(node->life<=0){
			[self removeNode:k];
			
		}
	}
	
	
	if(updateIndexes){
       
		
		num_particles=0;
		 for(int k=0;k<list_size;k++){	
             bnode* node=&list[k];
			for(int i=0;i<n_particles;i++){
				pindices[num_particles++]=node->particles[i].pvbi;
				
			}			
			
		}		

		updateIndexes=FALSE;
	}
	return FALSE;
}
//#define NUM_COLORS 2
const GLubyte colors[2][3]={
	{255,0,0},
	{255,100,0},
/*	{80,80,80},
	{40,40,40},
	{170,185,40},
	{170,40,40},*/
	
};
-(void)removeFire:(int)ppid{
    
	for(int k=0;k<list_size;k++)
		if(list[k].pid==ppid){
			list[k].life=0;
			break;
		}
    
}
-(void)updateFire:(int)idx:(Vector)pos{
    for(int k=0;k<list_size;k++)
		if(list[k].pid==idx){
			list[k].x=pos.x;
            list[k].y=pos.y;
            list[k].z=pos.z;
			break;
		}
    
}

static int pid=0;
- (int)addFire:(float)x:(float)z:(float)y:(int)type:(float)life{
	
	while(num_particles+n_particles>max_fparticles){
		[self removeNode:arc4random()%list_size];
	}
	num_particles+=n_particles;
	
	bnode* p=&list[list_size];
	
	for(int i=0;i<n_particles;i++){
		p->particles[i].life=-1;		
		
		int pvbi=getPVBI();
		p->particles[i].pvbi=pvbi;
		
		int color=arc4random()%2;
		pbuffer[pvbi].colors[0]=colors[color][0];
		pbuffer[pvbi].colors[1]=colors[color][1];
		pbuffer[pvbi].colors[2]=colors[color][2];
		pbuffer[pvbi].colors[3]=255;
      /*  pbuffer[pvbi].colors[0]=255;
		pbuffer[pvbi].colors[1]=255;
		pbuffer[pvbi].colors[2]=255;*/
        if(IS_RETINA){
             pbuffer[pvbi].size[0]=150;
        }else{
        pbuffer[pvbi].size[0]=70;
        }
	}
	if(type==0){
	p->x=x*BLOCK_SIZE+BLOCK_SIZE/2;
	p->y=y*BLOCK_SIZE+BLOCK_SIZE/2;
	p->z=z*BLOCK_SIZE+BLOCK_SIZE/2;
    }
	p->pid=pid++;
	p->life=life;
	updateIndexes=TRUE;	
	
	list_size++;	
	
	return p->pid;
	
}
- (void)render{
    glColor4f(0,0,0,1.0f);
    glDisableClientState(GL_COLOR_ARRAY);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glDrawElements(GL_POINTS,num_particles,GL_UNSIGNED_SHORT,pindices);	
    glEnableClientState(GL_COLOR_ARRAY);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);

    glColor4f(1,1,1,1.0f);
	glDrawElements(GL_POINTS,num_particles,GL_UNSIGNED_SHORT,pindices);	
}
- (void)clearAllEffects{
	updateIndexes=TRUE;
    list_size=0;
    num_particles=0;
	
	
}
@end
