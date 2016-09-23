//
//  CustomActivityProvider.m
//  youSay
//
//  Created by Baban on 19/01/2016.
//  Copyright © 2016 macbokpro. All rights reserved.
//

#import "CustomActivityProvider.h"
#import "UIImageView+Networking.h"

@interface CustomActivityProvider ()
@end

@implementation CustomActivityProvider

- (id) activityViewController:(UIActivityViewController *)activityViewController
          itemForActivityType:(NSString *)activityType
{
    if ( [activityType isEqualToString:UIActivityTypePostToFacebook] ) {
        return [NSURL URLWithString:_urlString];
    }
    else {
        NSString *apiEndpoint = [NSString stringWithFormat:@"http://tinyurl.com/api-create.php?url=%@",_urlString];
        NSString *shortURL = [NSString stringWithContentsOfURL:[NSURL URLWithString:apiEndpoint]
                                                      encoding:NSASCIIStringEncoding
                                                         error:nil];
        return [NSURL URLWithString:shortURL];
    }
    return nil;
}
- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController { return @""; }

//- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(nullable NSString *)activityType{
//    return _subject;
//}

//- (NSString *)activityViewController:(UIActivityViewController *)activityViewController dataTypeIdentifierForActivityType:(nullable NSString *)activityType; // UTI for item if it is an NSData. iOS 7.0. will be called with nil activity and then selected activity
//- (nullable UIImage *)activityViewController:(UIActivityViewController *)activityViewController thumbnailImageForActivityType:(nullable NSString *)activityType suggestedSize:(CGSize)size {
//    return _imageToShare;
//}
@end