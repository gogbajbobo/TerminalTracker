//
//  STTTComponentGroupTVC.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 22/01/16.
//  Copyright © 2016 Maxim Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "STTTAgentTask.h"
#import "STTTAgentComponentGroup.h"


@interface STTTComponentGroupTVC : UITableViewController

@property (nonatomic, weak) STTTAgentTask *task;


@end
