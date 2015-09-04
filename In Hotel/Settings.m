//
//  Settings.m
//  In Hotel
//
//  Created by NewageSMB on 3/26/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import "Settings.h"
#import "JSON.h"
#import "Account.h"
#import "BlockedUsers.h"

@interface Settings ()
{
    NSString *response_from;
    NSString *chat_status,*enter_status,*show_room_status;
}
@end

@implementation Settings

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.navigationController.navigationBarHidden = YES;
    [mscroll setContentSize: CGSizeMake(0,600)];
    if ([appDelegate.first_register isEqualToString:@"YES"]) {
        appDelegate.first_register = @"";
        profileView.hidden = NO;
        profileView.backgroundColor=[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.5];
    }
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated{
    change_view.hidden = YES;
    access_view.hidden = YES;
    appDelegate.chat_img.image = [UIImage imageNamed:@"chat.png"];
    appDelegate.hotel_img.image = [UIImage imageNamed:@"hotel.png"];
    appDelegate.guest_img.image = [UIImage imageNamed:@"guests.png"];
    appDelegate.setting_img.image = [UIImage imageNamed:@"settings_hover.png"];
    [self performSelector:@selector(serverRequest) withObject:nil afterDelay:.1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
   
}
#pragma mark -Other Methods

-(IBAction)showChangePassword:(id)sender{
    old_pass.text = @"";
    new_pass.text = @"";
    cpass.text = @"";
    change_view.backgroundColor=[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.5];
    access_view.hidden = YES;
    change_view.hidden = NO;
}
-(IBAction)blocked_users:(id)sender{
    BlockedUsers *users =  [[BlockedUsers alloc]initWithNibName:@"BlockedUsers" bundle:nil];
    [self presentViewController:users animated:YES completion:nil];
}
-(IBAction)change_password:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![[old_pass.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]isEqualToString:@""])
    {
        if([[defaults objectForKey:@"password"] isEqualToString:old_pass.text])
        {
            if (![[new_pass.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]isEqualToString:@""])
            {
                if ([new_pass.text length] >= 6)
                {
                    if ([[cpass.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]isEqualToString:new_pass.text])
                    {
                        response_from = @"password";
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        ServerRequests *ser_req = [[ServerRequests alloc] init];
                        ser_req.server_req_proces = self;
                        NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"change_password\", \"parameters\": {\"user_id\": \"%@\",\"password\": \"%@\"},\"token\":\"\"}",[defaults objectForKey:@"user_id"],new_pass.text];
                        NSLog(@"%@",postdata);
                        [ser_req sendServerRequests:postdata];
                        
                    }else{
                        cpass.text = @"";
                        [cpass becomeFirstResponder];
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Confirm password required" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alert show];
                    }
                    
                }else{
                    new_pass.text = @"";
                    [new_pass becomeFirstResponder];
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Password must be atleast 6 characters" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    
                }
                
            }else{
                new_pass.text = @"";
                [new_pass becomeFirstResponder];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"New password required" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }else{
            old_pass.text = @"";
            [old_pass becomeFirstResponder];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Old password is incorrect" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else{
        old_pass.text = @"";
        [old_pass becomeFirstResponder];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Old password required" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(IBAction)close_password:(id)sender{
    response_from = @"";
    change_view.hidden = YES;
    [new_pass resignFirstResponder];
    [cpass resignFirstResponder];
    [old_pass resignFirstResponder];
}
-(IBAction)signout:(id)sender{
    response_from = @"logout";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    ServerRequests *ser_req = [[ServerRequests alloc] init];
    ser_req.server_req_proces = self;
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
-(void) ServerRequestProcessFinish:(NSString *) serverResponse{
    
    if ([response_from isEqualToString:@"logout"]) {
        response_from = @"";
    }else if ([response_from isEqualToString:@"access_code"]) {
        response_from = @"";
        if([[[serverResponse JSONValue] objectForKey:@"activation_status"] isEqualToString:@"Y"]){
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[[serverResponse JSONValue] objectForKey:@"activation_status"] forKey:@"activation_status"];
            [defaults setObject:access_code.text forKey:@"activation_code"];
            [defaults synchronize];
            [access_code resignFirstResponder];
            access_view.hidden = YES;
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Your code activated successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }else{
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:nil forKey:@"activation_code"];
            [defaults setObject:@"N" forKey:@"activation_status"];
            [defaults synchronize];
            access_code.text = @"";
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Message" message:[[serverResponse JSONValue] objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }else if ([response_from isEqualToString:@"password"]) {
        response_from = @"";
        change_view.hidden = YES;
        [new_pass resignFirstResponder];
        [cpass resignFirstResponder];
        [old_pass resignFirstResponder];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:new_pass.text forKey:@"password"];
        [defaults synchronize];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Message" message:[[serverResponse JSONValue] objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }else if ([response_from isEqualToString:@"setting"]) {
        response_from = @"";
        if ([[[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"chat_status"] isEqualToString:@"Y"])
        {
            [chat_switch setOn:YES animated:YES];
        }else{
            [chat_switch setOn:NO animated:YES];
            if (![[[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"status_modified"] isEqual:[NSNull null]]) {
                last_time.text = [[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"status_modified"];
            }
        }
        if ([[[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"enter_to_send"] isEqualToString:@"0"])
        {
            [enter_switch setOn:NO animated:YES];
        }else{
            [enter_switch setOn:YES animated:YES];
        }
        if ([[[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"room_enable"] isEqualToString:@"N"])
        {
            [room_show_switch setOn:NO animated:YES];
        }else{
            [room_show_switch setOn:YES animated:YES];
        }
    }else if ([response_from isEqualToString:@"save_status"]) {
        if ([chat_status isEqualToString:@"N"]) {
            NSDate *today = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            last_time.text = [dateFormatter stringFromDate:today];
        }else{
            last_time.text = @"Now";
        }
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Message" message:[[serverResponse JSONValue] objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        //[self serverRequest];
    }
}
-(IBAction)ShowAccessView:(id)sender{
    access_code.text = @"";
    access_view.backgroundColor=[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.5];
    change_view.hidden = YES;
    access_view.hidden = NO;
}
-(IBAction)HideAccessView:(id)sender{
    response_from = @"";
    [access_code resignFirstResponder];
    access_view.hidden = YES;
}
-(IBAction)saveActivationCode:(id)sender{
    if ([[access_code.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Please enter Access code" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        response_from = @"access_code";
        NSString *user_id = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]];
        ServerRequests *ser_req = [[ServerRequests alloc] init];
        ser_req.server_req_proces = self;
        NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"checkActivationCodeExpires\", \"parameters\": {\"activation_code\": \"%@\",\"user_id\": \"%@\"},\"token\":\"\"}", access_code.text,user_id];
        NSLog(@"%@",postdata);
        [ser_req sendServerRequests:postdata];
    }
}
-(void)serverRequest{
    response_from = @"setting";
    NSString *user_id = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]];
    ServerRequests *ser_req = [[ServerRequests alloc] init];
    ser_req.server_req_proces = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"get_user_details\", \"parameters\": {\"user_id\": \"%@\"},\"token\":\"\"}", user_id];
    NSLog(@"%@",postdata);
    [ser_req sendServerRequests:postdata];
    
}
-(IBAction)saveStatus:(id)sender{
    response_from = @"save_status";
    NSString *user_id = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]];
    ServerRequests *ser_req = [[ServerRequests alloc] init];
    ser_req.server_req_proces = self;
    if ([chat_switch isOn]) {
        chat_status = @"Y";
    }else{
        chat_status = @"N";
    }
    if ([enter_switch isOn]) {
        enter_status = @"1";
    }else{
        enter_status = @"0";
    }
    if ([room_show_switch isOn]) {
        show_room_status = @"Y";
    }else{
        show_room_status = @"N";
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:enter_status forKey:@"enter_save"];
    [defaults synchronize];
    
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"updateDetails\", \"parameters\": {\"user_id\": \"%@\",\"chat_status\": \"%@\",\"enter_to_send\": \"%@\",\"room_enable\": \"%@\"},\"token\":\"\"}", user_id,chat_status,enter_status,show_room_status];
    NSLog(@"%@",postdata);
    [ser_req sendServerRequests:postdata];
}
-(IBAction)showAccountDetails:(id)sender{
    Account *account =  [[Account alloc]initWithNibName:@"Account" bundle:nil];
    [self presentViewController:account animated:YES completion:nil];
}

-(IBAction)complete_profile:(id)sender{
    profileView.hidden = YES;
    Account *account =  [[Account alloc]initWithNibName:@"Account" bundle:nil];
    [self presentViewController:account animated:YES completion:nil];
}
-(IBAction)closeProfileView:(id)sender{
    profileView.hidden = YES;
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
