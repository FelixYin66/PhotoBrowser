//
//  ViewController.m
//  PhotoBroswer
//
//  Created by FelixYin on 15/8/5.
//  Copyright © 2015年 felixios. All rights reserved.
//

#import "ViewController.h"
#import "PhotoController.h"

@interface ViewController ()

@end

@implementation ViewController


- (instancetype)init{
  
    self = [super init];
    
    //添加子控制器
    PhotoController *pVC = [[PhotoController alloc] init];
    
    //设置navi的title
    
    pVC.title = @"图片浏览器";
    
    [self addChildViewController:pVC];
    
    return self;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
