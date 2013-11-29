/*****************************************************************************/
/*                                                                           */
/* Modul: XRSRCFIX.C                                                         */
/* Datum: 19.10.92                                                           */
/*                                                                           */
/*****************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <tos.h>
#include <portab.h>
#include <vdi.h>
#include <aes.h>
#include "xrsrcfix.h"


/****** Compilerswitches ******************************************************/

#define BOOLEAN	char

/*#define SAVE_MEMORY FALSE	/* Speicherplatz bei Farbicons sparen? */*/

#ifndef TXT_NORMAL
#define TXT_NORMAL       0x0000 /* text effects */
#define TXT_THICKENED    0x0001
#define TXT_LIGHT        0x0002
#define TXT_SKEWED       0x0004
#define TXT_UNDERLINED   0x0008
#define TXT_OUTLINED     0x0010
#define TXT_SHADOWED     0x0020

#define ALI_LEFT         0 /* horizontal text alignment */
#define ALI_CENTER       1
#define ALI_RIGHT        2

#define ALI_BASE         0 /* vertical text alignment */
#define ALI_HALF         1
#define ALI_ASCENT       2
#define ALI_BOTTOM       3
#define ALI_DESCENT      4
#define ALI_TOP          5
#endif

#ifdef __TURBOC__
#pragma warn -sig		/* Warnung "Conversion may loose significant digits" ausschalten */
#endif

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL WORD    xvdi_handle;
LOCAL OBBLK   *obblk = NULL;
LOCAL CICON   *cicon_table = NULL;
LOCAL WORD    farbtbl[256][32];
LOCAL ULONG   farbtbl2[256];
LOCAL WORD    is_palette;
LOCAL WORD    rgb_palette[256][4];
LOCAL WORD    xpixelbytes;
LOCAL WORD    xscrn_planes;

/****** FUNCTIONS ************************************************************/

LOCAL WORD xadd_cicon        _((CICONBLK *cicnblk, OBJECT *obj, WORD nub));
LOCAL VOID draw_bitblk       _((WORD *p, WORD x, WORD y, WORD w, WORD h, WORD num_planes, WORD mode, WORD *index));
LOCAL VOID xfix_cicon        _((int handle, UWORD *col_data, LONG len, WORD old_planes, WORD new_planes, MFDB *s));
LOCAL VOID std_to_byte       _((UWORD *col_data, LONG len, WORD old_planes, ULONG *farbtbl2, MFDB *s));
LOCAL VOID xrect2array       _((CONST GRECT *rect, WORD *array));
LOCAL WORD test_rez          _((VOID));
LOCAL VOID xfill_farbtbl     _((VOID));
LOCAL WORD CDECL xdraw_cicon _((PARMBLK *pb));

/*****************************************************************************/
/* Icon ins ger„teabh„ngige Format wandeln und ggf an andere Aufl”sungen     */
/* anpassen                                                                  */
/*****************************************************************************/

WORD xadd_cicon (CICONBLK *cicnblk, OBJECT *obj, WORD nub)

