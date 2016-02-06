//
//  STTTMainNC.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 06/02/16.
//  Copyright © 2016 Maxim Grigoriev. All rights reserved.
//

#import "STTTMainNC.h"

@interface STTTMainNC ()

@end

@implementation STTTMainNC

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
//    return (self.shouldRotate) ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait;

    return UIInterfaceOrientationMaskPortrait;
    
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
//    self.shouldRotate = YES;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
