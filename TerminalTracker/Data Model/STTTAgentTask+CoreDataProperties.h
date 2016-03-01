//
//  STTTAgentTask+CoreDataProperties.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 05/02/16.
//  Copyright © 2016 Maxim Grigoriev. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STTTAgentTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface STTTAgentTask (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *doBefore;
@property (nullable, nonatomic, retain) NSNumber *routePriority;
@property (nullable, nonatomic, retain) NSNumber *servstatus;
@property (nullable, nonatomic, retain) NSDate *servstatusDate;
@property (nullable, nonatomic, retain) NSString *terminalBreakName;
@property (nullable, nonatomic, retain) NSString *terminalBarcode;
@property (nullable, nonatomic, retain) NSSet<STTTAgentTaskComponent *> *components;
@property (nullable, nonatomic, retain) NSSet<STTTAgentTaskDefect *> *defects;
@property (nullable, nonatomic, retain) NSSet<STTTAgentTaskRepair *> *repairs;
@property (nullable, nonatomic, retain) STTTAgentTerminal *terminal;
@property (nullable, nonatomic, retain) STTTTaskLocation *visitLocation;

@end

@interface STTTAgentTask (CoreDataGeneratedAccessors)

- (void)addComponentsObject:(STTTAgentTaskComponent *)value;
- (void)removeComponentsObject:(STTTAgentTaskComponent *)value;
- (void)addComponents:(NSSet<STTTAgentTaskComponent *> *)values;
- (void)removeComponents:(NSSet<STTTAgentTaskComponent *> *)values;

- (void)addDefectsObject:(STTTAgentTaskDefect *)value;
- (void)removeDefectsObject:(STTTAgentTaskDefect *)value;
- (void)addDefects:(NSSet<STTTAgentTaskDefect *> *)values;
- (void)removeDefects:(NSSet<STTTAgentTaskDefect *> *)values;

- (void)addRepairsObject:(STTTAgentTaskRepair *)value;
- (void)removeRepairsObject:(STTTAgentTaskRepair *)value;
- (void)addRepairs:(NSSet<STTTAgentTaskRepair *> *)values;
- (void)removeRepairs:(NSSet<STTTAgentTaskRepair *> *)values;

@end

NS_ASSUME_NONNULL_END
