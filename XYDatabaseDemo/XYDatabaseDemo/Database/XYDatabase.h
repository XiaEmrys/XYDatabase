//
//  XYDatabase.h
//  DBTest
//
//  Created by 夏雁博 on 16/4/13.
//  Copyright © 2016年 夏雁博. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^errorMsg)(NSError *errorMsg);

@interface XYDatabase : NSObject

// 打开数据库
- (BOOL)openSqlFileWithFilePath:(NSString *)filePath errorMsg:(errorMsg)error;
// 关闭数据库
- (void)closeSql;

// 创建表
- (BOOL)creatTable:(NSString *)tableName
    WithPrimaryKer:(NSString *)primaryKey
   isAutoIncrement:(BOOL)isAutoIncrement
          andItems:(NSDictionary *)items
          errorMsg:(errorMsg)error;

// 添加数据
- (BOOL)insertRecordInTable:(NSString *)tableName
                     record:(NSDictionary *)record
                   errorMsg:(errorMsg)error;
// 删除数据
- (BOOL)deleteRecordFromtable:(NSString *)tableName
                 requirements:(NSArray<NSString *> *)requirement
                     errorMsg:(errorMsg)error;
// 修改数据
- (BOOL)updataTable:(NSString *)tableName
            targets:(NSArray<NSString *> *)targets
       requirements:(NSArray<NSString *> *)requirements
              error:(errorMsg)error;
// 查询数据
-(NSArray *)selectDataFromTable:(NSString *)tableName requirements:(NSArray<NSString *> *)requirements error:(errorMsg)error;

// 事务
-(BOOL)beginTransaction;
-(BOOL)commit;
-(BOOL)rollback;
@end
