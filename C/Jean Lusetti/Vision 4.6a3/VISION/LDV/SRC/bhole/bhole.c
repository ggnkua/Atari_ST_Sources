/*
 *
 *
 *	Version PureC / Gcc
 */

#define PCGEMLIB 1 /* mettre 1 si les utilisateurs de Pure C
					* utilise les librairies GEM Pure C */

/* Fichiers headers */

#include <stdio.h> /* Forget this and sprintf will badly format numbers */
#include <portab.h>
#if PCGEMLIB
#include <aes.h>
#include <vdi.h>
#else
#include <aesbind.h>
#include <vdibind.h>
#endif

#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include "..\..\ldg.h"
#include "..\..\vapi.h"
#include "..\..\ldv.h"
#include "..\..\mt_aes.h"

/* Prototypages */
LDV_INFOS * cdecl GetLDVCapabilities(VAPI *vapi) ;
LDV_STATUS  cdecl PreRun(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out) ;
LDV_STATUS  cdecl Run(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out) ;
LDV_STATUS  cdecl Preview(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out) ;

void OnClose(void) ;

/* Variables globales */
PROC Proc[]  = {
                 "GetLDVCapabilities", "LDV Capabilities", (void *)GetLDVCapabilities,
                 "PreRun", "Run Initiliaze", (void *)PreRun,
                 "Run", "LDV Feature", (void *)Run,
                 "Preview", "Preview", (void *)Preview,
              } ;

char Info[] = "LDV";

LDGLIB Ldg[] = {
				0x0101,	 /* LDV version */
				4,		 /* Number of functions in the lib */
				Proc,	 /* Pointers to LDV functions */
				Info, 	 /* Library Information */
				0x0,   	 /* Lib flags, mandatory */
        OnClose, /* Closing, free VDIHandle */
				};

#define BP_CAPS (LDVF_ATARIFORMAT | LDVF_SUPPORTPREVIEW | LDVF_SUPPORTPROG | LDVF_REALTIMEPARAMS | LDVF_SUPPORTCANCEL | LDVF_NOSELECTION)
#define TC_CAPS (LDVF_SPECFORMAT  | LDVF_SUPPORTPREVIEW | LDVF_SUPPORTPROG | LDVF_REALTIMEPARAMS | LDVF_SUPPORTCANCEL | LDVF_NOSELECTION)

LDV_INFOS LdvInfos = {
                       (short) sizeof(LDV_INFOS), /* Size of this structure */
                       TLDV_MODIFYIMG,            /* LDV Type               */
                       "Jean Lusetti",            /* Authors                */
                       {
                         {  1,  1, BP_CAPS }, /* 1 bit-plane capabilities  */
                         {  2,  2, BP_CAPS }, /* 2 bit-plane capabilities  */
                         {  4,  4, BP_CAPS }, /* 4 bit-plane capabilities  */
                         {  8,  8, BP_CAPS }, /* 8 bit-plane capabilities  */
                         { 16, 16, TC_CAPS }, /* 16 bit-plane capabilities */
                         { 32, 32, TC_CAPS }, /* 32 bit-plane capabilities */
                         { 0, 0, 0UL }        /* End of capabilities list  */
                       },
                     } ;
VAPI *Vapi = NULL ;

#define ITRIGO_ARRAY_NBITS 14
#define ITRIGO_ARRAY_SIZE  (1 << ITRIGO_ARRAY_NBITS)
#define ITRIGO_ANGLE_MAX   (ITRIGO_ARRAY_SIZE-1)

#define QUARTER   (ITRIGO_ARRAY_SIZE/4)
#define ANGLE_ADD (M_PI/2.0/(double)QUARTER) ;

long*         pre_cosin = NULL ;             /* Array of pre-computed cosinus/sinus values */
long*         pre_loffset = NULL ;           /* To hold pre-computation of line offsets */
int           lo_w=0, lo_h=0, lo_nplanes=0 ; /* Current parameters for line offset */
unsigned long VapiLogLevel = LL_DISABLED ;
unsigned long ProcMask = 0L ;
short         UseSym = -1 ;                 /* By default use symmetry to save CPU calculations */
                                            /* On Aranym, this is usually slower, so there is a */
                                            /* Setting in bhole.ini to force no symetry usage   */

/* Macro to access pre-computed cosinus/sinus array */
/* Sinus is right after cosinus value */
#define COS(i)  (pre_cosin[(i)<<1])
#define SIN(i)  (pre_cosin[1 + ( (i)<<1 )])

/* Back Hole computation parameters are not passed to speed up calculations, */
/* They are global to the module */
/* Black Hole symmetry rotation */
typedef struct _RECT
{
  short x ;
  short y ;
  short w ;
  short h ;
}
RECT, *PRECT ;

typedef struct _BH_SPROPERTIES
{
  short estdpc ; /* Estimated duration in % (100 being the one without using symmetry) */
  short nrect ;
  short nsym ;
  RECT  rect[9] ;
}
BH_SPROPERTIES, *PBH_SPROPERTIES ;

