/*
 * This work is licensed under the terms of the CC-BY-SA 3.0 License.
 * http://creativecommons.org/licenses/by-sa/3.0/
 */

#import <Foundation/Foundation.h>
#import <unistd.h>
#import <Objective-OpenKeyval/Objective-OpenKeyval.h>

int main(void)
{
    @autoreleasepool {
        OKVStore *store = [OKVStore standardStore];
        NSString *testKey = (NSString *)[store getItemAtKey:@"testKey" ofClass:[NSString class]];
        NSLog(@"Value of testKey: %@", testKey);
        
        NSString *nonExistentKey = @"thatKeyDoesNotExist";
        
        BOOL data = [store deleteKey:nonExistentKey];
        NSLog(@"Value of thatKeyDoesNotExist: %@", data ? @"YES" : @"NO");
        
        [store putItem:testKey atKey:nonExistentKey];
        data = [store deleteKey:nonExistentKey];
        NSLog(@"Value of thatKeyDoesNotExist: %@", data ? @"YES" : @"NO");
    }
    exit(EXIT_SUCCESS);
}
