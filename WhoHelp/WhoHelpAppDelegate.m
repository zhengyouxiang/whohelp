//
//  WhoHelpAppDelegate.m
//  WhoHelp
//
//  Created by cloud on 11-9-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WhoHelpAppDelegate.h"
#import "HelpSendViewController.h"
#import "PreAuthViewController.h"
#import "LocationController.h"
#import "ProfileManager.h"
#import "Config.h"
#import "SBJson.h"
#import "ASIHTTPRequest.h"


@implementation WhoHelpAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize tabBarController=tabBarController_;
@synthesize nearbyItem, myListItem, helpItem, prizeItem, settingItem;

- (void)dealloc
{
    [_window release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [tabBarController_ release];
    [nearbyItem release]; 
    [myListItem release]; 
    [helpItem release]; 
    [prizeItem release]; 
    [settingItem release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // register the apns
    [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)]; 
    // Override point for customization after application launch.
    self.window.rootViewController = self.tabBarController;
    // select the middle post help tab bar item.
    self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:2];
    self.tabBarController.delegate = self;
    self.tabBarController.tabBar.opaque = YES;

    [self.tabBarController.tabBar setSelectionIndicatorImage:[UIImage imageNamed:@"blank.png"]];
    // config the tab bar items
    [self.nearbyItem setFinishedSelectedImage:[UIImage imageNamed:@"nearbyo.png"] 
                  withFinishedUnselectedImage:[UIImage imageNamed:@"nearby.png"]];
    [self.myListItem setFinishedSelectedImage:[UIImage imageNamed:@"mylisto.png"] 
                  withFinishedUnselectedImage:[UIImage imageNamed:@"mylist.png"]];
    [self.helpItem setFinishedSelectedImage:[UIImage imageNamed:@"helpo.png"] 
                withFinishedUnselectedImage:[UIImage imageNamed:@"help.png"]];
    [self.prizeItem setFinishedSelectedImage:[UIImage imageNamed:@"prizeo.png"] 
                 withFinishedUnselectedImage:[UIImage imageNamed:@"prize.png"]];
    [self.settingItem setFinishedSelectedImage:[UIImage imageNamed:@"settingo.png"]
                   withFinishedUnselectedImage:[UIImage imageNamed:@"setting.png"]];
    // support the shake feature.
    //application.applicationSupportsShakeToEdit = YES;
    
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [self tabBarController:self.tabBarController shouldSelectViewController:self.tabBarController.selectedViewController];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)updateTokenRequest:(NSString *)token
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", HOST, DDURI, [[UIDevice currentDevice] uniqueIdentifier]]];
    
    NSDictionary *data = [NSDictionary  dictionaryWithObject:token forKey:@"dtoken"];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request appendPostData:[[data JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    [request addRequestHeader:@"Content-Type" value:@"Application/json;charset=utf-8"]; 
    [request setRequestMethod:@"PUT"];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data

    if ([request responseStatusCode] == 201){
        
//         NSLog(@"%@", @"OK");
    }
    // Use when fetching binary data
    //NSData *responseData = [request responseData];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@", [error description]);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *devTokenStr = [[[deviceToken description]
                              stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] 
                             stringByReplacingOccurrencesOfString:@" " 
                             withString:@""];
    [self updateTokenRequest:devTokenStr];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Error in registration. Error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    /* do something when app foreground , apn action
     local notification. do
     */
    
}

- (void)awakeFromNib
{
    /*
     Typically you should set up the Core Data stack here, usually by passing the managed object context to the first view controller.
     self.<#View controller#>.managedObjectContext = self.managedObjectContext;
    */
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}


#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"WhoHelp" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"WhoHelp4.sqlite"];
    
    NSError *error = nil;
//    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         
        */
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
         
         /// Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         //[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         /*Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        // FIXME production let me go
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - tab bar delegate
//
//- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
//{
//    NSLog(@"fuck fuck");
//}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if (nil == [ProfileManager sharedInstance].profile){
        PreAuthViewController *preAVC = [[PreAuthViewController alloc] initWithNibName:@"PreAuthViewController" bundle:nil];
        [self.tabBarController presentModalViewController:preAVC animated:NO];
        [preAVC release];
        
        return NO;
    } 
//    else{
//        if (13 == viewController.tabBarItem.tag){
//            HelpSendViewController *helpSendVC = [[HelpSendViewController alloc] initWithNibName:@"HelpSendViewController" bundle:nil];
//            [self.tabBarController presentModalViewController:helpSendVC animated:YES];
//            [helpSendVC release];
//            
//            return NO;
//        }
//    }

    return YES;
}

@end
