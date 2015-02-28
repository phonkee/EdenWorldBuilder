//
//  Menu.h
//  prototype
//
//  Created by Ari Ronen on 10/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#ifndef Eden_Menu_h
#define Eden_Menu_h


#import "Texture2D.h"
#import "SettingsMenu.h"
#import "Input.h"
#import "ShareUtil.h"
#import "statusbar.h"
#import "SharedList.h"
#import "ShareMenu.h"
#import "Util.h"
#import "Menu_background.h"


@class ShareMenu;



class Menu{
    
public:
		CGRect rect_name;
	
	WorldNode* world_list;
	WorldNode* world_list_end;
	WorldNode* selected_world;
	BOOL activeLeftArrow;
	BOOL activeRightArrow;
	
	
	CGRect rect_loading;
	Button rect_options;
	
	Button rect_share;
	
	Button rect_loadshared;
		ShareUtil* shareutil;
	Button rect_delete;
	
	Button rect_create;
	
	Button left_arrow;
	Button right_arrow;
    
	
	statusbar* sbar;
	statusbar* fnbar;
	SettingsMenu* settings;
	SharedList* shared_list;
	ShareMenu* share_menu;
	Menu_background* menu_back;
	
	int loading;
	int loading_world_list;
	BOOL delete_mode;
	int is_sharing;
	BOOL share_mode;
	BOOL showsettings;
	BOOL showlistscreen;
    BOOL loadShared(SharedListNode* sharedNode);
    void update(float etime);
    void loadWorlds();
    void render();
    void refreshfn();
    void addWorld(WorldNode* node);
    void removeWorld(WorldNode* node);
    
    void activate();
    void deactivate();
    
    void a_genFlat(BOOL b);
    void a_deleteCancel();
    void a_deleteConfirm();
    Menu();
    
	//CGRect rcam
};
/*
@property(nonatomic,assign) int loading, is_sharing;
@property(nonatomic,assign) BOOL showsettings,showlistscreen;
@property(nonatomic,readonly) statusbar* sbar;
@property(nonatomic,readonly) WorldNode* selected_world;
@property(nonatomic,readonly) SharedList* shared_list;
@property(nonatomic,readonly) ShareUtil* shareutil;*/

#endif

