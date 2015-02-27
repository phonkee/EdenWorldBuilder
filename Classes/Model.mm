
///Modified PVRT Skinning/Bone mesh Example code.


#import "PVRTModelPOD.h"
#import <math.h>
#import "PVRTResourceFile.h"
#import "PVRTString.h"
#import "PVRTTextureAPI.h"

#import "Model.h"
#import "Util.h"
#import "Graphics.h"
#import "Terrain.h"
#import "Globals.h"
#import "Frustum.h"


#import "Resources.h"
#import "TerrainGen2.h"

int compare_creatures2 (const void *a, const void *b);
#define START_LIFE 5
#define C_PI 3.14159f
const char moofFile[]	= "Moof.pod";
const char battyFile[]	= "Batty.pod";
const char greenFile[]	= "Green.pod";
const char nergleFile[]	= "Nergle.pod";
const char stumpyFile[]	= "Stumpy.pod";
const char chargerFile[]= "Charger.pod";
const char stalkerFile[]= "Stalker.pod";

/*const static int n_states[NUM_CREATURES]={
    [M_GREEN]=6,
    [M_MOOF]=6,
    [M_NERGLE]=6,
    [M_BATTY]=6,
    [M_STUMPY]=6,
    [M_CHARGER]=6,
    [M_STALKER]=6,
};*/
const static float shadow_size[NUM_CREATURES]={
    [M_GREEN]=.8f,
    [M_MOOF]=1.0f,
    [M_NERGLE]=.8f,
    [M_BATTY]=.64f,
    [M_STUMPY]=.64f,
    [M_CHARGER]=.9f,
    [M_STALKER]=.7f,
    
};

#define DEFAULT_DAMAGE 5
#define DEFAULT_IDLE_START 3
#define DEFAULT_WALK 1
#define DEFAULT_JUMP 2
#define ROTATE_SPEED 1.14f
#define GREEN_WALK 1
#define GREEN_JUMP 2
#define GREEN_IDLE1 3
#define GREEN_IDLE2 4
#define GREEN_DAMAGE 5
#define GREEN_NONE 0

#define MOOF_WALK 1
#define MOOF_JUMP 2
#define MOOF_IDLE1 3
#define MOOF_IDLE2 4
#define MOOF_DAMAGE 5
#define MOOF_NONE 0

#define BATTY_NONE 0
#define BATTY_WALK 1
#define BATTY_JUMP 2
#define BATTY_IDLE1 3
#define BATTY_IDLE2 4
#define BATTY_DAMAGE 5

#define CHARGER_NONE 0
#define CHARGER_WALK 1
#define CHARGER_JUMP 2
#define CHARGER_IDLE1 3
#define CHARGER_IDLE2 4
#define CHARGER_DAMAGE 5

#define STALKER_NONE 0
#define STALKER_WALK 1
#define STALKER_JUMP 2
#define STALKER_IDLE1 3
#define STALKER_IDLE2 4
#define STALKER_DAMAGE 5

/*
 
 
 Stumpy's frames:
 Walk 1-80
 Jump  81-120
 Idle 1  121-240  
 Idle 2  241-300
 Damage  301-330
 
 Green guy's new frames:
 walk trans:  1-9
 walk 10-90
 jump 100-150
 idle_1 150-190
 idle_2 190-285
 Damage  310-340

 Charger frames:
 Movement:  1-40
 Jump:  40-80
 Idle:  81-121
 Take Damage:  121-141
 
 Stalker frames:
 Walk Cycle:  1-35
 Jump:  36-90
 Idle:  91-151
 Take Damage:152-182
 Attack:  183-233
 */

static int stalker_states[6][2]={
    [STALKER_WALK]={1,35},
    [STALKER_JUMP]={36,90},
    [STALKER_IDLE1]={91,151},
    [STALKER_IDLE2]={183,233},
    [STALKER_DAMAGE]={152,182},
    [STALKER_NONE]={91,91},
};

static int charger_states[6][2]={
    [CHARGER_WALK]={1,40},
    [CHARGER_JUMP]={40,80},
    [CHARGER_IDLE2]={81,218},
    [CHARGER_IDLE1]={81,218},
    [CHARGER_DAMAGE]={218,237},
    [CHARGER_NONE]={121,121},
};

static int nergle_states[6][2]={
    [GREEN_WALK]={11,90},
    [GREEN_JUMP]={91,140},
    [GREEN_IDLE2]={141,260},
    [GREEN_IDLE1]={261,300},
    [GREEN_DAMAGE]={300,325},
    [GREEN_NONE]={141,141},
};
static int stumpy_states[6][2]={
    [GREEN_WALK]={1,80},
    [GREEN_JUMP]={81,120},
    [GREEN_IDLE2]={121,240},
    [GREEN_IDLE1]={241,300},
    [GREEN_DAMAGE]={301,329},
    [GREEN_NONE]={240,240},
};
static int green_states[6][2]={
    [GREEN_WALK]={9,89},
    [GREEN_JUMP]={99,149},
    [GREEN_IDLE1]={149,189},
    [GREEN_IDLE2]={189,309},
    [GREEN_DAMAGE]={309,339},
    [GREEN_NONE]={150,150},
};

static int moof_states[6][2]={
    [MOOF_WALK]={248,293},
    [MOOF_JUMP]={0,40},
    [MOOF_IDLE1]={41,121},
    [MOOF_IDLE2]={122,247},
    [MOOF_DAMAGE]={0,40},
    [MOOF_NONE]={140,140},
};
static int batty_states[6][2]={
    [BATTY_NONE]={0,0},
    [BATTY_IDLE1]={0,40},  
    [BATTY_IDLE2]={0,40},  
    [BATTY_WALK]={0,40},  
    [BATTY_JUMP]={0,40},  
    
    [BATTY_DAMAGE]={40,59},
};
static int getFrame(int type,int state, int idx){
    if(type==M_GREEN){
        return green_states[state][idx];
    }else if(type==M_BATTY){
        return batty_states[state][idx];
    }else if(type==M_MOOF){
        return moof_states[state][idx];
    }else if(type==M_NERGLE){
        return nergle_states[state][idx];
    }else if(type==M_STUMPY){
        return stumpy_states[state][idx];
    }else if(type==M_CHARGER){
        return charger_states[state][idx];
    }else if(type==M_STALKER){
        return stalker_states[state][idx];
    }
    return 0;
}
    
    /*
     JUMP:  1-40
     IDLE BREATHE:  41-121
     IDLE LOOK:  122-247
     MOVE:  248-294
                
                Walk:  1-80
                Jump:  90-140
                Idle 1:  140-180
                Idle 2:  180-30
                Damage:  300-330*/
typedef struct _entity{
    float angle;
    float targetangle;
    PVRTVec3 pos;
    PVRTVec3 lpos;
    PVRTVec3 vel;
    PVRTVec3 acc;
    int model_type;
    int state;
    int idx;
    float life;
    float flash;
    float frame;
    float timer;
    float pitch;
    int fireidx;
    BOOL onground;
    BOOL jumping;
    BOOL onIce;
    BOOL alive;
    BOOL touched;
    int color;
    BOOL lastInLiquid;
    BOOL inLiquid;
    BOOL onfire;
    BOOL justhit;
    BOOL update;
    BOOL insideView;
    BOOL excited;
    BOOL greeted;
    float runaway;
    float ragetimer;
    float blinktimer;
    PVRTVec3 dest;
    int gotoDest;
   
    Polyhedra box;
    
}Entity;
#define nguys 300
static Entity guys[nguys+1];
static Vector min[NUM_CREATURES];
static Vector max[NUM_CREATURES];

static PVRTVec3 cmin[NUM_CREATURES];
static PVRTVec3 cmax[NUM_CREATURES];
static PVRTVec3 dmin[NUM_CREATURES];

static PVRTVec3 dmax[NUM_CREATURES];
static PVRTVec3 centers[NUM_CREATURES];

static float mradius[NUM_CREATURES];

static bool firstLoad=TRUE;
static Polyhedra mpolys[NUM_CREATURES];

CPVRTModelPOD		models[NUM_CREATURES];

extern int g_offcx;
extern int g_offcz;

	// View and Projection Matrices
	PVRTMat4			m_mView;

	// Model transformation variables
	PVRTMat4			m_mTransform;
	
 

	// Extensions
	CPVRTglesExt m_Extensions;

	// Vertex Buffer Object (VBO) handles
	GLuint*	m_puiVbo[NUM_CREATURES];
	GLuint*	m_puiIndexVbo[NUM_CREATURES];

	// Array to lookup the textures for each material in the scene
	
inline PVRTVec4 vpv4(Vector v){
    return PVRTVec4(v.x,v.y,v.z,1);
}

inline PVRTVec3 vpv(Vector v){
    return PVRTVec3(v.x,v.y,v.z);
}
inline PVRTVec3 MakePVR(Vector v){
    return PVRTVec3(v.x,v.y,v.z);
}
	
Vector MakeVector2(PVRTVec3 v2){
    Vector v;
    v.x=v2.x;
    v.y=v2.y;
    v.z=v2.z;
    return v;
    
}

/*
 utMat4 m = _pRefFrame->GetInvTranspose();
 
 // pV, pN and pTC point to the XYZ, Normal and Texture Coordinate attributes of a single vertex.
 
 for( int i=0; i<numVerts; i++, pV+=vstride, pN+=nstride, pTC+=tstride )
 {
 // Calculate the vector from Object Space Eye to the Vertex
 
 viewVec = _refFrameEye - *(utVec3*)pV;
 viewVec.NormalizeFast();
 
 // Reflect it
 float d = viewVec.Dot( *(utVec3*)pN );
 reflectedVec = *(utVec3*)pN * (2.f*d) - viewVec;
 
 // Transform it to World Space
 m.Multiply3( reflectedVec, reflectedVec );
 
 // Index into Sphere Map.  Optimization: this code takes the Reciprocal Square Root instead of the 1 / sqrt()
 float p = utMath::RSqrt(
 reflectedVec.v[0] * reflectedVec.v[0] +
 reflectedVec.v[1] * reflectedVec.v[1] +
 (reflectedVec.v[2]+1) * (reflectedVec.v[2]+1) ) * .5f;
 ((float*)pTC)[0] = .5f + reflectedVec.v[0] * p;
 ((float*)pTC)[1] = .5f + reflectedVec.v[1] * p;
 }
 */
int lolcounter=0;
PVRTMat4 envView;
void setViewNow(){
    GLfloat modelviewf[16];
	glGetFloatv( GL_MODELVIEW_MATRIX, modelviewf );
	// Set up the projection matrix
	envView = PVRTMat4(modelviewf).inverse().transpose();
    
}
PVRTVec3 unwrap(PVRTVec3 upos){
    PVRTVec3 player_pos=MakePVR([World getWorld].player->pos);
    player_pos.x=wrapx(player_pos.x);
    player_pos.z=wrapz(player_pos.z);
    
    float tempy=upos.y;
    upos=upos-player_pos;
    upos=upos+MakePVR([World getWorld].player->pos);
    upos.y=tempy;
    return upos;
}

void CalcEnvMap(vertexObject* vert){
 
    // pV, pN and pTC point to the XYZ, Normal and Texture Coordinate attributes of a single vertex.
    
     // Calculate the vector from Object Space Eye to the Vertex
        PVRTVec3 _refFrameEye([World getWorld].player->pos.x-[World getWorld].fm->chunkOffsetX*CHUNK_SIZE,
                              [World getWorld].player->pos.y+3*1.85f/10,
                              [World getWorld].player->pos.z-[World getWorld].fm->chunkOffsetZ*CHUNK_SIZE);
    PVRTVec3 pV(vert->position[0]/4.0f,vert->position[1]/4.0f,vert->position[2]/4.0f);
    
        PVRTVec3 viewVec = _refFrameEye - pV;
   
    viewVec.normalize();
        
    PVRTVec3 pN(vert->normal[0],vert->normal[1],vert->normal[2]);
        // Reflect it
        float d = viewVec.dot(pN );
        PVRTVec3 reflectedVec1 = pN * (2.f*d) - viewVec;
    
    
        
    PVRTVec4 reflectedVec(reflectedVec1.x,reflectedVec1.y,reflectedVec1.z,1.0f);
        // Transform it to World Space
        reflectedVec=envView*reflectedVec;
    
   /* lolcounter++;
    if(lolcounter>500000){
        printg("transformedVec:(%f,%f,%f)\n",reflectedVec.x,reflectedVec.y,reflectedVec.z);
        lolcounter=0;
    }*/
     
        // Index into Sphere Map.  Optimization: this code takes the Reciprocal Square Root instead of the 1 / sqrt()
        float p = rsqrt(
                                reflectedVec.x * reflectedVec.x +
                                reflectedVec.y * reflectedVec.y +
                                (reflectedVec.z+1) * (reflectedVec.z+1) ) * .5f;
    vert->texs[0]= .5f + reflectedVec.x * p;
    vert->texs[1]= (.5f + reflectedVec.y * p)*32;
    
        
    
    
}
static int nest_count;
extern Vector minTranDist;
 static float scale=1/16.0f;
