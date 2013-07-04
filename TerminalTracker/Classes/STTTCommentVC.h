//
//  STTTCommentVC.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 7/4/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STTTAgentTask.h"

@interface STTTCommentVC : UIViewController

@property (nonatomic, strong) STTTAgentTask *task;
@property (nonatomic, strong) NSDictionary *backgroundColors;

@end
