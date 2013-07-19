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
        self.view.backgroundColor = [UIColor whiteColor];
    }
    self.commentView.text = self.task.commentText;
    if ([self.task.visited boolValue]) {
        self.commentView.editable = NO;
        
// _________for testing
//        self.commentView.editable = YES;
//        self.commentView.delegate = self;
// ____________________
        
    } else {
        self.commentView.editable = YES;
        self.commentView.delegate = self;
    }
}

#pragma mark - textView delegate

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    NSLog(@"textViewShouldEndEditing");
    self.task.commentText = textView.text;
    return YES;
}

//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
//    if (![textField.text isEqualToString:@""]) {
//        if (![textField.text isEqualToString:self.spot.label]) {
//            self.spot.label = textField.text;
//            [self.tracker.document saveToURL:self.tracker.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
//                NSLog(@"spot.label UIDocumentSaveForOverwriting success");
//            }];
//        }
//    }
//    return YES;
//}
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    [textField resignFirstResponder];
//    return YES;
//}



#pragma mark - view lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self viewInit];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
