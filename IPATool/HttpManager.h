//
//  HttpManager.h
//  YouBeiJia
//
//  Created by lll410224 on 2017/8/30.
//  Copyright © 2017年 ll. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpManager : NSObject
/**
 *  发送get请求
 *  @param URLString  请求的网址字符串
 *  @param parameters 请求的参数
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 */
+ (void)getWithURLString:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSDictionary * responseObject))success failure:(void (^)(NSError *error))failure;
/**
 *  发送post请求
 *  @param URLString  请求的网址字符串
 *  @param parameters 请求的参数
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 */
+ (void)postWithURLString:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSDictionary * responseObject))success failure:(void (^)(NSError *error))failure;
@end
