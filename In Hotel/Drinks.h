//
//  Drinks.h
//  In Hotel
//
//  Created by NewageSMB on 4/18/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ServerRequests.h"
#import "Registration.h"

@interface Drinks : UIViewController<ServerRequestProcessDelegate,RegistrationProcess>
{
    AppDelegate *appDelegate;
    IBOutlet UITableView *drinksTbl;
    NSMutableArray *drinksArr,*tempArr;
    NSDictionary *responseDetails;
}
@property (retain, nonatomic) NSString *to_id;
-(IBAction)back:(id)sender;
@end
