/*
 * 
 * Z buffer: 16 bits Z / 16 bits color
 * 
 */
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <string.h>
#include "zbuffer.h"
#include "mem.h"
#define BYTE_ORDER BIG_ENDIAN
#define TGL_FEATURE_24_BITS 1
ZBuffer *ZB_open(int xsize,int ysize,int mode,
		 int nb_colors,
		 unsigned char *color_indexes,
		 int *color_table,
		 void *frame_buffer)
{
    ZBuffer *zb;
    int size;
    
    zb=my_Malloc(sizeof(ZBuffer));
    if (zb == NULL) return NULL;
    zb->xsize=xsize;
    zb->ysize=ysize;
    zb->mode=mode;
    
        zb->nb_colors=0;
    
  
    size=zb->xsize*zb->ysize*3/*sizeof(unsigned short)*/;
    
    zb->zbuf=my_Malloc(zb->xsize*zb->ysize*sizeof(unsigned short));
    if (zb->zbuf == NULL) goto error;
    
    if (frame_buffer == NULL) {
        zb->pbuf=ldg_Malloc(size);
        if (zb->pbuf == NULL) {
            my_Free(zb->zbuf);
            goto error;
        }
 /*       monimg= zb->pbuf;*/
        zb->frame_buffer_allocated=1;
    } else {
        zb->frame_buffer_allocated=0;
        zb->pbuf=frame_buffer;
    }
    
    zb->current_texture=NULL;
    
    return zb;
 error:
/*    monimg=NULL;*/
    my_Free(zb);
    return NULL;
}
void ZB_close(ZBuffer *zb)
{
#ifdef TGL_FEATURE_8_BITS
  if (zb->mode == ZB_MODE_INDEX) 
    ZB_closeDither(zb);
#endif
  
  if (zb->frame_buffer_allocated) 
    my_Free(zb->pbuf);
  my_Free(zb->zbuf);
  my_Free(zb);
}
void ZB_resize(ZBuffer *zb,void *frame_buffer,int xsize,int ysize)
{
  int size;
  /* xsize must be a multiple of 4 */
  xsize = xsize & ~3;
  zb->xsize=xsize;
  zb->ysize=ysize;
  size=zb->xsize*zb->ysize*3/**sizeof(unsigned short)*/;
  my_Free(zb->zbuf);
  zb->zbuf=my_Malloc(zb->xsize*zb->ysize*sizeof(unsigned short));
  if(zb->zbuf==NULL) return;
  if (zb->frame_buffer_allocated) 
  {
  	ldg_Free(zb->pbuf);
  	zb->frame_buffer_allocated=0;
  }
  if (frame_buffer == NULL) {
    zb->pbuf=ldg_Malloc(size);
    if(zb->pbuf==NULL) return;
/*    monimg=zb->pbuf;*/
    zb->frame_buffer_allocated=1;
  } else {
    zb->pbuf=frame_buffer;
 /*   monimg=zb->pbuf;*/
    zb->frame_buffer_allocated=0;
  }
}
/* 16 bpp copy */
void ZB_copyFrameBuffer5R6G5B(ZBuffer *zb,
			      void *buf,
			      int linesize)
{
  unsigned short *p1,*q;
  int y,n;
	 
  q=zb->pbuf;
  p1=buf;
  n = zb->xsize * 2;
  for(y=0;y<zb->ysize;y++) {
    memcpy(p1,q,n);
    p1+=linesize;
    q+=zb->xsize;
  }
}
/* 32 bpp copy */
#ifdef TGL_FEATURE_32_BITS
#define RGB16_TO_RGB32(p0,p1,v)\
{\
    unsigned int g,b,gb;\
    g = (v & 0x07E007E0) << 5;\
    b = (v & 0x001F001F) << 3;\
    gb = g | b;\
    p0 = (gb & 0x0000FFFF) | ((v & 0x0000F800) << 8);\
    p1 = (gb >> 16) | ((v & 0xF8000000) >> 8);\
}
void ZB_copyFrameBufferRGB32(ZBuffer *zb,
			      void *buf,
			      int linesize)
{
    unsigned short *q;
    unsigned int *p,*p1,v,w0,w1;
    int y,n;
    
    q=zb->pbuf;
    p1=(unsigned int *)buf;
    
    for(y=0;y<zb->ysize;y++) {
        p=p1;
        n=zb->xsize >> 2;
        do {
            v= *(unsigned int *) q;
#if BYTE_ORDER == BIG_ENDIAN
            RGB16_TO_RGB32(w1,w0,v);
#else
            RGB16_TO_RGB32(w0,w1,v);
#endif
            p[0] = w0;
            p[1] = w1;
            v= *(unsigned int *) (q + 2);
#if BYTE_ORDER == BIG_ENDIAN
            RGB16_TO_RGB32(w1,w0,v);
#else
            RGB16_TO_RGB32(w0,w1,v);
#endif
            p[2] = w0;
            p[3] = w1;
            
            q+=4;
            p+=4;
        } while (--n > 0);
        p1+=linesize;
  }
}
#endif
/* 24 bit packed pixel handling */
#ifdef TGL_FEATURE_24_BITS
/* order: RGBR GBRG BRGB */
/* XXX: packed pixel 24 bit support not tested */
/* XXX: big endian case not optimised */
#if BYTE_ORDER == BIG_ENDIAN
#define RGB16_TO_RGB24(p0,p1,p2,v1,v2)\
{\
    unsigned int r1,g1,b1,gb1,g2,b2,gb2;\
    v1 = (v1 << 16) | (v1 >> 16);\
    v2 = (v2 << 16) | (v2 >> 16);\
    r1 = (v1 & 0xF800F800);\
    g1 = (v1 & 0x07E007E0) << 5;\
    b1 = (v1 & 0x001F001F) << 3;\
    gb1 = g1 | b1;\
    p0 = ((gb1 & 0x0000FFFF) << 8) | (r1 << 16) | (r1 >> 24);\
    g2 = (v2 & 0x07E007E0) << 5;\
    b2 = (v2 & 0x001F001F) << 3;\
    gb2 = g2 | b2;\
    p1 = (gb1 & 0xFFFF0000) | (v2 & 0xF800) | ((gb2 >> 8) & 0xff);\
    p2 = (gb2 << 24) | ((v2 & 0xF8000000) >> 8) | (gb2 >> 16);\
}
#else
#define RGB16_TO_RGB24(p0,p1,p2,v1,v2)\
{\
    unsigned int r1,g1,b1,gb1,g2,b2,gb2;\
    r1 = (v1 & 0xF800F800);\
    g1 = (v1 & 0x07E007E0) << 5;\
    b1 = (v1 & 0x001F001F) << 3;\
    gb1 = g1 | b1;\
    p0 = ((gb1 & 0x0000FFFF) << 8) | (r1 << 16) | (r1 >> 24);\
    g2 = (v2 & 0x07E007E0) << 5;\
    b2 = (v2 & 0x001F001F) << 3;\
    gb2 = g2 | b2;\
    p1 = (gb1 & 0xFFFF0000) | (v2 & 0xF800) | ((gb2 >> 8) & 0xff);\
    p2 = (gb2 << 24) | ((v2 & 0xF8000000) >> 8) | (gb2 >> 16);\
}
#endif
void ZB_copyFrameBufferRGB24(ZBuffer *zb,
                             void *buf,
                             int linesize)
{
    unsigned short *q;
    unsigned int *p,*p1,w0,w1,w2,v0,v1;
    int y,n;
    
   
    q=zb->pbuf;
    p1=(unsigned int *)buf;
    linesize = linesize * 3;
    for(y=0;y<zb->ysize;y++) {
        p=p1;
        n=zb->xsize >> 2;
        do {
            v0= *(unsigned int *) q;
            v1= *(unsigned int *) (q + 2);
           RGB16_TO_RGB24(w0,w1,w2,v0,v1);
            p[0] = w0;
            p[1] = w1;
            p[2] = w2;
            q+=4;
            p+=3;
        } while (--n > 0);
    /*    (char *)p1 += linesize;*/
    	p1 = (unsigned int *)((unsigned long)p1 + linesize);
  }
}
#endif
void ZB_copyFrameBuffer(ZBuffer *zb,void *buf,
			int linesize)
{
/*        ZB_copyFrameBufferRGB24(zb,buf,linesize);*/
 
}
/*
 * adr must be aligned on an 'int'
 */
