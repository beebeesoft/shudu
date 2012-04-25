//
//  sudokuViewController.h
//  sudoku
//
//  Created by michelle on 11-6-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MySudokuClass.h"
#import <QuartzCore/QuartzCore.h>
#import <QuickLook/QuickLook.h>

@interface sudokuViewController : UIViewController {
    
    IBOutlet UITextField *hidTextField;
    IBOutlet UILabel *testLabel;
    IBOutlet UIScrollView *scrollView;

    IBOutlet UIImageView *image_notify;
    
    IBOutlet UIButton *readButton;
    IBOutlet UIButton *createButton;
    IBOutlet UIButton *clearButton;
    IBOutlet UIButton *editModeButton;
    IBOutlet UIButton *solveButton;
    IBOutlet UIButton *clearAllButton;
    IBOutlet UIButton *posibleValueButton;
    IBOutlet UIButton *homeButton;
    IBOutlet UIButton *checkButton;
    
    UIButton *activedButton;
    UIButton *lastActivedButton;
    int activedButtonTag;
    int lastActivedButtonTag;
    NSMutableArray *answerButtons;
    NSMutableArray *editNumButtons;
    NSMutableArray *numButtons;
    NSMutableDictionary *sudokuTable;
    NSMutableDictionary *originTable;
    
    int nowSudokuID;
    SEL method;
    BOOL showHighlight;
    BOOL isEditMode;
    BOOL isPosibleValueMode;
    int nowMode;
    
    
    UIControl *startView;
    UIControl *menuView;
    
}



@property (nonatomic, retain) UITextField *hidTextField;
@property (nonatomic, retain) UILabel *testLabel;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIImageView *image_notify;
@property (nonatomic, retain) UIControl *startView;
@property (nonatomic, retain) UIControl *menuView;
@property (nonatomic, retain) UIButton *activedButton;
@property (nonatomic, retain) UIButton *lastActivedButton;
@property (nonatomic, retain) UIButton *createButton;
@property (nonatomic, retain) UIButton *clearButton;
@property (nonatomic, retain) UIButton *editModeButton;
@property (nonatomic, retain) UIButton *solveButton;
@property (nonatomic, retain) UIButton *clearAllButton;
@property (nonatomic, retain) UIButton *posibleValueButton;
@property (nonatomic, retain) UIButton *homeButton;
@property (nonatomic, retain) UIButton *checkButton;

@property (nonatomic, assign) int activedButtonTag;
@property (nonatomic, assign) int lastActivedButtonTag;
@property (nonatomic, assign) NSMutableArray *answerButtons;
@property (nonatomic, assign) NSMutableArray *editNumButtons;
@property (nonatomic, assign) NSMutableArray *numButtons;
@property (nonatomic, assign) NSMutableDictionary *sudokuTable;
@property (nonatomic, assign) NSMutableDictionary *originTable;
@property (nonatomic, assign) BOOL isEditMode;
@property (nonatomic, assign) int nowSudokuID;
@property (nonatomic, assign) SEL method;
@property (nonatomic, assign) BOOL showHighlight;
@property (nonatomic, assign) BOOL isPosibleValueMode;
@property (nonatomic, assign) int nowMode;

-(IBAction) numButtonPressed:(UIButton *)sender;
-(IBAction) answerButtonPressed:(UIButton *)sender;
-(IBAction) createButtonPressed:(id)sender;
-(IBAction) clearButtonPressed:(UIButton *)sender;
-(IBAction) editModeButtonPressed:(UIButton *)sender;
-(IBAction) readButtonPressed:(UIButton *)sender;
-(IBAction) buttonSetHighlight:(UIButton *)sender;
-(IBAction) checkButtonPressed:(UIButton *)sender;
-(IBAction) clearAllButtonPressed:(UIButton *)sender;
-(IBAction) solveButtonPressed:(UIButton *)sender;
-(IBAction) posibleValueModeChange:(UIButton *)sender;
-(IBAction) homeButtonPressed:(UIButton *)sender;

-(void)initMode:(id)sender ;
-(void)answerButtonInit;
-(void)answerButtonSetState:(BOOL)state buttonID:(NSInteger)bid;
-(void)answerButtonDisplay;
-(void)editModeButtonSetState:(BOOL)state;
-(void)numButtonInit;
-(void)posibleValueClear:(id)sender;
-(void)createNumberButton;
-(BOOL)solveSudoku;
-(void)filledByTable:(NSMutableDictionary *)table;
-(void)startBackgroundThread ;
-(void)highlightRelatedCells ;
-(void)displayMenu;
-(void)loadQuickMenu;
-(void)loadStartView;
-(void)loadWelcomView;

-(UIButton *)setButtonState:(UIButton *)button tag:(int)tag title:(NSString *)title titleColor:(UIColor *)titleColor titleFont:(UIFont *)titleFont;
@end