static int renderlistc[nguys];
extern EntityData creatureData[MAX_CREATURES_SAVED];
EntityData inventory;
void SortModels(){
    
    
}
bool isFacingPlayer(int idx){
    int a=R2D(guys[idx].angle);
    int b=[World getWorld].player->yaw;
    
    a=(a+360+90+180)%360;
    b=(b+360)%360;
    if(a>b)
    {
        int t=a;
        a=b;
        b=t;
    }
  //  printg("a: %d, b:%d\n",a,b);
    if(absf(a-b)>180){
        if(absf((a+360)-b)<45){
            return TRUE;
        }
        
        
    }else if(absf(a-b)<45){
        return TRUE;
    }
    return FALSE;


    
}
void PlaySound(int idx,int sound){
    if(guys[idx].alive&&guys[idx].insideView&&guys[idx].update){
        if((sound==VO_IDLE||sound==VO_STRETCHING)){
            if(guys[idx].model_type!=M_BATTY&&isFacingPlayer(idx))
           Resources::getResources->voSound(sound,guys[idx].model_type,MakeVector2(guys[idx].pos));
        }
        else
           Resources::getResources->voSound(sound,guys[idx].model_type,MakeVector2(guys[idx].pos));
    }
        
}
void SaveModels(){
   // SortModels();
   // qsort (guys, nguys, sizeof (Entity*), compare_creatures2);
    int slot=0;
    for(int i=0;i<nguys;i++){
         if(slot>=MAX_CREATURES_SAVED)break;
        if(guys[i].alive&&guys[i].touched){
            creatureData[slot].type=guys[i].model_type;
            creatureData[slot].color=guys[i].color;
            creatureData[slot].pos=MakeVector(guys[i].pos.x,guys[i].pos.y,guys[i].pos.z);
            creatureData[slot].vel=MakeVector(guys[i].vel.x,guys[i].vel.y,guys[i].vel.z);
            creatureData[slot].angle=guys[i].angle;
            creatureData[slot].touched=1;
            slot++;
        }
    }
    for(int i=0;i<nguys;i++){
        if(slot>=MAX_CREATURES_SAVED)break;
        if(guys[i].alive&&!guys[i].touched){
            creatureData[slot].type=guys[i].model_type;
            creatureData[slot].color=guys[i].color;
            creatureData[slot].pos=MakeVector(guys[i].pos.x,guys[i].pos.y,guys[i].pos.z);
            creatureData[slot].vel=MakeVector(guys[i].vel.x,guys[i].vel.y,guys[i].vel.z);
            creatureData[slot].angle=guys[i].angle;
             creatureData[slot].touched=0;
            slot++;
        }
            
    }
    while(slot<MAX_CREATURES_SAVED){
        creatureData[slot].type=-1;
        slot++;
    }
    
}

int SimpleCollision(Entity* e){
  
    
    int bx=(int)roundf(e->pos.x-.5f);
	int bz=(int)roundf(e->pos.z-.5f);
	
    
	float bot=e->pos.y-mradius[e->model_type]+centers[e->model_type].y;
	int bh=(int)roundf(bot);
	for(int k=0;k<2;k++){
		int ih=bh+k;//[ter getHeight:bx :bz];
		for(int i=0;i<3;i++){
			for(int j=0;j<3;j++){
				int cx=i+bx-1;
				int cz=j+bz-1;
				if(getLandc(cx ,cz ,ih)<=0){continue;}
                
                
                return getLandc(cx ,cz ,ih);
				
				
			}
		}
		
		
	}
    
    return FALSE;
    
}
void ResetModel(int i){
    guys[i].model_type=-1;
    guys[i].angle=0;
    guys[i].pos=PVRTVec3(0,0,0);    
    guys[i].alive=TRUE;
    guys[i].color=0;    
    guys[i].timer=0;
    guys[i].flash=0;
    guys[i].idx=i;
    guys[i].touched=FALSE;
    guys[i].life=START_LIFE;
    guys[i].alive=TRUE;
    guys[i].update=TRUE;
    guys[i].state=0;
    guys[i].greeted=FALSE;
    guys[i].excited=FALSE;
    guys[i].blinktimer=1;
    guys[i].justhit=FALSE;
    guys[i].ragetimer=0;
    guys[i].runaway=0;
    if(i==nguys)
        guys[i].blinktimer=0;
    guys[i].gotoDest=0;
    guys[i].vel=PVRTVec3(0,0,0);
    guys[i].acc=PVRTVec3(0,0,0);
    guys[i].onground=guys[i].onIce=0;
    guys[i].onfire=FALSE;
}
void addMoreCreaturesIfNeeded(){
    int totalactive=0;
    int gc=0;
    int nTouched=0;
    for(int i=0;i<nguys;i++){
        if(guys[i].model_type!=-1&&(guys[i].update==TRUE||(guys[i].touched==TRUE&&nTouched<150))){
            if(guys[i].touched==TRUE){
                nTouched++;
                
                float adjx=guys[i].pos.x-[World getWorld].fm->chunkOffsetX*CHUNK_SIZE;
                float adjz=guys[i].pos.z-[World getWorld].fm->chunkOffsetZ*CHUNK_SIZE;
                if(adjx>0&&adjx<T_SIZE&&adjz>0&&adjz<T_SIZE ){
                    
                    
                    totalactive++;
                    guys[i].update=TRUE;
                }
               
            }else{
                totalactive++;
              
            }
            continue;
        }
    }
    if(totalactive<15)
    printg("adding more creatures");
    while(totalactive<15&&gc<nguys){
        if(guys[gc].touched==FALSE&&(guys[gc].model_type==-1||!guys[gc].update||!guys[gc].alive)){
          ResetModel(gc);
        }else{
            gc++;
            continue;
                
        }
    
        
        guys[gc].targetangle=randf(3.14f*2);
        
        int ly=-1;
        //guys[gc].pos=PVRTVec3(arc4random()%25+90,arc4random()%5+32,T_HEIGHT);
        for(int i=0;i<20;i++){
        guys[gc].pos=PVRTVec3(arc4random()%T_SIZE+[World getWorld].fm->chunkOffsetX*CHUNK_SIZE,T_HEIGHT-15,arc4random()%T_SIZE+[World getWorld].fm->chunkOffsetZ*CHUNK_SIZE);
            for(int y=T_HEIGHT-1;y>0;y--){
                int t=getLandc(guys[gc].pos.x,guys[gc].pos.z,y);
                if(t>0){
                    if(((blockinfo[t]&IS_LIQUID))  ||  t==TYPE_LEAVES){
                        ly=-1;
                        break;
                        
                    }else{
                        ly=y;
                        goto escapenest;
                    }
                    
                }
            }
        }
    escapenest:
        if(ly==-1){
            printg("oob model gen\n");
            continue;
        }
        guys[gc].pos.y=ly+2;
         guys[gc].color=0;
       /* int breakout=45;
        int lastType=-1;
        while(true){
            int t=SimpleCollision(&guys[gc]);
            lastType=t;
            if(t!=0)break;
           
            if(guys[gc].pos.y<0||breakout<=0){
                break;
            }
            guys[gc].pos.y-=1;
            breakout--;
        }
        int ltype=0,type=0;;
        breakout=50;
        while(guys[gc].pos.y<=T_HEIGHT-15&&breakout>0){
            ltype=type;
            breakout--;
            type=SimpleCollision(&guys[gc]);
            if(type==0)break;
            guys[gc].pos.y+=1;
        }*/
       
        //   printg("creature_pos: %f,%f,%f\n",guys[gc].pos.x,guys[gc].pos.z,guys[gc].pos.y);
        /*  if(ltype!=TYPE_GRASS&&ltype!=TYPE_GRASS2&&ltype!=TYPE_GRASS3&&ltype!=TYPE_DIRT){
         totalactive++;
         guys[gc].alive=FALSE;
         //printg("type:%d\n",ltype);
         
         continue;
         }*/
        //printg("creating creature:%d pos:(%f,%f,%f)\n",gc,guys[gc].pos.x,guys[gc].pos.y,guys[gc].pos.z);
        
        
      
        
        if([World getWorld].terrain->tgen->LEVEL_SEED==DEFAULT_LEVEL_SEED){
            
            int ppx=guys[gc].pos.x-4096*CHUNK_SIZE+GSIZE/2;
            int ppz=guys[gc].pos.z-4096*CHUNK_SIZE+GSIZE/2;
            ppx=ppx/(GSIZE/4);
            ppz=ppz/(GSIZE/4);
            if(ppx>4)ppx=4;
            if(ppz>4)ppz=4;
            if(ppx<0)ppx=0;
            if(ppz<0)ppz=0;
           /* const int regionSkyColors[4][4]={
                {COLOR_BWG1,COLOR_NORMAL_BLUE,COLOR_NORMAL_BLUE,COLOR_NORMAL_BLUE},
                {COLOR_ORANGE2,COLOR_NORMAL_BLUE,COLOR_NORMAL_BLUE,COLOR_NORMAL_BLUE},
                {COLOR_NORMAL_BLUE,COLOR_NORMAL_BLUE,COLOR_NORMAL_BLUE,COLOR_NORMAL_BLUE},
                {COLOR_PURPLE1,COLOR_NORMAL_BLUE,COLOR_NORMAL_BLUE,COLOR_RED5}};*/
            if(ppx==0&&ppz==0){
                guys[gc].model_type=M_MOOF;
                guys[gc].color=COLOR_BWG1;
            }else if(ppx==0&&(ppz==2||ppz==1)){
                if(arc4random()%2==0)
                guys[gc].color=COLOR_ORANGE1+arc4random()%2;
                 guys[gc].model_type=arc4random()%(NUM_CREATURES);
            }
            else if(ppx==0&&ppz==3){
               
                guys[gc].color=COLOR_PINK1+arc4random()%2;
                 guys[gc].model_type=arc4random()%(NUM_CREATURES);
            }else if(ppx==3&&ppz!=0){
                do{
                 guys[gc].model_type=arc4random()%(NUM_CREATURES);
                }while(guys[gc].model_type!=M_STALKER&&guys[gc].model_type!=M_CHARGER);
            }else
            {
                 guys[gc].model_type=arc4random()%(NUM_CREATURES);
            }
           // guys[gc].model_type=M_CHARGER;
            //printg("region: %d,%d\n",(int)ppx,(int)ppz);
            
           /* if(lrx!=ppx||lrz!=ppz){
                if(lrx==-1||regionSkyColors[ppz][ppx]!=regionSkyColors[lrz][lrx]){
                    [World getWorld].terrain.final_skycolor=colorTable[regionSkyColors[(int)(ppz+64)%4][(int)(ppx+64)%4]];
                }
                lrx=ppx;
                lrz=ppz;
            }*/
            
        }else guys[gc].model_type=arc4random()%(NUM_CREATURES);

      // guys[gc].model_type=M_CHARGER;
        guys[gc].state=0;
        guys[gc].touched=FALSE;
       
        guys[gc].life=START_LIFE;
        guys[gc].timer=1;
        guys[gc].frame=getFrame(guys[gc].model_type,guys[gc].state,0);
        totalactive++;
        guys[gc].update=TRUE;
        
        gc++;
        printg("new creature gened:%d \n",gc);
    }
    
    extern int g_offcx;
    
    
    
}
void LoadModels2(){
    int gc=0;
    int totalactive=0;
    for(int i=0;i<nguys;i++){
        ResetModel(i);
        guys[i].update=false;
        guys[i].alive=false;
        guys[i].model_type=-1;
    }
    guys[nguys].model_type=-1;
    for(int i=0;i<MAX_CREATURES_SAVED;i++){
        if( creatureData[i].type>-1&&creatureData[i].type<NUM_CREATURES&&creatureData[i].color>=0&&creatureData[i].color<256){
            
            ResetModel(gc);
            
            guys[gc].model_type=creatureData[i].type;
            if(guys[gc].model_type==-1){
                printg("-1 model type\n");
                continue;
            }
            guys[gc].pos=vpv(creatureData[i].pos);
            guys[gc].vel=vpv(creatureData[i].vel);
            guys[gc].color=creatureData[i].color;
            guys[gc].angle=creatureData[i].angle;
            guys[gc].targetangle=creatureData[i].angle;
            if(creatureData[i].touched==1)
                guys[gc].touched=TRUE;
            else 
                guys[gc].touched=FALSE;
            guys[gc].life=START_LIFE;
            
            float adjx=creatureData[i].pos.x-[World getWorld].fm->chunkOffsetX*CHUNK_SIZE;
            float adjz=creatureData[i].pos.z-[World getWorld].fm->chunkOffsetZ*CHUNK_SIZE;
            if(adjx>0&&adjx<T_SIZE&&adjz>0&&adjz<T_SIZE ){
                
               
                totalactive++;
                 guys[gc].update=TRUE;
            }else {
               // totalactive++;
                //guys[gc].update=TRUE;
                guys[gc].update=FALSE;
            }
            
            gc++;
            
            
            if(gc==nguys)break;
        }else{
            if(creatureData[i].type!=-1){
           //     printg("corrupt creature type: %d,  idx: %i\n",creatureData[i].type,i);
            }
        }
        
    }
    printg("LoadModels2  totalactive:%d   gc: %d \n",totalactive,gc);
   // Vector player_pos=[World getWorld].player.pos;
    for(int i=gc;i<nguys;i++){
        guys[i].update=FALSE;
    }
    addMoreCreaturesIfNeeded();
    // printg("LoadModels2  totalactive:%d   gc: %d \n",totalactive,gc);
    while(totalactive<40&&gc<nguys){
        if(guys[gc].update==TRUE){
        
            totalactive++;
            gc++;   //infinite loop sometimes
            continue;
        }else if(guys[gc].update==FALSE){
            if(!guys[gc].touched){
            ResetModel(gc);
            guys[gc].alive=false;
                guys[gc].update=false;
                gc++;}
            else{
                gc++;
            }
        }else gc++;
    }
     printg("LoadModels2  totalactive:%d   gc: %d \n",totalactive,gc);
   /* while(totalactive<40&&gc<nguys){
        ResetModel(gc);
        guys[gc].targetangle=randf(3.14f*2);
        //guys[gc].pos=PVRTVec3(arc4random()%25+90,arc4random()%5+32,T_HEIGHT);
        guys[gc].pos=PVRTVec3(arc4random()%T_SIZE+[World getWorld].fm.chunkOffsetX*CHUNK_SIZE,T_HEIGHT-15,arc4random()%T_SIZE+[World getWorld].fm.chunkOffsetZ*CHUNK_SIZE);
       
        int breakout=30;
        while(!SimpleCollision(&guys[gc])&&guys[gc].pos.y>=0&&breakout>0){
            guys[gc].pos.y-=1;
            breakout--;
        }
        int ltype=0,type=0;;
        breakout=50;
        while(guys[gc].pos.y<=T_HEIGHT-15&&breakout>0){
            ltype=type;
            breakout--;
            type=SimpleCollision(&guys[gc]);
            if(type==0)break;
            guys[gc].pos.y+=1;
        }
    
         //printg("creating creature:%d pos:(%f,%f,%f)\n",gc,guys[gc].pos.x,guys[gc].pos.y,guys[gc].pos.z);
        guys[gc].model_type=arc4random()%(NUM_CREATURES);
        guys[gc].state=0;   
        guys[gc].touched=FALSE;
        guys[gc].color=0;
        guys[gc].life=START_LIFE;
        guys[gc].timer=1;
        guys[gc].frame=getFrame(guys[gc].model_type,guys[gc].state,0);
        totalactive++;
        guys[gc].update=TRUE;

        gc++;
    }*/
   
   /* while(gc<nguys){
        ResetModel(gc);
        guys[gc].alive=false;
        gc++;
    }*/
}

