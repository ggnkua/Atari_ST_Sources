/* spatscal.c, spatial scalability decoding                                 */

/* Copyright (C) 1994, MPEG Software Simulation Group. All Rights Reserved. */

/*
 * Disclaimer of Warranty
 *
 * These software programs are available to the user without any license fee or
 * royalty on an "as is" basis.  The MPEG Software Simulation Group disclaims
 * any and all warranties, whether express, implied, or statuary, including any
 * implied warranties or merchantability or of fitness for a particular
 * purpose.  In no event shall the copyright-holder be liable for any
 * incidental, punitive, or consequential damages of any kind whatsoever
 * arising from the use of these programs.
 *
 * This disclaimer of warranty extends to the user of these programs and user's
 * customers, employees, agents, transferees, successors, and assigns.
 *
 * The MPEG Software Simulation Group does not represent or warrant that the
 * programs furnished hereunder are free of infringement of any third-party
 * patents.
 *
 * Commercial implementations of MPEG-1 and MPEG-2 video, including shareware,
 * are subject to royalty fees to patent holders.  Many of these patents are
 * general enough such that they are unavoidable regardless of implementation
 * design.
 *
 */

#include <stdio.h>
#include "config.h"
#include "global.h"

/* private prototypes */
static void spatpred _ANSI_ARGS_((int prog_frame, int llprog_frame,
  unsigned char *fld0, unsigned char *fld1, short *tmp, unsigned char *dst,
  int llx0, int lly0, int llw, int llh, int horizontal_size, int vertical_size,
  int vm, int vn, int hm, int hn, int aperture));
static void deinterlace _ANSI_ARGS_((unsigned char *fld0, unsigned char *fld1,
  int j0, int lx, int ly, int aperture));
static void subv _ANSI_ARGS_((unsigned char *s, short *d,
  int lx, int lys, int lyd, int m, int n, int j0, int dj));
static void subh _ANSI_ARGS_((short *s, unsigned char *d,
  int x0, int lx, int lxs, int lxd, int ly, int m, int n));

/* get reference frame */
void getspatref()
{
  int i, j, llw2, llh2;
  FILE *fd;
  char fname[80];

  llw2 = llw>>1;
  llh2 = llh>>1;

  sprintf(fname,llinputname,lltempref,'a');
  strcat(fname,".Y");
  if (verbose>1)
    printf("reading %s\n",fname);
  fd=fopen(fname,"rb");
  for (j=0; j<llh; j+=2)
    for (i=0; i<llw; i++)
      llframe0[0][llw*j+i]=getc(fd);
  fclose(fd);

  sprintf(fname,llinputname,lltempref,'b');
  strcat(fname,".Y");
  if (verbose>1)
    printf("reading %s\n",fname);
  fd=fopen(fname,"rb");
  for (j=1; j<llh; j+=2)
    for (i=0; i<llw; i++)
      llframe1[0][llw*j+i]=getc(fd);
  fclose(fd);

  sprintf(fname,llinputname,lltempref,'a');
  strcat(fname,".U");
  if (verbose>1)
    printf("reading %s\n",fname);
  fd=fopen(fname,"rb");
  for (j=0; j<llh2; j+=2)
    for (i=0; i<llw2; i++)
      llframe0[1][llw2*j+i]=getc(fd);
  fclose(fd);

  sprintf(fname,llinputname,lltempref,'b');
  strcat(fname,".U");
  if (verbose>1)
    printf("reading %s\n",fname);
  fd=fopen(fname,"rb");
  for (j=1; j<llh2; j+=2)
    for (i=0; i<llw2; i++)
      llframe1[1][llw2*j+i]=getc(fd);
  fclose(fd);

  sprintf(fname,llinputname,lltempref,'a');
  strcat(fname,".V");
  if (verbose>1)
    printf("reading %s\n",fname);
  fd=fopen(fname,"rb");
  for (j=0; j<llh2; j+=2)
    for (i=0; i<llw2; i++)
      llframe0[2][llw2*j+i]=getc(fd);
  fclose(fd);

  sprintf(fname,llinputname,lltempref,'b');
  strcat(fname,".V");
  if (verbose>1)
    printf("reading %s\n",fname);
  fd=fopen(fname,"rb");
  for (j=1; j<llh2; j+=2)
    for (i=0; i<llw2; i++)
      llframe1[2][llw2*j+i]=getc(fd);
  fclose(fd);

  spatpred(prog_frame,llprog_frame,llframe0[0],llframe1[0],lltmp,newframe[0],
    llx0,lly0,llw,llh,horizontal_size,vertical_size,vm,vn,hm,hn,
      pict_struct!=FRAME_PICTURE); /* this changed from CD to DIS */
  spatpred(prog_frame,llprog_frame,llframe0[1],llframe1[1],lltmp,newframe[1],
    llx0/2,lly0/2,llw2,llh2,horizontal_size>>1,vertical_size>>1,vm,vn,hm,hn,1);
  spatpred(prog_frame,llprog_frame,llframe0[2],llframe1[2],lltmp,newframe[2],
    llx0/2,lly0/2,llw2,llh2,horizontal_size>>1,vertical_size>>1,vm,vn,hm,hn,1);
}

/* form spatial prediction */
static void spatpred(prog_frame,llprog_frame,
  fld0,fld1,tmp,dst,llx0,lly0,llw,llh,horizontal_size,vertical_size,
  vm,vn,hm,hn,aperture)
