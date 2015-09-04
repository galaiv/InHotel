//
//  Conversation.m
//  In Hotel
//
//  Created by NewageSMB on 4/9/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import "Conversation.h"
#import "PTSMessagingCell.h"
#import "MBProgressHUD.h"
#import "JSON.h"
#import "UIImageView+WebCache.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Drinks.h"
#import "ODRefreshControl.h"

@interface Conversation ()
{
    int pageNo;
    BOOL scrol_flag,list_flag,msg_flag,send_flag;
    NSString *from_user,*response_from,*drink_push;
    NSString *notestring,*drink_id,*qty;
    int rowno,drinkID;
    NSTimer *timer;
    int cnt;
    Result *quickresult;
    BOOL apprate;
    BOOL pagenation;
    long push_id;
    
    NSString *mp4VideoPath;
}
@end

@implementation Conversation

- (void)viewDidLoad {
    [super viewDidLoad];
    list_flag = NO;
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    // Set chat notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatDidReceiveMessageNotification:)
                                                 name:kNotificationDidReceiveNewMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatRoomDidReceiveMessageNotification:)
                                                 name:kNotificationDidReceiveNewMessageFromRoom object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(drinkReload:) name:@"DRINK" object:nil];
    
    
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height -43, self.view.frame.size.width, 43)];
    
    if([_user_Type isEqualToString:@"normal"]){
        textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 6, 211, 25)];
    }else{
        textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 6, 245, 25)];
    }
    textView.font = [UIFont fontWithName:@"Lato-Regular" size:14.0f];
    
    containerView.backgroundColor=[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:0.9];
    UIImageView *bgImg = [[UIImageView alloc]init];
    bgImg.frame = CGRectMake(0,0,containerView.frame.size.width, 48);
    [bgImg setImage:[UIImage imageNamed:@"message_type_bar.png"]];
    bgImg.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    bgImg.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [containerView addSubview:bgImg];
    
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    textView.minNumberOfLines = 1;
    textView.maxNumberOfLines = 6;
    textView.returnKeyType = UIReturnKeyDefault;
    textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor whiteColor];
    textView.placeholder = @"Type your message";
    textView.placeholderColor=[UIColor lightGrayColor];
    textView.layer.cornerRadius = 5.0;
    textView.clipsToBounds = YES;
    [self.view addSubview:containerView];
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [containerView addSubview:textView];
    
    //    UIImageView *imgview = [[UIImageView alloc]
    //                            initWithFrame:CGRectMake(containerView.frame.size.width - 35, 13, 18, 18)];
    //    [imgview setImage:[UIImage imageNamed:@"message.png"]];
    //    [imgview setContentMode:UIViewContentModeScaleAspectFit];
    //    [containerView addSubview:imgview];

    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if([_user_Type isEqualToString:@"normal"]){
        doneBtn.frame = CGRectMake(containerView.frame.size.width - 125,0, 68, 45);
    }else{
        doneBtn.frame = CGRectMake(containerView.frame.size.width - 60,0, 68, 45);
    }
    [doneBtn setImage:[UIImage imageNamed:@"send_message.png"] forState:UIControlStateNormal];
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [doneBtn addTarget:self action:@selector(send_message) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:doneBtn];
    
    if([_user_Type isEqualToString:@"normal"]){
        
        drinkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        drinkBtn.frame = CGRectMake(containerView.frame.size.width - 70,0, 35, 45);
        [drinkBtn setImage:[UIImage imageNamed:@"drink.png"] forState:UIControlStateNormal];
        drinkBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [drinkBtn addTarget:self action:@selector(send_drink) forControlEvents:UIControlEventTouchUpInside];
        [containerView addSubview:drinkBtn];
        
        UIButton *videoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        videoBtn.frame = CGRectMake(containerView.frame.size.width - 35,0, 35, 45);
        [videoBtn setImage:[UIImage imageNamed:@"video.png"] forState:UIControlStateNormal];
        videoBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [videoBtn addTarget:self action:@selector(selectVideo) forControlEvents:UIControlEventTouchUpInside];
        [containerView addSubview:videoBtn];
    }
    
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    messageArr = [[NSMutableArray alloc]init];
    archivearray = [[NSMutableArray alloc]init];
    user_details = [[NSMutableDictionary alloc]init];
    tempArr = [[NSMutableArray alloc]init];
    from_user = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]];
    //[self performSelector:@selector(serverRequest) withObject:nil afterDelay:.1];
   // timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(chat_history) userInfo:nil repeats:YES];
//    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:messageTbl];
//    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(getpreviousmessages)
                  forControlEvents:UIControlEventValueChanged];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                forKey:NSForegroundColorAttributeName];
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
    self.refreshControl.attributedTitle = attributedTitle;
    appDelegate.drink_sent = @"N";
    // Do any additional setup after loading the view from its nib.
    
}
-(void)viewWillAppear:(BOOL)animated{

    if (msg_flag == YES) {
        pageNo=0;
        [tempArr removeAllObjects];
        //[messageArr removeAllObjects];
        //[self serverRequest];
        
    }else{
        msg_flag = YES;
    }

    if([appDelegate.drink_sent isEqualToString:@"Y"]){
        appDelegate.drink_sent = @"N";
        [self DrinkSent];
    }
    [[QBChat instance] loginWithUser:[LocalStorageService shared].currentUser];
    [QBChat instance].delegate = self;
    [self session];
    [self chatLogin];
    [self serverRequest];
    [self startLoader];
    timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(session) userInfo:nil repeats:YES];
    
}
- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [refreshControl endRefreshing];
    });
    pageNo = pageNo + 1;
    //[self serverRequest];
}

-(void)session{

    [[ChatService instance] loginWithUser:[LocalStorageService shared].currentUser completionBlock:^{
        //            BOOL logged = [[QBChat instance] loginWithUser:[LocalStorageService shared].currentUser];
        //            if(logged)
        [self chatLogin];
        
    }];
    
}

#pragma mark - HPGrowingTextView events

-(BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    const char * _char = [text cStringUsingEncoding:NSUTF8StringEncoding];
    int isBackSpace = strcmp(_char, "\b");

    if (isBackSpace == 2) {
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"enter_save"] isEqualToString:@"1"]) {
//            Registration *reg = [[Registration alloc] init];
//            reg.reg_proces = self;
//            notestring = [textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
//            [reg send_message:from_user to_user:_to_id message:notestring video:picData drink_id:drink_id qty:qty message_id:@""];
            [self send_message];
        }
    }
    
    return YES;
}

