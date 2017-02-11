//
//  AppDelegate.h
//  tubedo
//
//  Created by vm mac on 06/05/16.
//  Copyright © 2016 Julio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegateC : UIApplication <UIApplicationDelegate> {
    UIWindow *_window;
    UIViewController *_viewController;
}
@property (nonatomic, retain) UIWindow *window;
@end
