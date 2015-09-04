//
//  MyHotel.m
//  In Hotel
//
//  Created by NewageSMB on 3/31/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import "MyHotel.h"
#import "JSON.h"
#import "MBProgressHUD.h"

@interface MyHotel ()
{
    NSString *response_from;
}
@end

@implementation MyHotel

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.navigationController.navigationBarHidden = YES;
    [mscroll setContentSize: CGSizeMake(0,600)];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"activation_status"] isEqualToString:@"N"]){
        [self ShowAccessView:nil];
    }else{
        [access_code resignFirstResponder];
        access_view.hidden = YES;
        [self performSelector:@selector(serverRequest) withObject:nil afterDelay:.1];
    }
    appDelegate.chat_img.image = [UIImage imageNamed:@"chat.png"];
    appDelegate.hotel_img.image = [UIImage imageNamed:@"hotel_hover.png"];
    appDelegate.guest_img.image = [UIImage imageNamed:@"guests.png"];
    appDelegate.setting_img.image = [UIImage imageNamed:@"settings.png"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -Other Methods
-(IBAction)Hide:(id)sender{
    [access_code resignFirstResponder];
}
-(IBAction)ShowAccessView:(id)sender{
    access_code.text = @"";
    access_view.backgroundColor=[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.5];
    access_view.hidden = NO;
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
    NSString *activation_code = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"activation_code"]];
    ServerRequests *ser_req = [[ServerRequests alloc] init];
    ser_req.server_req_proces = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"hotel_details\", \"parameters\": {\"activation_code\": \"%@\"},\"token\":\"\"}", activation_code];
    NSLog(@"%@",postdata);
    [ser_req sendServerRequests:postdata];
    
}
-(void) ServerRequestProcessFinish:(NSString *) serverResponse{
    
    if ([response_from isEqualToString:@"share"]) {
        [self stopLoader];
        response_from = @"";
        [self hide:nil];
        exp.text = @"Write Your Experience";
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Message" message:[[serverResponse JSONValue] objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }else if ([response_from isEqualToString:@"access_code"]) {
        response_from = @"";
        if([[[serverResponse JSONValue] objectForKey:@"activation_status"] isEqualToString:@"Y"]){
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[[serverResponse JSONValue] objectForKey:@"activation_status"] forKey:@"activation_status"];
            [defaults setObject:access_code.text forKey:@"activation_code"];
            [defaults synchronize];
            [access_code resignFirstResponder];
            access_view.hidden = YES;
            [self viewWillAppear:NO];
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
    }else{
        response_from = @"";
        if (![[[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"title"] isEqual:[NSNull null]]){
            hotel_name.text = [[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"title"];
        }
        if (![[[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"description"] isEqual:[NSNull null]]){
            hotel_desc.text = [[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"description"];
        }
        if (![[[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"address"] isEqual:[NSNull null]]){
            hotel_addr.text = [[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"address"];
        }
        if (![[[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"contact_number"] isEqual:[NSNull null]]){
            hotel_phone.text = [[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"contact_number"];
        }
        if (![[[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"email_address"] isEqual:[NSNull null]]){
            hotel_email.text = [[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"email_address"];
        }
        if (![[[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"website"] isEqual:[NSNull null]]){
            hotel_website.text = [[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"website"];
        }
    }

}
-(IBAction)hide:(id)sender{
    [exp resignFirstResponder];
    [expScrl setBackgroundColor:[UIColor clearColor]];
    [expScrl setContentOffset:CGPointMake(0,0) animated:YES];
}
-(IBAction)shareExperiance:(id)sender{
    if (![[exp.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]isEqualToString:@"Write Your Experience"]) {
        if(![[exp.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]isEqualToString:@""])
        {
            response_from = @"share";
            NSString *activation_code = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"activation_code"]];
            NSString *user_id = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]];
            ServerRequests *ser_req = [[ServerRequests alloc] init];
            ser_req.server_req_proces = self;
            NSString* encodedUrl = [exp.text stringByAddingPercentEscapesUsingEncoding:
                                    NSUTF8StringEncoding];
            NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"shareExperiance\", \"parameters\": {\"experiance\": \"%@\",\"activation_code\": \"%@\",\"user_id\": \"%@\"},\"token\":\"\"}",encodedUrl,activation_code,user_id];
            NSLog(@"%@",postdata);
            [self startLoader];
            [ser_req sendServerRequests:postdata];
        }
    }
}
#pragma mark -MBHud Methods

-(void)startLoader
{
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText=@"Loading ...";
}
-(void)stopLoader
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}
#pragma mark -TextView Delegates

- (BOOL)textViewShouldBeginEditing:(UITextField *)textView{
    
    if ([textView isEqual:exp]) {
        if ([exp.text isEqualToString:@"Write Your Experience"]) {
            exp.text = @"";
            exp.textColor = [UIColor lightGrayColor];
        }
        [expScrl setBackgroundColor:[UIColor whiteColor]];
        [expScrl setContentOffset:CGPointMake(0,200) animated:YES];
    }
    return YES;
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([exp.text isEqualToString:@""]) {
        exp.text = @"Write Your Experience";
        exp.textColor = [UIColor lightGrayColor];
    }
}
- (BOOL)textViewShouldReturn:(UITextField *)textView{
    [expScrl setContentOffset:CGPointMake(0,0) animated:YES];
    return YES;
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
