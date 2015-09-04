//
//  Account.h
//  In Hotel
//
//  Created by NewageSMB on 3/27/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ServerRequests.h"
#import "Registration.h"

@interface Account : UIViewController<ServerRequestProcessDelegate,UITextViewDelegate,RegistrationProcess,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    AppDelegate *appDelegate;
    IBOutlet UIImageView *userImg;
    IBOutlet UILabel *from,*to,*room_no;
    IBOutlet UITextView *desc;
    IBOutlet UITextField *name,*status;
    IBOutlet UIButton *saveBtn;
    NSArray *vacancyArr;
    IBOutlet UITableView *vacancyTbl;
    IBOutlet UIScrollView *descSrl;
    NSDictionary *responseDetails;
    UIImagePickerController *imagePicker;
    NSMutableArray *selectedIDArray;
    NSData *picData;
    IBOutlet UIScrollView *mscroll;
}
-(IBAction)back:(id)sender;
-(IBAction)hide:(id)sender;
-(IBAction)updateUser:(id)sender;
-(IBAction)imageupload:(id)sender;
@end
