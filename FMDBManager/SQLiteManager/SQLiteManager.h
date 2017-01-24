//
//  SQLiteManager.h
//  FMDBManager
//
//  Created by 王腾飞 on 2017/1/22.
//  Copyright © 2017年 Jason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQLiteManager : NSObject
+ (SQLiteManager *)shareSQL;
/**
 *  打开数据库
 */
- (void)open;
/**
 *  关闭数据库
 */
- (void)close;
/**
 *  创建表
 */
- (void)create;
/**
 *  插入数据
 */
- (void)insert;
/**
 *  查询数据
 */
- (void)select;
/**
 *  删除数据
 */
- (void)deleteData;
@end
