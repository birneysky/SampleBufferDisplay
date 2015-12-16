//
//  VideoCapturer.m
//  SampleBufferDisplay
//
//  Created by zhangguang on 15/12/16.
//  Copyright © 2015年 com.v2tech. All rights reserved.
//

#import "VideoCapturer.h"

@interface VideoCapturer ()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic,strong) AVCaptureSession* session;

@property (nonatomic,copy) NSString* sessionPreset;

@property (nonatomic,strong) dispatch_queue_t dataOutputQueue;

@property (nonatomic,strong) dispatch_queue_t dataEncodeQueue;

@property (nonatomic,strong) AVCaptureVideoPreviewLayer* previewLayer;

@end

@implementation VideoCapturer

#pragma mark - *** Properties ***

- (dispatch_queue_t)dataOutputQueue
{
    if (!_dataEncodeQueue) {
        _dataEncodeQueue = dispatch_queue_create("com.video.output", 0);
    }
    return _dataEncodeQueue;
}

- (dispatch_queue_t)dataEncodeQueue
{
    if (!_dataEncodeQueue) {
        _dataEncodeQueue = dispatch_queue_create("com.video.Encode", 0);
    }
    return _dataEncodeQueue;
}

- (AVCaptureSession*)session
{
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}

- (AVCaptureVideoPreviewLayer*)previewLayer
{
    if (!_previewLayer) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _previewLayer.backgroundColor = [UIColor blackColor].CGColor;
    }
    return _previewLayer;
}

#pragma mark - *** Initializers ***
- (instancetype)initWithSessionPreset:(NSString*)preset
{
    if (self = [super init]) {
        self.sessionPreset = preset;
    }
    return self;
}

- (BOOL)start
{
    if (self.sessionPreset.length <= 0) {
        DebugLog(@" start failed ,sessionPreset is %@",self.sessionPreset);
        return NO;
    }
    NSError* error;
    AVCaptureDevice* captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput* inputDevice = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (error) {
        DebugLog(@"error %@",error.description);
        return NO;
    }
    
    if ([self.session canAddInput:inputDevice]) {
        [self.session addInput:inputDevice];
    }
    
    AVCaptureVideoDataOutput* dataOutput =  [[AVCaptureVideoDataOutput alloc] init];
    dataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey:
                                     @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};
    [dataOutput setSampleBufferDelegate:self queue:self.dataOutputQueue];
    if ([self.session canAddOutput:dataOutput]) {
        [self.session addOutput:dataOutput];
    }
    
    AVCaptureConnection* connection =[dataOutput connectionWithMediaType:AVMediaTypeVideo];
    if ([captureDevice.activeFormat isVideoStabilizationModeSupported:AVCaptureVideoStabilizationModeCinematic]) {
        [connection setPreferredVideoStabilizationMode:AVCaptureVideoStabilizationModeCinematic];
    }else if([captureDevice.activeFormat isVideoStabilizationModeSupported:AVCaptureVideoStabilizationModeAuto]){
        [connection setPreferredVideoStabilizationMode:AVCaptureVideoStabilizationModeAuto];
    }
    
    [self.session startRunning];
    return YES;
}

- (BOOL)stop;
{
    [self.session stopRunning];
    return YES;
}


#pragma mark - *** AVCaptureVideoDataOutputSampleBufferDelegate *** 

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    //DebugLog(@"sampleBuffer %p",sampleBuffer);
}

@end
