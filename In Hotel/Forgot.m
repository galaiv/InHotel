//
//  Forgot.m
//  In Hotel
//
//  Created by NewageSMB on 6/3/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import "Forgot.h"
#import "MBProgressHUD.h"
#import "JSON.h"

@interface Forgot ()

@end

@implementation Forgot

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -TextField Delegates


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if ([textField isEqual:username]) {
        [loginScroll setContentOffset:CGPointMake(0,110) animated:YES];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if ([textField isEqual:username]) {
        [self forgot_password:nil];
        [username resignFirstResponder];
        [loginScroll setContentOffset:CGPointMake(0,0) animated:YES];
    }
    return YES;
}

#pragma mark -MBHud Methods
-(void)startLoader
{
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText=@"Sending ...";
}
-(void)stopLoader
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

#pragma mark -Other Methods
-(void)forgot_password:(id)sender{
    if ([[username.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Message" message:@"Please enter your email" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
        [username becomeFirstResponder];
        [loginScroll setContentOffset:CGPointMake(0,80) animated:YES];
        
    }
    else{
        
        ServerRequests *ser_req = [[ServerRequests alloc] init];
        ser_req.server_req_proces = self;
        NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"forgotPassword\", \"parameters\": {\"email_address\": \"%@\"},\"token\":\"\"}", username.text];
        NSLog(@"%@",postdata);
        [ser_req sendServerRequests:postdata];
    }
}
-(void) ServerRequestProcessFinish:(NSString *) serverResponse{
    [self Hide:nil];
    username.text = @"";
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Message" message:[[serverResponse JSONValue] objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}
-(IBAction)Hide:(id)sender{
    [username resignFirstResponder];
    [loginScroll setContentOffset:CGPointMake(0,0) animated:YES];
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