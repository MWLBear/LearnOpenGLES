//
//  ViewController.m
//  demo -光照 法线
//
//  Created by lz on 2018/9/5.
//  Copyright © 2018年 lz. All rights reserved.
//

#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "sceneUtil.h"


@interface ViewController ()
@property(nonatomic,strong)EAGLContext*context;
@property(nonatomic,strong)GLKBaseEffect*baseEffect;
@property(nonatomic,strong)GLKBaseEffect*extraEffect;

@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *extraBuffer;

@property(nonatomic)BOOL shouldUserFaceNormals;
@property(nonatomic)BOOL shouldDrawNormal;
@property(nonatomic,assign)GLfloat centerVertexHeight;
@end

@implementation ViewController{
    SceneTriangle triangles[NUM_FACES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView*view = (GLKView*)self.view;
    view.context = self.context;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888 ;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24 ;
    [EAGLContext setCurrentContext:self.context];
    
    (GL_DEPTH_TEST);
   
    self.baseEffect = [[GLKBaseEffect alloc]init];
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.diffuseColor = GLKVector4Make(0.8, 0.8, 0.8, 1.0);
    self.baseEffect.light0.position = GLKVector4Make(1.0, 1.0, 0.5, 0);
    
    self.extraEffect = [[GLKBaseEffect alloc]init];
    self.extraEffect.useConstantColor = GL_TRUE;
    
    if (true) {
        GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(-60), 1, 0, 0);
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(-30), 0, 0, 1);
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, 0.25f);
        self.baseEffect.transform.modelviewMatrix = modelViewMatrix;
        self.extraEffect.transform.modelviewMatrix = modelViewMatrix;
    }
    
    [self setClearColor:GLKVector4Make(0, 0, 0, 1.0)];
    
    triangles[0] = SceneTriangleMake(vertexA, vertexB, vertexD);
    triangles[1] = SceneTriangleMake(vertexB, vertexC, vertexF);
    triangles[2] = SceneTriangleMake(vertexD, vertexB, vertexE);
    triangles[3] = SceneTriangleMake(vertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, vertexE, vertexH);
    triangles[5] = SceneTriangleMake(vertexE, vertexF, vertexH);
    triangles[6] = SceneTriangleMake(vertexG, vertexD, vertexH);
    triangles[7] = SceneTriangleMake(vertexH, vertexF, vertexI);
    
    
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(triangles)/sizeof(SceneVertex) bytes:triangles usage:GL_DYNAMIC_DRAW];
    
    self.extraBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(SceneVertex) numberOfVertices:0 bytes:NULL usage:GL_DYNAMIC_DRAW];
    
    self.centerVertexHeight = 0.0;
    self.shouldUserFaceNormals = YES;
    
}

- (void)setClearColor:(GLKVector4)clearColorRGBA
{
    glClearColor(
                 clearColorRGBA.r,
                 clearColorRGBA.g,
                 clearColorRGBA.b,
                 clearColorRGBA.a);
}


//更新法向量
-(void)updateNormals{
    if (self.shouldUserFaceNormals) {
        SceneTrianglesUpdateFaceNormals(triangles);
    }else{
        SceneTrianglesUpdateVertexNormals(triangles);
    }
    [self.vertexBuffer reinitWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(triangles)/sizeof(SceneVertex) bytes:triangles];
}
//绘制法向量
-(void)drawNormals{
    GLKVector3 normalLineVertices[NUM_LINE_VERTS];
    SceneTrianglesNormalLinesUpdate(triangles, GLKVector3MakeWithArray(self.baseEffect.light0.position.v), normalLineVertices);
    [self.extraBuffer reinitWithAttribStride:sizeof(GLKVector3) numberOfVertices:NUM_LINE_VERTS bytes:normalLineVertices];
    [self.extraBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    
    self.extraEffect.useConstantColor = GL_TRUE;
    self.extraEffect.constantColor = GLKVector4Make(0, 1.0, 0.0, 1.0);
    [self.extraEffect prepareToDraw];
    [self.extraBuffer drawArrayWithMode:GL_LINES startVertexIndex:0 numberOfVertices:NUM_NORMAL_LINE_VERTS];
    
    self.extraEffect.constantColor = GLKVector4Make(1.0, 1.0, 0.0, 1.0);
    [self.extraBuffer drawArrayWithMode:GL_LINES startVertexIndex:NUM_NORMAL_LINE_VERTS numberOfVertices:(NUM_LINE_VERTS-NUM_NORMAL_LINE_VERTS)];
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    glClearColor(0.3f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.baseEffect prepareToDraw];
    
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneVertex,position ) shouldEnable:YES];
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal numberOfCoordinates:3 attribOffset:offsetof(SceneVertex,normal) shouldEnable:YES];
    
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sizeof(triangles)/sizeof(SceneVertex)];
    if (self.shouldDrawNormal) {
        [self drawNormals];
    }
}

- (IBAction)takeShouldUserFaceNormalsFrom:(UISwitch*)sender {
    self.shouldUserFaceNormals = sender.isOn;
}
- (IBAction)takeShouldDrawNormalsFrom:(UISwitch*)sender {
    self.shouldDrawNormal = sender.isOn;
}
- (IBAction)takeCenterVertexHeight:(UISlider*)sender {
    
    self.centerVertexHeight = sender.value;
}


-(void)setCenterVertexHeight:(GLfloat)centerVertexHeight{
    
    _centerVertexHeight = centerVertexHeight;
    
    SceneVertex newVertexE = vertexE;
    newVertexE.position.z = _centerVertexHeight;
    
    triangles[2] = SceneTriangleMake(vertexD, vertexB, newVertexE);
    triangles[3] = SceneTriangleMake(newVertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, newVertexE, vertexH);
    triangles[5] = SceneTriangleMake(newVertexE, vertexF, vertexH);
    
    [self updateNormals];
}

-(void)setShouldUserFaceNormals:(BOOL)shouldUserFaceNormals{
    if (shouldUserFaceNormals != _shouldUserFaceNormals) {
        _shouldUserFaceNormals = shouldUserFaceNormals;
        [self updateNormals];
    }
}
-(void)update{
    
}
@end
