//
//  ViewController.m
//  VideoAndImage
//
//  Created by Csaba Toth on 7/5/15.
//  Copyright (c) 2015 Csaba Toth. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    NSMutableArray *imgArray;
    NSMutableArray *imgNameArray;
    NSMutableArray *imgDataArray;
    NSMutableArray *videoArray;
    NSMutableArray *videoNameArray;
    NSMutableArray *videoURLArray;
    NSMutableArray *videoThumbArray;
    NSMutableArray *arrVideoList;
    NSMutableArray *arrVideoThumbList;
    
    CGRect imageRect;
    
    MPMoviePlayerController *player;
    NSString *strLink;
    
    CGRect screenSize;
    CGRect scrollSize;
    
    int isPortrait;
    int isFullscreen;
    int isSlideList;
    int isSlidePlay;
    
    int nScrollIndex;
    int nScrollPreIndex;
    
    int nImageIndex;
    int nImageIsFirst;
    
    int nVideoIndex;
    int nVideoIsFirst;
    int nCurrentVideoIndex;
    int nCurrentThumbNumber;
    int nVideoThumbIndex;
    
    int nLoading;
    
    int nWidth;
    int nHeight;
}


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
    
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
        [self.btnLinkButton setTitle:@"Dropbox Unlink" forState:UIControlStateNormal];
    }
    
    isFullscreen = 0;
    isSlideList = 0;
    nScrollIndex = 0;
    nScrollPreIndex = 0;
    nImageIndex = 0;
    nImageIsFirst = 0;
    nVideoIndex = 0;
    nVideoIsFirst = 0;
    nCurrentVideoIndex = 0;
    nCurrentThumbNumber = 0;
    nVideoThumbIndex = 0;
    nLoading = 0;
    
    screenSize = [[UIScreen mainScreen] bounds];
    
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        isPortrait = 0;
        
        nWidth = (screenSize.size.height - 60)/2;
        nHeight = nWidth/3*2;
    }else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight){
        isPortrait = 1;
        
        nWidth = (screenSize.size.width - 60)/2;
        nHeight = nWidth/3*2;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMPMoviePlayerPlaybackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    [self setLayout];
    
    [self getLatestDropboxData];
    

}

