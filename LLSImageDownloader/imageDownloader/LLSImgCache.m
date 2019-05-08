//
//  LLSImgCache.m
//  LLSImageDownloader
//
//  Created by 李小帅 on 2019/5/7.
//  Copyright © 2019年 美好午后. All rights reserved.
//

#import "LLSImgCache.h"
#import "NSString+md5.h"

@interface LLSImgCache ()<NSCopying>

@property (nonatomic,strong) NSCache *caches;
@property (nonatomic,strong) dispatch_queue_t ioQueue;

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
- (NSCache *)caches{
    if (!_caches){
        _caches = [NSCache new];
    }
    return _caches;
}

- (dispatch_queue_t)ioQueue{
    if (!_ioQueue){
        _ioQueue = dispatch_queue_create("llsimgcacheioqueue", DISPATCH_QUEUE_SERIAL);
    }
    return _ioQueue;
}


#pragma mark -- public
-(void)saveImgWithUrlKey:(NSString*)urlKey img:(UIImage*)img imgData:(NSData*)imgData isSaveToDisk:(BOOL)isSaveToDisk{
    UIImage *localImg = [self.caches objectForKey:urlKey];
    if (!localImg) {
        [_caches setObject:img forKey:urlKey];
    }
    
    if (isSaveToDisk) {
        if (![DEFAULT_MANAGER fileExistsAtPath:[self p_fileLocationWithUrlKey:urlKey]]) {
            dispatch_async(self.ioQueue, ^{
                [DEFAULT_MANAGER createFileAtPath:[self p_fileLocationWithUrlKey:urlKey] contents:imgData attributes:nil];
                NSLog(@"cache path is %@",[self p_fileLocationWithUrlKey:urlKey]);
                if ([DEFAULT_MANAGER fileExistsAtPath:[self p_fileLocationWithUrlKey:urlKey]]) {
                    NSLog(@"cache success");
                }
            });
        }
    }
}

-(BOOL)selectImgWithUrlKey:(NSString*)urlKey completedBlock:(CacheCompletedBlock)completedBlock{
    BOOL isContainCache = NO;
    UIImage *localImg = [self.caches objectForKey:urlKey];
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
