//
//  sudokuViewController.m
//  sudoku
//
//  Created by michelle on 11-6-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "sudokuViewController.h"


@implementation sudokuViewController

@synthesize createButton,hidTextField,clearButton,editModeButton; 
@synthesize activedButton,lastActivedButton,testLabel,solveButton,clearAllButton,posibleValueButton,homeButton,checkButton;
@synthesize scrollView = _scrollView;
@synthesize activedButtonTag,lastActivedButtonTag;
@synthesize isEditMode,nowSudokuID,showHighlight,isPosibleValueMode,nowMode;
@synthesize answerButtons,editNumButtons,numButtons,sudokuTable,originTable;
@synthesize image_notify,method,startView,menuView;

#define smallSizeNum  8
#define midSizeNum  11
#define bigSizeNum  15
#define areaBorder 4
#define normalBorder 2

#define buttonHeight 34
#define buttonWidth 34

#define playMode 9001
#define solveMode 9002
#define inputMode 9003
#define returnMode 9009

#define highlightRow 1001
#define highlightCol 1002
#define highlightCell 1003

#define hintTag 9999


- (IBAction)buttonSetHighlight:(UIButton *)sender  {
    [sender setHighlighted:YES];
}

-(int)checkEmptyCells:(NSDictionary *)checkTable {
    //NSLog(@"%@",checkTable);
    int emptyCellCount = 0;
    for (NSString *v in [checkTable allValues]) {
        if ([v isEqualToString:@"0"] || [v isEqualToString:@" "]) {
            emptyCellCount ++ ;
        }
    }
    return emptyCellCount;
}

-(void)createNumberButton {
    int cellWidth = buttonWidth;
    int cellHeight = buttonHeight;
    int xSta = 7 - cellWidth;
    int ySta = 50 - cellHeight;
    //NSMutableDictionary *buttonTable = [[NSMutableDictionary alloc] initWithCapacity:81];
    for (int i = 1; i < 10; i++) {
        xSta = xSta + cellWidth;
        for (int j = 1 ; j < 10; j++) {
            ySta = ySta + cellHeight;
            CGRect pos = CGRectMake(xSta, ySta, cellWidth, cellHeight);
            UIButton *b = [MySudokuClass createSudokuButtonForView:self atPos:pos 
                                                           withTag:j*10+i forAction:@selector(numButtonPressed:)];
            NSString *picName = @"ButtonPic.jpg";
            [b setBackgroundImage:[[UIImage imageNamed:picName] stretchableImageWithLeftCapWidth:0 topCapHeight:0]  forState:0];
            [self.scrollView addSubview:b];
            [numButtons addObject:b];
        }
        ySta = 50 - cellHeight;
    }
    
    UIImageView *allCell = [[UIImageView alloc] initWithFrame:CGRectMake(7, 50, buttonWidth*9, buttonHeight*9)];
    allCell.backgroundColor = [UIColor clearColor];
    allCell.layer.borderColor = [[UIColor blackColor] CGColor];
    allCell.layer.borderWidth = 3;
    [self.scrollView addSubview:allCell];
    UIGraphicsBeginImageContext(allCell.frame.size);
    [allCell.image drawInRect:CGRectMake(0, 0, allCell.frame.size.width, allCell.frame.size.height)];
    CGContextRef cxt = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(cxt, 3);
    CGContextSetAllowsAntialiasing(cxt, YES);
    CGContextSetRGBStrokeColor(cxt, 0, 0, 0, 1.0);
    CGContextBeginPath(cxt);
    
    CGContextMoveToPoint(cxt, buttonWidth*3, 0);
    CGContextAddLineToPoint(cxt, buttonWidth*3, buttonHeight*9);
    CGContextMoveToPoint(cxt, buttonWidth*6, 0);
    CGContextAddLineToPoint(cxt, buttonWidth*6, buttonHeight*9);
    CGContextMoveToPoint(cxt, 0, buttonHeight*3);
    CGContextAddLineToPoint(cxt, buttonWidth*9, buttonHeight*3);
    CGContextMoveToPoint(cxt, 0, buttonHeight*6);
    CGContextAddLineToPoint(cxt, buttonWidth*9, buttonHeight*6);
    
    CGContextClosePath(cxt);
    CGContextStrokePath(cxt);
    allCell.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    [allCell release];
}



#pragma selection button
- (void)answerButtonSetState:(BOOL)state buttonID:(NSInteger)bid {
    id b = [answerButtons objectAtIndex:bid-1];
    //[b setEnabled:state];
    if (state == YES) {
        [b setBackgroundColor:[UIColor orangeColor]];
    }
    else {
        [b setBackgroundColor:[UIColor grayColor]];
    }
}
- (void)answerButtonInit {
    for (int i = 1; i < 10; i ++) {
        //id b = [answerButtons objectAtIndex:i];
        [self answerButtonSetState:YES buttonID:i];
    }
}

