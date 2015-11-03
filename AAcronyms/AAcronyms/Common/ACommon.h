//
//  ACommon.h
//  
//
//  Created by Dileep Nair on 11/2/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define WEB_SERVICE_URL @"http://nactem.ac.uk/software/acromine/dictionary.py"
#define ACCEPTABLE_CHARACTERS @" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
#define ACString(key)   [[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:@"Localizable"]

@interface ACommon : NSObject

+(UIAlertController*)applicationAlertMessage:(NSString*)message delegate:(id)delegate;

@end
