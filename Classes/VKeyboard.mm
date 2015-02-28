//
//  VKeyboard.m
//  Eden
//
//  Created by Ari Ronen on 2/28/15.
//
//

#import <Foundation/Foundation.h>
#import "EAGLView.h"
#import "World.h"
UITextField* world_name_field;
UITextField* search_field;


@interface PText : NSObject <UITextFieldDelegate> {
    
    
}
@end

@implementation PText

static int caller=-1;
- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
   if([string length]>1)return FALSE;
    
    char c=' ';
    if([string length]==0){
        c=-1;
       
    }else{
       c = [string characterAtIndex:0];
    }
    if(caller==0){
        [World::getWorld->menu->share_menu keyTyped:c];
    }else if(caller==1){
        [World::getWorld->menu->shared_list keyTyped:c];
    }
    
    return FALSE;
}
- (void)textFieldDidEndEditing:(UITextField*)textField
{
    NSLog(@"sup2");
    
    //NSLog(@"%@",[textField text]);
    //[textField endEditing:YES];
    //[textField removeFromSuperview];
}

- (BOOL)textFieldShouldReturn:(UITextField*)texField
{
    NSLog(@"sup");
    
    if(caller==0){
    [World::getWorld->menu->share_menu endShare:FALSE];
    }else if(caller==1){
        [World::getWorld->menu->shared_list searchAndHide:FALSE];
        }
    
    // end editing
    //[texField resignFirstResponder];
    return YES;
}


@end

PText* pptext;
extern EAGLView* G_EAGL_VIEW;

void vkeyboard_init(){
    pptext=[[PText alloc] init];
    world_name_field=[[UITextField alloc] initWithFrame:
                      CGRectMake(0, 0, 1, 1)];
    world_name_field.keyboardType=UIKeyboardTypeAlphabet;
    world_name_field.returnKeyType=UIReturnKeyDone;
    world_name_field.hidden=TRUE;
    world_name_field.borderStyle = UITextBorderStyleNone;
    world_name_field.autocorrectionType = UITextAutocorrectionTypeNo;
    
    
    [G_EAGL_VIEW insertSubview: world_name_field atIndex:0];
    [world_name_field setDelegate:pptext];
    
}
void vkeyboard_begin(int tcaller){
    caller=tcaller;
    [world_name_field becomeFirstResponder];
    world_name_field.text=@"a";
}

void vkeyboard_end(int tcaller){
    caller=-1;
    [world_name_field resignFirstResponder];
}
