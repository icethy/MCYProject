//
//  MCYRequestManager.m
//  MCYProject
//
//  Created by machunyan on 2017/8/28.
//  Copyright © 2017年 马春燕. All rights reserved.
//

#import "MCYRequestManager.h"
#import "AFNetworking.h"
#import "NetConfiguration.h"
#import "MCYRequest.h"
#import "MCYRequestErrorHander.h"

#import <pthread/pthread.h>
#import "MCYMD5Util.h"

NSString *NetStatusChangeNotification = @"net_status_change_noti";
NSString *NetStatusChangeStatusKey = @"net_status_change_key";

@interface MCYRequestManager ()
{
    AFURLSessionManager * manager;
    AFJSONResponseSerializer *jsonResponseSerializer;
    AFXMLParserResponseSerializer *xmlParserResponseSerialzier;
    
    NSMutableDictionary<NSNumber *, MCYRequest *> *requestsRecord;
    
    dispatch_queue_t recordQueue;
    
}

@property (nonatomic,assign) MCYNetStatus netStatus;

@end

@implementation MCYRequestManager

- (MCYNetStatus)currentStatus
{
    return self.netStatus;
}

- (BOOL)reachable
{
    return self.netStatus == MCYNetStatusWIFI || self.netStatus == MCYNetStatusWWAN;
}

+ (MCYRequestManager*)sharedManager
{
    static dispatch_once_t onceToken;
    static MCYRequestManager * manager;
    dispatch_once(&onceToken, ^{
        manager = [[MCYRequestManager alloc] init];
    });
    return manager;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.completionQueue = dispatch_queue_create("MCYRequestCompletionQueue", DISPATCH_QUEUE_CONCURRENT);
        WeakSelf(self);
        [manager.reachabilityManager startMonitoring];
        [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusUnknown:
                    weakself.netStatus = MCYNetStatusUnKnown;
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                    weakself.netStatus = MCYNetStatusNotReachable;
                    break;
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    weakself.netStatus = MCYNetStatusWIFI;
                    break;
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    weakself.netStatus = MCYNetStatusWWAN;
                    break;
            }
            NSDictionary *userInfo = @{
                                       NetStatusChangeStatusKey:@(weakself.netStatus)
                                       };
            [[NSNotificationCenter defaultCenter] postNotificationName:NetStatusChangeNotification object:nil userInfo:userInfo];
        }];
        
        jsonResponseSerializer = [AFJSONResponseSerializer serializer];
        xmlParserResponseSerialzier = [AFXMLParserResponseSerializer serializer];
        requestsRecord = [NSMutableDictionary dictionary];
        
        recordQueue = dispatch_queue_create("recordDictionaryQueue", DISPATCH_QUEUE_SERIAL);
        
    }
    
    return self;
}


- (void)addRequest:(MCYRequest *)request
{
    NSError * error;
    request.requestTask = [self sessionTaskForRequest:request error:&error];
    if (error) {
        [self requestDidFailWithRequest:request error:error];
        return;
    }
    [self addRequestToRecord:request];
    [request.requestTask resume];
    
}

- (void)cancelRequest:(MCYRequest *)request
{
    [request.requestTask cancel];
    [self removeRequestFromRecord:request];
    [request clearCompletionBlock];
}

- (void)cancelAllRequest
{
    
}

- (void)addRequestToRecord:(MCYRequest *)request
{
    dispatch_sync(recordQueue, ^{
        requestsRecord[@(request.requestTask.taskIdentifier)] = request;
    });
    
}

- (void)removeRequestFromRecord:(MCYRequest *)request
{
    dispatch_sync(recordQueue, ^{
        [requestsRecord removeObjectForKey:@(request.requestTask.taskIdentifier)];
    });
}

