//
//  UIPanNavigationController.m
//  CoolPop
//
//  Created by luo lisheng on 13-9-13.
//  Copyright (c) 2013年 ryan. All rights reserved.
//

#import "UIPanNavigationController.h"
#import <QuartzCore/QuartzCore.h>

#define PREVPAGE_SCALE .95f
#define PREVPAGE_ALPHA .5f

#define PREVPAGE_TAG 10001

#define ANIMATE_DURATION .3f
#define BACK_DURATION .2f

#define GRAG_MAXIMUM 100

#define KEYWINDOW [[UIApplication sharedApplication] keyWindow]
#define KEYWINDOW_BOUNDS [[UIApplication sharedApplication] keyWindow].bounds

@interface UIPanNavigationController ()

@property(nonatomic, strong)NSMutableArray *screenShots;

@end

@implementation UIPanNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
                   addPanGesture:(BOOL)gesture
{
    self = [self initWithRootViewController:rootViewController];
    if (self) {
        _screenShots = [[NSMutableArray alloc] init];
        if (gesture) {
            UIPanGestureRecognizer *panGestureRecognizer =
            [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(handlePanGesture:)];
            panGestureRecognizer.maximumNumberOfTouches = 1;
            [self.view addGestureRecognizer:panGestureRecognizer];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer{
    if (self.viewControllers.count <= 1) {
        return;
    }
    UIView * prevPageView = [KEYWINDOW viewWithTag:PREVPAGE_TAG];
    if (!prevPageView) {
        prevPageView = [self.screenShots lastObject];
        prevPageView.alpha = PREVPAGE_ALPHA;
        [prevPageView setTransform:CGAffineTransformMakeScale(PREVPAGE_SCALE, PREVPAGE_SCALE)];
        [KEYWINDOW insertSubview:prevPageView atIndex:0];
    }
    CGPoint translation = [panGestureRecognizer translationInView:self.view];
    if (translation.x > 0) {
        [self.view setTransform:CGAffineTransformMakeTranslation(translation.x, 0)];
        double alpha =
            MIN(1.0f, PREVPAGE_ALPHA + translation.x/CGRectGetWidth(KEYWINDOW_BOUNDS)*(1-PREVPAGE_ALPHA));
        prevPageView.alpha = alpha;
        double scale =
            MIN(1.0f, PREVPAGE_SCALE + translation.x/CGRectGetWidth(KEYWINDOW_BOUNDS)*(1-PREVPAGE_SCALE));
        [prevPageView setTransform:CGAffineTransformMakeScale(scale, scale)];
    }
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (translation.x > GRAG_MAXIMUM) {
            [self popViewControllerWithEffect:YES];
        } else {
            [UIView animateWithDuration:BACK_DURATION
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 [self.view setTransform:CGAffineTransformMakeTranslation(0, 0)];
                                 prevPageView.alpha = PREVPAGE_ALPHA;
                                 [prevPageView setTransform:CGAffineTransformMakeScale(PREVPAGE_SCALE, PREVPAGE_SCALE)];
                             }
                             completion:^(BOOL finished){
                                 //[prevPageView removeFromSuperview];
                             }];
        }
    }
}

- (UIImage *)getPrevPageScreenShot{
    if (UIGraphicsBeginImageContextWithOptions) {
        UIGraphicsBeginImageContextWithOptions(KEYWINDOW_BOUNDS.size, NO, 0.0);
    } else {
        UIGraphicsBeginImageContext(KEYWINDOW_BOUNDS.size);
    }
    [KEYWINDOW.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}

- (void)pushViewController:(UIViewController *)viewController effect:(BOOL)effect{
    UIView *prevPageView = [KEYWINDOW viewWithTag:PREVPAGE_TAG];
    if (prevPageView) {
        [prevPageView removeFromSuperview];
    }
    prevPageView = [[UIImageView alloc] initWithImage:[self getPrevPageScreenShot]];
    prevPageView.tag = PREVPAGE_TAG;
    
    [self.screenShots addObject:prevPageView];
    
    [KEYWINDOW insertSubview:prevPageView atIndex:0];
    [self.view setTransform:CGAffineTransformMakeTranslation(CGRectGetWidth(KEYWINDOW_BOUNDS), 0)];
    [super pushViewController:viewController animated:NO];
    [UIView animateWithDuration:ANIMATE_DURATION
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.view setTransform:CGAffineTransformMakeTranslation(0, 0)];
                         if (effect) {
                             prevPageView.alpha = PREVPAGE_ALPHA;
                             [prevPageView setTransform:CGAffineTransformMakeScale(PREVPAGE_SCALE, PREVPAGE_SCALE)];
                         }
                     }
                     completion:^(BOOL finished){
                     }];
}

- (void)popViewControllerWithEffect:(BOOL)effect{
    if (self.viewControllers.count <= 1) {
        return;
    }
    UIView *prevPageView = [KEYWINDOW viewWithTag:PREVPAGE_TAG];
    if (!prevPageView) {
        prevPageView = [self.screenShots lastObject];
        if (effect) {
            prevPageView.alpha = PREVPAGE_ALPHA;
            [prevPageView setTransform:CGAffineTransformMakeScale(PREVPAGE_SCALE, PREVPAGE_SCALE)];
        }
        [KEYWINDOW insertSubview:prevPageView atIndex:0];
    }
    [UIView animateWithDuration:ANIMATE_DURATION
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.view setTransform:CGAffineTransformMakeTranslation(CGRectGetWidth(KEYWINDOW_BOUNDS), 0)];
                         prevPageView.alpha = 1.0f;
                         [prevPageView setTransform:CGAffineTransformMakeScale(1.0f, 1.0f)];
                     }
                     completion:^(BOOL finished){
                         [super popViewControllerAnimated:NO];
                         [self.view setTransform:CGAffineTransformMakeTranslation(0, 0)];
                         [prevPageView removeFromSuperview];
                         [self.screenShots removeLastObject];
                     }];
}

@end
