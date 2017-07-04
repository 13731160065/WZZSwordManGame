//
//  GameViewController.m
//  WZZCutFruitGame
//
//  Created by 舞蹈圈 on 17/3/6.
//  Copyright © 2017年 wzz. All rights reserved.
//

#import "GameViewController.h"
#import "WZZRandomShape.h"
#import "WZZGameHelper.h"
#import "WZZWatchConnectionPhoneManager.h"
#import "WZZSocketManager.h"

@import SceneKit;

#define SHOWDEBUGINFO 0

@interface GameViewController ()<SCNSceneRendererDelegate, CBDStereoRendererDelegate>
{
    SCNView * mainView;
    SCNScene * mainScene;
    SCNNode * cameraNode;
    SCNNode * cameraContral;
    SCNNode * geoNode;
    NSTimeInterval mainTime;
    SCNRenderer *_renderer;
    NSTimer * testTimer;
    NSTimer * timeTimer;
    NSTimeInterval timee;
    WZZSocketServerManager * severManager;
    SCNNode * mySword;
    SCNNode * mySwordRen;
}

@end

@implementation GameViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
#if SIMMODE
        [self setup];
#else
        self.stereoRendererDelegate = self;
#endif
    }
    return self;
}

- (void)setup {
    [WZZWatchConnectionPhoneManager manager];
    
    //创建scn视图
    mainView = [[SCNView alloc] initWithFrame:self.view.bounds];
    
#if SIMMODE
    [self.view addSubview:mainView];
#endif
    
//    [self.view addSubview:mainView];//使用vr功能不能往上添加视图需要用vr里的glview
    mainView.playing = YES;
#if SHOWDEBUGINFO
    // 1
    mainView.showsStatistics = YES;
    // 2
    mainView.allowsCameraControl = YES;
    // 3
    mainView.autoenablesDefaultLighting = YES;
#endif
    
    //创建场景
    mainScene = [SCNScene scene];
    mainView.scene = mainScene;
    mainScene.background.contents = [UIColor blackColor];
    
    SCNNode * lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    [mainScene.rootNode addChildNode:lightNode];
    lightNode.position = SCNVector3Make(0, 50, 50);
    
    cameraContral = [SCNNode node];
    [mainScene.rootNode addChildNode:cameraContral];
    [cameraContral setPosition:SCNVector3Make(0, 5, 10)];
    //创建一个节点
    cameraNode = [SCNNode node];
    //设置节点的相机
    cameraNode.camera = [SCNCamera camera];
    //设置节点的位置
    cameraNode.position = SCNVector3Make(0, 0, 0);
    //将相机节点添加到场景的根节点上
    [cameraContral addChildNode:cameraNode];
    
    mainView.delegate = self;
    
    [self startSever];
    [self creatSword];
}

//创建我的剑
- (void)creatSword {
    //我的剑柄
    SCNCylinder * cy = [SCNCylinder cylinderWithRadius:0.2 height:2];
    cy.materials.firstObject.diffuse.contents = [UIColor yellowColor];
    
    mySword = [SCNNode nodeWithGeometry:cy];
#if SIMMODE
    mySword.position = SCNVector3Make(0, 4, -5);
#else
    mySword.position = SCNVector3Make(0, 0, 0);
#endif
    mySword.eulerAngles = SCNVector3Make(0, 0, 0);
    [mainScene.rootNode addChildNode:mySword];
    
    //我的剑刃
    SCNCylinder * cyRen = [SCNCylinder cylinderWithRadius:0.2 height:8];
    cyRen.materials.firstObject.diffuse.contents = [UIColor cyanColor];
    mySwordRen = [SCNNode nodeWithGeometry:cyRen];
    mySwordRen.position = SCNVector3Make(0, 5, 0);
    mySwordRen.eulerAngles = SCNVector3Make(0, 0, 0);
    [mySword addChildNode:mySwordRen];
}

//开启接收socket服务器
- (void)startSever {
    severManager = [WZZSocketServerManager sharedServerManager];
    NSLog(@"ip:%@", severManager.localIP);
    [severManager creatServerWithPort:@"38080" timeOut:-1 handleData:^(NSData *data) {
        NSString * jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary * dic = [self objectFromJsonString:jsonStr];
        if (dic) {
            NSLog(@"--->%@", jsonStr);
            NSLog(@"--->%@", dic);
            CGFloat x = [dic[@"xyz"][@"x"] floatValue];
            CGFloat y = [dic[@"xyz"][@"y"] floatValue];
            CGFloat z = [dic[@"xyz"][@"z"] floatValue];
            mySword.eulerAngles = SCNVector3Make(x, y, z);
            
            CGFloat xx = [dic[@"a"][@"x"] floatValue];
            CGFloat yy = [dic[@"a"][@"y"] floatValue];
            CGFloat zz = [dic[@"a"][@"z"] floatValue];
            mySword.position = SCNVector3Make(xx, yy, zz);
        }
    }];
}

