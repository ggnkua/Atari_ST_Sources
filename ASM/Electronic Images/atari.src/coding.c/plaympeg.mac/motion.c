/*
 *	PLAYMPEG.
 *	Martin Griffiths 1995.
 */

#include <stdio.h>
#include <stdlib.h>
#include "plaympeg.h"

static void calcMV _ANSI_ARGS_((INT32 *pred, INT32 r_size, INT32 motion_code,
  INT32 motion_r, INT32 full_pel_vector));

static void recon _ANSI_ARGS_((unsigned char *src[], INT32 sfield,
  unsigned char *dst[], INT32 dfield,
  INT32 lx, INT32 lx2, INT32 w, INT32 h, INT32 x, INT32 y, INT32 dx, INT32 dy,
  INT32 addflag));
static void recon_comp _ANSI_ARGS_((unsigned char *src, unsigned char *dst,
  INT32 lx, INT32 lx2, INT32 w, INT32 h, INT32 x, INT32 y, INT32 dx, INT32 dy, INT32 addflag));
static void rec _ANSI_ARGS_((unsigned char *s, unsigned char *d, INT32 lx2, INT32 h));
static void recc _ANSI_ARGS_((unsigned char *s, unsigned char *d, INT32 lx2, INT32 h));
static void reca _ANSI_ARGS_((unsigned char *s, unsigned char *d, INT32 lx2, INT32 h));
static void recac _ANSI_ARGS_((unsigned char *s, unsigned char *d, INT32 lx2, INT32 h));
static void rech _ANSI_ARGS_((unsigned char *s, unsigned char *d, INT32 lx2, INT32 h));
static void rechc _ANSI_ARGS_((unsigned char *s, unsigned char *d, INT32 lx2, INT32 h));
static void recha _ANSI_ARGS_((unsigned char *s, unsigned char *d, INT32 lx2, INT32 h));
static void rechac _ANSI_ARGS_((unsigned char *s, unsigned char *d, INT32 lx2, INT32 h));
static void recv _ANSI_ARGS_((unsigned char *s, unsigned char *d, INT32 lx, INT32 lx2, INT32 h));
static void recvc _ANSI_ARGS_((unsigned char *s, unsigned char *d, INT32 lx, INT32 lx2, INT32 h));
static void recva _ANSI_ARGS_((unsigned char *s, unsigned char *d, INT32 lx, INT32 lx2, INT32 h));
static void recvac _ANSI_ARGS_((unsigned char *s, unsigned char *d, INT32 lx, INT32 lx2, INT32 h));
static void rec4 _ANSI_ARGS_((unsigned char *s, unsigned char *d, INT32 lx, INT32 lx2, INT32 h));
static void rec4c _ANSI_ARGS_((unsigned char *s, unsigned char *d, INT32 lx, INT32 lx2, INT32 h));
static void rec4a _ANSI_ARGS_((unsigned char *s, unsigned char *d, INT32 lx, INT32 lx2, INT32 h));
static void rec4ac _ANSI_ARGS_((unsigned char *s, unsigned char *d, INT32 lx, INT32 lx2, INT32 h));

/* get and decode motion vector and differential motion vector */

void motion_vector(PMV,h_r_size,v_r_size,full_pel_vector)
INT32 *PMV;
INT32 h_r_size;
INT32 v_r_size;
INT32 full_pel_vector; /* MPEG-1 only */
{
  INT32 motion_code,motion_r;

  motion_code = getMV();
  motion_r = (h_r_size!=0 && motion_code!=0) ? getbits(h_r_size) : 0;

  calcMV(&PMV[0],h_r_size,motion_code,motion_r,full_pel_vector);

  motion_code = getMV();
  motion_r = (v_r_size!=0 && motion_code!=0) ? getbits(v_r_size) : 0;

  calcMV(&PMV[1],v_r_size,motion_code,motion_r,full_pel_vector);

}

/* calculate motion vector component */
static void calcMV(pred,r_size,motion_code,motion_r,full_pel_vector)
INT32 *pred;
INT32 r_size, motion_code, motion_r, full_pel_vector;
{
  INT32 lim, vec;

  lim = 16<<r_size;
  vec = full_pel_vector ? (*pred >> 1) : (*pred);

  if (motion_code>0)
  {
    vec+= ((motion_code-1)<<r_size) + motion_r + 1;
    if (vec>=lim)
      vec-= lim + lim;
  }
  else if (motion_code<0)
  {
    vec-= ((-motion_code-1)<<r_size) + motion_r + 1;
    if (vec<-lim)
      vec+= lim + lim;
  }
  *pred = full_pel_vector ? (vec<<1) : vec;
}


