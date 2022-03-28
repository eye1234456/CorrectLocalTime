# CorrectLocalTime
完整demo：https://github.com/eye1234456/CorrectLocalTime.git

![效果](https://github.com/eye1234456/CorrectLocalTime/raw/main/screenshots/1.png)

> 前言
开发中经常遇到在客户端做一些时间校验的场景，比如某个活动服务器设置到某个时间点才可以参与或进入，如果用户设备自己设置了与实际相差很大的时间或时区，会导致一些业务出错或参数校验失败的问题

解决方案：
>在每次请求接口时，从header里获取到比较准确的服务器时间，与本地时间进行校验，获取到本地时间与服务器时间的偏移量，然后在需要使用本地时间时，将偏移量添加到时间上

1、从接口响应体里获取服务器接口请求时的时间（以AFNetwoking为例）

```
[[AFHTTPSessionManager manager] POST:url parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [NSDate diff_updateDateDiffWithResponse:task.response];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [NSDate diff_updateDateDiffWithResponse:task.response];
    }];
```

2、拿到服务器响应后的`response`后，获取`response`的`header`里的`Date`字段并计算出于本机时间的偏移并保存到内存

```
// 服务器时间字符串转换为Date
    NSDate *inputDate = [NSDate diff_dateFromRFC822String:dateServer];
    if (inputDate == nil) {
        return;
    }
    // 本地时间
    NSDate *localDate = [NSDate date];
    // 服务器时间与本地时间之间的误差
    NSTimeInterval distance = [inputDate timeIntervalSinceDate:localDate];
```
3、在获取当前时间时，添加上偏移量

```
/// 获取使用了服务器校验后的时间
+ (NSDate *)diff_now {
    NSDate *localDate = [NSDate date];
    if (_diff_distanceLocalWithServer == 0) {
        return localDate;
    }
    NSDate *now = [localDate dateByAddingTimeInterval:_diff_distanceLocalWithServer];
    return now;
}
```
----
4、将服务器时间格式`Mon, 28 Mar 2022 08:54:31 GMT`转换为NSDate的方法

```
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
```