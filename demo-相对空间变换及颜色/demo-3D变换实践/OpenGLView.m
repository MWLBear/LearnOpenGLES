//
//  OpenGLView.m
//  demo-3D变换实践
//
//  Created by lz on 2018/8/26.
//  Copyright © 2018 lz. All rights reserved.
//

#import "OpenGLView.h"
#import "GLESUtils.h"

@interface OpenGLView(){
    
    ksMatrix4 _shouldModelViewMatrix;
    ksMatrix4 _elbowModelViewMatrix;
    float _rotateColorCube;
    
    CADisplayLink *_displayLink;
}

- (void)setupLayer;
- (void)setupContext;
- (void)setupBuffers;
- (void)destoryBuffers;

- (void)setupProgram;
- (void)setupProjection;

- (void)updateShoulderTransform;
- (void)updateElbowTransform;
- (void)resetTransform;

- (void)updateRectangleTransform;
- (void)updateColorCubeTransform;
- (void)drawColorCube;

- (void)drawCube:(ksColor) color;

@end

@implementation OpenGLView

+ (Class)layerClass {
    // 只有 [CAEAGLLayer class] 类型的 layer 才支持在其上描绘 OpenGL 内容。
    return [CAEAGLLayer class];
}

- (void)setupLayer
{
    _eaglLayer = (CAEAGLLayer*) self.layer;
    
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见
    _eaglLayer.opaque = YES;
    
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext {
    // 指定 OpenGL 渲染 API 的版本，在这里我们使用 OpenGL ES 2.0
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@" >> Error: Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    // 设置为当前上下文
    if (![EAGLContext setCurrentContext:_context]) {
        _context = nil;
        NSLog(@" >> Error: Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)setupBuffers {
    
    glGenRenderbuffers(1, &_colorRenderBuffer);
    // 设置为当前 renderbuffer
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    // 为 color renderbuffer 分配存储空间
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    glGenFramebuffers(1, &_frameBuffer);
    // 设置为当前 framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
}

- (void)destoryBuffers
{
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
    
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
}

- (void)cleanup
{
    [self destoryBuffers];
    
    if (_programHandle != 0) {
        glDeleteProgram(_programHandle);
        _programHandle = 0;
    }
    
    if (_context && [EAGLContext currentContext] == _context)
        [EAGLContext setCurrentContext:nil];
    
    _context = nil;
}

-(void)setupProgram{
    
    //顶点着色器:
    /*
     先进行模型视图变换然后在进行投影变换
     */
    
    
    NSString*vertexShaderPath = [[NSBundle mainBundle]pathForResource:@"VertexShader.glsl" ofType:nil];
    NSString*frgmentShaderPath = [[NSBundle mainBundle]pathForResource:@"FragmentShader.glsl" ofType:nil];

    _programHandle = [GLESUtils loadProgrammer:vertexShaderPath withFragmentShaderFilePath:frgmentShaderPath];
    
    if (_programHandle == 0) {
        return;
    }
    
    glUseProgram(_programHandle);
    
    _positionSlot = glGetAttribLocation(_programHandle, "vPosition");
    _colorSlot = glGetAttribLocation(_programHandle, "vSourceColor");
    _modelViewSlot = glGetUniformLocation(_programHandle, "modelView");
    _prjectionSlot = glGetUniformLocation(_programHandle, "projection");
    
}

//投影变换
-(void)setupProjection{
    float aspect = self.frame.size.width/self.frame.size.height;
    
    //将矩阵重置为单位矩阵.
    ksMatrixLoadIdentity(&_projectionMatrix);
    
    //将视椎体的近裁剪面到观察者的距离设置为1 ,远裁剪面到观察者的距离设置为20,视角为60度,然后装载投影矩阵
    //默认的观察方向 在原点,视线朝-Z方向,因此近裁剪面其实在z = -1,远裁剪面在z=-20 z值不在(-1,20)的是看不见的
    
    ksPerspective(&_projectionMatrix, 60, aspect, 1.0, 20);
    glUniformMatrix4fv(_prjectionSlot, 1, GL_FALSE, (GLfloat*)&_projectionMatrix.m[0][0]);
    
    //背面剔除
    glEnable(GL_CULL_FACE);
}

//胳膊
- (void)updateShoulderTransform{
    ksMatrixLoadIdentity(&_shouldModelViewMatrix);
    ksMatrixTranslate(&_shouldModelViewMatrix, 0.0, 0, -5.5);
    ksMatrixRotate(&_shouldModelViewMatrix, self.rotateShoulder, 0, 0, 1);
    
    // Scale the cube to be a shoulder
    ksMatrixCopy(&_modelViewMatrix, &_shouldModelViewMatrix);
    ksMatrixScale(&_modelViewMatrix, 1.5, 0.7, 0.7);
    
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);
    
    
}

//手臂
- (void)updateElbowTransform{
    ksMatrixCopy(&_elbowModelViewMatrix, &_shouldModelViewMatrix);
    //右移1.5个单位
    ksMatrixTranslate(&_elbowModelViewMatrix, 1.5, 0.0, 0.0);
    ksMatrixRotate(&_elbowModelViewMatrix, self.rotateElbow, 0.0, 0.0, 1.0);
    
    ksMatrixCopy(&_modelViewMatrix, &_elbowModelViewMatrix);
    ksMatrixScale(&_modelViewMatrix, 1.0, 0.4, 0.4);
    
    // Load the model-view matrix
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);
    
}
- (void)resetTransform{
    
    self.rotateShoulder = 0.0;
    self.rotateElbow = 0.0;
    
    [self updateShoulderTransform];
    [self updateElbowTransform];
}

- (void)updateRectangleTransform{
    ksMatrixLoadIdentity(&_modelViewMatrix);
    
    ksMatrixTranslate(&_modelViewMatrix, 0.0, -2, -5.5);
    
    // Load the model-view matrix
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);
}
- (void)updateColorCubeTransform{
    ksMatrixLoadIdentity(&_modelViewMatrix);
    
    ksMatrixTranslate(&_modelViewMatrix, 0.0, -2, -5.5);
    
    ksMatrixRotate(&_modelViewMatrix, _rotateColorCube, 0.0, 1.0, 0.0);
    
    // Load the model-view matrix
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);
}

