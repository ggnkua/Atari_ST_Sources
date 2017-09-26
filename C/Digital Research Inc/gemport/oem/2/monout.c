/**********************************************************************
 *                                                                    *
 *                              MONOUT.C                              *
 *                                                                    *
 **********************************************************************/

#include "portab.h"
#include "gsxdef.h"
#include "gsxextrn.h"

#define X_MALLOC 0x48
#define X_MFREE 0x49

EXTERN struct attribute *trap();
EXTERN	VOID	dr_recfl();

/* EXTENDED INQUIRE */
vq_extnd()
{
	REG WORD i;
	REG WORD *dp, *sp;

	dp = CONTRL;
	*(dp+2) = 6;
        *(dp+4) = 45;

	FLIP_Y = 1;

	dp = PTSOUT;

	if ( *(INTIN) == 0 ) {
	    sp = SIZ_TAB;
	    for (i=0;i<12;i++)
		*dp++ = *sp++;

	    sp = DEV_TAB;
	}

	else {
	    *dp++ = XMN_CLIP;	/* PTSOUT[0] */
	    *dp++ = YMN_CLIP;	/* PTSOUT[1] */
	    *dp++ = XMX_CLIP;	/* PTSOUT[2] */
	    *dp++ = YMX_CLIP;	/* PTSOUT[3] */

	    for (i=4; i<12; i++)
		*dp++ = 0;

	    sp = INQ_TAB;
	}

	dp = INTOUT;
	for (i=0;i<45;i++)
	    *dp++ = *sp++;

}
/* CLOSE_WORKSTATION: */
v_clswk()
{
    struct attribute *next_work;

    if (virt_work.next_work != NULLPTR) {	/* Are there VWs to close */
	cur_work = virt_work.next_work;
	do {
	    next_work = cur_work->next_work;
	    trap(X_MFREE, cur_work);
	} while ( (cur_work = next_work) );
    }

    DINIT_G();
}

/* POLYLINE: */
v_pline()
{
    REG WORD l;
    REG struct attribute *work_ptr;

    work_ptr = cur_work;
    l = work_ptr->line_index;
    LN_MASK = (l < 6) ? LINE_STYLE[l] : work_ptr->ud_ls;

    l = work_ptr->line_color;
    FG_BP_1 = (l & 1);
    FG_BP_2 = (l & 2);
    FG_BP_3 = (l & 4);
    FG_BP_4 = (l & 8);

    if (work_ptr->line_width == 1) {
	pline();
	work_ptr = cur_work;
	if ( (work_ptr->line_beg | work_ptr->line_end ) & ARROWED )
	    do_arrow();
    }
    else
	wline();
}

/* POLYMARKER: */

v_pmarker()
{

/* If this constant goes greater than 5, you must increase size of sav_points */

#define MARKSEGMAX 5

  EXTERN WORD m_dot[], m_plus[], m_star[], m_square[], m_cross[], m_dmnd[];

  static WORD *markhead[] =
  {
    m_dot, m_plus, m_star, m_square, m_cross, m_dmnd
  };

  WORD i, j, num_lines, num_vert, x_center, y_center, sav_points[10];
  WORD sav_index, sav_color, sav_width, sav_beg, sav_end, sav_clip;
  WORD *mrk_ptr, *old_ptsin, scale, num_points, *src_ptr;
  REG WORD h, *pts_in, *m_ptr;
  REG struct attribute *work_ptr;

  /* Save the current polyline attributes which will be used. */

  work_ptr = cur_work;
  sav_index = work_ptr->line_index;
  sav_color = work_ptr->line_color;
  sav_width = work_ptr->line_width;
  sav_beg = work_ptr->line_beg;
  sav_end = work_ptr->line_end;

  /* Set the appropriate polyline attributes. */

  work_ptr->line_index = 0;
  work_ptr->line_color = work_ptr->mark_color;
  work_ptr->line_width = 1;
  work_ptr->line_beg = 0;
  work_ptr->line_end = 0;
  CLIP = 1;

  scale = work_ptr->mark_scale;

  /* Copy the PTSIN pointer since we will be doing polylines */

  num_vert = CONTRL[1];
  src_ptr = old_ptsin = PTSIN;
  PTSIN = sav_points;

  /* Loop over the number of points. */

  for (i = 0; i < num_vert; i++) {

    pts_in = src_ptr;
    x_center = *pts_in++;
    y_center = *pts_in++;
    src_ptr = pts_in;

    /* Get the pointer to the appropriate marker type definition. */

    m_ptr = markhead[cur_work->mark_index];
    num_lines = *m_ptr++;

    /* Loop over the number of polylines which define the marker. */

    for (j = 0; j < num_lines; j++) {

      num_points = CONTRL[1] = *m_ptr++;	/* How many points?  Get them.	*/

      pts_in = sav_points;
      for (h = 0; h < num_points; h++ ) {
        *pts_in++ = x_center + scale*(*m_ptr++);
        *pts_in++ = y_center +	scale*(*m_ptr++);
      }  /* End for:  extract points. */

      /* Output the polyline. */

      mrk_ptr = m_ptr;		/* Save for next pass */
      v_pline();
      m_ptr = mrk_ptr;
    }  /* End for:  over the number of polylines defining the marker. */

  }  /* End for:  over marker points. */

  /* Restore the PTSIN pointer */

  PTSIN = old_ptsin;

  /* Restore the current polyline attributes. */

  work_ptr = cur_work;
  work_ptr->line_index = sav_index;
  work_ptr->line_color = sav_color;
  work_ptr->line_width = sav_width;
  work_ptr->line_beg = sav_beg;
  work_ptr->line_end = sav_end;
}

