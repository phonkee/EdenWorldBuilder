//
//  Liquids.m
//  Eden
//
//  Created by Ari Ronen on 7/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Liquids.h"
#import "hashmap.h"
#import "terrain.h"


enum wet_types{
    WT_SOURCE=0,
    WT_NORMAL=1,
};
#define MAX_SPREAD 4

static float delay;
static PNode* plist;

static PNode2* plist2;
//map_t wetmap;
//map_t usedmap;
static NSDate *start;
static NSTimeInterval last,now;

Liquids::Liquids(){
 //   wetmap=hashmap_new();
//    usedmap=hashmap_new();
    delay=0;
    plist=NULL;
    plist2=NULL;
    
    start = [NSDate date];		
   
    [start retain];
  //  last=-[start timeIntervalSinceNow];
  

}
void addPoint(int x,int z,int y){
    //int idx=threeToOne(x,y,z);
    //if(hashmap_contains(usedmap,idx))return;
   // hashmap_put(usedmap,idx,NULL);
    PNode* point=(PNode*)malloc(sizeof(PNode));
    point->x=x;
    point->y=y;
    point->z=z;
    point->next=plist;
    point->prev=NULL;
    if(plist)plist->prev=point;
    plist=point;
}
void addPoint2(int x,int z,int y,int type,int level){
    
    PNode2* point=(PNode2*)malloc(sizeof(PNode2));
    point->x=x;
    point->y=y;
    point->z=z;
    point->type=type;
    point->level=level;
    point->next=plist2;
    point->prev=NULL;
    if(plist2)plist2->prev=point;
    plist2=point;
}
PNode2* removePoint2(PNode2* point){
   
    PNode2* prev=point->prev;
    PNode2* next=point->next;
    free(point);
    if(prev)prev->next=next;
    if(next)next->prev=prev;
    if(point==plist2)plist2=NULL;
    return next;    
} 
PNode* removePoint(PNode* point){
    
    PNode* prev=point->prev;
    PNode* next=point->next;
    free(point);
    if(prev)prev->next=next;
    if(next)next->prev=prev;
    if(point==plist)plist=NULL;
    return next;    
} 

void Liquids::addSource(int x,int z,int y){
    addPoint(x,z,y);
    return;
   
}
void Liquids::removeSource(int x,int z,int y,int type){
  addPoint2(x,z,y,getBaseType(type),getLevel(type));
}


