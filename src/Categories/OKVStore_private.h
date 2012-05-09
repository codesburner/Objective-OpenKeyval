/*
 * This work is licensed under the terms of the CC-BY-SA 3.0 License.
 * http://creativecommons.org/licenses/by-sa/3.0/
 */

#import "OKVStore.h"

@interface OKVStore ()

- (NSData *)httpGetPath:(NSString *)path;
- (NSData *)httpPost:(NSDictionary *)formData;

@end