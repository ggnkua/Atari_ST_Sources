
void APIENTRY ldg_glArrayElement( long  i )
{
#ifdef SCRIPT
		script( "glArrayElement(%ld);",i);
#endif	
	glArrayElement( (GLint) i );
}
void APIENTRY ldg_glBindTexture( long  target, unsigned long  texture )
{
#ifdef SCRIPT
		script( "glBindTexture(%ld,%ld);",target,texture);
#endif
	glBindTexture( (GLenum) target, (GLuint) texture );
}
void APIENTRY ldg_glCallList( unsigned long  list )
{
#ifdef SCRIPT
		script( "glCallList(%ld);",list);
#endif
	glCallList( (GLuint) list );
}
void APIENTRY ldg_glClearDepth( float  depth )
{
#ifdef SCRIPT
		script( "glClearDepth(%f);",depth);
#endif
	glClearDepth(  depth );
}
void APIENTRY ldg_glColor4f( GLfloat  red, GLfloat  green, GLfloat  blue, GLfloat  alpha )
{
#ifdef SCRIPT
		script( "glColor4f(%f,%f,%f,%f);",red,green,blue,alpha);
#endif
	glColor4f( (GLfloat) red, (GLfloat) green, (GLfloat) blue, (GLfloat) alpha );
}
void APIENTRY ldg_glColor3fv(  GLfloat *v )
{
#ifdef SCRIPT
		script( "glColor3f(%f,%f,%f);",v[0],v[1],v[2]);
#endif
	glColor3fv(  (GLfloat *)v );
}
void APIENTRY ldg_glColor4fv(  GLfloat *v )
{
#ifdef SCRIPT
		script( "glColor4f(%f,%f,%f,%f);",v[0],v[1],v[2],v[4]);
#endif
	glColor4fv(  (GLfloat *)v );
}
void APIENTRY ldg_glColorMaterial( long  face, long  mode )
{
#ifdef SCRIPT
		script( "glColorMaterial(%ld,%ld);",face, mode);
#endif
	glColorMaterial( (GLenum) face, (GLenum) mode );
}
void APIENTRY ldg_glColorPointer( long  size, long  type, long  stride,
					  GLvoid *ptr )
{
	glColorPointer( (GLint) size, (GLenum) type, (GLsizei) stride,
					  (GLvoid *)ptr );
}
void APIENTRY ldg_glCullFace( long  mode )
{
#ifdef SCRIPT
		script( "glCullFace(%ld);",mode);
#endif
	glCullFace( (GLenum) mode );
}
void APIENTRY ldg_glDeleteTextures( long  n,  unsigned long *textures)
{
	glDeleteTextures( (GLsizei) n,  (GLuint *)textures);
}
void APIENTRY ldg_glDisableClientState( long  cap )
{
#ifdef SCRIPT
		script( "glDisableClientState(%ld);",cap);
#endif
	glDisableClientState( (GLenum) cap );
}
void APIENTRY ldg_glEnableClientState( long  cap )
{
#ifdef SCRIPT
		script( "glEnableClientState(%ld);",cap);
#endif
	glEnableClientState( (GLenum) cap );
}
void APIENTRY ldg_glEndList( void  )
{
#ifdef SCRIPT
		script( "glEndList();");
#endif
	glEndList();
}
void APIENTRY ldg_glEdgeFlag( unsigned long  flag )
{
#ifdef SCRIPT
		script( "glEdgeFlag(%ld);",flag);
#endif
	glEdgeFlag( (GLboolean) flag );
}
void APIENTRY ldg_glFlush( void  )
{
#ifdef SCRIPT
		script( "glFlush();");
#endif
	glFlush();
}
void APIENTRY ldg_glFrontFace( long  mode )
{
#ifdef SCRIPT
		script( "glFrontFace(%ld);",mode);
#endif
	glFrontFace( (GLenum) mode );
}
void APIENTRY ldg_glFrustum( float  left, float  right,
                         float  bottom, float  top,
                         float  nearval, float  farval )
{
#ifdef SCRIPT
		script( "glFrustrum(%f,%f,%f,%f,%f,%f);",left,right,bottom,top,nearval,farval);
#endif
	glFrustum( (GLdouble) left, (GLdouble) right,
                         (GLdouble) bottom, (GLdouble) top,
                         (GLdouble) nearval, (GLdouble) farval );
}
unsigned long APIENTRY ldg_glGenLists( long  range )
{
#ifdef SCRIPT
		script( "glGenLists(%ld);",range);
#endif
	return(glGenLists( (GLsizei) range ));
}
void APIENTRY ldg_glGenTextures( long  n, unsigned long *textures )
{
	glGenTextures( (GLsizei) n, (GLuint *)textures );
}
void APIENTRY ldg_glGetFloatv( long  pname, GLfloat *params )
{
	glGetFloatv( (GLenum) pname, (GLfloat *)params );
}
void APIENTRY ldg_glGetIntegerv( long  pname, long *params )
{
	glGetIntegerv( (GLenum) pname, (GLint *)params );
}
void APIENTRY ldg_glHint( long  target, long  mode )
{
#ifdef SCRIPT
		script( "glHint(%ld,%ld);",target,mode);
#endif
	glHint( (GLenum) target, (GLenum) mode );
}
void APIENTRY ldg_glInitNames( void  )
{
#ifdef SCRIPT
		script( "glInitNames();");
#endif
	glInitNames();
}
unsigned long APIENTRY ldg_glIsList( unsigned long  list )
{
#ifdef SCRIPT
		script( "glIsList(%ld);",list);
#endif
	return(glIsList( (GLuint) list ));
}
void APIENTRY ldg_glLightf( long  light, long  pname, GLfloat  param )
{
#ifdef SCRIPT
		script( "glLightf(%ld,%ld,%f);",light,pname,param);
#endif
	glLightf( (GLenum) light, (GLenum) pname, (GLfloat) param );
}
void APIENTRY ldg_glLightModeli( long  pname, long  param )
{
#ifdef SCRIPT
		script( "glLightModeli(%ld,%ld);",pname,param);
#endif
	glLightModeli( (GLenum) pname, (GLint) param );
}
void APIENTRY ldg_glLightModelfv( long  pname,  GLfloat *params )
{
	glLightModelfv( (GLenum) pname,  (GLfloat *)params );
}
void APIENTRY ldg_glLoadMatrixf(  GLfloat *m )
{
	glLoadMatrixf(  (GLfloat *)m );
}
void APIENTRY ldg_glNewList( unsigned long  list, long  mode )
{
#ifdef SCRIPT
		script( "glNewList(%ld,%ld);",list,mode);
#endif
	glNewList( (GLuint) list, (GLenum) mode );
}
void APIENTRY ldg_glNormal3f( GLfloat  nx, GLfloat  ny, GLfloat  nz )
{
#ifdef SCRIPT
		script( "glNormal3f(%f,%f,%f);",nx,ny,nz);
#endif
	glNormal3f( (GLfloat) nx, (GLfloat) ny, (GLfloat) nz );
}
void APIENTRY ldg_glNormal3fv(  GLfloat *v )
{
#ifdef SCRIPT
		script( "glNormal3f(%f,%f,%f);",v[0],v[1],v[2]);
#endif
	glNormal3fv(  (GLfloat *)v );
}
void APIENTRY ldg_glNormalPointer( long  type, long  stride,  GLvoid *ptr )
{
	glNormalPointer( (GLenum) type, (GLsizei) stride,  (GLvoid *)ptr );
}
void APIENTRY ldg_glPixelStorei( long  pname, long  param )
{
#ifdef SCRIPT
		script( "glPixelStorei(%ld,%ld);",pname,param);
#endif
	glPixelStorei( (GLenum) pname, (GLint) param );
}
void APIENTRY ldg_glPolygonMode( long  face, long  mode )
{
#ifdef SCRIPT
		script( "glPolygonMode(%ld,%ld);",face,mode);
#endif
	glPolygonMode( (GLenum) face, (GLenum) mode );
}
void APIENTRY ldg_glPolygonOffset( GLfloat  factor, GLfloat  units )
{
#ifdef SCRIPT
		script( "glPolygonOffset(%ld,%ld);",factor,units);
#endif
	glPolygonOffset( (GLfloat) factor, (GLfloat) units );
}
void APIENTRY ldg_glPopName( void  )
{
#ifdef SCRIPT
		script( "glPopName();");
#endif
	glPopName();
}
void APIENTRY ldg_glPushName( unsigned long  name )
{
#ifdef SCRIPT
		script( "glPushName();");
#endif
	glPushName( (GLuint) name );
}
long APIENTRY ldg_glRenderMode( long  mode )
{
#ifdef SCRIPT
		script( "glRenderMode(%ld);",mode);
#endif
	return(glRenderMode( (GLenum) mode ));
}
void APIENTRY ldg_glSelectBuffer( long  size, unsigned long *buffer )
{
	glSelectBuffer( (GLsizei) size, (GLuint *)buffer );
}
void APIENTRY ldg_glScalef( GLfloat  x, GLfloat  y, GLfloat  z )
{
#ifdef SCRIPT
		script( "glScalef(%f,%f,%f);",x,y,z);
#endif
	glScalef( (GLfloat) x, (GLfloat) y, (GLfloat) z );
}
void APIENTRY ldg_glShadeModel( long  mode )
{
#ifdef SCRIPT
		script( "glShadeModel(%ld);",mode);
#endif
	glShadeModel( (GLenum) mode );
}
void APIENTRY ldg_glTexCoord2f( GLfloat  s, GLfloat  t )
{
#ifdef SCRIPT
		script( "glTexCoord2f(%f,%f);",s,t);
#endif
	glTexCoord2f( (GLfloat) s, (GLfloat) t );
}
void APIENTRY ldg_glTexCoord4f( GLfloat  s, GLfloat  t, GLfloat  r, GLfloat  q )
{
#ifdef SCRIPT
		script( "glTexCoord4f(%f,%f,%f,%f);",s,t,r,q);
#endif
	glTexCoord4f( (GLfloat) s, (GLfloat) t, (GLfloat) r, (GLfloat) q );
}
void APIENTRY ldg_glTexCoord2fv(  GLfloat *v )
{
#ifdef SCRIPT
		script( "glTexCoord2f(%f,%f);",v[0],v[1]);
#endif
	glTexCoord2fv(  (GLfloat *)v );
}
void APIENTRY ldg_glTexCoordPointer( long  size, long  type, long  stride,
                         GLvoid *ptr )
{
	glTexCoordPointer( (GLint) size, (GLenum) type, (GLsizei) stride,
                         (GLvoid *)ptr );
}
void APIENTRY ldg_glTexImage2D( long  target, long  level, long  internalformat,
                            long  width, long  height, long  border,
                            long  format, long  type,  GLvoid *pixels )
{
	glTexImage2D( (GLenum) target, (GLint) level, (GLint) internalformat,
                            (GLsizei) width, (GLsizei) height, (GLint) border,
                            (GLenum) format, (GLenum) type,  (GLvoid *)pixels );
}
void APIENTRY ldg_glVertex4f( GLfloat  x, GLfloat  y, GLfloat  z, GLfloat  w )
{
#ifdef SCRIPT
		script( "glVertex4f(%f,%f,%f,%f);",x,y,z,w);
#endif
	glVertex4f( (GLfloat) x, (GLfloat) y, (GLfloat) z, (GLfloat) w );
}
void APIENTRY ldg_glVertex3fv(  GLfloat *v )
{
#ifdef SCRIPT
		script( "glVertex3f(%f,%f,%f);",v[0],v[1],v[2]);
#endif
	glVertex3fv(  (GLfloat *)v );
}
void APIENTRY ldg_glVertexPointer( long  size, long  type, long  stride,
                                GLvoid *ptr )
{
	glVertexPointer( (GLint) size, (GLenum) type, (GLsizei) stride,
                                (GLvoid *)ptr );
}
void APIENTRY ldg_glViewport( long  x, long  y, long  width, long  height )
{
#ifdef SCRIPT
		script( "glViewport(%ld,%ld,%ld,%ld);",x,y,width,height);
#endif
	glViewport( (GLint) x, (GLint) y, (GLsizei) width, (GLsizei) height );
}
void APIENTRY ldg_glLoadName( unsigned long  name )
{
#ifdef SCRIPT
		script( "glLoadName(%ld);",name);
#endif
	glLoadName( (GLuint) name );
}
void APIENTRY ldg_glMaterialf( long  face, long  pname, GLfloat  param )
{
#ifdef SCRIPT
		script( "glMaterialf(%ld,%ld,%f);",face,pname,param);
#endif
	glMaterialf( (GLenum) face, (GLenum) pname, (GLfloat) param );
}
void APIENTRY ldg_glMultMatrixf(  GLfloat *m )
{
	glMultMatrixf(  (GLfloat *)m );
}
