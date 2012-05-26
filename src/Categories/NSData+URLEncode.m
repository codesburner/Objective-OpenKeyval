/*
 * This work is licensed under the terms of the CC-BY-SA 3.0 License.
 * http://creativecommons.org/licenses/by-sa/3.0/
 */

#import "NSData+URLEncode.h"

#define IsUrlSafe(CHAR)                                     \
                           ((CHAR) >= '0' && (CHAR) <= '9') \
                        || ((CHAR) >= 'a' && (CHAR) <= 'z') \
                        || ((CHAR) >= 'A' && (CHAR) <= 'Z')

@implementation NSData (URLEncode)

- (NSString *)urlEncode
{
    NSMutableString *urlEncoded = [NSMutableString new];
    const char* bytes = self.bytes;
    for (int i=0 ; i<self.length ; i++) {
        const char byte = bytes[i];
        if (IsUrlSafe(byte)) {
            [urlEncoded appendFormat:@"%c", byte];
        } else {
            [urlEncoded appendFormat:@"%%%02x", byte];
        }
    }
    return urlEncoded;
}

@end
