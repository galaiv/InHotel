//
//  AppDelegate.m
//  In Hotel
//
//  Created by NewageSMB on 3/19/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"
#include <netinet/in.h>
#include <arpa/inet.h>
#import "SimplePinger.h"
#import "ViewController.h"
#import "Guests.h"
#import "Settings.h"
#import "MyHotel.h"
#import "Chat.h"
#import "LocalStorageService.h"
#import "Conversation.h"
#import "Chat.h"


@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize viewController,navigationController,window,ServerURL,devicetoken,tabcontroller;
@synthesize chat_img,hotel_img,guest_img,setting_img;
@synthesize drinkFrom,drinkTo,send_drinkID,drink_sent;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    sleep(2);
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController=[[ViewController alloc]initWithNibName:@"ViewController" bundle:nil];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    self.navigationController.navigationBarHidden = YES;
    
    self.window.rootViewController=self.navigationController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    tabcontroller = [[UITabBarController alloc] init];
    // URL setting
    //self.ServerURL = @"http://192.168.1.254/inhotel/";
    
    //self.ServerURL = @"http://newagesme.com/inhotel/";
    
    self.ServerURL = @"http://inhotel-app.com/";
    
    if (!hostItemToReach) {
        hostItemToReach=@"www.apple.com"; //start off somewhere familiar
    }
    [self mainItemsAfterLaunching];
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        
        
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
        {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        else
        {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
             (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
        }
    }
    
    else{
        [[UIApplication sharedApplication]
         registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeSound)];
    }
    
    // Set QuickBlox credentials (You must create application in admin.quickblox.com)
    [QBApplication sharedApplication].applicationId = 23119;
    [QBSettings setAccountKey:@"ryPTjCegSyi3Gaxy57E9"];
    [QBConnection registerServiceKey:@"PgYNyVxGKQdKWVj"];
    [QBConnection registerServiceSecret:@"bY6bx-pGbLJfSR5"];
    
    [QBApplication sharedApplication].productionEnvironmentForPushesEnabled = YES;
    
    // [QBSettings useProductionEnvironmentForPushNotifications:NO];
    
    
    
    //switch to production mode
    
#ifndef DEBUG
    
    [QBSettings setLogLevel:QBLogLevelNothing];
    
    [QBSettings useProductionEnvironmentForPushNotifications:YES];
    
#endif
    
    
    // [QBRequest createSessionWithSuccessBlock:nil errorBlock:nil];
    // [QBApplication sharedApplication].productionEnvironmentForPushesEnabled = YES;
    
#ifdef __IPHONE_8_0
    if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
#endif
    else{
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound |     UIRemoteNotificationTypeNewsstandContentAvailability;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    
    
    
    // Override point for customization after application launch.
    return YES;
}

-(void)tabFunction
{
    Chat *chat = [[Chat alloc] initWithNibName:@"Chat" bundle:Nil];
    MyHotel *myhotel = [[MyHotel alloc] initWithNibName:@"MyHotel" bundle:Nil];
    Guests *guest = [[Guests alloc] initWithNibName:@"Guests" bundle:Nil];
    Settings *setting = [[Settings alloc] initWithNibName:@"Settings" bundle:Nil];
    
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:chat];
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:myhotel];
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:guest];
    UINavigationController *nav4 = [[UINavigationController alloc] initWithRootViewController:setting];
    
    
    NSMutableArray *mainarray = [[NSMutableArray alloc] init];
    [mainarray addObject:nav1];
    [mainarray addObject:nav2];
    [mainarray addObject:nav3];
    [mainarray addObject:nav4];
    
    UIImageView *tabbarimage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, 49)];
    tabbarimage.image = [UIImage imageNamed:@"footer.png"];
    [tabcontroller.tabBar addSubview:tabbarimage];
    tabcontroller.delegate = self;
    float TabBtnwidth=(tabcontroller.tabBar.frame.size.width/4);
    float height = tabcontroller.tabBar.frame.size.height;
    float diff = TabBtnwidth / 4 ;
    float startpos = tabcontroller.tabBar.frame.origin.x;
    
    
    chat_img = [[UIImageView alloc] initWithFrame:CGRectMake(startpos + diff, height/2 - 15, 27, 36)];
    chat_img.image = [UIImage imageNamed:@"chat.png"];
    [tabbarimage addSubview:chat_img];
    
    startpos = startpos + TabBtnwidth;
    hotel_img = [[UIImageView alloc] initWithFrame:CGRectMake(startpos + diff + 10, height/2 - 15, 22, 36)];
    hotel_img.image = [UIImage imageNamed:@"hotel.png"];
    [tabbarimage addSubview:hotel_img];
    
    startpos = startpos + TabBtnwidth;
    guest_img = [[UIImageView alloc] initWithFrame:CGRectMake(startpos + diff + 20, height/2 - 15, 29, 36)];
    guest_img.image = [UIImage imageNamed:@"guests.png"];
    [tabbarimage addSubview:guest_img];
    
    startpos = startpos + TabBtnwidth;
    setting_img = [[UIImageView alloc] initWithFrame:CGRectMake(startpos + diff + 15, height/2 - 15, 34, 36)];
    setting_img.image = [UIImage imageNamed:@"settings.png"];
    [tabbarimage addSubview:setting_img];
    
    self.tabcontroller.viewControllers = mainarray;
    self.window.rootViewController = self.tabcontroller;
    
}

