/*
 * This work is licensed under the terms of the CC-BY-SA 3.0 License.
 * http://creativecommons.org/licenses/by-sa/3.0/
 */

#import <Foundation/Foundation.h>

typedef void(^OKVConnectionCallback)(NSURLResponse *response, NSData *data, NSError *error);
typedef void(^OKVDataCallback)(int statusCode, NSData *data);

inline OKVConnectionCallback OKVSimpleConnectionCallback(OKVDataCallback dataCallback);

@interface OKVConnectionHelper : NSObject

+ (void)sendRequestToURL:(NSURL *)url 
              withMethod:(NSString *)method 
                 timeOut:(NSTimeInterval)timeOut 
             synchronous:(BOOL)synchronous 
                callback:(OKVConnectionCallback)block;

+ (void)sendRequestToURL:(NSURL *)url 
              withMethod:(NSString *)method 
             requestBody:(NSData *)requestBody
             contentType:(NSString *)contentType
                 timeOut:(NSTimeInterval)timeOut 
             synchronous:(BOOL)synchronous 
                callback:(OKVConnectionCallback)block;


@end
