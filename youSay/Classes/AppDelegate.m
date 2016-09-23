//
//  AppDelegate.m
//  youSay
//
//  Created by macbokpro on 10/20/15.
//  Copyright © 2015 macbokpro. All rights reserved.
//

#import "AppDelegate.h"
#import "SlideNavigationController.h"
#import "MenuViewController.h"
#import "CommonHelper.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "MainPageViewController.h"
#import <BFAppLinkReturnToRefererView.h>
#import <Appsee/Appsee.h>



#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

static NSString *const kTrackingId = @"UA-72170478-1";
//@"UA-72170478-1";
//@"UA-72685655-1";

static NSString *const kAllowTracking = @"allowTracking";

@interface AppDelegate ()

// Used for sending Google Analytics traffic in the background.
@property(nonatomic, assign) BOOL okToWait;
@property(nonatomic, copy) void (^dispatchHandler)(GAIDispatchResult result);

@property (weak, nonatomic) BFAppLinkReturnToRefererView *appLinkReturnToRefererView;
@property (strong, nonatomic) BFAppLink *appLink;

@property (strong, nonatomic) NSDictionary *data;
@end

@implementation AppDelegate
@synthesize profileOwner;
@synthesize arrRecentSeacrh;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (AppDelegate *)sharedDelegate
{
    return [[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //--For AppFlyer
    [AppsFlyerTracker sharedTracker].appsFlyerDevKey = @"gafroSTLxPwjdqBW8WR9Mo";
    [AppsFlyerTracker sharedTracker].appleAppID = @"1063234995";
    [AppsFlyerTracker sharedTracker].delegate = self;
    [[AppsFlyerTracker sharedTracker] trackAppLaunch];
    
    [Appsee start:@"9eeb550f06e8463ba23cecf3b326826a"];
    
    //--For push notification
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIUserNotificationSettings *notificationSetting = [UIUserNotificationSettings settingsForTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert) categories:nil];
        
        [[UIApplication sharedApplication]  registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSetting];
    }
    else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
    MenuViewController *rightMenu = (MenuViewController*)[CommonHelper instantiateViewControllerWithIdentifier:@"MenuViewController" storyboard:@"Main" bundle:nil];
    
    [SlideNavigationController sharedInstance].rightMenu = rightMenu;
    
    NSDictionary *appDefaults = @{kAllowTracking: @(YES)};
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    // User must be able to opt out of tracking
    [GAI sharedInstance].optOut =
    ![[NSUserDefaults standardUserDefaults] boolForKey:kAllowTracking];
    
    // If your app runs for long periods of time in the foreground, you might consider turning
    // on periodic dispatching.  This app doesn't, so it'll dispatch all traffic when it goes
    // into the background instead.  If you wish to dispatch periodically, we recommend a 120
    // second dispatch interval.
    // [GAI sharedInstance].dispatchInterval = 120;
    [GAI sharedInstance].dispatchInterval = -1;
    
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    self.tracker = [[GAI sharedInstance] trackerWithName:@"Yousay Social"
                                              trackingId:kTrackingId];
    
    [Fabric with:@[[Crashlytics class]]];
    
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self sendHitsInBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //--For AppsFlyer
    // Track Installs, updates & sessions(app opens) (You must include this API to enable tracking)
    [[AppsFlyerTracker sharedTracker] trackAppLaunch];
    [AppsFlyerTracker sharedTracker].delegate = self;
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [GAI sharedInstance].optOut =
    ![[NSUserDefaults standardUserDefaults] boolForKey:kAllowTracking];
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    [[AppsFlyerTracker sharedTracker] handleOpenURL:url sourceApplication:sourceApplication withAnnotation:annotation];
    
    BFURL *parsedUrl = [BFURL URLWithInboundURL:url sourceApplication:sourceApplication];
    self.parsedUrl = parsedUrl;
    if ([parsedUrl appLinkData]) {
        // this is an applink url, handle it here
        // NSURL *targetUrl = [parsedUrl targetURL];
        
    }
    [[FBSDKApplicationDelegate sharedInstance] application:application
                                                   openURL:url
                                         sourceApplication:sourceApplication
                                                annotation:annotation];
    return YES;
}

