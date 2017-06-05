//
//  WZZRandomShape.m
//  WZZCutFruitGame
//
//  Created by 舞蹈圈 on 17/3/7.
//  Copyright © 2017年 wzz. All rights reserved.
//

#import "WZZRandomShape.h"

@implementation WZZRandomShape

+ (RSHAPE)randomShape {
    int maxValue = RSHAPE_Tube+1;
    return arc4random()%maxValue;
}

@end
