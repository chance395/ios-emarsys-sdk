//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSRESTClient.h"
#import "NSURLRequest+EMSCore.h"
#import "NSError+EMSCore.h"
#import "EMSResponseModel.h"
#import "EMSTimestampProvider.h"
#import "EMSMacros.h"
#import "EMSRequestModelMapperProtocol.h"
#import "EMSAbstractResponseHandler.h"
#import "EMSRequestLog.h"
#import "EMSStatusLog.h"
#import "EMSResponseBodyParserProtocol.h"

@interface EMSRESTClient () <NSURLSessionDelegate>

@property(nonatomic, strong) CoreSuccessBlock successBlock;
@property(nonatomic, strong) CoreErrorBlock errorBlock;
@property(nonatomic, strong) NSURLSession *session;
@property(nonatomic, strong) NSOperationQueue *queue;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;

@end

@implementation EMSRESTClient

- (instancetype)initWithSession:(NSURLSession *)session
                          queue:(NSOperationQueue *)queue
              timestampProvider:(EMSTimestampProvider *)timestampProvider
              additionalHeaders:(nullable NSDictionary<NSString *, NSString *> *)additionalHeaders
            requestModelMappers:(nullable NSArray<id <EMSRequestModelMapperProtocol>> *)requestModelMappers
               responseHandlers:(nullable NSArray<EMSAbstractResponseHandler *> *)responseHandlers
         mobileEngageBodyParser:(id <EMSResponseBodyParserProtocol>)mobileEngageBodyParser {
    NSParameterAssert(session);
    NSParameterAssert(queue);
    NSParameterAssert(timestampProvider);
    NSParameterAssert(mobileEngageBodyParser);
    if (self = [super init]) {
        _session = session;
        _queue = queue;
        _timestampProvider = timestampProvider;
        _additionalHeaders = additionalHeaders;
        _requestModelMappers = requestModelMappers;
        _responseHandlers = responseHandlers;
        _mobileEngageBodyParser = mobileEngageBodyParser;
    }
    return self;
}

- (void)executeWithRequestModel:(EMSRequestModel *)requestModel
            coreCompletionProxy:(id <EMSRESTClientCompletionProxyProtocol>)completionProxy {
    NSParameterAssert(requestModel);
    NSParameterAssert((NSObject *) completionProxy);

    NSDate *networkingStartTime = [self.timestampProvider provideTimestamp];

    EMSRequestModel *finalizedRequestModel = [self finalizeRequestModel:requestModel];
    NSURLRequest *request = [NSURLRequest requestWithRequestModel:finalizedRequestModel];

    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                     [weakSelf.queue addOperationWithBlock:^{
                                                         NSError *runtimeError = [weakSelf errorWithData:data
                                                                                                response:response
                                                                                                   error:error];
                                                         NSHTTPURLResponse *httpUrlResponse = (NSHTTPURLResponse *) response;

                                                         id responseParsedBody = nil;
                                                         if ([self.mobileEngageBodyParser shouldParse:requestModel
                                                                                         responseBody:data
                                                                                      httpUrlResponse:httpUrlResponse]) {
                                                             responseParsedBody = [self.mobileEngageBodyParser parseWithRequestModel:requestModel
                                                                                                                        responseBody:data];
                                                         }

                                                         EMSResponseModel *responseModel = [[EMSResponseModel alloc] initWithStatusCode:[httpUrlResponse statusCode]
                                                                                                                                headers:[httpUrlResponse allHeaderFields]
                                                                                                                                   body:data
                                                                                                                             parsedBody:responseParsedBody
                                                                                                                           requestModel:requestModel
                                                                                                                              timestamp:[weakSelf.timestampProvider provideTimestamp]];
                                                         [weakSelf handleResponse:responseModel];

                                                         EMSLog([[EMSRequestLog alloc] initWithResponseModel:responseModel
                                                                                         networkingStartTime:networkingStartTime
                                                                                                     headers:finalizedRequestModel.headers
                                                                                                     payload:finalizedRequestModel.payload], LogLevelDebug);

                                                         EMSStrictLog([[EMSRequestLog alloc] initWithResponseModel:responseModel
                                                                                               networkingStartTime:networkingStartTime
                                                                                                           headers:nil
                                                                                                           payload:nil], LogLevelInfo);
                                                         if (error && requestModel) {
                                                             NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                                                             parameters[@"requestModel"] = requestModel.description;
                                                             NSMutableDictionary *status = [NSMutableDictionary dictionary];
                                                             status[@"error"] = error.localizedDescription;
                                                             EMSLog([[EMSStatusLog alloc] initWithClass:[self class]
                                                                                                    sel:_cmd
                                                                                             parameters:parameters
                                                                                                 status:status], LogLevelDebug)
                                                         }
                                                         if (completionProxy.completionBlock) {
                                                             completionProxy.completionBlock(requestModel, responseModel, runtimeError);
                                                         }
                                                     }];
                                                 }];
    [task resume];
}

- (NSError *)errorWithData:(NSData *)data
                  response:(NSURLResponse *)response
                     error:(NSError *)error {
    NSError *runtimeError = error;
    if (!error) {
        if (!data) {
            runtimeError = [NSError errorWithCode:1500
                             localizedDescription:@"Missing data"];
        }
        if (!response) {
            runtimeError = [NSError errorWithCode:1500
                             localizedDescription:@"Missing response"];
        }
    }
    return runtimeError;
}

- (EMSRequestModel *)finalizeRequestModel:(EMSRequestModel *)requestModel {
    EMSRequestModel *resultModel = [self extendRequestModelWithAdditionalHeaders:requestModel];
    for (id modelMapper in self.requestModelMappers) {
        if ([modelMapper shouldHandleWithRequestModel:resultModel]) {
            resultModel = [modelMapper modelFromModel:resultModel];
        }
    }
    return resultModel;
}

- (EMSRequestModel *)extendRequestModelWithAdditionalHeaders:(EMSRequestModel *)requestModel {
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:requestModel.headers];
    [headers addEntriesFromDictionary:self.additionalHeaders];
    return [[EMSRequestModel alloc] initWithRequestId:requestModel.requestId
                                            timestamp:requestModel.timestamp
                                               expiry:requestModel.ttl
                                                  url:requestModel.url
                                               method:requestModel.method
                                              payload:requestModel.payload
                                              headers:[NSDictionary dictionaryWithDictionary:headers]
                                               extras:requestModel.extras];
}

- (void)handleResponse:(EMSResponseModel *)responseModel {
    for (EMSAbstractResponseHandler *handler in self.responseHandlers) {
        [handler processResponse:responseModel];
    }
}

@end

