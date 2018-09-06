//
//  ViewController.m
//  demo -地球月亮
//
//  Created by lz on 2018/9/5.
//  Copyright © 2018年 lz. All rights reserved.
//

#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "sphere.h"


@interface ViewController ()
@property(nonatomic,strong)EAGLContext*context;
@property(nonatomic,strong)GLKBaseEffect*effect;

@property (nonatomic , strong) EAGLContext* mContext;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexPositionBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexNormalBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexTextureCoordBuffer;
@property (strong, nonatomic) GLKTextureInfo *earthTextureInfo;
@property (strong, nonatomic) GLKTextureInfo *moonTextureInfo;
@property (nonatomic) GLKMatrixStackRef modelviewMatrixStack;
@property (nonatomic) GLfloat earthRotationAngleDegrees;
@property (nonatomic) GLfloat moonRotationAngleDegrees;
@end

static const GLfloat  SceneEarthAxialTiltDeg = 23.5f;
static const GLfloat  SceneDaysPerMoonOrbit = 28.0f;
static const GLfloat  SceneMoonRadiusFractionOfEarth = 0.25;
static const GLfloat  SceneMoonDistanceFromEarth = 2.0;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView*view = (GLKView*)self.view;
    view.context = self.context;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888 ;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24 ;
    [EAGLContext setCurrentContext:self.context];
    glEnable(GL_DEPTH_TEST);
   
    self.effect = [[GLKBaseEffect alloc]init];
    [self configLight];
    
    //投影
    GLfloat aspectRation = self.view.bounds.size.width/self.view.bounds.size.height;
    //正投影
    self.effect.transform.projectionMatrix = GLKMatrix4MakeOrtho(-1*aspectRation, 1*aspectRation, -1, 1, 1, 120);
    //模型矩阵
    self.effect.transform.modelviewMatrix = GLKMatrix4MakeTranslation(0, 0, -5.0);
    [self setClearColor:GLKVector4Make(0, 0, 0, 1)];
    //顶点数组
    [self bufferData];
    
}
- (void)setClearColor:(GLKVector4)clearColorRGBA
{
    glClearColor(
                 clearColorRGBA.r,
                 clearColorRGBA.g,
                 clearColorRGBA.b,
                 clearColorRGBA.a);
}

