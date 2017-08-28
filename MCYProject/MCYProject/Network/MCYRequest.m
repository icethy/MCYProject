//
//  MCYRequest.m
//  MCYProject
//
//  Created by machunyan on 2017/8/28.
//  Copyright © 2017年 马春燕. All rights reserved.
//

#import "MCYRequest.h"
#import "MCYRequestManager.h"

@interface MCYRequest ()

@end

@implementation MCYRequest

+ (instancetype)request
{
    return [[MCYRequest alloc] init];
}

+ (instancetype)downloadRequestWithUrl:(NSString *)url
                       destinationPath:(NSString *)path
                              progress:(resumableDownloadProgressBlock)progress
{
    MCYRequest * request = [self request];
    request.requestMethod = MCYRequestMethodGet;
    request.requestBaseUrl = @"";
    request.requestPath = url;
    request.reuseDownloadPath = path;
    request.downloadProgress = progress;
    request.responseSerializerType = MCYResponseSerializerTypeHTTP;
    return request;
}

+ (instancetype)postRequestWithPath:(NSString *)path paramater:(id)paramater
{
    MCYRequest * request = [self request];
    request.requestPath = path;
    request.requestParamater = paramater;
    return request;
}

+ (instancetype)getRequestWithPath:(NSString *)path paramater:(id)paramater
{
    MCYRequest * request = [MCYRequest request];
    request.requestMethod = MCYRequestMethodGet;
    request.requestPath = path;
    request.requestParamater = paramater;
    return request;
}

+ (instancetype)uploadRequestWithPath:(NSString *)path
                            paramater:(id _Nullable)paramater
                                 data:(AFConstructingBlock _Nullable)block
{
    MCYRequest * request = [MCYRequest request];
    request.requestMethod = MCYRequestMethodPost;
    request.requestPath = path;
    request.requestParamater = paramater;
    request.constructingBodyBlock = block;
    return request;
}

- (id)init
{
    self = [super init];
    if (self) {
        _requestMethod = MCYRequestMethodPost;
        _responseSerializerType = MCYResponseSerializerTypeJSON;
        _requestTimeOut = 30;
        
    }
    return self;
}

- (NSInteger)responseStatusCode
{
    return self.response.statusCode;
}

- (NSHTTPURLResponse *)response
{
    return (NSHTTPURLResponse *)self.requestTask.response;
}

- (BOOL)isCancelled
{
    if (!self.requestTask) {
        return NO;
    }
    return self.requestTask.state == NSURLSessionTaskStateCanceling;
}

- (BOOL)isExecuting
{
    if (!self.requestTask) {
        return NO;
    }
    return self.requestTask.state == NSURLSessionTaskStateRunning;
}


- (void)start
{
    [[MCYRequestManager sharedManager] addRequest:self];
}

- (void)stop
{
    [[MCYRequestManager sharedManager] cancelRequest:self];
}

- (void)startWithCompletionBlockWithSuccess:(MCYRequestCompletionBlock)success failure:(MCYRequestCompletionBlock)failure
{
    [self setCompletionBlockWithSuccess:success failure:failure];
    [self start];
}

- (void)setCompletionBlockWithSuccess:(MCYRequestCompletionBlock)success
                              failure:(MCYRequestCompletionBlock)failure
{
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
}

- (void)clearCompletionBlock
{
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}

@end
