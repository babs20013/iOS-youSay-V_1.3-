//
//  PeopleSayTableViewCell.h
//  BLKFlexibleHeightBar Demo
//
//  Created by BDP on 10/21/15.
//  Copyright (c) 2015 Bryan Keller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeopleSayTableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *peopleSayTitleLabel;
@property (nonatomic, strong) IBOutlet UIImageView *imgViewProfilePic;
@property (nonatomic, strong) IBOutlet UIView *peopleSayView;
@property (nonatomic, strong) IBOutlet UILabel *peopleSayLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *likesLabel;
@property (nonatomic, strong) IBOutlet UIButton *btnHide;
@property (nonatomic, strong) IBOutlet UIButton *btnUndo;
@property (nonatomic, strong) IBOutlet UIButton *btnProfile;
@property (nonatomic, strong) IBOutlet UIView *hideSayView;
@property (nonatomic, strong) IBOutlet UIView *mainView;
@property (nonatomic, strong) IBOutlet UIButton *likeButton;
@property (nonatomic, strong) IBOutlet UIButton *btnShare;
@property (nonatomic, strong) IBOutlet UIButton *btnReport;
@property (nonatomic, strong) IBOutlet UIButton *btnReportLabel;
@property (nonatomic, strong) IBOutlet UIButton *btnInstagram;
@property (nonatomic, strong) IBOutlet UIButton *btnInstagramLabel;
@property (nonatomic, strong) IBOutlet UIButton *btnLikeCount;
@property (nonatomic, strong) IBOutlet UIButton *btnShareFB;
@property (nonatomic, strong) IBOutlet UIButton *btnLike;
@property (nonatomic, strong) IBOutlet UIButton *btnDot;
@property (nonatomic, strong) IBOutlet UIView *viewMore;
@property (nonatomic, strong) IBOutlet UIView *viewLikeList;
@property (nonatomic, readwrite) BOOL willDisplayMenu;
@end

