//
//  LargePhotoController.h
//  PhotoBroswer
//
//  Created by FelixYin on 15/8/5.
//  Copyright © 2015年 felixios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"

@interface LargePhotoController : UIViewController

@property (nonatomic,strong)Photo *photo;


//提供一个返回当前被缩放的imageView

-(UIImageView *) currentImgView;

@end
