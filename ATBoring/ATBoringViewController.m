//
//  AT_BoringViewController.m
//  AT_Boring
//
//  Created by Thad Martin on 9/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ATBoringViewController.h"
#import "identity.h"
#import "info.h"

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
    UIView * ansView;
    UIImage * ansImage;
    NSString * logFileName;
    NSString * studentID;
    NSString * classID;
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
    
    NSDate * myDate = [NSDate date];
    NSDateFormatter * df = [NSDateFormatter new];
    [df setDateFormat:@"dd_MMMMyyyy_HH_mm_ss.SSS"];
    NSString * nowDate =  [df stringFromDate:myDate];
    
    NSString * fileName = [NSString stringWithFormat: @"ATBoring__%@__%@.txt",[[UIDevice currentDevice] name], nowDate];
    logFileName = [docPath stringByAppendingPathComponent:fileName];
    
}

-(void) updateLinkStatus:(NSTimer*)timer2{       //We gave dropbox another 3 sec.   Did it work?
    //NSLog(@"still trying to link to dropbox");
    if ([[DBSession sharedSession] isLinked]){
        problemLabel.text = @"app linked to dropbox";
        [clearButton setTitle:@"download" forState:normal];
        [continueButton setTitle:@"upload" forState:normal];
        [timer invalidate];
        linkedDB = true;
    }//else{
      //  [[DBSession sharedSession] linkFromController:self];
    //}
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
    
    //    if (!restClient && [[DBSession sharedSession] isLinked]) {
    //        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    //        restClient.delegate = self;
    //    }
    //if ([[DBSession sharedSession] isLinked]) {
    //    [[DBSession sharedSession] unlinkAll];
    //    exit(0);
    //}
    
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }
    
    NSLog(@"view did appear ran.");
    
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
        
        NSString * jsonFile = [docPath stringByAppendingPathComponent:@"problems_id2.json"];        
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
        
        
        NSString * studentID_path = [docPath stringByAppendingPathComponent:@"studentID.id"];
        
        NSData *data = [NSData dataWithContentsOfFile:studentID_path];
        
        studentID = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSString * classID_path = [docPath stringByAppendingPathComponent:@"classID.id"];
        
        NSData * classData = [NSData dataWithContentsOfFile:classID_path];
        
        classID = [[NSString alloc] initWithData:classData encoding:NSUTF8StringEncoding];
        
        
        
        identity* ident = [[identity alloc] init];
        
        info * instructions = [[info alloc] init];
        
        if([problemText isEqualToString:@"identification"]||[problemText isEqualToString:@"instruction"]){
            currentProblem ++;
            
            if ([problemText isEqualToString:@"identification"]){
                
                ident.currentProblemDict = currentProblemDict;
                [self presentModalViewController:ident animated:false ];
                
            }
            
            if ([problemText isEqualToString:@"instruction"]){
                
                instructions.currentProblemDict = currentProblemDict;
                [self presentModalViewController:instructions animated:false ];
            }
            
         }
        else{
            
            NSString * solveText = [NSString stringWithFormat:@"Simplify:  %@",problemText];
            
            self.problemLabel.text = solveText;
            [self.view setBackgroundColor:[UIColor whiteColor]];
            
            drawScreen=[[scratchPadDraw alloc]initWithFrame:CGRectMake(0, 100, 768, 1004)];
            [self.view addSubview:drawScreen];
            
            //put the answer box in place.
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0,640,self.view.bounds.size.width, 1)];
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

