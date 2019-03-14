//
//  BPAspectManager.m
//  podtext
//
//  Created by md314 on 2019/3/5.
//  Copyright © 2019年 jfr. All rights reserved.
//

#import "BPAspectManager.h"
#import "JANALYTICSService.h"
@interface BPAspectManager()
{
    NSString *filepath;
}
@end
@implementation BPAspectManager
+(void)trackAspectHooks{
    
    [BPAspectManager trackViewAppear];
    [BPAspectManager trackBttonEvent];
}


#pragma mark -- 监控统计用户进入此界面的时长，频率等信息
+ (void)trackViewAppear{
    
    [UIViewController aspect_hookSelector:@selector(viewDidAppear:)
                              withOptions:AspectPositionBefore
                               usingBlock:^(id<AspectInfo> info){
                                   
                                   //用户统计代码写在此处
                                   NSLog(@"[打点统计]:%@ viewWillAppear",NSStringFromClass([info.instance class]));
                                   NSString *className = NSStringFromClass([info.instance class]);
                                   NSLog(@"className-->%@",className);
                                   
                                   [JANALYTICSService startLogPageView:className];
                                   
                               }
                                    error:NULL];
    
    
    [UIViewController aspect_hookSelector:@selector(viewDidDisappear:)
                              withOptions:AspectPositionBefore
                               usingBlock:^(id<AspectInfo> info){
                                   
                                   //用户统计代码写在此处
                                   NSLog(@"[打点统计]:%@ viewWillDisappear",NSStringFromClass([info.instance class]));
                                   NSString *className = NSStringFromClass([info.instance class]);
                                   NSLog(@"className-->%@",className);
                                   
                                   [JANALYTICSService stopLogPageView:className];
                                   
                               }
                                    error:NULL];
    
}

#pragma mark --- 监控button的点击事件
+ (void)trackBttonEvent{
    
    __weak typeof(self) ws = self;
    
    //设置事件统计
    //放到异步线程去执行
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //读取配置文件，获取需要统计的事件列表
        NSString *path = [[NSBundle mainBundle] pathForResource:@"EventList" ofType:@"plist"];
        NSDictionary *eventStatisticsDict = [[NSDictionary alloc] initWithContentsOfFile:path];
        for (NSString *classNameString in eventStatisticsDict.allKeys) {
            //使用运行时创建类对象
            //    const char * className = [[NSString stringWithFormat:@"%@",@"homeViewController"] UTF8String];
            //    Class catMetal = objc_getClass(className);
            //    //监听页面要发送打点统计的事件
            //    [catMetal aspect_hookSelector:@selector(shareAction) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo) {
            //
            //        NSLog(@"aaaaaaaaa");
            //    } error:NULL];
            const char * className = [[NSString stringWithFormat:@"%@",classNameString] UTF8String];
            //从一个字串返回一个类(info.plist中控制器的名称)
            Class newClass = objc_getClass(className);
            
            NSArray *pageEventList = [eventStatisticsDict objectForKey:classNameString];
            for (NSDictionary *eventDict in pageEventList) {
                //事件方法名称
                NSString *eventMethodName = eventDict[@"MethodName"];
                SEL seletor = NSSelectorFromString(eventMethodName);
                NSString *eventId = eventDict[@"EventId"];
                
                
                
                if ([eventMethodName isEqualToString:@"tableView:didSelectRowAtIndexPath:"]) {
                    [ws trackTableViewEventWithClass:newClass selector:seletor eventID:eventId];
                }else{
                    [ws trackEventWithClass:newClass selector:seletor eventID:eventId];
                    
                    [ws trackParameterEventWithClass:newClass selector:seletor eventID:eventId];
                }
                
            }
        }
    });
}

#pragma mark -- 监控button和tap点击事件(不带参数)
+ (void)trackEventWithClass:(Class)klass selector:(SEL)selector eventID:(NSString*)eventID{
    
    [klass aspect_hookSelector:selector withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
        
        NSString *className = NSStringFromClass([aspectInfo.instance class]);
        NSLog(@"className--->%@",className);
        NSLog(@"event----->%@",eventID);
        
        JANALYTICSCountEvent * event = [[JANALYTICSCountEvent alloc] init];
        
        event.eventID = eventID;
        
        event.extra = @{@"MethodName":@"shareAction"};
        
        [JANALYTICSService eventRecord:event];
        
        
        if ([eventID isEqualToString:@"xxx"]) {
            
        }else{
            
        }
        
    } error:NULL];
}


#pragma mark -- 监控button和tap点击事件（带参数）
+ (void)trackParameterEventWithClass:(Class)klass selector:(SEL)selector eventID:(NSString*)eventID{
    
    [klass aspect_hookSelector:selector withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo,UIButton *button) {
        
        NSLog(@"button---->%@",button);
        NSString *className = NSStringFromClass([aspectInfo.instance class]);
        NSLog(@"className--->%@",className);
        NSLog(@"event----->%@",eventID);
        
    } error:NULL];
}


#pragma mark -- 监控tableView的点击事件
+ (void)trackTableViewEventWithClass:(Class)klass selector:(SEL)selector eventID:(NSString*)eventID{
    
    [klass aspect_hookSelector:selector withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo,NSSet *touches, UIEvent *event) {
        
        NSString *className = NSStringFromClass([aspectInfo.instance class]);
        NSLog(@"className--->%@",className);
        NSLog(@"event----->%@",eventID);
        NSLog(@"section---->%@",[event valueForKeyPath:@"section"]);
        NSLog(@"row---->%@",[event valueForKeyPath:@"row"]);
        NSInteger section = [[event valueForKeyPath:@"section"]integerValue];
        NSInteger row = [[event valueForKeyPath:@"row"]integerValue];
        
        if ([className isEqualToString:@""]) {
            
        }
        
        JANALYTICSCountEvent * Countevent = [[JANALYTICSCountEvent alloc] init];
        
        Countevent.eventID = eventID;
        
//        Countevent.extra = @{@"MethodName":@"shareAction"};
        
        [JANALYTICSService eventRecord:Countevent];
    
        
    } error:NULL];
}
@end
