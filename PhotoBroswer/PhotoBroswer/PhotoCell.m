//
//  PhotoCell.m
//  PhotoBroswer
//
//  Created by FelixYin on 15/8/5.
//  Copyright © 2015年 felixios. All rights reserved.
//

#import "PhotoCell.h"
#import "UIImageView+WebCache.h"

@interface PhotoCell()

@property(nonatomic,strong) UIImageView *imgView;

@end

@implementation PhotoCell


- (nonnull instancetype)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    
    self.imgView = [UIImageView new];
    
    //设置图片的平铺方式
    self.imgView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.imgView.clipsToBounds = YES;
    
    //超出部分裁剪掉
    
    self.imgView.frame = self.bounds;
    
    [self.contentView addSubview:_imgView];
    
    
    return self;


}




- (void)setPhoto:(Photo *)photo{

    _photo = photo;
    
    [self.imgView sd_setImageWithURL:photo.smallphotourl];


}


@end