extern long  bh_xd, bh_yd, bh_rd2, bh_xs, bh_ys, bh_ref ;
extern long  bh_xc, bh_yc ;
extern short bh_out_w, bh_out_h, bh_in_w, bh_in_h ;
extern short bh_out_x, bh_out_y ;
short bh_pc, bh_nrect ;

/* This is the routine address that will operate on a line basis */
static void (*BHLRoutine)(short use_sym, void* in, void* out) ;

/* Specific 68030 and FPU routines */
/* In BHOLE.S */
extern void BHL32_68030(short use_sym, void* in, void* out) ;
extern void BHL16_68030(short use_sym, void* in, void* out) ;
extern void BHLInd_68030(short use_sym, void* in, void* out) ;
extern void BHL32_F68030(short use_sym, void* in, void* out) ;
extern void BHL16_F68030(short use_sym, void* in, void* out) ;
extern void BHLInd_F68030(short use_sym, void* in, void* out) ;
extern void lcosin_fpu(long i, long* pcs) ;


/* GET/SET pixel macros for True Color 16 and 32bit */
#define SET_TCPIXEL(p,x,y,val) (p[pre_loffset[y]+x]=val)
#define GET_TCPIXEL(p,x,y)     (p[pre_loffset[y]+x])

/* Rotation by 90° macro */
#define R90(x,y)  { long _x=x; x=-y; y=_x; }

/* Macro to initialize calculations for a line */
#define BH_INIT_LINE\
  bh_xd  = bh_out_x-bh_xc ;\
  bh_rd2 = (bh_xd*bh_xd + bh_yd*bh_yd) ;\

/* This is the routine that computes the resulting pixel (bh_xs,bh_ys) in source image */
/* From the pixel (bh_xd, bh_yd) in destination image                                  */
/* (bh_xc,bh_yc) is the center pixel of the back hole                                  */
/* This routine also returns if the resulting pixel is in the source image             */
int rBH_68000(void)
{
  int  not_in_range = 1 ;
  long alpha ;

  bh_rd2 += ( bh_xd << 1 ) + 1 ;
  alpha   = bh_ref / (1+bh_rd2) ;
  alpha  &= ITRIGO_ANGLE_MAX ;
  bh_xs   = bh_xd * COS(alpha) - bh_yd * SIN(alpha) ;
  bh_xs >>= 16 ;
  if ( (bh_xs >= -bh_xc) && (bh_xs < -bh_xc+bh_in_w) )
  {
    bh_ys   = bh_xd * SIN(alpha) + bh_yd * COS(alpha) ;
    bh_ys >>= 16 ;
    if ( (bh_ys >= -bh_yc) && (bh_ys < -bh_yc+bh_in_h) )
      not_in_range = 0 ;
  }

  return not_in_range ;
}

/* For 68000/bit-planes organization: */
/* This routine returns the value of the pixel index in the source image */
/* Assuming (bh_xs,bh_ys) is within the source image */
#pragma warn -par
void BHLInd_68000(short use_sym, void* in, void* out)
{
  unsigned char* in_ptr  = (unsigned char*) in ;
  unsigned char* out_ptr = (unsigned char*) out ;
  short          x ;

  for ( x = bh_out_x; x < bh_out_w; x++, bh_xd++ )
  {
    if ( rBH_68000() == 0 )
      out_ptr[x] = in_ptr[pre_loffset[bh_ys+bh_yc] + bh_xs+bh_xc] ;
    else
      out_ptr[x] = 0 ;
  }
}
#pragma warn +par

