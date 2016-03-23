//
//  STTTAgentTerminal+CoreDataProperties.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 22/03/16.
//  Copyright © 2016 Maxim Grigoriev. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STTTAgentTerminal.h"

NS_ASSUME_NONNULL_BEGIN

@interface STTTAgentTerminal (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *address;
@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSNumber *distance;
@property (nullable, nonatomic, retain) NSString *errorText;
@property (nullable, nonatomic, retain) NSDate *lastActivityTime;
@property (nullable, nonatomic, retain) NSDate *lastPaymentTime;
@property (nullable, nonatomic, retain) NSString *mobileop;
@property (nullable, nonatomic, retain) NSString *srcSystemName;
@property (nullable, nonatomic, retain) STTTTerminalLocation *location;
@property (nullable, nonatomic, retain) NSSet<STTTAgentTask *> *tasks;
@property (nullable, nonatomic, retain) NSSet<STTTAgentTerminalComponent *> *components;

@end

@interface STTTAgentTerminal (CoreDataGeneratedAccessors)

- (void)addTasksObject:(STTTAgentTask *)value;
- (void)removeTasksObject:(STTTAgentTask *)value;
- (void)addTasks:(NSSet<STTTAgentTask *> *)values;
- (void)removeTasks:(NSSet<STTTAgentTask *> *)values;

- (void)addComponentsObject:(STTTAgentTerminalComponent *)value;
- (void)removeComponentsObject:(STTTAgentTerminalComponent *)value;
- (void)addComponents:(NSSet<STTTAgentTerminalComponent *> *)values;
- (void)removeComponents:(NSSet<STTTAgentTerminalComponent *> *)values;

@end

NS_ASSUME_NONNULL_END
