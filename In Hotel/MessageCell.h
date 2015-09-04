//
//  MessageCell.h
//  In Hotel
//
//  Created by NewageSMB on 4/14/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *userImg;
@property (retain, nonatomic) IBOutlet UILabel *nameLbl,*dateLbl,*msgView;

@end
