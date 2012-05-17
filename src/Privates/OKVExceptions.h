/*
 * This work is licensed under the terms of the CC-BY-SA 3.0 License.
 * http://creativecommons.org/licenses/by-sa/3.0/
 */

#import "OKVStore.h"

#pragma mark - Exception Factories
inline NSException *invalidKeyException(NSString *key, OKVStore *store, NSString *detail);
inline NSException *transportErrorException(NSError *rootCause);
inline NSException *serverErrorException(NSHTTPURLResponse *response, NSData *responseData);