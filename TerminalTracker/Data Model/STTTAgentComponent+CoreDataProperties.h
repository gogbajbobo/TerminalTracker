//
//  STTTAgentComponent+CoreDataProperties.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 20/01/16.
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
@property (nullable, nonatomic, retain) STTTAgentTaskComponent *taskComponent;
@property (nullable, nonatomic, retain) STTTAgentComponentGroup *componentGroup;

@end

NS_ASSUME_NONNULL_END
