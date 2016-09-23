//
//  CharmChart.m
//  youSay
//
//  Created by muthiafirdaus on 14/12/2015.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import "CharmChart.h"

#define kColor10 [UIColor colorWithRed:236.0/255.0 green:161.0/255.0 blue:20.0/255.0 alpha:1.0]
#define kColor20 [UIColor colorWithRed:214.0/255.0 green:163.0/255.0 blue:16.0/255.0 alpha:1.0]
#define kColor30 [UIColor colorWithRed:150.0/255.0 green:167.0/255.0 blue:14.0/255.0 alpha:1.0]
#define kColor40 [UIColor colorWithRed:90.0/255.0 green:171.0/255.0 blue:14.0/255.0 alpha:1.0]
#define kColor50 [UIColor colorWithRed:51.0/255.0 green:172.0/255.0 blue:37.0/255.0 alpha:1.0]
#define kColor60 [UIColor colorWithRed:51.0/255.0 green:171.0/255.0 blue:78.0/255.0 alpha:1.0]
#define kColor70 [UIColor colorWithRed:51.0/255.0 green:167.0/255.0 blue:125.0/255.0 alpha:1.0]
#define kColor80 [UIColor colorWithRed:51.0/255.0 green:165.0/255.0 blue:153.0/255.0 alpha:1.0]
#define kColor90 [UIColor colorWithRed:51.0/255.0 green:163.0/255.0 blue:170.0/255.0 alpha:1.0]
#define kColor100 [UIColor colorWithRed:51.0/255.0 green:161.0/255.0 blue:188.0/255.0 alpha:1.0]
#define kColorDefault [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0]
#define kChartTitleLabelColor [UIColor colorWithRed:90.0/255.0 green:90.0/255.0 blue:90.0/255.0 alpha:1.0]
#define kChartScoreLabelColor [UIColor colorWithRed:0.0/255.0 green:172.0/255.0 blue:196.0/255.0 alpha:1.0]


#define kMaximumScore 10

//#define kMinVerticalGap 1
//#define kMinHorizontalGap 5
//#define kChartLabelHeight 29

//#define kMinVerticalGap 7.0
#define kMinHorizontalGap 10
#define kChartLabelHeight 33

#define kDefaultFontArialBold @"Arial-BoldMT"
#define kDefaultFontHelvetica @"Helvetica-Neue"


@interface CharmChart(){
    NSMutableArray *boxes;
    UIButton *btn;
    UIButton *btnClose;
    NSInteger kMinVerticalGap;
}
@end
@implementation CharmChart
@synthesize lblScore;
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _score = 0;
        if ([UIScreen mainScreen].bounds.size.height <= 480) {
            kMinVerticalGap = 4.0;
        }
        else if ([UIScreen mainScreen].bounds.size.height <= 568) {
            kMinVerticalGap = 4.3;
        }
        else {
            kMinVerticalGap = 7.0;
        }
        
    }
    return self;
}