//太阳光
-(void)configLight{
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    self.effect.light0.position = GLKVector4Make(1.0, 0.0, 0.8, 0.0);
    self.effect.light0.ambientColor = GLKVector4Make(0.2, 0.2, 0.2, 1.0);
}
-(void)bufferData{
    self.modelviewMatrixStack = GLKMatrixStackCreate(kCFAllocatorDefault);
    NSLog(@"%@",self.modelviewMatrixStack);
    self.vertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                                 initWithAttribStride:3*sizeof(GLfloat)
                                 numberOfVertices:sizeof(sphereVerts)/(3*sizeof(GLfloat))
                                 bytes:sphereVerts
                                 usage:GL_STATIC_DRAW];
    self.vertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                               initWithAttribStride:(3 * sizeof(GLfloat))
                               numberOfVertices:sizeof(sphereNormals) / (3 * sizeof(GLfloat))
                               bytes:sphereNormals
                               usage:GL_STATIC_DRAW];
    self.vertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                                     initWithAttribStride:(2 * sizeof(GLfloat))
                                     numberOfVertices:sizeof(sphereTexCoords) / (2 * sizeof(GLfloat))
                                     bytes:sphereTexCoords
                                     usage:GL_STATIC_DRAW];
    

    //地球纹理
    CGImageRef earth = [UIImage imageNamed:@"Earth512x256.jpg"].CGImage;
    self.earthTextureInfo = [GLKTextureLoader textureWithCGImage:earth options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],GLKTextureLoaderOriginBottomLeft, nil] error:nil];
    //月球纹理
    CGImageRef moonth = [UIImage imageNamed:@"Moon256x128.png"].CGImage;
    self.moonTextureInfo = [GLKTextureLoader textureWithCGImage:moonth options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],GLKTextureLoaderOriginBottomLeft, nil] error:nil];
    //堆矩阵
    GLKMatrixStackLoadMatrix4(self.modelviewMatrixStack, self.effect.transform.modelviewMatrix);
    self.moonRotationAngleDegrees = -20;
    
}
-(void)drawEarth{
    self.effect.texture2d0.name = self.earthTextureInfo.name;
    self.effect.texture2d0.target = self.earthTextureInfo.target;
    
    GLKMatrixStackPush(self.modelviewMatrixStack);
    GLKMatrixStackRotate(self.modelviewMatrixStack, GLKMathDegreesToRadians(SceneEarthAxialTiltDeg), 1.0, 0.0, 0.0);
    GLKMatrixStackRotate(self.modelviewMatrixStack, GLKMathDegreesToRadians(self.earthRotationAngleDegrees), 0, 1.0, 0);
    
    self.effect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    [self.effect prepareToDraw];

    [AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sphereNumVerts];
    GLKMatrixStackPop(self.modelviewMatrixStack);
    self.effect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
}
-(void)drawMonth{
    
    self.effect.texture2d0.name = self.moonTextureInfo.name;
    self.effect.texture2d0.target = self.moonTextureInfo.target;
    
    GLKMatrixStackPush(self.modelviewMatrixStack);
    GLKMatrixStackRotate(self.modelviewMatrixStack, GLKMathDegreesToRadians(self.moonRotationAngleDegrees), 0, 1.0, 0.0);
    
    GLKMatrixStackTranslate(self.modelviewMatrixStack, 0.0, 0.0, SceneMoonDistanceFromEarth);
    GLKMatrixStackScale(self.modelviewMatrixStack, SceneMoonRadiusFractionOfEarth, SceneMoonRadiusFractionOfEarth, SceneMoonRadiusFractionOfEarth);
    
    GLKMatrixStackRotate(self.modelviewMatrixStack, GLKMathDegreesToRadians(self.moonRotationAngleDegrees), 0, 1.0, 0);
    
    self.effect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    [self.effect prepareToDraw];
    
    [AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sphereNumVerts];
    GLKMatrixStackPop(self.modelviewMatrixStack);
    self.effect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
}
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.3f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    
    self.earthRotationAngleDegrees += 360.0f / 60.0f;
    self.moonRotationAngleDegrees += (360.0f / 60.0f) / SceneDaysPerMoonOrbit;
    
    [self.vertexPositionBuffer
     prepareToDrawWithAttrib:GLKVertexAttribPosition
     numberOfCoordinates:3
     attribOffset:0
     shouldEnable:YES];
    [self.vertexNormalBuffer
     prepareToDrawWithAttrib:GLKVertexAttribNormal
     numberOfCoordinates:3
     attribOffset:0
     shouldEnable:YES];
    [self.vertexTextureCoordBuffer
     prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
     numberOfCoordinates:2
     attribOffset:0
     shouldEnable:YES];
    
    [self drawEarth];
    [self drawMonth];
}
- (IBAction)switchOn:(UISwitch*)aControl {
    GLfloat   aspectRatio =
    (float)((GLKView *)self.view).drawableWidth /
    (float)((GLKView *)self.view).drawableHeight;
    
    if([aControl isOn])
    {
        self.effect.transform.projectionMatrix =
        //透视投影
        GLKMatrix4MakeFrustum(
                              -1.0 * aspectRatio,
                              1.0 * aspectRatio,
                              -1.0,
                              1.0,
                              2.0,
                              120.0);
        //        self.baseEffect.transform.projectionMatrix =
        //        GLKMatrix4MakePerspective(1.0, aspectRatio, 1.0, 50.0);
    }
    else
    {
        self.effect.transform.projectionMatrix =
        //正交投影
        GLKMatrix4MakeOrtho(
                            -1.0 * aspectRatio,
                            1.0 * aspectRatio,
                            -1.0,
                            1.0,
                            1.0,
                            120.0);
    }
}

-(void)update{
    
}
@end
