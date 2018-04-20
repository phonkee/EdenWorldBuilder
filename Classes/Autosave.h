//
//  Autosave.h
//  Eden
//
//  Created by Ryan Kontos on 4/20/18.
//
//

#ifndef Eden_Autosave_h
#define Eden_Autosave_h
#import "statusbar.h"

void autosavetrigger(); // Responds to touch events and decides to save or not.
void autoSave(); //  Does the save.
void delayAutoSave(); // Calling this will set the touches required to autosave to 25 if it is currently less than that.
void autosavetracktouches(bool inworld);

#endif

