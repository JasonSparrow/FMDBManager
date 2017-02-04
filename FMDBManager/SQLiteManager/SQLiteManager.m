//
//  SQLiteManager.m
//  FMDBManager
//
//  Created by 王腾飞 on 2017/1/22.
//  Copyright © 2017年 Jason. All rights reserved.
//

#import "SQLiteManager.h"
#import <sqlite3.h>

@interface SQLiteManager ()
{
    sqlite3 *db;
}
@end

@implementation SQLiteManager
+ (SQLiteManager *)shareSQL {
    static SQLiteManager *sqlManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sqlManager = [SQLiteManager new];
    });
    return sqlManager;
}

- (void)open {
    //document存放路径
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    //sqlite路径
    NSString *sqlitePath = [documentPath stringByAppendingPathComponent:@"database.sqlite"];

    /**
     *  打开数据库
     *
     *  @param UTF8String] [sqlitePath UTF8String] 把OC字符串转成C字符串
     *  如果不存在数据库文件则会创建一个sqlite文件, 否则不创建, 直接打开文件
     *
     *  @return 打开成功与失败
     */
    int result = sqlite3_open([sqlitePath UTF8String], &db);
    if (result == SQLITE_OK) {
        NSLog(@"打开数据库成功");
    }else {
        NSLog(@"打开数据库失败");
    }
}

- (void)close {
    int result = sqlite3_close(db);
    if (result == SQLITE_OK) {
        NSLog(@"关闭数据库成功");
    }else {
        NSLog(@"打开数据库失败");
    }
}

- (void)create {
    NSString *sql = @"create table Person (id integer, name text)";
    char *error = nil;
    /**
     *  执行sql语句
     *  1. 数据库指针
     *  2. 要执行的SQL
     *  3. callBack 执行完SQL之后,  调用的C语言函数指针, 通常传入nil
     *  4. 第三个参数callBack的函数地址, 通常传入nil
     *  5. 错误信息
     */
    sqlite3_exec(db, sql.UTF8String, nil, nil, &error);
    if (error == nil) {
        NSLog(@"创建表成功");
    }else {
        NSLog(@"%s", error);
    }
}
- (void)insert {
    
    NSDate *time = [NSDate date];
    NSLog(@"开始插入数据");
    NSLog(@"开启事务");
    [self execSQL:@"BEGIN TRANSACTION"];
    for (int i = 0; i < 100000; i++) {
        NSString *sql = @"insert into Person values (0, '阿飞')";
        if ([self execSQL:sql]) {
//            NSLog(@"插入成功");
        }else {
            NSLog(@"插入失败");
        }
    }
    [self execSQL:@"COMMIT TRANSACTION"];
    NSLog(@"结束");
    NSLog(@"%f", [[NSDate date] timeIntervalSinceDate:time]);
}
- (void)select {
    NSString *sql = @"select * from Person";
    sqlite3_stmt * stmt = nil;
    /**
     *  预编译sql
     *
     *  @param db             数据库
     *  @param sql.UTF8String sql语句
     *  @param -1             sql语句长度, -1代表会自动计算长度
     *  @param stmt           数据库管理的指针
     *  @param nil            预留参数
     *
     *  @return 成功失败
     */
    int result = sqlite3_prepare_v2(db, sql.UTF8String, -1, &stmt, nil);
    if (result == SQLITE_OK) {
        //单步执行, 并判断是否有下一行数据
        /**
         * Person
         *
         * integer, name
         *  0   '小明'
         *  1   '小丽'
         *  2   '小花'
         */
        //while循环会去自动循环每一条数据,sqlite3_column_%, 回去自动
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            /**
             *  获取每列的数据
             *
             *  @param stmt 数据库指针
             *  @param 0    因为表Person有两个字段, 就是两列, 0代表第一列数据, 1代表第二列数据, 依次往后退
             *  @param sqlite3_column_count(); 获取当前查询字段的个数
             *  @return 每一列,
             */
            int count = sqlite3_column_count(stmt);
            for (int i = 0; i < count; i++) {
                //1 > 列名, 把C字符串转成OC字符串
                NSString *name = [[NSString alloc] initWithCString:sqlite3_column_name(stmt, i) encoding:NSUTF8StringEncoding];
                //2 > 列对应的数据类型
                int type = sqlite3_column_type(stmt, i);

                id objValue;
                double doubleVaule;
                NSInteger integerValue;
                NSString *typeString;
                switch (type) {
                    case SQLITE_FLOAT:
                        typeString = @"小数";
                        doubleVaule = sqlite3_column_double(stmt, i);
                        NSLog(@"name = %@, type = %@, value = %f", name, typeString, doubleVaule);
                        break;
                    case SQLITE3_TEXT:
                        typeString = @"字符串";
                        objValue = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, i)];
                        NSLog(@"name = %@, type = %@, value = %@", name, typeString, objValue);
                        break;
                    case SQLITE_INTEGER:
                        typeString = @"整数";
                        integerValue = (NSInteger)sqlite3_column_int64(stmt, i);
                        NSLog(@"name = %@, type = %@, value = %ld", name, typeString, integerValue);
                        break;
                    case SQLITE_NULL:
                        typeString = @"空值";
                        objValue = [NSNull null];
                        NSLog(@"name = %@, type = %@, value = %@", name, typeString, objValue);
                        break;
                    default:
                        NSLog(@"不支持的数据类型");
                        break;
                }
                
            }
        }
        /**
         *  释放数据库
         */
        sqlite3_finalize(stmt);
    }

}
- (void)deleteData {
    NSString *sql = @"delete from Person where id = 0";
    if ([self execSQL:sql]) {
        NSLog(@"删除数据成功");
    }else {
        NSLog(@"删除数失败");
    }
}

- (BOOL)execSQL:(NSString *)sql {
    char *error = nil;
    sqlite3_exec(db, sql.UTF8String, nil, nil, &error);
    if (error == nil) {
        return YES;
    }else {
        NSLog(@"%s", error);
        return NO;
    }

}
/**
 *  在SQLite数据库操作中, 如果不显示的开启事务, 每一条数据库的操作指令都会被开启事务, 执行完成之后, 提交事务
 *  如果显示的开启事务, SQLite不再每次执行数据库开启一次事务, 而是只开启一次.
 *  因为每次开始,提交事务都会消耗资源, 如果频繁的操作,会降低性能, 所以我们显示的开启事务
 */
@end
