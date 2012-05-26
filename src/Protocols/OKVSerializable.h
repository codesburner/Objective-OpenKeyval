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
 * Creates an NSData representation of the current object that can
 * later be parsed using deserialize:.
 * @return A blob of binary data.
 */
- (NSData *)serialize;

/**
 * Parses an NSData into an instance of the current class.
 * @param data A binary blob of data that was probably generated using serialize.
 * @return An instance of the current class.
 */
+ (id<OKVSerializable>)deserialize:(NSData *)data;
@end
