//
//  STTTAgentTerminal.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 6/28/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STDatum.h"

@class STTTAgentTask;

@interface STTTAgentTerminal : STDatum

@property (nonatomic, retain) NSString * lastpaymenttime;
@property (nonatomic, retain) NSString * last_check_ts;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * lastactivitytime;
@property (nonatomic, retain) NSString * errortext;
@property (nonatomic, retain) NSString * terminalid;
@property (nonatomic, retain) NSString * src_system;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * noteerrorid;
@property (nonatomic, retain) NSString * printererrorid;
@property (nonatomic, retain) STTTAgentTask *task;

@end
