/****************************************************
*
*  $Id: tv1.c 3274 2021-08-28 13:12:54Z trevor $
*
*  test program for ttf-gdos
*  test low level vdi calls, looking closely at io values
*
****************************************************/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <osbind.h>
#include <aesbind.h>
#include <sysvars.h>

#define TRAP   __asm( "illegal" )
#define BEEP   Cconout( '\a' )
#define STEP   printf( "line %d\n", __LINE__ );

__inline__ static unsigned long vq_vgdos( void )
{
register unsigned long ret __asm__("d0");
   __asm__ volatile(
     "movq #-2,d0; trap	#2"
     : "=d"(ret)		/* output */
     :				/* no input */
     : "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */
     );
   return ret;
}

#define ND_COORDS 0
#define YCOORDS  0
#define YSCALE   1

#define NDC_MAX 32767

#define MEMFREE Malloc(-1)

typedef short  bool;
typedef unsigned short  uint16;
typedef short  int16;
typedef long int32;
typedef unsigned long uint32;

typedef struct {
   int16 *contrl_adr;
   int16 *intin_adr;
   int16 *ptsin_adr;
   int16 *intout_adr;
   int16 *ptsout_adr;
   } Vdi_Params;

static int16 contrl[12];
static int16 intin[128];
static int16 intout[128];
static int16 ptsin[128];
static int16 ptsout[128];
static const Vdi_Params vdi_pb = { contrl, intin, ptsin, intout, ptsout };
static FILE *fout;
static int16 ha[64]; /* handles for devices */


void do_gdos( const Vdi_Params *vdi_param_adr )
{
register int i;
int16 xi0=0;
int16 xp0=0;
int16 xi1=0;
int16 xp1=0;
const int16 code = vdi_param_adr->contrl_adr[0];
const int16 np = vdi_param_adr->contrl_adr[1];
const int16 ni = vdi_param_adr->contrl_adr[3];
const int16 sub = vdi_param_adr->contrl_adr[5];
   for( i=0; i<128; i++ ) {
     xi0 += vdi_param_adr->intin_adr[i];
     xp0 += vdi_param_adr->ptsin_adr[i];
   } /* for */

   vdi_param_adr->contrl_adr[2] = -1; /* nr pts out */
   vdi_param_adr->contrl_adr[4] = -1; /* nr ints out */

    __asm__ volatile
    (" 	movl	%0,    d1
        movq	#0x73, d0
        trap	#2"
     :				/* no outputs */
     : "g"(vdi_param_adr)	/* inputs     */
     : "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */
     );
   if( code != vdi_param_adr->contrl_adr[0] ) {
      fprintf( fout, "\terror at line %d: code is %d, contrl[0] altered from %d to %d\n",
            __LINE__, code, code, vdi_param_adr->contrl_adr[0] );
   } /* if */
   if( np != vdi_param_adr->contrl_adr[1] ) {
      fprintf( fout, "\terror at line %d: code is %d, nptsin (contrl[1]) altered from %d to %d\n",
      __LINE__, code, np, vdi_param_adr->contrl_adr[1] );
   } /* if */
   if( ni != vdi_param_adr->contrl_adr[3] ) {
      fprintf( fout, "\terror at line %d: code is %d, nintin (contrl[3]) altered from %d to %d\n",
      __LINE__, code, ni, vdi_param_adr->contrl_adr[3] );
   } /* if */
   if( sub != vdi_param_adr->contrl_adr[5] ) {
      fprintf( fout, "\terror at line %d: code is %d, sub (contrl[5]) altered from %d to %d\n",
      __LINE__, code, sub, vdi_param_adr->contrl_adr[5] );
   } /* if */
   for( i=0; i<128; i++ ) {
     xi1 += vdi_param_adr->intin_adr[i];
     xp1 += vdi_param_adr->ptsin_adr[i];
   } /* for */
   if( xi0 != xi1 ) {
      fprintf( fout, "\terror at line %d: code is %d, intin[] altered\n", __LINE__, code );
   } /* if */
   if( xp0 != xp1 ) {
      fprintf( fout, "\terror at line %d: code is %d, ptsin[] altered\n", __LINE__, code );
   } /* if */

} /* do_gdos() */