void setState(int idx,int state){
    if(guys[idx].state!=state){
        if(state==DEFAULT_WALK&&(guys[idx].model_type==M_GREEN||guys[idx].model_type==M_NERGLE)){
            guys[idx].frame=0;
        }else
        guys[idx].frame=getFrame(guys[idx].model_type,state,0);
        guys[idx].state=state;
    }
    
}
float wrapx(float x){
    return x;
   // int ggx=((int)x+g_offcx)%T_SIZE;
   // return (x-(int)x)+ggx;
}
float wrapz(float z){
  //  int ggz=((int)z+g_offcz)%T_SIZE;
 //   return (z-(int)z)+ggz;
    
    return z;
}
int PointTestModels(float x,float y,float z){
    
   // printg("point testing models: %f,%f   %f,%f  global_offs: %d,%d\n" ,x,z,wrapx(x),wrapz(z),g_offcx,g_offcz);
    for(int i=0;i<nguys;i++){
        if(!guys[i].alive||!guys[i].update)continue;
        Entity* e=&guys[i];
        
     /*   int ggx=((int)x+g_offcx)%T_SIZE;
        int ggz=((int)z+g_offcz)%T_SIZE;
      
        float xx=(x-(int)x)+ggx;
        float zz=(z-(int)z)+ggz;*/
       // printg("creature: %f, %f\n", e->pos.x,e->pos.y);
        float ax=e->pos.x-wrapx(x);
        float az=e->pos.z-wrapz(z);
        
        float bot=e->pos.y+dmin[e->model_type].y;
        float top=e->pos.y+dmax[e->model_type].y;
        
        if(ax*ax+az*az<=mradius[e->model_type]*mradius[e->model_type]&&y>=bot&&y<=top){
            return i;
        }else{
           // if(ax*ax+az*az<=mradius[e->model_type]*mradius[e->model_type])
           //     printg("missed y?\n");
           // printg("distance from hit: %f,%f, 2(%f,%f)\n",ax,az,e->pos.x,x);
        }

    }
    return -1;
}
void ExplodeModels(Vector p,int color){
    for(int i=0;i<nguys;i++){
        if(!guys[i].alive||!guys[i].update)continue;
        Entity* e=&guys[i];
        PVRTVec3 pos=PVRTVec3(p);
        pos.x=wrapx(pos.x);
        pos.z=wrapz(pos.z);
        pos=(e->pos+centers[e->model_type])-pos;
        if(pos.lenSqr()<EXPLOSION_RADIUS*EXPLOSION_RADIUS){
            if(color==0){
                float hit_force=(EXPLOSION_RADIUS*EXPLOSION_RADIUS)-pos.lenSqr();
                pos=pos.normalize();
                e->state=0;
                setState(e->idx,DEFAULT_DAMAGE);
                e->life--;
                if(e->life<=0){
                    killCreature(e->idx);
                }else
                    PlaySound(e->idx,VO_HIT);
                
                
                e->vel+=hit_force*pos;
                
                e->vel.y+=6;
                e->flash=1.0f;
            }else{
                ColorModel(e->idx,color);
            }
           
        }
        
    }
    Player* e=[World getWorld].player;
    PVRTVec3 player_pos=MakePVR([World getWorld].player->pos);
   // player_pos.x=wrapx(player_pos.x);
   // player_pos.z=wrapz(player_pos.z);
    PVRTVec3 pos=PVRTVec3(p);
    PVRTVec3 ppos=player_pos;
    
    
    pos=ppos-p;
    extern Vector colorTable[256];
    if(pos.lenSqr()<EXPLOSION_RADIUS*EXPLOSION_RADIUS){
        if(color!=0){
            [World getWorld].hud->flash=.9f;
             [World getWorld].hud->flashcolor=colorTable[color];
            
        }else{
            
        
        float hit_force=((EXPLOSION_RADIUS*EXPLOSION_RADIUS)-pos.lenSqr())*.75f;
        pos=pos.normalize();
        
        pos*=hit_force;
        Vector vel=e->vel;
        vel.x+=pos.x;
        vel.y+=pos.y+6;
        vel.z+=pos.z;
        e->vel=vel;
         Resources::getResources->playSound(S_HIT);
            if([World getWorld].player->life>.5f)
                [World getWorld].player->takeDamage(.38f);
            else
                [World getWorld].player->takeDamage(.05f);
       
        }
    }

    
}
void UpdateBoxes(Entity* e);
extern Polyhedra testbox;
bool CheckCollision(Entity* e){
    nest_count++;
    if(nest_count>10)return false;
    if(e->model_type<0||e->model_type>NUM_CREATURES)return FALSE;
   float mrad=mradius[e->model_type];
    float bot=e->pos.y-mrad+centers[e->model_type].y;
	float top=e->pos.y+mrad+centers[e->model_type].y;
	float left=e->pos.x-mrad;
	float right=e->pos.x+mrad;
	float front=e->pos.z-mrad;
	float back=e->pos.z+mrad;
    
   // Polyhedra pbox=makeBox(left,right,back,front,bot,top);
    UpdateBoxes(e);
    
    if(e->ragetimer>0){
    
        if(collidePolyhedra(e->box,testbox)){
            
            e->ragetimer=0;
        
            Player* ep=[World getWorld].player;
            PVRTVec3 player_pos=MakePVR([World getWorld].player->pos);
            player_pos.x=wrapx(player_pos.x);
            player_pos.z=wrapz(player_pos.z);
            PVRTVec3 pos=PVRTVec3(e->pos);
            PVRTVec3 ppos=player_pos;
            pos=ppos-e->pos;
            
                float hit_force=(EXPLOSION_RADIUS*EXPLOSION_RADIUS)/6;
                pos=pos.normalize();
                
                pos*=hit_force;
                Vector vel=ep->vel;
                vel.x+=pos.x;
                vel.y+=pos.y+4;
                vel.z+=pos.z;
                ep->vel=vel;
                if(e->model_type==M_CHARGER||e->model_type==M_STALKER)
                ep->takeDamage(.33333333f);
                else
                ep->takeDamage(.5f);
            
                ep->flash=0.6f;
                Resources::getResources->playSound(S_HIT);
            
        }
       
    }
    
    
    Vector minminTranDist=MakeVector(0,0,0);
    int collided=0;
    for(int x=(int)left;x<=(int)right;x++){
        for(int z=(int)front;z<=(int)back;z++){
            for(int y=(int)bot;y<=(int)top;y++){
                int type=getLandc(x,z,y);
                if(type<=0)continue;
                if(type==TYPE_FLOWER)continue;
                int bleft=x;
				int bright=x+1;
				int bfront=z;
				int bback=z+1;
                int bbot=y;
                int btop=y+1;
                Polyhedra pbox2;
                if(type>=TYPE_STONE_RAMP1&&type<=TYPE_ICE_RAMP4){
                    
                    pbox2=makeRamp(bleft,bright,bback,bfront,bbot,btop,type%4);
                    // NSLog(@"yop");
                    
                }else if(type>=TYPE_STONE_SIDE1&&type<=TYPE_ICE_SIDE4){
                    pbox2=makeSide(bleft,bright,bback,bfront,bbot,btop,type%4);
                    
                }else if(blockinfo[type]&IS_LIQUID){
                    pbox2=makeBox(bleft,bleft+1,bback,bfront,bbot,bbot+getLevel(type)/4.0f);
                }else
                    pbox2=makeBox(bleft,bright,bback,bfront,bbot,btop);
                
                
                
               // int ggx=(x+g_offcx)%T_SIZE;
             //   int ggz=(z+g_offcz)%T_SIZE;
                
                
                if(collidePolyhedra(e->box,pbox2)){
                    if(blockinfo[type]&IS_WATER){
                        if(!e->lastInLiquid&&minTranDist.y>0&&e->vel.y<-6){
                            e->lastInLiquid=TRUE;
                            
                            //[[Resources getResources] playSound:SOUND_SPLASH];
                        }
                        e->inLiquid=TRUE;
                        continue;
                    }
                    if(v_length2(minTranDist)>v_length2(minminTranDist)){
                        if(type>=TYPE_STONE_RAMP1&&type<=TYPE_ICE_RAMP4){                            
                          
                        }
                       //paint trails
                        /*
                        for(int yy=0;yy<T_HEIGHT;yy++){
                            if(getLandc(x,z,yy)==TYPE_GRASS&&[[World getWorld].terrain getColor:x:z:yy]!=e->idx){
                                //    printg("setting color: %d,%d,%d local:(%d,%d)\n",ggx,ggz,y,x,z);
                                [[World getWorld].terrain paintBlock:x:z:yy:e->idx];
                            }
                            
                        }*/
                        collided=type;
                        minminTranDist=minTranDist;
                    }            
                    
                    
                }
            }
        }
    }
    if(!collided){
       
    if(collidePolyhedra(e->box,testbox)){
       
        if(v_length2(minTranDist)>v_length2(minminTranDist)){
           
            
            collided=999999;
            minminTranDist=minTranDist;
        }            
        
        
    }
    }
    
    if(collided){        
        
        if(minminTranDist.y>0){
            if(collided==TYPE_ICE||(collided>=TYPE_ICE_RAMP1&&collided<=TYPE_ICE_RAMP4)||(collided>=TYPE_ICE_SIDE1&&collided<=TYPE_ICE_SIDE4)){
                e->onIce=TRUE;
            }
        }
        
        PVRTVec3 vtran(minminTranDist.x,minminTranDist.y,minminTranDist.z);
        
        e->pos+=vtran;     
        PVRTVec3 normal=vtran.normalized();
     
        float n=e->vel.dot(normal);
        
        //  NSLog(@"before-vel:(%f,%f,%f)  normal:(%f,%f,%f) dotp: %f",vel.x,vel.y,vel.z,normal.x,normal.y,normal.z,n);
        if(blockinfo[collided]&IS_LAVA){
            n*=1.8;
            if(e->state!=DEFAULT_DAMAGE){
                e->state=0;
                setState(e->idx,DEFAULT_DAMAGE);
                e->life--;
                if(e->life<=0){        
                    killCreature(e->idx);
                } else
                     PlaySound(e->idx,VO_HIT);        
            e->flash=1.0f;
            }
           // [[Resources getResources] playSound:SOUND_LAVA_BURN];	
           // NSLog(@"n:%f",n);
            if(minminTranDist.y>0){
                if(n>-10&&n<0)n=-5;
                e->jumping=false;
            }
        }
        if(collided==TYPE_TRAMPOLINE){
            n*=2;
          //  [[Resources getResources] playSound:SOUND_BOUNCE];	
           // NSLog(@"n:%f vel.y:%f",n,vel.y);
            
            if(minminTranDist.y>0){
                
                if(n>-12&&n<0)n=-6;
                e->jumping=false;
            }
        }
        
        PVRTVec3 vel2=normal*n;
        
        // if(!onIce&&!lastOnIce){
        e->vel=e->vel-vel2;
        
        // NSLog(@"after-vel:(%f,%f,%f)  vel2:(%f,%f,%f)",vel.x,vel.y,vel.z,vel2.x,vel2.y,vel2.z);
        // }
        if(minminTranDist.y>0&&(e->vel.y<=0||(collided>=TYPE_STONE_RAMP1&&collided<=TYPE_ICE_RAMP4))){
            
            if(collided>=TYPE_STONE_RAMP1&&collided<=TYPE_ICE_RAMP4){
                if(collided>=TYPE_ICE_RAMP1&&collided<=TYPE_ICE_RAMP4){
                    
                }
                if(absf(e->lpos.y-e->pos.y)<.1||(collided<TYPE_ICE_RAMP1||collided>TYPE_ICE_RAMP4)){
                    if(!e->onIce){
                      //  NSLog(@"hit");
                        // vel.y=0;
                        e->onground=true;
                        
                    }                    
                }            
                
            }else{
                if(!e->onIce){                   
                    e->onground=true;
                }
                
            }
            
            
            if(e->jumping){
           //     [[Resources getResources] playSound:SOUND_LAND];			
            }
            e->jumping=FALSE;
        }
        
      
        CheckCollision(e);
        nest_count--;
        
    } 
    
	return collided; 
	

    
}
int nestmove=0;
static float poffsetx,poffsetz;