void Liquids::clearLiquids(){
    PNode* node=plist;
    while(node){
       
        
            node=removePoint(node);
       
    }
   PNode2* node2=plist2;
    while(node2){
        
        
        node2=removePoint2(node2);
        
    }
   
}
BOOL updateHeights(WetNode* node){
    return FALSE;
    /*
    int dx[]={-1,1,0,0,0,0};
    int dz[]={0,0,-1,1,0,0};
   // int dy[]={0,0,0,0,-1,1};
    int nx;
    int ny;
    int nz;
    int type;
    
    BOOL addit=FALSE;
    
    BOOL water_cap=FALSE;
    int wch[4];
    type=getLandc(node->x, node->z, node->y-1);
    if(type==TYPE_WATER||type==TYPE_NONE||type==TYPE_LAVA){
        type=getLandc(node->x, node->z, node->y+1);
        if(type==TYPE_NONE&&node->flowType!=WT_SOURCE){
            water_cap=TRUE;
            for(int i=0;i<4;i++)wch[i]=0;
        }

    }
    
    if(node->spread<MAX_SPREAD)
    for(int i=0;i<4;i++){
        nx=node->x+dx[i];
        nz=node->z+dz[i];
        ny=node->y;
        type=getLandc(nx, nz, ny);
        if(type==TYPE_NONE||type==TYPE_WATER||type==TYPE_LAVA){
            //NSLog(@"sup2");
            WetNode* new_node;
            
            int idx=threeToOne(nx,ny,nz);
            if(hashmap_get(wetmap, idx, (any_t)&new_node)!=MAP_MISSING){
                
                if(new_node->spread-1>node->spread){
                    node->spread=new_node->spread-1;
                    addit=TRUE;
                }
                int d=i;
                if(i==1)d=3;
                if(i==3)d=0;
                if(i==0)d=1;
                
                int oi=i+1;
                if(oi%2==0)oi-=2;
                int d2=oi;
                if(oi==1)d2=3;
                if(oi==3)d2=0;
                if(oi==0)d2=1;
                for(int j=0;j<2;j++){
                    int corner=(d+j)%4;
                    int corner2=(d2+!j)%4;   
                    if(water_cap){
                        if(wch[corner2]< new_node->heights[corner]){
                            wch[corner2]=new_node->heights[corner];                           
                            
                        }
                    }else
                    if(node->heights[corner2]< new_node->heights[corner]){
                        node->heights[corner2]=new_node->heights[corner];                           
                        addit=TRUE;
                    }
                    
                }            
                
                
                
            }else{
                
                
            }
            
        }
    }
    if(node->spread!=-1&&water_cap){
        for(int i=0;i<4;i++){
            if(wch[i]!=node->heights[i]){
                node->heights[i]=wch[i];
                addit=TRUE;
            }               
        }
        node->spread=0;
    }
    type=getLandc(node->x, node->z, node->y+1);
    if(type==TYPE_WATER||type==TYPE_LAVA){
        if(node->spread<MAX_SPREAD){
            addit=TRUE;
            node->spread=MAX_SPREAD;
        }
        
        
    }
    if(!water_cap)
    for(int j=0;j<4;j++){        
        if(node->heights[j]< node->spread){
            node->heights[j]=node->spread;                           
            addit=TRUE;
        }
        
    } else{
        
        //NSLog(@"t.t");
    }
     for(int j=0;j<4;j++){  
         if(node->heights[j]>node->max){
             node->max=node->heights[j];
             addit=TRUE;
         }
     }
    
    return addit;*/

    
}
void addVert(int x,int y,int z,block8 type,color8 color){/*
     WetNode* new_node;
    new_node=malloc(sizeof(WetNode));
    new_node->x=x;
    new_node->z=z;
    new_node->y=y;
    new_node->flowType=WT_NORMAL;
    new_node->spread=MAX_SPREAD;
    new_node->max=MAX_SPREAD;
    new_node->blockType=type;
    new_node->color=color;
    for(int i=0;i<4;i++){                 
        new_node->heights[i]=MAX_SPREAD;                
    }           
    hashmap_put(wetmap,threeToOne(x,y,z),new_node);
    addPoint(x,z,y);             
    [[World getWorld].terrain updateChunks:new_node->x:new_node->z:new_node->y:type];
    */
}
void addHoriz(int x,int y,int z,block8 type,color8 color){/*
    WetNode* new_node;
    new_node=malloc(sizeof(WetNode));
    new_node->spread=0;
    new_node->blockType=type;
    new_node->color=color;
    new_node->x=x;
    new_node->z=z;
    new_node->y=y;
    new_node->flowType=WT_NORMAL;
    new_node->heights[0]=0;
    new_node->heights[1]=0;
    new_node->heights[2]=0;
    new_node->heights[3]=0;
    new_node->spread=-1;
    new_node->max=0;
    updateHeights(new_node);
    if(new_node->spread==-1){
        free(new_node);
        return;
    }
    hashmap_put(wetmap,threeToOne(x,y,z),new_node);
    [[World getWorld].terrain updateChunks:new_node->x:new_node->z:new_node->y:type];
    addPoint(x,z,y);*/

}
 int genLevel(int type,int level){
    if(type==TYPE_WATER){
        if(level==4)return TYPE_WATER;
        if(level==3)return TYPE_WATER3;
        if(level==2)return TYPE_WATER2;
        if(level==1)return TYPE_WATER1;
        if(level==0)return TYPE_NONE;
    }else if(type==TYPE_LAVA){
        if(level==4)return TYPE_LAVA;
        if(level==3)return TYPE_LAVA3;
        if(level==2)return TYPE_LAVA2;
        if(level==1)return TYPE_LAVA1;
        if(level==0)return TYPE_NONE;
    }    
    return type;
}

