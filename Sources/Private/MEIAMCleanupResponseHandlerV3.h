//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSAbstractResponseHandler.h"
#import "MEButtonClickRepository.h"
#import "MEDisplayedIAMRepository.h"
#import "EMSEndpoint.h"

@interface MEIAMCleanupResponseHandlerV3 : EMSAbstractResponseHandler

- (instancetype)initWithButtonClickRepository:(MEButtonClickRepository *)buttonClickRepository
                         displayIamRepository:(MEDisplayedIAMRepository *)displayedIAMRepository
                                     endpoint:(EMSEndpoint *)endpoint;

@end