- (NSURLSessionTask *)sessionTaskForRequest:(MCYRequest *)request error:(NSError * _Nullable __autoreleasing *)error
{
    MCYRequestMethod method = request.requestMethod;
    NSString *basePath = request.requestBaseUrl ? request.requestBaseUrl : baseUrl;
    NSString *url = [basePath stringByAppendingString:request.requestPath];
    id param = request.requestParamater;
    AFHTTPRequestSerializer *requestSerializer = [self requestSerializerForRequest:request];
    AFConstructingBlock constructingBlock = [request constructingBodyBlock];
    switch (method) {
        case MCYRequestMethodGet:
            if (request.reuseDownloadPath) {
                return [self downloadTaskWithDownloadPath:request.reuseDownloadPath requestSerializer:requestSerializer URLString:url parameters:param progress:request.downloadProgress error:error];
            } else {
                return [self dataTaskWithHTTPMethod:@"GET" requestSerializer:requestSerializer URLString:url parameters:param error:error];
            }
        case MCYRequestMethodPost:
            return [self dataTaskWithHTTPMethod:@"POST" requestSerializer:requestSerializer URLString:url parameters:param constructingBodyWithBlock:constructingBlock error:error];
        case MCYRequestMethodHead:
            return [self dataTaskWithHTTPMethod:@"HEAD" requestSerializer:requestSerializer URLString:url parameters:param error:error];
        case MCYRequestMethodPut:
            return [self dataTaskWithHTTPMethod:@"PUT" requestSerializer:requestSerializer URLString:url parameters:param error:error];
        case MCYRequestMethodDelete:
            return [self dataTaskWithHTTPMethod:@"DELETE" requestSerializer:requestSerializer URLString:url parameters:param error:error];
            
    }
    
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                               requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                           error:(NSError * _Nullable __autoreleasing *)error
{
    return [self dataTaskWithHTTPMethod:method requestSerializer:requestSerializer URLString:URLString parameters:parameters constructingBodyWithBlock:nil error:error];
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                               requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                       constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block
                                           error:(NSError * _Nullable __autoreleasing *)error

{
    NSMutableURLRequest *request = nil;
    
    if (block) {
        request = [requestSerializer multipartFormRequestWithMethod:method URLString:URLString parameters:parameters constructingBodyWithBlock:block error:error];
    } else {
        request = [requestSerializer requestWithMethod:method URLString:URLString parameters:parameters error:error];
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        [self handleRequestResult:dataTask responseObject:responseObject error:error];
    }];
    
    
    return dataTask;
}

- (NSURLSessionDownloadTask *)downloadTaskWithDownloadPath:(NSString *)downloadPath
                                         requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                                 URLString:(NSString *)URLString
                                                parameters:(id)parameters
                                                  progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                                     error:(NSError * _Nullable __autoreleasing *)error
{
    // add parameters to URL;
    NSMutableURLRequest *urlRequest = [requestSerializer requestWithMethod:@"GET" URLString:URLString parameters:parameters error:error];
    
    NSString *downloadTargetPath;
    BOOL isDirectory;
    if(![[NSFileManager defaultManager] fileExistsAtPath:downloadPath isDirectory:&isDirectory]) {
        isDirectory = NO;
    }
    // If targetPath is a directory, use the file name we got from the urlRequest.
    // Make sure downloadTargetPath is always a file, not directory.
    if (isDirectory) {
        NSString *fileName = [urlRequest.URL lastPathComponent];
        downloadTargetPath = [NSString pathWithComponents:@[downloadPath, fileName]];
    } else {
        downloadTargetPath = downloadPath;
    }
    
    // AFN use `moveItemAtURL` to move downloaded file to target path,
    // this method aborts the move attempt if a file already exist at the path.
    // So we remove the exist file before we start the download task.
    // https://github.com/AFNetworking/AFNetworking/issues/3775
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadTargetPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:downloadTargetPath error:nil];
    }
    
    BOOL resumeDataFileExists = [[NSFileManager defaultManager] fileExistsAtPath:[self incompleteDownloadTempPathForDownloadPath:downloadPath].path];
    NSData *data = [NSData dataWithContentsOfURL:[self incompleteDownloadTempPathForDownloadPath:downloadPath]];
    
    BOOL canBeResumed = resumeDataFileExists;
    BOOL resumeSucceeded = NO;
    __block NSURLSessionDownloadTask *downloadTask = nil;
    // Try to resume with resumeData.
    // Even though we try to validate the resumeData, this may still fail and raise excecption.
    if (canBeResumed) {
        @try {
            downloadTask = [manager downloadTaskWithResumeData:data progress:downloadProgressBlock destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                return [NSURL fileURLWithPath:downloadTargetPath isDirectory:NO];
            } completionHandler:
                            ^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                [self handleRequestResult:downloadTask responseObject:filePath error:error];
                            }];
            resumeSucceeded = YES;
        } @catch (NSException *exception) {
            resumeSucceeded = NO;
        }
    }
    if (!resumeSucceeded) {
        downloadTask = [manager downloadTaskWithRequest:urlRequest progress:downloadProgressBlock destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [NSURL fileURLWithPath:downloadTargetPath isDirectory:NO];
        } completionHandler:
                        ^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                            [self handleRequestResult:downloadTask responseObject:filePath error:error];
                        }];
    }
    return downloadTask;
}