void reconstruct(bx,by,mb_type,PMV,stwtype)
INT32 bx, by;
INT32 mb_type;
INT32 PMV[2][2][2];
INT32 stwtype;
{
  INT32 DMV[2][2];
  INT32 stwtop, stwbot;

  stwtop = stwtype%3; /* 0:temporal, 1:(spat+temp)/2, 2:spatial */
  stwbot = stwtype/3;

  if ((mb_type & MB_FORWARD) || (pict_type==P_TYPE))
  {
        /* frame-based prediction */
        if (stwtop<2)
          recon(oldrefframe,0,newframe,0,
            coded_picture_width,coded_picture_width<<1,16,8,bx,by,
            PMV[0][0][0],PMV[0][0][1],stwtop);

        if (stwbot<2)
          recon(oldrefframe,1,newframe,1,
            coded_picture_width,coded_picture_width<<1,16,8,bx,by,
            PMV[0][0][0],PMV[0][0][1],stwbot);

    stwtop = stwbot = 1;
  }

  if (mb_type & MB_BACKWARD)
  {
        /* frame-based prediction */
        if (stwtop<2)
          recon(refframe,0,newframe,0,
            coded_picture_width,coded_picture_width<<1,16,8,bx,by,
            PMV[0][1][0],PMV[0][1][1],stwtop);

        if (stwbot<2)
          recon(refframe,1,newframe,1,
            coded_picture_width,coded_picture_width<<1,16,8,bx,by,
            PMV[0][1][0],PMV[0][1][1],stwbot);
  }
}

static void recon(src,sfield,dst,dfield,lx,lx2,w,h,x,y,dx,dy,addflag)
unsigned char *src[]; /* prediction source buffer */
INT32 sfield;           /* prediction source field number (0 or 1) */
unsigned char *dst[]; /* prediction destination buffer */
INT32 dfield;           /* prediction destination field number (0 or 1)*/
INT32 lx,lx2;           /* horizontal offsets */
INT32 w,h;              /* prediction block/sub-block width, height */
INT32 x,y;              /* pixel co-ordinates of top-left sample in current MB */
INT32 dx,dy;            /* horizontal, vertical motion vector */
INT32 addflag;          /* add prediction error to prediction ? */
{
  /* Y */
  recon_comp(src[0]+(sfield?lx2>>1:0),dst[0]+(dfield?lx2>>1:0),
  lx,lx2,w,h,x,y,dx,dy,addflag);

  lx>>=1; lx2>>=1; w>>=1; x>>=1; dx/=2;
  h>>=1; y>>=1; dy/=2;

  /* Cb */
  recon_comp(src[1]+(sfield?lx2>>1:0),dst[1]+(dfield?lx2>>1:0),
    lx,lx2,w,h,x,y,dx,dy,addflag);
  /* Cr */
  recon_comp(src[2]+(sfield?lx2>>1:0),dst[2]+(dfield?lx2>>1:0),
    lx,lx2,w,h,x,y,dx,dy,addflag);
}

static void recon_comp(src,dst,lx,lx2,w,h,x,y,dx,dy,addflag)
unsigned char *src;
unsigned char *dst;
INT32 lx,lx2;
INT32 w,h;
INT32 x,y;
INT32 dx,dy;
INT32 addflag;
{
  INT32 xint, xh, yint, yh;
  unsigned char *s, *d;

  /* half pel scaling */
  xint = dx>>1;
  xh = dx & 1;
  yint = dy>>1;
  yh = dy & 1;

  /* origins */
  s = src + lx*(y+yint) + x + xint;
  d = dst + lx*y + x;

  if (!xh && !yh)
    if (addflag)
    {
      if (w!=8)
        reca(s,d,lx2,h);
      else
        recac(s,d,lx2,h);
    }
    else
    {
      if (w!=8)
        rec(s,d,lx2,h);
      else
        recc(s,d,lx2,h);
    }
  else if (!xh && yh)
    if (addflag)
    {
      if (w!=8)
        recva(s,d,lx,lx2,h);
      else
        recvac(s,d,lx,lx2,h);
    }
    else
    {
      if (w!=8)
        recv(s,d,lx,lx2,h);
      else
        recvc(s,d,lx,lx2,h);
    }
  else if (xh && !yh)
    if (addflag)
    {
      if (w!=8)
        recha(s,d,lx2,h);
      else
        rechac(s,d,lx2,h);
    }
    else
    {
      if (w!=8)
        rech(s,d,lx2,h);
      else
        rechc(s,d,lx2,h);
    }
  else /* if (xh && yh) */
    if (addflag)
    {
      if (w!=8)
        rec4a(s,d,lx,lx2,h);
      else
        rec4ac(s,d,lx,lx2,h);
    }
    else
    {
      if (w!=8)
        rec4(s,d,lx,lx2,h);
      else
        rec4c(s,d,lx,lx2,h);
    }
}

