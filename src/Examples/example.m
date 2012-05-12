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
        NSData *data = [store getItemAtKey:@"testKey"];
        NSLog(@"%@", [NSString stringWithUTF8String:data.bytes]);
    }
    exit(EXIT_SUCCESS);
}
