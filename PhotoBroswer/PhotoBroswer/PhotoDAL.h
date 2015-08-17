//
//  PhotoDAL.h
//  PhotoBroswer
//
//  Created by FelixYin on 15/8/5.
//  Copyright © 2015年 felixios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoDAL : NSObject

+ (void) loadPhoto:(NSString *)maxid adnBack:(void (^)(NSArray * dictArray)) finished;

@end
