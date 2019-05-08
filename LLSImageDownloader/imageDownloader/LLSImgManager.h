//
//  LLSImgManager.h
//  LLSImageDownloader
//
//  Created by 李小帅 on 2019/5/7.
//  Copyright © 2019年 美好午后. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^CompletedBlock)(NSData *imgData,UIImage *img,NSError *error);
typedef void(^ProcessBlock)(NSInteger currentSize,NSInteger totalSize);

NS_ASSUME_NONNULL_BEGIN

@interface LLSImgManager : NSObject

+(instancetype)shareIntance;

- (void)downloadWithUrlKey:(NSString*)urlKey processBlock:(ProcessBlock)processBlock completedBlock:(CompletedBlock)completedBlock;

@end

NS_ASSUME_NONNULL_END
