//
//  AddNewSayViewController.h
//  youSay
//
//  Created by Baban on 04/12/2015.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileOwnerModel.h"

@class AddNewSayViewController;
@protocol AddNewSayDelegate <NSObject>
- (void) AddNewSayDidDismissed;
- (void) AddNewSayDidDismissedWithCancel;
@end


@interface AddNewSayViewController : GAITrackedViewController <UITextViewDelegate>

@property (nonatomic, strong) IBOutlet UITextView *addSayTextView;
@property (nonatomic, strong) IBOutlet UIView *textViewBG;
@property (nonatomic, strong) IBOutlet UIView *profileView;
@property (nonatomic, strong) IBOutlet UIView *chooseBGView;
@property (nonatomic, strong) IBOutlet UIView *colorContainer;
@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UIImageView *profileImg;
@property (nonatomic, strong) IBOutlet UIImageView *coverImg;
@property (nonatomic, strong) IBOutlet UILabel *profileLabel;
@property (nonatomic, strong) IBOutlet UILabel *placeholderLabel;
@property (nonatomic, strong) ProfileOwnerModel *model;
@property (nonatomic, strong) NSDictionary *colorDict;
@property (nonatomic, weak) id <AddNewSayDelegate> delegate;

@property (nonatomic,strong) IBOutlet NSLayoutConstraint *textConstraint;
@property (nonatomic,strong) IBOutlet NSLayoutConstraint *containerHeightCosntraint;

@end