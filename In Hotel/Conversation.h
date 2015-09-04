//
//  Conversation.h
//  In Hotel
//
//  Created by NewageSMB on 4/9/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "HPGrowingTextView.h"
#import "ServerRequests.h"
#import "Registration.h"
#import <MediaPlayer/MediaPlayer.h>
#import <Quickblox/Quickblox.h>
#import "ChatService.h"
#import "LocalStorageService.h"


@interface Conversation : UIViewController<HPGrowingTextViewDelegate,ServerRequestProcessDelegate,RegistrationProcess,UIImagePickerControllerDelegate,UINavigationControllerDelegate,QBActionStatusDelegate,QBChatDelegate>
{
    AppDelegate *appDelegate;
    UIView *containerView;
    HPGrowingTextView *textView;
    IBOutlet UITableView *messageTbl;
    NSMutableArray *messageArr,*tempArr,*archivearray;
    NSMutableDictionary *user_details;
    UIImagePickerController *imagePicker;
    NSData *picData;
    NSDictionary *responseDetails;
    IBOutlet UILabel *no_msg;
    IBOutlet UIView *video_view;
    UIButton *drinkBtn;
    BOOL loaded;
    BOOL drink_chat,sendingDrink;
}
@property (strong, nonatomic) MPMoviePlayerController *videoController;
@property (retain, nonatomic) NSString *to_id,*user_Type;
@property int recp_quickblox_id;
@property (nonatomic, retain) UIRefreshControl *refreshControl;

@property (nonatomic, strong) QBChatDialog *dialog;
@property (nonatomic, strong) QBChatRoom *chatRoom;


-(IBAction)back:(id)sender;
-(IBAction)close_video:(id)sender;

@end
