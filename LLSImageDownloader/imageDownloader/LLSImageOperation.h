//
//  LLSImageOperation.h
//  LLSImageDownloader
//
//  Created by 李小帅 on 2019/5/6.
//  Copyright © 2019年 美好午后. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^DownloadProcessBlock)(NSInteger currentSize,NSInteger totalSize);
typedef void(^CompletionBlock)(NSData *data, UIImage *image, NSError *error);

NS_ASSUME_NONNULL_BEGIN

@interface LLSImageOperation : NSOperation

-(instancetype)initWithUrl:(NSString*)url downloadProcess:(DownloadProcessBlock)downloadProcessBlock completionBlock:(CompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
