//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSDependencyContainer.h"

@interface EMSDependencyInjection : NSObject

@property(class, nonatomic, readonly) id <EMSDependencyContainerProtocol> dependencyContainer;

+ (void)setupWithDependencyContainer:(id <EMSDependencyContainerProtocol>)dependencyContainer;

+ (void)tearDown;

+ (id <EMSMobileEngageProtocol>)mobileEngage;

+ (id <EMSPushNotificationProtocol>)push;

+ (id <EMSDeepLinkProtocol>)deepLink;

+ (id <EMSInAppProtocol, MEIAMProtocol>)iam;

+ (id <EMSPredictProtocol, EMSPredictInternalProtocol>)predict;

+ (id <EMSGeofenceProtocol>)geofence;

+ (id <EMSMessageInboxProtocol>)messageInbox;

+ (id <EMSOnEventActionProtocol>)onEventAction;

@end