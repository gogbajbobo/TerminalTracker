//
//  STAgentTaskComponentService.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 04/07/15.
//  Copyright (c) 2015 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STTTAgentTask.h"
#import "STTTAgentComponentGroup.h"


@interface STAgentTaskComponentService : NSObject

+ (NSInteger)getNumberOfSelectedComponentsForTask:(STTTAgentTask *)task;

+ (NSArray *)getListOfComponentsForTask:(STTTAgentTask *)task;
+ (NSArray *)getListOfComponentsForTask:(STTTAgentTask *)task inGroup:(STTTAgentComponentGroup *)group;

+ (void)updateComponentsForTask:(STTTAgentTask *)task fromList:(NSArray *)componentsList;

+ (void)updateComponentsForTask:(STTTAgentTask *)task
        withInstalledComponents:(NSArray *)installedComponents
              removedComponents:(NSArray *)removedComponents
             remainedComponents:(NSArray *)remainedComponents
                 usedComponents:(NSArray *)usedComponents;

@end
