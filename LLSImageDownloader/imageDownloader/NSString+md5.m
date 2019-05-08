//
//  NSString+md5.m
//  LLSImageDownloader
//
//  Created by 李小帅 on 2019/5/8.
//  Copyright © 2019年 美好午后. All rights reserved.
//

#import "NSString+md5.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (md5)

+ (NSString *) md5:(NSString *) str{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (int)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
