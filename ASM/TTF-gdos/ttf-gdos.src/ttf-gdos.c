/***** (C) 1996-2002, Trevor Blight *****
*
*  $Id: ttf-gdos.c 1.39 2001/03/23 22:09:52 tbb Exp $
*
*
* This file is part of ttf-gdos.
*
* ttf-gdos is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public License
* as published by the Free Software Foundation; either version 2
* of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*
**************************************************************
*
*  this is the ttf-gdos main control program,
*  start up gdos,
*  manage workstations & load drivers,
*  dispatch gdos commands to the driver
*
*  workstation management centres around 2 structures:
*   1. workstn_table, the workstation definition table
*   2. active_wk_tbl, the active workstation table
*  workstn_table is essentially ttf-gdos.inf and defines workstation
*  specific data, like driver, device id number, etc.
*  An entry is made in workstn_table whenever a workstation is opened, and
*  is updated as commands are applied to a workstation.
*  It contains things like pointers to the driver and fonts, etc.
*  The workstation handle is an index into this table.
*
****************************************/

#include <string.h>

#include <osbind.h>
#include <basepage.h>
#include <sysvars.h>

#include "ttf-gdos.h"
#include "ttf-defs.h"


#define ND_COORDS 0        /* normalised coordinates */
#define RC_COORDS 2        /* raster coodinates */

#define YCOORDS   0        /* flag for scaling ptsout[y] */

#define RD_ONLY   0        /* open file for readonly */

static void *end_mem;
static int16 (*rom_entry)(void) IPTR;
ACTIVE_WKS_REC active_wk_tbl[MAX_WKS];

extern void vdi_hook(void);
extern void *old_trap2_vector;

static void init_gdos( struct basep *bparg );
static void scale_to_ndc( const Vdi_Params *const, const ACTIVE_WKS_REC *const, const int16 );
static tTTF_ERROR load_driver( const FILE_NAME, ACTIVE_WKS_REC *const );


/********************************************************
*  entry point
*/
void start( struct basep *bparg )
{
   __asm__ volatile("movl #gdos_stack+8000,sp":: );    /* use gdos_stack */
   init_gdos( bparg );

} /* start() */


/********************************************************
*
*/
static volatile void abort( const char *const err_msg)
{
   Cconws( err_msg );
   Cconws( "\r\nttf-gdos not installed\r\n"
           "Press a key ..." );
   (void)Cnecin();
   (void)Pterm0();
} /* abort() */


/******************
* load all RESIDENT & PERMANENT drivers ...
* set up an entry in active_wk_tbl[] for each loaded driver
******************/
static void
load_init_drivers( void )
{
register const WORKSTN_RECORD *pw = setup_inf.workstn_table;
register ACTIVE_WKS_REC *pd = active_wk_tbl;
int     iw;

   for( iw=setup_inf.nr_wkstns; iw>0 && pd<active_wk_tbl+MAX_WKS; iw-- ) {
      if( pw->load_type != DYNAMIC ) {
         pd->pw = pw;
	 if( pw->load_type == PERMANENT ) {
	    pd->base_pagep = NULL;
	    pd->entry_point = rom_entry;
	 }
	 else {  /* RESIDENT */
	    switch( load_driver( pw->driver_name, pd ) ) {
	    case MEM_ERR:
	       abort( "\rnot enough memory to load driver" ); /* <<< abort unnecessary? */
	    case FILE_ERR:
	       abort( "\rdriver file corrupted" );
	    case READ_ERR:
	       abort( "\runable to load driver" );
	    default:
	       ; /* ok, ==> do nothing */
	    } /* switch */
	 } /* if */
         pd++;
      } /* if */
      pw++;
   } /* for */
} /* load_init_drivers() */


/**********************************
* install FSMC cookie
* must be exec'd in super mode
*/

typedef struct {
   long id;
   void *arg;
} tCOOKIE;

static struct {
   char  id[4];
   int16 values[10];
} gdos_info = {
	"TTFG",
	MAJ_REV*256 + MIN_REV,   /* eg, 0x0201 = version 2.1 */
	-1,	/* gdos quality: -1= default, 0=draft, 1=final */
	0, 0, 0, 0, 0, 0, -1, -1
   };

static void install_cookie( void )
{
register tCOOKIE *p = *(tCOOKIE **)_p_cookies;
int nc = 0;	/* nr cookies installed */
int na = 0;	/* nr cookies available */

   if( p != NULL ) {
      while( p->id != 0L ) {
         nc++;
         p++;
      } /* while */
      na = (int)(p->arg);
      assert( nc+1 <= na );
   } /* if */

   if( na < nc+2 ) { /* space available < space required? */
   tCOOKIE *p0 = *(tCOOKIE **)_p_cookies;
   register tCOOKIE *const a = (tCOOKIE *)(((uint32)end_mem + 3) & ~3L);
      na += 8;
      *_p_cookies = p = a; /* new cookie area */
      end_mem = a + na;
      while( --nc >= 0 ) *p++ = *p0++;
   } /* if */

   /** p points to the first empty cookie,
   **  and there is at least one more free following **/
   p->id = 0x46534D43;  /* 'FSMC' */
   p->arg = &gdos_info;
   p++;
   p->id = 0L;
   p->arg = na;

} /* install_cookie() */


