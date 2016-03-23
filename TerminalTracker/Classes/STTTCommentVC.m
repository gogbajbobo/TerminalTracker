//
//  STTTCommentVC.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 7/4/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STTTCommentVC.h"

@interface STTTCommentVC () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *commentView;

@end

@implementation STTTCommentVC


- (void)viewInit {
    
    if ([[self.backgroundColors valueForKey:@"task"] isKindOfClass:[UIColor class]]) {
        self.view.backgroundColor = [self.backgroundColors valueForKey:@"task"];
    } else {
        self.view.backgroundColor = [UIColor lightGrayColor];
    }
    
    self.commentView.text = self.task.commentText;
    
    if ([self.task.servstatus boolValue]) {
        
        self.commentView.editable = NO;
     
#warning !!!!
// _________for testing
        self.commentView.editable = YES;
        self.commentView.delegate = self;
// ____________________
        
    } else {
        
        self.commentView.editable = YES;
        self.commentView.delegate = self;
        
    }

}

#pragma mark - textView delegate

//- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
//    
//    self.task.commentText = textView.text;
//    return YES;
//    
//}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    self.task.commentText = textView.text;
    [self.taskTVC taskCommentWasUpdated];
    
}


#pragma mark - view lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self viewInit];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
