//
//  GLESUtils.h
//  demo-3D变换实践
//
//  Created by lz on 2018/8/26.
//  Copyright © 2018 lz. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <OpenGLES/ES2/gl.h>
@interface GLESUtils : NSObject

+(GLuint)loadShader:(GLenum)type witString:(NSString*)shaderString;
+(GLuint)loaderShader:(GLenum)type withFilePath:(NSString*)shaderPath;
+(GLuint)loadProgrammer:(NSString*)vertexShaderFile withFragmentShaderFilePath:(NSString*)fragmentShaderFilePath;
@end
