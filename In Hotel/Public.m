//
//  Public.m
//  In Hotel
//
//  Created by NewageSMB on 5/4/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import "Public.h"
#import "JSON.h"
#import "UIImageView+WebCache.h"
#import "VacancyCell.h"
#import "MBProgressHUD.h"
#import "Settings.h"
#import "Conversation.h"
#import "Drinks.h"

@interface Public ()
{
    NSString *response_from,*vacancyIds;
}
@end

@implementation Public
@synthesize from_page;
- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    userImg.clipsToBounds = YES;
    userImg.layer.cornerRadius = 45;
    userImg.layer.borderColor=[[UIColor colorWithRed:60.0/255 green:132.0/255 blue:120.0/255 alpha:1] CGColor];
    userImg.layer.borderWidth=5.0;
    userImg.layer.masksToBounds=YES;
    selectedIDArray = [[NSMutableArray alloc]init];
    tempArr = [[NSMutableArray alloc]init];
    vacancyArr = [[NSMutableArray alloc]init];
    if ([UIScreen mainScreen].bounds.size.height == 480)
    {
        [mscroll setContentSize: CGSizeMake(0,600)];
        vacancyTbl.frame = CGRectMake(vacancyTbl.frame.origin.x, vacancyTbl.frame.origin.y, vacancyTbl.frame.size.width, vacancyTbl.frame.size.height + 150);
    }else{
        // [mscroll setContentSize: CGSizeMake(0,600)];
    }
    if ([from_page isEqualToString: @"block"]) {
        chat_new.hidden = YES;
        chat_newBtn.hidden = YES;
    }
    [self performSelector:@selector(serverRequest) withObject:nil afterDelay:.1];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -Other Methods