{	WORD     x, y, line, xmax, best_planes, find_planes;
	CICON    *cicn, *color_icn, *best_icn = NULL;
  LONG     len, *next;
  MFDB     d, ecran={0};
#ifdef SAVE_MEMORY
	CICON    *max_icn = NULL;
#endif

	len = cicnblk->monoblk.ib_wicon / 8 * cicnblk->monoblk.ib_hicon;

	color_icn = &cicon_table[nub];

	best_planes = 1;
	if (xscrn_planes > 8)
		find_planes = 4;
	else
		find_planes = xscrn_planes;

	cicn = cicnblk->mainlist;
	next = (LONG *)&cicnblk->mainlist;

	while (cicn != NULL)
	{
		*next = (LONG)cicn;
		next = (LONG *)&cicn->next_res;

#ifdef SAVE_MEMORY
		if (cicn->num_planes > xscrn_planes)
			max_icn = cicn;
#endif
		if (cicn->num_planes >= best_planes && cicn->num_planes <= find_planes)
		{
			best_planes = cicn->num_planes;
			best_icn = cicn;
		}
		cicn = cicn->next_res;
	}
	if(best_icn == NULL)
		best_icn = cicnblk->mainlist;
	
	if (best_icn == NULL)		/* kein passendes Farbicon gefunden */
		return (FALSE);
	else
		color_icn = best_icn;

	if (best_planes > 1)
		color_icn->num_planes = xscrn_planes;
	else
		color_icn->num_planes = 1;

	
	/* Platz fr das ger„teabh„ngige Format allozieren */
	if ((color_icn->col_data = malloc (len * color_icn->num_planes)) == NULL)
		return (FALSE);
	if (color_icn->sel_data)
	{
		if ((color_icn->sel_data = malloc (len * color_icn->num_planes)) == NULL)
		{
			free (color_icn->col_data);
			return (FALSE);
		}
	}
	
	if (best_planes > 1)
	{	if (best_icn->sel_data == NULL)
		{
			/* Selected-Maske vorbereiten */
			if ((color_icn->sel_mask = malloc (len)) == NULL)
			{
				free (color_icn->col_data);
				if (color_icn->sel_data)
					free (color_icn->sel_data);
				return (FALSE);
			}
	
			xmax = cicnblk->monoblk.ib_wicon / 16;
	
			for (y = 0; y < cicnblk->monoblk.ib_hicon; y++)
			{
				line = y * xmax;
	
				for (x = 0; x < xmax; x++)
				{
					if (y & 1)
						color_icn->sel_mask[line + x] = best_icn->col_mask[line + x] & 0xaaaa;
					else
						color_icn->sel_mask[line + x] = best_icn->col_mask[line + x] & 0x5555;
				}
			}
		}
		
		d.fd_addr    = color_icn->col_data;
		d.fd_w       = cicnblk->monoblk.ib_wicon;
		d.fd_h       = cicnblk->monoblk.ib_hicon;
		d.fd_wdwidth = d.fd_w >> 4;
		d.fd_stand   = TRUE;
		d.fd_nplanes = xscrn_planes;
	
		xfix_cicon (xvdi_handle, (UWORD *)best_icn->col_data, len, best_planes, xscrn_planes, &d);
		if (best_icn->sel_data)
		{	d.fd_addr = color_icn->sel_data;
			xfix_cicon (xvdi_handle, (UWORD *)best_icn->sel_data, len, best_planes, xscrn_planes, &d);
		}
	}
	else
	{
		memcpy (color_icn->col_data, best_icn->col_data, len);
		memcpy (color_icn->sel_data, best_icn->sel_data, len);
	}

#ifdef SAVE_MEMORY
	if (best_icn->num_planes < color_icn->num_planes && max_icn != NULL)
	{	if (best_icn->sel_data == NULL || max_icn->sel_data != NULL)
		{
			best_icn->col_data = max_icn->col_data;
			best_icn->sel_data = max_icn->sel_data;
			best_icn->num_planes = xscrn_planes;
		}
	}
	
	if (best_icn->num_planes == color_icn->num_planes)
	{
		memcpy (best_icn->col_data, color_icn->col_data, len * color_icn->num_planes);
		free (color_icn->col_data);
		color_icn->col_data = NULL;
		if (best_icn->sel_data != NULL)
		{	memcpy (best_icn->sel_data, color_icn->sel_data, len * color_icn->num_planes);
			free (color_icn->sel_data);
			color_icn->sel_data = NULL;
		}
		else
		{	memcpy (cicnblk->monoblk.ib_pmask, color_icn->sel_mask, len);
			best_icn->sel_mask = cicnblk->monoblk.ib_pmask;
			free (color_icn->sel_mask);
			color_icn->sel_mask = NULL;
		}
	}
	else
	{
		if (best_icn->sel_data == NULL)
		{
			memcpy (cicnblk->monoblk.ib_pmask, color_icn->sel_mask, len);
			free (color_icn->sel_mask);
			color_icn->sel_mask = NULL;
			best_icn->col_data = color_icn->col_data;
			best_icn->sel_mask = cicnblk->monoblk.ib_pmask;
			best_icn->num_planes = color_icn->num_planes;
		}
		else
			*best_icn = *color_icn;
	}
	cicnblk->mainlist = best_icn;
#else
	color_icn->next_res = cicnblk->mainlist;
	cicnblk->mainlist = color_icn;
#endif
	obblk[nub].old_type = G_CICON;
	if(obj)
		obblk[nub].ublk.ub_parm = obj->ob_spec.index;
	obblk[nub].ublk.ub_code = xdraw_cicon;
	obj->ob_spec.index = (LONG)&obblk[nub].ublk;
	obj->ob_type = (obj->ob_type & 0xff00) | G_USERDEF;
	
/*	{
	int pxy[10]={0};
	pxy[0] = pxy[1] = 0;
	pxy[2] = pxy[3] = 16;
	pxy[4] = pxy[5] = 100;
	pxy[6] = pxy[7] = 116;
	vro_cpyfm(0, S_ONLY, pxy, &d, &ecran);
	}
*/
	return (TRUE);
}

/*****************************************************************************/
/* Unter TrueColor Pixelwerte der RGB-Palette ermitteln                      */
/*****************************************************************************/

LOCAL VOID xfill_farbtbl ()

