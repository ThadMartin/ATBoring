//
//  identity.m
//  ATBoring
//
//  Created by Thad Martin on 10/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "identity.h"

@implementation identity
@synthesize textField;
@synthesize cancelButton;
@synthesize studentIDlabel;
@synthesize currentProblemDict;
@synthesize continueButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString * problemText = [currentProblemDict objectForKey:@"text"];
    studentIDlabel.text = problemText;
    NSLog(@"from identity");
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setStudentIDlabel:nil];
    [self setContinueButton:nil];
    [self setCancelButton:nil];
    [self setTextField:nil];
    [self setTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) 
        return NO;   
    else
        return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField{
    [theTextField resignFirstResponder];
    return (YES);
}



- (IBAction)continueButtonPressed:(id)sender {
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * docPath = [paths objectAtIndex:0]; 
    
    if ([[currentProblemDict objectForKey:@"type"] isEqualToString: @"studentID"])
        docPath = [docPath stringByAppendingPathComponent:@"studentID.id"];
    
    if ([[currentProblemDict objectForKey:@"type"]isEqualToString:@"classID"])
        docPath = [docPath stringByAppendingPathComponent:@"classID.id"];

    
    NSError * error;
    
    NSString * identifyInfo = self.textField.text;
    
    [identifyInfo writeToFile:docPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    NSLog(@"info: %@ path:%@",identifyInfo,docPath);
    
    [self dismissModalViewControllerAnimated:false];
}
- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissModalViewControllerAnimated:false];

}
@end
