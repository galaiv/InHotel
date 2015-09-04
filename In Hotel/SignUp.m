//
//  SignUp.m
//  In Hotel
//
//  Created by NewageSMB on 3/23/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import "SignUp.h"
#import "MBProgressHUD.h"
#import "JSON.h"
#import "JDFTooltips.h"
#import "Account.h"
#import "LocalStorageService.h"

@interface SignUp ()
// Tooltips
@property (nonatomic, strong) JDFSequentialTooltipManager *tooltipManager;

@end

@implementation SignUp

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [name setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [email setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [phone setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [password setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [cpassword setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -MBHud Methods

-(void)startLoader
{
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText=@"Registering ...";
}
-(void)stopLoader
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

#pragma mark -TextField Delegates


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    txtField = textField;
    if ([textField isEqual:name]) {
        [signupScroll setContentOffset:CGPointMake(0,210) animated:YES];
    }
    
    else if ([textField isEqual:email]) {
        [signupScroll setContentOffset:CGPointMake(0,210) animated:YES];
    }
    
    else if ([textField isEqual:phone]) {
        CGFloat tooltipWidth = 260.0f;
        
        self.tooltipManager = [[JDFSequentialTooltipManager alloc] initWithHostView:self.view];
        [self.tooltipManager addTooltipWithTargetView:phone hostView:self.view tooltipText:@"The number is for security reasons and it won’t be published on the app." arrowDirection:JDFTooltipViewArrowDirectionUp width:tooltipWidth];
        self.tooltipManager.showsBackdropView = YES;
        [self.tooltipManager showNextTooltip];
        [signupScroll setContentOffset:CGPointMake(0,210) animated:YES];
    }
    
    else if ([textField isEqual:password]) {
        [signupScroll setContentOffset:CGPointMake(0,210) animated:YES];
    }
    
    else  if ([textField isEqual:cpassword]) {
        [signupScroll setContentOffset:CGPointMake(0,210) animated:YES];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if ([textField isEqual:name]) {
        [email becomeFirstResponder];
        [signupScroll setContentOffset:CGPointMake(0,210) animated:YES];
    }
    
    if ([textField isEqual:email]) {
        [phone becomeFirstResponder];
        [signupScroll setContentOffset:CGPointMake(0,210) animated:YES];
    }
    
    if ([textField isEqual:phone]) {
        [password becomeFirstResponder];
        [signupScroll setContentOffset:CGPointMake(0,210) animated:YES];
    }
    
    if ([textField isEqual:password]) {
        [cpassword becomeFirstResponder];
        [signupScroll setContentOffset:CGPointMake(0,210) animated:YES];
    }
    
    if ([textField isEqual:cpassword]) {
        [self Signup];
        [name resignFirstResponder];
        [email resignFirstResponder];
        [phone resignFirstResponder];
        [password resignFirstResponder];
        [cpassword resignFirstResponder];
        [signupScroll setContentOffset:CGPointMake(0,0) animated:YES];
    }
    
    return YES;
}

#pragma mark -Other Methods
-(IBAction)Terms_Conditions:(id)sender{
    TCView.hidden = NO;
    NSString *urlString;
    if ([sender tag] == 0) {
        urlString =[NSString stringWithFormat:@"%@hotel_service/terms",appDelegate.ServerURL];
        termsLbl.text = @"TERMS & CONDITIONS";
    }else if ([sender tag] == 1) {
        urlString =[NSString stringWithFormat:@"%@hotel_service/privacy",appDelegate.ServerURL];
        termsLbl.text = @"PRIVACY POLICY";
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [tandc loadRequest:requestObj];
}
-(IBAction)close_Terms_Conditions:(id)sender{
    TCView.hidden = YES;
}

- (BOOL)validateEmail:(NSString *)emailStr
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+]+@[A-Za-z0-9.]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}

-(IBAction)signUp:(id)sender{
    [self Signup];
}
-(void)Signup{
    
    if (![[name.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]isEqualToString:@""]) {
            if ([self validateEmail:[email text]]){
                //if (![[phone.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]isEqualToString:@""]) {}else{
                //    phone.text = @"";
                //    [phone becomeFirstResponder];
                //    [self alertShow:phone];
                //}
                
                
                if (![[password.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]isEqualToString:@""]) {
                    if ([password.text length] >= 6) {
                        if ([[cpassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]isEqualToString:password.text])
                        {
                            [self startLoader];
                            Registration *reg = [[Registration alloc] init];
                            reg.reg_proces = self;
                            [reg registerUser:name.text email:email.text phone:phone.text paswd:password.text devceTckn:appDelegate.devicetoken];
                        }else{
                            cpassword.text = @"";
                            [cpassword becomeFirstResponder];
                            [self alertShow:cpassword];
                        }
                        
                    }else{
                        password.text = @"";
                        [password becomeFirstResponder];
                        [self alertShow:@"password1"];
                    }
                    
                }else{
                    password.text = @"";
                    [password becomeFirstResponder];
                    [self alertShow:password];
                }
                
                
                
            }else{
                email.text = @"";
                [email becomeFirstResponder];
                [self alertShow:email];
            }
    }else{
        name.text = @"";
        [name becomeFirstResponder];
        [self alertShow:name];
    }
}
-(void)alertShow:(id)sender{
    NSString *msg;
    if(sender == name)
        msg = @"Please enter name";
    else if(sender == email)
        msg = @"Please enter valid email address";
    else if(sender == phone)
        msg = @"Please enter phone";
    else if(sender == password)
        msg = @"Please enter password";
    else if(sender == cpassword)
        msg = @"Confirm password is incorrect";
    else if([sender isEqualToString:@"password1"])
        msg = @"Password must be atleast 6 characters";
    
    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Message" message:msg delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
    [alert show];
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
-(void) RegistrationProcessFinish:(NSString *) userdetails{
    
    
    responseDetails = [userdetails JSONValue];
    
    NSLog(@"userDet =-=======%@",responseDetails);
    
    if ([[responseDetails objectForKey:@"status"] isEqualToString:@"true"]) {
        
        appDelegate.first_register = @"YES";
        
        NSString *userid = [[responseDetails objectForKey:@"details"] objectForKey:@"user_id"];
        NSString *username_pass = [[responseDetails objectForKey:@"details"] objectForKey:@"email_address"];
        if ([password.text isEqualToString:@""]) {
            password.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"password"];
        }
        NSString *password_pass = password.text;
        //NSString *full_name =   [NSString stringWithFormat:@"%@ %@",[[responseDetails objectForKey:@"details"] objectForKey:@"first_name"],[[responseDetails objectForKey:@"details"] objectForKey:@"last_name"]];
        NSString *full_name = [[responseDetails objectForKey:@"details"] objectForKey:@"first_name"];
        NSString *email_id = [[responseDetails objectForKey:@"details"] objectForKey:@"email_address"];
        NSString *mem_type = [[responseDetails objectForKey:@"details"] objectForKey:@"member_type"];
        NSString *activation_code = [responseDetails objectForKey:@"activation_code"];
        NSString *activation_status = [responseDetails objectForKey:@"activation_status"];
        NSString *enter_save = [[responseDetails objectForKey:@"details"] objectForKey:@"enter_to_send"];
        //NSString *user_quickblox = [[responseDetails objectForKey:@"details"] objectForKey:@"quickblox_id"];
        
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:userid forKey:@"user_id"];
        [defaults setObject:username_pass forKey:@"username"];
        [defaults setObject:password_pass forKey:@"password"];
        [defaults setObject:full_name forKey:@"fullname"];
        [defaults setObject:email_id forKey:@"email"];
        [defaults setObject:mem_type forKey:@"mem_type"];
        [defaults setObject:activation_code forKey:@"activation_code"];
        [defaults setObject:activation_status forKey:@"activation_status"];
        [defaults setObject:enter_save forKey:@"enter_save"];
        //[defaults setObject:user_quickblox forKey:@"user_quickblox"];
        [defaults synchronize];
        
        if(([[responseDetails objectForKey:@"details"] objectForKey:@"quickblox_id"] == [NSNull null] || [[[responseDetails objectForKey:@"details"] objectForKey:@"quickblox_id"] isEqualToString:@""])){
            
            
            // Create session request
            [QBRequest createSessionWithSuccessBlock:^(QBResponse *response, QBASession *session) {
                
                
                //Your Quickblox session was created successfully
                
                QBUUser *user = [QBUUser user];
                user.login = [NSString stringWithFormat:@"inhotel_%@",userid];;
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
                    NSString *user_quickblox = [NSString stringWithFormat:@"%lu",(unsigned long)user1.ID];
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:user_quickblox forKey:@"user_quickblox"];
                    [defaults synchronize];
                    
                    [self quickblox];
                    
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
            
        }
        
        
        if ([[responseDetails objectForKey:@"activation_status"] isEqualToString:@"YES"]) {
            [appDelegate tabFunction];
            appDelegate.tabcontroller.selectedIndex = 2;
        }else{
            signupScroll.hidden = YES;
            access_code.text = @"";
            bakBtn.hidden = YES;
            bakImg.hidden = YES;
            [txtField resignFirstResponder];
            different_user_view.hidden = NO;
            access_view.hidden = NO;
        }
    }
    else {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Message" message:[responseDetails objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    
}

-(void)quickblox{
    
    
    NSString *userid = [[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"];
    QBSessionParameters *parameters = [QBSessionParameters new];
    
    parameters.userLogin = [NSString stringWithFormat:@"inhotel_%@",userid];
    parameters.userPassword = [NSString stringWithFormat:@"inhotel_%@123",userid];
    
    [QBRequest createSessionWithExtendedParameters:parameters successBlock:^(QBResponse *response, QBASession *session) {
        
        
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
        
        // set Chat delegate
        [QBChat instance].delegate = self;
        [[LocalStorageService shared] setUsername:[NSString stringWithFormat:@"inhotel_%@",userid]];
        [[LocalStorageService shared] setCurrentUser:currentUser];
        
        //                            if([tempdict objectForKey:@"quickblox_id"] != [NSNull null] || ![[tempdict objectForKey:@"quickblox_id"] isEqualToString:@""]){
        
        [[QBChat instance] loginWithUser:[LocalStorageService shared].currentUser];
        
    }errorBlock:^(QBResponse *response) {
        // error handling
        NSLog(@"error: %@", response.error);
    }];
    
    
}

-(IBAction)Hide:(id)sender{
    [name resignFirstResponder];
    [email resignFirstResponder];
    [phone resignFirstResponder];
    [password resignFirstResponder];
    [cpassword resignFirstResponder];
    [access_code resignFirstResponder];
    [signupScroll setContentOffset:CGPointMake(0,0) animated:YES];
}
-(IBAction)HideAccessView:(id)sender{
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
-(IBAction)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
