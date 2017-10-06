/*
 *	WinDom, Librairie GEM par Dominique B‚r‚ziat
 *	copyright 1997/2000
 *
 *	module: cicon.c
 *	description: impl‚mentation des ic“nes couleurs
 *				 (tir‚ de XRSRCFIX.C, Interface)
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "globals.h"
#include "cicon.h"
#include "userdef.h" /* pour XCICON */

/****** Compilerswitches ******************************************************/

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
#pragma warn -sig		/* d‚sactiver le message "Conversion may loose significant digits" */
#endif

#ifdef __SOZOBONX__
extern void lmemset(void*,char,long);
#define malloc(a)      lalloc((long)(a))
#define memcpy(a,b,c)  lmemcpy((a),(b),(long)(c))
#define memset(a,b,c)  lmemset((a),(b),(long)(c))
#endif /* __SOZOBONX__ */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

static WORD    xpixelbytes;
static WORD    xscrn_planes;


/****** FUNCTIONS ************************************************************/

static WORD xadd_cicon	 ( CICONBLK *cicnblk, OBJECT *obj, WORD nub, XRSRCFIX *fix);
static void draw_bitblk  ( WORD *p, WORD x, WORD y, WORD w, WORD h, WORD num_planes, WORD mode, INT16 *index);
static void xfix_cicon   ( UWORD *col_data, LONG len, WORD old_planes, WORD new_planes, MFDB *s, XRSRCFIX *fix);
static void std_to_byte  ( UWORD *col_data, LONG len, WORD old_planes, ULONG *farbtbl2, MFDB *s);
static WORD test_rez     ( void);
static void xfill_farbtbl( XRSRCFIX *fix);
int __CDECL xdraw_cicon  ( PARMBLK *pb);

/*****************************************************************************/
/* changer le format de l'ic“ne et l'adapter aux autres r‚solutions.         */
/*****************************************************************************/

WORD xadd_cicon (CICONBLK *cicnblk, OBJECT *obj, WORD nub, XRSRCFIX *fix)
{	WORD     x, y, line, xmax, best_planes, find_planes;
	CICON    *cicn, *color_icn, *best_icn = NULL;
  	LONG     len, *next;
  	MFDB     d;

	len = cicnblk->monoblk.ib_wicon / 8 * cicnblk->monoblk.ib_hicon;

	color_icn = &fix->cicon_table[nub];

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

		if (cicn->num_planes >= best_planes && cicn->num_planes <= find_planes)
		{
			best_planes = cicn->num_planes;
			best_icn = cicn;
		}
		cicn = cicn->next_res;
	}
	
	if (best_icn == NULL)		/* aucune ic“ne couleur trouv‚e */
		return (FALSE);
	else
		*color_icn = *best_icn;

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
	
		xfix_cicon ((UWORD *)best_icn->col_data, len, best_planes, xscrn_planes, &d, fix);
		if (best_icn->sel_data)
		{	d.fd_addr = color_icn->sel_data;
			xfix_cicon ((UWORD *)best_icn->sel_data, len, best_planes, xscrn_planes, &d, fix);
		}
	}
	else
	{
		memcpy (color_icn->col_data, best_icn->col_data, len);
		memcpy (color_icn->sel_data, best_icn->sel_data, len);
	}

	color_icn->next_res = cicnblk->mainlist;
	cicnblk->mainlist = color_icn;

	fix->obblk[nub].old_type = G_CICON;
	fix->obblk[nub].ublk.ub_parm = obj->ob_spec.index;
	fix->obblk[nub].ublk.ub_code = xdraw_cicon;
	obj->ob_spec.index = (LONG)&fix->obblk[nub].ublk;
	obj->ob_type = (XCICON << 8) | G_USERDEF;
	
	return (TRUE);
}

/*****************************************************************************/
/* En mode True-Color, passer la valeur de point en palette RVB              */
/*****************************************************************************/

