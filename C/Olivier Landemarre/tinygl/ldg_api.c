/*#include "config.h"*/
#include "GL/mesa_ldg.h"
#include "GL/glx.h"

#include <math.h>
#include "mem.h"
#include <osbind.h>
/*#define DEBUG 1 */ 
#define APIENTRY 
void **monimg=0L;
/* project.c */
void _ldg_debug(char *pt)
{long fp;  static int first=1;
	
	if(first)
	{
		fp=Fcreate("c:\\debug.txt",0);
		first=0;
	}
	else
	{
		fp=Fopen("c:\\debug.txt",2);
		Fseek(0,fp,2);
	}
	if(fp>=0L)
	{
		Fwrite(fp,(long)strlen(pt),pt);
		Fclose(fp);
	}
	
}
#include <stdarg.h>
#ifdef __STDC__
__EXTERN void script __PROTO(( const char *fmt, ...))
#else
_EXTERN void script __PROTO((const char *fmt))
#endif
{  static long fp=-1L;  va_list argp; static char buf[500];
	
	if(fp==-1L)
	{
		fp=Fcreate("c:\\scrptiny.c",0);
	}
	if(fmt==NULL)
	{
		Fclose(fp);
		fp=-1L;	
	}
	else
	if(fp>=0L)
	{
		va_start(argp, fmt); 
		vsprintf(buf,fmt,argp);
		strcat(buf,"\015\012");
		Fwrite(fp,(long)strlen(buf),buf);
	}	
}
void APIENTRY exception_error(void (*exception)(long param))
{
	error_except=exception;
}
 
