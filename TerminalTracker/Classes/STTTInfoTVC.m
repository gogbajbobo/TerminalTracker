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
#import "STTTTaskVC.h"
#import "STTTTerminalVC.h"

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([self.tableView.dataSource isKindOfClass:[STTTTaskController class]]) {
        STTTTaskController *taskController = (STTTTaskController *)self.tableView.dataSource;
        id <NSFetchedResultsSectionInfo> sectionInfo = [[taskController.resultsController sections] objectAtIndex:indexPath.section];
        STTTAgentTask *task = (STTTAgentTask *)[[sectionInfo objects] objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"showTask" sender:task];
        
    } else if ([self.tableView.dataSource isKindOfClass:[STTTTerminalController class]]) {
        STTTTerminalController *terminalController = (STTTTerminalController *)self.tableView.dataSource;
        id <NSFetchedResultsSectionInfo> sectionInfo = [[terminalController.resultsController sections] objectAtIndex:indexPath.section];
        STTTAgentTerminal *terminal = (STTTAgentTerminal *)[[sectionInfo objects] objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"showTerminal" sender:terminal];
        
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showTask"]) {
        if ([segue.destinationViewController isKindOfClass:[STTTTaskVC class]] && [sender isKindOfClass:[STTTAgentTask class]]) {
            [(STTTTaskVC *)segue.destinationViewController setTask:(STTTAgentTask *)sender];
//            [(STTTTaskVC *)segue.destinationViewController setBackgroundColors:self.backgroundColors];
        }
    } else if ([segue.identifier isEqualToString:@"showTerminal"]) {
        if ([segue.destinationViewController isKindOfClass:[STTTTerminalVC class]] && [sender isKindOfClass:[STTTAgentTerminal class]]) {
            [(STTTTerminalVC *)segue.destinationViewController setTerminal:(STTTAgentTerminal *)sender];
//            [(STTTTerminalVC *)segue.destinationViewController setBackgroundColors:self.backgroundColors];
        }
    }
    
}

@end