static void xfill_farbtbl ( XRSRCFIX *fix)
{
	int np, color, backup[32];
	INT16 pxy[8], rgb[3];
	MFDB screen;
	MFDB pixel = {NULL, 16, 1, 1, 0, 1, 0, 0, 0};
	MFDB stdfm = {NULL, 16, 1, 1, 1, 1, 0, 0, 0};
	WORD pixtbl[16] = {0, 2, 3, 6, 4, 7, 5, 8, 9, 10, 11, 14, 12, 15, 13, 16};
	
	if (xscrn_planes >= 8)
	{
		if (xscrn_planes > 8)
		{
			if (fix->is_palette == FALSE)	/* pas de palette dans le ressource */
			{
				for (color = 0; color < 255; color++)
				{	if (color < 16)
					{	vq_color( app.handle, pixtbl[color], 1, fix->rgb_palette[color]);
						fix->rgb_palette[color][3] = pixtbl[color];
					}
					else
					{	vq_color( app.handle, color + 1, 1, fix->rgb_palette[color]);
						fix->rgb_palette[color][3] = color + 1;
					}
				}
				vq_color (app.handle, 1, 1, fix->rgb_palette[255]);
				fix->rgb_palette[255][3] = 1;
				fix->is_palette = TRUE;
			}
			
			vs_clip (app.handle, FALSE, pxy);
			graf_mouse (M_OFF, NULL);

			memset (backup, 0, sizeof (backup));
	 		memset (fix->farbtbl, 0, 32 * 256 * sizeof (WORD));
			screen.fd_addr = NULL;
			stdfm.fd_nplanes = pixel.fd_nplanes = xscrn_planes;
		
			vswr_mode (app.handle, MD_REPLACE);
			vsl_ends (app.handle, 0, 0);
			vsl_type (app.handle, 1);
			vsl_width (app.handle, 1);
			memset (pxy, 0, sizeof (pxy));
			
			pixel.fd_addr = backup;	/* Punkt retten */
			vro_cpyfm (app.handle, S_ONLY, pxy, &screen, &pixel);
		
			/* Alte Farbe retten */
			vq_color (app.handle, 15, 1, rgb);

			for (color = 0; color < 256; color++)
			{
				vs_color (app.handle, 15, fix->rgb_palette[color]);
				vsl_color (app.handle, 15);
				v_pline (app.handle, 2, pxy);
				
				stdfm.fd_addr = pixel.fd_addr = fix->farbtbl[color];
		
				/* vro_cpyfm, weil v_get_pixel nicht mit TrueColor (>=24 Planes) funktioniert */
				vro_cpyfm (app.handle, S_ONLY, pxy, &screen, &pixel);
	
				if (fix->farbtbl2 != NULL && xpixelbytes)
				{	fix->farbtbl2[color] = 0L;
					memcpy (&fix->farbtbl2[color], pixel.fd_addr, xpixelbytes);
				}
					
				vr_trnfm (app.handle, &pixel, &stdfm);
				for (np = 0; np < xscrn_planes; np++)
					if (fix->farbtbl[color][np])
						fix->farbtbl[color][np] = 0xffff;
			}
		
			/* Alte Farbe restaurieren */
			vs_color (app.handle, 15, rgb);

			pixel.fd_addr = backup;	/* Punkt restaurieren */
			vro_cpyfm (app.handle, S_ONLY, pxy, &pixel, &screen);
		
			graf_mouse (M_ON, NULL);
		}
		else
		{	if (fix->farbtbl2 != NULL && xpixelbytes)
				for (color = 0; color < 256; color++)
					*(UBYTE *)&fix->farbtbl2[color] = color;
		}
	}
}

/*****************************************************************************/
/* combiens de bytes par pixels seront ‚chang‚s au format                    */
/*****************************************************************************/

static WORD test_rez ()

