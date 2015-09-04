//
//  Forgot.h
//  In Hotel
//
//  Created by NewageSMB on 6/3/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ServerRequests.h"

@interface Forgot : UIViewController<ServerRequestProcessDelegate>
{
    AppDelegate *appDelegate;
    IBOutlet UITextField *username;
    IBOutlet UIScrollView *loginScroll;
    
}
-(IBAction)Hide:(id)sender;
-(IBAction)forgot_password:(id)sender;
-(IBAction)back:(id)sender;
@end
