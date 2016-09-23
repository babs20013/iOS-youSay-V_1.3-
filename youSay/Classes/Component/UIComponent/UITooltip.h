//
//  UITooltip.h
//  youSay
//
//  Created by muthiafirdaus on 09/05/2016.
//  Copyright © 2016 macbokpro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITooltip : UIView
typedef enum {
    TipArrowTopLeft,
    TipArrowBottomLeft,
    TipArrowMiddleRight
} TipArrow;

typedef void (^OnTapActionBlock)();

@property (nonatomic, strong) NSString* backgroundImage;
@property (nonatomic, strong) NSString* tooltipText;
@property (nonatomic, strong) NSDictionary* imgMap;
@property (nonatomic) TipArrow tipArrow;
@property (copy, nonatomic) OnTapActionBlock onTap;

-(void)onButtonTap:(OnTapActionBlock)block;
-(void)closeToolTip;
-(void)showToolTip:(UIView*)view;

@end