/*******************************************************
*  read & check inf file
*  load any resident drivers
*  set up vectors, etc
*  terminate & stay resident
*/
static void init_gdos( struct basep *bparg )
{
int16 nr_bytes;
FILE_H fh;
char *title;

   Cconws( sign_on_msg );

   if( (fh = Fopen( INF_FILE, RD_ONLY )) < 0 ) {
      abort( "Couldn't open " INF_FILE );
   } /* if */

   assert( !((uint32)&setup_inf&1) ); /* end must be even address */

   nr_bytes = Fread( fh, INF_FILE_MAX_LEN, &setup_inf );
   (void)Fclose( fh );     /* assume successful */
   if(nr_bytes < 0) {
      abort( "Couldn't read " INF_FILE );
   } /* if */

   if( setup_inf.magic_nr != MAGIC_NR ) {
bad_file:
      abort( INF_FILE " has incorrect format" );
   } /* if */


   if( setup_inf.version < MY_VERSION ) abort( INF_FILE " has old format");
   if( setup_inf.version > MY_VERSION ) abort( "please upgrade to latest version of ttf-gdos" );
   if( nr_bytes != setup_inf.file_len ) goto bad_file;

   TTFont_Tablep = (FONT_RECORD *)(setup_inf.workstn_table + setup_inf.nr_wkstns);
   GemFont_Tablep = (FILE_NAME *)(TTFont_Tablep+setup_inf.nr_ttfonts);
   gem_path = (char *)(GemFont_Tablep + setup_inf.nr_gemfonts);
   title = gem_path + setup_inf.len_gem_path;
   Cconws( title );	/* display the title */
   end_mem = title + sizeof( FILE_NAME ) + 2;

   (void)Supexec( install_cookie );   /** set up FSMC cookie, may alter end_mem **/

   (void)Mshrink( bparg, (uint32)end_mem-(uint32)bparg);    /* assume successful */

   __asm__ volatile
	 ( "moveq   #-1,d0
	    trap    #2
	    movl    d0,%0"
	    : "=g"(rom_entry) : );

   load_init_drivers();
   ttf_startup(setup_inf.nr_ttfonts);

   old_trap2_vector = Setexc( 0x22, vdi_hook );

   Cconws( "\r\nttf-gdos installed\r\n");
   error_code = 0;

   Ptermres( (uint32)end_mem - (uint32)(bparg), 0 );

} /* init_gdos() */


/*****************************************************************
* this is the main vdi entry point
*   hook into the existing vdi trap handler
*   use XBRA
*   vq_vgdos() returns pointer to setup info
*   intercept some calls for local processing, before sending to driver
*   	(like workstation/font handling, etc)
*   route others to driver
*   use binary chop so call can be identified with less than about 5 compares
*/

