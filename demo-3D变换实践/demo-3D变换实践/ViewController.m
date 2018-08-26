//
//  ViewController.m
//  demo-3D变换实践
//
//  Created by lz on 2018/8/26.
//  Copyright © 2018 lz. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController


-(void)viewDidUnload{
    [super viewDidUnload];
    
    [self.openview cleanup];
    self.openview = nil;
    
    self.posXslider = nil;
    self.posZslider = nil;
    self.postYsolider = nil;
    self.sacleZslider = nil;
    self.RoteXsilder = nil;
    self.controlView = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self resetControls];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
- (void)resetControls
{
    [self.posXslider setValue:self.openview.posX];
    [self.postYsolider setValue:self.openview.posY];
    [self.posZslider setValue:self.openview.posZ];
    
    [self.sacleZslider setValue:self.openview.scaleZ];
    [self.RoteXsilder setValue:self.openview.rotateX];
}

- (IBAction)xSliderValueChanag:(id)sender {
    UISlider * slider = (UISlider *)sender;
    float currentValue = [slider value];
    
    self.openview.posX = currentValue;
}

- (IBAction)ySliderValueChange:(id)sender {
    UISlider * slider = (UISlider *)sender;
    float currentValue = [slider value];
    self.openview.posY = currentValue;
    NSLog(@" >> current y is %f", currentValue);
}


- (IBAction)zSliderValueChange:(id)sender {
    UISlider * slider = (UISlider *)sender;
    float currentValue = [slider value];
    
    self.openview.posZ = currentValue;
    
    NSLog(@" >> current z is %f", currentValue);
}

- (IBAction)rotexSliderVauleChange:(id)sender {
    UISlider * slider = (UISlider *)sender;
    float currentValue = [slider value];
    
    self.openview.rotateX = currentValue;
    
    NSLog(@" >> current x rotation is %f", currentValue);  
}

- (IBAction)scalezSliderValueChange:(id)sender {
    UISlider * slider = (UISlider *)sender;
    float currentValue = [slider value];
    
    self.openview.scaleZ = currentValue;
    
    NSLog(@" >> current z scale is %f", currentValue);
}

- (IBAction)resetBtnClick:(id)sender {
    [self.openview resetTransform];
    [self.openview render];
    
    [self resetControls];
}

- (IBAction)autoBtnClick:(id)sender {
    [_openview toggleDisplayLink];
    
    UIButton * button = (UIButton *)sender;
    NSString * text = button.titleLabel.text;
    if ([text isEqualToString:@"Auto"]) {
        [button setTitle: @"Stop" forState: UIControlStateNormal];
    }
    else {
        [button setTitle: @"Auto" forState: UIControlStateNormal];
    }
}
@end
