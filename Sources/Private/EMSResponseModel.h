//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSRequestModel.h"

@class EMSTimestampProvider;

NS_ASSUME_NONNULL_BEGIN

@interface EMSResponseModel : NSObject

@property(nonatomic, assign) NSInteger statusCode;
@property(nonatomic, strong) NSDictionary<NSString *, NSString *> *headers;
@property(nonatomic, readonly) NSDictionary<NSString *, NSHTTPCookie *> *cookies;
@property(nonatomic, readonly) EMSRequestModel *requestModel;
@property(nonatomic, readonly) NSData *body;
@property(nonatomic, readonly) NSDate *timestamp;

- (id)initWithStatusCode:(NSInteger)statusCode
                 headers:(NSDictionary<NSString *, NSString *> *)headers
                    body:(NSData *)body
              parsedBody:(nullable id)parsedBody
            requestModel:(EMSRequestModel *)requestModel
               timestamp:(NSDate *)timestamp;

- (nullable id)parsedBody;

@end

NS_ASSUME_NONNULL_END
