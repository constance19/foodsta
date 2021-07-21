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
    
    // Set the restaurant name of the location
    self.name = dictionary[@"name"];
    
    // Set the Yelp url of the location
    self.yelpURL = dictionary[@"url"];
    
    // Set the latitude and longitude of the location
    self.latitude = dictionary[@"coordinates"][@"latitude"];
    self.longitude = dictionary[@"coordinates"][@"longitude"];
    
    // Concatenate address components and set it to the location's property
    NSArray *address = dictionary[@"location"][@"display_address"];
    NSInteger count = [address count];
    NSString *concat = [address objectAtIndex:0];
    for (int i = 1; i < count; i++) {
        NSString* add = [address objectAtIndex:i];
        concat = [concat stringByAppendingString:@" "];
        concat = [concat stringByAppendingString:add];
    }
    self.address = concat;
    
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
