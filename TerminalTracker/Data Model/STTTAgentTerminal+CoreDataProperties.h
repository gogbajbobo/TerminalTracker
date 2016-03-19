//
//  STTTAgentTerminal+CoreDataProperties.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 11/03/16.
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
@property (nullable, nonatomic, retain) NSString *mobileop;
@property (nullable, nonatomic, retain) NSString *srcSystemName;
@property (nullable, nonatomic, retain) NSDate *lastPaymentTime;
@property (nullable, nonatomic, retain) STTTTerminalLocation *location;
@property (nullable, nonatomic, retain) NSSet<STTTAgentTask *> *tasks;
@property (nullable, nonatomic, retain) NSSet<STTTAgentTaskComponent *> *components;

@end

@interface STTTAgentTerminal (CoreDataGeneratedAccessors)

- (void)addTasksObject:(STTTAgentTask *)value;
- (void)removeTasksObject:(STTTAgentTask *)value;
- (void)addTasks:(NSSet<STTTAgentTask *> *)values;
- (void)removeTasks:(NSSet<STTTAgentTask *> *)values;

- (void)addComponentsObject:(STTTAgentTaskComponent *)value;
- (void)removeComponentsObject:(STTTAgentTaskComponent *)value;
- (void)addComponents:(NSSet<STTTAgentTaskComponent *> *)values;
- (void)removeComponents:(NSSet<STTTAgentTaskComponent *> *)values;

@end

NS_ASSUME_NONNULL_END