int getLevel(int type){
   
    if(type==TYPE_LAVA1||type==TYPE_WATER1)return 1;
    if(type==TYPE_LAVA2||type==TYPE_WATER2)return 2;
    if(type==TYPE_LAVA3||type==TYPE_WATER3)return 3;
    if(type==TYPE_LAVA||type==TYPE_WATER)return 4;
    return 0;
}
 int getBaseType(int type){
    if(type==TYPE_WATER2||type==TYPE_WATER3||type==TYPE_WATER1)return TYPE_WATER;
    if(type==TYPE_LAVA2||type==TYPE_LAVA3||type==TYPE_LAVA1)return TYPE_LAVA;
  
    return type;
}
static BOOL updateNode2(PNode2* pnode){
    
    int nx,ny,nz,type;  
    
    type=pnode->type;
    
    const int dx[]={-1,1,0,0,0,0};
    const int dz[]={0,0,-1,1,0,0};  
    const int dy[]={0,0,0,0,-1,0};
   
    int ntype,nbasetype;
    for(int i=0;i<5;i++){
        nx=pnode->x+dx[i];
        nz=pnode->z+dz[i];
        ny=pnode->y+dy[i];
        ntype=getLandc(nx, nz, ny);
        nbasetype=getBaseType(ntype);
        if(blockinfo[ntype]&IS_LIQUID&&nbasetype==type){
            if(i==4){
                 [[World getWorld].terrain updateChunks:nx:nz:ny:TYPE_NONE];
                addPoint2(nx,nz,ny,nbasetype,getLevel(ntype));
            }else{
                int nlevel=getLevel(ntype);
                BOOL bdelete=TRUE;
                if(nlevel==4||nlevel>=pnode->level)continue;
                for(int j=0;j<4;j++){
                    int tblock=getLandc(nx+dx[i],nz+dz[i],ny+dy[i]);
                    if(nbasetype==getBaseType(tblock)&&getLevel(tblock)>nlevel){
                        bdelete=FALSE;
                    }
                    if(bdelete){
                         [[World getWorld].terrain updateChunks:nx:nz:ny:TYPE_NONE];
                        addPoint2(nx,nz,ny,nbasetype,nlevel);
                    }
                }
                
            }
           
            
            
            
            
            
        }
        
    } 
    
    return TRUE;
}
static BOOL updateNode(PNode* pnode){
    int nx,ny,nz,type;  
    //int pidx=threeToOne(pnode->x,pnode->y,pnode->z);
    // WetNode* node;
    type=getLandc(pnode->x,pnode->z,pnode->y);
    if(!(blockinfo[type]&IS_LIQUID))return TRUE;
    int color=[[World getWorld].terrain getColor:pnode->x:pnode->z:pnode->y];
    /*if(hashmap_get(wetmap, pidx, (any_t)&node)==MAP_MISSING){
     
     if(type==TYPE_WATER||type==TYPE_LAVA){
     [[World getWorld].terrain updateChunks:pnode->x:pnode->z:pnode->y:TYPE_NONE];
     }
     
     
     nx=pnode->x;
     ny=pnode->y;
     nz=pnode->z;
     type=getLandc(nx, nz, ny+1);
     if(type==TYPE_WATER){
     addVert(nx,ny,nz,TYPE_WATER,0);
     
     }else if(type==TYPE_LAVA){
     addVert(nx,ny,nz,TYPE_LAVA,0);
     }else{
     
     int c1=getLandc(nx+1,nz,ny);
     int c2=getLandc(nx-1,nz,ny);
     int c3=getLandc(nx,nz+1,ny);
     int c4=getLandc(nx,nz-1,ny);
     
     if(c1==TYPE_LAVA||c2==TYPE_LAVA||c3==TYPE_LAVA||c4==TYPE_LAVA){
     addHoriz(nx,ny,nz,TYPE_LAVA,0);
     }else  if(c1==TYPE_WATER||c2==TYPE_WATER||c3==TYPE_WATER||c4==TYPE_WATER){
     addHoriz(nx,ny,nz,TYPE_WATER,0);
     }
     }
     return TRUE;
     }else{
     if(type!=TYPE_WATER&&type!=TYPE_LAVA){
     [[World getWorld].terrain updateChunks:pnode->x:pnode->z:pnode->y:node->blockType];
     }
     }
     */
    const int dx[]={-1,1,0,0,0,0};
    const int dz[]={0,0,-1,1,0,0};     
    
    nx=pnode->x;
    ny=pnode->y-1;
    nz=pnode->z;
    int ntype=getLandc(nx, nz, ny);
    if(ntype==TYPE_NONE||blockinfo[ntype]&IS_LIQUID){
        if(ntype==TYPE_WATER||ntype==TYPE_LAVA)return TRUE;
       
        if(getBaseType(type)!=TYPE_LAVA||![[World getWorld].player test:nx:ny:nz:1]){
            
            if(blockinfo[type]&IS_WATER)
                [[World getWorld].terrain updateChunks:nx:nz:ny:TYPE_WATER];
            else if(blockinfo[type]&IS_LAVA)
                [[World getWorld].terrain updateChunks:nx:nz:ny:TYPE_LAVA];
            
            
            [[World getWorld].terrain setColor:nx:nz:ny:color];
            
            addPoint(nx,nz,ny);
            return TRUE;
        }else
            return false;
        /*
         WetNode* new_node;
         int idx=threeToOne(nx,ny,nz);
         if(hashmap_get(wetmap, idx, (any_t)&new_node)==MAP_MISSING){
         addVert(nx,ny,nz,node->blockType,node->color);
         
         
         }  else if(type==TYPE_WATER||type==TYPE_LAVA){
         new_node->spread=MAX_SPREAD;
         BOOL test=FALSE;
         for(int i=0;i<4;i++){    
         if(new_node->heights[i]<MAX_SPREAD){
                     new_node->heights[i]=MAX_SPREAD;   
                     test=TRUE;
                 }
             }  
             if(test)
                 [[World getWorld].terrain updateChunks:new_node->x:new_node->z:new_node->y:node->blockType];
             
         } else{
             NSLog(@"assert,can't find liquid source in map");
         }*/
     }
     int level=getLevel(type);
     if(level==1)return TRUE;
     
     int btype=getBaseType(type);
     
     for(int i=0;i<4;i++){
         nx=pnode->x+dx[i];
         nz=pnode->z+dz[i];
         ny=pnode->y;
         ntype=getLandc(nx, nz, ny);
         if(ntype==TYPE_NONE||(blockinfo[ntype]&IS_LIQUID&&getLevel(ntype)<level-1)){
             if(btype!=TYPE_LAVA||![[World getWorld].player test:nx:ny:nz:1]){
             [[World getWorld].terrain updateChunks:nx:nz:ny:genLevel(btype,level-1)];
             
             [[World getWorld].terrain setColor:nx:nz:ny:color];
             
             addPoint(nx,nz,ny);
             }
             
         }
         
     } 
         
    return TRUE;
 }
