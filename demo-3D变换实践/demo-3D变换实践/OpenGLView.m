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
    CADisplayLink *_displayLink;
}

- (void)setupLayer;
- (void)setupContext;
- (void)setupBuffers;
- (void)destoryBuffers;

- (void)setupProgram;
- (void)setupProjection;

- (void)updateTransform;
- (void)displayLinkCallback:(CADisplayLink*)displayLink;
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
}

//更新模型矩阵,响应用户控制
-(void)updateTransform{
    //
    ksMatrixLoadIdentity(&_modelViewMatrix);
    
    //平移
    ksMatrixTranslate(&_modelViewMatrix, self.posX, self.posY, self.posZ);
    //旋转
    ksMatrixRotate(&_modelViewMatrix, self.rotateX, 1.0, 0.0, 0.0);
    //缩放
    ksMatrixScale(&_modelViewMatrix, 1.0, 1.0, self.scaleZ);
    
    //装载模型视图矩阵
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);
}


- (void)drawTriangle
{
    GLfloat vertices[] = {
        0.0f,  0.7f, 0.0f,
        -0.7f, -0.7f, 0.0f,
        0.7f,  -0.7f, 0.0f };
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices );
    glEnableVertexAttribArray(_positionSlot);
    
    // Draw triangle
    //
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

- (void)drawTriCone
{
    GLfloat vertices[] = {
        0.7f, 0.7f, 0.0f,
        0.7f, -0.7f, 0.0f,
        -0.7f, -0.7f, 0.0f,
        -0.7f, 0.7f, 0.0f,
        0.0f, 0.0f, -1.0f,
    };
    
    //顶点索引数组 减少储存重复顶点的内存消耗.
    GLubyte indices[] = {
        0, 1, 1, 2, 2, 3, 3, 0,
        4, 0, 4, 1, 4, 2, 4, 3
    };
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices );
    glEnableVertexAttribArray(_positionSlot);
    
    // Draw lines
    //
    
    /*
     glDrawElements 函数的原型为：
     
     void glDrawElements(    GLenum      mode,
     GLsizei      count,
     GLenum      type,
     const GLvoid *      indices);
     
     
     第一个参数 mode 为描绘图元的模式，其有效值为：GL_POINTS, GL_LINES, GL_LINE_STRIP,  GL_LINE_LOOP,  GL_TRIANGLES,  GL_TRIANGLE_STRIP, GL_TRIANGLE_FAN。这些模式具体含义下面有介绍。
     
     第二个参数 count 为顶点索引的个数也就是，第三个参数type 是指顶点索引的数据类型，因为索引始终是正值，索引这里必须是无符号型的非浮点类型，因此只能是 GL_UNSIGNED_BYTE, GL_UNSIGNED_SHORT, GL_UNSIGNED_INT 之一，为了减少内存的消耗，尽量使用最小规格的类型如 GL_UNSIGNED_BYTE。
     
     第四个参数 indices 是存放顶点索引的数组。（indices 是 index 的复数形式，3D 里面很多单词的复数都挺特别的。）

     */
    glDrawElements(GL_LINES, sizeof(indices)/sizeof(GLubyte), GL_UNSIGNED_BYTE, indices);
}

- (void)render
{
    if (_context == nil)
        return;
    
    glClearColor(0, 1.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Setup viewport
    //
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    //[self drawTriangle];
    [self drawTriCone];
    
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
    
    [self updateTransform];
    
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
        [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        _displayLink = nil;
    }
}

- (void)displayLinkCallback:(CADisplayLink*)displayLink
{
    self.rotateX += displayLink.duration * 90;
}

- (void)resetTransform
{
    if (_displayLink != nil) {
        [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        _displayLink = nil;
    }
    
    _posX = 0.0;
    _posY = 0.0;
    _posZ = -5.5;
    
    _scaleZ = 1.0;
    _rotateX = 0.0;
    
    [self updateTransform];
}

- (void)setPosX:(float)x
{
    _posX = x;
    
    [self updateTransform];
    [self render];
}

- (float)posX
{
    return _posX;
}

- (void)setPosY:(float)y
{
    _posY = y;
    
    [self updateTransform];
    [self render];
}

- (float)posY
{
    return _posY;
}

- (void)setPosZ:(float)z
{
    _posZ = z;
    
    [self updateTransform];
    [self render];
}

- (float)posZ
{
    return _posZ;
}

- (void)setScaleZ:(float)scaleZ
{
    _scaleZ = scaleZ;
    
    [self updateTransform];
    [self render];
}

- (float)scaleZ
{
    return _scaleZ;
}

- (void)setRotateX:(float)rotateX
{
    _rotateX = rotateX;
    
    [self updateTransform];
    [self render];
}

- (float)rotateX
{
    return _rotateX;
}


@end