void Move(Entity* e,float etime){
   
   
    if(ABS(e->vel.y)*etime>.4f||ABS(e->vel.x)*etime>.4f||ABS(e->vel.z)*etime>.4f){
        nestmove++;
        if(nestmove<2){
        Move(e,etime/2);
        Move(e,etime/2);
        nestmove--;
        return;
        }else{
            etime/=2;
        }
    }
    float move_speed=2;
    float jump_speed=8.5f;
    float JUMP_SPEED= 7.0f;
    float FLOW_SPEED=5.0f;
    if(e->inLiquid){
        
        
        e->acc.y=GRAVITY/3.0f;
        
        if(e->vel.y>JUMP_SPEED/4)
            e->vel.y=JUMP_SPEED/4;
        if(e->vel.y<-JUMP_SPEED*2)
            e->vel.y=-JUMP_SPEED*2;
        
        Vector flowdir=getFlowDirection(e->pos.x,e->pos.z,e->pos.y+min[e->model_type].y*scale+.01);
        // printg("flowdir (%f,%f)\n",flowdir.x,flowdir.z);
        e->vel.x+=flowdir.x*FLOW_SPEED*etime;
        e->vel.z+=flowdir.z*FLOW_SPEED*etime;
    }else{
        
         e->acc.y=-GRAVITY;
        
    }
    
    if(e->state==DEFAULT_WALK||e->state==DEFAULT_JUMP){
        float cosYaw=cos(e->angle+C_PI/2.0f );
        float sinYaw=sin(e->angle+C_PI/2.0f);
        if(e->runaway>0||e->ragetimer>0)move_speed*=2.0f;
        if(e->inLiquid)move_speed/=3.0f;
        e->vel.x=cosYaw*move_speed;
        e->vel.z=sinYaw*move_speed;
        
        if(e->onground){
            Vector vpos=MakeVector(e->pos.x,e->pos.y,e->pos.z);
            int x=vpos.x+cosYaw*1.2f;
            int z=vpos.z+sinYaw*1.2f;
            
            
            int y=min[e->model_type].y*scale+vpos.y+.01;
            int type=getLandc(x,z,y );
            if(!e->onIce){
            if(type!=TYPE_NONE&&type!=TYPE_FLOWER&&type!=TYPE_LADDER&&type!=TYPE_VINE&&type!=TYPE_LAVA&&type>0&&!(type>=TYPE_STONE_RAMP1&&type<=TYPE_ICE_SIDE4)&&!(blockinfo[type]&IS_WATER)&&getLandc(x,z,y+1)<=0){
                
                if(getLandc(x,z,y+2)<=0&&getLandc(vpos.x,vpos.z,vpos.y+2)<=0){
                    e->vel.y=jump_speed;
                    setState(e->idx,DEFAULT_JUMP);
                   //  printg("jumping:%d\n",e->idx);
                }
                
            }
            }
        }
    }else if(e->onIce&&e->onground){
        e->vel.x*=.99;
        e->vel.z*=.99;
    }else if(e->onground||e->inLiquid){
        e->vel.x*=.9f;
        e->vel.z*=.9f;
    }
    
    e->onIce=FALSE;
    PVRTVec3 lvel=e->vel;
    e->vel.x+=e->acc.x*etime;
    e->vel.y+=e->acc.y*etime;
    e->vel.z+=e->acc.z*etime;
    //  NSLog(@"vel(%f,%f,%f) acc(%f,%f,%f)",vel.x,vel.y,vel.z,accel.x,accel.y,accel.z);
    /* e->vel.x*=0;
     e->vel.z*=0;
    if(e->angle<M_PI/8)e->angle=M_PI/8;
    if(e->angle>M_PI/6)e->angle=M_PI/6;
    */e->lpos=e->pos; 
    e->pos.y+=e->vel.y*etime;
    e->pos.x+=e->vel.x*etime;
    e->pos.z+=e->vel.z*etime;
    
    e->onground=FALSE;
    nest_count=0;
    e->lastInLiquid=e->inLiquid;
    e->inLiquid=FALSE;
    float mag=0;
    mag=e->vel.length();
    poffsetx=[World getWorld].fm->chunkOffsetX*CHUNK_SIZE;
    poffsetz=[World getWorld].fm->chunkOffsetZ*CHUNK_SIZE;
    CheckCollision(e);  
    
    
    
     // if(onground)NSLog(@"grounded sucka");
    
    /*if((vel.x!=0||vel.z!=0)&&(onIce)){
        Vector vdir=vel;
        Vector volddir=lvel;
        vdir.y=0;
        volddir.y=0;
        NormalizeVector(&vdir);
        NormalizeVector(&volddir);
        Vector crossp=crossProduct(vdir,volddir);
        
        if(absf(absf(crossp.y)-.707107f)<.00001f){
            if(crossp.y>0)yawanimation+=45;
            else yawanimation-=45;
            
        }
        if(yawanimation>360)yawanimation-=360;
        if(yawanimation<-360)yawanimation+=360;
        
        
    }*/
    if(mag!=0&&e->onIce){
        
        //Vector dir=v_sub(pos,lpos);
        float dp=lvel.dot(e->vel);
        if(dp>0){
            e->vel.normalize();;
            e->vel*=mag;
           
        }else{
            //vel=v_div(v_sub(pos,lpos),etime);
        }
        // NSLog(@"icy");
        //if(!onground)NSLog(@"wtf");
        float EXCITE_SPEED=5.0f;
               if(!e->excited&&e->vel.lenSqr()>=EXCITE_SPEED){
                   if(!e->onfire&&&e->ragetimer<=0)
              PlaySound(e->idx,VO_EXCITED);
            e->excited=TRUE;
        }
    }
    if(!e->onIce||mag==0)
        e->excited=FALSE;
    
    
    if(e->inLiquid&&e->onfire){
        e->onfire=FALSE;
        e->runaway=0;
        e->life=START_LIFE;
          PlaySound(e->idx,VO_RELIEVED);
        [World getWorld].effects->removeFire(e->fireidx);
    }
    
    
    
    if(e->onfire){
        PVRTVec3 upos=unwrap(e->pos);
        
        Vector sigh;
        sigh.x=upos.x;
        sigh.y=upos.y+centers[e->model_type].y;
        sigh.z=upos.z;
        [World getWorld].effects->updateFire(e->fireidx,sigh);
    }
    
    
    if(e->pos.y <-10){ //darn, popped out of bounds
        e->pos.y=T_HEIGHT+3;
        e->vel.y=0;
        
    }
    
    
}

