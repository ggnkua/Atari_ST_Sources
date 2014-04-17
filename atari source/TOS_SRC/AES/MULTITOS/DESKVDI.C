/*	DESKVDI.C		12/10/91	Derek Mui	*/
/*	Fixed at d_xline to set line style	6/9/92	D.Mui	*/
/*	Separated Desktop from AES		3/31/93 C.Gee	*/
/*	Added d_v_hardcopy()			3/31/93 C.Gee	*/

/************************************************************************/
/*	New Desktop for Atari ST/TT Computer				*/
/*	Atari Corp							*/
/*	Copyright 1989,1990 	All Rights Reserved			*/
/************************************************************************/

#include "portab.h"
#include "vdidefs.h"
#ifdef TEXT
/* vdidefs.h uses "TEXT" in a different way than deskdefi.h does */ 
#undef TEXT
#endif
#include "pdesk.h"
#include "pmisc.h"

#ifdef TEXT
/* we avoid confusion between deskdefi.h and vdidefs.h by not using
 * TEXT anywhere in this file
 */
#undef TEXT
#endif

MLOCAL WORD	control[12];
MLOCAL WORD	intin[256];
MLOCAL WORD	ptsin[256];
MLOCAL WORD	intout[256];
MLOCAL WORD	ptsout[256];

MLOCAL	WORD 	work_in[11];	/* Input to VDI parameter array 	*/
MLOCAL	WORD 	work_out[57];	/* Output from VDI parameter array 	*/
MLOCAL	LONG	*pc[5];

EXTERN	WORD	v_handle;


	VOID
d_ncode()
{
	control[6] = v_handle;
	desk_vdi( (LONG *)pc );
}


/*	Set line style to user defined	*/

	VOID
d_v_style( style )
	WORD	style;
{
	intin[0] = style;
	control[0] = 15;
	control[1] = 0;
	control[3] = 1;
	d_ncode();		
}



/*	Set user defined polyline style	*/

	VOID
d_vsl_udsty( style )
	WORD	style;
{
	intin[0] = style;
	control[0] = 113;
	control[1] = 0;
	control[3] = 1;
	d_ncode();
}


	VOID
d_v_pline( number, points )
	WORD	number;
	WORD	*points;
{
	pc[2] = (LONG *) points;
	control[0] = POLYLINE;
	control[1] = number;
	control[3] = 0;
	d_ncode();
	pc[2] = (LONG *) ptsin;
}


	VOID
d_xline( ptscount, ppoints )
	WORD		ptscount;
	REG WORD		*ppoints;
{
	static	WORD	hztltbl[2] = { 0x5555, 0xaaaa };
	static  WORD	verttbl[4] = { 0x5555, 0xaaaa, 0xaaaa, 0x5555 };
	REG WORD		*linexy;
	REG WORD		st, i;

	d_v_style( 7 );

	for ( i = 1; i < ptscount; i++ )
	{
	  if ( *ppoints == *(ppoints + 2) )
	  {
	    st = verttbl[( (( *ppoints) & 1) | ((*(ppoints + 1) & 1 ) << 1))];
	  }	
	  else
	  {
	    linexy = ( *ppoints < *( ppoints + 2 )) ? ppoints : ppoints + 2;
	    st = hztltbl[( *(linexy + 1) & 1)];
	  }

	  d_vsl_udsty( st );
	  d_v_pline( 2, ppoints );
	  ppoints += 2;
	}
	d_vsl_udsty( 0xffff );
}	


	VOID
d_setattr( mode, color )
	UWORD	mode,color;
{
	intin[0] = mode;
	control[0] = SET_WRITING_MODE;
	control[1] = 0;
	control[3] = 1;
	d_ncode();

	control[0] = S_LINE_COLOR;
	intin[0] = color;

	control[1] = 0;
	control[3] = 1;
	d_ncode();
}



/* desktop open virtual workstation	*/

	VOID
desk_vopnvwk( handle, resolution, ptr )
	WORD	*handle;
	WORD	resolution;
	WORD	**ptr;
{
	WORD	i;

	for( i = 1; i < 10; ++i )
	  intin[i] = 1;

	intin[0] = resolution;
	intin[10] = 2;
	control[6] = *handle;
	control[0] = 100;
	control[1] = 0;
	control[3] = 11;
	pc[0] = (LONG *) control;
	pc[1] = (LONG *) intin;
	pc[2] = (LONG *) ptsin;
	pc[3] = (LONG *) intout;
	pc[4] = (LONG *) ptsout;
	desk_vdi( (LONG *)pc );
	*handle = control[6];
	*ptr = intout;
}

/*	show cursor	*/

	VOID
v_show_c( reset )
	WORD	reset;
{
	intin[0] = reset;
	control[0] = 122;
	control[1] = 0;
	control[3] = 1;
	d_ncode();
}


/*	hide cursor	*/

	VOID
v_hide_c( )
{
	control[0] = 123;
	control[1] = 0;
	control[3] = 0;
	d_ncode();
}


/*	enter graphic mode	*/

	VOID
v_exit_cur( )
{
	control[0] = 5;
	control[1] = 0;
	control[3] = 0;
	control[5] = 2;
	d_ncode();
}


