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
                
                [World getWorld].hud->asetHome();
                               break;
            }
            case 2:
            {
                
               [World getWorld].hud->awarpHome();
                break;
            }
            default:
                break;
        }
    }else if(alertView==alertDeleteConfirm){
        switch (buttonIndex) {
            case 0:
            {
                [World getWorld].menu->a_deleteCancel();
              //  
                break;
            }
            case 1:
            {
                
                [World getWorld].menu->a_deleteConfirm();
               
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
                [World getWorld].menu->a_genFlat(TRUE);
               // [World getWorld].fm->genflat=TRUE;
                break;
            }
            case 1:
            {
                 [World getWorld].menu->a_genFlat(FALSE);
              //  [World getWorld].fm->genflat=FALSE;
                break;
            }
                
            default:
                break;
        }
        
     //   loading++;
        
        
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
