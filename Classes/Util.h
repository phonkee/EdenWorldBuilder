//
//  Util.h
//  prototype
//
//  Created by Ari Ronen on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <UIKit/UIKit.h>
#import "Texture2D.h"
#import "Vector.h"
@interface Util : NSObject {

}

@end
typedef struct _worldnode{
	NSString* display_name;
	NSString* file_name;
	Button rect;
	Button anim;
    
	Texture2D* tex;
	struct _worldnode* next;
	struct _worldnode* prev;
}WorldNode;
typedef struct lnode{
	struct lnode* next;
	void* data;
	BOOL dead;
}ListNode;
typedef struct tnode{
	ListNode* dataList;
	int bounds[6];
	float rbounds[6];
	struct tnode* parent;
	BOOL hasChildren;
	struct tnode* children[8];
}TreeNode;
enum FC_MODES {
	FC_PLACE=1,
	FC_DESTROY=2
};
BOOL GenerateInverseMatrix4f(float i[16], const float m[16]);

typedef struct{
	int x;
	int y;
	int z;	
}Point3D;

float v_length2(Vector v);
typedef struct _face{
    Vector points[4];
    bool sharedface;
    int n_points;
    Vector normal;
}Face;



typedef struct _polyhedra{
    Face faces[6];
    Vector points[8];
    int n_faces;
    int n_points;
}Polyhedra;

int sign(float f);
float dotProduct(Vector A,Vector B);
Vector crossProduct(Vector v1, Vector v2);
Vector v_mult(Vector v,float scalar);
Vector v_add(Vector v,Vector v2);
Vector v_sub(Vector v,Vector v2);
Vector v_div(Vector v,float scalar);
bool v_equals(Vector vec,Vector v2);
float rsqrt( float number );

Vector MakeVector(float x,float y,float z);
Polyhedra makeBox(float left,float right,float back,float front,float bot,float top);
BOOL TestPoint(Polyhedra* A,float x,float y,float z);
Point3D findWorldCoords(int mx,int my,int mode);
Polyhedra makeRamp(float left,float right,float back,float front,float bot,float top,int type);
Polyhedra makeSide(float left,float right,float back,float front,float bot,float top,int type);
BOOL collidePolyhedra(Polyhedra A,Polyhedra B);
Vector calcCenter(Vector* points,int  n_points);
BOOL AxisSeparatePolygons(Vector Axis, Vector* A,int a_length, Vector* B,int b_length);
CGPoint CalculateInterval(Vector Axis, Vector* P,int p_length);

void MatrixMultiplyBy4x (float* src1, float* src2, float* dest);
void VectorMatrixMultiply(Vector* vDest, Vector vSrc,const float mat[16]);
void NormalizeVector(Vector* v);
float absf(float f);
BOOL inbox(float x,float y,CGRect rect);
BOOL inbox2(float x,float y,Button* rect);
BOOL inbox3(float x,float y,Button* rect);
Button ButtonMake(float x,float y,float width,float height);
CGRect RectFromButton(Button b);
Button ButtonFromRect(CGRect b);

int threeToOne(int cx,int cy,int cz);
int getColIndex(int cx,int cz);
int twoToOne(int cx,int cz);
float randf(float max);
NSString* genhash();
void takeScreenshot();
void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v );
void HSVtoRGB( float *r, float *g, float *b, float h, float s, float v );