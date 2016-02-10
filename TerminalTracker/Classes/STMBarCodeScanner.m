//
//  STMBarCodeScanner.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 09/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMBarCodeScanner.h"

#import <CoreData/CoreData.h>
#import <AVFoundation/AVFoundation.h>

#import "STTTAgentBarcodeType.h"
#import <STManagedTracker/STSessionManager.h>


@interface STMBarCodeScanner() <UITextFieldDelegate, AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) UITextField *hiddenBarCodeTextField;

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;

@property (nonatomic) BOOL isCheckingBarcode;


@end


@implementation STMBarCodeScanner

- (instancetype)initWithMode:(STMBarCodeScannerMode)mode {

    self = [super init];
    
    if (self) {
        
        _mode = mode;
        _status = STMBarCodeScannerStopped;
        
    }
    return self;

}

- (NSString *)scannerName {
    
    switch (self.mode) {
        case STMBarCodeScannerCameraMode: {
            return @"Camera scanner";
            break;
        }
        case STMBarCodeScannerHIDKeyboardMode: {
            return @"HID scanner";
            break;
        }
    }
    
}

- (void)startScan {
    
    if (self.status != STMBarCodeScannerStarted) {
        
        _status = STMBarCodeScannerStarted;

        switch (self.mode) {
            case STMBarCodeScannerCameraMode: {
                
                [self prepareForCameraMode];
                break;
                
            }
            case STMBarCodeScannerHIDKeyboardMode: {
                
                [self prepareForHIDScanMode];
                break;
                
            }
            default: {
                break;
            }
        }

    }
    
}

- (void)stopScan {
    
    if (self.status != STMBarCodeScannerStopped) {
        
        _status = STMBarCodeScannerStopped;
        
        switch (self.mode) {
            case STMBarCodeScannerCameraMode: {
                
                [self finishCameraMode];
                break;
                
            }
            case STMBarCodeScannerHIDKeyboardMode: {
                
                [self finishHIDScanMode];
                break;
                
            }
            default: {
                break;
            }
        }
        
        self.delegate = nil;
        
    }

}

- (void)checkScannedBarcode:(NSString *)barcode withType:(NSString *)type {
    
    self.isCheckingBarcode = YES;
    
    if ([type isEqualToString:AVMetadataObjectTypeCode128Code]) {
        
        BOOL barcodeIsGood = NO;
        
        NSArray *masks = [self terminalInvNumberBarcodeMasks];
        
        for (NSString *mask in masks) {
            
            if (mask) {
                
                NSError *error = nil;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:(NSString * _Nonnull)mask
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:&error];
                
                NSUInteger numberOfMatches = [regex numberOfMatchesInString:barcode
                                                                    options:0
                                                                      range:NSMakeRange(0, barcode.length)];
                
                if (numberOfMatches > 0) {
                    
                    barcodeIsGood = YES;
                    break;
                    
                }
                
            }
            
        }
        
        if (barcodeIsGood) {
            [self didSuccessfullyScan:barcode];
        }
        
    }
    
    self.isCheckingBarcode = NO;

}

- (NSArray *)terminalInvNumberBarcodeMasks {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STTTAgentBarcodeType class])];
    request.predicate = [NSPredicate predicateWithFormat:@"type == %@ && symbology == %@", [self terminalInvNumberType], [self terminalInvNumberSymbology]];
    
    NSManagedObjectContext *context = [[STSessionManager sharedManager].currentSession document].managedObjectContext;

    NSArray *result = [context executeFetchRequest:request error:nil];
    
    NSArray *masks = [result valueForKeyPath:@"@distinctUnionOfObjects.mask"];
    
    return masks;
    
}

- (NSString *)terminalInvNumberType {
    return @"terminal-inv-number";
}

- (NSString *)terminalInvNumberSymbology {
    return [self symbologyForMachineReadableObjectType:AVMetadataObjectTypeCode128Code];
}

- (NSString *)machineReadableObjectTypeForSymbology:(NSString *)symbology {
    
    if ([symbology isEqualToString:@"Code 128"]) {
        return AVMetadataObjectTypeCode128Code;
    }
    
    return nil;
    
}

- (NSString *)symbologyForMachineReadableObjectType:(NSString *)type {
    
    if ([type isEqualToString:AVMetadataObjectTypeCode128Code]) {
        return @"Code 128";
    }
    
    return nil;
    
}


