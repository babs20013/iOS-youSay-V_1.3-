//
//  SharePopUpViewController.m
//  youSay
//
//  Created by Kapil Maheshwari on 9/13/16.
//  Copyright © 2016 macbokpro. All rights reserved.
//

#import "SharePopUpViewController.h"
#import "ProfileViewController.h"

@interface SharePopUpViewController ()

@end

@implementation SharePopUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    
    _lblTitle.text = _strTitle;
    
    _viewGenericBG.layer.masksToBounds = YES;
    _viewGenericBG.layer.cornerRadius  = 3;
    
    _viewFaceBookBG.layer.masksToBounds = YES;
    _viewFaceBookBG.layer.cornerRadius  = 3;
    
    _viewBG.layer.masksToBounds = YES;
    _viewBG.layer.cornerRadius  = 5;
    
    _imgBanner.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",_strImageName]];
    _lblTitle.text = [NSString stringWithFormat:@"%@ \n %@",_strTitle,_strSubTitle];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivenewNotification:)
                                                 name:@"closeViewNotification"
                                               object:nil];

    

}

- (void)receivenewNotification:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"closeViewNotification"]) {
        [self performSelector:@selector(popupHide) withObject:self afterDelay:2];
    
    }
}

-(void)popupHide{
    
    ProfileViewController *vc = (ProfileViewController *)_parent;
    
    [self dismissViewControllerAnimated:NO completion:^{
        
        if (_chartState) {
            [vc closeButtonAppear:YES];
        }else{
            [vc closeButtonAppear:NO];
        }
        
    }];

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

- (IBAction)facebookButtonClicked:(id)sender {
    ProfileViewController *vc = (ProfileViewController *)_parent;
    
    [self dismissViewControllerAnimated:NO completion:^{
        [vc btnShareProfileToFacebookClicked:sender];
    }];
}

- (IBAction)genericShareButtonPressed:(id)sender {
    ProfileViewController *vc = (ProfileViewController *)_parent;
    
    [self dismissViewControllerAnimated:NO completion:^{
        [vc btnShareProfileClicked:sender];
    }];
}

- (IBAction)cloaseButtonClicked:(id)sender {
    ProfileViewController *vc = (ProfileViewController *)_parent;

    [self dismissViewControllerAnimated:NO completion:^{
        
        if (_chartState) {
               [vc closeButtonAppear:YES];
        }else{
               [vc closeButtonAppear:NO];
        }
        
    }];
}
@end
