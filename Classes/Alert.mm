//
//  Alert.m
//  Eden
//
//  Created by Ari Ronen on 2/26/15.
//
//

#import <Foundation/Foundation.h>
#import "World.h"

static UIAlertView *alertWarpHome;
UIAlertView *alertDeleteConfirm;
UIAlertView *alertWorldType;
static UIAlertView *alertReportContent;
static UIAlertView *alertReportConfirm;

@interface PAlert : NSObject <UIAlertViewDelegate> {
    
    
}
@end




@implementation PAlert
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if(alertView==alertWarpHome){
        switch (buttonIndex) {
            case 0:
            {
                //[sbar setStatus:@"" :2];
                break;
            }
            case 1:
            {
                
                World::getWorld->hud->asetHome();
                               break;
            }
            case 2:
            {
                
               World::getWorld->hud->awarpHome();
                break;
            }
            default:
                break;
        }
    }else if(alertView==alertDeleteConfirm){
        switch (buttonIndex) {
            case 0:
            {
                World::getWorld->menu->a_deleteCancel();
              //  
                break;
            }
            case 1:
            {
                
                World::getWorld->menu->a_deleteConfirm();
               
                break;
            }
                
            default:
                break;
        }
    }else if(alertView==alertWorldType){
        switch (buttonIndex) {
                NSLog(@"button idx %d",(int)buttonIndex);
            case 0:
            {
                World::getWorld->menu->a_genFlat(TRUE);
               // World::getWorld->fm->genflat=TRUE;
                break;
            }
            case 1:
            {
                 World::getWorld->menu->a_genFlat(FALSE);
              //  World::getWorld->fm->genflat=FALSE;
                break;
            }
                
            default:
                break;
        }
        
     //   loading++;
        
        
    }else if(alertView==alertReportContent){
        switch (buttonIndex) {
            case 0:
            {
                
                break;
            }
            case 1:
            {
                World::getWorld->menu->shared_list->alertCallback();
                break;
            }
                
            default:
                break;
        }
    }

    
}

@end


static PAlert* pa;

void alert_init(){
    pa=[[PAlert alloc] init];
    alertWarpHome= [[UIAlertView alloc]
                    initWithTitle:@"Home Menu"
                    message:@"\n"                                                                              delegate:pa
                    cancelButtonTitle:@"Cancel"                                                                           otherButtonTitles:@"Set Current Location as Home", @"Warp home" , nil];
    
    alertDeleteConfirm= [[UIAlertView alloc]
                         initWithTitle:@"Confirm Delete"
                         message:@""                                                                              delegate:pa
                         cancelButtonTitle:@"Cancel"                                                                           otherButtonTitles:@"Delete", nil, nil];
    alertWorldType= [[UIAlertView alloc]
                     initWithTitle:@"Pick world type"
                     message:@"\n"                                                                              delegate:pa
                     cancelButtonTitle:nil                                                                          otherButtonTitles:@"Flat", @"Normal", nil];
    
    alertReportContent= [[UIAlertView alloc]
                         initWithTitle:@"Flag Content"
                         message:@"Report this world for offensive or innappropriate content?\n"                                                                              delegate:pa
                         cancelButtonTitle:@"Cancel"                                                                           otherButtonTitles:@"Report" , nil];
    
    alertReportConfirm= [[UIAlertView alloc]
                         initWithTitle:@"Report sent, thanks\n"
                         message:@""                                                                              delegate:pa
                         cancelButtonTitle:@"Ok"                                                                          otherButtonTitles:nil , nil];
    

}

void showAlertWarpHome(){
    
    [alertWarpHome show];
}
void showAlertDeleteConfirm(NSString* name){
    [alertDeleteConfirm setMessage: name ];
    [alertDeleteConfirm show];
}
void showAlertWorldType(){
    [alertWorldType show];
}
void showAlertReport(){
    [alertReportContent show];
}
void showAlertReportConfirm(){
    [alertReportConfirm show];
}