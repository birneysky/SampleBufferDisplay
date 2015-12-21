//
//  FileParser.m
//  SampleBufferDisplay
//
//  Created by birneysky on 15/12/21.
//  Copyright © 2015年 com.v2tech. All rights reserved.
//

#import "VideoFileParser.h"

@interface VideoPacket ()

@end

@implementation VideoPacket



@end


@interface VideoFileParser ()

@property (nonatomic,strong) NSFileHandle* fileHandeler;

@property (nonatomic,strong) NSInputStream* fileStream;

@end

const uint8_t KStartCode[4] = {0, 0, 0, 1};

@implementation VideoFileParser

-(void)open:(NSString*)fileName
{
    self.fileHandeler = [NSFileHandle fileHandleForReadingAtPath:fileName];
    //NSData* data = [fileHandle readDataToEndOfFile];
    //self.fileStream = [NSInputStream inputStreamWithFileAtPath:fileName];
}

-(VideoPacket *)nextPacket
{
    unsigned long long curOffset = 0;
    unsigned long long endOffset = [self.fileHandeler seekToEndOfFile];
    unsigned long long prevStartOffet = 0;
    while (curOffset < endOffset) {
        [self.fileHandeler seekToFileOffset:curOffset];
        NSData* tempData = [self.fileHandeler readDataOfLength:4];
        if (0 == memcmp(tempData.bytes, KStartCode, 4)) {
            DebugLog(@"temp Data %@",tempData);
            [self.fileHandeler seekToFileOffset:prevStartOffet];
            
            prevStartOffet = curOffset;
        }
        curOffset ++;
    }
    
    return nil;
}


-(void)close
{
    
}


@end
