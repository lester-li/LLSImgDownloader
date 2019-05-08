//
//  LLSImageOperation.m
//  LLSImageDownloader
//
//  Created by 李小帅 on 2019/5/6.
//  Copyright © 2019年 美好午后. All rights reserved.
//

#import "LLSImageOperation.h"

@interface LLSImageOperation()<NSURLSessionDelegate,NSURLSessionDataDelegate>

@property (nonatomic,strong) NSMutableData *imageData;
@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) DownloadProcessBlock downloadProcessB;
@property (nonatomic,copy) CompletionBlock completionB;
@property (nonatomic,assign) NSInteger totalSize;

@end

@implementation LLSImageOperation

#pragma mark -- access method
-(NSMutableData *)imageData{
    if (!_imageData) {
        _imageData = [NSMutableData data];
    }
    return _imageData;
}

#pragma mark -- init
-(instancetype)initWithUrl:(NSString*)url downloadProcess:(DownloadProcessBlock)downloadProcessBlock completionBlock:(CompletionBlock)completionBlock{
    self = [super init];
    if (self) {
        _url = url;
        _downloadProcessB = downloadProcessBlock;
        _completionB = completionBlock;
    }
    return self;
}

#pragma mark -- start
-(void)start{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    NSURL *url = [NSURL URLWithString:self.url];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:(NSURLRequestReloadIgnoringLocalCacheData) timeoutInterval:(30)];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req];
    [dataTask resume];
}

#pragma mark -- session delegate
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    [self.imageData appendData:data];
    if (self.downloadProcessB) {
        self.downloadProcessB(_imageData.length, _totalSize);
    }
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (!error) {
        if (self.completionB) {
            UIImage *image = [UIImage imageWithData:self.imageData];
            self.completionB(self.imageData, image, nil);
        }
    }else{
        if (self.completionB) {
            self.completionB(nil, nil, error);
        }
    }
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    _totalSize = response.expectedContentLength;
    completionHandler(NSURLSessionResponseAllow);
}

@end
