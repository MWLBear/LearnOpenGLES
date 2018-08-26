//
//  GLESUtils.m
//  demo-3D变换实践
//
//  Created by lz on 2018/8/26.
//  Copyright © 2018 lz. All rights reserved.
//

#import "GLESUtils.h"
@implementation GLESUtils

+(GLuint)loaderShader:(GLenum)type withFilePath:(NSString *)shaderPath{
    NSError*error;
    NSString*str = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!str) {
        NSLog(@"loader shader file :%@ %@",str,error.localizedDescription);
        return 0;
    }
    return [self loadShader:type witString:str];
}

+(GLuint)loadShader:(GLenum)type witString:(NSString *)shaderString{
    GLuint shader = glCreateShader(type);
    const char* shaderSringUTDF8 = [shaderString UTF8String];
    glShaderSource(shader, 1, &shaderSringUTDF8, NULL);
    
    //compile the shader
    glCompileShader(shader);
    //check the compile status
    GLint complied = 0;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &complied);
    if (!complied) {
        GLint infoLen = 0;
        
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen>1) {
            char*infLog = malloc(sizeof(char)*infoLen);
            glGetShaderInfoLog(shader, infoLen, NULL, infLog);
            NSLog(@"Error compling shader:\n%s\n",infLog);
            free(infLog);
        }
        glDeleteShader(shader);
        return 0;
    }
    return shader;
}

+(GLuint)loadProgrammer:(NSString *)vertexShaderFile withFragmentShaderFilePath:(NSString *)fragmentShaderFilePath{
    GLuint vertexShader = [self loaderShader:GL_VERTEX_SHADER withFilePath:vertexShaderFile];
    GLuint fragmentShader = [self loaderShader:GL_FRAGMENT_SHADER withFilePath:fragmentShaderFilePath];
    
    if (vertexShader == 0 || fragmentShader == 0) {
        return 0;
    }
    
    GLuint programHandle = glCreateProgram();
    if (programHandle == 0) {
        return 0;
    }
    
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    // Check the link status
    GLint linked;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linked);
    
    if (!linked) {
        GLint infoLen = 0;
        glGetProgramiv(programHandle, GL_INFO_LOG_LENGTH, &infoLen);
        
        if (infoLen > 1){
            char * infoLog = malloc(sizeof(char) * infoLen);
            glGetProgramInfoLog(programHandle, infoLen, NULL, infoLog);
            
            NSLog(@"Error linking program:\n%s\n", infoLog);
            
            free(infoLog);
        }
        
        glDeleteProgram(programHandle );
        return 0;
    }
    
    // Free up no longer needed shader resources
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    
    return programHandle;
}












@end
