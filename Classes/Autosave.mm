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

/* Touch input serves as the trigger for autosaving in Eden. Whenever there is a touch, "autosavetrigger" will run, keeping count of how many touches there have been since the last autosave (with the touchcounter variable). Each time touchcounter reaches the number of touches defined in constants.h as "AUTOSAVE_TOUCHES", an autosave occurs and touchcount is reset. If "delayAutoSave" is run,
 */

int touchcounter=AUTOSAVE_TOUCHES;
bool tracktouches=false;

void autosavetracktouches(bool inworld){
    tracktouches=inworld;
    touchcounter=AUTOSAVE_TOUCHES;
    printg("trackmode: %d\n",tracktouches);
}

void autosavetrigger() {
    if (tracktouches==false) {
    } else {
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



