
//
//  ProfileTableViewCell.m
//  BLKFlexibleHeightBar Demo
//
//  Created by BDP on 10/21/15.
//  Copyright (c) 2015 Bryan Keller. All rights reserved.
//

#import "ProfileTableViewCell.h"
#import "ProfileViewController.h"

@implementation ProfileTableViewCell
@synthesize imgViewCover, imgViewProfilePicture, newbie, popular, lblName;
@synthesize lblCharm1, lblCharm2, lblCharm3, lblCharm4, lblCharm5;
@synthesize viewCharm1, viewCharm2, viewCharm3, viewCharm4, viewCharm5;

- (void)awakeFromNib {
    // Initialization code
}

//-(void)layoutSubviews{
//    [super layoutSubviews];
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)ScoreClicked:(id)sender {
    
    UIButton *btn = (UIButton*)sender;
    ProfileViewController *vc = (ProfileViewController*)_parent;
    CGRect frame = [vc.view convertRect:btn.frame fromView:btn];

    [vc profileCircularImageClicked:sender Frame:frame];
}

- (IBAction)profileClicked:(id)sender {
    
    UIButton *btn = (UIButton*)sender;

    ProfileViewController *vc = (ProfileViewController*)_parent;

    CGRect frame = [vc.view convertRect:btn.frame fromView:btn];
    
    [vc profileClickeded:sender Frame:frame];
    
}

- (IBAction)ratesClicked:(id)sender {
    UIButton *btn = (UIButton*)sender;
    
    ProfileViewController *vc = (ProfileViewController*)_parent;
    
    CGRect frame = [vc.view convertRect:btn.frame fromView:btn];
    
    [vc ratesClickedabc:sender Frame:frame];
}

- (IBAction)editButtonPressed:(id)sender {
    ProfileViewController *vc = (ProfileViewController*)_parent;
    [vc EnableCharmRateMode];
}
@end
