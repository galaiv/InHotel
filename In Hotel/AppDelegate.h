//
//  AppDelegate.h
//  In Hotel
//
//  Created by NewageSMB on 3/19/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Quickblox/Quickblox.h>

@class ViewController;
@class Reachability;
@class SessionRequest;

@interface AppDelegate : UIResponder <UIApplicationDelegate,UITabBarControllerDelegate>
{
    Reachability* hostReach;
    Reachability* internetReach;
    Reachability* wifiReach;
    
    NSString *hostItemToReach;
    dispatch_queue_t backgroundQueue;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) IBOutlet UINavigationController *navigationController;
@property (strong,nonatomic) IBOutlet UIViewController *viewController;
@property (nonatomic, retain) NSData *deviceid;
@property (nonatomic, strong) NSString *ServerURL, *devicetoken,*first_register;
@property (strong, nonatomic) UITabBarController *tabcontroller;
@property (strong, nonatomic) UIImageView *chat_img,*hotel_img,*guest_img,*setting_img;

//Drin send
@property (strong, nonatomic) NSString *drinkFrom,*drinkTo,*send_drinkID,*drink_sent;

// for Reachability
@property (nonatomic,assign)BOOL networkAvailable;

//QUICKBLOXCAHT....
@property(nonatomic, retain) QBUUser *loggeduser;
@property NSInteger recipientID;
@property (nonatomic,assign) BOOL chatpage;
@property NSInteger unreadmsgcount;


-(void)updateInterfaceWithReachability: (Reachability*) curReach;
-(void)displayNetworkAvailability:(id)sender;
-(void)tabFunction;
-(void)Logout;
@end