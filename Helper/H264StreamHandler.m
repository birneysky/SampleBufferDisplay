//
//  SampleBufferHandler.m
//  SampleBufferDisplay
//
//  Created by birneysky on 16/5/15.
//  Copyright © 2016年 com.v2tech. All rights reserved.
//

#import "H264StreamHandler.h"

@interface H264StreamHandler ()
@property (nonatomic,strong) NSMutableArray* simpleSizeArray;
@end

@implementation H264StreamHandler
{
    @private
    CMVideoFormatDescriptionRef _decoderFormatDescription;
    CMBlockBufferRef _blockBuffer;
    size_t _bufferSize;
}

#pragma mark - *** Properties ***
- (NSMutableArray*) simpleSizeArray
{
    if (!_simpleSizeArray) {
        _simpleSizeArray = [[NSMutableArray alloc] init];
    }
    return _simpleSizeArray;
}

#pragma mark - *** h264EncoderOutput***
- (void)didEncodedSps:(NSData *)sps pps:(NSData *)pps
{
    const uint8_t* const parameterSetPointers[2] = { sps.bytes, pps.bytes };
    const size_t parameterSetSizes[2] = { sps.length, pps.length };
    OSStatus status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault,
                                                                          2, //param count
                                                                          parameterSetPointers,
                                                                          parameterSetSizes,
                                                                          4, //nal start code size
                                                                          &_decoderFormatDescription);
    assert(noErr == status);
}

- (void)didEncodedData:(NSData *)data isKeyFrame:(BOOL)isKey
{
    if (!_blockBuffer) {
        OSStatus status = CMBlockBufferCreateEmpty(NULL, 0, 0, &_blockBuffer);
        assert(noErr == status);
        _bufferSize = 0;
    }
    
    size_t blockOffset = CMBlockBufferGetDataLength(_blockBuffer);
    NSUInteger dataLength = data.length;

    OSStatus status = CMBlockBufferAppendMemoryBlock(_blockBuffer, (void*)data.bytes,
                                            dataLength, // Add 1 for the offset we decremented
                                            kCFAllocatorDefault,
                                            NULL, 0, dataLength, 0);
    _bufferSize += dataLength;
    [self.simpleSizeArray addObject:@(dataLength)];

}

- (void)didOneFrameFinish
{
    CMSampleBufferRef sampleBuffer = NULL;
    OSStatus status = CMSampleBufferCreate(kCFAllocatorDefault, _blockBuffer, YES, NULL, NULL, _decoderFormatDescription, 1, 0, NULL/*timeArray*/, 0, NULL, &sampleBuffer);
    assert(noErr == status);
    CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
    CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
    CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);
    if ([self.dispalyDelegate respondsToSelector:@selector(displayEncodedSampleBuffer:)]) {
        [self.dispalyDelegate displayEncodedSampleBuffer:sampleBuffer];
    }
    CFRelease(_blockBuffer);
    //CFRelease(sampleBuffer);
    
    
    _blockBuffer = NULL;
}

@end
