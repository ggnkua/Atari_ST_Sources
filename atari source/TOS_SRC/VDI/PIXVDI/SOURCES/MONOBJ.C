/*
********************************** monobj.c ***********************************
*
* $Revision: 3.0 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/monobj.c,v $
* =============================================================================
* $Author: lozben $	$Date: 91/01/03 15:12:41 $     $Locker:  $
* =============================================================================
*
* $Log:	monobj.c,v $
* Revision 3.0  91/01/03  15:12:41  lozben
* New generation VDI
* 
* Revision 2.2  89/05/16  12:55:28  lozben
* Functions that used to initialize FG_BP_[1,2,3,4], now
* initialize FG_B_PLANES instead. FG_B_PLANES is set to the current
* color index before a drawing primitive is called.
* 
* Revision 2.1  89/02/21  17:23:50  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.7  88/05/05  12:17:01  lozben
* Put back vq_mouse_status() routine, then commented it out, so that people
* could see what it used to look like in "C".
* 
* Revision 1.6  88/04/28  17:25:59  eisen
* Removed the initialization in vrq_locator because it seemed to affect
* compatibility with previous versions.
* 
* Revision 1.5  88/04/25  17:18:51  eisen
* Changed v_locator to call SET_CUR(x, y). SET_CUR sets the GCURX, GCURY and
* vblank draw packet position to x,y. SET_CUR(x, y) alters system variables
* atomically.
* 
* Revision 1.4  88/04/19  17:19:57  eisen
* *** empty log message ***
* 
* Revision 1.2  88/04/19  12:34:34  lozben
* vq_mouse_status has been changed to an asembly routine, to allow
* for atomic access to mouse parameter block.
* 
* Revision 1.1  87/11/20  15:16:23  lozben
* Initial revision
* 
*************************************************************************
*/

#include	"proto.h"
#include	"portab.h"
#include	"fontdef.h"
#include	"attrdef.h"
#include	"scrndev.h"
#include	"lineavar.h"
#include	"vardefs.h"
#include	"gsxdef.h"
#include	"gsxextrn.h"

/*--------------------------------------------------------------------------*/
/*
 * S_LINE_TYPE: 
 */
VOID
vsl_type( VOID )
{
   REG WORD li;

   CONTRL[4]=1;

   li = (*INTIN-1);
   if ((li >= MX_LN_STYLE) || (li < 0))
      li = 0;

   *INTOUT = (cur_work->line_index = li) + 1;
} 
/*--------------------------------------------------------------------------*/
/* 
 * S_LINE_WIDTH:
 */
VOID
vsl_width( VOID )
{
  REG WORD w, *pts_out;

  /* Limit the requested line width to a reasonable value. */

  w = PTSIN[0];
  if (w < 1)
    w = 1;
  else if (w > SIZ_TAB[6])
    w = SIZ_TAB[6];

  /* Make the line width an odd number (one less, if even). */

  w = ((w-1)/2)*2 + 1;

  /* Set the line width internals and return parameters */

  CONTRL[2] = 1;
  pts_out = PTSOUT;
  *pts_out++ = cur_work->line_width = w;
  *pts_out = 0;
}
/*--------------------------------------------------------------------------*/
/*
 * S_END_STYLE:
 */
VOID
vsl_ends( VOID )
{
  REG WORD	    lb, le;
  REG WORD	    *pointer;
  REG ATTRIBUTE	    *work_ptr;

  *(CONTRL+4) = 2;

  pointer = INTIN;
  lb = *pointer++;
  if ( lb<0 || lb>2 )
    lb = 0;

  le = *pointer;
  if ( le<0 || le>2 )
    le = 0;

  pointer = INTOUT;
  work_ptr = cur_work;
  *pointer++ = work_ptr->line_beg = lb;
  *pointer = work_ptr->line_end = le;
}  /* End "vsl_ends". */
/*--------------------------------------------------------------------------*/
/* 
 * S_LINE_COLOR:
 */
VOID
vsl_color( VOID )
{
	REG WORD lc;
	
	*(CONTRL+4) = 1;
	lc = *(INTIN);

	if ((lc >= DEV_TAB[13]) || (lc < 0))
	    lc = 1;

	*(INTOUT) = lc;
	cur_work->line_color = MAP_COL[lc];
}
/*--------------------------------------------------------------------------*/
/* 
 * S_MARKER_SCALE
 */
