//
//  STTTSyncer.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 6/28/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STSyncer.h"

@interface STTTSyncer : STSyncer

@property (nonatomic, strong) NSString *requestParameters;
@property (nonatomic, strong) NSString *requestType;
@property (nonatomic, strong) NSString *restServerURI;

@end