- (AFHTTPRequestSerializer *)requestSerializerForRequest:(MCYRequest *)request
{
    AFHTTPRequestSerializer *requestSerializer = nil;
    if (request.requestSerializerType == MCYResponseSerializerTypeHTTP) {
        requestSerializer = [AFHTTPRequestSerializer serializer];
    } else if (request.requestSerializerType == MCYRequestSerializerTypeJSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    }
    requestSerializer.timeoutInterval = request.requestTimeOut;
    
    return requestSerializer;
}


- (void)handleRequestResult:(NSURLSessionTask *)task responseObject:(id)responseObject error:(NSError *)error
{
    
    MCYRequest *request = requestsRecord[@(task.taskIdentifier)];
    if (!request) {
        return;
    }
    
    NSError * __autoreleasing serializationError = nil;
    
    NSError *requestError = nil;
    BOOL succeed = YES;
    
    request.responseObject = responseObject;
    if ([request.responseObject isKindOfClass:[NSData class]]) {
        request.responseData = responseObject;
        
        switch (request.responseSerializerType) {
            case MCYResponseSerializerTypeHTTP:
                // Default serializer. Do nothing.
                break;
            case MCYResponseSerializerTypeJSON:
                request.responseObject = [jsonResponseSerializer responseObjectForResponse:task.response data:request.responseData error:&serializationError];
                break;
            case MCYResponseSerializerTypeXMLParser:
                request.responseObject = [xmlParserResponseSerialzier responseObjectForResponse:task.response data:request.responseData error:&serializationError];
                break;
        }
    }
    
    
    if (error) {
        succeed = NO;
        requestError = error;
    } else if (serializationError) {
        succeed = NO;
        requestError = serializationError;
    } else {
        NSError * error = [[MCYRequestErrorHander sharedHander] checkRequestResponse:request.responseObject];
        succeed = error == nil;
        requestError = error;
    }
    
    if (succeed) {
        [self requestDidSucceedWithRequest:request];
    } else {
        [self requestDidFailWithRequest:request error:requestError];
    }
    
    [self removeRequestFromRecord:request];
}

- (void)requestDidSucceedWithRequest:(MCYRequest *)request
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (request.successCompletionBlock) {
            request.successCompletionBlock(request);
        }
        
    });
}


- (void)requestDidFailWithRequest:(MCYRequest *)request error:(NSError *)error
{
    request.error = error;
    // Save incomplete download data.
    //    NSData *incompleteDownloadData = error.userInfo[NSURLSessionDownloadTaskResumeData];
    //    if (incompleteDownloadData) {
    //        [incompleteDownloadData writeToURL:[self incompleteDownloadTempPathForDownloadPath:request.resumableDownloadPath] atomically:YES];
    //    }
    
    // Load response from file and clean up if download task failed.
    if ([request.responseObject isKindOfClass:[NSURL class]]) {
        NSURL *url = request.responseObject;
        if (url.isFileURL && [[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
            request.responseData = [NSData dataWithContentsOfURL:url];
            //            request.responseString = [[NSString alloc] initWithData:request.responseData encoding:[YTKNetworkUtils stringEncodingWithRequest:request]];
            
            [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        }
        request.responseObject = nil;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (request.failureCompletionBlock) {
            request.failureCompletionBlock(request);
        }
    });
}

- (NSString *)incompleteDownloadTempCacheFolder
{
    NSFileManager *fileManager = [NSFileManager new];
    static NSString *cacheFolder;
    
    if (!cacheFolder) {
        NSString *cacheDir = NSTemporaryDirectory();
        cacheFolder = [cacheDir stringByAppendingPathComponent:@"MCYIncomplete"];
    }
    
    NSError *error = nil;
    if(![fileManager createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&error]) {
        cacheFolder = nil;
    }
    return cacheFolder;
}

- (NSURL *)incompleteDownloadTempPathForDownloadPath:(NSString *)downloadPath
{
    NSString *tempPath = nil;
    NSString *md5URLString = [MCYMD5Util MD5ForLower32Bate:downloadPath];
    tempPath = [[self incompleteDownloadTempCacheFolder] stringByAppendingPathComponent:md5URLString];
    return [NSURL fileURLWithPath:tempPath];
}

@end