//json字符串转对象
- (id)objectFromJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id obj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return obj;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (touches.count == 3) {
        [geoNode removeFromParentNode];
        [self spawnShape];
        
    }
}

- (void)makePosi {
    
    SCNBox * kx = [SCNBox boxWithWidth:0.4 height:0.4 length:0.4 chamferRadius:0];
    SCNBox * ky = [SCNBox boxWithWidth:0.4 height:0.4 length:0.4 chamferRadius:0];
    SCNBox * kz = [SCNBox boxWithWidth:0.4 height:0.4 length:0.4 chamferRadius:0];
    
    kx.materials.firstObject.diffuse.contents = [UIColor redColor];
    ky.materials.firstObject.diffuse.contents = [UIColor yellowColor];
    kz.materials.firstObject.diffuse.contents = [UIColor greenColor];
    
    SCNNode * knx = [SCNNode nodeWithGeometry:kx];
    SCNNode * kny = [SCNNode nodeWithGeometry:ky];
    SCNNode * knz = [SCNNode nodeWithGeometry:kz];
    
    knx.position = SCNVector3Make(1, 0, 0);
    kny.position = SCNVector3Make(0, 1, 0);
    knz.position = SCNVector3Make(0, 0, 1);
    
    [mainScene.rootNode addChildNode:knx];
    [mainScene.rootNode addChildNode:kny];
    [mainScene.rootNode addChildNode:knz];
    
    SCNCylinder * cx = [SCNCylinder cylinderWithRadius:0.2 height:10];
    SCNCylinder * cy = [SCNCylinder cylinderWithRadius:0.2 height:10];
    SCNCylinder * cz = [SCNCylinder cylinderWithRadius:0.2 height:10];
    
    cx.materials.firstObject.diffuse.contents = [UIColor redColor];
    cy.materials.firstObject.diffuse.contents = [UIColor yellowColor];
    cz.materials.firstObject.diffuse.contents = [UIColor greenColor];
    
    SCNNode * nx = [SCNNode nodeWithGeometry:cx];
    SCNNode * ny = [SCNNode nodeWithGeometry:cy];
    SCNNode * nz = [SCNNode nodeWithGeometry:cz];
    
    nx.position = SCNVector3Make(0, 0, 0);
    ny.position = SCNVector3Make(0, 0, 0);
    nz.position = SCNVector3Make(0, 0, 0);
    
    nx.eulerAngles = SCNVector3Make(0, 0, M_PI_2);
    ny.eulerAngles = SCNVector3Make(0, 0, 0);
    nz.eulerAngles = SCNVector3Make(M_PI_2, 0, 0);
    
    [mainScene.rootNode addChildNode:nx];
    [mainScene.rootNode addChildNode:ny];
    [mainScene.rootNode addChildNode:nz];
}

- (void)spawnShape {
    SCNGeometry * geo;
    switch ([WZZRandomShape randomShape]) {
        case RSHAPE_Tube:
        {
            geo = [SCNTube tubeWithInnerRadius:1 outerRadius:2 height:1];
//            NSLog(@"tube/空心圆柱体");
        }
            break;
        case RSHAPE_Cone:
        {
            geo = [SCNCone coneWithTopRadius:1 bottomRadius:2 height:1];
//            NSLog(@"cone/圆台");
        }
            break;
        case RSHAPE_Torus:
        {
            geo = [SCNTorus torusWithRingRadius:1 pipeRadius:1];
//            NSLog(@"torus/甜甜圈");
        }
            break;
        case RSHAPE_Sphere:
        {
            geo = [SCNSphere sphereWithRadius:1];
//            NSLog(@"sphere/球");
        }
            break;
        case RSHAPE_Capsule:
        {
            geo = [SCNCapsule capsuleWithCapRadius:0.5 height:2];
//            NSLog(@"capsule/胶囊");
        }
            break;
        case RSHAPE_Pyramid:
        {
            geo = [SCNPyramid pyramidWithWidth:1 height:1 length:1];
//            NSLog(@"pyamid/4凌锥");
        }
            break;
        case RSHAPE_Cylinder:
        {
            geo = [SCNCylinder cylinderWithRadius:1 height:1];
//            NSLog(@"cylinder/圆柱体");
        }
            break;
        default:
        {
            geo = [SCNBox boxWithWidth:1 height:1 length:1 chamferRadius:0];
        }
            break;
    }
    
    CGFloat red = arc4random()%256/255.0f;
    CGFloat green = arc4random()%256/255.0f;
    CGFloat blue = arc4random()%256/255.0f;
    geo.materials.firstObject.diffuse.contents = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
    geoNode = [SCNNode nodeWithGeometry:geo];
    geoNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeDynamic shape:nil];
    [mainScene.rootNode addChildNode:geoNode];
    
    float randomX = [WZZGameHelper floatRandomWithMax:2 min:-2];
    float randomY = [WZZGameHelper floatRandomWithMax:18 min:10];
