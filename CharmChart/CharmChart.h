//
//  CharmChart.h
//  youSay
//
//  Created by muthiafirdaus on 14/12/2015.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CharmChart;
@protocol CharmDelegate <NSObject>
- (void) showCharmsSelection:(NSString*)charmOut withIndex:(NSString*)index;
@end //end protocol


@interface CharmChart : UIView<UIGestureRecognizerDelegate>
typedef enum {
    ChartStateDefault,
    ChartStateEdit,
    //    ChartStateLock,
    ChartStateRate,
    ChartStateViewing
} ChartState;


@property (assign,nonatomic) ChartState state;
@property (assign,nonatomic) BOOL rated;
@property (assign,nonatomic) BOOL active;
@property (assign,nonatomic) BOOL isNeverRate;
@property (assign,nonatomic) NSInteger score;
@property (assign,nonatomic) NSInteger userRatedScore;
@property (assign,nonatomic) NSInteger index;
@property (retain,nonatomic) UILabel *lblScore;
@property (copy,nonatomic) NSString *title;
@property (nonatomic, weak) id <CharmDelegate> delegate;

@end
