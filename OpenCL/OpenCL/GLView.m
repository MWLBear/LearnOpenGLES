//
//  GLView.m
//  OpenCL
//
//  Created by lz on 2018/8/22.
//  Copyright © 2018年 lz. All rights reserved.
//

#import "GLView.h"
@import OpenGLES;

@implementation GLView
//着色器

+(Class)layerClass{
    return [CAEAGLLayer class];
}

-(void)setLayer{
    _eagLyer = (CAEAGLLayer*)self.layer;
    _eagLyer.opaque = YES;
}
// context 管理所有使用 OpenGL ES 进行渲染的状态，命令以及资源信息
-(void)setContext{
    if (!_context) {
        _context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    NSAssert(_context&&[EAGLContext setCurrentContext:_context], @"context初始化失败");
}

#pragma mark - renderBuffer
//OpenGL ES 有三大不同buffer :color buffer ,depth buffer ,stecncil buffer
//renferbuffer可以理解为用于展示的窗口
-(void)setupRenderBuffer{
    
    if (_renderbuffer) {
        glDeleteRenderbuffers(1, &_renderbuffer);
        _renderbuffer = 0;
    }
    //生成renderBuffer
    /*
     glGenRenderbuffers 用于生成 renderbuffer，并分配 id
     
     void glGenRenderbuffers (GLsizei n, GLuint* renderbuffers)
     n：表示申请生成 renderbuffer 的个数。
     renderbuffers：返回分配给 renderbuffer 的 id。
     
     */
    glGenRenderbuffers(1, &_renderbuffer);
    
    //绑定renderBuffer:将制定id的buffer绑定为当前的buffer
    /*
     void glBindRenderbuffer (GLenum target, GLuint renderbuffer)
     target：表示当前 renderbuffer，必须是 GL_RENDERBUFFER。
     renderbuffer：某个 renderbuffer 对应的 id（比如使用 glGenRenderbuffers 生成的 id）
     */
    
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
    
    //GL_RENDERBUFFER 内容存储到 CAEAGLayer上
    
    
    //renderbufferStorage 用于将 GL_RENDERBUFFER 的内容存储到实现 EAGLDrawable 协议的 CAEAGLLayer
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eagLyer];
}

#pragma mark - frameBuffer
//创建framebuffer object 称为 FBO  buffer的管理者,三大buffer可以附加到FBO上面
/*
 glFramebufferRenderbuffer:的作用正是将相关的 buffer（三大 buffer 之一）装配到 framebuffer 上，使得 framebuffer 能索引到对应的渲染内容
 函数原型:
 void glFramebufferRenderbuffer (GLenum target, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer)
 
 参数:
 target：表示当前 framebuffer，必须是 GL_FRAMEBUFFER。
 attachment：指定 renderbuffer 被装配到那个装配点上，其值是 GL_COLOR_ATTACHMENT0，GL_DEPTH_ATTACHMENT，GL_STENCIL_ATTACHMENT 中的一个，分别对应 color，depth 和 stencil 三大 buffer。
 renderbuffertarget：表示当前 renderbuffer，必须是 GL_RENDERBUFFER。
 renderbuffer：某个 renderbuffer 对应的 id，表示需要装配的 renderbuffer。
 */

-(void)setupFrameBuffer{
    //释放旧的的framebuffer
    if (_framebuffer) {
        glDeleteFramebuffers(1, &_framebuffer);
        _framebuffer = 0;
    }
    //framebuffer == 画布
    glGenFramebuffers(1, &_framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    // framebuffer 不对渲染的内容做存储, 所以这一步是将 framebuffer 绑定到 renderbuffer ( 渲染的结果就存在 renderbuffer )
    //是的framebuffer能够索引到对应的渲染内容
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderbuffer);
    /*
     void glFramebufferRenderbuffer (GLenum target, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer)
     target：表示当前 framebuffer，必须是 GL_FRAMEBUFFER。
     attachment：指定 renderbuffer 被装配到那个装配点上，其值是 GL_COLOR_ATTACHMENT0，GL_DEPTH_ATTACHMENT，GL_STENCIL_ATTACHMENT 中的一个，分别对应 color，depth 和 stencil 三大 buffer。
     renderbuffertarget：表示当前 renderbuffer，必须是 GL_RENDERBUFFER。
     renderbuffer：某个 renderbuffer 对应的 id，表示需要装配的 renderbuffer。
     */
    
}

