//
//  SharedList.h
//  prototype
//
//  Created by Ari Ronen on 11/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#ifndef Eden_ShareList_h
#define Eden_ShareList_h

#import <Foundation/Foundation.h>

#import "Texture2D.h"
#import "Input.h"
#import "statusbar.h"

typedef struct{
	int value;
	NSString* name;
	NSString* file_name;
	int date;	
	CGRect namerect;
	Texture2D* nametex;
	Button blockrect;
	Texture2D* blocktex;
	CGRect daterect;
	Texture2D* datetex;
	
}SharedListNode;

@interface SharedList : NSObject{
	
	CGRect rect_header;
	
	statusbar* sort_bar;
	CGRect sbrect;
	statusbar* sbar;
	CGRect sort_left;
	CGRect sort_right;
	int page_size;
	int cur_page;
	int cur_sort;
	
	BOOL finished_dl;
    BOOL finished_preview_dl;
    BOOL finished_list_dl;
	Button rect_arrow_up;
	CGRect preview_box;
	Button rect_arrow_down;
	
	CGRect input_background;
	Button rect_cancel;
	Button sbrrect;
    Button rload_cancel;
    Button rload_go;
    Button rect_flag;
	SharedListNode* file_list;
	int list_selection;
	int num_files;
    NSMutableString* search_string;
    
    statusbar* name_bar;
    NSMutableString* displays;
    Texture2D* previewScreenshot;
    float animation_offset;
}
@property(nonatomic,assign) BOOL finished_dl,finished_preview_dl,finished_list_dl;
@property(nonatomic,readonly) statusbar* sbar;
@property(nonatomic,readonly) statusbar* sort_bar;
@property(nonatomic,readonly) int cur_sort;
-(void)update:(float)etime;
-(void)setWorldList:(NSString*)wlist;
-(void)render;
-(void)setSortStatus;
-(void)activate;
-(void)deactivate;
-(void)clearWorldList;
-(void)searchAndHide:(BOOL)nosearch;
-(void)keyTyped:(char) c;
@end

#endif
