//
//  HZViewController.m
//  TimePickerSlider
//
//  Created by Rajiv Narayana on 12/21/2015.
//  Copyright (c) 2015 Rajiv Narayana. All rights reserved.
//

#import "HZViewController.h"
#import <TimePickerSlider/HZTimeIntervalSlider.h>
#import <TimePickerSlider/HZIndicatorPopupView.h>

@interface HZViewController ()

@property (nonatomic, strong) HZIndicatorPopupView *toolTipView;

@end

@implementation HZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    HZTimeIntervalSlider *slider = [[HZTimeIntervalSlider alloc] initWithFrame:CGRectMake(20, 100, self.view.bounds.size.width- 20, 50)];
    [self.view addSubview:slider];
    
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.toolTipView = [[HZIndicatorPopupView alloc] initWithFrame:CGRectZero];
    self.toolTipView.titleLabel.font = [UIFont systemFontOfSize:14.f];
    self.toolTipView.titleLabel.textColor = [UIColor whiteColor];
    self.toolTipView.maximumContentSize = CGSizeMake(200, 200);
    self.toolTipView.backgroundColor= [UIColor blueColor];
}

-(void)sliderValueChanged:(UISlider *)slider {
    self.toolTipView.titleLabel.text = [(HZTimeIntervalSlider *)slider textForIntervalValue:slider.value];
//        self.toolTipView.subTitleLabel.text = @"Pickup time";
    [self.toolTipView showAtView:slider insideParentView:self.view dismissAfter:slider.tracking ? 0 : 0.01];
}

@end
