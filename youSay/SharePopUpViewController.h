//
//  SharePopUpViewController.h
//  youSay
//
//  Created by Kapil Maheshwari on 9/13/16.
//  Copyright © 2016 macbokpro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SharePopUpViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *viewGenericBG;
@property (weak, nonatomic) IBOutlet UIView *viewFaceBookBG;

@property (weak, nonatomic) IBOutlet UIView *viewBG;
@property (nonatomic, readwrite) BOOL chartState;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property(weak,nonatomic)id parent;
@property(nonatomic,strong)NSString *strTitle;
@property(nonatomic,strong)NSString *strSubTitle;
@property(nonatomic,strong)NSString *strImageName;
@property (weak, nonatomic) IBOutlet UIImageView *imgBanner;

- (IBAction)facebookButtonClicked:(id)sender;
- (IBAction)genericShareButtonPressed:(id)sender;
- (IBAction)cloaseButtonClicked:(id)sender;

@end
