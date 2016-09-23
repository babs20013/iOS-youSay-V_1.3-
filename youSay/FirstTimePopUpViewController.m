//
//  FirstTimePopUpViewController.m
//  youSay
//
//  Created by Kapil Maheshwari on 9/12/16.
//  Copyright © 2016 macbokpro. All rights reserved.
//

#import "FirstTimePopUpViewController.h"
#import "ProfileViewController.h"
@interface FirstTimePopUpViewController ()

@end

@implementation FirstTimePopUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    _lblFirstText.text = _strTitle;
    _lblSecondText.text = _strDesc;
    
    _btnGotIt.layer.masksToBounds =YES;
    _btnGotIt.layer.cornerRadius = 5;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)gotItButtonClicked:(id)sender {
    ProfileViewController *vc = (ProfileViewController *)_parent;
    
    [self dismissViewControllerAnimated:NO completion:^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"myNotification" object:self];
        //[vc StartRateMode];
    }];
    
    
}
@end