static void rec(s,d,lx2,h)
unsigned char *s, *d;
INT32 lx2,h;
{
  INT32 j;

  for (j=0; j<h; j++)
  {
    d[0] = s[0];
    d[1] = s[1];
    d[2] = s[2];
    d[3] = s[3];
    d[4] = s[4];
    d[5] = s[5];
    d[6] = s[6];
    d[7] = s[7];
    d[8] = s[8];
    d[9] = s[9];
    d[10] = s[10];
    d[11] = s[11];
    d[12] = s[12];
    d[13] = s[13];
    d[14] = s[14];
    d[15] = s[15];
    s+= lx2;
    d+= lx2;
  }
}

static void recc(s,d,lx2,h)
unsigned char *s, *d;
INT32 lx2,h;
{
  INT32 j;

  for (j=0; j<h; j++)
  {
    d[0] = s[0];
    d[1] = s[1];
    d[2] = s[2];
    d[3] = s[3];
    d[4] = s[4];
    d[5] = s[5];
    d[6] = s[6];
    d[7] = s[7];
    s+= lx2;
    d+= lx2;
  }
}

static void reca(s,d,lx2,h)
unsigned char *s, *d;
INT32 lx2,h;
{
  INT32 j;

  for (j=0; j<h; j++)
  {
    d[0] = (UINT32)(d[0] + s[0] + 1)>>1;
    d[1] = (UINT32)(d[1] + s[1] + 1)>>1;
    d[2] = (UINT32)(d[2] + s[2] + 1)>>1;
    d[3] = (UINT32)(d[3] + s[3] + 1)>>1;
    d[4] = (UINT32)(d[4] + s[4] + 1)>>1;
    d[5] = (UINT32)(d[5] + s[5] + 1)>>1;
    d[6] = (UINT32)(d[6] + s[6] + 1)>>1;
    d[7] = (UINT32)(d[7] + s[7] + 1)>>1;
    d[8] = (UINT32)(d[8] + s[8] + 1)>>1;
    d[9] = (UINT32)(d[9] + s[9] + 1)>>1;
    d[10] = (UINT32)(d[10] + s[10] + 1)>>1;
    d[11] = (UINT32)(d[11] + s[11] + 1)>>1;
    d[12] = (UINT32)(d[12] + s[12] + 1)>>1;
    d[13] = (UINT32)(d[13] + s[13] + 1)>>1;
    d[14] = (UINT32)(d[14] + s[14] + 1)>>1;
    d[15] = (UINT32)(d[15] + s[15] + 1)>>1;
    s+= lx2;
    d+= lx2;
  }
}

static void recac(s,d,lx2,h)
unsigned char *s, *d;
INT32 lx2,h;
{
  INT32 j;

  for (j=0; j<h; j++)
  {
    d[0] = (UINT32)(d[0] + s[0] + 1)>>1;
    d[1] = (UINT32)(d[1] + s[1] + 1)>>1;
    d[2] = (UINT32)(d[2] + s[2] + 1)>>1;
    d[3] = (UINT32)(d[3] + s[3] + 1)>>1;
    d[4] = (UINT32)(d[4] + s[4] + 1)>>1;
    d[5] = (UINT32)(d[5] + s[5] + 1)>>1;
    d[6] = (UINT32)(d[6] + s[6] + 1)>>1;
    d[7] = (UINT32)(d[7] + s[7] + 1)>>1;
    s+= lx2;
    d+= lx2;
  }
}

