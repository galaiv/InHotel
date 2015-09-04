//
//  Chat.m
//  In Hotel
//
//  Created by NewageSMB on 4/8/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import "Chat.h"
#import "JSON.h"
#import "MBProgressHUD.h"
#import "MessageCell.h"
#import "UIImageView+WebCache.h"
#import "Conversation.h"
#import "Drinks.h"
#import "LocalStorageService.h"

@interface Chat ()
{
    int pageNo;
    NSString *response_from;
}
@end

@implementation Chat

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.navigationController.navigationBarHidden = YES;
    messageArr = [[NSMutableArray alloc]init];
    tempArr = [[NSMutableArray alloc]init];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"activation_status"] isEqualToString:@"N"]){
        [self ShowAccessView:nil];
    }else{
        [access_code resignFirstResponder];
        access_view.hidden = YES;
        pageNo = 0;
        [messageArr removeAllObjects];
        [self performSelector:@selector(serverRequest) withObject:nil afterDelay:.1];
    }
    appDelegate.chat_img.image = [UIImage imageNamed:@"chat_hover.png"];
    appDelegate.hotel_img.image = [UIImage imageNamed:@"hotel.png"];
    appDelegate.guest_img.image = [UIImage imageNamed:@"guests.png"];
    appDelegate.setting_img.image = [UIImage imageNamed:@"settings.png"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -MBHud Methods
-(void)startLoader
{
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText=@"Loading ...";
}
-(void)stopLoader
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
#pragma mark - Table


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)sectionn {
    return newarray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MessageCell";
    MessageCell *cell = (MessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageCell" owner:self options:Nil];
        cell = [nib objectAtIndex:0];
    }
    
    QBChatDialog *chatDialog = [[newarray objectAtIndex:indexPath.row] objectForKey:@"message"];
    
    if (![[[[newarray objectAtIndex:indexPath.row] objectForKey:@"user"] objectForKey:@"first_name"] isEqual:[NSNull null]]){
        cell.nameLbl.text = [[[newarray objectAtIndex:indexPath.row] objectForKey:@"user"] objectForKey:@"first_name"];
    }

    if (chatDialog.lastMessageText){
        cell.msgView.text = chatDialog.lastMessageText;
    }else{
        cell.msgView.text = @"Send a video";
    }
//    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, 1)];
//    separatorView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    separatorView.layer.borderWidth = 2.5;
//    separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|
//    UIViewAutoresizingFlexibleRightMargin;
//    [cell.contentView addSubview:separatorView];

    NSURL   *url  = [ NSURL URLWithString:[[[newarray objectAtIndex:indexPath.row] objectForKey:@"user"] objectForKey:@"image"]];
    [cell.userImg sd_setImageWithURL:url placeholderImage:nil];
    cell.userImg.clipsToBounds = YES;
    cell.userImg.layer.cornerRadius = 3.0;
    cell.userImg.layer.borderColor=[[UIColor colorWithRed:207.0/255 green:207.0/255 blue:207.0/255 alpha:1] CGColor];
    //    cell.userImg.layer.borderWidth=1.0;
    cell.userImg.layer.masksToBounds=YES;
    if (chatDialog.lastMessageDate){
        //ccell.timeLabel.text = [[messageArr objectAtIndex:indexPath.row] objectForKey:@"sent"];
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
        timeFormatter.dateFormat = @"MM-dd-YYYY";
        NSString *dateString = [timeFormatter stringFromDate:chatDialog.lastMessageDate];
        cell.dateLbl.text = [NSString stringWithFormat:@"Posted on - %@",dateString];
    }else{
        cell.msgView.hidden = YES;
    }
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Conversation *chat =  [[Conversation alloc]initWithNibName:@"Conversation" bundle:nil];
    chat.to_id = [[[newarray objectAtIndex:indexPath.row] objectForKey:@"user"] objectForKey:@"user_id"];
    chat.user_Type = [[[newarray objectAtIndex:indexPath.row] objectForKey:@"user"] objectForKey:@"user_Type"];
    chat.recp_quickblox_id = [[[[newarray objectAtIndex:indexPath.row] objectForKey:@"user"] objectForKey:@"quickblox_id"]intValue];
    NSLog(@"%d",chat.recp_quickblox_id);
    Drinks *drink =  [[Drinks alloc]initWithNibName:@"Drinks" bundle:nil];
    drink.to_id = [[[newarray objectAtIndex:indexPath.row] objectForKey:@"user"] objectForKey:@"user_id"];
    [self presentViewController:chat animated:YES completion:nil];
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
-(IBAction)back:(id)sender{
    [self dismissViewControllerAnimated:YES completion:Nil];
}
-(void)serverRequest{
    NSString *user_id = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]];
    NSString *activation_code = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"activation_code"]];
    ServerRequests *ser_req = [[ServerRequests alloc] init];
    ser_req.server_req_proces = self;
    //NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"showAllmesssages\", \"parameters\": {\"user_id\": \"%@\",\"pageNo\": \"%d\"},\"token\":\"\"}", user_id,pageNo];
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"getAllChatUsers\", \"parameters\": {\"user_id\": \"%@\",\"activation_code\": \"%@\"},\"token\":\"\"}",user_id,activation_code];
    NSLog(@"%@",postdata);
    [self startLoader];
    [ser_req sendServerRequests:postdata];
    
    NSMutableDictionary *extendedRequest = [NSMutableDictionary new];
    extendedRequest[@"limit"] = @(100);
    //extendedRequest[@"skip"] = @(100);
    
    [QBChat dialogsWithExtendedRequest:extendedRequest delegate:self];
    
    
}
-(void) ServerRequestProcessFinish:(NSString *) serverResponse{
    
    if ([response_from isEqualToString:@"access_code"]) {
        [self stopLoader];
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
        if (![[[serverResponse JSONValue] objectForKey:@"details"] isEqual:[NSNull null]]) {
            tempArr  = [[serverResponse JSONValue] objectForKey:@"details"];
            responsegot = YES;
            if ([tempArr count] > 0)
                [messageArr addObjectsFromArray:tempArr];
            [tempArr removeAllObjects];
            NSLog(@"maindict---%@",messageArr);
            
            
            if(onlinestatusgot == YES){
                NSInteger unreadmsgcount = 0;
                newarray = [[NSMutableArray alloc] init];
                for(int i = 0; i < self.maindialogs.count; i++){
                    
                    QBChatDialog *chatDialog = self.maindialogs[i];
                    if([chatDialog.occupantIDs objectAtIndex:0] != [chatDialog.occupantIDs objectAtIndex:1]){
                        
                        NSString *occupantid;
                        if([[chatDialog.occupantIDs objectAtIndex:0] intValue] == [LocalStorageService shared].currentUser.ID){
                            occupantid = [NSString stringWithFormat:@"%ld",(long)[[chatDialog.occupantIDs objectAtIndex:1] integerValue]];
                            
                        }
                        else
                            occupantid = [NSString stringWithFormat:@"%ld",(long)[[chatDialog.occupantIDs objectAtIndex:0] integerValue]];
                        
                        NSDictionary *dict;
                        for(int j = 0; j < tempArr.count; j++){
                            NSLog(@"quickblox_id --- %@",[[tempArr objectAtIndex:j] objectForKey:@"quickblox_id"]);
                            if([[[tempArr objectAtIndex:j] objectForKey:@"quickblox_id"] isEqualToString:occupantid]){
                                
                                
                                unreadmsgcount = unreadmsgcount + chatDialog.unreadMessagesCount;
                                dict = [[NSDictionary alloc] initWithObjectsAndKeys:chatDialog,@"message",[tempArr objectAtIndex:j],@"user", nil];
                                [newarray addObject:dict];
                                break;
                            }
                        }
                    }
                    
                }
                
                dialogcount = newarray.count;
                
//                for(int j = 0; j < tempArr.count; j++){
//                    
//                    NSLog(@"quickblox_id --- %@",[[tempArr objectAtIndex:j] objectForKey:@"quickblox_id"]);
//                    
//                    BOOL exist = NO;
//                    NSDictionary *dict;
//                    for(int k = 0; k < newarray.count; k++){
//                        
//                        NSString *quickbloxid = [NSString stringWithFormat:@"%ld",(long)[[[[newarray objectAtIndex:k] objectForKey:@"user"] objectForKey:@"quickblox_id"] integerValue]];
//                        NSLog(@"quickblox_id --- %@",[[[newarray objectAtIndex:k] objectForKey:@"user"] objectForKey:@"quickblox_id"]);
//                        
//                        if([[[tempArr objectAtIndex:j] objectForKey:@"quickblox_id"] isEqualToString:quickbloxid]){
//                            exist = YES;
//                            break;
//                        }
//                    }
//                    if(exist == NO){
//                        dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"",@"message",[tempArr objectAtIndex:j],@"user", nil];
//                        [newarray addObject:dict];
//                    }
//                }
                
                
                NSLog(@"newarray --- %@",newarray);
                
//                for(int i = 0; i < onorofflineusers.count; i++){
//                    QBUUser *recipient = [onorofflineusers objectAtIndex:i];
//                    if(recipient){
//                        if(recipient.ID == [LocalStorageService shared].currentUser.ID){
//                            [onorofflineusers removeObjectAtIndex:i];
//                            break;
//                        }
//                    }
//                }
                
                //            dialogcount = onorofflineusers.count;
                for(int i = 0; i < tempArr.count; i++){
                    
                    if([[tempArr objectAtIndex:i] objectForKey:@"quickblox_id"] != [NSNull null]){
                        NSString *occupantid = [NSString stringWithFormat:@"%ld",(long)[[[tempArr objectAtIndex:i] objectForKey:@"quickblox_id"] integerValue]];
                        // NSString *strng = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] %@",occupantid];
                        NSArray *results = [chatids filteredArrayUsingPredicate:predicate];
                        if(results.count>0){
                            
                        }
                        else
                            [onorofflineusers addObject:[tempArr objectAtIndex:i]];
                    }
                    else
                        [onorofflineusers addObject:[tempArr objectAtIndex:i]];
                    
                }
                if ([newarray count] == 0) {
                    pageNo = 0;
                    no_msgLbl.hidden = NO;
                }else{
                    no_msgLbl.hidden = YES;
                }
                [messageTbl reloadData];
                [self stopLoader];
                onlinestatusgot = NO;
                responsegot = NO;
            }
            
            
        }else{
            pageNo = 0;
        }
    }
}