float xtimer=0;
int model_update_count=0;
int model_render_count=0;
void UpdateModels(float etime){
  
    xtimer+=etime;
    if(xtimer>5){
        for(int i=0;i<nguys;i++){
           // printg("Guys[%d]=  Type: %d  State: %d Frame: %f\n",i,guys[i].model_type,guys[i].state,guys[i].frame);
        }
       // printg("\n");
        xtimer=0;
    }
   model_update_count=0;
    for(int i=0;i<nguys;i++){     
        if(!guys[i].alive||!guys[i].update)continue;
        
        float adjx=guys[i].pos.x-[World getWorld].fm->chunkOffsetX*CHUNK_SIZE;
        float adjz=guys[i].pos.z-[World getWorld].fm->chunkOffsetZ*CHUNK_SIZE;
        
        
        if(adjx>0&&adjx<T_SIZE&&adjz>0&&adjz<T_SIZE ){
            
             model_update_count++;
            //guys[i].update=TRUE;
        }else {
            guys[i].update=FALSE;
            continue;
           
        }
        nestmove=0;
        if(guys[i].insideView||(!guys[i].onground||guys[i].onIce||guys[i].ragetimer>0||guys[i].onfire))
        Move(&guys[i],etime);
        
        
        
        if(guys[i].model_type<0||guys[i].model_type>NUM_CREATURES)guys[i].alive=FALSE;
    }
    
    
    for(int i=0;i<nguys;i++){  
        if(!guys[i].alive||!guys[i].update)continue;
        if(guys[i].onfire){
            guys[i].life-=etime/2;
            if(guys[i].life<=0){
                killCreature(guys[i].idx);
            }
        }
        bool endCycle=FALSE;
        guys[i].timer-=etime;
        guys[i].runaway-=etime;
        guys[i].ragetimer-=etime;
        guys[i].blinktimer+=etime;
        if(guys[i].blinktimer>=.2f){
            guys[i].blinktimer=-(float)((arc4random()%4+1));
           // printg("hmmm: %f\n",guys[i].blinktimer);
        }
        if(guys[i].state!=0){
            bool inbounds=true;
            int end=getFrame(guys[i].model_type,guys[i].state,1);
            int start=getFrame(guys[i].model_type,guys[i].state,0);
            if(guys[i].frame>=start&&guys[i].frame<end){
                inbounds=true;
            }
            if(guys[i].runaway>0||guys[i].ragetimer>0){
                guys[i].frame+=etime*60*2.0f;
            }else{
            guys[i].frame+=etime*60;
            }
            if(guys[i].frame>=end){
                
                if(inbounds)
                    guys[i].frame=start+  (guys[i].frame-end);
                else{
                    guys[i].frame=start;
                }
                endCycle=TRUE;
            }
        }else{           
            if(guys[i].timer<0){
                endCycle=TRUE;                
            }
        }
        if(guys[i].flash>0){
            guys[i].flash-=etime*2;
            if(guys[i].flash<0)guys[i].flash=0;
        }
        
        if(guys[i].angle!=guys[i].targetangle){
            if(guys[i].angle<0)guys[i].angle+=M_PI*2.0f;
            if(guys[i].targetangle<0)guys[i].targetangle+=M_PI*2.0f;
            if(guys[i].angle>=M_PI*2.0f)guys[i].angle-=M_PI*2.0f;
            if(guys[i].targetangle>=M_PI*2.0f)guys[i].targetangle-=M_PI*2.0f;
            if(guys[i].angle!=guys[i].targetangle){
                float dir=1;
                if(guys[i].angle>guys[i].targetangle){
                    if(absf(guys[i].angle-guys[i].targetangle)<absf(guys[i].angle-(guys[i].targetangle+M_PI*2.0f)))
                    dir=-1;
                }else{
                    if(absf(guys[i].angle-guys[i].targetangle)>absf((guys[i].angle+M_PI*2.0f)-(guys[i].targetangle)))
                    dir=-1;
                }
                int before=sign(guys[i].angle-guys[i].targetangle);   
                if(guys[i].runaway>0||guys[i].ragetimer>0){
                   guys[i].angle+=dir*ROTATE_SPEED*etime*2.0f;
                }else{
                guys[i].angle+=dir*ROTATE_SPEED*etime;
                }
                int after=sign(guys[i].angle-guys[i].targetangle); 
                if(before!=after){
                    guys[i].angle=guys[i].targetangle;
                }
            }
        }
        if(guys[i].onground&&(guys[i].justhit||guys[i].runaway>0||guys[i].ragetimer>0)&&guys[i].state!=DEFAULT_WALK){
            endCycle=TRUE;
        }
        PVRTVec3 player_pos=MakePVR([World getWorld].player->pos);
        player_pos.x=wrapx(player_pos.x);
        player_pos.z=wrapz(player_pos.z);
        if((guys[i].onground||guys[i].inLiquid)&&endCycle&&!guys[i].onIce){
            
            float distance=(player_pos-guys[i].pos).lenSqr();
            float distance_fade=4.0f;
            
            if(guys[i].model_type==M_STALKER||guys[i].model_type==M_CHARGER){
                if(distance/2<distance_fade*distance_fade&&guys[i].insideView&&guys[i].ragetimer<=0)
                guys[i].justhit=true;
            }else
            if(distance<distance_fade*distance_fade&&guys[i].insideView&&guys[i].ragetimer<=0){
                
                if(!guys[i].greeted){
                      guys[i].greeted=TRUE;
                    if(isFacingPlayer(i)&&guys[i].ragetimer<=0&&!guys[i].onfire){
                       
                      
                        PlaySound(i,VO_APPROACH);
                    }
                          
                    Vector dir;
                    
                    dir.x=guys[i].pos.x-player_pos.x;
                    dir.z=guys[i].pos.z-player_pos.z;
                    
                    
                    guys[i].targetangle=(atan2(dir.z,dir.x)-atan2(0,1))+M_PI_2;
                }
            }else
                guys[i].greeted=FALSE;
            
            guys[i].timer=0;
            if(guys[i].justhit){
                guys[i].justhit=FALSE;
                int response=arc4random()%6;
                if(guys[i].model_type==M_CHARGER||guys[i].model_type==M_STALKER){
                    
                    response=1;
                }
                if(response==4||response==5){
                    guys[i].runaway=2;
                    
                     PlaySound(i,VO_SCARED);
                    
                }else if(response<=2){
                    guys[i].ragetimer=10;                    
              PlaySound(i,VO_ANGRY);
                }
            }
            if(guys[i].runaway>0||guys[i].ragetimer>0){
                if(guys[i].model_type==M_MOOF){
                   
                    guys[i].vel.y=6.0f;
                }
                
                Vector dir;
                if(guys[i].gotoDest){
                    dir.x=guys[i].pos.x-guys[i].dest.x;
                    dir.z=guys[i].pos.z-guys[i].dest.z;
                }else{
                dir.x=guys[i].pos.x-player_pos.x;
                dir.z=guys[i].pos.z-player_pos.z;
                }
                if(guys[i].ragetimer>0||guys[i].gotoDest>0){
                    guys[i].targetangle=(atan2(dir.z,dir.x)-atan2(0,1))+M_PI_2;
                }
                else{
                guys[i].targetangle=(atan2(dir.z,dir.x)-atan2(0,1))-M_PI_2;
                }
                
                setState(i,DEFAULT_WALK);
            }else{
                guys[i].gotoDest=0;
                int decision=arc4random()%7;
                //decision=0;
                if(decision==0||decision==1){
                    if(decision==1){
                        if(arc4random()%3==0)
                         PlaySound(i,VO_STRETCHING);
                        else
                         PlaySound(i,VO_IDLE); 
                    }
                    setState(i,DEFAULT_IDLE_START+decision);
                    if(guys[i].model_type==M_BATTY)guys[i].timer=1.5f;
                    
                }else if(decision==2||decision==3){
                    int degrees=arc4random()%200-100;
                    float radians=DEGREES_TO_RADIANS(degrees);
                    guys[i].targetangle+=radians;
                    guys[i].timer=1.5f;
                    setState(i,DEFAULT_IDLE_START);
                    
                }else if(decision==4||decision==5){
                    if(guys[i].model_type==M_MOOF){
                        guys[i].vel.y=6.0f;
                    }
                    setState(i,DEFAULT_WALK);
                    guys[i].timer=1;  
                }else{
                    guys[i].timer=1;                
                    setState(i,DEFAULT_IDLE_START);
                    
                }
            }
            
        }else if(endCycle){
            guys[i].timer=0;
            guys[i].timer=1;                
            setState(i,DEFAULT_IDLE_START);
        }
                           
                        
    }
    
}
	
void LoadVbos(int idx);
void DrawModel(int idx);
Polyhedra boxFromBox(Polyhedra* box,PVRTVec3 pos,float angle,float yaw){
    Polyhedra p=*box;
 /*   for(int i=0;i<p.n_faces;i++){
        for(int j=0;j<p.faces[i].n_points;j++){
            PVRTVec3 pt=vpv(box->faces[i].points[j]);
            pt*=PVRTMat4::Translation(pos.x,pos.y, pos.z);// * PVRTMat4::RotationY(angle);
            p.faces[i].points[j]=MakeVector(pt.x,pt.y,pt.z);
        }
    }*/
    for(int i=0;i<p.n_points;i++){
        PVRTVec4 pt=PVRTVec4(box->points[i].x,box->points[i].y,box->points[i].z,1);
     //   pt*= m_mView * PVRTMat4::Translation(pos.x, pos.y, pos.z)*PVRTMat4::RotationY(angle);
        PVRTMat4 mat4=PVRTMat4::Translation(pos.x, pos.y, pos.z)*PVRTMat4::RotationY(angle);
        //for(int j=0;j<16;j++){
            ///printg("%f ",mat4.f[j]);
       // }
        //printg("---\n");
        pt=mat4*pt;
       
       
        p.points[i]=MakeVector(pt.x,pt.y,pt.z);
    }
    return p;
}
void UpdateBoxes(Entity* e){
   
   /* float bot=e->pos.y+min[e->model_type].y*scale;
	float top=e->pos.y+max[e->model_type].y*scale;
	float left=e->pos.x+min[e->model_type].x*scale;
	float right=e->pos.x+max[e->model_type].x*scale;
	float front=e->pos.z+min[e->model_type].z*scale;
	float back=e->pos.z+max[e->model_type].z*scale;
    
    e->box=makeBox(left,right,back,front,bot,top);
    //Polyhedra* p=&e->box;
      */
    e->box=boxFromBox(&mpolys[e->model_type],e->pos,e->angle,e->pitch);
    
}


bool LoadModels(const char* pszReadPath)
{

	CPVRTResourceFile::SetReadPath(pszReadPath);

	if(!CPVRTglesExt::IsGLExtensionSupported("GL_OES_matrix_palette"))
	{
		// printg("bone animations not supported!!\n");
		return false;
	}
    const char* file;
    for(int i=0;i<NUM_CREATURES;i++){
        if(i==M_MOOF)file=moofFile;
        if(i==M_BATTY)file=battyFile;
        if(i==M_GREEN)file=greenFile;
         if(i==M_NERGLE)file=nergleFile;
        if(i==M_STUMPY)file=stumpyFile;
        if(i==M_CHARGER)file=chargerFile;
        if(i==M_STALKER)file=stalkerFile;
        if(models[i].ReadFromFile(file) != PVR_SUCCESS)
        {
          //  printg("failed to load model:%s!!\n",file);
            return false;
        }
    }
     
	//printg("%d,  %d!!!\n",getFrame(M_MOOF,MOOF_WALK,1),models[M_MOOF].nNumFrame);
	


    
    
    
    
	
  //  printg("%s\n", glGetString(GL_EXTENSIONS));
	// Initialise the matrix palette extensions
    if(firstLoad)
	m_Extensions.LoadExtensions();
    
    for(int i=0;i<NUM_CREATURES;i++){
        m_puiVbo[i]=NULL;
        m_puiIndexVbo[i]=NULL;
	LoadVbos(i);
    }
    for(int i=0;i<NUM_CREATURES;i++){
        cmin[i]=vpv(min[i])*scale;
        cmax[i]=vpv(max[i])*scale;
        if( cmin[i].x<.45f){
            
        }
        if(i==M_MOOF){
            cmin[i].x=-.3f;
            cmax[i].x=.3f;
        }
        if(i==M_NERGLE){
            cmin[i].x=-.4f;
            cmax[i].x=.4f;
            cmax[i].y-=.28f;
        }
        if(i==M_BATTY){
            cmin[i].x=-.45f;
            cmax[i].x=.45f;
            cmin[i].z=-.15f;
            cmax[i].z=.15f;
            cmin[i].z+=.1f;
            cmax[i].z+=.1f;
             cmax[i].y+=.05f;
        }
         if(i==M_GREEN){
             cmin[i].x=-.43f;
             cmax[i].x=.43f;
             cmin[i].z=-.19f;
             cmax[i].z=.19f;
             
            
             
         }
        if(i==M_STUMPY){
             cmin[i].x=-.43f;
             cmax[i].x=.43f;
         }
        if(i==M_CHARGER){
            cmin[i].x=-.3f;
            cmax[i].x=.3f;
            
            cmin[i].z=-.3f;
            cmax[i].z=.3f;
           // cmax[i].z-=.4f;
        }
        if(i==M_STALKER){
            cmin[i].x=-.3f;
            cmax[i].x=.3f;
        }
        
        centers[i].x=(cmin[i].x+cmax[i].x)/2.0f;
        centers[i].y=(cmin[i].y+cmax[i].y)/2.0f;
        centers[i].z=(cmin[i].z+cmax[i].z)/2.0f;
        mradius[i]=0;
        mradius[i]=MAX(mradius[i],ABS(centers[i].x-cmin[i].x));
        mradius[i]=MAX(mradius[i],ABS(centers[i].y-cmin[i].y));
        mradius[i]=MAX(mradius[i],ABS(centers[i].z-cmin[i].z));
        mradius[i]=MAX(mradius[i],ABS(centers[i].x-cmax[i].x));
        mradius[i]=MAX(mradius[i],ABS(centers[i].y-cmax[i].y));
        mradius[i]=MAX(mradius[i],ABS(centers[i].z-cmax[i].z));
        mpolys[i]=makeBox(cmin[i].x,cmax[i].x,cmax[i].z,cmin[i].z,cmin[i].y,cmax[i].y);    
        
        
        
        dmin[i]=vpv(min[i])*scale;
        dmax[i]=vpv(max[i])*scale;
       
        if(dmin[i].x<dmin[i].z)dmin[i].z=dmin[i].x;
        else dmin[i].x=dmin[i].z;
        if(dmax[i].x<dmax[i].z)dmax[i].x=dmax[i].z;
        else dmax[i].z=dmax[i].x;
    }
    
    
 //   printg("succeeded load model!!\n");
 //  for(int i=0;i<nguys;i++){
      //  ResetModel(i);
  //     // guys[i].alive=FALSE;
//    }
       /* ResetModel(i);
        guys[i].targetangle=randf(3.14f*2);
        guys[i].pos=PVRTVec3(arc4random()%25+90,arc4random()%5+32,arc4random()%25+90);
        guys[i].model_type=arc4random()%(NUM_CREATURES);
        guys[i].state=0;   
        guys[i].idx=i;
        guys[i].color=0;
        guys[i].life=START_LIFE;
        guys[i].timer=1;
        guys[i].frame=getFrame(guys[i].model_type,guys[i].state,0);
    }*/
    
    firstLoad=FALSE;
    
	return true;
}