/* FILLED_AREA: */

v_fillarea()
{
  plygn();
}

/*  GDP: */
v_gdp()
{
    WORD i, ltmp_end, rtmp_end;
    REG WORD *xy_pointer;
    REG struct attribute *work_ptr;

    i = *(CONTRL+5);
    xy_pointer = PTSIN;
    work_ptr = cur_work;

    if (( i > 0 ) && ( i < 11 )) 
    {  
	i--;
	switch ( i )
	{
	    case 0:	/* GDP BAR - converted to alpha 2 RJG 12-1-84 */
		dr_recfl();
		if ( cur_work->fill_per == TRUE ) {
		    LN_MASK = 0xffff;

		    xy_pointer = PTSIN;
		    *(xy_pointer+5) = *(xy_pointer+7) = *(xy_pointer+3);
		    *(xy_pointer+3) = *(xy_pointer+9) = *(xy_pointer+1);
		    *(xy_pointer+4) = *(xy_pointer+2);
		    *(xy_pointer+6) = *(xy_pointer+8) =  *(xy_pointer);

		    *(CONTRL+1) = 5;

		    pline();
		 }
	         break;	

	    case 1: /* GDP ARC */
	    case 2: /* GDP PIE */
	      gdp_arc();
	      break;
	 	
	    case 3: /* GDP CIRCLE */
	      xc = *xy_pointer;
	      yc = *(xy_pointer+1);   
	      xrad = *(xy_pointer+4);   
	      yrad = SMUL_DIV (xrad, xsize, ysize ); 
	      del_ang = 3600;
	      beg_ang = 0;
	      end_ang = 3600;
	      clc_nsteps();
	      clc_arc();
	      break;

	    case 4: /* GDP ELLIPSE */
	      xc = *xy_pointer;
	      yc = *(xy_pointer+1);   
	      xrad = *(xy_pointer+2);
	      yrad = *(xy_pointer+3);
	      if (work_ptr->xfm_mode < 2)
		  yrad = yres - yrad;
	      del_ang = 3600;
	      beg_ang = 0;
	      end_ang = 0;
	      clc_nsteps();
	      clc_arc();
	      break;
		
	    case 5: /* GDP ELLIPTICAL ARC */
	    case 6: /* GDP ELLIPTICAL PIE */
	      gdp_ell();
	      break;

	    case 7: /* GDP Rounded Box */
	      ltmp_end = work_ptr->line_beg;
	      work_ptr->line_beg = SQUARED;
	      rtmp_end = work_ptr->line_end;
	      work_ptr->line_end = SQUARED;
	      gdp_rbox();
	      work_ptr = cur_work;
	      work_ptr->line_beg = ltmp_end;
	      work_ptr->line_end = rtmp_end;
	      break;

	    case 8: /* GDP Rounded Filled Box */
	      gdp_rbox();
              break;

	    case 9: /* GDP Justified Text */
	      d_justified();
              break;
	    }
	}
}    	

/* INQUIRE CURRENT POLYLINE ATTRIBUTES */
vql_attr()
{
    REG WORD *pointer;
    REG struct attribute *work_ptr;

    pointer = INTOUT;
    work_ptr = cur_work;
    *pointer++ = work_ptr->line_index + 1;
    *pointer++ = REV_MAP_COL[ work_ptr->line_color ];
    *pointer = WRT_MODE + 1;

    pointer = PTSOUT;
    *pointer++ = work_ptr->line_width;
    *pointer = 0;

    pointer = CONTRL;
    *(pointer+2) = 1;
    *(pointer+4) = 3;
}

/* INQUIRE CURRENT Polymarker ATTRIBUTES */
vqm_attr()
{
    REG WORD *pointer;
    REG struct attribute *work_ptr;

    pointer = INTOUT;
    work_ptr = cur_work;
    *pointer++ = work_ptr->mark_index;
    *pointer++ = REV_MAP_COL[ work_ptr->mark_color ];
    *pointer = WRT_MODE + 1;

    pointer = PTSOUT;
    *pointer++ = 0;
    *pointer = work_ptr->mark_height;

    pointer = CONTRL;
    *(pointer+4) = 3;
    *(pointer+2) = 1;
    FLIP_Y = 1;
}

/* INQUIRE CURRENT Fill Area ATTRIBUTES */
vqf_attr()
{
    REG WORD *pointer;
    REG struct attribute *work_ptr;

    pointer = INTOUT;
    work_ptr = cur_work;
    *pointer++ = work_ptr->fill_style;
    *pointer++ = REV_MAP_COL[ work_ptr->fill_color ];
    *pointer++ = work_ptr->fill_index + 1;
    *pointer++ = WRT_MODE + 1;
    *pointer = work_ptr->fill_per;

    *(CONTRL+4) = 5;
}	

pline()
{
	WORD	i, *old_pointer;
	REG WORD *pointer;

	LSTLIN = TRUE;
	old_pointer = PTSIN;
	for (i = (*(CONTRL+1)-1 );i > 0;i--) {
	    if (i == 1)	      
	        LSTLIN = FALSE;

            pointer = old_pointer;
	    X1 = *pointer++;
	    Y1 = *pointer++;	
            X2 = *pointer;
	    Y2 = *(pointer+1);
	    old_pointer = pointer;
	    if ( CLIP ) {
	        if ( clip_line() )
		    ABLINE();
	    }
	    else	
	        ABLINE();
	}				
}

	WORD
