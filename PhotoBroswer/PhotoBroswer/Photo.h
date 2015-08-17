//
//  Photo.h
//  PhotoBroswer
//
//  Created by FelixYin on 15/8/5.
//  Copyright © 2015年 felixios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Photo : NSObject

@property (nonatomic,copy)NSString *photoid;

@property (nonatomic,strong)NSURL *smallphotourl;

@property (nonatomic,strong)NSURL  *largephotourl;


+ (void)loadPhoto:(NSString *)maxid andBack:(void(^)(NSArray * pArray)) finished;


@end
