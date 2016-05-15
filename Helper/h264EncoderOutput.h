//
//  h264EncoderOutput.h
//  SampleBufferDisplay
//
//  Created by birneysky on 16/5/15.
//  Copyright © 2016年 com.v2tech. All rights reserved.
//

#ifndef h264EncoderOutput_h
#define h264EncoderOutput_h

@protocol h264EncoderOutput <NSObject>

- (void) didEncodedSps:(NSData*)sps pps:(NSData*)pps;
- (void) didEncodedData:(NSData*)data isKeyFrame:(BOOL)isKey;
- (void) didOneFrameFinish;

@end


#endif /* h264EncoderOutput_h */
