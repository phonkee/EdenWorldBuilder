//
//  Autosave.mm
//  Eden
//
//  Created by Ryan Kontos on 4/20/18.
//
//


#import "Autosave.h"
#import "World.h"
#import "Hud.h"


int touchcounter=AUTOSAVE_TOUCHES;
bool tracktouches=false;
bool AUTOSAVE_ON;

void autosavetracktouches(bool inworld){
    tracktouches=inworld;
    touchcounter=AUTOSAVE_TOUCHES;
    printg("trackmode: %d\n",tracktouches);
}

void autosavetrigger() {
    
    if(AUTOSAVE_ON==true){
        return;
    }
        NSLog(@"Autosave is triggered and on");
        if (tracktouches==true) {
            printg("touchcount: %d\n",touchcounter);
            touchcounter--;
            if(touchcounter==0){
                touchcounter=AUTOSAVE_TOUCHES;
                saveWorld();
            }
        }
}

void delayAutoSave(){
    
    if (touchcounter<AUTOSAVE_TOUCHES_EXTENDED) {
        NSLog(@"autosave safety delay activated");
        if (touchcounter<5){
            NSLog(@"Would have been close!");
        }
        touchcounter = AUTOSAVE_TOUCHES_EXTENDED;
    } else {
        NSLog(@"Delay not needed");
    }
}
