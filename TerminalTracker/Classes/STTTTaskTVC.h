//
//  STTTTaskTVC.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 7/22/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STTTAgentTask+remainingTime.h"

@interface STTTTaskTVC : UITableViewController

@property (nonatomic, strong) STTTAgentTask *task;

@end

