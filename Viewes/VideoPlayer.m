//
//  VideoPlayer.m
//  SampleBufferDisplay
//
//  Created by birneysky on 15/12/27.
//  Copyright © 2015年 com.v2tech. All rights reserved.
//

#import "VideoPlayer.h"

@interface VideoPlayer ()

@property (nonatomic,strong) AVSampleBufferDisplayLayer* displayLayer;

@end

@implementation VideoPlayer

#pragma mark - *** Properties ***
- (AVSampleBufferDisplayLayer*)displayLayer
{
    if (!_displayLayer) {
        _displayLayer = [[AVSampleBufferDisplayLayer alloc] init];
        _displayLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        _displayLayer.backgroundColor = [UIColor blackColor].CGColor;
    }
    return _displayLayer;
}

-(instancetype) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self.layer addSublayer:self.displayLayer];
    }
    return self;
}

- (void)layoutSubviews
{
    self.displayLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

@end