VOID
vsm_height( VOID )
{
  REG WORD	    h, *pts_out;
  REG ATTRIBUTE	    *work_ptr;

  /* Limit the requested marker height to a reasonable value. */

  h = PTSIN[1];
  if (h < DEF_MKHT)
    h = DEF_MKHT;

  else if (h > MAX_MKHT)
    h = MAX_MKHT;

  /* Set the marker height internals and the return parameters. */

  work_ptr = cur_work;
  work_ptr->mark_height = h;
  h = (h + DEF_MKHT/2)/DEF_MKHT;
  work_ptr->mark_scale = h;
  CONTRL[2] = 1;
  pts_out = PTSOUT;
  *pts_out++ = h * DEF_MKWD;
  *pts_out   = h * DEF_MKHT;
  FLIP_Y = 1;
}
/*--------------------------------------------------------------------------*/
/*
 * S_MARK_TYPE
 */
VOID
vsm_type( VOID )
{
    REG WORD i;

    i = INTIN[0] - 1;
    i = ((i>=MAX_MARK_INDEX) || (i<0)) ? 2 : i;
    INTOUT[0] = (cur_work->mark_index = i) + 1;
    CONTRL[4] = 1;
}
/*--------------------------------------------------------------------------*/
/*
 * S_MARK_COLOR
 */
VOID
vsm_color( VOID )
{
    REG WORD i;

    i = INTIN[0];
    i = ((i>=DEV_TAB[13]) || (i<0)) ? 1 : i;
    INTOUT[0] = i;
    cur_work->mark_color = MAP_COL[i];
    CONTRL[4] = 1;
}
/*--------------------------------------------------------------------------*/
/*
 * S_FILL_STYLE:
 */
VOID 
vsf_interior( VOID )
{
    REG WORD fs;

    CONTRL[4] = 1;
    fs = *INTIN;
    if ((fs > MX_FIL_STYLE) || (fs < 0))
	fs = 0;
    *INTOUT = cur_work->fill_style = fs;
    st_fl_ptr();
}
/*--------------------------------------------------------------------------*/
/* 
 * S_FILL_INDEX:
 */
VOID
vsf_style( VOID )
{
    REG WORD fi;
    REG ATTRIBUTE   *work_ptr;

    CONTRL[4] = 1;
    fi = *INTIN;
    work_ptr = cur_work;

    if (work_ptr->fill_style == 2) {
	if ((fi > MX_FIL_PAT_INDEX) || (fi < 1))
	     fi = 1;
    }
    else {
	if ((fi > MX_FIL_HAT_INDEX) || (fi < 1))
	    fi = 1;
    }

    work_ptr->fill_index = (*INTOUT = fi) - 1;

    st_fl_ptr();
}
/*--------------------------------------------------------------------------*/
/*
 * S_FILL_COLOR:
 */
VOID
vsf_color( VOID )
{
    REG WORD fc;

    *(CONTRL+4)=1;
    fc = *INTIN;
    if ((fc >= DEV_TAB[13]) || (fc < 0))
	fc = 1;

    *INTOUT = fc;
    cur_work->fill_color = MAP_COL[ fc ];
}
/*--------------------------------------------------------------------------*/
/*
 * LOCATOR_INPUT
 */
VOID
v_locator( VOID )
{
	REG WORD motion, button;
	REG WORD *pointer;
	REG WORD x, y; 

	*INTIN = 1;

	/* Set the initial locator position.				 */

	pointer = PTSIN;
	x = *pointer++;
	y = *pointer;
	SET_CUR(x, y);				/* set GCURX, GCURY, & mouse */


	if ( loc_mode == 0 )			/* Request mode		  */
	{
/*	  GLOC_KEY(); Init locator status. OOPS, Causes incompatibilities */

	  HIDE_CNT = 1;				/* Force cursor visible	  */
	  DIS_CUR();

	/* Wait for key or button event (bit 0 of GLOC_KEY return)	  */

	  while ( !(GLOC_KEY() & 1))		/* X1 and Y1 get updated  */
	  ;			

	  pointer      = CONTRL;
	  *(pointer+4) = 1;
	  *(pointer+2) = 1;
	  *(INTOUT)    = TERM_CH & 0x00FF;	/* terminating character  */
	  pointer      = PTSOUT;
	  *pointer++   = X1;			/* final cursor position  */
	  *pointer     = Y1; 

	  HIDE_CUR();				/* always hide cursor	  */
	}


	else					/* Sample mode		  */
	{
	   motion = 0;
	   button = 0;

	   switch (GLOC_KEY())
	   {
	      case 0:
		break;

	      case 1:
		button     = 1;
		*(INTOUT)  = TERM_CH & 0x00FF;
		break;

	      case 2:
		motion     = 1;
		pointer    = PTSOUT;
		*pointer++ = X1;
		*pointer   = Y1;
		break;

	      case 3:
		motion     = 1;
		button     = 1;
		*(INTOUT)  = TERM_CH & 0x00FF;
		pointer    = PTSOUT;
		*pointer++ = X1;
		*pointer   = Y1;	
		break;
	    }
	    pointer = CONTRL;
	    *(pointer+2) = motion;
	    *(pointer+4) = button;
	}
}
/*--------------------------------------------------------------------------*/
/*
 * SHOW CURSOR
 */
