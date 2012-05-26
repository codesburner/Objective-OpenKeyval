//
//  NSString+Serializable.m
//  Objective-OpenKeyval
//
//  Created by Romain Muller on 12/05/12.
//  Copyright (c) 2012 Romain Muller. All rights reserved.
//

#import "NSString+Serializable.h"

@implementation NSString (Serializable)

- (NSData *)serialize
{
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)deserialize:(NSData *)data
{
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