- (void)showSolution{
    
    showingSolution = true;
    
    [clearButton setHidden:true];
    
    for(UIView *view in [self.view subviews])
    {
        if(![view isKindOfClass:[UIButton class]]&&![view isKindOfClass:[UILabel class]])
            [view removeFromSuperview];
        
    }
    
    UIImageView * solutionImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, 768, 640)];
    NSString * imgName = [currentProblemDict objectForKey:@"solution"];
    imgName = [docPath stringByAppendingPathComponent:imgName];
    //NSLog(@"imgName: %@ ",imgName);
    UIImage * theImage = [UIImage imageWithContentsOfFile:imgName];
    //solutionImg.contentMode = UIViewContentModeCenter;  //default autoresize doesn't look good.
    solutionImg.contentMode = UIViewContentModeScaleAspectFit;
    [solutionImg setImage:theImage];
    [self.view addSubview:solutionImg];
    UIImageView * showAns = [[UIImageView alloc] initWithFrame:CGRectMake(0,739,ansImage.size.width,ansImage.size.height)];  
    [showAns setImage:ansImage];
    [self.view addSubview:showAns];
    ansImage = nil;
    ansView = nil;
    showAns = nil;
    solutionImg = nil;
    theImage = nil;
    
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
        
        df = nil;
        
        NSString * fileName = [NSString stringWithFormat: @"ATBoring_Cleared_%@__%@__%@__%@.png",[[UIDevice currentDevice] name], nowDate,studentID,classID];
        NSString *localFilePath = [docPath stringByAppendingPathComponent:fileName];
        //[UIImagePNGRepresentation(viewImage) writeToFile:localFilePath atomically:YES];
        
        NSData * savePic = UIImagePNGRepresentation(viewImage);
        [savePic writeToFile:localFilePath atomically:YES];
        
        savePic = nil;
        
        viewImage = nil;
        saveView = nil;
        myDate = nil;
        localFilePath = nil;
        
        NSString * logline = [NSString stringWithFormat:@"problem %d cleared at: %@ , filename: %@ \n",currentProblem,nowDate,fileName];
        logFile = [logFile stringByAppendingString:logline];
        
        
        NSError * error;
        
        [filemgr removeItemAtPath:logFileName error:&error];
        
        [logFile writeToFile:logFileName atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        nowDate = nil;
        fileName = nil;
        
        // and clear the scratchpad.
        for(UIView *view in [self.view subviews])
        {
            if(![view isKindOfClass:[UIButton class]]&&![view isKindOfClass:[UILabel class]])
                [view removeFromSuperview];
        }
        
        drawScreen = nil;
        
        drawScreen=[[scratchPadDraw alloc]initWithFrame:CGRectMake(0, 100, 768, 1004)];
        [self.view addSubview:drawScreen];
        
        //put the answer box back in place.
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0,640,self.view.bounds.size.width, 1)];
        lineView.backgroundColor = [UIColor blackColor];
        [drawScreen addSubview:lineView]; 
        
        lineView = nil;
        drawScreen = nil;
        lineView = nil;
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
            UIImage * viewImage = UIGraphicsGetImageFromCurrentImageContext();
            CGRect rect = CGRectMake(0,739,viewImage.size.width,viewImage.size.height);  //this should be where the answer box is.
            CGImageRef subImageRef = CGImageCreateWithImageInRect([viewImage CGImage], rect);
            
            ansImage = [UIImage imageWithCGImage:subImageRef];
            
            CFRelease(subImageRef);
            
            //ansImage = [UIImage imageWithCGImage:(CGImageCreateWithImageInRect([viewImage CGImage], CGRectMake(0,739,viewImage.size.width,viewImage.size.height)))];
            
            UIGraphicsEndImageContext();
            
            NSDate *myDate = [NSDate date];
            NSDateFormatter *df = [NSDateFormatter new];
            [df setDateFormat:@"dd_MMMMyyyy_HH_mm_ss.SSS"];
            NSString * nowDate =  [df stringFromDate:myDate];
            
            NSString * ansName = [currentProblemDict objectForKey:@"solution"];
            
            NSString * fileName = [NSString stringWithFormat: @"ATBoring__%@__%@__%@__%@__%@__.png",ansName,[[UIDevice currentDevice] name], nowDate,studentID,classID];
            
            NSLog(@"class ID: %@",classID);
            
            NSString *localFilePath = [docPath stringByAppendingPathComponent:fileName];
            //[UIImagePNGRepresentation(viewImage) writeToFile:localFilePath atomically:YES];
            
            NSData * savePic = UIImagePNGRepresentation(viewImage);
            
            //[savePic writeToFile:fileName atomically:YES];
            
            [savePic writeToFile:localFilePath atomically:YES];
            
            savePic = nil;
            
            ansName = nil;
            
            viewImage = nil;
            
            NSString * logline = [NSString stringWithFormat:@"problem %d submitted at: %@ , filename: %@ \n",currentProblem,nowDate,fileName];
            logFile = [logFile stringByAppendingString:logline];
            //NSLog(@"logline  %@",logline);
            
            NSError * error;
            
            [filemgr removeItemAtPath:logFileName error:&error];
            
            [logFile writeToFile:logFileName atomically:YES encoding:NSUTF8StringEncoding error:&error];
            
            
            saveView = nil;
            viewImage = nil;
            //ansImage = nil;
            ansView = nil;
            myDate = nil;
            df = nil;
            nowDate = nil;
            fileName = nil;
            localFilePath = nil;
            logline = nil;
            
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
                
                NSString * solveText = [NSString stringWithFormat:@"Simplify:  %@",problemText];
                
                self.problemLabel.text = solveText;
                
                [self.view setBackgroundColor:[UIColor whiteColor]];
                
                drawScreen = nil;
                
                drawScreen=[[scratchPadDraw alloc]initWithFrame:CGRectMake(0, 100, 768, 1004)];
                [self.view addSubview:drawScreen];
                
                //put the answer box in place.
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0,640,self.view.bounds.size.width, 1)];
                lineView.backgroundColor = [UIColor blackColor];
                [drawScreen addSubview:lineView]; 
                
                NSDate * myDate = [NSDate date];
                NSDateFormatter * df = [NSDateFormatter new];
                [df setDateFormat:@"dd_MMMMyyyy_HH_mm_ss.SSS"];
                NSString * nowDate =  [df stringFromDate:myDate];
                NSString * logline = [NSString stringWithFormat:@"problem %d presented at: %@\n",currentProblem,nowDate];
                logFile = [logFile stringByAppendingString:logline];
                NSLog(@"logline  %@",logline);
                
                problemText = nil;
                solveText = nil;
                drawScreen = nil;
                lineView = nil;
                myDate = nil;
                df = nil;
                nowDate = nil;
                logline = nil;
                
            }//not at the end of problems
        }//end of present next problem
    }//end of upload
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
    
    for (NSString * fileName in filelist){  //pick out the .png and .txt files, but not the solutions that are named Silde.
        if([fileName hasSuffix:@".png"]||[fileName hasSuffix:@".txt"]){
            if(! ([fileName hasPrefix:@"Slide"]||[fileName hasPrefix:@"aslide"]))
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

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
    NSLog(@"There was an error loading the file - %@", error);
    NSLog(@"from %@",error.userInfo.description);
    
    NSString * reloadPath;
    NSString * reloadDestinationPath;
    
    for (id key in error.userInfo){
        NSLog(@"key, %@",key);
        NSLog(@"object, %@",[error.userInfo objectForKey:key]);
        if ([key isEqualToString:@"path"])
            reloadPath = [error.userInfo objectForKey:key];
        
        if ([key isEqualToString:@"destinationPath"])
            reloadDestinationPath = [error.userInfo objectForKey:key];
        
    }
    
    
    if ([reloadPath length]>1 && [reloadDestinationPath length] > 1){
        [restClient loadFile:reloadDestinationPath intoPath:reloadPath];
        NSLog(@"re-download trying");
    }
}



- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
    downloadCount = 0;
    
    NSLog(@"loaded metadata");
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    
    NSError * error;
    
    if (metadata.isDirectory) {
        for (DBMetadata *file in metadata.contents) {
            downloadCount++;
            NSString * dropboxPath = [@"/download/" stringByAppendingString:file.filename];
            NSString * localPath = [documentsDirectory stringByAppendingPathComponent:file.filename];
            [filemgr removeItemAtPath:localPath error:&error];
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
    [[DBSession sharedSession] unlinkAll]; 
    restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    restClient.delegate = self;
    
    NSString * directory = @"/download/";
    //NSLog(@"loading metadata");
    [restClient loadMetadata:directory];
    
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError *)error{
    NSLog(@"Upload error - %@", error);
    NSLog(@"from %@",error.userInfo.description);
    
    NSString * reloadSourcePath;
    NSString * reloadDestinationPath;
    NSString *destDir = @"/upload/";
    
    for (id key in error.userInfo){
        NSLog(@"key, %@",key);
        NSLog(@"object, %@",[error.userInfo objectForKey:key]);
        if ([key isEqualToString:@"sourcePath"])
            reloadSourcePath = [error.userInfo objectForKey:key];
        
        if ([key isEqualToString:@"destinationPath"])
            reloadDestinationPath = [error.userInfo objectForKey:key];
    }
    
    
    if ([reloadSourcePath length]>1 && [reloadDestinationPath length] > 1){
        [restClient uploadFile:[reloadSourcePath lastPathComponent] toPath:destDir withParentRev:nil  fromPath:reloadSourcePath];
        NSLog(@"re-upload trying");
    }
}


@end
