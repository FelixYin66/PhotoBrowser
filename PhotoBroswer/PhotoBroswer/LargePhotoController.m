//
//  LargePhotoController.m
//  PhotoBroswer
//
//  Created by FelixYin on 15/8/5.
//  Copyright © 2015年 felixios. All rights reserved.
//

#import "LargePhotoController.h"
#import "PhotoView.h"


@interface LargePhotoController ()<PhotoViewDelegate,UIViewControllerInteractiveTransitioning,UIViewControllerContextTransitioning>

@property (nonatomic,strong)PhotoView *pView;

@property (nonatomic,assign) CGFloat scale;

@end

@implementation LargePhotoController


//- (void)dealloc{
//
//    [super dealloc];
//
//    
//    NSLog(@"销毁了");
//
//}

- (void)loadView{
 
    [super loadView];
    
    _pView = [[PhotoView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    _pView.photoDelegate = self;
    
    _pView.backgroundColor = [UIColor clearColor];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:_pView];


}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置PhotoView的图片内容
    
    _pView.photo = _photo;
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//点击返回

- (void) closeLargeVC{
    
    
    [self dismissViewControllerAnimated:YES completion:nil];


}


#pragma mark ---代理方法的实现


//触摸图片时

- (void)tapClosePhoto:(PhotoView *)pView{

    [self closeLargeVC];

}

//图片缩放时

- (void)photoDidZoom:(CGFloat)scale{

//    NSLog(@"%f",scale);
    
    _scale = scale;
    
    
    [self changeBackgroundColor:(scale < 1)];
    
    if (scale < 1) {
        
        //当缩放到0.8时进行交互式转场
        
        [self startInteractiveTransition:self];
        
    }else{
    
        //当在缩放后再放大时，会出现一个白边。。。所以需要回复形变
        
        self.view.transform = CGAffineTransformIdentity;
        
        self.view.alpha = 1.0;
    
    }
    

}


//图片缩放结束

- (void)photoEndZoom{

    if (_scale < 1) {
        
        [self completeTransition:YES];
        
    }
    
    

}


//设置背景

- (void) changeBackgroundColor:(BOOL) isTransparent{
    
    
    self.view.backgroundColor = isTransparent ? [UIColor clearColor]:[UIColor blackColor];


}

//获取当前被缩放的imgView

-(UIImageView *) currentImgView{

    return self.pView.imgView;
}




#pragma mark ---转场协议方法的实现


//UIViewControllerInteractiveTransitioning  只有三个协议方法 控制器交互转场协议方法

- (void)startInteractiveTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext{
    
    //动画转场的实现
    
    self.view.transform = CGAffineTransformMakeScale(_scale, _scale);
    
    self.view.alpha = _scale;
    
}


//UIViewControllerContextTransitioning 控制器上下文转场

// The view in which the animated transition should take place.   提供动画转场的View
- (nullable UIView *)containerView{


    return self.view;
}



// This must be called whenever a transition completes (or is cancelled.)
// Typically this is called by the object conforming to the
// UIViewControllerAnimatedTransitioning protocol that was vended by the transitioning
// delegate.  For purely interactive transitions it should be called by the
// interaction controller. This method effectively updates internal view
// controller state at the end of the transition.
- (void)completeTransition:(BOOL)didComplete{

   //接收到缩放完成时，dismiss控制器
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


// Most of the time this is YES. For custom transitions that use the new UIModalPresentationCustom
// presentation type we will invoke the animateTransition: even though the transition should not be
// animated. This allows the custom transition to add or remove subviews to the container view.
- (BOOL)isAnimated{return YES;}


// This indicates whether the transition is currently interactive.
- (BOOL)isInteractive{return YES;}

- (BOOL)transitionWasCancelled{return YES;}

- (UIModalPresentationStyle)presentationStyle{return UIModalPresentationCustom;}

// It only makes sense to call these from an interaction controller that
// conforms to the UIViewControllerInteractiveTransitioning protocol and was
// vended to the system by a container view controller's delegate or, in the case
// of a present or dismiss, the transitioningDelegate.
- (void)updateInteractiveTransition:(CGFloat)percentComplete{}
- (void)finishInteractiveTransition{}
- (void)cancelInteractiveTransition{}


// Currently only two keys are defined by the
// system - UITransitionContextToViewControllerKey, and
// UITransitionContextFromViewControllerKey.
// Animators should not directly manipulate a view controller's views and should
// use viewForKey: to get views instead.
- (nullable __kindof UIViewController *)viewControllerForKey:(NSString *)key{


    return self;
}


// Currently only two keys are defined by the system -
// UITransitionContextFromViewKey, and UITransitionContextToViewKey
// viewForKey: may return nil which would indicate that the animator should not
// manipulate the associated view controller's view.
- (nullable __kindof UIView *)viewForKey:(NSString *)key NS_AVAILABLE_IOS(8_0){return self.view;}

- (CGAffineTransform)targetTransform NS_AVAILABLE_IOS(8_0){return CGAffineTransformIdentity;}


// The frame's are set to CGRectZero when they are not known or
// otherwise undefined.  For example the finalFrame of the
// fromViewController will be CGRectZero if and only if the fromView will be
// removed from the window at the end of the transition. On the other
// hand, if the finalFrame is not CGRectZero then it must be respected
// at the end of the transition.
- (CGRect)initialFrameForViewController:(UIViewController *)vc{return CGRectZero;};
- (CGRect)finalFrameForViewController:(UIViewController *)vc{return CGRectZero;}


@end
