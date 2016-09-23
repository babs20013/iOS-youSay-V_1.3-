//
//  UICheckBox.h
//  youSay
//
//  Created by Baban on 05/12/2015.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^Callback)(BOOL checked);

@interface UICheckBox : UIButton
@property (nonatomic,assign) BOOL checked;
@property (nonatomic, copy) Callback callback;


-(instancetype)initWithStateSelected:(BOOL)selected frame:(CGRect)frame;

@end
