//
//  STTTInfoTVC.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 7/22/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STTTInfoTVC.h"
#import "STTTTaskController.h"
#import "STTTTerminalController.h"
#import "STTTTaskTVC.h"
#import "STTTTerminalTVC.h"

@interface STTTInfoTVC ()

@end

@implementation STTTInfoTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    if ([self.tableView.dataSource isKindOfClass:[STTTTerminalController class]]) {
        [(STTTTerminalController *)self.tableView.dataSource calculateDistance];
    }
//    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.navigationController) {
        return;
    }
    
    if ([self.tableView.dataSource isKindOfClass:[STTTTaskController class]]) {
        
        STTTTaskController *taskController = (STTTTaskController *)self.tableView.dataSource;
        STTTAgentTask *task = [taskController.resultsController objectAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"showTask" sender:task];
        
    } else if ([self.tableView.dataSource isKindOfClass:[STTTTerminalController class]]) {
        
        STTTTerminalController *terminalController = (STTTTerminalController *)self.tableView.dataSource;
        STTTAgentTerminal *terminal = [terminalController.resultsController objectAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"showTerminal" sender:terminal];
        
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showTask"]) {
        
        if ([segue.destinationViewController isKindOfClass:[STTTTaskTVC class]] &&
            [sender isKindOfClass:[STTTAgentTask class]]) {
            
            [(STTTTaskTVC *)segue.destinationViewController setTask:(STTTAgentTask *)sender];
            
        }
        
    } else if ([segue.identifier isEqualToString:@"showTerminal"]) {
        
        if ([segue.destinationViewController isKindOfClass:[STTTTerminalTVC class]] &&
            [sender isKindOfClass:[STTTAgentTerminal class]]) {
            
            [(STTTTerminalTVC *)segue.destinationViewController setTerminal:(STTTAgentTerminal *)sender];
            
        }
        
    }
    
}

@end