static void rech(s,d,lx2,h)
unsigned char *s, *d;
INT32 lx2,h;
{
  unsigned char *dp,*sp;
  INT32 j;
  UINT32 s1,s2;

  sp = s;
  dp = d;
  for (j=0; j<h; j++)
  {
    s1=sp[0];
    dp[0] = (UINT32)(s1+(s2=sp[1])+1)>>1;
    dp[1] = (UINT32)(s2+(s1=sp[2])+1)>>1;
    dp[2] = (UINT32)(s1+(s2=sp[3])+1)>>1;
    dp[3] = (UINT32)(s2+(s1=sp[4])+1)>>1;
    dp[4] = (UINT32)(s1+(s2=sp[5])+1)>>1;
    dp[5] = (UINT32)(s2+(s1=sp[6])+1)>>1;
    dp[6] = (UINT32)(s1+(s2=sp[7])+1)>>1;
    dp[7] = (UINT32)(s2+(s1=sp[8])+1)>>1;
    dp[8] = (UINT32)(s1+(s2=sp[9])+1)>>1;
    dp[9] = (UINT32)(s2+(s1=sp[10])+1)>>1;
    dp[10] = (UINT32)(s1+(s2=sp[11])+1)>>1;
    dp[11] = (UINT32)(s2+(s1=sp[12])+1)>>1;
    dp[12] = (UINT32)(s1+(s2=sp[13])+1)>>1;
    dp[13] = (UINT32)(s2+(s1=sp[14])+1)>>1;
    dp[14] = (UINT32)(s1+(s2=sp[15])+1)>>1;
    dp[15] = (UINT32)(s2+sp[16]+1)>>1;
    sp+= lx2;
    dp+= lx2;
  }
}

static void rechc(s,d,lx2,h)
unsigned char *s, *d;
INT32 lx2,h;
{
  unsigned char *dp,*sp;
  INT32 j;
  UINT32 s1,s2;

  sp = s;
  dp = d;
  for (j=0; j<h; j++)
  {
    s1=sp[0];
    dp[0] = (UINT32)(s1+(s2=sp[1])+1)>>1;
    dp[1] = (UINT32)(s2+(s1=sp[2])+1)>>1;
    dp[2] = (UINT32)(s1+(s2=sp[3])+1)>>1;
    dp[3] = (UINT32)(s2+(s1=sp[4])+1)>>1;
    dp[4] = (UINT32)(s1+(s2=sp[5])+1)>>1;
    dp[5] = (UINT32)(s2+(s1=sp[6])+1)>>1;
    dp[6] = (UINT32)(s1+(s2=sp[7])+1)>>1;
    dp[7] = (UINT32)(s2+sp[8]+1)>>1;
    sp+= lx2;
    dp+= lx2;
  }
}

static void recha(s,d,lx2,h)
unsigned char *s, *d;
INT32 lx2,h;
{
  unsigned char *dp,*sp;
  INT32 j;
  UINT32 s1,s2;

  sp = s;
  dp = d;
  for (j=0; j<h; j++)
  {
    s1=sp[0];
    dp[0] = (dp[0] + ((UINT32)(s1+(s2=sp[1])+1)>>1) + 1)>>1;
    dp[1] = (dp[1] + ((UINT32)(s2+(s1=sp[2])+1)>>1) + 1)>>1;
    dp[2] = (dp[2] + ((UINT32)(s1+(s2=sp[3])+1)>>1) + 1)>>1;
    dp[3] = (dp[3] + ((UINT32)(s2+(s1=sp[4])+1)>>1) + 1)>>1;
    dp[4] = (dp[4] + ((UINT32)(s1+(s2=sp[5])+1)>>1) + 1)>>1;
    dp[5] = (dp[5] + ((UINT32)(s2+(s1=sp[6])+1)>>1) + 1)>>1;
    dp[6] = (dp[6] + ((UINT32)(s1+(s2=sp[7])+1)>>1) + 1)>>1;
    dp[7] = (dp[7] + ((UINT32)(s2+(s1=sp[8])+1)>>1) + 1)>>1;
    dp[8] = (dp[8] + ((UINT32)(s1+(s2=sp[9])+1)>>1) + 1)>>1;
    dp[9] = (dp[9] + ((UINT32)(s2+(s1=sp[10])+1)>>1) + 1)>>1;
    dp[10] = (dp[10] + ((UINT32)(s1+(s2=sp[11])+1)>>1) + 1)>>1;
    dp[11] = (dp[11] + ((UINT32)(s2+(s1=sp[12])+1)>>1) + 1)>>1;
    dp[12] = (dp[12] + ((UINT32)(s1+(s2=sp[13])+1)>>1) + 1)>>1;
    dp[13] = (dp[13] + ((UINT32)(s2+(s1=sp[14])+1)>>1) + 1)>>1;
    dp[14] = (dp[14] + ((UINT32)(s1+(s2=sp[15])+1)>>1) + 1)>>1;
    dp[15] = (dp[15] + ((UINT32)(s2+sp[16]+1)>>1) + 1)>>1;
    sp+= lx2;
    dp+= lx2;
  }
}

