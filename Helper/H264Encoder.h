//
//  H264Encoder.h
//  SampleBufferDisplay
//
//  Created by zhangguang on 15/12/16.
//  Copyright © 2015年 com.v2tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@protocol h264EncoderDelegate <NSObject>
@required

- (void) didEncodeSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@optional

- (void) didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

@interface H264Encoder : NSObject

@property (nonatomic,assign) id <h264EncoderDelegate> delegate;

@end
