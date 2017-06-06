//
//  GameViewController.h
//  WZZCutFruitGame
//
//  Created by 舞蹈圈 on 17/3/6.
//  Copyright © 2017年 wzz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import "CardboardSDK.h"
#import "CBDViewController.h"
#define SIMMODE 1//模拟器模式，关闭纸盒

#if SIMMODE
@interface GameViewController : UIViewController
#else
@interface GameViewController : CBDViewController
#endif

@end
