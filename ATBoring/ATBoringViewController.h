//
//  AT_BoringViewController.h
//  AT_Boring
//
//  Created by Thad Martin on 9/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "scratchPadDraw.h"
//#import <QuartzCore/QuartzCore.h>
#import "ATBoringAppDelegate.h"
//#import <DropboxSDK/DropboxSDK.h>

@interface ATBoringViewController : UIViewController // <DBRestClientDelegate>

@property (weak, nonatomic) IBOutlet UILabel *problemLabel;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
- (IBAction)clearButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
- (IBAction)continueButtonPressed:(id)sender;
@property(weak, nonatomic) NSString * infile;
//@property (nonatomic, strong) NSMutableDictionary *problemListDict;

@end