- (void)answerButtonDisplay {
    [self answerButtonInit];
    if ([activedButton.titleLabel.text intValue] != 0) {
        [self answerButtonSetState:NO buttonID:[activedButton.titleLabel.text intValue]];
    }
    for (UIView *v in [activedButton subviews]) {
        int bid = v.tag%10;
        if (bid>0) [self answerButtonSetState:NO buttonID:bid];
    }
}

- (IBAction)answerButtonPressed:(UIButton *)sender {
    int bid = sender.tag - 100;
    if (isEditMode==NO) {
        if (activedButton != nil && [editNumButtons indexOfObject:activedButton]>99) { // Posible Value Mode
            if (isPosibleValueMode) {
                if ([activedButton.titleLabel.text intValue] != 0) {
                    NSLog(@"ssss:%@",activedButton.titleLabel.text);
                    [self answerButtonSetState:YES buttonID:[activedButton.titleLabel.text intValue]];
                    [activedButton setTitle:@" " forState:UIControlStateNormal];
                }

                if ([activedButton viewWithTag:activedButton.tag*10+bid]) {
                    [[activedButton viewWithTag:activedButton.tag*10+bid] removeFromSuperview];
                    [self answerButtonSetState:YES buttonID:bid];
                }
                else {
                    UILabel *value = [[UILabel alloc] init];
                    value.text = [NSString stringWithFormat:@"%d",bid];
                    value.tag = activedButton.tag*10 + bid;
                    int valueRow = bid/3;
                    int valueCol = bid%3-1;
                    float valueX = buttonWidth%10/2+2;
                    float valueY = buttonHeight%10/2;
                    int valueHeight = (buttonHeight/10)*10/3;
                    int valueWidth = (buttonWidth/10)*10/3;
                    float fontSize = buttonHeight/3;
                    
                    switch (bid) {
                        case 3:
                            valueRow = 0;
                            valueCol = 2;
                            break;
                        case 6:
                            valueRow = 1;
                            valueCol = 2;
                            break;
                        case 9:
                            valueRow = 2;
                            valueCol = 2;
                            break;
                        default:
                            break;
                    }
                    valueY = valueY + valueRow*valueHeight;
                    valueX = valueX + valueCol*valueWidth;
                    value.frame = CGRectMake(valueX, valueY, valueWidth, valueHeight);
                    value.font = [UIFont boldSystemFontOfSize:fontSize];
                    value.textColor = [UIColor blueColor];
                    value.backgroundColor = [UIColor clearColor];
                    [activedButton addSubview:value];
                    [value release];
                    [self answerButtonSetState:NO buttonID:bid];
                }
                
            }
            else { //Normal Mode
                if ([sender.titleLabel.text isEqualToString:activedButton.titleLabel.text]) {
                    [activedButton setTitle:@" " forState:UIControlStateNormal];
                    [self answerButtonSetState:YES buttonID:bid];
                    [sudokuTable setValue:@"0" forKey:[NSString stringWithFormat:@"%d",activedButton.tag]];
                }
                else {
                    [activedButton setTitle:[NSString stringWithFormat:@"%@",sender.titleLabel.text] forState:0];
                    [activedButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                    [self answerButtonInit];
                    [self answerButtonSetState:NO buttonID:bid];
                    [self posibleValueClear:activedButton];
                    [sudokuTable setValue:sender.titleLabel.text forKey:[NSString stringWithFormat:@"%d",activedButton.tag]];
                }
            }            
        }
    }
    else {  //Edit Mode
        if ([sender.titleLabel.text isEqualToString:activedButton.titleLabel.text]) {
            [self answerButtonSetState:YES buttonID:bid];
            [activedButton setTitle:@" " forState:0];
            [editNumButtons removeObject:activedButton];
            [sudokuTable setValue:@"0" forKey:[NSString stringWithFormat:@"%d",activedButton.tag]];
        }
        else {
            [self answerButtonInit];
            [self answerButtonSetState:NO buttonID:bid];
            [activedButton setTitle:sender.titleLabel.text forState:0];
            [activedButton setTitleColor:[UIColor blackColor] forState:0];
            [activedButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
            [editNumButtons addObject:activedButton];
            [sudokuTable setValue:sender.titleLabel.text forKey:[NSString stringWithFormat:@"%d",activedButton.tag]];
        }
        
    }
    
    
}


#pragma edit button

-(void)editModeButtonSetState:(BOOL)state {
    switch (state) {
        case YES:
            [editModeButton setTitle:@"Edit Mode" forState:0];
            break;
        case NO:
            [editModeButton setTitle:@"Play Mode" forState:0];
            break;
        default:
            break;
    }
}
-(void)notify {
    
    image_notify.alpha = 0;
    [image_notify setImage:[UIImage imageNamed:@"NOTIFY_1"]];
    image_notify.alpha = 1;
    [UIView beginAnimations:@"norify" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.7f];

    [UIView setAnimationDelegate:self];
    [UIView setAnimationDelay:0.3f];
    
    image_notify.alpha = 0;
    [UIView commitAnimations];
}

#pragma number button



-(void)filledByTable:(NSMutableDictionary *)table {
    editNumButtons = [[NSMutableArray alloc] initWithCapacity:81];
    for (int i = 1; i <= 9; i++) {
        for (int j = 1; j <= 9; j++) {
            NSString *rowcol = [NSString stringWithFormat:@"%d%d",i,j];
            NSString *value = [table valueForKey:rowcol];
            if (![[table valueForKey:rowcol] isKindOfClass:[NSString class]]) continue;
            else {
                id b = [[self view] viewWithTag:[rowcol intValue]];
                if ([value intValue] != 0) {
                    [b setTitle:value forState:0];
                    [editNumButtons addObject:b];
                }
                else if ([value intValue] == 0) {
                    [b setTitle:@" " forState:0];
                }    
            }

            
        }
    }
    
}

-(void)startBackgroundThread {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //[NSThread sleepForTimeInterval:3];
    [self performSelectorOnMainThread:method withObject:nil waitUntilDone:NO];
    [pool release];
}
-(BOOL)solveSudoku {
    NSMutableDictionary *tmpTable = [[NSMutableDictionary alloc] initWithDictionary:sudokuTable copyItems:YES];
    sudokuTable = [MySudokuClass solveThisSudoku:sudokuTable];
    if ([MySudokuClass isSudokuTableFullFilled:sudokuTable]) {
        for (NSString *pos in [sudokuTable allKeys]) {
            id b = [[self view] viewWithTag:[pos intValue]];
            // Empty Cells
            if ([[tmpTable valueForKey:pos] intValue] == 0 && [editNumButtons indexOfObject:b] > 99 ) {
                [self posibleValueClear:b];
                [self setButtonState:b tag:[pos intValue] title:[sudokuTable valueForKey:pos] titleColor:[UIColor greenColor] titleFont:nil];
                continue;
            }
            
            // Different Answer Cells
            if ([[tmpTable valueForKey:pos] intValue] != [[sudokuTable valueForKey:pos] intValue]) {
                [self setButtonState:b tag:[pos intValue] title:[sudokuTable valueForKey:pos] titleColor:[UIColor redColor] titleFont:nil];
                continue;
            }
        }
        return YES;
    }
    else {
        sudokuTable = tmpTable;
        return NO;
    }
}

-(void)removeHint:(id)sender {
    [sender removeFromSuperview];
}

-(IBAction) solveButtonPressed:(UIButton *)sender {
    //NSLog(@"%d",[self checkEmptyCells:sudokuTable]);
    int emptyCellCount = [self checkEmptyCells:sudokuTable];
    if (emptyCellCount > 81-17) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" 
                                                            message:[NSString stringWithFormat:@"Please input more than 17 numbers.\nThere just %d numbers now.",81-emptyCellCount]
                                                           delegate:self 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    if (nowMode == playMode) {
        BOOL isHintShow = NO;
        UIButton *tmpButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        [tmpButton addTarget:self action:@selector(removeHint:) forControlEvents:UIControlEventTouchDown];
        tmpButton.backgroundColor = [UIColor grayColor];
        NSMutableArray *hintArray = [[NSMutableArray alloc] initWithCapacity:81];
        
        for (NSString *pos in [originTable allKeys]) {
            NSString *valueOrigin = [originTable valueForKey:pos];
            NSString *valueNow = [sudokuTable valueForKey:pos];
            if ([valueNow intValue] != [valueOrigin intValue]) {
                UIButton *b = [self.scrollView viewWithTag:[pos intValue]];
                // 加上对posiblevalue的判断
                BOOL hasPosibleValue = NO;
                for (UIView *v in [b subviews]) {
                    if(v.tag/10 == b.tag) {
                        hasPosibleValue = YES;
                        break;
                    }
                }
                
                if ([valueNow intValue] == 0 && !hasPosibleValue) {
                    [b setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                    [b setTitle:valueOrigin forState:UIControlStateNormal];
                }
                else {
                   // UIImageView *hint = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"View-Hint"]];
                    UIButton *hint = [[UIButton alloc] init];
                    //[hint setBac
                    [hint setBackgroundImage:[UIImage imageNamed:@"View-Hint"] forState:UIControlStateNormal];
                    float hintX = [b frame].origin.x + buttonWidth/2 + 2;
                    float hintY = [b frame].origin.y - buttonHeight/2 - 2;
                    float hintW = buttonWidth * 0.8;
                    float hintH = buttonHeight * 0.8;
                    
                    hint.frame = CGRectMake(hintX, hintY, hintW, hintH);
                    hint.tag = hintTag;
                    [hint setTitle:valueOrigin forState:UIControlStateNormal];
                    [hint setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                    [hint.titleLabel setTextAlignment:UITextAlignmentCenter];
                    hint.alpha = 1.0f;
                    [hintArray addObject:hint];
                    isHintShow = YES;
                }
            }
        }
        if (isHintShow) {
            tmpButton.alpha = 0.8f;
            [self.view addSubview:tmpButton];
            [self.view bringSubviewToFront:tmpButton];
            for (UIButton *b in hintArray) {
                [tmpButton addSubview:b];
                [b release];
            }

        }
        [tmpButton release];
    }
    else { // solve mode

        //UIProgressView *progressBar = [[UIProgressView alloc] initWithFrame:CGRectMake( 50,50, 200, 20)];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Progressing" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alertView show];
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.center = CGPointMake(alertView.bounds.size.width/2, alertView.bounds.size.height - 50);
        [indicator startAnimating];
        [alertView addSubview:indicator];
        [indicator release];
        method = @selector(solveSudoku);
        [NSThread detachNewThreadSelector:@selector(startBackgroundThread) toTarget:self withObject:nil];
        
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
    }
    
}

-(void)highlightRelatedCells {
    
    if ([self.view viewWithTag:highlightRow] != nil) {
        [[self.view viewWithTag:highlightRow] removeFromSuperview];
    }
    if ([self.view viewWithTag:highlightCol] != nil) {
        [[self.view viewWithTag:highlightCol] removeFromSuperview];
    }
    
    int row = activedButton.tag/10;
    int col = activedButton.tag%10;
    UIView *row1 = [[self view] viewWithTag:(row*10+1)];
    UIView *col1 = [[self view] viewWithTag:(10+col)];
    float rowX = row1.frame.origin.x;
    float rowY = row1.frame.origin.y;
    float colX = col1.frame.origin.x;
    float colY = col1.frame.origin.y;
    CGColorRef highlightColor = [[UIColor colorWithRed:0 green:0.584 blue:0.984 alpha:1] CGColor];
    
    CGRect rectRow = CGRectMake(rowX-2, rowY-2, buttonWidth*9+4, buttonHeight+4);
    UIImageView *image = [[UIImageView alloc] initWithFrame:rectRow];
    [image.image drawInRect:rectRow];
    [image setBackgroundColor:[UIColor clearColor]];
    [image.layer setBorderColor:highlightColor];
    [image.layer setBorderWidth:5];
    [image.layer setCornerRadius:8.0];
    image.tag=highlightRow;
    [self.scrollView addSubview:image];
    //[self.scrollView bringSubviewToFront:image];
    [image release];
    
    
    CGRect rectCol = CGRectMake(colX-2, colY-2, buttonWidth+4, buttonHeight*9+4);
    image = [[UIImageView alloc] initWithFrame:rectCol];
    [image.image drawInRect:rectCol];
    [image setBackgroundColor:[UIColor clearColor]];
    [image.layer setBorderColor:highlightColor];
    [image.layer setBorderWidth:5];
    [image.layer setCornerRadius:8.0];
    image.tag=highlightCol;
    [self.scrollView addSubview:image];
    [self.scrollView bringSubviewToFront:image];
    [image release];
    
    
    
    //[self.view bringSubviewToFront:image];
    
    
}

- (IBAction)numButtonPressed:(UIButton *)sender {
    if (activedButton) {
        UIColor *lastActivedButtonColor = activedButton.titleLabel.textColor;
        lastActivedButton = activedButton;
        [lastActivedButton.layer setBorderColor:[[UIColor clearColor] CGColor]];
        [lastActivedButton.layer setBorderWidth:0];
        [[lastActivedButton viewWithTag:highlightCell] removeFromSuperview];
        [self.scrollView sendSubviewToBack:lastActivedButton];
        lastActivedButton.titleLabel.textColor = lastActivedButtonColor;
        [lastActivedButtonColor release];
    }
    activedButton = sender;
    //UIColor *activedButtonColor = [sender titleColorForState:UIControlStateNormal];
    //NSLog(@"%@",activedButtonColor);
    // convert button'tag to row-col text
    int num = sender.tag;
    int row = num/10;
    int col = num - (num/10)*10;
    testLabel.text = [NSString stringWithFormat:@"Row: %d Col: %d",row,col];
    // convert end
    [self answerButtonDisplay];
    activedButtonTag = sender.tag;
    
    // highlight related cells
    if(showHighlight)[self highlightRelatedCells];
    
    // highlight actived cell
    [self.scrollView bringSubviewToFront:activedButton];
    UIImageView *highlightButton = [[UIImageView alloc] initWithFrame:CGRectMake(-1, -1, buttonWidth+2, buttonHeight+2)];
    highlightButton.backgroundColor = [UIColor clearColor];
    highlightButton.layer.borderColor = [[UIColor redColor] CGColor];
    highlightButton.layer.borderWidth = 4;
    highlightButton.layer.cornerRadius = 8;
    highlightButton.alpha = 0.5f;
    highlightButton.tag = highlightCell;
    [activedButton addSubview:highlightButton];
    [activedButton bringSubviewToFront:highlightButton];
    [highlightButton release];
    
    //[activedButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
}

#pragma read sudoku file
- (IBAction)readButtonPressed:(UIButton *)sender {
    [self numButtonInit];
    editNumButtons = [[NSMutableArray alloc] initWithCapacity:81];
    //read sudoku file
    MySudokuClass *msc = [[MySudokuClass alloc] init];
    NSArray *allFileContents = [msc readSudokuFile:@" "];
    
    //make a random sudoku id
    int randomSudoku = 0;
    while (1) {
        randomSudoku = arc4random() % ([allFileContents count] -1 ) + 1;
        if (randomSudoku != nowSudokuID) {
            nowSudokuID = randomSudoku;
            break;
        }
    }
    
    //make a sudoku game
    NSArray *fileContents = [allFileContents objectAtIndex:randomSudoku];
    //NSLog(@"%d:%d",randomSudoku,[allFileContents count]);
    sudokuTable = [MySudokuClass initSudokuTable:sudokuTable];
    for (id s in fileContents) {
        NSArray *tmp = [s componentsSeparatedByString:@"-"];
        [sudokuTable setValue:[tmp objectAtIndex:1] forKey:[tmp objectAtIndex:0]];
    }

    for (int i = 1; i < 10 ; i++) {
        for (int j = 1; j < 10; j++) {
            NSString *rowcol = [NSString stringWithFormat:@"%d%d",i,j];
            NSString *nowValue = [sudokuTable valueForKey:rowcol];
            NSLog(@"%@",nowValue);
            if (nowValue != @"0") {
                id b = [[self view] viewWithTag:i*10+j];
                [editNumButtons addObject:b];
                [b setTitleColor:[UIColor blackColor] forState:0];
                [[b titleLabel] setFont:[UIFont boldSystemFontOfSize:15]];
                [b setTitle:nowValue forState:0];
            }
        }
    }
    
    isEditMode = YES;
    [self editModeButtonSetState:YES];
    //NSLog(@"%@",fileContents);
    [allFileContents release];
}

- (IBAction)checkButtonPressed:(UIButton *)sender {
    if ([[sudokuTable allValues] count]>0) {
        //NSMutableDictionary *tempTable = [[NSMutableDictionary alloc] initWithDictionary:sudokuTable copyItems:YES];
        sudokuTable = [MySudokuClass makeEmptyCell:sudokuTable forLevel:30];
        [self filledByTable:sudokuTable];
    }
    
}

- (void)numButtonInit {
    if (activedButton!=nil) {
        [activedButton setTitleColor:[UIColor blackColor] forState:0];
        [activedButton.layer setBorderColor:[[UIColor clearColor] CGColor]];
        [activedButton.layer setBorderWidth:0];
        [[activedButton viewWithTag:highlightCell] removeFromSuperview];
    }
    activedButton = nil;
    [self answerButtonInit];
    for (UIButton *b in numButtons) {
        //NSLog(@"%d",[b tag]);
        [b setTitle:@"" forState:0];
        [[b titleLabel] setFont:[UIFont boldSystemFontOfSize:15]];
        [b setTitleColor:[UIColor blackColor] forState:0];
        [self posibleValueClear:b];
        [self.scrollView sendSubviewToBack:b];
        //[b setBackgroundColor:[UIColor clearColor]];
    }
    [[self.view viewWithTag:highlightCol] removeFromSuperview];
    [[self.view viewWithTag:highlightRow] removeFromSuperview];
}

- (void)posibleValueClear:(id)sender {
    for (UIView *v in [sender subviews]) {
        if(v.tag/10 == [sender tag]) [v removeFromSuperview];
    }
}
- (IBAction)clearButtonPressed:(UIButton *)sender {
    if (activedButton != nil && [editNumButtons indexOfObject:activedButton]>99) {
        [activedButton setTitle:@" " forState:0];
        [self answerButtonInit];
        [self posibleValueClear:activedButton];
        return;
    }
    
}

- (IBAction)posibleValueModeChange:(UIButton *)sender {
    if (activedButton != nil & [editNumButtons indexOfObject:activedButton] > 99) {
        [self posibleValueClear:activedButton];
        [activedButton setTitle:@" " forState:UIControlStateNormal];
        [self answerButtonInit];
    }
    if (isPosibleValueMode) {
        isPosibleValueMode = NO;
        //[sender setBackgroundColor:[UIColor redColor]];
        sender.layer.borderColor = [[UIColor clearColor] CGColor];
        [sender.layer setCornerRadius:0];
        
    }
    else {
        isPosibleValueMode = YES;
        [sender setBackgroundColor:[UIColor clearColor]];
        sender.layer.borderColor = [[UIColor orangeColor] CGColor];
        sender.layer.borderWidth = 2;
        [sender.layer setCornerRadius:5];
        [sender.layer setMasksToBounds:YES];
    }
}


- (IBAction)clearAllButtonPressed:(UIButton *)sender {
    if (nowMode != playMode) {
        editNumButtons = [[NSMutableArray alloc] initWithCapacity:81];
        //sudokuTable = [[NSMutableDictionary alloc] initWithCapacity:81];
        sudokuTable = [MySudokuClass initSudokuTable:sudokuTable];
        [self numButtonInit];
        activedButton = nil;
    }
    else {
        sudokuTable = [MySudokuClass initSudokuTable:sudokuTable];
        //sudokuTable = originTable;
        [self numButtonInit];
        [self answerButtonInit];
        for (UIButton *b in editNumButtons) {
            [sudokuTable setValue:b.titleLabel.text forKey:[NSString stringWithFormat:@"%d",b.tag]];
        }
        [self filledByTable:sudokuTable];
        activedButton = nil;
    }
    
}

-(IBAction)editModeButtonPressed:(UIButton *)sender {
    [self notify];
    if (isEditMode == YES) {
        isEditMode = NO;
        [self editModeButtonSetState:NO];
    }
    else {
        isEditMode = YES;
        [self editModeButtonSetState:YES];
    }
    
}


- (IBAction)createButtonPressed:(id)sender {
    //[MySudokuClass resloveSudoku:sudokuNow];
    sudokuTable = [MySudokuClass initSudokuTable:sudokuTable];
    sudokuTable = [MySudokuClass makeSudoku];
    [self numButtonInit];
    [self filledByTable:sudokuTable];
    originTable = [MySudokuClass initSudokuTable:originTable];
    originTable = sudokuTable;
    [checkButton sendActionsForControlEvents:UIControlEventTouchDown];
    //[editNumButtons addObjectsFromArray:numButtons];
    
}



- (IBAction) homeButtonPressed:(UIButton *)sender {
    [self loadStartView];
}


-(UIButton *)setButtonState:(UIButton *)button tag:(int)tag title:(NSString *)title titleColor:(UIColor *)titleColor titleFont:(UIFont *)titleFont {
    button.tag = tag;
    [button setTitle:title forState:0];
    
    UIColor *fontColor = [UIColor blueColor];
    if ([title length]>1) {
        fontColor = [UIColor clearColor];
    }
    float buttonTitleSize = 15;
    if ([title length] >= 6) {
        buttonTitleSize = smallSizeNum;
    }
    if ([title length] >= 3 && [activedButton.titleLabel.text length] <6) {
        buttonTitleSize = midSizeNum;
    }
    if ([title length] < 3) {
        buttonTitleSize = bigSizeNum;
        
    }
    UIFont *titleSize = [UIFont boldSystemFontOfSize:buttonTitleSize];

    if (titleColor != nil) fontColor=titleColor;
    if (titleFont != nil) {
        titleSize = titleFont;
    }
    [button setTitleColor:fontColor forState:0];
    [[button titleLabel] setFont:titleSize];
    return button;
}

#pragma memory

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
-(void)displayMenu {
    if ([startView superview] == self.view) {
        return;
    }
    [UIView beginAnimations:@"DisplayMenuView" context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelay:0.1];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    if (menuView.frame.origin.y == 0) {
        menuView.frame = CGRectMake(0, -105, 320, 120);
        menuView.alpha = 0.5;
    }
    else {
        menuView.frame = CGRectMake(0, 0, 320, 120);
        menuView.alpha = 0.8;
    }
            
    [UIView commitAnimations];
}
-(void)showHighlight:(UIButton *)sender {
    if ([self.scrollView viewWithTag:highlightRow]) {
        [[self.scrollView viewWithTag:highlightCol] removeFromSuperview];
        [[self.scrollView viewWithTag:highlightRow] removeFromSuperview];
    }
    if (showHighlight == NO) {
        showHighlight = YES;
        if (activedButton != nil) {
            [self highlightRelatedCells];
        }
        [sender setBackgroundImage:[UIImage imageNamed:@"Icon-Selected.png"] forState:UIControlStateNormal];
    }
    else {
        showHighlight = NO;
        [sender setBackgroundImage:[UIImage imageNamed:@"Icon-Unselected.png"] forState:UIControlStateNormal];
    }
    
    
}

-(void)initMode:(id)sender {
    if(nowMode == 0 && [sender tag] == returnMode) return;
    if([sender tag] != returnMode) {
        nowMode = [sender tag];
        sudokuTable = [MySudokuClass initSudokuTable:sudokuTable];
        originTable = sudokuTable;
        [self numButtonInit];
        editNumButtons = [[NSMutableArray alloc] initWithCapacity:81];
        switch ([sender tag]) {
            case playMode:
                NSLog(@"Play Mode");
                createButton.hidden = NO;
                posibleValueButton.hidden = NO;
                [createButton sendActionsForControlEvents:UIControlEventTouchDown];
                isEditMode = YES; // Change to Play Mode
                [editModeButton sendActionsForControlEvents:UIControlEventTouchDown];
                break;
            case solveMode:
                NSLog(@"Solve Mode");
                createButton.hidden = YES;
                posibleValueButton.hidden = YES;
                isEditMode = NO; // Change to Edit Mode
                [editModeButton sendActionsForControlEvents:UIControlEventTouchDown];
                break;
            case inputMode:
                NSLog(@"Solve Mode");
                break;
            default:
                break;
        }
    }
    [UIView beginAnimations:@"Show Main View" context:nil];
    [UIView setAnimationDuration:0.7f];
    [UIView setAnimationDelay:0.2f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    UIViewController *coming = [[UIViewController alloc] init];
    UIViewController *going = [[UIViewController alloc] init];
    
    coming.view = startView.superview;
    going.view = startView;
    
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:coming.view cache:YES];
    [coming viewWillAppear:YES];
    [going viewWillDisappear:YES];
    [going.view removeFromSuperview];
    [going viewDidDisappear:YES];
    [coming viewDidAppear:YES];
    
    [UIView commitAnimations];
    //[startView removeFromSuperview];
}
- (void) loadQuickMenu {
    // Quick Menu
    menuView = [[UIControl alloc] initWithFrame:CGRectMake(0, -105, 320, 120)];
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Option-View.png"]];
    image.frame = CGRectMake(0,0, 320, 120);
    image.alpha = 1;
    [menuView addSubview:image];
    [image release];
    menuView.alpha = 0.5;
    [menuView addTarget:self action:@selector(displayMenu) forControlEvents:UIControlEventTouchDown];
    
    
    
    UILabel *highlightSwitchLabel = [[UILabel alloc] init];
    highlightSwitchLabel.text = @"Highlight";
    [highlightSwitchLabel setTextAlignment:UITextAlignmentLeft];
    highlightSwitchLabel.backgroundColor = [UIColor clearColor];
    highlightSwitchLabel.textColor = [UIColor whiteColor];
    highlightSwitchLabel.font = [UIFont boldSystemFontOfSize:20];
    highlightSwitchLabel.shadowColor = [UIColor grayColor];
    highlightSwitchLabel.shadowOffset = CGSizeMake(0, -1.0);
    highlightSwitchLabel.frame = CGRectMake(20, 10, 80, 40);
    highlightSwitchLabel.adjustsFontSizeToFitWidth = YES;
    highlightSwitchLabel.highlighted = YES;
    [menuView addSubview:highlightSwitchLabel];
    
    /*
    UISwitch *highlightSwitch = [[UISwitch alloc] init];
    [highlightSwitch setOn:YES];
    highlightSwitch.frame = CGRectMake(20, 50, 80, 120);
    [highlightSwitch addTarget:self action:@selector(showHighlight:) forControlEvents:UIControlEventValueChanged];
    [menuView addSubview:highlightSwitch];
    */
    
    UIButton *highlightSwitch = [[UIButton alloc] init];
    [highlightSwitch setBackgroundImage:[UIImage imageNamed:@"Icon-Selected"] forState:UIControlStateNormal];
    [highlightSwitch setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.8]];
    highlightSwitch.layer.cornerRadius = 10.0f;
    highlightSwitch.layer.masksToBounds = YES;
    highlightSwitch.frame = CGRectMake(35, 50, 40, 40);
    highlightSwitch.layer.borderWidth = 2;
    highlightSwitch.layer.borderColor = [[UIColor blackColor] CGColor];
    showHighlight =YES;
    [highlightSwitch addTarget:self action:@selector(showHighlight:) forControlEvents:UIControlEventTouchDown];
    [menuView addSubview:highlightSwitch];
    [self.view addSubview:menuView];
}

- (void)loadStartView {
    // Start View
    startView = [[UIControl alloc] initWithFrame:CGRectMake(5, 15, 310, 440)];
    startView.backgroundColor = [UIColor blackColor];
    startView.alpha = 0.0f;
    startView.tag = returnMode;
    [startView.layer setCornerRadius:20.0];
    [startView.layer setMasksToBounds:YES];
    [startView.layer setBorderWidth:2.0f];
    [startView.layer setBorderColor:[[UIColor whiteColor] CGColor]];    
    [startView addTarget:self action:@selector(initMode:) forControlEvents:UIControlEventTouchDown];
    [[self view] addSubview:startView];

    UIButton *play = [[UIButton alloc] initWithFrame:CGRectMake(35, 35, 240, 75)];
    [play setBackgroundImage:[UIImage imageNamed:@"Option-Play"] forState:UIControlStateNormal];
    play.alpha = 1.0f;
    [play.layer setCornerRadius:8.0f];
    [play.layer setMasksToBounds:YES];
    //[play.layer setBorderColor:[[UIColor colorWithWhite:1 alpha:0.8] CGColor]];
    //[play.layer setBorderWidth:1.0f];
    [play setTag:playMode];
    
    [play addTarget:self action:@selector(initMode:) forControlEvents:UIControlEventTouchDown];
    [startView addSubview:play];
    
    UIButton *solve = [[UIButton alloc] initWithFrame:CGRectMake(35, 145, 240, 75)];
    //[solve setTitle:@"Solve Sudoku" forState:UIControlStateNormal];
    [solve setBackgroundImage:[UIImage imageNamed:@"Option-Newspaper"] forState:UIControlStateNormal];
    solve.alpha = 1.0f;
    [solve.layer setCornerRadius:8.0f];
    [solve.layer setMasksToBounds:YES];
    //[solve.layer setBorderColor:[[UIColor colorWithWhite:1 alpha:0.8] CGColor]];
    //[solve.layer setBorderWidth:1.0f];
    [solve setTag:solveMode];
    [solve addTarget:self action:@selector(initMode:) forControlEvents:UIControlEventTouchDown];
    [startView addSubview:solve];
    
    
    UIButton *hello  = [[UIButton alloc] initWithFrame:CGRectMake(10,210,300,240)];
    [hello setBackgroundImage:[UIImage imageNamed:@"View-Hello"] forState:UIControlStateNormal];
    hello.alpha = 0.8f;
    [startView addSubview:hello];
    
    
    
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.8];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    startView.alpha = 0.8;
    [UIView commitAnimations];
    
}
-(void)loadWelcomView {
    // Display Welcome View
    UIImageView *startPic = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"View-Start.jpg"]];
    startPic.frame = CGRectMake(0, 0, 320, 480);
    [self.view addSubview:startPic];
    [self.view bringSubviewToFront:startPic];
    startPic.alpha = 1;
    
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    startPic.alpha = 0;
    [UIView commitAnimations];
    [startPic release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadStartView];
    [self loadQuickMenu];
    //[self loadWelcomView];
    numButtons = [[NSMutableArray alloc] initWithCapacity:100];
    [self createNumberButton];
    nowSudokuID = 0;
    
    // answer button array make
    answerButtons = [[NSMutableArray alloc] initWithCapacity:9];
    for (int i = 101; i <=109 ; i++) {
        id b = [[self view] viewWithTag:i];
        [b setBackgroundColor:[UIColor orangeColor]];
        [answerButtons addObject:b];
    }
    
    // edit mode state init
    isEditMode = YES;
    editNumButtons = [[NSMutableArray alloc] initWithCapacity:100];
    
    // init sudoku info
    sudokuTable = [MySudokuClass initSudokuTable:sudokuTable];
    originTable = [MySudokuClass initSudokuTable:originTable];
    showHighlight = YES;
    nowMode = 0;
    [self.scrollView bringSubviewToFront:image_notify];
    
    

    //homeButton.layer.cornerRadius = 10.0f;
    //homeButton.layer.masksToBounds = YES;
    homeButton.layer.borderColor = [[UIColor colorWithWhite:1.0 alpha:0.8] CGColor];
    homeButton.layer.borderWidth = 1;
    
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
