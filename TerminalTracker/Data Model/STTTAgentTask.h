//
//  STTTAgentTask.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 05/02/16.
//  Copyright © 2016 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STComment.h"

@class STTTAgentTaskComponent, STTTAgentTaskDefect, STTTAgentTaskRepair, STTTAgentTerminal, STTTTaskLocation;

NS_ASSUME_NONNULL_BEGIN

@interface STTTAgentTask : STComment

- (NSTimeInterval)remainingTime;
- (int)numberOfTasksOnSameTerminal;
- (BOOL)recentlyVisited;


@end

NS_ASSUME_NONNULL_END

#import "STTTAgentTask+CoreDataProperties.h"