long APIENTRY max_width(void)  /* informe sur la largeur maximale de l'image */
{
	return((long)3000);
}
long APIENTRY max_height(void)  /* informe sur la hauteur maximale de l'image */
{
	return((long)3000);
}
void APIENTRY ldg_glLightfv( long light, long pname, float *params )
{
   glLightfv( (GLenum) light, (GLenum) pname, (GLfloat *)params );
}
void APIENTRY ldg_glEnd( void )
{
#ifdef SCRIPT
		script( "glEnd();");
#endif
   glEnd();
}
void APIENTRY ldg_glEnable( long cap )
{
#ifdef SCRIPT
		script( "glEnable(%ld);",cap);
#endif
   glEnable( (GLenum) cap );
}
void APIENTRY ldg_glMatrixMode( long mode )
{
#ifdef SCRIPT
		script( "glMatrixMode(%ld);",mode);
#endif
   glMatrixMode( (GLenum) mode );
}
void APIENTRY ldg_glLoadIdentity( void )
{
#ifdef SCRIPT
		script("gere_tout(); /* Gem, resize et redraw par cette fonction */");
		script( "glLoadIdentity();");
		script("oriente_tout(); /* rotations translations si l'on veut */");
#endif
   glLoadIdentity();
}
void APIENTRY glOrtho( GLdouble left, GLdouble right,
                       GLdouble bottom, GLdouble top,
                       GLdouble nearval, GLdouble farval )
{
   float x, y, z;
   float tx, ty, tz;
   float m[16];
   x = 2.0 / (right-left);
   y = 2.0 / (top-bottom);
   z = -2.0 / (farval-nearval);
   tx = -(right+left) / (right-left);
   ty = -(top+bottom) / (top-bottom);
   tz = -(farval+nearval) / (farval-nearval);
#define M(row,col)  m[(col<<2)+row] 
   m[0] = x;     m[4] = 0.0F;  m[8] = 0.0F;   m[12] = tx;
   m[1] = 0.0F;  m[5] = y;     m[9] = 0.0F;   m[13] = ty;
   m[2] = 0.0F;  m[6] = 0.0F;  m[10] = z;     m[14] = tz;
   m[3] = 0.0F;  m[7] = 0.0F;  m[11] = 0.0F;  m[15] = 1.0F;
#undef M
   glMultMatrixf( m );
}
void APIENTRY ldg_glOrtho( float left, float right,
                       float bottom, float top,
                       float nearval, float farval )
{
#ifdef SCRIPT
		script( "glOrtho(%f,%f,%f,%f,%f,%f);",left,right,bottom,top,nearval,farval);
#endif
   glOrtho( (GLdouble) left, (GLdouble) right,
            (GLdouble) bottom, (GLdouble) top,
            (GLdouble) nearval, (GLdouble) farval );
}
void APIENTRY gluLookAt( float eyex, float eyey, float eyez,
                         float centerx, float centery, float centerz,
                         float upx, float upy, float upz )
{
   float m[16];
   float x[3], y[3], z[3];
   float mag;
#ifdef SCRIPT
		script( "glLookAt(%f,%f,%f,%f,%f,%f,%f,%f,%f);",eyex,eyey,eyez,centerx,centery,centerz,upx,upy,upz);
#endif
   /* Make rotation matrix */
   /* Z vector */
   z[0] = eyex - centerx;
   z[1] = eyey - centery;
   z[2] = eyez - centerz;
   mag = sqrt( z[0]*z[0] + z[1]*z[1] + z[2]*z[2] );
   if (mag) {  /* mpichler, 19950515 */
      z[0] /= mag;
      z[1] /= mag;
      z[2] /= mag;
   }
   /* Y vector */
   y[0] = upx;
   y[1] = upy;
   y[2] = upz;
   /* X vector = Y cross Z */
   x[0] =  y[1]*z[2] - y[2]*z[1];
   x[1] = -y[0]*z[2] + y[2]*z[0];
   x[2] =  y[0]*z[1] - y[1]*z[0];
   /* Recompute Y = Z cross X */
   y[0] =  z[1]*x[2] - z[2]*x[1];
   y[1] = -z[0]*x[2] + z[2]*x[0];
   y[2] =  z[0]*x[1] - z[1]*x[0];
   /* mpichler, 19950515 */
   /* cross product gives area of parallelogram, which is < 1.0 for
    * non-perpendicular unit-length vectors; so normalize x, y here
    */
   mag = sqrt( x[0]*x[0] + x[1]*x[1] + x[2]*x[2] );
   if (mag) {
      x[0] /= mag;
      x[1] /= mag;
      x[2] /= mag;
   }
   mag = sqrt( y[0]*y[0] + y[1]*y[1] + y[2]*y[2] );
   if (mag) {
      y[0] /= mag;
      y[1] /= mag;
      y[2] /= mag;
   }
#define M(row,col)  m[col*4+row]
   M(0,0) = x[0];  M(0,1) = x[1];  M(0,2) = x[2];  M(0,3) = 0.0;
   M(1,0) = y[0];  M(1,1) = y[1];  M(1,2) = y[2];  M(1,3) = 0.0;
   M(2,0) = z[0];  M(2,1) = z[1];  M(2,2) = z[2];  M(2,3) = 0.0;
   M(3,0) = 0.0;   M(3,1) = 0.0;   M(3,2) = 0.0;   M(3,3) = 1.0;
#undef M
   glMultMatrixf( m );
   /* Translate Eye to Origin */
   glTranslatef( -eyex, -eyey, -eyez );
}
void APIENTRY ldg_glClear( long mask )
{
#ifdef SCRIPT
		script( "glClear(%ld);",mask);
#endif
   glClear( mask );
}
void APIENTRY ldg_glPushMatrix( void )
{
#ifdef SCRIPT
		script( "glPushMatrix();");
#endif
   glPushMatrix();
}
void APIENTRY ldg_glRotatef( float angle, float x, float y, float z )
{
#ifdef SCRIPT
		script( "glRotatef(%f,%f,%f,%f);",angle,x,y,z);
#endif
   glRotatef( (GLfloat) angle, (GLfloat) x, (GLfloat) y, (GLfloat) z );
}
void APIENTRY ldg_glTranslatef( float x, float y, float z )
{
#ifdef SCRIPT
		script( "glTranslatef(%f,%f,%f);",x,y,z);
#endif
   glTranslatef( (GLfloat) x, (GLfloat) y, (GLfloat) z );
}
void APIENTRY ldg_glMaterialfv( long face, long pname, float *params )
{
#ifdef DEBUG
		_ldg_debug( "ldg_glMaterialfv in");
#endif
   glMaterialfv( (GLenum) face, (GLenum) pname, params );
#ifdef DEBUG
		_ldg_debug( "ldg_glMaterialfv out");
#endif
}
void APIENTRY ldg_glPopMatrix( void )
{
#ifdef SCRIPT
		script( "glPopMatrix();");
#endif
   glPopMatrix();
}
/*
struct osmesa_context {
   GLcontext *gl_ctx;		/ * The core GL/Mesa context * /
   GLvisual *gl_visual;		/ * Describes the buffers * /
   GLframebuffer *gl_buffer;	/ * Depth, stencil, accum, etc buffers * /
   GLenum format;		/ * either GL_RGBA or GL_COLOR_INDEX * /
   void *buffer;		/  * the image buffer * /
   GLint width, height;		/ * size of image buffer * /
   GLuint pixel;		/ * current color index or RGBA pixel value * /
   GLuint clearpixel;		/ * pixel for clearing the color buffer * /
   GLint rowlength;		/ *  number of pixels per row * /
   GLint userRowLength;		/ * user-specified number of pixels per row * /
   GLint rshift, gshift;	/ * bit shifts for RGBA formats * /
   GLint bshift, ashift;
   GLint rind, gind, bind;	/ * index offsets for RGBA formats * /
   void *rowaddr[MAX_HEIGHT];	/ * address of first pixel in each image row * /
   GLboolean yup;		/ * TRUE  -> Y increases upward * /
				/  * FALSE -> Y increases downward * /
};*/
short loc_flagcreate=0,
			loc_flag_malloc=0; /* si 1 erreur d'allocation m‚moire quelque part */
