//
//  UICheckBox.m
//  youSay
//
//  Created by Baban on 05/12/2015.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import "UICheckBox.h"
@interface UICheckBox(){
    UIImageView *imageState;
}
@end

@implementation UICheckBox

- (instancetype)init
{
    return [self initWithStateSelected:NO frame:CGRectMake(0, 0, 25, 25)];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

-(instancetype)initWithStateSelected:(BOOL)selected frame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.selected = selected;
        [self setup];
    }
    return self;
}
-(void)setup{

    [self addTarget:self action:@selector(onTouch) forControlEvents:UIControlEventTouchUpInside];

    imageState = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [self addSubview:imageState];
}
-(void)layoutSubviews{
    [self updateUI];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, imageState.frame.size.width, self.frame.size.height);
}

-(void)updateState{
    _checked = !_checked;
    [self updateUI];
}
-(void)updateUI{
    
    if (_checked) {
        imageState.image = [UIImage imageNamed:@"checked"];
    }
    else{
        imageState.image = [UIImage imageNamed:@"unchecked"];
    }
    
    if (self.callback) {
        self.callback(_checked);
    }
}
-(void)onTouch{
    [self updateState];
}

-(void)setChecked:(BOOL)checked{
    _checked = checked;
    [self updateUI];
}

@end
