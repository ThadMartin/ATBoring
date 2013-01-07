//
//  AT_BoringAppDelegate.h
//  AT_Boring
//
//  Created by Thad Martin on 9/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class startScreen;

@interface ATBoringAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong) NSMutableArray * allQnsAndPaths;
@property (strong, nonatomic) startScreen *viewController;
@property (strong, nonatomic) UINavigationController * navController;

@end
