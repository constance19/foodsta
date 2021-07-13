//
//  Location.m
//  foodsta
//
//  Created by constanceh on 7/12/21.
//

#import "Location.h"

@implementation Location


- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    // Set the restaurant name and address
    self.name = dictionary[@"name"];
    self.address = dictionary[@"location"][@"display_address"];
    
    // Get the poster URL to set the poster view
    NSString *imageString = dictionary[@"image_url"];
    NSURL *imageURL = [NSURL URLWithString:imageString];
    self.imageURL = imageURL;

    return self;
}


+ (NSArray *)locationsWithDictionaries:(NSArray *)dictionaries {
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    
    // Get an array of locations using the input dictionary array
    for (NSDictionary *dictionary in dictionaries) {
        Location *location = [[Location alloc] initWithDictionary:dictionary];
        [locations addObject:location];
    }
    
    return locations;
}

@end
