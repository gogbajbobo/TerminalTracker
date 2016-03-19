//
//  STTTComponentGroupTVC.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 22/01/16.
//  Copyright © 2016 Maxim Grigoriev. All rights reserved.
//

#import "STTTComponentGroupTVC.h"
#import "STSessionManager.h"
#import "STManagedDocument.h"

#import "STTTSubtitleTableViewCell.h"

#import "STEditTaskComponentsTVC.h"


@interface STTTComponentGroupTVC ()

@property (nonatomic, strong) STManagedDocument *document;
@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, strong) NSArray *tableData;


@end


@implementation STTTComponentGroupTVC

- (NSString *)cellIdentifier {
    
    if (!_cellIdentifier) {
        _cellIdentifier = @"componentGroupCell";
    }
    return _cellIdentifier;
    
}

- (STManagedDocument *)document {
    
    if (!_document) {
        _document = [[STSessionManager sharedManager] currentSession].document;
    }
    return _document;
    
}

- (NSArray *)tableData {
    
    if (!_tableData) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STTTAgentComponentGroup class])];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"name != nil && components.@count > 0 && (ANY components.taskComponent.terminal == %@ || ANY components.taskComponent.terminal == nil)", self.task.terminal];

        NSArray *groups = [self.document.managedObjectContext executeFetchRequest:request error:nil];
        
        NSMutableArray *tableData = @[].mutableCopy;
        
        for (STTTAgentComponentGroup *group in groups) {
        
            NSMutableDictionary *groupDic = @{}.mutableCopy;

            groupDic[@"group"] = group;
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskComponent.terminal == %@ && taskComponent.isBroken != YES && taskComponent.isdeleted != YES", self.task.terminal];
            NSSet *components = [group.components filteredSetUsingPredicate:predicate];
            groupDic[@"usedComponents"] = @(components.count);
            
            predicate = [NSPredicate predicateWithFormat:@"taskComponent.terminal == %@ || taskComponent.isdeleted == YES", nil];
            components = [group.components filteredSetUsingPredicate:predicate];
            groupDic[@"remainedComponents"] = @(components.count);
            
            [tableData addObject:groupDic];
            
        }
        
        _tableData = tableData;
        
    }
    return _tableData;
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    NSDictionary *tableDatum = self.tableData[indexPath.row];
    STTTAgentComponentGroup *group = tableDatum[@"group"];
    
    NSInteger remainedComponents = [tableDatum[@"remainedComponents"] integerValue];
    NSInteger usedComponents = [tableDatum[@"usedComponents"] integerValue];
    
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = [NSString stringWithFormat:@"%@ / %@ / %@", group.name, @(group.components.count), group.isManualReplacement];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Остаток: %@", @(remainedComponents)];
    
    if (usedComponents > 0) {
        
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 21)];
        infoLabel.text = [NSString stringWithFormat:@"%@", tableDatum[@"usedComponents"]];
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
    STTTAgentComponentGroup *group = tableDatum[@"group"];

    STEditTaskComponentsTVC *componentsTVC = [[STEditTaskComponentsTVC alloc] initWithStyle:UITableViewStylePlain];
    componentsTVC.task = self.task;
    componentsTVC.componentGroup = group;
    
    [self.navigationController pushViewController:componentsTVC animated:YES];
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    [self.tableView registerClass:[STTTSubtitleTableViewCell class] forCellReuseIdentifier:self.cellIdentifier];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (![self isMovingToParentViewController]) {
        
        self.tableData = nil;
        [self.tableView reloadData];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