//检查framebuffer的创建情况
-(BOOL)checkFramebuffer:(NSError *__autoreleasing*)error{
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSString*errorString = nil;
    BOOL reslut = NO;
    switch (status) {
        case GL_FRAMEBUFFER_UNSUPPORTED:
            errorString = @"framerbuffer不支持该格式";
            reslut = NO;
            break;
        case GL_FRAMEBUFFER_COMPLETE:
            errorString = @"framebuffer创建成功";
            NSLog(@"framebuffer 创建成功");
            reslut = YES;
            break;
        case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT:
            errorString = @"framebuffer不完整 缺失组件";
            reslut = NO;
            break;
        case GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS:
            errorString = @"framebuffer不完整 附加图片必须指定大小";
            reslut = NO;
            break;
        default:
            errorString = @"未知错误";
            reslut = NO;
            break;
    }
    *error = errorString?[NSError errorWithDomain:@"com.lz.nb" code:status userInfo:@{@"errorMessage":errorString}]:nil;
    return reslut;
}

#pragma mark - VBO
//顶点缓存对象(VBO:Vertex Buffer Objects)
/*
 把顶点数据发送给图形渲染管道的第一个处理阶段:顶点着色器.它在GPU上创建内存存储顶点数据
 顶点缓存对象(VBO)管理这个内存,它会在 GPU 内存（通常被称为显存）中储存大量顶点.
 */

/*
 glBufferData函数 :它会把之前定义的顶点数据复制到缓存的内存中
 void GL_APIENTRY glBufferData (GLenum target, GLsizeiptr size, const GLvoid* data, GLenum usage);
 
 target：缓存类型，这里指定 GL_ARRAY_BUFFER。
 size：传输数据的大小（以字节为单位）。直接通过 sizeof(vertices) 计算出顶点数据大小即可。
 data：指向实际传输数据。
 usage：指定我们希望显卡如何管理给定的数据。它有三种形式：
 GL_STATIC_DRAW ：数据不会或几乎不会改变。
 GL_DYNAMIC_DRAW：数据会被改变很多。
 GL_STREAM_DRAW ：数据每次绘制时都会改变。
 三角形的位置数据不会改变，每次渲染调用时都保持原样，所以它的使用类型最好是GL_STATIC_DRAW。如果，比如说一个缓存中的数据将频繁被改变，那么使用的类型就是GL_DYNAMIC_DRAW 或 GL_STREAM_DRAW，这样就能确保显卡把数据放在能够高速写入的内存部分。
 */
//创建VBO
-(void)setupVBOs{
    //顶点数据
    static const CustomVertex vertices[] =
    {
        { .position = { -1.0,  1.0, 0, 1 }, .color = { 1, 0, 0, 1 } },
        { .position = { -1.0, -1.0, 0, 1 }, .color = { 0, 1, 0, 1 } },
        { .position = {  1.0, -1.0, 0, 1 }, .color = { 0, 0, 1, 1 } }
    };
    
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
}
#pragma makr -编译 着色器

//// 动态编译着色器源码
-(GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType{
    NSString*shaderPath = [[NSBundle mainBundle]pathForResource:shaderName ofType:nil];
    NSError*error;
    NSString*shaderSting = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderSting) {
        exit(1);
    }
    //着色器源码
    const char *shaderStringUTF8 = [shaderSting UTF8String];
    int shaderStringLength = (int)[shaderSting length];

    //创建着色器对象
    /*
     GLuint GL_APIENTRY glCreateShader (GLenum type);
     type：着色器类型，可选值有 GL_VERTEX_SHADER 和 GL_FRAGMENT_SHADER。
     */
    
    GLuint shaderHandle = glCreateShader(shaderType);
    //把着色器源码附加到着色器上面
    /*
     */
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    //编译着色器
    glCompileShader(shaderHandle);

    GLint complieSucess;
    //检查编译是否成功
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &complieSucess);
    if (complieSucess == GL_FALSE) {
        GLchar message[256];
        glGetShaderInfoLog(shaderHandle, sizeof(message), 0, &message[0]);
        NSString*messageString = [NSString stringWithUTF8String:message];
        NSLog(@" glGetShaderiv shagerLog = %@",messageString);
        exit(1);
    }
    return shaderHandle;
}

