//
//  MenuViewController.h
//  youSay
//
//  Created by muthiafirdaus on 10/12/2015.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController<UITableViewDataSource,UITableViewDataSource, FBSDKAppInviteDialogDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableLeadingConstraint;
@end
