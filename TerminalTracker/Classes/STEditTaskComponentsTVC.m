//
//  STEditTaskComponentsTVC.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 04/07/15.
//  Copyright (c) 2015 Maxim Grigoriev. All rights reserved.
//

#import "STEditTaskComponentsTVC.h"
#import "STAgentTaskComponentService.h"


@interface STEditTaskComponentsTVC ()

@property (strong, nonatomic) NSMutableArray* componentsList;


@end


@implementation STEditTaskComponentsTVC

- (NSMutableArray *)componentsList {
    
    if(!_componentsList) {
        
        _componentsList = [[NSMutableArray alloc] init];
        
        for (NSDictionary *component in [STAgentTaskComponentService getListOfComponentsForTask:self.task]) {
            [_componentsList addObject:[component mutableCopy]];
        }
        
    }
    return _componentsList;
    
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.componentsList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"componentCell" forIndexPath:indexPath];
    cell.textLabel.text = [self.componentsList[indexPath.row] objectForKey:@"shortName"];
    cell.detailTextLabel.text = [self.componentsList[indexPath.row] objectForKey:@"serial"];
    
    BOOL isUsed = [[self.componentsList[indexPath.row] objectForKey:@"isUsed"] boolValue];
    
    if (isUsed) {
        
        UIColor *isUsedColor = [UIColor lightGrayColor];
        
        cell.textLabel.textColor = isUsedColor;
        cell.detailTextLabel.textColor = isUsedColor;
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    } else {

        UIColor *notUsedColor = [UIColor blackColor];
        
        cell.textLabel.textColor = notUsedColor;
        cell.detailTextLabel.textColor = notUsedColor;

        BOOL isChecked = [[self.componentsList[indexPath.row] objectForKey:@"isChecked"] boolValue];
        cell.accessoryType = isChecked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL isUsed = [[self.componentsList[indexPath.row] objectForKey:@"isUsed"] boolValue];
    
    if (!isUsed) {
        
        BOOL isChecked = [self.componentsList[indexPath.row][@"isChecked"] boolValue];
        self.componentsList[indexPath.row][@"isChecked"] = @(!isChecked);
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = (!isChecked) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        
    }
    
}


#pragma mark - view lifecycle

- (void)viewWillDisappear:(BOOL)animated {
    
    [STAgentTaskComponentService updateComponentsForTask:self.task fromList:self.componentsList];
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
