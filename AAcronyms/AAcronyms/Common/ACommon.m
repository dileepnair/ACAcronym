//
//  ACommon.m
//  
//
//  Created by Dileep Nair on 11/2/15.
//
//

#import "ACommon.h"

@implementation ACommon


+(UIAlertController*)applicationAlertMessage:(NSString*)message delegate:(id)delegate{

    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:ACString(@"STR_APP_NAME")  message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:ACString(@"STR_OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
    [alertCtr addAction:okAction];
    return alertCtr;
}
@end
