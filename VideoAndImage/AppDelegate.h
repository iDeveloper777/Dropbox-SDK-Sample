//
//  AppDelegate.h
//  VideoAndImage
//
//  Created by Csaba Toth on 7/5/15.
//  Copyright (c) 2015 Csaba Toth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "RTSpinKitView.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, DBRestClientDelegate>

@property (strong, nonatomic) UIWindow *window;

// Dropbox client properties
@property (nonatomic) DBRestClient *restClient;

//HUD
@property (nonatomic, retain) UIView *loadingView;
+ (void)showWaitView;
+ (void)hideWaitView;

@end