{	int     i, np, color, bpp = 0;
	UWORD    backup[32], test[32];
	INT16     pxy[8], rgb[3];
	INT16     black[3] = {0, 0, 0};
	INT16     white[3] = {1000, 1000, 1000};
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
			vr_trnfm (app.handle, &stdfm, &pixel);
			
			for (i = 1; i < xscrn_planes; i++)
				if (test[i])	break;
			
			if (i >= xscrn_planes && !(test[0] & 0x00ff))
				bpp = 1;
		}
		else
		{
			vs_clip (app.handle, FALSE, pxy);
			screen.fd_addr = NULL;
			
			memset (backup, 0, sizeof (backup));
		
			vswr_mode (app.handle, MD_REPLACE);
			vsl_ends (app.handle, 0, 0);
			vsl_type (app.handle, 1);
			vsl_width (app.handle, 1);
			memset (pxy, 0, sizeof (pxy));
			
			graf_mouse (M_OFF, NULL);
		
			pixel.fd_addr = backup;	

			vro_cpyfm (app.handle, S_ONLY, pxy, &screen, &pixel);
		
			/* sauver l'ancienne couleur */
			vq_color (app.handle, 15, 1, rgb);
	
			/* tester le format universel */
			pixel.fd_addr = test;
			vsl_color (app.handle, 15);
			vs_color (app.handle, 15, white);
			v_pline (app.handle, 2, pxy);
			
			memset (test, 0, xscrn_planes * sizeof (WORD));
			vro_cpyfm (app.handle, S_ONLY, pxy, &screen, &pixel);
			
			for (i = (xscrn_planes + 15) / 16 * 2; i < xscrn_planes; i++)
				if (test[i])	break;
			
			if (i >= xscrn_planes)
			{
				vs_color (app.handle, 15, black);
				v_pline (app.handle, 2, pxy);
				
				memset (test, 0, xscrn_planes * sizeof (WORD));
				vro_cpyfm (app.handle, S_ONLY, pxy, &screen, &pixel);
				
				for (i = (xscrn_planes + 15) / 16 * 2; i < xscrn_planes; i++)
					if (test[i])	break;
				
				if (i >= xscrn_planes)
					bpp = (xscrn_planes + 7) / 8;
			}

			/* restaurer les anciennes couleurs */
			vs_color (app.handle, 15, rgb);
	
			pixel.fd_addr = backup;	/* restaure le point */
			vro_cpyfm (app.handle, S_ONLY, pxy, &pixel, &screen);
		
			graf_mouse (M_ON, NULL);
		}
	}

	return (bpp);
}

/*****************************************************************************/
/* adapter l'ic“ne … la r‚solution graphique actuelle                        */
/* (par exemple : une ic“ne de 4 Plans vers 24 Plans TrueColor)              */
/*****************************************************************************/

static void xfix_cicon (UWORD *col_data, LONG len, WORD old_planes, WORD new_planes, MFDB *s, XRSRCFIX *fix)

{	LONG  x, i, old_len, rest_len, mul[32], pos;
	UWORD np, *new_data, mask, pixel, bit, color, back[32], old_col[32], maxcol=0;
	WORD  got_mem = FALSE;
	MFDB  d;
	
	len >>= 1;

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
				
				vr_trnfm (app.handle, s, &d);
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
	/* debug windom */
	old_len  = 0;
	rest_len = 0;
	/* ------------ */
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
				for (i = 0; i < rest_len; i += len)
					new_data[x+i] |= mask;
		}

		if (s != NULL)	/* convertir au format universel */
		{
			d = *s;
			d.fd_stand = 0;
			if ((d.fd_addr = malloc (len * 2 * new_planes)) == NULL)
				d.fd_addr = s->fd_addr;
			
			vr_trnfm (app.handle, s, &d);
			if (d.fd_addr != s->fd_addr)
			{
				memcpy (s->fd_addr, d.fd_addr, len * 2 * new_planes);
				free (d.fd_addr);
			}
		}
	}
	else	/* TrueColor, valeur de points en RVB */
	{
		if (!xpixelbytes || s == NULL)
		{
			for (i = 0; i < new_planes; i++)
				mul[i] = i * len;
			
			if (old_planes < 8)
			{
				maxcol = (1 << old_planes) - 1;
				memcpy (old_col, fix->farbtbl[maxcol], new_planes * sizeof (WORD));
				memset (fix->farbtbl[maxcol], 0, new_planes * sizeof (WORD));
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
						col_data[pos] = (col_data[pos] & ~bit) | (fix->farbtbl[color][np] & bit);
					}
					
					bit <<= 1;
				}
			}
			if (old_planes < 8)
				memcpy (fix->farbtbl[maxcol], old_col, new_planes * sizeof (WORD));

			if (s != NULL)	/* convertir au format universel */
			{
				d = *s;
				d.fd_stand = 0;
				if ((d.fd_addr = malloc (len * 2 * new_planes)) == NULL)
					d.fd_addr = s->fd_addr;
				
				vr_trnfm (app.handle, s, &d);
				if (d.fd_addr != s->fd_addr)
				{
					memcpy (s->fd_addr, d.fd_addr, len * 2 * new_planes);
					free (d.fd_addr);
				}
			}
		}
		else
			std_to_byte (col_data, len, old_planes, fix->farbtbl2, s);
	}
}

