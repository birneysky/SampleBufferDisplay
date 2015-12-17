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

#import <mach/mach.h>


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
    DebugLog(@" cpu_usage = %f",cpu_usage());
}


float cpu_usage()
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

@end
