//
//  ViewController.h
//  demo-3D变换实践
//
//  Created by lz on 2018/8/26.
//  Copyright © 2018 lz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet OpenGLView *openview;
@property (weak, nonatomic) IBOutlet UIView *controlView;


@property (weak, nonatomic) IBOutlet UISlider *posXslider;
@property (weak, nonatomic) IBOutlet UISlider *postYsolider;
@property (weak, nonatomic) IBOutlet UISlider *posZslider;
@property (weak, nonatomic) IBOutlet UISlider *RoteXsilder;
@property (weak, nonatomic) IBOutlet UISlider *sacleZslider;



- (IBAction)xSliderValueChanag:(id)sender;
- (IBAction)ySliderValueChange:(id)sender;
- (IBAction)zSliderValueChange:(id)sender;
- (IBAction)rotexSliderVauleChange:(id)sender;
- (IBAction)scalezSliderValueChange:(id)sender;



- (IBAction)resetBtnClick:(id)sender;
- (IBAction)autoBtnClick:(id)sender;
@end

