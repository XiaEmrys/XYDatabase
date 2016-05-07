//
//  XYDatabase.m
//  DBTest
//
//  Created by 夏雁博 on 16/4/13.
//  Copyright © 2016年 夏雁博. All rights reserved.
//

#import "XYDatabase.h"
#import <sqlite3.h>

@interface XYDatabase () {
    sqlite3 *_db;
    sqlite3_stmt *_stmt;
}

@end

@implementation XYDatabase
/// 打开数据库
- (BOOL)openSqlFileWithFilePath:(NSString *)filePath errorMsg:(errorMsg)error {

  int openSqlResult = sqlite3_open(filePath.UTF8String, &_db);

    if (SQLITE_OK != openSqlResult) {
        error([self sqliteError:openSqlResult]);
        return NO;
    }
    return YES;
}

/// 关闭数据库
- (void)closeSql{
    sqlite3_close(_db);
}

/// 创建表
- (BOOL)creatTable:(NSString *)tableName
    WithPrimaryKer:(NSString *)primaryKey
   isAutoIncrement:(BOOL)isAutoIncrement
          andItems:(NSDictionary *)items
          errorMsg:(errorMsg)error {
  // 拼接创建表的 sql 语句
  __block NSString *creatTableSql =
      [NSString stringWithFormat:
                    @"CREATE TABLE IF NOT EXISTS %@ (%@ INTEGER PRIMARY KEY ",
                    tableName, primaryKey];
  if (isAutoIncrement) {
    creatTableSql = [creatTableSql stringByAppendingString:@"AUTOINCREMENT"];
  }
  //遍历字段字典
  [items enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj,
                                             BOOL *_Nonnull stop) {
    NSString *value = obj;
    creatTableSql =
        [creatTableSql stringByAppendingFormat:@", %@ %@", key, value];
  }];

  creatTableSql = [creatTableSql stringByAppendingString:@");"];

  //    NSLog(@"%@", creatTableSql);

  int creatTableResult =
      sqlite3_exec(_db, creatTableSql.UTF8String, NULL, NULL, NULL);
  if (SQLITE_OK != creatTableResult) {
    error([self sqliteError:creatTableResult]);
    return NO;
  }
  return YES;
}

// 添加数据
- (BOOL)insertRecordInTable:(NSString *)tableName
                     record:(NSDictionary *)record
                   errorMsg:(errorMsg)error {
  NSString *insertSql =
      [NSString stringWithFormat:@"INSERT INTO %@ (", tableName];
  NSArray<NSString *> *items = [record allKeys];
  NSArray *values = [record allValues];
  for (int i = 0; i < items.count; ++i) {
    if (i != items.count - 1) {
      insertSql = [insertSql stringByAppendingFormat:@"%@, ", items[i]];
    } else {
      //
      insertSql = [insertSql stringByAppendingFormat:@"%@) ", items[i]];
    }
  }
  insertSql = [insertSql stringByAppendingString:@"VALUES ("];
  for (int i = 0; i < values.count; ++i) {
    if ([values[i] isKindOfClass:[NSString class]]) {
      insertSql = [insertSql stringByAppendingFormat:@"'%@'", values[i]];
    } else {
      insertSql = [insertSql stringByAppendingFormat:@"%@", values[i]];
    }

    if (i != values.count - 1) {
      insertSql = [insertSql stringByAppendingString:@", "];
    } else {
      //
      insertSql = [insertSql stringByAppendingString:@");"];
    }
  }
  int insertResult =
      sqlite3_exec(_db, insertSql.UTF8String, NULL, NULL, NULL);

    if (SQLITE_OK != insertResult) {
        error([self sqliteError:insertResult]);
        return NO;
    }
    return YES;
}

//删除数据
- (BOOL)deleteRecordFromtable:(NSString *)tableName
                 requirements:(NSArray<NSString *> *)requirements
                     errorMsg:(errorMsg)error {

  NSString *deleteSql =
      [NSString stringWithFormat:@"DELETE FROM %@ WHERE ", tableName];

  for (int i = 0; i < requirements.count; ++i) {
    if (0 == i) {
      deleteSql = [deleteSql stringByAppendingString:requirements.firstObject];
    } else {
      deleteSql =
          [deleteSql stringByAppendingFormat:@" AND %@", requirements[i]];
    }
  }
  deleteSql = [deleteSql stringByAppendingString:@";"];
  int deleteResult =
      sqlite3_exec(_db, deleteSql.UTF8String, NULL, NULL, NULL);

    if (SQLITE_OK != deleteResult) {
        error([self sqliteError:deleteResult]);
        return NO;
    }
    return YES;
}

