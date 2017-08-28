//
//  MCYRequest.h
//  MCYProject
//
//  Created by machunyan on 2017/8/28.
//  Copyright © 2017年 马春燕. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MCYRequestMethod) {
    MCYRequestMethodPost,//default
    MCYRequestMethodGet,
    MCYRequestMethodPut,
    MCYRequestMethodHead,
    MCYRequestMethodDelete
};

typedef NS_ENUM(NSInteger, MCYRequestSerializerType) {
    MCYRequestSerializerTypeHTTP = 0,
    MCYRequestSerializerTypeJSON,
};


typedef NS_ENUM(NSInteger, MCYResponseSerializerType) {
    MCYResponseSerializerTypeHTTP,
    MCYResponseSerializerTypeJSON,//default
    MCYResponseSerializerTypeXMLParser,
};

@class MCYRequest;
@protocol AFMultipartFormData;

typedef void(^MCYRequestCompletionBlock)(MCYRequest * _Nullable request);
typedef void(^resumableDownloadProgressBlock)(NSProgress * _Nullable progress);
typedef void (^AFConstructingBlock)(id<AFMultipartFormData> _Nullable formData);

@interface MCYRequest : NSObject

@property (nonatomic, strong) NSURLSessionTask * _Nullable requestTask;

@property (nonatomic, strong, readonly) NSHTTPURLResponse * _Nullable response;

@property (nonatomic, strong) id _Nullable responseObject;

@property (nonatomic, strong) NSData * _Nullable responseData;

@property (nonatomic, assign, readonly) NSInteger responseStatusCode;

@property (nonatomic, strong) NSError * _Nullable error;

@property (nonatomic, readonly, getter=isCancelled) BOOL cancelled;

@property (nonatomic, readonly, getter=isExecuting) BOOL executing;

@property (nonatomic, copy, nullable) MCYRequestCompletionBlock successCompletionBlock;

@property (nonatomic, copy, nullable) MCYRequestCompletionBlock failureCompletionBlock;

@property (nonatomic,copy) resumableDownloadProgressBlock _Nullable downloadProgress;

@property (nonatomic,copy) NSString * _Nullable reuseDownloadPath;//下载 地址

@property (nonatomic,assign) MCYRequestMethod requestMethod;

@property (nonatomic,assign) MCYResponseSerializerType responseSerializerType;

@property (nonatomic,assign) MCYRequestSerializerType requestSerializerType;

@property (nonatomic,copy) NSString * _Nullable requestPath;

@property (nonatomic,copy) NSString * _Nullable requestBaseUrl;//自定义baseURL

@property (nonatomic,assign) NSTimeInterval requestTimeOut;

@property (nonatomic,copy) id _Nullable requestParamater;

///  This can be use to construct HTTP body when needed in POST request. Default is nil.
@property (nonatomic, copy, nullable) AFConstructingBlock constructingBodyBlock;


+ (instancetype _Nullable )request;

+ (instancetype _Nullable )getRequestWithPath:(NSString*_Nullable)path
                                    paramater:(id _Nullable )paramater;

+ (instancetype _Nullable )postRequestWithPath:(NSString*_Nullable)path
                                     paramater:(id _Nullable )paramater;

+ (instancetype _Nullable )downloadRequestWithUrl:(NSString*_Nullable)url
                                  destinationPath:(NSString*_Nullable)path
                                         progress:(resumableDownloadProgressBlock _Nullable )progress;

+ (instancetype _Nullable )uploadRequestWithPath:(NSString*_Nullable)path
                                       paramater:(id _Nullable )paramater
                                            data:(AFConstructingBlock _Nullable )block;

- (void)start;

- (void)stop;

- (void)startWithCompletionBlockWithSuccess:(nullable MCYRequestCompletionBlock)success
                                    failure:(nullable MCYRequestCompletionBlock)failure;

- (void)setCompletionBlockWithSuccess:(nullable MCYRequestCompletionBlock)success
                              failure:(nullable MCYRequestCompletionBlock)failure;

- (void)clearCompletionBlock;


@end