/* For 68000/16bit TrueColor organization: */
/* This routine returns the value of the pixel index in the source image */
/* Assuming (bh_xs,bh_ys) is within the source image */
void BHL16_68000(short use_sym, void* in, void* out)
{
  unsigned int* in_ptr  = (unsigned int*) in ;
  unsigned int* out_ptr = (unsigned int*) out ;
  short         x ;

  if (use_sym)
  {
    unsigned long  save_bh_xd, save_bh_yd ;
    short n ;

    for ( x = bh_out_x; x <= bh_out_x+bh_out_w/2; x++, bh_xd++ )
    {
      /* Save bh_xd and bh_yd as they will change */
      save_bh_xd = bh_xd ;
      save_bh_yd = bh_yd ;

      if ( rBH_68000() == 0 ) /* Compute 1st pixel with Black Hole formula */
        SET_TCPIXEL(out_ptr, bh_xd+bh_xc, bh_yd+bh_yc, GET_TCPIXEL(in_ptr, bh_xs+bh_xc, bh_ys+bh_yc)) ;
      else
        SET_TCPIXEL(out_ptr, bh_xd+bh_xc, bh_yd+bh_yc, 0xFFFF) ;

      /* Deduce 2nd, 3rd and 4th pixel */
      for (n=0; n < 3; n++)
	  {
        R90(bh_xd, bh_yd) ;
        R90(bh_xs, bh_ys) ;
        if ( (bh_xd>=-bh_xc) && (bh_xd < -bh_xc+bh_in_w) && (bh_yd >= -bh_yc) && (bh_yd < -bh_yc+bh_in_h))
        {
          if ( (bh_xs>=-bh_xc) && (bh_xs < -bh_xc+bh_in_w) && (bh_ys >= -bh_yc) && (bh_ys < -bh_yc+bh_in_h))
            SET_TCPIXEL(out_ptr, bh_xd+bh_xc, bh_yd+bh_yc, GET_TCPIXEL(in_ptr, bh_xs+bh_xc, bh_ys+bh_yc)) ;
          else
            SET_TCPIXEL(out_ptr, bh_xd+bh_xc, bh_yd+bh_yc, 0xFFFF) ;
        }
    }
    /* Restore bh_xd and bh_yd */
    bh_xd = save_bh_xd ;
    bh_yd = save_bh_yd ;
    }
  }
  else
  {
    for ( x = bh_out_x; x < bh_out_x+bh_out_w; x++, bh_xd++ )
    {
      if ( rBH_68000() == 0 )
        out_ptr[x] = in_ptr[pre_loffset[bh_ys+bh_yc] + bh_xs+bh_xc] ;
      else
        out_ptr[x] = 0xFFFF ;
    }
  }
}

/* For 68000/32bit TrueColor organization: */
/* This routine returns the value of the pixel index in the source image */
/* Assuming (bh_xs,bh_ys) is within the source image */
void BHL32_68000(short use_sym, void* in, void* out)
{
  unsigned long* in_ptr  = (unsigned long*) in ;
  unsigned long* out_ptr = (unsigned long*) out ;
  short          x ;

  if (use_sym)
  {
    unsigned long save_bh_xd, save_bh_yd ;
    short         n ;

    for ( x = bh_out_x; x <= bh_out_x+bh_out_w/2; x++, bh_xd++ )
    {
      /* Save bh_xd and bh_yd as they will change */
      save_bh_xd = bh_xd ;
      save_bh_yd = bh_yd ;

      if ( rBH_68000() == 0 ) /* Compute 1st pixel with Black Hole formula */
        SET_TCPIXEL(out_ptr, bh_xd+bh_xc, bh_yd+bh_yc, GET_TCPIXEL(in_ptr, bh_xs+bh_xc, bh_ys+bh_yc)) ;
      else
        SET_TCPIXEL(out_ptr, bh_xd+bh_xc, bh_yd+bh_yc, 0xFFFFFFFFL) ;

      /* Deduce 2nd, 3rd and 4th pixel */
      for (n=0; n < 3; n++)
	  {
        R90(bh_xd, bh_yd) ;
        R90(bh_xs, bh_ys) ;
        if ( (bh_xd>=-bh_xc) && (bh_xd < -bh_xc+bh_in_w) && (bh_yd >= -bh_yc) && (bh_yd < -bh_yc+bh_in_h))
        {
          if ( (bh_xs>=-bh_xc) && (bh_xs < -bh_xc+bh_in_w) && (bh_ys >= -bh_yc) && (bh_ys < -bh_yc+bh_in_h))
            SET_TCPIXEL(out_ptr, bh_xd+bh_xc, bh_yd+bh_yc, GET_TCPIXEL(in_ptr, bh_xs+bh_xc, bh_ys+bh_yc)) ;
          else
            SET_TCPIXEL(out_ptr, bh_xd+bh_xc, bh_yd+bh_yc, 0xFFFFFFFFL) ;
        }
      }
      /* Restore bh_xd and bh_yd */
      bh_xd = save_bh_xd ;
      bh_yd = save_bh_yd ;
    }
  }
  else
  {
    for ( x = bh_out_x; x < bh_out_x+bh_out_w; x++, bh_xd++ )
    {
      if ( rBH_68000() == 0 )
        out_ptr[x] = in_ptr[pre_loffset[bh_ys+bh_yc] + bh_xs+bh_xc] ;
      else
        out_ptr[x] = 0xFFFFFFFFL ;
    }
  }
}

void lcosin(long i, long* pcs)
{
  double angle = i*ANGLE_ADD ;

  pcs[0] = (long) (65536.0 * cos(angle)) ;
  pcs[1] = (long) (65536.0 * sin(angle)) ;
}

