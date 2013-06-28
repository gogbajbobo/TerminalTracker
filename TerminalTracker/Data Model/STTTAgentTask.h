//
//  STTTAgentTask.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 6/28/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STDatum.h"

@class STTTAgentTerminal, STTTLocation;

@interface STTTAgentTask : STDatum

@property (nonatomic, retain) NSString * servstatus;
@property (nonatomic, retain) NSString * visited;
@property (nonatomic, retain) NSString * isservice;
@property (nonatomic, retain) NSString * terminal_break;
@property (nonatomic, retain) NSString * agent_route;
@property (nonatomic, retain) NSString * cistatus;
@property (nonatomic, retain) NSString * penaltystatus;
@property (nonatomic, retain) NSString * point;
@property (nonatomic, retain) NSString * status_transfer;
@property (nonatomic, retain) NSString * do_before;
@property (nonatomic, retain) NSString * servtimelimit;
@property (nonatomic, retain) NSString * sstracker;
@property (nonatomic, retain) NSString * route;
@property (nonatomic, retain) NSString * placement;
@property (nonatomic, retain) NSString * servstatus_date;
@property (nonatomic, retain) NSString * isdone;
@property (nonatomic, retain) STTTAgentTerminal *terminal;
@property (nonatomic, retain) STTTLocation *donelocation;

@end