static int resetFeedCount(any_t passedIn,any_t wnode){
    WetNode* node=(WetNode*)wnode;
    node->feeders=0;
    return MAP_OK;
}
static int removeUnfed(any_t passedIn,any_t wnode){
    WetNode* node=(WetNode*)wnode;
    if(node->feeders==0){
        if(node->flowType==WT_NORMAL){
            [[World getWorld].terrain updateChunks:node->x:node->z:node->y:TYPE_NONE];
            
            return MAP_REMOVE;
        }
    }
    return MAP_OK;
}

    

	
BOOL Liquids::update(float etime){
    
    delay+=etime;
    if(delay>.5f){
        last=-[start timeIntervalSinceNow];
        delay=0;
       /* hashmap_iterate(wetmap, resetFeedCount, NULL);
        hashmap_iterate(wetmap, updateNode, NULL);
        hashmap_iterate(wetmap, removeUnfed, NULL);
        hashmap_remove_all(usedmap,FALSE);*/
         int n=0;
        
        PNode2* node2=plist2;        
        
        while(node2){
            n++;
            if(updateNode2(node2)){
                node2=removePoint2(node2);
            }else{               
                node2=node2->next;
            }
        }

        
        PNode* node=plist;        
       
        while(node){
            n++;
            if(updateNode(node)){
                node=removePoint(node);
            }else{               
                node=node->next;
            }
        }
       
         now=-[start timeIntervalSinceNow];
        float eetime=(float)(now-last);
        eetime++;
        if(n!=0){
           
         // printg("nodes: %d  etime: %f  etime/node: %f\n",n,eetime,eetime/n);//eetime/(float)n);
            return FALSE;
        }
        
        
    }
    return TRUE;
}
void Liquids::render(){
    
}