bool UnloadModels()
{
    //printg("models unloaded\n");
	if(CHECK_GL_ERROR()){
        
    }
    for(int i=0;i<NUM_CREATURES;i++){
        for(int j=0;j<models[i].nNumMesh;j++){
            glDeleteBuffers(1,&m_puiVbo[i][j]);     
            glDeleteBuffers(1,&m_puiIndexVbo[i][j]);    
        }
        
        delete[] (m_puiVbo[i]);
        delete[] (m_puiIndexVbo[i]);
        
    }
    for(int i=0;i<NUM_CREATURES;i++)
        models[i].Destroy();
    return true;
}
extern Vector fpoint;
extern int offsetdir;
void PlaceModel(int idx,Vector pos){
    if(idx==-2)
    {guys[nguys].model_type=-1;
        return;
        
    }
    if(idx!=-1){
        guys[nguys].model_type=-1;
        //guys[idx].touched=TRUE;
        idx=0;
        for(int i=0;i<nguys;i++){
            if(!guys[i].alive&&!guys[i].touched){
                idx=i;
                
                 guys[idx].touched=TRUE;
                printg("assigining new slot: %d\n",idx);
                
                break;
            }
        }
        for(int i=0;i<nguys;i++){
            if(!guys[i].alive){
                idx=i;
                
                guys[idx].touched=TRUE;
                printg("ran out of untouched slot spaces, assigining new slot: %d\n",idx);
                
                break;
            }
        }
       
    }else{
        idx=nguys;
    }
    ResetModel(idx);
    guys[idx].model_type=inventory.type;
    guys[idx].alive=TRUE;
    guys[idx].life=START_LIFE;
    guys[idx].touched=true;
    guys[idx].pos.x=wrapx(fpoint.x);
    guys[idx].pos.y=fpoint.y;//+centers[guys[idx].model_type].y;
    guys[idx].pos.z=wrapz(fpoint.z);
    guys[idx].angle=D2R([World getWorld].player->yaw+90);
    guys[idx].targetangle=guys[idx].angle;
    guys[idx].color=[World getWorld].hud->creature_color;
    if(idx!=nguys)
        Resources::getResources->playSound(S_BUILD_GENERIC);
    
    if(idx!=nguys){
    guys[idx].vel.y=3;
    [World getWorld].hud->blocktype=TYPE_CLOUD;
    [World getWorld].hud->holding_creature=FALSE;
       
    }else{
        guys[idx].vel.y=0;
       
    }
    
   
    
    
}
#define SEARCH_SIZE 35
void BurnModel(int idx){
    guys[idx].touched=TRUE;
    Entity* e=&guys[idx];
    if(e->onfire)return;
    PVRTVec3 upos=unwrap(e->pos);
    e->fireidx=[World getWorld].effects->addFire(upos.x ,e->pos.z ,upos.y+centers[e->model_type].y ,1 ,e->life*2);
    e->onfire=TRUE;
    e->runaway= e->life*2;
    if(e->model_type==M_CHARGER||e->model_type==M_STALKER){
        e->justhit=true;
    }
   
   if(!e->inLiquid)
      PlaySound(e->idx,VO_ONFIRE);
    Vector vpos=MakeVector(e->pos.x,e->pos.y,e->pos.z);
    int x=vpos.x;
    int z=vpos.z;    
    int y=min[e->model_type].y*scale+vpos.y+.01;
    
   
   // BOOL foundWater=FALSE;
    e->gotoDest=0;
    for(int h=-1;h<=1;h++){
        for(int size=0;size<SEARCH_SIZE;size++){
            for(int xx=x-size;xx<=x+size;xx++){
                for(int zz=z-size;zz<=z+size;zz++){
                    
                    int type=getLandc(xx,zz,y+h);
                    if(type>=0&&(blockinfo[type]&IS_WATER)){
                      //  foundWater=TRUE;
                        e->dest=PVRTVec3(xx+.5f,y+h+.5f,zz+.5f);
                        e->gotoDest=1;
                       // printg("Found water\n");
                        return;
                    }//else 
                       // [World getWorld].terrain setColor:x,z,y+h)
                }
            }
        }
    }
//doneSearching:
    
    
   
}
void killCreature(int idx){
    guys[idx].alive=FALSE;
    Resources::getResources->playSound(S_CREATURE_VANISH);
    PVRTVec3 upos=unwrap(guys[idx].pos);
    [World getWorld].effects->addCreatureVanish(upos.x,upos.z,guys[idx].pos.y,guys[idx].color,guys[idx].model_type);
    
    
}
void HitModel(int idx,Vector hitpoint){
    if(idx>=0&&idx<nguys){
        guys[idx].touched=TRUE;
        Vector dir;
       // printg("hitpoint (%f,%f)\n",guys[idx].pos.x,hitpoint.x);
        dir.x=guys[idx].pos.x-wrapx(hitpoint.x);
        dir.z=guys[idx].pos.z-wrapz(hitpoint.z);
        dir.y=0;
        NormalizeVector(&dir);
        guys[idx].state=0;
        setState(idx,DEFAULT_DAMAGE);
        guys[idx].life--;
        guys[idx].justhit=TRUE;
        
        
        if(guys[idx].life<=0){        
            killCreature(idx);
            
            //printg("adding particle fx for creature: (%f,%f,%f)\n",guys[idx].pos.x,guys[idx].pos.y,guys[idx].pos.z);
            //[[World getWorld].effects addCreatureVanish:guys[idx].pos.x:guys[idx].pos.z:guys[idx].pos.y:guys[idx].color:guys[idx].model_type];
        }else
            PlaySound(idx,VO_HIT);
        float hit_force=6;
        guys[idx].vel.x=dir.x*hit_force;
        guys[idx].vel.z=dir.z*hit_force;
        guys[idx].vel.y=6;
        guys[idx].flash=1.0f;
    }
    else
        printg("bad creature idx for hitModel\n");
    
}
void ColorModel(int idx,int color){
    if(idx>=0&&idx<nguys){
        guys[idx].touched=TRUE;
        guys[idx].color=color;

       
    }
    else
        printg("bad creature idx for ColorModel\n");
    
}

void PickupModel(int idx){
    if(idx>=0&&idx<nguys){
        guys[idx].alive=FALSE;
        [World getWorld].hud->blocktype=TYPE_CLOUD;
        [World getWorld].hud->creature_color=guys[idx].color;
        [World getWorld].hud->holding_creature=idx+1;
        inventory.pos=MakeVector(guys[idx].pos.x,guys[idx].pos.y,guys[idx].pos.z);
        inventory.color=guys[idx].color;
        inventory.type=guys[idx].model_type;
          Resources::getResources->playSound(S_CREATURE_PICKEDUP);
    }
    else
        printg("bad creature idx for PickupModel\n");
    
}

static void CalcBox(
                              CPODData			&data,
                              const void			* const pInter,
                              const int			nNumVertex,int type)
{
    unsigned int	nSrcStride	= data.nStride;
    //unsigned int	nDestStride	= (unsigned int)PVRTModelPODDataStride(data);
    const char		*pSrc		= (char*)pInter + (size_t)data.pData;
    
    if(!nSrcStride)
        return;
    
  //  data.pData = 0;
   // SafeAlloc(data.pData, nDestStride * nNumVertex);
 //   data.nStride	= nDestStride;
    
    for(int i = 0; i < nNumVertex; ++i){
        float* p=(float*)(pSrc + i * nSrcStride);
        Vector pt=MakeVector(*p,*(p+1),*(p+2));
        if(pt.x<min[type].x)min[type].x=pt.x;
        if(pt.y<min[type].y)min[type].y=pt.y;
        if(pt.z<min[type].z)min[type].z=pt.z;
        if(pt.x>max[type].x)max[type].x=pt.x;
        if(pt.y>max[type].y)max[type].y=pt.y;
        if(pt.z>max[type].z)max[type].z=pt.z;
        
        //NSLog(@"x:%f, y:%f z:%f",pt.x,pt.y,pt.z);
    }
       // memcpy((char*)data.pData + i * nDestStride, pSrc + i * nSrcStride, nDestStride);
}

void LoadVbos(int idx)
{
	if(!m_puiVbo[idx])
		m_puiVbo[idx] = new GLuint[models[idx].nNumMesh];

	if(!m_puiIndexVbo[idx])
		m_puiIndexVbo[idx] = new GLuint[models[idx].nNumMesh];

	/*
		Load vertex data of all meshes in the scene into VBOs

		The meshes have been exported with the "Interleave Vectors" option,
		so all data is interleaved in the buffer at pMesh->pInterleaved.
		Interleaving data improves the memory access pattern and cache efficiency,
		thus it can be read faster by the hardware.
	*/
    //printg("model:%d n_mesh:%d\n",idx,models[idx].nNumMesh);
	glGenBuffers(models[idx].nNumMesh, m_puiVbo[idx]);
    max[idx]=MakeVector(-9999,-99999,-9999999);
    min[idx]=MakeVector(99999,99999,9999999);
	for(unsigned int i = 0; i <models[idx].nNumMesh; ++i)
	{
       // printg("numMesh:%d\n",i);
		// Load vertex data into buffer object
		SPODMesh& Mesh = models[idx].pMesh[i];
		unsigned int uiSize = Mesh.nNumVertex * Mesh.sVertex.nStride;

       
		CalcBox(Mesh.sVertex, Mesh.pInterleaved, Mesh.nNumVertex,idx);
        
		glBindBuffer(GL_ARRAY_BUFFER, m_puiVbo[idx][i]);
		glBufferData(GL_ARRAY_BUFFER, uiSize, Mesh.pInterleaved, GL_STATIC_DRAW);

		// Load index data into buffer object if available
		m_puiIndexVbo[idx][i] = 0;

		if(Mesh.sFaces.pData)
		{
			glGenBuffers(1, &m_puiIndexVbo[idx][i]);
			uiSize = PVRTModelPODCountIndices(Mesh) * sizeof(GLshort);
			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_puiIndexVbo[idx][i]);
			glBufferData(GL_ELEMENT_ARRAY_BUFFER, uiSize, Mesh.sFaces.pData, GL_STATIC_DRAW);
		}
	}
    //printg("min(%f,%f,%f)  max(%f,%f,%f)\n",min[idx].x,min[idx].y,min[idx].z,max[idx].x,max[idx].y,max[idx].z);
    if(idx==M_GREEN){
        min[idx].x-=117.5;
        max[idx].x-=117.5;
    }
    if(idx==M_CHARGER){
        min[idx].x+=48;
        max[idx].x+=48;
    }
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

void DrawBox(Polyhedra*p){
    GLfloat				verts[8*3];
    int v=0;
   // printg("----\n");
    for(int i=0;i<p->n_points;i++){
        verts[v]=p->points[i].x;
        verts[v+1]=p->points[i].y;
        verts[v+2]=p->points[i].z;
      //  printg("(%f,%f,%f)\n",p->points[i].x,p->points[i].y,p->points[i].z);
        v+=3;
        
    }
    
    
    
    
    
    glVertexPointer(3, GL_FLOAT, 0, verts);
    glDrawArrays(GL_LINE_LOOP, 0, 8);
    
}

