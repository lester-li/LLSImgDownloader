//
//  ViewController.m
//  LLSImageDownloader
//
//  Created by 李小帅 on 2019/5/6.
//  Copyright © 2019年 美好午后. All rights reserved.
//

#import "ViewController.h"
#import "Header.h"
#import "LLSHeader.h"

#define imgURL @"http://img95.699pic.com/photo/50017/4600.jpg_wh300.jpg"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, 200, 200)];
    [self.view addSubview:imgView];
    imgView.backgroundColor = [UIColor greenColor];
    [imgView lls_setImageWithUrlKey:imgURL];
    
    UIImageView *imgView1 = [[UIImageView alloc]initWithFrame:CGRectMake(20, 250, 200, 200)];
    [self.view addSubview:imgView1];
    imgView1.backgroundColor = [UIColor redColor];
}


@end
