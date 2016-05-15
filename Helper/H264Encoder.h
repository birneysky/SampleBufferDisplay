//
//  H264Encoder.h
//  SampleBufferDisplay
//
//  Created by birneysky on 15/12/16.
//  Copyright © 2015年 com.v2tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "H264Encoder.h"
#import "h264EncoderOutput.h"
#import "H264StreamHandler.h"

@interface H264Encoder : NSObject

@property (nonatomic,assign) id <h264EncoderOutput> delegate;

@property (nonatomic,readonly) H264StreamHandler* handler;

- (void)startWithSize:(CGSize) videoSize;

- (BOOL)encode:(CMSampleBufferRef)sampleBuffer;

- (void)stop;


@end
