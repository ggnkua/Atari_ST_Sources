/*************************************************************
 * Copyright 1999 by Caldera Thin Clients, Inc.              *
 * This software is licensed under the GNU Public License.   *
 * Please see LICENSE.TXT for further information.           *
 *************************************************************/
#include <portab.h>
#include <machine.h>
#include <rclib.h>
#if GEMDOS
#if TURBO_C
#include <aes.h>
#include <vdi.h>
#endif
#else
#include <obdefs.h>
#include <gembind.h>
#include <vdibind.h>
#endif
#include "rcs.h"
#include "rcsdefs.h"
#include "rcsiext.h"
#include "rcsimain.h"
#include "rcslib.h"
#include "rcsintf.h"
#include "rcsvdi.h"
#include "rcsiedit.h"

EXTERN	GRECT	dispc_area;
EXTERN  WORD	ptsin[];
EXTERN  UWORD	color_map[];

GLOBAL	WORD	scale;	/*indicating if size is changed, image will be scaled,
						keeped/croped, or cleared*/
WORD    stemp[256], dtemp[256];
GRECT   orign_area;

VOID del_img(BOOLEAN mouse, WORD which)
{
	UWORD	t2pxy[4];

	t2pxy[0] = selec_area.g_x;
	t2pxy[1] = selec_area.g_y;
	t2pxy[2] = selec_area.g_x + selec_area.g_w - 1;
	t2pxy[3] = selec_area.g_y + selec_area.g_h - 1;
/*	gsx_attr(FALSE, 1, WHITE);	*/
	vsf_color(gl_handle, WHITE);
	if (which != 2)
	{
		hold_to_undo();
		if (mouse)
			graf_mouse(M_OFF, 0x0L);
		if (!gl_isicon)
			rubrec_off();
		gsx_sclip(&dat_img);
		v_bar(gl_handle, (WORD *)t2pxy);
		if (which == 1)
			return;
	}
	if (gl_isicon)  	/*mask area*/
	{
		if(which != 1)
		{
			t2pxy[0] += deltax;
			t2pxy[1] += deltay;
			t2pxy[2] += deltax;
			t2pxy[3] += deltay;
			rubrec_off();
			gsx_sclip(&mas_img);
			v_bar(gl_handle,(WORD *)t2pxy);
		}
		if (which != 3)
			return;
    }
	save_img();
	graf_mouse(M_ON, 0x0L);
}

VOID clear_clipb(VOID)
{
    GRECT  temp_area;
    if (orign_area.g_w && orign_area.g_h)	/*clear the old stuff in clip board*/
    {
		orign_area.g_x -= 1;	/*include the outline*/
		orign_area.g_y -= 1;
		orign_area.g_w += 2;
		orign_area.g_h += 2;
		gsx_sclip(&orign_area);
		rast_op(0, &orign_area, &scrn_mfdb, &orign_area, &scrn_mfdb);
		if (orign_area.g_w > dispc_area.g_w)
		{
			objc_xywh(ad_itool, CLIPBOX, &temp_area);
			gsx_sclip(&temp_area);
			objc_draw((OBJECT FAR *)ad_itool, CLIPBOX, 1, temp_area.g_x, temp_area.g_y, 
			temp_area.g_w, temp_area.g_h);
		}
		orign_area.g_w = orign_area.g_h = 0;
	}
}

/* this routine draw an rectangle outline specified by area	*/
VOID draw_outline(GRECT *area)
{
	WORD   mode, colr;

	graf_mouse(M_OFF, 0x0L);
	mode = gl_mode;
	colr = gl_lcolor;
	gsx_attr(FALSE, 1, BLACK);
	gsx_bxpts(area);  /*draw an outline of the clipping content*/
	v_pline(gl_handle, 5, &ptsin[0]);
	gsx_attr(FALSE, mode, colr);	/*restore the mode and color*/
	graf_mouse(M_ON, 0x0L);
}    

VOID copy_clor(LONG spt, WORD color)
{
	UWORD plane;
	WORD i;
	LONG s, d;

	rast_op(0, &hold_area, &disp_mfdb, &hold_area, &disp_mfdb);
	plane = color_map[color];
	s = spt;
	d = (LONG)disp_mfdb.fd_addr;
	if( color == old_fc)
	{
		for(i=0; i<gl_nplanes; i++)
		{
			if (plane & 1)
				LWCOPY(	d, s, gl_datasize);
			s += gl_datasize << 1;
			d += gl_datasize << 1;
			plane = plane >> 1;
		}
    }
	else	/*if image's old color is not black, we need the following*/
	{
		plane = color_map[old_fc];
		for(i=0; i<gl_nplanes; i++)
		{
			if (plane & 1)
				break;
			s += gl_datasize << 1;
			plane = plane >> 1;
		}
		plane = color_map[color];
		for (i=0; i<gl_nplanes; i++)
		{
			if (plane & 1)
				LWCOPY(d, s, gl_datasize);
			d += gl_datasize << 1;
			plane = plane >> 1;
		}
	}
	LWCOPY(clip_mfdb.fd_addr, disp_mfdb.fd_addr, gl_datasize * gl_nplanes);
}

