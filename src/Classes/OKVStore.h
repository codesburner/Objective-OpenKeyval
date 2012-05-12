/*
 * This work is licensed under the terms of the CC-BY-SA 3.0 License.
 * http://creativecommons.org/licenses/by-sa/3.0/
 */

#import "OKVSerializable.h"

#pragma mark - Helper definitions / macros
extern NSString * const OKVInvalidKeyException;
extern NSString * const OKVTransportError;
extern NSString * const OKVServerError;

#pragma mark - Key-Value Store interface
/**
 * A client for [OpenKeyval](http://openkeyval.org), which is a dead-simple RESTful web-service acting as a key-value store.
 */
@interface OKVStore : NSObject
#pragma mark Initializers
/** @name Initializers */

/**
 * Gets an OKVStore backed by `http://api.openkeyval.org`.
 * @return A new OKVStore.
 * @see initWithURL:
 */
+ (OKVStore *)standardStore;

/**
 * Gets an OKVStore backed by `https://secure.openkeyval.org`.
 * @return A new OKVStore.
 * @see initWithURL:
 */
+ (OKVStore *)secureStore;

/**
 * Initializes an OKVStore with a custom URL.
 * @param url The root URL of the OpenKeyval endpoint.
 * @return A new OKVStore.
 */
- (OKVStore *)initWithURL:(NSString *)url;

#pragma mark Data Accessors
/** @name Data Accessors */

/**
 * Reads data from the store.
 * @param key The key to be read.
 * @return The data that was found for the `key`, or `nil` if the key had no value.
 * @exception OKVInvalidKeyException If the key is invalid.
 * @exception OKVTransportError If a network problem arose. The underlying error can be found in `userInfo` with the key `@"NSError"`.
 * @exception OKVServerError If a server error arose. The actual server response can be found in `userInfo` with they key `@"NSHTTPURLResponse"`.
 */
- (NSData*)getItemAtKey:(NSString *)key;

/**
 * Reads and deserializes data from the store.
 * @param key The key to be read.
 * @param class The OKVSerializable class of the value.
 * @return An instance of `class`, or `nil` if the key had no value.
 * @exception NSException As it would have been thrown by getItemAtKey:
 * @see getItemAtKey:
 */
- (id<OKVSerializable>)getItemAtKey:(NSString *)key ofClass:(Class<OKVSerializable>)class;

@end
