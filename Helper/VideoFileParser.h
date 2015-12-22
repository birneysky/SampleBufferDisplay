//
//  FileParser.h
//  SampleBufferDisplay
//
//  Created by birneysky on 15/12/21.
//  Copyright © 2015年 com.v2tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoPacket : NSObject

@property (readonly) NSData* data;

@end

@interface VideoFileParser : NSObject

-(void)open:(NSString*)fileName;
-(VideoPacket *)nextPacket;
-(void)close;

@end
