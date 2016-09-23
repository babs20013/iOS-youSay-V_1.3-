//
//  CustomePopOverVC.m
//  youSay
//
//  Created by Kapil Maheshwari on 9/11/16.
//  Copyright © 2016 macbokpro. All rights reserved.
//

#import "CustomePopOverVC.h"
#import "ProfileViewController.h"
#import <UIKit/UIKit.h>

@interface CustomePopOverVC ()

@end

@implementation CustomePopOverVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _whiteView.layer.masksToBounds = YES;
    _whiteView.layer.cornerRadius = 5;
    
    _blackView.layer.masksToBounds = YES;
    _blackView.layer.cornerRadius = 5;
    
    ProfileViewController *vc = (ProfileViewController *)_parent;
    
    if (!vc.isFriendProfile) {
        _lblTitle.text = _strTitle;
        _lblDetailedText.text = _strDesc;
    }else{
        _lblTitle.text = _strTitle;
        _lblDetailedText.text = _strDesc;
    }

}
-(void)viewWillAppear:(BOOL)animated{

    
    UIButton *btn = (UIButton *)_objButton;
    
    _YPosition.constant = _y;
    _XPosition.constant = btn.frame.origin.x+btn.frame.size.width/2;
    
//    [self.view setNeedsDisplay];
//    [self.view setNeedsLayout];
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

- (IBAction)dissmissButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)shareButtonClicked:(id)sender {
    
    ProfileViewController *vc = (ProfileViewController *)_parent;

    [self dismissViewControllerAnimated:NO completion:^{
        [vc btnShareProfileClicked:sender];
    }];
}

- (IBAction)dissmissUI:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];

}
@end
