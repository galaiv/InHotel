//
//  ServerRequests.h
//  TrackOr
//
//  Created by NewageSMB on 2/19/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@protocol ServerRequestProcessDelegate <NSObject>

-(void) ServerRequestProcessFinish:(NSString *) serverResponse;

@end

@interface ServerRequests : NSObject {
    
    //---web service access ---
    NSMutableData *webData;
    NSURLConnection *conn;
    NSMutableString *postStatus;
    
    AppDelegate *appDelegate;
    id<ServerRequestProcessDelegate> server_req_proces;
    
}

@property (nonatomic,retain) id<ServerRequestProcessDelegate> server_req_proces;


@property(strong,nonatomic)NSString *user_id,*login_id;

-(void)sendServerRequests:(NSString *) post_data;
-(void)sendServerRequests2:(NSString *) post_data;






@end

