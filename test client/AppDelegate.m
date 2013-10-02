//
//  AppDelegate.m
//  test client
//
//  Created by Marcin Krzyzanowski on 01.10.2013.
//  Copyright (c) 2013 HAKORE. All rights reserved.
//

#import "AppDelegate.h"
#import "UNNetPGP.h"

@implementation AppDelegate {
//    UNNetPGP *pgp;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    UNNetPGP *pgp = [[UNNetPGP alloc] init];
    pgp.userId = @"Vodaofone KYC W27";
    NSString *plainFilePath = [[self documentsDirectory] stringByAppendingPathComponent:@"fuckeverything.gif"];
    NSString *decryptedFilePath = [[self documentsDirectory] stringByAppendingPathComponent:@"fuckeverything-decrypted.gif"];
    NSString *encryptedFilePath = [[self documentsDirectory] stringByAppendingPathComponent:@"secure-fuckeverything.gif.gpg"];
    BOOL res = NO;
    res = [pgp encryptFileAtPath:plainFilePath toFileAtPath:encryptedFilePath];
    NSLog(@"encryptedFilePath = %@",@(res));
    res = [pgp decryptFileAtPath:encryptedFilePath toFileAtPath:decryptedFilePath];
    NSLog(@"decryptFileAtPath = %@",@(res));
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSString *) documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


@end
