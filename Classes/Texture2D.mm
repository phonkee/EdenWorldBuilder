 /*

===== IMPORTANT =====

This is sample code demonstrating API, technology or techniques in development.
Although this sample code has been reviewed for technical accuracy, it is not
final. Apple is supplying this information to help you plan for the adoption of
the technologies and programming interfaces described herein. This information
is subject to change, and software implemented based on this sample code should
be tested with final operating system software and final documentation. Newer
versions of this sample code may be provided with future seeds of the API or
technology. For information about updates to this and other developer
documentation, view the New & Updated sidebars in subsequent documentation
seeds.

=====================

File: Texture2D.m
Abstract: Convenience class that allows to create OpenGL 2D textures from images, text or raw data.

Version: 1.3

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
("Apple") in consideration of your agreement to the following terms, and your
use, installation, modification or redistribution of this Apple software
constitutes acceptance of these terms.  If you do not agree with these terms,
please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject
to these terms, Apple grants you a personal, non-exclusive license, under
Apple's copyrights in this original Apple software (the "Apple Software"), to
use, reproduce, modify and redistribute the Apple Software, with or without
modifications, in source and/or binary forms; provided that if you redistribute
the Apple Software in its entirety and without modifications, you must retain
this notice and the following text and disclaimers in all such redistributions
of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may be used
to endorse or promote products derived from the Apple Software without specific
prior written permission from Apple.  Except as expressly stated in this notice,
no other rights or licenses, express or implied, are granted by Apple herein,
including but not limited to any patent rights that may be infringed by your
derivative works or by other works in which the Apple Software may be
incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/

#import <OpenGLES/ES1/glext.h>
#import "Glu.h"
#import "Texture2D.h"
#import "OpenGL_Internal.h"
#import "GLobals.h"
#import "World.h"
#import "Util.h"
#import "ColorUtilc.h"
//CONSTANTS:

#define kMaxTextureSize		1024

//CLASS IMPLEMENTATIONS:

@implementation Texture2D

@synthesize contentSize=_size, pixelFormat=_format, pixelsWide=_width, pixelsHigh=_height, name=_name, maxS=_maxS, maxT=_maxT;

- (id) initWithData:(const void*)data pixelFormat:(Texture2DPixelFormat)pixelFormat pixelsWide:(NSUInteger)width 
		 pixelsHigh:(NSUInteger)height contentSize:(CGSize)size{
	return [self initWithData:data pixelFormat:pixelFormat pixelsWide:width pixelsHigh:height contentSize:size generateMips:FALSE];
}
- (id) initWithData:(const void*)data pixelFormat:(Texture2DPixelFormat)pixelFormat pixelsWide:(NSUInteger)width 
		 pixelsHigh:(NSUInteger)height contentSize:(CGSize)size generateMips:(BOOL)genMips
{
	GLint					saveName;
	
	if((self = [super init])) {
		glGenTextures(1, &_name);
		glGetIntegerv(GL_TEXTURE_BINDING_2D, &saveName);
		glBindTexture(GL_TEXTURE_2D, _name);
		if(genMips){
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
			glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_LINEAR);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		}else{
            glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);
			glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_LINEAR);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
			//glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
			//glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
			//glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);	
			//glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);	
		}
		//glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);	
		
		switch(pixelFormat) {
			
			case kTexture2DPixelFormat_RGBA8888:
               
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)width, (int)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
			break;
			
			case kTexture2DPixelFormat_RGBA4444:
                
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)width, (int)height, 0, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, data);
			break;
			
			case kTexture2DPixelFormat_RGBA5551:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)width, (int)height, 0, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, data);
			break;
			
			case kTexture2DPixelFormat_RGB565:
				
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, (int)width, (int)height, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, data);
		
			break;
			
			case kTexture2DPixelFormat_RGB888:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB,(int)width, (int)height, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
			break;
			
			case kTexture2DPixelFormat_L8:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, (int)width, (int)height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, data);
			break;
			
			case kTexture2DPixelFormat_A8:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, (int)width, (int)height, 0, GL_ALPHA, GL_UNSIGNED_BYTE, data);
			break;
			
			case kTexture2DPixelFormat_LA88:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE_ALPHA, (int)width, (int)height, 0, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, data);
			break;
			
			case kTexture2DPixelFormat_RGB_PVRTC2:
			glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG, (int)width, (int)height, 0, ((int)width * (int)height) / 4, data);
			break;
			
			case kTexture2DPixelFormat_RGB_PVRTC4:
			glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG, (int)width, (int)height, 0, ((int)width * (int)height) / 2, data);
			break;
			
			case kTexture2DPixelFormat_RGBA_PVRTC2:
			glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG, (int)width, (int)height, 0, ((int)width * (int)height) / 4, data);
			break;
			
			case kTexture2DPixelFormat_RGBA_PVRTC4:
			glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG, (int)width, (int)height, 0, ((int)width * (int)height) / 2, data);
			break;
			
			default:
			[NSException raise:NSInternalInconsistencyException format:@""];
			
		}
		glBindTexture(GL_TEXTURE_2D, saveName);
		
		if(!CHECK_GL_ERROR()) {			
			[self release];
			return nil;
		}
		
		_size = size;
		_width = width;
		_height = height;
		_format = pixelFormat;
		_maxS = size.width / (float)width;
		_maxT = size.height / (float)height;
	}
	
	return self;
}

- (void) dealloc
{
	
	if(_name){
		
	glDeleteTextures(1, &_name);
	}
	[super dealloc];
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %@ | Name = %i | Dimensions = %ix%i | Coordinates = (%.2f, %.2f)>", [self class], self, _name, (int)_width, (int)_height,(double) _maxS, (double)_maxT];
}

@end

@implementation Texture2D (Image)

- (id) initWithImagePath:(NSString*)path
{
	return [self initWithImagePath:path sizeToFit:NO generateMips:FALSE];
}
- (id) initWithImagePath:(NSString*)path sizeToFit:(BOOL)sizeToFit  generateMips:(BOOL)genMips;
{
	return [self initWithImagePath:path sizeToFit:sizeToFit pixelFormat:kTexture2DPixelFormat_Automatic generateMips:genMips];

}
- (id) initWithImagePath:(NSString*)path sizeToFit:(BOOL)sizeToFit
{
	return [self initWithImagePath:path sizeToFit:sizeToFit pixelFormat:kTexture2DPixelFormat_Automatic generateMips:FALSE];
}
CGContextRef CreateARGBBitmapContext (CGImageRef inImage)
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (int)(pixelsWide * 4);
    bitmapByteCount     = (int)(bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst| kCGBitmapByteOrder32Big);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

CGImageRef ManipulateImagePixelData(CGImageRef inImage,CGImageRef inMask,int tint)
{
    // Create the bitmap context
    CGContextRef cgctx = CreateARGBBitmapContext(inImage);
    CGContextRef cgctx2 = CreateARGBBitmapContext(inImage);
    if (cgctx == NULL)
    {
        // error creating context
        printg("error creating context for manipulation\n");
        return NULL;
    }
    
    // Get image width, height. We'll use the entire image.
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextSetBlendMode(cgctx, kCGBlendModeCopy);
    CGContextSetBlendMode(cgctx2, kCGBlendModeCopy);
    CGContextDrawImage(cgctx, rect, inImage);
    CGContextDrawImage(cgctx2, rect, inMask);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    int *data = (int*)CGBitmapContextGetData (cgctx);
    int *data2 = (int*)CGBitmapContextGetData (cgctx2);
    
   int cr =  (tint >> 8) & 255;
    int cg = (tint >> 16) & 255;
    int cb =   (tint >> 24) & 255;
    float fr=cr/255.0f;
    float fg=cg/255.0f;
    float fb=cb/255.0f;
    
    if (data != NULL)
    {
        for(int i=0;i<w*h;i++){
            if(data2[i]==0xFFFFFFFF){
                //outputRed = (foregroundRed * foregroundAlpha) + (backgroundRed * (1.0 - foregroundAlpha));
                int rr,gg,bb;
                int rgba=data[i];
                rr =  (rgba >> 8) & 255;
                gg = (rgba >> 16) & 255;
                bb =   (rgba >> 24) & 255;
                bb=MAX(MAX(bb,gg),rr);
                
               // int color= (()<<24) | (b<<16) | (b<<8)  | 0xFF;
              // int igrey= (bb<<24) | (bb<<16) | (bb<<8)  | 0xFF;
                
                float grey=bb/255.0f;
                float r=grey*fr;
                float g=grey*fg;
                float b=grey*fb;
             /*   float r=(grey*.5f)+(fr*(1.0-.5f));
                float g=(grey*.5f)+(fg*(1.0-.5f));
                float b=(grey*.5f)+(fb*(1.0-.5f));*/
                rr=r*255;
                gg=g*255;
                bb=b*255;
                data[i]= (bb<<24) | (gg<<16) | (rr<<8)  | 0xFF;
                
                
                               //     data[i]=ret<<8 | 0xFF;
                //printg("hex(%X,%X)\n",data[i],data[i+1]);
            }
            //if(i%2==0)
            //data[i]=0xFFFFFFFF;
        }
        // **** You have a pointer to the image data ****
        
        // **** Do stuff with the data here ****
        
    }
    CGImageRef ref=CGBitmapContextCreateImage(cgctx);
    // When finished, release the context
    CGContextRelease(cgctx);
    CGContextRelease(cgctx2);
    // Free image data memory for the context
    if (data)
    {
        free(data);
    }
    if(data2){
        free(data2);
    }
    return ref;
    
}
#define MIN3(x,y,z)  ((y) <= (z) ? \
((x) <= (y) ? (x) : (y)) \
: \
((x) <= (z) ? (x) : (z)))

