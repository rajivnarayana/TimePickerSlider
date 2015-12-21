//
//  HZTimeIntervalSlider.m
//  
//
//  Created by Hertz on 12/18/15.
//
//

#import "HZTimeIntervalSlider.h"

//#ifdef DEBUG
#    define ALog(...) NSLog(__VA_ARGS__)
//#else
#    define DLog(...) /* */
//#endif

@interface HZTimeIntervalSlider()

@property(nonatomic) CGFloat intrinsicHeight;
@property(nonatomic) CGPoint shadowOffset;
@property(nonatomic) CGFloat shadowBlurRadius;
@property(nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation HZTimeIntervalSlider

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"h:mm a"];
        self.dateFormatter = dateFormatter;
        self.dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        self.maximumValue = 47;
        self.lineWidth = 2.f;
        self.fillColor = [UIColor grayColor];
        self.strokeColor = [UIColor whiteColor];
        self.shadowOffset = CGPointMake(0, 2.0);
        self.shadowBlurRadius = 3.5f;
        self.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        self.textAttributes = @{NSForegroundColorAttributeName : self.strokeColor, NSFontAttributeName: [UIFont boldSystemFontOfSize:12.f] };
        self.cornerRadius = 5.f;
        self.continuous = YES;
        [self performSelector:@selector(updateThumbImage) withObject:nil afterDelay:0];
        [self addTarget:self action:@selector(updateThumbImage) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    CGRect parentThumbRect = [super thumbRectForBounds:bounds trackRect:rect value:value];
    if (parentThumbRect.size.height > 0) {
        self.intrinsicHeight = parentThumbRect.size.height;
    }
    
    if (self.state != UIControlStateNormal) {
        return parentThumbRect;
    }

    DLog(@"Parent rect: %@", NSStringFromCGRect(parentThumbRect));
    NSString *text = [self textForIntervalValue:value];
    CGSize size = [text sizeWithAttributes:self.textAttributes];
    DLog(@"Size :%@", NSStringFromCGSize(size));
    CGSize paddedSize = CGSizeMake(size.width + self.edgeInsets.left + self.edgeInsets.right, size.height + self.edgeInsets.top + self.edgeInsets.bottom);
    CGPoint center = CGPointMake(CGRectGetWidth(rect) * value/ self.maximumValue, CGRectGetMidY(parentThumbRect));
    CGFloat x = center.x * (CGRectGetWidth(rect) + 5 - paddedSize.width)/ CGRectGetWidth(rect);
    CGRect newRect = CGRectMake(x, CGRectGetMinY(parentThumbRect), paddedSize.width, CGRectGetHeight(parentThumbRect));
    DLog(@"New rect: %@", NSStringFromCGRect(newRect));
    return newRect;
}

- (void)updateThumbImage {
    CGRect intrinsicRect = CGRectMake(0, 0, self.intrinsicHeight, self.intrinsicHeight);
    CGRect drawingRect = CGRectInset(intrinsicRect, self.shadowOffset.y, self.shadowOffset.y);
    drawingRect = CGRectOffset(drawingRect, 0.f, -(self.shadowBlurRadius - self.shadowOffset.y));
    CGContextRef context;
    
    //circle thumb for highlighted state : UIControlStateHighlighted
    UIGraphicsBeginImageContextWithOptions(intrinsicRect.size, NO, [UIScreen mainScreen].scale);
    context = UIGraphicsGetCurrentContext();
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGContextAddEllipseInRect(context, drawingRect);
    CGContextSetShadow(context, CGSizeMake(self.shadowOffset.x, self.shadowOffset.y), self.shadowBlurRadius);
    CGContextAddPath(context, pathRef);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillPath(context);
    UIImage *imageFromContext = UIGraphicsGetImageFromCurrentImageContext();
    [self setThumbImage:imageFromContext forState:UIControlStateHighlighted];
    CGPathRelease(pathRef);
    UIGraphicsEndImageContext();
    
    //rounded rect for normal state : UIControlStateNormal
    NSString *text = [self textForIntervalValue:self.value];
    CGSize size = [text sizeWithAttributes:self.textAttributes];
    CGSize paddedTextSize = CGSizeMake(size.width + self.edgeInsets.left + self.edgeInsets.right, size.height + self.edgeInsets.top + self.edgeInsets.bottom);
    intrinsicRect = CGRectMake(0, 0, paddedTextSize.width, intrinsicRect.size.height);
    drawingRect = CGRectInset(intrinsicRect, self.shadowOffset.y, self.shadowOffset.y);
    drawingRect = CGRectOffset(drawingRect, 0.f, -(self.shadowBlurRadius - self.shadowOffset.y));
    UIGraphicsBeginImageContextWithOptions(intrinsicRect.size, NO, [UIScreen mainScreen].scale);
    context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, self.lineWidth);
    pathRef = CGPathCreateMutable();
    CGPathAddRoundedRect(pathRef, nil, CGRectInset(drawingRect, self.lineWidth/2, self.lineWidth), self.cornerRadius, self.cornerRadius);
    CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
    CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
    CGPathRef pathCopyRef = CGPathCreateCopy(pathRef);
    CGContextSaveGState(context);
    {
        CGContextSetShadow(context, CGSizeMake(self.shadowOffset.x, self.shadowOffset.y), self.shadowBlurRadius);
        CGPathRef rectPath = CGPathCreateWithRect(CGRectMake(0, 0, intrinsicRect.size.width, intrinsicRect.size.height), NULL);
        CGContextAddPath(context, rectPath);
        CGContextAddPath(context, pathCopyRef);
        CGContextClip(context);
        // Now draw the path in the clipped context
        CGContextAddPath(context, pathCopyRef);
        CGContextDrawPath(context, kCGPathStroke);
    }
    CGContextRestoreGState(context);
    CGContextAddPath(context, pathRef);
    CGContextDrawPath(context, kCGPathFillStroke);
    CGPoint textLocation = CGPointMake(self.edgeInsets.left, intrinsicRect.size.height/2 - paddedTextSize.height/2 - self.shadowOffset.y);
    [text drawAtPoint:textLocation withAttributes:self.textAttributes];
//    [text drawInRect:drawingRect withAttributes:self.textAttributes];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    DLog(@"image: %@, text: %@", NSStringFromCGSize(image.size), NSStringFromCGSize(paddedTextSize));
    [self setThumbImage:image forState:UIControlStateNormal];
    CGPathRelease(pathRef);
    UIGraphicsEndImageContext();
}

- (NSString *)textForIntervalValue:(CGFloat)value {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textForIntervalValue:forSlider:)]) {
        return [self.delegate textForIntervalValue:value forSlider:self];
    }
    return [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:floor(value) * 30 * 60.f]];
}
@end
