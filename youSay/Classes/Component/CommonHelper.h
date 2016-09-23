//
//  CommonHelper.h
//  youSay
//
//  Created by Baban on 10/12/2015.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CommonHelper : NSObject
+(id)instantiateViewControllerWithIdentifier:(NSString*)identifier storyboard:(NSString*)storyboard bundle:(NSBundle*)bundle;

#pragma mark - TEXT
+(CGSize)expectedSizeForLabel:(UILabel*)label attributes:(NSDictionary*)attributes ;
+(CGSize)expectedSizeForString:(NSString*)string width:(CGFloat)width font:(UIFont*)font attributes:(NSDictionary*)attributes ;
@end
