//
//  ViewController.m
//  demo - GLKit
//
//  Created by lz on 2018/9/4.
//  Copyright © 2018年 lz. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property(nonatomic,strong)EAGLContext*context;
@property(nonatomic,strong)GLKBaseEffect*effect;

@property(nonatomic,assign)int count;
@property(nonatomic,assign)float mDegreeX;
@property(nonatomic,assign)float mDegreeY;
@property(nonatomic,assign)float mDegreeZ;

@property(nonatomic,assign)BOOL mBoolX;
@property(nonatomic,assign)BOOL mBoolY;
@property(nonatomic,assign)BOOL mBoolZ;

@end

@implementation ViewController{
    dispatch_source_t timer;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    GLKView*view = (GLKView*)self.view;
    view.context = self.context;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:self.context];
    glEnable(GL_DEPTH_TEST);
    
    [self render];
    //[self renderNew];
}

-(void)render{
    GLfloat attrArr[] =
    {
        -0.5f, 0.5f, 0.0f,      0.0f, 0.0f, 0.5f,       0.0f, 1.0f,//左上
        0.5f, 0.5f, 0.0f,       0.0f, 0.5f, 0.0f,       1.0f, 1.0f,//右上
        -0.5f, -0.5f, 0.0f,     0.5f, 0.0f, 1.0f,       0.0f, 0.0f,//左下
        0.5f, -0.5f, 0.0f,      0.0f, 0.0f, 0.5f,       1.0f, 0.0f,//右下
        0.0f, 0.0f, 1.0f,       1.0f, 1.0f, 1.0f,       0.5f, 0.5f,//顶点
    };
    GLuint indices[] =
    {
        0, 3, 2,
        0, 1, 3,
        0, 2, 4,
        0, 4, 1,
        2, 3, 4,
        1, 4, 3,
        0, 4 ,3,
    };
    self.count = sizeof(indices)/sizeof(GLuint);
    
    //顶点
    GLuint vertex;
    glGenBuffers(1, &vertex);
    glBindBuffer(GL_ARRAY_BUFFER, vertex);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_STATIC_DRAW);
    
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (GLfloat*)NULL);
    
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, 4*8, (GLfloat*)NULL+3);
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 4*8, (GLfloat*)NULL+6);
   

    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"for_test" ofType:@"png"];
    NSLog(@"fliePaht = %@",filePath);
    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];

  //  NSDictionary*options = [NSDictionary dictionaryWithObjectsAndKeys:@(1),GLKTextureInfoOriginTopLeft ,nil];
    GLKTextureInfo *textInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
   
    
    
    
    //着色器
    self.effect = [[GLKBaseEffect alloc]init];
    self.effect.texture2d0.enabled = GL_TRUE;
    self.effect.texture2d0.name = textInfo.name;
    //投影
    
    CGSize size = self.view.bounds.size;
    float aspect = fabs(size.width/size.height);
    GLKMatrix4 projectionMatrix4 = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1, 10.0);
    projectionMatrix4 = GLKMatrix4Scale(projectionMatrix4,1.0, 1.0, 1.0);
    self.effect.transform.projectionMatrix = projectionMatrix4;
    
    GLKMatrix4 modelMatrix4 = GLKMatrix4Translate(GLKMatrix4Identity, 0, 0, -2.0);
    self.effect.transform.modelviewMatrix = modelMatrix4;
    
    //定时器
    double delaySeconds = 0.1;
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, delaySeconds*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
          self.mDegreeX += 0.1 * self.mBoolX;
          self.mDegreeY += 0.1 * self.mBoolY;
          self.mDegreeZ += 0.1 * self.mBoolZ;
    });
    dispatch_resume(timer);
    
}

-(void)update{
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -2.0f);
    
    modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, self.mDegreeX);
    modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, self.mDegreeY);
    modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, self.mDegreeZ);
    
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    
}
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.3, 0.3, 0.3, 1.0);
    glClear(GL_DEPTH_BUFFER_BIT|GL_COLOR_BUFFER_BIT);
    
    [self.effect prepareToDraw];
    glDrawElements(GL_TRIANGLES, self.count, GL_UNSIGNED_INT, 0);
}

- (IBAction)onX:(id)sender {
    self.mBoolX = !self.mBoolX;
}

- (IBAction)onY:(id)sender {
    self.mBoolY = !self.mBoolY;

}

- (IBAction)onZ:(id)sender {
    self.mBoolZ = !self.mBoolZ;

}

@end
