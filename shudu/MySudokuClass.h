//
//  MySudokuClass.h
//  sudoku
//
//  Created by michelle on 11-6-12.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef struct {
    int rowcol;
    int value;
}SudokuCell;

@interface MySudokuClass : NSObject {
    
}

- (NSArray *) readSudokuFile:(NSString *)fileName;
+(BOOL)isSudokuTableFullFilled:(NSMutableDictionary *)sudokuTable ;
+ (void) resloveSudoku:(NSArray *)sudokuNow;
+ (NSMutableDictionary *) makeSudoku;
+ (NSMutableDictionary *) initSudokuTable:(NSMutableDictionary *)sudokuTable;
+ (NSMutableDictionary *)getCellPosibleValue:(NSDictionary *)sudokuTable atRow:(int)row atCol:(int)col;
+(NSArray *)getMinPosibleValueCount:(NSMutableDictionary *)posibleTable;
+(NSMutableDictionary *)makePosibleValueTable;
+(UIButton *)createSudokuButtonForView:(UIViewController *)view atPos:(CGRect)position withTag:(int)tag forAction:(SEL)action;
+(NSMutableDictionary *)makeEmptyCell:(NSMutableDictionary *)sudokuResource forLevel:(int)level ;
+(NSMutableDictionary *)solveThisSudoku:(NSMutableDictionary *)sudokuTable ;
+(NSMutableDictionary *)solveSudoku:(NSDictionary *)sudokuTable ;
+(NSMutableDictionary *) solveOnePosibleValueCellFor:(NSMutableDictionary *)posibleValueTable atRow:(int)row atCol:(int)col ;
@end
