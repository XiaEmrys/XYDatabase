//
//  XYDBManager.h
//  DBTest
//
//  Created by 夏雁博 on 16/4/13.
//  Copyright © 2016年 夏雁博. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kTableItemTypeInteger @"INTEGER"
#define kTableItemTypeIntegerNotNull @"INTEGER NOT NULL"
#define kTableItemTypeIntegerNotNullDefault(integerDefault)                    \
  [NSString stringWithFormat:@"INTEGER NOT NULL DEFAULT %zd", integerDefault]
#define kTableItemTypeIntegerDefault(integerDefault)                           \
  [NSString stringWithFormat:@"INTEGER DEFAULT %zd", integerDefault]

#define kTableItemTypeReal @"REAL"
#define kTableItemTypeRealNotNull @"REAL NOT NULL"
#define kTableItemTypeRealNotNullDefault(realDefault)                          \
  [NSString stringWithFormat:@"REAL NOT NULL DEFAULT %f", realDefault]
#define kTableItemTypeRealDefault(realDefault)                                 \
  [NSString stringWithFormat:@"REAL DEFAULT %f", realDefault]

#define kTableItemTypeText @"TEXT"
#define kTableItemTypeTextNotNull @"TEXT NOT NULL"
#define kTableItemTypeTextNotNullDefault(textDefault)                          \
  [NSString stringWithFormat:@"TEXT NOT NULL DEFAULT %@", textDefault]
#define kTableItemTypeTextDefault(textDefault)                                 \
  [NSString stringWithFormat:@"TEXT DEFAULT %@", textDefault]

#define kTableItemTypeBlob @"BLOB"
#define kTableItemTypeBlobNotNull @"BLOB NOT NULL"
#define kTableItemTypeBlobNotNullDefault(blobDefault)                          \
  [NSString stringWithFormat:@"BLOB NOT NULL DEFAULT %@", blobDefault]
#define kTableItemTypeBlobDefault(blobDefault)                                 \
  [NSString stringWithFormat:@"BLOB DEFAULT %@", blobDefault]

//错误信息
typedef void (^error)(NSError *error);

@interface XYDBManager : NSObject

//创建单例
+ (instancetype)sharedManager;

/**
 *  打开数据库
 *
 *  @param filePath 数据库文件路径
 *  @param success  打开成功的回调
 *  @param error    打开失败的回调
 */
- (BOOL)openSqlWithFilePath:(NSString *)filePath error:(error)error;

// 关闭数据库
-(void)closeSql;

/**
 *  创建一张表
 *
 *  @param tableName        表名
 *  @param primaryKey       主键
 *  @param isAutoIncrement  是否自动增长
 *  @param items            字段
 *  @param success          创建成功的回调
 *  @param error            创建失败的回调
 */
- (BOOL)creatTable:(NSString *)tableName
    WithPrimaryKey:(NSString *)primaryKey
   isAutoIncrement:(BOOL)isAutoIncrement
          andItems:(NSDictionary *)items
             error:(error)error;

/**
 *  getAllRecord
 */
-(NSArray *)getAllRecordFromTable:(NSString *)tableName error:(error)error;

/**
 *  insertRecord
 */
-(void)insertRecordInTable:(NSString *)tableName record:(NSDictionary *)record error:(error)error;

/**
 *  deleteRecord
 */
-(void)deleteRecordFromtable:(NSString *)tableName requirements:(NSArray<NSString *>*)requirements error:(error)error;

/**
 *  updataTable
 */
-(void)updataTable:(NSString *)tableName targets:(NSArray<NSString *>*)targets requirements:(NSArray<NSString *> *)requirements error:(error)error;
/**
 *  selectRecord
 */
-(NSArray *)selectDataFromTable:(NSString *)tableName requirements:(NSArray<NSString *> *)requirements error:(error)error;
-(NSArray *)selectDataFromTable:(NSString *)tableName requirements:(NSArray<NSString *> *)requirements orderBy:(NSString *)item isAsc:(BOOL)isAsc error:(error)error;

/**
 *   beginTransaction
 */
-(BOOL)beginTransaction;

/**
 *   commit
 */
-(BOOL)commit;

/**
 *   rollback
 */
-(BOOL)rollback;
@end