/*	enter alpha mode	*/

	VOID
v_enter_cur( )
{
	control[0] = 5;
	control[1] = 0;
	control[3] = 0;
	control[5] = 3;
	d_ncode();
}


/*	clipping function	*/

	VOID
vs_clip( clip_flag, pxyarray )
	WORD	clip_flag;
	WORD	pxyarray[];
{
	intin[0] = clip_flag;
	control[0] = 129;
	control[1] = 2;
	control[3] = 1;
	pc[2] = (LONG *) pxyarray;
	d_ncode();
	pc[2] = (LONG *) ptsin;
}


	VOID
d_v_clsvwk( )
{
	control[0] = 101;
	control[1] = 0;
	control[3] = 0;
	d_ncode();
}


	VOID
d_vro_cpyfm( mode, xyarray, psrc, pdst )
	WORD	mode;
	WORD	xyarray[];
	LONG	*psrc,*pdst;
{
	LONG	*ptr;

	intin[0] = mode;
	ptr = (LONG *) &control[7];	
	ptr[0] = (LONG) psrc;
	ptr[1] = (LONG) pdst;
	pc[2] = (LONG *) xyarray;
	control[0] = 109;
	control[1] = 4;
	control[3] = 1;
	d_ncode();
	pc[2] = (LONG *) ptsin;
}


	VOID
vq_chcells( row, col )
	WORD	*row,*col;
{
	control[0] = 5;
	control[1] = 0;
	control[3] = 0;
	control[5] = 1;
	d_ncode();
	*row = intout[0];
	*col = intout[1];
}

	WORD	
d_v_load_fonts()
{
	control[0] = 119;
	control[1] = 0;
	control[3] = 1;
	intin[0] = 0;
	d_ncode();
	return intout[0];
}
	VOID	
d_v_unload_fonts()
{
	control[0] = 120;
	control[1] = 0;
	control[3] = 1;
	intin[0] = 0;
	d_ncode();
}


	WORD
d_v_font_name( i, name, fsmflag )
	WORD	i;
	BYTE	*name;
	WORD	*fsmflag;
{
	intin[0] = i;
	control[0] = 130;
	control[1] = 0;
	control[3] = 1;
	d_ncode();

	for ( i = 1; i <=32; i++ )
	  *name++ = (BYTE)intout[i];

	*fsmflag = intout[33];
	return( intout[0] );
}

	WORD
d_vqt_width(c, w, ld, rd)
	WORD	c;
	WORD 	*w, *ld, *rd;
{
	intin[0] = c;
	control[0] = 117;
	control[1] = 0;
	control[3] = 1;
	d_ncode();

	*w = ptsout[0];
	*ld = ptsout[2];
	*rd = ptsout[4];
	return intout[0];
}

	WORD
d_vqt_attributes( attrib )
	WORD	*attrib;
{
	control[0] = 38;
	control[1] = 0;
	control[3] = 0;
	d_ncode();
	attrib[0] = intout[0];
	attrib[1] = intout[1];
	attrib[2] = intout[2];	
	attrib[3] = intout[3];
	attrib[4] = intout[4];
	attrib[5] = intout[5];
	attrib[6] = ptsout[0];
	attrib[7] = ptsout[1];
	attrib[8] = ptsout[2];
	attrib[9] = ptsout[3];
}

	WORD
d_v_setfont(font)
WORD	font;
{
	intin[0] = font;
	control[0] = 21;
	control[1] = 0;
	control[3] = 1;
	d_ncode();
	return intout[0];
}

	WORD
d_vst_point(point, chw, chh, cew, ceh)
WORD	point;
WORD	*chw, *chh, *cew, *ceh;
{
	intin[0] = point;
	control[0] = 107;
	control[1] = 0;
	control[3] = 1;
	d_ncode();
	*chw = ptsout[0];
	*chh = ptsout[1];
	*cew = ptsout[2];
	*ceh = ptsout[3]; 
	return intout[0];
}

	WORD
d_vst_arbpt(point, chw, chh, cew, ceh)
WORD	point;
WORD	*chw, *chh, *cew, *ceh;
{
	intin[0] = point;
	control[0] = 246;
	control[1] = 0;
	control[3] = 1;
	d_ncode();
	*chw = ptsout[0];
	*chh = ptsout[1];
	*cew = ptsout[2];
	*ceh = ptsout[3]; 
	return intout[0];
}

	WORD
d_vst_height(h, chw, chh, cew, ceh)
WORD	h;
WORD	*chw, *chh, *cew, *ceh;
{
	ptsin[0] = 0;
	ptsin[1] = h;
	control[0] = 12;
	control[1] = 1;
	control[3] = 0;
	d_ncode();
	*chw = ptsout[0];
	*chh = ptsout[1];
	*cew = ptsout[2];
	*ceh = ptsout[3]; 
	return intout[0];
}
 	


/*	Hard Copy */
	VOID
d_v_hardcopy( VOID )
{
	control[0] = 5;
	control[1] = 0;
	control[3] = 0;
	control[5] = 17;
	d_ncode();
}
