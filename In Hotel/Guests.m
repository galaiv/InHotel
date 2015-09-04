//
//  Guests.m
//  In Hotel
//
//  Created by NewageSMB on 3/25/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import "Guests.h"
#import "JSON.h"
#import "MBProgressHUD.h"
#import "GuestCell.h"
#import "UIImageView+WebCache.h"
#import "Conversation.h"
#import "Drinks.h"
#import "Public.h"
#import "Account.h"

@interface Guests ()
{
    BOOL scrol_flag;
    NSString *response_from;
}
@end

@implementation Guests

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.navigationController.navigationBarHidden = YES;
    guestArr = [[NSMutableArray alloc]init];
    tempArr = [[NSMutableArray alloc]init];
    
    if ([appDelegate.first_register isEqualToString:@"YES"]) {
        appDelegate.first_register = @"";
        profileView.hidden = NO;
        profileView.backgroundColor=[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.5];
    }
    
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"activation_status"] isEqualToString:@"N"]){
        [self ShowAccessView:nil];
    }else{
        [access_code resignFirstResponder];
        access_view.hidden = YES;
        page = 0;
        [tempArr removeAllObjects];
        [guestArr removeAllObjects];
        [self performSelector:@selector(serverRequest) withObject:nil afterDelay:.1];
        scrol_flag = YES;
    }
    appDelegate.chat_img.image = [UIImage imageNamed:@"chat.png"];
    appDelegate.hotel_img.image = [UIImage imageNamed:@"hotel.png"];
    appDelegate.guest_img.image = [UIImage imageNamed:@"guests_hover.png"];
    appDelegate.setting_img.image = [UIImage imageNamed:@"settings.png"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSString *user_id = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]];
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"GetAllGuestUsers\", \"parameters\": {\"activation_code\": \"%@\",\"user_id\": \"%@\",\"page\": \"%d\"},\"token\":\"\"}", activation_code,user_id,page];
    NSLog(@"%@",postdata);
    [self startLoader];
    [ser_req sendServerRequests:postdata];
    
}
-(void) ServerRequestProcessFinish:(NSString *) serverResponse{
    NSLog(@"%@",serverResponse);
    if ([response_from isEqualToString:@"access_code"]) {
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
        [self stopLoader];
        scrol_flag = NO;
        if (![[[serverResponse JSONValue] objectForKey:@"details"] isEqual:[NSNull null]]) {
            tempArr  = [[serverResponse JSONValue] objectForKey:@"details"];
            [guestArr addObjectsFromArray:tempArr];
            if ([guestArr count] == 0) {
                page = 0;
                no_guest.hidden = NO;
            }else{
                no_guest.hidden = YES;
            }
            NSLog(@"maindict---%@",guestArr);
            [guestTbl reloadData];
            if (page == 0) {
                //[guestTbl scrollsToTop];
                if ([guestArr count] > 0) {
                    [guestTbl scrollToRowAtIndexPath:0 atScrollPosition:UITableViewScrollPositionTop animated:NO];
                }
            }
        }
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)ScrollView {
    
    if (ScrollView ==guestTbl) {
        
        CGFloat height = ScrollView.frame.size.height;
        
        CGFloat contentYoffset = ScrollView.contentOffset.y;
        
        CGFloat distanceFromBottom = ScrollView.contentSize.height - contentYoffset;
        
        if(distanceFromBottom <= height)
        {
            //            NSLog(@"end of the table");
            if(scrol_flag == NO){
                page = page + 1;
                scrol_flag = YES;
                [self serverRequest];
            }
            
        }
        else
        {
            scrol_flag = NO;
           // page = 0;
        }
    }
}
-(IBAction)complete_profile:(id)sender{
    profileView.hidden = YES;
    Account *account =  [[Account alloc]initWithNibName:@"Account" bundle:nil];
    [self presentViewController:account animated:YES completion:nil];
}
-(IBAction)closeProfileView:(id)sender{
    profileView.hidden = YES;
}
#pragma mark - Table

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)sectionn {
    return guestArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"GuestCell";
    GuestCell *cell = (GuestCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GuestCell" owner:self options:Nil];
        cell = [nib objectAtIndex:0];
        
//        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 65, self.view.frame.size.width, 1)];
//        separatorView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//        separatorView.layer.borderWidth = 2.5;
//        separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|
//        UIViewAutoresizingFlexibleRightMargin;
//        [cell.contentView addSubview:separatorView];
        
//        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"seperator.png"]];
//        imgView.frame = CGRectMake(0, 65, self.view.frame.size.width, 1);
//        [cell.contentView addSubview:imgView];
        
    }
    
    if (![[[guestArr objectAtIndex:indexPath.row] objectForKey:@"first_name"] isEqual:[NSNull null]]){
        cell.guestLbl.text = [[guestArr objectAtIndex:indexPath.row] objectForKey:@"first_name"];
    }
    if (![[[guestArr objectAtIndex:indexPath.row] objectForKey:@"status"] isEqual:[NSNull null]]){
        cell.statusLbl.text = [[guestArr objectAtIndex:indexPath.row] objectForKey:@"status"];
    }
    NSURL   *url  = [ NSURL URLWithString:[[guestArr objectAtIndex:indexPath.row] objectForKey:@"image"] ];
    [cell.guestImg sd_setImageWithURL:url placeholderImage:nil];
    cell.guestImg.clipsToBounds = YES;
    cell.guestImg.layer.cornerRadius = 3.0;
    cell.guestImg.layer.borderColor=[[UIColor colorWithRed:207.0/255 green:207.0/255 blue:207.0/255 alpha:1] CGColor];
    //    cell.guestImg.layer.borderWidth=1.0;
    cell.guestImg.layer.masksToBounds=YES;
    return cell;

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    Conversation *chat =  [[Conversation alloc]initWithNibName:@"Conversation" bundle:nil];
//    chat.to_id = [[guestArr objectAtIndex:indexPath.row] objectForKey:@"user_id"];
//    chat.user_Type = @"normal";
//    Drinks *drink =  [[Drinks alloc]initWithNibName:@"Drinks" bundle:nil];
//    drink.to_id = [[guestArr objectAtIndex:indexPath.row] objectForKey:@"user_id"];
//    [self presentViewController:chat animated:YES completion:nil];
    
    Public *public =  [[Public alloc]initWithNibName:@"Public" bundle:nil];
    public.public_id = [[guestArr objectAtIndex:indexPath.row] objectForKey:@"user_id"];
    public.rec_quickblox_id = [[[guestArr objectAtIndex:indexPath.row] objectForKey:@"quickblox_id"]intValue];
    [self presentViewController:public animated:YES completion:nil];
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
