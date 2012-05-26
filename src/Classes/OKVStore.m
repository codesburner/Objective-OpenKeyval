/*
 * This work is licensed under the terms of the CC-BY-SA 3.0 License.
 * http://creativecommons.org/licenses/by-sa/3.0/
 */

#import "OKVStore.h"
#import "JSONKit.h"

#pragma mark - Helper definitions & macros
#define kOKVURLStandard     @"http://api.openkeyval.org"
#define kOKVURLSecure       @"https://secure.openkeyval.org"
#define kOKVTimeout         5.0
#define kOKVAllowedKeyChars @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
#define kOKVMinKeySize      5
#define kOKVMaxKeySize      128
#define kOKVMaxPayloadSize  65536L
#define kOKVContentType     @"application/x-www-form-urlencoded; charset=utf-8"

#pragma mark - Static functions

#pragma mark - Implementation
@implementation OKVStore
#pragma mark Initializers
+ (OKVStore *)standardStore
{
    return [[OKVStore alloc] initWithURL:kOKVURLStandard];
}

+ (OKVStore *)secureStore
{
    return [[OKVStore alloc] initWithURL:kOKVURLSecure];
}

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (OKVStore *)initWithURL:(NSString *)url
{
    if ((self = [super init])) {
        storeURL = [NSURL URLWithString:url];
        NSCharacterSet *keyValidCharset = [NSCharacterSet characterSetWithCharactersInString:kOKVAllowedKeyChars];
        keyForbiddenCharset = [keyValidCharset invertedSet];
    }
    return self;
}

#pragma mark Data Accessors
- (NSData *)getItemAtKey:(NSString *)key
{
    [self assertKeyIsValid:key];
    
    __block NSData *result;
    OKVDataCallback block = ^(int statusCode, NSData *data) {
        if (statusCode == 200)
            result = data;
        else
            result = nil;
    };
    
    [OKVConnectionHelper sendRequestToURL:[NSURL URLWithString:key relativeToURL:storeURL]
                               withMethod:@"GET"
                                  timeOut:kOKVTimeout
                              synchronous:YES
                                 callback:OKVSimpleConnectionCallback(block)];
        
    return result;
}

- (id<OKVSerializable>)getItemAtKey:(NSString *)key ofClass:(Class<OKVSerializable>)class
{
    NSData *rawData = [self getItemAtKey:key];
    if (rawData == nil)
        return nil;
    else
        return [class deserialize:rawData];
}

- (BOOL)deleteKey:(NSString *)key
{
    [self assertKeyIsValid:key];
    
    __block NSData *result;
    OKVDataCallback block = ^(int statusCode, NSData *data) {
        if (statusCode == 200)
            result = data;
        else
            result = nil;
    };
    [OKVConnectionHelper sendRequestToURL:[NSURL URLWithString:key relativeToURL:storeURL]
                               withMethod:@"POST"
                              requestBody:[@"data=" dataUsingEncoding:NSUTF8StringEncoding]
                              contentType:kOKVContentType
                                  timeOut:kOKVTimeout
                              synchronous:YES
                                 callback:OKVSimpleConnectionCallback(block)];
    NSDictionary *jsonData = [[JSONDecoder new] objectWithData:result];
    return [[jsonData valueForKey:@"status"] isEqualToString:@"deleted"];
}

- (void)putData:(NSData *)data atKey:(NSString *)key
{
    [self assertKeyIsValid:key];

    [OKVConnectionHelper sendRequestToURL:storeURL
                               withMethod:@"POST" 
                               bodyString:stringWithFormat(@"%@=%@", key, [data urlEncode])
                              contentType:kOKVContentType 
                                  timeOut:kOKVTimeout 
                              synchronous:YES 
                                 callback:OKVSimpleConnectionCallback(nil)];
}
}

#pragma mark Extension Implementation
- (void)assertKeyIsValid:(NSString *)key
{
    if (key.length < kOKVMinKeySize)
        @throw invalidKeyException(key, self, stringWithFormat(@"Key \"%@\" should be at least %i characters long.", key, kOKVMinKeySize));
    if (key.length > kOKVMaxKeySize)
        @throw invalidKeyException(key, self, stringWithFormat(@"Key \"%@\" should be at most %i characters long.", key, kOKVMaxKeySize));
    if ([key rangeOfCharacterFromSet:keyForbiddenCharset].location != NSNotFound)
        @throw invalidKeyException(key, self, stringWithFormat(@"Key \"%@\" can only contain characters within \"%@\".", key, kOKVAllowedKeyChars));
}

@end