{	WORD np, color, pxy[8], backup[32], rgb[3];
	MFDB screen;
	MFDB pixel = {NULL, 16, 1, 1, 0, 1, 0, 0, 0};
	MFDB stdfm = {NULL, 16, 1, 1, 1, 1, 0, 0, 0};
	WORD pixtbl[16] = {0, 2, 3, 6, 4, 7, 5, 8, 9, 10, 11, 14, 12, 15, 13, 16};
	
	if (xscrn_planes >= 8)
	{
		if (xscrn_planes > 8)
		{
			if (is_palette == FALSE)	/* Keine Palette in der Resource */
			{
				for (color = 0; color < 255; color++)
				{	if (color < 16)
					{	vq_color (xvdi_handle, pixtbl[color], 1, rgb_palette[color]);
						rgb_palette[color][3] = pixtbl[color];
					}
					else
					{	vq_color (xvdi_handle, color + 1, 1, rgb_palette[color]);
						rgb_palette[color][3] = color + 1;
					}
				}
				vq_color (xvdi_handle, 1, 1, rgb_palette[255]);
				rgb_palette[255][3] = 1;
				is_palette = TRUE;
			}
			
			vs_clip (xvdi_handle, FALSE, pxy);
			graf_mouse (M_OFF, NULL);

			memset (backup, 0, sizeof (backup));
	 		memset (farbtbl, 0, 32 * 256 * sizeof (WORD));
			screen.fd_addr = NULL;
			stdfm.fd_nplanes = pixel.fd_nplanes = xscrn_planes;
		
			vswr_mode (xvdi_handle, MD_REPLACE);
			vsl_ends (xvdi_handle, 0, 0);
			vsl_type (xvdi_handle, 1);
			vsl_width (xvdi_handle, 1);
			memset (pxy, 0, sizeof (pxy));
			
			pixel.fd_addr = backup;	/* Punkt retten */
			vro_cpyfm (xvdi_handle, S_ONLY, pxy, &screen, &pixel);
		
			/* Alte Farbe retten */
			vq_color (xvdi_handle, 15, 1, rgb);

			for (color = 0; color < 256; color++)
			{
				vs_color (xvdi_handle, 15, rgb_palette[color]);
				vsl_color (xvdi_handle, 15);
				v_pline (xvdi_handle, 2, pxy);
				
				stdfm.fd_addr = pixel.fd_addr = farbtbl[color];
		
				/* vro_cpyfm, weil v_get_pixel nicht mit TrueColor (>=24 Planes) funktioniert */
				vro_cpyfm (xvdi_handle, S_ONLY, pxy, &screen, &pixel);
	
				if (farbtbl2 != NULL && xpixelbytes)
				{	farbtbl2[color] = 0L;
					memcpy (&farbtbl2[color], pixel.fd_addr, xpixelbytes);
				}
					
				vr_trnfm (xvdi_handle, &pixel, &stdfm);
				for (np = 0; np < xscrn_planes; np++)
					if (farbtbl[color][np])
						farbtbl[color][np] = 0xffff;
			}
		
			/* Alte Farbe restaurieren */
			vs_color (xvdi_handle, 15, rgb);

			pixel.fd_addr = backup;	/* Punkt restaurieren */
			vro_cpyfm (xvdi_handle, S_ONLY, pxy, &pixel, &screen);
		
			graf_mouse (M_ON, NULL);
		}
		else
		{	if (farbtbl2 != NULL && xpixelbytes)
				for (color = 0; color < 256; color++)
					*(UBYTE *)&farbtbl2[color] = color;
		}
	}
}

/*****************************************************************************/
/* Testen wieviel Bytes pro Pixel im ger„teabh„ngigen Format verwendet werden*/
/*****************************************************************************/

LOCAL WORD test_rez ()

{	WORD     i, np, color, pxy[8], rgb[3], bpp = 0;
	UWORD    backup[32], test[32];
	WORD     black[3] = {0, 0, 0};
	WORD     white[3] = {1000, 1000, 1000};
	MFDB     screen;
	MFDB     pixel = {NULL, 16, 1, 1, 0, 1, 0, 0, 0};
	MFDB     stdfm = {NULL, 16, 1, 1, 1, 1, 0, 0, 0};

	if (xscrn_planes >= 8)
	{
		stdfm.fd_nplanes = pixel.fd_nplanes = xscrn_planes;

		if (xscrn_planes == 8)
		{
			color = 0xff;
			memset (test, 0, xscrn_planes * sizeof (WORD));
			for (np = 0; np < xscrn_planes; np++)
				test[np] = (color & (1 << np)) << (15 - np);
	
			pixel.fd_addr = stdfm.fd_addr = test;
			vr_trnfm (xvdi_handle, &stdfm, &pixel);
			
			for (i = 1; i < xscrn_planes; i++)
				if (test[i])	break;
			
			if (i >= xscrn_planes && !(test[0] & 0x00ff))
				bpp = 1;
		}
		else
		{
			vs_clip (xvdi_handle, FALSE, pxy);
			screen.fd_addr = NULL;
			
			memset (backup, 0, sizeof (backup));
		
			vswr_mode (xvdi_handle, MD_REPLACE);
			vsl_ends (xvdi_handle, 0, 0);
			vsl_type (xvdi_handle, 1);
			vsl_width (xvdi_handle, 1);
			memset (pxy, 0, sizeof (pxy));
			
			graf_mouse (M_OFF, NULL);
		
			pixel.fd_addr = backup;	/* Punkt retten */
			vro_cpyfm (xvdi_handle, S_ONLY, pxy, &screen, &pixel);
		
			/* Alte Farbe retten */
			vq_color (xvdi_handle, 15, 1, rgb);
	
			/* Ger„teabh„ngiges Format testen */
			pixel.fd_addr = test;
			vsl_color (xvdi_handle, 15);
			vs_color (xvdi_handle, 15, white);
			v_pline (xvdi_handle, 2, pxy);
			
			memset (test, 0, xscrn_planes * sizeof (WORD));
			vro_cpyfm (xvdi_handle, S_ONLY, pxy, &screen, &pixel);
			
			for (i = (xscrn_planes + 15) / 16 * 2; i < xscrn_planes; i++)
				if (test[i])	break;
			
			if (i >= xscrn_planes)
			{
				vs_color (xvdi_handle, 15, black);
				v_pline (xvdi_handle, 2, pxy);
				
				memset (test, 0, xscrn_planes * sizeof (WORD));
				vro_cpyfm (xvdi_handle, S_ONLY, pxy, &screen, &pixel);
				
				for (i = (xscrn_planes + 15) / 16 * 2; i < xscrn_planes; i++)
					if (test[i])	break;
				
				if (i >= xscrn_planes)
					bpp = (xscrn_planes + 7) / 8;
			}

			/* Alte Farbe restaurieren */
			vs_color (xvdi_handle, 15, rgb);
	
			pixel.fd_addr = backup;	/* Punkt restaurieren */
			vro_cpyfm (xvdi_handle, S_ONLY, pxy, &pixel, &screen);
		
			graf_mouse (M_ON, NULL);
		}
	}

	return (bpp);
}

