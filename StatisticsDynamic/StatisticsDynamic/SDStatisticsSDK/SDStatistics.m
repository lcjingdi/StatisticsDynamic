//
//  SDStatistics.m
//  StatisticsDynamic
//
//  Created by lcjingdi on 2018/3/13.
//  Copyright © 2018年 EKW. All rights reserved.
//

#import "SDStatistics.h"
#import <Aspects/Aspects.h>
#import <objc/runtime.h>

@implementation SDStatistics
static id _instance;
+ (instancetype)sharedInstance {
    @synchronized(self){
        if(_instance == nil){
            _instance = [[self alloc] init];
        }
    }
    return _instance;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    @synchronized(self) {
        if (_instance == nil) {
            _instance = [super allocWithZone:zone];
        }
    }
    return _instance;
}
- (void)pullStatisticsWithURL:(NSString *)urlStr UMengKey:(NSString *)key {
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    __weak typeof(self) ws = self;
    [[session dataTaskWithURL:[NSURL URLWithString:urlStr] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        [ws statistics:dic];
    }] resume];
}
- (void)pullStatisticsWithDictionary:(NSDictionary *)dic UMengKey:(NSString *)key {
    [self statistics:dic];
}
- (void)updateStatisticsWithPrefix:(NSString *)prefix toURL:(NSString *)urlStr {
    
}
- (void)statistics:(NSDictionary *)dic {
    __weak typeof(self) ws = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"statistics" ofType:@"plist"];
//        NSDictionary *eventStatisticsDict = [[NSDictionary alloc] initWithContentsOfFile:path];
        for (NSString *classNameString in dic.allKeys) {
            //使用运行时创建类对象
            const char * className = [classNameString UTF8String];
            //从一个字串返回一个类
            Class newClass = objc_getClass(className);
            NSArray *pageEventList = [dic objectForKey:classNameString];
            for (NSDictionary *eventDict in pageEventList) {
                //事件方法名称
                NSString *eventMethodName = eventDict[@"MethodName"];
                SEL seletor = NSSelectorFromString(eventMethodName);
                
                NSString *eventId = eventDict[@"EventId"];
                NSArray *params = eventDict[@"Params"];
                [ws trackEventWithClass:newClass selector:seletor event:eventId params:params];
            }
        }
    });
}
- (void)start {
    [self statistics:@{}];
    int count = 0;
    unsigned int outCount;
    count = 0;
    Class *classes2 = objc_copyClassList(&outCount);
    for (int i = 0; i < outCount; i++) {
        const char *className = class_getName(classes2[i]);
        NSString *OCString =[NSString stringWithCString:className encoding:NSUTF8StringEncoding];
        count++;
        NSLog(@"%s",class_getName(classes2[i]));
        
        unsigned int methodCount = 0;
        Method * methods = class_copyMethodList(NSClassFromString([NSString stringWithCString:class_getName(classes2[i]) encoding:NSUTF8StringEncoding]), &methodCount);
        for(int i=0;i<methodCount  ;i++)
        {
            Method method = methods[i];
            SEL methodsel = method_getName(method);
            const char * name = sel_getName(methodsel);
            NSString *MethodString =[NSString stringWithCString:name encoding:NSUTF8StringEncoding];
            if ([MethodString hasPrefix:@"_"]) {
                continue;
            }
        }
    }
    
    
}
- (void)trackEventWithClass:(Class)klass selector:(SEL)selector event:(NSString *)event params:(NSArray *)params
{
    [klass aspect_hookSelector:selector withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
        NSLog(@"eventId:%@, params:%@",event,params);
    } error:NULL];
}
@end