int InitTrigo(int fpu)
{
  void    (*rlcosin)(long i, long* pcs) ;
  long    cs[2] ;
  long    q, i;
  clock_t t0 ;

  /* if ( pre_cosin[0] == 65536L ) return 0 ; Used to detect init done before dynamic allocation design */
  if ( pre_cosin ) return 0 ;
  pre_cosin = (long*) calloc( ITRIGO_ARRAY_SIZE, 2*sizeof(long) ) ;
  if ( pre_cosin == NULL ) return -1 ;

  t0 = clock() ;
  if (fpu) rlcosin = lcosin_fpu ;
  else     rlcosin = lcosin ;
  for ( i = 0; i < QUARTER; i++ )
  {
    rlcosin( i, cs ) ;
    COS(i) = cs[0] ;
    SIN(i) = cs[1] ;

    q = QUARTER ;
    /* Set [PI/2;PI] */
    COS(q+i) = -SIN(i) ;
    SIN(q+i) = COS(i) ;

    q += QUARTER ;
    /* Set [PI;3*PI/2] */
    COS(q+i) = -COS(i) ;
    SIN(q+i) = -SIN(i) ;

    q += QUARTER ;
    /* Set [3*PI/2; 2*PI] */
    COS(q+i) = COS(i) ;
    SIN(q+i) = -SIN(i) ;
  }
  if (Vapi && Vapi->LoDoLog)
    Vapi->LoDoLog(LL_INFO, "IniTrigo%s done in %ldms", fpu ? "(FPU)":"", 1000L * (clock()-t0)/CLK_TCK) ;

  return 0 ;
}

/* Called when LDV is loaded, take this opportunity to get some */
/* Info about system: VAPI version and CPU/FPU availability     */
LDV_INFOS * cdecl GetLDVCapabilities(VAPI *vapi)
{
  Vapi = vapi ;
  VapiLogLevel = LL_DISABLED ;
  if ( Vapi && (Vapi->Header.Version >= 0x0104) && Vapi->LoDoLog && Vapi->LoGetLogLevel )
  {
    VapiLogLevel = Vapi->LoGetLogLevel() ;
    if (Vapi->CoGetProcessors)
      ProcMask = Vapi->CoGetProcessors() ;

    if (ProcMask & CO_HAS_030)
      Vapi->LoDoLog(LL_INFO, "%s", "68030 processor available") ;
  
    if (ProcMask & CO_HAS_FPU)
      Vapi->LoDoLog(LL_INFO, "%s", "Floating Point unit available") ;
  }

  return( &LdvInfos ) ;
}

/* Free allocated RunTime stuff */
void OnClose(void)
{
  if ( pre_cosin ) free( pre_cosin ) ;
  pre_cosin = NULL ;
  if ( pre_loffset ) free( pre_loffset ) ;
  pre_loffset = NULL ;
}

/* Pre-compute line offsets from source to speed-up computations */
int compute_loffset(MFDB* in, long** ppre_lo, int* plo_w, int* plo_h, int* plo_nplanes)
{
  /* Sanity checks */
  if ( (ppre_lo == NULL) || (plo_w == NULL)  || (plo_h == NULL) || (plo_nplanes == NULL) )
    return -2 ;

  if ( *ppre_lo && (*plo_w == in->fd_w) && (*plo_h == in->fd_h) && (*plo_nplanes == in->fd_nplanes) )
  {
    /* Current line offsets are still valid */
    return 0 ;
  }
  else
  {
    /* Need to compute line offsets */
    *plo_w = *plo_h = *plo_nplanes = 0 ;
    if (*ppre_lo) free(*ppre_lo) ;
    *ppre_lo  = (long*) malloc(sizeof(long) * (long)in->fd_h) ;
    if (*ppre_lo)
    {
      long* pt_off ;
      long  add    = (long) ALIGN16( in->fd_w ) ;
      long  offset = 0L ;
      int  y ;

      pt_off = *ppre_lo ;
      for ( y = 0; y < in->fd_h; y++ )
      {
        *pt_off++ = offset ;
        offset   += add ;
      }
      *plo_w       = in->fd_w ;
      *plo_h       = in->fd_h ;
      *plo_nplanes = in->fd_nplanes ;

      return 0 ;
    }
  }

  return -1 ; 
}

#pragma warn -par
/* Just say that output image has same width/length than source */
LDV_STATUS cdecl PreRun(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out)
{
  out->Raster.fd_w = in->Raster.fd_w ;
  out->Raster.fd_h = in->Raster.fd_h ;

  return( ELDV_NOERROR ) ;
}
#pragma warn +par

/* Update progression window 1 time on 16 */
char check_prog(short y, short ymax)
{
  char cancel = 0 ;

  if ( ( y & 0x0F ) == 0 )
  {
    int pc = (short) ( ( 100L * (long)y ) / (long)ymax ) ;

    cancel = Vapi->PrSetProgEx( bh_pc+pc/bh_nrect ) ;
  }

  return cancel ;
}

