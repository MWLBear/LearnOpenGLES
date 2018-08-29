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
    
   
    self.controlView = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void) OnShoulderSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float currentValue = [slider value];
    
    NSLog(@" >> current shoulder is %f", currentValue);
    
    self.openview.rotateShoulder = currentValue;
}

- (void) OnElbowSliderValueChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    float currentValue = [slider value];
    
    NSLog(@" >> current elbow is %f", currentValue);
    
    self.openview.rotateElbow = currentValue;
}

- (IBAction) OnRotateButtonClick:(id)sender
{
    [self.openview toggleDisplayLink];
    
    UIButton * button = (UIButton *)sender;
    NSString * text = button.titleLabel.text;
    if ([text isEqualToString:@"Rotate"]) {
        [button setTitle: @"Stop" forState: UIControlStateNormal];
    }
    else {
        [button setTitle: @"Rotate" forState: UIControlStateNormal];
    }
}

@end
