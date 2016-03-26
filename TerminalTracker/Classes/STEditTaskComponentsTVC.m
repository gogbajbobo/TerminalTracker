//
//  STEditTaskComponentsTVC.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 04/07/15.
//  Copyright (c) 2015 Maxim Grigoriev. All rights reserved.
//

#import "STEditTaskComponentsTVC.h"

#import "STAgentTaskComponentService.h"
#import "STTTSubtitleTableViewCell.h"
#import "STTTComponentsMovingVC.h"

#import "STTTAgentComponent.h"


@interface STEditTaskComponentsTVC () <UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *tableData;
@property (nonatomic, strong) NSString *cellIdentifier;


@end


@implementation STEditTaskComponentsTVC

- (NSString *)cellIdentifier {
    
    if (!_cellIdentifier) {
        _cellIdentifier = @"componentCell";
    }
    return _cellIdentifier;
    
}

- (NSMutableArray *)tableData {
    
    if (!_tableData) {
        
//        _tableData = @[].mutableCopy;
        
        NSMutableArray *initiallyInstalledComponents = @[].mutableCopy;
        NSMutableArray *otherComponents = @[].mutableCopy;
        
        [self.components enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj isKindOfClass:[STTTAgentComponent class]]) {
                
                STTTAgentComponent *component = (STTTAgentComponent *)obj;

                NSDictionary *dataDic = @{@"shortName": component.shortName, @"serial": component.serial};

                if (component.wasInitiallyInstalled.boolValue) {
                    
                    if (![initiallyInstalledComponents containsObject:dataDic]) [initiallyInstalledComponents addObject:dataDic];
                    
                } else {
                    
                    if (![otherComponents containsObject:dataDic]) [otherComponents addObject:dataDic];
                    
                }
                
//                if (![_tableData containsObject:dataDic]) [_tableData addObject:dataDic];
                
            }
            
        }];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"serial" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        [initiallyInstalledComponents sortUsingDescriptors:@[sortDescriptor]];
        [otherComponents sortUsingDescriptors:@[sortDescriptor]];
        
        _tableData = @[initiallyInstalledComponents, otherComponents].mutableCopy;
        
    }
    return _tableData;
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return @"Изначально установлены";
            break;

        case 1:
            return @"В наличии";
            break;

        default:
            return nil;
            break;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableData[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 77;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.numberOfLines = 0;
    
    NSDictionary *tableDatum = self.tableData[indexPath.section][indexPath.row];
    
    NSString *shortName = tableDatum[@"shortName"];
    NSString *serial = tableDatum[@"serial"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"shortName == %@ AND serial == %@", shortName, serial];
    NSArray *components = [self.components filteredArrayUsingPredicate:predicate];
    
    predicate = [NSPredicate predicateWithFormat:@"isBroken == NO && isInstalled == NO"];
    NSArray *remainedComponents = [components filteredArrayUsingPredicate:predicate];

    predicate = [NSPredicate predicateWithFormat:@"isBroken == YES"];
    NSArray *brokenComponents = [components filteredArrayUsingPredicate:predicate];

    predicate = [NSPredicate predicateWithFormat:@"isInstalled == YES"];
    NSArray *usedComponents = [components filteredArrayUsingPredicate:predicate];

    cell.textLabel.text = shortName;
    
    switch (indexPath.section) {
        case 0:

            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\nПоломато: %@", serial, @(brokenComponents.count)];
            predicate = [NSPredicate predicateWithFormat:@"wasInitiallyInstalled == YES"];
            
            break;

        case 1:
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\nОстаток: %@", serial, @(remainedComponents.count)];
            predicate = [NSPredicate predicateWithFormat:@"wasInitiallyInstalled == NO"];

            break;

        default:
            break;
    }
    
    usedComponents = [usedComponents filteredArrayUsingPredicate:predicate];

    if (usedComponents.count > 0) {
        
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 21)];
        infoLabel.text = [NSString stringWithFormat:@"%@", @(usedComponents.count)];
        infoLabel.textAlignment = NSTextAlignmentRight;
        infoLabel.adjustsFontSizeToFitWidth = YES;
        
        cell.accessoryView = infoLabel;
        
    } else {
        
        cell.accessoryView = nil;
        
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *tableDatum = self.tableData[indexPath.section][indexPath.row];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"shortName == %@ AND serial == %@", tableDatum[@"shortName"], tableDatum[@"serial"]];
    NSArray *components = [self.components filteredArrayUsingPredicate:predicate];

    if (self.componentGroup.isManualReplacement.boolValue) {
        
        STTTComponentsMovingVC *componentsMovingVC = [[UIStoryboard storyboardWithName:@"STTTMainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"componentsMovingVC"];;
        componentsMovingVC.components = components;
        componentsMovingVC.parentVC = self;
        
        [self.navigationController pushViewController:componentsMovingVC animated:YES];

    } else {
        
        if (indexPath.section == 1) {

            predicate = [NSPredicate predicateWithFormat:@"isInstalled == YES && wasInitiallyInstalled == NO"];
            NSArray *installedComponents = [components filteredArrayUsingPredicate:predicate];
            
            NSString *alertMessage = (installedComponents.count > 0) ? @"Снимаем?" : @"Ставим?";
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"!!!"
                                                                message:alertMessage
                                                               delegate:self
                                                      cancelButtonTitle:@"Отмена"
                                                      otherButtonTitles:@"Ok", nil];
                
                alert.tag = (installedComponents.count > 0) ? 202 : 201;
                
                [alert show];
                
            }];

        }
        
    }
    
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    switch (alertView.tag) {
        case 201:
            [self autoReplacement];
            break;

        case 202:
            [self backAutoReplacement];
            break;

        default:
            break;
    }
    
}

