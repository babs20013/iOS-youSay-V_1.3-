//
//  AddNewSayViewController.m
//  youSay
//
//  Created by Baban on 04/12/2015.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import "AddNewSayViewController.h"
#import "UIImageView+Networking.h"
#import "AppDelegate.h"
#import "AddSayRequest.h"
#import "BFPaperButton.h"
#import "SlideNavigationController.h"

@interface AddNewSayViewController (){
    CGFloat textViewOriginalHeight;
    CGFloat _currentKeyboardHeight;
    UIButton *btnSelectedColor;
    NSMutableArray *arrayColorKey;
    NSInteger idColor;
    NSMutableArray *arrayColor;
    UIButton *previousButton;
}
@end

@implementation AddNewSayViewController

@synthesize addSayTextView;
@synthesize textViewBG;
@synthesize profileView;
@synthesize chooseBGView;
@synthesize colorContainer;
@synthesize profileImg;
@synthesize coverImg;
@synthesize profileLabel;
@synthesize model;
@synthesize placeholderLabel;

- (void)viewWillAppear:(BOOL)animated {
    [self InitializeUI];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.screenName = @"AddNewSay";
    addSayTextView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    _currentKeyboardHeight = 0.0f;
    self.textViewBG.layer.cornerRadius = 3;
    
    [self addColorButton];
    
}

-(void)viewDidAppear:(BOOL)animated{
    textViewOriginalHeight = addSayTextView.frame.size.height;
    [self.view bringSubviewToFront:textViewBG];
    [self.view bringSubviewToFront:_headerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)InitializeUI {
    
    //--Profile Box
    NSURL *cover = [NSURL URLWithString:model.CoverImage];
    if  (cover && [cover scheme] && [cover host]) {
        [coverImg setImageURL:cover];
    }
    else {
        [coverImg setImageURL:[NSURL URLWithString:@"http://freephotos.atguru.in/hdphotos/best-cover-photos/best-friend-facebook-timeline-cover-image.png"]];
    }
    
    //[coverImg setImageURL:[NSURL URLWithString:model.CoverImage]];
    coverImg.frame = CGRectMake(0, 0, self.view.bounds.size.width, 70);
    profileView.frame = CGRectMake(0, 43, self.view.bounds.size.width, 70);
    profileLabel.text = model.Name;
    coverImg.clipsToBounds = YES;
    
    NSURL *profile = [NSURL URLWithString:model.ProfileImage];
    if  (profile && [profile scheme] && [profile host]) {
        [profileImg setImageURL:[NSURL URLWithString:model.ProfileImage]];
    }
    else {
        [profileImg setImageURL:[NSURL URLWithString:@"http://2.bp.blogspot.com/-6QyJDHjB5XE/Uscgo2DVBdI/AAAAAAAACS0/DFSFGLBK_fY/s1600/facebook-default-no-profile-pic.jpg"]];
    }
    
    //[profileImg setImageURL:[NSURL URLWithString:model.ProfileImage]];
    profileImg.layer.cornerRadius = 0.5 * profileImg.bounds.size.width;
    profileImg.layer.masksToBounds = YES;
    profileImg.layer.borderWidth = 1;
    profileImg.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.5].CGColor;
    [self.view bringSubviewToFront:_headerView];
    [addSayTextView becomeFirstResponder];
}

#pragma mark - Request

- (void)requestAddSay:(NSInteger)colorID {
    ShowLoader();
    
    AddSayRequest *request = [[AddSayRequest alloc]init];
    request.request = REQUEST_ADD_SAY;
    request.user_id = [[AppDelegate sharedDelegate].profileOwner UserID] ;
    request.token = [[AppDelegate sharedDelegate].profileOwner token];
    request.profile_id_to_add_to = model.UserID;
    request.text = addSayTextView.text;
    request.color = [[arrayColorKey objectAtIndex:colorID] integerValue];
    
    [HTTPReq  postRequestWithPath:@"" class:nil object:request completionBlock:^(id result, NSError *error) {
        HideLoader();
        if (result)
        {
            NSDictionary *dictResult = result;
            if([[dictResult valueForKey:@"message"] isEqualToString:@"success"])
            {
                [self dismissViewControllerAnimated:YES completion:^{
                    if ([self.delegate performSelector:@selector(AddNewSayDidDismissed) withObject:nil]) {
                        [self.delegate AddNewSayDidDismissed];
                    }
                }];
            }
            else if ([[dictResult valueForKey:@"message"] isEqualToString:@"invalid user token"]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [self logout];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Say" message:[dictResult valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else if (error)
        {
        }
        else{
            
        }
    }];
}


#pragma mark IBAction

- (IBAction)btnCloseClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate performSelector:@selector(AddNewSayDidDismissedWithCancel) withObject:nil]) {
            [self.delegate AddNewSayDidDismissedWithCancel];
        }
    }];
}