/*****************************************************************************/
/* Icon an aktuelle Grafikaufl”sung anpassen                                 */
/* (z.B. 4 Plane Icon an 24 Plane TrueColor)                                 */
/*****************************************************************************/

VOID xfix_cicon (int handle, UWORD *col_data, LONG len, WORD old_planes, WORD new_planes, MFDB *s)

{	LONG  x, i, old_len, rest_len, mul[32], pos;
	UWORD np, *new_data, mask, pixel, bit, color, back[32], old_col[32], maxcol;
	WORD  got_mem = FALSE;
	MFDB  d;
	
	len >>= 1;
	xvdi_handle = handle;

	if (old_planes == new_planes)
	{	if (s != NULL)
		{	if (new_planes == xscrn_planes)
			{
				d = *s;
				d.fd_stand = FALSE;
				s->fd_addr = col_data;
				if (d.fd_addr == s->fd_addr)
				{	if ((d.fd_addr = malloc (len * 2 * new_planes)) == NULL)
						d.fd_addr = s->fd_addr;
					else
						got_mem = TRUE;
				}
				
				vr_trnfm (xvdi_handle, s, &d);
				if (d.fd_addr != s->fd_addr && got_mem == TRUE)
				{
					memcpy (s->fd_addr, d.fd_addr, len * 2 * new_planes);
					free (d.fd_addr);
				}
			}
			else
				memcpy (s->fd_addr, col_data, len * 2 * new_planes);
		}
		return;
	}
	
	if (new_planes <= 8)
	{
		old_len  = old_planes * len;
		rest_len = new_planes * len - old_len;

		if (s != NULL)
		{
			new_data = &((UWORD *)s->fd_addr)[old_len];
			memset (new_data, 0, rest_len * 2);
			memcpy (s->fd_addr, col_data, old_len * 2);
			col_data = s->fd_addr;
		}
		else
			new_data = (UWORD *)&col_data[old_len];
		
		for (x = 0; x < len; x++)
			{
			mask = 0xffff;
	
			for (i = 0; i < old_len; i += len)
				mask &= (UWORD)col_data[x+i];
			
			if (mask)
				{
				for (i = 0; i < rest_len; i += len)
					new_data[x+i] |= mask;
				}
			}

		if (s != NULL)	/* ins ger„teabh„ngige Format konvertieren */
			{
			d = *s;
			d.fd_stand = 0;
			if ((d.fd_addr = malloc (len * 2 * new_planes)) == NULL)
				d.fd_addr = s->fd_addr;
			
			vr_trnfm (xvdi_handle, s, &d);
			if (d.fd_addr != s->fd_addr)
				{
				memcpy (s->fd_addr, d.fd_addr, len * 2 * new_planes);
				free (d.fd_addr);
				}
			}
		}
	else	/* TrueColor, bzw RGB-orientierte Pixelwerte */
	{
		if (!xpixelbytes || s == NULL)
		{
			for (i = 0; i < new_planes; i++)
				mul[i] = i * len;
			
			if (old_planes < 8)
			{
				maxcol = (1 << old_planes) - 1;
				memcpy (old_col, farbtbl[maxcol], new_planes * sizeof (WORD));
				memset (farbtbl[maxcol], 0, new_planes * sizeof (WORD));
			}
	
			if (s != NULL)
			{
				new_data = &((UWORD *)s->fd_addr)[old_len];
				memset (new_data, 0, rest_len * 2);
				memcpy (s->fd_addr, col_data, old_len * 2);
				col_data = s->fd_addr;
			}
			
			for (x = 0; x < len; x++)
			{
				bit = 1;
				for (np = 0; np < old_planes; np++)
					back[np] = col_data[mul[np] + x];
				
				for (pixel = 0; pixel < 16; pixel++)
				{
					color = 0;
					for (np = 0; np < old_planes; np++)
					{
						color += ((back[np] & 1) << np);
						back[np] >>= 1;
					}
					
					for (np = 0; np < new_planes; np++)
					{	pos = mul[np] + x;
						col_data[pos] = (col_data[pos] & ~bit) | (farbtbl[color][np] & bit);
					}
					
					bit <<= 1;
				}
			}
			if (old_planes < 8)
				memcpy (farbtbl[maxcol], old_col, new_planes * sizeof (WORD));

			if (s != NULL)	/* ins ger„teabh„ngige Format konvertieren */
			{
				d = *s;
				d.fd_stand = 0;
				if ((d.fd_addr = malloc (len * 2 * new_planes)) == NULL)
					d.fd_addr = s->fd_addr;
				
				vr_trnfm (xvdi_handle, s, &d);
				if (d.fd_addr != s->fd_addr)
				{
					memcpy (s->fd_addr, d.fd_addr, len * 2 * new_planes);
					free (d.fd_addr);
				}
			}
		}
		else
			std_to_byte (col_data, len, old_planes, farbtbl2, s);
	}
}

