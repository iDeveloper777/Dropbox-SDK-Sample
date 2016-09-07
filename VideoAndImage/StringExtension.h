//
//  StringExtension.h
//  VideoAndImage
//
//  Created by Csaba Toth on 12/5/15.
//  Copyright (c) 2015 Csaba Toth. All rights reserved.
//

#ifndef VideoAndImage_StringExtension_h
#define VideoAndImage_StringExtension_h

#import <Foundation/Foundation.h>

@protocol StringExtension

@end

@interface StringExtension : NSObject

- (NSString *) getDateFromString: (NSString *) parentString;
- (NSString *) getSlideNameFromString: (NSString *) parentString;
- (NSString *) getPlayNameFromString: (NSString *) parentString;
- (BOOL) isValidImage: (NSString *) strImageName;
- (BOOL) isValidVideo: (NSString *) strVideoName;

@end

#endif
