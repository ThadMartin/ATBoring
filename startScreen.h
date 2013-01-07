//
//  startScreen.h
//  ATWR
//
//  Created by Thad Martin on 11/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface startScreen : UIViewController <DBRestClientDelegate>

@property (weak, nonatomic) IBOutlet UILabel *linkLabel;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@property (weak, nonatomic) IBOutlet UIButton *linkButton;
- (IBAction)linkButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *unlinkButton;
- (IBAction)unlinkButtonPressed:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
- (IBAction)downloadButtonPressed:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *continueButton;
- (IBAction)continueButtonPressed:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
- (IBAction)uploadButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *quitButton;
- (IBAction)quitButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *clearButton;
- (IBAction)clearButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *downloadDirLabel;

@property (weak, nonatomic) IBOutlet UILabel *uploadDirLabel;

@property (weak, nonatomic) IBOutlet UIButton *downloadDirChange;

@property (weak, nonatomic) IBOutlet UIButton *uploadDirChange;

@property (weak, nonatomic) IBOutlet UITextField *downloadDirText;

@property (weak, nonatomic) IBOutlet UITextField *uploadDirtext;
- (IBAction)downloadDirChangePressed:(id)sender;
- (IBAction)uploadDirChangePressed:(id)sender;


@end