static void rechac(s,d,lx2,h)
unsigned char *s, *d;
INT32 lx2,h;
{
  unsigned char *dp,*sp;
  INT32 j;
  UINT32 s1,s2;

  sp = s;
  dp = d;
  for (j=0; j<h; j++)
  {
    s1=sp[0];
    dp[0] = (dp[0] + ((UINT32)(s1+(s2=sp[1])+1)>>1) + 1)>>1;
    dp[1] = (dp[1] + ((UINT32)(s2+(s1=sp[2])+1)>>1) + 1)>>1;
    dp[2] = (dp[2] + ((UINT32)(s1+(s2=sp[3])+1)>>1) + 1)>>1;
    dp[3] = (dp[3] + ((UINT32)(s2+(s1=sp[4])+1)>>1) + 1)>>1;
    dp[4] = (dp[4] + ((UINT32)(s1+(s2=sp[5])+1)>>1) + 1)>>1;
    dp[5] = (dp[5] + ((UINT32)(s2+(s1=sp[6])+1)>>1) + 1)>>1;
    dp[6] = (dp[6] + ((UINT32)(s1+(s2=sp[7])+1)>>1) + 1)>>1;
    dp[7] = (dp[7] + ((UINT32)(s2+sp[8]+1)>>1) + 1)>>1;
    sp+= lx2;
    dp+= lx2;
  }
}

static void recv(s,d,lx,lx2,h)
unsigned char *s, *d;
INT32 lx,lx2,h;
{
  unsigned char *dp,*sp,*sp2;
  INT32 j;

  sp = s;
  sp2 = s+lx;
  dp = d;
  for (j=0; j<h; j++)
  {
    dp[0] = (UINT32)(sp[0]+sp2[0]+1)>>1;
    dp[1] = (UINT32)(sp[1]+sp2[1]+1)>>1;
    dp[2] = (UINT32)(sp[2]+sp2[2]+1)>>1;
    dp[3] = (UINT32)(sp[3]+sp2[3]+1)>>1;
    dp[4] = (UINT32)(sp[4]+sp2[4]+1)>>1;
    dp[5] = (UINT32)(sp[5]+sp2[5]+1)>>1;
    dp[6] = (UINT32)(sp[6]+sp2[6]+1)>>1;
    dp[7] = (UINT32)(sp[7]+sp2[7]+1)>>1;
    dp[8] = (UINT32)(sp[8]+sp2[8]+1)>>1;
    dp[9] = (UINT32)(sp[9]+sp2[9]+1)>>1;
    dp[10] = (UINT32)(sp[10]+sp2[10]+1)>>1;
    dp[11] = (UINT32)(sp[11]+sp2[11]+1)>>1;
    dp[12] = (UINT32)(sp[12]+sp2[12]+1)>>1;
    dp[13] = (UINT32)(sp[13]+sp2[13]+1)>>1;
    dp[14] = (UINT32)(sp[14]+sp2[14]+1)>>1;
    dp[15] = (UINT32)(sp[15]+sp2[15]+1)>>1;
    sp+= lx2;
    sp2+= lx2;
    dp+= lx2;
  }
}