-(void)layoutSubviews{
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSInteger roundedScore = [self roundedScore];
    NSInteger roundedUserRatedScore = [self roundedUserRatedScore];
    boxes = [NSMutableArray array];
    for (int i = 0; i<kMaximumScore; i++) {
        CGFloat barValue = ((i+1) * 10);
        
        UIView *valueBox = [[UIView alloc]initWithFrame:CGRectMake(kMinHorizontalGap/2,self.frame.size.height- (i*([self boxSize].height+kMinVerticalGap) + [self boxSize].height)-kChartLabelHeight, [self boxSize].width, [self boxSize].height)];
        [valueBox setBackgroundColor:kColorDefault];
        [valueBox setHidden:NO];
        valueBox.tag = i+1;
        if (( roundedScore >= 0 && roundedScore >= barValue )) {
            [valueBox setBackgroundColor:[self getColor:i+1]];
            [valueBox setHidden:NO];
        }
        valueBox.layer.cornerRadius = 0.02 * valueBox.bounds.size.width;
        valueBox.layer.masksToBounds = YES;
        [self addSubview:valueBox];
        
        if (_state == ChartStateEdit) {        }
        else if (_state == ChartStateViewing ){
            if ( _score == 0 && !_rated) {
                [valueBox setBackgroundColor:[self getColor:0]];
                [valueBox setHidden:NO];
            }
            else if(!_active || _isNeverRate){
                //on viewing mode if its not yet rated user can see the actual score before set rating
                _score = 0;//
                //if not rated change val to 0 so able to rate
                [valueBox setHidden:NO];
                [valueBox setBackgroundColor:[self getColor:0]];
            }
        }
        else if ( _state == ChartStateRate){
            if (_rated && !_isNeverRate) {
                _score = _userRatedScore;
                if (roundedUserRatedScore >= 0 && roundedUserRatedScore >= barValue) {
                    [valueBox setBackgroundColor:[self getColor:i+1]];
                    [valueBox setHidden:NO];
                }
                else {
                    [valueBox setBackgroundColor:kColorDefault];
                }
            }
            else{
                _score = 0;//
                //if not rated change val to 0 so able to rate
                [valueBox setHidden:NO];
                [valueBox setBackgroundColor:[self getColor:0]];
                
            }
        }
        
        [boxes addObject:valueBox];
    }
    
    if (_state == ChartStateRate && _rated == YES) {
        CGFloat widthHeightLock = [self boxSize].height*2-4;
        //        CGFloat originalY = 11*([self boxSize].height+kMinVerticalGap) + [self boxSize].height-kChartLabelHeight;
        UIImageView *imgLocked = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"lock"]];
        imgLocked.frame = CGRectMake((self.frame.size.width-widthHeightLock)/2,
                                     (self.frame.size.height - widthHeightLock)-kChartLabelHeight-2,
                                     widthHeightLock,
                                     widthHeightLock);
        // [self addSubview:imgLocked];
    }
    
    UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, self.frame.size.height-kChartLabelHeight+5, self.frame.size.width, kChartLabelHeight)];
    [lblTitle setText:_title];
    [lblTitle setFont:[UIFont systemFontOfSize:10]];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setTextColor:kChartTitleLabelColor];
    lblTitle.numberOfLines = 0;
    
    
    CGRect frame = lblTitle.frame;
    [lblTitle sizeToFit];
    frame.size.height = lblTitle.frame.size.height;
    lblTitle.frame = CGRectMake(0, self.frame.size.height-kChartLabelHeight+5, self.frame.size.width, lblTitle.frame.size.height);
    [self addSubview:lblTitle];
    
    float position = ceil(roundedScore/10)+1;
    if ((_state == ChartStateViewing && _score == 0 && !_active) ||
        (_state ==  ChartStateRate && !_rated) ||
        (_state != ChartStateDefault && _isNeverRate && _state != ChartStateEdit)){
        position = 12;
    }
    else if (self.score == 0 && _state != ChartStateRate){
        position = 2;
    }
    else if (_state == ChartStateRate) {
        position = ceil(roundedUserRatedScore/10)+1;
    }

    lblScore = [[UILabel alloc]initWithFrame:CGRectMake(kMinHorizontalGap/2,self.frame.size.height- ((position-1)*([self boxSize].height+kMinVerticalGap) + [self boxSize].height)-kChartLabelHeight, [self boxSize].width, [self boxSize].height)];
    
    if (_active){
        [lblScore setText:[NSString stringWithFormat:@"%ld",(long)_score]];
    }
    else {
        [lblScore setText:_state ==  ChartStateRate ? @"0" : [NSString stringWithFormat:@"%ld",(long)_score]];
    }
    
    [lblScore setFont:[UIFont systemFontOfSize:13]];
    NSString *string = @"The string to render";
    CGSize size = [string sizeWithAttributes: @{NSFontAttributeName: [UIFont systemFontOfSize:13.0f]}];
    float pointsPerPixel = 13.0 / size.height;
    float desiredFontSize = ([self boxSize].height+4) * pointsPerPixel;
    
    [lblScore setFont:[UIFont systemFontOfSize:desiredFontSize]];
    if (position > 11 && _state ==  ChartStateRate) {
        [lblScore setHidden:YES];
    }
    else if (position > 11 && _state == ChartStateViewing){
        [lblScore setHidden:YES];
    }
    
    lblScore.textAlignment = NSTextAlignmentCenter;
    [lblScore setTextColor:[self getColor:roundedScore/10]];
    [self addSubview:lblScore];
    
    btn = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width-[self boxSize].height-25, lblScore.frame.origin.y-13, ([self boxSize].height+50), ([self boxSize].height+50))];
    [btn setImage:[UIImage imageNamed:@"charm-close"] forState:UIControlStateNormal];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn addTarget:self
            action:@selector(btnCloseClicked: withCharm:)
  forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    
    btnClose = [[UIButton alloc]initWithFrame:CGRectMake(lblTitle.frame.origin.x, 0, ([self boxSize].height+50), self.frame.size.height)];
    [btnClose setBackgroundColor:[UIColor clearColor]];
    [btnClose addTarget:self
                 action:@selector(btnCloseClicked: withCharm:)
       forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnClose];
    
    [btn setHidden:YES];
    [btnClose setHidden:YES];
    if (_state == ChartStateEdit) {
        [btn setHidden:NO];
        [btnClose setHidden:NO];
    }
    else if (_state == ChartStateViewing && !_active){
        [lblScore setHidden:YES];
    }
    
    if (_state == ChartStateRate) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchChart:)];
        tap.delegate      =   self;
        [self addGestureRecognizer:tap];
        tap = nil;
        
        UIPanGestureRecognizer *longPress = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchAndPanChart:)];
        longPress.delegate      =   self;
        [self addGestureRecognizer:longPress];
        longPress = nil;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSInteger animationCount = [[defaults objectForKey:@"animation"] integerValue];
        if (animationCount < 6 && _isNeverRate) {
            [self showAnimation];
        }
    }
    [self bringSubviewToFront:btnClose];
}

