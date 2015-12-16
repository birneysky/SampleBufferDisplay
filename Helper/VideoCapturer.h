//
//  VideoCapturer.h
//  SampleBufferDisplay
//
//  Created by zhangguang on 15/12/16.
//  Copyright © 2015年 com.v2tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoCapturer : NSObject

@property (nonatomic,readonly) AVCaptureVideoPreviewLayer* previewLayer;

- (instancetype)initWithSessionPreset:(NSString*)preset;

- (BOOL)start;

- (BOOL)stop;

@end
