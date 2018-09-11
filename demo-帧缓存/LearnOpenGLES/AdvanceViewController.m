//
//  AdvanceViewController.m
//  LearnOpenGLES
//
//  Created by 林伟池 on 16/3/25.
//  Copyright © 2016年 林伟池. All rights reserved.
//

#import "AdvanceViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"

#define const_length 512

@interface AdvanceViewController ()


@property (nonatomic , strong) EAGLContext* mContext;

@property (nonatomic , strong) GLKBaseEffect* mBaseEffect;
@property (nonatomic , strong) GLKBaseEffect* mExtraEffect;

@property (nonatomic , assign) int mCount;

@property (nonatomic , assign) GLint mDefaultFBO;
@property (nonatomic , assign) GLuint mExtraFBO;
@property (nonatomic , assign) GLuint mExtraDepthBuffer;
@property (nonatomic , assign) GLuint mExtraTexture;

@property (nonatomic , assign) long mBaseRotate;
@property (nonatomic , assign) long mExtraRotate;

@property (nonatomic , strong) IBOutlet UISwitch* mBaseSwitch;//外面
@property (nonatomic , strong) IBOutlet UISwitch* mExtraSwitch;//里面
@end



@implementation AdvanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //新建OpenGLES 上下文
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    GLKView* view = (GLKView *)self.view;
    view.context = self.mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [EAGLContext setCurrentContext:self.mContext];
    
    
    //顶点数据，前三个是顶点坐标， 中间三个是顶点颜色，    最后两个是纹理坐标
    GLfloat attrArr[] =
    {
        -1.0f, 1.0f, 0.0f,      0.0f, 0.0f, 1.0f,       0.0f, 1.0f,//左上
        1.0f, 1.0f, 0.0f,       0.0f, 1.0f, 0.0f,       1.0f, 1.0f,//右上
        -1.0f, -1.0f, 0.0f,     1.0f, 0.0f, 1.0f,       0.0f, 0.0f,//左下
        1.0f, -1.0f, 0.0f,      0.0f, 0.0f, 1.0f,       1.0f, 0.0f,//右下
        0.0f, 0.0f, 1.0f,       1.0f, 1.0f, 1.0f,       0.5f, 0.5f,//顶点
    };
    //顶点索引
    GLuint indices[] =
    {
        0, 3, 2,
        0, 1, 3,
        //可以去掉注释
//        0, 2, 4,
//        0, 4, 1,
//        2, 3, 4,
//        1, 4, 3,
    };
    self.mCount = sizeof(indices) / sizeof(GLuint);
    
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_STATIC_DRAW);
    
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL);

    //可以去掉注释
//    glEnableVertexAttribArray(GLKVertexAttribColor);
//    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, 4 * 8, (GLfloat *)NULL + 3);
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 4 * 8, (GLfloat *)NULL + 6);
    
    
    self.mBaseEffect = [[GLKBaseEffect alloc] init];
    self.mExtraEffect = [[GLKBaseEffect alloc] init];

    glEnable(GL_DEPTH_TEST);
    
    [self preparePointOfViewWithAspectRatio:
     CGRectGetWidth(self.view.bounds) / CGRectGetHeight(self.view.bounds)];
    

    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"for_test" ofType:@"png"];
    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];

    GLKTextureInfo* textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    self.mExtraEffect.texture2d0.enabled = self.mBaseEffect.texture2d0.enabled = GL_TRUE;
    self.mExtraEffect.texture2d0.name = self.mBaseEffect.texture2d0.name = textureInfo.name;
    NSLog(@"panda texture %d", textureInfo.name);
    
    int width, height;
    
    //指定纹理图像的宽度，必须是2的n次方。纹理图片至少要支持64个材质元素的宽度
    width = self.view.bounds.size.width * self.view.contentScaleFactor;
    height = self.view.bounds.size.height * self.view.contentScaleFactor;
    [self extraInitWithWidth:width height:height]; //特别注意这里的大小
    
    self.mBaseRotate = self.mExtraRotate = 0;
}