VOID draw_clipb(BOOLEAN mouse, GRECT *dirty)
{
	GRECT  temp_area;

	if (clipped && orign_area.g_w && orign_area.g_h)
	{
		rc_copy(dirty, &temp_area);
		if (rc_intersect(&orign_area, &temp_area))
		{
			temp_area.g_x -= 1;	/*need to draw the outline*/
			temp_area.g_y -= 1;
			temp_area.g_w += 2;
			temp_area.g_h += 2;
			if (!rc_equal(dirty, &orign_area))
				rc_intersect(dirty, &temp_area);
			gsx_sclip(&temp_area);
			if (mouse)
				graf_mouse(M_OFF, 0x0L);
			rc_copy(&clip_area, &temp_area);
			if (gl_isicon)
			{
				temp_area.g_x += icn_img.g_x ;
				temp_area.g_y += icn_img.g_y ;
				rast_op(3, &temp_area, &scrn_mfdb, &orign_area, &scrn_mfdb);
			}
			else
			{
				disp_mfdb.fd_nplanes = clip_mfdb.fd_nplanes;
				disp_mfdb.fd_h = clip_mfdb.fd_h;
				disp_mfdb.fd_wdwidth = clip_mfdb.fd_wdwidth;
				disp_mfdb.fd_w = clip_mfdb.fd_w;
				disp_mfdb.fd_stand = clip_mfdb.fd_stand;
				copy_clor((LONG)clip_mfdb.fd_addr, fgcolor);
				rast_op(3, &clip_area, &disp_mfdb, &orign_area, &scrn_mfdb);
			}
			rc_copy(&orign_area, &temp_area);
			temp_area.g_x -= 1;
			temp_area.g_y -= 1;
			temp_area.g_w += 2;
			temp_area.g_h += 2;
			draw_outline(&temp_area);
			if(mouse)
				graf_mouse(M_ON, 0x0L);
		}
	}
}

VOID copy_img(BOOLEAN mouse)	/*copy part of icon/image to the clipboard*/
{
	GRECT    temp_area;

	graf_mouse(M_OFF, 0x0L);
	rc_copy(&selec_area, &clip_area);
	rc_copy(&selec_area, &temp_area);
	gsx_sclip(&dat_img);
	clip_area.g_x -= dat_img.g_x;	/*relative to the data frame*/
	clip_area.g_y -= dat_img.g_y;	/*relative to the data frame*/
	rast_op(3, &temp_area, &scrn_mfdb, &clip_area, &clip_mfdb);
	if (gl_isicon)
	{
		gsx_sclip(&mas_img);
		temp_area.g_x += deltax;
		temp_area.g_y += deltay;
		rast_op(3, &temp_area, &scrn_mfdb, &clip_area, &clp2_mfdb);
	}
	clear_clipb();
	/*show the stuff in the clip board*/
	rc_copy(&dispc_area, &orign_area);	
	orign_area.g_x -= (clip_area.g_w - orign_area.g_w) / 2; /*don't change 
			/ 2 to >> 1, because it maybe a negative value*/
	orign_area.g_w = clip_area.g_w;
	orign_area.g_h = clip_area.g_h;
	clipped = TRUE;	/*something in the clipboard*/
	draw_clipb(FALSE, &orign_area);
	if (mouse)
		graf_mouse(M_ON, 0x0L);
	gsx_sclip(&full);
}

VOID cut_img(VOID)
{
	copy_img(FALSE);
	del_img(FALSE, 3);
}

VOID do_paste_img(VOID)
{
	UWORD 	t1[2], smlxy[2];
	GRECT	dest_area;

	hold_to_undo();
	t1[0] = mousex;
	t1[1] = mousey;
	dest_area.g_w = clip_area.g_w;
	dest_area.g_h = clip_area.g_h;
	fat2sml((WORD *)t1, (WORD *)smlxy, 1, 1);
	dest_area.g_x = smlxy[0];
	dest_area.g_y = smlxy[1];
	rast_op(3, &clip_area, &clip_mfdb, &dest_area, &scrn_mfdb);
	if (gl_isicon)
	{
		gsx_sclip(&mas_img);
		dest_area.g_x += deltax;
		dest_area.g_y += deltay;
		rast_op(3, &clip_area, &clp2_mfdb, &dest_area, &scrn_mfdb);
	}
	save_img();
}

