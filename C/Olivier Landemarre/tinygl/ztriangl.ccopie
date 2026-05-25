#include <stdlib.h>
#include "zbuffer.h"
#define ZCMP(z,zpix) ((z) >= (zpix))
void ZB_fillTriangleFlat(ZBuffer *zb,
			 ZBufferPoint *p0,ZBufferPoint *p1,ZBufferPoint *p2)  /* supporte maintenant 24bits */
{
  unsigned char colorR,colorG,colorB;
	{	unsigned long zz;
		unsigned short *pz1,*pzz=(unsigned short*)&zz;
		unsigned long adr;
		adr=p0->y * zb->xsize;
		pz1 = zb->zbuf + adr +p0->x;
		zz=p0->z << (16-ZB_POINT_Z_FRAC_BITS);	
/*    	if (*pzz<*pz1)
    	{
    		adr=p1->y * zb->xsize;
			pz1 = zb->zbuf + adr +p1->x;
			zz=p1->z << (16-ZB_POINT_Z_FRAC_BITS);	
    		if (*pzz<*pz1)
    		{
				adr=p2->y * zb->xsize;
				pz1 = zb->zbuf + adr +p2->x;
				zz=p2->z << (16-ZB_POINT_Z_FRAC_BITS);	
    			if (*pzz<*pz1)
    			{
    				return;
    			}    	
    		}
    	
    	}*/
	}
#define INTERP_Z
#define DRAW_INIT()				\
{						\
  colorR=p2->r>>8;		\
  colorG=p2->g>>8;		\
  colorB=p2->b>>8;	\
}
  
#define PUT_PIXEL(_a)				\
{						\
   /*  zz=z >> ZB_POINT_Z_FRAC_BITS;*/zz=z << (16-ZB_POINT_Z_FRAC_BITS); /*1cycle par rotation on gagne sur un 68K */		\
    if (ZCMP(*pzz,pz[_a])) {				\
      *pp++ = colorR;				\
      *pp++ = colorG;				\
      *pp++ = colorB;				\
      pz[_a]=*pzz;				\
    }						\
     else 	\
    {	\
    	pp+=3L;	\
    }	\
    z+=dzdx;					\
}
#define DRAW_LINE()				\
{						\
  register  unsigned short *pz;		\
  unsigned char *pp;	\
  unsigned long zz; unsigned short *pzz = (unsigned short *) &zz; \
  unsigned int z;			\
  register int n;			   \
  n=(/*x2 >> 16*/ *speedx2) - x1;	   	   \
  pp=(long)((long)pp1+(((long)x1)<<1L)+(long)x1);					\
  pz=pz1+x1;					\
  z=z1;						\
  while (n>=3) {							   \
    PUT_PIXEL(0);							   \
    PUT_PIXEL(1);							   \
    PUT_PIXEL(2);							   \
    PUT_PIXEL(3);							   \
    pz+=4;								   \
    n-=4;								   \
  }									   \
  while (n>=0) {							   \
    PUT_PIXEL(0);							   \
    pz+=1;								   \
    n-=1;								   \
  }									   \
}
  
#include "ztriangl.h"
#undef PUT_PIXEL
}
/*
 * Smooth filled triangle.
 * The code below is very tricky :)
 */