//MVP矩阵
- (void)preparePointOfViewWithAspectRatio:(GLfloat)aspectRatio
{
    self.mExtraEffect.transform.projectionMatrix = self.mBaseEffect.transform.projectionMatrix =
    GLKMatrix4MakePerspective(
                              GLKMathDegreesToRadians(85.0f),
                              aspectRatio,
                              0.1f,
                              20.0f);
    
    self.mExtraEffect.transform.modelviewMatrix = self.mBaseEffect.transform.modelviewMatrix =
    GLKMatrix4MakeLookAt(
                         0.0, 0.0, 3.0,   // Eye position
                         0.0, 0.0, 0.0,   // Look-at position
                         0.0, 1.0, 0.0);  // Up direction
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
//把纹理对象关联到帧缓存
- (void)extraInitWithWidth:(GLint)width height:(GLint)height {

    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &_mDefaultFBO);
    glGenTextures(1, &_mExtraTexture);
    NSLog(@"render texture %d", self.mExtraTexture);
    glGenFramebuffers(1, &_mExtraFBO);
    glGenRenderbuffers(1, &_mExtraDepthBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, self.mExtraFBO);
    glBindTexture(GL_TEXTURE_2D, self.mExtraTexture);
    
    //glTexImage2D—— 指定一个二维的纹理图片
//    target     指定目标纹理，这个值必须是GL_TEXTURE_2D。
//    level       执行细节级别。0是最基本的图像级别，你表示第N级贴图细化级别。
//    internalformat     指定纹理中的颜色组件，这个取值和后面的format取值必须相同。可选的值有
//    GL_ALPHA,
//    GL_RGB,
//    GL_RGBA,
//    GL_LUMINANCE,
//    GL_LUMINANCE_ALPHA 等几种。
//    width     指定纹理图像的宽度，必须是2的n次方。纹理图片至少要支持64个材质元素的宽度
//    height     指定纹理图像的高度，必须是2的m次方。纹理图片至少要支持64个材质元素的高度
//    border    指定边框的宽度。必须为0。
//    format    像素数据的颜色格式，必须和internalformatt取值必须相同。可选的值有
//    GL_ALPHA,
//    GL_RGB,
//    GL_RGBA,
//    GL_LUMINANCE,
//    GL_LUMINANCE_ALPHA 等几种。
//    type        指定像素数据的数据类型。可以使用的值有
//    GL_UNSIGNED_BYTE,
//    GL_UNSIGNED_SHORT_5_6_5,
//    GL_UNSIGNED_SHORT_4_4_4_4,
//    GL_UNSIGNED_SHORT_5_5_5_1
 //   pixels      指定内存中指向图像数据的指针
    
    glTexImage2D(GL_TEXTURE_2D,
                 0,
                 GL_RGBA,
                 width,
                 height,
                 0,
                 GL_RGBA,
                 GL_UNSIGNED_BYTE,
                 NULL);
    //PS:纹理坐标系用S-T来表示，S为横轴，T为纵轴。
    
    //图象从纹理图象空间映射到帧缓冲图象空间(映射需要重新构造纹理图像,
    //这样就会造成应用到多边形上的图像失真),这时就可用glTexParmeteri()函数来确定如何把纹理象素映射成像素.
    
    
    // GL_TEXTURE_WRAP_S: S方向上的贴图模式.
    //GL_CLAMP_TO_EDGE：边界处采用纹理边缘自己的的颜色，和边框无关
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
     //  GL_TEXTURE_MAG_FILTER: 放大过滤
    //GL_TEXTURE_MIN_FILTER: 缩小过滤
    //GL_LINEAR: 线性过滤, 使用距离当前渲染像素中心最近的4个纹素加权平均值.
    // GL_LINEAR_MIPMAP_NEAREST: 使用GL_NEAREST对最接近当前多边形的解析度的两个层级贴图进行采样,然后用这两个值进行线性插值.
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

    //5、切换帧缓存为纹理对象
    glFramebufferTexture2D(GL_FRAMEBUFFER,
                           GL_COLOR_ATTACHMENT0,
                           GL_TEXTURE_2D, self.mExtraTexture, 0);
    

    glBindRenderbuffer(GL_RENDERBUFFER, self.mExtraDepthBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16,
                          width, height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, self.mExtraDepthBuffer);
    
    GLenum status;
    status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    switch(status) {
        case GL_FRAMEBUFFER_COMPLETE:
            NSLog(@"fbo complete width %d height %d", width, height);
            break;
            
        case GL_FRAMEBUFFER_UNSUPPORTED:
            NSLog(@"fbo unsupported");
            break;
            
        default:
            NSLog(@"Framebuffer Error");
            break;
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, self.mDefaultFBO);
    glBindTexture(GL_TEXTURE_2D, 0);
}


- (void)update
{
    GLKMatrix4 modelViewMatrix;
    if (self.mBaseSwitch.on) {
        ++self.mBaseRotate;
        modelViewMatrix = GLKMatrix4Identity;
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, -3);
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(self.mBaseRotate), 1, 1, 1);
        self.mBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    }
    
    if (self.mExtraSwitch.on) {
        self.mExtraRotate += 2;
        modelViewMatrix = GLKMatrix4Identity;
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, -3);
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(self.mExtraRotate), 1, 1, 1);
        self.mExtraEffect.transform.modelviewMatrix = modelViewMatrix;
    }
}

- (void)renderFBO {
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, self.mExtraFBO);
    
    //如果视口和主缓存的不同，需要根据当前的大小调整，同时在下面的绘制时需要调整glviewport
   // glViewport(0, 0, const_length, const_length);
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.mExtraEffect prepareToDraw];
    glDrawElements(GL_TRIANGLES, self.mCount, GL_UNSIGNED_INT, 0);
    
    glBindFramebuffer(GL_FRAMEBUFFER, self.mDefaultFBO);
    self.mBaseEffect.texture2d0.name = self.mExtraTexture;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [self renderFBO];
    
    [((GLKView *) self.view) bindDrawable];
    

//    glViewport() 见上面
    glClearColor(0.3, 0.3, 0.3, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    
    [self.mBaseEffect prepareToDraw];
    glDrawElements(GL_TRIANGLES, self.mCount, GL_UNSIGNED_INT, 0);
}


- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation !=
            UIInterfaceOrientationPortraitUpsideDown);
}

@end

