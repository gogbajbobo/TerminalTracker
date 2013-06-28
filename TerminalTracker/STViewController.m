//
//  STViewController.m
//  TerminalTracker
//
//  Created by Maxim Grigoriev on 6/17/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STViewController.h"
#import <STManagedTracker/STRequestAuthenticatable.h>
#import <STManagedTracker/STSessionManager.h>
#import <STManagedTracker/STSession.h>
#import "STTTSyncer.h"

@interface STViewController ()

@property (nonatomic, strong) id <STRequestAuthenticatable> authDelegate;
@property (nonatomic, strong) STSession *currentSession;
@property (nonatomic, strong) NSMutableData *responseData;


@end

@implementation STViewController

- (IBAction)buttonPressed:(id)sender {
    NSLog(@"buttonPressed");
    [self sync];
}

- (STSession *)currentSession {
    if (!_currentSession) {
        _currentSession = [[STSessionManager sharedManager] currentSession];
    }
    return _currentSession;
}

- (id <STRequestAuthenticatable>)authDelegate {
    if (!_authDelegate) {
        _authDelegate = self.currentSession.authDelegate;
    }
    return _authDelegate;
}

- (void)sync {
    
//    NSString *serverUrlString = @"https://system.unact.ru/iproxy/rest/test/megaport.iAgentTerminal";
//    NSString *serverUrlString = @"https://system.unact.ru/iproxy/rest/test/megaport.iAgentTask";
//    NSURL *requestURL = [NSURL URLWithString:serverUrlString];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
//    [request setHTTPMethod:@"POST"];
    
    
//    NSString *postData = @"@shift=-13&page-size:=20&page-number:=1";
//    NSString *postData = @"";
//    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];

//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    
//    [(STTTSyncer *)self.currentSession.syncer setRequestType:@"megaport.iAgentTerminal"];
//    [self.currentSession.syncer syncData];

//    [self.currentSession.syncer sendData:nil toServer:serverUrlString withParameters:postData];
    
    
//    request = [[self.authDelegate authenticateRequest:(NSURLRequest *) request] mutableCopy];
//    
//    NSLog(@"request %@", request);
//    
//    NSLog(@"valueForHTTPHeaderField:Authorization %@", [request valueForHTTPHeaderField:@"Authorization"]);
//    if ([request valueForHTTPHeaderField:@"Authorization"]) {
//        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//        if (!connection) {
//            [[self.currentSession logger] saveLogMessageWithText:@"Syncer no connection" type:@"error"];
////            self.syncing = NO;
//        } else {
//            [[self.currentSession logger] saveLogMessageWithText:@"Syncer send data" type:@""];
//        }
//    } else {
//        [[self.currentSession logger] saveLogMessageWithText:@"Syncer no authorization header" type:@"error"];
////        self.syncing = NO;
//    }

}


#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
//    self.syncing = NO;
    NSString *errorMessage = [NSString stringWithFormat:@"connection did fail with error: %@", error];
    [[self.currentSession logger] saveLogMessageWithText:errorMessage type:@"error"];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.responseData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}



- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    //    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"json"];
    //    self.responseData = [NSData dataWithContentsOfFile:dataPath];
    //
    NSString *responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    NSLog(@"connectionDidFinishLoading responseData %@", responseString);

}





- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
