//
//  GLESUtils.h
//  OpenGL ES渲染管线与着色器
//
//  Created by lz on 2018/8/23.
//  Copyright © 2018 lz. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <OpenGLES/ES2/gl.h>
@interface GLESUtils : NSObject
+(GLuint)loadShader:(GLenum)type withString:(NSString*)shaderSting;
+(GLuint)loadShader:(GLenum)type withFilePath:(NSString *)shaderFilePath;
@end
