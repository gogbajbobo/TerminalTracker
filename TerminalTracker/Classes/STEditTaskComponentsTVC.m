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


@interface STEditTaskComponentsTVC ()

@property (strong, nonatomic) NSMutableArray *componentsList;
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

- (NSMutableArray <NSDictionary *> *)componentsList {
    
    if (!_componentsList) {
        
        _componentsList = [STAgentTaskComponentService getListOfComponentsForTask:self.task inGroup:self.componentGroup].mutableCopy;
        
//        _componentsList = [[NSMutableArray alloc] init];
//        
//        for (NSDictionary *component in [STAgentTaskComponentService getListOfComponentsForTask:self.task inGroup:self.componentGroup]) {
//            [_componentsList addObject:[component mutableCopy]];
//        }
        
    }
    return _componentsList;
    
}

- (NSMutableArray *)tableData {
    
    if (!_tableData) {
        
        _tableData = @[].mutableCopy;
        
        [self.componentsList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSDictionary *dataDic = @{@"shortName": [obj valueForKey:@"shortName"], @"serial": [obj valueForKey:@"serial"]};
            if (![_tableData containsObject:dataDic]) [_tableData addObject:dataDic];
            
        }];
        
    }
    return _tableData;
    
}

- (NSPredicate *)usedComponentsPredicate {
    return [NSPredicate predicateWithFormat:@"taskComponent.terminal == %@ && taskComponent.isBroken != YES && taskComponent.isdeleted != YES", self.task.terminal];
}

- (NSPredicate *)remainedComponentsPredicate {
    return [NSPredicate predicateWithFormat:@"taskComponent.terminal == nil || taskComponent.isdeleted == YES"];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 77;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.numberOfLines = 0;
    
    NSDictionary *tableDatum = self.tableData[indexPath.row];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"shortName == %@ AND serial == %@", tableDatum[@"shortName"], tableDatum[@"serial"]];
    NSArray *components = [self.componentsList filteredArrayUsingPredicate:predicate];
    
    predicate = [self usedComponentsPredicate];
    NSArray *usedComponents = [components filteredArrayUsingPredicate:predicate];

    predicate = [self remainedComponentsPredicate];
    NSArray *remainedComponents = [components filteredArrayUsingPredicate:predicate];
    
//    cell.textLabel.text = [[tableDatum[@"shortName"] stringByAppendingString:@" -/- "] stringByAppendingString:@(components.count).stringValue];
    cell.textLabel.text = tableDatum[@"shortName"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\nОстаток: %@", tableDatum[@"serial"], @(remainedComponents.count)];

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
    
    NSDictionary *tableDatum = self.tableData[indexPath.row];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"shortName == %@ AND serial == %@", tableDatum[@"shortName"], tableDatum[@"serial"]];
    NSArray *components = [self.componentsList filteredArrayUsingPredicate:predicate];

    STTTComponentsMovingVC *componentsMovingVC = [[UIStoryboard storyboardWithName:@"STTTMainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"componentsMovingVC"];;
    componentsMovingVC.components = components;
    componentsMovingVC.parentVC = self;
    
    [self.navigationController pushViewController:componentsMovingVC animated:YES];

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
