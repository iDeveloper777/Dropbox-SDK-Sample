//
//  AppDelegate.m
//  VideoAndImage
//
//  Created by Csaba Toth on 7/5/15.
//  Copyright (c) 2015 Csaba Toth. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Initialize DropboxSDK
    //    DBSession *dbSession = [[DBSession alloc]
    //                            initWithAppKey:@"voc8nnx5ktc6wxh"
    //                            appSecret:@"6kqydnn6j8jkfah"
    //                            root:kDBRootDropbox]; // either kDBRootAppFolder or kDBRootDropbox
    DBSession *dbSession = [[DBSession alloc]
                            initWithAppKey:@"t83thz4e1sb2hwp"
                            appSecret:@"d7xegzbyks0du3r"
                            root:kDBRootDropbox]; // either kDBRootAppFolder or kDBRootDropbox
    [DBSession setSharedSession:dbSession];
    
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
  sourceApplication:(NSString *)source annotation:(id)annotation {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
            // At this point you can start making API calls
        }
        return YES;
    }
    // Add whatever other url handling code your app requires here
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - HUD

+ (void)showWaitView
{
    AppDelegate *sharedApp = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (sharedApp.loadingView == nil) {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        sharedApp.loadingView = [[UIView alloc] initWithFrame:screenBounds];
        [sharedApp.loadingView setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f]];
        
        RTSpinKitView *indicatorView = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleBounce color:[UIColor whiteColor]];
        indicatorView.center = CGPointMake(screenBounds.size.width/2, screenBounds.size.height/2);
        [sharedApp.loadingView addSubview:indicatorView];
        
        [sharedApp.window addSubview:sharedApp.loadingView];
    }
}

+ (void)hideWaitView
{
    AppDelegate *sharedApp = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (sharedApp.loadingView) {
        [sharedApp.loadingView removeFromSuperview];
        sharedApp.loadingView = nil;
    }
}

@end
