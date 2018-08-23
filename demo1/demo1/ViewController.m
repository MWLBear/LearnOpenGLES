//
//  ViewController.m
//  demo1
//
//  Created by lz on 2018/8/23.
//  Copyright © 2018年 lz. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property(nonatomic,strong)EAGLContext*myContext;
@property(nonatomic,strong)GLKBaseEffect*effect;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupConfing];
    [self setVeterData];
    [self uploadTexture];
}


-(void)setupConfing{
    self.myContext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView*view = (GLKView*)self.view;
    view.context = self.myContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    [EAGLContext setCurrentContext:self.myContext];
}

-(void)setVeterData{
    /*
     顶点数组里包括顶点坐标，OpenGLES的世界坐标系是[-1, 1]，故而点(0, 0)是在屏幕的正中间。
     纹理坐标系的取值范围是[0, 1]，原点是在左下角。故而点(0, 0)在左下角，点(1, 1)在右上角。
     */
    
    //顶点数据，前三个是顶点坐标（x、y、z轴），后面两个是纹理坐标（x，y）
    GLfloat squareVertexData[] =
    {
        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
        0.5, 0.5, -0.0f,    1.0f, 1.0f, //右上
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上

        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上
        -0.5, -0.5, 0.0f,   0.0f, 0.0f, //左下
        
//        1, -0.5, 0.0f, 0.0f, 0.0f, //右下
//        1, 0.5, -0.0f, 0.0f, 1.0f, //右上
//        0.0, 0.5, 0.0f, 1.0f, 1.0f, //中上
//        0.0, -0.5, 0.0f, 1.0f, 0.0f, //中下
//
//        -1, 0.5, 0.0f, 0.0f, 1.0f, //左上
//        -1, -0.5, 0.0f, 0.0f, 0.0f, //左下
//        0.0, -0.5, 0.0f, 1.0f, 0.0f, //中下
//        0.0, 0.5, 0.0f, 1.0f, 1.0f, //中上
    };
    
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    //把顶点数据从cpu内存复制到gpu内存
    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData), &squareVertexData, GL_STATIC_DRAW);
    
    //开启顶点属性
    glEnableVertexAttribArray(GLKVertexAttribPosition);//顶点数据
    //设置合适的格式从bufffer中读取数据
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat *)NULL + 0);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);//纹理
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat *)NULL + 3);
    
}
-(void)uploadTexture{
    NSString*path = [[NSBundle mainBundle]pathForResource:@"abd" ofType:@"jpeg"];
    NSLog(@"path = %@",path);
    NSDictionary*option = [NSDictionary dictionaryWithObjectsAndKeys:@(1),GLKTextureLoaderOriginBottomLeft, nil];//纹理坐标相反的
    GLKTextureInfo*textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:option error:nil];
    
    //着色器
    self.effect = [[GLKBaseEffect alloc]init];
    self.effect.texture2d0.enabled = GL_TRUE;
    self.effect.texture2d0.name = textureInfo.name;
}
//渲染场景代码
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    //状态设置
    glClearColor(0.3, 0.6, 1.0, 1.0);
    //状态应用
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    //启动着色器
    [self.effect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

@end
