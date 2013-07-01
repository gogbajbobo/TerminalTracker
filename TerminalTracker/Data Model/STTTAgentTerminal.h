//
//  STTTAgentTerminal.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 7/1/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STComment.h"

@class STTTAgentTask, STTTTerminalLocation;

@interface STTTAgentTerminal : STComment

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * errorText;
@property (nonatomic, retain) NSDate * lastActivityTime;
@property (nonatomic, retain) NSString * srcSystemName;
@property (nonatomic, retain) STTTAgentTask *task;
@property (nonatomic, retain) STTTTerminalLocation *location;

@end