__asm__("
	.data
.comm	gdos_stack,8000

	.text
	.even
entry_count:
	.short -1
	.globl	_vdi_hook, _old_trap2_vector
	.globl	_v_opnwk, _v_opnvwk, _v_clswk
	.globl	_vst_load_fonts, _vst_unload_fonts, _call_driver, _find_wkstnp
	.globl	_v_bez_qual, _v_bez, _v_bez_fill, _v_bez_control
	.globl	_v_gtext, _vst_font, _vq_devinfo
	.ascii	\"XBRA\"
	.ascii	\"TTFG\" | id for ttf-gdos
_old_trap2_vector:
		.long	0

_vdi_hook:
	cmpw	#115,d0 | is this a vdi call?
	beq	do_vdi
	cmpw	#-1,d0
	bne	not_adr
	movl	_rom_entry,d0
	rte
not_adr:
	cmpw	#-2,d0		| vq_vgdos call
	bne	go_old
	movl	#_end+12,d0	| &setup_inf.magic_nr
	rte
go_old:
	movel	_old_trap2_vector,sp@-
	rts

do_vdi:
	link	a6,#0
	addqw	#1,entry_count
	bne	stk_set
	movel	#gdos_stack+8000,a7
stk_set:
	movel	d1,sp@-		| arg = vdi_param_adr
	|bsr	_login		| <<< uncomment for LOGGING
	|movel	sp@,d1  	| <<< uncomment for LOGGING
	pea	done		| return address
	movel	d1,a0
	movel	a0@,a1		| &contrl[0]
	movew	a1@,d0		| opcode
	movew	a1@(10),d1	| sub opcode

	| intercept some gdos calls ...

cmp11:
	cmpw	#11,d0	| GDP
	jgt	cmp101
	jlt	cmp6
	cmpw	#10,d1	| v_justified
	jne	not10
do_text:
	jra	_v_gtext
not10:
	cmpw	#13,d1
	jne	others
	jra	_v_bez_control

cmp6:
	cmpw	#6,d0
	jlt	cmp5
	jgt	cmp8
	cmpw	#13,d1
	jne	others
	jra	_v_bez

cmp5:
	cmpw	#5,d0
	jne	cmp2
	cmpw	#99,d1
	jne	others
	movel	a0@(4),a0	| &intin[0]
	cmpw	#32,a0@		| sub op code == v_bez_qual ??
	jne	others
	jra	_v_bez_qual

cmp2:
	cmpw	#2,d0
	jne	cmp1
close:
	jra	_v_clswk

cmp1:
	cmpw	#1,d0
	jne	others
	jra	_v_opnwk

cmp8:
	cmpw	#8,d0
	jeq	do_text
	cmpw	#9,d0
	jne	others
	cmpw	#13,d1
	jne	others
	jra	_v_bez_fill

cmp101:
	cmpw	#101,d0
	jgt	cmp120
	jeq	close
	cmpw	#100,d0
	jne	cmp21
	jra	_v_opnvwk

cmp21:
	cmpw	#21,d0
	jne	others
	jra	_vst_font

cmp120:
	cmpw	#120,d0
	jne	cmp119
	jra	_vst_unload_fonts

cmp119:
	cmpw	#119,d0
	jne	cmp248
	jra	_vst_load_fonts

cmp248:
	cmpw	#248,d0
	jne	others
	jra	_vq_devinfo


| rtn adr on top of stack, this is destroyed as we drop thru to rtn address
| adr vdi parm block is next on stack
| a1 = adr control[]
others:
	movew	a1@(12),sp@	| arg is cntrl[6], handle (overwrites rtn adr)
	jbsr	_find_wkstnp
	addqw	#4,sp		| adr param block is now top of stack
	tstl	d0		| valid handle ?
	jeq	done
	movel	sp@,a0		| get adr param block
	movel	d0,sp@-		| arg1 is wkstn pointer
	movel	a0,sp@-		| arg0 is adr vdi param block
	jbsr	_call_driver
	|addqw	#8,sp		| drop thru,  uncomment for LOGGING

done:
	|bsr _logout	| <<< uncomment for LOGGING
	subqw	#1,entry_count
	unlk	a6		| restore old stack
	rte
	" );


/*******************************
* open a font or driver file in the gemsys path
* return GEMDOS file handle, this is <0 for error
*/
FILE_H open_sys_file( const FILE_NAME fn )
{
register const char *s = fn;
register char *t = gem_path + setup_inf.len_gem_path;	/* file name pos */
   while( *t++ = *s++ );                  /* concat file name to gempath */
   return Fopen( gem_path, RD_ONLY );
} /* open_sys_file() */


/*******************************
* get size of a file
* return error code == -33 if file not found
* return error code < 0 if error
*/
__inline__ static int32
get_file_siz( const char *fn )
{
struct _dta *const sav_dta = (struct _dta *)Fgetdta();
register int32 r;
struct _dta *const pdta = (struct _dta *)((struct basep*)start)[-1].p_cmdlin;
   Fsetdta( pdta );
   r = Fsfirst( fn, 0 );
   Fsetdta( sav_dta );
   /* r == 0 if file found <<< */
   return r!=0 ? r : pdta->dta_size;
} /* get_file_siz() */


/*******************************
* get size of a font or driver file in the gemsys path
* return code as for get_file_siz
*/
int32 get_sysfile_siz( const FILE_NAME fn )
{
register const char *s = fn;
register char *t = gem_path + setup_inf.len_gem_path; 	/* file name pos */
   while( *t++ = *s++ );                  /* concat file name to gempath */
   return get_file_siz( gem_path );
} /* get_sysfile_siz() */


/******************
*  malloc for fonts, drivers, etc to reduce memory fragmentation
*  check for under/over run unless NDEBUG
**/

#ifndef NDEBUG

int errno;

/* debug version ... */
#define MAGIC_HI 0x369CF258
#define MAGIC_LO 0xBE147AD0

void dfree(const void *p, char *fn, int line)
{
const uint32 *const q = p;
   assert( ((int)q&1) == 0 );
   assert( q != NULL );
   if( q[-1] != MAGIC_LO ) {
      sprintf( assert_buf, "bad MAGIC_LO, free() called from %s %d\n\r", fn, line );
      Cconws(assert_buf); \
   } /* if */
   assert( q[ q[-2] ] == MAGIC_HI );
   assert( Mfree((uint32)p-8) == 0 );
}

void *dmalloc(uint32 a)
{
register uint32 *p;
   a = (a+3) & ~3L;
   p = (uint32*)Malloc(a+12);
   assert( ((int)p&1) == 0 );
   if( p != NULL ) {
      a >>= 2;
      *p++ = a;
      *p++ = MAGIC_LO;
      p[a] = MAGIC_HI;
   } /* if */
   return p;
}
#endif

/* this reduces memory fragmenting, but doesn't work for timeworks */
#if 0
void *hi_malloc( const int32 m )
{
void *p IPTR, *q IPTR;
const int32 f = MemAvail() -m -32;
   if( f<=0 )  return NULL;	/* not enough memory */
   q = (void*)Malloc( f );	/* take low memory */
   p = (void*)malloc(m);	/* allocate at hi memory */
   (void)Mfree(q);		/* free low memory */
   if( p==NULL ) p = (void*)malloc(m);	/* timeworks! */
   assert( p!=NULL );
   return p;
} /* hi_malloc() */
#endif

/***********************************
*
*/
__inline__ static int16
open_driver( const Vdi_Params *const vdi_param_adr,
	     register ACTIVE_WKS_REC *const pd )
{
int16 yscale;
register Vdi_Params *vdi_in __asm__("d1");
   __asm__ volatile ("movl %1,%0": "=d"(vdi_in): "g"(vdi_param_adr) );
   yscale = (*pd->entry_point)();
   pd->drv_handle = vdi_param_adr->contrl_adr->handle;
   return yscale;
} /* open_driver() */


/********************************************************
*
*  call driver associated with device record at pd
*  convert to & from raster coords if neccessary
*  rc = ((ndc+1)*z2 - 1)/64k = ~((~ndc)*z2)/64k
*/

/** do fast scaling arithmetic ... **/
static __inline__
int16 scale_siz( int16 ndc, int16 z2)
{
register int16 r __asm__ ("d0");;
   __asm__ volatile
   ("	muls	%2,%0  | ndc * 2size
        notl	%0
        swap	%0     | /64k"
    :	"=d"(r) /* output */
    :	"0"(~ndc), "dmi"(z2) /* inputs    */ );
    return r;
} /* scale_siz() */

void call_driver( const Vdi_Params *vdi_param_adr,
	     register const ACTIVE_WKS_REC *const pd )
{
register int16 *contrl6_ptr = &vdi_param_adr->contrl_adr->handle;
int16 sav_handle = *contrl6_ptr;

   *contrl6_ptr = pd->drv_handle;

   if( pd->rc_flag == ND_COORDS ) {

   /*** nd coords, so create a new ptsin array with raster coords ***/

   register const int16 *p_ndc = vdi_param_adr->ptsin_adr;
   register uint16  n = vdi_param_adr->contrl_adr->nptsin;
   register const int16  h1 = pd->dev_height-1;
   register const int16  h2 = 2*pd->dev_height;
   register const int16  w2 = 2*pd->dev_width;
   register int16 *p_rc;
   Vdi_Params new_vdi_par = *vdi_param_adr;
   int16	   yscale;

      new_vdi_par.ptsin_adr = p_rc = malloc(4*n);  /* a new ptsin array, 2*n ints */
      if( p_rc != NULL ) {
         for( ; n>0; n-- ) {
	   assert( *p_ndc<0 || scale_siz(*p_ndc, w2) == (((int32)(*p_ndc)+1)*pd->dev_width-1)/32768L );
	   assert( abs(scale_siz(*p_ndc, w2) - (((int32)(*p_ndc)+1)*pd->dev_width-1)/32768L) <= 1 );
           *p_rc++ = scale_siz( *p_ndc++, w2 );    /* the x coord */
	   assert( *p_ndc<0 || scale_siz(*p_ndc, h2) == (((int32)(*p_ndc)+1)*pd->dev_height-1)/32768L );
	   assert( abs(scale_siz(*p_ndc, h2) - (((int32)(*p_ndc)+1)*pd->dev_height-1)/32768L) <= 1 );
	   *p_rc++ = h1-scale_siz( *p_ndc++, h2); /* the y coord */
         } /* for */

         {
         register Vdi_Params *vdi_in __asm__("d1");;
	   __asm__ volatile ("movl %1,%0": "=d"(vdi_in): "g"(&new_vdi_par) );
	   yscale = (*pd->entry_point)(); /* call_driver() */
         }
         scale_to_ndc( &new_vdi_par, pd, yscale );
         free( new_vdi_par.ptsin_adr );
      } /* if */
   }
   else {
	 register Vdi_Params *vdi_in __asm__("d1");;
	  __asm__ volatile ("movl %1,%0": "=d"(vdi_in): "g"(vdi_param_adr) );
	 (void)(*pd->entry_point)();      /* call_driver() */
   } /* if */

   *contrl6_ptr = sav_handle;

} /* call_driver() */


/********************************************************
* transform from raster to normalised device coordinates
* the ndc value is the one that contains the lower left corner of the
* pixel:
*  ndc = (rc*64k)/(2*w)
* yscale == YCCORDS means that the y values are coordinates
* and so the origin must be transformed from top left to bottom right
* If the y values are scalar (eg line width) then they are simply scaled
*/

/** do fast scaling arithmetic ... **/
static __inline__
int16 scale_32k( int16 rc, int16 z2)
{
register int16 n __asm__ ("d0");;
   __asm__ volatile
   ("	swap	%0     | (raster coord) * 64k
	divs	%2,%0  | / 2size"
    :	"=d"(n) /* outputs */
    :	"0"((uint32)rc), "dmi"(z2) /* inputs */ );
    return n;
} /* scale_32k() */

static void scale_to_ndc( const Vdi_Params *const vdi_param_adr,
	                  const ACTIVE_WKS_REC *const pd,
                          const int16 yscale )
{
register const int16  h1 = pd->dev_height-1;
register const int16  h2 = 2*pd->dev_height;
register const int16  w2 = 2*pd->dev_width;
register int16 *p = vdi_param_adr->ptsout_adr;
register int16  n = vdi_param_adr->contrl_adr->nptsout;
register int16  t;

   for( ; n>0; n-- ) {
      assert( abs(*p)>=pd->dev_width || (int32)(*p)*32768L/pd->dev_width == scale_32k(*p, w2) );
      *p++ = scale_32k(*p, w2);         /* the x coordinate */
      t = *p;
      if( yscale == YCOORDS ) t = h1-t;
#if 0
      if( (int32)t*32768L/pd->dev_height != scale_32k(t, h2) ) {
         sprintf( assert_buf, "t is %d, h is %d, scale is %d, func code is %d, vertex nr %d\r\n",
	                      (int)t, (int)pd->dev_height, (int)scale_32k(t, h2),
                         vdi_param_adr->contrl_adr->opcode, vdi_param_adr->contrl_adr->nptsout-n);
	 Cconws( assert_buf );
	 TRAP;
      }
#endif
      assert( abs(*p)>=pd->dev_height || (int32)t*32768L/pd->dev_height == scale_32k(t, h2) );
      *p++ = scale_32k(t, h2);            /* the y coordinate */
   } /* for */
} /* scale_to_ndc() */


/****************************************
*  open a vdi workstation
*  find device definition,
*  load & call driver as appropriate,
*  set up an entry in active workstn table
*/

/** convert dot size in microns to dots per inch **/
static uint16 get_dpi( register const uint16 s )
{
register uint16 dpi;
   if( s==71 ) dpi = 360;
   else if( s==85 ) dpi = 300;
   else if( s==0 ) dpi = 0;
   else dpi = (25400+s/2)/s;
   return dpi;
} /* get_dpi() */


void v_opnwk( register const Vdi_Params *vdi_param_adr )
{
register const WORKSTN_RECORD *pw = setup_inf.workstn_table;
register const int wid = vdi_param_adr->intin_adr[0];	/* wkstn id */
register int             n, r;        /* wkstn counter, ret value */
register ACTIVE_WKS_REC *pd IPTR;
register int             handle;    /* workstation handle */
int16                    yscale;

   /** look for workstation id in load table ... **/

   assert(vdi_param_adr->contrl_adr->opcode == OP_OPNWK);
   n = setup_inf.nr_wkstns;
   assert( n > 0 );
   while( pw->id != wid ) {
      pw++; n--;
      if( n<=0 ) {	/* error: this id not found */
	 goto error;	   /* <<< set intout length ?? */
      } /* if */
   } /* while */


   if( pw->load_type != DYNAMIC ) {
      /** find entry in load table **/
      pd = active_wk_tbl;
      handle = 1;
      while( pd->pw != pw ) {
	 pd++;
	 assert( handle <= MAX_WKS );
	 handle++;
      } /* while */
   }
   else {
      /** DYNAMIC driver, create a handle for the workstation ... */
      pd = active_wk_tbl;
      n = MAX_WKS;
      while( !ISEMPTY(pd) ) {
   	 pd++; n--;
	 if( n <= 0 ) {      /* error: empty space not found */
	    goto error;
	 } /* if */
      } /* while */

      handle = MAX_WKS + 1 - n;

      r = load_driver( pw->driver_name, pd );
      if( r != OK ) {	/* error: couldn't load driver */
	 vdi_param_adr->intout_adr[0] = r;       /* <<< */
	 vdi_param_adr->contrl_adr->nintout = 1;
	 goto error;
      } /* if */
      pd->pw = pw;
   } /* if */

   pd->rc_flag = (vdi_param_adr->intin_adr)[10];
   assert( pd->wks_fonts.font_chain == NULL );
   pd->wks_fonts.font_chain = NULL; /* not needed, but best to be safe */

   yscale = open_driver( vdi_param_adr, pd );

   if( (vdi_param_adr->contrl_adr->nptsout == 0)
    && (vdi_param_adr->contrl_adr->nintout == 0) ) {
      /* driver returned failure */
      if( pd->pw->load_type == DYNAMIC ) {
	 (void)free( pd->base_pagep );   /* assume successful */
	 pd->pw = NULL;      /* free slot */
      } /* if */
     goto error;
   } /* if */

   /** opened successfully, so set up info **/
   pd->root_handle = handle;
   pd->dev_width  = (vdi_param_adr->intout_adr)[0]+1;
   pd->dev_height = (vdi_param_adr->intout_adr)[1]+1;
   pd->dpix = get_dpi( vdi_param_adr->intout_adr[3] );
   pd->dpiy = get_dpi( vdi_param_adr->intout_adr[4] );
   pd->bez_qual = 7; /* default */

   if( pd->rc_flag == ND_COORDS ) {
      scale_to_ndc( vdi_param_adr, pd, yscale );
   } /* if */

   vdi_param_adr->contrl_adr->handle = handle;
   assert( pd == find_wkstnp( handle ) );
   assert( wid>=10 || pd==find_wkstnp(0) );
   return;

error:
   vdi_param_adr->contrl_adr->handle = 0;

} /* v_opnwk() */



/*****************************************************************
*
*  open a virtual screen device
*/
void v_opnvwk(register const Vdi_Params *const vdi_param_adr)
{
register const WORKSTN_RECORD *pw = setup_inf.workstn_table;
register       int             n;
register       ACTIVE_WKS_REC *pd IPTR;
register       int             handle;    /* workstation handle */
               int16 yscale;
const ACTIVE_WKS_REC *const root_pd = find_wkstnp( vdi_param_adr->contrl_adr->handle );

   assert(vdi_param_adr->contrl_adr->opcode == OP_OPNVWK);

   if( root_pd == NULL ) {
      goto error;
   } /* if */

   /** look for workstation in workstation table ... **/
   n = setup_inf.nr_wkstns;
   assert( n > 0 );
   while( pw->id != vdi_param_adr->intin_adr[0] ) {
      pw++; n--;
      if( n<=0 ) {	/* error this id not found */
	 goto error;
      } /* if */
   } /* while */


   /** create a handle for the workstation ... */
   pd = active_wk_tbl;
   n = MAX_WKS;
   assert( n>0 );
   while( !ISEMPTY(pd) ) {
      pd++; n--;
      if( n<=0 ) {	/* error: empty space not found */
	 goto error;
      } /* if */
   } /* while */
   handle = MAX_WKS + 1 - n;

   *pd = *root_pd;	/* copy root's wkstn data */
   pd->pw = pw;	        /* point to correct workstation */
   assert( &active_wk_tbl[pd->root_handle-1] == root_pd );
   pd->rc_flag = (vdi_param_adr->intin_adr)[10];
   pd->wks_fonts.font_chain = NULL;
   yscale = open_driver( vdi_param_adr, pd );
   if( pd->drv_handle == 0 ) {
      pd->pw = NULL;	   /* free slot */
      pd->root_handle = 0; /* workstn now closed */
      goto error;
   } /* if */

   if( pd->rc_flag == ND_COORDS ) {
      scale_to_ndc( vdi_param_adr, pd, yscale );
   } /* if */

   vdi_param_adr->contrl_adr->handle = handle;
   assert( pd == find_wkstnp( handle ) );
   return;

error:
   vdi_param_adr->contrl_adr->handle = 0;

} /* v_opnvwk() */


/*****************************************************************
*
*  close a workstation
*/
void v_clswk( const Vdi_Params *vdi_param_adr )
{
register ACTIVE_WKS_REC *const pd = find_wkstnp( vdi_param_adr->contrl_adr->handle );

   assert(vdi_param_adr->contrl_adr->opcode == OP_CLSWK
       || vdi_param_adr->contrl_adr->opcode == OP_CLSVWK);

   if( pd != NULL ) {
   int16 sav_op = vdi_param_adr->contrl_adr->opcode;

      call_driver( vdi_param_adr, pd);	/* this can corrupt opcode !! */
      free_wks_fonts(pd);

      if( sav_op == OP_CLSWK ) {
         assert( &active_wk_tbl[pd->root_handle-1] == pd );
         if( pd->pw->load_type == DYNAMIC ) {
            (void)free( pd->base_pagep );   /* assume successful */
            pd->pw = NULL;	/* free slot */
	 } /* if */
      }
      else {      /* OP_CLSVWK */
         assert( &active_wk_tbl[pd->root_handle-1] != pd );
         assert( active_wk_tbl[pd->root_handle-1].root_handle == pd->root_handle );
         pd->pw = NULL;	/* free slot */
      } /* if */
      pd->root_handle = 0;	/* workstn now closed */
      assert( find_wkstnp( vdi_param_adr->contrl_adr->handle ) == NULL );
   } /* if */

} /* v_clswk() */


/**********************************
* vq_devinfo
* find driver info for device
*/
void vq_devinfo( const Vdi_Params *const vdi_param_adr )
{
register const int wid = vdi_param_adr->intin_adr[0];
register int  n;
register ACTIVE_WKS_REC *pd = active_wk_tbl;
BOOL open_flag = FALSE;
register const char *s;	/* temp char pointer */
register int16 *p; /* temp int pointer */
int16 nr_ptsout = 1;
int16 nr_intout = 0;

   assert(vdi_param_adr->contrl_adr->opcode == OP_DEVINFO);

   /*** see if the device is active **/
   n = MAX_WKS;
   assert( n>0 );
   while( ISEMPTY(pd) || pd->pw->id != wid ) {
      pd++; n--;
      if( n<=0 ) {	/* wid not found */
         goto done;
      } /* if */
   } /* while */

   /** copy the driver filename to intout[] **/
   assert( pd->pw->id == wid );
   open_flag = ISOPEN(pd);
   s=pd->pw->driver_name;
   p=vdi_param_adr->intout_adr; 
   while( nr_intout<sizeof(pd->pw->driver_name) /*max file len*/ 
      && (*p++ = *s++) != 0 ) nr_intout++;

   /** copy device name to pts out **/
   /** scan back from end of data area looking for '_FSM_HDR' **/

   if( pd->base_pagep != NULL ) {
      p = (int16*)((uint32)pd->base_pagep->p_bbase - 76);	/* end of data - strlen - offset */
      assert( ((int16)p&1) == 0 );	/* work on word boundaries */
      n = pd->base_pagep->p_dlen;

      do {
   	   if(   p[0]==0x5f46	/* '_F' */
            && p[1]==0x534d	/* 'SM' */
            && ((int32*)p)[1]== 0x5f484452L /* '_HDR' */
         ) {
         int16 *p0 = &(vdi_param_adr->ptsout_adr[1]); /* copy *p to &ptsout[1], ptsout[0] contains open_flag */
            p += 25;       /* found it, text string is 50 bytes (25 words) offset */
            n = 13; /* max text len is 13 words */
            while( --n>=0 && (*p0++ = *p++) != 0 ) nr_ptsout++;
            break; /* out of search loop */
         } /* if */
	      p--;
      } while( (n-=sizeof(*p)) >= 0 );
   } /* if */

done:
   vdi_param_adr->ptsout_adr[0] = open_flag;
   vdi_param_adr->contrl_adr->nptsout = nr_ptsout; /* nr pts out */
   vdi_param_adr->contrl_adr->nintout = nr_intout;	/* nr chars in filename */

} /* devinfo() */


/****************************
* load a driver into memory
* set entry point & basepage in *pd
* check for insufficient memory, or driver not loadable
* return ...
*  ERR_????  if error
*  OK (=0)   driver loaded successfully
*/
static tTTF_ERROR
load_driver( const FILE_NAME fname, ACTIVE_WKS_REC *const pd )
{
FILE_H fh;                 /* file handle of driver */
uint32 file_size;
int32  size_fixuptbl;

struct {
   uint16 magic_nr;
   uint32 siz_text;
   uint32 siz_data;
   uint32 siz_bss;
   uint32 siz_symtab;
   uint32 reserved1;
   uint32 reserved2;
   uint16 reserved3;
} exec_file_hdr;        /* header for executable file */

register int32 nr_bytes;
register struct basep *driver_bp IPTR; /* points to driver basepage */
struct basep *const gdos_bp = &((struct basep*)start)[-1];

   /******* open the file, check if OK ... *******/

   fh = open_sys_file( fname );
   file_size = get_sysfile_siz( fname );
#if 1
   if( (fh == -33) /* && (pd->load_type == RESIDENT) */ ) {
      /* resident driver not found in gem system directory.
      ** look in current directory (ie boot disk) */
      fh = Fopen( fname, RD_ONLY );
      file_size = get_file_siz( &fname[0] );
   } /* if */
#endif

   if( fh < 0 ) {
      error_code = READ_ERR;
      goto error0;      /* check, report if error */
   } /* if */

   /******* read in the header & check ... *******/

   nr_bytes = Fread( fh, sizeof( exec_file_hdr ), &exec_file_hdr );
   if( nr_bytes != sizeof( exec_file_hdr ) ) {
      error_code = READ_ERR;
      goto error1;          /* check, report if error */
   } /* if */

   if( exec_file_hdr.magic_nr != 0x601a ) {
      error_code = FILE_ERR;
      goto error1;         /* check, report if error */
   } /* if */
   if( exec_file_hdr.siz_text == 0 ) {
      error_code = FILE_ERR;
      goto error1;         /* check, report if error */
   } /* if */

   /******* allocate memory for driver & check ... *******/

   {
   register uint32 exec_size = sizeof( struct basep ) + exec_file_hdr.siz_text
			+ exec_file_hdr.siz_data + exec_file_hdr.siz_bss;
      driver_bp = (struct basep *)hi_malloc( exec_size );  /* get memory for file */
      if( driver_bp == NULL ) {
	 error_code = MEM_ERR;
	 goto error1;	      /* check, report if error */
      } /* if */
   }

   /*** set up the driver's basepage ... ***/
   {
   register uint32 temp;
      driver_bp->p_lowtpa = gdos_bp->p_lowtpa;
      driver_bp->p_hitpa  = gdos_bp->p_hitpa;
      temp = (uint32)&driver_bp[1];
      driver_bp->p_tbase  = (char *)temp;
      driver_bp->p_tlen   = exec_file_hdr.siz_text;
      temp += exec_file_hdr.siz_text;
      driver_bp->p_dbase  = (char*)temp;
      driver_bp->p_dlen   = exec_file_hdr.siz_data;
      temp += exec_file_hdr.siz_data;
      driver_bp->p_bbase  = (char *)temp;
      driver_bp->p_blen   = exec_file_hdr.siz_bss;
      driver_bp->p_dta	  = gdos_bp->p_cmdlin;
      driver_bp->p_parent = gdos_bp->p_parent;
      driver_bp->p_env	  = gdos_bp->p_env;
   }

   /*** read in the driver executable image ... ***/

   {
   register const uint32 image_size = exec_file_hdr.siz_text + exec_file_hdr.siz_data;
   nr_bytes = Fread( fh, image_size, driver_bp->p_tbase );
   if( nr_bytes != image_size ) {
      error_code = READ_ERR;
      goto error2;         /* check, report if error */
   } /* if */
   }

   (void)Fseek( exec_file_hdr.siz_symtab, fh, 1 );    /* skip symbol table */

   /*** read in the fixup table ***/

   size_fixuptbl = file_size
                   - sizeof( exec_file_hdr )
                   - exec_file_hdr.siz_text
                   - exec_file_hdr.siz_data
                   - exec_file_hdr.siz_symtab;
   if( size_fixuptbl <= 0 ) {
      error_code = READ_ERR;
      goto error2;         /* check, report if error */
   } /* if */
   {
   register const uint8  *const fixup_tblp = (uint8 *)malloc( size_fixuptbl );
   register const uint8  *fp = fixup_tblp;
   register uint32  d;

   if( fixup_tblp == NULL ) {
      error_code = MEM_ERR;
      goto error2;         /* check, report if error */
   } /* if */
   nr_bytes = Fread( fh, 0x7fffffff, fixup_tblp ); /* read fixup table */
   if( nr_bytes != size_fixuptbl ) {
      error_code = READ_ERR;
      (void)free((void *)fixup_tblp);    /* assume successful */
      goto error2;         /* check, report if error */
   } /* if */
   (void)Fclose( fh );  /* assume successful */

   /*** fixup relocation addresses in code ... ***/

   d = *((uint32 *)fp)++;
   if( d != 0L ) {
   register uint32 *cp = (uint32*)driver_bp->p_tbase;
   register uint32  const code_base = (uint32)cp;
      cp = (uint32*)((uint8 *)cp + d);
      assert( cp >= (uint32*)driver_bp->p_tbase);
      assert( cp < (uint32*)driver_bp->p_bbase );
      *cp += code_base;
      assert( *cp >= (uint32)driver_bp->p_tbase);
      assert( *cp < (uint32)driver_bp->p_bbase + driver_bp->p_blen );
      while( (d = *fp++) != 0 ) {
         assert( fp <= fixup_tblp + size_fixuptbl );
	 if( d == 1 ) {
	    cp = (uint32*)((uint8 *)cp + 0xfe);
	 }
	 else {
            cp = (uint32*)((uint8 *)cp + d);
	    *cp += code_base;
            assert( *cp >= (uint32)driver_bp->p_tbase);
            assert( *cp < (uint32)driver_bp->p_bbase + driver_bp->p_blen );
	 } /* if */
         assert( cp >= (uint32*)driver_bp->p_tbase);
         assert( cp < (uint32*)driver_bp->p_bbase );
      } /* while */
   } /* if */
   /* for sq.sys, address c9d8 contains address 8712 .. */
   assert( (strcmp( fname, "sq.sys" ) != 0)
    || ( ((uint32*)driver_bp->p_tbase)[0x3276] == (uint32)driver_bp->p_tbase + 0x8712) );
   (void)free((void *)fixup_tblp);    /* assume successful */
   }

   /*** clear bss area ... ***/
   {
   register uint8  *bssp = (uint8 *)driver_bp->p_bbase;
   register int     n;
      for( n = driver_bp->p_blen; n>0; n-- ) {
	 *bssp++ = 0;
      } /* for */
   }

   pd->base_pagep = driver_bp;
   pd->entry_point = (int16(*)(void))driver_bp->p_tbase;

   return OK;

error2:
   (void)free(driver_bp);    /* assume successful */
error1:
   (void)Fclose(fh);          /* assume successful */
error0:
   return error_code;

} /* load_driver() */


/**************************************************************
*
*  find workstation associated with handle
*  check if current handle is in range, and has valid open workstation
*/
ACTIVE_WKS_REC *find_wkstnp( const int16 handle )
{
register ACTIVE_WKS_REC *pd IPTR;

   if( handle == 0 ) {
   register int n = MAX_WKS;
      /*** get handle of root screen workstation ***/
      pd = active_wk_tbl;
      /* scan table, looking for an opened screen wkstn handle */
      while( (n>0)	/* there are entries in table */
         && ((pd->pw == NULL) || (pd->pw->id >= 10)   /* !screen */
	 || (pd->root_handle == 0)) ) {               /* !opened */
	 pd++; n--;
      } /* while */

      if( n<=0 ) {      /* error this id not found */
	 pd = NULL;
      } /* if */
   }
   else if( ((unsigned)handle > MAX_WKS)
      || ((pd=&active_wk_tbl[handle-1])->root_handle == 0) ) {
      /*** this handle is invalid, or has no open workstation ***/
      pd = NULL;
   } /* if */

   assert( (pd==NULL) ||
                ((pd>=active_wk_tbl) && (pd<=active_wk_tbl+MAX_WKS-1)
		  && ISOPEN(pd) ) ||
		  (handle == 0 && ISOPEN(pd) ) );
   return pd;

} /* find_wkstnp() */


#ifdef LOGGING

int	sprintf(char *, const char *, ...);
int errno;	/* <<< */
int16 fh;

#define LOGFILE "c:\\log"
#define LOG_DEVICE 21	/* id of device to log */

void login( register const Vdi_Params *vdi_param_adr )
{
char buf[80];
int i;


   fh=0; 
   if( (vdi_param_adr->contrl_adr->opcode == OP_OPNWK)
                && (vdi_param_adr->intin_adr[0] == LOG_DEVICE)
    || (active_wk_tbl[vdi_param_adr->contrl_adr->handle-1].pw->id == LOG_DEVICE) ) {

      fh = Fopen( LOGFILE, 2 );
      if( fh == 0 ) {
	 Cconws( "couldn't open logfile " LOGFILE "\r\n" );
	 return;
      } /* if */
      Fseek( 0, fh, 2 );
      sprintf( buf, "\r\nentered gdos: opcode = (%d:%d), handle = %d\r\n"
                    "intin[%d] = { ",
		  vdi_param_adr->contrl_adr->opcode,
		  vdi_param_adr->contrl_adr->subfunc,
		  vdi_param_adr->contrl_adr->handle,
		  vdi_param_adr->contrl_adr->nintin );
      Fwrite( fh, strlen(buf), buf );
      for(i=0; i<vdi_param_adr->contrl_adr->nintin; i++) {
         sprintf( buf, "%d, ", vdi_param_adr->intin_adr[i] );
	 Fwrite( fh, strlen(buf), buf );
      } /* for */
      sprintf( buf, "}\r\nptsin[%d] = { ", vdi_param_adr->contrl_adr->nptsin );
      Fwrite( fh, strlen(buf), buf );
      for(i=0; i<vdi_param_adr->contrl_adr->nptsin; i++) {
         sprintf( buf, "(%d, %d), ", vdi_param_adr->ptsin_adr[2*i], vdi_param_adr->ptsin_adr[2*i+1] );
	 Fwrite( fh, strlen(buf), buf );
      } /* for */
      sprintf( buf, "}\r\n");
      Fwrite( fh, strlen(buf), buf );
      Fclose( fh );
   } /* if */

} /* login() */


void logout( register const Vdi_Params *vdi_param_adr )
{
char buf[80];
int16 fh=0;
int i;

   if( fh > 0 ) {  /* log output only when input was logged */
      fh = Fopen( LOGFILE, 2 );
      Fseek( 0, fh, 2 );
      sprintf( buf, "leaving gdos: handle = %d\r\n"
                    "intout[%d] = { ",
		  vdi_param_adr->contrl_adr->handle,
		  vdi_param_adr->contrl_adr->nintout );
      Fwrite( fh, strlen(buf), buf );
      for(i=0; i<vdi_param_adr->contrl_adr->nintout; i++) {
         sprintf( buf, "%d, ", vdi_param_adr->intout_adr[i] );
	 Fwrite( fh, strlen(buf), buf );
      } /* for */
      sprintf( buf, "}\r\nptsout[%d] = { ", vdi_param_adr->contrl_adr->nptsout );
      Fwrite( fh, strlen(buf), buf );
      for(i=0; i<vdi_param_adr->contrl_adr->nptsout; i++) {
         sprintf( buf, "(%d, %d), ", vdi_param_adr->ptsout_adr[2*i], vdi_param_adr->ptsout_adr[2*i+1] );
	 Fwrite( fh, strlen(buf), buf );
      } /* for */
      sprintf( buf, "}\r\n\n");
      Fwrite( fh, strlen(buf), buf );
      Fclose( fh );
   } /* if */
  
} /* logout() */


#endif


/*********************** end of ttf-gdos.c *********************/
