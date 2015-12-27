//
//  VideoPlayer.h
//  SampleBufferDisplay
//
//  Created by birneysky on 15/12/27.
//  Copyright © 2015年 com.v2tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoPlayer : UIView

@property (nonatomic,readonly) AVSampleBufferDisplayLayer* displayLayer;


@end
