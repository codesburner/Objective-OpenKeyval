/*
 * This work is licensed under the terms of the CC-BY-SA 3.0 License.
 * http://creativecommons.org/licenses/by-sa/3.0/
 */

#import "OKVSerializable.h"

#pragma mark - Helper definitions / macros
typedef void (^OKVCallback)(
    NSString *key,
    id<OKVSerializable> value,
    NSError *error
);

#pragma mark - Key-Value Store interface
@interface OKVStore : NSObject
#pragma mark Initializers
+ (OKVStore *)standardStore;
+ (OKVStore *)secureStore;
- (OKVStore *)initWithURL:(NSString *)url;

#pragma mark Reading
- (NSData*)getItemAtKey:(NSString *)key;

@end
