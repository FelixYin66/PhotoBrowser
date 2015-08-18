//
//  PhotoController.m
//  PhotoBroswer
//
//  Created by FelixYin on 15/8/5.
//  Copyright © 2015年 felixios. All rights reserved.
//

#import "PhotoController.h"
#import "PhotoCell.h"
#import "LargePhotoController.h"
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"
#import "MJRefresh.h"

//#import "SDWebImageManager.h"

//UIViewControllerTransitioningDelegate  专场代理协议

@interface PhotoController ()<UIViewControllerTransitioningDelegate,UIViewControllerAnimatedTransitioning>

@property (nonatomic,strong) NSMutableArray *photoArray;

//专场标记
@property (nonatomic,assign) BOOL isPresented;

//转场时的cell索引
@property (nonatomic,strong) NSIndexPath *selectedIndex;

//临时imgView
@property (nonatomic,strong) UIImageView *presentedImgView;


@end

@implementation PhotoController

static NSString * const reuseIdentifier = @"Cell";


- (NSMutableArray *)photoArray{

    if (_photoArray == nil) {
        
        //添加一个开始加载数据的遮盖
        
        [SVProgressHUD showWithStatus:@"图片正在加载中..."];
        
        //一开始加载数据maxid为nil
        [Photo loadPhoto:nil andMinid:nil resultBack:^(NSArray *pArray) {
            
            //移除遮盖
            
            [SVProgressHUD dismiss];
            
            _photoArray = (NSMutableArray *)pArray;
            
            //数据返回之后刷新数据
            
            [self.collectionView reloadData];
            
        }];
    }


    return _photoArray;
}

- (instancetype)init{

    //设置流水布局
    
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    

    self = [super initWithCollectionViewLayout:flowLayout];
    
    
    //计算itemSize的大小
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    CGFloat h = 120;
    
    CGFloat w = (size.width - 40)/3;
    
    flowLayout.itemSize = CGSizeMake(w, h);
    
    flowLayout.minimumInteritemSpacing = 10;
    
    flowLayout.minimumLineSpacing = 10;
    
    flowLayout.sectionInset = UIEdgeInsetsMake(15, 10, 10, 10);
    
    
    //设置刷新控件
    
    [self settingRefreshControl];
    
    
    return self;

}





- (void)viewDidLoad {
    [super viewDidLoad];

    //
    [self.collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    self.collectionView.backgroundColor = [UIColor orangeColor];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    
}

#pragma mark 刷新控件设置

- (void) settingRefreshControl{

    self.collectionView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(downLoadData:)];
    
    self.collectionView.footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(upLoadData:)];


}


- (void) downLoadData:(id) param{

    NSLog(@"下拉刷新数据");
    
    Photo *photo = [_photoArray firstObject];
    
    [self loadData:photo.photoid andMinID:nil];
    
    
    
    
}

- (void) upLoadData:(id) param{

    NSLog(@"上拉刷新数据");

    Photo *photo = [_photoArray lastObject];
    
    [self loadData:nil andMinID:photo.photoid];
    
    

}


- (void) loadData:(NSString *) maxid andMinID:(NSString *) minid{

    [Photo loadPhoto:maxid andMinid:minid resultBack:^(NSArray *pArray) {
        
        
        //结束刷新状态
        
        [self.collectionView.header endRefreshing];
        
        [self.collectionView.footer endRefreshing];

        if (pArray == nil) {
            
            return;
        }
        
        
        
        if (maxid != nil) {
            
            NSMutableArray *pMarray = (NSMutableArray *) pArray;
            
            [pMarray addObjectsFromArray:_photoArray];
            
            
            
        }else if (minid != nil){
        
            [_photoArray addObjectsFromArray:pArray];
            
        }
        
        //刷新数据
        
        [self.collectionView reloadData];
        
        
    }];

}