#pragma mark - STMBarCodeScannerCameraMode

- (void)prepareForCameraMode {
    
    if ([STMBarCodeScanner isCameraAvailable]) {
        
        [self setupScanner];
        
    } else {
        
        NSString *bundleId = [NSBundle mainBundle].bundleIdentifier;
        
        NSError *error = [NSError errorWithDomain:(NSString * _Nonnull)bundleId
                                             code:0
                                         userInfo:@{NSLocalizedDescriptionKey: @"No camera available"}];
        
        [self.delegate barCodeScanner:self receiveError:error];
        
        [self stopScan];
        
    }

}

- (void)finishCameraMode {
    
    [self.session stopRunning];
    [self.preview removeFromSuperlayer];
    
    [self.delegate cameraLayer:nil];

    self.preview = nil;
    self.output = nil;
    self.session = nil;
    self.input = nil;
    self.device = nil;
    
}

+ (BOOL)isCameraAvailable {
    
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    return ([videoDevices count] > 0);
    
}

- (void)setupScanner {
    
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    self.session = [[AVCaptureSession alloc] init];
    self.output = [[AVCaptureMetadataOutput alloc] init];
    
    [self.session addOutput:self.output];
    [self.session addInput:self.input];
    
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    self.output.metadataObjectTypes = self.output.availableMetadataObjectTypes;
    
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    UIView *superView = [self.delegate viewForScanner:self];
    self.preview.frame = superView.bounds;

    AVCaptureConnection *con = self.preview.connection;
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    switch (interfaceOrientation) {
        case UIInterfaceOrientationUnknown: {
            break;
        }
        case UIInterfaceOrientationPortrait: {
            con.videoOrientation = AVCaptureVideoOrientationPortrait;
            break;
        }
        case UIInterfaceOrientationPortraitUpsideDown: {
            con.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        }
        case UIInterfaceOrientationLandscapeLeft: {
            con.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        }
        case UIInterfaceOrientationLandscapeRight: {
            con.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        }
    }
    
    [superView.layer insertSublayer:self.preview above:superView.layer];

    [self.delegate cameraLayer:self.preview];

    [self.session startRunning];

}


#pragma mark AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    for (AVMetadataObject *current in metadataObjects) {
        
        if([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            
            AVMetadataMachineReadableCodeObject *readableCodeObject = (AVMetadataMachineReadableCodeObject *)current;
            
            NSLog(@"readableCodeObject.type %@", readableCodeObject.type);
            
            NSString *scannedValue = readableCodeObject.stringValue;
            
            NSLog(@"scannedValue %@", scannedValue);
            
            if (!self.isCheckingBarcode) {
                [self checkScannedBarcode:scannedValue withType:readableCodeObject.type];
            }
            
        }
        
    }
    
}

- (void)didSuccessfullyScan:(NSString *)aScannedValue {
    
    //    NSLog(@"aScannedValue %@", aScannedValue);

    [self.delegate barCodeScanner:self receiveBarCode:aScannedValue];

    [self stopScan];
    
}


#pragma mark - STMBarCodeScannerHIDKeyboardMode

- (void)prepareForHIDScanMode {

    
    self.hiddenBarCodeTextField = [[UITextField alloc] init];
    
    self.hiddenBarCodeTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.hiddenBarCodeTextField.keyboardType = UIKeyboardTypeASCIICapable;
    
    if ([self.hiddenBarCodeTextField respondsToSelector:@selector(inputAssistantItem)]) {
        
        UITextInputAssistantItem *inputAssistantItem = self.hiddenBarCodeTextField.inputAssistantItem;
        inputAssistantItem.leadingBarButtonGroups = @[];
        inputAssistantItem.trailingBarButtonGroups = @[];
        
    }

    [self.hiddenBarCodeTextField becomeFirstResponder];
    
    self.hiddenBarCodeTextField.delegate = self;
    
    [[self.delegate viewForScanner:self] addSubview:self.hiddenBarCodeTextField];

}

- (void)finishHIDScanMode {
    
    [self.hiddenBarCodeTextField resignFirstResponder];
    [self.hiddenBarCodeTextField removeFromSuperview];
    self.hiddenBarCodeTextField.delegate = nil;
    self.hiddenBarCodeTextField = nil;
    
}


#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self checkScannedBarcode:textField.text withType:nil];
    textField.text = @"";
    
    return NO;
    
}


@end
