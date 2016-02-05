//
//  STTTAgentComponentGroup+CoreDataProperties.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 20/01/16.
//  Copyright © 2016 Maxim Grigoriev. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STTTAgentComponentGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface STTTAgentComponentGroup (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *isManualReplacement;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<STTTAgentComponent *> *components;

@end

@interface STTTAgentComponentGroup (CoreDataGeneratedAccessors)

- (void)addComponentsObject:(STTTAgentComponent *)value;
- (void)removeComponentsObject:(STTTAgentComponent *)value;
- (void)addComponents:(NSSet<STTTAgentComponent *> *)values;
- (void)removeComponents:(NSSet<STTTAgentComponent *> *)values;

@end

NS_ASSUME_NONNULL_END
