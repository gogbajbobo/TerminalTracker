//
//  STTTAuthBasic.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 6/17/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STTTAuthBasic.h"
#import <UDPushAuth/UDAuthTokenRetriever.h>
#import <UDPushAuth/UDPushAuthCodeRetriever.h>
#import <UDPushAuth/UDPushAuthRequestBasic.h>

#define PUSHAUTH_SERVICE_URI @"https://uoauth.unact.ru/a/UPushAuth/"
#define AUTH_SERVICE_URI @"https://uoauth.unact.ru/a/uoauth/"
#define REACHABILITY_SERVER  @"uoauth.unact.ru"
#define AUTH_SERVICE_PARAMETERS @"app_id=terminal-tracker-dev"

@implementation STTTAuthBasic

- (NSString *) reachabilityServer{
    return REACHABILITY_SERVER;
}

- (void) tokenReceived:(UDAuthToken *) token{
    [super tokenReceived:token];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tokenReceived" object:self];
}

- (NSURLRequest *) authenticateRequest:(NSURLRequest *)request{
    NSMutableURLRequest *resultingRequest = nil;
    
    if (self.tokenValue != nil) {
        resultingRequest = [request mutableCopy];
        [resultingRequest addValue:[NSString stringWithFormat:@"Bearer %@",self.tokenValue] forHTTPHeaderField:@"Authorization"];
    }
    
    return resultingRequest;
}

+ (id) tokenRetrieverMaker{
    UDAuthTokenRetriever *tokenRetriever = [[UDAuthTokenRetriever alloc] init];
    tokenRetriever.authServiceURI = [NSURL URLWithString:AUTH_SERVICE_URI];
    
    UDPushAuthCodeRetriever *codeRetriever = [UDPushAuthCodeRetriever codeRetriever];
    codeRetriever.requestDelegate.uPushAuthServiceURI = [NSURL URLWithString:PUSHAUTH_SERVICE_URI];
#if DEBUG
    [(UDPushAuthRequestBasic *)[codeRetriever requestDelegate] setConstantGetParameters:AUTH_SERVICE_PARAMETERS];
    
#else
    [(UDPushAuthRequestBasic *)[codeRetriever requestDelegate] setConstantGetParameters:[AUTH_SERVICE_PARAMETERS stringByReplacingOccurrencesOfString:@"-dev" withString:@""]];
    
#endif
    tokenRetriever.codeDelegate = codeRetriever;
    
    return tokenRetriever;
}

@end
