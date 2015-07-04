//
//  STAgentTaskComponentService.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 04/07/15.
//  Copyright (c) 2015 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STTTAgentTask.h"


@interface STAgentTaskComponentService : NSObject

+ (NSInteger)getNumberOfSelectedComponentsForTask:(STTTAgentTask *)task;


@end
