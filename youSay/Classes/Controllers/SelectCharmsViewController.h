//
//  SelectCharmsViewController.h
//  youSay
//
//  Created by Baban on 17/12/2015.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SelectCharmsViewController;
@protocol CharmSelectionDelegate <NSObject>
- (void) SelectCharmDidDismissed:(NSString*)charmIn;
@end

@interface SelectCharmsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, assign) id parent;
@property (nonatomic, strong) IBOutlet UITableView *tblView;
@property (nonatomic, strong) IBOutlet UITextField *searchTextField;
@property (nonatomic, strong) NSString *charmOut;
@property (nonatomic, strong) NSArray *activeCharm;
@property (nonatomic, weak) id <CharmSelectionDelegate> delegate;
@end