- (void) handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication withAnnotation:(id) annotation {
   // NSLog(@"My URL is: %@", url);
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
   // NSLog(@"My token is: %@", deviceToken);
    NSString *token = [NSString stringWithFormat:@"%@", deviceToken];
    NSString *newToken = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    newToken =  [newToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    self.deviceToken =  [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![[defaults objectForKey:@"token"] isEqualToString:self.deviceToken]) {
        [defaults setObject:deviceToken forKey:self.deviceToken];
        _isNewToken = YES;
    }
    
    [defaults synchronize];
}

//Your app receives push notification.
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    UIApplicationState state = [application applicationState];
   // NSLog(@"state = %ld", (long)state);
    // If your app is running
    if (state == UIApplicationStateActive)
    {
        NSString *cancelTitle = @"Close";
        NSString *message = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
        _data = [userInfo valueForKey:@"data"];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:cancelTitle
                                                  otherButtonTitles:@"You Say", nil];
        [alertView show];
        
    }
    // If your app was in inactive state
    else if (state == UIApplicationStateInactive || state == UIApplicationStateBackground){
        _data = [userInfo valueForKey:@"data"];
        [self pushNotificationAction:_data];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self pushNotificationAction:_data];
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

- (void) onAppOpenAttribution:(NSDictionary*) attributionData {
    NSLog(@"attribution data: %@",attributionData );
    
    if ([attributionData objectForKey:@"profile"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MainPageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainPageViewController"];
        vc.isFromFeed = YES;
        vc.requestedID = [attributionData objectForKey:@"profile"];
        vc.sayID = [attributionData objectForKey:@"sayid"];
        vc.isAddSay = NO;
        
        NSLog(@"sayID original: %@",[attributionData objectForKey:@"sayid"]);
        vc.colorDictionary = [AppDelegate sharedDelegate].colorDict;
        vc.profileModel = [AppDelegate sharedDelegate].profileOwner;
        [(UINavigationController *)self.window.rootViewController pushViewController:vc animated:YES];
    }
}

-(void)onConversionDataReceived:(NSDictionary*) installData {
    id status = [installData objectForKey:@"af_status"];
    if([status isEqualToString:@"Non-organic"]) {
        id sourceID = [installData objectForKey:@"media_source"];
        id campaign = [installData objectForKey:@"campaign"];
        NSLog(@"This is a none organic install. Media source: %@  Campaign: %@",sourceID,campaign);
    } else if([status isEqualToString:@"Organic"]) {
        NSLog(@"This is an organic install.");
    }
}

- (void)pushNotificationAction:(NSDictionary*)data{
    NSDictionary *type = [data objectForKey:@"type"];
    NSArray *keys = [type allKeys];
    NSString *key;
    if ([keys count] != 0) {
        key = [keys objectAtIndex:0];}
    if ([key integerValue] == 8) {
        FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
        content.appLinkURL = [NSURL URLWithString:@"http://yousayweb.com/yousay/profileshare.html"];
        content.appInvitePreviewImageURL = [NSURL URLWithString:@"http://yousayweb.com/yousay/images/Invite_Friends.png"];
        [FBSDKAppInviteDialog showFromViewController:self.window.rootViewController withContent:content delegate:self];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainPageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainPageViewController"];
    vc.isFromFeed = YES;
    vc.requestedID = [data objectForKey:@"profile_id"];
    vc.sayID = [data objectForKey:@"say_id"];
    vc.isAddSay = NO;
    
    NSLog(@"sayID original: %@",[data objectForKey:@"say_id"]);
    vc.colorDictionary = [AppDelegate sharedDelegate].colorDict;
    vc.profileModel = [AppDelegate sharedDelegate].profileOwner;
    [(UINavigationController *)self.window.rootViewController pushViewController:vc animated:YES];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MyStore" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MyStore.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)sendHitsInBackground {
    self.okToWait = YES;
    __weak AppDelegate *weakSelf = self;
    __block UIBackgroundTaskIdentifier backgroundTaskId =
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        weakSelf.okToWait = NO;
    }];
    
    if (backgroundTaskId == UIBackgroundTaskInvalid) {
        return;
    }
    
    self.dispatchHandler = ^(GAIDispatchResult result) {
        // If the last dispatch succeeded, and we're still OK to stay in the background then kick off
        // again.
        if (result == kGAIDispatchGood && weakSelf.okToWait ) {
            [[GAI sharedInstance] dispatchWithCompletionHandler:weakSelf.dispatchHandler];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
        }
    };
    [[GAI sharedInstance] dispatchWithCompletionHandler:self.dispatchHandler];
}

#pragma mark - AppInviteDelegate

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results {
    
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"YouSay" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - AppsFlyer
// Reports app open from a Universal Link for iOS 9
- (BOOL) application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *_Nullable))restorationHandler
{
    [[AppsFlyerTracker sharedTracker] continueUserActivity:userActivity restorationHandler:restorationHandler];
    return YES;
}


@end