#pragma mark 数据源协议UICollectionViewDataSource


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    NSInteger num = self.photoArray == nil ? 5:self.photoArray.count;
    
    return num;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.photo = _photoArray != nil ? _photoArray[indexPath.item]:nil;
    
    
    return cell;
}


- (void)collectionView:(nonnull UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    //记录当前选中cell的indexPath
    
    _selectedIndex = indexPath;

    //创建目标控制器
    
    LargePhotoController *largeVC = [[LargePhotoController alloc] init];
    
    Photo *p = _photoArray[indexPath.item];
    
    largeVC.photo = p;
    
    //设置专场动画样式
    
    // 系统提供的有:
    
    //UIModalTransitionStyleCrossDissolve  从中间慢慢出来
    
    //UIModalTransitionStyleFlipHorizontal 旋转效果出现
    
    //UIModalTransitionStylePartialCurl  翻日历效果出现
    
    //UIModalPresentationCustom  自定义专场，专场需要自己实现
    
    largeVC.modalPresentationStyle = UIModalPresentationCustom;
    
    largeVC.transitioningDelegate = self;
    
    //下载图片时给一个提醒

    BOOL isShow = [self showInfoDownloadImg:p];
    
    
    //专场之前将图片下载完整
    
    [[SDWebImageManager sharedManager] downloadImageWithURL:p.largephotourl options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        
        //关闭下载提醒
        
        if (isShow) {
            
            [SVProgressHUD dismiss];
            
        }
        
        //创建临时imgView，并指定其frame(是以UIWindow为坐标系)
        
        self.presentedImgView = [[UIImageView alloc] initWithFrame:[self imgViewScreenFrameInWindow]];
        
        //image的内容为刚刚下载好的图片
        
        [self.presentedImgView sd_setImageWithURL:imageURL];
        
        
        //图片下载完成后再----modal
        
        [self presentViewController:largeVC animated:YES completion:nil];
        
    }];


}


//计算imgView相对UIWindow的位置  ---> 坐标系转换


- (CGRect) imgViewScreenFrameInWindow{

    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:_selectedIndex];
    
    
    //使用collectionView将cell坐标转换到keyWindow上
    
    CGRect frame = [self.collectionView convertRect:cell.frame toCoordinateSpace:[UIApplication sharedApplication].keyWindow];
    
   return frame;
}


//计算大图imgView在最终显示的位置  ---> 专场之后调用这个方法获取最终展示的位置

- (CGRect) imgViewFullScreenFrameInWindow{
    
    Photo *p = _photoArray[_selectedIndex.item];
    
    NSString *urlStr = [p.largephotourl absoluteString];
    
    UIImage *img = [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:urlStr];

    //计算img等比例缩放之后的CGRect
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    CGFloat scale = img.size.height / img.size.width;
    
    CGFloat h = scale * size.width;
    
    CGFloat y = 0;
    
    if (h < size.height) {
        
        y = (size.height - h) * 0.5;
    }
    

    return CGRectMake(0, y, size.width, h);
}





#pragma mark ---专场代理方法的实现   UIViewControllerContextTransitioning

//返回提供presented时转场的对象，提供专场动画的是控制器  --- UIViewControllerTransitioning的协议方法

