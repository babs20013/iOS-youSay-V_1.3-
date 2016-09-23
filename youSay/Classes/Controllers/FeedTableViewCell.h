//
//  FeedTableViewCell.h
//  youSay
//
//  Created by Baban on 26/12/2015.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *lblDate;
@property (nonatomic, strong) IBOutlet UILabel *lblLikes;
@property (nonatomic, strong) IBOutlet UILabel *lblSaidAbout;
@property (nonatomic, strong) IBOutlet UILabel *lblSaidAbout2;
@property (nonatomic, strong) IBOutlet UILabel *lblSays;
@property (nonatomic, strong) IBOutlet UILabel *lbl1ProfileSay;
@property (nonatomic, strong) IBOutlet UIImageView *imgViewProfile1;
@property (nonatomic, strong) IBOutlet UIImageView *imgViewProfile2;
@property (nonatomic, strong) IBOutlet UIView *viewSays;
@property (nonatomic, strong) IBOutlet UIView *viewBottom;
@property (nonatomic, strong) IBOutlet UIButton *btnReport;
@property (nonatomic, strong) IBOutlet UIButton *btnReportLabel;
@property (nonatomic, strong) IBOutlet UIButton *btnShare;
@property (nonatomic, strong) IBOutlet UIButton *btnShareFB;
@property (nonatomic, strong) IBOutlet UIButton *btnLikes;
@property (nonatomic, strong) IBOutlet UIButton *btnProfile1;
@property (nonatomic, strong) IBOutlet UIButton *btnProfile2;
@property (nonatomic, strong) IBOutlet UIButton *btnLblProfile1;
@property (nonatomic, strong) IBOutlet UIButton *btnLblProfile2;
@property (nonatomic, strong) IBOutlet UIButton *btnLikeCount;
@property (nonatomic, strong) IBOutlet UIButton *btnAddSay;
@property (nonatomic, strong) IBOutlet UIButton *btnDot;
@property (nonatomic, strong) IBOutlet UIView *viewMore;
@property (nonatomic, strong) IBOutlet UIView *viewLikeList;
@end

