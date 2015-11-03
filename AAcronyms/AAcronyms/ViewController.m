//
//  ViewController.m
//  AAcronyms
//
//  Created by Dileep Nair on 11/2/15.
//  Copyright (c) 2015 Dileep Nair. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "ACommon.h"


@interface ViewController ()<MBProgressHUDDelegate>
{
    MBProgressHUD *progressHUD;
}
- (IBAction)searchButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *meaningTextView;
@property (nonatomic,strong) NSMutableDictionary *meaningsDictionary;
@property (weak, nonatomic) IBOutlet UITextField *acronymTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Private methods

- (void)showProgressHUD{
    progressHUD = [[MBProgressHUD alloc]initWithView:self.navigationController.view];
    progressHUD.color = [UIColor lightGrayColor];
    [self.navigationController.view addSubview:progressHUD];
    progressHUD.delegate = self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideProgressView) name:@"HideMDProgressView" object:nil];
    [self webServiceCall];
    [progressHUD show:YES];
    
}

- (void)webServiceCall{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *parameterDict = [NSMutableDictionary dictionary];
    [parameterDict setObject:_acronymTextField.text forKey:@"sf"];
    AFJSONResponseSerializer *jsonReponseSerializer = [AFJSONResponseSerializer serializer];
    jsonReponseSerializer.acceptableContentTypes = nil;
    manager.responseSerializer = jsonReponseSerializer;
    [manager GET:WEB_SERVICE_URL parameters:parameterDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
            if([responseObject count]>0){
                NSMutableDictionary *longformObjects = [[responseObject objectAtIndex:0] objectForKey:@"lfs"];
                _meaningsDictionary = [[NSMutableDictionary alloc]init];
                for(NSMutableDictionary *longformObj in longformObjects){
                    NSMutableArray *varsArray = [[NSMutableArray alloc]init];
                    
                    for(NSMutableDictionary *varsObject in [longformObj objectForKey:@"vars"]){
                        [varsArray addObject:[varsObject objectForKey:@"lf"]];
                    }
                    [_meaningsDictionary setObject:varsArray forKey:[longformObj objectForKey:@"lf"]];
                    varsArray = nil;
                }
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [self displayMeaningsInTextView:_meaningsDictionary];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    UIAlertController *alert= [ACommon applicationAlertMessage:ACString(@"STR_NO_RESULTS") delegate:self];
                    [self presentViewController:alert animated:YES completion:nil];
                    _acronymTextField.text = @"";
                    _meaningTextView.text = @"";
                    
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"HideMDProgressView" object:self];
                });
            }
            
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


-(BOOL)checkAcronymValue{
    BOOL bValue = YES;
    if([_acronymTextField.text isEqualToString:@""]){
        bValue = NO;
        return bValue;
    }
        return bValue;
}


- (void)checkReachability{
    AFHTTPRequestOperationManager *manager;;

    manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://www.google.com/"]];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSOperationQueue *operationQueue = manager.operationQueue;
    [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
             {
                UIAlertController *alert= [ACommon applicationAlertMessage:ACString(@"STR_NO_INTERNET_CONN") delegate:self];
                [self presentViewController:alert animated:YES completion:nil];
           //     NSLog(@"No Internet Conexion");
                break;
                
            }
            case AFNetworkReachabilityStatusReachableViaWiFi:
             //   NSLog(@"WIFI");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
               // NSLog(@"3G");
                break;
            default:
               // NSLog(@"Unkown network status");
                [operationQueue setSuspended:YES];
                break;
        }

    }];

    [manager.reachabilityManager startMonitoring];
}


- (void)displayMeaningsInTextView:(NSMutableDictionary*)meaningDict{
    NSString *formattedString = @"";
    for(NSString *mkey in [meaningDict allKeys]){
        formattedString = [formattedString stringByAppendingString:[NSString stringWithFormat:@"%@\n",mkey]];
        
        for(NSString *mValue in [meaningDict objectForKey:mkey]){
            formattedString = [formattedString stringByAppendingString:[NSString stringWithFormat:@"\t - %@ \n",mValue]];
        }
    }
    _meaningTextView.text = formattedString;
    
     [[NSNotificationCenter defaultCenter]postNotificationName:@"HideMDProgressView" object:self];
}


#pragma mark - TextField delegate methods

- (BOOL)textFieldShouldReturn:(UITextField*)textField{
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [textField becomeFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
    
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    return [string isEqualToString:filtered];
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    [progressHUD removeFromSuperview];
    progressHUD = nil;
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
}

#pragma NSNotification Method
- (void)hideProgressView{
     [progressHUD removeFromSuperview];
}

#pragma mark - IBAction methods

- (IBAction)searchButtonAction:(id)sender {
    [self checkReachability];
    if([self checkAcronymValue]){
        [self showProgressHUD];
        [_acronymTextField resignFirstResponder];
    }else{
        UIAlertController *alert= [ACommon applicationAlertMessage:ACString(@"STR_ENTER_ACRONYM") delegate:self];
        [self presentViewController:alert animated:YES completion:nil];
        _acronymTextField.text = @"";
        
    }
    
}


@end