VOID
v_show_c( VOID ) 
{
    /* DIS_CUR will trash all registers but FP and SP */

    if ( !*INTIN && HIDE_CNT )
	HIDE_CNT = 1;		/* reset cursor to on */

    DIS_CUR();
}
/*--------------------------------------------------------------------------*/
/*
 * HIDE CURSOR
 */
VOID
v_hide_c( VOID )
{
    HIDE_CUR();
}
/*--------------------------------------------------------------------------*/
/*
 * RETURN MOUSE BUTTON STATUS
 *
 * vq_mouse_status() - has been changed to an assembly file, to allow for
 *                     atomic access to mouse parameter block.
 * vq_mouse_status() 
 * {
 *    REG WORD *pointer;
 *
 *    *(INTOUT) = MOUSE_BT;
 *
 *    pointer = CONTRL;
 *    *(pointer+4) = 1;
 *    *(pointer+2) = 1;
 *
 *    pointer = PTSOUT;
 *    *pointer++ = GCURX;
 *    *pointer   = GCURY;
 * }
 */
/*--------------------------------------------------------------------------*/
/* 
 * VALUATOR_INPUT: 
 */
VOID
v_valuator( VOID )
{
}
/*--------------------------------------------------------------------------*/
/*
 * CHOICE_INPUT:
 */
VOID
v_choice( VOID )
{
	WORD	i;

	if ( chc_mode == 0 )
	{
	  *(CONTRL+4)=1;
	  while ( GCHC_KEY() != 1 );
	    *(INTOUT)=TERM_CH &0x00ff;
	}
	else
	{
	  i = GCHC_KEY();
	  *(CONTRL+4)=i;
	  if (i == 1)
	    *(INTOUT)=TERM_CH &0x00ff;
	  else if (i == 2)
	    *(INTOUT+1)=TERM_CH & 0x00ff;
	}	
}
/*--------------------------------------------------------------------------*/
/*
 * STRING_INPUT:
 */
VOID
v_string( VOID )
{
	WORD	i, j, mask;

	mask = 0x00ff;
	j = *INTIN;
	if ( j < 0 )
	{
	    j = -j;
	    mask = 0xffff;
	}
	if ( !str_mode )	/* Request mode */
	{
	  TERM_CH = 0;
	  for ( i = 0;( i < j) && (TERM_CH != 0x000d); i++)
	  {
	    while ( GCHR_KEY() == 0 );
	    *(INTOUT+i) = TERM_CH = TERM_CH & mask;	
	  }
	  if ( TERM_CH == 0x000d )
	    --i;
	  *(CONTRL+4) = i; 
	}
	else			/* Sample mode */
	{
	  i = 0;
	  while ( (i < j) && (GCHR_KEY() != 0) )	/* jde 12-aug-85 */
	    *(INTOUT+i++) = TERM_CH & mask;
	  *(CONTRL+4) = i;
	}
}
/*--------------------------------------------------------------------------*/
/*
 * Return Shift, Control, Alt State
 */
VOID 
vq_key_s( VOID )
{
	CONTRL[4] = 1;
	INTOUT[0] = GSHIFT_S();
}
/*--------------------------------------------------------------------------*/
/*
 * SET_WRITING_MODE:
 */
VOID
vswr_mode( VOID )
{
    REG WORD wm;

    CONTRL[4] = 1;
    wm = INTIN[0] - 1;
    if ((wm > MAX_MODE) | (wm < 0))
	wm = 0;

    INTOUT[0] = (cur_work->wrt_mode = wm) + 1;
}
/*--------------------------------------------------------------------------*/
/*
 * SET_INPUT_MODE:
 */
