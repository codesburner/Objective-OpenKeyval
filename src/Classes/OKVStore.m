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
    NSData *data = [self httpPost:@"" toPath:key];
    NSDictionary *jsonData = [[JSONDecoder new] objectWithData:data];
    return [[jsonData valueForKey:@"status"] isEqualToString:@"removed"];
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

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:storeURL 
                                                           cachePolicy:NSURLCacheStorageNotAllowed 
                                                       timeoutInterval:kOKVTimeout];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=urf-8" forHTTPHeaderField:@"Content-Type"];
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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path relativeToURL:storeURL] 
                                                           cachePolicy:NSURLCacheStorageNotAllowed 
                                                       timeoutInterval:kOKVTimeout];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=urf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[stringWithFormat(@"data=%@", [data serialize]) dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request 
                                                 returningResponse:&response 
                                                             error:&error];
    if (error != nil)
        @throw transportErrorException(error);
    
    if (response.statusCode != 200)
        @throw serverErrorException(response, responseData);
    
    return responseData;
}

@end