- (void)handleMPMoviePlayerPlaybackDidFinish:(NSNotification *)notification
{
    NSDictionary *notificationUserInfo = [notification userInfo];
    NSNumber *resultValue = [notificationUserInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    MPMovieFinishReason reason = [resultValue intValue];
    if (reason == MPMovieFinishReasonPlaybackError)
    {
        NSError *mediaPlayerError = [notificationUserInfo objectForKey:@"error"];
        if (mediaPlayerError)
        {
            NSLog(@"playback failed with error description: %@", [mediaPlayerError localizedDescription]);
        }
        else
        {
            NSLog(@"playback failed without any given reason");
        }
        
        [SVProgressHUD dismiss];
        //Enable all Events
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error loading from Dropbox!" message:@"Please check your Internet connectivity and try again." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alertView show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated{
    
}

-(void) getLatestDropboxData {
    if (![[DBSession sharedSession] isLinked]) {
        [self raiseAlert:@"Error" about:@"You didn't log in dropbox yet. Please sign in Dropbox."];
        return;
    }
    
    //Disable all Events
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    nScrollIndex = 0;
    isSlideList = 0;
    nImageIndex = 0;
    nVideoIndex = 0;
    nImageIsFirst = 0;
    nVideoIsFirst = 0;
    nCurrentVideoIndex = 0;
    nCurrentThumbNumber = 0;
    nVideoThumbIndex = 0;
    nLoading = 0;
    
    imgArray = [[NSMutableArray alloc] init];
    imgNameArray = [[NSMutableArray alloc] init];
    imgDataArray = [[NSMutableArray alloc] init];
    
    videoArray = [[NSMutableArray alloc] init];
    videoNameArray = [[NSMutableArray alloc] init];
    videoURLArray = [[NSMutableArray alloc] init];
    videoThumbArray = [[NSMutableArray alloc] init];
    
    arrVideoList = [[NSMutableArray alloc] init];
    arrVideoThumbList = [[NSMutableArray alloc] init];
    
    if (![[DBSession sharedSession] isLinked]) {
        [self raiseAlert:@"Error" about:@"You didn't log in dropbox yet. Please press 'DropboxLink' button."];
        return;
    }
    
    self.viewSlideList.hidden = YES;
    
    [SVProgressHUD showWithStatus:@"Loading..."];
//    [self.restClient loadMetadata:@"/odeskApp/"];
    [self.restClient loadMetadata:@"/CoachsOffice/"];
}

#pragma mark setLayout

- (void) setLayout{
    if (![[DBSession sharedSession] isLinked]) {
        [self.btnLinkButton setTitle:@"Dropbox Link" forState:UIControlStateNormal];
    } else {
        [self.btnLinkButton setTitle:@"Dropbox Unlink" forState:UIControlStateNormal];
    }
    
    self.btnLinkButton.hidden = YES;
    self.btnRefreshButton.hidden = YES;
    
    screenSize = [[UIScreen mainScreen] bounds];
    scrollSize = self.scrollView.bounds;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[appDelegate window] addSubview:_viewSlideList];
    [[appDelegate window] addSubview:_scrollViewFull];
    
    self.viewSlideList.hidden = YES;
    //Slide List View
    [_viewSlideList setFrame:CGRectMake(screenSize.size.width/2, 60, screenSize.size.width/2-20, screenSize.size.height-80)];
    [_tvList setFrame:CGRectMake(20, 20, _viewSlideList.bounds.size.width-40, _viewSlideList.bounds.size.height-90)];
    [_btnHideListButton setFrame:CGRectMake(_viewSlideList.bounds.size.width-140, _viewSlideList.bounds.size.height-50, _btnHideListButton.bounds.size.width, _btnHideListButton.bounds.size.height)];
    
    
    if (isPortrait == 0)
        [_scrollView setFrame:CGRectMake(20, 60, screenSize.size.width-40, (screenSize.size.height-180)/2)];
    else
        [_scrollView setFrame:CGRectMake(20, 60, (screenSize.size.width-60)/2, screenSize.size.height-140)];
    
    imageRect  = _scrollView.bounds;
    self.ivFullScreen.hidden = YES;
    self.scrollViewFull.hidden = YES;
    
    [self.btnRefreshButton setFrame:CGRectMake(screenSize.size.width - self.btnRefreshButton.bounds.size.width - 20, self.btnRefreshButton.frame.origin.y, self.btnRefreshButton.bounds.size.width, self.btnRefreshButton.bounds.size.height)];
    [self.btnShowListButton setFrame:CGRectMake(20, screenSize.size.height - 60, 100, 40)];
    
    _scrollView.contentSize = CGSizeMake(imageRect.size.width * imgArray.count, _scrollView.bounds.size.height);
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [_scrollView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *singleTap01 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    singleTap01.numberOfTapsRequired = 1;
    [self.ivFullScreen setUserInteractionEnabled:YES];
    [self.ivFullScreen addGestureRecognizer:singleTap01];
    
    UITapGestureRecognizer *singleTap02 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.scrollViewFull addGestureRecognizer:singleTap02];

    if (isPortrait == 0)
        [_scrollThumb setFrame:CGRectMake(160, screenSize.size.height - 80, screenSize.size.width-180, 60)];
    else
        [_scrollThumb setFrame:CGRectMake(screenSize.size.width/2+10, (screenSize.size.height-nHeight-140)/2+nHeight+80, (screenSize.size.width-60)/2, 60)];
    
    player = [[MPMoviePlayerController alloc] initWithContentURL:nil];
    
    if (isPortrait == 0)
        [player.view setFrame:CGRectMake(20, (screenSize.size.height-180)/2+80, screenSize.size.width-40, (screenSize.size.height-180)/2)];
    else
        [player.view setFrame:CGRectMake(screenSize.size.width/2+10, (screenSize.size.height-nHeight-140)/2+60, (screenSize.size.width-60)/2, nHeight)];
    player.view.hidden = NO;
    player.shouldAutoplay = NO;
    player.movieSourceType = MPMovieSourceTypeFile;
    [player prepareToPlay];
    [player.view.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [player.view.layer setBorderWidth:1.0];
    [self.view addSubview:player.view];
    
    UIDevice *device = [UIDevice currentDevice];
    //Tell it to start monitoring the accelerometer for orientation
    [device beginGeneratingDeviceOrientationNotifications];
    //Get the notification centre for the app
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(orientationChanged:)  name:UIDeviceOrientationDidChangeNotification  object:device];
    
    //Full Screen scrollview reload
    [self.ivFullScreen removeFromSuperview];
    [self.view addSubview:self.ivFullScreen];
    
//    self.ivLeft.hidden = YES;
//    self.ivRight.hidden =  YES;
}

- (void) setLayoutPortrait{
    screenSize = [[UIScreen mainScreen] bounds];
    scrollSize = self.scrollView.bounds;
    
    [self.btnRefreshButton setFrame:CGRectMake(screenSize.size.width - self.btnRefreshButton.bounds.size.width - 20, self.btnRefreshButton.frame.origin.y, self.btnRefreshButton.bounds.size.width, self.btnRefreshButton.bounds.size.height)];
    [self.btnShowListButton setFrame:CGRectMake(20, screenSize.size.height - 60, 100, 40)];
    
    [_scrollView setFrame:CGRectMake(20, 60, screenSize.size.width-40, (screenSize.size.height-180)/2)];
    imageRect  = _scrollView.bounds;
    [_scrollView setContentOffset:CGPointMake(imageRect.size.width * nScrollIndex, 0)];
    
    if (isFullscreen == 0){
        //        [self.ivFullScreen setFrame:imageRect];
        [self.ivFullScreen setFrame:CGRectMake(0, 0, imageRect.size.width, imageRect.size.height)];
        [self.scrollViewFull setFrame:imageRect];
    }else{
        [self.ivFullScreen setFrame:screenSize];
        [self.scrollViewFull setFrame:screenSize];
        
        for (UIView *view in self.scrollViewFull.subviews){
            [view removeFromSuperview];
        }
        
        [self.scrollViewFull addSubview:self.ivFullScreen];
        [self.ivFullScreen setFrame:CGRectMake(0, 0, _scrollViewFull.frame.size.width, _scrollViewFull.frame.size.height)];
        self.scrollViewFull.contentSize = self.ivFullScreen.frame.size;
        
        player.view.hidden = YES;
    }
    
    for (UIView *view in _scrollView.subviews){
        [view removeFromSuperview];
    }
    
    _scrollView.contentSize = CGSizeMake(imageRect.size.width * imgArray.count, _scrollView.bounds.size.height);
    
    [_ivLeft setFrame:CGRectMake(_scrollView.frame.origin.x+20,
                                _scrollView.frame.origin.y + _scrollView.bounds.size.height/2-20,
                                 20, 40)];
    [_ivRight setFrame:CGRectMake(_scrollView.frame.origin.x+_scrollView.bounds.size.width-40,
                                 _scrollView.frame.origin.y + _scrollView.bounds.size.height/2-20,
                                 20, 40)];
    
    [_scrollThumb setFrame:CGRectMake(160, screenSize.size.height - 80, screenSize.size.width-180, 60)];

    for (UIView *view in _scrollThumb.subviews){
        [view removeFromSuperview];
    }
    
    [self loadImages];
    
    [player.view setFrame:CGRectMake(20, (screenSize.size.height-180)/2+80, screenSize.size.width-40, (screenSize.size.height-180)/2)];
    
    //Slide List View
    [_viewSlideList setFrame:CGRectMake(screenSize.size.width/2, 60, screenSize.size.width/2-20, screenSize.size.height-80)];
    [_tvList setFrame:CGRectMake(20, 20, _viewSlideList.bounds.size.width-40, _viewSlideList.bounds.size.height-90)];
    [_btnHideListButton setFrame:CGRectMake(_viewSlideList.bounds.size.width-140, _viewSlideList.bounds.size.height-50, _btnHideListButton.bounds.size.width, _btnHideListButton.bounds.size.height)];
}

- (void) setLayoutLandscape{
    
    screenSize = [[UIScreen mainScreen] bounds];
    scrollSize = self.scrollView.bounds;
    
    //Slide List View
    [_viewSlideList setFrame:CGRectMake(screenSize.size.width/2, 60, screenSize.size.width/2-20, screenSize.size.height-80)];
    [_tvList setFrame:CGRectMake(20, 20, _viewSlideList.bounds.size.width-40, _viewSlideList.bounds.size.height-90)];
    [_btnHideListButton setFrame:CGRectMake(_viewSlideList.bounds.size.width-140, _viewSlideList.bounds.size.height-50, _btnHideListButton.bounds.size.width, _btnHideListButton.bounds.size.height)];
    
    
    [self.btnRefreshButton setFrame:CGRectMake(screenSize.size.width - self.btnRefreshButton.bounds.size.width - 20, self.btnRefreshButton.frame.origin.y, self.btnRefreshButton.bounds.size.width, self.btnRefreshButton.bounds.size.height)];
    [self.btnShowListButton setFrame:CGRectMake(20, screenSize.size.height - 60, 100, 40)];
    
    [_scrollView setFrame:CGRectMake(20, 60, (screenSize.size.width-60)/2, screenSize.size.height-140)];
    imageRect  = _scrollView.bounds;
    [_scrollView setContentOffset:CGPointMake(imageRect.size.width * nScrollIndex, 0)];
    
    if (isFullscreen == 0){
        //        [self.ivFullScreen setFrame:imageRect];
        [self.ivFullScreen setFrame:CGRectMake(0, 0, imageRect.size.width, imageRect.size.height)];
        [self.scrollViewFull setFrame:imageRect];

    }else{
        [self.ivFullScreen setFrame:screenSize];
        [self.scrollViewFull setFrame:screenSize];
        
        for (UIView *view in self.scrollViewFull.subviews){
            [view removeFromSuperview];
        }
        
        [self.scrollViewFull addSubview:self.ivFullScreen];
        [self.ivFullScreen setFrame:CGRectMake(0, 0, _scrollViewFull.frame.size.width, _scrollViewFull.frame.size.height)];
        self.scrollViewFull.contentSize = self.ivFullScreen.frame.size;
        
        player.view.hidden = YES;
    }
    
    for (UIView *view in _scrollView.subviews){
        [view removeFromSuperview];
    }
    
    _scrollView.contentSize = CGSizeMake(imageRect.size.width * imgArray.count, _scrollView.bounds.size.height);
    
    [_ivLeft setFrame:CGRectMake(_scrollView.frame.origin.x+20,
                                 _scrollView.frame.origin.y + _scrollView.bounds.size.height/2-20,
                                 20, 40)];
    [_ivRight setFrame:CGRectMake(_scrollView.frame.origin.x+_scrollView.bounds.size.width-40,
                                  _scrollView.frame.origin.y + _scrollView.bounds.size.height/2-20,
                                  20, 40)];
    
    [_scrollThumb setFrame:CGRectMake(screenSize.size.width/2+10, (screenSize.size.height-nHeight-140)/2+nHeight+80, (screenSize.size.width-60)/2, 60)];
    
    for (UIView *view in _scrollThumb.subviews){
        [view removeFromSuperview];
    }
    
    [self loadImages];
    
    [player.view setFrame:CGRectMake(screenSize.size.width/2+10, (screenSize.size.height-nHeight-140)/2+60, (screenSize.size.width-60)/2, nHeight)];
    
    //Slide List View
    [_viewSlideList setFrame:CGRectMake(screenSize.size.width/2, 60, screenSize.size.width/2-20, screenSize.size.height-80)];
    [_tvList setFrame:CGRectMake(20, 20, _viewSlideList.bounds.size.width-40, _viewSlideList.bounds.size.height-90)];
    [_btnHideListButton setFrame:CGRectMake(_viewSlideList.bounds.size.width-140, _viewSlideList.bounds.size.height-50, _btnHideListButton.bounds.size.width, _btnHideListButton.bounds.size.height)];
}

#pragma mark loadImages
- (void) loadImages{
    if (nImageIsFirst != 0){
        [self loadImagesToScrollView];
        [self loadVideos];
        return;
    }
    
    if (imgArray.count != 0){
        [self loadImageWithIndex:0];
    }else{
        [self loadVideos];
    }
}

- (void) loadImageWithIndex: (int) nIndex{
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[imgNameArray objectAtIndex:nIndex]];
    
    nImageIndex = nIndex;
    
    [self.restClient loadFile:[imgArray objectAtIndex:nIndex] intoPath:filePath];
    
}

