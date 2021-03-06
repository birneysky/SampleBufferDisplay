//
//  H264Encoder.m
//  SampleBufferDisplay
//
//  Created by birneysky on 15/12/16.
//  Copyright © 2015年 com.v2tech. All rights reserved.
//

#import "H264Encoder.h"
#import <VideoToolbox/VideoToolbox.h>

@interface H264Encoder ()

@end

@implementation H264Encoder
{
@protected
    VTCompressionSessionRef _encodeSession;
    H264StreamHandler* _handler;
     int  frameCount;
}

#pragma mark - *** Initializers ***
- (instancetype)init
{
    if (self = [super init]) {
        _handler = [[H264StreamHandler alloc] init];
        self.delegate = _handler;
    }
    return self;
}

#pragma makr - *** API ***
- (void)startWithSize:(CGSize) videoSize
{
    OSStatus status = VTCompressionSessionCreate(NULL, (int32_t)videoSize.width, (int32_t)videoSize.height, kCMVideoCodecType_H264, NULL, NULL, NULL, videoCompressionOutputCallback, (__bridge void * _Nullable)(self), &_encodeSession);
    
    if (noErr != status) {
        DebugLog(@"H264: Unable to create a H264 session code %ld",status);
    }
    else
    {
        VTSessionSetProperty(_encodeSession, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
        VTSessionSetProperty(_encodeSession, kVTCompressionPropertyKey_AverageBitRate, (__bridge CFTypeRef _Nonnull)(@(256 * 1024)));
         VTSessionSetProperty(_encodeSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Main_AutoLevel);
        VTSessionSetProperty(_encodeSession, kVTCompressionPropertyKey_MaxH264SliceBytes, (__bridge CFTypeRef _Nonnull)(@(256)));//这个参数似乎没什么卵用，设置了跟没设置一样的
        VTCompressionSessionPrepareToEncodeFrames(_encodeSession);
    }
    
    frameCount = 0;
}

- (BOOL)encode:(CMSampleBufferRef)sampleBuffer
{
    if (NULL == _encodeSession) {
        DebugLog(@" encode failed session %p ",_encodeSession);
        return NO;
    }
    OSStatus status = 0;
    VTEncodeInfoFlags flags;
    frameCount++;
//    CVImageBufferRef imageBuffer = (CVImageBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
//    CMTime presentationTimeStamp = CMTimeMake(frameCount, 3000);
//    status = VTCompressionSessionEncodeFrame(_encodeSession, imageBuffer, presentationTimeStamp, kCMTimeInvalid, NULL, NULL, &flags);

    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CMTime presentationTimeStamp = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer);
    CMTime duration = CMSampleBufferGetOutputDuration(sampleBuffer);
    status = VTCompressionSessionEncodeFrame(_encodeSession, pixelBuffer, presentationTimeStamp, duration, NULL, NULL, &flags);

    assert(status == noErr);
    return status == noErr;
}

- (void)stop
{
    if (NULL != _encodeSession) {
        VTCompressionSessionCompleteFrames(_encodeSession, kCMTimeInvalid);
        
        // End the session
        VTCompressionSessionInvalidate(_encodeSession);
        CFRelease(_encodeSession);
        _encodeSession = NULL;
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
    
    if (status != 0) return;
    
    if (!CMSampleBufferDataIsReady(sampleBuffer))
    {
        NSLog(@"didCompressH264 data is not ready ");
        return;
    }

    bool keyframe = !CFDictionaryContainsKey((CFDictionaryRef) CFArrayGetValueAtIndex(CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true), 0), kCMSampleAttachmentKey_NotSync);
    //NSMutableArray* dataArray = [[NSMutableArray alloc] initWithCapacity:5];
    if (keyframe)
    {
        CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
        size_t sparameterSetSize, sparameterSetCount;
        const uint8_t *sparameterSet;
        OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 0, &sparameterSet, &sparameterSetSize, &sparameterSetCount, 0 );
        if (statusCode == noErr)
        {
            // Found sps and now check for pps
            size_t pparameterSetSize, pparameterSetCount;
            const uint8_t *pparameterSet;
            OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 1, &pparameterSet, &pparameterSetSize, &pparameterSetCount, 0 );
            if (statusCode == noErr)
            {
                // Found pps
                NSData* spsData = [[NSData alloc] initWithBytesNoCopy:(void*)sparameterSet length:sparameterSetSize freeWhenDone:NO];
                NSData* ppsData = [[NSData alloc] initWithBytesNoCopy:(void*)pparameterSet length:pparameterSetSize freeWhenDone:NO];
                [encoder.delegate didEncodedSps:spsData pps:ppsData];
                //[dataArray addObject:spsData];
                //[dataArray addObject:ppsData];
            }
        }
    }
    
    /*BlockBuffer 是由多个“数据长度+数据”这样的数据（Slices）拼接成的，
    其中数据长度占四个字节，并且用网络字节序表示。数据是没有起始码的h264流.
    返回的SampleBuffer 是编码后一整帧的数据。
    也就是说，如果把一帧中的多个slice，使用“数据+长度”的方式拼接起来就可以创建出代表一整帧的数据的SampleBuffer
     这样就可以使用硬件解码了，当然也可以把这个SampleBuffer丢入到AVSampleBufferDisplayLayer图层的队列中，
     由图层完成解码显示的工作
     */
    CMBlockBufferRef dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    size_t length, totalLength;
    char *dataPointer;
    OSStatus statusCodeRet = CMBlockBufferGetDataPointer(dataBuffer, 0, &length, &totalLength, &dataPointer);
    if (statusCodeRet == noErr) {
        
        size_t bufferOffset = 0;
        static const int AVCCHeaderLength = 4;
        while (bufferOffset < totalLength - AVCCHeaderLength) {
            
            // Read the NAL unit length
            uint32_t NALUnitLength = 0;
            memcpy(&NALUnitLength, dataPointer + bufferOffset, AVCCHeaderLength);
            
            // Convert the length value from Big-endian to Little-endian
            NALUnitLength = CFSwapInt32BigToHost(NALUnitLength);
            NSLog(@"keyFrame %d, size %d",keyframe,NALUnitLength);
            NSData* data = [[NSData alloc] initWithBytesNoCopy:(dataPointer + bufferOffset ) length:NALUnitLength + AVCCHeaderLength freeWhenDone:NO];
            [encoder.delegate didEncodedData:data isKeyFrame:keyframe];
            //[dataArray addObject:data];
            bufferOffset += AVCCHeaderLength + NALUnitLength;
        }
        
    }
    if ([encoder.delegate respondsToSelector:@selector(didOneFrameFinish:)]) {
        [encoder.delegate didOneFrameFinish:keyframe];
    }
    NSLog(@"frame end");
    
}

@end
