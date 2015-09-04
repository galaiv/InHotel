/*
 PTSMessagingCell.m
 
 Copyright (C) 2012 pontius software GmbH
 
 This program is free software: you can redistribute and/or modify
 it under the terms of the Createive Commons (CC BY-SA 3.0) license
 */

#import "PTSMessagingCell.h"

@implementation PTSMessagingCell

static CGFloat textMarginHorizontal = 15.0f;
static CGFloat textMarginVertical = 7.5f;
static CGFloat messageTextSize = 13.0;

@synthesize sent, messageLabel, messageView, timeLabel, nameLabel, avatarImageView, balloonView,msg_video,msg_drink;
@synthesize videoImg,playBtn,drinkImg,drinkLabel,acceptBtn,rejectBtn,drinkBgImg;
#pragma mark -
#pragma mark Static methods

+(CGFloat)textMarginHorizontal {
    return textMarginHorizontal;
}

+(CGFloat)textMarginVertical {
    return textMarginVertical;
}

+(CGFloat)maxTextWidth {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return 200.0f;
    } else {
        return 400.0f;
    }
}

+(CGSize)messageSize:(NSString*)message {
    return [message sizeWithFont:[UIFont fontWithName:@"Lato" size:13.0] constrainedToSize:CGSizeMake([PTSMessagingCell maxTextWidth], CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
}

+(UIImage*)balloonImage:(BOOL)sent isSelected:(BOOL)selected {
    if (sent == YES && selected == YES) {
        return [[UIImage imageNamed:@"bubbl_small"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
    } else if (sent == YES && selected == NO) {
        return [[UIImage imageNamed:@"bubbl_small"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
    } else if (sent == NO && selected == YES) {
        return [[UIImage imageNamed:@"bubbl_smalr"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
    } else {
        return [[UIImage imageNamed:@"bubbl_smalr"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
    }
}

#pragma mark -
#pragma mark Object-Lifecycle/Memory management

-(id)initMessagingCellWithReuseIdentifier:(NSString*)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        /*Selection-Style of the TableViewCell will be 'None' as it implements its own selection-style.*/
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        /*Now the basic view-lements are initialized...*/
        messageView = [[UIView alloc] initWithFrame:CGRectZero];
        messageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        balloonView = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        nameLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        avatarImageView = [[UIImageView alloc] initWithImage:nil];
        videoImg = [[UIImageView alloc] initWithImage:nil];
        playBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        drinkImg = [[UIImageView alloc] initWithImage:nil];
        drinkLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        acceptBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        rejectBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        drinkBgImg = [[UIImageView alloc] initWithImage:nil];
        
        
        /*Message-Label*/
        self.messageLabel.backgroundColor = [UIColor clearColor];
        self.messageLabel.font = [UIFont systemFontOfSize:messageTextSize];
        self.messageLabel.textColor = [UIColor grayColor];
        self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageLabel.numberOfLines = 0;
        
        /*Time-Label*/
        self.timeLabel.font = [UIFont systemFontOfSize:9.0f];
        self.timeLabel.textColor = [UIColor grayColor];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        
        /*Name-Label*/
        self.nameLabel.font = [UIFont systemFontOfSize:12];
        self.nameLabel.textColor = [UIColor grayColor];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        
        /*Name-Label*/
        self.drinkLabel.font = [UIFont systemFontOfSize:13];
        self.drinkLabel.textColor = [UIColor grayColor];
        self.drinkLabel.backgroundColor = [UIColor clearColor];
        
        /*...and adds them to the view.*/
        [self.contentView addSubview: self.avatarImageView];

        [self.messageView addSubview: self.balloonView];
        [self.messageView addSubview: self.messageLabel];
        
        [self.balloonView addSubview: self.timeLabel];
        [self.balloonView addSubview: self.nameLabel];
        
        
        [self.contentView addSubview: self.messageView];
        [self.contentView addSubview: self.videoImg];
        [self.contentView addSubview: self.playBtn];
        [self.contentView addSubview: self.drinkBgImg];
        [self.contentView addSubview: self.drinkImg];
        [self.contentView addSubview: self.drinkLabel];
        [self.contentView addSubview: self.acceptBtn];
        [self.contentView addSubview: self.rejectBtn];
        
        self.videoImg.hidden = YES;
        self.playBtn.hidden = YES;
        self.drinkBgImg.hidden = YES;
        self.acceptBtn.hidden = YES;
        self.rejectBtn.hidden = YES;
        
        
        /*...and a gesture-recognizer, for LongPressure is added to the view.*/
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [recognizer setMinimumPressDuration:1.0f];
        [self addGestureRecognizer:recognizer];
    }
    
    return self;
}


#pragma mark -
#pragma mark Layouting

- (void)layoutSubviews {
    /*This method layouts the TableViewCell. It calculates the frame for the different subviews, to set the layout according to size and orientation.*/
    
    /*Calculates the size of the message. */
    CGSize textSize = [PTSMessagingCell messageSize:self.messageLabel.text];
    
    /*Calculates the size of the name. */
    CGSize nameSize = [PTSMessagingCell messageSize:self.nameLabel.text];
    CGSize drinknameSize = [PTSMessagingCell messageSize:self.drinkLabel.text];
    
    /*Calculates the size of the timestamp.*/
    CGSize dateSize = [self.timeLabel.text sizeWithFont:self.timeLabel.font forWidth:[PTSMessagingCell maxTextWidth] lineBreakMode:NSLineBreakByClipping];
    
    /*Initializes the different frames , that need to be calculated.*/
    CGRect ballonViewFrame = CGRectZero;
    CGRect messageLabelFrame = CGRectZero;
    CGRect timeLabelFrame = CGRectZero;
    CGRect nameLabelFrame = CGRectZero;
    CGRect avatarImageFrame = CGRectZero;
    CGRect videoImageFrame = CGRectZero;
    CGRect playImageFrame = CGRectZero;
    CGRect drinkImageFrame = CGRectZero;
    CGRect drinkLabelFrame = CGRectZero;
    CGRect acceptBtnFrame = CGRectZero;
    CGRect rejectBtnFrame = CGRectZero;
    CGRect drinkBgImageFrame = CGRectZero;
    
    
    if (self.sent == YES) { //self.frame.size.width - dateSize.width - 7.8*textMarginHorizontal,
        timeLabelFrame = CGRectMake(avatarImageFrame.origin.x+avatarImageFrame.size.width+160, 4.0f, dateSize.width, dateSize.height);
        
        nameLabelFrame = CGRectMake(avatarImageFrame.origin.x+avatarImageFrame.size.width+10, 4.0f, nameSize.width+25, nameSize.height);
        
        if (self.msg_video == YES) {
            ballonViewFrame = CGRectMake(43,timeLabelFrame.size.height, 215, 800);
            videoImageFrame = CGRectMake(70,  ballonViewFrame.origin.y + 45, 160.0f, 125.0f);
            playImageFrame = CGRectMake(70,  ballonViewFrame.origin.y + 45, 160.0f, 125.0f);
            
        }else if (self.msg_drink == YES) {
            ballonViewFrame = CGRectMake(43,timeLabelFrame.size.height, 230, 800);
            drinkImageFrame = CGRectMake(62,  ballonViewFrame.origin.y + 55, 55.0f, 55.0f);
            drinkLabelFrame = CGRectMake(125,  ballonViewFrame.origin.y + 60, drinknameSize.width+50, drinknameSize.height);
            acceptBtnFrame = CGRectMake(70,  ballonViewFrame.origin.y + 105, 20.0f, 20.0f);
            rejectBtnFrame = CGRectMake(110,  ballonViewFrame.origin.y + 105, 54.0f, 20.0f);
            drinkBgImageFrame = CGRectMake(56,  ballonViewFrame.origin.y + 50, 189.0f, 65.0f);
            
        }else{
            ballonViewFrame = CGRectMake(43,10, 215, textSize.height + 2*textMarginVertical + nameSize.height+25);
        }
        avatarImageFrame = CGRectMake(15.0f, timeLabelFrame.size.height, 35.0f, 35.0f);
        messageLabelFrame = CGRectMake(53,  ballonViewFrame.origin.y + textMarginVertical+10, 200, textSize.height + nameSize.height);
        if (self.msg_drink == YES) {
            messageLabelFrame = CGRectMake(53,  ballonViewFrame.origin.y + textMarginVertical+5, 200, textSize.height + nameSize.height);
        }
        
    } else {
        timeLabelFrame = CGRectMake(10*textMarginHorizontal, 4.0f, dateSize.width, dateSize.height);
        
        nameLabelFrame = CGRectMake(textMarginHorizontal-8, 4.0f, nameSize.width+25, nameSize.height);
        
        if (self.msg_video == YES) {
            //ballonViewFrame = CGRectMake(67.0f, timeLabelFrame.size.height, 215,800);
            ballonViewFrame = CGRectMake(self.frame.size.width - 258.0f, timeLabelFrame.size.height, 215,800);
            //videoImageFrame = CGRectMake(90,  ballonViewFrame.origin.y + 45, 160.0f, 125.0f);
            videoImageFrame = CGRectMake(self.frame.size.width - 230.0f, ballonViewFrame.origin.y + 45, 160.0f, 125.0f);
            //playImageFrame = CGRectMake(90,  ballonViewFrame.origin.y + 45, 160.0f, 125.0f);
            playImageFrame = CGRectMake(self.frame.size.width - 230.0f, ballonViewFrame.origin.y + 45, 160.0f, 125.0f);
            
        }else if (self.msg_drink == YES) {
           ballonViewFrame = CGRectMake(self.frame.size.width - 268.0f, timeLabelFrame.size.height, 225,800);
            
           drinkImageFrame = CGRectMake(self.frame.size.width - 240.0f,  ballonViewFrame.origin.y + 58, 50.0f, 50.0f);
            
           drinkLabelFrame = CGRectMake(self.frame.size.width - 182.0f,  ballonViewFrame.origin.y + 55, drinknameSize.width+50, drinknameSize.height);
            
           acceptBtnFrame = CGRectMake(self.frame.size.width - 130.0f, ballonViewFrame.origin.y + 77, 54.0f, 20.0f);
            
           rejectBtnFrame = CGRectMake(self.frame.size.width - 182.0f, ballonViewFrame.origin.y + 77, 54.0f, 20.0f);
            
           drinkBgImageFrame = CGRectMake(self.frame.size.width - 247.0f,  ballonViewFrame.origin.y + 50, 189.0f, 65.0f);
        }else{
            ballonViewFrame = CGRectMake(self.frame.size.width - 258.0f, 10, 215,textSize.height + 2*textMarginVertical + nameSize.height+20);
        }
        avatarImageFrame = CGRectMake(self.frame.size.width - 50.0f, timeLabelFrame.size.height, 35.0f, 35.0f);   messageLabelFrame = CGRectMake(self.frame.size.width - 250.0f, ballonViewFrame.origin.y + 2.5*textMarginVertical, 200, textSize.height + nameSize.height);
        if (self.msg_drink == YES) {
            messageLabelFrame = CGRectMake(self.frame.size.width - 260.0f, ballonViewFrame.origin.y + 2.5*textMarginVertical - 5, 200, textSize.height + nameSize.height);
        }
    }
    
    self.balloonView.image = [PTSMessagingCell balloonImage:self.sent isSelected:self.selected];
    
    /*Sets the pre-initialized frames  for the balloonView and messageView.*/
    self.balloonView.frame = ballonViewFrame;
    self.messageLabel.frame = messageLabelFrame;
    
    /*If shown (and loaded), sets the frame for the avatarImageView*/
    if (self.avatarImageView.image != nil) {
        self.avatarImageView.frame = avatarImageFrame;
    }
    
    if (self.videoImg.image != nil) {
        self.videoImg.frame = videoImageFrame;
    }
    
    if (self.drinkImg.image != nil) {
        self.drinkImg.frame = drinkImageFrame;
    }
    
    if (self.msg_video == YES) {
        self.playBtn.frame = playImageFrame;
    }
    
    if (self.msg_drink == YES) {
        self.acceptBtn.frame = acceptBtnFrame;
        self.rejectBtn.frame = rejectBtnFrame;
        self.drinkBgImg.frame = drinkBgImageFrame;
    }
        
    /*If there is next for the timeLabel, sets the frame of the timeLabel.*/
    
    if (self.timeLabel.text != nil) {
        self.timeLabel.frame = timeLabelFrame;
    }
    
    if (self.nameLabel.text != nil) {
        self.nameLabel.frame = nameLabelFrame;
    }
    if (self.drinkLabel.text != nil) {
        self.drinkLabel.frame = drinkLabelFrame;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    /*Selecting a UIMessagingCell will cause its subviews to be re-layouted. This process will not be animated! So handing animated = YES to this method will do nothing.*/
    [super setSelected:selected animated:NO];
    [self setNeedsLayout];
    
    /*Furthermore, the cell becomes first responder when selected.*/
    if (selected == YES) {
        [self becomeFirstResponder];
    } else {
        [self resignFirstResponder];
    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
}

#pragma mark -
#pragma mark UIGestureRecognizer-Handling

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressRecognizer {
    /*When a LongPress is recognized, the copy-menu will be displayed.*/
    if (longPressRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    if ([self becomeFirstResponder] == NO) {
        return;
    }
    
    UIMenuController * menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:self.balloonView.frame inView:self];
    
    [menu setMenuVisible:YES animated:YES];
}

-(BOOL)canBecomeFirstResponder {
    /*This cell can become first-responder*/
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    /*Allows the copy-Action on this cell.*/
    if (action == @selector(copy:)) {
        return YES;
    } else {
        return [super canPerformAction:action withSender:sender];
    }
}

-(void)copy:(id)sender {
    /**Copys the messageString to the clipboard.*/
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:self.messageLabel.text];
}
@end