- (void) loadImagesToScrollView{
    imageRect  = _scrollView.bounds;
    
    for (int i=0; i<imgDataArray.count; i++){
        _scrollView.bounces = false;
        _scrollView.contentSize = CGSizeMake(imageRect.size.width * imgArray.count, imageRect.size.height);
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageRect.size.width * i, 0, imageRect.size.width, imageRect.size.height)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
//        imageView.contentMode = UIViewContentModeScaleToFill;
        
        imageView.image = [imgDataArray objectAtIndex:i];
        [_scrollView addSubview:imageView];
    }
    
    if (imgArray.count != 0)
        _ivRight.hidden = NO;
    else
        _ivRight.hidden = YES;
    _ivLeft.hidden =  YES;
    
    nImageIsFirst = 1;
    
    //reload tableview data
    [self.tvList reloadData];
    
    [self loadVideos];
}

#pragma mark loadVideos
- (void) loadVideos{
    
    if (nVideoIsFirst != 0){
        [self loadVideoToMediaPlay];
        return;
    }
    
    if (videoArray.count != 0) {
        [self loadVideoWithIndex:0];
    }else{
        nLoading = 1;
        [SVProgressHUD dismiss];
        
        //Enable all Events
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
}

- (void) loadVideoWithIndex: (int) nIndex{
   
    nVideoIndex = nIndex;
    
    [self.restClient loadStreamableURLForFile:[videoArray objectAtIndex:nIndex]];
    
}

- (void) loadVideoToMediaPlay{
    if (nScrollPreIndex == nScrollIndex && nVideoIsFirst != 0){
        [SVProgressHUD dismiss];
        return;
    }
    
    [player.view removeFromSuperview];
    
    if (nVideoIsFirst == 0){
//        [player setContentURL:[videoURLArray objectAtIndex:nCurrentVideoIndex]];
        [self getVideoThumbs];
        player = [[MPMoviePlayerController alloc] initWithContentURL:[videoURLArray objectAtIndex:nCurrentVideoIndex]];
    }
    
    if (isSlidePlay == 1){
        isSlidePlay = 0;
        
        if (nScrollIndex == nScrollPreIndex)
            return;
        else
            nScrollPreIndex = nScrollIndex;
        
        NSMutableArray *tempArray = [arrVideoList objectAtIndex:nScrollIndex];
        if (tempArray.count != 0) {
            NSNumber *num = [tempArray objectAtIndex:0];
            player = [[MPMoviePlayerController alloc] initWithContentURL:[videoURLArray objectAtIndex:[num integerValue]]];
        }else
            player = [[MPMoviePlayerController alloc] initWithContentURL:nil];
    }
    
    if (player == nil || player.view == nil)
        NSLog(@"asdfasdf");
    
    if (isPortrait == 0)
        [player.view setFrame:CGRectMake(20, (screenSize.size.height-180)/2+80, screenSize.size.width-40, (screenSize.size.height-180)/2)];
    else
        [player.view setFrame:CGRectMake(screenSize.size.width/2+10, (screenSize.size.height-nHeight-140)/2+60, (screenSize.size.width-60)/2, nHeight)];
    
    player.view.hidden = NO;
    player.shouldAutoplay = NO;
    player.movieSourceType = MPMovieSourceTypeFile;
    [player prepareToPlay];
    [player.view.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [player.view.layer setBorderWidth:1.0];
    [self.view addSubview:player.view];
    
    //scrollView
//    [self.scrollViewFull removeFromSuperview];
//    [self.view addSubview:self.scrollViewFull];
    
    //Thumb
    [self loadThumbToScroll];
    
    nVideoIsFirst = 1;
    nLoading = 1;
    nScrollPreIndex = nScrollIndex;
    [SVProgressHUD dismiss];
    
    //Enable all Events
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

- (void) loadThumbToScroll{
    for (UIView *view in _scrollThumb.subviews)
         [view removeFromSuperview];
    
    NSMutableArray *tempArray = [arrVideoList objectAtIndex:nScrollIndex];
    
    for (int i=0; i<tempArray.count; i++){
        NSNumber *num = [tempArray objectAtIndex:i];
        
        if (videoThumbArray.count > [num integerValue]) {
            _scrollThumb.contentSize = CGSizeMake(100 * tempArray.count, _scrollThumb.bounds.size.height);
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100 * i, 0, 80, _scrollThumb.bounds.size.height)];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.image = [videoThumbArray objectAtIndex:[num integerValue]];
            imageView.tag = [num integerValue];
            
            UITapGestureRecognizer *newTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureThumb:)];
            
            [imageView setUserInteractionEnabled:YES];
            [imageView addGestureRecognizer:newTap];
            
            [_scrollThumb addSubview:imageView];
        }
    }

    if (nVideoThumbIndex < videoArray.count){
        [self performSelector:@selector(loadThumbToScroll) withObject:nil afterDelay:1.0];
    }else{
        return;
    }
}

