//
//  AQSFacebookMessengerActivity.m
//  AQSFacebookMessengerActivity
//
//  Created by kaiinui on 2014/11/11.
//  Copyright (c) 2014年 Aquamarine. All rights reserved.
//

#import "AQSFacebookMessengerActivity.h"
#import "FBSDKShareKit.h"

@interface AQSFacebookMessengerActivity ()

@property (nonatomic, strong) NSArray *activityItems;

@end

@implementation AQSFacebookMessengerActivity

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    [super prepareWithActivityItems:activityItems];
    
    self.activityItems = activityItems;
}

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryShare;
}

- (NSString *)activityType {
    return @"org.openaquamarine.facebookmessenger";
}

- (NSString *)activityTitle {
    return @"Facebook Messenger";
}

- (UIImage *)activityImage {
    if ([[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue] >= 8) {
        return [UIImage imageNamed:[NSString stringWithFormat:@"color_%@", NSStringFromClass([self class])]];
    } else {
        return [UIImage imageNamed:NSStringFromClass([self class])];
    }
}

//- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
//    if ([self isFacebookMessengerDialogAvailable] == NO) {
//        return NO;
//    }
//    
//    UIImage *image = [self nilOrFirstImageFromArray:activityItems];
//    NSURL *URL = [self nilOrFirstURLFromArray:activityItems];
//    FBSDKSharePhoto *photoParams = [self nilOrFirstPhotoParamsFromArray:activityItems];
//    FBSDKShareLinkContent *linkParams = [self nilOrFirstLinkShareParamsFromArray:activityItems];
//    
//    if (linkParams && [self isFacebookMessengerDialogAvailableWithLinkShareParams:linkParams]) {
//        return YES;
//    } else if (photoParams && [self isFacebookMessengerDialogAvailableWithPhoto]) {
//        return YES;
//    } else if (image && [self isFacebookMessengerDialogAvailableWithPhoto]) {
//        return YES;
//    } else if (URL != nil) {
//        return YES;
//    }
//    
//    return NO;
//}

//- (void)performActivity {
//    UIImage *image = [self nilOrFirstImageFromArray:_activityItems];
//    NSURL *URL = [self nilOrFirstURLFromArray:_activityItems];
//    FBSDKSharePhoto *photoParams = [self nilOrFirstPhotoParamsFromArray:_activityItems];
//    FBSDKShareLinkContent *linkParams = [self nilOrFirstLinkShareParamsFromArray:_activityItems];
//    
//     [self performActivityWithImageArray:_activityItems];
//    
////    if (linkParams && [self isFacebookMessengerDialogAvailableWithLinkShareParams:linkParams]) {
////        [self performActivityWithLinkShareParams:linkParams];
////    } else if (photoParams && [self isFacebookMessengerDialogAvailableWithPhoto]) {
////        [self performActivityWithPhotoParams:photoParams];
////    } else if (image && [self isFacebookMessengerDialogAvailableWithPhoto]) {
////        [self performActivityWithImageArray:_activityItems];
////    } else if (URL) {
////        [self performActivityWithURL:URL];
////    }
//}

# pragma mark - Helpers (Facebook Messenger)
//
//- (BOOL)isFacebookMessengerDialogAvailable {
//    return [FBSDKMessageDialog canPresentMessageDialog];
//}
//
//- (BOOL)isFacebookMessengerDialogAvailableWithPhoto {
//    return [FBDialogs canPresentMessageDialogWithPhotos];
//}
//
//- (BOOL)isFacebookMessengerDialogAvailableWithLinkShareParams:(FBSDKShareLinkContent *)params {
//    return [FBDialogs canPresentMessageDialogWithParams:params];
//}
//
//
//- (void)performActivityWithLinkShareParams:(FBSDKShareLinkContent *)params {
//    __weak typeof(self) weakSelf = self;
//    [FBSDKShareDialog presentMessageDialogWithParams:params clientState:nil handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
//        [weakSelf handleCallback:call results:results error:error];
//    }];
//}
//
//- (void)performActivityWithPhotoParams:(FBPhotoParams *)params {
//    __weak typeof(self) weakSelf = self;
//    [FBDialogs presentMessageDialogWithPhotoParams:params clientState:nil handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
//        [weakSelf handleCallback:call results:results error:error];
//    }];
//}

//- (void)performActivityWithImageArray:(NSArray /* UIImage */ *)images {
//    __weak typeof(self) weakSelf = self;
//    [FBDialogs presentMessageDialogWithPhotos:images handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
//        [weakSelf handleCallback:call results:results error:error];
//    }];
//}
//
//- (void)performActivityWithURL:(NSURL *)URL {
//    __weak typeof(self) weakSelf = self;
//    [FBDialogs presentMessageDialogWithLink:URL handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
//        [weakSelf handleCallback:call results:results error:error];
//    }];
//}
//
//- (void)handleCallback:(FBAppCall *)call results:(NSDictionary *)results error:(NSError *)error {
//    if (error != nil) {
//        [self activityDidFinish:NO];
//    } else {
//        [self activityDidFinish:YES];
//    }
//}

# pragma mark - Helpers (Array)

- (NSURL *)nilOrFirstURLFromArray:(NSArray *)array {
    for (id item in array) {
        if ([item isKindOfClass:[NSURL class]]) {
            return item;
        }
    }
    return nil;
}

- (FBSDKShareLinkContent *)nilOrFirstLinkShareParamsFromArray:(NSArray *)array {
    for (id item in array) {
        if ([item isKindOfClass:[FBSDKShareLinkContent class]]) {
            return item;
        }
    }
    return nil;
}

- (FBSDKSharePhoto *)nilOrFirstPhotoParamsFromArray:(NSArray *)array {
    for (id item in array) {
        if ([item isKindOfClass:[FBSDKSharePhoto class]]) {
            return item;
        }
    }
    return nil;
}

- (UIImage *)nilOrFirstImageFromArray:(NSArray *)array {
    for (id item in array) {
        if ([item isKindOfClass:[UIImage class]]) {
            return item;
        }
    }
    return nil;
}

- (NSArray *)emptyOrImageArrayFromArray:(NSArray *)array {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (id item in array) {
        if ([item isKindOfClass:[UIImage class]]) {
            [mutableArray addObject:item];
        }
    }
    return mutableArray;
}

@end
