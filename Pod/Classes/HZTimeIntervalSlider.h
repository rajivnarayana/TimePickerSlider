//
//  HZTimeIntervalSlider.h
//  
//
//  Created by Hertz on 12/18/15.
//
//

#import <UIKit/UIKit.h>

@class HZTimeIntervalSlider;
@protocol HZTimeIntervalSliderDelegate <NSObject>

-(NSString *)textForIntervalValue:(CGFloat)value forSlider:(HZTimeIntervalSlider *)slider;

@end

@interface HZTimeIntervalSlider : UISlider

@property(nonatomic, unsafe_unretained) id<HZTimeIntervalSliderDelegate> delegate;
@property(nonatomic, strong) NSDictionary *textAttributes;

@property(nonatomic) UIEdgeInsets edgeInsets;
@property(nonatomic) CGFloat lineWidth;
@property(nonatomic) CGFloat cornerRadius;
@property(nonatomic) UIColor *fillColor;
@property(nonatomic) UIColor *strokeColor;

- (NSString *)textForIntervalValue:(CGFloat)value;

@end
