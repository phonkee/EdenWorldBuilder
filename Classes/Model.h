#import "Util.h"




bool LoadModels(const char* pszReadPath);
bool UnloadModels();
bool RenderModels();
void UpdateModels(float etime);
int PointTestModels(float x,float y,float z);
void PickupModel(int idx);

void PlaceModel(int idx,Vector pos);
void ColorModel(int idx,int color);
void HitModel(int idx,Vector hitpoint);
void BurnModel(int idx);
void ExplodeModels(Vector pos,int color);
void SaveModels();
void LoadModels2();
void addMoreCreaturesIfNeeded();
void setViewNow();
void killCreature(int idx);
float wrapx(float x);
float wrapz(float z);

void CalcEnvMap(vertexObject* vert);