VOID solid_img(VOID)
{	      
	WORD	color;

	hold_to_undo();
	color = (colour == WHITE ? 0 : 15);
	if (pen_on != BCLORBOX)	/*eraser or 0 or fgcolr*/
	{
		rast_op(color,&hold_area, &hold_mfdb, &hold_area, &hold_mfdb);  
		if (color && gl_isicon)
			rast_op(0,&hold_area, &hld2_mfdb, &hold_area, &hld2_mfdb);
	}
	if (pen_on == BCLORBOX || (pen_on == ERASEBOX && gl_isicon))
	{
		rast_op(color,&hold_area, &hld2_mfdb, &hold_area, &hld2_mfdb);
		if (color)
			rast_op(0,&hold_area, &hold_mfdb, &hold_area, &hold_mfdb);  
	}
	save_fat(FALSE);
	gsx_sclip(&fat_area);
	fattify(NULL);	/*fattify the whole scroll area*/
	inverted = FALSE;
}

VOID invrt_img(VOID)
{
	WORD	color1, color2;

	hold_to_undo();
	if (gl_nplanes == 1)
	{
		color2 = fgcolor ^ 0x01;
		color1 = bgcolor ^ 0x01;
	}
	else if(gl_nplanes == 3)
	{
		color2 = invert3[fgcolor];
		if (gl_isicon)
			color1 = invert3[bgcolor];
	}
	else
	{
		color2 = invert4[fgcolor];
		if (gl_isicon)
			color1 = invert4[bgcolor];
	}
	set_fgcol(color2, TRUE);
	if (gl_isicon)
		set_bgcol(color1, TRUE);
	if (pen_on == BCLORBOX)
		colour = color1;
	else if(pen_on == FCLORBOX || pen_on == FALSE)
		colour = color2;
	inverted = TRUE;
	draw_clipb(TRUE, &orign_area);
}

VOID icon_size(WORD *pwidth, WORD *pheight)
{
	LONG		tree;
	UWORD		state;
	WORD		ii, butn, exitobj,new_w, new_h;
	GRECT		p;

	objc_xywh(ad_menu, EDITMENU, &p);
	ini_tree(&tree, NEWICNSZ);

	butn = (gl_wimage >> 4) + BEGWDSZ - 1;
	LWSET(OB_STATE(butn),SELECTED);
	butn = (gl_himage >> 2) + BEGHTSZ  - 1;
	LWSET(OB_STATE(butn),SELECTED);
	LWSET(OB_STATE(SCALESZ),SELECTED);
	exitobj = hndl_dial(tree,0,&p);
	/* find the new buttons	*/
	for (ii = BEGWDSZ; ii <= LASTWDSZ; ii++)
	{
		state = LWGET(OB_STATE(ii));
		if (state & SELECTED)
		{
			new_w = ii;
			break;
		}
	} /* for */
	/* get the height button	*/
	for (ii = BEGHTSZ; ii <= LASTHTSZ; ii++)
	{
		state = LWGET(OB_STATE(ii));
		if (state & SELECTED)
		{
			new_h = ii;
			break;
		}
	} /* for */
	for (ii = SCALESZ; ii <= CLEARSZ; ii++) 
	{
		state = LWGET(OB_STATE(ii));
		if (state & SELECTED)
		{
			scale = ii;
			break;
		}
	}
	/* reset the just-changed buttons	*/
	LWSET(OB_STATE(new_w), NORMAL);
	LWSET(OB_STATE(new_h), NORMAL);
	LWSET(OB_STATE(scale), NORMAL);
	if ( exitobj == OKCHNGSZ )	
	{
		*pwidth = (new_w - BEGWDSZ + 1 ) << 4;
		*pheight = (new_h - BEGHTSZ  + 1) << 2;
		LWSET(OB_STATE(OKCHNGSZ), NORMAL);
	}
	else
	{ 	/* it was CANCEL	*/
		/* reset the old buttons	*/
		LWSET(OB_STATE(CNCLCHGS), NORMAL);
		/* return old values		*/
		*pwidth = gl_wimage;
		*pheight = gl_himage;
	} /* else */
} /* icon_size */

