//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@class EMSRequestModel;
@class MERequestContext;
@class EMSDeviceInfo;
@class EMSEndpoint;
@class MEButtonClickRepository;
@class EMSSessionIdHolder;
@protocol EMSStorageProtocol;

typedef enum {
    EventTypeInternal,
    EventTypeCustom
} EventType;

NS_ASSUME_NONNULL_BEGIN

@interface EMSRequestFactory : NSObject

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext
                              endpoint:(EMSEndpoint *)endpoint
                 buttonClickRepository:(MEButtonClickRepository *)buttonClickRepository
                       sessionIdHolder:(EMSSessionIdHolder *)sessionIdHolder
                               storage:(id<EMSStorageProtocol>)storage;

- (EMSRequestModel *)createDeviceInfoRequestModel;

- (EMSRequestModel *)createPushTokenRequestModelWithPushToken:(NSString *)pushToken;

- (EMSRequestModel *)createClearPushTokenRequestModel;

- (EMSRequestModel *)createContactRequestModel;

- (EMSRequestModel *)createEventRequestModelWithEventName:(NSString *)eventName
                                          eventAttributes:(nullable NSDictionary<NSString *, NSString *> *)eventAttributes
                                                eventType:(EventType)eventType;

- (EMSRequestModel *)createRefreshTokenRequestModel;

- (EMSRequestModel *)createDeepLinkRequestModelWithTrackingId:(NSString *)trackingId;

- (EMSRequestModel *)createGeofenceRequestModel;

- (EMSRequestModel *)createMessageInboxRequestModel;

- (EMSRequestModel *)createInlineInappRequestModelWithViewId:(NSString *)viewId;

@end

NS_ASSUME_NONNULL_END