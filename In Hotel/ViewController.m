//
//  ViewController.m
//  In Hotel
//
//  Created by NewageSMB on 3/19/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD.h"
#import "SignUp.h"
#import "JSON.h"
#import <CoreGraphics/CoreGraphics.h>
#import "LocalStorageService.h"
#import "Forgot.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    username.text = @"";
    password.text = @"";
    [username setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [password setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [access_code setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    NSString *USER = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"username"]];
    NSString *PASS = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"password"]];
    if (!([[NSUserDefaults standardUserDefaults]objectForKey:@"username"] == nil || [[NSUserDefaults standardUserDefaults]objectForKey:@"password"] == nil)) {
        [self startLoader];
        Registration *reg = [[Registration alloc] init];
        reg.reg_proces = self;
        [reg completeLogin:USER paswd:PASS devceTckn:@"" device_flag:@"N"];
    }

    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    username.text = @"";
    password.text = @"";
}


#pragma mark -TextField Delegates


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if ([textField isEqual:username]) {
        [loginScroll setContentOffset:CGPointMake(0,170) animated:YES];
    }
    
    else  if ([textField isEqual:password]) {
        [loginScroll setContentOffset:CGPointMake(0,170) animated:YES];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if ([textField isEqual:username]) {
        [password becomeFirstResponder];
        [loginScroll setContentOffset:CGPointMake(0,170) animated:YES];
    }
    
    if ([textField isEqual:password]) {
        [self Login];
        [username resignFirstResponder];
        [password resignFirstResponder];
        [loginScroll setContentOffset:CGPointMake(0,0) animated:YES];
    }
    
    return YES;
}

#pragma mark -MBHud Methods

-(void)startLoader
{
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText=@"Authenticating ...";
}
-(void)stopLoader
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

#pragma mark -Other Methods

-(IBAction)login:(id)sender{
    [self Login];
}

