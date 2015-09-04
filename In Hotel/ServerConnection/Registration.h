//
//  Registration.h
//  TrackOr
//
//  Created by NewageSMB on 2/19/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@protocol RegistrationProcess <NSObject>

-(void) RegistrationProcessFinish:(NSString *) userdetails;

@end


@interface Registration : NSObject {
    
    //---web service access ---
    NSMutableData *webData;
    NSURLConnection *conn;
    NSMutableString *postStatus;
    
    AppDelegate *appDelegate;
    
    id<RegistrationProcess> reg_proces;
    
}

@property (nonatomic,retain) id<RegistrationProcess> reg_proces;

-(void)completeLogin:(NSString *)user_name paswd:(NSString *)pass_word devceTckn:(NSString *)D_tocken device_flag:(NSString *)device_flag;
-(void)registerUser:(NSString *)name email:(NSString *)email phone:(NSString *)phone  paswd:(NSString *)pass_word devceTckn:(NSString *)D_tocken;
-(void)updateUser:(NSString *)name status:(NSString *)status desc:(NSString *)desc imgData:(NSData *)imgData vacancy_list:(NSString *)vacancy_list;
-(void)send_message:(NSString *)from_user to_user:(NSString *)to_user message:(NSString *)message video:(NSData *)picData drink_id:(NSString *)drink_id qty:(NSString *)qty message_id:(NSString *)message_id;

@end
