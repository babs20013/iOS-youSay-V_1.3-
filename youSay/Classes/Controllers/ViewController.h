//
//  ViewController.h
//  youSay
//
//  Created by Baban on 10/20/15.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "SlideNavigationController.h"

#import "PageControl.h"

@interface ViewController : GAITrackedViewController  <PageControlDelegate,UIScrollViewDelegate, SlideNavigationControllerDelegate, FBSDKAppInviteDialogDelegate>

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@end