// 修改数据
- (BOOL)updataTable:(NSString *)tableName
            targets:(NSArray<NSString *> *)targets
       requirements:(NSArray<NSString *> *)requirements
              error:(errorMsg)error {
  NSString *updataSql =
      [NSString stringWithFormat:@"UPDATE %@ SET ", tableName];
  for (int i = 0; i < targets.count; ++i) {
    if (0 == i) {
      updataSql = [updataSql stringByAppendingString:targets.firstObject];
    } else {
      updataSql = [updataSql stringByAppendingFormat:@", %@", targets[i]];
    }
  }

  updataSql = [updataSql stringByAppendingString:@" WHERE "];

  for (int i = 0; i < requirements.count; ++i) {
    if (0 == i) {
      updataSql = [updataSql stringByAppendingString:requirements.firstObject];
    } else {
      updataSql =
          [updataSql stringByAppendingFormat:@" AND %@", requirements[i]];
    }
  }
  updataSql = [updataSql stringByAppendingString:@";"];

  int updataResult =
      sqlite3_exec(_db, updataSql.UTF8String, NULL, NULL, NULL);

    if (SQLITE_OK != updataResult) {
        error([self sqliteError:updataResult]);
        return NO;
    }
    return YES;
}

// 查询数据
-(NSArray *)selectDataFromTable:(NSString *)tableName requirements:(NSArray<NSString *> *)requirements orderBy:(NSString *)item isAsc:(BOOL)isAsc error:(errorMsg)error {
    NSArray *items = [self tableInfo:tableName];
    NSString *selectSql = [NSString stringWithFormat:@"SELECT * FROM %@", tableName];
    for (int i = 0; i < requirements.count; ++i) {
        if (0 == i) {
            selectSql = [selectSql stringByAppendingFormat:@" WHERE %@", requirements.firstObject];
        } else {
            selectSql =
            [selectSql stringByAppendingFormat:@" AND %@", requirements[i]];
        }
    }
    if (nil != item) {
        selectSql = [selectSql stringByAppendingFormat:@" ORDER BY %@", item];
        if (isAsc) {
            selectSql = [selectSql stringByAppendingString:@" ASC"];
        } else {
            selectSql = [selectSql stringByAppendingString:@" DESC"];
        }
    }
    selectSql = [selectSql stringByAppendingString:@";"];
    
    NSMutableArray<NSDictionary *> *selectArray = [NSMutableArray array];
    
    int selectResult = sqlite3_prepare_v2(_db, selectSql.UTF8String, -1, &_stmt, NULL);
    if (SQLITE_OK == selectResult) {
        while (SQLITE_ROW == sqlite3_step(_stmt)) {
            NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithCapacity:items.count];
            for (int i = 0; i < items.count; ++i) {
                NSDictionary *itemDict = items[i];
                if ([[itemDict objectForKey:@"type"] isEqualToString:@"INTEGER"]) {
                    [resultDict setObject:[NSNumber numberWithInteger:sqlite3_column_int(_stmt, i)] forKey:[itemDict objectForKey:@"name"]];
                } else if ([[itemDict objectForKey:@"type"] isEqualToString:@"TEXT"]) {
                    [resultDict setObject:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(_stmt, i)] forKey:[itemDict objectForKey:@"name"]];
                } else if ([[itemDict objectForKey:@"type"] isEqualToString:@"REAL"]) {
                    [resultDict setObject:[NSNumber numberWithFloat:sqlite3_column_double(_stmt, i)] forKey:[itemDict objectForKey:@"name"]];
                } else {
                    [resultDict setObject:(__bridge id _Nonnull)(sqlite3_column_blob(_stmt, i)) forKey:@"name"];
                }
            }
            [selectArray addObject:resultDict];
        }
        return selectArray;
    }
    error([self sqliteError:selectResult]);
    return nil;
};
-(NSArray *)selectDataFromTable:(NSString *)tableName requirements:(NSArray<NSString *> *)requirements error:(errorMsg)error {
    
    return [self selectDataFromTable:tableName requirements:requirements orderBy:nil isAsc:YES error:error];
}

// 获取表中所有字段名及字段类型
-(NSArray *)tableInfo:(NSString *)tableName{
    
    NSString *getItemsSql = [NSString stringWithFormat:@"PRAGMA table_info(%@)", tableName];
    
    int itemsResult = sqlite3_prepare_v2(_db, getItemsSql.UTF8String, -1, &_stmt, NULL);
    if (SQLITE_OK == itemsResult) {
        NSMutableArray<NSDictionary *> *items = [NSMutableArray array];
        while (SQLITE_ROW == sqlite3_step(_stmt)) {
            NSMutableDictionary *itemDict = [NSMutableDictionary dictionaryWithCapacity:2];
            NSString *name = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(_stmt, 1)];
            NSString *type = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(_stmt, 2)];
            [itemDict setObject:name forKey:@"name"];
            [itemDict setObject:type forKey:@"type"];
            [items addObject:itemDict];
        }
        return items;
    }
    return nil;
}

