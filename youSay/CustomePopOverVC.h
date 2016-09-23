//
//  CustomePopOverVC.h
//  youSay
//
//  Created by Kapil Maheshwari on 9/11/16.
//  Copyright © 2016 macbokpro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomePopOverVC : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imgArrow;

@property (weak, nonatomic) id parent;
@property (weak, nonatomic) id objButton;

@property (nonatomic) float x;
@property (nonatomic) float y;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *YPosition;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *XPosition;
- (IBAction)dissmissButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *blackView;
@property (weak, nonatomic) IBOutlet UIView *whiteView;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDetailedText;
@property (weak, nonatomic) IBOutlet UIButton *bthSHare;

@property(nonatomic,strong)NSString *strTitle;
@property(nonatomic,strong)NSString *strDesc;

- (IBAction)shareButtonClicked:(id)sender;
- (IBAction)dissmissUI:(id)sender;

@end
