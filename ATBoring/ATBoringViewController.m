//
//  AT_BoringViewController.m
//  AT_Boring
//
//  Created by Thad Martin on 9/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ATBoringViewController.h"

@implementation ATBoringViewController{
    
    scratchPadDraw * drawScreen;
    DBRestClient * restClient;
    bool online;
    bool linkedDB;
    NSTimer * timer;
    int uploadCount;
    int didUpload;
    NSFileManager *filemgr;
    NSString * docPath;
    int downloadCount;
    NSMutableArray * problemList;
    NSMutableDictionary * problemListDict;
    NSMutableDictionary * currentProblemDict;
    int currentProblem;
    int numOfProblems;
    bool showingSolution;
    NSString * logFile;
}


@synthesize continueButton;
@synthesize problemLabel;
@synthesize clearButton;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    online = false;
    linkedDB = false;
    showingSolution = false;
    currentProblem = 1;
    logFile = @"";
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docPath = [paths objectAtIndex:0];           //All downloaded files and files to be uploaded.  Nothing from bundle path.
}

-(void) updateLinkStatus:(NSTimer*)timer2{       //We gave dropbox another 3 sec.   Did it work?
    //NSLog(@"still trying to link to dropbox");
    if ([[DBSession sharedSession] isLinked]){
        problemLabel.text = @"app linked to dropbox";
        [clearButton setTitle:@"download" forState:normal];
        [continueButton setTitle:@"upload" forState:normal];
        [timer invalidate];
        linkedDB = true;
    }else{
        [[DBSession sharedSession] linkFromController:self];
    }
}

- (void)viewDidUnload
{
    [self setClearButton:nil];
    [self setContinueButton:nil];
    [self setProblemLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!restClient) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    }
    restClient.delegate = self;
    
    
    NSString *URLString = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.google.com"] encoding:NSUTF8StringEncoding error:nil];
    if ( URLString != NULL ){  //we are online, link dropbox and upload or download.
        online = true;
        
        if (![[DBSession sharedSession] isLinked]) {
            [[DBSession sharedSession] linkFromController:self];
            
            if (![[DBSession sharedSession] isLinked]) {
                int timerTimeNumber = 3;
                timer = [NSTimer scheduledTimerWithTimeInterval:timerTimeNumber target:self selector:@selector(updateLinkStatus:) userInfo:nil repeats:YES];
                NSRunLoop *runner = [NSRunLoop currentRunLoop];
                [runner addTimer: timer forMode: NSDefaultRunLoopMode];
            }
        }
        
        if ([[DBSession sharedSession] isLinked]) {
            linkedDB = true;
            [clearButton setTitle:@"download" forState:normal];
            [continueButton setTitle:@"upload" forState:normal];
            
        }
    }
    
    else{  //we are offline.  Load the json file, go to next (first) problem.
        
        NSString * jsonFile = [docPath stringByAppendingPathComponent:@"problems.json"];        
        NSData *problemListData = [[NSMutableData alloc] initWithContentsOfFile:jsonFile];
        
        NSError *error;
        if(problemListData == nil)
            NSLog(@"problem list not found");
        
        problemListDict = [NSJSONSerialization JSONObjectWithData:problemListData options:NSJSONWritingPrettyPrinted error:&error];
        problemList = [problemListDict objectForKey:@"problem-list"];
        numOfProblems = [problemList count];
        
        if(error != nil)
            NSLog(@"error:%@",error);
        
        currentProblemDict = [problemList objectAtIndex:currentProblem-1 ];        
        
        NSString * problemText = [currentProblemDict objectForKey:@"start"];
        //NSLog(@"current problem:  %@",problemText);
        
        NSString * solveText = [NSString stringWithFormat:@"Solve:  %@",problemText];
        
        self.problemLabel.text = solveText;
        [self.view setBackgroundColor:[UIColor whiteColor]];
        
        drawScreen=[[scratchPadDraw alloc]initWithFrame:CGRectMake(0, 40, 768, 1004)];
        [self.view addSubview:drawScreen];
        
        //put the answer box in place.
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(384,850,self.view.bounds.size.width, 1)];
        lineView.backgroundColor = [UIColor blackColor];
        [drawScreen addSubview:lineView];        
        lineView = [[UIView alloc] initWithFrame:CGRectMake(384,850,1,self.view.bounds.size.height)];
        lineView.backgroundColor = [UIColor blackColor];
        [drawScreen addSubview:lineView];
        
        NSDate * myDate = [NSDate date];
        NSDateFormatter * df = [NSDateFormatter new];
        [df setDateFormat:@"dd_MMMMyyyy_HH_mm_ss.SSS"];
        NSString * nowDate =  [df stringFromDate:myDate];
        
        NSString * logline = [NSString stringWithFormat:@"problem %d presented at: %@ \n",currentProblem,nowDate];        
        logFile = [logFile stringByAppendingString:logline];
        
    }
    
    
}


- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) 
        return NO;   
    else
        return YES;
}


-(void)leaveNoLog{
    [NSThread sleepForTimeInterval:3]; 
    exit(0);
}

-(void)leave{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSDate *myDate = [NSDate date];
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"dd_MMMMyyyy_HH_mm_ss.SSS"];
    NSString * nowDate =  [df stringFromDate:myDate];
    
    NSString * fileName = [NSString stringWithFormat: @"ATBoring__%@__%@.txt",[[UIDevice currentDevice] name], nowDate];
    NSString *localFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSError * error;
    
    [logFile writeToFile:localFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    [NSThread sleepForTimeInterval:3]; 
    
    exit(0);
}


- (void)downloadDB{
    
    if (!restClient) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    }
    restClient.delegate = self;
    
    NSString * directory = @"/download/";
    //NSLog(@"loading metadata");
    [restClient loadMetadata:directory];
    
}

- (void)uploadDB{
    
    if (!restClient) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    }
    restClient.delegate = self;
    
    filemgr = [NSFileManager defaultManager];
    
    NSString *destDir = @"/upload/";
    
    NSArray * filelist= [filemgr contentsOfDirectoryAtPath:docPath error:nil];
    
    NSMutableArray * answerFiles = [[NSMutableArray alloc] init];
    
    for (NSString * fileName in filelist){  //pick out the .jpg and .txt files, but not the solutions that are named Silde.
        if([fileName hasSuffix:@".jpg"]||[fileName hasSuffix:@".txt"]){
            if(! [fileName hasPrefix:@"Slide"])
                [answerFiles addObject:fileName];
        }
    }
    
    
    for(NSString * existing in answerFiles){
        uploadCount++;
        NSString * filePathName = [docPath stringByAppendingPathComponent:existing];
        [restClient uploadFile:existing toPath:destDir withParentRev:nil  fromPath:filePathName];
    }  // end of step through 
    
    if ([answerFiles count] ==0){
        self.problemLabel.text = @"nothing left to upload.";
        [self performSelector:@selector(leaveNoLog) withObject:self afterDelay:0.0];
        
    }
}

- (void)showSolution{
    
    showingSolution = true;
    
    [clearButton setHidden:true];
    
    for(UIView *view in [self.view subviews])
    {
        if(![view isKindOfClass:[UIButton class]]&&![view isKindOfClass:[UILabel class]])
            [view removeFromSuperview];
    }
    
    UIImageView * solutionImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 768, 1004)];
    NSString * imgName = [currentProblemDict objectForKey:@"solution"];
    imgName = [docPath stringByAppendingPathComponent:imgName];
    //NSLog(@"imgName: %@ ",imgName);
    UIImage * theImage = [UIImage imageWithContentsOfFile:imgName];
    solutionImg.contentMode = UIViewContentModeCenter;  //default autoresize doesn't look good.
    [solutionImg setImage:theImage];
    [self.view addSubview:solutionImg];
}

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
    downloadCount = 0;
    
    NSLog(@"loaded metadata");
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    
    if (metadata.isDirectory) {
        for (DBMetadata *file in metadata.contents) {
            downloadCount++;
            NSString * dropboxPath = [@"/download/" stringByAppendingString:file.filename];
            NSString * localPath = [documentsDirectory stringByAppendingPathComponent:file.filename];
            [restClient loadFile:dropboxPath intoPath:localPath];
            NSLog(@" loading files:  %i",downloadCount);
        }
    }//if not a directory, in wrong place.
    if(downloadCount == 0){
        self.problemLabel.text = @"nothing left to download";
        [self performSelector:@selector(leaveNoLog) withObject:self afterDelay:0.0];
    }
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath {
    NSLog(@"got one.");
    downloadCount--;
    if(downloadCount == 0){
        self.problemLabel.text = @"download complete";
        [self performSelector:@selector(leaveNoLog) withObject:self afterDelay:0.0];
    }
}


- (void)restClient:(DBRestClient*)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath {
    didUpload ++;
    
    NSError * error;
    [filemgr removeItemAtPath:srcPath error:&error];
    
    if(error)
        NSLog(@"error: %@",error);
    
    if (didUpload >= uploadCount){
        self.problemLabel.text = @"upload complete";
        [self performSelector:@selector(leaveNoLog) withObject:self afterDelay:0.0];
    }
}


- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    NSLog(@"Error loading metadata: %@", error);
}

