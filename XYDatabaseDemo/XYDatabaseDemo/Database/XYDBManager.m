//
//  XYDBManager.m
//  DBTest
//
//  Created by 夏雁博 on 16/4/13.
//  Copyright © 2016年 夏雁博. All rights reserved.
//

#import "XYDBManager.h"
#import "XYDatabase.h"

@interface XYDBManager ()

@property(nonatomic, strong) XYDatabase *db;

@end

@implementation XYDBManager

static XYDBManager *_instance = nil;
+ (instancetype)sharedManager {

  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _instance = [[self alloc] init];
      
  });
  return _instance;
}

/**
 *  打开数据库
 *
 *  @param filePath 数据库文件路径
 */
- (BOOL)openSqlWithFilePath:(NSString *)filePath error:(error)error{
    
    XYDatabase *db = [[XYDatabase alloc] init];
    self.db = db;


    BOOL openSqlResult = [self.db openSqlFileWithFilePath:filePath errorMsg:error];
    
    if (!openSqlResult) {
        return NO;
    }
    return YES;
}

// 关闭数据库
-(void)closeSql{
    if (nil != self.db) {
        [self.db closeSql];
    }
}

// 创建表
- (BOOL)creatTable:(NSString *)tableName
    WithPrimaryKey:(NSString *)primaryKey
   isAutoIncrement:(BOOL)isAutoIncrement
          andItems:(NSDictionary *)items
             error:(error)error {
  BOOL creatTableResult = [self.db creatTable:tableName
                               WithPrimaryKer:primaryKey
                              isAutoIncrement:isAutoIncrement
                                     andItems:items errorMsg:error];
  if (!creatTableResult) {
    // 创建表成功
      return NO;
  }
    return YES;
}

// 获取表中所有数据
-(NSArray *)getAllRecordFromTable:(NSString *)tableName error:(error)error{
    return [self selectDataFromTable:tableName requirements:nil error:error];
}

// 添加数据
- (void)insertRecordInTable:(NSString *)tableName
                     record:(NSDictionary *)record
                      error:(error)error {
  [self.db insertRecordInTable:tableName
                        record:record errorMsg:error];
}

// 删除数据
- (void)deleteRecordFromtable:(NSString *)tableName
                 requirements:(NSArray<NSString *> *)requirements
                        error:(error)error {
  [self.db deleteRecordFromtable:tableName
                    requirements:requirements errorMsg:error];
}

// 修改数据
- (void)updataTable:(NSString *)tableName
            targets:(NSArray<NSString *> *)targets
       requirements:(NSArray<NSString *> *)requirements
              error:(error)error {
  [self.db updataTable:tableName
               targets:targets
          requirements:requirements error:error];
}

// 查询数据
-(NSArray *)selectDataFromTable:(NSString *)tableName requirements:(NSArray<NSString *> *)requirements orderBy:(NSString *)item isAsc:(BOOL)isAsc error:(error)error{
    NSArray *selectArray = [self.db selectDataFromTable:tableName requirements:requirements orderBy:item isAsc:isAsc error:error];
    return selectArray;
}
-(NSArray *)selectDataFromTable:(NSString *)tableName requirements:(NSArray<NSString *> *)requirements error:(error)error {
    NSArray *selectArray = [self.db selectDataFromTable:tableName requirements:requirements error:error];
    return selectArray;
}

// 事务
-(BOOL)beginTransaction{
    return [self.db beginTransaction];;
}
-(BOOL)commit{
    return [self.db commit];
}
-(BOOL)rollback{
    return [self.db rollback];
}
@end
