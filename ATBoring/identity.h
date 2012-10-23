//
//  identity.h
//  ATBoring
//
//  Created by Thad Martin on 10/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface identity : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *studentIDlabel;
@property (weak, nonatomic) NSDictionary * currentProblemDict;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
- (IBAction)continueButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
- (IBAction)cancelButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end
