//
//  captionCell.h
//  foodsta
//
//  Created by constanceh on 7/16/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CaptionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *captionLabel;

@property (weak, nonatomic) IBOutlet UILabel *selfCaptionLabel;

@property (weak, nonatomic) IBOutlet UILabel *containerCaptionLabel;

@end

NS_ASSUME_NONNULL_END

