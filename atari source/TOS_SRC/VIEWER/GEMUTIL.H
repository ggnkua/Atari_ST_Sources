/* gemutil.h	external definitions for GEM utility routines
 *=======================================================================
 * 920601 kbad
 */
#ifndef _GEMUTIL_H
#define _GEMUTIL_H _GEMUTIL_H

#ifndef _PORTAB_H
#include <portab.h>
#endif
#ifndef _VDI_H
#include <vdi.h>
#endif
#ifndef _AES_H
#include <aes.h>
#endif
#ifndef _AES4_h
#include "aes4.h"
#endif

/* Configuration
 *=======================================================================
 */
#undef NEED_RC_INTERSECT /* #define if rc_intersect() isn't in libs */
#undef NEED_MINMAX		/* #define if min() & max() aren't in libs */


#ifdef LATTICE
/* set traditional array declarations for Lattice */
#define vpb		_VDIpb
#define contrl	_VDIcontrl
#define intin	_VDIintin
#define intout	_VDIintout
#define ptsin	_VDIptsin
#define ptsout	_VDIptsout
#endif

#ifdef __TURBOC__
#define NEED_RC_INTERSECT	/* Ugh! */
#define NEED_MINMAX

#define umul_div(num1, num2, div) \
		((int)(((long)(num1) * (long)(num2)) / (long)(div)))
#define ADDR(a) (a)
#define rc_equal(r1, r2) \
		(*(long *)&(r1)->g_x == *(long *)&(r2)->g_x && \
		 *(long *)&(r1)->g_w == *(long *)&(r2)->g_w)

extern WORD *_VdiParBlk[];
#define vpb		_VdiParBlk
#define contrl	(_VdiParBlk[0])
#define intin	(_VdiParBlk[1])
#define ptsin	(_VdiParBlk[3])
#endif


/* Definitions & data types
 *=======================================================================
 */
/* all in <aes4.h> */

/* Functions
 *=======================================================================
 */

/* Needed library functions */
#ifdef NEED_MINMAX
int min __PROTO((int a, int b));
int max __PROTO((int a, int b));
#endif

/* Blit functions */
void	bb_scroll __PROTO((int wsid, const GRECT *r, int dx, int dy,
						   GRECT *r1, GRECT *r2));

/* File selector */
char	*pn_full __PROTO((const char *path, char *fullpath));
WORD	fsel_name __PROTO((const char *label, const char *filemask,
						   char *name));

/* Graphics functions */


/* Rectangle functions */
WORD	*rc_boxpts __PROTO((const GRECT *r, WORD *xy));
void	rc_chrect __PROTO((const GRECT *r, int x0, int y0, int wch, int hch,
						   GRECT *chrect));

BOOLEAN	rc_dirty __PROTO((const GRECT *r, int dx, int dy,
						  GRECT *r1, GRECT *r2));
WORD	*rc_getpts __PROTO((const GRECT *r, WORD *xy));
#ifdef NEED_RC_INTERSECT
GLOBAL	BOOLEAN	rc_intersect __PROTO((const GRECT *rs, GRECT *rd));
#endif
GRECT	*rc_setpts __PROTO((const WORD *xy, GRECT *r));


/* Slider functions */
WORD	sl_delay __PROTO((WORD delay));

/* VDI functions */
void	vdi __PROTO((void *pb));
#ifdef LATTICE
#pragma inline vdi(d1) {register d2,a2; "70734E42";}
						/* moveq #73,d0 / trap #2 */
#endif
void	v_wtext __PROTO((int wsid, int textlen));

/* Window functions */
void	wind_slider __PROTO((int id, int set, int range, int visrange,
							 WORD *pval));

#endif /* !defined(_GEMUTIL_H) */
