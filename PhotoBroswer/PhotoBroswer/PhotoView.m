//
//  PhotoView.m
//  PhotoBroswer
//
//  Created by FelixYin on 15/8/6.
//  Copyright © 2015年 felixios. All rights reserved.
//

#import "PhotoView.h"
#import "UIImageView+WebCache.h"

@interface PhotoView ()<UIScrollViewDelegate>

@property (nonatomic,strong) UIScrollView *scrollView;

@property (nonatomic,strong) UIActivityIndicatorView *indicator;

@end


@implementation PhotoView

- (nonnull instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];

    //添加scrollView
    
    [self prepareScrollView];
    
    //添加小菊花提示
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    //设置小菊花剧中显示
    
    _indicator.center = self.center;
    
    
    [self addSubview:_indicator];
    
    
    return self;
}

- (void)setPhoto:(Photo *)photo{

    _photo = photo;
    
    
    //显示小菊花
    
    [_indicator startAnimating];
    
    
    //设置图片
    
    [_imgView sd_setImageWithURL:photo.largephotourl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        if (error) {
            
            NSLog(@"现在图片错误提醒是%@",error);
            
            return ;
        }
        
        
        //隐藏小菊花
        [_indicator stopAnimating];
        
        //计算imgView的frame
        
        [self caclImgViewFrame:image];
        
    }];
    

}

#pragma mar ---scrollView前期准备

- (void) prepareScrollView {

    _scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    
    _scrollView.backgroundColor = [UIColor clearColor];
    
    _imgView = [[UIImageView alloc] init];
    
    [_scrollView addSubview:_imgView];
    
    [self addSubview:_scrollView];
    
    
    //给图片添加一个Tap手势
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClosePhoto)];
    
    [_imgView addGestureRecognizer:tapGesture];
    
    //注意：imgView用户交互默认是关闭，所以添加手势后需要打开
    
    _imgView.userInteractionEnabled = YES;
    
    
    //设置scrollView的属性
    
    _scrollView.delegate = self;
    
    _scrollView.minimumZoomScale = 0.01;
    
    _scrollView.maximumZoomScale = 2.0;


}

#pragma mark ---计算imgView的frame


- (void) caclImgViewFrame:(UIImage *) img{

    //计算的imgView的size
    
    CGSize size = [self caclImgViewSize:img];
    
    //计算imgView的位置
    
    //1.大图时
    
    if (_scrollView.frame.size.height < size.height){
    
        //顶部显示
        
        _imgView.frame = CGRectMake(0, 0, size.width, size.height);
        
        //设置scrollView的内容大小
        
        _scrollView.contentSize = size;
    
    }else{
    
    //2.小图时
        
        CGFloat y = (_scrollView.frame.size.height - size.height) * 0.5;
        
        _imgView.frame = CGRectMake(0, 0, size.width, size.height);
        
        //注意：如果通过设置_imgView的frame的话，不可行  _imgView.frame = CGRectMake(0, y, size.width, size.height);
        
        //设置scrollView的内边距,把图片顶下来
        
        _scrollView.contentInset = UIEdgeInsetsMake(y, 0, 0, 0);
    
    
    }

}


//计算imgView的size

- (CGSize) caclImgViewSize:(UIImage *) img{
    
    //图片最大的宽度为UIScreen的宽度
    
    CGFloat scale = img.size.height / img.size.width;
    
    CGFloat h = _scrollView.frame.size.width * scale;
    
    //所以显示图片的size为
    
    CGSize size = CGSizeMake(_scrollView.frame.size.width, h);

    return size;
}



#pragma mark -----事件处理方法


- (void) tapClosePhoto{

    if ([self.photoDelegate respondsToSelector:@selector(tapClosePhoto:)]) {
        
        [self.photoDelegate tapClosePhoto:self];
        
    }

}


#pragma mark ----代理方法


//告诉scrollView缩放谁

- (nullable UIView *)viewForZoomingInScrollView:(nonnull UIScrollView *)scrollView{

    return _imgView;
}


//在缩放的时候一直调用此方法

- (void)scrollViewDidZoom:(nonnull UIScrollView *)scrollView{
    
    //获取缩放比例
    
    CGFloat scale = _imgView.transform.a;
    
    
    if ([self.photoDelegate respondsToSelector:@selector(photoDidZoom:)]) {
        
        [self.photoDelegate photoDidZoom:scale];
        
    }
    
    
}


//缩放结束后调用

- (void)scrollViewDidEndZooming:(nonnull UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale{
    
//    NSLog(@"%@-----%@",NSStringFromCGSize(scrollView.contentSize),NSStringFromCGSize(view.bounds.size));
    

    //此时的view时imgView
    
    CGFloat x = (_scrollView.frame.size.width - view.frame.size.width) * 0.5;
    
    CGFloat y = (_scrollView.frame.size.height - view.frame.size.height) * 0.5;
    
    
    //如果是放大时，就不移动照片，在缩小的时候移动照片
    
    if (x < 0) {
    
        x= 0;
    
    }
    
    if (y < 0) {
        
        y = 0;
    }
    
    
    //移动图片
    
    _scrollView.contentInset = UIEdgeInsetsMake(y, x, 0, 0);
    
    
    //通知缩放结束
    
    if ([self.photoDelegate respondsToSelector:@selector(photoEndZoom)]) {
        
        [self.photoDelegate photoEndZoom];
        
    }
   
}

@end