- (void)showAnimation {
    for (int i = 0; i < 10; i++) {
        UIView *box = [boxes objectAtIndex:i];
        if (self.frame.origin.x == 0 && i < 8) {
            box.tag = i+1;
            float minTime = 1.5/8;
            if  (box.tag < 3){
                [self animaTeCharm:box];
            }
            else {
                float time = minTime * (box.tag-2);
                [self performSelector:@selector(animaTeCharm:) withObject:box afterDelay:time];
            }
        }
    }
    for (int i = 7; i >= 0; i--) {
        UIView *box = [boxes objectAtIndex:i];
        if (self.frame.origin.x == 0 && i < 8) {
            box.tag = i+1;
            float minTime = 3.0/12;
            if  (box.tag < 3){
                [self performSelector:@selector(animaTeCharm2:) withObject:box afterDelay:3.0];
            }
            else if (box.tag == 8){
                float time = minTime *7;
                [self performSelector:@selector(animaTeCharm2:) withObject:box afterDelay:time];
            }
            else if (box.tag == 7){
                float time = minTime *8;
                [self performSelector:@selector(animaTeCharm2:) withObject:box afterDelay:time];
            }
            else if (box.tag == 6){
                float time = minTime *9;
                [self performSelector:@selector(animaTeCharm2:) withObject:box afterDelay:time];
            }
            else if (box.tag == 5){
                float time = minTime *10;
                [self performSelector:@selector(animaTeCharm2:) withObject:box afterDelay:time];
            }
            else if (box.tag == 4){
                float time = minTime *11;
                [self performSelector:@selector(animaTeCharm2:) withObject:box afterDelay:time];
            }
            else if (box.tag == 3){
                float time = minTime *12;
                [self performSelector:@selector(animaTeCharm2:) withObject:box afterDelay:time];
            }
        }
    }
}

- (void)animaTeCharm:(UIView*)box {
    [box setHidden:NO];
    [box setBackgroundColor:[self getColor:box.tag]];
}

- (void)animaTeCharm2:(UIView*)box {
    [box setHidden:NO];
    [box setBackgroundColor:[self getColor:0]];
}


-(CGSize)boxSize{
    return CGSizeMake(self.frame.size.width-kMinHorizontalGap, ((self.frame.size.width-kMinHorizontalGap)/5));
}

-(NSInteger)roundedScore{
    NSInteger roundedScore = 0;
    if (_score < 10) {
        roundedScore = 10;
    }
    else if (_score%10 < 5) {
        roundedScore = _score/10*10;
    }
    else {
        roundedScore = _score/10*10+10;
    }
    return roundedScore;
}

-(NSInteger)roundedUserRatedScore{
    NSInteger roundedScore = 0;
    if (_userRatedScore < 10) {
        roundedScore = 10;
    }
    else if (_userRatedScore%10 < 5) {
        roundedScore = _userRatedScore/10*10;
    }
    else {
        roundedScore = _userRatedScore/10*10+10;
    }
    return roundedScore;
}