clip_line()
{
	WORD	deltax, deltay, x1y1_clip_flag, x2y2_clip_flag, line_clip_flag;
	REG WORD *x,*y;

	while (( x1y1_clip_flag = code( X1, Y1 )) | 
		( x2y2_clip_flag = code( X2, Y2)))
	{
	    if ( ( x1y1_clip_flag & x2y2_clip_flag ))
		return( FALSE );
	    if ( x1y1_clip_flag )
	    {
		line_clip_flag = x1y1_clip_flag;
		x = &X1; y = &Y1;
	    }
  	    else
	    {
		line_clip_flag = x2y2_clip_flag;
		x = &X2; y = &Y2;
	    }
	    deltax = X2 - X1; deltay = Y2 - Y1;
	    if ( line_clip_flag & 1 )	/* left ? */
	    {
		*y = Y1 + SMUL_DIV( deltay, (XMN_CLIP-X1), deltax );
		*x = XMN_CLIP;
	    }
	    else if ( line_clip_flag & 2 )	/* right ? */
	    {
		*y = Y1 + SMUL_DIV( deltay, (XMX_CLIP-X1), deltax );
		*x = XMX_CLIP;
	    }
	    else if ( line_clip_flag & 4 )	/* top ? */
	    {
		*x = X1 + SMUL_DIV( deltax, (YMN_CLIP-Y1), deltay );
		*y = YMN_CLIP;
	    }
	    else if ( line_clip_flag & 8 )	/* bottom ? */
	    {
		*x = X1 + SMUL_DIV( deltax, (YMX_CLIP-Y1), deltay );
		*y = YMX_CLIP;
	    }
	}
	return( TRUE );		/* segment now cliped  */
}

	WORD
code( x, y )
	WORD	x,y;
{
	WORD	clip_flag;
	clip_flag = 0;
	if ( x < XMN_CLIP )
	    clip_flag = 1;
	else if ( x > XMX_CLIP )
	    clip_flag = 2;
	if ( y < YMN_CLIP )
	    clip_flag +=4;
	else if ( y > YMX_CLIP )
	    clip_flag +=8;
	return ( clip_flag );
}

plygn()	
{
	REG WORD *pointer, i, k, cnt;
	WORD j;

	i = cur_work->fill_color;
	FG_BP_1 = (i & 1);
	FG_BP_2 = (i & 2);
	FG_BP_3 = (i & 4);
	FG_BP_4 = (i & 8);
	LSTLIN  = FALSE;

	pointer = PTSIN;
	pointer++;

	fill_maxy = fill_miny = *pointer++;
	pointer++;

	for (i = (*(CONTRL+1)-1);i > 0;i--)
	{
	  k = *pointer++;
	  pointer++;
	  if ( k < fill_miny )
	    fill_miny = k;
	  else if ( k > fill_maxy )
	    fill_maxy = k;
	}
	if ( CLIP )
	{
	    if ( fill_miny < YMN_CLIP )		
	    {
	  	if ( fill_maxy >= YMN_CLIP ) {	/* plygon starts before clip */
		    fill_miny = YMN_CLIP-1;	/* plygon partial overlap */
		    if (fill_miny < 1)
			fill_miny = 1;
		}
		else
		    return;		       	/* plygon entirely before clip */
	    }
	    if ( fill_maxy > YMX_CLIP )
	    {
		if ( fill_miny <= YMX_CLIP )	/* plygon ends after clip */
		    fill_maxy = YMX_CLIP;	/* plygon partial overlap */
		else
		    return;			/* plygon entirely after clip */ 
	    }
	}
	k = *(CONTRL+1) * 2;
	pointer = PTSIN;
	*(pointer+k) = *pointer;
	*(pointer+k+1) = *(pointer+1);
	for (Y1 = fill_maxy; Y1 > fill_miny; Y1--)
	{
	    fil_intersect = 0;
	    CLC_FLIT();
	}
	if ( cur_work->fill_per == TRUE )
	{
	    LN_MASK = 0xffff;
	    (*(CONTRL+1))++;
	    pline();
	}
}

	VOID
