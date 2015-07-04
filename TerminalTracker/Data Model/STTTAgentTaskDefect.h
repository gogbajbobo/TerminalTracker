//
//  STTTAgentTaskDefect.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 21/04/15.
//  Copyright (c) 2015 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STComment.h"

@class STTTAgentDefectCode, STTTAgentTask;

@interface STTTAgentTaskDefect : STComment

@property (nonatomic, retain) NSNumber * isdeleted;
@property (nonatomic, retain) STTTAgentTask *task;
@property (nonatomic, retain) STTTAgentDefectCode *defectCode;

@end