static int16 open_vwkstn( int16 device, int16 c )
{
   contrl[0] = 100;	/* opcode */
   contrl[1] = 0;	/* nr pts in */
   contrl[2] = 0;	/* nr pts out */
   contrl[3] = 11;	/* nr intin */
   contrl[4] = 0;	/* nr int out */
   contrl[5] = 0;	/* gdp or escape sub function */

#if 1
{
int id;
int dummy;
int r;
int h;
   id = appl_init();
   h = graf_handle( &dummy, &dummy, &dummy, &dummy );
   r = appl_exit();
   contrl[6] = h;
}
#else
   contrl[6] = 0;       /* handle */
#endif

   intin[0] = device;
   intin[1] = 1;
   intin[2] = 1;
   intin[3] = 1;
   intin[4] = 1;
   intin[5] = 1;
   intin[6] = 1;
   intin[7] = 1;
   intin[8] = 1;
   intin[9] = 1;
   intin[10] = c;    /* 0 = ndc, 2 = raster coords */

   do_gdos( &vdi_pb);

   if( contrl[6] !=0 ) {
      if(contrl[2] != 6) {
         fprintf( fout, "\terror at line %d: pts out sb 6, %d returned\n", __LINE__, contrl[2]);
      } /* if */
      if( contrl[4] != 45 ) {
         fprintf( fout, "\terror at line %d: ints out sb 45, %d returned\n", __LINE__, contrl[4]);
      } /* if */
#if 0
   }
   else {
        if(contrl[2]!=0) {
           fprintf( fout, "\terror at line %d: pts out sb 0, %d returned\n", __LINE__, contrl[2]);
        } /* if */
        if( contrl[4] != 0 ) {
          fprintf( fout, "\terror at line %d: ints out sb 0, %d returned\n", __LINE__, contrl[4]);
      } /* if */
#endif
   } /* if */

   return contrl[6];
} /* open_vwkstn() */

static void v_clsvwk( int16 handle )
{
   contrl[0] = 101;	/* close v wkstation */
   contrl[1] = 0;	/* nr pts in */
   contrl[3] = 0;	/* nr intin */
   contrl[6] = handle;
   do_gdos( &vdi_pb);
   if(contrl[2] != 0) {
      fprintf( fout, "\terror at line %d: pts out sb 0, %d returned\n", __LINE__, contrl[2]);
   } /* if */
   if(contrl[4] != 0) {
      fprintf( fout, "\terror at line %d: ints out sb 0, %d returned\n", __LINE__, contrl[4]);
   } /* if */
} /* v_clsvwk() */

static int16 open_wkstn( int16 device, int16 c )
{
   contrl[0] = 1;	/* opcode */
   contrl[1] = 0;	/* nr pts in */
   contrl[2] = 0;	/* nr pts out */
   contrl[3] = 11;	/* nr intin */
   contrl[4] = 0;	/* nr int out */
   contrl[5] = 0;	/* gdp or escape sub function */
   contrl[6] = 0;       /* handle */

   intin[0] = device;
   intin[1] = 1;
   intin[2] = 1;
   intin[3] = 1;
   intin[4] = 1;
   intin[5] = 1;
   intin[6] = 1;
   intin[7] = 1;
   intin[8] = 1;
   intin[9] = 1;
   intin[10] = c;    /* 0 = ndc, 2 = raster coords */

   do_gdos( &vdi_pb);

   if( contrl[6] !=0 ) {
      if(contrl[2] != 6) {
         fprintf( fout, "\terror at line %d: pts out sb 6, %d returned\n", __LINE__, contrl[2]);
      } /* if */
      if( contrl[4] != 45 ) {
         fprintf( fout, "\terror at line %d: ints out sb 45, %d returned\n", __LINE__, contrl[4]);
      } /* if */
#if 0
   }
   else {
        if(contrl[2]!=0) {
           fprintf( fout, "\terror at line %d: pts out sb 0, %d returned\n", __LINE__, contrl[2]);
        } /* if */
        if( contrl[4] != 0 ) {
          fprintf( fout, "\terror at line %d: ints out sb 0, %d returned\n", __LINE__, contrl[4]);
      } /* if */
#endif
   } /* if */

   return contrl[6];
} /* openwkstn() */

static void v_clswk( int16 handle )
{
   contrl[0] = 2;	/* close wkstation */
   contrl[1] = 0;	/* nr pts in */
   contrl[3] = 0;	/* nr intin */
   contrl[6] = handle;
   do_gdos( &vdi_pb);
   if(contrl[2] != 0) {
      fprintf( fout, "\terror at line %d: pts out sb 0, %d returned\n", __LINE__, contrl[2]);
   } /* if */
   if(contrl[4] != 0) {
   int i;
      fprintf( fout, "\terror at line %d: ints out sb 0, %d returned\n", __LINE__, contrl[4]);
      for( i=0; i<contrl[4]; i++ ) {
         fprintf( fout, "intout[%d] = %d\n", i, intout[i]);
      } /* for */
   } /* if */
} /* v_clswk() */