#define MAX3(x,y,z)  ((y) >= (z) ? \
((x) >= (y) ? (x) : (y)) \
: \
((x) >= (z) ? (x) : (z)))

struct rgb_color {
    float r, g, b;    /* Channel intensities between 0.0 and 1.0 */
};

struct hsv_color {
    float hue;        /* Hue degree between 0.0 and 360.0 */
    float sat;        /* Saturation between 0.0 (gray) and 1.0 */
    float val;        /* Value between 0.0 (black) and 1.0 */
};


struct hsv_color rgb_to_hsv(struct rgb_color rgb) {
    struct hsv_color hsv;
    double rgb_min, rgb_max;
    rgb_min = MIN3(rgb.r, rgb.g, rgb.b);
    rgb_max = MAX3(rgb.r, rgb.g, rgb.b);
    hsv.val = rgb_max;
    if (hsv.val == 0) {
        hsv.hue = hsv.sat = 0;
        return hsv;
    }
    /* Normalize value to 1 */
    rgb.r /= hsv.val;
    rgb.g /= hsv.val;
    rgb.b /= hsv.val;
    rgb_min = MIN3(rgb.r, rgb.g, rgb.b);
    rgb_max = MAX3(rgb.r, rgb.g, rgb.b);
    hsv.sat = rgb_max - rgb_min;
    if (hsv.sat == 0) {
        hsv.hue = 0;
        return hsv;
    }
    /* Normalize saturation to 1 */
    rgb.r = (rgb.r - rgb_min)/(rgb_max - rgb_min);
    rgb.g = (rgb.g - rgb_min)/(rgb_max - rgb_min);
    rgb.b = (rgb.b - rgb_min)/(rgb_max - rgb_min);
    rgb_min = MIN3(rgb.r, rgb.g, rgb.b);
    rgb_max = MAX3(rgb.r, rgb.g, rgb.b);
    /* Compute hue */
    if (rgb_max == rgb.r) {
        hsv.hue = 0.0 + 60.0*(rgb.g - rgb.b);
        if (hsv.hue < 0.0) {
            hsv.hue += 360.0;
        }
    } else if (rgb_max == rgb.g) {
        hsv.hue = 120.0 + 60.0*(rgb.b - rgb.r);
    } else /* rgb_max == rgb.b */ {
        hsv.hue = 240.0 + 60.0*(rgb.r - rgb.g);
    }
    return hsv;
}
/**
 * Converts an RGB color value to HSL. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
 * Assumes r, g, and b are contained in the set [0, 255] and
 * returns h, s, and l in the set [0, 1].
 *
 * @param   Number  r       The red color value
 * @param   Number  g       The green color value
 * @param   Number  b       The blue color value
 * @return  Array           The HSL representation
 */
struct hsv_color rgbToHsl(float r, float g, float b){
    struct hsv_color ret;
    
    float max = MAX3(r, g, b);
    float min = MIN3(r, g, b);
    float h, s, l = (max + min) / 2;
    
    if(max == min){
        h = s = 0; // achromatic
    }else{
        float d = max - min;
        s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
        if(max==r)
            h = (g - b) / d + (g < b ? 6 : 0);
        else if(max==g)
            h = (b - r) / d + 2;
        else if(max==b)
            h = (r - g) / d + 4; 
        
        h /= 6;
    }
    ret.hue=h;
    ret.sat=s;
    ret.val=l;
    return ret;
}

