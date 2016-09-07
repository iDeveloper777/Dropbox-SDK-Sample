//
//  MainViewController.m
//  VideoAndImage
//
//  Created by Csaba Toth on 14/5/15.
//  Copyright (c) 2015 Csaba Toth. All rights reserved.
//

#import "MainViewController.h"
#import "ViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self performSelector:@selector(showView) withObject:nil afterDelay:3.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showView{
    self.lblTitle.hidden = YES;
    self.lblCopyright.hidden = YES;
    
    ViewController *viewController = (ViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"View"];
    [self.navigationController pushViewController:viewController animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
