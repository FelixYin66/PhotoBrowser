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

#define PhotoCellItemH 120


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
        
        [SVProgressHUD showWithStatus:@"图片正在加载中..."];
        
        [Photo loadPhoto:nil andMinid:nil resultBack:^(NSArray *pArray) {
            
            [SVProgressHUD dismiss];
            
            _photoArray = (NSMutableArray *)pArray;
            
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
    
    CGFloat h = PhotoCellItemH;
    
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
    
    _selectedIndex = indexPath;

    //创建目标控制器
    
    LargePhotoController *largeVC = [[LargePhotoController alloc] init];
    
    Photo *p = _photoArray[indexPath.item];
    
    largeVC.photo = p;
    
    //设置专场动画样式
    
    largeVC.modalPresentationStyle = UIModalPresentationCustom;
    
    largeVC.transitioningDelegate = self;

    BOOL isShow = [self showInfoDownloadImg:p];
    
    
    [[SDWebImageManager sharedManager] downloadImageWithURL:p.largephotourl options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        
        if (isShow) {
            
            [SVProgressHUD dismiss];
            
        }
        
        self.presentedImgView = [[UIImageView alloc] initWithFrame:[self imgViewScreenFrameInWindow]];
        
        
        [self.presentedImgView sd_setImageWithURL:imageURL];
        
        
        [self presentViewController:largeVC animated:YES completion:nil];
        
    }];


}



- (CGRect) imgViewScreenFrameInWindow{

    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:_selectedIndex];
    
    
    CGRect frame = [self.collectionView convertRect:cell.frame toCoordinateSpace:[UIApplication sharedApplication].keyWindow];
    
   return frame;
}



- (CGRect) imgViewFullScreenFrameInWindow{
    
    Photo *p = _photoArray[_selectedIndex.item];
    
    NSString *urlStr = [p.largephotourl absoluteString];
    
    UIImage *img = [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:urlStr];
    
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


- (nullable id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(nonnull UIViewController *)presented presentingController:(nonnull UIViewController *)presenting sourceController:(nonnull UIViewController *)source{

    _isPresented = true;
    
    return self;
}


- (nullable id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(nonnull UIViewController *)dismissed{

    _isPresented = false;
    
    
    return self;
}



- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext{

    
    return 1;
}



- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext{
    
    
    NSString *viewKey = _isPresented ? UITransitionContextToViewKey:UITransitionContextFromViewKey;
    
    UIView *targetView = [transitionContext viewForKey:viewKey];
    
    
    if (targetView == nil) {
        return;
    }
    
    CGFloat time = [self transitionDuration:transitionContext];
    
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
    
    [container addSubview:_presentedImgView];
    
    targetView.alpha = 0;
    
    
    [UIView animateWithDuration:time animations:^{
        
        _presentedImgView.frame = [self imgViewFullScreenFrameInWindow];
        
        
    } completion:^(BOOL finished) {
        
        [_presentedImgView removeFromSuperview];
        
        targetView.alpha = 1;
        
        [transitionContext completeTransition:YES];
        
    }];
    
    
    
    
}






// ------dismiss时动画的实现


- (void) dismissAnimationForView:(nonnull id<UIViewControllerContextTransitioning>)transitionContext Time:(CGFloat) time andTargetView:(UIView *)targetView{
    
    LargePhotoController *vc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIImageView *imgV = [vc currentImgView];
    
    [[transitionContext containerView] addSubview:imgV];
    
    imgV.center = vc.view.center;
    
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
