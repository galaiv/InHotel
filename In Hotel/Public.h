//
//  Public.h
//  In Hotel
//
//  Created by NewageSMB on 5/4/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ServerRequests.h"


@interface Public : UIViewController<ServerRequestProcessDelegate,UITextViewDelegate>
{
    AppDelegate *appDelegate;
    IBOutlet UIImageView *userImg,*chat_new;
    IBOutlet UILabel *from,*to,*room_no,*user_interests;
    IBOutlet UITextView *desc;
    IBOutlet UITextField *name,*status;
    IBOutlet UIButton *saveBtn,*chat_newBtn;
    NSMutableArray *vacancyArr;
    IBOutlet UITableView *vacancyTbl;
    IBOutlet UIScrollView *descSrl;
    NSDictionary *responseDetails;
    UIImagePickerController *imagePicker;
    NSMutableArray *selectedIDArray,*tempArr;
    NSData *picData;
    IBOutlet UISwitch *block;
    IBOutlet UIScrollView *mscroll;
    IBOutlet UIView *roomView;
}
-(IBAction)back:(id)sender;
-(IBAction)chat:(id)sender;
-(IBAction)block_guest:(id)sender;
@property (retain, nonatomic) NSString *public_id,*from_page;
@property int rec_quickblox_id;

@end
