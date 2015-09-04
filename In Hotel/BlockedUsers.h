//
//  BlockedUsers.h
//  In Hotel
//
//  Created by NewageSMB on 5/6/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ServerRequests.h"

@interface BlockedUsers : UIViewController<ServerRequestProcessDelegate>
{
    AppDelegate *appDelegate;
    NSMutableArray *blockedArr,*tempArr;
    IBOutlet UITableView *blockUserTbl;
    IBOutlet UILabel *no_users;
    int page;
}
-(IBAction)back:(id)sender;
@end