#pragma mark - Keyboard events

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        // kbHgt= kbSize.height;
        
        
        CGRect frame = containerView.frame;
        frame.origin.y -= kbSize.height;
        containerView.frame = frame;
        
        frame = messageTbl.frame;
        frame.size.height -= kbSize.height;
        
        messageTbl.frame = frame;
        
        
        NSInteger rows = [messageTbl numberOfRowsInSection:0];
        if(rows > 0) {
            
            [messageTbl scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows-1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:NO];
        }
        
        
        
    }];
    
    
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.2f animations:^{
        CGRect frame = containerView.frame;
        frame.origin.y += kbSize.height;
        containerView.frame = frame;
        
        frame = messageTbl.frame;
        frame.size.height += kbSize.height;
        messageTbl.frame = frame;
    }];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    //NSLog(@"diff -- %f",diff);
    // //NSLog(@"growingTextView -- %f",growingTextView.frame.size.height);
    ////NSLog(@"height -- %f",height);
    
    CGRect r = containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    containerView.frame = r;
    
    diff=diff*-1;
    
    CGRect frame;
    frame = messageTbl.frame;
    frame.size.height -=diff;
    messageTbl.frame = frame;
    
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [messageArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*This method sets up the table-view.*/
    
    static NSString* cellIdentifier = @"messagingCell";
    
    PTSMessagingCell * cell = (PTSMessagingCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[PTSMessagingCell alloc] initMessagingCellWithReuseIdentifier:cellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView  willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:0.9]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatAbstractMessage *chatMessage = [messageArr objectAtIndex:indexPath.row];
    
    NSString *text = chatMessage.text;

    //NSString *temp = [[[messageArr objectAtIndex:indexPath.row] objectForKey:@"message"] stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    CGSize messageSize = [text sizeWithFont:[UIFont fontWithName:@"Lato" size:13.0] constrainedToSize:CGSizeMake(200, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    
    
    CGSize nameSize = [PTSMessagingCell messageSize:[user_details objectForKey:@"from_name"]];
    
    for(QBChatAttachment *attachment in chatMessage.attachments){
        if(attachment){
            return 200.0f;
        }
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"message_id LIKE[c] %@",chatMessage.ID];
    NSArray *results = [archivearray filteredArrayUsingPredicate:predicate];
    if(results.count>0){
        return 130.0f;
    }
    return nameSize.height + messageSize.height + 2*[PTSMessagingCell textMarginVertical] + 25.0f;
  
    
//    if (!([[[messageArr objectAtIndex:indexPath.row] objectForKey:@"drink_offerings_id"] isEqualToString:@"0"])) {
//        if ([from_user isEqualToString:[[messageArr objectAtIndex:indexPath.row] objectForKey:@"from"]]) {
//            return 115.0f;
//        }else{
//            return 115.0f;
//        }
//    }else if (![[[messageArr objectAtIndex:indexPath.row] objectForKey:@"video"] isEqualToString:@""]){
//        return 200.0f;
//    }else{
//        return nameSize.height + messageSize.height + 2*[PTSMessagingCell textMarginVertical] + 15.0f;
//    }
}

-(void)configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
    PTSMessagingCell* ccell = (PTSMessagingCell*)cell;
    
    QBChatAbstractMessage *chatMessage = [messageArr objectAtIndex:indexPath.row];
    
    if (chatMessage.senderID == [LocalStorageService shared].currentUser.ID) {
        ccell.sent = YES;
        NSURL   *url  = [ NSURL URLWithString:[user_details objectForKey:@"from_image"] ];
        [ccell.avatarImageView sd_setImageWithURL:url placeholderImage:nil];
        ccell.nameLabel.text = [user_details objectForKey:@"from_name"];
    } else {
        ccell.sent = NO;
        NSURL   *url  = [ NSURL URLWithString:[user_details objectForKey:@"to_image"] ];
        [ccell.avatarImageView sd_setImageWithURL:url placeholderImage:nil];
        ccell.nameLabel.text = [user_details objectForKey:@"to_name"];
    }
    ccell.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    ccell.avatarImageView.clipsToBounds = YES;
    ccell.avatarImageView.layer.cornerRadius = 3.0;
    ccell.avatarImageView.layer.borderColor=[[UIColor colorWithRed:207.0/255 green:207.0/255 blue:207.0/255 alpha:1] CGColor];
    ccell.avatarImageView.layer.masksToBounds=YES;
    
//    NSData *data = [[[messageArr objectAtIndex:indexPath.row]objectForKey:@"message"] dataUsingEncoding:NSUTF8StringEncoding];
//    NSString *strng = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
//    
//    [strng stringByReplacingOccurrencesOfString:@"&^^" withString:@"\""];
//    [strng stringByReplacingOccurrencesOfString:@"&^" withString:@"\'"];
    
    
    
    
    
    //ccell.messageLabel.text = [[[messageArr objectAtIndex:indexPath.row] objectForKey:@"message"] stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    ccell.messageLabel.text = chatMessage.text;
    
    
    //ccell.timeLabel.text = [[messageArr objectAtIndex:indexPath.row] objectForKey:@"sent"];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"MM-dd-YYYY";
    NSString *dateString = [timeFormatter stringFromDate:chatMessage.datetime];
    ccell.timeLabel.text = dateString;
    
    ccell.videoImg.image = [UIImage imageNamed:nil];
    [ccell.playBtn setImage:[UIImage imageNamed:nil] forState:UIControlStateNormal];
    for(QBChatAttachment *attachment in chatMessage.attachments){
        
        NSString *pathimage = [self getImage:[attachment.ID integerValue]];
        if([pathimage isEqualToString:@"N"]){
            
            [QBRequest TDownloadFileWithBlobID:[attachment.ID integerValue] successBlock:^(QBResponse *response, NSData *fileData) {
                [self saveImage:[attachment.ID integerValue] fileData:fileData];
                
            } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                // handle progress

            } errorBlock:^(QBResponse *response) {
                
            }];
        }else{
            ccell.msg_video = NO;
            ccell.playBtn.hidden = YES;
        }
        
        ccell.msg_video = YES;
        ccell.videoImg.hidden = NO;
        ccell.videoImg.image = [UIImage imageNamed:@"videoBG.png"];
        ccell.videoImg.clipsToBounds = YES;
        ccell.videoImg.layer.masksToBounds=YES;
        ccell.playBtn.hidden = NO;
        ccell.playBtn.tag = indexPath.row;
        [ccell.playBtn setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        [ccell.playBtn addTarget:self action:@selector(showVideo:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"message_id LIKE[c] %@",chatMessage.ID];
    NSArray *results = [archivearray filteredArrayUsingPredicate:predicate];
    if(results.count>0){
        ccell.msg_drink = YES;
        ccell.msg_video = NO;
        ccell.playBtn.hidden = YES;
        ccell.videoImg.hidden = YES;
        ccell.acceptBtn.hidden = YES;
        ccell.rejectBtn.hidden = YES;
        ccell.drinkBgImg.hidden = YES;
        
        NSLog(@"%@",archivearray);
        
        NSLog(@"%@",[[[results objectAtIndex:0] objectForKey:@"drink_offer"] objectForKey:@"image"]);
        NSURL *url2 = [NSURL URLWithString:[[[results objectAtIndex:0] objectForKey:@"drink_offer"] objectForKey:@"image"]];
        [ccell.drinkImg sd_setImageWithURL:url2 placeholderImage:nil];
        ccell.drinkImg.clipsToBounds = YES;
        ccell.drinkImg.layer.cornerRadius = 3.0;
        ccell.drinkImg.layer.borderColor=[[UIColor colorWithRed:207.0/255 green:207.0/255 blue:207.0/255 alpha:1] CGColor];
        ccell.drinkImg.layer.masksToBounds=YES;
        
        //ccell.messageLabel.text = [NSString stringWithFormat:@"%@ offered a drink",[[messageArr objectAtIndex:indexPath.row] objectForKey:@"to_name"]];
        ccell.messageLabel.text = [NSString stringWithFormat:@"offered a drink"];
        
        if (([[[[results objectAtIndex:0] objectForKey:@"drink_offer"] objectForKey:@"status_flag"] isEqualToString:@"A"]) && ([[[results objectAtIndex:0] objectForKey:@"from"] isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]])) {
            ccell.messageLabel.text = @"Accepted the drink offer";
        }else if (([[[[results objectAtIndex:0] objectForKey:@"drink_offer"] objectForKey:@"status_flag"] isEqualToString:@"D"]) && ([[[results objectAtIndex:0] objectForKey:@"from"] isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]])) {
            ccell.messageLabel.text = [NSString stringWithFormat:@"%@ said Thanks, but no thanks",[[results objectAtIndex:0] objectForKey:@"to_name"]];
        }
        
        ccell.acceptBtn.tag = [[[results objectAtIndex:0] objectForKey:@"drink_offerings_id"] integerValue];
        ccell.rejectBtn.tag = [[[results objectAtIndex:0] objectForKey:@"drink_offerings_id"] integerValue];
        [ccell.acceptBtn setImage:[UIImage imageNamed:@"accept.png"] forState:UIControlStateNormal];
        [ccell.acceptBtn addTarget:self action:@selector(AcceptDrink:) forControlEvents:UIControlEventTouchUpInside];
        [ccell.rejectBtn setImage:[UIImage imageNamed:@"thanks.png"] forState:UIControlStateNormal];
        [ccell.rejectBtn addTarget:self action:@selector(RejectDrink:) forControlEvents:UIControlEventTouchUpInside];
        drinkID = (int)indexPath.row;
        ccell.acceptBtn.hidden = YES;
        ccell.rejectBtn.hidden = YES;
        if (([[[[results objectAtIndex:0] objectForKey:@"drink_offer"] objectForKey:@"status_flag"] isEqualToString:@"P"]) && (![[[results objectAtIndex:0] objectForKey:@"from"] isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]])) {
            ccell.acceptBtn.hidden = NO;
            ccell.rejectBtn.hidden = NO;
        }else{
            ccell.acceptBtn.hidden = YES;
            ccell.rejectBtn.hidden = YES;
        }
        ccell.drinkBgImg.hidden = NO;
        [ccell.drinkBgImg setImage:[UIImage imageNamed:@"message_bg.png"]];
        ccell.drinkLabel.text = [[[results objectAtIndex:0] objectForKey:@"drink_offer"] objectForKey:@"drink_title"];
    }else{
        ccell.msg_drink = NO;
        ccell.drinkBgImg.hidden = YES;
        ccell.acceptBtn.hidden = YES;
        ccell.rejectBtn.hidden = YES;
    }
    
    
    
    
