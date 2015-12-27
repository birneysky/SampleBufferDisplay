//
//  PreView.m
//  SampleBufferDisplay
//
//  Created by birneysky on 15/12/27.
//  Copyright © 2015年 com.v2tech. All rights reserved.
//

#import "PreView.h"

@implementation PreView

- (void)layoutSubviews
{
    self.displayLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)setDisplayLayer:(CALayer *)displayLayer
{
    if (_displayLayer) {
        [_displayLayer removeFromSuperlayer];
    }
    
    _displayLayer = displayLayer;
    [self.layer addSublayer:_displayLayer];
}

@end
