/*
 * This work is licensed under the terms of the CC-BY-SA 3.0 License.
 * http://creativecommons.org/licenses/by-sa/3.0/
 */

#import <Foundation/Foundation.h>

/**
 * This protocol allows an OKVStore instance to handle arbitrary objects both
 * for storing and reading.
 */
@protocol OKVSerializable <NSObject>
/**
 * Creates an NSString representation of the current object that can
 * later be parsed using deserialize:.
 * @return An UTF-8 encoded NSString.
 */
- (NSString *)serialize;

/**
 * Parses an NSString into an instance of the current class.
 * @param string An UTF-8 encoded string, that was probably generated using serialize.
 * @return An instance of the current class.
 */
+ (id)deserialize:(NSString *)string;
@end
