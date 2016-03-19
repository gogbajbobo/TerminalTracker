//
//  STTTComponentsMovingVC.h
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 24/01/16.
//  Copyright © 2016 Maxim Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STEditTaskComponentsTVC.h"


@interface STTTComponentsMovingVC : UIViewController

@property (nonatomic, weak) STEditTaskComponentsTVC *parentVC;
@property (nonatomic, strong) NSArray *components;


@end
