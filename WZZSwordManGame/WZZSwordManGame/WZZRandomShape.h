//
//  WZZRandomShape.h
//  WZZCutFruitGame
//
//  Created by 舞蹈圈 on 17/3/7.
//  Copyright © 2017年 wzz. All rights reserved.
//

#import <Foundation/Foundation.h>
@import SceneKit;

typedef enum {
    RSHAPE_Box = 0,
    RSHAPE_Sphere,
    RSHAPE_Pyramid,
    RSHAPE_Torus,
    RSHAPE_Capsule,
    RSHAPE_Cylinder,
    RSHAPE_Cone,
    RSHAPE_Tube//空心圆
}RSHAPE;

@interface WZZRandomShape : NSObject

+ (RSHAPE)randomShape;

@end
