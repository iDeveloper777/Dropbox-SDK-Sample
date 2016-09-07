//
//  StringExtension.m
//  VideoAndImage
//
//  Created by Csaba Toth on 12/5/15.
//  Copyright (c) 2015 Csaba Toth. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "StringExtension.h"

@implementation StringExtension

- (NSString *) getDateFromString:(NSString *)parentString{
    NSString *strDate = @"";
    
    strDate = [parentString substringToIndex:10];
    return strDate;
}

- (NSString *) getSlideNameFromString:(NSString *)parentString{
    NSString *str = @"";
    
    int nFlag = 0;
    int nPos = 9;
    
    while (nFlag == 0 && nPos < parentString.length-1) {
        nPos ++;
        
        NSString *tempStr = [parentString substringWithRange:NSMakeRange(nPos, 1)];
        if ([tempStr isEqualToString:@"I"]) {
            nFlag = 1;
        }
    }

    if (nFlag == 1)
        str = [parentString substringWithRange:NSMakeRange(10, nPos - 9)];
    
    return str;
}

- (NSString *) getPlayNameFromString:(NSString *)parentString{
    NSString *str = @"";
    NSString *strSlideName = [self getSlideNameFromString:parentString];
    
    if (strSlideName.length != 0)
        str = [parentString substringWithRange:NSMakeRange(strSlideName.length+10, parentString.length-strSlideName.length-15)];
    
    return str;
}

- (BOOL) isValidImage:(NSString *)strImageName{
    int nFlag = 0;
    for (int i=0; i<strImageName.length-1; i++) {
        NSString *strTemp = [strImageName substringWithRange:NSMakeRange(i, 1)];
        if ([strTemp isEqualToString:@"I"])
            nFlag = 1;
    }
    
    if (nFlag == 0)
        return FALSE;
    
    NSString *strYear = [strImageName substringToIndex:4];
    long nYear = [strYear integerValue];
    
    if (nYear >= 2000)
        return TRUE;
    
    return FALSE;
}

- (BOOL) isValidVideo:(NSString *)strVideoName{
    NSString *strYear = [strVideoName substringToIndex:4];
    long nYear = [strYear integerValue];
    
    if (nYear >= 2000)
        return TRUE;
    
    return FALSE;
}
@end