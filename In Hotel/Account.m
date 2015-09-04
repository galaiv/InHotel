//
//  Account.m
//  In Hotel
//
//  Created by NewageSMB on 3/27/15.
//  Copyright (c) 2015 NewageSMB. All rights reserved.
//

#import "Account.h"
#import "JSON.h"
#import "UIImageView+WebCache.h"
#import "VacancyCell.h"
#import "MBProgressHUD.h"
#import "Settings.h"

@interface Account ()
{
    NSString *response_from,*vacancyIds;
}
@end

@implementation Account

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    userImg.clipsToBounds = YES;
    userImg.layer.cornerRadius = 45;
    userImg.layer.borderColor=[[UIColor colorWithRed:60.0/255 green:132.0/255 blue:120.0/255 alpha:1] CGColor];
    userImg.layer.borderWidth=5.0;
    userImg.layer.masksToBounds=YES;
    selectedIDArray = [[NSMutableArray alloc]init];
    if ([UIScreen mainScreen].bounds.size.height == 480)
    {
        [mscroll setContentSize: CGSizeMake(0,600)];
        vacancyTbl.frame = CGRectMake(vacancyTbl.frame.origin.x, vacancyTbl.frame.origin.y, vacancyTbl.frame.size.width, vacancyTbl.frame.size.height + 200);
    }else{
       // [mscroll setContentSize: CGSizeMake(0,600)];
    }
    [self performSelector:@selector(serverRequest) withObject:nil afterDelay:.1];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -Other Methods