- (IBAction)btnSendClicked:(id)sender {
    // NSLog(@"Sending the message");
    [self.addSayTextView endEditing:YES];
    [self requestAddSay:[btnSelectedColor tag]];
}

- (IBAction)btnColorlicked:(id)sender {
    [chooseBGView setHidden:NO];
    [self.view endEditing:YES];
}

- (IBAction)backgroundClicked:(id)sender {
    [chooseBGView setHidden:YES];
}


- (IBAction)selectColor:(id)sender {
    if (previousButton != nil) {
        for (UIView *i in colorContainer.subviews){
            if([i isKindOfClass:[UIButton class]]){
                UIButton *oldButton = (UIButton *)i;
                if(oldButton.tag == previousButton.tag){
                    oldButton.frame = previousButton.frame;
                    oldButton.layer.cornerRadius = 0.5 * oldButton.bounds.size.width;
                    //[oldButton.layer setBorderWidth:0.0];
                    [oldButton.layer setBorderColor: [UIColor clearColor].CGColor];
                    //oldButton.imageEdgeInsets = UIEdgeInsetsMake(24, 22, 24, 22);
                }
            }
        }
    }
    
    
    btnSelectedColor.selected = NO;
    
    UIButton *btn = (UIButton*)sender;
    btn.selected = YES;
    previousButton = [[UIButton alloc]init];
    previousButton.frame = btn.frame;
    previousButton.tag = btn.tag;
    btnSelectedColor = btn;
    btn.frame = CGRectMake(btn.frame.origin.x-8, btn.frame.origin.y-6, 60, 60);
    btn.layer.cornerRadius = 0.5 * btn.bounds.size.width;
    [btn.layer setBorderWidth:7.0];
    [btn.layer setBorderColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.85].CGColor];
    //[btn.layer setBorderColor:[UIColor colorWithWhite:0.9 alpha:0.9].CGColor];
    
    
    //[addSayTextView setBackgroundColor:btn.backgroundColor];
    [textViewBG setBackgroundColor:btn.backgroundColor];
    NSDictionary *dict = [arrayColor objectAtIndex:btn.tag];
    [addSayTextView setTextColor:[self colorWithHexString:[dict objectForKey:@"fore"]]];
    [placeholderLabel setTextColor:[self colorWithHexString:[dict objectForKey:@"fore"]]];
    
    [chooseBGView setHidden:YES];
    [addSayTextView becomeFirstResponder];
    
}

#pragma mark Method

