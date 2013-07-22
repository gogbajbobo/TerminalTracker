//
//  STTTMainTVC.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 7/22/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STTTTaskController.h"
#import "STTTTerminalController.h"

@interface STTTMainTVC : UITableViewController

@property (nonatomic, strong) STTTTerminalController *terminalController;
@property (nonatomic, strong) STTTTaskController *taskController;


@end
