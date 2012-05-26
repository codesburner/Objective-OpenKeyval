/*
 * This work is licensed under the terms of the CC-BY-SA 3.0 License.
 * http://creativecommons.org/licenses/by-sa/3.0/
 */

#import "NSData+Serializable.h"

@implementation NSData (Serializable)

- (NSData *)serialize
{
    return [NSData dataWithData:self];
}

+ (id<OKVSerializable>)deserialize:(NSData *)data
{
    return [NSData dataWithData:data];
}

@end
