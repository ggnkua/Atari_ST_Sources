/* simple glx driver for TinyGL */
/*#include "GL/x11.h"*/
#include "GL/glx.h"
#include "zgl.h"
#include "zglx.h"
#include "mem.h"
#include <osbind.h>
GLXContext glXCreateContext( Display *dpy, XVisualInfo *vis,
                             GLXContext shareList, Bool direct )
{
  TinyGLXContext *ctx;
  if (shareList != NULL) {
    if(gl_exception_error(11)) return (NULL);
    gl_fatal_error("No sharing available in TinyGL");
  }
  ctx=my_Malloc((long)sizeof(TinyGLXContext));
  if(ctx==NULL) return(NULL);
  ctx->gl_context=NULL;
 /* ctx->visual_info=*vis;*/
  return ((GLXContext) ctx);
}
void glXDestroyContext( Display *dpy, GLXContext ctx1 )
{
  TinyGLXContext *ctx = (TinyGLXContext *) ctx1;
  if (ctx->gl_context != NULL) {
    glClose();
  }
  my_Free(ctx);
}
static int glxXErrorFlag=0;
static int glxHandleXError(Display *dpy,XErrorEvent *event)
{
  glxXErrorFlag=1;
  return 0;
}
static int bits_per_pixel(Display *dpy,XVisualInfo *visinfo)
{
   return(24);  /* 24 bits par pixels RGB */
}
XImage* XCreateImage(Display *display,long None,long depth,long ZPixmap,long zero,long rien,long xsize,long ysize,long huit, long rien2)
{ XImage *img;
	img=my_Malloc(sizeof(XImage));
	if(img)
	{
		img->bytes_per_line=xsize*3;	
	}
	return(img);
}
static int create_ximage(TinyGLXContext *ctx,
                         int xsize,int ysize,int depth)
{
 
  
  unsigned char *framebuffer;
 
  ctx->ximage=XCreateImage(ctx->display,0L, depth,0L, 0, 
                             NULL,xsize,ysize, 8, 0);
  if(ctx->ximage==NULL) return(0);
  framebuffer=my_Malloc(ysize * ctx->ximage->bytes_per_line);
  ctx->ximage->data = framebuffer;
/*  monimg=(void *)framebuffer;*/
  return 0;
}
static void free_ximage(TinyGLXContext *ctx)
{ 
  my_Free(ctx->ximage->data);
  my_Free(ctx->ximage);
}
/* resize the glx viewport : we try to use the xsize and ysize
   given. We return the effective size which is guaranted to be smaller */
extern void **monimg;
int glX_resize_viewport(GLContext *c,int *xsize_ptr,int *ysize_ptr)
{
  TinyGLXContext *ctx;
  int xsize,ysize;
  ctx=(TinyGLXContext *)c->opaque;
  xsize=*xsize_ptr;
  ysize=*ysize_ptr;
  /* we ensure that xsize and ysize are multiples of 2 for the zbuffer. 
     TODO: find a better solution */
  xsize&=~3;
  ysize&=~3;
  if (xsize == 0 || ysize == 0) return -1;
  *xsize_ptr=xsize;
  *ysize_ptr=ysize;
  if (ctx->ximage != NULL) free_ximage(ctx);
  
  ctx->xsize=xsize;
  ctx->ysize=ysize;
  ctx->visual_info.depth=24;
  if (create_ximage(ctx,ctx->xsize,ctx->ysize,ctx->visual_info.depth) != 0) 
    return -1;
  /* resize the Z buffer */
 /* if (ctx->visual_info.depth != 16) {
    ZB_resize(c->zb,NULL,xsize,ysize);
  } else {*/
    ZB_resize(c->zb,ctx->ximage->data,xsize,ysize);
 /* }*/
	monimg=&c->zb->pbuf;
  return 0;
}
void XGetWindowAttributes(Display *display, GLXDrawable drawable, XWindowAttributes *attr)
{
	attr->width=display->width;
	attr->height=display->height;	
}
/* we assume here that drawable is a window */
Bool glXMakeCurrent( Display *dpy, GLXDrawable drawable,
                     GLXContext ctx1)
{
  TinyGLXContext *ctx = (TinyGLXContext *) ctx1;
  XWindowAttributes attr;
  int xsize,ysize;
  
  
  ZBuffer *zb;
 
  
  if((dpy==NULL)||(ctx1==NULL)) return(0);
  if (ctx->gl_context == NULL) {
    /* create the TinyGL context */
    ctx->display=dpy;
    ctx->drawable=drawable;
	
    XGetWindowAttributes(ctx->display,drawable,&attr);
    xsize=attr.width;
    ysize=attr.height;
    /* ximage structure */
    ctx->ximage=NULL;
    ctx->shm_use=0; /* no shm */
    {
        int mode,bpp;
        /* RGB 16/24/32 */
        bpp = bits_per_pixel(ctx->display,&ctx->visual_info);
        
        mode = ZB_MODE_RGB24;
       /* _ldg_debug( "ZB_open in\012\015");*/
        zb=ZB_open(xsize,ysize,mode,0,NULL,NULL,NULL);
      /*  _ldg_debug( "ZB_open out\012\015");*/
        if (zb == NULL) {
          /*  fprintf(stderr, "Error while initializing Z buffer\n");*/
            if(!gl_exception_error(1L)) Cconws("Error while initializing Z buffer\015\012");;
            exit(1);
        }
    }
    /* create a gc */
   
   
    /* initialisation of the TinyGL interpreter */
   
    glInit(zb);
 
    ctx->gl_context=gl_get_context();
    ctx->gl_context->opaque=(void *) ctx;
    ctx->gl_context->gl_resize_viewport=glX_resize_viewport;
    /* set the viewport : we force a call to glX_resize_viewport */
    ctx->gl_context->viewport.xsize=-1;
    ctx->gl_context->viewport.ysize=-1;
    glViewport(0, 0, xsize, ysize);
 
  }
  return True;
}
void glXSwapBuffers( Display *dpy)/*, GLXDrawable drawable )*/
{
  GLContext *gl_context;
  TinyGLXContext *ctx;
  /* retrieve the current GLXContext */
  gl_context=gl_get_context();
  ctx=(TinyGLXContext *)gl_context->opaque;
    ZB_copyFrameBuffer(ctx->gl_context->zb,
                       ctx->ximage->data,
                       ctx->xsize);
 
  /* draw the ximage */
  
  /*  XPutImage(dpy, drawable, ctx->gc, 
              ctx->ximage, 0, 0, 0, 0, ctx->ximage->width, ctx->ximage->height);
  XFlush(dpy);*/
}