static void v_clrwk( int16 handle )
{
   contrl[0] = 3;	/* opcode */
   contrl[1] = 0;	/* nr pts in */
   contrl[3] = 0;	/* nr intin */
   contrl[6] = handle;
   do_gdos( &vdi_pb);
   if(contrl[2] != 0) {
      /*  not specified in later editions of vdi spec
      fprintf( fout, "\terror at line %d: pts out sb 0, %d returned\n", __LINE__, contrl[2]);
      */
   } /* if */
   if(contrl[4] != 0) {
      /*  not specified in later editions of vdi spec
      fprintf( fout, "\terror at line %d: ints out sb 0, %d returned\n", __LINE__, contrl[4]);
      */
   } /* if */
} /* v_clrwk() */

static void v_updwk( int16 handle )
{
   contrl[0] = 4;	/* opcode */
   contrl[1] = 0;	/* nr pts in */
   contrl[3] = 0;	/* nr intin */
   contrl[6] = handle;
   do_gdos( &vdi_pb);
   if(contrl[2] != 0) {
      fprintf( fout, "\terror at line %d (v_updwk): pts out sb 0, %d returned\n", __LINE__, contrl[2]);
   } /* if */
   if(contrl[4] != 0) {
      fprintf( fout, "\terror at line %d (v_updwk): ints out sb 0, %d returned\n", __LINE__, contrl[4]);
      fprintf( fout, "intout[0] = %d\n", intout[0] );
   } /* if */
} /* v_updwk() */

static void v_clip( int16 handle, bool clipflag, int16 x0, int16 y0,
                                                 int16 x1, int16 y1 )
{
   contrl[0] = 129;	/* opcode */
   contrl[1] = 2;	/* nr pts in */
   contrl[3] = 1;	/* nr intin */
   contrl[6] = handle;
   ptsin[0] = x0;
   ptsin[1] = y0;
   ptsin[2] = x1;
   ptsin[3] = y1;
   intin[0] = clipflag;
   do_gdos( &vdi_pb);
   if(contrl[2] != 0) {
      fprintf( fout, "\terror at line %d: pts out sb 0, %d returned\n", __LINE__, contrl[2]);
   } /* if */
   if(contrl[4] != 0) {
      fprintf( fout, "\terror at line %d: ints out sb 0, %d returned\n", __LINE__, contrl[4]);
   } /* if */
} /* v_clip() */

static void v_polyline( int16 handle, int16 n )
{
   contrl[0] = 6;	/* polyline opcode */
   contrl[1] = n;	/* nr pts in */
   contrl[3] = 0;	/* nr intin */
   contrl[6] = handle;

   do_gdos( &vdi_pb );

   if(contrl[2] != 0) {
      fprintf( fout, "\terror at line %d: pts out sb 0, %d returned\n", __LINE__, contrl[2]);
   } /* if */
   if(contrl[4] != 0) {
      fprintf( fout, "\terror at line %d: ints out sb 0, %d returned\n", __LINE__, contrl[4]);
   } /* if */
} /* v_polyline() */

static int16 vst_load_fonts( int16 handle )
{
   contrl[0] = 119;	/* opcode */
   contrl[1] = 0;	/* nr pts in */
   contrl[3] = 1;	/* nr intin */
   contrl[6] = handle;
   intin[0] = 0;
   do_gdos( &vdi_pb);

   if(contrl[2] != 0) {
      /* unspecified
      fprintf( fout, "\terror at line %d: pts out sb 0, %d returned\n", __LINE__, contrl[2]);
      */
   } /* if */
   if(contrl[4] != 1) {
      fprintf( fout, "%d: error loading fonts: ints out sb 1, %d returned\n", __LINE__, contrl[4]);
   } /* if */
   return intout[0];
} /* vst_load_fonts() */

static int16 vst_font( int16 handle, int16 font )
{
   contrl[0] = 21;   	/* set text face */
   contrl[1] = 0;	/* nr pts in */
   contrl[3] = 1;	/* nr intin */
   contrl[6] = handle;
   intin[0] = font;
   do_gdos( &vdi_pb);
   if(contrl[2] != 0) {
      fprintf( fout, "\terror at line %d: pts out sb 0, %d returned\n", __LINE__, contrl[2]);
   } /* if */
   if(intout[0] != font) {
      fprintf( fout, "\terror at line %d: expected font %d, selected %d\n", __LINE__, font, intout[0]);
   } /* if */
   return intout[0];
} /* vst_font() */