/* OSMesaContext loc_ctx;*/
long _MODE_ECRAN=0;
#include <osbind.h>
APIENTRY void *OSMesaCreateLDG( long format, long type, long width, long height ) /* retourne buffer allou‚ image, NULL si erreur */
{ Display *_dpy=NULL;
	XVisualInfo *vi=NULL;
	GLXDrawable win;
  void *buffer=NULL;
/*		_ldg_debug( "OSMesaCreateLDG in\012\015");*/
		
#ifdef SCRIPT
		script( "OSMesaCreateLDG(%ld,%ld,%ld,%ld);",format,type,width,height);
#endif 
  if((format!=VDI_RGB)&&(format!=GL_RGB)) return NULL;
  if(loc_flagcreate==0)
  {
		_MODE_ECRAN=format;
		
		
		if(1/*(loc_ctx!=NULL)&&(!loc_flag_malloc)*/)
		{
			GLXContext cx; 
			_dpy =my_Malloc(sizeof(Display));	
  			if(_dpy==NULL)
  			{_ldg_debug( "erreur Malloc\012\015");
  			 return(NULL);
  			}
  
  			cx =glXCreateContext(_dpy, vi, 0, GL_TRUE);
  
  		   if(cx==NULL) return(NULL);
  			_dpy->width=width;
  			_dpy->height=height;
  
  			glXMakeCurrent(_dpy, win, cx);
  	
  			if(monimg!=NULL) buffer=*monimg;
			if(buffer!=NULL)
			{
				
  				loc_flagcreate=1;
	
				return(buffer);
			}
			else loc_flagcreate=0;
		}
		
	}
	return(NULL);
}
void APIENTRY swapbuffer(void *buf)
{
/*	loc_ctx->buffer=buf;
	compute_row_addresses( loc_ctx );   */
	*monimg=buf;
}
void APIENTRY OSMesaDestroyLDG(void)
{
#ifdef SCRIPT
		script( "OSMesaDestroyLDG();");
#endif
	if(loc_flagcreate==1)
	{
		Freeall();
		loc_flagcreate=0;
	}
}
void APIENTRY Save_TGA(char *file, void *buffer, long WIDTH, long HEIGHT)
{
	char *pt_int;
	short width,height; 
	long f=-1L,close; 
#ifdef DEBUG
		_ldg_debug( "Save_TGA in");
#endif
	height=(short)HEIGHT-1;
  f=Fcreate(file,0); 
  if (f>0L) 
  { char entete[18];
  	 
  	 entete[1]=0; /* no color map */
  	 entete[2]=2; /* TGA unmaped RGB image */
    
    entete[3]=0;
    entete[4]=0;
    entete[5]=0;
    entete[6]=0;
    entete[7]=0;
    entete[8]=0;  /* X origine coin gauche   */
    entete[9]=0;  /* X suite */
    pt_int=(char *)&height;
    entete[11]=*pt_int++;  /* Y origine coin bas */
    entete[10]=*pt_int;    /* Y suite */
    width=(short)WIDTH;
		height=(short)HEIGHT;
		pt_int=(char *)&width;
    entete[13]=*pt_int++;  /* largeur */
    entete[12]=*pt_int;    /* largeur suite */
    pt_int=(char *)&height;
    entete[15]=*pt_int++;  /* hauteur */
    entete[14]=*pt_int;    /* hauteur suite */
   
    	entete[16]=24;				/* TGA 24 bits */
    
    	entete[17]|=32;  /* coin origine haut gauche */
    
    (void)Fwrite(f,WIDTH*HEIGHT*3L,buffer); 
    
    close=Fclose((int)(f&0xFFFFL));
   /* if(close!=0L) printf("Fclose erreur : %ld fichier %ld\015\012",close,f);*/
  }
  else if(!gl_exception_error(14L)) Cconws("can't create TGA image \015\012");
#ifdef DEBUG
		_ldg_debug( "Save_TGA out");
#endif
}
void APIENTRY ldg_glBegin( long mode )
{
#ifdef SCRIPT
		script( "glBegin(%ld);",mode);
#endif
   glBegin( (GLenum) mode );
}
void APIENTRY ldg_glVertex2f( float x, float y )
{
#ifdef SCRIPT
		script( "glVertex2f(%f,%f);",x,y);
#endif
   glVertex2f( (GLfloat) x, (GLfloat) y );
}
void APIENTRY ldg_glVertex3f( float x, float y, float z )
{
#ifdef SCRIPT
		script( "glVertex3f(%f,%f,%f);",x,y,z);
#endif
   glVertex3f( (GLfloat) x, (GLfloat) y, (GLfloat) z);
}
void APIENTRY ldg_glColor3f( float red, float green, float blue )
{
#ifdef SCRIPT
		script( "glColor3f(%f,%f,%f);",red,green,blue);
#endif
   glColor3f( (GLfloat) red, (GLfloat) green, (GLfloat) blue ); /* inversion pour cause de bug Mesa il inverse le bleu et le rouge ! */
}
void APIENTRY ldg_glDisable( long cap )
{
#ifdef SCRIPT
		script( "glDisable(%ld);",cap);
#endif
   glDisable( (GLenum) cap );
}
void APIENTRY ldg_glTexParameteri( long target, long pname, long param )
{
#ifdef DEBUG
		_ldg_debug( "ldg_glTexParameteri in");
#endif
   glTexParameteri( (GLenum) target, (GLenum) pname, (GLint) param );
#ifdef DEBUG
		_ldg_debug( "ldg_glTexParameteri out");
#endif
}
void APIENTRY ldg_glTexEnvi( long target, long pname, long param )
{
#ifdef DEBUG
		_ldg_debug( "ldg_glTexEnvi in");
#endif
   glTexEnvi( (GLenum) target, (GLenum) pname, (GLint) param );
#ifdef DEBUG
		_ldg_debug( "lldg_glTexEnvi out");
#endif
}
void APIENTRY ldg_glClearColor( float red, float green, float blue, float alpha )
{
#ifdef SCRIPT
		script( "glClearColor(%f,%f,%f,%f);",red,green,blue,alpha);
#endif
   glClearColor(  red,  green,  blue,  alpha );
}
