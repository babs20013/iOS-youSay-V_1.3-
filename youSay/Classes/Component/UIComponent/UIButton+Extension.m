//
//  UIButton+Extension.m
//  youSay
//
//  Created by muthiafirdaus on 22/12/2015.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import "UIButton+Extension.h"

@implementation UIButton (Extension)

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [NSOperationQueue.mainQueue addOperationWithBlock:^{ self.highlighted = YES; }];
    [super touchesBegan:touches withEvent:event];

}


- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self performSelector:@selector(setDefault) withObject:nil afterDelay:0.1];
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    [self performSelector:@selector(setDefault) withObject:nil afterDelay:0.1];
}


- (void)setDefault
{
    [NSOperationQueue.mainQueue addOperationWithBlock:^{ self.highlighted = NO; }];
}

@end
