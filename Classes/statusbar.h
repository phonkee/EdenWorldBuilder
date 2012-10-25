//
//  statusbar.h
//  prototype
//
//  Created by Ari Ronen on 11/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Graphics.h"

@interface statusbar : NSObject {
	CGRect pos;
	Texture2D* text;
    NSString* message;
	float textlife;
	float font_size;
}
@property(nonatomic,assign) CGRect pos;
-(id)initWithRect:(CGRect)rect;
-(id)initWithRect:(CGRect)rect:(float)font_size;
-(void)setStatus:(NSString*)status:(float)time;
-(void)setStatus:(NSString*)status:(float)time:(UITextAlignment)align;
-(void)clear;
-(void)update:(float)etime;
-(void)render;
-(void)renderPlain;
@end