-(void)Login{
    
    [username resignFirstResponder];
    [password resignFirstResponder];
    
    
    if ([[username.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Message" message:@"Please enter your email" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
        [username becomeFirstResponder];
        [loginScroll setContentOffset:CGPointMake(0,170) animated:YES];
        
    }
    else if ([[password.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0){
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Message" message:@"Please enter your password" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
        [password becomeFirstResponder];
        [loginScroll setContentOffset:CGPointMake(0,170) animated:YES];
    }
    else{
        
        [self startLoader];
        Registration *reg = [[Registration alloc] init];
        reg.reg_proces = self;
        [reg completeLogin:username.text paswd:password.text devceTckn:appDelegate.devicetoken device_flag:@"Y"];
        
    }
}

-(void) RegistrationProcessFinish:(NSString *) userdetails{
    
    
    responseDetails = [userdetails JSONValue];
    
    NSLog(@"userDet =-=======%@",responseDetails);
    
    if ([[responseDetails objectForKey:@"status"] isEqualToString:@"true"]) {
        
        NSString *userid = [[responseDetails objectForKey:@"details"] objectForKey:@"user_id"];
        NSString *username_pass = [[responseDetails objectForKey:@"details"] objectForKey:@"email_address"];
        if ([password.text isEqualToString:@""]) {
            password.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"password"];
        }
        NSString *password_pass = password.text;
        //NSString *full_name = [NSString stringWithFormat:@"%@ %@",[[responseDetails objectForKey:@"details"] objectForKey:@"first_name"],[[responseDetails objectForKey:@"details"] objectForKey:@"last_name"]];
        NSString *full_name = [[responseDetails objectForKey:@"details"] objectForKey:@"first_name"];
        NSString *email = [[responseDetails objectForKey:@"details"] objectForKey:@"email_address"];
        NSString *mem_type = [[responseDetails objectForKey:@"details"] objectForKey:@"member_type"];
        NSString *activation_code = [responseDetails objectForKey:@"activation_code"];
        NSString *activation_status = [responseDetails objectForKey:@"activation_status"];
        NSString *enter_save = [[responseDetails objectForKey:@"details"] objectForKey:@"enter_to_send"];
        NSString *user_quickblox = [[responseDetails objectForKey:@"details"] objectForKey:@"quickblox_id"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:userid forKey:@"user_id"];
        [defaults setObject:username_pass forKey:@"username"];
        [defaults setObject:password_pass forKey:@"password"];
        [defaults setObject:full_name forKey:@"fullname"];
        [defaults setObject:email forKey:@"email"];
        [defaults setObject:mem_type forKey:@"mem_type"];
        //[defaults setObject:activation_code forKey:@"activation_code"];
        [defaults setObject:activation_status forKey:@"activation_status"];
        [defaults setObject:enter_save forKey:@"enter_save"];
        [defaults setObject:user_quickblox forKey:@"user_quickblox"];
        
        [defaults synchronize];
        
        if(([[responseDetails objectForKey:@"details"] objectForKey:@"quickblox_id"] == [NSNull null] || [[[responseDetails objectForKey:@"details"] objectForKey:@"quickblox_id"] isEqualToString:@""])){
            
            
            // Create session request
            [QBRequest createSessionWithSuccessBlock:^(QBResponse *response, QBASession *session) {
                
                
                //Your Quickblox session was created successfully
                
                QBUUser *user = [QBUUser user];
                user.login = [NSString stringWithFormat:@"inhotel_%@",userid];
                user.password = [NSString stringWithFormat:@"inhotel_%@123",userid];
                
                // Registration/sign up of User
                [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user1) {
                    
                    [QBRequest registerSubscriptionForDeviceToken:appDelegate.deviceid successBlock:^(QBResponse *response, NSArray *subscriptions) {
                        
                        
                        
                    } errorBlock:^(QBError *error) {
                        
                        //                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", "")
                        //
                        //                                                                                    message:[error.reasons description]
                        //
                        //                                                                                   delegate:nil
                        //
                        //                                                                          cancelButtonTitle:NSLocalizedString(@"OK", "")
                        //
                        //                                                                          otherButtonTitles:nil];
                        //
                        //                                    [alert show];
                        
                    }];
                    
                    // Sign up was successful
                    // Sign In to QuickBlox Chat
                    QBUUser *currentUser = [QBUUser user];
                    currentUser.ID = session.userID; // your current user's ID
                    currentUser.password = [NSString stringWithFormat:@"inhotel_%@123",password_pass]; // your current user's password
                    NSLog(@"currentUser.ID: %lu", (unsigned long)currentUser.ID);
                    
                    ServerRequests *ser_req = [[ServerRequests alloc] init];
                    //ser_req.server_req_proces = self;
                    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"updateQuickBloxId\",\"parameters\": {\"quickblox_id\": \"%lu\",\"user_id\": \"%@\"},\"token\":\"\"}",(unsigned long)user1.ID,userid];
                    NSLog(@"%@",postdata);
                    [ser_req sendServerRequests:postdata];
                    //[self startLoader];
                    
                    // set Chat delegate
                    [QBChat instance].delegate = self;
                    [[LocalStorageService shared] setUsername:userid];
                    [[LocalStorageService shared] setCurrentUser:currentUser];
                    [self stopLoader];
                } errorBlock:^(QBResponse *response) {
                    // error handling
                    NSLog(@"error: %@", response.error);
                }];
                
            } errorBlock:^(QBResponse *response) {                            // Handle error here
                
                
                
                //Handle error here
                NSLog(@"error: %@", response.error);
            }];
            
        }else{
            
            QBSessionParameters *parameters = [QBSessionParameters new];

            parameters.userLogin = [NSString stringWithFormat:@"inhotel_%@",userid];
            parameters.userPassword = [NSString stringWithFormat:@"inhotel_%@123",userid];
            
            [QBRequest createSessionWithExtendedParameters:parameters successBlock:^(QBResponse *response, QBASession *session) {
                
                NSLog(@"%@",appDelegate.deviceid);
                [QBRequest registerSubscriptionForDeviceToken:appDelegate.deviceid successBlock:^(QBResponse *response, NSArray *subscriptions) {
                    
                    
                    
                } errorBlock:^(QBError *error) {
                    
                    //                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", "")
                    //
                    //                                                                                    message:[error.reasons description]
                    //
                    //                                                                                   delegate:nil
                    //
                    //                                                                          cancelButtonTitle:NSLocalizedString(@"OK", "")
                    //
                    //                                                                          otherButtonTitles:nil];
                    //
                    //                                    [alert show];
                    
                }];
                
                // Sign In to QuickBlox Chat
                QBUUser *currentUser = [QBUUser user];
                currentUser.ID = session.userID; // your current user's ID
                currentUser.password = [NSString stringWithFormat:@"inhotel_%@123",userid]; // your current user's password
                
                ServerRequests *ser_req = [[ServerRequests alloc] init];
                //ser_req.server_req_proces = self;
                NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"updateQuickBloxId\",\"parameters\": {\"quickblox_id\": \"%lu\",\"user_id\": \"%@\"},\"token\":\"\"}",(unsigned long)currentUser.ID,userid];
                NSLog(@"%@",postdata);
                [ser_req sendServerRequests:postdata];
                
                // set Chat delegate
                [QBChat instance].delegate = self;
                [[LocalStorageService shared] setUsername:[NSString stringWithFormat:@"inhotel_%@",userid]];
                [[LocalStorageService shared] setCurrentUser:currentUser];
                
                //                            if([tempdict objectForKey:@"quickblox_id"] != [NSNull null] || ![[tempdict objectForKey:@"quickblox_id"] isEqualToString:@""]){
                
                [[QBChat instance] loginWithUser:[LocalStorageService shared].currentUser];
                [self stopLoader];
            
            }errorBlock:^(QBResponse *response) {
                // error handling
                NSLog(@"error: %@", response.error);
            }];
            
        }
        
    
        if ([[responseDetails objectForKey:@"activation_status"] isEqualToString:@"YES"]) {            
            [appDelegate tabFunction];
            appDelegate.tabcontroller.selectedIndex = 2;
        }else{
            NSLog(@"-----%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"activation_code"]);
            if (!([[NSUserDefaults standardUserDefaults]objectForKey:@"activation_code"] == nil || [[[NSUserDefaults standardUserDefaults]objectForKey:@"activation_code"] isEqualToString:@""])) {
                access_code.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"activation_code"];
                [self saveActivationCode:nil];
            }else{
                loginScroll.hidden = YES;
                sign_view.hidden = YES;
                access_code.text = @"";
                access_view.hidden = NO;
                different_user_view.hidden = NO;
            }
        }
        
       
    }
    else {
        [self stopLoader];
        NSString *MSG;
        username.text = @"";
        password.text = @"";
        if ([responseDetails count] == 0) {
            MSG = @"Some server error occured, please try later";
        }else{
            MSG = [responseDetails objectForKey:@"message"];
        }
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Message" message:MSG delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}
-(IBAction)signup:(id)sender{
    SignUp *signup =  [[SignUp alloc]initWithNibName:@"SignUp" bundle:nil];
    [self.navigationController pushViewController:signup animated:YES];
}
-(IBAction)forgot:(id)sender{
    Forgot *forgot =  [[Forgot alloc]initWithNibName:@"Forgot" bundle:nil];
    [self.navigationController pushViewController:forgot animated:YES];
}
-(IBAction)signout:(id)sender{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    ServerRequests *ser_req = [[ServerRequests alloc] init];
    //ser_req.server_req_proces = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"logout\", \"parameters\": {\"user_id\": \"%@\"},\"token\":\"\"}",[defaults objectForKey:@"user_id"]];
    NSLog(@"%@",postdata);
    [ser_req sendServerRequests:postdata];
    
    
    [defaults setObject:nil forKey:@"user_id"];
    [defaults setObject:nil forKey:@"username"];
    [defaults setObject:nil forKey:@"password"];
    [defaults setObject:nil forKey:@"fullname"];
    [defaults setObject:nil forKey:@"email"];
    [defaults setObject:nil forKey:@"mem_type"];
    [defaults setObject:nil forKey:@"activation_code"];
    [defaults setObject:@"NO" forKey:@"activation_status"];
    [defaults setObject:nil forKey:@"user_quickblox"];
    
    [defaults synchronize];
    [appDelegate Logout];
}
-(IBAction)Hide:(id)sender{
    
    [username resignFirstResponder];
    [password resignFirstResponder];
    [access_code resignFirstResponder];
    [loginScroll setContentOffset:CGPointMake(0,0) animated:YES];
}
-(IBAction)HideAccessView:(id)sender{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"activation_code"];
    [defaults synchronize];
    [access_code resignFirstResponder];
    access_view.hidden = YES;
    [appDelegate tabFunction];
    appDelegate.tabcontroller.selectedIndex = 3;
}
-(IBAction)saveActivationCode:(id)sender{
    if ([[access_code.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Please enter Access code" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        NSString *user_id = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]];
        ServerRequests *ser_req = [[ServerRequests alloc] init];
        ser_req.server_req_proces = self;
        NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"checkActivationCodeExpires\", \"parameters\": {\"activation_code\": \"%@\",\"user_id\": \"%@\"},\"token\":\"\"}", access_code.text,user_id];
        NSLog(@"%@",postdata);
        [ser_req sendServerRequests:postdata];
    }
}
-(void) ServerRequestProcessFinish:(NSString *) serverResponse{
    if([[[serverResponse JSONValue] objectForKey:@"activation_status"] isEqualToString:@"Y"]){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[[serverResponse JSONValue] objectForKey:@"activation_status"] forKey:@"activation_status"];
        [defaults setObject:access_code.text forKey:@"activation_code"];
        [defaults synchronize];
        [access_code resignFirstResponder];
        access_view.hidden = YES;
        [appDelegate tabFunction];
        appDelegate.tabcontroller.selectedIndex = 2;
    }else{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:nil forKey:@"activation_code"];
        [defaults synchronize];
        access_code.text = @"";
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Message" message:[[serverResponse JSONValue] objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}


-(void)quickblox{
    
    // Create session with user
    NSString *userLogin = @"chatUser1";
    NSString *userPassword = @"chatUser1pass";
    
    QBSessionParameters *parameters = [QBSessionParameters new];
    parameters.userLogin = userLogin;
    parameters.userPassword = userPassword;
    [QBRequest createSessionWithExtendedParameters:parameters successBlock:^(QBResponse *response, QBASession *session) {
        // Sign In to QuickBlox Chat
        QBUUser *currentUser = [QBUUser user];
        currentUser.ID = session.userID; // your current user's ID
        currentUser.password = userPassword; // your current user's password
        appDelegate.loggeduser = currentUser;
        // set Chat delegate
        [QBChat instance].delegate = self;
        
        // login to Chat
        [[QBChat instance] loginWithUser:currentUser];
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        NSLog(@"error: %@", response.error);
    }];
}

#pragma mark QBChatDelegate
// Chat delegate
-(void) chatDidLogin{
    // You have successfully signed in to QuickBlox Chat
}

- (void)chatDidNotLogin{
    
}


@end