/*****************************************************************************/
/* std_to_byte wandelt eine Grafik im Standardformat direkt ins ger„te-      */
/* abh„ngige Format (in Aufl”sungen mit >= 16 Planes)                        */
/*****************************************************************************/

LOCAL VOID std_to_byte (col_data, len, old_planes, farbtbl2, s)
UWORD *col_data;
LONG  len;
WORD  old_planes;
ULONG *farbtbl2;
MFDB  *s;

{	LONG  x, i, mul[32], pos;
	UWORD np, *new_data, pixel, color, back[32];
	WORD  memflag = FALSE;
	UBYTE *p1, *p2;
	ULONG  colback;

	if (s->fd_addr == col_data)
	{
		if ((col_data = malloc (len * 2 * s->fd_nplanes)) == NULL)
			return;
		memcpy (col_data, s->fd_addr, len * 2 * s->fd_nplanes);
		memflag = TRUE;
	}
	new_data = (UWORD *)s->fd_addr;
	p1 = (UBYTE *)new_data;

	if (old_planes < 8)
	{
		colback = farbtbl2[(1 << old_planes) - 1];
		farbtbl2[(1 << old_planes) - 1] = farbtbl2[255];
	}
		
	for (i = 0; i < old_planes; i++)
		mul[i] = i * len;
	
	pos = 0;
	
	for (x = 0; x < len; x++)
	{
		for (np = 0; np < old_planes; np++)
			back[np] = col_data[mul[np] + x];
		
		for (pixel = 0; pixel < 16; pixel++)
		{
			color = 0;
			for (np = 0; np < old_planes; np++)
			{
				color |= ((back[np] & 0x8000) >> (15 - np));
				back[np] <<= 1;
			}
			
			switch (xpixelbytes)
			{
				case 2:
					new_data[pos++] = *(UWORD *)&farbtbl2[color];
					break;

				case 3:
					p2 = (UBYTE *)&farbtbl2[color];
					*(p1++) = *(p2++);
					*(p1++) = *(p2++);
					*(p1++) = *(p2++);
					break;

				case 4:
					((ULONG *)new_data)[pos++] = farbtbl2[color];
					break;
			}
		}
	}

	if (old_planes < 8)
		farbtbl2[(1 << old_planes) - 1] = colback;

	if (memflag)
		free (col_data);
}

/*****************************************************************************/
/* Zeichnet Farb-Icon                                                        */
/*****************************************************************************/

WORD CDECL xdraw_cicon (PARMBLK *pb)

