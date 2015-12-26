//
//  RootNavigationController.m
//  SampleBufferDisplay
//
//  Created by zhangguang on 15/12/18.
//  Copyright © 2015年 com.v2tech. All rights reserved.
//

#import "RootNavigationController.h"

@interface RootNavigationController ()

@property (nonatomic,strong) UITraitCollection* traitCollection_wCompactHRegular;

@property (nonatomic,strong) UITraitCollection* traitCollection_hAnyWAny;

@property (nonatomic,assign) BOOL willTransitionToPortrait;

@end

@implementation RootNavigationController

- (UITraitCollection*)traitCollection_hCompactWRegular
{
    if (!_traitCollection_wCompactHRegular) {
        UITraitCollection* wCompact = [UITraitCollection traitCollectionWithHorizontalSizeClass:UIUserInterfaceSizeClassCompact];
        UITraitCollection* hCompact = [UITraitCollection traitCollectionWithVerticalSizeClass:UIUserInterfaceSizeClassRegular];
        _traitCollection_wCompactHRegular  =[UITraitCollection traitCollectionWithTraitsFromCollections:@[wCompact,hCompact]];
    }
    return _traitCollection_wCompactHRegular;
}

- (UITraitCollection*)traitCollection_hAnyWAny
{
    if (!_traitCollection_hAnyWAny) {
        UITraitCollection* wAny = [UITraitCollection traitCollectionWithVerticalSizeClass:UIUserInterfaceSizeClassUnspecified];
        UITraitCollection* hAny = [UITraitCollection traitCollectionWithHorizontalSizeClass:UIUserInterfaceSizeClassUnspecified];
        _traitCollection_hAnyWAny = [UITraitCollection traitCollectionWithTraitsFromCollections:@[wAny,hAny]];
    }
    return _traitCollection_hAnyWAny;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.willTransitionToPortrait = self.view.frame.size.height > self.view.frame.size.width;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    self.willTransitionToPortrait = size.height > size.width;
}

- (UITraitCollection*)overrideTraitCollectionForChildViewController:(UIViewController *)childViewController
{
    UITraitCollection* overrideTraitConnection = self.willTransitionToPortrait ? self.traitCollection_hCompactWRegular : self.traitCollection_hAnyWAny;
    return overrideTraitConnection;
}

@end
