//
//  MyHotel.h
//  In Hotel
//
//  Created by NewageSMB on 3/31/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ServerRequests.h"

@interface MyHotel : UIViewController<UITextViewDelegate,ServerRequestProcessDelegate>
{
    AppDelegate *appDelegate;
    IBOutlet UITextView *exp,*hotel_desc,*hotel_addr;
    IBOutlet UILabel *hotel_name,*hotel_phone,*hotel_website,*hotel_email;
    IBOutlet UIScrollView *expScrl;
    IBOutlet UIView *access_view;
    IBOutlet UITextField *access_code;
    IBOutlet UIScrollView *mscroll;
}
-(IBAction)ShowAccessView:(id)sender;
-(IBAction)saveActivationCode:(id)sender;
-(IBAction)hide:(id)sender;
-(IBAction)shareExperiance:(id)sender;
-(IBAction)Hide:(id)sender;
@end
