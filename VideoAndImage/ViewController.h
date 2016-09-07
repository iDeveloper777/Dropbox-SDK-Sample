//
//  ViewController.h
//  VideoAndImage
//
//  Created by Csaba Toth on 7/5/15.
//  Copyright (c) 2015 Csaba Toth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import "StringExtension.h"
#import "SVProgressHUD.h"

@interface ViewController : UIViewController <DBRestClientDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

// Dropbox client properties
@property (nonatomic, strong) DBRestClient *restClient;

//---------------------------------------------
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewFull;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollThumb;

@property (weak, nonatomic) IBOutlet UIImageView *ivFullScreen;
@property (weak, nonatomic) IBOutlet UIImageView *ivThumb;

@property (weak, nonatomic) IBOutlet UIButton *btnLinkButton;
@property (weak, nonatomic) IBOutlet UIButton *btnRefreshButton;
@property (weak, nonatomic) IBOutlet UIButton *btnShowListButton;

@property (weak, nonatomic) IBOutlet UIImageView *ivLeft;
@property (weak, nonatomic) IBOutlet UIImageView *ivRight;

@property (weak, nonatomic) IBOutlet UIView *viewSlideList;
@property (weak, nonatomic) IBOutlet UITableView *tvList;
@property (weak, nonatomic) IBOutlet UIButton *btnHideListButton;

//---------------------------------------------
- (IBAction)pressDropboxLinkBtn:(id)sender;
- (IBAction)pressRefreshDataBtn:(id)sender;
- (IBAction)pressShowListBtn:(id)sender;
- (IBAction)pressHideListBtn:(id)sender;

@end

