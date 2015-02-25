//
//  Joystick.h
//  prototype
//
//  Created by Ari Ronen on 12/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


class Joystick{
    public:
    Joystick();
    BOOL update(float etime);
    void render();
};