static int16 vqt_name( int16 handle, int16 index, char *name )
{
register int i;
   contrl[0] = 130;
   contrl[1] = 0;
   contrl[3] = 1;
   contrl[6] = handle;
   intin[0] = index;
   do_gdos( &vdi_pb);
   if( contrl[2] != 0 ) {
      fprintf( fout, "\terror at line %d: ptsout sb 0, found %d\n",
               __LINE__, contrl[2] );
   } /* if */
   if( contrl[4] != 33 ) {
      fprintf( fout, "\terror at line %d: expected 33 intout values, found %d\n",
               __LINE__, contrl[2] );
   } /* if */
   for( i=0; i<33; i++ ) {
      name[i] = intout[i+1];
   } /* for */
   return intout[0];
} /* vqt_name */

static int16 vst_point( int16 handle, int16 size,
               int16 *chw, int16 *chh, int16 *cellw, int16 *cellh )
{
   contrl[0] = 107;   	/* set char height */
   contrl[1] = 0;
   contrl[3] = 1;
   contrl[6] = handle;
   intin[0] = size;	/*  points */
   do_gdos( &vdi_pb);

   if( contrl[2] != 2 ) {
      fprintf( fout, "\terror at line %d: ptsout sb 2, found %d\n",
               __LINE__, contrl[2] );
   } /* if */
   if( contrl[4] != 1 ) {
      fprintf( fout, "\terror at line %d: expected 1 intout values, found %d\n",
               __LINE__, contrl[2] );
   } /* if */

   *chw = ptsout[0];
   *chh = ptsout[1];
   *cellw = ptsout[2];
   *cellh = ptsout[3];
   return intout[0];
} /* vst_point */

static void v_gtext( int16 handle, int16 x, int16 y, unsigned char *string )
{
register int i;
   contrl[0] = 8;   	/* v_gtext() */
   contrl[1] = 1;
   contrl[3] = strlen(string);
   contrl[6] = handle;
   ptsin[0] = x;
   ptsin[1] = y;
   for( i=0; i<=contrl[3]; i++ ) {
      intin[i] = string[i];
   } /* for */
   do_gdos( &vdi_pb);
   if( contrl[2] != 0 ) {
      fprintf( fout, "\terror at line %d: ptsout sb 0, found %d\n",
               __LINE__, contrl[2] );
   } /* if */
   if( contrl[4] != 0 ) {
      fprintf( fout, "\terror at line %d: expected 0 intout values, found %d\n",
               __LINE__, contrl[2] );
   } /* if */
} /* v_gtext */

static void v_justified( int16 handle, int16 x, int16 y, unsigned char *string, int16 span )
{
register int i;
   contrl[0] = 11;   	/* v_justified() */
   contrl[1] = 2;
   contrl[2] = -1;
   contrl[3] = strlen(string) + 2;
   contrl[4] = -1;
   contrl[5] = 10;	/* sub opcode */
   contrl[6] = handle;
   intin[0] = 1;	/* interword spacing allowed */
   intin[1] = 1;	/* interchar spacing allowed */
   for( i=0; string[i]!=0; i++ ) {
      intin[2+i] = string[i];
   } /* for */
   ptsin[0] = x;
   ptsin[1] = y;
   ptsin[2] = span;
   ptsin[3] = 0;
   do_gdos( &vdi_pb);
   if( contrl[2] != 0 ) {
      fprintf( fout, "\terror at line %d (v_justified): ptsout sb 0, found %d\n",
               __LINE__, contrl[2] );
      for( i=0; i<contrl[2]; i++ ) {
         fprintf( fout, "ptsout[%d] = %d\n", i, ptsout[i] );
      } /* for */
   } /* if */
   if( contrl[4] != 0 ) {
      fprintf( fout, "\terror at line %d (v_justified): expected 0 intout values, found %d\n",
               __LINE__, contrl[4] );
   } /* if */
} /* v_justified() */

static void v_rbox( int16 handle, int16 x0, int16 y0, int16 x1, int16 y1 )
{
   contrl[0] = 11;   	/* opcode */
   contrl[1] = 2;
   contrl[3] = 0;
   contrl[5] = 8;	/* sub opcode */
   contrl[6] = handle;
   ptsin[0] = x0;
   ptsin[1] = y0;
   ptsin[2] = x1;
   ptsin[3] = y1;
   do_gdos( &vdi_pb);
   if( contrl[2] != 0 ) {
      fprintf( fout, "\terror at line %d: ptsout sb 0, found %d\n",
               __LINE__, contrl[2] );
   } /* if */
   if( contrl[4] != 0 ) {
      fprintf( fout, "\terror at line %d: expected 0 intout values, found %d\n",
               __LINE__, contrl[4] );
   } /* if */
} /* v_rbox() */

