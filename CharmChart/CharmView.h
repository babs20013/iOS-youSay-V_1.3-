//
//  CharmView.h
//  youSay
//
//  Created by muthiafirdaus on 16/12/2015.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CharmChart.h"

@class CharmView;
@protocol CharmChartDelegate <NSObject>

//Edit Mode
-(void)didBeginEditing:(CharmView*)charm ;
-(void)didBeginEditingRateOwnProfile:(CharmView*)charm;
-(void)didEndEditing:(CharmView*)charm ;

-(void)showSelectionOfCharm:(NSArray*)charmNameAndIndex;
@end

@interface CharmView : UIView<UIGestureRecognizerDelegate, CharmDelegate>

@property (assign,nonatomic) ChartState state;
@property (assign,nonatomic) id<CharmChartDelegate> delegate;
@property (strong,nonatomic) NSMutableArray *chartScores;
@property (strong,nonatomic) NSMutableArray *chartNames;
@property (strong,nonatomic) NSMutableArray *chartLocked;
@property (strong,nonatomic) NSMutableArray *chartActive;
@property (strong,nonatomic) NSMutableArray *chartUserRated;
@property (strong,nonatomic) NSMutableArray *charts;
@property (readwrite,nonatomic) BOOL isNeverRate;


-(void)beginEditing;
-(void)endEditing;
- (void)beginRatingOwnProfile;
@end

