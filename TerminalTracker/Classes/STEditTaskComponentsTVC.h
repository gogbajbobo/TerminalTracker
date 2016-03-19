//
//  STEditTaskComponentsTVC.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 04/07/15.
//  Copyright (c) 2015 Maxim Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "STTTAgentTask.h"
#import "STTTAgentComponentGroup.h"


@interface STEditTaskComponentsTVC : UITableViewController

@property (strong, nonatomic) STTTAgentTask *task;
@property (nonatomic, strong) STTTAgentComponentGroup *componentGroup;

- (NSPredicate *)usedComponentsPredicate;
- (NSPredicate *)remainedComponentsPredicate;


@end
