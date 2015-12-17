//
//  CpuReporter.m
//  SampleBufferDisplay
//
//  Created by zhangguang on 15/12/17.
//  Copyright © 2015年 com.v2tech. All rights reserved.
//

#import "CPUReporter.h"

@interface CPUReporter ()

@property(nonatomic,copy) reportBlock reportBlk;

@end

@implementation CPUReporter

- (instancetype)initWithReportBlcock:(reportBlock)block
{
    if (self = [super init]) {
        self.reportBlk = block;
    }
    
    return self;
}


- (void)start
{
    
}

- (void)stop
{
    
}

@end