{	WORD	 	ob_x, ob_y, x, y, dummy, pxy[4], m_mode, i_mode, mskcol, icncol;
	LONG	 	ob_spec;
	ICONBLK *iconblk;
	CICON   *cicn;
	WORD    *mask, *data, *dark = NULL;
	BYTE    letter[2];
	WORD    selected, mindex[2], iindex[2], buf, xy[4];
	BOOLEAN invert = FALSE;
	
	selected = pb->pb_currstate & SELECTED;
	
	xrect2array ((GRECT *)&pb->pb_xc, xy);
	vs_clip (xvdi_handle, TRUE, xy);   /* Setze Rechteckausschnitt */

	ob_spec	= pb->pb_parm;
	ob_x		= pb->pb_x;
	ob_y		= pb->pb_y;

	iconblk = (ICONBLK *)ob_spec;
	cicn    = ((CICONBLK *)ob_spec)->mainlist;
	m_mode  = MD_TRANS;

	if (selected) /* it was an objc_change */
	{
		if (cicn->sel_data != NULL)
		{
			mask = cicn->sel_mask;
			data = cicn->sel_data;
			if (cicn->num_planes > 1)
			{	if (cicn->num_planes > 8)	/* TrueColor, bzw RGB-orientierte Grafikkarte? */
					i_mode = S_AND_D;
				else
					i_mode = S_OR_D;
			}
			else
				i_mode = MD_TRANS;
		}
		else
		{
			mask = cicn->col_mask;
			data = cicn->col_data;

			if (cicn->num_planes > 1)
			{	if (cicn->num_planes > 8)
					i_mode = S_AND_D;
				else
					i_mode = S_OR_D;
				dark = cicn->sel_mask;
			}
			else
				invert = TRUE;
		}
	}
	else
	{
		mask = cicn->col_mask;
		data = cicn->col_data;
	
		if (cicn->num_planes > 1)
		{	if (cicn->num_planes > 8)
				i_mode = S_AND_D;
			else
				i_mode = S_OR_D;
		}
		else
			i_mode = MD_TRANS;
	}
	
	mindex [0] = ((iconblk->ib_char & 0x0f00) != 0x0100) ? (iconblk->ib_char & 0x0f00) >> 8 : WHITE;
	mindex [1] = WHITE;
	
	icncol = iindex[0] = (WORD)(((UWORD)iconblk->ib_char & 0xf000U) >> 12U);
	iindex[1] = WHITE;

	mskcol = (iconblk->ib_char & 0x0f00) >> 8;

	x = ob_x + iconblk->ib_xicon;
	y = ob_y + iconblk->ib_yicon;

	if (invert)
	{
		buf       = iindex[0];
		iindex[0] = mindex[0];
		mindex[0] = buf;
		i_mode    = MD_TRANS;
	}
	if (selected)
	{
		buf    = icncol;
		icncol = mskcol;
		mskcol = buf;
	}
	
	draw_bitblk (mask, x, y, iconblk->ib_wicon, iconblk->ib_hicon, 1, m_mode, mindex);
	draw_bitblk (data, x, y, iconblk->ib_wicon, iconblk->ib_hicon, cicn->num_planes, i_mode, iindex);
	
	if (dark)
	{
		mindex [0] = BLACK;
		mindex [1] = WHITE;
		draw_bitblk (dark, x, y, iconblk->ib_wicon, iconblk->ib_hicon, 1, MD_TRANS, mindex);
	}

	if (iconblk->ib_ptext[0])
	{
		x = ob_x + iconblk->ib_xtext;
		y = ob_y + iconblk->ib_ytext;
		
		pxy[0] = x;
		pxy[1] = y;
		pxy[2] = x + iconblk->ib_wtext - 1;
		pxy[3] = y + iconblk->ib_htext - 1;
		
		vswr_mode     (xvdi_handle, MD_REPLACE);		/* Textbox zeichnen */
		vsf_color     (xvdi_handle, mskcol);
		vsf_interior  (xvdi_handle, FIS_SOLID);
		vsf_perimeter (xvdi_handle, FALSE);
		v_bar         (xvdi_handle, pxy);
	}

	vswr_mode     (xvdi_handle, MD_TRANS);
  vst_font      (xvdi_handle, 1);	/* Systemfont */
	vst_height    (xvdi_handle, 4, &dummy, &dummy, &dummy, &dummy);
  vst_color     (xvdi_handle, icncol);
  vst_effects   (xvdi_handle, TXT_NORMAL);
  vst_alignment (xvdi_handle, ALI_LEFT, ALI_TOP, &dummy, &dummy);
  vst_rotation  (xvdi_handle, 0);
	
	if (iconblk->ib_ptext[0])
	{	x += (iconblk->ib_wtext - strlen (iconblk->ib_ptext) * 6) / 2;
		y += (iconblk->ib_htext - 6) / 2;
		
		v_gtext (xvdi_handle, x, y, iconblk->ib_ptext);
	}

	letter[0] = iconblk->ib_char & 0xff;
	if (letter[0])
	{
		letter[1] = '\0';
		x = ob_x + iconblk->ib_xicon + iconblk->ib_xchar;
		y = ob_y + iconblk->ib_yicon + iconblk->ib_ychar;
	
		v_gtext (xvdi_handle, x, y, letter);
	}
	
	vs_clip (xvdi_handle, FALSE, xy);

	return (pb->pb_currstate & ~ SELECTED);
} /* draw_userdef */

/*****************************************************************************/

LOCAL VOID draw_bitblk (WORD *p, WORD x, WORD y, WORD w, WORD h, WORD num_planes, WORD mode, WORD *index)

{	WORD	 	pxy[8];
	MFDB	 	s, d;

	d.fd_addr	   = NULL; /* screen */
	s.fd_addr    = (VOID *)p;
	s.fd_w       = w;
	s.fd_h       = h;
	s.fd_wdwidth = w >> 4;
	s.fd_stand   = FALSE;
	s.fd_nplanes = num_planes;

	pxy[0] = 0;
	pxy[1] = 0;
 	pxy[2] = s.fd_w - 1;
 	pxy[3] = s.fd_h - 1;

	pxy[4] = x;
	pxy[5] = y;
	pxy[6] = pxy[4] + pxy [2];
	pxy[7] = pxy[5] + pxy [3];

	if (num_planes > 1)
		vro_cpyfm (xvdi_handle, mode, pxy, &s, &d);
	else
		vrt_cpyfm (xvdi_handle, mode, pxy, &s, &d, index);	 /* copy it */
}

