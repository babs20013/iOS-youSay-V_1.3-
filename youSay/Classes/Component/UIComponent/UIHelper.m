//
//  UIHelper.m
//  youSay
//
//  Created by Baban on 05/12/2015.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import "UIHelper.h"

@implementation UIHelper
+(UIButton*)flatButtonWithTitle:(NSString *)title frame:(CGRect)frame{
    UIButton *btn = [[UIButton alloc]initWithFrame:frame];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor colorWithRed:20/255.f green:156/255.f blue:184/255.f alpha:1]];
    btn.layer.cornerRadius = 3;
    btn.layer.shadowOffset = CGSizeMake(0, 1);
    btn.layer.shadowColor = [UIColor blackColor].CGColor;
    btn.layer.shadowRadius = 1.0; 
    btn.layer.shadowOpacity = .5;
    [btn setTitleColor:[UIColor colorWithWhite:0.9 alpha:0.7] forState:UIControlStateHighlighted];

    return btn;
}
@end
