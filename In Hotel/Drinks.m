//
//  Drinks.m
//  In Hotel
//
//  Created by NewageSMB on 4/18/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import "Drinks.h"
#import "JSON.h"
#import "DrinksCell.h"
#import "UIImageView+WebCache.h"
#import "Conversation.h"

@interface Drinks ()
{
    NSString *from_user;
    NSString *notestring,*drink_id,*qty;
    NSData *picData;
}
@end

@implementation Drinks

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    drinksArr = [[NSMutableArray alloc]init];
    tempArr = [[NSMutableArray alloc]init];
    from_user = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]];
    [self performSelector:@selector(serverRequest) withObject:nil afterDelay:.1];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)sectionn {
    return drinksArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"DrinksCell";
    DrinksCell *cell = (DrinksCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DrinksCell" owner:self options:Nil];
        cell = [nib objectAtIndex:0];
    }
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, 1)];
    separatorView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    separatorView.layer.borderWidth = 2.5;
    separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|
    UIViewAutoresizingFlexibleRightMargin;
    [cell.contentView addSubview:separatorView];
    
    cell.nameLbl.text = [[drinksArr objectAtIndex:indexPath.row] objectForKey:@"title"];
    cell.rupeeLbl.text = [NSString stringWithFormat:@"$%@",[[drinksArr objectAtIndex:indexPath.row] objectForKey:@"price"]];
    cell.drink_desc.text = [[drinksArr objectAtIndex:indexPath.row] objectForKey:@"description"];
    NSURL   *url  = [ NSURL URLWithString:[[drinksArr objectAtIndex:indexPath.row] objectForKey:@"image"] ];
    [cell.drinkImg sd_setImageWithURL:url placeholderImage:nil];
    cell.drinkImg.clipsToBounds = YES;
    cell.drinkImg.layer.cornerRadius = 3.0;
    cell.drinkImg.layer.borderColor=[[UIColor colorWithRed:207.0/255 green:207.0/255 blue:207.0/255 alpha:1] CGColor];
    //    cell.userImg.layer.borderWidth=1.0;
    cell.drinkImg.layer.masksToBounds=YES;
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    Registration *reg = [[Registration alloc] init];
//    reg.reg_proces = self;
//    notestring = @"";
//    qty = @"1";
    drink_id = [[drinksArr objectAtIndex:indexPath.row] objectForKey:@"id"];
//    [reg send_message:from_user to_user:_to_id message:notestring video:picData drink_id:drink_id qty:qty message_id:@""];
    
    //Conversation *chat =  [[Conversation alloc]initWithNibName:@"Conversation" bundle:nil];
    appDelegate.drink_sent = @"Y";
    appDelegate.drinkFrom = from_user;
    appDelegate.drinkTo = _to_id;
    appDelegate.send_drinkID = drink_id;
    [self back:nil];
}
-(void) RegistrationProcessFinish:(NSString *) userdetails{
    
    responseDetails = [userdetails JSONValue];
    
    NSLog(@"userDet =-=======%@",responseDetails);
    
    //[self stopLoader];
    
    if ([[responseDetails objectForKey:@"status"] isEqualToString:@"true"]) {
        [self back:nil];
    }
    else {
        NSString *MSG;
        if ([responseDetails count] == 0) {
            MSG = @"Some server error occured, please try later";
        }else{
            MSG = [responseDetails objectForKey:@"message"];
        }
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Message" message:MSG delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

#pragma mark -Other Methods
-(IBAction)back:(id)sender{
    [self dismissViewControllerAnimated:YES completion:Nil];
}
-(void)serverRequest{
    NSString *activation_code = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"activation_code"]];
    ServerRequests *ser_req = [[ServerRequests alloc] init];
    ser_req.server_req_proces = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"drinks_list\", \"parameters\": {\"activation_code\": \"%@\"},\"token\":\"\"}", activation_code];
    NSLog(@"%@",postdata);
    [ser_req sendServerRequests:postdata];
    
}
-(void) ServerRequestProcessFinish:(NSString *) serverResponse{
    
    if (![[[serverResponse JSONValue] objectForKey:@"details"] isEqual:[NSNull null]]) {
        tempArr  = [[serverResponse JSONValue] objectForKey:@"details"];
        if ([tempArr count] > 0)
            [drinksArr addObjectsFromArray:tempArr];
        [tempArr removeAllObjects];
        NSLog(@"maindict---%@",drinksArr);
        [drinksTbl reloadData];
    }
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
