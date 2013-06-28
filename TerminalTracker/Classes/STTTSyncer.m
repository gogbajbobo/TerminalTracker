//
//  STTTSyncer.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 6/28/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STTTSyncer.h"

@implementation STTTSyncer

- (NSString *)requestParameters {
    return @"@shift=-13&page-size:=20&page-number:=1";
}

- (void)onTimerTick:(NSTimer *)timer {
    [self setRequestType:@"megaport.iAgentTerminal"];
    [super onTimerTick:timer];
}

- (void)sendData:(NSData *)requestData toServer:(NSString *)serverUrlString withParameters:(NSString *)parameters {
    NSLog(@"STTTSyncer sendData");
    if (!self.requestType) {
        NSLog(@"No request type");
        self.syncing = NO;
    } else {
        NSString *requestString = [NSString stringWithFormat:@"%@/%@", serverUrlString, self.requestType];
        NSLog(@"requestString %@", requestString);
        [super sendData:nil toServer:requestString withParameters:self.requestParameters];
    }
}

- (void)parseResponse:(NSData *)responseData fromConnection:(NSURLConnection *)connection {
    NSLog(@"parseResponse");
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"responseData %@", responseString);
}


@end
