/*
 * This work is licensed under the terms of the CC-BY-SA 3.0 License.
 * http://creativecommons.org/licenses/by-sa/3.0/
 */

#import <Foundation/Foundation.h>

@protocol OKVSerializable <NSObject>
- (NSString *)serialize;
+ (id)deserializeString:(NSString *)string;
@end
