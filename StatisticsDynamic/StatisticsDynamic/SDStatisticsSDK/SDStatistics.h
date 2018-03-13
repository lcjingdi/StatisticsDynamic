//
//  SDStatistics.h
//  StatisticsDynamic
//
//  Created by lcjingdi on 2018/3/13.
//  Copyright © 2018年 EKW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDStatistics : NSObject

+ (instancetype)sharedInstance;

/// 通过url获取需要增加统计事件的类 格式为
/// @classname: 类名
/// optional @Params: 里面传输的为额外的参数
/// @EventId 事件ID
/// @MethodName 方法名
/// @{@classname:@[@{@Params:@[@"pam1",@"pam2"]},@EventId:@pam,@MethodName:@pam]}
- (void)pullStatisticsWithURL:(NSString *)urlStr UMengKey:(NSString *)key;

- (void)pullStatisticsWithDictionary:(NSDictionary *)dic UMengKey:(NSString *)key;

/// 通过前缀得到所有前缀的方法并上传url
- (void)updateStatisticsWithPrefix:(NSString *)prefix toURL:(NSString *)urlStr;

@end