static void recvc(s,d,lx,lx2,h)
unsigned char *s, *d;
INT32 lx,lx2,h;
{
  unsigned char *dp,*sp,*sp2;
  INT32 j;

  sp = s;
  sp2 = s+lx;
  dp = d;
  for (j=0; j<h; j++)
  {
    dp[0] = (UINT32)(sp[0]+sp2[0]+1)>>1;
    dp[1] = (UINT32)(sp[1]+sp2[1]+1)>>1;
    dp[2] = (UINT32)(sp[2]+sp2[2]+1)>>1;
    dp[3] = (UINT32)(sp[3]+sp2[3]+1)>>1;
    dp[4] = (UINT32)(sp[4]+sp2[4]+1)>>1;
    dp[5] = (UINT32)(sp[5]+sp2[5]+1)>>1;
    dp[6] = (UINT32)(sp[6]+sp2[6]+1)>>1;
    dp[7] = (UINT32)(sp[7]+sp2[7]+1)>>1;
    sp+= lx2;
    sp2+= lx2;
    dp+= lx2;
  }
}

static void recva(s,d,lx,lx2,h)
unsigned char *s, *d;
INT32 lx,lx2,h;
{
  unsigned char *dp,*sp,*sp2;
  INT32 j;

  sp = s;
  sp2 = s+lx;
  dp = d;
  for (j=0; j<h; j++)
  {
    dp[0] = (dp[0] + ((UINT32)(sp[0]+sp2[0]+1)>>1) + 1)>>1;
    dp[1] = (dp[1] + ((UINT32)(sp[1]+sp2[1]+1)>>1) + 1)>>1;
    dp[2] = (dp[2] + ((UINT32)(sp[2]+sp2[2]+1)>>1) + 1)>>1;
    dp[3] = (dp[3] + ((UINT32)(sp[3]+sp2[3]+1)>>1) + 1)>>1;
    dp[4] = (dp[4] + ((UINT32)(sp[4]+sp2[4]+1)>>1) + 1)>>1;
    dp[5] = (dp[5] + ((UINT32)(sp[5]+sp2[5]+1)>>1) + 1)>>1;
    dp[6] = (dp[6] + ((UINT32)(sp[6]+sp2[6]+1)>>1) + 1)>>1;
    dp[7] = (dp[7] + ((UINT32)(sp[7]+sp2[7]+1)>>1) + 1)>>1;
    dp[8] = (dp[8] + ((UINT32)(sp[8]+sp2[8]+1)>>1) + 1)>>1;
    dp[9] = (dp[9] + ((UINT32)(sp[9]+sp2[9]+1)>>1) + 1)>>1;
    dp[10] = (dp[10] + ((UINT32)(sp[10]+sp2[10]+1)>>1) + 1)>>1;
    dp[11] = (dp[11] + ((UINT32)(sp[11]+sp2[11]+1)>>1) + 1)>>1;
    dp[12] = (dp[12] + ((UINT32)(sp[12]+sp2[12]+1)>>1) + 1)>>1;
    dp[13] = (dp[13] + ((UINT32)(sp[13]+sp2[13]+1)>>1) + 1)>>1;
    dp[14] = (dp[14] + ((UINT32)(sp[14]+sp2[14]+1)>>1) + 1)>>1;
    dp[15] = (dp[15] + ((UINT32)(sp[15]+sp2[15]+1)>>1) + 1)>>1;
    sp+= lx2;
    sp2+= lx2;
    dp+= lx2;
  }
}

static void recvac(s,d,lx,lx2,h)
unsigned char *s, *d;
INT32 lx,lx2,h;
{
  unsigned char *dp,*sp,*sp2;
  INT32 j;

  sp = s;
  sp2 = s+lx;
  dp = d;
  for (j=0; j<h; j++)
  {
    dp[0] = (dp[0] + ((UINT32)(sp[0]+sp2[0]+1)>>1) + 1)>>1;
    dp[1] = (dp[1] + ((UINT32)(sp[1]+sp2[1]+1)>>1) + 1)>>1;
    dp[2] = (dp[2] + ((UINT32)(sp[2]+sp2[2]+1)>>1) + 1)>>1;
    dp[3] = (dp[3] + ((UINT32)(sp[3]+sp2[3]+1)>>1) + 1)>>1;
    dp[4] = (dp[4] + ((UINT32)(sp[4]+sp2[4]+1)>>1) + 1)>>1;
    dp[5] = (dp[5] + ((UINT32)(sp[5]+sp2[5]+1)>>1) + 1)>>1;
    dp[6] = (dp[6] + ((UINT32)(sp[6]+sp2[6]+1)>>1) + 1)>>1;
    dp[7] = (dp[7] + ((UINT32)(sp[7]+sp2[7]+1)>>1) + 1)>>1;
    sp+= lx2;
    sp2+= lx2;
    dp+= lx2;
  }
}

