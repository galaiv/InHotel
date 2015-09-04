//
//  BlockedUsers.m
//  In Hotel
//
//  Created by NewageSMB on 5/6/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import "BlockedUsers.h"
#import "JSON.h"
#import "MBProgressHUD.h"
#import "GuestCell.h"
#import "UIImageView+WebCache.h"
#import "Public.h"


@interface BlockedUsers ()
{
    BOOL scrol_flag;
    NSString *response_from;
}
@end

@implementation BlockedUsers

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    blockedArr = [[NSMutableArray alloc]init];
    tempArr = [[NSMutableArray alloc]init];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    page = 0;
    [tempArr removeAllObjects];
    [blockedArr removeAllObjects];
    [self performSelector:@selector(serverRequest) withObject:nil afterDelay:.1];
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

#pragma mark -Other Methods
-(IBAction)back:(id)sender{
    [self dismissViewControllerAnimated:YES completion:Nil];
}
-(void)serverRequest{
    NSString *activation_code = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"activation_code"]];
    ServerRequests *ser_req = [[ServerRequests alloc] init];
    ser_req.server_req_proces = self;
    NSString *user_id = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]];
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"GetAllBlockedUsers\", \"parameters\": {\"activation_code\": \"%@\",\"user_id\": \"%@\",\"page\": \"%d\"},\"token\":\"\"}", activation_code,user_id,page];
    NSLog(@"%@",postdata);
    [self startLoader];
    [ser_req sendServerRequests:postdata];
    
}
-(void) ServerRequestProcessFinish:(NSString *) serverResponse{
    
    [self stopLoader];
    if (![[[serverResponse JSONValue] objectForKey:@"details"] isEqual:[NSNull null]]) {
        tempArr  = [[serverResponse JSONValue] objectForKey:@"details"];
        [blockedArr addObjectsFromArray:tempArr];
        if ([blockedArr count] == 0) {
            page = 0;
            no_users.hidden = NO;
        }else{
            no_users.hidden = YES;
        }
        NSLog(@"maindict---%@",blockedArr);
        [blockUserTbl reloadData];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)ScrollView {
    
    if (ScrollView ==blockUserTbl) {
        
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
            page = 0;
        }
    }
}

#pragma mark - Table

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)sectionn {
    return blockedArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"GuestCell";
    GuestCell *cell = (GuestCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GuestCell" owner:self options:Nil];
        cell = [nib objectAtIndex:0];
        
    }
    
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 65, self.view.frame.size.width, 1)];
    separatorView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    separatorView.layer.borderWidth = 2.5;
    separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|
    UIViewAutoresizingFlexibleRightMargin;
    [cell.contentView addSubview:separatorView];
    if (![[[blockedArr objectAtIndex:indexPath.row] objectForKey:@"first_name"] isEqual:[NSNull null]]){
        cell.guestLbl.text = [[blockedArr objectAtIndex:indexPath.row] objectForKey:@"first_name"];
    }
    if (![[[blockedArr objectAtIndex:indexPath.row] objectForKey:@"status"] isEqual:[NSNull null]]){
        cell.statusLbl.text = [[blockedArr objectAtIndex:indexPath.row] objectForKey:@"status"];
    }
    NSURL   *url  = [ NSURL URLWithString:[[blockedArr objectAtIndex:indexPath.row] objectForKey:@"image"] ];
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
    Public *public =  [[Public alloc]initWithNibName:@"Public" bundle:nil];
    public.public_id = [[blockedArr objectAtIndex:indexPath.row] objectForKey:@"user_id"];
    public.from_page = @"block";
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
