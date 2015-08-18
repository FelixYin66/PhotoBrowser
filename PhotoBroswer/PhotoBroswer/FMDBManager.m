//
//  FMDBManager.m
//  PhotoBroswer
//
//  Created by FelixYin on 15/8/5.
//  Copyright © 2015年 felixios. All rights reserved.
//

#import "FMDBManager.h"


@implementation FMDBManager


//创建数据库

static FMDatabaseQueue *dbQueue;

+ (void) openDBByQueue:(NSString *) dbName{

    //数据库存储的位置
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:dbName];
    
    
    NSLog(@"%@",path);
    
    //创建并打开数据库
    
    dbQueue = [[FMDatabaseQueue alloc] initWithPath:path];
    
    
    //创建一张表
    
    [self createTableByQueue];

}


//创建一张表

+ (void) createTableByQueue{
    
    //获取sql的路径
    NSString *path = [[NSBundle mainBundle] pathForResource:@"photo.sql" ofType:nil];

    NSString *sql = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSLog(@"sql语句是%@",sql);
    
    //执行sql语句
    
    [dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        //swift中不需要加(),oc需要。。。差点糊涂了
        
        if (![db executeUpdate:sql]) {
        
            NSLog(@"创建图片表失败");
            
            return;
        }
        
        NSLog(@"创建表成功!");
        
    }];



}


+ (FMDatabaseQueue *) sharedQueue{

    
    return dbQueue;
}

@end
