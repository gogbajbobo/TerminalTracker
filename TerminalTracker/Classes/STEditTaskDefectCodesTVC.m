//
//  STEditTaskDefectCodesTVC.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 22/04/15.
//  Copyright (c) 2015 Maxim Grigoriev. All rights reserved.
//

#import "STEditTaskDefectCodesTVC.h"
#import "STAgentTaskDefectCodeService.h"


@interface STEditTaskDefectCodesTVC ()
@property (strong, nonatomic) NSMutableArray* defectsList;


@end


@implementation STEditTaskDefectCodesTVC


- (NSMutableArray *)defectsList {
    
    if(!_defectsList) {
        
        _defectsList = [[NSMutableArray alloc] init];
        
        for (NSDictionary *defect in [STAgentTaskDefectCodeService getListOfDefectsForTask:self.task]) {
            [_defectsList addObject:[defect mutableCopy]];
        }
        
    }
    return _defectsList;
    
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.defectsList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defectType" forIndexPath:indexPath];
    cell.textLabel.text = [self.defectsList[indexPath.row] objectForKey:@"name"];
    
    BOOL isChecked = [[self.defectsList[indexPath.row] objectForKey:@"isChecked"] boolValue];
    cell.accessoryType =  isChecked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL isChecked = [[self.defectsList[indexPath.row] objectForKey:@"isChecked"] boolValue];
    [self.defectsList[indexPath.row] setObject:@(!isChecked) forKey:@"isChecked"];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = (!isChecked) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
}


#pragma mark - view lifecycle

- (void)viewWillDisappear:(BOOL)animated {
    
    //    [STAgentTaskRepairCodeService updateRepairsForTask:self.task fromList:self.repairList];
    [super viewWillDisappear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
