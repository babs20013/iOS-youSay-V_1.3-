//
//  ProfileTableViewCell.h
//  BLKFlexibleHeightBar Demo
//
//  Created by BDP on 10/21/15.
//  Copyright (c) 2015 Bryan Keller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CharmView.h"
@interface ProfileTableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UIImageView *imgViewCover;
@property (nonatomic, strong) IBOutlet UIImageView *imgViewProfilePicture;
@property (nonatomic, strong) IBOutlet UIImageView *newbie;
@property (nonatomic, strong) IBOutlet UIImageView *popular;
@property (nonatomic, strong) IBOutlet UILabel *lblName;
@property (nonatomic, strong) IBOutlet UILabel *lblCharm1;
@property (nonatomic, strong) IBOutlet UILabel *lblCharm2;
@property (nonatomic, strong) IBOutlet UILabel *lblCharm3;
@property (nonatomic, strong) IBOutlet UILabel *lblCharm4;
@property (nonatomic, strong) IBOutlet UILabel *lblCharm5;
@property (nonatomic, strong) IBOutlet UIView *viewCharm1;
@property (nonatomic, strong) IBOutlet UIView *viewCharm2;
@property (nonatomic, strong) IBOutlet UIView *viewCharm3;
@property (nonatomic, strong) IBOutlet UIView *viewCharm4;
@property (nonatomic, strong) IBOutlet UIView *viewCharm5;
@property (nonatomic, strong) IBOutlet UILabel *lblRankLevel;
@property (nonatomic, strong) IBOutlet UILabel *lblPopularityLevel;
@property (nonatomic, strong) IBOutlet UILabel *lblRankCount;
@property (nonatomic, strong) IBOutlet UILabel *lblPopularityCount;
@property (nonatomic, strong) IBOutlet UILabel *lblTotalScore;
@property (nonatomic, strong) IBOutlet UIView *charmView;
@property (nonatomic, strong) IBOutlet CharmView *charmChartView;

@property (nonatomic, strong) IBOutlet UIView *longPressInfoView;
@property (nonatomic, strong) IBOutlet UIButton *btnShare;
@property (nonatomic, strong) IBOutlet UIButton *btnDone;
@property (nonatomic, strong) IBOutlet UIButton *rankButton;
@property (nonatomic, strong) IBOutlet UILabel *lblShare;
@property (nonatomic, strong) IBOutlet UIImageView *imgVShare;

@property (nonatomic, strong) IBOutlet UIView *buttonEditView;
@property (nonatomic, strong) IBOutlet UIView *LongPressToRankView;
@property (nonatomic, strong) IBOutlet UILabel *lblYourCharm;
@property (nonatomic, strong) IBOutlet UILabel *lblWhatPeopleSay;
@property (nonatomic, strong) IBOutlet UIView *defaultFooterView;
@property (nonatomic, strong) IBOutlet UIView *cancelSkip;
@property (nonatomic, strong) IBOutlet UILabel *lblNeverRate;
@property (nonatomic, strong) IBOutlet UILabel *lblTotalRateTitle;
@property (nonatomic, strong) IBOutlet UIImageView *imgHand;
@property (nonatomic, strong) IBOutlet UIButton *btnSkip;
@property (nonatomic, strong) IBOutlet UIView *line;

@property (nonatomic, strong) NSDictionary *saysDictionary;
@property (weak, nonatomic) IBOutlet UIImageView *imgEditIcon;

@property (weak, nonatomic) IBOutlet UIButton *btnProfilePic;
@property (weak, nonatomic) IBOutlet UIButton *btnBadge;
@property (weak, nonatomic) IBOutlet UIButton *btnRate;
@property (weak, nonatomic) id parent;
- (IBAction)ScoreClicked:(id)sender;
- (IBAction)profileClicked:(id)sender;
- (IBAction)ratesClicked:(id)sender;
- (IBAction)editButtonPressed:(id)sender;

@end
