//
//  ViewController.m
//  IPDFCameraViewController
//
//  Created by Maximilian Mackh on 11/01/15.
//  Copyright (c) 2015 Maximilian Mackh. All rights reserved.
//

#import "ViewController.h"

#import "IPDFCameraViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet IPDFCameraViewController *cameraViewController;
@property (weak, nonatomic) IBOutlet UIImageView *focusIndicator;
- (IBAction)focusGesture:(id)sender;

- (IBAction)captureButton:(id)sender;

@end

@implementation ViewController

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.cameraViewController setupCameraView];
    [self.cameraViewController setEnableBorderDetection:YES];
    [self updateTitleLabel];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.cameraViewController start];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark -
#pragma mark CameraVC Actions

- (IBAction)focusGesture:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized)
    {
        CGPoint location = [sender locationInView:self.cameraViewController];
        
        [self focusIndicatorAnimateToPoint:location];
        
        [self.cameraViewController focusAtPoint:location completionHandler:^
         {
             [self focusIndicatorAnimateToPoint:location];
         }];
    }
}

- (void)focusIndicatorAnimateToPoint:(CGPoint)targetPoint
{
    [self.focusIndicator setCenter:targetPoint];
    self.focusIndicator.alpha = 0.0;
    self.focusIndicator.hidden = NO;
    
    [UIView animateWithDuration:0.4 animations:^
     {
         self.focusIndicator.alpha = 1.0;
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.4 animations:^
          {
              self.focusIndicator.alpha = 0.0;
          }];
     }];
}

- (IBAction)borderDetectToggle:(id)sender
{
    BOOL enable = !self.cameraViewController.isBorderDetectionEnabled;
    [self changeButton:sender targetTitle:(enable) ? @"CROP On" : @"CROP Off" toStateEnabled:enable];
    self.cameraViewController.enableBorderDetection = enable;
    [self updateTitleLabel];
}

- (IBAction)filterToggle:(id)sender
{
    [self.cameraViewController setCameraViewType:(self.cameraViewController.cameraViewType == IPDFCameraViewTypeBlackAndWhite) ? IPDFCameraViewTypeNormal : IPDFCameraViewTypeBlackAndWhite];
    [self updateTitleLabel];
}

- (IBAction)torchToggle:(id)sender
{
    BOOL enable = !self.cameraViewController.isTorchEnabled;
    [self changeButton:sender targetTitle:(enable) ? @"FLASH On" : @"FLASH Off" toStateEnabled:enable];
    self.cameraViewController.enableTorch = enable;
}

- (void)updateTitleLabel
{
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    animation.duration = 0.35;
    [self.titleLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
    
    NSString *filterMode = (self.cameraViewController.cameraViewType == IPDFCameraViewTypeBlackAndWhite) ? @"TEXT FILTER" : @"COLOR FILTER";
    self.titleLabel.text = [filterMode stringByAppendingFormat:@" | %@",(self.cameraViewController.isBorderDetectionEnabled)?@"AUTOCROP On":@"AUTOCROP Off"];
}

- (void)changeButton:(UIButton *)button targetTitle:(NSString *)title toStateEnabled:(BOOL)enabled
{
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:(enabled) ? [UIColor colorWithRed:1 green:0.81 blue:0 alpha:1] : [UIColor whiteColor] forState:UIControlStateNormal];
}


#pragma mark -
#pragma mark CameraVC Capture Image

- (IBAction)captureButton:(id)sender
{
    [self.cameraViewController captureImageWithCompletionHander:^(id data)
    {
        UIImage *image = ([data isKindOfClass:[NSData class]]) ? [UIImage imageWithData:data] : data;
        NSLog(@"%@",image);
    }];
}

@end
