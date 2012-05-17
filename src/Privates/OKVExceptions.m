/*
 * This work is licensed under the terms of the CC-BY-SA 3.0 License.
 * http://creativecommons.org/licenses/by-sa/3.0/
 */

#include "OKVExceptions.h"

#pragma mark - Exception Names
NSString * const OKVInvalidKeyException = @"InvalidKeyException";
NSString * const OKVTransportError      = @"TransportError";
NSString * const OKVServerError         = @"ServerError";

#pragma mark - Exception Factories
NSException *invalidKeyException(NSString *key, OKVStore *store, NSString *detail)
{
    return [NSException exceptionWithName:OKVInvalidKeyException 
                                   reason:detail 
                                 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:key, "OKVKey", store, NSStringFromClass([store class]), nil]];
}

NSException *transportErrorException(NSError *rootCause)
{
    return [NSException exceptionWithName:OKVTransportError
                                   reason:rootCause.description
                                 userInfo:[NSDictionary dictionaryWithObject:rootCause forKey:NSStringFromClass([NSException class])]];
}

NSException *serverErrorException(NSHTTPURLResponse *response, NSData *responseData)
{
    return [NSException exceptionWithName:OKVServerError
                                   reason:stringWithFormat(@"Server returned HTTP %i", response.statusCode)
                                 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:response, NSStringFromClass([NSHTTPURLResponse class]), responseData, NSStringFromClass([NSData class]), nil]];
}