//    if (![[[messageArr objectAtIndex:indexPath.row] objectForKey:@"video"] isEqualToString:@""]){
//        ccell.msg_video = YES;
//        ccell.videoImg.hidden = NO;
//        NSURL *url1 = [NSURL URLWithString:[[messageArr objectAtIndex:indexPath.row] objectForKey:@"video_thumb"]];
//        [ccell.videoImg sd_setImageWithURL:url1 placeholderImage:nil];
//        ccell.videoImg.clipsToBounds = YES;
//        ccell.videoImg.layer.masksToBounds=YES;
//        ccell.playBtn.hidden = NO;
//        [ccell.playBtn setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
//        [ccell.playBtn addTarget:self action:@selector(showVideo) forControlEvents:UIControlEventTouchUpInside];
//        rowno = (int)indexPath.row;
//    }else{
//        ccell.msg_video = NO;
//        ccell.playBtn.hidden = YES;
//    }
//    if (!([[[messageArr objectAtIndex:indexPath.row] objectForKey:@"drink_offerings_id"] isEqualToString:@"0"])) {
//        ccell.msg_drink = YES;
//        NSURL *url2 = [NSURL URLWithString:[[[messageArr objectAtIndex:indexPath.row] objectForKey:@"drink_offer"] objectForKey:@"image"]];
//        [ccell.drinkImg sd_setImageWithURL:url2 placeholderImage:nil];
//        ccell.drinkImg.clipsToBounds = YES;
//        ccell.drinkImg.layer.cornerRadius = 3.0;
//        ccell.drinkImg.layer.borderColor=[[UIColor colorWithRed:207.0/255 green:207.0/255 blue:207.0/255 alpha:1] CGColor];
//        ccell.drinkImg.layer.masksToBounds=YES;
//        
//        //ccell.messageLabel.text = [NSString stringWithFormat:@"%@ offered a drink",[[messageArr objectAtIndex:indexPath.row] objectForKey:@"to_name"]];
//        ccell.messageLabel.text = [NSString stringWithFormat:@"offered a drink"];
//        
//        if (([[[[messageArr objectAtIndex:indexPath.row] objectForKey:@"drink_offer"] objectForKey:@"status_flag"] isEqualToString:@"A"])) {
//            ccell.messageLabel.text = @"Accepted the drink offer";
//        }else if (([[[[messageArr objectAtIndex:indexPath.row] objectForKey:@"drink_offer"] objectForKey:@"status_flag"] isEqualToString:@"D"])) {
//            ccell.messageLabel.text = [NSString stringWithFormat:@"%@ said Thanks, but no thanks",[[messageArr objectAtIndex:indexPath.row] objectForKey:@"to_name"]];
//        }
//        
//        [ccell.acceptBtn setImage:[UIImage imageNamed:@"accept.png"] forState:UIControlStateNormal];
//        [ccell.acceptBtn addTarget:self action:@selector(AcceptDrink) forControlEvents:UIControlEventTouchUpInside];
//        [ccell.rejectBtn setImage:[UIImage imageNamed:@"thanks.png"] forState:UIControlStateNormal];
//        [ccell.rejectBtn addTarget:self action:@selector(RejectDrink) forControlEvents:UIControlEventTouchUpInside];
//        drinkID = (int)indexPath.row;
//        if (([[[[messageArr objectAtIndex:indexPath.row] objectForKey:@"drink_offer"] objectForKey:@"status_flag"] isEqualToString:@"P"])) {
//            ccell.acceptBtn.hidden = NO;
//            ccell.rejectBtn.hidden = NO;
//        }else{
//            ccell.acceptBtn.hidden = YES;
//            ccell.rejectBtn.hidden = YES;
//        }
//        
//        [ccell.drinkBgImg setImage:[UIImage imageNamed:@"bubbl_small.png"]];
//        ccell.drinkLabel.text = [[[messageArr objectAtIndex:indexPath.row] objectForKey:@"drink_offer"] objectForKey:@"drink_title"];
//    }else{
//        ccell.msg_drink = NO;
//        ccell.acceptBtn.hidden = YES;
//        ccell.rejectBtn.hidden = YES;
//    }
    ccell.clipsToBounds = YES;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (![[[messageArr objectAtIndex:indexPath.row] objectForKey:@"video"] isEqualToString:@""]){
//        NSURL *url = [NSURL URLWithString:[[messageArr objectAtIndex:indexPath.row] objectForKey:@"video"]];
//        self.videoController = [[MPMoviePlayerController alloc] initWithContentURL:url];
//        self.videoController = [[MPMoviePlayerController alloc] initWithContentURL:url];
//        _videoController.controlStyle = MPMovieControlStyleDefault;
//        _videoController.shouldAutoplay = YES;
//        [self.view addSubview:_videoController.view];
//        [self.videoController setFullscreen:YES animated:YES];
//    }
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

-(void)drinkReload:(NSNotification *)notification
{
    [self serverRequest];
}
- (void)saveImage:(NSInteger)blobID fileData:(NSData *)fileData {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imageFilename = [NSString stringWithFormat:@"%ld.mp4",(long)blobID];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:imageFilename];
    [fileData writeToFile:path atomically:NO];
}
- (NSString *)getImage:(NSInteger)blobID {
    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *imageFilename = [NSString stringWithFormat:@"%ld.mp4",(long)blobID];
//    NSString *getImagePath = [documentsDirectory stringByAppendingPathComponent:imageFilename];
//    UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
    
    
    
    NSString *realpath=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent: [NSString stringWithFormat:@"%ld.mp4",(long)blobID]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:realpath]){
        

        NSLog(@"find file");
        return realpath;
    }
    else{
        NSLog(@"not found");
        return @"N";
    }
    
    
    
    //return img;
}

-(void)getpreviousmessages{
    
    pagenation = YES;
    QBChatDialogResult *res = (QBChatDialogResult *)quickresult;
    QBChatDialog *dialog = res.dialog;
    NSLog(@"Dialog: %@", dialog);
    NSMutableDictionary *extendedRequest = [NSMutableDictionary new];
    extendedRequest[@"limit"] = @(50);
    extendedRequest[@"sort_desc"] = @"date_sent";
    [QBChat messagesWithDialogID:dialog.ID extendedRequest:extendedRequest delegate:self];
}


