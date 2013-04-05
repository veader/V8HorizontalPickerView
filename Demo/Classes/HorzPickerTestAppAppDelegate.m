//
//  HorzPickerTestAppAppDelegate.m
//  HorzPickerTestApp
//
//  Created by Shawn Veader on 9/20/10.
//  Copyright 2010 V8 Labs, LLC. All rights reserved.
//

#import "TestViewController.h"
#import "HorzPickerTestAppAppDelegate.h"

@implementation HorzPickerTestAppAppDelegate


#pragma mark - Application lifecycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	// Override point for customization after application launch.
	self.testView = [[TestViewController alloc] init];
	self.window.rootViewController = self.testView;
	[self.window addSubview:self.testView.view];

	[self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application { }

- (void)applicationDidEnterBackground:(UIApplication *)application { }

- (void)applicationWillEnterForeground:(UIApplication *)application { }

- (void)applicationDidBecomeActive:(UIApplication *)application { }

- (void)applicationWillTerminate:(UIApplication *)application { }


#pragma mark - Memory management
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application { }

@end
