#include <stdlib.h>
#include <stdio.h>
#include "zbuffer.h"
/*#define ZCMP(z,zpix) ((z) >= (zpix))*/
#define ZCMP(z,zpix) 1

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
