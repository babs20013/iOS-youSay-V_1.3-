//
//  MessageTableViewCell.h
//  BLKFlexibleHeightBar Demo
//
//  Created by BDP on 10/21/15.
//  Copyright (c) 2015 Bryan Keller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageTableViewCell : UITableViewCell
@property (nonatomic , strong) IBOutlet UIButton * hideButton;
@property (nonatomic , strong) IBOutlet UIButton * UNDOButton;
@property (nonatomic , strong) IBOutlet UIView * UNDOView;

@property (nonatomic, strong) IBOutlet UILabel * userNameLabel;
@property (nonatomic, strong) IBOutlet UILabel * likeCountLabel;
@property (nonatomic, strong) IBOutlet UIButton * likeButton;
@property (nonatomic, strong) IBOutlet UITextView * messageLabel;

@end