#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
- (void)completedWithResult:(Result *)result{
    
    if (result.success && [result isKindOfClass:[QBDialogsPagedResult class]]) {
        QBDialogsPagedResult *pagedResult = (QBDialogsPagedResult *)result;
        //
        NSArray *dialogs = pagedResult.dialogs;
        self.maindialogs = [dialogs mutableCopy];
        for(int i = 0; i < self.maindialogs.count; i++){
            
            //
            QBChatDialog *chatDialog = self.maindialogs[i];
            if([chatDialog.occupantIDs objectAtIndex:0] == [chatDialog.occupantIDs objectAtIndex:1]){
                [self.maindialogs removeObjectAtIndex:i];
                break;
            }
        }
        
        QBGeneralResponsePage *pagedRequest = [QBGeneralResponsePage responsePageWithCurrentPage:0 perPage:100];
        //
        NSSet *dialogsUsersIDs = pagedResult.dialogsUsersIDs;
        NSArray *temparray = [pagedResult.dialogsUsersIDs allObjects];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for(int i = 0; i <temparray.count;i++){
            NSString *val = [[temparray objectAtIndex:i] stringValue];
            [array addObject:val];
        }
        chatids = (NSArray *)[array mutableCopy];
        
        //
        [QBRequest usersWithIDs:[dialogsUsersIDs allObjects] page:pagedRequest successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
            
            NSLog(@"users === %@",users);
            onorofflineusers = [users mutableCopy];
            onlinestatusgot = YES;
            // [LocalStorageService shared].users = users;
            [LocalStorageService shared].users = users;
            //
            if(responsegot == YES){
                
                newarray = [[NSMutableArray alloc] init];
                NSInteger unreadmsgcount = 0;
                //appdelegate.unreadmsgcount = 0;
                for(int i = 0; i < self.maindialogs.count; i++){
                    
                    QBChatDialog *chatDialog = self.maindialogs[i];
                    if([chatDialog.occupantIDs objectAtIndex:0] != [chatDialog.occupantIDs objectAtIndex:1]){
                        
                        NSString *occupantid;
                        if([[chatDialog.occupantIDs objectAtIndex:0] intValue] == [LocalStorageService shared].currentUser.ID){
                            
                            occupantid = [NSString stringWithFormat:@"%ld",(long)[[chatDialog.occupantIDs objectAtIndex:1] integerValue]];
                            
                        }
                        else
                            occupantid = [NSString stringWithFormat:@"%ld",(long)[[chatDialog.occupantIDs objectAtIndex:0] integerValue]];
                        NSDictionary *dict;
                        
                        for(int j = 0; j < messageArr.count; j++){
                            NSLog(@"quickblox_id --- %@",[[messageArr objectAtIndex:j] objectForKey:@"quickblox_id"]);
                            if([[[messageArr objectAtIndex:j] objectForKey:@"quickblox_id"] isEqualToString:occupantid]){
                                
                                unreadmsgcount = unreadmsgcount + chatDialog.unreadMessagesCount;
                                dict = [[NSDictionary alloc] initWithObjectsAndKeys:chatDialog,@"message",[messageArr objectAtIndex:j],@"user", nil];
                                [newarray addObject:dict];
                                break;
                            }
                        }

                    }
                }

                
//                for(int j = 0; j < messageArr.count; j++){
//                    
//                    NSLog(@"quickblox_id --- %@",[[messageArr objectAtIndex:j] objectForKey:@"quickblox_id"]);
//                    
//                    BOOL exist = NO;
//                    NSDictionary *dict;
//                    for(int k = 0; k < newarray.count; k++){
//                        
//                        NSString *quickbloxid = [NSString stringWithFormat:@"%ld",(long)[[[[newarray objectAtIndex:k] objectForKey:@"user"] objectForKey:@"quickblox_id"] integerValue]];
//                        NSLog(@"quickblox_id --- %@",[[[newarray objectAtIndex:k] objectForKey:@"user"] objectForKey:@"quickblox_id"]);
//                        
//                        if([[[messageArr objectAtIndex:j] objectForKey:@"quickblox_id"] isEqualToString:quickbloxid]){
//                            exist = YES;
//                            break;
//                        }
//                    }
//                    if(exist == NO){
//                        dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"",@"message",[messageArr objectAtIndex:j],@"user", nil];
//                        [newarray addObject:dict];
//                    }
//                }
                NSLog(@"newarray --- %@",newarray);
                
//                for(int i = 0; i < onorofflineusers.count; i++){
//                    QBUUser *recipient = [onorofflineusers objectAtIndex:i];
//                    if(recipient){
//                        if(recipient.ID == [LocalStorageService shared].currentUser.ID){
//                            [onorofflineusers removeObjectAtIndex:i];
//                            break;
//                        }
//                    }
//                }
                
                [messageTbl reloadData];
                if ([newarray count] == 0) {
                    no_msgLbl.hidden = NO;
                }else{
                    no_msgLbl.hidden = YES;
                }
                [self stopLoader];
                onlinestatusgot = NO;
                responsegot = NO;
                
            }
            //  [self.activityIndicator stopAnimating];
            
        } errorBlock:^(QBResponse *response){
            onlinestatusgot = YES;
        }];
        
    }
    else{
        onlinestatusgot = YES;
    }
}


#pragma mark -
#pragma mark QBChatDelegate

// Chat delegate
-(void) chatDidLogin{
    // You have successfully signed in to QuickBlox Chat
}

- (void)chatDidNotLogin{
    
}

- (void)chatContactListDidChange:(QBContactList *)contactList{
}

- (void)chatDidReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(NSString *)status{
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
