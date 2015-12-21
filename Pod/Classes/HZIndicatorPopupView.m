//
//  HZIndicatorPopupView.m
//  
//
//  Created by Hertz on 12/20/15.
//
//

#import "HZIndicatorPopupView.h"

@interface HZIndicatorPopupViewArrowView : UIView

@property (nonatomic) UIPopoverArrowDirection direction;
@property (nonatomic) CAShapeLayer *shapeLayer;

@end

@implementation HZIndicatorPopupViewArrowView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.
        self.shapeLayer = [[CAShapeLayer alloc] init];
        [self.layer addSublayer: self.shapeLayer];
    }
    return self;
}

-(void)setDirection:(UIPopoverArrowDirection)direction {
    _direction = direction;
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    switch (direction) {
        case UIPopoverArrowDirectionAny:
        case UIPopoverArrowDirectionDown:
        default:
            [bezierPath moveToPoint:CGPointMake(0, 0)];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds), 0)];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetHeight(self.bounds))];
            [bezierPath closePath];
            break;
    }
    self.shapeLayer.path = bezierPath.CGPath;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:[UIColor clearColor]];
    self.layer.backgroundColor = [UIColor clearColor].CGColor;
    self.shapeLayer.fillColor = backgroundColor.CGColor;
}

@end

@interface HZIndicatorPopupViewContentView : UIView

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *subTitleLabel;
@property(nonatomic) UIEdgeInsets insets;
@property(nonatomic) UIPopoverArrowDirection preferredArrowDirection;
@property(nonatomic) CGSize maximumContentSize;

@end

@implementation HZIndicatorPopupViewContentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.subTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.subTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.subTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:self.titleLabel];
        [self addSubview:self.subTitleLabel];
        self.insets = UIEdgeInsetsMake(5, 5, 5, 5);
        self.maximumContentSize = CGSizeMake(NSIntegerMax, NSIntegerMax);
    }
    return self;
}

-(void)setInsets:(UIEdgeInsets)insets {
    _insets = insets;
    [self removeConstraints:self.constraints];
    NSDictionary *viewsDictionary = @{@"titleLabel" : self.titleLabel, @"subTitleLabel": self.subTitleLabel};
    NSDictionary *metricsDictionary = @{@"top" : @(insets.top), @"bottom": @(insets.bottom), @"right": @(insets.right), @"left": @(insets.left)};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top-[titleLabel]-1-[subTitleLabel]-bottom-|" options:NSLayoutFormatAlignAllCenterX metrics:metricsDictionary views:viewsDictionary]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=left)-[titleLabel]-(>=right)-|" options:0 metrics:metricsDictionary views:viewsDictionary]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=left)-[subTitleLabel]-(>=right)-|" options:0 metrics:metricsDictionary views:viewsDictionary]];
}

@end

@interface HZIndicatorPopupView ()

@property(nonatomic, strong) HZIndicatorPopupViewContentView *contentView;
@property(nonatomic, strong) HZIndicatorPopupViewArrowView *arrowView;

@end

@implementation HZIndicatorPopupView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView = [[HZIndicatorPopupViewContentView alloc] initWithFrame:CGRectZero];
        self.contentView.layer.cornerRadius = 5.f;
        self.contentView.layer.shadowOffset = CGSizeMake(1, 2);
        self.contentView.layer.shadowRadius = 5.0;
        self.contentView.layer.shadowOpacity = 0.8;

        self.arrowView = [[HZIndicatorPopupViewArrowView alloc] initWithFrame:CGRectMake(0, 0, 20, 10)];
        
        self.arrowView.layer.shadowOffset = CGSizeMake(1, 3);
        self.arrowView.layer.shadowRadius = 3.0;
        self.arrowView.layer.shadowOpacity = 0.8;

        [self addSubview:self.contentView];
        [self addSubview:self.arrowView];
    }
    return self;
}

-(void)showAtView:(UIView *)view insideParentView:(UIView *)parentView {
    [self showAtView:view insideParentView:parentView dismissAfter:0];
}
-(void)showAtView:(UIView *)view insideParentView:(UIView *)parentView dismissAfter:(NSTimeInterval)timeInterval {
    [parentView addSubview:self];
    CGPoint targetPoint;
    if ([view isKindOfClass:[UISlider class]]) {
        UISlider *slider = (UISlider *)view;
        targetPoint = CGPointMake([self xPositionFromSliderValue:slider], slider.bounds.size.height/2 - slider.currentThumbImage.size.height/2);
    } else {
        if (self.preferredArrowDirection && UIPopoverArrowDirectionUp > 0) {
            targetPoint = CGPointMake(CGRectGetWidth(view.frame)/2, CGRectGetHeight(view.frame));
        }
        //TODO: Support left and right arrow directions
        targetPoint = CGPointMake(CGRectGetWidth(view.frame)/2, CGRectGetMinY(view.frame));
    }

    CGPoint pointToPosition = [view convertPoint:targetPoint toView:parentView];
    self.arrowView.direction = UIPopoverArrowDirectionDown;
    CGSize size = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    size.width = MIN(size.width, self.maximumContentSize.width);
    size.height = MIN(size.height, self.maximumContentSize.height);
    CGRect frame = CGRectMake(pointToPosition.x - size.width/2, pointToPosition.y - size.height - CGRectGetHeight(self.arrowView.frame) - 2, size.width, size.height + CGRectGetHeight(self.arrowView.frame));
    frame.origin.x = MIN(CGRectGetMinX(frame), CGRectGetWidth(parentView.bounds) - CGRectGetWidth(frame));
    frame.origin.x = MAX(CGRectGetMinX(frame), 0);
    self.frame = frame;
    self.arrowView.center = CGPointMake(MAX(pointToPosition.x - CGRectGetMinX(frame), MIN(pointToPosition.x, size.width/2)), CGRectGetHeight(frame) - CGRectGetHeight(self.arrowView.frame)/2);
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissAnimated:) object:self];
    if (timeInterval > 0) {
        [self performSelector:@selector(dismissAnimated:) withObject:self afterDelay:timeInterval];
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.contentView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - CGRectGetHeight(self.arrowView.frame));
}

- (float)xPositionFromSliderValue:(UISlider *)aSlider {
    return (((aSlider.value - aSlider.minimumValue)/(aSlider.maximumValue - aSlider.minimumValue)) * (aSlider.frame.size.width - aSlider.currentThumbImage.size.width)) + aSlider.currentThumbImage.size.width/2;
}

-(void)dismissAfter:(NSTimeInterval)timeInterval {
    [self performSelector:@selector(dismissAnimated:) withObject:self afterDelay:timeInterval];
}

-(void)dismissAnimated:(BOOL)animated {
    [self removeFromSuperview];
}

-(void)setMaximumContentSize:(CGSize)maximumContentSize {
    _maximumContentSize = maximumContentSize;
}

-(UILabel *)titleLabel {
    return self.contentView.titleLabel;
}

-(UILabel *)subTitleLabel {
    return self.contentView.subTitleLabel;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:[UIColor clearColor]];
    self.arrowView.backgroundColor = backgroundColor;
    self.contentView.backgroundColor = backgroundColor;
}

-(void)setInsets:(UIEdgeInsets)insets {
    self.contentView.insets = insets;
}

-(UIEdgeInsets)insets {
    return self.contentView.insets;
}

@end