void DrawBox(PVRTVec3 min,PVRTVec3 max){
   
        GLfloat				verts[] = {
            min.x,	min.y,min.z,
            min.x,	max.y,min.z,
            max.x,	max.y,min.z,
            max.x,	min.y,min.z,
            min.x,	min.y,min.z,
            
            min.x,	min.y,max.z,
            min.x,	max.y,max.z,
            max.x,	max.y,max.z,
            max.x,	min.y,max.z,
            min.x,	min.y,max.z,
          //  min.x,	min.y,min.z,
        };
              
        
      
        glVertexPointer(3, GL_FLOAT, 0, verts);
        
        glDrawArrays(GL_LINE_LOOP, 0, 10);
    GLfloat				verts2[] = {
       
        min.x,	max.y,min.z,
        min.x,	max.y,max.z,
        
        max.x,	max.y,min.z,
        max.x,	max.y,max.z,
        
        max.x,	min.y,min.z,
        max.x,	min.y,max.z,
       
        //  min.x,	min.y,min.z,
    };
     glVertexPointer(3, GL_FLOAT, 0, verts2);
      glDrawArrays(GL_LINES, 0, 6);
    
}
extern Vector colorTable[256];
static int max_render;
void DrawShadows(){
    
    glEnable(GL_BLEND);
   glDepthMask(GL_FALSE);
    //glDisable(GL_DEPTH_TEST);
    glBindTexture(GL_TEXTURE_2D, Resources::getResources->getTex(ICO_SHADOW).name);
    glColor4f(1,1,1,.4f);
    int shadows_drawn=0;
    for(int j=0;j<=max_render;j++){
       
        int i=renderlistc[j];
        if(j==max_render){
            if(guys[nguys].model_type!=-1){
                i=nguys;
                
            }else
            {
               // printg("continue1\n");
                continue;}
        }else{
            if(!guys[i].alive||!guys[i].update||!guys[i].insideView){
              //  printg("continue2\n");
                continue;}
       	}
        Vector vpos=MakeVector(guys[i].pos.x,guys[i].pos.y,guys[i].pos.z);
        //if(guys[i].model_type==M_GREEN)vpos.x-=.5f;
        float x=ABS(vpos.x-[World getWorld].fm->chunkOffsetX*CHUNK_SIZE);
        float z=ABS(vpos.z-[World getWorld].fm->chunkOffsetZ*CHUNK_SIZE);
        float y=(int)(min[guys[i].model_type].y*scale+vpos.y+.01)+.01f;
         Vector point;
        point.x=x;
        point.z=z;
        point.y=y;
        if((int)x<=0||(int)y<=0){
            
            continue;}
        if(y<=1)y=3;
        int type;
        int landx=vpos.x;
        int landz=vpos.z;
        if(blockinfo[getLandc(landx,landz,y)]&IS_LIQUID)type=-1;
        else
        for(int k=0;k<5;k++){
           type=getLandc(landx,landz,y-1-k);
            if(type<=0||blockinfo[type]&IS_RAMP){
                
                point.y--;
                continue;
            }
            if(blockinfo[type]&IS_LIQUID){
                type=-1;
                break;
            }
            
        }
        if(type==-1){
           
            continue;};
        float dist=(min[guys[i].model_type].y*scale+vpos.y)-point.y;
        if(dist>4){
            
            continue;}
        dist=(4-dist)/4.0f;
        
        GLfloat				coordinates[] = {
            0,				1,
           
            0,				0,
             1,			1,
            1,			0
        };
        //printg("(%f,%f,%f)",point.x,point.y,point.z);
        GLfloat				width = dist*shadow_size[guys[i].model_type],
        height = dist*shadow_size[guys[i].model_type];
        GLfloat				vertices[] = {
            -width / 2 + point.x,	point.y,	-height / 2 + point.z,		
           	
            -width / 2 + point.x,	point.y,	height / 2 + point.z,	
             width / 2 + point.x,	point.y,	-height / 2 + point.z,	
            width / 2 + point.x,	point.y,	height / 2 + point.z,		
        };
        
                glVertexPointer(3, GL_FLOAT, 0, vertices);
        glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        shadows_drawn++;
        //DrawBox(vpv(point)-PVRTVec3(.1f,.1f,.1f),
         //       vpv(point)+PVRTVec3(.1f,.1f,.1f));
        
    }
   // printg("shadows drawn: %d\n",shadows_drawn);
      //glEnable(GL_DEPTH_TEST);
    glDepthMask(GL_TRUE);
    glDisable(GL_BLEND);

    
      //  guys[nguys].model_type=-1;
        
}
int compare_creatures (const void *a, const void *b)
{
    
    int first=*((int*)(a));
    int second=*((int*)(b));
    
    Vector player_pos=[World getWorld].player->pos;
 
    
    Vector cam=player_pos;
    Vector center=MakeVector(guys[first].pos.x,guys[first].pos.y,guys[first].pos.z);
    
    float dist=(cam.x-center.x)*(cam.x-center.x)+
    (cam.y-center.y)*(cam.y-center.y)+
    (cam.z-center.z)*(cam.z-center.z);
    
    center=MakeVector(guys[second].pos.x,guys[second].pos.y,guys[second].pos.z);
    
    dist-=((cam.x-center.x)*(cam.x-center.x)+
           (cam.y-center.y)*(cam.y-center.y)+
           (cam.z-center.z)*(cam.z-center.z));
    
    if (dist > 0)
        return 1;
    else if (dist < 0)
        return -1;
    else
        return 0;
}

int compare_creatures2 (const void *a, const void *b)
{
    
    int first=((Entity*)(a))->idx;
    int second=((Entity*)(b))->idx;
    
    Vector player_pos=[World getWorld].player->pos;
    player_pos.x=wrapx(player_pos.x);
    player_pos.z=wrapz(player_pos.z);
    Vector cam=player_pos;
    if(first<0||first>nguys||!guys[first].alive){
        if(second<0||second>nguys||!guys[second].alive)return 0;
        else 
            return 1;
    }
    if(second<0||second>nguys||!guys[second].alive)return -1;
    Vector center=MakeVector(guys[first].pos.x,guys[first].pos.y,guys[first].pos.z);
    
    float dist=(cam.x-center.x)*(cam.x-center.x)+
    (cam.y-center.y)*(cam.y-center.y)+
    (cam.z-center.z)*(cam.z-center.z);
    
    center=MakeVector(guys[second].pos.x,guys[second].pos.y,guys[second].pos.z);
    
    dist-=((cam.x-center.x)*(cam.x-center.x)+
           (cam.y-center.y)*(cam.y-center.y)+
           (cam.z-center.z)*(cam.z-center.z));
   
    
    if (dist > 0)
        return 1;
    else if (dist < 0)
        return -1;
    else
        return 0;
}

