//
//  SignUp.h
//  In Hotel
//
//  Created by NewageSMB on 3/23/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ServerRequests.h"
#include "Registration.h"
#import <Quickblox/Quickblox.h>


@interface SignUp : UIViewController<ServerRequestProcessDelegate,RegistrationProcess,QBActionStatusDelegate,QBChatDelegate>
{
    AppDelegate *appDelegate;
    IBOutlet UITextField *name,*email,*phone,*password,*cpassword,*access_code,*txtField;
    IBOutlet UIScrollView *signupScroll;
    NSDictionary *responseDetails;
    IBOutlet UIView *access_view,*different_user_view;
    IBOutlet UIButton *bakBtn;
    IBOutlet UIImageView *bakImg;
    IBOutlet UIView *TCView;
    IBOutlet UIWebView *tandc;
    IBOutlet UILabel *termsLbl;
}
-(IBAction)Hide:(id)sender;
-(IBAction)HideAccessView:(id)sender;
-(IBAction)saveActivationCode:(id)sender;
-(IBAction)back:(id)sender;
-(IBAction)signout:(id)sender;
-(IBAction)Terms_Conditions:(id)sender;
-(IBAction)close_Terms_Conditions:(id)sender;
@end
