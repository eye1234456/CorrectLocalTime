//
//  NSDate+Diff.h
//  CorrectLocalTime
//
//  Created by Flow on 3/28/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Diff)

/// 获取使用了服务器校验后的时间
+ (NSDate *)diff_now;
/// 通过response来计算服务器时间与本机时间的偏移量
/// @param response 接口请求后收到的response
+ (void)diff_updateDateDiffWithResponse:(NSURLResponse * __nullable)response;
+ (NSString *)diff_get_distanceStr;
@end

NS_ASSUME_NONNULL_END
