//
//  EarthRenderer.m
//  Earth
//
//  Created by Arman Uguray on 2/21/11.
//  Copyright 2011 Brown University. All rights reserved.
//

#import "EarthRenderer.h"
#import <QuartzCore/QuartzCore.h>
#include "OrbitingCamera.h"
#import "GLESFileLoader.h"

#define RES 50

@implementation EarthRenderer


- (id)init
{
	if (self = [super init]) {
		vertices = (GLfloat *)malloc(RES*RES*6*3*sizeof(GLfloat));
		tex_coords = (GLfloat *)malloc(RES*RES*6*2*sizeof(GLfloat));
		GLfloat lat,lon;
		GLfloat lat_incr = M_PI/RES;
		GLfloat lon_incr = 2*lat_incr;
		REAL u, v;
		lon = 0;
		int index = -1;
		int tindex = -1;
		for (int i = 0; i < RES; i++) {
			lat = 0;
			for (int j = 0; j < RES; j++) {
				// V1
				vertices[++index] = sin(lat)*cos(lon);
				vertices[++index] = cos(lat);
				vertices[++index] = sin(lat)*sin(lon);
				
				u = lon*0.5*M_1_PI;
				v = asin(vertices[index-1])*M_1_PI + 0.5;
				if (v == 0 || v == 1) u = 0.5;
				
				tex_coords[++tindex] = 1.f-u;
				tex_coords[++tindex] = 1.f-v;
				
				// V2			
				vertices[++index] = sin(lat+lat_incr)*cos(lon+lon_incr);
				vertices[++index] = cos(lat+lat_incr);
				vertices[++index] = sin(lat+lat_incr)*sin(lon+lon_incr);
				
				u = (lon+lon_incr)*0.5*M_1_PI;
				v = asin(vertices[index-1])*M_1_PI + 0.5;
				if (v == 0 || v == 1) u = 0.5;
				
				tex_coords[++tindex] = 1.f-u;
				tex_coords[++tindex] = 1.f-v;
				
				// V3
				vertices[++index] = sin(lat+lat_incr)*cos(lon);
				vertices[++index] = cos(lat+lat_incr);
				vertices[++index] = sin(lat+lat_incr)*sin(lon);
				
				u = lon*0.5*M_1_PI;
				v = asin(vertices[index-1])*M_1_PI + 0.5;
				if (v == 0 || v == 1) u = 0.5;
				
				tex_coords[++tindex] = 1.f-u;
				tex_coords[++tindex] = 1.f-v;
				
			
				// V4			
				vertices[++index] = sin(lat+lat_incr)*cos(lon+lon_incr);
				vertices[++index] = cos(lat+lat_incr);
				vertices[++index] = sin(lat+lat_incr)*sin(lon+lon_incr);
				
				u = (lon+lon_incr)*0.5*M_1_PI;
				v = asin(vertices[index-1])*M_1_PI + 0.5;
				if (v == 0 || v == 1) u = 0.5;
				
				tex_coords[++tindex] = 1.f-u;
				tex_coords[++tindex] = 1.f-v;
				
				// V5				
				vertices[++index] = sin(lat)*cos(lon);
				vertices[++index] = cos(lat);
				vertices[++index] = sin(lat)*sin(lon);
				
				u = lon*0.5*M_1_PI;
				v = asin(vertices[index-1])*M_1_PI + 0.5;
				if (v == 0 || v == 1) u = 0.5;
				
				tex_coords[++tindex] = 1.f-u;
				tex_coords[++tindex] = 1.f-v;
			
				// V6				
				vertices[++index] = sin(lat)*cos(lon+lon_incr);
				vertices[++index] = cos(lat);
				vertices[++index] = sin(lat)*sin(lon+lon_incr);
				
				u = (lon+lon_incr)*0.5*M_1_PI;
				v = asin(vertices[index-1])*M_1_PI + 0.5;
				if (v == 0 || v == 1) u = 0.5;
				
				tex_coords[++tindex] = 1.f-u;
				tex_coords[++tindex] = 1.f-v;
				

				lat += lat_incr;
			}
			lon += lon_incr;
		}
		
		program = [GLESFileLoader loadShaderNamed:@"Earth"];
		
		mv_loc = glGetUniformLocation(program, "mv");
		proj_loc = glGetUniformLocation(program, "proj");
		tex_index = glGetAttribLocation(program, "TextureCoord");
		
		glEnable(GL_TEXTURE_2D);
		glEnable(GL_CULL_FACE);
		glEnable(GL_BLEND);
		glEnable(GL_DEPTH_TEST);
		glBlendFunc(GL_ONE, GL_SRC_COLOR);
		
		m_camera = new OrbitingCamera();
		[self updateMatrices];
		
		[self loadTextures];
		
		
	}
	return self;
}

- (void)dragX:(CGFloat)x Y:(CGFloat)y
{
	m_camera->mouse_dragged(x,y);
	[self updateMatrices];
}

- (void)zoom:(CGFloat)delta
{
	m_camera->lookVectorTranslate(delta);
	[self updateMatrices];
}

- (void)updateMatrices
{
	m_camera->getModelviewMatrix().getTranspose().fillArray(mv);
	m_camera->getProjectionMatrix().getTranspose().fillArray(proj);
}

- (void)drawFrame
{
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	static float rot = 0;
	
	glUseProgram(program);
	
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, day_texture);
	glActiveTexture(GL_TEXTURE1);
	glBindTexture(GL_TEXTURE_2D, night_texture);
	glActiveTexture(GL_TEXTURE2);
	glBindTexture(GL_TEXTURE_2D, clouds_texture);
	glActiveTexture(GL_TEXTURE0);
		
	glUniformMatrix4fv(mv_loc, 1, GL_FALSE, mv);
	glUniformMatrix4fv(proj_loc, 1, GL_FALSE, proj);
	
	glUniform1f(glGetUniformLocation(program, "rot"), rot);
	rot += 0.01;
	
	glUniform3f(glGetUniformLocation(program, "LightPosition"), 3.0, 0.0, -3.0);
	glUniform1i(glGetUniformLocation(program, "EarthDay"), 0);
	glUniform1i(glGetUniformLocation(program, "EarthNight"), 1);
	glUniform1i(glGetUniformLocation(program, "EarthCloudGloss"), 2);

	glVertexAttribPointer(0, 3, GL_FLOAT, 0, 0, vertices);
	glEnableVertexAttribArray(0);
	glVertexAttribPointer(tex_index, 2, GL_FLOAT, GL_FALSE, 0, tex_coords);
	glEnableVertexAttribArray(tex_index);
	glDrawArrays(GL_TRIANGLES, 0, 6*RES*RES);	
	
	glUseProgram(0); 
}

- (void)loadTextures
{
	day_texture = [GLESFileLoader loadTextureNamed:@"Day.jpg"];
	night_texture = [GLESFileLoader loadTextureNamed:@"Night.jpg"];
	clouds_texture = [GLESFileLoader loadTextureNamed:@"Clouds.jpg"];
}

- (void)dealloc
{
	glDeleteTextures(1, &day_texture);
	glDeleteTextures(1, &night_texture);
	glDeleteTextures(1, &clouds_texture);
	if (program)
    {
        glDeleteProgram(program);
        program = 0;
    }
	delete m_camera;
	free(tex_coords);
	free(vertices);
	[super dealloc];
}

@end
