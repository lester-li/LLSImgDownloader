//
//  LLSImgCache.m
//  LLSImageDownloader
//
//  Created by 李小帅 on 2019/5/7.
//  Copyright © 2019年 美好午后. All rights reserved.
//

#import "LLSImgCache.h"
#import "NSString+md5.h"
#import "LLSCachedImg.h"

@interface LLSImgCache ()<NSCopying>

//@property (nonatomic,strong) NSCache *caches;
@property (nonatomic,strong) NSMutableDictionary *caches;
@property (nonatomic,strong) dispatch_queue_t ioQueue;
@property (nonatomic,assign) CGFloat totalCacheStandard;

@end

#define DEFAULT_MANAGER [NSFileManager defaultManager]

@implementation LLSImgCache

#pragma mark -- init
LLSImgCache *singleInstance = nil;
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleInstance = [[super allocWithZone:zone] init];
    });
    return singleInstance;
}

-(id)copyWithZone:(NSZone *)zone{
    return [[self class]allocWithZone:zone];
}

+(instancetype)shareIntance{
    return [self alloc];
}

#pragma mark -- access method
- (NSMutableDictionary *)caches{
    if (!_caches){
        _caches = [NSMutableDictionary new];
    }
    return _caches;
}

- (dispatch_queue_t)ioQueue{
    if (!_ioQueue){
        _ioQueue = dispatch_queue_create("llsimgcacheioqueue", DISPATCH_QUEUE_SERIAL);
    }
    return _ioQueue;
}

-(CGFloat)totalCacheStandard{
    if (!_totalCacheStandard) {
        _totalCacheStandard = 1024 * 1024 * 5;
    }
    return _totalCacheStandard;
}


#pragma mark -- public
-(void)saveImgWithUrlKey:(NSString*)urlKey img:(UIImage*)img imgData:(NSData*)imgData isSaveToDisk:(BOOL)isSaveToDisk{
    LLSCachedImg *localImg = [self.caches objectForKey:urlKey];
    if (!localImg) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(_ioQueue, ^{
            typeof(self) strongSelf = weakSelf;
            // 加入缓存
            LLSCachedImg *cachedImg = [[LLSCachedImg alloc]initWithImg:img identifier:urlKey];
            [strongSelf.caches setObject:cachedImg forKey:urlKey];
            
            // 内存缓存策略：FIFO
            //        步骤 ： 1.创建移除数组，缓存排序
            //        2.判断是否需要移除
            //        3.不需要移除，结束l
            //        4.需要移除，记录移除元素。更新当前缓存大小
            //        5.清空移除内存
            NSMutableArray *deleteArray = [NSMutableArray array];
            NSMutableArray *cacheArray = [[strongSelf.caches allValues]mutableCopy];
            NSSortDescriptor *dateAscendingSort = [[NSSortDescriptor alloc]initWithKey:@"date" ascending:YES];
            [cacheArray sortUsingDescriptors:@[dateAscendingSort]];
            
            __block double currTotalSize = 0;
            [cacheArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                LLSCachedImg *img = (LLSCachedImg*)obj;
                currTotalSize += img.totalBytes;
            }];
            while (currTotalSize > strongSelf.totalCacheStandard) {
                LLSCachedImg *deleteCacheImg = cacheArray[0];
                [deleteArray addObject:deleteCacheImg];
                [cacheArray removeObject:deleteCacheImg];
                currTotalSize -= deleteCacheImg.totalBytes;
            }
            
            for (LLSCachedImg *deleteCachedImg in deleteArray) {
                [strongSelf.caches removeObjectForKey:deleteCachedImg.identifier];
            }
        });
    }
    
    if (isSaveToDisk) {
        dispatch_async(_ioQueue, ^{
            if (![DEFAULT_MANAGER fileExistsAtPath:[self p_fileLocationWithUrlKey:urlKey]]) {
                dispatch_async(self.ioQueue, ^{
                    [DEFAULT_MANAGER createFileAtPath:[self p_fileLocationWithUrlKey:urlKey] contents:imgData attributes:nil];
                    if ([DEFAULT_MANAGER fileExistsAtPath:[self p_fileLocationWithUrlKey:urlKey]]) {
                        NSLog(@"cache success");
                    }
                });
            }
        });
    }
}

-(BOOL)selectImgWithUrlKey:(NSString*)urlKey completedBlock:(CacheCompletedBlock)completedBlock{
    BOOL isContainCache = NO;
    LLSCachedImg *cachedImg = [self.caches objectForKey:urlKey];
    UIImage *localImg = cachedImg.img;
    if (localImg) {
        isContainCache = YES;
        if (completedBlock) {
            completedBlock(localImg);
        }
    }else{
        if ([DEFAULT_MANAGER fileExistsAtPath:[self p_fileLocationWithUrlKey:urlKey]]) {
            isContainCache = YES;
            if (completedBlock) {
                NSData *imgData = [NSData dataWithContentsOfFile:[self p_fileLocationWithUrlKey:urlKey]];
                localImg = [UIImage imageWithData:imgData];
                completedBlock(localImg);
            }
        }else{
            if (completedBlock) {
                completedBlock(localImg);
            }
        }
    }
    return isContainCache;
}

-(void)clearDiskOnSuccessBlock:(ClearSuccessBlock)successBlock{
    dispatch_async(self.ioQueue, ^{
        // 获取全部缓存资源
        // 拿出时间与自定义时间比较，符合要求的放到deleteArray中，清空元素
        NSURL *fileUrl = [NSURL fileURLWithPath:[self p_cachePath] isDirectory:YES];
        NSArray *resourceKeys = @[NSURLIsDirectoryKey,NSURLContentModificationDateKey];
        NSDirectoryEnumerator *dicEnumerator = [DEFAULT_MANAGER enumeratorAtURL:fileUrl includingPropertiesForKeys:resourceKeys options:(NSDirectoryEnumerationSkipsHiddenFiles) errorHandler:nil];
        NSMutableArray *deleteArray = [NSMutableArray array];
        
        NSDate *stdDate = [NSDate dateWithTimeIntervalSinceNow:-7*24*60*60];
        for (NSURL *fileUrl in dicEnumerator) {
            NSDictionary *dataDic = [fileUrl resourceValuesForKeys:resourceKeys error:nil];
            if (dataDic[NSURLIsDirectoryKey]) {
                continue;
            }
            NSDate *modiDate = dataDic[NSURLContentModificationDateKey];
            if ([[stdDate laterDate:modiDate] isEqual:stdDate]) {
                [deleteArray addObject:fileUrl];
            }
        }
        for (NSURL *deleteUrl in deleteArray) {
            [DEFAULT_MANAGER removeItemAtURL:deleteUrl error:nil];
        }
        if (successBlock) {
            successBlock();
        }
    });
}



#pragma mark -- private
-(NSString*)p_cachePath{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    cachePath = [NSString stringWithFormat:@"%@%@",cachePath,@"/LLSImgCache"];
    return cachePath;
}

-(NSString*)p_fileLocationWithUrlKey:(NSString*)urlKey{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[self p_cachePath],[NSString md5:urlKey]];
    return filePath;
}



@end
