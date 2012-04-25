//
//  sudokuAppDelegate.h
//  sudoku
//
//  Created by michelle on 11-6-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class sudokuViewController;

@interface sudokuAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet sudokuViewController *viewController;

@end