- (void) drawColorCube
{
    GLfloat vertices[] = {
        -0.5f, -0.5f, 0.5f, 1.0, 0.0, 0.0, 1.0,     // red
        -0.5f, 0.5f, 0.5f, 1.0, 1.0, 0.0, 1.0,      // yellow
        0.5f, 0.5f, 0.5f, 0.0, 0.0, 1.0, 1.0,       // blue
        0.5f, -0.5f, 0.5f, 1.0, 1.0, 1.0, 1.0,      // white
        
        0.5f, -0.5f, -0.5f, 1.0, 1.0, 0.0, 1.0,     // yellow
        0.5f, 0.5f, -0.5f, 1.0, 0.0, 0.0, 1.0,      // red
        -0.5f, 0.5f, -0.5f, 1.0, 1.0, 1.0, 1.0,     // white
        -0.5f, -0.5f, -0.5f, 0.0, 0.0, 1.0, 1.0,    // blue
    };
    
    GLubyte indices[] = {
        // Front face
        0, 3, 2, 0, 2, 1,
        
        // Back face
        7, 5, 4, 7, 6, 5,
        
        // Left face
        0, 1, 6, 0, 6, 7,
        
        // Right face
        3, 4, 5, 3, 5, 2,
        
        // Up face
        1, 2, 5, 1, 5, 6,
        
        // Down face
        0, 7, 4, 0, 4, 3
    };
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 7 * sizeof(float), vertices);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, 7 * sizeof(float), vertices + 3);
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    glDrawElements(GL_TRIANGLES, sizeof(indices)/sizeof(GLubyte), GL_UNSIGNED_BYTE, indices);
    glDisableVertexAttribArray(_colorSlot);
}

- (void)drawCube:(ksColor) color{
    
    GLfloat vertices[] = {
        0.0f, -0.5f, 0.5f,
        0.0f, 0.5f, 0.5f,
        1.0f, 0.5f, 0.5f,
        1.0f, -0.5f, 0.5f,
        
        1.0f, -0.5f, -0.5f,
        1.0f, 0.5f, -0.5f,
        0.0f, 0.5f, -0.5f,
        0.0f, -0.5f, -0.5f,
    };
    
    GLubyte indices[] = {
        0, 1, 1, 2, 2, 3, 3, 0,
        4, 5, 5, 6, 6, 7, 7, 4,
        0, 7, 1, 6, 2, 5, 3, 4
    };
    
    glVertexAttrib4f(_colorSlot, color.r, color.g, color.b, color.a);
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(_positionSlot);
    
    glDrawElements(GL_LINES, sizeof(indices)/sizeof(GLbyte), GL_UNSIGNED_BYTE, indices);
}



- (void)render
{
    if (_context == nil) {
        return;
    }
    ksColor colorRed = {1, 0, 0, 1};
    ksColor colorWhite = {1, 1, 1, 1};
    
    glClearColor(0.0, 1.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Setup viewport
    //
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    
    // Draw color rectangle
    //
    //    [self updateRectangleTransform];
    //    [self drawColorRectangle];
    
    // Draw color cube
    //
    [self updateColorCubeTransform];
    [self drawColorCube];
    
    
    // Draw shoulder
    //
    [self updateShoulderTransform];
    [self drawCube:colorRed];
    
    // Draw elbow
    //
    [self updateElbowTransform];
    [self drawCube:colorWhite];
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupLayer];
        [self setupContext];
        [self setupProgram];
        [self setupProjection];
        
        [self resetTransform];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [EAGLContext setCurrentContext:_context];
    glUseProgram(_programHandle);
    
    [self destoryBuffers];
    
    [self setupBuffers];
    
  
    
    [self render];
}

- (void)toggleDisplayLink
{
    if (_displayLink == nil) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    else {
        [_displayLink invalidate];
       // [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        _displayLink = nil;
    }
}

- (void)displayLinkCallback:(CADisplayLink*)displayLink
{
    _rotateColorCube += displayLink.duration * 90;
    
    [self render];
}

- (void)setRotateShoulder:(float)rotateShoulder
{
    _rotateShoulder = rotateShoulder;
    
    [self render];
}

- (float)rotateShoulder
{
    return _rotateShoulder;
}

- (void)setRotateElbow:(float)rotateElbow
{
    _rotateElbow = rotateElbow;
    
    [self render];
}

- (float)rotateElbow
{
    return _rotateElbow;
}

@end