VOID
vsin_mode( VOID )
{
	REG WORD i, *int_in;

	CONTRL[4] = 1;

	int_in = INTIN;
	*INTOUT = i = *(int_in+1);
	i--; 
	switch ( *(int_in) )
	{	
	  case 0:
	    break;
	  
	  case 1:	/* locator */
	    loc_mode = i;
	    break;

	  case 2:	/* valuator */
	    val_mode = i;
	    break;

	  case 3: /* choice */
	    chc_mode = i;
	    break;

	  case 4: /* string */
	    str_mode = i;
	    break;
	}
}
/*--------------------------------------------------------------------------*/
/*
 * INQUIRE INPUT MODE:
 */
VOID
vqi_mode( VOID )
{
	REG WORD *int_out;

	*(CONTRL+4) = 1;

	int_out = INTOUT;
	switch ( *(INTIN) )
	{	
	  case 0:
	    break;
	  
	  case 1:	/* locator */
	    *int_out = loc_mode;
	    break;

	  case 2:	/* valuator */
	    *int_out = val_mode;
	    break;

	  case 3: /* choice */
	    *int_out = chc_mode;
	    break;

	  case 4: /* string */
	    *int_out = str_mode;
	    break;
	}
}
/*--------------------------------------------------------------------------*/
/*
 * ST_FILLPERIMETER:
 */
VOID
vsf_perimeter( VOID )
{
    REG WORD	    *int_out;
    REG ATTRIBUTE   *work_ptr;

    work_ptr = cur_work;
    int_out = INTOUT;

    if ( *INTIN == 0 ) {
	*int_out = 0;  
	work_ptr->fill_per = FALSE;
    }
    else {
	*(int_out) = 1;
	work_ptr->fill_per = TRUE;
    }
    CONTRL[4] = 1;
}
/*--------------------------------------------------------------------------*/
/* 
 * ST_UD_LINE_STYLE:
 */
VOID
vsl_udsty( VOID )
{
    cur_work->ud_ls = *INTIN;
}
/*--------------------------------------------------------------------------*/
/*
 * Set Clip Region
 */