void memset_s(void *adr,int val,int count)
{
  int i,n; register int v;
  register unsigned int *p;
  unsigned short *q;
  p=adr;
  v=val | (val << 16);
  n=count >> 3;
  for(i=0;i<n;i++) {
/*    p[0]=v;
    p[1]=v;
    p[2]=v;
    p[3]=v;
    p+=4;*/
    *p++=v;
    *p++=v;
    *p++=v;
    *p++=v;
  }
  q=(unsigned short *)p;
  n=count & 7;
  for(i=0;i<n;i++) *q++=val;
}
/*void memset_sRGB24(void *adr,int r, int v, int b,long count)
{
  long i,*v1=(long *)adr;
  register long *v2=(long *)(adr+4L),*v3=(long *)(adr+2L),*pt=(long *)((long)adr+8L);
  unsigned char *p,R=(unsigned char)r,V=(unsigned char)v,B=(unsigned char)b;
  p=(unsigned char *)adr;
  *p++=R;
  *p++=V;
  *p++=B;
  *p++=R;
  *p++=V;
  *p++=B;
  *p++=R;
  *p++=V;
  count=(count-4L)>>3;
  for(i=1L;i<count;i++) {
    *pt++=*v3;
    *pt++=*v1;
    *pt++=*v2;
    *pt++=*v3;
    *pt++=*v1;
    *pt++=*v2;
  }
}*/
void memset_sRGB24(void *adr,int r, int v, int b,long count)
{
  long i;
  register long v1,v2,v3,*pt=(long *)(adr);
  unsigned char *p,R=(unsigned char)r,V=(unsigned char)v,B=(unsigned char)b;
  p=(unsigned char *)adr;
  *p++=R;
  *p++=V;
  *p++=B;
  *p++=R;
  *p++=V;
  *p++=B;
  *p++=R;
  *p++=V;
  *p++=B;
  *p++=R;
  *p++=V;
  *p++=B;
  v1=*pt++;
  v2=*pt++;
  v3=*pt++;
  for(i=1;i<(count>>2);i++)
  {
  	*pt++=v1;
   	*pt++=v2;
    *pt++=v3;
  }
}
void ZB_clear(ZBuffer *zb,int clear_z,int z,
	      int clear_color,int r,int g,int b)
{
  int size,color;
 
  size=zb->xsize*zb->ysize;
  if (clear_z) {
    memset_s(zb->zbuf,z,size);
  }
  if (clear_color) {
    /*color=RGB_TO_5R6G5B(r,g,b);
    memset_s(zb->pbuf,color,size);*/
    memset_sRGB24(zb->pbuf,r>>8,g>>8,b>>8,size);
  }
}
