//
//  AppDelegate.h
//  youSay
//
//  Created by macbokpro on 10/20/15.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "ProfileOwnerModel.h"
#import <BFURL.h>
#import "GAI.h"
#import "AppsFlyerTracker.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, FBSDKAppInviteDialogDelegate, UIAlertViewDelegate, AppsFlyerTrackerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ProfileOwnerModel *profileOwner;
@property (strong, nonatomic) NSDictionary *colorDict;
@property (strong, nonatomic) NSDictionary *ownerDict;
@property (strong, nonatomic) NSString *deviceToken;
@property (readwrite, nonatomic) NSInteger num_of_new_notifications;
@property (strong, nonatomic) NSMutableArray *arrRecentSeacrh;
@property (nonatomic, readwrite) BOOL isNewToken;
@property (nonatomic, readwrite) BOOL isFirstLoad;
@property (strong, nonatomic) BFURL *parsedUrl;
@property(nonatomic, strong) id<GAITracker> tracker;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
+ (AppDelegate *)sharedDelegate;

@end