VOID
s_clip( VOID )
{
    REG WORD	    *xy, rtemp;
    REG ATTRIBUTE   *work_ptr;

    work_ptr = cur_work;
    if ( (work_ptr->clip = *INTIN) != 0)
    {
	xy = PTSIN;
	arb_corner(xy, ULLR);

	rtemp = *xy++;
	work_ptr->xmn_clip = (rtemp < 0) ? 0 : rtemp;

	rtemp = *xy++;
	work_ptr->ymn_clip = (rtemp < 0) ? 0 : rtemp;

	rtemp = *xy++;
	work_ptr->xmx_clip = (rtemp > DEV_TAB[0]) ? DEV_TAB[0] : rtemp;

	rtemp = *xy;
	work_ptr->ymx_clip = (rtemp > DEV_TAB[1]) ? DEV_TAB[1] : rtemp;
    }	
    else
    {
	work_ptr->clip = 0;
	work_ptr->xmn_clip = 0;
	work_ptr->ymn_clip = 0;
	work_ptr->xmx_clip = xres;
	work_ptr->ymx_clip = yres;
   }  /* End else:  clipping turned off. */
}
/*--------------------------------------------------------------------------*/
VOID
arb_corner(corners, type)
WORD *corners, type;
{
  /* Local declarations. */
  REG WORD temp, typ;
  REG WORD *xy1, *xy2;

  /* Fix the x coordinate values, if necessary. */

  xy1 = corners;
  xy2 = corners+2;
  if (*xy1 > *xy2)
  {
    temp = *xy1;
    *xy1 = *xy2;
    *xy2 = temp;
  }  /* End if:  "x" values need to be swapped. */

  /* Fix y values based on whether traditional (ll, ur) or raster-op */
  /* (ul, lr) format is desired.                                     */

  xy1++;	/* they now point to corners[1] and corners[3] */
  xy2++;

  typ = type;

  if ( ( (typ == LLUR) && (*xy1 < *xy2) ) ||
       ( (typ == ULLR) && (*xy1 > *xy2) ) )
    {
      temp = *xy1;
      *xy1 = *xy2;
      *xy2 = temp;
    }  /* End if:  "y" values need to be swapped. */
}
/*--------------------------------------------------------------------------*/
VOID
dro_cpyfm( VOID )
{
  arb_corner(PTSIN, ULLR);
  arb_corner((PTSIN+4), ULLR);
  COPYTRAN = 0;
  COPY_RFM();
}
/*--------------------------------------------------------------------------*/
VOID
drt_cpyfm( VOID )
{
  arb_corner(PTSIN, ULLR);
  arb_corner((PTSIN+4), ULLR);
  COPYTRAN = 0xFFFF;
  COPY_RFM();
}
/*--------------------------------------------------------------------------*/
VOID
dr_trn_fm( VOID )
{
    REG FDB	*src, *dst;
    REG WORD    sFormat, dFormat;
    REG LONG    *cntrlS, *cntrlD;

    cntrlS = CONTRL + 7;
    cntrlD = CONTRL + 9;

    src = (FDB *) *cntrlS;
    dst = (FDB *) *cntrlD;

    sFormat = src->formatId;
    dFormat = dst->formatId;

    switch (sFormat) {

	case DEVICEDEP:
	    switch (dFormat) {
		case DEVICEDEP:
		case STANDARD:
		default:
		    if (form_id == PIXPACKED) {
			*cntrlD = (LONG) src;
			src->formatId = PIXPACKED;
		        PX_AND_INT_TRAN_FM();
			src->formatId = DEVICEDEP;
			*cntrlD = (LONG) dst;
		    }

		    TRAN_FM();
		    break;
			
		case INTERLEAVED:
		    if (form_id == PIXPACKED) {
			src->formatId = PIXPACKED;
			PX_AND_INT_TRAN_FM();
			src->formatId = DEVICEDEP;
		    }

		    break;

		case PIXPACKED:
		    if (form_id == INTERLEAVED) {
			src->formatId = PIXPACKED;
			PX_AND_INT_TRAN_FM();
			src->formatId = DEVICEDEP;
		    }

		    break;

	    }	
	    break;


	case STANDARD:
	    switch (dFormat) {
		case DEVICEDEP:
		case STANDARD:
		default:
		    TRAN_FM();

		    if (form_id == PIXPACKED) {
			*cntrlS = (LONG) dst;
			dst->formatId = INTERLEAVED;
		        PX_AND_INT_TRAN_FM();
			dst->formatId = DEVICEDEP;
			*cntrlS = (LONG) src;
		    }
		    break;

		case INTERLEAVED:
		    TRAN_FM();
		    break;

		case PIXPACKED:
		    TRAN_FM();

		    *cntrlS = (LONG) dst;
		    dst->formatId = INTERLEAVED;
		    PX_AND_INT_TRAN_FM();
		    dst->formatId = PIXPACKED;
	    	    *cntrlS = (LONG) src;
		    break;
	    }
	    break;


	case INTERLEAVED:
	    switch (dFormat) {
	        case DEVICEDEP:
		    if (form_id == PIXPACKED)
			PX_AND_INT_TRAN_FM();

		    break;

		case STANDARD:
		    TRAN_FM();
		    break;

		case INTERLEAVED:
		    break;

		case PIXPACKED:
		    PX_AND_INT_TRAN_FM();
		    break;

		default:
		    break;
	    }
	    break;


        case PIXPACKED:
	    switch (dFormat) {
	        case DEVICEDEP:
		    if (form_id == INTERLEAVED)
			PX_AND_INT_TRAN_FM();
	    	    break;

		case STANDARD:
		    *cntrlD = (LONG) src;
		    PX_AND_INT_TRAN_FM();
	    	    *cntrlD = (LONG) dst;

		    src->formatId = INTERLEAVED;
		    TRAN_FM();
		    src->formatId = PIXPACKED;
		    break;

		case INTERLEAVED:
		    PX_AND_INT_TRAN_FM();
		    break;

		case PIXPACKED:
		    break;

		default:
		    break;
	    }
	    break;


	default:
	    break;
    }
	
}
/*--------------------------------------------------------------------------*/
VOID
dr_recfl( VOID )
{
  REG WORD *pts_in;

  /* Perform arbitrary corner fix-ups and invoke the rectangle fill routine */

  arb_corner(PTSIN, ULLR);
  FG_B_PLANES = cur_work->fill_color;

  pts_in = PTSIN;
  X1 = *pts_in++;
  Y1 = *pts_in++;
  X2 = *pts_in++;
  Y2 = *pts_in;

  RECTFILL();
}
/*--------------------------------------------------------------------------*/
