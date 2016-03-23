//
//  STTTAgentComponent+CoreDataProperties.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 22/03/16.
//  Copyright © 2016 Maxim Grigoriev. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STTTAgentComponent.h"

NS_ASSUME_NONNULL_BEGIN

@interface STTTAgentComponent (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *serial;
@property (nullable, nonatomic, retain) NSString *shortName;
@property (nullable, nonatomic, retain) STTTAgentComponentGroup *componentGroup;
@property (nullable, nonatomic, retain) NSSet<STTTAgentTerminalComponent *> *terminalComponents;

@end

@interface STTTAgentComponent (CoreDataGeneratedAccessors)

- (void)addTerminalComponentsObject:(STTTAgentTerminalComponent *)value;
- (void)removeTerminalComponentsObject:(STTTAgentTerminalComponent *)value;
- (void)addTerminalComponents:(NSSet<STTTAgentTerminalComponent *> *)values;
- (void)removeTerminalComponents:(NSSet<STTTAgentTerminalComponent *> *)values;

@end

NS_ASSUME_NONNULL_END
