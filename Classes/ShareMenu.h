//
//  ShareMenu.h
//  prototype
//
//  Created by Ari Ronen on 11/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#ifndef Eden_ShareMenu_h
#define Eden_ShareMenu_h

#import <Foundation/Foundation.h>
#import "World.h"
#import "Menu.h"
#import "Util.h"

@interface ShareMenu : NSObject {
	
	WorldNode* node;
	CGRect input_background;
	Button rect_cancel;
	Button rect_submit;
  
	CGRect share_explain_rect;
	statusbar* share_explain_lbl;
	statusbar* label_bar;
	statusbar* name_bar;
      NSMutableString* displays;
	NSMutableString* name;
 
	//BOOL starto;
}
- (void) trimDisplay;
-(void)beginShare:(WorldNode*)world;
-(void)endShare:(BOOL)cancel;
-(void)activate;
-(void)deactivate;
-(void)update:(float)etime;
-(void)render;
-(void) keyTyped:(char)c;
@end


#endif