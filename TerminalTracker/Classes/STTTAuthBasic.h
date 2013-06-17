//
//  STTTAuthBasic.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 6/17/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <UDPushAuth/UDOAuthBasicAbstract.h>
#import "STRequestAuthenticatable.h"

@interface STTTAuthBasic : UDOAuthBasicAbstract <STRequestAuthenticatable>

- (NSString *) reachabilityServer;
+ (id) tokenRetrieverMaker;


@end
