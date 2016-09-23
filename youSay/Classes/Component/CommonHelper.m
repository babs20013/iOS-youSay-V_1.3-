//
//  CommonHelper.m
//  youSay
//
//  Created by Baban on 10/12/2015.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import "CommonHelper.h"
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define iOS7_0 @"7.0"

@implementation CommonHelper
+(id)instantiateViewControllerWithIdentifier:(NSString*)identifier storyboard:(NSString*)storyboard bundle:(NSBundle*)bundle{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:storyboard bundle:bundle];
    return [sb instantiateViewControllerWithIdentifier:identifier];
}

+(CGSize)expectedSizeForLabel:(UILabel*)label attributes:(NSDictionary*)attributes {
    return [CommonHelper expectedSizeForString:label.text width:label.frame.size.width font:label.font attributes:attributes];
}

+(CGSize)expectedSizeForString:(NSString*)string width:(CGFloat)width font:(UIFont*)font attributes:(NSDictionary*)attributes {

    if (SYSTEM_VERSION_LESS_THAN(iOS7_0)) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        //version < 7.0
        return [string sizeWithFont:font constrainedToSize:CGSizeMake(width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
#pragma GCC diagnostic pop

    }
    else{
        //version >= 7.0
        
        //Return the calculated size of the Label
        return [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{
                                                        NSFontAttributeName : font
                                                        }
                                              context:nil].size;
        
    }
}

@end
