#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/gl.h>

//CONSTANTS:

typedef enum {
	kTexture2DPixelFormat_Automatic = 0,
	kTexture2DPixelFormat_RGBA8888,
	kTexture2DPixelFormat_RGBA4444,
	kTexture2DPixelFormat_RGBA5551,
	kTexture2DPixelFormat_RGB565,
	kTexture2DPixelFormat_RGB888,
	kTexture2DPixelFormat_L8,
	kTexture2DPixelFormat_A8,
	kTexture2DPixelFormat_LA88,
	kTexture2DPixelFormat_RGB_PVRTC2,
	kTexture2DPixelFormat_RGB_PVRTC4,
	kTexture2DPixelFormat_RGBA_PVRTC2,
	kTexture2DPixelFormat_RGBA_PVRTC4
} Texture2DPixelFormat;

typedef struct _Button {
    CGPoint origin;
    CGSize size;
    BOOL pressed=FALSE;
}Button;
//CLASS INTERFACES:

/*
This class allows to easily create OpenGL 2D textures from images, text or raw data.
The created Texture2D object will always have power-of-two dimensions.
Depending on how you create the Texture2D object, the actual image area of the texture might be smaller than the texture dimensions i.e. "contentSize" != (pixelsWide, pixelsHigh) and (maxS, maxT) != (1.0, 1.0).
Be aware that the content of the generated textures will be upside-down!
*/
class Texture2D {

private:
	
	CGSize						_size;
	NSUInteger					_width,
								_height;
	Texture2DPixelFormat		_format;
	GLfloat						_maxS,
								_maxT;

    void initData(const void* data, Texture2DPixelFormat pixelFormat, int width,int height,CGSize size,BOOL genMips);
    void initFromPath(NSString* path, BOOL sizeToFit, Texture2DPixelFormat pixelFormat, BOOL genMips);
    void initFromImage(CGImageRef image,UIImageOrientation orientation, BOOL sizeToFit,Texture2DPixelFormat pixelFormat, BOOL genMips);
    void initFromString(NSString* string, CGSize dimensions, UITextAlignment alignment, UIFont* font);
public:
GLuint						name;
Texture2D(const void* data ,Texture2DPixelFormat pixelFormat, int width, int height, CGSize size);
~Texture2D();
Texture2D(const void* data ,Texture2DPixelFormat pixelFormat, int width, int height, CGSize size,BOOL genMips);
/*@property(readonly) Texture2DPixelFormat pixelFormat;
@property(readonly) NSUInteger pixelsWide;
@property(readonly) NSUInteger pixelsHigh;

@property(readonly) GLuint name;

@property(readonly, nonatomic) CGSize contentSize;
@property(readonly) GLfloat maxS;
@property(readonly) GLfloat maxT;*/


/*
Drawing extensions to make it easy to draw basic quads using a Texture2D object.
These functions require GL_TEXTURE_2D and both GL_VERTEX_ARRAY and GL_TEXTURE_COORD_ARRAY client states to be enabled.
*/

    void preload();
    void drawAtPoint(CGPoint point);
    void drawAtPoint(CGPoint point,CGFloat depth,BOOL center);
    void drawInRect(CGRect rect);
    void drawInRect2(CGRect rect);
    void drawText(CGRect rect);
    void drawNumbers(CGRect rect, int num);
    void drawButton(Button button);
    void drawButton2(Button button);
    void drawTextHalfsies(CGRect rect);
    void drawTextNoScale(CGRect rect);
    void drawTextM(CGRect rect);
    void drawInRect(CGRect rect, CGFloat depth);
    void drawSky(CGRect rect, CGFloat depth);


/*
Extensions to make it easy to create a Texture2D object from an image file.
Note that RGBA type textures will have their alpha premultiplied - use the blending mode (GL_ONE, GL_ONE_MINUS_SRC_ALPHA).
*/
Texture2D(NSString* path ,BOOL sizeToFit, UIImageOrientation orientation, Texture2DPixelFormat pixelFormat,BOOL genMips);
Texture2D(NSString* path ,BOOL sizeToFit, Texture2DPixelFormat pixelFormat,BOOL genMips);
Texture2D(NSString* path ,BOOL sizeToFit, BOOL genMips);
Texture2D(NSString* path ,BOOL sizeToFit);
Texture2D(NSString* path);
    Texture2D(CGImageRef image, UIImageOrientation orientation, BOOL sizeToFit,Texture2DPixelFormat pixelFormat,BOOL genMips);
    //If the path is not absolute, it is assumed to be relative to the main bundle's resources
    //For non-power-of-two images, if "sizeToFit" is YES, the image is scaled to power-of-two dimensions, otherwise extra margins are added

    
   // Texture2D(NSString* string, CGSize dimension, UITextAlignment alignment, NSString* name,CGFloat size);
    Texture2D(NSString* string, CGSize dimension, UITextAlignment alignment, UIFont* font);
/*
Extensions to make it easy to create a Texture2D object from a string of text.
Note that the generated textures are of type A8 - use the blending mode (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA).
*/
    static void drawTexture(Texture2D* texture, CGPoint point, CGFloat depth);
    

    NSString* description();
};

CGImageRef ManipulateImagePixelData(CGImageRef inImage,CGImageRef inMask,int color);
CGImageRef ManipulateImagePixelData2(CGImageRef inImage,int tint,int mode);