-(void)serverRequest{
    NSString *user_id = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]];
    NSString *activation_code = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"activation_code"]];
    ServerRequests *ser_req = [[ServerRequests alloc] init];
    ser_req.server_req_proces = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"get_user_details\", \"parameters\": {\"user_id\": \"%@\",\"activation_code\": \"%@\"},\"token\":\"\"}", user_id,activation_code];
    NSLog(@"%@",postdata);
    [self startLoader];
    [ser_req sendServerRequests:postdata];
    
}
-(void) ServerRequestProcessFinish:(NSString *) serverResponse{
    
    if ([response_from isEqualToString:@"vacancy"]) {
        response_from = @"";
        vacancyArr  = [[serverResponse JSONValue] objectForKey:@"details"];
        NSLog(@"maindict---%@",vacancyArr);
        [vacancyTbl reloadData];
    }else{
        [self stopLoader];
        response_from = @"";
        if (![[[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"first_name"] isEqual:[NSNull null]]){
            name.text = [[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"first_name"];
        }
        if (![[[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"status"] isEqual:[NSNull null]]){
            status.text = [[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"status"];
        }
        if (![[[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"access_start_date_time"] isEqual:[NSNull null]]){
            from.text = [[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"access_start_date_time"];
        }
        if (![[[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"access_end_date_time"] isEqual:[NSNull null]]){
            to.text = [[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"access_end_date_time"];
        }
        if (![[[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"room"] isEqual:[NSNull null]]){
            room_no.text = [[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"room"];
        }
        if (![[[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"profile_description"] isEqual:[NSNull null]]){
            desc.text = [[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"profile_description"];
            if ([desc.text isEqualToString:@""]) {
                desc.text = @"Description";
            }
        }
        for (int i=0; i < [[[serverResponse JSONValue] objectForKey:@"user_vacancy"] count]; i++) {
            [selectedIDArray addObject: [[[[serverResponse JSONValue] objectForKey:@"user_vacancy"] objectAtIndex:i] objectForKey:@"vecancy_id"]];
        }
        NSURL   *url  = [[[serverResponse JSONValue] objectForKey:@"details"] objectForKey:@"image"];
        [userImg sd_setImageWithURL:url placeholderImage:nil];
        [self vacancyList];
    }
    
}
-(IBAction)back:(id)sender{
    [self dismissViewControllerAnimated:YES completion:Nil];
}
-(void)vacancyList{
    response_from = @"vacancy";
    ServerRequests *ser_req = [[ServerRequests alloc] init];
    ser_req.server_req_proces = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"vacancy_reason_list\", \"parameters\": {},\"token\":\"\"}"];
    NSLog(@"%@",postdata);
    [ser_req sendServerRequests:postdata];
}
-(IBAction)hide:(id)sender{
    [desc resignFirstResponder];
    [name resignFirstResponder];
    [descSrl setBackgroundColor:[UIColor clearColor]];
    [descSrl setContentOffset:CGPointMake(0,0) animated:YES];
    [status resignFirstResponder];
}
-(IBAction)updateUser:(id)sender{
    [self startLoader];
    Registration *reg = [[Registration alloc] init];
    reg.reg_proces = self;
    [reg updateUser:name.text status:status.text desc:desc.text imgData:picData vacancy_list:vacancyIds ];
}

-(void) RegistrationProcessFinish:(NSString *) userdetails{
    
    responseDetails = [userdetails JSONValue];
    
    NSLog(@"userDet =-=======%@",responseDetails);
    
    [self stopLoader];
    [self hide:nil];
    if ([[responseDetails objectForKey:@"status"] isEqualToString:@"true"]) {
        
        NSString *full_name =   [NSString stringWithFormat:@"%@",name.text];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:full_name forKey:@"fullname"];
        
        [defaults synchronize];
        saveBtn.hidden = YES;
        [self serverRequest];
    }
}
-(IBAction)imageupload:(id)sender{
    
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            
                            initWithTitle:@"Choose an option"
                            
                            delegate:self
                            
                            cancelButtonTitle:@"Cancel"
                            
                            destructiveButtonTitle:nil
                            
                            otherButtonTitles:@"Take Photo",@"Choose From Library", nil];
    
    //    sheet.tag = 2;
    
    [sheet showInView:self.view];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex == 0)
    {
       // saveBtn.hidden = NO;
        [self takePhoto];
    }
    
    else if(buttonIndex == 1)
    {
       // saveBtn.hidden = NO;
        [self selectPhoto];
    }
//    else
//        saveBtn.hidden = YES;
}


-(void)takePhoto   // invoke camera in iPhone

{
    
    imagePicker=[[UIImagePickerController alloc]init];
    
    imagePicker.delegate=self;
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        saveBtn.hidden = NO;
        [self presentViewController:imagePicker animated:YES completion:NULL];
        
        //[self presentModalViewController:imagePicker animated:YES];
    }
    
    else
    {
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"" message:@"Sorry your device wont support" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alertView show];
        
    }
    
}



-(void)selectPhoto  // to select photo from photo library

{
    
    imagePicker=[[UIImagePickerController alloc]init];
    
    imagePicker.delegate=self;
    
    imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum ;
    
    
    
    imagePicker.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo
{
    
    [[picker parentViewController] dismissModalViewControllerAnimated:YES];
    
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info

{
    
    //image= [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    saveBtn.hidden = NO;
    UIImage *img=[info objectForKey:UIImagePickerControllerOriginalImage];
    
    picData = UIImageJPEGRepresentation([self scaleAndRotateImage:img], 1.0);
    
    userImg.image =[UIImage imageWithData:picData];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    //[self startLoader];
    
}
- (UIImage *)scaleAndRotateImage:(UIImage *)image1 {
    
    int kMaxResolution = 640; // Or whatever
    
    
    
    CGImageRef imgRef = image1.CGImage;
    
    
    
    CGFloat width = CGImageGetWidth(imgRef);
    
    CGFloat height = CGImageGetHeight(imgRef);
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    if (width > kMaxResolution || height > kMaxResolution) {
        
        CGFloat ratio = width/height;
        
        if (ratio > 1) {
            
            bounds.size.width = kMaxResolution;
            
            bounds.size.height = roundf(bounds.size.width / ratio);
            
        }
        
        else {
            
            bounds.size.height = kMaxResolution;
            
            bounds.size.width = roundf(bounds.size.height * ratio);
            
        }
        
    }
    
    
    
    CGFloat scaleRatio = bounds.size.width / width;
    
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    
    CGFloat boundHeight;
    
    UIImageOrientation orient = image1.imageOrientation;
    
    switch(orient) {
            
            
            
        case UIImageOrientationUp: //EXIF = 1
            
            transform = CGAffineTransformIdentity;
            
            break;
            
            
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            
            break;
            
            
            
        case UIImageOrientationDown: //EXIF = 3
            
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            
            transform = CGAffineTransformRotate(transform, M_PI);
            
            break;
            
            
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            
            break;
            
            
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            
            boundHeight = bounds.size.height;
            
            bounds.size.height = bounds.size.width;
            
            bounds.size.width = boundHeight;
            
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            
            break;
            
            
            
        case UIImageOrientationLeft: //EXIF = 6
            
            boundHeight = bounds.size.height;
            
            bounds.size.height = bounds.size.width;
            
            bounds.size.width = boundHeight;
            
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            
            break;
            
            
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            
            boundHeight = bounds.size.height;
            
            bounds.size.height = bounds.size.width;
            
            bounds.size.width = boundHeight;
            
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            
            break;
            
            
            
        case UIImageOrientationRight: //EXIF = 8
            
            boundHeight = bounds.size.height;
            
            bounds.size.height = bounds.size.width;
            
            bounds.size.width = boundHeight;
            
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            
            break;
            
            
            
        default:
            
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
            
            
    }
    
    
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        
        CGContextTranslateCTM(context, -height, 0);
        
    }
    
    else {
        
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        
        CGContextTranslateCTM(context, 0, -height);
        
    }
    
    
    
    CGContextConcatCTM(context, transform);
    
    
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    
    
    return imageCopy;
    
}

#pragma mark -MBHud Methods

-(void)startLoader
{
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText=@"Updating ...";
}
-(void)stopLoader
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
#pragma mark -TextField Delegates

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if ([textField isEqual:name]) {
        saveBtn.hidden = NO;
    }else if ([textField isEqual:status]) {
        saveBtn.hidden = NO;
    }
    return YES;
}

#pragma mark -TextView Delegates

- (BOOL)textViewShouldBeginEditing:(UITextField *)textView{
    
    if ([textView isEqual:desc]) {
        if ([desc.text isEqualToString:@"Description"]) {
            desc.text = @"";
            desc.textColor = [UIColor lightGrayColor];
        }
        saveBtn.hidden = NO;
        [descSrl setBackgroundColor:[UIColor whiteColor]];
        [descSrl setContentOffset:CGPointMake(0,100) animated:YES];
    }
    return YES;
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([desc.text isEqualToString:@""]) {
        desc.text = @"Description";
        desc.textColor = [UIColor lightGrayColor];
    }
}
- (BOOL)textViewShouldReturn:(UITextField *)textView{
    [descSrl setContentOffset:CGPointMake(0,0) animated:YES];
    return YES;
}

#pragma mark - Table

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)sectionn {
    
    return vacancyArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    static NSString *CellIdentifier = @"VacancyCell";
    VacancyCell *cell = (VacancyCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VacancyCell" owner:self options:Nil];
        cell = [nib objectAtIndex:0];
        
    }
    
    cell.vacancyLbl.text = [[vacancyArr objectAtIndex:indexPath.row] objectForKey:@"title"];
    if ([[[vacancyArr objectAtIndex:indexPath.row] objectForKey:@"id"] isEqualToString:@"1"]) {
        cell.vacancyImg.image = [UIImage imageNamed:@"nature_icon.png"];
    }else if ([[[vacancyArr objectAtIndex:indexPath.row] objectForKey:@"id"] isEqualToString:@"2"]) {
        cell.vacancyImg.image = [UIImage imageNamed:@"culture_icon.png"];
    }else if ([[[vacancyArr objectAtIndex:indexPath.row] objectForKey:@"id"] isEqualToString:@"3"]) {
        cell.vacancyImg.image = [UIImage imageNamed:@"fiera.png"];
    }else if ([[[vacancyArr objectAtIndex:indexPath.row] objectForKey:@"id"] isEqualToString:@"4"]) {
        cell.vacancyImg.image = [UIImage imageNamed:@"concert.png"];
    }else if ([[[vacancyArr objectAtIndex:indexPath.row] objectForKey:@"id"] isEqualToString:@"5"]) {
        cell.vacancyImg.image = [UIImage imageNamed:@"sports.png"];
    }else if ([[[vacancyArr objectAtIndex:indexPath.row] objectForKey:@"id"] isEqualToString:@"6"]) {
        cell.vacancyImg.image = [UIImage imageNamed:@"family_vacation.png"];
    }
    
    if ([selectedIDArray containsObject:[[vacancyArr objectAtIndex:indexPath.row] objectForKey:@"id"]]) {
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"activation_status"] isEqualToString:@"N"]){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Please activate your account" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        saveBtn.hidden = NO;
        if ([selectedIDArray containsObject:[[vacancyArr objectAtIndex:indexPath.row] objectForKey:@"id"]]) {
            [selectedIDArray removeObject:[[vacancyArr objectAtIndex:indexPath.row] objectForKey:@"id"]];
        }
        else{
            [selectedIDArray addObject:[[vacancyArr objectAtIndex:indexPath.row] objectForKey:@"id"]];
        }
        vacancyIds = [selectedIDArray componentsJoinedByString:@","];
        [vacancyTbl reloadData];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
