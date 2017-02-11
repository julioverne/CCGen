//
//  AppDelegate.m
//  tubedo
//
//  Created by vm mac on 06/05/16.
//  Copyright © 2016 Julio. All rights reserved.
//

#import "AppDelegate.h"
#import <objc/runtime.h>

@implementation AppDelegateC
@synthesize window = _window;
- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _viewController = [[UINavigationController alloc] initWithRootViewController:[[objc_getClass("ViewControllerC") alloc] init]];
    [_window addSubview:_viewController.view];
    _window.rootViewController = _viewController;
    [_window makeKeyAndVisible];
}
@end
