//
//  OpenGLView.h
//  demo-3D变换实践
//
//  Created by lz on 2018/8/26.
//  Copyright © 2018 lz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/glext.h>
#include <OpenGLES/ES2/gl.h>
#import "ksMatrix.h"

@interface OpenGLView : UIView{
    CAEAGLLayer*_eaglLayer;
    EAGLContext*_context;
    GLuint _colorRenderBuffer;
    GLuint _frameBuffer;
    
    GLuint _programHandle;
    GLuint _positionSlot;
    GLuint _modelViewSlot;
    GLuint _prjectionSlot;
    
    ksMatrix4 _modelViewMatrix; //模型矩阵  ksMatrix4 表示4*4的二维数组表示的矩阵
    ksMatrix4 _projectionMatrix; //投影矩阵
    
    float _posX;
    float _posY;
    float _posZ;
    
    float _rotateX;
    float _scaleZ;
 
}

@property (nonatomic, assign) float posX;
@property (nonatomic, assign) float posY;
@property (nonatomic, assign) float posZ;

@property (nonatomic, assign) float scaleZ;
@property (nonatomic, assign) float rotateX;

- (void)resetTransform;
- (void)render;
- (void)cleanup;
- (void)toggleDisplayLink;


@end
