//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSRESTClientCompletionProxyFactory.h"
#import "EMSRESTClient.h"
#import "EMSRequestFactory.h"

@class EMSContactTokenResponseHandler;
@class EMSStorage;

@interface EMSCompletionProxyFactory : EMSRESTClientCompletionProxyFactory

- (instancetype)initWithRequestRepository:(id <EMSRequestModelRepositoryProtocol>)requestRepository
                           operationQueue:(NSOperationQueue *)operationQueue
                      defaultSuccessBlock:(CoreSuccessBlock)defaultSuccessBlock
                        defaultErrorBlock:(CoreErrorBlock)defaultErrorBlock
                               restClient:(EMSRESTClient *)restClient
                           requestFactory:(EMSRequestFactory *)requestFactory
                   contactResponseHandler:(EMSContactTokenResponseHandler *)contactResponseHandler
                                 endpoint:(EMSEndpoint *)endpoint
                                  storage:(id<EMSStorageProtocol>)storage;

@end