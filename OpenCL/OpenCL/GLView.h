//
//  GLView.h
//  OpenCL
//
//  Created by lz on 2018/8/22.
//  Copyright © 2018年 lz. All rights reserved.
//

#import <UIKit/UIKit.h>

//顶点结构体
typedef struct {
    float position[4];
    float color[4];
}CustomVertex;

enum
{
    ATTRIBUTE_POSITION = 0,
    ATTRIBUTE_COLOR,
    NUM_ATTRIBUTES
};
GLint glViewAttributes[NUM_ATTRIBUTES];

@interface GLView : UIView
{
    CAEAGLLayer*_eagLyer;
    EAGLContext*_context;
    GLuint    _framebuffer;
    GLuint   _renderbuffer;
    
     CGSize       _oldSize;
}

@end