- (void)addColorButton {
    arrayColor = [[NSMutableArray alloc] init];
    arrayColorKey = [[NSMutableArray alloc]init];
    
    for (int i= 1; i <[_colorDict allKeys].count+1; i++) {
        NSString *colorIndex = [NSString stringWithFormat:@"%i",i];
        NSDictionary *indexDict = [_colorDict objectForKey:colorIndex];
        if (indexDict) {
            [arrayColorKey addObject:colorIndex];
            [arrayColor addObject:indexDict];
        }
    }
    if  (arrayColor.count < 5) {
        [colorContainer setFrame:CGRectMake(colorContainer.frame.origin.x, colorContainer.frame.origin.y, chooseBGView.frame.size.width-60, 160)];
        self.containerHeightCosntraint.constant = 160;
    }
    else if  (arrayColor.count < 9) {
        [colorContainer setFrame:CGRectMake(colorContainer.frame.origin.x, colorContainer.frame.origin.y, self.view.frame.size.width-60, 210)];
        self.containerHeightCosntraint.constant = 210;
    }
    else if  (arrayColor.count < 13) {
        [colorContainer setFrame:CGRectMake(colorContainer.frame.origin.x, colorContainer.frame.origin.y, self.view.frame.size.width-60, 260)];
        self.containerHeightCosntraint.constant = 260;
    }
    else if  (arrayColor.count > 12) {
        [colorContainer setFrame:CGRectMake(colorContainer.frame.origin.x, colorContainer.frame.origin.y, self.view.frame.size.width-60, 310)];
        self.containerHeightCosntraint.constant = 310;
    }
    
    colorContainer.layer.cornerRadius = 0.01 * colorContainer.bounds.size.width;
    colorContainer.layer.masksToBounds = YES;
    colorContainer.layer.borderWidth = 1;
    colorContainer.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.5].CGColor;
    //Randomize the array
    NSUInteger count = [arrayColor count];
    for (NSUInteger i = 0; i < count; ++i) {
        unsigned long int nElements = count - i;
        unsigned long int n = (arc4random() % nElements) + i;
        [arrayColor exchangeObjectAtIndex:i withObjectAtIndex:n];
        [arrayColorKey exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    for (int i = 0; i < arrayColor.count; i++) {
        CGFloat containerWidth = colorContainer.frame.size.width-10;
        CGFloat gridWidth = containerWidth / 4;
        
        CGFloat x = (i%4)*gridWidth+((gridWidth-50)/2)+5;
        CGFloat y = i/4*65+60;
        //
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(x, y, 50, 50);
        button.tag =i;
        button.layer.cornerRadius = 0.5 * button.bounds.size.width;
        [button setBackgroundColor:[self colorWithHexString: [[arrayColor objectAtIndex:i] objectForKey:@"back"]]];
        [button addTarget:self action:@selector(selectColor:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"Tick"] forState:UIControlStateSelected];
        [button setImage:[UIImage imageNamed:@"Tick"] forState:UIControlStateHighlighted];
        
        [chooseBGView bringSubviewToFront:colorContainer];
        [colorContainer addSubview:button];
    }
    
    //Randomly select color
    unsigned long int nElements = [arrayColor count] - 1;
    int n = (arc4random() % nElements) + 1;
    
    [self selectColor:[colorContainer.subviews objectAtIndex:n]];
}

-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    cString = [cString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

- (void)logout {
    FBSDKLoginManager *fb = [[FBSDKLoginManager alloc]init];
    [fb logOut];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"yousayuserid"];
    [defaults setObject:nil forKey:@"yousaytoken"];
    [AppDelegate sharedDelegate].ownerDict = nil;
    [[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:YES];
}


#pragma mark UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    float rawLineNumber = (textView.textInputView.frame.size.height - textView.textContainerInset.top - textView.textContainerInset.bottom) / textView.font.lineHeight;
    int finalLineNumber = round(rawLineNumber);
    // NSLog(@"final: %d", finalLineNumber);
    if ([text isEqualToString:@""]) {
        return YES;
    }
    else if ([textView.text length] > 100 || finalLineNumber > 5) {
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    float rawLineNumber = (textView.contentSize.height - textView.textContainerInset.top - textView.textContainerInset.bottom) / textView.font.lineHeight;
    int finalLineNumber = round(rawLineNumber);
    // NSLog(@"final: %d", finalLineNumber);
    
    if ([textView.text length] > 100 || finalLineNumber > 5) {
        [placeholderLabel setHidden:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeText;
        hud.opacity = 0.1;
        hud.color = [UIColor blackColor];
        hud.labelText = @"Text is limited to 100 characters and 5 lines";
        hud.labelFont = [UIFont systemFontOfSize:12];
        hud.margin = 10.f;
        hud.yOffset = 10.f;
        hud.dimBackground = NO;
        hud.removeFromSuperViewOnHide = YES;
        
        [hud hide:YES afterDelay:1.0];
    }
    else if ([textView.text length] >0){
        [placeholderLabel setHidden:YES];
    }
    else {
        [placeholderLabel setHidden:NO];
    }
}

- (void)keyboardDidShow:(NSNotification*)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    _currentKeyboardHeight = keyboardFrameBeginRect.size.height;
    self.textConstraint.constant = _currentKeyboardHeight+10;
}

- (void)keyboardDidHide:(NSNotification*)notification {
    _currentKeyboardHeight = 0.0;
    self.textConstraint.constant = 10;
    
}


@end