- (IBAction)clearButtonPressed:(id)sender {
    
    if(online && linkedDB){  //this is the download button now.
        //NSLog(@"downloading");
        [self performSelector:@selector(downloadDB) withObject:sender afterDelay:0.0];
    }
    else{    
        //save cleared...
        
        UIView * saveView = self.view;
        UIGraphicsBeginImageContext(saveView.bounds.size);
        [saveView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage * viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSDate *myDate = [NSDate date];
        NSDateFormatter *df = [NSDateFormatter new];
        [df setDateFormat:@"dd_MMMMyyyy_HH_mm_ss.SSS"];
        NSString * nowDate =  [df stringFromDate:myDate];
        
        NSString * fileName = [NSString stringWithFormat: @"ATBoring_Cleared_%@__%@.jpg",[[UIDevice currentDevice] name], nowDate];
        NSString *localFilePath = [docPath stringByAppendingPathComponent:fileName];
        [UIImageJPEGRepresentation(viewImage, 1.0) writeToFile:localFilePath atomically:YES];
        
        NSString * logline = [NSString stringWithFormat:@"problem %d cleared at: %@ , filename: %@ \n",currentProblem,nowDate,fileName];
        logFile = [logFile stringByAppendingString:logline];
        
        // and clear the scratchpad.
        for(UIView *view in [self.view subviews])
        {
            if(![view isKindOfClass:[UIButton class]]&&![view isKindOfClass:[UILabel class]])
                [view removeFromSuperview];
        }
        
        drawScreen=[[scratchPadDraw alloc]initWithFrame:CGRectMake(0, 40, 768, 1004)];
        [self.view addSubview:drawScreen];
        
        //put the answer box back in place.
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(384,850,self.view.bounds.size.width, 1)];
        lineView.backgroundColor = [UIColor blackColor];
        [drawScreen addSubview:lineView];        
        lineView = [[UIView alloc] initWithFrame:CGRectMake(384,850,1,self.view.bounds.size.height)];
        lineView.backgroundColor = [UIColor blackColor];
        [drawScreen addSubview:lineView];
    }
    
}

- (IBAction)continueButtonPressed:(id)sender {
    
    if(online && linkedDB)  //this is the upload button now.
        [self performSelector:@selector(uploadDB) withObject:sender afterDelay:0.0];
    else{ 
        
        if (! showingSolution){
            
            //save
            
            UIView * saveView = self.view;
            UIGraphicsBeginImageContext(saveView.bounds.size);
            [saveView.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            NSDate *myDate = [NSDate date];
            NSDateFormatter *df = [NSDateFormatter new];
            [df setDateFormat:@"dd_MMMMyyyy_HH_mm_ss.SSS"];
            NSString * nowDate =  [df stringFromDate:myDate];
            
            NSString * fileName = [NSString stringWithFormat: @"ATBoring__%@__%@.jpg",[[UIDevice currentDevice] name], nowDate];
            NSString *localFilePath = [docPath stringByAppendingPathComponent:fileName];
            [UIImageJPEGRepresentation(viewImage, 1.0) writeToFile:localFilePath atomically:YES];
            
            NSString * logline = [NSString stringWithFormat:@"problem %d submitted at: %@ , filename: %@ \n",currentProblem,nowDate,fileName];
            logFile = [logFile stringByAppendingString:logline];
            
            
            [self performSelector:@selector(showSolution) withObject:sender afterDelay:0.0];
        }
        if(showingSolution){
            showingSolution = false;
            [clearButton setHidden:false];
            for(UIView *view in [self.view subviews])
            {
                if(![view isKindOfClass:[UIButton class]]&&![view isKindOfClass:[UILabel class]])
                    [view removeFromSuperview];
            }
            currentProblem ++;
            
            if (currentProblem > numOfProblems){
                self.problemLabel.text = @"Thank you, that is all.";
                [self performSelector:@selector(leave) withObject:sender afterDelay:0.0];
            }
            
            else{  // here we present the next problem.
                
                
                currentProblemDict = [problemList objectAtIndex:currentProblem-1 ];
                
                NSString * problemText = [currentProblemDict objectForKey:@"start"];
                
                NSString * solveText = [NSString stringWithFormat:@"Solve:  %@",problemText];
                
                self.problemLabel.text = solveText;
                
                [self.view setBackgroundColor:[UIColor whiteColor]];
                
                drawScreen=[[scratchPadDraw alloc]initWithFrame:CGRectMake(0, 40, 768, 1004)];
                [self.view addSubview:drawScreen];
                
                //put the answer box in place.
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(384,850,self.view.bounds.size.width, 1)];
                lineView.backgroundColor = [UIColor blackColor];
                [drawScreen addSubview:lineView];        
                lineView = [[UIView alloc] initWithFrame:CGRectMake(384,850,1,self.view.bounds.size.height)];
                lineView.backgroundColor = [UIColor blackColor];
                [drawScreen addSubview:lineView];
                
                NSDate * myDate = [NSDate date];
                NSDateFormatter * df = [NSDateFormatter new];
                [df setDateFormat:@"dd_MMMMyyyy_HH_mm_ss.SSS"];
                NSString * nowDate =  [df stringFromDate:myDate];
                NSString * logline = [NSString stringWithFormat:@"problem %d presented at: %@\n",currentProblem,nowDate];
                logFile = [logFile stringByAppendingString:logline];
                
                
            }//not at the end of problems
        }//end of present next problem
    }//end of upload
}
@end
