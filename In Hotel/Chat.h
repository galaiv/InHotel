//
//  Chat.h
//  In Hotel
//
//  Created by NewageSMB on 4/8/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ServerRequests.h"
#import <Quickblox/Quickblox.h>

@interface Chat : UIViewController<ServerRequestProcessDelegate,QBActionStatusDelegate,QBChatDelegate>
{
    AppDelegate *appDelegate;
    IBOutlet UITableView *messageTbl;
    IBOutlet UILabel *no_msgLbl;
    NSMutableArray *messageArr,*tempArr;
    IBOutlet UIView *access_view;
    IBOutlet UITextField *access_code;
    BOOL responsegot;
    BOOL onlinestatusgot;
    NSMutableArray *newarray;
    NSArray *chatids;
    NSMutableArray *onorofflineusers;
     NSInteger dialogcount;
}
@property (nonatomic, strong) NSMutableArray *maindialogs;
-(IBAction)Hide:(id)sender;
-(IBAction)ShowAccessView:(id)sender;
-(IBAction)saveActivationCode:(id)sender;
@end
