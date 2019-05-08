//
//  LLSImageDownloder.m
//  LLSImageDownloader
//
//  Created by 李小帅 on 2019/5/6.
//  Copyright © 2019年 美好午后. All rights reserved.
//

#import "LLSImageDownloder.h"
#import "LLSImageOperation.h"

typedef void(^CreateTaskBlock)(void);

@interface LLSImageDownloder() <NSCopying>

@property (nonatomic,strong) NSOperationQueue *imgQueue;

// 以url为key，对应的所有回调为值，建立映射关系
@property (nonatomic,strong) NSMutableDictionary *downloaderCallBacks;

@end

@implementation LLSImageDownloder

NSString * const processBlockName = @"process";
NSString * const completionBlockName = @"completion";

#pragma mark -- init
LLSImageDownloder *imageDownloader = nil;
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageDownloader = [[super allocWithZone:zone]init];
    });
    return imageDownloader;
}

+ (instancetype)shareInstance{
    return [self allocWithZone:NULL];
}

- (id)copyWithZone:(nullable NSZone *)zone{
    LLSImageDownloder *copyOne = [[self class] allocWithZone:NULL];
    return copyOne;
}

#pragma mark -- access method
// 管理所有下载任务
-(NSOperationQueue *)imgQueue{
    if (!_imgQueue) {
        _imgQueue = [[NSOperationQueue alloc]init];
    }
    return _imgQueue;
}

-(NSMutableDictionary *)downloaderCallBacks{
    if (!_downloaderCallBacks) {
        _downloaderCallBacks = [NSMutableDictionary dictionary];
    }
    return _downloaderCallBacks;
}

#pragma mark -- public
-(void)downloadImageWithUrl:(NSString*)url downloadProcessBlock:(DownloadProcessBlock)downloadProcessBlock completionBlock:(CompletionBlock)completionBlock{
    // 记录该任务对应的所有回调
    // 创建一个任务，并监听其过程和结果的回调
    [self p_addTaskWithUrl:url processBlock:downloadProcessBlock completionBlock:completionBlock createTaskBlock:^{
        LLSImageOperation *ope = [[LLSImageOperation alloc] initWithUrl:url downloadProcess:^(NSInteger currentSize, NSInteger totalSize) {
//            同步获取内容 在并发队列中，对集合的操作尽量使用栅栏
            __block NSArray *array = nil;
            dispatch_barrier_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                array = self.downloaderCallBacks[url];
            });
            for (NSDictionary *dic in array) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    DownloadProcessBlock processB = dic[processBlockName];
                    processB(currentSize,totalSize);
                });
            }
        } completionBlock:^(NSData *data, UIImage *image, NSError *error) {
            __block NSArray *array = nil;
            dispatch_barrier_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                array = self.downloaderCallBacks[url];
            });
            for (NSDictionary *dic in array) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    CompletionBlock completionB = dic[completionBlockName];
                    completionB(data,image,error);
                });
            }
        }];
        [self.imgQueue addOperation:ope];
    }];
}

#pragma mark -- private
// 添加下载完成回调
// 添加任务（任务唯一性校验）
- (void)p_addTaskWithUrl:(NSString*)url processBlock:(DownloadProcessBlock)processB completionBlock:(CompletionBlock)completionB createTaskBlock:(CreateTaskBlock)createTaskB{
    BOOL isFirstDownload = NO;
    if (!self.downloaderCallBacks[url]) {
        [self.downloaderCallBacks setObject:[NSMutableArray array] forKey:url];
        isFirstDownload = YES;
    }
    
// 添加回调
    NSMutableArray *callBacks = self.downloaderCallBacks[url];
    NSMutableDictionary *addedDic = [NSMutableDictionary dictionary];
    [addedDic setObject:processB forKey:processBlockName];
    [addedDic setObject:completionB forKey:completionBlockName];
    [callBacks addObject:addedDic];
    
    if (isFirstDownload) {
        createTaskB();
    }
}



@end