- (UIColor*)getColor:(NSInteger)index {
    UIColor *color;
    switch (index) {
        case 1:
            color = kColor10;
            break;
        case 2:
            color = kColor20;
            break;
        case 3:
            color = kColor30;
            break;
        case 4:
            color = kColor40;
            break;
        case 5:
            color = kColor50;
            break;
        case 6:
            color = kColor60;
            break;
        case 7:
            color = kColor70;
            break;
        case 8:
            color = kColor80;
            break;
        case 9:
            color = kColor90;
            break;
        case 10:
            color = kColor100;
            break;
        default:
            color = kColorDefault;
            break;
    }
    return color;
}

//-(void)changeStateOfChart{
//    for (UIView *box in boxes) {
//        [self wiggleAnimation:box];
//    }
//}
//
//-(void)wiggleAnimation:(UIView*)v{
//    if (_state == ChartStateEdit) {
//        CGAffineTransform leftWobble = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-2.0));
//        CGAffineTransform rightWobble = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(2.0));
//
//        v.transform = leftWobble;  // starting point
//
//        [UIView beginAnimations:@"wobble" context:nil];
//        [UIView setAnimationRepeatAutoreverses:YES]; // important
//        [UIView setAnimationRepeatCount:INFINITY];
//        [UIView setAnimationDuration:0.1];
//        [UIView setAnimationDelegate:self];
//        v.layer.speed = 0.1;
//
//        //    [UIView setAnimationDidStopSelector:@selector(wobbleEnded:finished:context:)];
//
//        v.transform = rightWobble; // end here & auto-reverse
//
//        [UIView commitAnimations];
//    }
//    else{
//        //Stop Wiggling
//        v.transform = CGAffineTransformIdentity;
//    }
//}

-(void)updateRateOnPoint:(CGPoint)point{
    //    NSLog(@"Touch & Pan - %@",NSStringFromCGPoint(point));
    UIView *bottomBox = [boxes objectAtIndex:0];
    CGFloat bottomY = bottomBox.frame.origin.y + (bottomBox.frame.size.height+kMinVerticalGap);
    CGFloat perPoint = (((bottomY-((UIView*)[boxes lastObject]).frame.origin.y ) / kMaximumScore)/10);
    CGFloat increase = (bottomY - point.y)/perPoint;
    //    NSLog(@"Increase: %@",[NSString stringWithFormat:@"%f",increase]);
    
    if (increase < 0) {
        self.score = 0;
    }
    else if (increase > 100){
        self.score = 100;//max
    }
    else{
        self.score = ceilf(increase);
    }
    
    NSInteger roundedScore = 0;
    if (self.score < 10) {
        roundedScore = 10;
    }
    else if (self.score%10 < 5) {
        roundedScore = self.score/10*10;
    }
    else {
        roundedScore = self.score/10*10+10;
    }
    
    float position = ceil(roundedScore/10)+1;
    
    if (position <= 1) {
        position = 2;
    }
    else if (position > 11){
        position= 12;//max
    }
    [lblScore setHidden:NO];
    lblScore.frame = CGRectMake(kMinHorizontalGap/2,self.frame.size.height- (position*([self boxSize].height+kMinVerticalGap))-kChartLabelHeight, [self boxSize].width, [self boxSize].height);
    [lblScore setText:[NSString stringWithFormat:@"%ld",(long)self.score]];
    
    for (UIView *box in boxes) {
        if (box.tag < position ) {
            [box setHidden:NO];
            [box setBackgroundColor:[self getColor:box.tag]];
        }else{
            [box setHidden:YES];
            [box setBackgroundColor:[self getColor:0]];
        }
    }
    
}
- (IBAction)btnCloseClicked:(id)sender withCharm:(NSString*)selectedCharm{
    if([self.delegate respondsToSelector:@selector(showCharmsSelection: withIndex:)]) {
        [self.delegate showCharmsSelection:_title withIndex:[NSString stringWithFormat:@"%li", (long)_index]];
    }
    
}

- (void)onTouchAndPanChart:(UIPanGestureRecognizer*)sender {
    CGPoint touchPoint = [sender locationInView: self];
    [self updateRateOnPoint:touchPoint];
}

- (void)onTouchChart:(UITapGestureRecognizer*)sender {
    CGPoint touchPoint = [sender locationInView: self];
    [self updateRateOnPoint:touchPoint];
}

@end
