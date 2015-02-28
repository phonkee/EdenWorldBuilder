//
//  Joystick.h
//  prototype
//
//  Created by Ari Ronen on 12/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#ifndef Eden_Joystick_h
#define Eden_Joystick_h




class Joystick{
    public:
    Joystick();
    BOOL update(float etime);
    void render();
};


#endif