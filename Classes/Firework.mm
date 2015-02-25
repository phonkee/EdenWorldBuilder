//
//  Firework.m
//  Eden
//
//  Created by Ari Ronen on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Firework.h"


Firework::Firework(){
    n_firework=0;
    
}
void Firework::addFirework(int x,int y,int z,int color){
    int n=n_firework;
    if(n_firework!=MAX_FIREWORK){
        n_firework++;
    }
    fireworks[n].pos=MakeVector(x,y,z);
    fireworks[n].vel=MakeVector(0,27,0);
   // fireworks[n].vel=MakeVector(0,0,0);
    fireworks[n].color=color;
    if(color==0)fireworks[n].color=arc4random()%53+1;
    
    if(arc4random()%40==0){
        fireworks[n].color=0;
    }
       fireworks[n].fuse=randf(0.8f)+1.3f;
}
void Firework::removeAllFireworks(){
    n_firework=0;
    
}
void Firework::removeFirework(int i){
    for(int j=i+1;j<n_firework;j++){
        fireworks[j-1]=fireworks[j];
    }
    if(i<n_firework){
        n_firework--;
    }
}
void Firework::update(float etime) {
    for(int i=0;i<n_firework;i++){
        fireworks[i].pos=v_add(fireworks[i].pos,v_mult(fireworks[i].vel,etime));
        if([[World getWorld].terrain getLand:roundf(fireworks[i].pos.x)
                                            :roundf(fireworks[i].pos.z)
                                            :roundf(fireworks[i].pos.y)]>0){
            fireworks[i].fuse=-1;
        }
        fireworks[i].fuse-=etime;
       
    }
    frot+=(M_PI*2/4.0f)*etime;
    if(frot>M_PI*2)frot-=M_PI*2;
}
void Firework::render(){
    Graphics::startPreview();
    glEnableClientState(GL_NORMAL_ARRAY);  
    glEnable(GL_LIGHTING);
    
  glShadeModel(GL_SMOOTH);
    
    float lightPosition[4] = {0.0f,0.0f, 0.0f, 1.0f};
    float lightAmbient[4]  = {0.3f, 0.3f, 0.3f, 1.0f};
    float lightDiffuse[4]  = {0.7f, 0.7f, 0.7f, 1.0f};    
    glEnable(GL_LIGHT0);
    glPushMatrix();
    glLoadIdentity();
    glLightfv(GL_LIGHT0, GL_POSITION, lightPosition); 
    glPopMatrix();
    glLightfv(GL_LIGHT0, GL_AMBIENT,  lightAmbient);
    glLightfv(GL_LIGHT0, GL_DIFFUSE,  lightDiffuse);
     for(int i=0;i<n_firework;i++){
     /*[Graphics drawCube:fireworks[i].pos.x
                      :fireworks[i].pos.y
                      :fireworks[i].pos.z
                      :TYPE_FIREWORK
                      :1];*/
         Graphics::drawFirework(fireworks[i].pos.x,
                                fireworks[i].pos.y,
                                fireworks[i].pos.z,
                                fireworks[i].color,
                                0.5f,
                                frot);
        
         
         if(fireworks[i].fuse<0){
             [[Resources getResources] playSound:S_FIREWORK_EXPLODE];
             Vector skyc=[World getWorld].terrain.skycolor;
             skyc.x+=.3f;
             skyc.y+=.3f;
             skyc.z+=.3f;
             if(skyc.x>1)skyc.x=1;
             if(skyc.y>1)skyc.y=1;
             if(skyc.z>1)skyc.z=1;
             [World getWorld].terrain.skycolor=skyc;
             [World getWorld].effects->addCreatureVanish(fireworks[i].pos.x,fireworks[i].pos.z,fireworks[i].pos.y,fireworks[i].color,TYPE_FIREWORK);
             [World getWorld].effects->addFirework(fireworks[i].pos.x,fireworks[i].pos.z,fireworks[i].pos.y,fireworks[i].color);
             this->removeFirework(i);
             i--;
             
         }
     }
    glShadeModel(GL_FLAT);

    glDisableClientState(GL_NORMAL_ARRAY);  
    glDisable(GL_LIGHTING);
    Graphics::endPreview();
    
}

