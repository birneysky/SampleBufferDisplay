//
//  ViewController.m
//  SampleBufferDisplay
//
//  Created by birneysky on 15/12/16.
//  Copyright © 2015年 com.v2tech. All rights reserved.
//

#import "ViewController.h"
#import "VideoCapturer.h"
#import "CPUReporter.h"
#import "VideoFileParser.h"
#import "VideoPlayer.h"
#import "PreView.h"

@interface ViewController () <SampleBufferDisplayDelegate>

@property (nonatomic,strong) VideoCapturer* capture;
@property (weak, nonatomic) IBOutlet UISegmentedControl *resolutionSegment;

@property (nonatomic,strong) CPUReporter* reporter;

@property (weak, nonatomic) IBOutlet UILabel *cpuUseageLabel;

@property (weak, nonatomic) IBOutlet PreView *captureView;

@property (weak, nonatomic) IBOutlet VideoPlayer *playView;

@end

@implementation ViewController


#pragma mark - *** Properties ***

- (VideoCapturer*)capture
{
    if (!_capture) {
        _capture = [[VideoCapturer alloc] initWithSessionPreset:AVCaptureSessionPresetiFrame1280x720];
    }
    return _capture;
}

- (CPUReporter*)reporter
{
    if (!_reporter) {
        _reporter = [[CPUReporter alloc] initWithReportBlcock:^(CGFloat value) {
            self.cpuUseageLabel.text = [NSString stringWithFormat:@"CPU %.1f%%",value];
        }];
    }
    return _reporter;
}




#pragma mark - *** Init View ***
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //self.capture.previewLayer.frame = CGRectMake(20, 70, 352, 288);
    self.captureView.displayLayer = self.capture.previewLayer;
    //[self.view.layer addSublayer:self.capture.previewLayer];
    
     //[[UIApplication sharedApplication].keyWindow addSubview:self.view];
    //[[UIApplication sharedApplication].keyWindow.layer addSublayer: self.capture.previewLayer];
    //[self.view removeFromSuperview];
    
   
    
//    CGRect rect = self.capture.previewLayer.frame;
//    //CGPoint center = self.capture.previewLayer
//    self.sampleLayer.frame = CGRectMake(100, rect.origin.y + rect.size.height + 10, 288, 352);
//    self.sampleLayer.transform = CATransform3DMakeRotation(M_PI / 2, 0, 0, 1);
    
    //[self.view.layer addSublayer:self.sampleLayer];
    /*第一个参数是旋转角度，后面三个参数形成一个围绕其旋转的向量，起点位置由UIView的center属性标识。
     在这里需要说明的是在3D变换的时候，如果是变换的向量和屏幕垂直，那么就会相当于2D的旋转变化。如果不是垂直的，系统会现将整个画面调整到与这个向量垂直（没有动画），再进行旋转。所以会形成一个跳跃，破坏动画的连贯。
     所以如果有这类变换的情况请尽量考虑动画的连贯，现将view动画变换到和向量垂直，然后进行旋转，最后再恢复和屏幕平行。
     CATransform3DMakeRotation 总是按最短路径来选择，当顺时针和逆时针的路径相同时，使用逆时针。若需要使其按顺时针旋转，用 CAKeyframeAnimation 并在在顺时针路径上增加几个关键点即可。*/
    
    //self.capture.encoder.delegate = self;
    self.capture.encoder.handler.dispalyDelegate = self;
    [self.reporter start];
    
    
//    VideoFileParser* parese = [[VideoFileParser alloc] init];
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"h264"];
//    [parese open:path];
//    [parese nextPacket];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissPreview) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPreview) name:UIApplicationDidBecomeActiveNotification object:nil];
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
    //[self.capture start];
    //[self.reporter start];
    //[self.sampleLayer performSelector:@selector(flush) withObject:nil afterDelay:2];
    [self.playView.displayLayer flushAndRemoveImage];
    [self.capture startSend];
}

- (void)dismissPreview
{
    //[self.capture.previewLayer removeFromSuperlayer];
    //[self.capture stop];
    [self.capture stopSend];

    
}


#pragma mark - *** Target Action ***

- (IBAction)leftButtomItemClicked:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"开始"]) {
        [self.capture start];
        sender.title = @"停止";
    }
    else
    {
        [self.capture stop];
        sender.title = @"开始";
    }
    
}
- (IBAction)SegmentedControlClicked:(UISegmentedControl *)sender {
    

}


- (IBAction)leftBottomItemClicked:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"◉"]) {
        [self.capture startSend];
        sender.tintColor = [UIColor redColor];
        sender.title = @"⦿";
    }else{
        [self.capture stopSend];
        sender.tintColor = [UIColor greenColor];
        sender.title = @"◉";
    }
}

- (void)displayEncodedSampleBuffer:(CMSampleBufferRef)sample
{
    [self.playView.displayLayer enqueueSampleBuffer:sample];
}

#pragma mark - *** h264EncoderDelegate ***
- (void)didEncodeSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    [self.playView.displayLayer enqueueSampleBuffer:sampleBuffer];
}


- (BOOL)shouldAutorotate
{
    return YES;
}


//
//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    
//}
//
//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//}

@end
