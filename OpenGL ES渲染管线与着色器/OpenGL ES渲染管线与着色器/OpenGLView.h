//
//  OpenGLView.h
//  OpenGL ES渲染管线与着色器
//
//  Created by lz on 2018/8/23.
//  Copyright © 2018 lz. All rights reserved.
//

#import <UIKit/UIKit.h>
@import OpenGLES;

@interface OpenGLView : UIView
{
    CAEAGLLayer*_eaglayer;
    EAGLContext*_contex;
    GLuint _colorRenderBuffer;
    GLuint _frameBuffer;
    
    GLuint _programHandle;
    GLuint _positionSlot;
}
@end
