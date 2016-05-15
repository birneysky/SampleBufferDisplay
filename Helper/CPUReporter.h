//
//  CpuReporter.h
//  SampleBufferDisplay
//
//  Created by birneysky on 15/12/17.
//  Copyright © 2015年 com.v2tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef void(^reportBlock)(CGFloat value);

@interface CPUReporter : NSObject

- (instancetype)initWithReportBlcock:(reportBlock)block;

- (void)start;

- (void)stop;

@end
