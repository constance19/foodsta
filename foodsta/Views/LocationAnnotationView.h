//
//  LocationAnnotationView.h
//  foodsta
//
//  Created by constanceh on 7/21/21.
//

#import <MapKit/MapKit.h>
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LocationAnnotationViewDelegate;

@interface LocationAnnotationView : MKMarkerAnnotationView

@property (nonatomic, strong) Post *post;
@property (nonatomic, weak) id<LocationAnnotationViewDelegate> delegate;

@end


@protocol LocationAnnotationViewDelegate

- (void)locationAnnotationView:(LocationAnnotationView *)locationAnnotationView didTap:(Post *)post;

@end

NS_ASSUME_NONNULL_END