#pragma mark getVideoThumbs
-(void) getVideoThumbs{
    if (nVideoThumbIndex >= videoArray.count){
        return;
    }else{
        [self getThumbImage:[videoURLArray objectAtIndex:nVideoThumbIndex]];
    }
}

#pragma mark getThumbImage
- (void) getThumbImage:(NSURL *) url {
    AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform=TRUE;
    
    CMTime thumbTime = CMTimeMakeWithSeconds(30,30);
    
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result != AVAssetImageGeneratorSucceeded) {
            NSLog(@"couldn't generate thumbnail, error:%@", error);
        }
        
        UIImage *thumbnail = [UIImage imageWithCGImage:im];
        UIImage *img = [UIImage imageNamed:@"blank.png"];
        
        if (thumbnail == nil)
            [videoThumbArray addObject:img];
        else
            [videoThumbArray addObject:thumbnail];

        nVideoThumbIndex++;
            
        [self getVideoThumbs];
    };
    
    CGSize maxSize = CGSizeMake(128, 128);
    generator.maximumSize = maxSize;
    [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
    
}

#pragma mark getVideoListArray

- (void) getVideoListArray{
    for (int i = 0; i<imgArray.count; i++) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        NSString *strSlideName = [[StringExtension alloc] getSlideNameFromString:[imgNameArray objectAtIndex:i]];
        NSString *strTemp = [[imgNameArray objectAtIndex:i] substringToIndex:strSlideName.length+9];
        
        for (int j=0; j<videoArray.count; j++) {
            if ([strTemp isEqualToString:[[videoNameArray objectAtIndex:j] substringToIndex:strSlideName.length+9]])
                [tempArray addObject:[NSNumber numberWithInt:j]];
        }
        
        [arrVideoList addObject:tempArray];
    }
}

