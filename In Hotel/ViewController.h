//
//  ViewController.h
//  In Hotel
//
//  Created by NewageSMB on 3/19/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Registration.h"
#import "ServerRequests.h"
#import <Quickblox/Quickblox.h>


@interface ViewController : UIViewController<UITextFieldDelegate,RegistrationProcess,ServerRequestProcessDelegate,QBActionStatusDelegate,QBChatDelegate>
{
    AppDelegate *appDelegate;
    NSDictionary *responseDetails;
    IBOutlet UITextField *username,*password,*access_code;
    IBOutlet UIScrollView *loginScroll;
    IBOutlet UIView *access_view,*sign_view,*different_user_view;
}
-(IBAction)Hide:(id)sender;
-(IBAction)login:(id)sender;
-(IBAction)signup:(id)sender;
-(IBAction)forgot:(id)sender;
-(IBAction)HideAccessView:(id)sender;
-(IBAction)saveActivationCode:(id)sender;
-(IBAction)signout:(id)sender;
@end

