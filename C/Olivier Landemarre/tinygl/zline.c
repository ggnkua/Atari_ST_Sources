#include <stdlib.h>
#include "zbuffer.h"
#define ZCMP(z,zpix) ((z) >= (zpix))
    
void ZB_plot(ZBuffer *zb,ZBufferPoint *p) /* fonctionne maintenant en 24 bits */
{
  unsigned short *pz,color2;
  unsigned char *pp,*color=(unsigned char *)&color2;
  long adr,zz;
  
  adr=p->y*zb->xsize+p->x;
  pz=zb->zbuf + adr;
  pp=(unsigned char *)((long)zb->pbuf + adr*3L);
  zz= p-> z >> ZB_POINT_Z_FRAC_BITS;
  if (ZCMP(zz,*pz)) {
  	 color2=p->r;
    *pp++ = *color;
    color2=p->g;
    *pp++ = *color;
    color2=p->b;
    *pp = *color;
    *pz = zz;
  }
  
}
void ZB_lineold(ZBuffer *zb,ZBufferPoint *p1,ZBufferPoint *p2) /* fonctionne maintenant en 24 bits */
{
  int n,zinc,dx,dy,sx;
  long adr;
  register int a, z, zz;
  register unsigned short *pz;
  unsigned short color2;
  unsigned char *pp, *color=(unsigned char *)&color2;
  
  if (p1->y > p2->y || (p1->y == p2->y && p1->x > p2->x)) {
    ZBufferPoint *tmp;
    tmp=p1;
    p1=p2;
    p2=tmp;
  }
  sx=zb->xsize;
  adr=((long)p1->y * (long)sx + (long)p1->x);
  pp = (unsigned char *)((long)zb->pbuf + adr*3L);
  pz = zb->zbuf + adr;
  
  dx = p2->x - p1->x;
  dy = p2->y - p1->y;
  z = p1->z;
#define PUTPIXEL() 				\
  {						\
    zz=z >> ZB_POINT_Z_FRAC_BITS;		\
    if (ZCMP(zz,*pz))  { 			\
      color2=p2->r; 				\
      *pp++ = *color; 				\
      color2=p2->g; 				\
      *pp++ = *color; 				\
      color2=p2->b; 				\
      *pp++ = *color; 				\
      *pz=zz; 					\
    }						\
     else 	\
    {	\
    	pp+=3L;	\
    }	\
  }
#define DRAWLINE(dx,dy,inc_1,inc_2) \
    zinc=(p2->z-p1->z)/dx;\
    n=dx;\
    a=2*dy-dx;\
    dy=2*dy;\
    dx=2*dx-dy;\
	 do {\
      PUTPIXEL();\
			z+=zinc;\
			if (a>0) { pp+=((long)inc_1*3L); pz+=(inc_1);  a-=dx; }\
			else { pp+=((long)inc_2*3L); pz+=(inc_2); a+=dy; }\
	 } while (--n >= 0);
/* fin macro */
  if (dx == 0 && dy == 0) {
    PUTPIXEL();
  } else if (dx > 0) {
    if (dx >= dy) {
      DRAWLINE(dx, dy, sx + 1, 1);
    } else {
      DRAWLINE(dy, dx, sx + 1, sx);
    }
  } else {
    dx = -dx;
    if (dx >= dy) {
      DRAWLINE(dx, dy, sx - 1, -1);
    } else {
      DRAWLINE(dy, dx, sx - 1, sx);
    }
  }
#undef DRAWLINE
#undef PUTPIXEL
}
void ZB_lineold2(ZBuffer *zb,ZBufferPoint *p1,ZBufferPoint *p2) /* fonctionne maintenant en 24 bits */
{
  long /*n,zinc,*/nb,dx,dy,sx;
  long adr,z,dz; unsigned long firstpos=0L;
/*  register*/ int /*a,*/zz;
/*  register*/ unsigned short *pz;
/*  unsigned short color2;*/
  
  long deltax,deltay,fdeltax,fdeltay,fdeltar,fdeltab,fdeltag;
  unsigned long colorr,colorb,colorg; 
  unsigned char *pp, *rcolor=((unsigned char *)&colorr)+1, *gcolor=((unsigned char *)&colorg)+1, *bcolor=((unsigned char *)&colorb)+1;
  short *ptdeltax=(short *)&deltax,*ptdeltay=(short *)&deltay;
  
  if (p1->y > p2->y || (p1->y == p2->y && p1->x > p2->x)) {
    ZBufferPoint *tmp;
    tmp=p1;
    p1=p2;
    p2=tmp;
  }
  colorr=((unsigned long)p1->r)<<8;
  colorg=((unsigned long)p1->g)<<8;
  colorb=((unsigned long)p1->b)<<8;
  sx=zb->xsize;
  adr=((long)p1->y * (long)sx + (long)p1->x);
  pp = (unsigned char *)((long)zb->pbuf + adr*3L);
  pz = zb->zbuf + adr;
  
  dx = p2->x - p1->x;
  dy = p2->y - p1->y;
  z = p1->z;
  dz = p2->z - p1->z;
#define PUTPIXEL() 				\
  {						\
    zz=z >> ZB_POINT_Z_FRAC_BITS;		\
    if (ZCMP(zz,*pz))  { 			\
      pp=(unsigned char*)(firstpos+((long)*ptdeltax+(long)*ptdeltay*(long)sx)*3L);	\
      *pp++ = *rcolor; 				\
      *pp++ = *gcolor; 				\
      *pp = *bcolor; 				\
      *pz=zz; 					\
    }						\
  }
/* fin macro */
  if (dx == 0 && dy == 0) {
    PUTPIXEL();
  } 
  else 
  {
  	firstpos=(unsigned long)pp;
  	if(abs(dx)>abs(dy))
  	{
  		nb=abs(dx);
  	}
  	else 	nb=abs(dy);
  	fdeltax=deltax=(dx<<16)/nb;
  	fdeltay=deltay=(dy<<16)/nb; 
  	fdeltar=(((long)((long)p2->r-(long)p1->r))<<8)/nb;
  	fdeltag=(((long)((long)p2->g-(long)p1->g))<<8)/nb;
  	fdeltab=(((long)((long)p2->b-(long)p1->b))<<8)/nb;		
   dz=dz/nb;
  	do {
  		
  		PUTPIXEL();
  		deltax+=fdeltax;
  		deltay+=fdeltay;
  		colorr+=fdeltar;  /* l'interpolation coute environ 2 img/min … 85 img/min chez moi */
  		colorb+=fdeltab;
  		colorg+=fdeltag;
  		z+=dz;
  		pz=zb->zbuf + adr + (long)*ptdeltax + (long)*ptdeltay*(long)sx;
 /* 		pp=firstpos+((long)*ptdeltax+(long)*ptdeltay*(long)sx)*3L; mis dans PUTPIXEL*/
  		
  		
  	} while(--nb>=0);
  }
#undef DRAWLINE
#undef PUTPIXEL
}
/* reprise de ZB_lineold2() l‚gerement acc‚l‚r‚ */ 
void ZB_lineold4(ZBuffer *zb,ZBufferPoint *p1,ZBufferPoint *p2) /* fonctionne maintenant en 24 bits */
{
  long /*n,zinc,*/nb,dx,dy,sx,nsx,nsy,nzsx,nzsy;
  long adr,z,dz; unsigned long firstpos=0L;
/*  register*/ int /*a,*/zz;
/*  register*/ unsigned short *pz;
/*  unsigned short color2;*/
  
  long deltax,deltay,fdeltax,fdeltay,fdeltar,fdeltab,fdeltag;
  unsigned long colorr,colorb,colorg; 
  unsigned char *pp, *rcolor=((unsigned char *)&colorr)+1, *gcolor=((unsigned char *)&colorg)+1, *bcolor=((unsigned char *)&colorb)+1;
  short *ptdeltax=(short *)&deltax,*ptdeltay=(short *)&deltay,oldptdeltax,oldptdeltay;
  
  if (p1->y > p2->y || (p1->y == p2->y && p1->x > p2->x)) {
    ZBufferPoint *tmp;
    tmp=p1;
    p1=p2;
    p2=tmp;
  }
  colorr=((unsigned long)p1->r)<<8;
  colorg=((unsigned long)p1->g)<<8;
  colorb=((unsigned long)p1->b)<<8;
  sx=zb->xsize;
  adr=((long)p1->y * (long)sx + (long)p1->x);
  pp = (unsigned char *)((long)zb->pbuf + adr*3L);
  pz = zb->zbuf + adr;
  
  dx = p2->x - p1->x;
  dy = p2->y - p1->y;
  z = p1->z;
  dz = p2->z - p1->z;
#define PUTPIXEL() 				\
  {						\
    zz=z >> ZB_POINT_Z_FRAC_BITS;		\
    if (ZCMP(zz,*pz))  { 			\
      *pp = *rcolor; 				\
      pp[1] = *gcolor; 				\
      pp[2] = *bcolor; 				\
      *pz=zz; 					\
    }						\
  }
/* fin macro */
  if (dx == 0 && dy == 0) {
    PUTPIXEL();
  } 
  else 
  {
  	firstpos=(unsigned long)pp;
  	if(abs(dx)>abs(dy))
  	{
  		nb=abs(dx);
  	}
  	else 	nb=abs(dy);
  	fdeltax=deltax=(dx<<16)/nb;
  	fdeltay=deltay=(dy<<16)/nb; 
  	fdeltar=(((long)((long)p2->r-(long)p1->r))<<8)/nb;
  	fdeltag=(((long)((long)p2->g-(long)p1->g))<<8)/nb;
  	fdeltab=(((long)((long)p2->b-(long)p1->b))<<8)/nb;		
   dz=dz/nb;
   oldptdeltax=*ptdeltax;
   oldptdeltay=*ptdeltay;
   if(dy<0)
   {
   	nsy=-sx*3L;
   	nzsy=-sx;
   }
   else
   {
   	nsy=sx*3L;
   	nzsy=sx;
   }
   if(dx<0)
   {
   	nsx=-3L;
   	nzsx=-1L;
   }
   else
   {
   	nsx=3L;
   	nzsx=1L;
   }
  	do {
  		
  		PUTPIXEL();
  		deltax+=fdeltax;
  		deltay+=fdeltay;
  		colorr+=fdeltar;  /* l'interpolation coute environ 2 img/min … 85 img/min chez moi */
  		colorb+=fdeltab;
  		colorg+=fdeltag;
  		z+=dz;
  		if(oldptdeltax!=*ptdeltax) 
  		{
  			oldptdeltax=*ptdeltax;
  			pz+=(long)nzsx;
  			pp+=nsx;
  		}
  		if(oldptdeltay!=*ptdeltay) 
  		{
  			oldptdeltay=*ptdeltay;
  			pz+=(long)nzsy;
  			pp+=nsy;
 		}			
  	} while(--nb>=0);
  }
#undef DRAWLINE
#undef PUTPIXEL
}
/* version la + rapide mais moins traits moins fins algorithme de Bresenham */
void ZB_lineold3(ZBuffer *zb,ZBufferPoint *p1,ZBufferPoint *p2) /* fonctionne maintenant en 24 bits */
{
  long /*n,zinc,*/nb,dx,dy,sx,adx,adx2,ady2,ady,E,nsy,zsy,nsx,zsx;
  long adr,z,dz; unsigned long firstpos=0L;
/*  register*/ int /*a,*/zz;
/*  register*/ unsigned short *pz;
/*  unsigned short color2;*/
  
  long fdeltar,fdeltab,fdeltag;
  unsigned long colorr,colorb,colorg; 
  unsigned char *pp, *rcolor=((unsigned char *)&colorr)+1, *gcolor=((unsigned char *)&colorg)+1, *bcolor=((unsigned char *)&colorb)+1;
  
  if (p1->y > p2->y || (p1->y == p2->y && p1->x > p2->x)) {
    ZBufferPoint *tmp;
    tmp=p1;
    p1=p2;
    p2=tmp;
  }
  colorr=((unsigned long)p1->r)<<8;
  colorg=((unsigned long)p1->g)<<8;
  colorb=((unsigned long)p1->b)<<8;
  sx=zb->xsize;
  adr=((long)p1->y * (long)sx + (long)p1->x);
  pp = (unsigned char *)((long)zb->pbuf + adr*3L);
  pz = zb->zbuf + adr;
  
  dx = p2->x - p1->x;
  dy = p2->y - p1->y;
  z = p1->z;
  dz = p2->z - p1->z;
#define PUTPIXEL() 				\
  {						\
    zz=z >> ZB_POINT_Z_FRAC_BITS;		\
    if (ZCMP(zz,*pz))  { 			\
      *pp++ = *rcolor; 				\
      *pp++ = *gcolor; 				\
      *pp = *bcolor; 				\
      *pz=zz; 					\
    }						\
  }
/* fin macro */
  if (dx == 0 && dy == 0) {
    PUTPIXEL();
  } 
  else 
  {
  	firstpos=(unsigned long)pp;
  	
  	adx=abs(dx);
  	ady=abs(dy);  		
  	nb=adx+ady;
  	E=(ady<<1)-adx;
  	fdeltar=(((long)((long)p2->r-(long)p1->r))<<8)/nb;
  	fdeltag=(((long)((long)p2->g-(long)p1->g))<<8)/nb;
  	fdeltab=(((long)((long)p2->b-(long)p1->b))<<8)/nb;		
   dz=dz/nb;
   if(dy<0) 
   {
   	nsy=-sx*3L;
   	zsy=-sx;
   }
   else 
   {
   	nsy=sx*3L;
   	zsy=sx;
   }	
   if(dx<0) 
   {
   	nsx=-3L;
   	zsx=-1L;
   }
   else 
   {
   	nsx=3L;
   	zsx=1L;
   }
   pz=zb->zbuf + adr;
   adx2=adx<<1;
   ady2=ady<<1;
  	do {
  		
  		PUTPIXEL();
  		colorr+=fdeltar;  /* l'interpolation coute environ 2 img/min … 85 img/min chez moi */
  		colorb+=fdeltab;
  		colorg+=fdeltag;
  		z+=dz;
  		if(E>0)
  		{
  			firstpos+=nsy;
  			E-=adx2;
  			pz+=zsy;
  		}	
  		else 
  		{
  			firstpos+=nsx;
  			E+=ady2;
  			pz+=zsx;
  		}
  		pp=firstpos;
  		
  		
  	} while(--nb>=0);
  }
#undef DRAWLINE
#undef PUTPIXEL
}
/* idem ZB_lineold3 mais ligne plus fines modif maison version finale! */
void ZB_line(ZBuffer *zb,ZBufferPoint *p1,ZBufferPoint *p2) /* fonctionne maintenant en 24 bits */
{
  long /*n,zinc,*/nb,dx,dy,sx,adx,adx2,ady2,ady,E,nsy,zsy,nsx,zsx,milieu;
  long adr,z,dz; unsigned long firstpos=0L;
/*  register*/ int /*a,*/zz;
/*  register*/ unsigned short *pz;
/*  unsigned short color2;*/
  
  long fdeltar,fdeltab,fdeltag;
  unsigned long colorr,colorb,colorg; 
  unsigned char *pp, *rcolor=((unsigned char *)&colorr)+1, *gcolor=((unsigned char *)&colorg)+1, *bcolor=((unsigned char *)&colorb)+1;
  
  if (p1->y > p2->y || (p1->y == p2->y && p1->x > p2->x)) {
    ZBufferPoint *tmp;
    tmp=p1;
    p1=p2;
    p2=tmp;
  }
  colorr=((unsigned long)p1->r)<<8;
  colorg=((unsigned long)p1->g)<<8;
  colorb=((unsigned long)p1->b)<<8;
  sx=zb->xsize;
  adr=((long)p1->y * (long)sx + (long)p1->x);
  pp = (unsigned char *)((long)zb->pbuf + adr*3L);
  pz = zb->zbuf + adr;
  
  dx = p2->x - p1->x;
  dy = p2->y - p1->y;
  z = p1->z;
  dz = p2->z - p1->z;
#define PUTPIXEL() 				\
  {						\
    zz=z >> ZB_POINT_Z_FRAC_BITS;		\
    if (ZCMP(zz,*pz))  { 			\
      *pp++ = *rcolor; 				\
      *pp++ = *gcolor; 				\
      *pp = *bcolor; 				\
      *pz=zz; 					\
    }						\
  }
/* fin macro */
  if (dx == 0 && dy == 0) {
    PUTPIXEL();
  } 
  else 
  {
  	firstpos=(unsigned long)pp;
  	
  	adx=abs(dx);
  	ady=abs(dy);  		
  	nb=adx+ady;
  	E=(ady<<1)-adx;
  	fdeltar=(((long)((long)p2->r-(long)p1->r))<<8)/nb;
  	fdeltag=(((long)((long)p2->g-(long)p1->g))<<8)/nb;
  	fdeltab=(((long)((long)p2->b-(long)p1->b))<<8)/nb;		
   dz=dz/nb;
   if(dy<0) 
   {
   	nsy=-sx*3L;
   	zsy=-sx;
   }
   else 
   {
   	nsy=sx*3L;
   	zsy=sx;
   }	
   if(dx<0) 
   {
   	nsx=-3L;
   	zsx=-1L;
   }
   else 
   {
   	nsx=3L;
   	zsx=1L;
   }
   pz=zb->zbuf + adr;
   adx2=adx<<1;
   ady2=ady<<1;
   if(adx>ady)
   {
   	milieu=adx;
   }
   else milieu=ady;
  	do {
  		
  		PUTPIXEL();
  /*		colorr+=fdeltar;  / * l'interpolation coute environ 2 img/min … 85 img/min chez moi  * /
  		colorb+=fdeltab;
  		colorg+=fdeltag;
  		z+=dz;*/
  		if(E>milieu)
  		{
  			firstpos+=nsy;
  			E-=adx2;
  			pz+=zsy;
  			nb--;
  			colorr+=fdeltar;  /* l'interpolation coute environ 2 img/min … 85 img/min chez moi */
  			colorb+=fdeltab;
  			colorg+=fdeltag;
  			z+=dz;
  		}
  		else
  		{
  			if(E<-milieu)
  			{
  				firstpos+=nsx;
  				E+=ady2;
  				pz+=zsx;
  				nb--;
  				colorr+=fdeltar;  /* l'interpolation coute environ 2 img/min … 85 img/min chez moi */
  				colorb+=fdeltab;
  				colorg+=fdeltag;
  				z+=dz;
  			}
  			else
  			{	/* pas en diagonale !!! */
  				firstpos+=(nsx+nsy);
  				E+=(ady2-adx2);
  				pz+=(zsx+zsy);
  				nb-=2;
  				colorr+=(fdeltar<<1);  /* l'interpolation coute environ 2 img/min … 85 img/min chez moi */
  				colorb+=(fdeltab<<1);
  				colorg+=(fdeltag<<1);
  				z+=(dz<<1);
  			}
  		}
  	/*	if(E>0)
  		{
  			firstpos+=nsy;
  			E-=adx2;
  			pz+=zsy;
  		}	
  		else 
  		{
  			firstpos+=nsx;
  			E+=ady2;
  			pz+=zsx;
  		}*/
  		pp=firstpos;
  		
  		
  	} while(nb>=0);
  }
#undef DRAWLINE
#undef PUTPIXEL
}
