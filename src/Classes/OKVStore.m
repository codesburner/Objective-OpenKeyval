/*
 * This work is licensed under the terms of the CC-BY-SA 3.0 License.
 * http://creativecommons.org/licenses/by-sa/3.0/
 */

#import "OKVStore.h"

#pragma mark - Helper definitions & macros
NSString * const OKVInvalidKeyException = @"InvalidKeyException";
NSString * const OKVTransportError = @"TransportError";
NSString * const OKVServerError = @"ServerError";

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
@end

#pragma mark - Static functions
static inline void assertKeyIsValid(NSString *key, OKVStore *forStore)
{
#define userInfoDict    [NSDictionary dictionaryWithObjectsAndKeys:key, @"OKVKey", forStore, @"OKVStore", nil]
    if (key.length < kOKVMinKeySize)
        @throw [NSException exceptionWithName:OKVInvalidKeyException 
                                       reason:stringWithFormat(@"Key \"%@\" should be at least %i characters long.", key, kOKVMinKeySize)
                                     userInfo:userInfoDict];
    if (key.length > kOKVMaxKeySize)
        @throw [NSException exceptionWithName:OKVInvalidKeyException
                                       reason:stringWithFormat(@"Key \"%@\" should be at most %i characters long.", key, kOKVMaxKeySize) 
                                     userInfo:userInfoDict];
    if ([key rangeOfCharacterFromSet:forStore.keyForbiddenCharset].location != NSNotFound)
        @throw [NSException exceptionWithName:OKVInvalidKeyException 
                                       reason:stringWithFormat(@"Key \"%@\" can only contain characters within \"%@\".", key, kOKVAllowedKeyChars) 
                                     userInfo:userInfoDict];
#undef userInfoDict
}

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

#pragma mark Data Accessors
- (NSData *)getItemAtKey:(NSString *)key
{
    assertKeyIsValid(key, self);
    return [self httpGetPath:key];
}

- (id<OKVSerializable>)getItemAtKey:(NSString *)key ofClass:(Class<OKVSerializable>)class
{
    NSData *rawData = [self getItemAtKey:key];
    if (rawData == nil)
        return nil;
    else
        return [class deserialize:[NSString stringWithUTF8String:rawData.bytes]];
}

- (NSData *)httpGetPath:(NSString *)path
{
    NSURL *url = [NSURL URLWithString:path 
                        relativeToURL:self.storeUrl];
    NSMutableURLRequest *request = [NSURLRequest requestWithURL:url 
                                             cachePolicy:NSURLCacheStorageNotAllowed 
                                         timeoutInterval:kOKVTimeout];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request 
                                                 returningResponse:&response 
                                                             error:&error];
    
    if (error != nil)
        @throw [NSException exceptionWithName:OKVTransportError
                                       reason:error.description
                                     userInfo:[NSDictionary dictionaryWithObject:error forKey:@"NSError"]];
    
    if (response.statusCode == 200)
        return responseData;
    else if (response.statusCode == 404)
        return nil;
    @throw [NSException exceptionWithName:OKVServerError 
                                   reason:stringWithFormat(@"Server responded with HTTP %i.", response.statusCode) 
                                 userInfo:[NSDictionary dictionaryWithObject:response forKey:@"NSHTTPURLResponse"]];
}

- (NSData *)httpPost:(NSDictionary *)formData
{
    NSMutableString *postData = [NSMutableString new];
    for (NSString *key in formData) {
        if ([postData length] > 0)
            [postData appendString:@"&"];
        id value = [formData valueForKey:key];
        if (![value conformsToProtocol:@protocol(OKVSerializable)]) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"Values of the dictionary are expected to conform to OKVSerializable." 
                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:formData, @"NSDictionary", key, @"key", value, @"value", nil]];
        }
        NSString *valueString = [((id<OKVSerializable>)value) serialize];

        [postData appendFormat:@"%@=%@", [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                         [valueString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.storeUrl 
                                                           cachePolicy:NSURLCacheStorageNotAllowed 
                                                       timeoutInterval:kOKVTimeout];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencodeda; charset=urf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request 
                                                 returningResponse:&response 
                                                             error:&error];
    if (error != nil)
        @throw [NSException exceptionWithName:OKVTransportError
                                       reason:error.description
                                     userInfo:[NSDictionary dictionaryWithObject:error forKey:@"NSError"]];

    return responseData;
}

- (NSData *)httpPost:(id<OKVSerializable>)data toPath:(NSString *)path
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path relativeToURL:self.storeUrl] 
                                                           cachePolicy:NSURLCacheStorageNotAllowed 
                                                       timeoutInterval:kOKVTimeout];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencodeda; charset=urf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[stringWithFormat(@"data=%@", [data serialize]) dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request 
                                                 returningResponse:&response 
                                                             error:&error];
    if (error != nil)
        @throw [NSException exceptionWithName:OKVTransportError
                                       reason:error.description
                                     userInfo:[NSDictionary dictionaryWithObject:error forKey:@"NSError"]];
    
    if (response.statusCode != 200)
        @throw [NSException exceptionWithName:OKVServerError 
                                       reason:stringWithFormat(@"Server responded with HTTP %i.", response.statusCode) 
                                     userInfo:[NSDictionary dictionaryWithObject:response forKey:@"NSHTTPURLResponse"]];
    
    return responseData;
}

@end
