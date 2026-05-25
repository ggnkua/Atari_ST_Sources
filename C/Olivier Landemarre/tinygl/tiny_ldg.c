/*
 * Librairie dynamique type LDG … base de la librairie publique Tiny GL (Fabrice Bellard) clone d'OPEN GL
 */
/*#define SCRIPT 1*/ /* pour avoir une version r‚alisant des scripts */
#if defined(__M68020__)
#if defined(__M68881__)
#ifdef  MAKEPERF
#define INFORME "Test perf 68020+68881 pour Kronos Olivier LANDEMARRE V1.0\015\012"
#else
#define INFORME "version 0.46 68020+68881 TINYGL clone OPEN GL portage LDG Atari Olivier LANDEMARRE 4 decembre 2004 \015\012"
#endif
#else
#ifdef  MAKEPERF
#define INFORME "Test perf 68020-40 pour Kronos Olivier LANDEMARRE V1.0\015\012"
#else
#define INFORME "version 0.46 68020-40 TINYGL clone OPEN GL portage LDG Atari Olivier LANDEMARRE 4 decembre 2004 \015\012"
#endif
#endif
#endif
#if defined(__M68030__)
#if defined(__M68881__)
#ifdef  MAKEPERF
#define INFORME "Test perf 68030+68881 pour Kronos Olivier LANDEMARRE V1.0\015\012"
#else
#define INFORME "version 0.46 68030+68881 TINYGL clone OPEN GL portage LDG Atari Olivier LANDEMARRE 4 decembre 2004\015\012"
#endif
#else
#ifdef  MAKEPERF
#define INFORME "Test perf 68030 pour Kronos Olivier LANDEMARRE V1.0\015\012"
#else
#define INFORME "version 0.46 68030 TINYGL clone OPEN GL portage LDG Atari Olivier LANDEMARRE 4 decembre 2004 \015\012"
#endif
#endif
#endif
#if defined(__M68040__)
#if defined(__M68881__)
#ifdef  MAKEPERF
#define INFORME "Test perf 68040+68881pour Kronos Olivier LANDEMARRE V1.0\015\012"
#else
#define INFORME "version 0.46 68040+68881 TINYGL clone OPEN GL portage LDG Atari Olivier LANDEMARRE 4 decembre 2004 \015\012"
#endif
#else
#ifdef  MAKEPERF
#define INFORME "Test perf 68040 pour Kronos Olivier LANDEMARRE V1.0\015\012"
#else
#define INFORME "version 0.46 68040 TINYGL clone OPEN GL portage LDG Atari Olivier LANDEMARRE 4 decembre 2004 \015\012"
#endif
#endif
#endif
#if defined(__M68060__)
#if defined(__M68881__)
#ifdef  MAKEPERF
#define INFORME "Test perf 68040+68881 pour Kronos Olivier LANDEMARRE V1.0\015\012"
#else
#define INFORME "version 0.46 68040+68881 TINYGL clone OPEN GL portage LDG Atari Olivier LANDEMARRE 4 decembre 2004 \015\012"
#endif
#else
#ifdef  MAKEPERF
#define INFORME "Test perf 68040 pour Kronos Olivier LANDEMARRE V1.0\015\012"
#else
#define INFORME "version 0.46 68040 TINYGL clone OPEN GL portage LDG Atari Olivier LANDEMARRE 4 decembre 2004 \015\012"
#endif
#endif
#endif
#ifndef INFORME
#if defined(__M68881__)
#ifdef  MAKEPERF
#define INFORME "Test perf 68000+68881 pour Kronos Olivier LANDEMARRE V1.0\015\012"
#else
#define INFORME "version 0.46 68000+68881 TINYGL clone OPEN GL portage LDG Atari Olivier LANDEMARRE 4 decembre 2004 \015\012"
#endif
#else
#ifdef  MAKEPERF
#define INFORME "Test perf 68000 pour Kronos Olivier LANDEMARRE V1.0\015\012"
#else
#define INFORME "version 0.46 68000 TINYGL clone OPEN GL portage LDG Atari Olivier LANDEMARRE 4 decembre 2004 \015\012"
#endif
#endif
#endif
 