/* Initialize global variables for calculation */
void init_computation(short xc, short yc, long angle, MFDB* in, RECT* rect)
{
  long maxrd2 ;

  bh_xd  = -xc ;
  bh_yd  = -yc ;
  maxrd2 = bh_xd*bh_xd + bh_yd*bh_yd ;
  if ( (ProcMask & (CO_HAS_030|CO_HAS_FPU)) == (CO_HAS_030|CO_HAS_FPU) )
    maxrd2 = (long) sqrt(maxrd2) ;
  bh_ref    = (angle * maxrd2) ;
  bh_xc     = xc ;
  bh_yc     = yc ;
  bh_in_w   = in->fd_w ;
  bh_in_h   = in->fd_h ;
  bh_out_x  = rect->x ;
  bh_out_y  = rect->y ;
  bh_out_w  = rect->w ;
  bh_out_h  = rect->h ;

  bh_yd     = bh_out_y-bh_yc ;
}

/* 68000 routine for bit-plane images */
LDV_STATUS bpRun(MFDB *in, long angle, short xc, short yc, MFDB *out, RECT* rect, short use_sym)
{
  MFDB          dst_line ;
  LDV_STATUS    status = ELDV_NOERROR ;
  size_t        size_indexes, size_dst_line ;
  short         y ;
  long          wout, sizelout ;
  unsigned char *index_in, *index_out, *out_ptr ;
  char          cancel = 0 ;

  /* We will convert the whole image in indexes   */
  /* Allocate memory to convert then to bitplanes */
  /* A line to destination  tion                  */
  size_indexes  = (long) ALIGN16( in->fd_w ) ;
  size_indexes *= (long) in->fd_h ;
  size_dst_line = (long) ALIGN16( out->fd_w ) ;
  index_in = (unsigned char *) malloc( size_indexes ) ;
  if ( index_in == NULL ) return ELDV_NOTENOUGHMEMORY ;
  index_out = (unsigned char *) malloc(size_dst_line) ;
  if ( index_out == NULL )
  {
    free(index_in) ;
    return ELDV_NOTENOUGHMEMORY ;
  }

  /* Convert all source to indexes */
  Vapi->RaRaster2Ind( in->fd_addr, size_indexes, (long)in->fd_nplanes, index_in ) ;

  memcpy( &dst_line, out, sizeof(MFDB) ) ;
  dst_line.fd_wdwidth = out->fd_w / 16 ;
  if ( out->fd_w % 16 ) dst_line.fd_wdwidth++ ;
  dst_line.fd_h = 1 ;
  wout          = (long) ALIGN16( out->fd_w ) ; 
  out_ptr       = out->fd_addr ;
  sizelout      = Vapi->RaGetImgSize( (long) dst_line.fd_w, (long) dst_line.fd_h, (long) out->fd_nplanes ) ;
  init_computation(xc, yc, angle, in, rect) ;
  for ( y = 0; !cancel && (y < out->fd_h); y++, bh_yd++, out_ptr += sizelout )
  {
    BH_INIT_LINE ;
    BHLRoutine(use_sym, index_in, index_out) ;
    dst_line.fd_addr = out_ptr ;
    Vapi->RaInd2RasterInit( &dst_line, wout ) ;
    Vapi->RaInd2Raster( index_out, wout ) ;
    cancel = check_prog(y, out->fd_h) ;
  }

  free(index_in) ;
  free(index_out) ;
  if ( cancel ) status = ELDV_CANCELLED ;

  return( status ) ;
}

/* 68000 routine for 16bit True Color images */
LDV_STATUS Run16(MFDB *in, long angle, short xc, short yc, MFDB *out, RECT* rect, short use_sym)
{
  LDV_STATUS    status = ELDV_NOERROR ;
  unsigned int  *in_ptr, *out_ptr ;
  unsigned long sizelout = 0 ;
  short         y, hy ;
  char          cancel = 0 ;

  in_ptr   = (unsigned int*) in->fd_addr ;
  out_ptr  = (unsigned int*) out->fd_addr ;
  init_computation(xc, yc, angle, in, rect) ;
  hy       = bh_out_y+bh_out_h/2 ;
  if (!use_sym)
  {
    sizelout = (long) ALIGN16( out->fd_w ) ;
    out_ptr += sizelout*(long)rect->y ;
	hy       = bh_out_y+bh_out_h ;
  }
  for ( y = bh_out_y; !cancel && (y < hy); y++, bh_yd++, out_ptr += sizelout )
  {
    BH_INIT_LINE ;
    BHLRoutine(use_sym, in_ptr, out_ptr) ;
    cancel = check_prog(y, hy-bh_out_y) ;
  }

  if ( cancel ) status = ELDV_CANCELLED ;

  return( status ) ;
}