/**
 * Converts an HSL color value to RGB. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
 * Assumes h, s, and l are contained in the set [0, 1] and
 * returns r, g, and b in the set [0, 255].
 *
 * @param   Number  h       The hue
 * @param   Number  s       The saturation
 * @param   Number  l       The lightness
 * @return  Array           The RGB representation
 */
float hue2rgb(float p, float q, float t){
    if(t < 0) t += 1;
    if(t > 1) t -= 1;
    if(t < 1/6) return p + (q - p) * 6 * t;
    if(t < 1/2) return q;
    if(t < 2/3) return p + (q - p) * (2/3 - t) * 6;
    return p;
}
struct rgb_color hslToRgb(float h, float s, float l){
    float r, g, b;
    
    if(s == 0){
        r = g = b = l; // achromatic
    }else{
        
        
        float q = l < 0.5 ? l * (1 + s) : l + s - l * s;
        float p = 2 * l - q;
        r = hue2rgb(p, q, h + 1/3);
        g = hue2rgb(p, q, h);
        b = hue2rgb(p, q, h - 1/3);
    }
    struct rgb_color ret;
    ret.r=r/255.0f;
    ret.g=g/255.0f;
    ret.b=b/255.0f;
    return ret;
}


CGImageRef ManipulateImagePixelData2(CGImageRef inImage,int tint,int mode)
{
    // Create the bitmap context
    CGContextRef cgctx = CreateARGBBitmapContext(inImage);
   
    if (cgctx == NULL)
    {
        // error creating context
        printg("error creating context for manipulation\n");
        return NULL;
    }
    
    // Get image width, height. We'll use the entire image.
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage);
       
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    int *data = (int*)CGBitmapContextGetData (cgctx);
   
    
    int cr =  (tint >> 8) & 255;
    int cg = (tint >> 16) & 255;
    int cb =   (tint >> 24) & 255;
    float fr=cr/255.0f;
    float fg=cg/255.0f;
    float fb=cb/255.0f;
    fr=fr;
    fg=fg;
    fb=fb;
    //void RGB2HSL(int color,int* h,int* s,int* l);
    //int HSL2RGB(int h,int s,int l);
    unsigned int hh,ss,ll;
    
    void RGB2HSL(unsigned int color,unsigned int* h,unsigned int* s,unsigned int* l);
    unsigned int HSL2RGB(unsigned int h,unsigned int s,unsigned int l);
    unsigned int utint=((tint>>8)&0x00FFFFFF);
    
    
    RGB2HSL(utint,&hh,&ss,&ll);
    unsigned int ret=HSL2RGB(hh,ss,ll);
        
    if(ret!=utint){
        printg("conversion off: %X != %X\n",utint,ret);
    }else{
        printg("convert success!");
    }
    if (data != NULL)
    {
        for(int i=0;i<w*h;i++){
           
                //outputRed = (foregroundRed * foregroundAlpha) + (backgroundRed * (1.0 - foregroundAlpha));
                int rr,gg,bb;
                int rgba=data[i];
                rr =  (rgba >> 8) & 255;
                gg = (rgba >> 16) & 255;
                bb =   (rgba >> 24) & 255;
                
                
                // int color= (()<<24) | (b<<16) | (b<<8)  | 0xFF;
                // int igrey= (bb<<24) | (bb<<16) | (bb<<8)  | 0xFF;
            
            
            float grey=bb/255.0f;
            //grey*=100;
           float r,g,b;
           /*
            unsigned int ret=HSL2RGB(hh,ss,(4.0f*grey+ll)/5.0f);
            data[i]=(ret<<8)|0xFF;*/
           
            r=(grey*fr);
            g=(grey*fg);
            b=(grey*fb);
            
            
            
          
              
                rr=r*255;
                gg=g*255;
                bb=b*255;
                data[i]= (bb<<24) | (gg<<16) | (rr<<8)  | 0xFF;
                
        }
       
        
    }
    CGImageRef ref=CGBitmapContextCreateImage(cgctx);
    // When finished, release the context
    CGContextRelease(cgctx);
  
    // Free image data memory for the context
    if (data)
    {
        free(data);
    }
    return ref;
    
}


extern UIImage* storedSkins[5][2];
extern UIImage* storedMasks[5][2];
extern UIImage* storedDoor;
extern UIImage* storedDoorMask;
extern UIImage* storedPaint;
extern UIImage* storedPaintMask;
extern UIImage* storedCube;
extern UIImage* storedCubeMask;
extern UIImage* storedFlowerico;
extern UIImage* storedFlowericoMask;
extern UIImage* storedDoorico;
extern UIImage* storedDooricoMask;
extern UIImage* storedPortalico;
extern UIImage* storedPortalicoMask;

int storedMaskCounter=-1;
int storedSkinCounter=-1;
int realStoredSkinCounter=0;
/*
 temp=[[Texture2D alloc] initWithImagePath:@"Batty_BlinkMASK.png" sizeToFit:FALSE];
 [textures addObject:temp];
 temp=[[Texture2D alloc] initWithImagePath:@"Batty_DefaultMASK.png" sizeToFit:FALSE];
 [textures addObject:temp];
 temp=[[Texture2D alloc] initWithImagePath:@"Green_BlinkMASK.png" sizeToFit:FALSE];
 [textures addObject:temp];
 temp=[[Texture2D alloc] initWithImagePath:@"Green_DefaultMASK.png" sizeToFit:FALSE];
 [textures addObject:temp];
 temp=[[Texture2D alloc] initWithImagePath:@"Moof_BlinkMASK.png" sizeToFit:FALSE];
 [textures addObject:temp];
 temp=[[Texture2D alloc] initWithImagePath:@"Moof_DefaultMASK.png" sizeToFit:FALSE];
 [textures addObject:temp];
 temp=[[Texture2D alloc] initWithImagePath:@"Nergle_BlinkMASK.png" sizeToFit:FALSE];
 [textures addObject:temp];
 temp=[[Texture2D alloc] initWithImagePath:@"Nergle_DefaultMASK.png" sizeToFit:FALSE];
 [textures addObject:temp];
 temp=[[Texture2D alloc] initWithImagePath:@"Stumpy_BlinkMASK.png" sizeToFit:FALSE];
 [textures addObject:temp];
 temp=[[Texture2D alloc] initWithImagePath:@"Stumpy_DefaultMASK.png" sizeToFit:FALSE];
 [textures addObject:temp];
 */
