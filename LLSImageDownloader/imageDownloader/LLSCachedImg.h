//
//  LLSCachedImg.h
//  LLSImageDownloader
//
//  Created by 李小帅 on 2019/5/9.
//  Copyright © 2019年 美好午后. All rights reserved.
//

//记录图片的大小和访问时间的简单封装

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LLSCachedImg : NSObject

@property (nonatomic,strong) UIImage *img;
@property (nonatomic,assign) UInt64 totalBytes;
@property (nonatomic,strong) NSDate *date;
@property (nonatomic,copy) NSString *identifier;

-(instancetype)initWithImg:(UIImage* _Nullable)img identifier:(NSString*)identifier NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