#pragma mark initVideoAndImage

- (void) initVideoAndImage{
    if (isPortrait == 0)
        [self setLayoutPortrait];
    else
        [self setLayoutLandscape];
}



#pragma mark Dropbox
- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    NSString *strFileName, *strTempName;
    NSString *strPath;
    
    imgArray = [[NSMutableArray alloc] init];
    videoArray = [[NSMutableArray alloc] init];
    
    if ([metadata.contents count] == 0){
        [self raiseAlert:@"Alert" about:@"There is no files!"];
        [SVProgressHUD dismiss];
        
        //Enable all Events
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        return;
    }
    
    if (metadata.isDirectory) {
        for (DBMetadata* file in metadata.contents) {
            if (!file.isDirectory){
//                NSLog(file.filename);
                strTempName = [file.filename lowercaseString];
                strFileName = file.filename;
                strPath = file.path;
                
                NSString *subString = [strTempName substringFromIndex:strFileName.length - 4];
                if ([subString isEqualToString:@".png"] || [subString isEqualToString:@".jpg"]){
                    if ([[StringExtension alloc] isValidImage:strFileName]){
                        [imgArray addObject:strPath];
                        [imgNameArray addObject:strFileName];
                    }
                }else if ([subString isEqualToString:@".mp4"]){
                    if ([[StringExtension alloc] isValidVideo:strFileName]){
                        [videoArray addObject:strPath];
                        [videoNameArray addObject:strFileName];
                    }
                }
            }
        }
    }
    
    [self initVideoAndImage];