// 事务
-(BOOL)beginTransaction{
    NSString *sql = @"BEGIN TRANSCATION";
    int rec = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, NULL);
    return rec == SQLITE_OK;
}
-(BOOL)commit{
    NSString *sql = @"COMMIT TRANSCATION";
    int rec = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, NULL);
    return rec == SQLITE_OK;
}
-(BOOL)rollback{
    NSString *sql = @"ROLLBACK TRANSCATION";
    int rec = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, NULL);
    return rec == SQLITE_OK;
}
-(NSError *)sqliteError:(NSInteger)errorCode{
    NSString *sqliteErrorInfo = @"sqliteError";
    
    switch (errorCode) {
        case SQLITE_ERROR:      //1
            sqliteErrorInfo = @"SQL error or missing database";
            break;
        case SQLITE_INTERNAL:   //2
            sqliteErrorInfo = @"Internal logic error in SQLite";
            break;
        case SQLITE_PERM:       //3
            sqliteErrorInfo = @"Access permission denied";
            break;
        case SQLITE_ABORT:      //4
            sqliteErrorInfo = @"Callback routine requested an abort";
            break;
        case SQLITE_BUSY:       //5
            sqliteErrorInfo = @"The database file is locked";
            break;
        case SQLITE_LOCKED:     //6
            sqliteErrorInfo = @"A table in the database is locked";
            break;
        case SQLITE_NOMEM:      //7
            sqliteErrorInfo = @"A malloc() failed";
            break;
        case SQLITE_READONLY:   //8
            sqliteErrorInfo = @"Attempt to write a readonly database";
            break;
        case SQLITE_INTERRUPT:  //9
            sqliteErrorInfo = @"Operation terminated by sqlite3_interrupt()";
            break;
        case SQLITE_IOERR:      //10
            sqliteErrorInfo = @"Some kind of disk I/O error occurred";
            break;
        case SQLITE_CORRUPT:    //11
            sqliteErrorInfo = @"The database disk image is malformed";
            break;
        case SQLITE_NOTFOUND:   //12
            sqliteErrorInfo = @"Unknown opcode in sqlite3_file_control()";
            break;
        case SQLITE_FULL:       //13
            sqliteErrorInfo = @"Insertion failed because database is full";
            break;
        case SQLITE_CANTOPEN:   //14
            sqliteErrorInfo = @"Unable to open the database file";
            break;
        case SQLITE_PROTOCOL:   //15
            sqliteErrorInfo = @"Database lock protocol error";
            break;
        case SQLITE_EMPTY:      //16
            sqliteErrorInfo = @"Database is empty";
            break;
        case SQLITE_SCHEMA:     //17
            sqliteErrorInfo = @"The database schema changed";
            break;
        case SQLITE_TOOBIG:     //18
            sqliteErrorInfo = @"String or BLOB exceeds size limit";
            break;
        case SQLITE_CONSTRAINT: //19
            sqliteErrorInfo = @"Abort due to constraint violation";
            break;
        case SQLITE_MISMATCH:   //20
            sqliteErrorInfo = @"Data type mismatch";
            break;
        case SQLITE_MISUSE:     //21
            sqliteErrorInfo = @"Library used incorrectly";
            break;
        case SQLITE_NOLFS:      //22
            sqliteErrorInfo = @"Uses OS features not supported on host";
            break;
        case SQLITE_AUTH:       //23
            sqliteErrorInfo = @"Authorization denied";
            break;
        case SQLITE_FORMAT:     //24
            sqliteErrorInfo = @"Auxiliary database format error";
            break;
        case SQLITE_RANGE:      //25
            sqliteErrorInfo = @"2nd parameter to sqlite3_bind out of range";
            break;
        case SQLITE_NOTADB:     //26
            sqliteErrorInfo = @"File opened that is not a database file";
            break;
        case SQLITE_NOTICE:     //27
            sqliteErrorInfo = @"Notifications from sqlite3_log()";
            break;
        case SQLITE_WARNING:    //28
            sqliteErrorInfo = @"Warnings from sqlite3_log()";
            break;
        default:
            break;
    }
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:sqliteErrorInfo forKey:@"sqliteError"];
    return [NSError errorWithDomain:@"com.XYDatabase.ErrorDomain" code:errorCode userInfo:userInfo];
}

@end
