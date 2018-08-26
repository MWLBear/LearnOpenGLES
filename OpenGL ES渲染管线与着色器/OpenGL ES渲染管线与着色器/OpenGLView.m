//
//  OpenGLView.m
//  OpenGL ES渲染管线与着色器
//
//  Created by lz on 2018/8/23.
//  Copyright © 2018 lz. All rights reserved.
//

#import "OpenGLView.h"
#import "GLESUtils.h"

@implementation OpenGLView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self setup];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        
        //[self setup];
        [self setupLayer];
        [self setupContext];
        [self setupProgarm];
    }
    return self;
}

-(void)setup{
    [self setupLayer];
    [self setupContext];
    [self setupBuffer];
    [self setupProgarm];
    
}
-(void)didMoveToWindow{
    [super didMoveToWindow];
    [self render];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    [EAGLContext setCurrentContext:_contex];
    
    [self destoryBuffers];
    
    [self setupBuffer];
    
    [self render];

}

+(Class)layerClass{
    // 只有 [CAEAGLLayer class] 类型的 layer 才支持在其上描绘 OpenGL 内容。
    return [CAEAGLLayer class];
}

-(void)setupLayer{
    _eaglayer = (CAEAGLLayer*)self.layer;
    _eaglayer.opaque = YES;
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    _eaglayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:NO],kEAGLDrawablePropertyRetainedBacking,
                                    kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat,
                                    nil];
}
-(void)setupContext{
    _contex = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!_contex) {
        NSLog(@"Failed create contex");
        exit(1);
    }
    if (![EAGLContext setCurrentContext:_contex]) {
        _contex = nil;
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

-(void)setupBuffer{

    glGenRenderbuffers(1, &_colorRenderBuffer);
    //设置当前的renderbuffer
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    //为color renderbuffer分配储存空间
    [_contex renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglayer];

    glGenFramebuffers(1, &_frameBuffer);
#warning
    //这里的函数写错了 一直运行的不对.
    //设置当前的framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);

}

- (void)destoryBuffers
{
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
    
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;

}

-(void)render{
    
    glClearColor(0, 1.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    GLfloat vertices[] ={
        0.0f,  0.5f, 0.0f,
        -0.5f, -0.5f, 0.0f,
        0.5f,  -0.5f, 0.0f };
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices );
    glEnableVertexAttribArray(_positionSlot);
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    [_contex presentRenderbuffer:GL_RENDERBUFFER];
}

-(void)setupProgarm{
    
    NSString*vertexShaderPath = [[NSBundle mainBundle]pathForResource:@"VertexShader.glsl" ofType:nil];
    NSString*fragmentShaderpath = [[NSBundle mainBundle]pathForResource:@"FragmentShader.glsl" ofType:nil];
    
    //create progam ,attach shader
    GLuint vertexShader = [GLESUtils loadShader:GL_VERTEX_SHADER withFilePath:vertexShaderPath];
    GLuint fragmentShader = [GLESUtils loadShader:GL_FRAGMENT_SHADER withFilePath:fragmentShaderpath];
    
    _programHandle = glCreateProgram();
    if (!_programHandle) {
        NSLog(@"Failed to create program");
        return;
    }
    
    glAttachShader(_programHandle, vertexShader);
    glAttachShader(_programHandle, fragmentShader);
    
    //link program
    glLinkProgram(_programHandle);
    
    //check link sattus;
    GLint linked;
    glGetProgramiv(_programHandle, GL_LINK_STATUS, &linked);
    if (!linked) {
        GLint infoLen = 0;
        glGetProgramiv (_programHandle, GL_INFO_LOG_LENGTH, &infoLen );
        
        if (infoLen > 1)
        {
            char * infoLog = malloc(sizeof(char) * infoLen);
            glGetProgramInfoLog (_programHandle, infoLen, NULL, infoLog );
            NSLog(@"Error linking program:\n%s\n", infoLog );
            
            free (infoLog );
        }
        glDeleteProgram(_programHandle);
        _programHandle = 0;
    }
    
    glUseProgram(_programHandle);
    _positionSlot = glGetAttribLocation(_programHandle, "vPosition");
}
@end
