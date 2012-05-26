/*
 * This work is licensed under the terms of the CC-BY-SA 3.0 License.
 * http://creativecommons.org/licenses/by-sa/3.0/
 */

#import "OKVConnectionHelper.h"
#import "OKVExceptions.h"

OKVConnectionCallback OKVSimpleConnectionCallback(OKVDataCallback dataCallback)
{
    OKVConnectionCallback callbackBlock = ^(NSURLResponse *response, NSData *data, NSError *error){
        if (error != nil)
            @throw transportErrorException(error);
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 200 && httpResponse.statusCode != 404)
            @throw serverErrorException(httpResponse, data);
        if(dataCallback != nil)
            dataCallback(httpResponse.statusCode, data);
    };
    return [callbackBlock copy];
}

@implementation OKVConnectionHelper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (void)sendRequestToURL:(NSURL *)url 
              withMethod:(NSString *)method 
                 timeOut:(NSTimeInterval)timeOut 
             synchronous:(BOOL)synchronous 
                callback:(OKVConnectionCallback)block
{
    [self sendRequestToURL:url 
                withMethod:method
               requestBody:nil
               contentType:nil
                   timeOut:timeOut
               synchronous:synchronous
                  callback:block];
}

+ (void)sendRequestToURL:(NSURL *)url 
              withMethod:(NSString *)method 
              bodyString:(NSString *)bodyString
             contentType:(NSString *)contentType
                 timeOut:(NSTimeInterval)timeOut 
             synchronous:(BOOL)synchronous 
                callback:(OKVConnectionCallback)block
{
    [self sendRequestToURL:url 
                withMethod:method
               requestBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]
               contentType:contentType
                   timeOut:timeOut
               synchronous:synchronous
                  callback:block];
}

+ (void)sendRequestToURL:(NSURL *)url 
              withMethod:(NSString *)method 
             requestBody:(NSData *)requestBody 
             contentType:(NSString *)contentType 
                 timeOut:(NSTimeInterval)timeOut 
             synchronous:(BOOL)synchronous 
                callback:(OKVConnectionCallback)block
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url 
                                                           cachePolicy:NSURLCacheStorageNotAllowed 
                                                       timeoutInterval:timeOut];
    request.HTTPMethod = method;
    if (requestBody != nil)
        request.HTTPBody = requestBody;
    if (contentType != nil)
        [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    
    if (synchronous) {
        NSData * responseData = [NSURLConnection sendSynchronousRequest:request 
                                                      returningResponse:&response 
                                                                  error:&error];
        block(response, responseData, error);
    } else {
        [NSURLConnection sendAsynchronousRequest:request queue:nil completionHandler:block];
    }
}

@end