//    [AppDelegate hideWaitView];
    
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [imgDataArray addObject:[UIImage imageWithContentsOfFile:localPath]];
    if (nImageIndex == imgArray.count - 1) {
        [self loadImagesToScrollView];
        nImageIndex = 0;
    }else{
        nImageIndex ++;
        [self loadImageWithIndex:nImageIndex];
    }
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [SVProgressHUD dismiss];
    
    //Enable all Events
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    NSLog(@"There was an error loading the file – %@", error);
    [self raiseAlert:@"Error" about:@"There was an error loading the file!"];
}

-(void)restClient:(DBRestClient *)restClient loadedStreamableURL:(NSURL *)url forFile:(NSString *)path {
//    NSLog(@"Load streamable URL for file complete. URL: %@", url);
    
    [videoURLArray addObject:url];
    
    if (nVideoIndex == videoArray.count - 1){
        [self getVideoListArray];
        [self loadVideoToMediaPlay];
        nVideoIndex = 0;
    }else{
        nVideoIndex ++;
        [self loadVideoWithIndex:nVideoIndex];
    }
}

-(void)restClient:(DBRestClient *)restClient loadStreamableURLFailedWithError:(NSError *)error {
    NSLog(@"Loading streamable URL for file from Dropbox had an unexpected error: %@", error);
}