-(void)chat_history{
    pageNo = 0;
    //[messageArr removeAllObjects];
    [self serverRequest];
}
-(void)AcceptDrink:(id)sender{
    ServerRequests *ser_req = [[ServerRequests alloc] init];
    ser_req.server_req_proces = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"updateDrinksStatus\", \"parameters\": {\"status_flag\": \"%@\",\"drink_id\": \"%ld\"},\"token\":\"\"}", @"A",(long)[sender tag]];
    NSLog(@"%@",postdata);
    drink_push = @"accepted the drink offer";
    response_from = @"accept_reject_drink";
    [self startLoader];
    [ser_req sendServerRequests:postdata];
}
-(void)RejectDrink:(id)sender{
    ServerRequests *ser_req = [[ServerRequests alloc] init];
    ser_req.server_req_proces = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"updateDrinksStatus\", \"parameters\": {\"status_flag\": \"%@\",\"drink_id\": \"%ld\"},\"token\":\"\"}", @"D",(long)[sender tag]];
    NSLog(@"%@",postdata);
    drink_push = @"said Thanks, but no thanks";
    response_from = @"accept_reject_drink";
    [self startLoader];
    [ser_req sendServerRequests:postdata];
}
-(IBAction)showVideo:(id)sender{
    //video_view.backgroundColor=[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.5];
    //video_view.hidden = NO;
   // NSURL *url = [NSURL URLWithString:[[messageArr objectAtIndex:1] objectForKey:@"video"]];
   // self.videoController = [[MPMoviePlayerController alloc] initWithContentURL:url];
//    self.videoController.view.frame = self.view.bounds;
//    [self.videoController.view setFrame:CGRectMake (video_view.frame.origin.x+30, video_view.frame.origin.y+155,260,150)];
//    //[video_view addSubview:self.videoController.view];
//    [self.videoController play];
    
    
    msg_flag = NO;
//    NSURL *url = [NSURL URLWithString:[[messageArr objectAtIndex:rowno] objectForKey:@"video"]];
//    self.videoController = [[MPMoviePlayerController alloc] initWithContentURL:url];
//    self.videoController = [[MPMoviePlayerController alloc] initWithContentURL:url];
//    _videoController.controlStyle = MPMovieControlStyleDefault;
//    _videoController.shouldAutoplay = YES;
//    [self.view addSubview:_videoController.view];
//    [self.videoController setFullscreen:YES animated:YES];
    [self startLoader];
    rowno = [sender tag];
    QBChatAbstractMessage *chatMessage = [messageArr objectAtIndex:rowno];
    for(QBChatAttachment *attachment in chatMessage.attachments){
        
        NSString *pathimage = [self getImage:[attachment.ID integerValue]];
        
        //if([pathimage isEqualToString:@"N"]){
            
            [QBRequest TDownloadFileWithBlobID:[attachment.ID integerValue] successBlock:^(QBResponse *response, NSData *fileData) {
                // NSURL *obj = [NSData data]
                //        self.videoController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:@"/var/mobile/Containers/Data/Application/C09458E4-6C86-47EC-AD0B-8F7BB31454A2/Documents/1064217.mp4" isDirectory:YES]];
                //        _videoController.controlStyle = MPMovieControlStyleDefault;
                //        _videoController.shouldAutoplay = YES;
                //        [self.view addSubview:_videoController.view];
                //        [self.videoController setFullscreen:YES animated:YES];
                
                [self stopLoader];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *path = [documentsDirectory stringByAppendingPathComponent:@"myMove.mp4"];
                [[NSFileManager defaultManager] createFileAtPath:path contents:fileData attributes:nil];
                NSURL *moveUrl = [NSURL fileURLWithPath:path];
                self.videoController = [[MPMoviePlayerController alloc] initWithContentURL:moveUrl];
                _videoController.controlStyle = MPMovieControlStyleDefault;
                _videoController.shouldAutoplay = YES;
                [self.view addSubview:_videoController.view];
                [self.videoController setFullscreen:YES animated:YES];
                
                
            } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                
            } errorBlock:^(QBResponse *response) {
                
            }];
        
//        }else{
//            
//        }
        
    
    }
}

-(IBAction)close_video:(id)sender{
    video_view.hidden = YES;
}

