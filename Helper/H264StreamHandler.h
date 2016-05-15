//
//  SampleBufferHandler.h
//  SampleBufferDisplay
//
//  Created by birneysky on 16/5/15.
//  Copyright © 2016年 com.v2tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "h264EncoderOutput.h"
#import <AVFoundation/AVFoundation.h>

@protocol  SampleBufferDisplayDelegate <NSObject>

- (void)displayEncodedSampleBuffer:(CMSampleBufferRef)sample;

@end

@interface H264StreamHandler : NSObject <h264EncoderOutput>

@property (nonatomic,assign) id<SampleBufferDisplayDelegate> dispalyDelegate;

- (void)didEncodedSps:(NSData *)sps pps:(NSData *)pps;

- (void)didEncodedData:(NSData *)data isKeyFrame:(BOOL)isKey;

- (void)didOneFrameFinish:(BOOL) isKey;

@end