/* 68000 routine for 32bit True Color images */
LDV_STATUS Run32(MFDB *in, long angle, short xc, short yc, MFDB *out, RECT* rect, short use_sym)
{
  LDV_STATUS    status = ELDV_NOERROR ;
  unsigned long *in_ptr, *out_ptr ;
  unsigned long sizelout = 0 ;
  short         y, hy ;
  char          cancel = 0 ;

  in_ptr   = (unsigned long*) in->fd_addr ;
  out_ptr  = (unsigned long*) out->fd_addr ;
  init_computation(xc, yc, angle, in, rect) ;
  hy       = bh_out_y+bh_out_h/2 ;
  if (!use_sym)
  {
    sizelout = (long) ALIGN16( out->fd_w ) ;
    out_ptr += sizelout*(long)rect->y ;
	hy       = bh_out_y+bh_out_h ;
  }
  for ( y = bh_out_y; !cancel && (y < hy); y++, bh_yd++, out_ptr += sizelout )
  {
    BH_INIT_LINE ;
    BHLRoutine(use_sym, in_ptr, out_ptr) ;
    cancel = check_prog(y, hy-bh_out_y) ;
  }

  if ( cancel ) status = ELDV_CANCELLED ;

  return( status ) ;
}

int MayAddRect(RECT* subRect, BH_SPROPERTIES* sgProps)
{
  int add = (subRect->w && subRect->h) ;

  if (Vapi->LoDoLog)
    Vapi->LoDoLog(LL_DEBUG,"MayAddRect (%d,%d,%d,%d)", subRect->x, subRect->y, subRect->w, subRect->h);
  if ( add )  /* Sub Rectangle not empty */
    memcpy( &sgProps->rect[sgProps->nrect++], subRect, sizeof(RECT) ) ;

  return( add ) ;
}

/* Estimation of the expected gain by using rotation symmetry */
void SymmetrySplit(MFDB* img, short xc, short yc, BH_SPROPERTIES* sgProps)
{
  long  npts_insym, npts_total, npts_to_compute ;
  short sw = 0 ;

  if ( UseSym && ( (img->fd_nplanes == 16) || (img->fd_nplanes == 32) ) )
  {
    /* Bitplane organization would have make things too complicated */
	  /* By the way, who is using bitplanes nowadays ?                */
    sw = xc ;
    if ( img->fd_w-xc < sw ) sw = img->fd_w-xc ;
    if ( yc < sw ) sw = yc ;
    if ( img->fd_h-yc < sw ) sw = img->fd_h-yc ;
    if ( img->fd_h-yc < sw ) sw = img->fd_h-yc ;

	/* Let's build the rectangle arrays to define the image                    */
	/* First rectangle (square actually) is the one to use for symmetry        */
	/* On this one only 25% of pixels will be computed with Black Hole formula */
    sgProps->nrect = 1 ;
    sgProps->nsym  = 0 ;

    sgProps->rect[0].x = xc-sw ;
    sgProps->rect[0].y = yc-sw ;
    sgProps->rect[0].w = 2*sw ;
    sgProps->rect[0].h = 2*sw ;
  }

  npts_total      = (long)img->fd_w*(long)img->fd_h ;
  npts_insym      = 4L*(long)sw*(long)sw ;
  npts_to_compute = npts_total-((3L*npts_insym)/4L) ;
  sgProps->estdpc = (100L*npts_to_compute)/npts_total ;
  if ( sgProps->estdpc > 70 )
  {
    /* Not worth make things complicated for that gain */
    sgProps->nrect     = 1 ;
    sgProps->nsym      = -1 ;
    sgProps->rect[0].x = 0 ;
    sgProps->rect[0].y = 0 ;
    sgProps->rect[0].w = img->fd_w ;
    sgProps->rect[0].h = img->fd_h ;
  }
  else
  {
    /* Let's build the remaining rectangles */
    RECT* sRect = &sgProps->rect[0] ; /* Symmetry Rectangle */
    RECT  subRect ;
    /*
    |----------------------------------------|
    |      R1      | R2 |        R3          |
    |----------------------------------------|
    |              ******                    |
    |      R4      ******        R5          |   
    |              ******                    |
    |              ******                    |
    |----------------------------------------|
    |      R6      | R7 |        R8          |
    |----------------------------------------|
    */

    /* R1 */
    subRect.x = 0 ;        subRect.y = 0 ;
    subRect.w = sRect->x ; subRect.h = sRect->y ;
    if (MayAddRect( &subRect, sgProps ))
      if (Vapi->LoDoLog)
        Vapi->LoDoLog(LL_DEBUG,"Adding R1(%d,%d,%d,%d)", subRect.x, subRect.y, subRect.w, subRect.h);

    /* R2 */
    subRect.x = sRect->x ; subRect.y = 0 ;
    subRect.w = sRect->w ; subRect.h = sRect->y ;
    if (MayAddRect( &subRect, sgProps ))
      if (Vapi->LoDoLog)
        Vapi->LoDoLog(LL_DEBUG,"Adding R2(%d,%d,%d,%d)", subRect.x, subRect.y, subRect.w, subRect.h);

    /* R3 */
    subRect.x = sRect->x+sRect->w ;           subRect.y = 0 ;
    subRect.w = img->fd_w-sRect->x-sRect->w ; subRect.h = sRect->y ;
    if (MayAddRect( &subRect, sgProps ))
      if (Vapi->LoDoLog)
        Vapi->LoDoLog(LL_DEBUG,"Adding R3(%d,%d,%d,%d)", subRect.x, subRect.y, subRect.w, subRect.h);

    /* R4 */
    subRect.x = 0 ;        subRect.y = sRect->y ;
    subRect.w = sRect->x ; subRect.h = sRect->h ;
    if (MayAddRect( &subRect, sgProps ))
      if (Vapi->LoDoLog)
        Vapi->LoDoLog(LL_DEBUG,"Adding R4(%d,%d,%d,%d)", subRect.x, subRect.y, subRect.w, subRect.h);

    /* R5 */
    subRect.x = sRect->x+sRect->w ;           subRect.y = sRect->y ;
    subRect.w = img->fd_w-sRect->x-sRect->w ; subRect.h = sRect->h ;
    if (MayAddRect( &subRect, sgProps ))
      if (Vapi->LoDoLog)
        Vapi->LoDoLog(LL_DEBUG,"Adding R5(%d,%d,%d,%d)", subRect.x, subRect.y, subRect.w, subRect.h);

    /* R6 */
    subRect.x = 0 ;        subRect.y = sRect->y+sRect->h ;
    subRect.w = sRect->x ; subRect.h = img->fd_h-sRect->y-sRect->h ;
    if (MayAddRect( &subRect, sgProps ))
      if (Vapi->LoDoLog)
        Vapi->LoDoLog(LL_DEBUG,"Adding R6(%d,%d,%d,%d)", subRect.x, subRect.y, subRect.w, subRect.h);

    /* R7 */
    subRect.x = sRect->x ; subRect.y = sRect->y+sRect->h ;
    subRect.w = sRect->w ; subRect.h = img->fd_h-sRect->y-sRect->h ;
    if (MayAddRect( &subRect, sgProps ))
      if (Vapi->LoDoLog)
        Vapi->LoDoLog(LL_DEBUG,"Adding R7(%d,%d,%d,%d)", subRect.x, subRect.y, subRect.w, subRect.h);

    /* R8 */
    subRect.x = sRect->x+sRect->w ;           subRect.y = sRect->y+sRect->h ;
    subRect.w = img->fd_w-sRect->x-sRect->w ; subRect.h = img->fd_h-sRect->y-sRect->h ;
    if (MayAddRect( &subRect, sgProps ))
      if (Vapi->LoDoLog)
        Vapi->LoDoLog(LL_DEBUG,"Adding R8(%d,%d,%d,%d)", subRect.x, subRect.y, subRect.w, subRect.h);
  }
}

