//
//  ServerRequests.m
//  TrackOr
//
//  Created by NewageSMB on 2/19/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//


#import "ServerRequests.h"
 

@implementation ServerRequests

@synthesize server_req_proces,user_id,login_id;

-(void) sendServerRequests:(NSString *)post_data{
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    if (appDelegate.networkAvailable) {    
    
    
        [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
      //  NSLog(@"post_data==>%@",post_data);
    
        NSData *postData = [post_data dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
   
        
       [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@hotel_service",appDelegate.ServerURL]]];

        [request setTimeoutInterval:100];

        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
       
        
        [request setHTTPBody:postData];
    
        conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (conn) {
            webData = [[NSMutableData alloc]init];
        }
    }
    else{
        
        [appDelegate displayNetworkAvailability:self];
    }
}

-(void) sendServerRequests2:(NSString *)post_data{
}
 



-(void) connection:(NSURLConnection *) connection didReceiveResponse:(NSURLResponse *) response {
	[webData setLength: 0];
}
//Note that the preceding code initializes the length of webData to 0. As the data progressively comes in from the web service, the connection:didReceiveData: method will be called repeatedly. You use the method to append the data received to the webData object:

-(void) connection:(NSURLConnection *) connection didReceiveData:(NSData *) data {
	[webData appendData:data];
}
//If there is an error during the transmission, the connection:didFailWithError: method will be called:

-(void) connection:(NSURLConnection *) connection didFailWithError:(NSError *) error {
    
   
    NSLog(@"errrooooorrrrrrrrr---%@",error);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ERROR"  object:@"true"];
   
    [self.server_req_proces ServerRequestProcessFinish:@"error"];

	
}

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
	
    
    NSLog(@"written---%i",totalBytesWritten*100/totalBytesExpectedToWrite);
    
    
    

    
    
	
}


//When the connection has finished and succeeded in downloading the response, the connectionDidFinishLoading: method will be called:

-(void) connectionDidFinishLoading:(NSURLConnection *) connection {
   // NSLog(@"DONE. Received Bytes: %d", [webData length]);
    
    NSString *jsonString = [[NSString alloc] initWithData:webData encoding:NSUTF8StringEncoding];
    
    

    
  //  NSLog(@"webData: %@", webData);

// NSLog(@"webData: %@", jsonString);
  //  NSLog(@"webData: %@", webData);

    
    
    
    
    
        [server_req_proces ServerRequestProcessFinish:jsonString];
    
   // if (appDelegate.back) {
        
          // }

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

}


#pragma mark -MBHud Methods





@end
