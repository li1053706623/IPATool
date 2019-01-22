//
//  HttpManager.m
//  YouBeiJia
//
//  Created by lll410224 on 2017/8/30.
//  Copyright © 2017年 ll. All rights reserved.
//

#import "HttpManager.h"

@implementation HttpManager
+ (void)getWithURLString:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSDictionary * responseObject))success failure:(void (^)(NSError *))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // 可以接受的类型
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:  ,nil];
   
    [manager GET:URLString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            NSDictionary * dictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            success(dictionary);
        }}  failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (failure) {
                failure(error);
            }}];
}
+(void)postWithURLString:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //无条件的信任服务器上的证书

    AFSecurityPolicy *securityPolicy =  [AFSecurityPolicy defaultPolicy];
    // 客户端是否信任非法证书

    securityPolicy.allowInvalidCertificates = YES;

    // 是否在证书域字段中验证域名

    securityPolicy.validatesDomainName = NO;
    
    manager.securityPolicy = securityPolicy;
    
   
  // manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html",@"application/x-www-form-urlencoded",nil];
//   [manager.requestSerializer setValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            NSDictionary * dictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            success(dictionary);
        }}  failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (failure) {
                failure(error);
                
            }}];
}

@end