short GetSymetryUsageFromIni(void)
{
  short use_sym = 1 ; /* Unless INI file say no, assume symetry usage */
  long  found = 0 ;
  char  *path_ldv, *language ;
  char  val_key[64] ;

  path_ldv = Vapi->CoGetLDVPath() ;
  language = Vapi->CoGetCurrentLanguage() ;
  if ( path_ldv && language && Vapi->InGetKeyFromFile )
  {
    char filename[256] ;

    sprintf( filename, "%s\\%s\\BHOLE.INI", path_ldv, language ) ;
    if ( Vapi->LoDoLog ) Vapi->LoDoLog(LL_INFO,"Looking into %s to see symetry usage...", filename) ;
	found = Vapi->InGetKeyFromFile( filename, "Private", "UseSym", val_key ) ;
    if ( !found )
    {
      sprintf( filename, "%s\\BHOLE.INI", path_ldv ) ;
      if ( Vapi->LoDoLog ) Vapi->LoDoLog(LL_INFO,"Looking into non language specific %s to see symetry usage...", filename) ;
      found = Vapi->InGetKeyFromFile( filename, "Private", "UseSym", val_key ) ;
    }
  }
  else if ( Vapi->LoDoLog ) Vapi->LoDoLog(LL_WARNING,"Can't access LDV (%s) or language path (%s)!", path_ldv, language) ;

  if ( found ) use_sym = atoi( val_key ) ;
  if ( Vapi->LoDoLog ) Vapi->LoDoLog(LL_INFO,"Symetry usage: %d (found=%ld)", use_sym, found) ;

  return use_sym ;
}

