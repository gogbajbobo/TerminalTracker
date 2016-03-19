//
//  STTTComponentsMovingVC.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 24/01/16.
//  Copyright © 2016 Maxim Grigoriev. All rights reserved.
//

#import "STTTComponentsMovingVC.h"

#import "STTTAgentComponent.h"
#import "STAgentTaskComponentService.h"


@interface STTTComponentsMovingVC ()

@property (weak, nonatomic) IBOutlet UILabel *componentName;

@property (weak, nonatomic) IBOutlet UILabel *numberOfInstalledComponents;
@property (weak, nonatomic) IBOutlet UILabel *numberOfRemovedComponents;
@property (weak, nonatomic) IBOutlet UILabel *numberOfRemainedComponents;
@property (weak, nonatomic) IBOutlet UILabel *numberOfUsedComponents;
@property (weak, nonatomic) IBOutlet UIButton *removeComponentButton;
@property (weak, nonatomic) IBOutlet UIButton *backRemovedComponentButton;
@property (weak, nonatomic) IBOutlet UIButton *useComponentButton;
@property (weak, nonatomic) IBOutlet UIButton *backUsedComponentButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (nonatomic, strong) NSMutableArray *installedComponents;
@property (nonatomic, strong) NSMutableArray *removedComponents;
@property (nonatomic, strong) NSMutableArray *remainedComponents;
@property (nonatomic, strong) NSMutableArray *usedComponents;

@property (nonatomic) BOOL isManualReplacement;


@end


@implementation STTTComponentsMovingVC

- (BOOL)isManualReplacement {
    return self.parentVC.componentGroup.isManualReplacement.boolValue;
}

- (IBAction)removeButtonPressed:(id)sender {
    
    if (self.isManualReplacement) {
        
        STTTAgentComponent *component = self.installedComponents.firstObject;
        [self.installedComponents removeObject:component];
        [self.removedComponents addObject:component];
        [self updateDataAndViews];
        
    } else {

        [self autoReplacement];

    }

}

- (IBAction)backRemovedComponentButtonPressed:(id)sender {
    
    if (self.isManualReplacement) {

        STTTAgentComponent *component = self.removedComponents.firstObject;
        [self.removedComponents removeObject:component];
        [self.installedComponents addObject:component];
        [self updateDataAndViews];
        
    } else {
    
        [self backAutoReplacement];

    }
    
}

- (IBAction)useButtonPressed:(id)sender {
    
    if (self.isManualReplacement) {

        STTTAgentComponent *component = self.remainedComponents.firstObject;
        [self.remainedComponents removeObject:component];
        [self.usedComponents addObject:component];
        [self updateDataAndViews];

    } else {
    
        [self autoReplacement];

    }
    
}

- (IBAction)backUsedComponentButtonPressed:(id)sender {
    
    if (self.isManualReplacement) {
        
        STTTAgentComponent *component = self.usedComponents.firstObject;
        [self.usedComponents removeObject:component];
        [self.remainedComponents addObject:component];
        [self updateDataAndViews];
        
    } else {

        [self backAutoReplacement];

    }

}

- (void)autoReplacement {
    
    [self.removedComponents addObjectsFromArray:self.installedComponents];
    [self.installedComponents removeObjectsInArray:self.installedComponents];

    STTTAgentComponent *component = self.remainedComponents.firstObject;
    
    if (component) {
        
        [self.usedComponents addObject:component];
        [self.remainedComponents removeObject:component];

    }
    
    [self updateDataAndViews];

}

- (void)backAutoReplacement {
    
    [self.installedComponents addObjectsFromArray:self.removedComponents];
    [self.removedComponents removeObjectsInArray:self.removedComponents];
    
    [self.remainedComponents addObjectsFromArray:self.usedComponents];
    [self.usedComponents removeObjectsInArray:self.usedComponents];
    
    [self updateDataAndViews];

}

- (IBAction)doneButtonPressed:(id)sender {
    
    [STAgentTaskComponentService updateComponentsForTask:self.parentVC.task
                                 withInstalledComponents:self.installedComponents
                                       removedComponents:self.removedComponents
                                      remainedComponents:self.remainedComponents
                                          usedComponents:self.usedComponents];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)updateDataAndViews {
    
    [self sortArrays];
    [self updateButtonsAndLabels];
    
}

- (void)sortArrays {
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ts" ascending:YES selector:@selector(compare:)];

    self.installedComponents = [self.installedComponents sortedArrayUsingDescriptors:@[sortDescriptor]].mutableCopy;
    self.removedComponents = [self.removedComponents sortedArrayUsingDescriptors:@[sortDescriptor]].mutableCopy;
    self.remainedComponents = [self.remainedComponents sortedArrayUsingDescriptors:@[sortDescriptor]].mutableCopy;
    self.usedComponents = [self.usedComponents sortedArrayUsingDescriptors:@[sortDescriptor]].mutableCopy;
    
}

- (void)updateButtonsAndLabels {
    
    self.numberOfInstalledComponents.text = @(self.installedComponents.count).stringValue;
    self.numberOfRemovedComponents.text = @(self.removedComponents.count).stringValue;
    self.numberOfRemainedComponents.text = @(self.remainedComponents.count).stringValue;
    self.numberOfUsedComponents.text = @(self.usedComponents.count).stringValue;
    
    self.removeComponentButton.enabled = (self.installedComponents.count > 0);
    self.backRemovedComponentButton.enabled = (self.removedComponents.count > 0);
    self.useComponentButton.enabled = (self.remainedComponents.count > 0);
    self.backUsedComponentButton.enabled = (self.usedComponents.count > 0);
    
    if (!self.isManualReplacement) {
        if (self.usedComponents.count >= 1) self.useComponentButton.enabled = NO;
    }
    
}

- (void)prepareComponentsData {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskComponent.task == nil && taskComponent.terminal == %@ && taskComponent.isBroken != YES", self.parentVC.task.terminal];
    self.installedComponents = [self.components filteredArrayUsingPredicate:predicate].mutableCopy;

    predicate = [NSPredicate predicateWithFormat:@"taskComponent.task == %@ && taskComponent.terminal == %@ && taskComponent.isBroken == YES && taskComponent.isdeleted != YES", self.parentVC.task, self.parentVC.task.terminal];
    self.removedComponents = [self.components filteredArrayUsingPredicate:predicate].mutableCopy;

    predicate = [NSPredicate predicateWithFormat:@"taskComponent.terminal == nil || taskComponent.isdeleted == YES"];
    self.remainedComponents = [self.components filteredArrayUsingPredicate:predicate].mutableCopy;

    predicate = [NSPredicate predicateWithFormat:@"taskComponent.terminal == %@ && taskComponent.task == %@ && taskComponent.isdeleted != YES", self.parentVC.task.terminal, self.parentVC.task];
    self.usedComponents = [self.components filteredArrayUsingPredicate:predicate].mutableCopy;
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    STTTAgentComponent *component = self.components.firstObject;
    
    self.componentName.text = component.shortName;
    
    [self prepareComponentsData];
    [self updateDataAndViews];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
