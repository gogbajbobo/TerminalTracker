//
//  STTTAgentTaskComponent.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 04/07/15.
//  Copyright (c) 2015 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STTTAgentComponent, STTTAgentTask;

@interface STTTAgentTaskComponent : NSManagedObject

@property (nonatomic, retain) STTTAgentComponent *component;
@property (nonatomic, retain) STTTAgentTask *task;

@end