- (void)autoReplacement {
    
    NSMutableArray *removedComponents = @[].mutableCopy;
    NSMutableArray *remainedComponents = @[].mutableCopy;
    NSMutableArray *installedComponents = @[].mutableCopy;
    NSMutableArray *usedComponents = @[].mutableCopy;
    
    for (STTTAgentComponent *component in self.components) {
        
        if ([component isBroken]) {
            
            [removedComponents addObject:component];
            
        } else if (![component isInstalled]) {
            
            [remainedComponents addObject:component];
            
        } else if (component.wasInitiallyInstalled.boolValue) {
            
            [installedComponents addObject:component];
            
        } else {
            
            [usedComponents addObject:component];
            
        }
        
    }

    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ts" ascending:YES selector:@selector(compare:)];
    
    installedComponents = [installedComponents sortedArrayUsingDescriptors:@[sortDescriptor]].mutableCopy;
    removedComponents = [removedComponents sortedArrayUsingDescriptors:@[sortDescriptor]].mutableCopy;
    remainedComponents = [remainedComponents sortedArrayUsingDescriptors:@[sortDescriptor]].mutableCopy;
    usedComponents = [usedComponents sortedArrayUsingDescriptors:@[sortDescriptor]].mutableCopy;

    [removedComponents addObjectsFromArray:installedComponents];
    [installedComponents removeObjectsInArray:installedComponents];
    
    [remainedComponents addObjectsFromArray:usedComponents];
    [usedComponents removeObjectsInArray:usedComponents];

    NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
    NSDictionary *tableDatum = self.tableData[selectedIndexPath.section][selectedIndexPath.row];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"shortName == %@ AND serial == %@", tableDatum[@"shortName"], tableDatum[@"serial"]];

    STTTAgentComponent *component = [remainedComponents filteredArrayUsingPredicate:predicate].firstObject;

    if (component) {
        
        [usedComponents addObject:component];
        [remainedComponents removeObject:component];
        
    }
    
    [STAgentTaskComponentService updateComponentsForTask:self.task
                                 withInstalledComponents:installedComponents
                                       removedComponents:removedComponents
                                      remainedComponents:remainedComponents
                                          usedComponents:usedComponents];
    
    [self.tableView reloadData];
    
}

- (void)backAutoReplacement {
    
    NSMutableArray *removedComponents = @[].mutableCopy;
    NSMutableArray *remainedComponents = @[].mutableCopy;
    NSMutableArray *installedComponents = @[].mutableCopy;
    NSMutableArray *usedComponents = @[].mutableCopy;
    
    for (STTTAgentComponent *component in self.components) {
        
        if ([component isBroken]) {
            
            [removedComponents addObject:component];
            
        } else if (![component isInstalled]) {
            
            [remainedComponents addObject:component];
            
        } else if (component.wasInitiallyInstalled.boolValue) {
            
            [installedComponents addObject:component];
            
        } else {
            
            [usedComponents addObject:component];
            
        }
        
    }
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ts" ascending:YES selector:@selector(compare:)];
    
    installedComponents = [installedComponents sortedArrayUsingDescriptors:@[sortDescriptor]].mutableCopy;
    removedComponents = [removedComponents sortedArrayUsingDescriptors:@[sortDescriptor]].mutableCopy;
    remainedComponents = [remainedComponents sortedArrayUsingDescriptors:@[sortDescriptor]].mutableCopy;
    usedComponents = [usedComponents sortedArrayUsingDescriptors:@[sortDescriptor]].mutableCopy;
    
    [installedComponents addObjectsFromArray:removedComponents];
    [removedComponents removeObjectsInArray:removedComponents];
    
    [remainedComponents addObjectsFromArray:usedComponents];
    [usedComponents removeObjectsInArray:usedComponents];
    
    [STAgentTaskComponentService updateComponentsForTask:self.task
                                 withInstalledComponents:installedComponents
                                       removedComponents:removedComponents
                                      remainedComponents:remainedComponents
                                          usedComponents:usedComponents];
    
    [self.tableView reloadData];

}


#pragma mark - view lifecycle

- (void)customInit {
    
    [self.tableView registerClass:[STTTSubtitleTableViewCell class] forCellReuseIdentifier:self.cellIdentifier];
    
    if (self.componentGroup) self.navigationItem.title = self.componentGroup.name;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (![self isMovingToParentViewController]) {
        [self.tableView reloadData];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