gdp_rbox()
{
	REG WORD i, j;
	WORD rdeltax, rdeltay;
	REG WORD *pointer;
	REG struct attribute *work_ptr;

        arb_corner(pointer, LLUR);

	pointer = PTSIN;
	X1 = *pointer++;
	Y1 = *pointer++;
	X2 = *pointer++;
	Y2 = *pointer;

	rdeltax = (X2 - X1)/2;
	rdeltay = (Y1 - Y2)/2;

	xrad = xres >> 6;
	if ( xrad > rdeltax )
	    xrad = rdeltax;

	yrad = SMUL_DIV( xrad, xsize, ysize );
	if ( yrad > rdeltay )
	    yrad = rdeltay;

	pointer = PTSIN;
	*pointer++ = 0;
	*pointer++ = yrad;
	*pointer++ = SMUL_DIV ( Icos(675), xrad, 32767 ) ;
	*pointer++ = SMUL_DIV ( Isin(675), yrad, 32767 ) ;
	*pointer++ = SMUL_DIV ( Icos(450), xrad, 32767 ) ;
	*pointer++ = SMUL_DIV ( Isin(450), yrad, 32767 ) ;
	*pointer++ = SMUL_DIV ( Icos(225), xrad, 32767 ) ;
	*pointer++ = SMUL_DIV ( Isin(225), yrad, 32767 ) ;
	*pointer++ = xrad;
	*pointer = 0;

	pointer = PTSIN;
	xc = X2 - xrad; yc = Y1 - yrad;
	j = 10;
	for ( i = 9; i >= 0 ; i-- )
	{ 
	    *(pointer+j+1) = yc + *(pointer+i--);
	    *(pointer+j) = xc + *(pointer+i);
	    j += 2;
	}
	xc = X1 + xrad; 
	j = 20;
	for ( i = 0; i < 10; i++ )
	{ 
	    *(pointer+j++) = xc - *(pointer+i++);
	    *(pointer+j++) = yc + *(pointer+i);
	}
	yc = Y2 + yrad;
	j = 30;
	for ( i = 9; i >= 0; i-- )
	{ 
	    *(pointer+j+1) = yc - *(pointer+i--);
	    *(pointer+j) = xc - *(pointer+i);
	    j += 2;
	}
	xc = X2 - xrad;
	j = 0;
	for ( i = 0; i < 10; i++ )
	{ 
	    *(pointer+j++) = xc + *(pointer+i++);
	    *(pointer+j++) = yc - *(pointer+i);
	}
	*(pointer+40) = *pointer;
	*(pointer+41) = *(pointer+1); 

	pointer = CONTRL;
	*(pointer+1) = 21;
    	if (*(pointer+5) == 8) 
	{
	  work_ptr = cur_work;
	  i = work_ptr->line_index;
	  LN_MASK = (i < 6) ? LINE_STYL[i] : work_ptr->ud_ls;
	  i = work_ptr->line_color;
	  FG_BP_1 = (i & 1);
	  FG_BP_2 = (i & 2);
	  FG_BP_3 = (i & 4);
	  FG_BP_4 = (i & 8);

	  if (work_ptr->line_width == 1) {
	      pline();
	  }
	  else
	      wline();
	}
    	else
	  plygn();

	return;
}
	
	VOID
gdp_arc()
{
	REG WORD *pointer;

	pointer = INTIN;

	beg_ang = *pointer++;
	end_ang = *pointer;
	del_ang = end_ang - beg_ang;
	if ( del_ang < 0 )
	    del_ang += 3600; 

	pointer = PTSIN;
	xrad = *(pointer+6);   
	yrad = SMUL_DIV ( xrad, xsize, ysize );
	clc_nsteps();
	n_steps = SMUL_DIV ( del_ang, n_steps, 3600 );
	if ( n_steps == 0 )
	  return;
	xc = *pointer++;
	yc = *pointer;   
	clc_arc();
	return;
}

clc_nsteps()
{
	if ( xrad > yrad )
	    n_steps = xrad;
	else
	    n_steps = yrad;
	n_steps = n_steps >> 2;
	if ( n_steps < 16 )
	    n_steps = 16;
	else
	{
	    if ( n_steps > MAX_ARC_CT )
	        n_steps = MAX_ARC_CT;
	}
	return;
}

gdp_ell()
{
	REG WORD *pointer;

	pointer = INTIN;
	beg_ang = *pointer++;
	end_ang = *pointer;
	del_ang = end_ang - beg_ang;
	if ( del_ang < 0 )
	    del_ang += 3600;

	pointer = PTSIN;
	xc = *pointer++;
	yc = *pointer++;   
	xrad = *pointer++;
	yrad = *pointer;
	if (cur_work->xfm_mode < 2)
	    yrad = yres - yrad;
	clc_nsteps();	
	n_steps = SMUL_DIV ( del_ang, n_steps, 3600 );
	if ( n_steps == 0 )
	  return;
	clc_arc();
	return;
}

	VOID
clc_arc()
{
	WORD	i,j;
	REG WORD *cntl_ptr, *xy_ptr;

	if ( CLIP )
	{
	    if ( (( xc + xrad ) < XMN_CLIP) || ((xc - xrad) > XMX_CLIP) ||
			((yc + yrad ) < YMN_CLIP) || ((yc - yrad) > YMX_CLIP))
		return;
	}
	start = angle = beg_ang ;	
    	i = j = 0 ;
    	Calc_pts(j);
	for ( i = 1; i < n_steps; i++ )
    	{
	  j += 2;
	  angle = SMUL_DIV( del_ang, i , n_steps ) + start;
          Calc_pts(j);
        }
	j += 2;
    	i = n_steps ;
    	angle = end_ang ;
    	Calc_pts(j);

/*----------------------------------------------------------------------*/
/* If pie wedge	draw to center and then close. If arc or circle, do 	*/
/* nothing because loop should close circle.				*/
/*----------------------------------------------------------------------*/

	cntl_ptr = CONTRL;
	xy_ptr = PTSIN;

        *(cntl_ptr+1) = n_steps + 1 ;	/* since loop in Clc_arc starts at 0 */
	if ((*(cntl_ptr+5) == 3)||(*(cntl_ptr+5) == 7)) /* pie wedge */
	{
	  n_steps++;
	  j +=2;
	  *(xy_ptr+j) = xc; *(xy_ptr+j+1) = yc;
	  *(cntl_ptr+1) = n_steps+1;
	}
    	if ((*(cntl_ptr+5) == 2) || ( *(cntl_ptr+5) == 6 )) /* open arc */
	  v_pline();

    	else
	  plygn();
}

	VOID
Calc_pts(j) 
	WORD	j;
{
	WORD	k;
	REG WORD *pointer;

	pointer = PTSIN;
	k = SMUL_DIV ( Icos(angle), xrad, 32767 ) + xc ;
    	*(pointer+j) = k;
        k = yc - SMUL_DIV ( Isin( angle), yrad, 32767 ) ; /*FOR RASTER CORDS. */
    	*(pointer+j+1) = k;
}

