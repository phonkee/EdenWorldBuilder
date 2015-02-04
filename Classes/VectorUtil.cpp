
extern "C" {
#include "VectorUtil.h"
}
#include "PVRTVector.h"

Vector rotateVertice(Vector rot,Vector v){
    Vector r;
    PVRTVec4 pt=PVRTVec4(v.x,v.y,v.z,1);
    PVRTMat4 mat4=PVRTMat4::RotationX(rot.x)*PVRTMat4::RotationY(rot.y)*PVRTMat4::RotationZ(rot.z);
    //for(int j=0;j<16;j++){
    ///printg("%f ",mat4.f[j]);
    // }
    //printg("---\n");
    pt=mat4*pt;
    r.x=pt.x;
    r.y=pt.y;
    r.z=pt.z;
    return r;
    
}
