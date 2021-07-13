//
//  Location.h
//  foodsta
//
//  Created by constanceh on 7/12/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Location : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSString *address;

- (id)initWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)locationsWithDictionaries:(NSArray *)dictionaries;

@end

NS_ASSUME_NONNULL_END
