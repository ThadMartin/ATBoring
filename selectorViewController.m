//
//  selectorViewController.m
//  ATWR
//
//  Created by Thad Martin on 11/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "selectorViewController.h"
#import "ATBoringAppDelegate.h"
#import "ATBoringViewController.h"

@implementation selectorViewController{
    ATBoringAppDelegate * appDelegate;
}

//@synthesize tableView;

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
    // Do any additional setup after loading the view from its nib.
    appDelegate = [[UIApplication sharedApplication] delegate];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [appDelegate.allQnsAndPaths count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
        
     UIView * footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)]; 
     footer.backgroundColor = [UIColor clearColor];   //footer makes table stop when it should.
     [tableView setTableFooterView:footer];
    
    NSMutableArray * lastPart = [[NSMutableArray alloc]init];
    
    for (NSString * pathName in appDelegate.allQnsAndPaths){
        [lastPart addObject:[pathName lastPathComponent]];
    }
    
    cell.textLabel.text = [lastPart objectAtIndex:indexPath.row] ;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * infile = [appDelegate.allQnsAndPaths objectAtIndex:indexPath.row];
    
    //NSLog(@"allQnsAndPaths: %@",appDelegate.allQnsAndPaths);
    
    NSLog(@"Selected for input:%@",infile);
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    ATBoringViewController * mainView = [[ATBoringViewController alloc] init];
    
    mainView.infile = infile;
    
    [self presentModalViewController:mainView animated:NO];
    
}

- (void)viewDidUnload
{
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

@end