static void rec4(s,d,lx,lx2,h)
unsigned char *s, *d;
INT32 lx,lx2,h;
{
  unsigned char *dp,*sp,*sp2;
  INT32 j;
  UINT32 s1,s2,s3,s4;

  sp = s;
  sp2 = s+lx;
  dp = d;
  for (j=0; j<h; j++)
  {
    s1=sp[0]; s3=sp2[0];
    dp[0] = (UINT32)(s1+(s2=sp[1])+s3+(s4=sp2[1])+2)>>2;
    dp[1] = (UINT32)(s2+(s1=sp[2])+s4+(s3=sp2[2])+2)>>2;
    dp[2] = (UINT32)(s1+(s2=sp[3])+s3+(s4=sp2[3])+2)>>2;
    dp[3] = (UINT32)(s2+(s1=sp[4])+s4+(s3=sp2[4])+2)>>2;
    dp[4] = (UINT32)(s1+(s2=sp[5])+s3+(s4=sp2[5])+2)>>2;
    dp[5] = (UINT32)(s2+(s1=sp[6])+s4+(s3=sp2[6])+2)>>2;
    dp[6] = (UINT32)(s1+(s2=sp[7])+s3+(s4=sp2[7])+2)>>2;
    dp[7] = (UINT32)(s2+(s1=sp[8])+s4+(s3=sp2[8])+2)>>2;
    dp[8] = (UINT32)(s1+(s2=sp[9])+s3+(s4=sp2[9])+2)>>2;
    dp[9] = (UINT32)(s2+(s1=sp[10])+s4+(s3=sp2[10])+2)>>2;
    dp[10] = (UINT32)(s1+(s2=sp[11])+s3+(s4=sp2[11])+2)>>2;
    dp[11] = (UINT32)(s2+(s1=sp[12])+s4+(s3=sp2[12])+2)>>2;
    dp[12] = (UINT32)(s1+(s2=sp[13])+s3+(s4=sp2[13])+2)>>2;
    dp[13] = (UINT32)(s2+(s1=sp[14])+s4+(s3=sp2[14])+2)>>2;
    dp[14] = (UINT32)(s1+(s2=sp[15])+s3+(s4=sp2[15])+2)>>2;
    dp[15] = (UINT32)(s2+sp[16]+s4+sp2[16]+2)>>2;
    sp+= lx2;
    sp2+= lx2;
    dp+= lx2;
  }
}

static void rec4c(s,d,lx,lx2,h)
unsigned char *s, *d;
INT32 lx,lx2,h;
{
  unsigned char *dp,*sp,*sp2;
  INT32 j;
  UINT32 s1,s2,s3,s4;

  sp = s;
  sp2 = s+lx;
  dp = d;
  for (j=0; j<h; j++)
  {
    s1=sp[0]; s3=sp2[0];
    dp[0] = (UINT32)(s1+(s2=sp[1])+s3+(s4=sp2[1])+2)>>2;
    dp[1] = (UINT32)(s2+(s1=sp[2])+s4+(s3=sp2[2])+2)>>2;
    dp[2] = (UINT32)(s1+(s2=sp[3])+s3+(s4=sp2[3])+2)>>2;
    dp[3] = (UINT32)(s2+(s1=sp[4])+s4+(s3=sp2[4])+2)>>2;
    dp[4] = (UINT32)(s1+(s2=sp[5])+s3+(s4=sp2[5])+2)>>2;
    dp[5] = (UINT32)(s2+(s1=sp[6])+s4+(s3=sp2[6])+2)>>2;
    dp[6] = (UINT32)(s1+(s2=sp[7])+s3+(s4=sp2[7])+2)>>2;
    dp[7] = (UINT32)(s2+sp[8]+s4+sp2[8]+2)>>2;
    sp+= lx2;
    sp2+= lx2;
    dp+= lx2;
  }
}

