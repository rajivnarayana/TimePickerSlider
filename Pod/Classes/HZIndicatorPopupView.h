//
//  HZIndicatorPopupView.h
//  
//
//  Created by Hertz on 12/20/15.
//
//

#import <UIKit/UIKit.h>

/**
 * A popup view with a arrow pointing
 */
@interface HZIndicatorPopupView : UIView

@property(nonatomic, strong, readonly) UILabel *titleLabel;
@property(nonatomic, strong, readonly) UILabel *subTitleLabel;

@property(nonatomic) UIEdgeInsets insets;

@property(nonatomic) UIPopoverArrowDirection preferredArrowDirection;
@property(nonatomic) CGSize maximumContentSize;

-(void)showAtView:(UIView *)view insideParentView:(UIView *)parentView;
-(void)showAtView:(UIView *)view insideParentView:(UIView *)parentView dismissAfter:(NSTimeInterval)timeInterval;
-(void)dismissAfter:(NSTimeInterval)timeInterval;

@end
