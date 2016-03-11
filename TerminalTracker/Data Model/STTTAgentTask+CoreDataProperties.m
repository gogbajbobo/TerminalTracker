//
//  STTTAgentTask+CoreDataProperties.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 05/02/16.
//  Copyright © 2016 Maxim Grigoriev. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STTTAgentTask+CoreDataProperties.h"

@implementation STTTAgentTask (CoreDataProperties)

@dynamic doBefore;
@dynamic routePriority;
@dynamic servstatus;
@dynamic servstatusDate;
@dynamic terminalBreakName;
@dynamic terminalBarcode;
@dynamic components;
@dynamic defects;
@dynamic repairs;
@dynamic terminal;
@dynamic visitLocation;

@end