st_fl_ptr()
{
    REG WORD fi, pm, *pp;
    REG struct attribute *work_ptr;

    work_ptr = cur_work;
    fi = work_ptr->fill_index;
    pm = 0;
    switch ( work_ptr->fill_style ) {
	case 0:
	    pp = &HOLLOW;
	    break;

	case 1:
	    pp = &SOLID;
	    break;

	case 2:
	    if ( fi < 8) {
		pm = DITHRMSK;
		pp = &DITHER[ fi * (pm+1) ];
	    }
	    else {
		pm = OEMMSKPAT;
		pp = &OEMPAT[ (fi-8) * (pm+1) ];
	    }
	    break;
	case 3:
	    if (fi < 6) {
		pm = HAT_0_MSK;
		pp = &HATCH0[ fi * (pm+1) ];
	    }
	    else {
		pm = HAT_1_MSK;
		pp = &HATCH1[ (fi-6) * (pm+1) ];
	    }
	    break;
	case 4:
	    pm = 0x000f;
	    pp = &work_ptr->ud_patrn[0];
	    break;
	}
    work_ptr->patptr = pp;
    work_ptr->patmsk = pm;
}

/* Moved the circle DDA code that was in vsl_width() here. */

cir_dda()
{
    WORD low, high, i, j;

    REG WORD *xptr, *yptr, x, y, d;

    /* Calculate the number of vertical pixels required. */

    d = cur_work->line_width;
    num_qc_lines = (d * xsize/ysize)/2 + 1;

    /* Initialize the circle DDA.  "y" is set to the radius. */

    line_cw = d;
    y = (d + 1)/2;
    x = 0;
    d = 3 - 2*y;

    xptr = &q_circle[x];
    yptr = &q_circle[y];

    /* Do an octant, starting at north.  The values for the next octant */
    /* (clockwise) will be filled by transposing x and y.               */

    while (x < y) {
	*yptr = x;
	*xptr = y;

	if (d < 0)
	    d = d + 4*x + 6;
	else {
	    d = d + 4*(x - y) + 10;
	    yptr--;
	    y--;
	}
	xptr++;
	x++;
    }

    if (x == y)
	q_circle[x] = x;

    /* Fake a pixel averaging when converting to non-1:1 aspect ratio. */

    x = 0;


    yptr = q_circle;
    for (i = 0; i < num_qc_lines; i++) {
	y = ((2*i + 1)*ysize/xsize)/2;
	d = 0;

	xptr = &q_circle[x];
	for (j = x; j <= y; j++)
	    d += *xptr++;

	*yptr++ = d/(y - x + 1);
	x = y + 1;
    }  /* End for loop. */
}

#define ABS(x) ((x) >= 0 ? (x) : -(x))

wline()
{
  WORD i, k, box[10];	/* box two high to close polygon */

  WORD numpts, wx1, wy1, wx2, wy2, vx, vy, tinv;

  WORD *old_ptsin, *src_ptr;

  REG WORD *pointer, x, y, d, d2;
  REG struct attribute *work_ptr;

  /* Don't attempt wide lining on a degenerate polyline */

  if ( (numpts = *(CONTRL+1)) < 2)
    return;

  work_ptr = cur_work;
  if (work_ptr->line_width != line_cw)
    cir_dda();

  /* If the ends are arrowed, output them. */

  if ((work_ptr->line_beg | work_ptr->line_end) & ARROWED)
    do_arrow();

  s_fa_attr();

  /* Initialize the starting point for the loop. */

  old_ptsin = pointer = PTSIN;
  wx1 = *pointer++;
  wy1 = *pointer++;
  src_ptr = pointer;

  /* If the end style for the first point is not squared, output a circle. */

  if (s_begsty != SQUARED)
    do_circ(wx1, wy1);

  /* Loop over the number of points passed in. */

  for (i = 1; i < numpts; i++)
  {
    /* Get the ending point for the line segment and the vector from the */
    /* start to the end of the segment.                                  */

    pointer = src_ptr;
    wx2 = *pointer++;
    wy2 = *pointer++;
    src_ptr = pointer;

    vx = wx2 - wx1;
    vy = wy2 - wy1;

    /* Ignore lines of zero length. */

    if ( (vx == 0) && (vy == 0) )
      continue;

    /* Calculate offsets to fatten the line.  If the line segment is */
    /* horizontal or vertical, do it the simple way.                 */

    if (vx == 0)
    {
      vx = q_circle[0];
      vy = 0;
    }  /* End if:  vertical. */

    else if (vy == 0)
    {
      vx = 0;
      vy = num_qc_lines - 1;
    }  /* End else if:  horizontal. */

    else
    {
      /* Find the offsets in x and y for a point perpendicular to the line */
      /* segment at the appropriate distance.                              */

      k = SMUL_DIV(-vy, ysize, xsize);
      vy = SMUL_DIV(vx, xsize, ysize);
      vx = k;
      perp_off(&vx, &vy);
    }  /* End else:  neither horizontal nor vertical. */

    /* Prepare the control and points parameters for the polygon call. */

    *(CONTRL+1) = 4;

    PTSIN = pointer = box;

    x = wx1;     y = wy1;
    d = vx;      d2 = vy;

    *pointer++ = x + d;
    *pointer++ = y + d2;
    *pointer++ = x - d;
    *pointer++ = y - d2;

    x = wx2;     y = wy2;

    *pointer++ = x - d;
    *pointer++ = y - d2;
    *pointer++ = x + d;
    *pointer   = y + d2;

    plygn();

    /* restore the PTSIN pointer */

    PTSIN = old_ptsin;

    /* If the terminal point of the line segment is an internal joint, */
    /* output a filled circle.                                         */

    if ( (i < numpts - 1) || (s_endsty != SQUARED) )
      do_circ(wx2, wy2);

    /* The line segment end point becomes the starting point for the next */
    /* line segment.                                                      */

    wx1 = wx2;
    wy1 = wy2;
  }  /* End for:  over number of points. */

  /* Restore the attribute environment. */

  r_fa_attr();
}  /* End "wline". */


