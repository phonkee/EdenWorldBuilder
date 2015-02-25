//
//  Menu_background.h
//  prototype
//
//  Created by Ari Ronen on 1/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


class Menu_background {
    
public:
    Menu_background();
    void update(float etime);
    void render();
private:
CGRect clouds[3];
};

