//
//  RequestTool.m
//  CorrectLocalTime
//
//  Created by Flow on 3/28/22.
//

#import "RequestTool.h"
#import <AFNetworking/AFNetworking.h>
#import "NSDate+Diff.h"

@implementation RequestTool

+ (void)requestWithGETUrl:(NSString *)url parameters:(NSDictionary *)parameters {
    [[AFHTTPSessionManager manager] GET:url parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [NSDate diff_updateDateDiffWithResponse:task.response];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [NSDate diff_updateDateDiffWithResponse:task.response];
    }];
}

+ (void)requestWithPostUrl:(NSString *)url parameters:(NSDictionary *)parameters {
    [[AFHTTPSessionManager manager] POST:url parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [NSDate diff_updateDateDiffWithResponse:task.response];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [NSDate diff_updateDateDiffWithResponse:task.response];
    }];
}

+ (void)requestDate {
    [[AFHTTPSessionManager manager] HEAD:@"https://www.baidu.com" parameters:nil headers:nil success:^(NSURLSessionDataTask * _Nonnull task) {
        [NSDate diff_updateDateDiffWithResponse:task.response];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [NSDate diff_updateDateDiffWithResponse:task.response];
    }];
    [[AFHTTPSessionManager manager] HEAD:@"https://www.google.com" parameters:nil headers:nil success:^(NSURLSessionDataTask * _Nonnull task) {
        [NSDate diff_updateDateDiffWithResponse:task.response];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [NSDate diff_updateDateDiffWithResponse:task.response];
    }];
}
@end