-(void)send_drink
{
    Drinks *drink =  [[Drinks alloc]initWithNibName:@"Drinks" bundle:nil];
    drink.to_id = _to_id;
    [self presentViewController:drink animated:YES completion:nil];
}
-(void)selectVideo
{
    
    imagePicker=[[UIImagePickerController alloc]init];
    
    imagePicker.delegate=self;
    
    imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum ;
    
    imagePicker.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    [self presentViewController:imagePicker animated:YES completion:NULL];
    
    
    imagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
    NSArray *sourceTypes = [UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
    if (![sourceTypes containsObject:(NSString *)kUTTypeMovie ])
    {
        NSLog(@"no video");
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo
{
    
    [[picker parentViewController] dismissModalViewControllerAnimated:YES];
    
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    [self convertMP4:info];
    picData = [NSData dataWithContentsOfURL:videoURL];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    //[self startLoader];
//    Registration *reg = [[Registration alloc] init];
//    reg.reg_proces = self;
//    notestring = [textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
//    [reg send_message:from_user to_user:_to_id message:notestring video:picData drink_id:drink_id qty:qty];
    
    
    
   
    
    
}

-(void)sendingVideo:(NSData *)vdata{
    
    picData = vdata;
    QBChatMessage *tempmessage = [QBChatMessage message];
    QBChatAttachment *tempattachment = QBChatAttachment.new;
    tempattachment.type = @"video";
    // use 'ID' property to store an ID of a file in Content or CustomObjects modules
    [tempmessage setAttachments:@[tempattachment]];
    tempmessage.recipientID = _recp_quickblox_id;
    NSLog(@"message.recipientID : %lu", (unsigned long)tempmessage.recipientID );
    //[self.dialog recipientID];
    tempmessage.senderID = [LocalStorageService shared].currentUser.ID;
    NSLog(@"message.senderID : %lu", (unsigned long)tempmessage.senderID );
    
    //    [messageArr addObject:tempmessage];
    //    [messageTbl reloadData];
    //    if(messageArr.count >0)
    //        [messageTbl scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messageArr count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    [QBRequest TUploadFile:picData fileName:@"Great Video" contentType:@"video/mp4" isPublic:NO successBlock:^(QBResponse *response, QBCBlob *uploadedBlob) {
        //    [QBRequest TUploadFile:picData fileName:@"pic1.jpeg" contentType:@"pic1.jpeg" isPublic:NO successBlock:^(QBResponse *response, QBCBlob *uploadedBlob) {
        NSUInteger uploadedFileID = uploadedBlob.ID;
        
        // Create chat message with attach
        //
        QBChatMessage *message = [QBChatMessage message];
        message.text = @"Sent a video";
        QBChatAttachment *attachment = QBChatAttachment.new;
        attachment.type = @"video";
        attachment.ID = [NSString stringWithFormat:@"%lu", (unsigned long)uploadedFileID]; // use 'ID' property to store an ID of a file in Content or CustomObjects modules
        [message setAttachments:@[attachment]];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"save_to_history"] = @YES;
        [message saveWhenDeliveredToCustomObjectsWithClassName:@"ChatMessage" additionalParameters:nil];
        [message setCustomParameters:params];
        //if(textView.text.length>0)
        //   message.text = textView.text;
        // send message
        message.recipientID = _recp_quickblox_id;
        NSLog(@"message.recipientID : %lu", (unsigned long)message.recipientID );
        //[self.dialog recipientID];
        message.senderID = [LocalStorageService shared].currentUser.ID;
        NSLog(@"message.senderID : %lu", (unsigned long)message.senderID );
        
        [[ChatService instance] sendMessage:message];
        // save message
        
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *imageFilename = [NSString stringWithFormat:@"%ld.mp4",(long)attachment.ID];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:imageFilename];
        [picData writeToFile:path atomically:NO];
        
        if(messageArr.count>0)
            [messageArr removeLastObject];
        [messageArr addObject:message];
        [messageTbl reloadData];
        if(messageArr.count >0)
            [messageTbl scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messageArr count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        // Send push notifications....
        
        QBMEvent *event = [QBMEvent event];
        event.notificationType = QBMNotificationTypePush;
        event.usersIDs = [NSString stringWithFormat:@"%ld",(long)_recp_quickblox_id];
        event.isDevelopmentEnvironment = [QBSettings isUseProductionEnvironmentForPushNotifications];
        event.type = QBMEventTypeOneShot;
        // custom params
        NSMutableDictionary  *dictPush=[NSMutableDictionary  dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@: %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"fullname"],message.text], @"message", nil];
        [dictPush setObject:@"" forKey:@"ios_badge"];
        [dictPush setObject:@"msg" forKey:@"type"];
        [dictPush setObject:@"default" forKey:@"ios_sound"];
        [dictPush setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_quickblox"] forKey:@"recp_quickblox_id"];
        [dictPush setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"] forKey:@"to_id"];
        [dictPush setObject:@"normal" forKey:@"user_Type"];
        
        //
        NSError *error = nil;
        NSData *sendData = [NSJSONSerialization dataWithJSONObject:dictPush options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:sendData encoding:NSUTF8StringEncoding];
        //
        event.message = jsonString;
        
        
        [QBRequest createEvent:event successBlock:^(QBResponse *response , NSArray *event){
            
        }errorBlock:^(QBResponse *response)
         {
             QBMEvent *event = [QBMEvent event];
             event.notificationType = QBMNotificationTypePush;
             event.usersIDs = [NSString stringWithFormat:@"%ld",(long)_recp_quickblox_id];
             event.isDevelopmentEnvironment = ![QBSettings isUseProductionEnvironmentForPushNotifications];
             event.type = QBMEventTypeOneShot;
             NSMutableDictionary  *dictPush=[NSMutableDictionary  dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@: Sent a video",[[NSUserDefaults standardUserDefaults]objectForKey:@"fullname"]], @"message", nil];
             [dictPush setObject:@"" forKey:@"ios_badge"];
             [dictPush setObject:@"msg" forKey:@"type"];
             [dictPush setObject:@"default" forKey:@"ios_sound"];
             [dictPush setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_quickblox"] forKey:@"recp_quickblox_id"];
             [dictPush setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"] forKey:@"to_id"];
             [dictPush setObject:@"normal" forKey:@"user_Type"];
             
             //
             NSError *error = nil;
             NSData *sendData = [NSJSONSerialization dataWithJSONObject:dictPush options:NSJSONWritingPrettyPrinted error:&error];
             NSString *jsonString = [[NSString alloc] initWithData:sendData encoding:NSUTF8StringEncoding];
             //
             event.message = jsonString;
             
             
             [QBRequest createEvent:event successBlock:^(QBResponse *response , NSArray *event){
                 
             }errorBlock:^(QBResponse *response)
              {
                  
              }];
         }];
        
        
        //        NSMutableDictionary *payload = [NSMutableDictionary dictionary];
        //
        //        NSMutableDictionary *aps = [NSMutableDictionary dictionary];
        //        [aps setObject:@"default" forKey:QBMPushMessageSoundKey];
        //        NSString *pushmessagetext = [NSString stringWithFormat:@"%@: Sent a video",[[NSUserDefaults standardUserDefaults]objectForKey:@"fullname"]];
        //        [aps setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_quickblox"] forKey:@"recp_quickblox_id"];
        //        [aps setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"] forKey:@"to_id"];
        //        [aps setObject:@"normal" forKey:@"user_Type"];
        //        [aps setObject:pushmessagetext forKey:QBMPushMessageAlertKey];
        //        [aps setObject:[NSString stringWithFormat:@"%lu",(unsigned long)message.senderID] forKey:QBMPushMessageAlertBodyKey];
        //        // [aps setObject:message forKey:QBMEventMessagePayloadKey];
        //        [payload setObject:aps forKey:QBMPushMessageApsKey];
        //
        //        QBMPushMessage *pushmessage = [[QBMPushMessage alloc] initWithPayload:payload];
        //        [QBRequest sendPush:pushmessage toUsers:[NSString stringWithFormat:@"%ld",(long)_recp_quickblox_id] successBlock:^(QBResponse *response, QBMEvent *event) {
        //
        //            // Successful response with event
        //
        //        } errorBlock:^(QBError *error) {
        //
        //            // Handle error
        //
        //        }];
        
        
        
        
        //        if(messageArr.count >0)
        //            [messageTbl scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messageArr count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
        // handle progress
        
        picData = nil;
    } errorBlock:^(QBResponse *response) {
        NSLog(@"error: %@", response.error);
        
        picData = nil;
    }];
    
}

-(void)convertMP4:(NSDictionary*)info

{
    
    NSString *videoPath1 = @"";
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo)
        
    {
        
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        videoPath1 =[NSString stringWithFormat:@"%@/tempv.mov",docDir];
        
        NSData *videoData = [NSData dataWithContentsOfURL:[info objectForKey:UIImagePickerControllerMediaURL]];
        
        [videoData writeToFile:videoPath1 atomically:NO];
        
    }
    
    CFRelease((__bridge CFStringRef)(mediaType));//CRA
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:videoPath1] options:nil];
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality])
        
    {
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetPassthrough];
        
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSDate *currentDataTime=[NSDate date];
        
        NSString* videoPath = [NSString stringWithFormat:@"%@/%@.mp4", [paths objectAtIndex:0],currentDataTime];
        
        mp4VideoPath = videoPath;
        
        exportSession.outputURL = [NSURL fileURLWithPath:videoPath];
        
        NSLog(@"videopath of your mp4 file = %@",videoPath);  // PATH OF YOUR .mp4 FILE
        
        exportSession.outputFileType = AVFileTypeMPEG4;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            [[NSFileManager defaultManager]removeItemAtPath:videoPath1 error:nil];
            
            switch ([exportSession status]) {
                    
                case AVAssetExportSessionStatusFailed:
                    
                    NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                    
                    //[Utils showAlertView:APP_NAME message:@"Failed to save video.Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    
                    break;
                    
                case AVAssetExportSessionStatusCancelled:
                    
                    NSLog(@"Export canceled");
                    
                    break;
                    
                case AVAssetExportSessionStatusCompleted:
                    
                    NSLog(@"%@",mp4VideoPath);
                    
                    picData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:mp4VideoPath]];
                    
                    //[self ownerWantstoSendData];
                    
                    [self sendingVideo:picData];
                    
                    NSLog(@"Export completed");
                    
                    break;
                    
                default:
                    
                    break;
                    
            }
            
        }];
        
    }
    
}


