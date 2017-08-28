//
//  NetConfiguration.h
//  MCYProject
//
//  Created by machunyan on 2017/8/28.
//  Copyright © 2017年 马春燕. All rights reserved.
//

#ifndef NetConfiguration_h
#define NetConfiguration_h

#define Test 1
#define Product 2

#define Env_Mode Test

#if Env_Mode == Test

#pragma mark Test
#define baseUrl @"http://"      // 此处需要替换为服务器请求地址
#define baseImageUrl @"http://" // 此处需要替换为服务器请求地址

#elif Env_Mode == Product

#pragma mark Product

#define baseUrl 3

#else

#pragma mark other
#define baseUrl 1

#endif

#endif /* NetConfiguration_h */