- (nullable id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(nonnull UIViewController *)presented presentingController:(nonnull UIViewController *)presenting sourceController:(nonnull UIViewController *)source{

    _isPresented = true;
    
    return self;
}

//返回提供dismiss时转场的对象，提供专场的也是控制器 --- UIViewControllerTransitioning的协议方法

- (nullable id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(nonnull UIViewController *)dismissed{

    _isPresented = false;
    
    
    return self;
}


//转场时长   ----UIViewControllerAnimatedTransitioning 的协议方法

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext{

    
    return 1;
}



//动画代码实现（包括presented与dimissed）  ---UIViewControllerAnimatedTransitioning 的协议方法

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext{
    
    
    NSString *viewKey = _isPresented ? UITransitionContextToViewKey:UITransitionContextFromViewKey;
    
    //获取视图
    
    UIView *targetView = [transitionContext viewForKey:viewKey];
    
    
    if (targetView == nil) {
        return;
    }
    
    //获取转场时长
    
    CGFloat time = [self transitionDuration:transitionContext];
    
    
    //转场动画
    
    if (_isPresented) {
        
    
        [self presentedAnimationForView:transitionContext Time:time andTargetView:targetView];
        
        
    }else{
        
        
        [self dismissAnimationForView:transitionContext Time:time andTargetView:targetView];
        
    }

}




// ------presented时动画的实现


- (void) presentedAnimationForView:(nonnull id<UIViewControllerContextTransitioning>)transitionContext Time:(CGFloat) time andTargetView:(UIView *)targetView {

   
    UIView *container = [transitionContext containerView];
    
    [container addSubview:targetView];
    
    //添加临时图片视图到容器视图
    
    [container addSubview:_presentedImgView];
    
    
    //一开始不现实目标视图
    
    targetView.alpha = 0;
    
    
    [UIView animateWithDuration:time animations:^{
        
        //临时视图慢慢变大到与目标显示内容的大小一致
        
        _presentedImgView.frame = [self imgViewFullScreenFrameInWindow];
        
        
    } completion:^(BOOL finished) {
        
        //将临时图片视图从容器视图移除
        
        [_presentedImgView removeFromSuperview];
        
        
        //显示目标视图  ----显示目标内容
        
        targetView.alpha = 1;
        
        
        //告诉代理动画已经完成
        
        [transitionContext completeTransition:YES];
        
    }];
    
    
    
    
}






// ------dismiss时动画的实现


- (void) dismissAnimationForView:(nonnull id<UIViewControllerContextTransitioning>)transitionContext Time:(CGFloat) time andTargetView:(UIView *)targetView{


    //dismiss时执行动画
    
    //获取需要被dismiss控制器
    
    LargePhotoController *vc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    //此时的imgV只有大小，没有frame
    
    UIImageView *imgV = [vc currentImgView];
    
    //将imgV添加到容器视图中执行动画
    //这样做的原因是：containerView是整个屏幕的大小，而且还是透明的，如果把imgV放在FromVC中动画，动画效果不是很好，会有偏差
    //偏差的原因是：他们的参照空间不同所以相对屏幕frame也是不一样的
    
    //此时imgV的x,y是0，0
    
    [[transitionContext containerView] addSubview:imgV];
    
    //为了更好的动画效果，需要设置一下imgV刚刚被缩放到什么位置(相对于)
    //不设置的话，imgV的x，y为零，所以在停止缩放时imgV会先回到window的原点再缩放
    
    imgV.center = vc.view.center;
    
    //由于设置了scrollView的最大形变为2，最小型变为0.5
    //所以当缩放时要让imgV的形变参数与targetView的形变参数保持一直  如果添加这块代码，imgV当小于0.5时，会先变大，最后再动画
    //所以不添加这一块代码时，会出现一个闪动效果
    
    imgV.transform = CGAffineTransformScale(imgV.transform, targetView.transform.a, targetView.transform.a);
    
    [targetView removeFromSuperview];
    
    [UIView animateWithDuration:time animations:^{
        
        imgV.frame = [self imgViewScreenFrameInWindow];
        
    } completion:^(BOOL finished) {
        
        [transitionContext completeTransition:YES];
        
    }];


}


//图片下载提醒

- (BOOL) showInfoDownloadImg:(Photo *)p{
    
    BOOL isShow = ![[SDWebImageManager sharedManager] cachedImageExistsForURL:p.largephotourl];
    
    if (isShow) {
        
        [SVProgressHUD showInfoWithStatus:@"图片正在加载中..." maskType:SVProgressHUDMaskTypeGradient];
        
    }
    
    
    return isShow;
}


@end