bool RenderModels()
{

    //printg("renderModels\n");
	
		
    
	// Clear the depth and frame buffer
	//glClearColor(0.6f, 0.8f, 1.0f, 1.0f);
	//glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	// Set Z compare properties
	glEnable(GL_DEPTH_TEST);
     glEnable(GL_FOG);
	// Disable Blending
	//glDisable(GL_BLEND);

	// Calculate the model view matrix
	glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glScalef(scale,scale,scale);
    glEnable(GL_LIGHTING);
    glEnable(GL_NORMALIZE);
    glShadeModel(GL_SMOOTH);
    PVRTVec4 lightPosition = PVRTVec4(0.0f,0.0f, 0.0f, 1.0f);
    PVRTVec4 lightAmbient  = PVRTVec4(0.3f, 0.3f, 0.3f, 1.0f);
    PVRTVec4 lightDiffuse  = PVRTVec4(0.7f, 0.7f, 0.7f, 1.0f);
    if(!LOW_MEM_DEVICE&&v_equals([World getWorld].terrain->final_skycolor,colorTable[54])){
       lightAmbient  = PVRTVec4(0.2f, 0.2f, 0.2f, 1.0f);
       lightDiffuse  = PVRTVec4(0.35f, 0.35f, 0.35f, 1.0f);
    }
    //PVRTVec4 lightSpecular = PVRTVec4(0.2f, 0.2f, 0.2f, 1.0f);
    
    glEnable(GL_LIGHT0);
    glPushMatrix();
    glLoadIdentity();
    glLightfv(GL_LIGHT0, GL_POSITION, lightPosition.ptr());
    glPopMatrix();
    glLightfv(GL_LIGHT0, GL_AMBIENT,  lightAmbient.ptr());
    glLightfv(GL_LIGHT0, GL_DIFFUSE,  lightDiffuse.ptr());
  //  glLightfv(GL_LIGHT0, GL_SPECULAR, lightSpecular.ptr());
    
    GLfloat modelviewf[16];
	glGetFloatv( GL_MODELVIEW_MATRIX, modelviewf );
	// Set up the projection matrix
	m_mView = PVRTMat4(modelviewf);
	
    //glLoadMatrixf(m_mView.f);
    
	
	// Draw the model
    glEnableClientState(GL_NORMAL_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    float bounds[6];
    int renderidx=0;
    model_render_count=0;
    int debug_count1=0;
    
    for(int i=0;i<nguys;i++){
        if(!guys[i].alive)continue;
        if(!guys[i].update){
          //  printg("model alive but not updating[%d]: (%f,%f,%f)\n",i,guys[i].pos.x,guys[i].pos.y,guys[i].pos.z);
            continue;
        }else{
            debug_count1++;
        }
       
       // while(guys[i].frame > models[guys[i].model_type].nNumFrame-1)
       //    guys[i].frame -= models[guys[i].model_type].nNumFrame-1;
        Vector AA=min[guys[i].model_type];
        Vector BB=max[guys[i].model_type];
        bounds[0]=guys[i].pos.x+AA.x*scale;
        bounds[1]=guys[i].pos.y+AA.y*scale;
        bounds[2]=guys[i].pos.z+AA.z*scale;
        bounds[3]=guys[i].pos.x+BB.x*scale;
        bounds[4]=guys[i].pos.y+BB.y*scale;
        bounds[5]=guys[i].pos.z+BB.z*scale;
        
        int vtr=(ViewTestAABB(bounds,0));
        //printg("vtr:  %#010x\n", vtr);
        if(!(vtr&VT_OUTSIDE)){
            guys[i].insideView=TRUE;
            renderlistc[renderidx++]=i;
             model_render_count++;
            
            //printg("model in view[%d]: (%f,%f,%f)\n",i,guys[i].pos.x,guys[i].pos.y,guys[i].pos.z);
           
        }else{
             guys[i].insideView=FALSE;
            //renderlistc[renderidx++]=i;
            //printg("model out of view(but active/alive)[%d]: (%f,%f,%f)\n",i,guys[i].pos.x,guys[i].pos.y,guys[i].pos.z);
        }
        
       
    }
  // printg("models alive and being updated: %d   inside view: %d\n",debug_count1,model_render_count);
     qsort (renderlistc, renderidx, sizeof (int), compare_creatures);
    max_render=renderidx;
    int mmax=50;//30;
     if(LOW_MEM_DEVICE){
         mmax=10;
    }
    extern bool SUPPORTS_OGL2;
    if(!SUPPORTS_OGL2)mmax=10;
    if(max_render>mmax)max_render=mmax;
    int models_drawn=0;
    for(int j=0;j<max_render;j++){
          
        int i=renderlistc[j];
        
        guys[i].pos.x-=[World getWorld].fm->chunkOffsetX*CHUNK_SIZE;
        guys[i].pos.z-=[World getWorld].fm->chunkOffsetZ*CHUNK_SIZE;
        
     //   printg("rendering model: (%f,%f,%f)\n",guys[i].pos.x,guys[i].pos.y,guys[i].pos.z);
        if(guys[i].color==0||guys[i].ragetimer>0){
            if(guys[i].flash!=0){
                glColor4f(1,1-guys[i].flash,1-guys[i].flash,1);
                DrawModel(i);
                glColor4f(1,1,1,1);
            }else{
                if(guys[i].onfire){
                    glColor4f(.5f,.5f,.5f,1);
                    DrawModel(i);
                    glColor4f(1,1,1,1);
                }else
                    DrawModel(i); 
            }
        }else{
            Vector clr;
            if(guys[i].color<256&&guys[i].color>0)
            clr= colorTable[guys[i].color];
            clr=MakeVector(1.0f,1.0f,1.0f);
            if(guys[i].flash!=0){
                clr.y-=guys[i].flash;
                clr.z-=guys[i].flash;
                if(clr.y-guys[i].flash<0)clr.y=0;
                if(clr.z-guys[i].flash<0)clr.z=0;
                glColor4f(clr.x,clr.y,clr.z,1);
                
                
            }else {
                if(guys[i].onfire){
                    glColor4f(clr.x/2.0f,clr.y/2.0f,clr.z/2.0f,1);
                    
                }else
                   
                glColor4f(clr.x,clr.y,clr.z,1);
                
            }
            
            
            DrawModel(i);
            models_drawn++;
            glColor4f(1,1,1,1);
        }
        
        guys[i].pos.x+=[World getWorld].fm->chunkOffsetX*CHUNK_SIZE;
        guys[i].pos.z+=[World getWorld].fm->chunkOffsetZ*CHUNK_SIZE;
    
    }
    
   // printg("models drawn: %d\n",models_drawn);
    if(guys[nguys].model_type!=-1){
        glEnable(GL_BLEND);
        //if(guys[nguys].color==0)
            glColor4f(1.0f,1.0f,1.0f,.5f);
        guys[nguys].pos.z-=[World getWorld].fm->chunkOffsetZ*CHUNK_SIZE;
        guys[nguys].pos.x-=[World getWorld].fm->chunkOffsetX*CHUNK_SIZE;
        DrawModel(nguys);
       guys[nguys].pos.z+=[World getWorld].fm->chunkOffsetZ*CHUNK_SIZE;
        guys[nguys].pos.x+=[World getWorld].fm->chunkOffsetX*CHUNK_SIZE;
        glDisable(GL_BLEND);
    }
	glDisableClientState(GL_NORMAL_ARRAY);
    glDisable(GL_LIGHTING);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    
    
    glBindTexture(GL_TEXTURE_2D, 0);
    glColor4f(1,0,0,1);
    glDisable(GL_TEXTURE_2D);
    glScalef(1/scale,1/scale,1/scale);
    
    
    glLineWidth(1.0f);
    glDisable(GL_DEPTH_TEST);
    /*Vector AA=min[M_CHARGER];
    Vector BB=max[M_CHARGER];
    Vector avg=v_add(AA,BB);
    avg=v_mult(avg,.5f);*/
   // printg("center: %f,%f,%f\n",avg.x,avg.y,avg.z);
    //outputs; center: -48.000000,13.084567,5.033846
    bool DRAW_BOUNDING_BOXES=FALSE;
    if(DRAW_BOUNDING_BOXES)
    for(int i=0;i<nguys;i++){
        if(!guys[i].alive)continue;
      
        
        
        guys[i].pos.x-=[World getWorld].fm->chunkOffsetX*CHUNK_SIZE;
        guys[i].pos.z-=[World getWorld].fm->chunkOffsetZ*CHUNK_SIZE;
      //  Vector vpos=MakeVector(guys[i].pos.x*1/scale,guys[i].pos.y*1/scale,guys[i].pos.z*1/scale);
        
       // DrawBox(v_add(min[guys[i].model_type],vpos),v_add(max[guys[i].model_type],vpos));
        if(guys[i].insideView)
        glColor4f(1,1,1,1);
        else{
            glColor4f(1,0,0,1);
        }
        
        Vector AA=min[guys[i].model_type];
        Vector BB=max[guys[i].model_type];
       
        AA.x=guys[i].pos.x+AA.x*scale;
        AA.y=guys[i].pos.y+AA.y*scale;
        AA.z=guys[i].pos.z+AA.z*scale;
         BB.x=guys[i].pos.x+BB.x*scale;
       BB.y=guys[i].pos.y+BB.y*scale;
        BB.z=guys[i].pos.z+BB.z*scale;
        DrawBox(AA,
               BB);
        
        
        //DrawBox(centers[guys[i].model_type]+guys[i].pos-mradius[guys[i].model_type],
         //       centers[guys[i].model_type]+guys[i].pos+mradius[guys[i].model_type]);
        glColor4f(0,1,1,1);
        DrawBox(centers[guys[i].model_type]+guys[i].pos-PVRTVec3(.1f,.1f,.1f),
                centers[guys[i].model_type]+guys[i].pos+PVRTVec3(.1f,.1f,.1f));
        
        glColor4f(0,1,0,1);
        DrawBox(guys[i].pos-PVRTVec3(.1f,.1f,.1f),
                guys[i].pos+PVRTVec3(.1f,.1f,.1f));
        glColor4f(1,0,0,1);
        
      
        
        guys[i].pos.x+=[World getWorld].fm->chunkOffsetX*CHUNK_SIZE;
        guys[i].pos.z+=[World getWorld].fm->chunkOffsetZ*CHUNK_SIZE;
        //DrawBox(&guys[i].box);
        
    }
     glEnable(GL_DEPTH_TEST);
    
    
    glEnable(GL_TEXTURE_2D);
    
    
	glDisable(GL_FOG);
    
	
	
    glPopMatrix();
    glShadeModel(GL_FLAT);
    glDisable(GL_NORMALIZE);
    DrawShadows();
    glEnableClientState(GL_COLOR_ARRAY);
   // static int mcc=0;
   // mcc++;
  //  if(mcc%60==0)
   // printg("Models updated:%d   models rendered:%d\n",model_update_count,model_render_count);
		return true;
}

/*******************************************************************************
 * Function Name  : DrawModel
 * Description    : Draws the model
 *******************************************************************************/
void DrawModel(int mi)
{
    float frame=guys[mi].frame;
    float angle=guys[mi].angle;
    PVRTVec3 position=guys[mi].pos;
   // if(guys[mi].model_type==M_GREEN){
   //     position.x+=.35f;
   // }
   // position.x-=16;
   // position.z-=16;
    //position.y-=64;
    int modelType=guys[mi].model_type;
    if(modelType==-1){
        printg("error drawing -1 model\n");
        return;
    }
	//Set the frame number
    if(modelType==M_BATTY){
    m_mTransform = PVRTMat4::Translation(position.x*1/scale,(position.y+.2f)*1/scale, position.z*1/scale) * PVRTMat4::RotationY(angle);
    }else{
       m_mTransform = PVRTMat4::Translation(position.x*1/scale,position.y*1/scale, position.z*1/scale) * PVRTMat4::RotationY(angle); 
    }
	models[modelType].SetFrame(frame);

	int tex=-1;
    if(guys[mi].ragetimer<=0&&guys[mi].color!=0&&modelType!=M_CHARGER&&modelType!=M_STALKER){
        if(guys[mi].blinktimer>0){
               tex=Resources::getResources->getSkin(modelType,guys[mi].color,1);
            
            
        }else{
             tex=Resources::getResources->getSkin(modelType,guys[mi].color,0);
        }
    }else
    if(modelType==M_MOOF){
        if(guys[mi].ragetimer>0)
            glBindTexture(GL_TEXTURE_2D, Resources::getResources->getTex(SKIN_MOOFRAGE).name);
        else if(guys[mi].blinktimer>0){
            if(guys[mi].color==0)
                tex=Resources::getResources->getTex(SKIN_MOOFBLINK).name;
            else{
               tex=Resources::getResources->getSkin(M_MOOF,guys[mi].color,1);
               
                
            }
                     
        }else{
            if(guys[mi].color==0)
            glBindTexture(GL_TEXTURE_2D, Resources::getResources->getTex(SKIN_MOOF).name);
            else{
                tex=Resources::getResources->getSkin(M_MOOF,guys[mi].color,0);
               
             
            }
            
        }
    }else if(modelType==M_BATTY){
        if(guys[mi].ragetimer>0)
            glBindTexture(GL_TEXTURE_2D, Resources::getResources->getTex(SKIN_BATTYRAGE).name);
        else if(guys[mi].blinktimer>0)
            glBindTexture(GL_TEXTURE_2D, Resources::getResources->getTex(SKIN_BATTYBLINK).name);
        else
            glBindTexture(GL_TEXTURE_2D, Resources::getResources->getTex(SKIN_BATTY).name);
    }else if(modelType==M_GREEN){
        if(guys[mi].ragetimer>0)
            glBindTexture(GL_TEXTURE_2D, Resources::getResources->getTex(SKIN_GREENRAGE).name);
        else if(guys[mi].blinktimer>0)
            glBindTexture(GL_TEXTURE_2D, Resources::getResources->getTex(SKIN_GREENBLINK).name);
        else
            glBindTexture(GL_TEXTURE_2D, Resources::getResources->getTex(SKIN_GREEN).name);
        
    }else if(modelType==M_NERGLE){
        if(guys[mi].ragetimer>0)
            glBindTexture(GL_TEXTURE_2D, Resources::getResources->getTex(SKIN_NERGLERAGE).name);
        else if(guys[mi].blinktimer>0)
            glBindTexture(GL_TEXTURE_2D, Resources::getResources->getTex(SKIN_NERGLEBLINK).name);
        else
            glBindTexture(GL_TEXTURE_2D, Resources::getResources->getTex(SKIN_NERGLE).name);
    }else if(modelType==M_STUMPY){
        if(guys[mi].ragetimer>0)
            glBindTexture(GL_TEXTURE_2D, Resources::getResources->getTex(SKIN_STUMPYRAGE).name);
        else if(guys[mi].blinktimer>0)
            glBindTexture(GL_TEXTURE_2D, Resources::getResources->getTex(SKIN_STUMPYBLINK).name);
        else
            glBindTexture(GL_TEXTURE_2D, Resources::getResources->getTex(SKIN_STUMPY).name);
    }else if(modelType==M_CHARGER){
        if(guys[mi].ragetimer>0)
            glBindTexture(GL_TEXTURE_2D, Resources::getResources->getTex(SKIN_CHARGERRAGE).name);
        else if(guys[mi].blinktimer>0)
            glBindTexture(GL_TEXTURE_2D, Resources::getResources->getTex(SKIN_CHARGERBLINK).name);
        else
            glBindTexture(GL_TEXTURE_2D, Resources::getResources->getTex(SKIN_CHARGER).name);
    }else if(modelType==M_STALKER){
        if(guys[mi].ragetimer>0)
            glBindTexture(GL_TEXTURE_2D, Resources::getResources->getTex(SKIN_STALKERRAGE).name);
        else if(guys[mi].blinktimer>0)
            glBindTexture(GL_TEXTURE_2D, Resources::getResources->getTex(SKIN_STALKERBLINK).name);
        else
            glBindTexture(GL_TEXTURE_2D, Resources::getResources->getTex(SKIN_STALKER).name);
    }
    if(tex!=-1)
     glBindTexture(GL_TEXTURE_2D, tex);

	//Iterate through all the mesh nodes in the scene
	for(int iNode = 0; iNode < (int)models[modelType].nNumMeshNode; ++iNode)
	{
		//Get the mesh node.
		SPODNode* pNode = &models[modelType].pNode[iNode];
       
		//Get the mesh that the mesh node uses.
		SPODMesh* pMesh = &models[modelType].pMesh[pNode->nIdx];

		// bind the VBO for the mesh
		glBindBuffer(GL_ARRAY_BUFFER, m_puiVbo[modelType][pNode->nIdx]);

		// bind the index buffer, won't hurt if the handle is 0
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_puiIndexVbo[modelType][pNode->nIdx]);

		// Loads the correct texture using our texture lookup table
		
       
        
		
			glEnableClientState(GL_MATRIX_INDEX_ARRAY_OES);
			glEnableClientState(GL_WEIGHT_ARRAY_OES);
       
		
 
		// Set Data Pointers
		// Used to display non interleaved geometry
        if(pMesh->sVertex.n==0||pMesh->psUVW[0].n==0)continue;
		glVertexPointer(pMesh->sVertex.n, GL_FLOAT, pMesh->sVertex.nStride, pMesh->sVertex.pData);
		glNormalPointer(GL_FLOAT, pMesh->sNormals.nStride, pMesh->sNormals.pData);
		glTexCoordPointer(pMesh->psUVW[0].n, GL_FLOAT, pMesh->psUVW[0].nStride, pMesh->psUVW[0].pData);

	// printg("model:%d, %d\n",modelType,iNode);
			//Set up the indexes into the matrix palette.
        if(pMesh->sBoneIdx.pData!=NULL)
			m_Extensions.glMatrixIndexPointerOES(pMesh->sBoneIdx.n, GL_UNSIGNED_BYTE, pMesh->sBoneIdx.nStride, pMesh->sBoneIdx.pData);
         if(pMesh->sBoneWeight.pData!=NULL)
			m_Extensions.glWeightPointerOES(pMesh->sBoneWeight.n, GL_FLOAT, pMesh->sBoneWeight.nStride, pMesh->sBoneWeight.pData);
		

		// Draw

		
        
		for(int i32Batch = 0; i32Batch < pMesh->sBoneBatches.nBatchCnt; ++i32Batch)
		{ 
			// If the mesh is used for skining then set up the matrix palettes.
			
            //Enable the matrix palette extension
            glEnable(GL_MATRIX_PALETTE_OES);
            /*
             Enables the matrix palette stack extension, and apply subsequent
             matrix operations to the matrix palette stack.
             */
            glMatrixMode(GL_MATRIX_PALETTE_OES);
            
            PVRTMat4	mBoneWorld;
            int			i32NodeID;
            
            //	Iterate through all the bones in the batch
            for(int j = 0; j < pMesh->sBoneBatches.pnBatchBoneCnt[i32Batch]; ++j)
            {
                /*
                 Set the current matrix palette that we wish to change. An error
                 will be returned if the index (j) is not between 0 and
                 GL_MAX_PALETTE_MATRICES_OES. The value of GL_MAX_PALETTE_MATRICES_OES
                 can be retrieved using glGetIntegerv, the initial value is 9.
                 
                 GL_MAX_PALETTE_MATRICES_OES does not mean you need to limit
                 your character to 9 bones as you can overcome this limitation
                 by using bone batching which splits the mesh up into sub-meshes
                 which use only a subset of the bones.
                 */
                
                m_Extensions.glCurrentPaletteMatrixOES(j);
                
                // Generates the world matrix for the given bone in this batch.
                i32NodeID = pMesh->sBoneBatches.pnBatches[i32Batch * pMesh->sBoneBatches.nBatchBoneMax + j];
                models[modelType].GetBoneWorldMatrix(mBoneWorld, *pNode, models[modelType].pNode[i32NodeID]);
                
                // Multiply the bone's world matrix by our transformation matrix and the view matrix
                mBoneWorld = m_mView * m_mTransform * mBoneWorld;
                
                // Load the bone matrix into the current palette matrix.
                glLoadMatrixf(mBoneWorld.f);
                
            }
			

			//Switch to the modelview matrix.
			glMatrixMode(GL_MODELVIEW);
           
			// Calculate the number of triangles in the current batch
			int i32Tris;

			if(i32Batch + 1 < pMesh->sBoneBatches.nBatchCnt)
				i32Tris = pMesh->sBoneBatches.pnBatchOffset[i32Batch+1] - pMesh->sBoneBatches.pnBatchOffset[i32Batch];
			else
				i32Tris = pMesh->nNumFaces - pMesh->sBoneBatches.pnBatchOffset[i32Batch];

			// Indexed Triangle list
			if(pMesh->nNumStrips == 0)
			{
                
               
				glDrawElements(GL_TRIANGLES, i32Tris * 3, GL_UNSIGNED_SHORT, &((unsigned short*)0)[3 * pMesh->sBoneBatches.pnBatchOffset[i32Batch]]);
			}
			
		}

		
        glDisableClientState(GL_MATRIX_INDEX_ARRAY_OES);
        glDisableClientState(GL_WEIGHT_ARRAY_OES);
        
        // We are finished with the matrix pallete so disable it.
        glDisable(GL_MATRIX_PALETTE_OES);
		
		
	}


	
}