perp_off(px, py)
WORD *px, *py;
{
  REG WORD *vx, *vy, *pcircle, u, v;
  WORD i, x, y, quad, magnitude, min_val, x_val, y_val;

  vx = px;
  vy = py;

  pcircle = q_circle;

  /* Mirror transform the vector so that it is in the first quadrant. */

  if (*vx >= 0)
    quad = (*vy >= 0) ? 1 : 4;
  else
    quad = (*vy >= 0) ? 2 : 3;

  quad_xform(quad, *vx, *vy, &x, &y);

  /* Traverse the circle in a dda-like manner and find the coordinate pair   */
  /* (u, v) such that the magnitude of (u*y - v*x) is minimized.  In case of */
  /* a tie, choose the value which causes (u - v) to be minimized.  If not   */
  /* possible, do something.                                                 */

  min_val = 32767;
  u = *pcircle;
  v = 0;
  FOREVER
  {
    /* Check for new minimum, same minimum, or finished. */
    if ( ( (magnitude = ABS(u*y - v*x)) < min_val ) ||
         ( (magnitude == min_val) && (ABS(x_val - y_val) > ABS(u - v) ) ) )
    {
      min_val = magnitude;
      x_val = u;
      y_val = v;
    }  /* End if:  new minimum. */

    else
      break;

    /* Step to the next pixel. */
    if (v == num_qc_lines - 1)
    {
      if (u == 1)
        break;
      else
        u--;
    }  /* End if:  doing top row. */

    else
    {
      if (pcircle[v + 1] >= u - 1)
      {
        v++;
        u = pcircle[v];
      }  /* End if:  do next row up. */
      else
      {
        u--;
      }  /* End else:  continue on row. */
    }  /* End else:  other than top row. */
  }  /* End FOREVER loop. */

  /* Transform the solution according to the quadrant. */

  quad_xform(quad, x_val, y_val, vx, vy);
}  /* End "perp_off". */


quad_xform(quad, x, y, tx, ty)
int quad, x, y, *tx, *ty;
{
  switch (quad)
  {
    case 1:
    case 4:
      *tx = x;
      break;

    case 2:
    case 3:
      *tx = -x;
      break;
  }  /* End switch. */

  switch (quad)
  {
    case 1:
    case 2:
      *ty = y;
      break;

    case 3:
    case 4:
      *ty = -y;
      break;
  }  /* End switch. */
}  /* End "quad_xform". */


do_circ(cx, cy)
WORD cx, cy;
{
  WORD k;
  REG WORD *pointer;

  /* Only perform the act if the circle has radius. */

  if (num_qc_lines > 0)
  {
    /* Do the horizontal line through the center of the circle. */

    pointer = q_circle;
    X1 = cx - *pointer;
    X2 = cx + *pointer;
    Y1 = Y2 = cy;
    if (clip_line() )
      ABLINE();

    /* Do the upper and lower semi-circles. */

    for (k = 1; k < num_qc_lines; k++)
    {
      /* Upper semi-circle. */

      pointer = &q_circle[k];
      X1 = cx - *pointer;
      X2 = cx + *pointer;
      Y1 = Y2 = cy - k;
      if (clip_line() ) {
        ABLINE();
        pointer = &q_circle[k];
      }

      /* Lower semi-circle. */

      X1 = cx - *pointer;
      X2 = cx + *pointer;
      Y1 = Y2 = cy + k;
      if (clip_line() )
        ABLINE();
    }  /* End for. */
  }  /* End if:  circle has positive radius. */
}  /* End "do_circ". */


s_fa_attr()
{
  REG struct attribute *work_ptr;

  /* Set up the fill area attribute environment. */

  work_ptr = cur_work;

  LN_MASK = LINE_STYL[0];
  s_fil_col = work_ptr->fill_color;
  work_ptr->fill_color = work_ptr->line_color;
  s_fill_per = work_ptr->fill_per;
  work_ptr->fill_per = TRUE;
  patptr = &SOLID;
  patmsk = 0;
  s_begsty = work_ptr->line_beg;
  s_endsty = work_ptr->line_end;
  work_ptr->line_beg = SQUARED;
  work_ptr->line_end = SQUARED;
}  /* End "s_fa_attr". */


r_fa_attr()
{
  REG struct attribute *work_ptr;

  /* Restore the fill area attribute environment. */

  work_ptr = cur_work;

  work_ptr->fill_color = s_fil_col;
  work_ptr->fill_per = s_fill_per;
  work_ptr->line_beg = s_begsty;
  work_ptr->line_end = s_endsty;
}  /* End "r_fa_attr". */

