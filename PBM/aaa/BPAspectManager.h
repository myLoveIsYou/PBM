//
//  BPAspectManager.h
//  podtext
//
//  Created by md314 on 2019/3/5.
//  Copyright © 2019年 jfr. All rights reserved.
//

//  1.用于打点统计、统一页面等骚操作
//  2.需要统计的页面及页面中的方法可配置在info.plist文件中统一管理
//  3.根据页面逻辑不同打点统计需加其他判断
//  4.依赖Aspects 和 统计功能的第三方
#import <Foundation/Foundation.h>
#import <libkern/OSAtomic.h>
#import <objc/runtime.h>
#import "Aspects.h"
NS_ASSUME_NONNULL_BEGIN


typedef void (^usingBlock)(id block);
@interface BPAspectManager : NSObject

+(void)trackAspectHooks;

@end

NS_ASSUME_NONNULL_END
