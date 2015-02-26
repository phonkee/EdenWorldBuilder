//
//  Portal.m
//  Eden
//
//  Created by Ari Ronen on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Portal.h"


Portal::Portal(){
    n_portal=0;
    
}
void Portal::paintPortal(int x,int y,int z,int color){
    for(int i=0;i<n_portal;i++){
        if(portals[i].x==x&&portals[i].y==y&&portals[i].z==z){
            portals[i].color=color;
            break;
        }
        
        
    }
}
void Portal::addPortal(int x,int y,int z,int dir,int color){
    int n=-1;
    for(int i=0;i<n_portal;i++){
        if(portals[i].x==x&&portals[i].y==y&&portals[i].z==z){
           n=i;
            break;
        }
        
        
    }
    if(n==-1){       
        n=n_portal;
        if(n==MAX_PORTAL){
            //figure out which portal to drop
            n=MAX_PORTAL-1;
        }
    }
    portals[n].x=x;
    portals[n].y=y;
    portals[n].z=z;
    portals[n].dir=dir;
    portals[n].color=color;
    if(n==n_portal&&n_portal<MAX_PORTAL){
        
        n_portal++;
    }
}
void Portal::removePortal(int x,int y,int z){
    for(int i=0;i<n_portal;i++){
        if(portals[i].x==x&&portals[i].y==y&&portals[i].z==z){
            for(int j=i+1;j<n_portal;j++){
                portals[j-1]=portals[j];
                
            }
            n_portal--;
          
            break;
        }
    }
}
void Portal::removeAllPortals(){
    n_portal=0;
}
extern float yawanimation;
Vector2 Portal::enterPortal(int x,int y,int z,Vector vel){
    Vector2 vec;
    vec.x=-9;
    
    for(int i=0;i<n_portal;i++){
      //  printg(" portal[%d] %d, %d, %d ",i,portals[i].x,portals[i].y,portals[i].z);
        if(portals[i].x==x&&portals[i].y==y&&portals[i].z==z){
            int color=portals[i].color;
            for(int j=0;j<n_portal;j++){
                int k=(i+j+1)%n_portal;
                if(portals[k].color==color){
                   
                    float mag=sqrtf(vel.x*vel.x+vel.z*vel.z);
                    float dx[4]={-1,0,1,0};
                    float dz[4]={0,-1,0,1};
                    float yaw[4]={0,90,180,270};
                    int dir=portals[k].dir;
                    vec.x2=mag*dx[(dir+1)%4];
                    vec.y2=0;
                    vec.z2=mag*dz[(dir+1)%4];
                    vec.x=portals[k].x+dx[(dir+1)%4]*1.2f;
                    if(dx[(dir+1)%4]==0){
                        vec.x+=.5f;
                    }
                    vec.y=portals[k].y;
                    vec.z=portals[k].z+dz[(dir+1)%4]*1.2f;
                    if(dz[(dir+1)%4]==0){
                        vec.z+=.5f;
                    }
                    

                    yawanimation=0;
                    [World getWorld].player->yaw=yaw[(dir+3)%4];
                    
                    break;
                }
            }
            
            break;
        }
    }
    if(vec.x==-9){
        vec.x=x;
        vec.y=y;
        vec.z=z;
        vec.x2=vel.x;
        vec.y2=vel.y;
        vec.z2=vel.z;
        printg("couldn't find entered portal\n");
    }
    
    return vec;
}