-(void)DrinkSent{
    QBChatMessage *message = [[QBChatMessage alloc] init];
    message.text = @"Sent a drink";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"save_to_history"] = @YES;
    [message setCustomParameters:params];
    
    // send message
    message.recipientID = _recp_quickblox_id;
    message.senderID = [LocalStorageService shared].currentUser.ID;
    
    NSLog(@"message.recipientID---  %lu   message.senderID %lu ",(unsigned long)message.recipientID, (unsigned long)message.senderID);
    
    [[ChatService instance] sendMessage:message];
    sendingDrink = YES;
    //send drink to our server
    Registration *reg = [[Registration alloc] init];
    reg.reg_proces = self;
    [reg send_message:appDelegate.drinkFrom to_user:appDelegate.drinkTo message:@"" video:picData drink_id:appDelegate.send_drinkID qty:@"1" message_id:message.ID];
    appDelegate.drinkFrom = @"";
    appDelegate.drinkTo = @"";
    appDelegate.send_drinkID = @"";
    
    
    // Send push notifications....
    QBMEvent *event = [QBMEvent event];
    event.notificationType = QBMNotificationTypePush;
    event.usersIDs = [NSString stringWithFormat:@"%ld",(long)_recp_quickblox_id];
    event.isDevelopmentEnvironment = [QBSettings isUseProductionEnvironmentForPushNotifications];
    event.type = QBMEventTypeOneShot;
    // custom params
    NSMutableDictionary  *dictPush=[NSMutableDictionary  dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@: %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"fullname"],message.text], @"message", nil];
    [dictPush setObject:@"" forKey:@"ios_badge"];
    [dictPush setObject:@"msg" forKey:@"type"];
    [dictPush setObject:@"default" forKey:@"ios_sound"];
    [dictPush setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_quickblox"] forKey:@"recp_quickblox_id"];
    [dictPush setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"] forKey:@"to_id"];
    [dictPush setObject:@"normal" forKey:@"user_Type"];
    
    //
    NSError *error = nil;
    NSData *sendData = [NSJSONSerialization dataWithJSONObject:dictPush options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:sendData encoding:NSUTF8StringEncoding];
    //
    event.message = jsonString;
    
    
    [QBRequest createEvent:event successBlock:^(QBResponse *response , NSArray *event){
        
    }errorBlock:^(QBResponse *response)
     {
         QBMEvent *event = [QBMEvent event];
         event.notificationType = QBMNotificationTypePush;
         event.usersIDs = [NSString stringWithFormat:@"%ld",(long)_recp_quickblox_id];
         event.isDevelopmentEnvironment = ![QBSettings isUseProductionEnvironmentForPushNotifications];
         event.type = QBMEventTypeOneShot;
         NSMutableDictionary  *dictPush=[NSMutableDictionary  dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@: %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"fullname"],message.text], @"message", nil];
         [dictPush setObject:@"" forKey:@"ios_badge"];
         [dictPush setObject:@"msg" forKey:@"type"];
         [dictPush setObject:@"default" forKey:@"ios_sound"];
         [dictPush setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_quickblox"] forKey:@"recp_quickblox_id"];
         [dictPush setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"] forKey:@"to_id"];
         [dictPush setObject:@"normal" forKey:@"user_Type"];
         
         //
         NSError *error = nil;
         NSData *sendData = [NSJSONSerialization dataWithJSONObject:dictPush options:NSJSONWritingPrettyPrinted error:&error];
         NSString *jsonString = [[NSString alloc] initWithData:sendData encoding:NSUTF8StringEncoding];
         //
         event.message = jsonString;
         
         
         [QBRequest createEvent:event successBlock:^(QBResponse *response , NSArray *event){
             
         }errorBlock:^(QBResponse *response)
          {
              
          }];
     }];
    
    
//    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
//
//    NSMutableDictionary *aps = [NSMutableDictionary dictionary];
//
//    [aps setObject:@"default" forKey:QBMPushMessageSoundKey];
//    
//    NSString *pushmessagetext = [NSString stringWithFormat:@"%@: %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"fullname"],message.text];
//    [aps setObject:pushmessagetext forKey:QBMPushMessageAlertKey];
//    [aps setObject:@"Drink" forKey:@"type"];
//    [aps setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_quickblox"] forKey:@"recp_quickblox_id"];
//    [aps setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"] forKey:@"to_id"];
//    [aps setObject:@"normal" forKey:@"user_Type"];
//    [aps setObject:[NSString stringWithFormat:@"%lu",(unsigned long)message.senderID] forKey:QBMPushMessageAlertBodyKey];
//    push_id = (unsigned long)message.senderID;
//    //  [aps setObject:message forKey:QBMEventMessagePayloadKey];
//    
//    [payload setObject:aps forKey:QBMPushMessageApsKey];
//    
//    QBMPushMessage *pushmessage = [[QBMPushMessage alloc] initWithPayload:payload];
//    [QBRequest sendPush:pushmessage toUsers:[NSString stringWithFormat:@"%ld",(long)_recp_quickblox_id] successBlock:^(QBResponse *response, QBMEvent *event) {
//        
//        // Successful response with event
//        
//    } errorBlock:^(QBError *error) {
//        
//        // Handle error
//        
//    }];
    
    
    [messageArr addObject:message];
//    if(messageArr.count >0)
//        [messageTbl scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messageArr count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    // Clean text field
    [textView setText:nil];
}

-(void)send_message{
    
    if([[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]isEqualToString:@""])
    {
        
    }else{
//        //[self startLoader];
//        Registration *reg = [[Registration alloc] init];
//        reg.reg_proces = self;
//        //NSData *data = [textView.text dataUsingEncoding:NSNonLossyASCIIStringEncoding];
//        //NSString *string1 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        notestring = [textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
//        send_flag = YES;
//        [reg send_message:from_user to_user:_to_id message:notestring video:picData drink_id:drink_id qty:qty message_id:@""];
        
        
        // create a message
        QBChatMessage *message = [[QBChatMessage alloc] init];
        message.text = textView.text;
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"save_to_history"] = @YES;
        [message setCustomParameters:params];
        
        // send message
        message.recipientID = _recp_quickblox_id;
        message.senderID = [LocalStorageService shared].currentUser.ID;
        
        NSLog(@"message.recipientID---  %lu   message.senderID %lu ",(unsigned long)message.recipientID, (unsigned long)message.senderID);
        
        [[ChatService instance] sendMessage:message];
        
        // Send push notifications....
        
        QBMEvent *event = [QBMEvent event];
        event.notificationType = QBMNotificationTypePush;
        event.usersIDs = [NSString stringWithFormat:@"%ld",(long)_recp_quickblox_id];
        event.isDevelopmentEnvironment = [QBSettings isUseProductionEnvironmentForPushNotifications];
        event.type = QBMEventTypeOneShot;
        
        
//        NSMutableDictionary *payload = [NSMutableDictionary dictionary];
//        
//        NSMutableDictionary *aps = [NSMutableDictionary dictionary];
//        
//        [aps setObject:@"default" forKey:QBMPushMessageSoundKey];
//        
//        NSString *pushmessagetext = [NSString stringWithFormat:@"%@: %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"fullname"],message.text];
//        [aps setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_quickblox"] forKey:@"recp_quickblox_id"];
//        [aps setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"] forKey:@"to_id"];
//        [aps setObject:@"normal" forKey:@"user_Type"];
//        [aps setObject:pushmessagetext forKey:QBMPushMessageAlertKey];
//        [aps setObject:[NSString stringWithFormat:@"%lu",(unsigned long)message.senderID] forKey:QBMPushMessageAlertBodyKey];
//        //  [aps setObject:message forKey:QBMEventMessagePayloadKey];
//        
//        [payload setObject:aps forKey:QBMPushMessageApsKey];
//        
//        QBMPushMessage *pushmessage = [[QBMPushMessage alloc] initWithPayload:payload];
//        [QBRequest sendPush:pushmessage toUsers:[NSString stringWithFormat:@"%ld",(long)_recp_quickblox_id] successBlock:^(QBResponse *response, QBMEvent *event) {
//            
//            // Successful response with event
//            
//        } errorBlock:^(QBError *error) {
//            
//            // Handle error
//            
//        }];

        //
        // custom params
        NSMutableDictionary  *dictPush=[NSMutableDictionary  dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@: %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"fullname"],message.text], @"message", nil];
        [dictPush setObject:@"" forKey:@"ios_badge"];
        [dictPush setObject:@"msg" forKey:@"type"];
        [dictPush setObject:@"default" forKey:@"ios_sound"];
        [dictPush setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_quickblox"] forKey:@"recp_quickblox_id"];
        [dictPush setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"] forKey:@"to_id"];
        [dictPush setObject:@"normal" forKey:@"user_Type"];
        
        //
        NSError *error = nil;
        NSData *sendData = [NSJSONSerialization dataWithJSONObject:dictPush options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:sendData encoding:NSUTF8StringEncoding];
        //
        event.message = jsonString;
       
        
        [QBRequest createEvent:event successBlock:^(QBResponse *response , NSArray *event){
             
         }errorBlock:^(QBResponse *response)
         {
             QBMEvent *event = [QBMEvent event];
             event.notificationType = QBMNotificationTypePush;
             event.usersIDs = [NSString stringWithFormat:@"%ld",(long)_recp_quickblox_id];
             event.isDevelopmentEnvironment = ![QBSettings isUseProductionEnvironmentForPushNotifications];
             event.type = QBMEventTypeOneShot;
             NSMutableDictionary  *dictPush=[NSMutableDictionary  dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@: %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"fullname"],message.text], @"message", nil];
             [dictPush setObject:@"" forKey:@"ios_badge"];
             [dictPush setObject:@"msg" forKey:@"type"];
             [dictPush setObject:@"default" forKey:@"ios_sound"];
             [dictPush setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_quickblox"] forKey:@"recp_quickblox_id"];
             [dictPush setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"] forKey:@"to_id"];
             [dictPush setObject:@"normal" forKey:@"user_Type"];
             
             //
             NSError *error = nil;
             NSData *sendData = [NSJSONSerialization dataWithJSONObject:dictPush options:NSJSONWritingPrettyPrinted error:&error];
             NSString *jsonString = [[NSString alloc] initWithData:sendData encoding:NSUTF8StringEncoding];
             //
             event.message = jsonString;
             
             
             [QBRequest createEvent:event successBlock:^(QBResponse *response , NSArray *event){
                 
             }errorBlock:^(QBResponse *response)
              {
                  
              }];
         }];
        
        [messageArr addObject:message];
        no_msg.hidden = YES;
        // Reload table
        [messageTbl reloadData];
        if(messageArr.count >0)
            [messageTbl scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messageArr count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        // Clean text field
        [textView setText:nil];
        
        
    }
}
-(void) RegistrationProcessFinish:(NSString *) userdetails{
    
    responseDetails = [userdetails JSONValue];
    
    NSLog(@"userDet =-=======%@",responseDetails);
    
    //[self stopLoader];
    
    if ([[responseDetails objectForKey:@"status"] isEqualToString:@"true"]) {
        pageNo = 0;
        [self serverRequest];
        textView.text = @"";
//        CGPoint offset = CGPointMake(0, messageTbl.contentSize.height - messageTbl.frame.size.height);
//        [messageTbl setContentOffset:offset animated:NO];
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
//- (void)scrollViewDidScroll:(UIScrollView *)ScrollView {
//    
//    if (ScrollView ==messageTbl) {
//        
//        CGFloat height = ScrollView.frame.size.height;
//        
//        CGFloat contentYoffset = ScrollView.contentOffset.y;
//        
//        
//        
//        CGFloat distanceFromBottom = ScrollView.contentSize.height - contentYoffset;
//        
//        if (list_flag == NO) {
//            if(distanceFromBottom <= height)
//            {
//                list_flag = YES;
//                //            NSLog(@"end of the table");
//                if(scrol_flag == NO){
//                    pageNo = pageNo + 1;
//                    scrol_flag = YES;
//                    [self serverRequest];
//                }
//                
//            }
//            else
//            {
//                scrol_flag = NO;
//                //page = 0;
//            }
//        }
//    }
//    
//}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        [textView resignFirstResponder];
        textView.text = @"";
        pageNo = 0;
        //[messageArr removeAllObjects];
        [self serverRequest];
    }
}
-(IBAction)back:(id)sender{
    [self dismissViewControllerAnimated:YES completion:Nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)serverRequest{
    NSString *user_id = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]];
    ServerRequests *ser_req = [[ServerRequests alloc] init];
    ser_req.server_req_proces = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"MessageDetails\", \"parameters\": {\"from_id\": \"%@\",\"to_id\": \"%@\",\"pageNo\": \"%d\"},\"token\":\"\"}", user_id,_to_id,pageNo];
    NSLog(@"%@",postdata);
    //[self startLoader];
    [ser_req sendServerRequests:postdata];
    
}
-(void) ServerRequestProcessFinish:(NSString *) serverResponse{
    //[self stopLoader];
    
    if ([response_from isEqualToString:@"accept_reject_drink"]) {
        [self stopLoader];
        response_from = @"";
        pageNo=0;
        [tempArr removeAllObjects];
        [archivearray removeAllObjects];
        
        
        // Send push notifications....
        QBMEvent *event = [QBMEvent event];
        event.notificationType = QBMNotificationTypePush;
        event.usersIDs = [NSString stringWithFormat:@"%ld",(long)_recp_quickblox_id];
        event.isDevelopmentEnvironment = [QBSettings isUseProductionEnvironmentForPushNotifications];
        event.type = QBMEventTypeOneShot;
        // custom params
        NSMutableDictionary  *dictPush=[NSMutableDictionary  dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@: %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"fullname"],drink_push], @"message", nil];
        [dictPush setObject:@"" forKey:@"ios_badge"];
        [dictPush setObject:@"accept_reject_drink" forKey:@"type"];
        [dictPush setObject:@"default" forKey:@"ios_sound"];
        [dictPush setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_quickblox"] forKey:@"recp_quickblox_id"];
        [dictPush setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"] forKey:@"to_id"];
        [dictPush setObject:@"normal" forKey:@"user_Type"];
        
        //
        NSError *error = nil;
        NSData *sendData = [NSJSONSerialization dataWithJSONObject:dictPush options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:sendData encoding:NSUTF8StringEncoding];
        //
        event.message = jsonString;
        
        
        [QBRequest createEvent:event successBlock:^(QBResponse *response , NSArray *event){
            
        }errorBlock:^(QBResponse *response)
         {
             QBMEvent *event = [QBMEvent event];
             event.notificationType = QBMNotificationTypePush;
             event.usersIDs = [NSString stringWithFormat:@"%ld",(long)_recp_quickblox_id];
             event.isDevelopmentEnvironment = ![QBSettings isUseProductionEnvironmentForPushNotifications];
             event.type = QBMEventTypeOneShot;
             NSMutableDictionary  *dictPush=[NSMutableDictionary  dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@: %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"fullname"],drink_push], @"message", nil];
             [dictPush setObject:@"" forKey:@"ios_badge"];
             [dictPush setObject:@"accept_reject_drink" forKey:@"type"];
             [dictPush setObject:@"default" forKey:@"ios_sound"];
             [dictPush setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_quickblox"] forKey:@"recp_quickblox_id"];
             [dictPush setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"] forKey:@"to_id"];
             [dictPush setObject:@"normal" forKey:@"user_Type"];
             
             //
             NSError *error = nil;
             NSData *sendData = [NSJSONSerialization dataWithJSONObject:dictPush options:NSJSONWritingPrettyPrinted error:&error];
             NSString *jsonString = [[NSString alloc] initWithData:sendData encoding:NSUTF8StringEncoding];
             //
             event.message = jsonString;
             
             
             [QBRequest createEvent:event successBlock:^(QBResponse *response , NSArray *event){
                 
             }errorBlock:^(QBResponse *response)
              {
                  
              }];
         }];
        
        
//        // Send push notifications....
//        NSMutableDictionary *payload = [NSMutableDictionary dictionary];
//        
//        NSMutableDictionary *aps = [NSMutableDictionary dictionary];
//        
//        [aps setObject:@"default" forKey:QBMPushMessageSoundKey];
//        
//        NSString *pushmessagetext = [NSString stringWithFormat:@"%@ %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"fullname"],drink_push];
//        [aps setObject:pushmessagetext forKey:QBMPushMessageAlertKey];
//        [aps setObject:@"accept_reject_drink" forKey:@"type"];
//        [aps setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_quickblox"] forKey:@"recp_quickblox_id"];
//        [aps setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"] forKey:@"to_id"];
//        [aps setObject:@"normal" forKey:@"user_Type"];
//        [aps setObject:[NSString stringWithFormat:@"%lu",push_id] forKey:QBMPushMessageAlertBodyKey];
//        //  [aps setObject:message forKey:QBMEventMessagePayloadKey];
//        
//        [payload setObject:aps forKey:QBMPushMessageApsKey];
//        
//        QBMPushMessage *pushmessage = [[QBMPushMessage alloc] initWithPayload:payload];
//        [QBRequest sendPush:pushmessage toUsers:[NSString stringWithFormat:@"%ld",(long)_recp_quickblox_id] successBlock:^(QBResponse *response, QBMEvent *event) {
//            
//            // Successful response with event
//            
//        } errorBlock:^(QBError *error) {
//            
//            // Handle error
//            
//        }];
        
        
        [self serverRequest];
    }else{
        if (![[[serverResponse JSONValue] objectForKey:@"details"] isEqual:[NSNull null]]) {
            NSLog(@"%@",[[serverResponse JSONValue] objectForKey:@"to_room_status"]);
            if (([[[serverResponse JSONValue] objectForKey:@"to_room_status"] isEqualToString:@"Y"]) && ([[[serverResponse JSONValue] objectForKey:@"from_room_status"] isEqualToString:@"Y"])) {
                drinkBtn.hidden = NO;
            }else{
                drinkBtn.hidden = YES;
            }
            
            tempArr  = [[serverResponse JSONValue] objectForKey:@"details"];
            user_details = [[serverResponse JSONValue]objectForKey:@"user_details"];
            list_flag = NO;
            
            
            if(send_flag == YES){
                [messageArr removeAllObjects];
                send_flag = NO;
            }

            
            if ([tempArr count] > 0)
            {
                [tempArr addObjectsFromArray:archivearray];
                archivearray = [tempArr mutableCopy];
                [messageTbl reloadData];
                
                if(messageArr.count >0)
                    [messageTbl scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messageArr count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                
//                CGPoint offset = CGPointMake(0, messageTbl.contentSize.height - messageTbl.frame.size.height);
//                [messageTbl setContentOffset:offset animated:YES];
            }
            
            
            //[tempArray removeAllObjects];
            
            
            NSLog(@"maindict---%@",messageArr);
            //        [messageTbl reloadData];
            //        th
            //        CGPoint offset = CGPointMake(0, messageTbl.contentSize.height - messageTbl.frame.size.height);
            //        [messageTbl setContentOffset:offset animated:YES];
            
        }else{
            pageNo = 0;
        }
   
    }

}

- (void)chatLogin
{
    QBChatDialog *chatDialog = [QBChatDialog new];
    //chatDialog.name =@"Chat With Me";
    chatDialog.occupantIDs = @[@((int)_recp_quickblox_id)];
    chatDialog.type = QBChatDialogTypePrivate;
    [QBChat createDialog:chatDialog delegate:self];
}

#pragma mark
#pragma mark Chat Notifications

- (void)chatDidReceiveMessageNotification:(NSNotification *)notification{
    
    QBChatMessage *message = notification.userInfo[kMessage];
    if(message.senderID != _recp_quickblox_id){
        return;
    }
    else{
        // save message
        [messageArr addObject:message];
        no_msg.hidden = YES;
//        if (sendingDrink == YES) {
//            sendingDrink = NO;
//            
//        }
        [self serverRequest];
        // Reload table
        [messageTbl reloadData];
        if(messageArr.count > 0){
            [messageTbl scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messageArr count] - 1 inSection:0]
                                          atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
}

- (void)chatRoomDidReceiveMessageNotification:(NSNotification *)notification{
    QBChatMessage *message = notification.userInfo[kMessage];
    NSString *roomJID = notification.userInfo[kRoomJID];
    
    if(![self.chatRoom.JID isEqualToString:roomJID]){
        return;
    }
    
    // save message
    [messageArr addObject:message];
    no_msg.hidden = YES;
    // Reload table
    [messageTbl reloadData];
    if(messageArr.count > 0){
        [messageTbl scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messageArr count] - 1 inSection:0]
                                      atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}


#pragma mark -
#pragma mark QBActionStatusDelegate

- (void)completedWithResult:(Result *)result
{
    //    if(result){
    
    if (result.success && [result isKindOfClass:[QBChatDialogResult class]])
    {
        quickresult = result;
        QBChatDialogResult *res = (QBChatDialogResult *)result;
        QBChatDialog *dialog = res.dialog;
        NSLog(@"Dialog: %@", dialog);
        NSMutableDictionary *extendedRequest = [NSMutableDictionary new];
        extendedRequest[@"limit"] = @(1000);
        extendedRequest[@"sort_desc"] = @"date_sent";
        [QBChat messagesWithDialogID:dialog.ID extendedRequest:extendedRequest delegate:self];
        
    }
    else if (result.success && [result isKindOfClass:QBChatHistoryMessageResult.class]) {
        
        [self stopLoader];
        QBChatHistoryMessageResult *res = (QBChatHistoryMessageResult *)result;
        NSArray* reversed  = res.messages;
        NSArray *historymessages = [[reversed reverseObjectEnumerator] allObjects];
        //        if(pagenation == NO){
        [messageArr removeAllObjects];
        //        }
        [messageArr addObjectsFromArray:[historymessages mutableCopy]];
        [self.refreshControl endRefreshing];
        //
        //        todaystartsindex = -1;
        //        for(int i = 0; i<self.messages.count;i++){
        //
        //            QBChatAbstractMessage *chatMessage = [self.messages objectAtIndex:i];
        //            NSCalendar* calendar = [NSCalendar currentCalendar];
        //            unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
        //            NSDateComponents* comp1 = [calendar components:unitFlags fromDate:[NSDate date]];
        //            NSDateComponents* comp2 = [calendar components:unitFlags fromDate:chatMessage.datetime];
        //
        //            if( [comp1 day]   == [comp2 day] && [comp1 month] == [comp2 month] && [comp1 year]  == [comp2 year]){
        //                todaystartsindex = i;
        //                break;
        //            }
        //        }
        [messageTbl reloadData];
        if(loaded == NO)
        {
            if(messageArr.count >0)
                [messageTbl scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messageArr count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            loaded = YES;
        }
    }
    else{
        
        QBDialogsPagedResult *res = (QBDialogsPagedResult *)result;
        NSArray *messages1;
        if(res)
            messages1  = res.dialogs;
        
        //        QBUUser *recipient = [LocalStorageService shared].usersAsDictionary[@(2046583)];
        //        NSLog(@"recipient == %@",recipient);
        //        self.title = recipient.login == nil ? recipient.email : recipient.login;
        //        NSLog(@"self.dialog.ID == %@",[[messages1 objectAtIndex:0]objectForKey:@"ID"]);
        //        // get messages history
        //        [QBChat messagesWithDialogID:[[messages1 objectAtIndex:0]objectForKey:@"ID"] extendedRequest:nil delegate:self];
        
        //        NSMutableDictionary *extendedRequest = [NSMutableDictionary new];
        //        extendedRequest[@"limit"] = @(100);
        //
        //        [QBChat messagesWithDialogID:@"5481c0e58a472ba18ddf5d8b" extendedRequest:extendedRequest delegate:self];
        //
        //        [self.messages addObjectsFromArray:[messages1 mutableCopy]];
        //        //
        //        [self.messagesTableView reloadData];
    }
    //    }
    if ([messageArr count] == 0) {
        pageNo = 0;
        no_msg.hidden = NO;
    }else{
        no_msg.hidden = YES;
    }
}


#pragma mark
#pragma mark ChatServiceDelegate

- (void)chatDidLogin{

    [self chatLogin];
}

- (void)chatDidReceiveMessage:(QBChatMessage *)message{
    NSLog(@"message == %@",message.text);
    if(message.senderID != _recp_quickblox_id){
        return;
    }
    [messageArr addObject:message];
    no_msg.hidden = YES;
    if([message.text isEqualToString:@"Sent a drink"]){
        [self serverRequest];
    }
    [messageTbl reloadData];
    if(messageArr.count >0)
        [messageTbl scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messageArr count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    for(QBChatAttachment *attachment in message.attachments){
        // download file by ID
        [QBRequest TDownloadFileWithBlobID:[attachment.ID integerValue] successBlock:^(QBResponse *response, NSData *fileData) {
            [self saveImage:[attachment.ID integerValue] fileData:fileData];
            
        } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
            // handle progress
        } errorBlock:^(QBResponse *response) {
            NSLog(@"error: %@", response.error);
        }];
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
