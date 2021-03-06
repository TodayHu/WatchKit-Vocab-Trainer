//
//  AppDelegate.m
//  WatchKit Vocab Trainer
//
//  Created by Arik Sosman on 1/10/15.
//  Copyright (c) 2015 WKH. All rights reserved.
//

#import "AppDelegate.h"



@interface AppDelegate ()

@property (strong, nonatomic) CLLocationManager *manager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.manager = [[CLLocationManager alloc] init];
    [self.manager requestAlwaysAuthorization];
    
    self.manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.manager.distanceFilter = 20;
    self.manager.delegate = self;
    
    [self.manager startUpdatingLocation];
    
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    // NSLog(@"Locations: %@", locations);
    
    CLLocation *lastLocation = locations.firstObject;
    
    if(lastLocation.speed < 1.5){ // we are more or less stationary
        
        NSLog(@"Location property suitable for quiz. Now a push notification should be triggered – if Apple allowed it!");
        
    }
    
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

   
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *replyInfo))reply {
    if([[NSString stringWithFormat:@"%@",userInfo[@"key"]] isEqualToString:@"sendAnswerToServer"]) {
        
        
        NSString *correctString = @"false";
        if([[NSString stringWithFormat:@"%@",userInfo[@"numberOfAnswers"]] isEqualToString:@"1"]) {
            correctString=@"true";
        }
        

        NSString *serverRequestSting = [NSString stringWithFormat:@"http://xampp.localhost/watchkit-vocab-trainer/web/answer/?question_id=%@&correct=%@&device_id=%@" ,[NSString stringWithFormat:@"%@",userInfo[@"questionid"]],correctString,[UIDevice currentDevice].identifierForVendor.UUIDString];
        
        
        
        
        void (^finishedDownloading)(NSString *dic) = ^void(NSString *dic) {
            reply(@{@"Server answer": dic});
        };
        
        
        
        [FRServer stringFromURL:serverRequestSting HTTPMethod:@"POST" attributes:nil HTTPHeaderFieldDictionary:nil andCallbackBlock:finishedDownloading];
        
        
    } else if([userInfo[@"key"] isEqualToString:@"getNewQuestionFromServer"]) {
        void (^finishedDownloading)(NSDictionary *dic) = ^void(NSDictionary *dic) {
            
            NSString *question = dic[@"question"][@"text"];
            
            
            //int r = arc4random() % 3;
            
            NSString *answer1;
            NSString *identifier1;
            NSString *answer2;
            NSString *identifier2;
            NSString *answer3;
            NSString *identifier3;
            
            
            
            NSMutableArray *answerOptions = @[].mutableCopy;
            
            
            [answerOptions addObject:@{@"answer": dic[@"correct_answers"][0][@"value"], @"identifier": @"true"}];
            
            
            for(int i = 0; i < MIN(2, [dic[@"wrong_answers"] count]); i++){
                
                NSDictionary *currentAddition = @{@"answer": dic[@"wrong_answers"][i][@"value"], @"identifier": @"false"};
                
                if(arc4random() % 2 == 1){
                    
                    [answerOptions insertObject:currentAddition atIndex:0];
                    
                }else{
                    
                    [answerOptions addObject:currentAddition];
                    
                }
                
            }
            
            answer1 = answerOptions[0][@"answer"];
            identifier1 = answerOptions[0][@"identifier"];
            
            answer2 = answerOptions[1][@"answer"];
            identifier2 = answerOptions[1][@"identifier"];
            
            answer3 = answerOptions[2][@"answer"];
            identifier3 = answerOptions[2][@"identifier"];
            
            
            
            /*
             
             if(r == 0) {
             answer1 = dic[@"correct_answers"][0][@"value"];
             identifier1 = @"true";
             } else if(r == 1) {
             answer2 = dic[@"correct_answers"][0][@"value"];
             identifier2 = @"true";
             } else if(r == 2) {
             answer3 = dic[@"correct_answers"][0][@"value"];
             identifier3 = @"true";
             }
             
             int wrongAnswerIndex = 0;
             
             NSArray *wrongAnswers = dic[@"wrong_answers"];
             
             if(r != 0) {
             answer1 = wrongAnswers[wrongAnswerIndex][@"value"];
             identifier1 = @"false";
             wrongAnswerIndex++;
             } else if(r != 1) {
             answer2 = wrongAnswers[wrongAnswerIndex][@"value"];
             identifier2 = @"false";
             wrongAnswerIndex++;
             } else if(r != 2) {
             answer3 = wrongAnswers[wrongAnswerIndex][@"value"];
             identifier3 = @"false";
             wrongAnswerIndex++;
             }*/
            
            
            
            NSString *questionString = [NSString stringWithFormat:@"{    \"aps\": {        \"alert\": \"%@\",        \"title\": \"Optional title\",        \"category\": \"myCategory\"    },        \"WatchKit Simulator Actions\": [                                   {                                        \"title\": \"%@\",                                        \"identifier\": \"%@\"                                   } , {                                        \"title\": \"%@\",                                        \"identifier\": \"%@\"                                   } , {                                        \"title\": \"%@\",                                        \"identifier\": \"%@\"                                   }                                   ]}",question,answer1,identifier1,answer2,identifier2,answer3,identifier3];
            
            
            NSMutableDictionary *newQuestionDic = [[NSJSONSerialization JSONObjectWithData:[questionString  dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil] mutableCopy];
            
            [newQuestionDic setValue:dic[@"question"][@"id"] forKey:@"questionid"];
            
            reply(newQuestionDic);
            
        };
        
        
        NSString *requestURL = [NSString stringWithFormat:@"http://xampp.localhost/watchkit-vocab-trainer/web/category/%u/random-question?device_id=%@",[AppDelegate getPackageID],[UIDevice currentDevice].identifierForVendor.UUIDString];
        
        [FRServer jsonFromURL: [requestURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] HTTPMethod:@"GET" attributes:nil HTTPHeaderFieldDictionary:nil andCallbackBlock:finishedDownloading];
    }
}





+(NSDictionary *) factoryJSONQuestion {
    
    NSString *question = @"Banane";
    NSString *answer1 = @"Cola";
    NSString *identifier1 = @"false";
    
    NSString *answer2 = @"Apfel";
    NSString *identifier2 = @"false";
    
    NSString *answer3 = @"Banana";
    NSString *identifier3 = @"true";
    
    
    NSString *questionString = [NSString stringWithFormat:@"{    \"aps\": {        \"alert\": \"%@\",        \"title\": \"Optional title\",        \"category\": \"myCategory\"    },        \"WatchKit Simulator Actions\": [                                   {                                        \"title\": \"%@\",                                        \"identifier\": \"%@\"                                   } , {                                        \"title\": \"%@\",                                        \"identifier\": \"%@\"                                   } , {                                        \"title\": \"%@\",                                        \"identifier\": \"%@\"                                   }                                   ]}",question,answer1,identifier1,answer2,identifier2,answer3,identifier3];
    
    
    return [NSJSONSerialization JSONObjectWithData:[questionString  dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
}

+(void) setPackageID:(int) packageID {
    [FRLocalStorage storeObject:[NSString stringWithFormat:@"%u",packageID] forKey:@"packageid"];
}

+(int) getPackageID {
    return [[FRLocalStorage objectForKey:@"packageid"] intValue];
}

@end
