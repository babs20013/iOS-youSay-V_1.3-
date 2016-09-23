//
//  CharmView.m
//  youSay
//
//  Created by muthiafirdaus on 16/12/2015.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import "CharmView.h"
#import "CharmChart.h"
#import "SelectCharmsViewController.h"
#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

@interface CharmView(){
}
@end

@implementation CharmView
@synthesize charts;

-(void)layoutSubviews{
    charts = [NSMutableArray array];
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat w = roundf(self.frame.size.width / 5);
    CGFloat h = self.frame.size.height;
    
    for (int i=0; i<[_chartScores count]; i++) {
        CGRect chartFrame =  CGRectMake(i*w, 0, w,h);
        
        CharmChart *chart = [[CharmChart alloc]initWithFrame:chartFrame];
        chart.delegate = self;
        chart.state = _state;
        chart.score = [[_chartScores objectAtIndex:i] integerValue];
        chart.userRatedScore = [[_chartUserRated objectAtIndex:i] integerValue];
        chart.index = i;
        if ([_chartNames count] > i) {
            chart.title = [_chartNames objectAtIndex:i];
        }
        if ([[_chartLocked objectAtIndex:i] isEqualToString:@"true"]) {
            chart.rated = YES;
        }
        else{
            chart.rated = NO;
        }
        
        if ([[_chartActive objectAtIndex:i] isEqualToString:@"true"]) {
            chart.active = YES;
        }
        else{
            chart.active = NO;
        }
        
        chart.isNeverRate = _isNeverRate;
        
        
        chart.tag = i;
        if (_state != ChartStateEdit && _state != ChartStateRate) {
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapAndHoldChart:)];
            longPress.delegate      =   self;
            [chart addGestureRecognizer:longPress];
            longPress = nil;
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapChart:)];
            tapGesture.delegate = self;
            [chart addGestureRecognizer:tapGesture];
        }
        
        [charts addObject:chart];
        [self addSubview:chart];
        
        if (_state == ChartStateEdit) {
            CGAffineTransform leftWobble = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-1.5));
            CGAffineTransform rightWobble = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(0.5));
            
            chart.transform = leftWobble;  // starting point
            
            [UIView beginAnimations:@"wobble" context:nil];
            [UIView setAnimationRepeatAutoreverses:YES]; // important
            [UIView setAnimationRepeatCount:INFINITY];
            [UIView setAnimationDuration:0.1];
            [UIView setAnimationDelegate:self];
            chart.transform = rightWobble; // end here & auto-reverse
            
            [UIView commitAnimations];
        }
        
    }
}

- (void)tapAndHoldChart:(UILongPressGestureRecognizer*)sender {
    if (_state != ChartStateEdit) {
        [self beginEditing];
    }
    else if (_state != ChartStateViewing) {
        [self beginEditing];
    }
}

- (void)tapChart:(UITapGestureRecognizer*)sender {
    if (_state == ChartStateDefault || _state == ChartStateViewing) {
        [self beginRatingOwnProfile];
    }
}


#pragma mark - Editing Methods
- (void)beginRatingOwnProfile {
    for (CharmChart *chart in charts) {
        for (UIGestureRecognizer *recognizer in chart.gestureRecognizers) {
            if([recognizer isKindOfClass:[UITapGestureRecognizer class]] ||
               [recognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
                [chart removeGestureRecognizer:recognizer];
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(didBeginEditingRateOwnProfile:)]) {
        [self.delegate performSelector:@selector(didBeginEditingRateOwnProfile:) withObject:self];
    }
}

-(void)beginEditing{
    for (CharmChart *chart in charts) {
        for (UIGestureRecognizer *recognizer in chart.gestureRecognizers) {
            if([recognizer isKindOfClass:[UILongPressGestureRecognizer class]] ||
               [recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
                [chart removeGestureRecognizer:recognizer];
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(didBeginEditing:)]) {
        [self.delegate performSelector:@selector(didBeginEditing:) withObject:self];
    }
}

-(void)endEditing{
    for (CharmChart *chart in charts) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapAndHoldChart:)];
        longPress.delegate      =   self;
        [chart addGestureRecognizer:longPress];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapChart:)];
        tapGesture.delegate = self;
        [chart addGestureRecognizer:tapGesture];
    }
    
    if ([self.delegate respondsToSelector:@selector(didEndEditing:)]) {
        [self.delegate performSelector:@selector(didEndEditing:) withObject:self];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}

- (void) showCharmsSelection:(NSString*)charmOut withIndex:(NSString*)index{
    NSArray * arrayOfObjects = [NSArray arrayWithObjects: charmOut, index, nil];
    if ([self.delegate performSelector:@selector(showSelectionOfCharm:) withObject:arrayOfObjects]) {
        [self.delegate showSelectionOfCharm:arrayOfObjects];
    }
}

#pragma mark - Rank Charm

-(void)beginRank{
    _state = ChartStateEdit;
    for (CharmChart *chart in charts) {
        for (UIGestureRecognizer *recognizer in chart.gestureRecognizers) {
            if([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
                [chart removeGestureRecognizer:recognizer];
            }
        }
    }
    
    if ([self.delegate performSelector:@selector(didBeginEditing:) withObject:self]) {
        [self.delegate didBeginEditing:self];
    }
}

@end
