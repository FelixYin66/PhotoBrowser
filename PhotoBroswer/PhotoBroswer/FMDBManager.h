//
//  FMDBManager.h
//  PhotoBroswer
//
//  Created by FelixYin on 15/8/5.
//  Copyright © 2015年 felixios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface FMDBManager : NSObject

+ (void)openDBByQueue:(NSString *) dbName;

+ (FMDatabaseQueue *) sharedQueue;


//+ (void) aaa;
@end
