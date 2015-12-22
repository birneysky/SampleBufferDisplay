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

@end

@implementation H264Encoder
{
@protected
    VTCompressionSessionRef encodeSession;
}

#pragma mark - *** Property ***


- (void)startWithSize:(CGSize) videoSize
{
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
}

- (BOOL)encode:(CMSampleBufferRef)sampleBuffer
{
    if (NULL == encodeSession) {
        DebugLog(@" encode failed session %p ",encodeSession);
        return NO;
    }
    OSStatus status = 0;
    VTEncodeInfoFlags flags;
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CMTime presentationTimeStamp = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer);
    CMTime duration = CMSampleBufferGetOutputDuration(sampleBuffer);
    status = VTCompressionSessionEncodeFrame(encodeSession, pixelBuffer, presentationTimeStamp, duration, NULL, NULL, &flags);

    assert(status == noErr);
    return status == noErr;
}

- (void)stop
{
    if (NULL != encodeSession) {
        VTCompressionSessionCompleteFrames(encodeSession, kCMTimeInvalid);
        
        // End the session
        VTCompressionSessionInvalidate(encodeSession);
        CFRelease(encodeSession);
        encodeSession = NULL;
    }
}


void videoCompressionOutputCallback(
                                    void * CM_NULLABLE outputCallbackRefCon,
                                    void * CM_NULLABLE sourceFrameRefCon,
                                    OSStatus status,
                                    VTEncodeInfoFlags infoFlags,
                                    CM_NULLABLE CMSampleBufferRef sampleBuffer )
{
    
    H264Encoder* encoder = (__bridge H264Encoder *)outputCallbackRefCon;
    if ([encoder.delegate respondsToSelector:@selector(didEncodeSampleBuffer:)]) {
        [encoder.delegate didEncodeSampleBuffer:sampleBuffer];
    }
}

@end
