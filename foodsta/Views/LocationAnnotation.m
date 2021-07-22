//
//  LocationAnnotation.m
//  foodsta
//
//  Created by constanceh on 7/21/21.
//

#import <Foundation/Foundation.h>
#import "LocationAnnotation.h"
#import "Post.h"

@interface LocationAnnotation()

@property (nonatomic) CLLocationCoordinate2D coordinate;

@end

@implementation LocationAnnotation

- (NSString *)title {
    return self.post.locationTitle;
}

@end
