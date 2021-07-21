//
//  Location.h
//  foodsta
//
//  Created by constanceh on 7/12/21.
//

#import <Foundation/Foundation.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface Location : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *yelpURL;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;


- (id)initWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)locationsWithDictionaries:(NSArray *)dictionaries;

@end

NS_ASSUME_NONNULL_END
