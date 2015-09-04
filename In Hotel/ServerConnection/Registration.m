//
//  Registration.m
//  TrackOr
//
//  Created by NewageSMB on 2/19/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//


#import "Registration.h"

@implementation Registration

@synthesize reg_proces;


-(void)completeLogin:(NSString *)user_name paswd:(NSString *)pass_word devceTckn:(NSString *)D_tocken device_flag:(NSString *)device_flag{
    
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    NSString *urlString =[NSString stringWithFormat:@"%@hotel_service/login",appDelegate.ServerURL];
    
    
    //device_token
    
    NSLog(@"urlString%@",urlString);
    
    NSLog(@"D_tocken%@",appDelegate.devicetoken);

    
    NSMutableURLRequest *request= [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    
    NSLog(@"urlString%@",urlString);
    
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:100];
    
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *postbody = [NSMutableData data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"username\"\r\n\r\n%@", user_name] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"user_name%@",user_name);
    
    

    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"password\"\r\n\r\n%@", pass_word] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"pass_word%@",pass_word);
    
    
   [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"device_token\"\r\n\r\n%@", D_tocken] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"D_tocken---%@",appDelegate.devicetoken);
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"device_flag\"\r\n\r\n%@", device_flag] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"member_type\"\r\n\r\n%d", 1] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:postbody];
    
    conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn) {
        webData = [NSMutableData data];
    }
    
    
}


-(void)registerUser:(NSString *)name email:(NSString *)email phone:(NSString *)phone  paswd:(NSString *)pass_word devceTckn:(NSString *)D_tocken{
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    NSString *urlString =[NSString stringWithFormat:@"%@hotel_service/register",appDelegate.ServerURL];
    
    //device_token
    
    NSLog(@"urlString%@",urlString);
    
    NSLog(@"D_tocken%@",D_tocken);
    
    
    NSMutableURLRequest *request= [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    
    NSLog(@"urlString%@",urlString);
    
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:100];
    
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *postbody = [NSMutableData data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"first_name\"\r\n\r\n%@", name] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"email_address\"\r\n\r\n%@", email] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"phone\"\r\n\r\n%@", phone] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"password\"\r\n\r\n%@", pass_word] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"device_token\"\r\n\r\n%@", D_tocken] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"member_type\"\r\n\r\n%d", 1] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:postbody];
    
    conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn) {
        webData = [NSMutableData data];
    }
    
}

-(void)updateUser:(NSString *)name status:(NSString *)status desc:(NSString *)desc imgData:(NSData *)imgData vacancy_list:(NSString *)vacancy_list{
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    NSString *urlString =[NSString stringWithFormat:@"%@hotel_service/register",appDelegate.ServerURL];
    
    NSString *userId = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]];
    NSString *activation_code = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"activation_code"]];
    
    //device_token
    
    NSLog(@"urlString%@",urlString);
    
    
    NSMutableURLRequest *request= [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    
    NSLog(@"urlString%@",urlString);
    
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:100];
    
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *postbody = [NSMutableData data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (![userId isEqualToString:@""]) {
        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"user_id\"\r\n\r\n%@", userId] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"first_name\"\r\n\r\n%@", name] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"status\"\r\n\r\n%@", status] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"desc\"\r\n\r\n%@", desc] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"vacancy_list\"\r\n\r\n%@", vacancy_list] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"member_type\"\r\n\r\n%d", 1] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"activation_code\"\r\n\r\n%@", activation_code] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
   
    if([imgData length] != 0){
        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"%@\"\r\n", @"pic.jpg"] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[NSData dataWithData:imgData]];
    }
    
    
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:postbody];
    
    conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn) {
        webData = [NSMutableData data];
    }
    
}

-(void)send_message:(NSString *)from_user to_user:(NSString *)to_user message:(NSString *)message video:(NSData *)picData drink_id:(NSString *)drink_id qty:(NSString *)qty message_id:(NSString *)message_id{
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    NSString *urlString =[NSString stringWithFormat:@"%@hotel_service/send_message",appDelegate.ServerURL];

    
    NSMutableURLRequest *request= [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    
    NSLog(@"urlString%@",urlString);
    
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:100];
    
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *postbody = [NSMutableData data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"from_id\"\r\n\r\n%@", from_user] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"to_id\"\r\n\r\n%@", to_user] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"message\"\r\n\r\n%@", message] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"message_id\"\r\n\r\n%@", message_id] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    if([picData length] != 0){
        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"video\"; filename=\"%@\"\r\n", @"video.mp4"] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[NSData dataWithData:picData]];
    }
    
    if([drink_id length] != 0){
        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"drinks_id\"\r\n\r\n%@", drink_id] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"quantity\"\r\n\r\n%@", qty] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:postbody];
    
    conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn) {
        webData = [NSMutableData data];
    }
    
}


-(void) connection:(NSURLConnection *) connection didReceiveResponse:(NSURLResponse *) response {
	[webData setLength: 0];

}
 
-(void) connection:(NSURLConnection *) connection didReceiveData:(NSData *) data {
	[webData appendData:data];
}
 
-(void) connection:(NSURLConnection *) connection didFailWithError:(NSError *) error {
    
    NSLog(@"Errorrrrr --- %@",error);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ERROR"  object:@"true"];

}

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
	
	
}
//When the connection has finished and succeeded in downloading the response, the connectionDidFinishLoading: method will be called:

-(void) connectionDidFinishLoading:(NSURLConnection *) connection {
  
  //  NSLog(@"webData: %@", webData);
    
    NSString *jsonString = [[NSString alloc] initWithData:webData encoding:NSUTF8StringEncoding] ;
    
    NSLog(@"DONE. Received Bytes: %@", jsonString);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    
    [self.reg_proces RegistrationProcessFinish:jsonString];

}





@end