int prog_frame,llprog_frame;
unsigned char *fld0,*fld1;
short *tmp;
unsigned char *dst;
int llx0,lly0,llw,llh,horizontal_size,vertical_size,vm,vn,hm,hn,aperture;
{
  int w, h, x0, llw2, llh2;
#if 0
  if (llprog_frame)
  {
    /* progressive -> progressive / interlaced */
    subv(fld0,tmp,horizontal_sizell,vertical_sizell,vertical_size,m,n,0,1);
    subh(tmp,dst,0,horizontal_size,horizontal_sizell,horizontal_size,vertical_size,m,n);
  }
  else if (prog_frame)
  {
    /* interlaced -> progressive */
    if (ll_fldsel)
    {
      deinterlace(fld1,fld0);
      subv(fld1,tmp);
      subh(tmp,dst);
    }
    else
    {
      deinterlace(fld0,fld1);
      subv(fld0,tmp);
      subh(tmp,dst);
    }
  }
  else
  {
#endif

    /* interlaced -> interlaced */
    llw2 = (llw*hn)/hm;
    llh2 = (llh*vn)/vm;
    deinterlace(fld0,fld1,1,llw,llh,aperture);
    deinterlace(fld1,fld0,0,llw,llh,aperture);
    subv(fld0,tmp,llw,llh,llh2,vm,vn,0,2);
    subv(fld1,tmp,llw,llh,llh2,vm,vn,1,2);

    /* vertical limits */
    if (lly0<0)
    {
      tmp-= llw*lly0;
      llh2+= lly0;
      if (llh2<0)
        llh2 = 0;
      h = (vertical_size<llh2) ? vertical_size : llh2;
    }
    else
    {
      dst+= horizontal_size*lly0;
      h= vertical_size - lly0;
      if (h>llh2)
        h = llh2;
    }

    /* horizontal limits */
    if (llx0<0)
    {
      x0 = -llx0;
      llw2+= llx0;
      if (llw2<0)
        llw2 = 0;
      w = (horizontal_size<llw2) ? horizontal_size : llw2;
    }
    else
    {
      dst+= llx0;
      x0 = 0;
      w = horizontal_size - llx0;
      if (w>llw2)
        w = llw2;
    }
    subh(tmp,dst,x0,w,llw,horizontal_size,h,hm,hn);

#if 0
  }
#endif
}

/* deinterlace one field (interpolate opposite parity samples)
 *
 * deinterlacing is done in-place: if j0=1, fld0 contains the input field in
 * its even lines and the odd lines are interpolated by this routine
 * if j0=0, the input field is in the odd lines and the even lines are
 * interpolated
 *
 * fld0: field to be deinterlaced
 * fld1: other field (referenced by the two field aperture filter)
 * j0:   0: interpolate even (top) lines, 1: interpolate odd (bottom) lines
 * lx:   width of fld0 and fld1
 * ly:   height of the deinterlaced field (has to be even)
 * aperture: 1: use one field aperture filter (two field otherwise)
 */
static void deinterlace(fld0,fld1,j0,lx,ly,aperture)
unsigned char *fld0,*fld1;
int j0,lx,ly; /* ly has to be even */
int aperture;
{
  int i,j,v;
  unsigned char *p0, *p0m1, *p0p1, *p1, *p1m2, *p1p2;

  /* deinterlace one field */
  for (j=j0; j<ly; j+=2)
  {
    p0 = fld0+lx*j;
    p0m1 = (j==0)    ? p0+lx : p0-lx;
    p0p1 = (j==ly-1) ? p0-lx : p0+lx;

    if (aperture)
      for (i=0; i<lx; i++)
        p0[i] = (unsigned int)(p0m1[i] + p0p1[i] + 1)>>1;
    else
    {
      p1 = fld1 + lx*j;
      p1m2 = (j<2)     ? p1 : p1-2*lx;
      p1p2 = (j>=ly-2) ? p1 : p1+2*lx;
      for (i=0; i<lx; i++)
      {
        v = 8*(p0m1[i]+p0p1[i]) + 2*p1[i] - p1m2[i] - p1p2[i];
        p0[i] = clp[(v + ((v>=0) ? 8 : 7))>>4];
      }
    }
  }
}

/* vertical resampling */
static void subv(s,d,lx,lys,lyd,m,n,j0,dj)
unsigned char *s;
short *d;
int lx, lys, lyd, m, n, j0, dj;
{
  int i, j, c1, c2, jd;
  unsigned char *s1, *s2;
  short *d1;

  for (j=j0; j<lyd; j+=dj)
  {
    d1 = d + lx*j;
    jd = (j*m)/n;
    s1 = s + lx*jd;
    s2 = (jd<lys-1)? s1+lx : s1;
    c2 = (16*((j*m)%n) + (n>>1))/n;
    c1 = 16 - c2;
    for (i=0; i<lx; i++)
      d1[i] = c1*s1[i] + c2*s2[i];
  }
}

/* horizontal resampling */
static void subh(s,d,x0,lx,lxs,lxd,ly,m,n)
short *s;
unsigned char *d;
int x0, lx, lxs, lxd, ly, m, n;
{
  int i, i1, j, id, c1, c2, v;
  short *s1, *s2;
  unsigned char *d1;

  for (i1=0; i1<lx; i1++)
  {
    d1 = d + i1;
    i = x0 + i1;
    id = (i*m)/n;
    s1 = s+id;
    s2 = (id<lxs-1) ? s1+1 : s1;
    c2 = (16*((i*m)%n) + (n>>1))/n;
    c1 = 16 - c2;
    for (j=0; j<ly; j++)
    {
      v = c1*(*s1) + c2*(*s2);
      *d1 = (v + ((v>=0) ? 128 : 127))>>8;
      d1+= lxd;
      s1+= lxs;
      s2+= lxs;
    }
  }
}
