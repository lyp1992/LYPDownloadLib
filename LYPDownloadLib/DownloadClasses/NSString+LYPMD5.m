//
//  NSString+LYPMD5.m
//  LYPDownloadLib
//
//  Created by laiyp on 2018/10/11.
//  Copyright © 2018 laiyongpeng. All rights reserved.
//

#import "NSString+LYPMD5.h"
#import <CommonCrypto/CommonDigest.h>
@implementation NSString (LYPMD5)
-(NSString *)md5Str{
    const char *data = [self UTF8String];
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    // 1. c字符串
    // 2. c字符串长度
    // 3. 结果
    CC_MD5(data, (CC_LONG)strlen(data), result);
    
    // md5 32
    NSMutableString *results = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [results appendFormat:@"%02x", result[i]];
    }
    return results;
}
@end
