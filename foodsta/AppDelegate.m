//
//  AppDelegate.m
//  foodsta
//
//  Created by constanceh on 7/12/21.
//

#import "AppDelegate.h"
#import "Parse/Parse.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {

            configuration.applicationId = @"0M723WfbPOyB8UpQb5pssvHvSDv3hk6fLzcVw4No"; // <- UPDATE
            configuration.clientKey = @"bPm4pejszdD4V3MP8KrBF41XJkqB0CidH9Y1nPjG"; // <- UPDATE
        
//            configuration.applicationId = @"DMEVJy22E9uOHzC2IfT4wVd4RCl8qWL6CJmR3nWV"; // <- UPDATE
//            configuration.clientKey = @"szJAnnLHb1kPneYsXDKi7nVONgGKCSgxZ1I6VzeR"; // <- UPDATE
            configuration.server = @"https://parseapi.back4app.com";
        }];

        [Parse initializeWithConfiguration:config];
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
