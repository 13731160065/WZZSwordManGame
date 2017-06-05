//
//  WZZGameHelper.h
//  WZZCutFruitGame
//
//  Created by 舞蹈圈 on 17/3/7.
//  Copyright © 2017年 wzz. All rights reserved.
//

#import <Foundation/Foundation.h>
@import SceneKit;
@import SpriteKit;

typedef enum {
    Playing,
    TapToPlay,
    GameOver
}GameStateType;

@interface WZZGameHelper : NSObject

@property (assign, nonatomic) NSInteger score;
@property (assign, nonatomic) NSInteger highScore;
@property (assign, nonatomic) NSInteger lastScore;
@property (assign, nonatomic) NSInteger lives;
@property (assign, nonatomic) GameStateType state;
@property (strong, nonatomic) SCNNode * hudNode;
@property (strong, nonatomic) SKLabelNode * labelNode;
@property (strong, nonatomic) NSMutableDictionary * sounds;

+ (instancetype)helper;

- (void)updateHUD;

- (void)loadSound:(NSString *)name fileName:(NSString *)fileName;

- (void)playSoundNode:(SCNNode *)node name:(NSString *)name;

- (void)reset;

- (void)shakeNode:(SCNNode *)node;

#pragma mark - 计算
+ (double)doubleRandomWithMax:(double)max min:(double)min;
+ (float)floatRandomWithMax:(float)max min:(float)min;
+ (int)intRandomWithMax:(int)max min:(int)min;

+ (SCNAction *)waitForDurationThenRemoveFromParent:(NSTimeInterval)dur;
+ (SCNAction *)waitForDuration:(NSTimeInterval)dur thenRunBlock:(void(^)(SCNNode *))aBlock;
+ (SCNAction *)rotateByXForever:(SCNVector3)v3 duration:(NSTimeInterval)dur;

@end
