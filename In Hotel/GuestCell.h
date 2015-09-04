//
//  GuestCell.h
//  In Hotel
//
//  Created by NewageSMB on 3/26/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuestCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *guestImg;
@property (retain, nonatomic) IBOutlet UILabel *guestLbl,*statusLbl;

@end
