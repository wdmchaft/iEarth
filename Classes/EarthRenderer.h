//
//  EarthRenderer.h
//  Earth
//
//  Created by Arman Uguray on 2/21/11.
//  Copyright 2011 Brown University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

typedef struct OrbitingCamera OrbitingCamera;

@interface EarthRenderer : NSObject {
	
	GLuint program, mv_loc, proj_loc;
	GLuint tex_index;
	
	GLuint day_texture, night_texture, clouds_texture;
	GLfloat *vertices; // holds both vertices and normals
	GLfloat *tex_coords;
	OrbitingCamera *m_camera;
	
	GLfloat mv[16], proj[16];
}

- (id)init;
- (void)loadTextures;
- (void)updateMatrices;
- (void)drawFrame;

- (void)dragX:(CGFloat)x Y:(CGFloat)y;
- (void)zoom:(CGFloat)delta;

@end