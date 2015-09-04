//
//  DrinksCell.h
//  In Hotel
//
//  Created by NewageSMB on 4/18/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrinksCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *drinkImg;
@property (retain, nonatomic) IBOutlet UILabel *nameLbl,*rupeeLbl;
@property (retain, nonatomic) IBOutlet UITextView *drink_desc;
@property (retain, nonatomic) IBOutlet UIButton *sendBtn;

@end