/*****************************************************************************/

LOCAL VOID xrect2array (CONST GRECT *rect, WORD *array)

{
  *array++ = rect->g_x;
  *array++ = rect->g_y;
  *array++ = rect->g_x + rect->g_w - 1;
  *array   = rect->g_y + rect->g_h - 1;
} /* xrect2array */

/*****************************************************************************/

GLOBAL VOID init_xrsrc (vdi_handle, object, num_obs, num_cib, palette)
OBJECT *object;
WORD   num_obs;
WORD   num_cib;
WORD   palette[][4];

{	WORD    i, nub = 0, work_out[57];
	UWORD   type, xtype;
	OBJECT  *ob;
	
	xvdi_handle = vdi_handle;
	
	if (num_cib)
	{
		vq_extnd (xvdi_handle, TRUE, work_out);	/* Anzahl der Planes ermitteln */
		xscrn_planes = work_out[4];
		xfill_farbtbl ();

		xpixelbytes = test_rez ();
		
		if ((obblk = (OBBLK *)malloc (num_cib * sizeof (OBBLK))) != 0L)
			memset (obblk, 0, num_cib * sizeof (OBBLK));
		if ((cicon_table = (CICON *)malloc (num_cib * sizeof (CICON))) != 0L)
			memset (cicon_table, 0, num_cib * sizeof (CICON));

		if (palette != NULL)
		{
			is_palette = TRUE;
			memcpy (rgb_palette, palette, sizeof (rgb_palette));
		}
		else
			is_palette = FALSE;
	}
	
	for (i = 0; i < num_obs; i++)
	{
		ob    = &object[i];
		type  = ob->ob_type & 0xFF;
		xtype = ob->ob_type & 0xff00;
		
		rsrc_obfix (ob, 0);
		
		if (type == G_CICON)
		{	if (obblk != NULL && cicon_table != NULL)
			{
				if (xadd_cicon ((CICONBLK *)ob->ob_spec.index, ob, nub++) == FALSE)
				{
					memset (&cicon_table[nub-1], 0, sizeof (CICON));
					ob->ob_type = xtype | G_ICON;
				}
				/* Sp„ter mssen noch die Iconausmaže an die Aufl”sung und die           */
				/* monochrome Bitmap ans ger„teabh„ngige Format angepažt werden!         */
			}
			else
				ob->ob_type = xtype | G_ICON;
		}
	}
}

/*****************************************************************************/

GLOBAL VOID term_xrsrc (num_cib)
WORD num_cib;

{	WORD i;

	if (cicon_table != NULL)
	{
#ifdef SAVE_MEMORY
		VOID   *rs_start, *rs_end;
		
		rs_start = (VOID *)&RS0_MMASK[0];
		rs_end   = (VOID *)&rs_object[0];

		for (i = 0; i < num_cib; i++)
		{
			if (cicon_table[i].num_planes > 1)
			{
				if (cicon_table[i].col_data != NULL && (cicon_table[i].col_data < rs_start || cicon_table[i].col_data > rs_end))
					free (cicon_table[i].col_data);
				if (cicon_table[i].sel_data != NULL && (cicon_table[i].sel_data < rs_start || cicon_table[i].sel_data > rs_end))
					free (cicon_table[i].sel_data);
				if (cicon_table[i].sel_data == NULL && cicon_table[i].sel_mask != NULL && (cicon_table[i].sel_mask < rs_start || cicon_table[i].sel_mask > rs_end))
					free (cicon_table[i].sel_mask);
			}
		}
#else
		for (i = 0; i < num_cib; i++)
		{
			if (cicon_table[i].num_planes > 1)
			{
				if (cicon_table[i].col_data != NULL)
					free (cicon_table[i].col_data);
				if (cicon_table[i].sel_data != NULL)
					free (cicon_table[i].sel_data);
				if (cicon_table[i].sel_data == NULL && cicon_table[i].sel_mask != NULL)
					free (cicon_table[i].sel_mask);
			}
		}
#endif
		free (cicon_table);
	}
	if (obblk)
		free (obblk);
}




/*****************************************************************************/
/* Zeichnet Farb-Icon                                                        */
/*****************************************************************************/

WORD draw_icon (int handle, OBJECT *icon)

