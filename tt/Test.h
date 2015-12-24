//
//  Test.h
//  SampleBufferDisplay
//
//  Created by zhangguang on 15/12/24.
//  Copyright © 2015年 com.v2tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A.h"
#import "B.h"

@interface Test : NSObject

@property (nonatomic,strong)id<A,B> obj;

@end
