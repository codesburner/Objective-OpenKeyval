/*
 * This work is licensed under the terms of the CC-BY-SA 3.0 License.
 * http://creativecommons.org/licenses/by-sa/3.0/
 */

#import "OKVStore.h"

#pragma mark - Helper definitions & macros
#define kOKVURLStandard     @"http://api.openkeyval.org"
#define kOKVURLSecure       @"https://secure.openkeyval.org"
#define kOKVAllowedKeyChars @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
#define kOKVMinKeySize      5
#define kOKVMaxKeySize      128
#pragma mark - Extension
@interface OKVStore ()
@property (readonly) NSURL          *storeUrl;
@property (readonly) NSCharacterSet *keyForbiddenCharset;
- (BOOL)isKeyValid:(NSString *)key;
@end

#pragma mark - Implementation
@implementation OKVStore

#pragma mark Synthetics
@synthesize storeUrl;
@synthesize keyForbiddenCharset;

#pragma mark Initializers
+ (OKVStore *)standardStore
{
    return [[OKVStore alloc] initWithURL:kOKVURLStandard];
}

+ (OKVStore *)secureStore
{
    return [[OKVStore alloc] initWithURL:kOKVURLSecure];
}

- (OKVStore *)initWithURL:(NSString *)url
{
    if ((self = [super init])) {
        storeUrl = [NSURL URLWithString:url];
        NSCharacterSet *keyValidCharset = [NSCharacterSet characterSetWithCharactersInString:kOKVAllowedKeyChars];
        keyForbiddenCharset = [keyValidCharset invertedSet];
    }
    return self;
}

#pragma mark - Extension Implementation
- (BOOL)isKeyValid:(NSString *)key
{
    return [key rangeOfCharacterFromSet:keyForbiddenCharset].location == NSNotFound; 
}

@end