-(IBAction)chat:(id)sender{
    Conversation *chat =  [[Conversation alloc]initWithNibName:@"Conversation" bundle:nil];
    chat.to_id = _public_id;
    chat.recp_quickblox_id = _rec_quickblox_id;
    chat.user_Type = @"normal";
    Drinks *drink =  [[Drinks alloc]initWithNibName:@"Drinks" bundle:nil];
    drink.to_id = _public_id;
    [self presentViewController:chat animated:YES completion:nil];
}
-(void)serverRequest{
     NSString *other_id = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]];
     //NSString *activation_code = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"activation_code"]];
    ServerRequests *ser_req = [[ServerRequests alloc] init];
    ser_req.server_req_proces = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"get_user_details\", \"parameters\": {\"user_id\": \"%@\",\"other_id\": \"%@\"},\"token\":\"\"}", _public_id,other_id];
    NSLog(@"%@",postdata);
    [self startLoader];
    [ser_req sendServerRequests:postdata];
    
}
-(void) ServerRequestProcessFinish:(NSString *) serverResponse{
    if ([response_from isEqualToString:@"vacancy"]) {
        response_from = @"";
        tempArr  = [[serverResponse JSONValue] objectForKey:@"details"];
        //vacancyArr  = [[serverResponse JSONValue] objectForKey:@"details"];
        NSLog(@"maindict---%@",tempArr);
        for (int j=0; j < [tempArr count]; j++) {
            if ([selectedIDArray containsObject:[[tempArr objectAtIndex:j] objectForKey:@"id"]]) {
                [vacancyArr addObject:[tempArr objectAtIndex:j]];
            }
        }
        [vacancyTbl reloadData];
    }else if ([response_from isEqualToString:@"block"]) {
        [self back:nil];
    }else{
        [self stopLoader];
        response_from = @"";
        if (![[[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"first_name"] isEqual:[NSNull null]]){
            name.text = [[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"first_name"];
        }
        if (![[[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"status"] isEqual:[NSNull null]]){
            status.text = [[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"status"];
        }
        if (![[[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"access_start_date_time"] isEqual:[NSNull null]]){
            from.text = [[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"access_start_date_time"];
        }
        if (![[[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"access_end_date_time"] isEqual:[NSNull null]]){
            to.text = [[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"access_end_date_time"];
        }
        if (![[[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"room"] isEqual:[NSNull null]]){
            room_no.text = [[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"room"];
        }
        if (![[[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"profile_description"] isEqual:[NSNull null]]){
            desc.text = [[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"profile_description"];
            if ([desc.text isEqualToString:@""]) {
                desc.text = @"Description";
            }
        }
        if (![[[serverResponse JSONValue] objectForKey:@"user_vacancy"]  isEqual:[NSNull null]]){
            for (int i=0; i < [[[serverResponse JSONValue] objectForKey:@"user_vacancy"] count]; i++) {
                [selectedIDArray addObject: [[[[serverResponse JSONValue] objectForKey:@"user_vacancy"] objectAtIndex:i] objectForKey:@"vecancy_id"]];
            }
        }
        
        if (selectedIDArray.count > 0){
            user_interests.hidden = NO;
        }else{
            user_interests.hidden = YES;
        }
        if ([[[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"blocked_status"] isEqualToString:@"N"])
        {
            [block setOn:NO animated:YES];
        }else{
            [block setOn:YES animated:YES];
        }
        if ([[[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"room_enable"] isEqualToString:@"N"])
        {
            roomView.hidden = YES;
            CGRect frame = CGRectMake(desc.frame.origin.x, desc.frame.origin.y - 36, desc.frame.size.width + 190, desc.frame.size.height);
            desc.frame = frame;
        }else{
            roomView.hidden = NO;
        }
        
        if (!_rec_quickblox_id){
            chat_new.hidden = YES;
            chat_newBtn.hidden = YES;
        }else{
            chat_new.hidden = NO;
            chat_newBtn.hidden = NO;
        }
        NSURL   *url  = [[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"image"];
        [userImg sd_setImageWithURL:url placeholderImage:nil];
        [self vacancyList];
    }
    
}
-(IBAction)back:(id)sender{
    [self dismissViewControllerAnimated:YES completion:Nil];
}
-(void)vacancyList{
    response_from = @"vacancy";
    ServerRequests *ser_req = [[ServerRequests alloc] init];
    ser_req.server_req_proces = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"vacancy_reason_list\", \"parameters\": {},\"token\":\"\"}"];
    NSLog(@"%@",postdata);
    [ser_req sendServerRequests:postdata];
}

-(IBAction)block_guest:(id)sender{
    response_from = @"block";
    NSString *user_id = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]];
    ServerRequests *ser_req = [[ServerRequests alloc] init];
    ser_req.server_req_proces = self;
    
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"block_guest\", \"parameters\": {\"user_id\": \"%@\",\"blocked_profile_id\": \"%@\"},\"token\":\"\"}", user_id,_public_id];
    NSLog(@"%@",postdata);
    [ser_req sendServerRequests:postdata];
}

#pragma mark -MBHud Methods

-(void)startLoader
{
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText=@"Updating ...";
}
-(void)stopLoader
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
#pragma mark -TextField Delegates

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if ([textField isEqual:name]) {
        saveBtn.hidden = NO;
    }else if ([textField isEqual:status]) {
        saveBtn.hidden = NO;
    }
    return YES;
}

#pragma mark - Table

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)sectionn {
    
    return vacancyArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"VacancyCell";
    VacancyCell *cell = (VacancyCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VacancyCell" owner:self options:Nil];
        cell = [nib objectAtIndex:0];
        
    }
    
    cell.vacancyLbl.text = [[vacancyArr objectAtIndex:indexPath.row] objectForKey:@"title"];
    if ([[[vacancyArr objectAtIndex:indexPath.row] objectForKey:@"id"] isEqualToString:@"1"]) {
        cell.vacancyImg.image = [UIImage imageNamed:@"nature_icon.png"];
    }else if ([[[vacancyArr objectAtIndex:indexPath.row] objectForKey:@"id"] isEqualToString:@"2"]) {
        cell.vacancyImg.image = [UIImage imageNamed:@"culture_icon.png"];
    }else if ([[[vacancyArr objectAtIndex:indexPath.row] objectForKey:@"id"] isEqualToString:@"3"]) {
        cell.vacancyImg.image = [UIImage imageNamed:@"fiera.png"];
    }else if ([[[vacancyArr objectAtIndex:indexPath.row] objectForKey:@"id"] isEqualToString:@"4"]) {
        cell.vacancyImg.image = [UIImage imageNamed:@"concert.png"];
    }else if ([[[vacancyArr objectAtIndex:indexPath.row] objectForKey:@"id"] isEqualToString:@"5"]) {
        cell.vacancyImg.image = [UIImage imageNamed:@"sports.png"];
    }else if ([[[vacancyArr objectAtIndex:indexPath.row] objectForKey:@"id"] isEqualToString:@"6"]) {
        cell.vacancyImg.image = [UIImage imageNamed:@"family_vacation.png"];
    }
    
    if ([selectedIDArray containsObject:[[vacancyArr objectAtIndex:indexPath.row] objectForKey:@"id"]]) {
        
        //cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        //cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    return cell;
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
