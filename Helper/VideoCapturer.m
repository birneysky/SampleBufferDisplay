//
//  VideoCapturer.m
//  SampleBufferDisplay
//
//  Created by birneysky on 15/12/16.
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
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSessionWithNoConnection:self.session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
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

#pragma mark - *** Control ***
- (BOOL)start
{
    if (self.sessionPreset.length <= 0) {
        DebugLog(@" start failed ,sessionPreset is %@",self.sessionPreset);
        return NO;
    }
    
    self.session.sessionPreset = self.sessionPreset;
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
                                     @(kCVPixelFormatType_32BGRA)};
    [dataOutput setSampleBufferDelegate:self queue:self.dataOutputQueue];
    if ([self.session canAddOutput:dataOutput]) {
        [self.session addOutput:dataOutput];
    }
    
    [captureDevice lockForConfiguration:nil];
    captureDevice.activeVideoMinFrameDuration = CMTimeMake(1, 10);
    captureDevice.activeVideoMaxFrameDuration = CMTimeMake(1, 10 + 2);
    [captureDevice unlockForConfiguration];
    
    AVCaptureConnection* connection =[dataOutput connectionWithMediaType:AVMediaTypeVideo];
    connection.videoOrientation = AVCaptureVideoOrientationPortrait;

    if ([captureDevice.activeFormat isVideoStabilizationModeSupported:AVCaptureVideoStabilizationModeCinematic]) {
        [connection setPreferredVideoStabilizationMode:AVCaptureVideoStabilizationModeCinematic];
    }else if([captureDevice.activeFormat isVideoStabilizationModeSupported:AVCaptureVideoStabilizationModeAuto]){
        [connection setPreferredVideoStabilizationMode:AVCaptureVideoStabilizationModeAuto];
    }
    //connection.videoMirrored = YES;

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
        [self.encoder startWithSize:[self CaptureSize]];
        self.isSend = YES;
    });
}

- (void)stopSend
{
    dispatch_async(self.dataOutputQueue, ^{
        [self.encoder stop];
        self.isSend = NO;
    });
}

- (CGSize)CaptureSize
{
    if ([self.sessionPreset isEqualToString:AVCaptureSessionPresetLow]) {
        return CGSizeMake(192, 144);
    }
    else if ([self.sessionPreset isEqualToString:AVCaptureSessionPreset352x288]){
        return CGSizeMake(352, 288);
    }
    else if ([self.sessionPreset isEqualToString:AVCaptureSessionPreset640x480]){
        return CGSizeMake(480, 640);
    }
    else if ([self.sessionPreset isEqualToString:AVCaptureSessionPresetiFrame1280x720]){
        return CGSizeMake(1280, 720);
    }else{
        DebugLog(@"capture size not support preset = %@",self.sessionPreset);
        return CGSizeZero;
    }
}

#pragma mark - *** AVCaptureVideoDataOutputSampleBufferDelegate *** 

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
    if (self.isSend) {
       //DebugLog(@"sampleBuffer %p",sampleBuffer);
        [self.encoder encode:sampleBuffer];
    }
}

@end