- (void)restClient:(DBRestClient *)client
loadMetadataFailedWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//    [AppDelegate hideWaitView];
    
    [SVProgressHUD dismiss];
    //Enable all Events
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
//    NSLog(@"There was an error loading the file – %@", error);
//    [self raiseAlert:@"Error" about:@"There was an error loading the file!"];
    
    NSLog(@"Error loading Dropbox metadata: %@", error);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error loading from Dropbox!" message:@"Please check your Internet connectivity and try again. And please check 'CoachsOffice' folder on your dropbox account." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alertView show];
    
}

#pragma mark TapGesture

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    if (imgArray.count == 0){
        return;
    }
    
    isFullscreen = 1;
    CGPoint touchPoint=[gesture locationInView:_scrollView];
    
    int nIndex = (int)touchPoint.x/_scrollView.bounds.size.width;
    self.ivFullScreen.image = [imgDataArray objectAtIndex:nIndex];
    self.ivFullScreen.hidden = NO;
    
    player.view.hidden = YES;
    
    for (UIView *view in self.scrollViewFull.subviews){
        [view removeFromSuperview];
    }
    
    self.scrollViewFull.hidden = NO;
    [self.ivFullScreen setFrame:CGRectMake(0, 0, _scrollViewFull.frame.size.width, _scrollViewFull.frame.size.height)];
    [self.scrollViewFull addSubview:self.ivFullScreen];
    self.scrollViewFull.contentSize = self.ivFullScreen.frame.size;
    
    [UIView animateWithDuration:0.3 animations:^{
//                [self.ivFullScreen setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        [self.scrollViewFull setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    }];
    
}

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _ivFullScreen;
}

- (void) tapGesture: (UIGestureRecognizer *) gestureRecognizer{
    isFullscreen = 0;
    
    //    for (UIView *view in self.scrollViewFull.subviews){
    //        [view removeFromSuperview];
    //    }
    
    [UIView animateWithDuration:0.3 animations:^{
        //        [self.ivFullScreen setFrame:CGRectMake(_scrollView.frame.origin.x, _scrollView.frame.origin.y, _scrollView.bounds.size.width, _scrollView.bounds.size.height)];
        [self.scrollViewFull setFrame:CGRectMake(_scrollView.frame.origin.x, _scrollView.frame.origin.y, _scrollView.bounds.size.width, _scrollView.bounds.size.height)];
    }];
    
    [self performSelector:@selector(hideFullScreenImageView) withObject:nil afterDelay:0.3];
}

- (void) tapGestureThumb: (UIGestureRecognizer *) gestureRecognizer{
    int n = gestureRecognizer.view.tag;
    
    if (n == nCurrentVideoIndex) {
        return;
    }
    
    nCurrentVideoIndex = n;
    
    [player.view removeFromSuperview];

//    [player setContentURL:[videoURLArray objectAtIndex:nCurrentVideoIndex]];
    player = [[MPMoviePlayerController alloc] initWithContentURL:[videoURLArray objectAtIndex:nCurrentVideoIndex]];
    
    if (isPortrait == 0)
        [player.view setFrame:CGRectMake(20, (screenSize.size.height-180)/2+80, screenSize.size.width-40, (screenSize.size.height-180)/2)];
    else
        [player.view setFrame:CGRectMake(screenSize.size.width/2+10, (screenSize.size.height-nHeight-140)/2+60, (screenSize.size.width-60)/2, nHeight)];
    
    player.view.hidden = NO;
    player.shouldAutoplay = NO;
    player.movieSourceType = MPMovieSourceTypeFile;
    [player prepareToPlay];
    [player.view.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [player.view.layer setBorderWidth:1.0];
    [self.view addSubview:player.view];
}

- (void) hideFullScreenImageView{
    self.ivFullScreen.hidden = YES;
    player.view.hidden = NO;
    self.scrollViewFull.hidden = YES;
    [self.ivFullScreen setFrame:CGRectMake(0, 0, _scrollView.bounds.size.width, _scrollView.bounds.size.height)];
}

#pragma mark Protrait/Landscape
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    if (isPortrait == 0){
        
    }else{
        
    }
}

