//
//  STEditTaskBreakCodesTVC.m
//  TerminalTracker
//
//  Created by Sergey on 14/10/2014.
//  Copyright (c) 2014 Sergey Dvornikov. All rights reserved.
//

#import "STEditTaskRepairCodesTVC.h"
#import "STAgentTaskRepairCodeService.h"

@interface STEditTaskRepairCodesTVC ()
@property (strong, nonatomic) NSMutableArray* repairList;
@end

@implementation STEditTaskRepairCodesTVC

- (NSArray *)repairList {
    if(_repairList == nil) {
        _repairList = [[NSMutableArray alloc] init];
        for(NSDictionary *repair in [STAgentTaskRepairCodeService getListOfRepairsForTask:self.task]) {
            [_repairList addObject:[repair mutableCopy]];
        }
    }
    return _repairList;
}

- (void)viewWillDisappear:(BOOL)animated {
    [STAgentTaskRepairCodeService updateRepairsForTask:self.task fromList:self.repairList];
    [super viewWillDisappear:animated];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.repairList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"breakType" forIndexPath:indexPath];
    cell.textLabel.text = [self.repairList[indexPath.row] objectForKey:@"repairName"];
    BOOL isChecked = [[self.repairList[indexPath.row] objectForKey:@"isChecked"] boolValue];
    cell.accessoryType =  isChecked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isChecked = [[self.repairList[indexPath.row] objectForKey:@"isChecked"] boolValue];
    [self.repairList[indexPath.row] setObject:[NSNumber numberWithBool:!isChecked] forKey:@"isChecked"];
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = !isChecked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

@end
