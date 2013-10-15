//
//  UIPanNavigationController.h
//  CoolPop
//
//  Created by luo lisheng on 13-9-13.
//  Copyright (c) 2013年 ryan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPanNavigationController : UINavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController addPanGesture:(BOOL)gesture;
- (void)pushViewController:(UIViewController *)viewController effect:(BOOL)effect;
- (void)popViewControllerWithEffect:(BOOL)effect;

@end
