//
//  RequestTool.h
//  CorrectLocalTime
//
//  Created by Flow on 3/28/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RequestTool : NSObject
+ (void)requestWithGETUrl:(NSString *)url parameters:(NSDictionary *)parameters;
+ (void)requestWithPostUrl:(NSString *)url parameters:(NSDictionary *)parameters;
+ (void)requestDate;
@end

NS_ASSUME_NONNULL_END