do_arrow()
{
  WORD x_start, y_start, new_x_start, new_y_start;
  REG WORD *pts_in;

  /* Set up the attribute environment. */

  s_fa_attr();

  /* Function "arrow" will alter the end of the line segment.  Save the */
  /* starting point of the polyline in case two calls to "arrow" are    */
  /* necessary.                                                         */

  pts_in = PTSIN;
  new_x_start = x_start = *pts_in;
  new_y_start = y_start = *(pts_in+1);

  if (s_begsty & ARROWED) {
    arrow(pts_in, 2);
    pts_in = PTSIN;		/* arrow calls plygn which trashes regs */
    new_x_start = *pts_in;
    new_y_start = *(pts_in+1);
  }  /* End if:  beginning point is arrowed. */

  if (s_endsty & ARROWED)
  {
    *pts_in = x_start;
    *(pts_in+1) = y_start;
    arrow((pts_in+2**(CONTRL+1) - 2), -2);
    pts_in = PTSIN;		/* arrow calls plygn which trashes regs */
    *pts_in = new_x_start;
    *(pts_in+1) = new_y_start;
  }  /* End if:  ending point is arrowed. */

  /* Restore the attribute environment. */

  r_fa_attr();
}  /* End "do_arrow". */

arrow(xy, inc)
WORD *xy, inc;
{
  WORD arrow_len, arrow_wid, line_len;
  WORD *xybeg, sav_contrl, triangle[8];	/* triangle 2 high to close polygon */
  WORD dx, dy;
  WORD base_x, base_y, ht_x, ht_y;
  WORD *old_ptsin;
  REG WORD *ptr1, *ptr2, temp, i;

  /* Set up the arrow-head length and width as a function of line width. */

  temp = cur_work->line_width;
  arrow_wid = (arrow_len = (temp == 1) ? 8 : 3*temp - 1)/2;

  /* Initialize the beginning pointer. */

  xybeg = ptr1 = ptr2 = xy;

  /* Find the first point which is not so close to the end point that it */
  /* will be obscured by the arrowhead.                                  */

  temp = *(CONTRL+1);
  for (i = 1; i < temp; i++)
  {
    /* Find the deltas between the next point and the end point.  Transform */
    /* to a space such that the aspect ratio is uniform and the x axis      */
    /* distance is preserved.                                               */

    ptr1 += inc;
    dx = *ptr2 - *ptr1;
    dy = SMUL_DIV(*(ptr2 + 1) - *(ptr1 + 1), ysize, xsize);

    /* Get the length of the vector connecting the point with the end point. */
    /* If the vector is of sufficient length, the search is over.            */

    if ( (line_len = vec_len(ABS(dx), ABS(dy))) >= arrow_len)
      break;
  }  /* End for:  over i. */

  /* Set xybeg to the point we found */

  xybeg = ptr1;

  /* If the longest vector is insufficiently long, don't draw an arrow. */

  if (line_len < arrow_len)
    return;

  /* Rotate the arrow-head height and base vectors.  Perform calculations */
  /* in 1000x space.                                                      */

  ht_x = SMUL_DIV(arrow_len, SMUL_DIV(dx, 1000, line_len), 1000);
  ht_y = SMUL_DIV(arrow_len, SMUL_DIV(dy, 1000, line_len), 1000);
  base_x = SMUL_DIV(arrow_wid, SMUL_DIV(dy, -1000, line_len), 1000);
  base_y = SMUL_DIV(arrow_wid, SMUL_DIV(dx, 1000, line_len), 1000);

  /* Transform the y offsets back to the correct aspect ratio space. */

  ht_y = SMUL_DIV(ht_y, xsize, ysize);
  base_y = SMUL_DIV(base_y, xsize, ysize);

  /* Save the vertice count */

  ptr1 = CONTRL;
  sav_contrl = *(ptr1+1);

  /* Build a polygon to send to plygn.  Build into a local array first since */
  /* xy will probably be pointing to the PTSIN array.                        */

  *(ptr1+1) = 3;
  ptr1 = triangle;
  ptr2 = xy;
  *ptr1 = *ptr2 + base_x - ht_x;
  *(ptr1+1) = *(ptr2 + 1) + base_y - ht_y;
  *(ptr1+2) = *ptr2 - base_x - ht_x;
  *(ptr1+3) = *(ptr2 + 1) - base_y - ht_y;
  *(ptr1+4) = *ptr2;
  *(ptr1+5) = *(ptr2 + 1);

  old_ptsin = PTSIN;
  PTSIN = ptr1;
  plygn();
  PTSIN = old_ptsin;

  /* Restore the vertex count. */

  *(CONTRL+1) = sav_contrl;

  /* Adjust the end point and all points skipped. */

  ptr1 = xy;
  ptr2 = xybeg;
  *ptr1 -= ht_x;
  *(ptr1 + 1) -= ht_y;

  temp = inc;
  while ( (ptr2 -= temp) != ptr1)
  {
    *ptr2 = *ptr1;
    *(ptr2 + 1) = *(ptr1 + 1);
  }  /* End while. */
}  /* End "arrow". */