//    NSLog(@"%f, %f", randomX, randomY);
    SCNVector3 force = SCNVector3Make(randomX, randomY, 0);
    SCNVector3 posi = SCNVector3Make(0.05, 0.05, 0.05);
    [geoNode.physicsBody applyForce:force atPosition:posi impulse:YES];
    
//    [geoNode.physicsBody applyTorque:SCNVector4Make(0, 0, 3, 0) impulse:YES];
}

- (void)cleanScene {
    [mainScene.rootNode.childNodes enumerateObjectsUsingBlock:^(SCNNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.position.y < -2) {
            [obj removeFromParentNode];
        }
    }];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - 渲染循环代理
//渲染循环刚开始
- (void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time {
    if (time > mainTime) {//每隔多少秒一次
        [self spawnShape];
        mainTime = time+(NSTimeInterval)([WZZGameHelper floatRandomWithMax:3 min:1]);
    }
    [self cleanScene];//清除超出屏幕的node
}

#pragma mark - 纸盒代理
- (void)setupRendererWithView:(GLKView *)glView {
    [EAGLContext setCurrentContext:glView.context];
    glClearColor(0.25f, 0.25f, 0.25f, 1.0f);
    
    [self setup];
    
#if SHOWDEBUGINFO
    [self makePosi];
#endif
    
    _renderer = [SCNRenderer rendererWithContext:glView.context options:nil];
    _renderer.scene = mainScene;
    _renderer.pointOfView = cameraNode;
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//        SCNAction *cameraMoveAction = [SCNAction moveTo:SCNVector3Make(-4.5f, -4.5f, 0.0f) duration:10.0f];
//        cameraMoveAction.timingMode = SCNActionTimingModeEaseInEaseOut;
//        [cameraContral runAction:cameraMoveAction];
//    });
}
- (void)shutdownRendererWithView:(GLKView *)glView
{
    NSLog(@"shutdown");
}

- (void)renderViewDidChangeSize:(CGSize)size
{
    NSLog(@"changeSize");
}

- (void)prepareNewFrameWithHeadViewMatrix:(GLKMatrix4)headViewMatrix
{
    // Disable GL_SCISSOR_TEST here due to an issue that causes parts of the screen not to be cleared on some devices
    // GL_SCISSOR_TEST is enabled again after returning from this function so no need to re-enable here.
    glDisable(GL_SCISSOR_TEST);
    // Perform glClear() because using SpriteKit's SKScene as a texture in SceneKit interferes with GL_SCISSOR_TEST
    // If you move glClear() to the start of -drawEyeWithEye:, the left side of the screen is cleared when the right eye is drawn
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
//    NSLog(@"prepareHeadViewMatrix:\n%f, %f, %f, %f\n%f, %f, %f, %f\n%f, %f, %f, %f\n%f, %f, %f, %f", headViewMatrix.m[0], headViewMatrix.m[1], headViewMatrix.m[2], headViewMatrix.m[3], headViewMatrix.m[4], headViewMatrix.m[5], headViewMatrix.m[6], headViewMatrix.m[7], headViewMatrix.m[8], headViewMatrix.m[9], headViewMatrix.m[10], headViewMatrix.m[11], headViewMatrix.m[12], headViewMatrix.m[13], headViewMatrix.m[14], headViewMatrix.m[15]);
}

- (void)drawEyeWithEye:(CBDEye *)eye
{
    // Use Z-Up/Y-Forward because we are using a scene exported from Blender
    GLKMatrix4 lookAt = GLKMatrix4MakeLookAt(0.0f, 0.0f, 0.0f,
                                             0.0f, 0.0f, -1.0f,
                                             0.0f, 1.0f, 0.0f);
    cameraNode.transform = SCNMatrix4Invert(SCNMatrix4FromGLKMatrix4(GLKMatrix4Multiply([eye eyeViewMatrix], lookAt)));
    [cameraNode.camera setProjectionTransform:SCNMatrix4FromGLKMatrix4([eye perspectiveMatrixWithZNear:0.1f zFar:100.0f])];
    
    [_renderer renderAtTime:0];
}

- (void)finishFrameWithViewportRect:(CGRect)viewPort
{
}

@end
