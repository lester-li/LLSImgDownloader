//
//  UIImageView+LLSImageSetting.m
//  LLSImageDownloader
//
//  Created by 李小帅 on 2019/5/8.
//  Copyright © 2019年 美好午后. All rights reserved.
//

#import "UIImageView+LLSImageSetting.h"
#import "LLSImgManager.h"

@implementation UIImageView (LLSImageSetting)

-(void)lls_setImageWithUrlKey:(NSString*)urlKey{
    __weak typeof(self) weakSelf = self;
    [[LLSImgManager shareIntance] downloadWithUrlKey:urlKey processBlock:^(NSInteger currentSize, NSInteger totalSize) {
    } completedBlock:^(NSData *imgData, UIImage *img, NSError *error) {
        if (!error) {
            weakSelf.image = img;
        }
    }];
}

@end