init_wk()
{
    REG WORD l;
    REG WORD *pointer, *src_ptr;
    REG struct attribute *work_ptr;

    pointer = INTIN;
    pointer++;
    work_ptr = cur_work;

    l = *pointer++;			/* INTIN[1] */
    work_ptr->line_index = ((l > MX_LN_STYLE) || (l < 0)) ?  0 : l-1;

    l = *pointer++;			/* INTIN[2] */
    if ((l >= DEV_TAB[13]) || (l < 0))
	l = 1;
    work_ptr->line_color = MAP_COL[l];

    l = *pointer++ - 1;			/* INTIN[3] */
    work_ptr->mark_index = ((l>=MAX_MARK_INDEX) || (l<0)) ? 2 : l;

    l = *pointer++;			/* INTIN[4] */
    if ((l >= DEV_TAB[13]) || (l < 0))
	l = 1;
    work_ptr->mark_color = MAP_COL[l];

    /* You always get the default font */

    pointer++;			/* INTIN[5] */

    l = *pointer++;		/* INTIN[6] */
    if ((l >= DEV_TAB[13]) || (l < 0))
	l = 1;
    work_ptr->text_color = MAP_COL[ l ];

    work_ptr->mark_height = DEF_MKHT;
    work_ptr->mark_scale = 1;

    l = *pointer++;		/* INTIN[7] */
    work_ptr->fill_style = ((l > MX_FIL_STYLE) || (l < 0)) ?  0 : l;

    l = *pointer++;		/* INTIN[8] */
    if (work_ptr->fill_style == 2)
	l = ((l > MX_FIL_PAT_INDEX) || (l < 1)) ? 1 : l;
    else
	l = ((l > MX_FIL_HAT_INDEX) || (l < 1)) ? 1 : l;
    work_ptr->fill_index = l;

    l = *pointer++;		/* INTIN[9] */
    if ((l >= DEV_TAB[13]) || (l < 0))
	l = 1;
    work_ptr->fill_color = MAP_COL[l];

    work_ptr->xfm_mode = *pointer;	/* INTIN[10] */

    st_fl_ptr();			/* set the fill pattern as requested */

    work_ptr->wrt_mode = 0;	/* default is replace mode */
    work_ptr->line_width = DEF_LWID;
    work_ptr->line_beg = 0;	/* default to squared ends */
    work_ptr->line_end = 0;

    work_ptr->fill_per = TRUE;

    work_ptr->xmn_clip = 0;
    work_ptr->ymn_clip = 0;
    work_ptr->xmx_clip = DEV_TAB[0];
    work_ptr->ymx_clip = DEV_TAB[1];
    work_ptr->clip = 0;

    work_ptr->cur_font = def_font;

    work_ptr->loaded_fonts = NULLPTR;

    work_ptr->scrpt2 = scrtsiz;
    work_ptr->scrtchp = deftxbuf;

    work_ptr->num_fonts = ini_font_count;

    work_ptr->style = 0;	/* reset special effects */
    work_ptr->scaled = FALSE;
    work_ptr->h_align = 0;
    work_ptr->v_align = 0;
    work_ptr->chup = 0;
    work_ptr->pts_mode = FALSE;

    /* move default user defined pattern to RAM */

    src_ptr = ROM_UD_PATRN;
    pointer = &work_ptr->ud_patrn[0];

    for (l=0; l<16; l++)
	*pointer++ = *src_ptr++;

    work_ptr->multifill = 0;

    work_ptr->ud_ls = LINE_STYLE[0];

    pointer = CONTRL;
    *(pointer+2) = 6;
    *(pointer+4) = 45;

    pointer = INTOUT;
    src_ptr = DEV_TAB;
    for (l=0;l<45;l++)
	*pointer++ = *src_ptr++;

    pointer = PTSOUT;
    src_ptr = SIZ_TAB;
    for (l=0;l<12;l++)
	*pointer++ = *src_ptr++;

    FLIP_Y = 1;
}

d_opnvwk()
{
    REG WORD handle;
    REG struct attribute *new_work, *work_ptr, *temp;

    /* Allocate the memory for a virtual workstation.  If none available, exit */

    new_work = trap(X_MALLOC, (LONG) (sizeof(struct attribute)) );

    if( new_work == NULLPTR) {		/* No work available */
	CONTRL[6] = 0;
	return;
    }

    /* Now find a free handle */

    handle = 1;
    work_ptr = &virt_work;

    while (handle == work_ptr->handle) {
	handle++;
	if (work_ptr->next_work == NULLPTR)
	    break;
	work_ptr = work_ptr->next_work;
    }

    /* Empty slot found, Insert the workstation here */

    if (work_ptr->next_work == NULLPTR) {	/* Add at end of chain */
	cur_work = work_ptr->next_work = new_work;
	new_work->next_work = NULLPTR;
    }

    else {					/* Add in middle of chain */
	temp = work_ptr->next_work;
	cur_work = work_ptr->next_work = new_work;
	new_work->next_work = temp;
    }

    new_work->handle = CONTRL[6] = handle;
    init_wk();
}

d_clsvwk()
{
    REG struct attribute *work_ptr;
    REG WORD handle;

    /* cur_work points to workstation to deallocate, find who points to me */

    handle = cur_work->handle;

    if(handle == 1)		/* Can't close physical this way */
	return;

    for(work_ptr = &virt_work; handle != work_ptr->next_work->handle;
	work_ptr = work_ptr->next_work)
    ;

    work_ptr->next_work = cur_work->next_work;
    trap(X_MFREE, cur_work);
}

dsf_udpat()
{
    REG WORD *sp, *dp, i, count;
    REG struct attribute *work_ptr;

    work_ptr = cur_work;
    count = CONTRL[3];

    if (count == 16)
	work_ptr->multifill = 0;	/* Single Plane Pattern */
    else if (count == (INQ_TAB[4]*16))
	work_ptr->multifill = 1;	/* Valid Multi-plane pattern */
    else
	return(0);			/* Invalid pattern, return */

    sp = INTIN;
    dp = &work_ptr->ud_patrn[0];
    for (i=0; i<count; i++)
	*dp++ = *sp++;
}