void ZB_fillTriangleSmooth(ZBuffer *zb,
			   ZBufferPoint *p0,ZBufferPoint *p1,ZBufferPoint *p2) /* supporte maintenant 24bits */
{
  int _drgbdx;
	{	unsigned long zz;
		unsigned short *pz1,*pzz=(unsigned short*)&zz;
		unsigned long adr;
		adr=p0->y * zb->xsize;
		pz1 = zb->zbuf + adr +p0->x;
		zz=p0->z << (16-ZB_POINT_Z_FRAC_BITS);	
/*    	if (*pzz<*pz1)
    	{
    		adr=p1->y * zb->xsize;
			pz1 = zb->zbuf + adr +p1->x;
			zz=p1->z << (16-ZB_POINT_Z_FRAC_BITS);	
    		if (*pzz<*pz1)
    		{
				adr=p2->y * zb->xsize;
				pz1 = zb->zbuf + adr +p2->x;
				zz=p2->z << (16-ZB_POINT_Z_FRAC_BITS);	
    			if (*pzz<*pz1)
    			{
    				return;
    			}    	
    		}
    	
    	}*/
	} 
#define INTERP_Z
#define INTERP_RGB
#define DRAW_INIT()				\
{						\
}
#define PUT_PIXEL()				\
{						\
  /*  zz=z >> ZB_POINT_Z_FRAC_BITS;*/zz=z << (16-ZB_POINT_Z_FRAC_BITS); /*1cycle par rotation on gagne sur un 68K */		\
    if (ZCMP(*pzz,*pz)) {				\
      *pp++=*cr1;			\
      *pp++=*cg1;			\
      *pp++=*cb1;			\
      *pz++=*pzz;				\
    }						\
    else 	\
    {	\
    	pp+=3L;	\
    	pz++;  \
    }	\
    z+=dzdx;					\
    og1+=dgdx;					\
    or1+=drdx;					\
    ob1+=dbdx;					\
}
#define DRAW_LINE()							   \
{									   \
  register unsigned short *pz;					   \
  unsigned int z,zz/*,drgbdx*/; 	unsigned short *pzz=(unsigned short*)&zz;		   \
  register int n;							 \
  register unsigned char *pp;						 \
  or1=(unsigned short)r1; og1=(unsigned short)g1; ob1=(unsigned short)b1;			   \
  n=(/*x2 >> 16*/ *speedx2) - x1;							   \
  pp=(long)((long)pp1+(((long)x1)<<1L)+(long)x1);								   \
  pz=pz1+x1;								   \
  z=z1;									   \
/*  drgbdx=_drgbdx;	*/						   \
  while (n>=3) {							   \
    PUT_PIXEL();									   \
    PUT_PIXEL();							   \
    PUT_PIXEL();							   \
    PUT_PIXEL();							   \
    n-=4;								   \
  }									   \
  while (n>=0) {							   \
    PUT_PIXEL();							   \
    n--;								   \
  }									   \
}
  
#include "ztriangl.h"
#undef PUT_PIXEL
}
void ZB_setTexture(ZBuffer *zb,unsigned short *texture)
{
  zb->current_texture=texture;
}
void ZB_fillTriangleMapping(ZBuffer *zb,
			    ZBufferPoint *p0,ZBufferPoint *p1,ZBufferPoint *p2)
{
  unsigned char *texture,*pttexture;
#define INTERP_Z
#define INTERP_ST
#define DRAW_INIT()				\
{						\
  texture=zb->current_texture;			\
}
#define PUT_PIXEL(_a)				\
{						\
   zz=z << (16-ZB_POINT_Z_FRAC_BITS);/*zz=z >> ZB_POINT_Z_FRAC_BITS;*/		\
   if (ZCMP(*pzz,pz[_a])) {				\
      pttexture=(unsigned char*)((long)texture+(((t & 0x3FC00000L) | s) >> 14)*3L);	\
      *pp++ = *pttexture++;	\
      *pp++ = *pttexture++;	\
      *pp++ = *pttexture++;	\
       pz[_a]=*pzz;				\
    }						\
    else 	\
    {	\
    	pp+=3L;	\
    }	\
    z+=dzdx;					\
    s+=dsdx;					\
    t+=dtdx;					\
}
#define DRAW_LINE()				\
{						\
  register unsigned short *pz;		\
  unsigned char *pp;	\
  register unsigned long s,t,z; unsigned long zz; unsigned short *pzz = (unsigned short *) &zz;		\
  register int n;		\
  n=(/*x2 >> 16*/ *speedx2) - x1;                             \
  pp=(long)((long)pp1+(((long)x1)<<1L)+(long)x1);					\
  pz=pz1+x1;					\
  z=z1;						\
  s=s1;                                         \
  t=t1;						\
  while (n>=3) {							   \
    PUT_PIXEL(0);							   \
    PUT_PIXEL(1);							   \
    PUT_PIXEL(2);							   \
    PUT_PIXEL(3);							   \
    pz+=4;								   \
    n-=4;								   \
  }									   \
  while (n>=0) {							   \
    PUT_PIXEL(0);							   \
    pz+=1;								   \
    n-=1;								   \
  }									   \
}
  
#include "ztriangl.h"
#undef PUT_PIXEL
}
/*
 * Texture mapping with perspective correction.
 * We use the gradient method to make less divisions.
 * TODO: pipeline the division
 */