/* LDV Run routine */
LDV_STATUS cdecl Run(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out)
{
  BH_SPROPERTIES sgProps ;
  LDV_STATUS    (*RunRoutine)(MFDB *in, long angle, short xc, short yc, MFDB *out, RECT* rect, short use_sym) ;
  LDV_STATUS     status = ELDV_NOERROR ;
  long           angle, np=0 ;
  short          xc, yc, n ;

  if ( Vapi->Header.Version < 0x102 ) return ELDV_BADVAPIVERSION ;

  if ( InitTrigo((ProcMask & CO_HAS_FPU) == CO_HAS_FPU) != 0 ) return ELDV_NOTENOUGHMEMORY ;
  if ( compute_loffset(&in->Raster, &pre_loffset, &lo_w, &lo_h, &lo_nplanes) ) return ELDV_NOTENOUGHMEMORY ;
  if ( UseSym == -1 ) UseSym = GetSymetryUsageFromIni() ;

  if ( in->Raster.fd_nplanes <= 8 )       { BHLRoutine = BHLInd_68000 ; RunRoutine = bpRun ; }
  else if ( in->Raster.fd_nplanes == 16 ) { BHLRoutine = BHL16_68000 ;  RunRoutine = Run16 ; }
  else if ( in->Raster.fd_nplanes == 32 ) { BHLRoutine = BHL32_68000 ;  RunRoutine = Run32 ; }
  else                                    return ELDV_IMGFORMATMISMATCH ;

  if (ProcMask & CO_HAS_030)
  {
    if (ProcMask & CO_HAS_FPU)
    {
      /* Note that FPU requires also a 68030 here         */
      /* To avoid having another set of macros in bhole.s */
      /* And convert even 68000 routines to ASM           */
      /* FPU won't speed-up computations; it will just    */
      /* Make the angle proportional to the distance to   */
      /* Black Hole Center instead of its square          */
      Vapi->PrOptimize(0x05) ;
      if ( in->Raster.fd_nplanes <= 8 )       BHLRoutine = BHLInd_F68030 ;
      else if ( in->Raster.fd_nplanes == 16 ) BHLRoutine = BHL16_F68030 ;
      else if ( in->Raster.fd_nplanes == 32 ) BHLRoutine = BHL32_F68030 ;
    }
    else
    {
      /* CPU 030 'only', note that it is about 2 times faster than 68000 */
      /* Routine mostly because of 32x32x-->32 MULS.L instruction  */
      Vapi->PrOptimize(0x01) ;
      if ( in->Raster.fd_nplanes <= 8 )       BHLRoutine = BHLInd_68030 ;
      else if ( in->Raster.fd_nplanes == 16 ) BHLRoutine = BHL16_68030 ;
      else if ( in->Raster.fd_nplanes == 32 ) BHLRoutine = BHL32_68030 ;
    }
  }

  angle = (long) params->Param[0].s ;
  xc    = ((long)params->Param[1].s * (long)in->Raster.fd_w)/100L ;
  yc    = ((long)params->Param[2].s * (long)in->Raster.fd_h)/100L ;

  SymmetrySplit(&in->Raster, xc, yc, &sgProps) ;
  if (Vapi->LoDoLog)
  {
    Vapi->LoDoLog(LL_DEBUG, "100 being the time without using symmetry, using symmetry would be %d", sgProps.estdpc) ;
    Vapi->LoDoLog(LL_DEBUG, "Image source  : (0,0,+%d,+%d); %ld pixels", in->Raster.fd_w, in->Raster.fd_h, (long)in->Raster.fd_w * (long)in->Raster.fd_h) ;
    Vapi->LoDoLog(LL_DEBUG, "Symmetry zone : (%d,%d,+%d,+%d), index:%d", sgProps.rect[0].x, sgProps.rect[0].y, sgProps.rect[0].w, sgProps.rect[0].h, sgProps.nsym) ;
  }

  bh_nrect = sgProps.nrect ;
  for ( n=0; (status != ELDV_CANCELLED) && (n < sgProps.nrect); n++)
  {
    long npix ;

    bh_pc = (100*n)/sgProps.nrect ; /* For progression indicator as we may have multiple loops */
    npix  = (long)sgProps.rect[n].w * (long)sgProps.rect[n].h ;
    np   += npix ;
    if ( VapiLogLevel >= LL_PERF )
    {
      size_t t0, tms ;

      t0 = clock() ;
      status = RunRoutine( &in->Raster, angle, xc, yc, &out->Raster, &sgProps.rect[n], (sgProps.nsym == n) ) ;
      tms = (1000L * (clock() - t0) ) / CLK_TCK ;
      if (tms == 0 ) tms = 1 ;
      if (Vapi->LoDoLog)
        Vapi->LoDoLog(LL_PERF, "Run zone %d: (%d,%d,+%d,+%d), use_sym=%d, %ld pixels, done in %ldms, %ld Kpixels/s",
                      n, sgProps.rect[n].x, sgProps.rect[n].y, sgProps.rect[n].w, sgProps.rect[n].h, (sgProps.nsym == n), (long)sgProps.rect[n].w * (long)sgProps.rect[n].h, tms, npix/tms) ;
    }
    else
      status = RunRoutine( &in->Raster, angle, xc, yc, &out->Raster, &sgProps.rect[n], (sgProps.nsym == n) ) ;
  }
  if (Vapi->LoDoLog)
    Vapi->LoDoLog(LL_DEBUG, "%ld pixels computed or deduced", np) ;

  return( status ) ;
}

LDV_STATUS cdecl Preview(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out)
{
  return( Run( in, params, out ) ) ;
}

int main(void)
{
  ldg_init( Ldg ) ;

  return( 0 ) ;
}