/*****************************************************************************/
/* std_to_byte transforme un dessin du format standard au format             */
/* universel (pour les r‚solutions >= 16 Plans)                              */
/*****************************************************************************/

static void std_to_byte (col_data, len, old_planes, farbtbl2, s)
UWORD *col_data;
LONG  len;
WORD  old_planes;
ULONG *farbtbl2;
MFDB  *s;

{	LONG  x, i, mul[32], pos;
	UWORD np, *new_data, pixel, color, back[32];
	WORD  memflag = FALSE;
	UBYTE *p1, *p2;
	ULONG  colback=0;

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
/* dessine l'ic“ne couleur                                                        */
/*****************************************************************************/

int __CDECL xdraw_cicon (PARMBLK *pb)
{
	WORD	 	ob_x, ob_y, x, y, m_mode, i_mode=0, mskcol, icncol;
	INT16			pxy[4], xy[4], dummy;
	INT16			fatr[10],tatr[10];
	INT16       mindex[2], iindex[2];
	LONG	 	ob_spec;
	ICONBLK 	*iconblk;
	CICON   	*cicn;
	INT16    	*mask, *data, *dark = NULL;
	BYTE    	letter[2];
	int    		selected, buf;
	int 		invert = FALSE;

   	vqt_attributes(app.handle,tatr);
   	vqf_attributes(app.handle,fatr);

	selected = pb->pb_currstate & SELECTED;
	
	grect_to_array( (GRECT *)&pb->pb_xc, xy);
	vs_clip (app.handle, TRUE, xy);     /* d‚finit la zone rectangulaire */

	ob_spec	= pb->pb_parm;
	ob_x	= pb->pb_x;
	ob_y	= pb->pb_y;

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
			{	if (cicn->num_planes > 8)		/* TrueColor, carte couleur en mode RVB? */
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
		
		vswr_mode     (app.handle, MD_REPLACE);		/* dessiner la boŒte texte */
		vsf_color     (app.handle, mskcol);
		vsf_interior  (app.handle, 1 /*FIS_SOLID*/ );
		vsf_perimeter (app.handle, FALSE);
		v_bar         (app.handle, pxy);
	}

	vswr_mode     (app.handle, MD_TRANS);
  	vst_font      (app.handle, 1);	/* Systemfont */
	vst_height    (app.handle, 4, &dummy, &dummy, &dummy, &dummy);
  	vst_color     (app.handle, icncol);
  	vst_effects   (app.handle, TXT_NORMAL);
  	vst_alignment (app.handle, 0 /*ALI_LEFT*/, 1 /*ALI_TOP*/, &dummy, &dummy);
  	vst_rotation  (app.handle, 0);
	
	if (iconblk->ib_ptext[0])
	{	
		x += (iconblk->ib_wtext - strlen (iconblk->ib_ptext) * 6) / 2;
		y += (iconblk->ib_htext - 6) / 2;
		
		v_gtext (app.handle, x, y, iconblk->ib_ptext);
	}

	letter[0] = iconblk->ib_char & 0xff;
	if (letter[0])
	{
		letter[1] = '\0';
		x = ob_x + iconblk->ib_xicon + iconblk->ib_xchar;
		y = ob_y + iconblk->ib_yicon + iconblk->ib_ychar;
	
		v_gtext (app.handle, x, y, letter);
	}

	vsf_color(app.handle,fatr[1]);
	vsf_interior(app.handle,fatr[0]);
	vsf_perimeter(app.handle,fatr[4]);
  	vst_font(app.handle,tatr[0]);
	vst_height(app.handle,tatr[7],&dummy,&dummy,&dummy,&dummy);
  	vst_color(app.handle,tatr[1]);
  	vst_alignment(app.handle,tatr[3],tatr[4],&dummy,&dummy);
  	vst_rotation(app.handle,tatr[2]);
  	vst_effects(app.handle,TXT_NORMAL);
	vswr_mode(app.handle,MD_REPLACE);
	
	vs_clip (app.handle, FALSE, xy);

	return (pb->pb_currstate & ~ SELECTED);
} /* draw_userdef */

/*****************************************************************************/

static void draw_bitblk (WORD *p, WORD x, WORD y, WORD w, WORD h, WORD num_planes, WORD mode, INT16 *index)
{
	INT16	 	pxy[8];
	MFDB	 	s, d;

	d.fd_addr	   = NULL; /* screen */
	s.fd_addr    = (void *)p;
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
		vro_cpyfm (app.handle, mode, pxy, &s, &d);
	else
		vrt_cpyfm (app.handle, mode, pxy, &s, &d, index);	 /* copy it */
}


/*****************************************************************************/

void RsrcFixCicon ( OBJECT *object, int num_obs, int num_cib, INT16 palette[][4], void *_fix) {
	XRSRCFIX *fix = _fix;
	int    i, nub = 0;
	INT16 work_out[57];
	UWORD   type, xtype;
	OBJECT  *ob;
	
	fix->num_cib = num_cib;
	if (num_cib) {
		vq_extnd (app.handle, TRUE, work_out);	/* d‚finir le nombre de plans */
		xscrn_planes = work_out[4];
		xpixelbytes = test_rez ();
		
		if ((fix->obblk = (OBBLK *)malloc (num_cib * sizeof (OBBLK))) != 0L)
			memset (fix->obblk, 0, num_cib * sizeof (OBBLK));
		if ((fix->cicon_table = (CICON *)malloc (num_cib * sizeof (CICON))) != 0L)
			memset (fix->cicon_table, 0, num_cib * sizeof (CICON));

		if (palette != NULL) {
			fix->is_palette = TRUE;
			memcpy (fix->rgb_palette, palette, sizeof (fix->rgb_palette));
		} else
			fix->is_palette = FALSE;
		xfill_farbtbl (fix);
	}
	
	for (i = 0; i < num_obs; i++) {
		ob    = &object[i];
		type  = ob->ob_type & 0xFF;
		xtype = ob->ob_type & 0xff00;
				
		if (type == G_CICON) {	
			if (fix->obblk != NULL && fix->cicon_table != NULL)
			{
				if (xadd_cicon ((CICONBLK *)ob->ob_spec.index, ob, nub++, fix) == FALSE)
				{
					memset (&fix->cicon_table[nub-1], 0, sizeof (CICON));
					ob->ob_type = xtype | G_ICON;
				}
				/* L'ic“ne et l'image monochrome devront plus tard ˆtre transform‚es     */
				/* au format universel !                                                 */
			}
			else
				ob->ob_type = xtype | G_ICON;
		}
	}
}

/*****************************************************************************/

void RsrcFreeCicon ( void *_fix) {
	XRSRCFIX *fix = _fix;
	WORD i;

	if (fix->cicon_table != NULL) {
		for (i = 0; i < fix->num_cib; i++) {
			if (fix->cicon_table[i].num_planes > 1) {
				if (fix->cicon_table[i].col_data != NULL)
					free (fix->cicon_table[i].col_data);
				if (fix->cicon_table[i].sel_data != NULL)
					free (fix->cicon_table[i].sel_data);
				if (fix->cicon_table[i].sel_data == NULL && fix->cicon_table[i].sel_mask != NULL)
					free (fix->cicon_table[i].sel_mask);
			}
		}
		free (fix->cicon_table);
	}
	if (fix->obblk)
		free (fix->obblk);
}

