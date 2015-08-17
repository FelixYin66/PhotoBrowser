//
//  PhotoDAL.m
//  PhotoBroswer
//
//  Created by FelixYin on 15/8/5.
//  Copyright © 2015年 felixios. All rights reserved.
//

#import "PhotoDAL.h"
#import "FMDBManager.h"

@implementation PhotoDAL

static NSMutableString *sql = (NSMutableString *) @"SELECT PHOTOID,SMALLPHOTOURL,LARGEPHOTOURL FROM T_PHOTO\t";

+ (void)loadPhoto:maxid adnBack:(void (^)(NSArray *))finished{
    
    
    if (maxid) {
        
    sql =(NSMutableString *) [sql stringByAppendingFormat:@"WHERE PHOTOID > %@\t",maxid];
        
    }
    
    sql =(NSMutableString *) [sql stringByAppendingFormat:@"LIMIT 20;"];
    
    NSLog(@"%@",sql);
    
    
    
    //执行查询
    
    NSMutableArray *dictArray = [[NSMutableArray alloc] init];
    
    [[FMDBManager sharedQueue] inDatabase:^(FMDatabase *db) {
        
        FMResultSet *result = [db executeQuery:sql];
        
        if (!result) {

            //没有结果返回空
            
            finished(nil);
            
            return;
            
        }
        
        
        while ([result next]) {
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            [dict setValue:[result stringForColumn:@"photoid"] forKey:@"photoid"];
            
            [dict setValue:[result stringForColumn:@"smallphotourl"] forKey:@"smallphotourl"];
            
            [dict setValue:[result stringForColumn:@"largephotourl"] forKey:@"largephotourl"];
            
            
            //将字典添加到数组中
            
            [dictArray addObject:dict];
            
        }
        
        
        //数据回调
        
        finished(dictArray);
        
        
        
    }];

}

@end
