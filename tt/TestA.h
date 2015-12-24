//
//  TestA.h
//  SampleBufferDisplay
//
//  Created by zhangguang on 15/12/24.
//  Copyright © 2015年 com.v2tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A.h"
#import "B.h"

@interface TestA : NSObject <A,B>

- (void)start;

- (void)stop;

@end
