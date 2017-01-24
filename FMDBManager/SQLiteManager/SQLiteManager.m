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
    //执行sql语句
    sqlite3_exec(db, sql.UTF8String, nil, nil, &error);
    if (error == nil) {
        NSLog(@"创建表成功");
    }else {
        NSLog(@"%s", error);
    }
}
- (void)insert {
    NSString *sql = @"insert into Person values (0, '阿飞')";
    char *error = nil;
    sqlite3_exec(db, sql.UTF8String, nil, nil, &error);
    if (error == nil) {
        NSLog(@"插入数据成功");
    }else {
        NSLog(@"%s", error);
    }
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
             *
             *  @return 每一列,
             */
            int ID = sqlite3_column_int(stmt, 0);
            const unsigned char * name = sqlite3_column_text(stmt, 1);
            NSString *nameString = [NSString stringWithUTF8String:(const char *)name];
            NSLog(@"id = %d, name = %@", ID, nameString);
        }
        /**
         *  释放数据库
         */
        sqlite3_finalize(stmt);
    }

}
- (void)deleteData {
    NSString *sql = @"delete from Person where id = 0";
    char *error = nil;
    sqlite3_exec(db, sql.UTF8String, nil, nil, &error);
    if (error == nil) {
        NSLog(@"删除数据成功");
    }else {
        NSLog(@"%s", error);
    }
}
@end
