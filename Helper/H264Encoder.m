//
//  H264Encoder.m
//  SampleBufferDisplay
//
//  Created by zhangguang on 15/12/16.
//  Copyright © 2015年 com.v2tech. All rights reserved.
//

#import "H264Encoder.h"
#import <VideoToolbox/VideoToolbox.h>


@interface H264Encoder ()

@property (nonatomic,strong) dispatch_queue_t dataEncodeQueue;

@end

@implementation H264Encoder
{
@protected
    VTCompressionSessionRef encodeSession;
}

#pragma mark - *** Property ***
- (dispatch_queue_t)dataEncodeQueue
{
    if (!_dataEncodeQueue) {
        _dataEncodeQueue = dispatch_queue_create("com.video.Encode", 0);
    }
    return _dataEncodeQueue;
}

- (void)startWithSize:(CGSize) videoSize
{
    dispatch_async(self.dataEncodeQueue, ^{
       
        OSStatus status = VTCompressionSessionCreate(NULL, (int32_t)videoSize.width, (int32_t)videoSize.height, kCMVideoCodecType_H264, NULL, NULL, NULL, videoCompressionOutputCallback, (__bridge void * _Nullable)(self), &encodeSession);
        
        if (noErr != status) {
            DebugLog(@"H264: Unable to create a H264 session code %ld",status);
        }
        else
        {
            VTSessionSetProperty(encodeSession, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
            VTSessionSetProperty(encodeSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Main_AutoLevel);
            VTCompressionSessionPrepareToEncodeFrames(encodeSession);
        }
        
    });
}

- (BOOL)encode:(CMSampleBufferRef)sampleBuffer
{
    if (NULL == encodeSession) {
        DebugLog(@" encode failed session %p ",encodeSession);
        return NO;
    }
    __block OSStatus status;
    dispatch_async(self.dataEncodeQueue, ^{
       	CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CMTime presentationTimeStamp = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer);
        CMTime duration = CMSampleBufferGetOutputDuration(sampleBuffer);
        status = VTCompressionSessionEncodeFrame(encodeSession, pixelBuffer, presentationTimeStamp, duration, NULL, pixelBuffer, NULL);
        
    });
    assert(status == noErr);
    return status == noErr;
}

- (void)stop
{
    dispatch_async(self.dataEncodeQueue, ^{
        VTCompressionSessionCompleteFrames(encodeSession, kCMTimeInvalid);
        
        // End the session
        VTCompressionSessionInvalidate(encodeSession);
        CFRelease(encodeSession);
        encodeSession = NULL;
    });
}


void videoCompressionOutputCallback(
                                    void * CM_NULLABLE outputCallbackRefCon,
                                    void * CM_NULLABLE sourceFrameRefCon,
                                    OSStatus status,
                                    VTEncodeInfoFlags infoFlags,
                                    CM_NULLABLE CMSampleBufferRef sampleBuffer )
{
    
    DebugLog("samplebuffer %p, staus %ld",sampleBuffer,status);
    //    NSLog(@"==> videoCompressionOutputCallback");
    //    VTPCompressionSession *compressionSession = (__bridge VTPCompressionSession *)outputCallbackRefCon;
    //    [compressionSession encodePixelBufferCallbackWithSampleBuffer:sampleBuffer infoFlags:infoFlags];
}

@end
