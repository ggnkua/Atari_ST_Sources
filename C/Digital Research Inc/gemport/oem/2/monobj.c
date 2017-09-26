/***********************************************************************
 *                                                                     *
 *                         MONOBJ.C                                    *
 *                                                                     *
 ***********************************************************************/

#include "portab.h"
#include "gsxdef.h"
#include "gsxextrn.h"

/************************************************************************
 *	All comments of the form "SCC  date  VW" note changes made to	*
 *	support virtual workstations					*
 *									*
 ************************************************************************/

/* S_LINE_TYPE: */
vsl_type()
{
   REG WORD li;

   CONTRL[4]=1;

   li = (*INTIN-1);
   if ((li >= MX_LN_STYLE) || (li < 0))
      li = 0;

   *INTOUT = (cur_work->line_index = li) + 1;
} 

/* S_LINE_WIDTH: */
vsl_width()
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

/* S_END_STYLE: */
vsl_ends()
{
  REG WORD lb, le;
  REG WORD *pointer;
  REG struct attribute *work_ptr;

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

/* S_LINE_COLOR: */
vsl_color()
{
	REG WORD lc;

	*(CONTRL+4)=1;
	lc = *(INTIN);
	if ((lc >= DEV_TAB[13]) || (lc < 0))
	  lc = 1;
	*(INTOUT) = lc;
	cur_work->line_color = MAP_COL[ lc ];
}

/* S_MARKER_SCALE */
vsm_height()
{
  REG WORD h, *pts_out;
  REG struct attribute *work_ptr;

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
/* End "vsm_height". */

/* S_MARK_TYPE */
vsm_type()
{
    REG WORD i;

    i = INTIN[0] - 1;
    i = ((i>=MAX_MARK_INDEX) || (i<0)) ? 2 : i;
    INTOUT[0] = (cur_work->mark_index = i) + 1;
    CONTRL[4] = 1;
}

/* S_MARK_COLOR */
vsm_color()
{
    REG WORD i;

    i = INTIN[0];
    i = ((i>=DEV_TAB[13]) || (i<0)) ? 1 : i;
    INTOUT[0] = i;
    cur_work->mark_color = MAP_COL[i];
    CONTRL[4] = 1;
}


/* S_FILL_STYLE: */
vsf_interior()
{
    REG WORD fs;

    CONTRL[4] = 1;
    fs = *INTIN;
    if ((fs > MX_FIL_STYLE) || (fs < 0))
	fs = 0;
    *INTOUT = cur_work->fill_style = fs;
    st_fl_ptr();
}

/* S_FILL_INDEX: */
vsf_style()
{
    REG WORD fi;
    REG struct attribute *work_ptr;

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

/* S_FILL_COLOR: */
vsf_color()
{
    REG WORD fc;

    *(CONTRL+4)=1;
    fc = *INTIN;
    if ((fc >= DEV_TAB[13]) || (fc < 0))
	fc = 1;

    *INTOUT = fc;
    cur_work->fill_color = MAP_COL[ fc ];
}

/* LOCATOR_INPUT: */
v_locator()
{
	WORD	i;
	REG WORD *pointer;

	*INTIN = 1;

	/* Set the initial locator position. */

	pointer = PTSIN;
	GCURX = *pointer++;
	GCURY = *pointer;

	if ( loc_mode == 0 )
	{
	  DIS_CUR();
	  while ( (i = GLOC_KEY()) != 1 ) /* loop till some event */
	  {
	      if ( i == 4 )	/* keyboard cursor? */
	      {
	          HIDE_CUR();	/* turn cursor off */
		  GCURX = X1;
		  GCURY = Y1;
	          DIS_CUR();   /* turn cursor on */ 
	      }
	  }	
	  *(INTOUT) = TERM_CH & 0x00ff;
	  pointer = CONTRL;
	  *(pointer+4) = 1;
	  *(pointer+2) = 1;
	  pointer = PTSOUT;
	  *pointer++ = X1;
	  *pointer = Y1;
	  HIDE_CUR();
	}
	else
	{
	  i = GLOC_KEY();
	  pointer = CONTRL;
	  *(pointer+2) = 1;
	  *(pointer+4) = 0;
	  switch ( i )
	    {
	      case 0:
	        *(pointer+2) = 0;
		break;

	      case 1:
	        *(pointer+2) = 0;
		*(pointer+4) = 1;
		*(INTOUT) = TERM_CH & 0x00ff;
		break;

	      case 2:
		pointer = PTSOUT;
		*pointer++ = X1;
		*pointer   = Y1;
		break;

	     case 3:
		*(pointer+4) = 1;
		pointer = PTSOUT;
		*pointer++ = X1;
		*pointer   = Y1;	
		break;

	     case 4:
		if ( HIDE_CNT == 0 )
		{
		    HIDE_CUR();
		    pointer = PTSOUT;
		    *pointer++ = GCURX = X1;
		    *pointer   = GCURY = Y1;
		    DIS_CUR();
		}
		else
		{
		    pointer = PTSOUT;
		    *pointer++ = GCURX = X1;
		    *pointer   = GCURY = Y1;
		}
		break;

	    }
	}
}

/* SHOW CURSOR */
v_show_c()
{
    /* DIS_CUR will trash all registers but FP and SP */

    if ( !*INTIN && HIDE_CNT )
	HIDE_CNT = 1;		/* reset cursor to on */

    DIS_CUR();
}

/* HIDE CURSOR */

v_hide_c()
{
    HIDE_CUR();
}

/* RETURN MOUSE BUTTON STATUS */
vq_mouse_status() 
{
    REG WORD *pointer;

    *(INTOUT) = MOUSE_BT;

    pointer = CONTRL;
    *(pointer+4) = 1;
    *(pointer+2) = 1;

    pointer = PTSOUT;
    *pointer++ = GCURX;
    *pointer   = GCURY;
}

/* VALUATOR_INPUT: */
v_valuator()
{
}

/* CHOICE_INPUT: */
v_choice()
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

/* STRING_INPUT: */
v_string()
{
	WORD	i,j,k,mask;

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
	  for ( i = 0;( i < j) && ((TERM_CH & 0x00ff) != 0x000d); i++)
	  {
	    while ( GCHR_KEY() == 0 );
	    *(INTOUT+i) = TERM_CH = TERM_CH & mask;	
	  }
	  if ( (TERM_CH & 0x00ff) == 0x000d )
	    --i;
	  *(CONTRL+4) = i; 
	}
	else			/* Sample mode */
	{
	  i = 0;
	  while ( (GCHR_KEY() != 0) && (i < j) )
	    *(INTOUT+i++) = TERM_CH & mask;
	  *(CONTRL+4) = i;
	}
}
/* Return Shift, Control, Alt State */
vq_key_s()
{
	CONTRL[4] = 1;
	INTOUT[0] = GSHIFT_S();
}

/* SET_WRITING_MODE: */
vswr_mode()
{
    REG WORD wm;

    CONTRL[4] = 1;
    wm = INTIN[0] - 1;
    if ((wm > MAX_MODE) | (wm < 0))
	wm = 0;

    INTOUT[0] = (cur_work->wrt_mode = wm) + 1;
}

/* SET_INPUT_MODE: */
vsin_mode()
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

/* INQUIRE INPUT MODE: */
vqi_mode()
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

/* ST_FILLPERIMETER: */
vsf_perimeter()
{
    REG WORD h, *int_out;
    REG struct attribute *work_ptr;

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

/* ST_UD_LINE_STYLE: */
vsl_udsty()
{
    cur_work->ud_ls = *INTIN;
}

/* Set Clip Region */
s_clip()
{
    REG WORD *xy, h, rtemp;
    REG struct attribute *work_ptr;

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
}  /* End "arb_corner". */

dro_cpyfm()
{
  arb_corner(PTSIN, ULLR);
  arb_corner((PTSIN+4), ULLR);
  COPYTRAN = 0;
  COPY_RFM();
}  /* End "dr_cpyfm". */

drt_cpyfm()
{
  arb_corner(PTSIN, ULLR);
  arb_corner((PTSIN+4), ULLR);
  COPYTRAN = 0xFFFF;
  COPY_RFM();
}  /* End "dr_cpyfm". */

dr_recfl()
{
  REG WORD fi, *pts_in;

  /* Perform arbitrary corner fix-ups and invoke the rectangle fill routine */

  arb_corner(PTSIN, ULLR);
  fi = cur_work->fill_color;
  FG_BP_1 = fi & 1;
  FG_BP_2 = fi & 2;
  FG_BP_3 = fi & 4;
  FG_BP_4 = fi & 8;

  pts_in = PTSIN;
  X1 = *pts_in++;
  Y1 = *pts_in++;
  X2 = *pts_in++;
  Y2 = *pts_in;

  RECTFILL();
}  /* End "dr_recfl". */
