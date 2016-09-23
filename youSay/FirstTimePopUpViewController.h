//
//  FirstTimePopUpViewController.h
//  youSay
//
//  Created by Kapil Maheshwari on 9/12/16.
//  Copyright © 2016 macbokpro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstTimePopUpViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *lblFirstText;
@property (weak, nonatomic) IBOutlet UILabel *lblSecondText;

@property (weak, nonatomic) IBOutlet UIButton *btnGotIt;

@property(nonatomic,strong)NSString *strTitle;
@property(nonatomic,strong)NSString *strDesc;

@property (weak, nonatomic) id parent;
- (IBAction)gotItButtonClicked:(id)sender;

@end
