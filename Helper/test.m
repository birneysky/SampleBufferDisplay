//
//  test.m
//  SampleBufferDisplay
//
//  Created by zhangguang on 15/12/17.
//  Copyright © 2015年 com.v2tech. All rights reserved.
//

#import "test.h"


@interface testa ()
@property (nonatomic,strong) dispatch_queue_t dataEncodeQueue;
@property (nonatomic,strong) NSMutableArray* array;
@property (nonatomic,assign) int stst;
@end
@implementation testa


#pragma mark - *** Property ***
- (dispatch_queue_t)dataEncodeQueue
{
    if (!_dataEncodeQueue) {
        _dataEncodeQueue = dispatch_queue_create("com.video.Encode", 0);
    }
    return _dataEncodeQueue;
}

- (NSMutableArray*)array
{
    if (!_array) {
        _array = [[NSMutableArray alloc] init];
    }
    return _array;
}


- (void)start
{
    dispatch_async(self.dataEncodeQueue, ^{
        self.stst = 3;
        [self.array addObject:@"xxx"];
    });
}

- (void)dealloc
{
    DebugLog(@"class %@",[self class]);
}

@end