- (id) initWithImagePath:(NSString*)path sizeToFit:(BOOL)sizeToFit pixelFormat:(Texture2DPixelFormat)pixelFormat generateMips:(BOOL)genMips
{
	UIImage*				uiImage;
    BOOL isMask=FALSE;
    BOOL isDoor=FALSE;
    BOOL isPaint=FALSE;
    BOOL isGoldcubeico=FALSE;
    BOOL isFlowerico=FALSE;
    BOOL isDoorico=FALSE;
    BOOL isPortalico=FALSE;
    BOOL storeImage=FALSE;
    if(storedSkinCounter>=0&&storedSkinCounter<15){
        if(storedSkinCounter%3!=1){
            
            storeImage=TRUE;
        }
        storedSkinCounter++;
       
    }
    if(storedMaskCounter>=0&&storedMaskCounter<10){
        
        isMask=TRUE;
        storeImage=TRUE;
        
    }
    if([path isEqualToString:@"door.png"]){
        isDoor=TRUE;
        storeImage=TRUE;
        //printg("stored door path %s\n",[path cStringUsingEncoding:NSUTF8StringEncoding]);

    }else if([path isEqualToString:@"door_mask.png"]){
        isDoor=TRUE;
        isMask=TRUE;
        storeImage=TRUE;
       
    }else if([path isEqualToString:@"palette.png"]){
       isPaint=TRUE;
        storeImage=TRUE;
        
    }else if([path isEqualToString:@"paint_mask.png"]){
        isPaint=TRUE;
        isMask=TRUE;
        storeImage=TRUE;
    }else if([path isEqualToString:@"goldcube_icon.png"]){
       // printg("stored cube path %s\n",[path cStringUsingEncoding:NSUTF8StringEncoding]);
        isGoldcubeico=TRUE;
        storeImage=TRUE;
    }else if([path isEqualToString:@"goldcube_icon_mask.png"]){
       // printg("stored cube mask path %s\n",[path cStringUsingEncoding:NSUTF8StringEncoding]);
        isGoldcubeico=TRUE;
        isMask=TRUE;
        storeImage=TRUE;
    }else if([path isEqualToString:@"flower_icon.png"]){
        isFlowerico=TRUE;
        storeImage=TRUE;
    }else if([path isEqualToString:@"flower_icon_mask.png"]){
        isFlowerico=TRUE;
        isMask=TRUE;
        storeImage=TRUE;
    }else if([path isEqualToString:@"door_icon2.png"]){
        isDoorico=TRUE;
        storeImage=TRUE;
    }else if([path isEqualToString:@"door_icon2_mask.png"]){
        isDoorico=TRUE;
        isMask=TRUE;
        storeImage=TRUE;
    }else if([path isEqualToString:@"portal_icon2.png"]){
        isPortalico=TRUE;
        storeImage=TRUE;
    }else if([path isEqualToString:@"portal_icon2_mask.png"]){
        isPortalico=TRUE;
        isMask=TRUE;
        storeImage=TRUE;
    }    //
    
    if(IS_IPAD||SUPPORTS_RETINA){
        NSString* oipadPath=[NSString stringWithFormat:@"ipad~%@",path];
        NSString* ipadPath=[[NSBundle mainBundle] pathForResource:oipadPath ofType:nil];
        NSFileManager* fm=[NSFileManager defaultManager];
        if([fm fileExistsAtPath:ipadPath]){
            path=oipadPath;
        }
        
    }
	//NSString* opath=[NSString stringWithString:path];
	if(![path isAbsolutePath])
	path = [[NSBundle mainBundle] pathForResource:path ofType:nil];
	
    
	uiImage = [[UIImage alloc] initWithContentsOfFile:path];
   
        self = [self initWithCGImage:[uiImage CGImage] orientation:[uiImage imageOrientation] sizeToFit:sizeToFit pixelFormat:pixelFormat generateMips:(BOOL)genMips];
    
    
	
    
    if(storeImage){
        /* BOOL isGoldcubeico=FALSE;
         BOOL isFlowerico=FALSE;
         BOOL isDoorico=FALSE;
         BOOL isPortalico=FALSE;
         BOOL storeImage=FALSE;
*/
        if(isPortalico){
            if(isMask){
                storedPortalicoMask=uiImage;
            }else
                storedPortalico=uiImage;
        }else if(isDoorico){
            if(isMask){
                storedDooricoMask=uiImage;
            }else
                storedDoorico=uiImage;
        }else if(isFlowerico){
            if(isMask){
                storedFlowericoMask=uiImage;
            }else
                storedFlowerico=uiImage;
        }else if(isGoldcubeico){
            if(isMask){
                storedCubeMask=uiImage;
            }else
                storedCube=uiImage;
        }else if(isPaint){
            if(isMask){
                storedPaintMask=uiImage;
            }else
                storedPaint=uiImage;
        }else
        if(isDoor){
            if(isMask){
                storedDoorMask=uiImage;
            }else
                storedDoor=uiImage;
        }else
        if(isMask){
          //  printg("Storing mask in [%d][%d]: %s\n",storedMaskCounter/2,storedMaskCounter%2,[path cStringUsingEncoding:NSUTF8StringEncoding]);
            storedMasks[storedMaskCounter/2][storedMaskCounter%2]=uiImage;
            storedMaskCounter++;
            
        }else{
            storedSkins[realStoredSkinCounter/2][realStoredSkinCounter%2]=uiImage;
            realStoredSkinCounter++;}
    }else
	[uiImage release];
	
	if(self == nil)
	REPORT_ERROR(@"Failed loading image at path \"%@\" %@", path,path);
    //else
   // REPORT_ERROR(@"loaded image at path \"%@\" %@", path,opath);
	
	return self;
}
	