static void vst_unload_fonts( int16 handle )
{
   contrl[0] = 120;	/* unload fonts */
   contrl[1] = 0;	/* nr pts in */
   contrl[3] = 1;	/* nr pts in */
   contrl[6] = handle;
   intin[0] = 0;
   do_gdos( &vdi_pb);
   if(contrl[2] != 0) {
      fprintf( fout, "\terror at line %d: pts out sb 0, %d returned\n", __LINE__, contrl[2]);
   } /* if */
   if(contrl[4] != 0) {
      fprintf( fout, "\terror at line %d: ints out sb 0, %d returned\n", __LINE__, contrl[4]);
   } /* if */
} /* vst_unload_fonts() */

static void vst_alignment( int16 handle, int16 hor, int16 vert )
{
   contrl[0] = 39;	/* opcode */
   contrl[1] = 0;	/* nr pts in */
   contrl[3] = 2;	/* nr ints in */
   contrl[6] = handle;
   intin[0] = hor;
   intin[1] = vert;
   do_gdos( &vdi_pb);
   if(contrl[2] != 0) {
        /* not specified
      fprintf( fout, "\terror at line %d: pts out sb 0, %d returned\n", __LINE__, contrl[2]);
        */
   } /* if */
   if(contrl[4] != 2) {
      fprintf( fout, "\terror at line %d: ints out sb 2, %d returned\n", __LINE__, contrl[4]);
   } /* if */
   if(intout[0] != hor) {
      fprintf( fout, "\terror at line %d: intout[0] sb %d, %d returned\n", __LINE__, hor, intout[0]);
   } /* if */
   if(intout[1] != vert) {
      fprintf( fout, "\terror at line %d: intout[1] sb %d, %d returned\n", __LINE__, vert, intout[1]);
   } /* if */
} /* vst_alignment() */


static bool is_screen( int16 handle )
{
   contrl[0] = 102;
   contrl[1] = 0;
   contrl[3] = 1;
   contrl[6] = handle;
   intin[0] = 1;	/* get extended info */
   do_gdos( &vdi_pb);
   return intout[0] != 0;
} /* is_screen */

static void wait_mouse( int16 handle )
{
   fprintf( fout, "%d: waiting for mouse click ...", (int)__LINE__ );
   contrl[0] = 124;	/* opcode */
   contrl[1] = 0;	/* nr pts in */
   contrl[3] = 0;	/* nr ints in */
   contrl[6] = handle;
   BEEP; Cconws("\r click mouse ... ");
   do {
      do_gdos( &vdi_pb);
   } while( intout[0]==0 );
   Cconws      ("\r                 ");
   fprintf( fout, "%d: ... arrived!\n", (int)__LINE__ );
} /* wait_mouse() */

static void test_wkstn( int16 handle )
{
int16  y = 0;
int16 charw, charh, cellw, cellh;
int16 new_fonts = vst_load_fonts( handle );
int fi;
   fprintf( fout, "starting tests, handle is %d\n", handle );
   v_clip( handle, 1, 0, 0, NDC_MAX, NDC_MAX );
   vst_alignment( handle, 0, 5);
   fprintf( fout, "%d: testing %d fonts for wkstn\n", (int)__LINE__, new_fonts );
   for( fi=1+new_fonts; fi>1; fi-- ) {
      /** load each font ... **/
      char font_name[33], buf[128];
      int16 font_id, psiz, size_obtained;
      font_name[32] = '\0';
      font_id = vqt_name( handle, fi, font_name );
      if( font_id < 0 ) {
         fprintf( fout, "%d: error in vqt_name(%d): name is \"%s\", font_id is %d\n",
	           (int)__LINE__, fi, font_name, font_id );
         continue;
      }
      else {
         fprintf( fout, "%d: name(%d) is \"%s\", font_id is %d\n",
	            (int)__LINE__, fi, font_name, font_id );
      } /* if */
      vst_font( handle, font_id );  /* select font */
      for( psiz=6; psiz<=36; psiz++ ) {
         /** loop for each size **/
         size_obtained = vst_point( handle, psiz, &charw, &charh, &cellw, &cellh );
	 if( size_obtained == psiz ) {
	    (void)vqt_name( handle, fi, font_name );
	    sprintf( buf, "%s %d points, id = %d Aa(œ)", font_name, size_obtained, font_id );
	    if( y < NDC_MAX-cellh ) {
	       y += cellh;
	    }
	    else {
               v_rbox( handle, 0, 0, NDC_MAX, NDC_MAX );
	       if( is_screen( handle ) )  wait_mouse( handle );
	       v_updwk( handle );
	       v_clrwk( handle );
	       y = cellh;
	    } /* if */
	    v_gtext( handle, 0, y, buf );
	 } /* for */
      } /* for */
   } /* for */
   v_rbox( handle, 0, 0, NDC_MAX, NDC_MAX );
   if( is_screen( handle ) ) wait_mouse( handle );
} /* test_wkstn() */


