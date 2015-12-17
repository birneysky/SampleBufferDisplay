//
//  ViewController.m
//  SampleBufferDisplay
//
//  Created by zhangguang on 15/12/16.
//  Copyright © 2015年 com.v2tech. All rights reserved.
//

#import "ViewController.h"
#import "VideoCapturer.h"
#import<CoreFoundation/CFArray.h>

//#import<IOKit/IOKitLib.h>

//#import<IOKit/pwr_mgt/IOPMLibDefs.h>

//#import<IOKit/pwr_mgt/IOPMKeys.h>

#import<Availability.h>


@interface ViewController ()

@property (nonatomic,strong) VideoCapturer* capture;
@property (weak, nonatomic) IBOutlet UISegmentedControl *resolutionSegment;

@end

@implementation ViewController


#pragma mark - *** Properties ***

- (VideoCapturer*)capture
{
    if (!_capture) {
        _capture = [[VideoCapturer alloc] initWithSessionPreset:AVCaptureSessionPresetLow];
    }
    return _capture;
}

#pragma mark - *** Init View ***
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    DebugLog(@"previewlayer %p",self.capture.previewLayer);
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissPreview) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPreview) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - *** Helper ***
- (void)showPreview
{
    self.capture.previewLayer.frame = CGRectMake(0, 70, 320, 240);
    [self.view.layer addSublayer:self.capture.previewLayer];
    [self.capture start];
}

- (void)dismissPreview
{
    [self.capture.previewLayer removeFromSuperlayer];
    [self.capture stop];
}

#pragma mark - *** Target Action ***

- (IBAction)leftButtomItemClicked:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"开始"]) {
        [self showPreview];
        sender.title = @"停止";
    }
    else
    {
        [self dismissPreview];
        sender.title = @"开始";
    }
    
}
- (IBAction)SegmentedControlClicked:(UISegmentedControl *)sender {
    
    DebugLog(@" select index %d, title",sender.selectedSegmentIndex,[sender titleForSegmentAtIndex:sender.selectedSegmentIndex]);
    
    IOPMCopyCPUPowerStatus(NULL);
}
@end
