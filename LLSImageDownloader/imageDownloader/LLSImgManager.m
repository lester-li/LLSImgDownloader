//
//  LLSImgManager.m
//  LLSImageDownloader
//
//  Created by 李小帅 on 2019/5/7.
//  Copyright © 2019年 美好午后. All rights reserved.
//

#import "LLSImgManager.h"
#import "LLSImgCache.h"
#import "LLSImageDownloder.h"

@interface LLSImgManager ()<NSCopying>

@end

@implementation LLSImgManager

#pragma mark -- init
static LLSImgManager *singleInstance = nil;
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleInstance = [[super allocWithZone:zone] init];
    });
    return singleInstance;
}

-(id)copyWithZone:(NSZone *)zone{
    LLSImgManager *copyIntance = [[self class]allocWithZone:zone];
    return copyIntance;
}

+(instancetype)shareIntance{
    return [self alloc];
}

#pragma mark -- public
// 在缓存中查找，如果没有进行网络请求，并缓存
- (void)downloadWithUrlKey:(NSString*)urlKey processBlock:(ProcessBlock)processBlock completedBlock:(CompletedBlock)completedBlock{
    [[LLSImgCache shareIntance]selectImgWithUrlKey:urlKey completedBlock:^(UIImage * img) {
        if (img) {
            if (completedBlock) {
                NSData *imgData = UIImageJPEGRepresentation(img, 1.0);
                completedBlock(imgData,img,nil);
            }
        }else{
            [[LLSImageDownloder shareInstance] downloadImageWithUrl:urlKey downloadProcessBlock:^(NSInteger currentSize, NSInteger totalSize) {
                NSLog(@"dowloading %ld %ld",(long)currentSize,(long)totalSize);
            } completionBlock:^(NSData * _Nonnull data, UIImage * _Nonnull image, NSError * _Nonnull error) {
                if (completedBlock) {
                    completedBlock(data,image,error);
//                    缓存图片
                    [[LLSImgCache shareIntance]saveImgWithUrlKey:urlKey img:image imgData:data isSaveToDisk:YES];
                }
            }];
        }
    }];
}

@end