int main( void )
{
uint32 memfree0, memfree1;
uint32 memrc, memndc, memsq, memfx, memlq;
int16 handle_ndc, handle_rc, handle_meta, handle_lq, handle_fx;
int16   widrc,   heightrc;
int16 nr_fonts4;
int16 dummy;
int16 result;
int i;
time_t tp;
int max_i;


   fout = fopen( "tv1.out", "w" );
   if( setvbuf( fout, NULL, _IOLBF, 128 ) != 0 ) {
      fprintf( stderr, "can't buffer tv1.out correctly\n" );
   } /* if */
   fprintf( fout, __FILE__ " gdos tests, $Revision: 1.3 $\n" );
   tp = time(NULL);
   fprintf( fout, "%d: tested on %s\n", (int)__LINE__, ctime(&tp) );

   fprintf( fout, "%d: TOS version: %0x  gdos version: ", (int)__LINE__,
            ((OSHEADER *)get_sysvar(_sysbase))->os_version );
   switch( vq_vgdos() ) {
   case -2:
      fprintf( fout, "gdos not installed!!\n" );
      fprintf( stderr, "%d: gdos not installed!!\n", (int)__LINE__ );
      exit(-1);
   case 0x0007E88A:
        fprintf( fout, "GDOS 1.1 from Atari Corp\n" );
        break;
   case 0x0007E864:
        fprintf( fout, "AMC-GDOS from Arnd Beissner\n" );
        break;
   case 0x0007E8BA:
        fprintf( fout, "GEMINI-special GDOS from Arnd Beissner\n" );
        break;
   case 0x5F464E54:  /* '_FNT' */
        fprintf( fout, "FONTGDOS\n" );
        break;
   case 0x5F46534D:  /* '_FSM' */
        fprintf( fout, "FSMGDOS\n" );
        break;
   case 0x66564449:  /* 'fVDI' */
        fprintf( fout, "fVDI\n" );
        break;
    default :    {
         uint32 *p = (uint32 *)vq_vgdos();
         if( ((int)p&1) == 0
               && p <= (uint32 *)get_sysvar(phystop)
               && p >= (uint32 *)0x800 /* bot of mem */
               && *p == 0x3e5d0957L )

              fprintf( fout, "ttf-gdos\n" );
         else
              fprintf( fout, "GDOS 1.0 or 1.2, vq_vgdos() is %08lx\n", vq_vgdos() );
      }
   } /* switch */

   memfree0 = MEMFREE;
   fprintf( fout, "%d: free mem at start is %ld\n", (int)__LINE__, memfree0 );

   handle_rc = open_vwkstn( Getrez()+2, 2 );    /* 1 = default screen id, 2 = raster coords */
   fprintf( fout, "%d: handle_rc is %d\n", (int)__LINE__, handle_rc );
   widrc = intout[0];
   heightrc = intout[1];

   v_clrwk( handle_rc );

   memrc = memfree0 - MEMFREE;
   fprintf( fout, "%d: opening rc workstation uses %ld Bytes, WxH is %d x %d\n", (int)__LINE__, memrc, widrc, heightrc );

   handle_ndc = open_vwkstn( Getrez()+2, 0 );    /* 4 =  hi res screen, 0 = nd coords */
   fprintf( fout, "%d: handle_ndc is %d\n", (int)__LINE__, handle_ndc );
   memndc = memfree0 - MEMFREE - memrc;
   if( memndc != memrc ) {
      fprintf( fout, "%d: >>>>>> opening ndc workstation uses %ld bytes, expected %ld\n", (int)__LINE__, memndc, memrc );
   }
   else {
      fprintf( fout, "%d: opening ndc workstation uses %ld Bytes, as expected\n", (int)__LINE__, memndc );
   } /* if */


   ptsin[0] = 0;
   ptsin[1] = 0;
   ptsin[2] = (widrc+1)/2;
   ptsin[3] = (heightrc+1)/2;;
   v_polyline( handle_rc, 2 );

   ptsin[0] = 4;
   ptsin[1] = heightrc;
   ptsin[2] = widrc;
   ptsin[3] = 4;
   v_polyline( handle_rc, 2 );

   ptsin[0] = 0;
   ptsin[1] = heightrc - 4;
   ptsin[2] = widrc -4;
   ptsin[3] = 0;
   v_polyline( handle_rc, 2 );

   ptsin[0] = (widrc + 1)/2;
   ptsin[1] = 0;
   ptsin[2] = 0;
   ptsin[3] = (heightrc + 1)/2;
   ptsin[4] = (widrc + 1)/2;
   ptsin[5] = heightrc;
   ptsin[6] = widrc;

   ptsin[7] = (heightrc + 1)/2;
   v_polyline( handle_rc, 4 );

   ptsin[0] = 16384;
   ptsin[1] = NDC_MAX;
   ptsin[2] = NDC_MAX;
   ptsin[3] = 16384;
   v_polyline( handle_ndc, 2 );

   ptsin[0] = 16384;
   ptsin[1] = 16384;
   ptsin[2] = NDC_MAX;
   ptsin[3] = 0;
   v_polyline( handle_ndc, 2 );

   ptsin[0] = 0;
   ptsin[1] = 0;
   for( i=2; i<126; i++ ) {
      ptsin[i] = ptsin[i-2] + 521;
   } /* for */
   ptsin[126] = NDC_MAX;
   ptsin[127] = NDC_MAX;
   v_polyline( handle_ndc, 64 );

   wait_mouse( handle_rc );


   fprintf( fout, "%d: testing ndc workstation ...\n", (int)__LINE__ );
   v_clrwk( handle_ndc );
   test_wkstn( handle_ndc );

   memfree1 = MEMFREE;
   fprintf( fout, "%d: free mem after loading screen fonts is %ld\n", (int)__LINE__, memfree1 );

   nr_fonts4 = vst_load_fonts(handle_rc);

   /* workstations on same device (hi rez screen) should share fonts */
   if( MEMFREE != memfree1 ) {
      fprintf( fout, "%d: >>>>>> after loading screen fonts again, free mem is %ld, expected %ld\n", (int)__LINE__, MEMFREE, memfree0 );
   }
   else {
      fprintf( fout, "%d: screen fonts shared correctly between wkstations\n", (int)__LINE__);
   } /* if */

   v_clsvwk( handle_ndc );

   if( MEMFREE != memfree1 + memndc ) {
      fprintf( fout, "%d: >>>>>> after closing a screen workstation, free mem is %ld, expected %ld\n", (int)__LINE__, MEMFREE, memfree1 + memndc );
   }
   else {
      fprintf( fout, "%d: closed workstation and removed only one of the shared fonts ok\n", (int)__LINE__ );
   } /* if */

   vst_font( handle_rc, 14);	/* times */
   vst_point( handle_rc, 14, &dummy, &dummy, &dummy, &dummy );
   v_justified( handle_rc, 19, 100,
           "ABCD EFGHI JKLMN OPQRS TUVWXYZ 01234567890 !$%&*()@ abcde fghijk lmnp q rstu vwxyz", 600 );

   vst_unload_fonts( handle_rc );
   if( MEMFREE != memfree0 - memrc ) {
      fprintf( fout, "%d: >>>>>> after unloading screen fonts, free mem is %ld, expected %ld\n", (int)__LINE__, MEMFREE, memfree0 - memrc );
   } /* if */


   /** open too many workstations **/
   {
   int i;
   uint32 memfree1 = MEMFREE;
      fprintf( fout, "assigning all handles, mem free is %ld\n", memfree1 );
      for( i=0; 1; i++ ) {
         if( i>=sizeof(ha)/sizeof(ha[0]) ) {
            fprintf( fout, "%d: too many workstations opened (%d)\n", (int)__LINE__, ha[i] );
            break;
         } /* if */
         ha[i] = open_vwkstn( Getrez()+2, 2 );
         fprintf( fout, "%d: opened wkstn, handle is %d, free mem is now %ld\n", (int)__LINE__, ha[i], MEMFREE );
         if( ha[i] == 0 ) {
            break;
         } /* if */
      } /* for */

      max_i = i-1;
      for( i=0; i<=max_i; i++ ) {
         fprintf( fout, "%d: closing wkstn, handle is %d, memfree is now %ld\n", (int)__LINE__, ha[i], MEMFREE );
         v_clsvwk( ha[i] );
      } /* for */
      if( MEMFREE != memfree1 ) {
         fprintf( fout, ">>>>>cleared all handles, mem free is %ld, expected %ld\n", MEMFREE, memfree1 );
      }
      else {
         fprintf( fout, "cleared all handles, mem free is ok (%ld)\n", MEMFREE );
      } /* if */
   }

#if 0
   /* this is now in tv5.c */
   /*** do a timing test ***/
   {
   clock_t t0 = clock();
   int16 h;
   register int i = 1000;
      printf( "timing test: start time is %ld\n", (long)t0 );
      while( i-- > 0 ) {
         h = open_vwkstn( Getrez()+2, 0 );
         v_clsvwk( h );
      } /* while */
      printf( "time for 1k ops is %ld\n", (long)(clock() - t0) );
      fprintf( fout, "time for 1k ops is %ld\n", (long)(clock() - t0) );
   }
#endif

/******************
*  ensure handle_ndc is now closed,
*  no others opened until end of invalid op tests
******************/

   memfree1 = MEMFREE;
   fprintf( fout, "%d: testing metafile driver\n", (int)__LINE__ );
   handle_meta = open_wkstn( 31, 2 );    /* meta file id, 2 = rc */
   if( handle_meta != 0 ) {
      test_wkstn( handle_meta );
      fprintf( fout, "%d: now updating\n", (int)__LINE__ );
      v_updwk( handle_meta );     /* output page to printer */
      fprintf( fout, "%d: now clearing\n", (int)__LINE__ );
      v_clrwk( handle_meta );	/* eject page */
      fprintf( fout, "%d: now closing\n", (int)__LINE__ );
      v_clswk( handle_meta );
      if( MEMFREE != memfree1 ) {
	 fprintf( fout, "%d: >>>>>> after testing sq wkstn, free mem is %ld, expected %ld\n", (int)__LINE__, MEMFREE, memfree0 );
      }
      else {
	 fprintf( fout, "%d: after testing sq wkstn, free mem is ok\n", (int)__LINE__);
      } /* if */
   }
   else {
      fprintf( fout, "%d: couldn't open metafile driver\n", (int)__LINE__ );
   } /* if */
   
   memfree1 = MEMFREE;
   fprintf( fout, "%d: testing printer 21\n", (int)__LINE__ );
   handle_lq = open_wkstn( 21, 0 );    /* lq printer id, 0 = ndc */
   if( handle_lq != 0 ) {
      test_wkstn( handle_lq );
      fprintf( fout, "%d: now updating\n", (int)__LINE__ );
      v_updwk( handle_lq );
      fprintf( fout, "%d: now clearing\n", (int)__LINE__ );
      v_clrwk( handle_lq );
      vst_unload_fonts( handle_lq );
   
      fprintf( fout, "%d: testing printer 23\n", (int)__LINE__ );
      handle_fx = open_wkstn( 23, 0 );	  /* fx printer id, 0 = ndc */
      if( handle_fx != 0 ) {
         test_wkstn( handle_fx );
         fprintf( fout, "%d: now updating\n", (int)__LINE__ );
         v_updwk( handle_fx );
         fprintf( fout, "%d: now clearing\n", (int)__LINE__ );
         v_clrwk( handle_fx );	/* ejects page */
         fprintf( fout, "%d: now closing\n", (int)__LINE__ );
         v_clswk( handle_fx );	/* implicit update & unload */
      }
      else {
	 fprintf( fout, "%d: couldn't open fx wkstatn\n", (int)__LINE__ );
      } /* if */
      fprintf( fout, "%d: now closing printer 21\n", (int)__LINE__ );
      v_clswk( handle_lq );	   /* implicit update, fonts already unloaded */
   }
   else {
      fprintf( fout, "%d: couldn't open lq wkstatn\n", (int)__LINE__ );
   } /* if */
   if( MEMFREE != memfree1 ) {
      fprintf( fout, "%d: >>>>>> after testing fx & lq wkstn, free mem is %ld, expected %ld\n", (int)__LINE__, MEMFREE, memfree0 );
   }
   else {
      fprintf( fout, "%d: after testing fx & lq wkstn, free mem is ok\n", (int)__LINE__);
   } /* if */

   v_clsvwk( handle_rc );

   if( MEMFREE != memfree0 ) {
      fprintf( fout, "%d: >>>>>> after closing down, free mem is %ld, expected %ld\n", (int)__LINE__, MEMFREE, memfree0 );
   }
   else
   {
      fprintf( fout, "%d: no memory leaks detected\n", (int)__LINE__ );
   } /* if */

   tp = time(NULL);
   fprintf( fout, "%d: end of tests, %s\n", (int)__LINE__, ctime(&tp) );
   fclose( fout );
   return 0;

} /* main */

/********************** end of tv1.c ********************/
