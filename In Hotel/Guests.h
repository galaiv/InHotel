//
//  Guests.h
//  In Hotel
//
//  Created by NewageSMB on 3/25/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ServerRequests.h"

@interface Guests : UIViewController<ServerRequestProcessDelegate>
{
    AppDelegate *appDelegate;
    NSMutableArray *guestArr,*tempArr;
    IBOutlet UITableView *guestTbl;
    IBOutlet UILabel *no_guest;
    NSInteger page;
    IBOutlet UIView *access_view,*profileView;
    IBOutlet UITextField *access_code;
}
-(IBAction)Hide:(id)sender;
-(IBAction)ShowAccessView:(id)sender;
-(IBAction)saveActivationCode:(id)sender;
-(IBAction)complete_profile:(id)sender;
-(IBAction)closeProfileView:(id)sender;
@end