{	WORD	 	ob_x, ob_y, x, y, dummy, pxy[4], m_mode, i_mode, mskcol, icncol;
	LONG	 	ob_spec;
	ICONBLK *iconblk;
	CICON   *cicn;
	WORD    *mask, *data, *dark = NULL;
	BYTE    letter[2];
	WORD    selected, mindex[2], iindex[2], buf, xy[4];
	BOOLEAN invert = FALSE;
	
	selected = 0;
	xvdi_handle = handle;
	
/*	xrect2array ((GRECT *)&pb->pb_xc, xy);	*/
	xy[0] = xy[1] = 100;
	xy[2] = xy[3] = 116;
/*	vs_clip (xvdi_handle, TRUE, xy);   /* Setze Rechteckausschnitt */
*/

	ob_spec	= (LONG)icon->ob_spec.ciconblk;		/* pb->pb_parm;	*/
	ob_x		= 100;		/*	pb->pb_x;	*/
	ob_y		= 100;		/*	pb->pb_y;	*/

	iconblk = (ICONBLK *)ob_spec;
	cicn    = ((CICONBLK *)ob_spec)->mainlist;
	m_mode  = MD_REPLACE;		/*	MD_TRANS;	*/

	if (selected) /* it was an objc_change */
	{
		if (cicn->sel_data != NULL)
		{
			mask = cicn->sel_mask;
			data = cicn->sel_data;
			if (cicn->num_planes > 1)
			{	if (cicn->num_planes > 8)	/* TrueColor, bzw RGB-orientierte Grafikkarte? */
					i_mode = S_AND_D;
				else
					i_mode = S_OR_D;
			}
			else
				i_mode = MD_TRANS;
		}
		else
		{
			mask = cicn->col_mask;
			data = cicn->col_data;

			if (cicn->num_planes > 1)
			{	if (cicn->num_planes > 8)
					i_mode = S_AND_D;
				else
					i_mode = S_OR_D;
				dark = cicn->sel_mask;
			}
			else
				invert = TRUE;
		}
	}
	else
	{
		mask = cicn->col_mask;
		data = cicn->col_data;
	
		if (cicn->num_planes > 1)
		{	if (cicn->num_planes > 8)
				i_mode = S_AND_D;
			else
				i_mode = S_OR_D;
		}
		else
			i_mode = MD_TRANS;
	}
	
	mindex [0] = ((iconblk->ib_char & 0x0f00) != 0x0100) ? (iconblk->ib_char & 0x0f00) >> 8 : WHITE;
	mindex [1] = WHITE;
	
	icncol = iindex[0] = (WORD)(((UWORD)iconblk->ib_char & 0xf000U) >> 12U);
	iindex[1] = WHITE;

	mskcol = (iconblk->ib_char & 0x0f00) >> 8;

	x = ob_x + iconblk->ib_xicon;
	y = ob_y + iconblk->ib_yicon;

	if (invert)
	{
		buf       = iindex[0];
		iindex[0] = mindex[0];
		mindex[0] = buf;
		i_mode    = MD_TRANS;
	}
	if (selected)
	{
		buf    = icncol;
		icncol = mskcol;
		mskcol = buf;
	}
	
	draw_bitblk (mask, x, y, iconblk->ib_wicon, iconblk->ib_hicon, 1, m_mode, mindex);
	draw_bitblk (data, x, y, iconblk->ib_wicon, iconblk->ib_hicon, cicn->num_planes, i_mode, iindex);
	
	if (dark)
	{
		mindex [0] = BLACK;
		mindex [1] = WHITE;
		draw_bitblk (dark, x, y, iconblk->ib_wicon, iconblk->ib_hicon, 1, MD_TRANS, mindex);
	}

	if (iconblk->ib_ptext[0])
	{
		x = ob_x + iconblk->ib_xtext;
		y = ob_y + iconblk->ib_ytext;
		
		pxy[0] = x;
		pxy[1] = y;
		pxy[2] = x + iconblk->ib_wtext - 1;
		pxy[3] = y + iconblk->ib_htext - 1;
		
		vswr_mode     (xvdi_handle, MD_REPLACE);		/* Textbox zeichnen */
		vsf_color     (xvdi_handle, mskcol);
		vsf_interior  (xvdi_handle, FIS_SOLID);
		vsf_perimeter (xvdi_handle, FALSE);
		v_bar         (xvdi_handle, pxy);
	}

	vswr_mode     (xvdi_handle, MD_TRANS);
  vst_font      (xvdi_handle, 1);	/* Systemfont */
	vst_height    (xvdi_handle, 4, &dummy, &dummy, &dummy, &dummy);
  vst_color     (xvdi_handle, icncol);
  vst_effects   (xvdi_handle, TXT_NORMAL);
  vst_alignment (xvdi_handle, ALI_LEFT, ALI_TOP, &dummy, &dummy);
  vst_rotation  (xvdi_handle, 0);
	
	if (iconblk->ib_ptext[0])
	{	x += (iconblk->ib_wtext - strlen (iconblk->ib_ptext) * 6) / 2;
		y += (iconblk->ib_htext - 6) / 2;
		
		v_gtext (xvdi_handle, x, y, iconblk->ib_ptext);
	}

	letter[0] = iconblk->ib_char & 0xff;
	if (letter[0])
	{
		letter[1] = '\0';
		x = ob_x + iconblk->ib_xicon + iconblk->ib_xchar;
		y = ob_y + iconblk->ib_yicon + iconblk->ib_ychar;
	
		v_gtext (xvdi_handle, x, y, letter);
	}
	
	vs_clip (xvdi_handle, FALSE, xy);

	return (1);
}