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
    BOOL pressed;
}Button;
//CLASS INTERFACES:

/*
This class allows to easily create OpenGL 2D textures from images, text or raw data.
The created Texture2D object will always have power-of-two dimensions.
Depending on how you create the Texture2D object, the actual image area of the texture might be smaller than the texture dimensions i.e. "contentSize" != (pixelsWide, pixelsHigh) and (maxS, maxT) != (1.0, 1.0).
Be aware that the content of the generated textures will be upside-down!
*/
@interface Texture2D : NSObject
{
@private
	GLuint						_name;
	CGSize						_size;
	NSUInteger					_width,
								_height;
	Texture2DPixelFormat		_format;
	GLfloat						_maxS,
								_maxT;
}
- (id) initWithData:(const void*)data pixelFormat:(Texture2DPixelFormat)pixelFormat pixelsWide:(NSUInteger)width pixelsHigh:(NSUInteger)height contentSize:(CGSize)size;
- (id) initWithData:(const void*)data pixelFormat:(Texture2DPixelFormat)pixelFormat pixelsWide:(NSUInteger)width 
		 pixelsHigh:(NSUInteger)height contentSize:(CGSize)size generateMips:(BOOL)genMips;
@property(readonly) Texture2DPixelFormat pixelFormat;
@property(readonly) NSUInteger pixelsWide;
@property(readonly) NSUInteger pixelsHigh;

@property(readonly) GLuint name;

@property(readonly, nonatomic) CGSize contentSize;
@property(readonly) GLfloat maxS;
@property(readonly) GLfloat maxT;
@end

/*
Drawing extensions to make it easy to draw basic quads using a Texture2D object.
These functions require GL_TEXTURE_2D and both GL_VERTEX_ARRAY and GL_TEXTURE_COORD_ARRAY client states to be enabled.
*/
@interface Texture2D (Drawing)
- (void) preload; //Forces the texture to "preload" by drawing an invisible quad with it
- (void) drawAtPoint:(CGPoint)point;
- (void) drawAtPoint:(CGPoint)point depth:(CGFloat)depth :(BOOL)center;
- (void) drawInRect:(CGRect)rect;
- (void) drawInRect2:(CGRect)rect;
- (void) drawText:(CGRect)rect;
- (void) drawButton:(Button)button;
- (void) drawButton2:(Button)button;
- (void) drawTextHalfsies:(CGRect)rect;
- (void) drawTextNoScale:(CGRect)rect;
- (void) drawInRect:(CGRect)rect depth:(CGFloat)depth;
-(void) drawSky:(CGRect)rect depth:(CGFloat)depth;
@end

/*
Extensions to make it easy to create a Texture2D object from an image file.
Note that RGBA type textures will have their alpha premultiplied - use the blending mode (GL_ONE, GL_ONE_MINUS_SRC_ALPHA).
*/
@interface Texture2D (Image)
- (id) initWithImagePath:(NSString*)path; //If the path is not absolute, it is assumed to be relative to the main bundle's resources
- (id) initWithImagePath:(NSString*)path sizeToFit:(BOOL)sizeToFit;
- (id) initWithImagePath:(NSString*)path sizeToFit:(BOOL)sizeToFit  generateMips:(BOOL)genMips; //For non-power-of-two images, if "sizeToFit" is YES, the image is scaled to power-of-two dimensions, otherwise extra margins are added
- (id) initWithImagePath:(NSString*)path sizeToFit:(BOOL)sizeToFit pixelFormat:(Texture2DPixelFormat)pixelFormat generateMips:(BOOL)genMips;

- (id) initWithCGImage:(CGImageRef)image orientation:(UIImageOrientation)orientation sizeToFit:(BOOL)sizeToFit pixelFormat:(Texture2DPixelFormat)pixelFormat generateMips:(BOOL)genMips; //Primitive
@end

/*
Extensions to make it easy to create a Texture2D object from a string of text.
Note that the generated textures are of type A8 - use the blending mode (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA).
*/
@interface Texture2D (Text)
- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size;
- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment font:(UIFont*)font;

+ (void) drawTexture:(Texture2D*)texture atPoint:(CGPoint)point depth:(CGFloat)depth;
@end