- (void)orientationChanged:(NSNotification *)note
{
    if (nLoading == 0)
        return;
    
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight){
        isPortrait = 1;
        [self setLayoutLandscape];
    }else if([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait || [UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown){
        isPortrait = 0;
        [self setLayoutPortrait];
    }
}

#pragma mark ScrollView

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView{
    float contentOffsetX = _scrollView.contentOffset.x;
    nScrollIndex = contentOffsetX / _scrollView.frame.size.width;
    
    if (nVideoIsFirst != 0){
        isSlidePlay = 1;
        [self loadVideoToMediaPlay];
    }

    if (imgArray.count == 0){
        _ivLeft.hidden =  YES;
        _ivRight.hidden =  YES;
    }else{
        if (nScrollIndex == 0){
            _ivLeft.hidden = YES;
            _ivRight.hidden =  NO;
        }else if(nScrollIndex == imgArray.count-1){
            _ivLeft.hidden = NO;
            _ivRight.hidden = YES;
        }else{
            _ivLeft.hidden = NO;
            _ivRight.hidden = NO;
        }
    }
}

-(void) raiseAlert:(NSString*)title about:(NSString*)message {
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1)
        exit(1);
}

#pragma mark UITableView Delegate
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return imgArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0 , cell.bounds.size.width, cell.bounds.size.height)];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.text = [[StringExtension alloc] getPlayNameFromString:[imgNameArray objectAtIndex:indexPath.row]];
    titleLabel.font =[UIFont fontWithName:@"Helvetica-normal" size:18.0];
    titleLabel.textColor = [UIColor colorWithRed:23.0/255.0 green:30.0/255.0 blue:39.0/255.0 alpha:1];
    [cell.contentView addSubview:titleLabel];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self hideSlideList];
    
    [_scrollView setContentOffset:CGPointMake(indexPath.row * _scrollView.frame.size.width, _scrollView.contentOffset.y)];
    nScrollIndex = indexPath.row;
    isSlidePlay = 1;
    
    [self loadVideoToMediaPlay];
}

#pragma mark Buttons Event

- (IBAction)pressDropboxLinkBtn:(id)sender {
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
        [self.btnLinkButton setTitle:@"Dropbox Unlink" forState:UIControlStateNormal];
    } else {
        [[DBSession sharedSession] unlinkAll];
        [self.btnLinkButton setTitle:@"Dropbox Link" forState:UIControlStateNormal];
        [[[UIAlertView alloc]
          initWithTitle:@"Account Unlinked!" message:@"Your dropbox account has been unlinked"
          delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
         show];
    }

}

- (IBAction)pressRefreshDataBtn:(id)sender {
    [self getLatestDropboxData];
}

- (IBAction)pressShowListBtn:(id)sender {
    [self showSlideList];
}

- (IBAction)pressHideListBtn:(id)sender {
    [self hideSlideList];
}

#pragma mark SlideList
- (void) showSlideList{
//    player.view.hidden = YES;

//    [_viewSlideList removeFromSuperview];
    
    //Slide List View
    [_viewSlideList setFrame:CGRectMake(screenSize.size.width/2, 60, screenSize.size.width/2-20, screenSize.size.height-80)];
    [_tvList setFrame:CGRectMake(20, 20, _viewSlideList.bounds.size.width-40, _viewSlideList.bounds.size.height-90)];
    [_btnHideListButton setFrame:CGRectMake(_viewSlideList.bounds.size.width-140, _viewSlideList.bounds.size.height-50, _btnHideListButton.bounds.size.width, _btnHideListButton.bounds.size.height)];
    
    
    [UIView animateWithDuration:1.0 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.viewSlideList.hidden = NO;
    }completion:^(BOOL finished){
        
    }];
    isSlideList = 1;
}

- (void) hideSlideList{
    [UIView animateWithDuration:1.0 delay:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.viewSlideList.hidden = YES;
    }completion:^(BOOL finished){
        player.view.hidden = NO;
    }];
    isSlideList = 0;
}

@end
