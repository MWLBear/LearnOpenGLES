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

- (IBAction) OnShoulderSliderValueChanged:(id)sender;
- (IBAction) OnElbowSliderValueChanged:(id)sender;
- (IBAction) OnRotateButtonClick:(id)sender;

@end

