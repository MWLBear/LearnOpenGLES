//
//  learnView.m
//  demo2
//
//  Created by lz on 2018/8/23.
//  Copyright © 2018年 lz. All rights reserved.
//

#import "learnView.h"
@import OpenGLES;

@interface learnView()
@property(nonatomic,strong)EAGLContext*context;
@property(nonatomic,strong)CAEAGLLayer*myLayer;

@property(nonatomic,assign)GLuint myProgrmmer;
@property(nonatomic,assign)GLuint colorFramerBuffer;
@property(nonatomic,assign)GLuint colorRenderBuffer;

@end
@implementation learnView

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        
    }
    return self;
}

-(void)setUp{
    
}

+(Class)layerClass{
    return [CAEAGLLayer class];
}
-(void)setContext{
    self.context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!_context) {
        NSLog(@"no context");
        exit(1);
    }
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"set failed currentContxt");
        exit(1);
    }
}
-(void)setLayer{
    self.myLayer = (CAEAGLLayer*)self.layer;
    self.myLayer.opaque = YES;
}
-(void)setFrameBuffer{
    GLuint buffer;
    glGenFramebuffers(1, &buffer);
    self.colorFramerBuffer = buffer;
    glBindFramebuffer(GL_FRAMEBUFFER, self.colorFramerBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.colorFramerBuffer);
}
-(void)setRenderBuffer{
    GLuint buffer;
    glGenRenderbuffers(1, &buffer);
    self.colorRenderBuffer = buffer;
    glBindRenderbuffer(GL_RENDERBUFFER, self.colorRenderBuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myLayer];
}
-(void)destoryRenderAndFrameBuffer{
    glDeleteFramebuffers(1, &_colorFramerBuffer);
    _colorFramerBuffer = 0;
    glDeleteBuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
}
-(void)render{
    
}
-(void)compileShader{
    
}

-(GLuint)setUpTextre:(NSString*)fileName{
    
    
    
    return 1;
}



@end