#define BETA 1 /* nouveau type LDG */

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <osbind.h> 
/*#include <mgem.h>*/  
#include <gem.h>
/*#if BETA
#include "ldg2.h"
#else */
#include "ldg.h"
/*#endif */
#include "GL/gl.h"
/*#include "GL/atarmesa.h"*/
/*
#include "macros.h"
*/
/*
#include "types.h"
*/
__EXTERN short __ldg_id;	
void (*error_except)(long)=NULL;
#include "ldg_api.c"
#include "apiauto.c"
#ifdef  MAKEPERF
#define NB_FCT 84     /* nombre de fonctions dans la librairie LDG */
#else
#define NB_FCT 83     /* nombre de fonctions dans la librairie LDG */
#endif
long _stksize=16000L;
void information(void)
{
	Cconws(INFORME); 
}
void APIENTRY ldg_glDeleteLists( unsigned long list, long range )
{
}

#ifdef  MAKEPERF
long APIENTRY ldg_glConfigure( long param )
{
	if(param==123L) return -2L;
	return -1L;
}
#endif

/* tableau de taille … modifier pour mettre toutes 
 * les addresses des proc‚dures … pr‚senter 
 */
PROC LibFunc[NB_FCT] = { "information", "Message d'information", (void *)information,
"glBegin", "         void APIENTRY glBegin( long mode )",(void *)ldg_glBegin,
"glClear", "         void glClear( long mask )", (void *) ldg_glClear,
"glClearColor","      void APIENTRY glClearColor( float red, float green, float blue, float alpha )", (void *)ldg_glClearColor,
"glColor3f", "       void APIENTRY glColor3f( float red, float green, float blue )", (void *)ldg_glColor3f,
"glDisable", "       void APIENTRY glDisable( long cap )", (void *)ldg_glDisable,
"glEnable", "        void APIENTRY glEnable( long cap )", (void *)ldg_glEnable,
"glEnd", "           void APIENTRY glEnd(void)",(void *) ldg_glEnd,
"glLightfv", "       void APIENTRY glLightfv( long light, long pname, float *params )", (void *)ldg_glLightfv,
"glLoadIdentity", "  void APIENTRY glLoadIdentity( void )", (void *)ldg_glLoadIdentity,
"glMaterialfv", "    void APIENTRY glMaterialfv( long face, long pname, float *params )", (void *) ldg_glMaterialfv,
"glMatrixMode", "    void APIENTRY glMatrixMode( long mode )", (void *)ldg_glMatrixMode,
"glOrtho", "         void APIENTRY glOrtho( float left, float right,float bottom, float top,float nearval, float farval )",(void *)ldg_glOrtho,
"glPopMatrix", "     void APIENTRY glPopMatrix( void )", (void *)ldg_glPopMatrix, 
"glPushMatrix", "    void APIENTRY glPushMatrix( void )", (void *)ldg_glPushMatrix,
"glRotatef", "       void APIENTRY glRotatef( float angle, float x, float y, float z )", (void *) ldg_glRotatef,
"glTexEnvi","        void APIENTRY glTexEnvi( long target, long pname, long param )", (void *) ldg_glTexEnvi,
"glTexParameteri", " void APIENTRY glTexParameteri( long target, long pname, long param )", (void *) ldg_glTexParameteri,
"glTranslatef", "    void APIENTRY glTranslatef( float x, float y, float z )", (void *) ldg_glTranslatef, 
"glVertex2f", "      void APIENTRY glVertex2f( float x, float y )",(void *) ldg_glVertex2f,
"glVertex3f", "      void APIENTRY glVertex3f( float x, float y, float z )",(void *) ldg_glVertex3f,
"OSMesaCreateLDG", " APIENTRY void *OSMesaCreateLDG( long format, long type, long WIDTH, long HEIGHT )  /* retourne buffer allou‚ image, NULL si erreur */",(void *) OSMesaCreateLDG,
"OSMesaDestroyLDG", "void APIENTRY OSMesaDestroyLDG(void)", (void *) OSMesaDestroyLDG,
"glArrayElement", " void APIENTRY glArrayElement( long i )",(void *)ldg_glArrayElement,
"glBindTexture", " void APIENTRY glBindTexture( long target, unsigned long texture )",(void *)ldg_glBindTexture,
"glCallList", " void APIENTRY glCallList( unsigned long list )",(void *)ldg_glCallList,
"glClearDepth", " void APIENTRY glClearDepth( float depth )",(void *)ldg_glClearDepth,
"glColor4f", " void APIENTRY glColor4f( GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha )",(void *)ldg_glColor4f,
"glColor3fv", " void APIENTRY glColor3fv(  GLfloat *v )",(void *)ldg_glColor3fv,
"glColor4fv", " void APIENTRY glColor4fv(  GLfloat *v )",(void *)ldg_glColor4fv,
"glColorMaterial", " void APIENTRY glColorMaterial( long face, long mode )",(void *)ldg_glColorMaterial,
"glColorPointer", " void APIENTRY glColorPointer( long size, long type, long stride,  GLvoid *ptr )",(void *)ldg_glColorPointer,
"glCullFace", " void APIENTRY glCullFace( long mode )",(void *)ldg_glCullFace,
"glDeleteTextures", " void APIENTRY glDeleteTextures( long n,  unsigned long *textures)",(void *)ldg_glDeleteTextures,
"glDisableClientState", " void APIENTRY glDisableClientState( long cap )",(void *)ldg_glDisableClientState,
"glEnableClientState", " void APIENTRY glEnableClientState( long cap )",(void *)ldg_glEnableClientState,
"glEndList", " void APIENTRY glEndList( void )",(void *)ldg_glEndList,
"glEdgeFlag", " void APIENTRY glEdgeFlag( unsigned long flag )",(void *)ldg_glEdgeFlag,
"glFlush", " void APIENTRY glFlush( void )",(void *)ldg_glFlush,
"glFrontFace", " void APIENTRY glFrontFace( long mode )",(void *)ldg_glFrontFace,
"glFrustum", " void APIENTRY glFrustum( float left, float right, float bottom, float top, float nearval, float farval )",(void *)ldg_glFrustum,
"glGenLists", " unsigned long APIENTRY glGenLists( long range )",(void *)ldg_glGenLists,
"glGenTextures", " void APIENTRY glGenTextures( long n, unsigned long *textures )",(void *)ldg_glGenTextures,
"glGetFloatv", " void APIENTRY glGetFloatv( long pname, GLfloat *params )",(void *)ldg_glGetFloatv,
"glGetIntegerv", " void APIENTRY glGetIntegerv( long pname, long *params )",(void *)ldg_glGetIntegerv,
"glHint", " void APIENTRY glHint( long target, long mode )",(void *)ldg_glHint,
"glInitNames", " void APIENTRY glInitNames( void )",(void *)ldg_glInitNames,
"glIsList", " unsigned long APIENTRY glIsList( unsigned long list )",(void *)ldg_glIsList,
"glLightf", " void APIENTRY glLightf( long light, long pname, GLfloat param )",(void *)ldg_glLightf,
"glLightModeli", " void APIENTRY glLightModeli( long pname, long param )",(void *)ldg_glLightModeli,
"glLightModelfv", " void APIENTRY glLightModelfv( long pname,  GLfloat *params )",(void *)ldg_glLightModelfv,
"glLoadMatrixf", " void APIENTRY glLoadMatrixf(  GLfloat *m )",(void *)ldg_glLoadMatrixf,
"glLoadName", " void APIENTRY glLoadName( unsigned long name )",(void *)ldg_glLoadName,
"glMaterialf", " void APIENTRY glMaterialf( long face, long pname, GLfloat param )",(void *)ldg_glMaterialf,
"glMultMatrixf", " void APIENTRY glMultMatrixf(  GLfloat *m )",(void *)ldg_glMultMatrixf,
"glNewList", " void APIENTRY glNewList( unsigned long list, long mode )",(void *)ldg_glNewList,
"glNormal3f", " void APIENTRY glNormal3f( GLfloat nx, GLfloat ny, GLfloat nz )",(void *)ldg_glNormal3f,
"glNormal3fv", " void APIENTRY glNormal3fv(  GLfloat *v )",(void *)ldg_glNormal3fv,
"glNormalPointer", " void APIENTRY glNormalPointer( long type, long stride,  GLvoid *ptr )",(void *)ldg_glNormalPointer,
"glPixelStorei", " void APIENTRY glPixelStorei( long pname, long param )",(void *)ldg_glPixelStorei,
"glPolygonMode", " void APIENTRY glPolygonMode( long face, long mode )",(void *)ldg_glPolygonMode,
"glPolygonOffset", " void APIENTRY glPolygonOffset( GLfloat factor, GLfloat units )",(void *)ldg_glPolygonOffset,
"glPopName", " void APIENTRY glPopName( void )",(void *)ldg_glPopName,
"glPushName", " void APIENTRY glPushName( unsigned long name )",(void *)ldg_glPushName,
"glRenderMode", " long APIENTRY glRenderMode( long mode )",(void *)ldg_glRenderMode,
"glSelectBuffer", " void APIENTRY glSelectBuffer( long size, unsigned long *buffer )",(void *)ldg_glSelectBuffer,
"glScalef", " void APIENTRY glScalef( GLfloat x, GLfloat y, GLfloat z )",(void *)ldg_glScalef,
"glShadeModel", " void APIENTRY glShadeModel( long mode )",(void *)ldg_glShadeModel,
"glTexCoord2f", " void APIENTRY glTexCoord2f( GLfloat s, GLfloat t )",(void *)ldg_glTexCoord2f,
"glTexCoord4f", " void APIENTRY glTexCoord4f( GLfloat s, GLfloat t, GLfloat r, GLfloat q )",(void *)ldg_glTexCoord4f,
"glTexCoord2fv", " void APIENTRY glTexCoord2fv(  GLfloat *v )",(void *)ldg_glTexCoord2fv,
"glTexCoordPointer", " void APIENTRY glTexCoordPointer( long size, long type, long stride,  GLvoid *ptr )",(void *)ldg_glTexCoordPointer,
"glTexImage2D", " void APIENTRY glTexImage2D( long target, long level, long internalformat, long width, long height, long border, long format, long type,  GLvoid *pixels )",(void *)ldg_glTexImage2D,
"glVertex4f", " void APIENTRY glVertex4f( GLfloat x, GLfloat y, GLfloat z, GLfloat w )",(void *)ldg_glVertex4f,
"glVertex3fv", " void APIENTRY glVertex3fv(  GLfloat *v )",(void *)ldg_glVertex3fv,
"glVertexPointer", " void APIENTRY glVertexPointer( long size, long type, long stride,  GLvoid *ptr )",(void *)ldg_glVertexPointer,
#ifdef  MAKEPERF
"glConfigure"," long APIENTRY glConfigure(long param)",(void *)ldg_glConfigure,
#endif
"glViewport", " void APIENTRY glViewport( long x, long y, long width, long height )",(void *)ldg_glViewport,
"swapbuffer", " void APIENTRY swapbuffer(void *buf)", (void *)glXSwapBuffers/*swapbuffer*/,
"max_width", " long APIENTRY max_width(void) nombre de pixels support‚s en largeur", (void *)max_width,
"max_height", " long APIENTRY max_height(void) nombre de pixels support‚s en hauteur", (void *)max_height,
"glDeleteLists", " void APIENTRY glDeleteLists( unsigned long list, long range )",(void *)ldg_glDeleteLists,
"gluLookAt", " void APIENTRY gluLookAt( float eyex, float eyey, float eyez, float centerx, float centery, float centerz, float upx, float upy, float upz )", (void *)gluLookAt,
"exception_error", "void APIENTRY exception_error(void APIENTRY (*exception)(long param))",(void *)exception_error
				    };
char LibInfo[] = INFORME;
LDGLIB  LibLdg[] = { 
#ifdef  MAKEPERF
0x0100,
#else
0x0046,
#endif
				  NB_FCT,
				  LibFunc,
				  LibInfo,
				  LDG_NOT_SHARED,
				  NULL,
				  NULL};
/*
 *	Les fonctions de la librairie servant aux clients
 */
/*
 *	boucle principale: communication de la librairie avec les clients
 */
int main( void)
{
/*	int dum; */
	
	/*
	 *	Mettre une s‚curit‚ pour
	 *	ne pas ‚xecuter ce programme
	 *	directement (pourrait ˆtre dans ldg_init()) .
	 */
	/*ldg_init( LibLdg) ;   */
	ldg_init(LibLdg);
	return 0;
}
