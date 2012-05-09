/*
 * This work is licensed under the terms of the CC-BY-SA 3.0 License.
 * http://creativecommons.org/licenses/by-sa/3.0/
 */

#import "OKVStore.h"

#pragma mark - Helper definitions & macros
#define kOKVURLStandard     @"http://api.openkeyval.org"
#define kOKVURLSecure       @"https://secure.openkeyval.org"
#define kOKVTimeout         5.0
#define kOKVAllowedKeyChars @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
#define kOKVMinKeySize      5
#define kOKVMaxKeySize      128
#define kOKVMaxPayloadSize  65536L

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

#pragma mark Extension Implementation
- (BOOL)isKeyValid:(NSString *)key
{
    return [key rangeOfCharacterFromSet:keyForbiddenCharset].location == NSNotFound; 
}

- (NSData *)httpGetPath:(NSString *)path
{
    NSURL *url = [NSURL URLWithString:path relativeToURL:self.storeUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:kOKVTimeout];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    //@todo: Handle error if it occurs
    return responseData;
}

- (NSData *)httpPost:(NSDictionary *)formData
{
    NSMutableString *postData = [NSMutableString new];
    for (NSString *key in formData) {
        if ([postData length] > 0)
            [postData appendString:@"&"];
        id value = [formData valueForKey:key];
        NSString *valueString;
        if ([value conformsToProtocol:@protocol(OKVSerializable)])
            valueString = [((id<OKVSerializable>)value) serialize];
        else {
            NSLog(@"Warning: using `description` since class %@ doesn't conform to OKVSerializable", NSStringFromClass([value class]));
            valueString = [value description];
        }

        [postData appendFormat:@"%@=%@", [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                         [valueString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.storeUrl cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:kOKVTimeout];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencodeda; charset=urf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];

    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    //@todo: Handle error if it occurs
    return responseData;
}

@end