VOID horiz_scale(BYTE *srcpt, WORD srcw, BYTE *despt)
{
	WORD s_bit_index, d_bit_index, xds, xdd, i, j, e;
	UBYTE bmask;

	xds = srcw << 1;
	xdd = gl_wimage << 1;

	bmask = 0x80;    
	e = j = d_bit_index = 0;
	for(i=0; i < srcw; i++)
	{
		e += xdd;
		s_bit_index = i % 8;
		if (i && !s_bit_index)
			srcpt++;
		if (e <= 0) /*this bit should be skipped, but save it by
			doing the logical or to the privious bit in destination */ 
		{
			if (*srcpt & (bmask >> s_bit_index))
				*despt |= (bmask >> d_bit_index);
		}
		else 
		{
			while( e > 0)
			{
				d_bit_index = j % 8;
				if (j++ && !d_bit_index)
					despt++;
				if (*srcpt & (bmask >> s_bit_index))
					*despt |= (bmask >> d_bit_index);
				e -= xds;
			}	/*end of while(e>0)*/
		}	/*end else	   */
	}	/*end of for i-loop*/
}

/* This routine will expand or shrink a given image. */
VOID scale_img(LONG srcpt, WORD srcw, WORD srch, LONG despt)
{
	WORD yds, ydd, f, l, k, j, last_k, db_per_row, sb_per_row;
	BYTE *p, *q, *last_q, *t, *s, temp[8];

	yds = srch << 1;
	ydd = gl_himage << 1;
	db_per_row = gl_wimage >> 3;	/*bytes per row in destination*/
	sb_per_row = srcw >> 3;	/*bytes per row in source*/
	f = l = 0;
	LBCOPY(ADDR(stemp), srcpt, sb_per_row * srch);
	last_k = -1;
	last_q = q = (BYTE *) dtemp;

	for(k=0; k < srch; k++)
	{
		f += ydd;
		p = ((BYTE*) stemp) + sb_per_row * k;
		if ( f <= 0) /*instead of skipping this row, scale it, bitwise or to
			the previous destination row*/
		{
			for (j=0; j<8; temp[j++]=0)
				;
			horiz_scale(p, srcw, temp);
			s = temp;
			t = q;
			for (j=0; j < db_per_row; j++)
				*t++ |= *s++;
		}
		else 
		{
			while(f > 0)
			{
				q = ((BYTE*) dtemp) + db_per_row * l++;
				if (k == last_k)/*no nedd to go through the scaling,just copy*/
					LBCOPY(ADDR(q), ADDR(last_q), db_per_row);
				else
				{
					last_q = q;
					last_k = k;
					horiz_scale(p, srcw, q);
				}		/*end of else clause*/
				f -= yds;
			}		/*end of while(f>0) */
		}	/*end of else clause*/
	}		/*end of for k-loop*/

	LBCOPY(despt, ADDR(dtemp), db_per_row * gl_himage );
}	/*end of scale_img*/

/************************************************************************/
/*keep_img()  This routine will keep or crop the given image in a new	*/
/*size.  The initialization of the destination image with zeros is done	*/
/*in the routine resize().                                              */
/************************************************************************/
VOID keep_img(LONG srcpt, WORD srcw, WORD srch, LONG despt)
{
	WORD  j, sw_per_row, dw_per_row;
	WORD  *p, *q;

	sw_per_row = srcw >> 4;	/*words per row in source image*/
	dw_per_row = gl_wimage >> 4;	/*words per row in destination image*/

	LWCOPY(ADDR(stemp), srcpt, sw_per_row * srch);
	for (j=0; j<min(srch, gl_himage); j++)
	{
		p = (WORD *) stemp + sw_per_row * j;
		q = (WORD *) dtemp + dw_per_row * j;
		LWCOPY(ADDR(q), ADDR(p), min(dw_per_row, sw_per_row));
	}
	LWCOPY(despt, ADDR(dtemp), dw_per_row * gl_himage);
}

/************************************************************************/
/* resize(): src_pt points to src image, src_w is its width in pixels,	*/
/* src_h is its height in pixels, des_pt points to destination image.	*/
/* This routine will call scale_img, keep_img or clear_img to scale an	*/
/* source image to a destination, depends on "scale" obtained from      */
/* icon_size dialog.  "scale" can be scale, keep or clear.  The new size*/
/* information is already set in gl_wimage and gl_himage in icon_size().*/
/************************************************************************/
VOID resize(LONG src_pt, WORD src_w, WORD src_h, LONG des_pt)
{
	WORD k;    

	for(k=0; k<256; k++)
		dtemp[k] = 0;
	if (scale == KEEPSZ)
		keep_img(src_pt, src_w, src_h, des_pt);
	else if(scale == SCALESZ)
		scale_img(src_pt, src_w, src_h, des_pt);
	else
		LWCOPY(des_pt, ADDR(dtemp), gl_datasize);
}
