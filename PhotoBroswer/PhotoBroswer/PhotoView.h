//
//  PhotoView.h
//  PhotoBroswer
//
//  Created by FelixYin on 15/8/6.
//  Copyright © 2015年 felixios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"

//声明一个协议
@protocol PhotoViewDelegate;

@interface PhotoView : UIView

@property (nonatomic,weak) id<PhotoViewDelegate> photoDelegate;

@property(nonatomic,strong)Photo *photo;

//需要被缩放的imgView
@property (nonatomic,strong) UIImageView *imgView;

@end



//定义一个协议

@protocol PhotoViewDelegate <NSObject>

//触摸图片时
-(void) tapClosePhoto:(PhotoView *) pView;

//缩放时

-(void) photoDidZoom:(CGFloat) scale;

//缩放结束

-(void) photoEndZoom;

@end
