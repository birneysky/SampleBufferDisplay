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

@property (nonatomic,strong) AVCaptureVideoPreviewLayer* previewLayer;

@property (nonatomic,assign) BOOL isSend;

@property (nonatomic,strong) H264Encoder* encoder;

@end

@implementation VideoCapturer

#pragma mark - *** Properties ***

- (dispatch_queue_t)dataOutputQueue
{
    if (!_dataOutputQueue) {
        _dataOutputQueue = dispatch_queue_create("com.video.output", 0);
    }
    return _dataOutputQueue;
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

- (H264Encoder*)encoder
{
    if (!_encoder) {
        _encoder = [[H264Encoder alloc] init];
    }
    return _encoder;
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
    connection.videoMirrored = YES;
    
    [self.session startRunning];
    return YES;
}

- (BOOL)stop;
{
    [self.session stopRunning];
    return YES;
}


- (void)startSend
{
    dispatch_async(self.dataOutputQueue, ^{
        self.isSend = YES;
    });
}

- (void)stopSend
{
    dispatch_async(self.dataOutputQueue, ^{
        self.isSend = NO;
    });
}


#pragma mark - *** AVCaptureVideoDataOutputSampleBufferDelegate *** 

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
    if (self.isSend) {
       DebugLog(@"sampleBuffer %p",sampleBuffer);
        [self.encoder encode:sampleBuffer];
    }
}

@end
