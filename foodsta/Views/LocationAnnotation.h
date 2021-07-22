//
//  LocationAnnotation.h
//  foodsta
//
//  Created by constanceh on 7/21/21.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Post.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface LocationAnnotation : NSObject <MKAnnotation>

@property (strong, nonatomic) UIImage *photo;
@property (strong, nonatomic) Post *post;

@end

NS_ASSUME_NONNULL_END