-(void) Logout{
   
    self.viewController=[[ViewController alloc]initWithNibName:@"ViewController" bundle:nil];
    self.navigationController = [[UINavigationController alloc]initWithRootViewController:self.viewController];
    self.window.rootViewController = self.navigationController;
    self.navigationController.navigationBarHidden=YES;
    
    if([[QBChat instance] isLoggedIn]){
        
        [QBRequest unregisterSubscriptionWithSuccessBlock:^(QBResponse *response) {
            // Unsubscribed successfully
        } errorBlock:^(QBError *error) {
            // Handle error
        }];
        [[QBChat instance] logout];
        
    }
}

-(void) clearNotifications {
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * userId = [defaults objectForKey:@"user_id"];
    NSLog(@"user id %@",userId);
    NSString *uID =[NSString stringWithFormat:@"%@",[defaults objectForKey:@"user_id"]];
    
    if (uID.length>0) {
        
//        ServerRequests *ser_req = [[ServerRequests alloc] init];
//        ser_req.server_req_proces = nil;
//        NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"clear_notification\", \"parameters\": {\"user_id\": \"%@\"},\"token\":\"\"}",userId];
//        NSLog(@"%@",postdata);
//        [ser_req sendServerRequests:postdata];
//        
//        NSLog(@"post data %@",postdata);
        
        
    }
}

#pragma mark- AppDelegate Delegates

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif


- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    //NSString *str = [NSString
    //stringWithFormat:@"Device Token=%@",deviceToken];
    self.deviceid = deviceToken;
    NSString *strWithoutSpaces  = [NSString stringWithFormat:@"%@",deviceToken];
    strWithoutSpaces = [strWithoutSpaces stringByReplacingOccurrencesOfString:@" " withString:@""];
    strWithoutSpaces = [strWithoutSpaces stringByReplacingOccurrencesOfString:@"<" withString:@""];
    self.devicetoken = [strWithoutSpaces stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    NSLog(@" device token..........%@",self.devicetoken);
}


- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    NSString *str = [NSString stringWithFormat: @"Error: %@", err];
    NSLog(@"%@",str);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Get push message
    if([userInfo objectForKey:@"aps"]){
        //NSString *message = [[userInfo objectForKey:QBMPushMessageApsKey] objectForKey:QBMPushMessageAlertKey];
        NSString *pType = [userInfo objectForKey:@"type"];
        NSString *to_id = [userInfo objectForKey:@"to_id"];
        NSString *user_Type = [userInfo objectForKey:@"user_Type"];
        int recp_quickblox_id = (int)[[userInfo objectForKey:@"recp_quickblox_id"] integerValue];
        
        if([pType isEqualToString:@"accept_reject_drink"]){
            [[NSNotificationCenter defaultCenter]postNotificationName:@"DRINK" object:nil];
        }
        else{
            [self clearNotifications];
            NSDictionary *dict = [[userInfo objectForKey:@"aps"] mutableCopy];
            NSLog(@"%@",dict);
            UIApplicationState state = [application applicationState];
            if (state == UIApplicationStateActive)
            {
                if(userInfo != Nil)
                {
                    //NSString *message = [dict objectForKey:@"alert"];
                    if([userInfo objectForKey:@"type"]){
                        if([userInfo objectForKey:@"type"] != [NSNull null] && [[userInfo objectForKey:@"type"] isEqualToString:@"accept_reject_drink"]){
                            
                            [[NSNotificationCenter defaultCenter]postNotificationName:@"DRINK" object:nil];
                            
                        }
                        
                    }
                    
                }
            }
        }
        if ([to_id isEqualToString:@""]) {
            Chat *chat =  [[Chat alloc]initWithNibName:@"Chat" bundle:nil];
            [self.window.rootViewController presentViewController:chat animated:YES completion:nil];
        }else{
            Conversation *chat =  [[Conversation alloc]initWithNibName:@"Conversation" bundle:nil];
            chat.to_id = to_id;
            chat.user_Type = user_Type;
            chat.recp_quickblox_id = recp_quickblox_id;
            [self.window.rootViewController presentViewController:chat animated:YES completion:nil];
        }
    }
}




- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[QBChat instance] loginWithUser:[LocalStorageService shared].currentUser];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [self clearNotifications];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark- Reachability Delegates



- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    
    if(curReach == hostReach)
    {
        
        NetworkStatus netStatus = [curReach currentReachabilityStatus];
        
        switch (netStatus)
        
        {
            case NotReachable:
            {
                NSLog(@"A gateway to the host server is down.");
                
                self.networkAvailable=NO;
                break;
                
            }
            case ReachableViaWiFi:
            {
                NSLog(@"A gateway to the host server is working via WIFI.");
                self.networkAvailable=YES;
                break;
                
            }
            case ReachableViaWWAN:
            {
                NSLog(@"A gateway to the host server is working via WWAN.");
                self.networkAvailable=YES;
                break;
                
            }
        }
    }
    if(self.networkAvailable)
    {
        
    }
    else{
        
        
    }    
    
}


- (void) displayNetworkAvailability:(id)sender{
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Please Connect To Internet!!!"  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}


- (void) reachabilityChanged: (NSNotification* )note
{
    /* This method is called every time there is a change */
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    
    
    
    /* Now update the user interface visually
     this might be replaced with some logic and commands of some sort
     
     */
    /* Check Ping again */
    [self simplePingThis:hostItemToReach];
    
    [self updateInterfaceWithReachability: curReach];
}

- (void) simplePingThis:(NSString*) addressToPing
{
    NSLog(@"Going to Ping");
    // dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    
    backgroundQueue = dispatch_queue_create("com.elbsolutions.simpleping", NULL);
    
    dispatch_async(backgroundQueue, ^{
        
        /* Add the SImplePinger app into here */
        
        
        SimplePinger *mainObj = [[SimplePinger alloc] init];
        //mainObj.stopOnAnyError = true;
        assert(mainObj != nil);
        
        //[mainObj runWithHostName:[NSString stringWithUTF8String:argv[1]]];
        [mainObj runWithHostName:addressToPing];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            
            NSString *msg = @"";
            if ([mainObj reachedIpAddress]) {
                msg = [NSString stringWithFormat:@"Successful Ping of %@",addressToPing,nil];;
                
            } else {
                
                msg = [NSString stringWithFormat:@"No Response from %@",addressToPing,nil];;
                //
                //                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Please Connect To Internet!!!"  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                //                [alert show];
                
            }
            
            NSLog(@"%@",msg);
            
            
        });
    });
    
    
}

-(void) mainItemsAfterLaunching
{
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
    [self simplePingThis:hostItemToReach];
    
    
    struct sockaddr_in callAddress;
    callAddress.sin_len = sizeof(callAddress);
    callAddress.sin_family = AF_INET;
    callAddress.sin_port = htons(24);
    callAddress.sin_addr.s_addr = inet_addr([hostItemToReach UTF8String]);
    
    hostReach = [Reachability reachabilityWithAddress:&callAddress];
    
    
    [hostReach startNotifier];
    [self updateInterfaceWithReachability: hostReach];
    
    /* internetReach is an instance of Reachability */
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    [self updateInterfaceWithReachability: internetReach];
    
    /* wifiReach is an instance of Reachability */
    wifiReach = [Reachability reachabilityForLocalWiFi];
    [wifiReach startNotifier];
    [self updateInterfaceWithReachability: wifiReach];
    
    
}


@end