- (id) initWithCGImage:(CGImageRef)image orientation:(UIImageOrientation)orientation sizeToFit:(BOOL)sizeToFit pixelFormat:(Texture2DPixelFormat)pixelFormat generateMips:(BOOL)genMips
{
	NSUInteger				width,
							height,
							i;
	CGContextRef			context = nil;
	void*					data = nil;;
	CGColorSpaceRef			colorSpace;
	void*					tempData;
	unsigned char*			inPixel8;
	unsigned int*			inPixel32;
	unsigned char*			outPixel8;
	unsigned short*			outPixel16;
	BOOL					hasAlpha;
	CGImageAlphaInfo		info;
	CGAffineTransform		transform;
	CGSize					imageSize;
	
	if(image == NULL) {
		[self release];
		return nil;
	}
	
	if(pixelFormat == kTexture2DPixelFormat_Automatic) {
		info = CGImageGetAlphaInfo(image);
		hasAlpha = ((info == kCGImageAlphaPremultipliedLast) || (info == kCGImageAlphaPremultipliedFirst) || (info == kCGImageAlphaLast) || (info == kCGImageAlphaFirst) ? YES : NO);
		if(CGImageGetColorSpace(image)) {
			if(CGColorSpaceGetModel(CGImageGetColorSpace(image)) == kCGColorSpaceModelMonochrome) {
				if(hasAlpha) {
					pixelFormat = kTexture2DPixelFormat_LA88;
#if __DEBUG__
					if((CGImageGetBitsPerComponent(image) != 8) && (CGImageGetBitsPerPixel(image) != 16))
					REPORT_ERROR(@"Unoptimal image pixel format for image at path \"%@\"", path);
#endif
				}
				else {
					pixelFormat = kTexture2DPixelFormat_L8;
#if __DEBUG__
					if((CGImageGetBitsPerComponent(image) != 8) && (CGImageGetBitsPerPixel(image) != 8))
					REPORT_ERROR(@"Unoptimal image pixel format for image at path \"%@\"", path);
#endif
				}
			}
			else {
				if((CGImageGetBitsPerPixel(image) == 16) && !hasAlpha)
				pixelFormat = kTexture2DPixelFormat_RGBA5551;
				else {
					if(hasAlpha)
					pixelFormat = kTexture2DPixelFormat_RGBA8888;
					else {
						pixelFormat = kTexture2DPixelFormat_RGB565;
#if __DEBUG__
						if((CGImageGetBitsPerComponent(image) != 8) && (CGImageGetBitsPerPixel(image) != 24))
						REPORT_ERROR(@"Unoptimal image pixel format for image at path \"%s\"", path);
#endif
					}
				}
			}		
		}
		else { //NOTE: No colorspace means a mask image
			pixelFormat = kTexture2DPixelFormat_A8;
#if __DEBUG__
			if((CGImageGetBitsPerComponent(image) != 8) && (CGImageGetBitsPerPixel(image) != 8))
			REPORT_ERROR(@"Unoptimal image pixel format for image at path \"%@\"", path);
#endif
		}
	}
	
	imageSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
	switch(orientation) {
		
		case UIImageOrientationUp: //EXIF = 1
		transform = CGAffineTransformIdentity;
		break;
		
		case UIImageOrientationUpMirrored: //EXIF = 2
		transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
		transform = CGAffineTransformScale(transform, -1.0, 1.0);
		break;
		
		case UIImageOrientationDown: //EXIF = 3
		transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
		transform = CGAffineTransformRotate(transform, M_PI);
		break;
		
		case UIImageOrientationDownMirrored: //EXIF = 4
		transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
		transform = CGAffineTransformScale(transform, 1.0, -1.0);
		break;
		
		case UIImageOrientationLeftMirrored: //EXIF = 5
		transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
		transform = CGAffineTransformScale(transform, -1.0, 1.0);
		transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
		break;
		
		case UIImageOrientationLeft: //EXIF = 6
		transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
		transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
		break;
		
		case UIImageOrientationRightMirrored: //EXIF = 7
		transform = CGAffineTransformMakeScale(-1.0, 1.0);
		transform = CGAffineTransformRotate(transform, M_PI / 2.0);
		break;
		
		case UIImageOrientationRight: //EXIF = 8
		transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
		transform = CGAffineTransformRotate(transform, M_PI / 2.0);
		break;
		
		default:
		[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
		
	}
	if((orientation == UIImageOrientationLeftMirrored) || (orientation == UIImageOrientationLeft) || (orientation == UIImageOrientationRightMirrored) || (orientation == UIImageOrientationRight))
	imageSize = CGSizeMake(imageSize.height, imageSize.width);
	
	width = imageSize.width;
	if((width != 1) && (width & (width - 1))) {
		i = 1;
		while((sizeToFit ? 2 * i : i) < width)
		i *= 2;
		width = i;
	}
	height = imageSize.height;
	if((height != 1) && (height & (height - 1))) {
		i = 1;
		while((sizeToFit ? 2 * i : i) < height)
		i *= 2;
		height = i;
	}
	while((width > kMaxTextureSize) || (height > kMaxTextureSize)) {
#if __DEBUG__
		REPORT_ERROR(@"Image at %ix%i pixels is too big to fit in texture", width, height);
#endif
		width /= 2;
		height /= 2;
		transform = CGAffineTransformScale(transform, 0.5, 0.5);
		imageSize.width *= 0.5;
		imageSize.height *= 0.5;
	}
	
	switch(pixelFormat) {
		
		case kTexture2DPixelFormat_RGBA8888:
		case kTexture2DPixelFormat_RGBA4444:
		colorSpace = CGColorSpaceCreateDeviceRGB();
		data = malloc(height * width * 4);
		context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
		CGColorSpaceRelease(colorSpace);
		break;
		
		case kTexture2DPixelFormat_RGBA5551:
		colorSpace = CGColorSpaceCreateDeviceRGB();
		data = malloc(height * width * 2);
		context = CGBitmapContextCreate(data, width, height, 5, 2 * width, colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder16Little);
		CGColorSpaceRelease(colorSpace);
		break;
		
		case kTexture2DPixelFormat_RGB888:
		case kTexture2DPixelFormat_RGB565:
		colorSpace = CGColorSpaceCreateDeviceRGB();
		data = malloc(height * width * 4);
		context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
		CGColorSpaceRelease(colorSpace);
		break;
		
		case kTexture2DPixelFormat_L8:
		colorSpace = CGColorSpaceCreateDeviceGray();
		data = malloc(height * width);
		context = CGBitmapContextCreate(data, width, height, 8, width, colorSpace, kCGImageAlphaNone);
		CGColorSpaceRelease(colorSpace);
		break;
		
		case kTexture2DPixelFormat_A8:
		data = malloc(height * width);
		context = CGBitmapContextCreate(data, width, height, 8, width, NULL, kCGImageAlphaOnly);
		break;
		
		case kTexture2DPixelFormat_LA88:
		colorSpace = CGColorSpaceCreateDeviceRGB();
		data = malloc(height * width * 4);
		context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
		CGColorSpaceRelease(colorSpace);
		break;
		
		default:
		[NSException raise:NSInternalInconsistencyException format:@"Invalid pixel format"];
		
	}
	if(context == NULL) {
		REPORT_ERROR(@"Failed creating CGBitmapContext", NULL);
		free(data);
		[self release];
		return nil;
	}
	
	if(sizeToFit)
	CGContextScaleCTM(context, (CGFloat)width / imageSize.width, (CGFloat)height / imageSize.height);
	else {
		CGContextClearRect(context, CGRectMake(0, 0, width, height));
		CGContextTranslateCTM(context, 0, height - imageSize.height);
	}
	if(!CGAffineTransformIsIdentity(transform))
	CGContextConcatCTM(context, transform);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
	CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
	
	//Convert "-RRRRRGGGGGBBBBB" to "RRRRRGGGGGBBBBBA"
	if(pixelFormat == kTexture2DPixelFormat_RGBA5551) {
		outPixel16 = (unsigned short*)data;
		for(i = 0; i < width * height; ++i, ++outPixel16)
		*outPixel16 = *outPixel16 << 1 | 0x0001;
#if __DEBUG__
		REPORT_ERROR(@"Falling off fast-path converting pixel data from ARGB1555 to RGBA5551", NULL);
#endif
	}
	//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRRRRRGGGGGGGGBBBBBBBB"
	else if(pixelFormat == kTexture2DPixelFormat_RGB888) {
		tempData = malloc(height * width * 3);
		inPixel8 = (unsigned char*)data;
		outPixel8 = (unsigned char*)tempData;
		for(i = 0; i < width * height; ++i) {
			*outPixel8++ = *inPixel8++;
			*outPixel8++ = *inPixel8++;
			*outPixel8++ = *inPixel8++;
			inPixel8++;
		}
		free(data);
		data = tempData;
#if __DEBUG__
		REPORT_ERROR(@"Falling off fast-path converting pixel data from RGBA8888 to RGB888", NULL);
#endif
	}
	//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGGBBBBB"
	else if(pixelFormat == kTexture2DPixelFormat_RGB565) {
		tempData = malloc(height * width * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(i = 0; i < width * height; ++i, ++inPixel32)
		*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | ((((*inPixel32 >> 8) & 0xFF) >> 2) << 5) | ((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);
		free(data);
		data = tempData;
#if __DEBUG__
		REPORT_ERROR(@"Falling off fast-path converting pixel data from RGBA8888 to RGB565", NULL);
#endif
	}
	//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGBBBBAAAA"
	else if(pixelFormat == kTexture2DPixelFormat_RGBA4444) {
		tempData = malloc(height * width * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(i = 0; i < width * height; ++i, ++inPixel32)
		*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 4) << 12) | ((((*inPixel32 >> 8) & 0xFF) >> 4) << 8) | ((((*inPixel32 >> 16) & 0xFF) >> 4) << 4) | ((((*inPixel32 >> 24) & 0xFF) >> 4) << 0);
		free(data);
		data = tempData;
#if __DEBUG__
		REPORT_ERROR(@"Falling off fast-path converting pixel data from RGBA8888 to RGBA4444", NULL);
#endif
	}
	//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "LLLLLLLLAAAAAAAA"
	else if(pixelFormat == kTexture2DPixelFormat_LA88) {
		tempData = malloc(height * width * 3);
		inPixel8 = (unsigned char*)data;
		outPixel8 = (unsigned char*)tempData;
		for(i = 0; i < width * height; ++i) {
			*outPixel8++ = *inPixel8++;
			inPixel8 += 2;
			*outPixel8++ = *inPixel8++;
		}
		free(data);
		data = tempData;
#if __DEBUG__
		REPORT_ERROR(@"Falling off fast-path converting pixel data from RGBA8888 to LA88", NULL);
#endif
	}
   // printg("%d,",pixelFormat);
	self = [self initWithData:data pixelFormat:pixelFormat pixelsWide:width pixelsHigh:height contentSize:imageSize generateMips:genMips];
	
	CGContextRelease(context);
	free(data);
	
	return self;
}

@end

@implementation Texture2D (Text)

- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [self initWithString:string dimensions:dimensions alignment:alignment font:[UIFont fontWithName:name size:size]];
}

- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment font:(UIFont*)font
{
	NSUInteger				width,
							height,
							i;
	CGContextRef			context;
	void*					data;
	CGColorSpaceRef			colorSpace;
	
	if(font == nil) {
		REPORT_ERROR(@"Invalid font", NULL);
		[self release];
		return nil;
	}
	
	width = dimensions.width;
	if((width != 1) && (width & (width - 1))) {
		i = 1;
		while(i < width)
		i *= 2;
		width = i;
	}
	height = dimensions.height;
	if((height != 1) && (height & (height - 1))) {
		i = 1;
		while(i < height)
		i *= 2;
		height = i;
	}
	
	/*colorSpace = CGColorSpaceCreateDeviceGray();
	data = calloc(height, width);
	context = CGBitmapContextCreate(data, width, height, 8, width, colorSpace, kCGImageAlphaNone);
	CGColorSpaceRelease(colorSpace);
	if(context == NULL) {
		REPORT_ERROR(@"Failed creating CGBitmapContext", NULL);
		free(data);
		[self release];
		return nil;
	}
	
	CGContextSetGrayFillColor(context, 1.0, 1.0);
	CGContextTranslateCTM(context, 0.0, height);
	CGContextScaleCTM(context, 1.0, -1.0); //NOTE: NSString draws in UIKit referential i.e. renders upside-down compared to CGBitmapContext referential
	UIGraphicsPushContext(context);
		[string drawInRect:CGRectMake(0, 0, dimensions.width, dimensions.height) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:alignment];
	UIGraphicsPopContext();
	
	self = [self initWithData:data pixelFormat:kTexture2DPixelFormat_L8 pixelsWide:width pixelsHigh:height contentSize:dimensions];
	
	CGContextRelease(context);
	free(data);
	
	return self;*/
	
	 colorSpace = CGColorSpaceCreateDeviceRGB();
	 data = calloc(1, width * height * 4);
	 context = CGBitmapContextCreate(data, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	 CGColorSpaceRelease(colorSpace);
	 
	 
	 CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0,1.0);
	 CGContextTranslateCTM(context, 0.0, height);
	 CGContextScaleCTM(context, 1.0, -1.0); //NOTE: NSString draws in UIKit referential i.e. renders upside-down compared to CGBitmapContext referential
	 UIGraphicsPushContext(context);
	 [string drawInRect:CGRectMake(0, 0, dimensions.width, dimensions.height) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:alignment];
	 UIGraphicsPopContext();
	 
	self = [self initWithData:data pixelFormat:kTexture2DPixelFormat_RGBA8888 pixelsWide:width pixelsHigh:height contentSize:dimensions generateMips:FALSE];
	 
	 CGContextRelease(context);
	 free(data);
	 
	 return self;
	 
}

+ (void) drawTexture:(Texture2D*)texture atPoint:(CGPoint)point depth:(CGFloat)depth
{
	GLfloat				maxS = texture.maxS,
    maxT = texture.maxT,
    pixelsWide = texture.pixelsWide,
    pixelsHigh = texture.pixelsHigh;						
	GLfloat				coordinates[] = {
        0,				maxT,
        maxS,			maxT,
        0,				0,
        maxS,			0
    };
	GLfloat				width = (GLfloat)pixelsWide * maxS,
    height = (GLfloat)pixelsHigh * maxT;
	GLfloat				vertices[] = {
        -width / 2 + point.x,		-height / 2 + point.y,		depth,
        width / 2 + point.x,		-height / 2 + point.y,		depth,
        -width / 2 + point.x,		height / 2 + point.y,		depth,
        width / 2 + point.x,		height / 2 + point.y,		depth
    };
	
	glBindTexture(GL_TEXTURE_2D, texture.name);
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}
@end

@implementation Texture2D (Drawing)

- (void) preload
{
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();
	
	[self drawInRect:CGRectMake(-2, -2, 0.1, 0.1)];
	
	glPopMatrix();
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
}

- (void) drawAtPoint:(CGPoint)point
{
	[self drawAtPoint:point depth:0.0 :FALSE];
}

- (void) drawAtPoint:(CGPoint)point depth:(CGFloat)depth :(BOOL)center
{
	GLfloat				coordinates[] = {
							0,				_maxT,
							_maxS,			_maxT,
							0,				0,
							_maxS,			0
						};
	GLfloat				width = (GLfloat)_width * _maxS,
						height = (GLfloat)_height * _maxT;
	GLfloat				cvertices[] = {
							-width / 2 + point.x,		-height / 2 + point.y,		depth,
							width / 2 + point.x,		-height / 2 + point.y,		depth,
							-width / 2 + point.x,		height / 2 + point.y,		depth,
							width / 2 + point.x,		height / 2 + point.y,		depth
						};
	GLfloat				zvertices[] = {
	    point.x,		-height / 2 + point.y,		depth,
		width+ point.x,	-height / 2 + point.y,		depth,
		point.x,		height / 2 + point.y,		depth,
		width + point.x,height / 2 + point.y,		depth
	};
	
	glBindTexture(GL_TEXTURE_2D, _name);
	if(center)
		glVertexPointer(3, GL_FLOAT, 0, cvertices);
	else
		glVertexPointer(3, GL_FLOAT, 0, zvertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void) drawInRect:(CGRect)rect
{
	[self drawInRect:rect depth:0.0];
}
- (void) drawTextHalfsies:(CGRect)rect{
    CGFloat depth=0.0;
	GLfloat				coordinates[] = {
        0,				_maxT,
        _maxS,			_maxT,
        0,				0,
        _maxS,			0
    };
    GLfloat				width = roundf((GLfloat)_width * _maxS),
    height = roundf((GLfloat)_height * _maxT);
    if(!IS_RETINA&&SUPPORTS_RETINA){
        width/=2;
        height/=2;
    }
   
    if(IS_IPAD){
        rect.origin.x*=SCALE_WIDTH;
        rect.origin.y*=SCALE_HEIGHT;
        
        rect.origin.x=roundf(rect.origin.x);
        rect.origin.y=roundf(rect.origin.y);
    }
	GLfloat				vertices[] = {
        rect.origin.x,							rect.origin.y,							depth,
        rect.origin.x + width,		rect.origin.y,							depth,
        rect.origin.x,							rect.origin.y + height,		depth,
        rect.origin.x + width,		rect.origin.y + height,		depth
    };
	
	glBindTexture(GL_TEXTURE_2D, _name);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    
    
}
- (void) drawTextNoScale:(CGRect)rect{
    CGFloat depth=0.0;
	GLfloat				coordinates[] = {
        0,				_maxT,
        _maxS,			_maxT,
        0,				0,
        _maxS,			0
    };
    GLfloat				width = roundf((GLfloat)_width * _maxS),
    height = roundf((GLfloat)_height * _maxT);
    if(!IS_RETINA&&SUPPORTS_RETINA){
        width/=2;
        height/=2;
    }
  	GLfloat				vertices[] = {
        rect.origin.x,							rect.origin.y,							depth,
        rect.origin.x + width,		rect.origin.y,							depth,
        rect.origin.x,							rect.origin.y + height,		depth,
        rect.origin.x + width,		rect.origin.y + height,		depth
    };
	
	glBindTexture(GL_TEXTURE_2D, _name);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    
}
- (void) drawButton2:(Button)button{
     if(button.pressed){
         [self drawButton:button];
     }else{
         CGRect rect=CGRectMake(button.origin.x,button.origin.y,button.size.width,button.size.height);
         [self drawInRect:rect];
     }
}
- (void) drawButton:(Button)button{
    if(button.pressed){
        button.size.width=roundf((GLfloat)_width * _maxS)/2.0f;
        button.size.height=roundf((GLfloat)_height * _maxT)/2.0f;
        float offx=button.size.width*.08f;
        float offy=button.size.height*.08f;
        CGRect rect=CGRectMake(button.origin.x+offx,button.origin.y+offy,
                               button.size.width-offx*2,button.size.height-offy*2);
        CGFloat depth=0.0;
        GLfloat				coordinates[] = {
            0,				_maxT,
            _maxS,			_maxT,
            0,				0,
            _maxS,			0
        };
        GLfloat				width = rect.size.width;
        GLfloat height = rect.size.height;
        
        if(IS_IPAD){
            rect.origin.x*=SCALE_WIDTH;
            rect.origin.y*=SCALE_HEIGHT;
            width*=2;
            height*=2;
            rect.origin.x=roundf(rect.origin.x);
            rect.origin.y=roundf(rect.origin.y);
        }
        GLfloat				vertices[] = {
            rect.origin.x,							rect.origin.y,							depth,
            rect.origin.x + width,		rect.origin.y,							depth,
            rect.origin.x,							rect.origin.y + height,		depth,
            rect.origin.x + width,		rect.origin.y + height,		depth
        };
        
        glBindTexture(GL_TEXTURE_2D, _name);
        glVertexPointer(3, GL_FLOAT, 0, vertices);
        glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
    }else{
    CGRect rect=CGRectMake(button.origin.x,button.origin.y,button.size.width,button.size.height);
    [self drawText:rect];
    }
}
- (void) drawNumbers:(CGRect)rect:(int)num{
    if(num<0||num>10){
        printg("num out of bounds/n");
        num=0;
    }
    CGFloat depth=0.0;
    float xoff=num*1/16.0f;
    float xwidth=1;
    if(num==10)xwidth=2;
	GLfloat				coordinates[] = {
        xoff,				_maxT,
        xoff+_maxS/16.0f*xwidth,	_maxT,
        xoff,				0,
        xoff+_maxS/16.0f*xwidth,	0
    };
    GLfloat				width = roundf((GLfloat)_width * _maxS/16.0f),
    height = roundf((GLfloat)_height * _maxT);
    
    if(num==10){
        width = roundf((GLfloat)_width * _maxS/16.0f*2);
    }
    if(!IS_RETINA&&SUPPORTS_RETINA){
        width/=2;
        height/=2;
    }
    if(IS_IPAD){
        rect.origin.x*=SCALE_WIDTH;
        rect.origin.y*=SCALE_HEIGHT;
        rect.origin.x=roundf(rect.origin.x);
        rect.origin.y=roundf(rect.origin.y);
    }
	GLfloat				vertices[] = {
        rect.origin.x,							rect.origin.y,							depth,
        rect.origin.x + width,		rect.origin.y,							depth,
        rect.origin.x,							rect.origin.y + height,		depth,
        rect.origin.x + width,		rect.origin.y + height,		depth
    };
	
	glBindTexture(GL_TEXTURE_2D, _name);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    
}

- (void) drawTextM:(CGRect)rect{
    CGFloat depth=0.0;
	
    GLfloat				width = 480,
    height = roundf((GLfloat)_height * _maxT);
    
    if(IS_IPAD){
        rect.origin.x*=SCALE_WIDTH;
        width=1024;
        rect.origin.y*=SCALE_HEIGHT;
        rect.origin.x=roundf(rect.origin.x);
        rect.origin.y=roundf(rect.origin.y);
    }
	GLfloat				vertices[] = {
        rect.origin.x,							rect.origin.y,							depth,
        rect.origin.x + width,		rect.origin.y,							depth,
        rect.origin.x,							rect.origin.y + height,		depth,
        rect.origin.x + width,		rect.origin.y + height,		depth
    };
	GLfloat				coordinates[] = {
        0,				_maxT,
        _maxS,			_maxT,
        0,				0,
        _maxS,			0
    };
	glBindTexture(GL_TEXTURE_2D, _name);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    
}

- (void) drawText:(CGRect)rect{
    CGFloat depth=0.0;
	GLfloat				coordinates[] = {
        0,				_maxT,
        _maxS,			_maxT,
        0,				0,
        _maxS,			0
    };
    GLfloat				width = roundf((GLfloat)_width * _maxS),
                        height = roundf((GLfloat)_height * _maxT);
    if(!IS_RETINA&&SUPPORTS_RETINA){
        width/=2;
        height/=2;
    }
    if(IS_IPAD){
        rect.origin.x*=SCALE_WIDTH;
        rect.origin.y*=SCALE_HEIGHT;
         rect.origin.x=roundf(rect.origin.x);
        rect.origin.y=roundf(rect.origin.y);
    }
	GLfloat				vertices[] = {
        rect.origin.x,							rect.origin.y,							depth,
        rect.origin.x + width,		rect.origin.y,							depth,
        rect.origin.x,							rect.origin.y + height,		depth,
        rect.origin.x + width,		rect.origin.y + height,		depth
    };
	
	glBindTexture(GL_TEXTURE_2D, _name);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    
}
- (void) drawInRect2:(CGRect)rect{
	CGFloat depth=0.0;
	GLfloat				coordinates[] = {
        0,				_maxT,
        _maxS,			_maxT,
        0,				0,
        _maxS,			0
    };
    if(IS_IPAD){
        rect.origin.x*=SCALE_WIDTH;
        rect.origin.y*=SCALE_HEIGHT;
        rect.size.width*=2;
        rect.size.height*=2;
    }
	GLfloat				vertices[] = {
        rect.origin.x,							rect.origin.y,							depth,
        rect.origin.x + rect.size.width,		rect.origin.y,							depth,
        rect.origin.x,							rect.origin.y + rect.size.height,		depth,
        rect.origin.x + rect.size.width,		rect.origin.y + rect.size.height,		depth
    };
	
	glBindTexture(GL_TEXTURE_2D, _name);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}
-(void) drawSky:(CGRect)rect depth:(CGFloat)depth
{
    
    float pitch=[World getWorld].cam->pitch;
    float sinPitch=sin(D2R(pitch));
    float sty=0;
    float ety=1.0f;
   // NSLog(@"p:%f sp:%f ",pitch,sinPitch);
    
    if(sinPitch<0){sty=-sinPitch;
        if(sty>.8)sty=.8;
    }
    else{
        ety=1-sinPitch;
        if(ety<.2)ety=.2;
    }
    
	
    if(IS_IPAD){
        rect.origin.x*=SCALE_WIDTH;
        rect.origin.y*=SCALE_HEIGHT;
        rect.size.width*=SCALE_WIDTH;
        rect.size.height*=SCALE_HEIGHT;
    }
    GLfloat				coordinates[] = {
        0,				ety*32,
        _maxS*rect.size.width/128,			ety*32,
        0,				sty*32,
        _maxS*rect.size.width/128,			sty*32
    };
	GLfloat				vertices[] = {
        rect.origin.x,							rect.origin.y,							depth,
        rect.origin.x + rect.size.width,		rect.origin.y,							depth,
        rect.origin.x,							rect.origin.y + rect.size.height,		depth,
        rect.origin.x + rect.size.width,		rect.origin.y + rect.size.height,		depth
    };
	
	glBindTexture(GL_TEXTURE_2D, _name);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    //glDrawArrays(GL_LINE_LOOP, 0, 4);
}

- (void) drawInRect:(CGRect)rect depth:(CGFloat)depth
{
	GLfloat				coordinates[] = {
							0,				_maxT,
							_maxS,			_maxT,
							0,				0,
							_maxS,			0
						};
    if(IS_IPAD){
        rect.origin.x*=SCALE_WIDTH;
        rect.origin.y*=SCALE_HEIGHT;
        rect.size.width*=SCALE_WIDTH;
        rect.size.height*=SCALE_HEIGHT;
    }
	GLfloat				vertices[] = {
							rect.origin.x,							rect.origin.y,							depth,
							rect.origin.x + rect.size.width,		rect.origin.y,							depth,
							rect.origin.x,							rect.origin.y + rect.size.height,		depth,
							rect.origin.x + rect.size.width,		rect.origin.y + rect.size.height,		depth
						};
	
	glBindTexture(GL_TEXTURE_2D, _name);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    //glDrawArrays(GL_LINE_LOOP, 0, 4);
}

@end