#pragma mark -着色器程序

// 把着色器对象合并
-(void)compileShaders{
    GLuint vertexShader = [self compileShader:@"OpenGLESDemo.vsh" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"OpenGLESDmeo.fsh" withType:GL_FRAGMENT_SHADER];
   
    //创建着色器对象
    GLuint programHandle = glCreateProgram();
    
    //将编译好的着色器附加到着色器程序上
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    
    //链接着色器
    glLinkProgram(programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar message[256];
        glGetShaderInfoLog(programHandle, sizeof(message), 0, &message[0]);
        NSString*messageString = [NSString stringWithUTF8String:message];
        NSLog(@"glGetProgramiv ShaderIngoLog :%@",messageString);
        exit(1);
    }
    //激活程序对象
    glUseProgram(programHandle);
    
    //告诉opengl ES 将顶点数据链接到顶点着色器的属性上面
    
    //着色器变量的入口和属性绑定起来
    glViewAttributes[ATTRIBUTE_POSITION] = glGetAttribLocation(programHandle, "position");
    glViewAttributes[ATTRIBUTE_COLOR] = glGetAttribLocation(programHandle, "color");
    
    //顶点属性值作为参数，启用顶点属性
    glEnableVertexAttribArray( glViewAttributes[ATTRIBUTE_POSITION]);
    glEnableVertexAttribArray( glViewAttributes[ATTRIBUTE_COLOR]);
    
    //顶点属性的绑定已经完成了，之后只需要在渲染的时候，为对应的顶点属性赋值即可。
}

//渲染背景色
-(void)render{
    glBindBuffer(GL_FRAMEBUFFER, _framebuffer);
    glBindBuffer(GL_RENDERBUFFER, _renderbuffer);
    
    glClearColor(0, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    //视图的视见区域
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    // 使用VBO时，最后一个参数0为要获取参数在GL_ARRAY_BUFFER中的偏移量
    
    // glVertexAttribPointer 函数告诉 OpenGL ES 该如何解析顶点数据 （应用到逐个顶点属性上）
    glVertexAttribPointer(glViewAttributes[ATTRIBUTE_POSITION], 4, GL_FLOAT, GL_FALSE,sizeof(CustomVertex), 0);
    glVertexAttribPointer(glViewAttributes[ATTRIBUTE_COLOR], 4, GL_FLOAT, GL_FALSE, sizeof(CustomVertex), (GLvoid *)(sizeof(float) * 4));
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
    //做完所有的绘制操作后,呈现在屏幕上
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark - lifeCycle

- (void)dealloc {
    if (_framebuffer) {
        glDeleteFramebuffers(1, &_framebuffer);
        _framebuffer = 0;
    }
    
    if (_renderbuffer) {
        glDeleteRenderbuffers(1, &_renderbuffer);
        _renderbuffer = 0;
    }
    
    _context = nil;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = self.frame.size;
    if (CGSizeEqualToSize(_oldSize, CGSizeZero) ||
        !CGSizeEqualToSize(_oldSize, size)) {
        [self setup];
        _oldSize = size;
    }
    
    [self render];
}
-(void)didMoveToWindow{
    [super didMoveToWindow];
    [self render];
}
#pragma mark -setup
-(void)setup{
    [self setLayer];
    [self setContext];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    NSError*error;
    NSAssert1([self checkFramebuffer:&error], @"%@",error.userInfo[@"errorMessage"]);
    
    [self compileShaders];
    [self setupVBOs];
}

@end
