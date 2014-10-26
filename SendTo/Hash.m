#import <Foundation/Foundation.h>

#import <CommonCrypto/CommonDigest.h>

#import "Hash.h"

@implementation Hash

+ (NSString*) SHA1:(NSString*)input {
  unsigned int outputLength = CC_SHA1_DIGEST_LENGTH;
  unsigned char output[outputLength];
  
  CC_SHA1(input.UTF8String, [self UTF8Length:input], output);
  return [self toHexString:output length:outputLength];;
}

+ (unsigned int) UTF8Length:(NSString*)input {
  return (unsigned int) [input lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString*) toHexString:(unsigned char*) data length: (unsigned int) length {
  NSMutableString* hash = [NSMutableString stringWithCapacity:length * 2];
  for (unsigned int i = 0; i < length; i++) {
    [hash appendFormat:@"%02x", data[i]];
    data[i] = 0;
  }
  return hash;
}

@end
