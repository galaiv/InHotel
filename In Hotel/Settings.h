//
//  Settings.h
//  In Hotel
//
//  Created by NewageSMB on 3/26/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ServerRequests.h"

@interface Settings : UIViewController<ServerRequestProcessDelegate>
{
    AppDelegate *appDelegate;
    IBOutlet UILabel *last_time;
    IBOutlet UIView *change_view,*access_view,*profileView;
    IBOutlet UITextField *new_pass,*cpass,*old_pass,*access_code;
    IBOutlet UISwitch *chat_switch,*enter_switch,*room_show_switch;
    IBOutlet UIScrollView *mscroll;
}
-(IBAction)showChangePassword:(id)sender;
-(IBAction)change_password:(id)sender;
-(IBAction)blocked_users:(id)sender;
-(IBAction)close_password:(id)sender;
-(IBAction)signout:(id)sender;
-(IBAction)HideAccessView:(id)sender;
-(IBAction)ShowAccessView:(id)sender;
-(IBAction)saveActivationCode:(id)sender;
-(IBAction)saveStatus:(id)sender;
-(IBAction)showAccountDetails:(id)sender;
-(IBAction)complete_profile:(id)sender;
-(IBAction)closeProfileView:(id)sender;
@end
