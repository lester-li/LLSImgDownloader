//
//  LLSImgCache.h
//  LLSImageDownloader
//
//  Created by 李小帅 on 2019/5/7.
//  Copyright © 2019年 美好午后. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CacheCompletedBlock)(UIImage *img);
typedef void(^ClearSuccessBlock)(void);

@interface LLSImgCache : NSObject

+(instancetype)shareIntance;

-(void)saveImgWithUrlKey:(NSString*)urlKey img:(UIImage*)img imgData:(NSData*)imgData isSaveToDisk:(BOOL)isSaveToDisk;

-(BOOL)selectImgWithUrlKey:(NSString*)urlKey completedBlock:(CacheCompletedBlock)completedBlock;

-(void)clearDiskOnSuccessBlock:(ClearSuccessBlock)successBlock;

@end

NS_ASSUME_NONNULL_END
