//
//  LLSCachedImg.m
//  LLSImageDownloader
//
//  Created by 李小帅 on 2019/5/9.
//  Copyright © 2019年 美好午后. All rights reserved.
//

#import "LLSCachedImg.h"

@implementation LLSCachedImg

#pragma mark -- init
-(instancetype)init{
    return [self initWithImg:nil identifier:@"default"];
}

-(instancetype)initWithImg:(UIImage* _Nullable)img identifier:(NSString*)identifier{
    self = [super init];
    if (self) {
        _identifier = identifier;
        if (img) {
            _img = img;
            _date = [NSDate date];
            _totalBytes = (UInt64)UIImageJPEGRepresentation(img, 1.0);
        }
    }
    return self;
}

#pragma mark -- access method
-(void)setImg:(UIImage *)img{
    if (img) {
        _img = img;
        _date = [NSDate date];
        _totalBytes = (UInt64)UIImageJPEGRepresentation(img, 1.0);
    }
}

@end
