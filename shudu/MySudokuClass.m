//
//  MySudokuClass.m
//  sudoku
//
//  Created by michelle on 11-6-12.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "MySudokuClass.h"

@implementation MySudokuClass

- (NSArray *)readSudokuFile:(NSString *)fileName {
    //NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:100];
    NSError *error;
    NSString *textFileContents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SudokuFile" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
    if (textFileContents == nil) {
        NSLog(@"Read File error! %@",[error localizedFailureReason]);
    }
    NSArray *fileContents = [textFileContents componentsSeparatedByString:@"#"];
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:10];
    for (NSString *s in fileContents) {
        s=[s stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        s=[s stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        [result addObject:[s componentsSeparatedByString:@" "]];
    }
    return result;
}

+ (NSMutableDictionary *)initSudokuTable:(NSMutableDictionary *)sudokuTable {
    sudokuTable = [[NSMutableDictionary alloc] initWithCapacity:81];
    for (int i = 1; i < 10; i++) {
        for (int j = 1; j < 10; j++) {
            [sudokuTable setValue:@"0" forKey:[NSString stringWithFormat:@"%d%d",i,j]];
        }
    }
    return sudokuTable;
}

+ (void)resloveSudoku:(NSArray *)sudokuNow {
    //NSMutableArray *sudokuTable = [[NSMutableArray alloc] initWithCapacity:99];
    // init sudoku table
    NSMutableDictionary *sudokuTable = [[NSMutableDictionary alloc] initWithCapacity:100];
    for (int i = 1; i <= 9; i ++) {
        //NSMutableArray *row = [[NSMutableArray alloc] initWithCapacity:9];
        for (int j = 1; j <= 9; j ++) {
            /*SudokuCell c;
            c.rowcol=i*10+j;
            c.value = 0;*/
            //NSValue *cell = [NSValue value:&c withObjCType:@encode(SudokuCell)];
            //NSString *no = [NSString stringWithFormat:@"%d%d",i,j];
            //[sudokuTable addObject:cell];
            [sudokuTable setObject:@"0" forKey:[NSString stringWithFormat:@"%d%d",i,j]];
        }
    }
    
    for (int i = 0; i <[sudokuNow count] ;i ++) {
        SudokuCell c;
        NSValue *cell = [sudokuNow objectAtIndex:i];
        [cell getValue:&c];
        NSString *rowCol = [NSString stringWithFormat:@"%d",c.rowcol];
        [sudokuTable setValue:[NSNumber numberWithInt:c.value] forKey:rowCol];
        NSLog(@"row:%d col:%d value:%@",c.rowcol/10,c.rowcol%10,[sudokuTable valueForKey:rowCol]);
    }
    // fill table with sudoku now

}

+(int)getSudokuAreaStartPos:(int)pos {
    int areaPos = 0;
    int startPos = pos%3;
    switch (startPos) {
        case 1:
            areaPos = pos;
            break;
        case 2:
            areaPos = pos - 1;
            break;
        case 0:
            areaPos = pos - 2;
            break;
        default:
            break;
    }
    return areaPos;
}

+(BOOL)checkSudokuArea:(NSMutableDictionary *)sudokuTable atRow:(int)row atCol:(int)col forValue:(int)value {
    int areaRow = [MySudokuClass getSudokuAreaStartPos:row];
    int areaCol = [MySudokuClass getSudokuAreaStartPos:col];
    for (int i = areaRow; i < areaRow + 3; i++) {
        for (int j = areaCol; j < areaCol + 3; j++) {
            int nowValue = [[sudokuTable valueForKey:[NSString stringWithFormat:@"%d%d",i,j]] intValue];
            if (nowValue == value) {
                return NO;
            }
        }
    }
    return YES;
}

+ (BOOL) checkSudoku:(NSMutableDictionary *)sudokuTable inRowCol:(NSString *)rowcol forValue:(int)value {
    int row = [rowcol intValue]/10;
    int col = [rowcol intValue]%10;
    // check same row & col
    for (int i = 1 ; i <= 9; i++) {
        int nowValueRow = [[sudokuTable valueForKey:[NSString stringWithFormat:@"%d%d",row,i]] intValue];
        int nowValueCol = [[sudokuTable valueForKey:[NSString stringWithFormat:@"%d%d",i,col]] intValue];
        if (nowValueRow == value || nowValueCol == value) {
            return NO;
        }
    }
    return [MySudokuClass checkSudokuArea:sudokuTable atRow:row atCol:col forValue:value];
}



+ (NSMutableDictionary *)getCellPosibleValue:(NSDictionary *)sudokuTable atRow:(int)row atCol:(int)col {

    int posibleValueCount = 0;
    //get related cells exsist value
    NSMutableDictionary *posibleValues = [[NSMutableDictionary alloc] initWithCapacity:9];
    for (int i = 1; i < 10; i++) {
        [posibleValues setValue:@"YES" forKey:[NSString stringWithFormat:@"%d",i]];
    }
    // Row & Col
    for (int i = 1; i < 10; i++) {
        NSString *nowValueRow = [sudokuTable valueForKey:[NSString stringWithFormat:@"%d%d",row,i]];
        NSString *nowValueCol = [sudokuTable valueForKey:[NSString stringWithFormat:@"%d%d",i,col]];
        if (nowValueCol != @"0" && nowValueCol != nil) [posibleValues setValue:@"NO" forKey:nowValueCol];
        if (nowValueRow != @"0" && nowValueRow != nil) [posibleValues setValue:@"NO" forKey:nowValueRow];
    }
    
    // Area
    int areaRow = [MySudokuClass getSudokuAreaStartPos:row];
    int areaCol = [MySudokuClass getSudokuAreaStartPos:col];
    for (int i = areaRow; i < areaRow+3 ; i++) {
        for (int j = areaCol; j < areaCol+3; j++) {
            NSString *nowValue = [sudokuTable valueForKey:[NSString stringWithFormat:@"%d%d",i,j]];
            if (nowValue !=@"0" && nowValue != nil) [posibleValues setValue:@"NO" forKey:nowValue];
        }
    }
    
    for (int i = 1; i < 10; i++) {
        if ([[posibleValues valueForKey:[NSString stringWithFormat:@"%d",i]] boolValue]) {
            posibleValueCount++;
        }
    }
    //NSLog(@"row:%d col:%d posible number count:%d %@",row,col,posibleValueCount,exsistValue);
    
    return posibleValues;
}

+(NSArray *)getMinPosibleValueCount:(NSMutableDictionary *)posibleValueTable {
    int minPosibleValueCount = 9;
    NSArray *minPosibleValue = [[NSMutableArray alloc] initWithCapacity:9];
    int minRow = 0;
    int minCol = 0;
    for (int i = 1; i < 10; i++) {
        for (int j = 1; j < 10; j++) {
            NSString *pos = [NSString stringWithFormat:@"%d%d",i,j];
            NSString *nowValue = [posibleValueTable valueForKey:pos];
            //NSLog(@"%@",nowValue);
            if ([nowValue intValue] == 0) {
                NSArray *posibleValue = [[MySudokuClass getCellPosibleValue:posibleValueTable atRow:i atCol:j] allKeysForObject:@"YES"];
                int posibleValueCount = [posibleValue count];
                if (posibleValueCount <= minPosibleValueCount) {
                    minPosibleValueCount = posibleValueCount;
                    minPosibleValue =posibleValue;
                    minRow = i;
                    minCol = j;
                }
            }

        }
    }
   /* for (NSString *pos in [posibleValueTable allKeysForObject:@"0"]) {
        int row = [pos intValue]/10;
        int col = [pos intValue]%10;
        NSArray *posibleValue = [[MySudokuClass getCellPosibleValue:posibleValueTable atRow:row atCol:col] allKeysForObject:@"YES"];
        int posibleValueCount = [posibleValue count];
        if (posibleValueCount <= minPosibleValueCount) {
            minPosibleValueCount = posibleValueCount;
            minPosibleValue =posibleValue;
            minRow = row;
            minCol = col;
        }
    }*/
    //NSLog(@"min:%d %d-%@",minRow,minCol,minPosibleValue);
    //NSString *str = [NSString stringWithFormat:@"%d:%d:%d",minRow,minCol,minPosibleValueCount];
    NSArray *returnArray = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%d%d",minRow,minCol],minPosibleValue, nil];
    return returnArray;
    
}


+(BOOL)isSudokuTableFullFilled:(NSMutableDictionary *)sudokuTable {
    if ([[sudokuTable allKeysForObject:@"0"] count]!=0) {
        return NO;
    }
    else return YES;
}

+(void)removePosibleValueFromRelatedCell:(NSMutableDictionary *)posibleValueTable atRow:(int)row atCol:(int)col forValue:(NSString *)value {
    for (int i = 1; i < 10 ; i++) {
        NSMutableDictionary *nowValueRow = [posibleValueTable valueForKey:[NSString stringWithFormat:@"%d%d",row,i]];
        NSMutableDictionary *nowValueCol = [posibleValueTable valueForKey:[NSString stringWithFormat:@"%d%d",i,col]];
        [nowValueRow setValue:@"NO" forKey:value];
        [nowValueCol setValue:@"NO" forKey:value];
        
    }
    int areaRow = [MySudokuClass getSudokuAreaStartPos:row];
    int areaCol = [MySudokuClass getSudokuAreaStartPos:col];
    for (int i = areaRow; i < areaRow + 3; i ++) {
        for (int j = areaCol; j < areaCol + 3; j++) {
            NSString *pos = [NSString stringWithFormat:@"%d%d",i,j];
            NSMutableDictionary *nowValue = [posibleValueTable valueForKey:pos];
            [nowValue setValue:@"NO" forKey:value];
        }
    }
}

+(NSMutableDictionary *)makePosibleValueTable {
    NSMutableDictionary *posibleValueTemp = [[NSMutableDictionary alloc] initWithCapacity:9];
    NSMutableDictionary *sudokuTable = [[NSMutableDictionary alloc] initWithCapacity:81];
    for (int i = 1; i < 10; i++) {
        [posibleValueTemp setValue:@"YES" forKey:[NSString stringWithFormat:@"%d",i]];
    }
    for (int i = 1; i < 10; i++) {
        for (int j = 1; j < 10; j++) {
            NSMutableDictionary *posibleValue = [[NSMutableDictionary alloc] initWithDictionary:posibleValueTemp copyItems:YES];
            [sudokuTable setValue:posibleValue forKey:[NSString stringWithFormat:@"%d%d",i,j]];
            
        }
    }
    return sudokuTable;
}

+ (NSDictionary *) makeSudoku {
    NSMutableDictionary *sudokuTable = [[NSMutableDictionary alloc] initWithCapacity:81];
    sudokuTable = [MySudokuClass initSudokuTable:sudokuTable];
    //NSMutableDictionary *sudokuTable1 = [[NSMutableDictionary alloc] initWithCapacity:1];
    int rowLoop = 0;
    int loop = 0;
    while (loop <10) {
        //NSLog(@"Now program is doing No.%d loop....",loop);
        sudokuTable = [MySudokuClass initSudokuTable:sudokuTable];
        for (int i = 1; i <= 9 && rowLoop <= 50; i ++) {
            //NSString *rowSudoku = [[NSString alloc] init];
            //NSLog(@"  |_ Now program is making Row(%d)....",i);
            for (int j = 1; j <= 9 ; j++) {
                NSArray *posibleValue = [[MySudokuClass getCellPosibleValue:sudokuTable atRow:i atCol:j] allKeysForObject:@"YES"];
                //NSLog(@"%@",posibleValue);
                if ([posibleValue count]==0) {
                    for (int k = 1; k < j; k++) {
                        [sudokuTable setValue:@"0" forKey:[NSString stringWithFormat:@"%d%d",i,k]];
                    }
                    rowLoop ++;
                    i--;
                    break;
                }
                int randomID = 0;
                if ([posibleValue count] > 1) randomID = (arc4random() % [posibleValue count]);
                int random = [[posibleValue objectAtIndex:randomID] intValue];
                NSString *rowcol = [NSString stringWithFormat:@"%d%d",i,j];
                [sudokuTable setValue:[NSString stringWithFormat:@"%d",random] forKey:rowcol];
            }
            
        }rowLoop = 0;

        if ([MySudokuClass isSudokuTableFullFilled:sudokuTable]) {
            break;
        }
        loop ++;
    }

    return sudokuTable;
}

+(NSMutableDictionary *)makeEmptyCell:(NSMutableDictionary *)sudokuResource forLevel:(int)level {
    int notEmptyCell = 81;
    NSMutableDictionary *sudokuTable = [[NSMutableDictionary alloc] initWithDictionary:sudokuResource copyItems:YES];
    while (notEmptyCell > level) {
        int row = (arc4random() % 9) + 1;
        int col = (arc4random() % 9) + 1;
        NSString *rowcol = [NSString stringWithFormat:@"%d%d",row,col];
        if ([[sudokuTable valueForKey:rowcol] intValue] > 0) {
            [sudokuTable setValue:@"0" forKey:rowcol];
            notEmptyCell--;
        }
    }
    return sudokuTable;
}

+(UIButton *)createSudokuButtonForView:(UIViewController *)view atPos:(CGRect)position withTag:(int)tag forAction:(SEL)action {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    [b setFrame:position];
    [b.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [b setTag:tag];
    [b addTarget:view action:action forControlEvents:UIControlEventTouchDown];
    [b setTitle:@"" forState:0];
    [b setTitleColor:[UIColor blackColor] forState:0];
    //b.layer.frame = CGRectMake(xSta-1, ySta-1, 31, 31);
    //[b.layer setBorderWidth:borderWidth];
    

    b.userInteractionEnabled = YES;
    return b;
}

+(NSMutableDictionary *)solveThisSudoku:(NSMutableDictionary *)sudokuTable {
    int minPosibleValueCount = 0;
    NSMutableArray *lastTable = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableDictionary *tmpTable = [[NSMutableDictionary alloc] initWithDictionary:sudokuTable copyItems:YES];
    [lastTable addObject:tmpTable];
    int flag = 0;
    while (flag < 500) {
        NSArray *minPosibleValueCell = [MySudokuClass getMinPosibleValueCount:sudokuTable];
        minPosibleValueCount = [[minPosibleValueCell objectAtIndex:1] count];
        if (minPosibleValueCount == 0) {
            NSLog(@"Solve Failed %d times!",flag);  
            flag++;
            sudokuTable = [lastTable lastObject];
            if ([lastTable count] > 1) {
                [lastTable removeLastObject];
            }
            if ([MySudokuClass isSudokuTableFullFilled:sudokuTable]) break;
            continue;
        }
        else if (minPosibleValueCount == 1) {
            
            NSMutableDictionary *solvetable = [MySudokuClass solveSudoku:sudokuTable];
            for (NSString *pos in [solvetable allKeys]) {
                NSMutableArray *values = [solvetable valueForKey:pos];
                if ([values count]>1) [values sortUsingSelector:@selector(compare:)];
                NSString *value = [values componentsJoinedByString:@""];
                
                if ([values count]==1) {
                    [sudokuTable setValue:value forKey:pos];
                }
            }
            [lastTable removeAllObjects];
            [lastTable addObject:sudokuTable];
        }
        else if (minPosibleValueCount > 1) {
            NSString *pos = [minPosibleValueCell objectAtIndex:0];
            //int lastRandom = -1;
            int randomCount = 0;
            NSMutableArray *testRandom = [[NSMutableArray alloc] initWithCapacity:9];
            while (randomCount<=minPosibleValueCount) {
                int random = arc4random() % minPosibleValueCount ;
                if ([testRandom indexOfObject:[NSString stringWithFormat:@"%d",random]] > 9 ) {
                    randomCount++;
                    [testRandom addObject:[NSString stringWithFormat:@"%d",random]];
                    NSString *n = [[minPosibleValueCell objectAtIndex:1] objectAtIndex:random];
                    [sudokuTable setValue:n forKey:pos];
                    NSArray *minCell = [MySudokuClass getMinPosibleValueCount:sudokuTable];
                    int minCount = [[minCell objectAtIndex:1] count];
                    if (minCount == 0) {
                        sudokuTable = [lastTable lastObject];
                        continue;
                    }
                    else {
                        [lastTable addObject:sudokuTable];
                        break;
                    }
                }
                else continue;
            }
        }
    }
    return sudokuTable;
}

+(NSMutableDictionary *)solveSudoku:(NSDictionary *)sudokuTable {
    //NSMutableDictionary *solveTable = [[NSMutableDictionary alloc] initWithCapacity:81];
    NSMutableDictionary *posibleValueTable = [[NSMutableDictionary alloc] initWithCapacity:81];
    for (int i = 1; i < 10; i++) {
        for (int j = 1; j < 10; j++) {
            NSString *pos = [NSString stringWithFormat:@"%d%d",i,j];
            NSString *nowValue = [sudokuTable valueForKey:pos];
            if ([nowValue intValue]==0) {
                NSMutableArray *posibleValue = [[NSMutableArray alloc] initWithArray:[[MySudokuClass getCellPosibleValue:sudokuTable atRow:i atCol:j] allKeysForObject:@"YES"] copyItems:YES];
                //NSLog(@"%d%d:%@",i,j,posibleValue);
                [posibleValueTable setValue:posibleValue forKey:pos];
            }
        }
    }
    for (NSString *pos in [posibleValueTable allKeys]) {
        int row = [pos intValue]/10;
        int col = [pos intValue]%10;
        posibleValueTable = [MySudokuClass solveOnePosibleValueCellFor:posibleValueTable atRow:row atCol:col];
    }
    
    return posibleValueTable;
}

+ (NSMutableDictionary *) solveOnePosibleValueCellFor:(NSMutableDictionary *)posibleValueTable atRow:(int)row atCol:(int)col {
    int areaRow = [MySudokuClass getSudokuAreaStartPos:row];
    int areaCol = [MySudokuClass getSudokuAreaStartPos:col];
    NSMutableDictionary *valueCountRow = [[NSMutableDictionary alloc] initWithCapacity:9];
    NSMutableDictionary *valueCountCol = [[NSMutableDictionary alloc] initWithCapacity:9];
    NSMutableDictionary *valueCountArea = [[NSMutableDictionary alloc] initWithCapacity:9];
    for (int i = 1; i < 10; i ++) {
        [valueCountRow setValue:[[NSMutableArray alloc] initWithCapacity:9] forKey:[NSString stringWithFormat:@"%d",i]];
        [valueCountCol setValue:[[NSMutableArray alloc] initWithCapacity:9]forKey:[NSString stringWithFormat:@"%d",i]];
        [valueCountArea setValue:[[NSMutableArray alloc] initWithCapacity:9] forKey:[NSString stringWithFormat:@"%d",i]];
    }
    for (int i = 1; i < 10; i++) {
        NSArray *rowValue = [posibleValueTable valueForKey:[NSString stringWithFormat:@"%d%d",row,i]];
        NSArray *colValue = [posibleValueTable valueForKey:[NSString stringWithFormat:@"%d%d",i,col]];
        if ( rowValue != nil) {
            for (NSString *s in rowValue) {
                NSMutableArray *posForValue = [valueCountRow valueForKey:s];
                [posForValue addObject:[NSString stringWithFormat:@"%d%d",row,i]];
                [valueCountRow setValue:posForValue forKey:s];
            }
        }
        if ( colValue != nil) {
            for (NSString *s in colValue) {
                NSMutableArray *posForValue = [valueCountCol valueForKey:s];
                [posForValue addObject:[NSString stringWithFormat:@"%d%d",i,col]];
                [valueCountCol setValue:posForValue forKey:s];
            }
        }
    }
    
    for (int i = areaRow; i < areaRow + 3; i ++) {
        for (int j = areaCol; j < areaCol + 3; j ++) {
            NSString *pos = [NSString stringWithFormat:@"%d%d",i,j];
            NSArray *areaValue = [posibleValueTable valueForKey:pos];
            if (areaValue != nil) {
                for (NSString *s in areaValue) {
                    NSMutableArray *posForValue = [valueCountArea valueForKey:s];
                    [posForValue addObject:[NSString stringWithFormat:@"%d%d",i,j]];
                    [valueCountArea setValue:posForValue forKey:s];
                }
            }
        }
    }
    //posibleValueTable = [[NSMutableDictionary alloc] initWithCapacity:81];
    for (int i = 1; i < 10; i++) {
        NSString *num = [NSString stringWithFormat:@"%d",i];
        int countRow = [[valueCountRow valueForKey:num] count];
        int countCol = [[valueCountCol valueForKey:num] count]; 
        int countArea = [[valueCountArea valueForKey:num] count]; 
        if (countRow == 1) {
            //NSLog(@"Number(%d) in %@",i,[valueCountRow valueForKey:num]);
            [posibleValueTable setValue:[NSArray arrayWithObject:num] forKey:[[valueCountRow valueForKey:num] objectAtIndex:0]];
        }
        if (countCol == 1) {
            //NSLog(@"Number(%d) in %@",i,[valueCountCol valueForKey:num]);
            [posibleValueTable setValue:[NSArray arrayWithObject:num] forKey:[[valueCountCol valueForKey:num] objectAtIndex:0]];
        }
        if (countArea == 1) {
            //NSLog(@"Number(%d) in %@",i,[valueCountArea valueForKey:num]);
            [posibleValueTable setValue:[NSArray arrayWithObject:num] forKey:[[valueCountArea valueForKey:num] objectAtIndex:0]];
        }
    }

    return posibleValueTable;
    //NSLog(@"%@%@%@",valueCountRow,valueCountCol,valueCountArea);
}
      













@end
