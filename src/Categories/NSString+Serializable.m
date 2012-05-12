//
//  NSString+Serializable.m
//  Objective-OpenKeyval
//
//  Created by Romain Muller on 12/05/12.
//  Copyright (c) 2012 Romain Muller. All rights reserved.
//

#import "NSString+Serializable.h"

@implementation NSString (Serializable)

- (NSString *)serialize
{
    return self;
}

+ (NSString *)deserialize:(NSString *)string
{
    return string;
}

@end
