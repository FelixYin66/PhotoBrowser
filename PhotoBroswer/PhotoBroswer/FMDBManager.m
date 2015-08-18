//
//  FMDBManager.m
//  PhotoBroswer
//
//  Created by FelixYin on 15/8/5.
//  Copyright © 2015年 felixios. All rights reserved.
//

#import "FMDBManager.h"


@implementation FMDBManager


static FMDatabaseQueue *dbQueue;

+ (void) openDBByQueue:(NSString *) dbName{
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:dbName];
    
    
    NSLog(@"%@",path);
    
    dbQueue = [[FMDatabaseQueue alloc] initWithPath:path];
    
    [self createTableByQueue];

}


//创建一张表

+ (void) createTableByQueue{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"photo.sql" ofType:nil];

    NSString *sql = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSLog(@"sql语句是%@",sql);
    
    [dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
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
