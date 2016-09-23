//
//  SearchViewController.h
//  youSay
//
//  Created by Baban on 04/12/2015.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tblView;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *tableBottomConstraint;

@end