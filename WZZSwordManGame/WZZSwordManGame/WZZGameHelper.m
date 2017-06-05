//
//  WZZGameHelper.m
//  WZZCutFruitGame
//
//  Created by 舞蹈圈 on 17/3/7.
//  Copyright © 2017年 wzz. All rights reserved.
//

#import "WZZGameHelper.h"

static WZZGameHelper * hhh;

@implementation WZZGameHelper

+ (instancetype)helper {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hhh = [[WZZGameHelper alloc] init];
        hhh.score = 0;
        hhh.lastScore = 0;
        hhh.highScore = 0;
        hhh.lives = 3;
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        hhh.score = [defaults integerForKey:@"lastScore"];
        hhh.highScore = [defaults integerForKey:@"highScore"];
        hhh.sounds = [NSMutableDictionary dictionary];
        
        [hhh initHUD];
    });
    return hhh;
}

- (void)initHUD {
    SKScene * skScene = [SKScene sceneWithSize:CGSizeMake(500, 100)];
    [skScene setBackgroundColor:[UIColor colorWithWhite:0 alpha:0]];
    _labelNode = [SKLabelNode labelNodeWithFontNamed:@"Menlo-Bold"];
    _labelNode.fontSize = 48;
    _labelNode.position = CGPointMake(250, 50);
    
    [skScene addChild:_labelNode];
    SCNPlane * plane = [SCNPlane planeWithWidth:5 height:1];
    SCNMaterial * material = [SCNMaterial material];
    material.lightingModelName = SCNLightingModelConstant;
    material.doubleSided = YES;
    material.diffuse.contents = skScene;
    plane.materials = @[material];
    
    _hudNode = [SCNNode nodeWithGeometry:plane];
    _hudNode.name = @"HUD";
    _hudNode.rotation = SCNVector4Make(1, 0, 0, 3.14159265);
}

- (void)updateHUD {
    NSString * scoreFormatted = [NSString stringWithFormat:@"%0004ld", _score];
    NSString * highScoreFormatted = [NSString stringWithFormat:@"%0004ld", _highScore];
    _labelNode.text = [NSString stringWithFormat:@"❤️%@  😎x%@  💥x%@", @(_lives), scoreFormatted, highScoreFormatted];
}

- (void)loadSound:(NSString *)name fileName:(NSString *)fileName {
    SCNAudioSource * sound = [SCNAudioSource audioSourceNamed:fileName];
    [sound load];
    _sounds[name] = sound;
}

- (void)playSoundNode:(SCNNode *)node name:(NSString *)name {
    [node runAction:[SCNAction playAudioSource:_sounds[name] waitForCompletion:NO]];
}

- (void)reset {
    _score = 0;
    _lives = 0;
}

- (void)shakeNode:(SCNNode *)node {
    SCNAction * left = [SCNAction moveBy:SCNVector3Make(-0.2, 0, 0) duration:0.05];
    SCNAction * right = [SCNAction moveBy:SCNVector3Make(0.2, 0, 0) duration:0.05];
    SCNAction * up = [SCNAction moveBy:SCNVector3Make(0, 0.2, 0) duration:0.05];
    SCNAction * down = [SCNAction moveBy:SCNVector3Make(0, -0.2, 0) duration:0.05];
    [node runAction:[SCNAction sequence:@[left, up, down, right, left, right, down, up, right, down, left, up,left, up, down, right, left, right, down, up, right, down, left, up]]];
}

#pragma mark - 计算
+ (double)doubleRandomWithMax:(double)max min:(double)min {
    return (float)(arc4random()%(int)(max-min)+min);
}

+ (float)floatRandomWithMax:(float)max min:(float)min {
    return (float)(arc4random()%(int)(max-min)+min);
}

+ (int)intRandomWithMax:(int)max min:(int)min {
    return arc4random()%(int)(max-min)+min;
}

+ (SCNAction *)waitForDurationThenRemoveFromParent:(NSTimeInterval)dur {
    SCNAction * wait = [SCNAction waitForDuration:dur];
    SCNAction * remove = [SCNAction removeFromParentNode];
    return [SCNAction sequence:@[wait, remove]];
}

+ (SCNAction *)waitForDuration:(NSTimeInterval)dur thenRunBlock:(void(^)(SCNNode *))aBlock {
    SCNAction * wait = [SCNAction waitForDuration:dur];
    SCNAction * ation = [SCNAction runBlock:^(SCNNode * _Nonnull node) {
        if (aBlock) {
            aBlock(node);
        }
    }];
    return [SCNAction sequence:@[wait, ation]];
}

+ (SCNAction *)rotateByXForever:(SCNVector3)v3 duration:(NSTimeInterval)dur {
    SCNAction * rotate = [SCNAction rotateByX:v3.x y:v3.y z:v3.z duration:dur];
    return [SCNAction repeatActionForever:rotate];
}

@end
