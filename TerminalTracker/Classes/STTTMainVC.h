//
//  STMainVC.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 6/24/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STTTTerminalController.h"
#import "STTTTaskController.h"
#import "STTTLocationController.h"

@interface STTTMainVC : UIViewController

@property (nonatomic, strong) STTTTerminalController *terminalController;
@property (nonatomic, strong) STTTTaskController *taskController;

@end
