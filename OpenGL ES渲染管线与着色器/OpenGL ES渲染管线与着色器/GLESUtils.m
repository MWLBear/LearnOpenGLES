//
//  GLESUtils.m
//  OpenGL ES渲染管线与着色器
//
//  Created by lz on 2018/8/23.
//  Copyright © 2018 lz. All rights reserved.
//

#import "GLESUtils.h"

@implementation GLESUtils
+(GLuint)loadShader:(GLenum)type withString:(NSString *)shaderSting{
    
    //creat the shader object
    GLuint shader = glCreateShader(type);
    if (shader == 0) {
        NSLog(@"Error: failed to create shader");
        return 0;
    }
    //load the shader source
    const char *shaderStringUTF8 = [shaderSting UTF8String];
    glShaderSource(shader, 1, &shaderStringUTF8, NULL);
    //complie the shader
    glCompileShader(shader);
    
    //check the compile shader
    GLint compiled = 0;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    if (!compiled) {
        GLint infoLen = 0;
        glGetShaderiv ( shader, GL_INFO_LOG_LENGTH, &infoLen );
        if (infoLen>1) {
            char*infoLog = malloc(sizeof(char)*infoLen);
            glGetShaderInfoLog(shader, infoLen, NULL, infoLog);
            NSLog(@"Error compiling shader:\n%s\n", infoLog );
            free(infoLog);
        }
        glDeleteShader(shader);
        return 0;
    }
    return  shader;
}

+(GLuint)loadShader:(GLenum)type withFilePath:(NSString *)shaderFilePath{
    NSError*error;
    NSString*shaderSring = [NSString stringWithContentsOfFile:shaderFilePath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderSring) {
        NSLog(@"Error: loading shader file:%@ %@",shaderFilePath,error.localizedDescription);
        return 0;
    }
    return [self loadShader:type withString:shaderSring];
}
@end
