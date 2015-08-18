//
//  Photo.m
//  PhotoBroswer
//
//  Created by FelixYin on 15/8/5.
//  Copyright © 2015年 felixios. All rights reserved.
//

#import "Photo.h"
#import "PhotoDAL.h"
#import "UIImageView+WebCache.h"

@implementation Photo

-(instancetype)initWithDict:(NSDictionary *)dict{

    self = [super init];
    
    [self setValuesForKeysWithDictionary:dict];
    
    return self;

}

- (void)setValue:(nullable id)value forKey:(nonnull NSString *)key{
    
    [super setValue:value forKey:key];

    if ([key isEqualToString:@"smallphotourl"]) {
     
        _smallphotourl = [NSURL URLWithString:value];
    
    }
    
    if ([key isEqualToString:@"largephotourl"]) {
        
        _largephotourl = [NSURL URLWithString:value];
    }

}


//控制器获取数据时的请求方法

+ (void)loadPhoto:(NSString *)maxid andMinid:(NSString *)minid resultBack:(void(^)(NSArray * pArray)) finished{
    
    
    [PhotoDAL loadPhoto:maxid andMinid:minid resultBack:^(NSArray *dictArray) {
        
        //解析返回的数据
        
        [self cacheAllImage:dictArray andBack:finished];
        
    }];

}


//缓存图片与解析数据

+ (void)cacheAllImage:(NSArray *) dictArray andBack:(void(^)(NSArray * pArray)) finished{

    //先解析数据
    
    NSArray *array = [self paseData:dictArray];
    
    //缓存图片
    
    dispatch_group_t group = dispatch_group_create();
    
    for (Photo *photo in array) {
        
        dispatch_group_enter(group);
        
        [[SDWebImageManager sharedManager] downloadImageWithURL:photo.smallphotourl options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            
            
            //大哥图片下载完成
            
            dispatch_group_leave(group);
            
        }];
        
        
    }
    
    //全部下载完成，数据回调到控制器
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        finished(array);
        
    });
    
    

}



//解析数据

+ (NSArray *) paseData:(NSArray *) dictArray{
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in dictArray) {
        
        Photo *photo = [[Photo alloc] initWithDict:dict];
        
        //将模型添加到数组中
        
        [array addObject:photo];
        
    }
    
    
    return array;
}

@end