static void rec4a(s,d,lx,lx2,h)
unsigned char *s, *d;
INT32 lx,lx2,h;
{
  unsigned char *dp,*sp,*sp2;
  INT32 j;
  UINT32 s1,s2,s3,s4;

  sp = s;
  sp2 = s+lx;
  dp = d;
  for (j=0; j<h; j++)
  {
    s1=sp[0]; s3=sp2[0];
    dp[0] = (dp[0] + ((UINT32)(s1+(s2=sp[1])+s3+(s4=sp2[1])+2)>>2) + 1)>>1;
    dp[1] = (dp[1] + ((UINT32)(s2+(s1=sp[2])+s4+(s3=sp2[2])+2)>>2) + 1)>>1;
    dp[2] = (dp[2] + ((UINT32)(s1+(s2=sp[3])+s3+(s4=sp2[3])+2)>>2) + 1)>>1;
    dp[3] = (dp[3] + ((UINT32)(s2+(s1=sp[4])+s4+(s3=sp2[4])+2)>>2) + 1)>>1;
    dp[4] = (dp[4] + ((UINT32)(s1+(s2=sp[5])+s3+(s4=sp2[5])+2)>>2) + 1)>>1;
    dp[5] = (dp[5] + ((UINT32)(s2+(s1=sp[6])+s4+(s3=sp2[6])+2)>>2) + 1)>>1;
    dp[6] = (dp[6] + ((UINT32)(s1+(s2=sp[7])+s3+(s4=sp2[7])+2)>>2) + 1)>>1;
    dp[7] = (dp[7] + ((UINT32)(s2+(s1=sp[8])+s4+(s3=sp2[8])+2)>>2) + 1)>>1;
    dp[8] = (dp[8] + ((UINT32)(s1+(s2=sp[9])+s3+(s4=sp2[9])+2)>>2) + 1)>>1;
    dp[9] = (dp[9] + ((UINT32)(s2+(s1=sp[10])+s4+(s3=sp2[10])+2)>>2) + 1)>>1;
    dp[10] = (dp[10] + ((UINT32)(s1+(s2=sp[11])+s3+(s4=sp2[11])+2)>>2) + 1)>>1;
    dp[11] = (dp[11] + ((UINT32)(s2+(s1=sp[12])+s4+(s3=sp2[12])+2)>>2) + 1)>>1;
    dp[12] = (dp[12] + ((UINT32)(s1+(s2=sp[13])+s3+(s4=sp2[13])+2)>>2) + 1)>>1;
    dp[13] = (dp[13] + ((UINT32)(s2+(s1=sp[14])+s4+(s3=sp2[14])+2)>>2) + 1)>>1;
    dp[14] = (dp[14] + ((UINT32)(s1+(s2=sp[15])+s3+(s4=sp2[15])+2)>>2) + 1)>>1;
    dp[15] = (dp[15] + ((UINT32)(s2+sp[16]+s4+sp2[16]+2)>>2) + 1)>>1;
    sp+= lx2;
    sp2+= lx2;
    dp+= lx2;
  }
}

static void rec4ac(s,d,lx,lx2,h)
unsigned char *s, *d;
INT32 lx,lx2,h;
{
  unsigned char *dp,*sp,*sp2;
  INT32 j;
  UINT32 s1,s2,s3,s4;

  sp = s;
  sp2 = s+lx;
  dp = d;
  for (j=0; j<h; j++)
  {
    s1=sp[0]; s3=sp2[0];
    dp[0] = (dp[0] + ((UINT32)(s1+(s2=sp[1])+s3+(s4=sp2[1])+2)>>2) + 1)>>1;
    dp[1] = (dp[1] + ((UINT32)(s2+(s1=sp[2])+s4+(s3=sp2[2])+2)>>2) + 1)>>1;
    dp[2] = (dp[2] + ((UINT32)(s1+(s2=sp[3])+s3+(s4=sp2[3])+2)>>2) + 1)>>1;
    dp[3] = (dp[3] + ((UINT32)(s2+(s1=sp[4])+s4+(s3=sp2[4])+2)>>2) + 1)>>1;
    dp[4] = (dp[4] + ((UINT32)(s1+(s2=sp[5])+s3+(s4=sp2[5])+2)>>2) + 1)>>1;
    dp[5] = (dp[5] + ((UINT32)(s2+(s1=sp[6])+s4+(s3=sp2[6])+2)>>2) + 1)>>1;
    dp[6] = (dp[6] + ((UINT32)(s1+(s2=sp[7])+s3+(s4=sp2[7])+2)>>2) + 1)>>1;
    dp[7] = (dp[7] + ((UINT32)(s2+sp[8]+s4+sp2[8]+2)>>2) + 1)>>1;
    sp+= lx2;
    sp2+= lx2;
    dp+= lx2;
  }
}
