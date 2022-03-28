//
//  NSDate+Diff.m
//  CorrectLocalTime
//
//  Created by Flow on 3/28/22.
//

#import "NSDate+Diff.h"

@implementation NSDate (Diff)

/// 获取使用了服务器校验后的时间
+ (NSDate *)diff_now {
    NSDate *localDate = [NSDate date];
    if (_diff_distanceLocalWithServer == 0) {
        return localDate;
    }
    NSDate *now = [localDate dateByAddingTimeInterval:_diff_distanceLocalWithServer];
    return now;
}


+ (void)diff_updateDateDiffWithResponse:(NSURLResponse * __nullable)response {
    if (![response isKindOfClass:NSHTTPURLResponse.class]) {
        return;
    }
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    // 请求到达服务器时的服务器时间
    NSString *dateServer = [httpResponse.allHeaderFields objectForKey:@"Date"];
    if (dateServer == nil) {
        return;
    }
    if (![dateServer isKindOfClass:NSString.class]) {
        return;
    }
    // 服务器时间字符串转换为Date
    NSDate *inputDate = [NSDate diff_dateFromRFC822String:dateServer];
    if (inputDate == nil) {
        return;
    }
    // 本地时间
    NSDate *localDate = [NSDate date];
    // 服务器时间与本地时间之间的误差
    NSTimeInterval distance = [inputDate timeIntervalSinceDate:localDate];
    if (distance < -5 || distance > 5) {
        // 将本地时间与服务器之间的时间差保存
        [self diff_updateDistance:distance];
    }
}

#pragma mark - 保存时间偏移量

+ (void)diff_updateDistance:(NSTimeInterval)distance {
    _diff_distanceLocalWithServer = distance;
    _diff_str_distanceLocalWithServer = [NSString stringWithFormat:@"%f",distance];
}
+ (NSString *)diff_get_distanceStr {
    return _diff_str_distanceLocalWithServer;
}
// 服务器时间与本地时间的偏移
static NSTimeInterval _diff_distanceLocalWithServer = 0;
static NSString *_diff_str_distanceLocalWithServer = @"unkown";
#pragma mark - 时间转换工具
/**
 将header里的标准服务区时间转换为本地时间
 */
+ (NSDate *)diff_dateFromRFC822String:(NSString *)dateString {
     // Keep dateString around a while (for thread-safety)
    NSDate *date = nil;
    if (dateString) {
        NSDateFormatter *dateFormatter = [NSDate diff_internetDateTimeFormatter];
        @synchronized(dateFormatter) {

            // Process
            NSString *RFC822String = [[NSString stringWithString:dateString] uppercaseString];
            if ([RFC822String rangeOfString:@","].location != NSNotFound) {
                if (!date) { // Sun, 19 May 2002 15:21:36 GMT
                    [dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss zzz"];
                    date = [dateFormatter dateFromString:RFC822String];
                }
                if (!date) { // Sun, 19 May 2002 15:21 GMT
                    [dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm zzz"];
                    date = [dateFormatter dateFromString:RFC822String];
                }
                if (!date) { // Sun, 19 May 2002 15:21:36
                    [dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss"];
                    date = [dateFormatter dateFromString:RFC822String];
                }
                if (!date) { // Sun, 19 May 2002 15:21
                    [dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm"];
                    date = [dateFormatter dateFromString:RFC822String];
                }
            } else {
                if (!date) { // 19 May 2002 15:21:36 GMT
                    [dateFormatter setDateFormat:@"d MMM yyyy HH:mm:ss zzz"];
                    date = [dateFormatter dateFromString:RFC822String];
                }
                if (!date) { // 19 May 2002 15:21 GMT
                    [dateFormatter setDateFormat:@"d MMM yyyy HH:mm zzz"];
                    date = [dateFormatter dateFromString:RFC822String];
                }
                if (!date) { // 19 May 2002 15:21:36
                    [dateFormatter setDateFormat:@"d MMM yyyy HH:mm:ss"];
                    date = [dateFormatter dateFromString:RFC822String];
                }
                if (!date) { // 19 May 2002 15:21
                    [dateFormatter setDateFormat:@"d MMM yyyy HH:mm"];
                    date = [dateFormatter dateFromString:RFC822String];
                }
            }
            if (!date) NSLog(@"Could not parse RFC822 date: \"%@\" Possible invalid format.", dateString);
            
        }
    }
     // Finished with date string
    return date;
}
/**
 * 服务器时间转换为时间的格式format
 */
static NSDateFormatter *_diff_internetDateTimeFormatter = nil;
+ (NSDateFormatter *)diff_internetDateTimeFormatter {
    @synchronized(self) {
        if (!_diff_internetDateTimeFormatter) {
            NSLocale *en_US_POSIX = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            _diff_internetDateTimeFormatter = [[NSDateFormatter alloc] init];
            [_diff_internetDateTimeFormatter setLocale:en_US_POSIX];
            [_diff_internetDateTimeFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        }
    }
    return _diff_internetDateTimeFormatter;
}
@end