#if 1
void ZB_fillTriangleMappingPerspective(ZBuffer *zb,
                            ZBufferPoint *p0,ZBufferPoint *p1,ZBufferPoint *p2)
{
  unsigned char *texture,*pttexture;
  double fdzdx,fndzdx,ndszdx,ndtzdx;
#define INTERP_Z
#define INTERP_STZ
#define NB_INTERP 8
#define DRAW_INIT()				\
{						\
  texture=zb->current_texture;\
  fdzdx=(double)dzdx;\
  fndzdx=NB_INTERP * fdzdx;\
  ndszdx=NB_INTERP * dszdx;\
  ndtzdx=NB_INTERP * dtzdx;\
}
#define PUT_PIXEL(_a)				\
{						\
   zz=z << (16-ZB_POINT_Z_FRAC_BITS);/*zz=z >> ZB_POINT_Z_FRAC_BITS;*/		\
     if (ZCMP(*pzz,pz[_a])) {				\
       pttexture=(unsigned char*)((long)texture+(((t & 0x3FC00000L) | s) >> 14)*3L);	\
      *pp++ = *pttexture++;	\
      *pp++ = *pttexture++;	\
      *pp++ = *pttexture++;	\
       pz[_a]=*pzz;				\
    }						\
    else 	\
    {	\
    	pp+=3L;	\
    }	\
    z+=dzdx;					\
    s+=dsdx;					\
    t+=dtdx;					\
}
#define DRAW_LINE()				\
{						\
  register unsigned short *pz;		\
  unsigned char *pp;	\
  register unsigned long s,t,z; unsigned long zz; unsigned short *pzz = (unsigned short *) &zz;	\
  long n,dsdx,dtdx;		\
  double sz,tz,fz,zinv; \
  n=(/*x2 >> 16*/ *speedx2) - x1;                              \
  fz=(double)z1;\
  zinv=1.0 / fz;\
  pp=(long)((long)pp1+(((long)x1)<<1L)+(long)x1);					\
  pz=pz1+x1;					\
  z=z1;						\
  sz=sz1;\
  tz=tz1;\
  while (n>=(NB_INTERP-1)) {						   \
    {\
      double ss,tt;\
      ss=(sz * zinv);\
      tt=(tz * zinv);\
      s=(long) ss;\
      t=(long) tt;\
      dsdx= (long)( (dszdx - ss*fdzdx)*zinv );\
      dtdx= (long)( (dtzdx - tt*fdzdx)*zinv );\
      fz+=fndzdx;\
      zinv=1.0 / fz;\
    }\
    PUT_PIXEL(0);							   \
    PUT_PIXEL(1);							   \
    PUT_PIXEL(2);							   \
    PUT_PIXEL(3);							   \
    PUT_PIXEL(4);							   \
    PUT_PIXEL(5);							   \
    PUT_PIXEL(6);							   \
    PUT_PIXEL(7);							   \
    pz+=NB_INTERP;							   \
   /* pp+=NB_INTERP;*/							   \
    n-=NB_INTERP;							   \
    sz+=ndszdx;\
    tz+=ndtzdx;\
  }									   \
    {\
      double ss,tt;\
      ss=(sz * zinv);\
      tt=(tz * zinv);\
      s=(long) ss;\
      t=(long) tt;\
      dsdx= (long)( (dszdx - ss*fdzdx)*zinv );\
      dtdx= (long)( (dtzdx - tt*fdzdx)*zinv );\
    }\
  while (n>=0) {							   \
    PUT_PIXEL(0);							   \
    pz+=1;								   \
   /* pp+=1;	*/							   \
    n-=1;								   \
  }									   \
}
  
#include "ztriangl.h"
#undef PUT_PIXEL
}
#endif
#if 0
/* version correcte */
void ZB_fillTriangleMappingPerspective(ZBuffer *zb,
                            ZBufferPoint *p0,ZBufferPoint *p1,ZBufferPoint *p2)
{
  unsigned char *texture,*pttexture;
#define INTERP_Z
#define INTERP_STZ
#define DRAW_INIT()				\
{						\
  texture=(unsigned char *)zb->current_texture;			\
}
#define PUT_PIXEL(_a)				\
{						\
   double zinv; \
   long s,t; \
   zz=z << (16-ZB_POINT_Z_FRAC_BITS);/*zz=z >> ZB_POINT_Z_FRAC_BITS;*/	\
     if (ZCMP(*pzz,pz[_a])) {				\
       zinv= 1.0 / (double) z; \
       s= (long) (sz * zinv); \
       t= (long) (tz * zinv); \
      /* pp[_a]=texture[((t & 0x3FC00000) | s) >> 14];*/	\
      pttexture=(unsigned char*)((long)texture+((((t & 0x3FC00000L) | s) >> 14)*3L));	\
      *pp++ = *pttexture++;	\
      *pp++ = *pttexture++;	\
      *pp++ = *pttexture++;	\
       pz[_a]=*pzz;				\
    }						\
    else 	\
    {	\
    	pp+=3L;	\
    }	\
    z+=dzdx;					\
    sz+=dszdx;					\
    tz+=dtzdx;					\
}
#define DRAW_LINE()				\
{						\
  register unsigned short *pz;		\
  unsigned char *pp;	\
  register unsigned long z,zz; unsigned short *pzz = (unsigned short *) &zz;		\
  register int n;		\
  double sz,tz; \
  n=(/*x2 >> 16*/ *speedx2) - x1;                           \
  pp=(long)((long)pp1+(((long)x1)<<1L)+(long)x1);/*pp=pp1+x1;*/					\
  pz=pz1+x1;					\
  z=z1;						\
  sz=sz1;                                         \
  tz=tz1;						\
  while (n>=3) {							   \
    PUT_PIXEL(0);							   \
    PUT_PIXEL(1);							   \
    PUT_PIXEL(2);							   \
    PUT_PIXEL(3);							   \
    pz+=4;								   \
   /* pp+=4;	*/							   \
    n-=4;								   \
  }									   \
  while (n>=0) {							   \
    PUT_PIXEL(0);							   \
    pz+=1;								   \
   /* pp+=1;	*/							   \
    n-=1;								   \
  }									   \
}
  
#include "ztriangl.h"
#undef PUT_PIXEL
}
#endif
