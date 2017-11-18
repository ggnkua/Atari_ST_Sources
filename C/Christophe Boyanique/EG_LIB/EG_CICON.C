/******************************************************************************/
/*	"Easy Gem" library Copyright (c)1994 by		Christophe BOYANIQUE				*/
/*																29 Rue R‚publique					*/
/*																37230 FONDETTES					*/
/*																FRANCE								*/
/*						*small* mail at email adress:	cb@spia.freenix.fr				*/
/******************************************************************************/
/*	This program is free software; you can redistribute it and/or modify it		*/
/*	under the terms of the GNU General Public License as published by the Free	*/
/*	Software Foundation; either version 2 of the License, or any later version.*/
/*	This program is distributed in the hope that it will be useful, but WITHOUT*/
/*	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or		*/
/* FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for	*/
/*	more details.																					*/
/*	You should have received a copy of the GNU General Public License along		*/
/*	with this program; if not, write to the Free Software Foundation, Inc.,		*/
/*	675 Mass Ave, Cambridge, MA 02139, USA.												*/
/******************************************************************************/
/*																										*/
/*	This module is adapted from the Interface's XRSRCFIX.C							*/
/*		it *seems* that there is not any copyright on this module (I havn't		*/
/*		found anyone neither in the (french) documentation nor in the source);	*/
/*		so you can use it freely...															*/
/*		BUT, Interface is the *BEST* rsc editor, so if you want to use easily	*/
/*		GEM AES, buy it !																			*/
/*																										*/
/******************************************************************************/
/*	TABULATION: 3 CARACTERES																	*/
/******************************************************************************/

#include		"EG_MAIN.H"

/******************************************************************************/
/*	FUNCTIONS																						*/
/******************************************************************************/
static void	xfix_cicon(uint *col_data,long len,int old_planes,int new_planes,MFDB *s);
static void	std_to_byte(uint *col_data,long len,int old_planes,ulong *__farb2,MFDB *s);
static void	draw_bitblk(int *p,int x,int y,int w,int h,int num_planes,int mode,int *index);
static void	xrect2array(const GRECT *rect,int *array);

/******************************************************************************/
/*	INTERN VARIABLES																				*/
/******************************************************************************/
int			__farb[256][32];			/*	for color icon handling						*/
ulong			__farb2[32];
int			__pal[256][4];
int			__xpixel;


/******************************************************************************/
/*	Changer le format de l'ic“ne et l'adapter aux autres r‚solutions.				*/
/******************************************************************************/

int _addCicon(CICONBLK *cicnblk,OBJECT *obj,UBLK *obblk,CICON *cicon_table)
{
	int		x,y,line,xmax,best_planes,find_planes,dum;
	CICON		*cicn,*color_icn,*best_icn=NULL;
	long		len,*next;
	MFDB		d;

	len=cicnblk->monoblk.ib_wicon/8*cicnblk->monoblk.ib_hicon;
	color_icn=cicon_table;

	best_planes=1;
	if (glb.extnd[4]>8)
		find_planes=4;
	else
		find_planes=glb.extnd[4];

	cicn=cicnblk->mainlist;
	next=(long *)&cicnblk->mainlist;

	while (cicn != NULL)
	{
		*next=(long)cicn;
		next=(long *)&cicn->next_res;
		if (cicn->num_planes >= best_planes && cicn->num_planes <= find_planes)
		{
			best_planes = cicn->num_planes;
			best_icn = cicn;
		}
		cicn = cicn->next_res;
	}

	if (best_icn == NULL)		/* aucune ic“ne couleur trouv‚e */
		return 2*TRUE;
	else
		*color_icn = *best_icn;

	if (best_planes > 1)
		color_icn->num_planes = glb.extnd[4];
	else
		color_icn->num_planes = 1;

	/* Allouer la place pour le format universel */
	dum=_mAlloc(len*color_icn->num_planes,MB_NOMOVE,0);
	if (dum!=NO_MEMORY)
		color_icn->col_data=(int *)mem.bloc[dum].adr;
	else
		return FALSE;

	if (color_icn->sel_data)
	{
		dum=_mAlloc(len*color_icn->num_planes,MB_NOMOVE,0);
		if (dum!=NO_MEMORY)
			color_icn->sel_data=(int *)mem.bloc[dum].adr;
		else
		{
			_mSpecFree((long)color_icn->col_data);
			return FALSE;
		}
	}

	if (best_planes > 1)
	{
		if (best_icn->sel_data == NULL)
		{
			/* Pr‚parer le masque s‚lectionn‚ */
			dum=_mAlloc(len,MB_NOMOVE,0);
			if (dum!=NO_MEMORY)
				color_icn->sel_mask=(int *)mem.bloc[dum].adr;
			else
			{
				_mSpecFree((long)color_icn->col_data);
				if (color_icn->sel_data)
					_mSpecFree((long)color_icn->sel_data);
				return FALSE;
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
		d.fd_nplanes = glb.extnd[4];

		xfix_cicon ((uint *)best_icn->col_data, len, best_planes, glb.extnd[4], &d);
		if (best_icn->sel_data)
		{
			d.fd_addr = color_icn->sel_data;
			xfix_cicon ((uint *)best_icn->sel_data, len, best_planes, glb.extnd[4], &d);
		}
	}
	else
	{
		memcpy (color_icn->col_data, best_icn->col_data, len);
		memcpy (color_icn->sel_data, best_icn->sel_data, len);
	}

	color_icn->next_res = cicnblk->mainlist;
	cicnblk->mainlist = color_icn;

	obblk->type				=	G_CICON;
	obblk->spec				=	obj->ob_spec.index;
	obblk->blk.ub_parm	=	(long)obblk;
	obblk->blk.ub_code	=	_drawCicon;
	obj->ob_spec.index	=	(long)&obblk->blk;
	obj->ob_type			=	(obj->ob_type&0xFF00)|G_USERDEF;

	return TRUE;
}

typedef struct __rgb
{
	int r,g,b;
}	RGB;


/******************************************************************************/
/*	En mode True-Color, passer la valeur de point en palette RVB					*/
/******************************************************************************/
void _fillFarbTbl()
{
	int				np, color, pxy[8], backup[32], rgb[3];
	MFDB				screen;
	MFDB				pixel = {NULL, 16, 1, 1, 0, 1, 0, 0, 0};
	MFDB				stdfm = {NULL, 16, 1, 1, 1, 1, 0, 0, 0};
	int				pixtbl[16] = {0, 2, 3, 6, 4, 7, 5, 8, 9, 10, 11, 14, 12, 15, 13, 16};

	if (glb.extnd[4] > 8)
	{
		for (color = 0; color < 255; color++)
		{
			if (color < 16)
			{
				vq_color (glb.hvdi, pixtbl[color], 1, __pal[color]);
				__pal[color][3] = pixtbl[color];
			}
			else
			{
				vq_color (glb.hvdi, color - 1, 1, __pal[color]);
				__pal[color][3] = color - 1;
			}
		}
		vq_color (glb.hvdi,1,1,__pal[255]);
		__pal[255][3] = 1;

		vs_clip (glb.hvdi, FALSE, pxy);
		graf_mouse (M_OFF, NULL);

		memset (backup, 0, sizeof (backup));
 		memset (__farb, 0, 32 * 256 * sizeof (int));
		screen.fd_addr = NULL;
		stdfm.fd_nplanes = pixel.fd_nplanes = glb.extnd[4];

		vswr_mode (glb.hvdi, MD_REPLACE);
		vsl_ends (glb.hvdi, 0, 0);
		vsl_type (glb.hvdi, 1);
		vsl_width (glb.hvdi, 1);
		memset (pxy, 0, sizeof (pxy));

		pixel.fd_addr = backup;	/* Punkt retten */
		vro_cpyfm (glb.hvdi, S_ONLY, pxy, &screen, &pixel);

		/* calculer l'ancienne couleur */
		vq_color (glb.hvdi, 15, 1, rgb);

		for (color = 0; color < 256; color++)
		{
			vs_color (glb.hvdi,15,__pal[color]);
			vsl_color (glb.hvdi, 15);
			v_pline (glb.hvdi, 2, pxy);

			stdfm.fd_addr = pixel.fd_addr = __farb[color];

			/* vro_cpyfm,  car v_get_pixel ne fonctionne pas en TrueColor (>=24 Plans) */
			vro_cpyfm (glb.hvdi, S_ONLY, pxy, &screen, &pixel);

			if (__farb2 != NULL && __xpixel)
			{
				__farb2[color] = 0L;
				memcpy (&__farb2[color], pixel.fd_addr,__xpixel);
			}

			vr_trnfm (glb.hvdi, &pixel, &stdfm);
			for (np = 0; np < glb.extnd[4]; np++)
				if (__farb[color][np])
					__farb[color][np] = 0xffff;
		}

		/* restaurer l'ancienne couleur */
		vs_color (glb.hvdi, 15, rgb);

		pixel.fd_addr = backup;	/* restaurer le point */
		vro_cpyfm (glb.hvdi, S_ONLY, pxy, &pixel, &screen);

		graf_mouse (M_ON, NULL);
	}
}


/******************************************************************************/
/*	Combiens de bytes par pixels seront ‚chang‚s au format							*/
/******************************************************************************/
int _testRez()
{
	int		i,np,color,pxy[8],rgb[3],bpp=0;
	uint		backup[32], test[32];
	int		black[3]={0,0,0};
	int		white[3]={1000,1000,1000};
	MFDB		screen;
	MFDB		pixel={NULL,16,1,1,0,1,0,0,0};
	MFDB		stdfm={NULL,16,1,1,1,1,0,0,0};

	if (glb.extnd[4] >= 8)
	{
		stdfm.fd_nplanes = pixel.fd_nplanes = glb.extnd[4];

		if (glb.extnd[4] == 8)
		{
			color = 0xff;
			memset (test, 0, glb.extnd[4] * sizeof (int));
			for (np = 0; np < glb.extnd[4]; np++)
				test[np] = (color & (1 << np)) << (15 - np);

			pixel.fd_addr = stdfm.fd_addr = test;
			vr_trnfm (glb.hvdi, &stdfm, &pixel);

			for (i = 1; i < glb.extnd[4]; i++)
				if (test[i])
					break;

			if (i >= glb.extnd[4] && !(test[0] & 0x00ff))
				bpp = 1;
		}
		else
		{
			vs_clip (glb.hvdi, FALSE, pxy);
			screen.fd_addr = NULL;

			memset (backup, 0, sizeof (backup));

			vswr_mode (glb.hvdi, MD_REPLACE);
			vsl_ends (glb.hvdi, 0, 0);
			vsl_type (glb.hvdi, 1);
			vsl_width (glb.hvdi, 1);
			memset (pxy, 0, sizeof (pxy));

			graf_mouse (M_OFF, NULL);

			pixel.fd_addr = backup;	
			vro_cpyfm (glb.hvdi, S_ONLY, pxy, &screen, &pixel);

			/* sauver l'ancienne couleur */
			vq_color (glb.hvdi, 15, 1, rgb);

			/* tester le format universel */
			pixel.fd_addr = test;
			vsl_color (glb.hvdi, 15);
			vs_color (glb.hvdi, 15, white);
			v_pline (glb.hvdi, 2, pxy);

			memset (test, 0, glb.extnd[4] * sizeof (int));
			vro_cpyfm (glb.hvdi, S_ONLY, pxy, &screen, &pixel);

			for (i = (glb.extnd[4] + 15) / 16 * 2; i < glb.extnd[4]; i++)
				if (test[i])	break;

			if (i >= glb.extnd[4])
			{
				vs_color (glb.hvdi, 15, black);
				v_pline (glb.hvdi, 2, pxy);

				memset (test, 0, glb.extnd[4] * sizeof (int));
				vro_cpyfm (glb.hvdi, S_ONLY, pxy, &screen, &pixel);

				for (i = (glb.extnd[4] + 15) / 16 * 2; i < glb.extnd[4]; i++)
					if (test[i])	break;

				if (i >= glb.extnd[4])
					bpp = (glb.extnd[4] + 7) / 8;
			}

			/* restaurer l'ancienne couleur */
			vs_color (glb.hvdi, 15, rgb);

			pixel.fd_addr = backup;	/* restaurer le point */
			vro_cpyfm (glb.hvdi, S_ONLY, pxy, &pixel, &screen);

			graf_mouse (M_ON, NULL);

			vs_clip (glb.hvdi, TRUE, pxy);
		}
	}

	return bpp;
}


/******************************************************************************/
/*	Adapter l'ic“ne … la r‚solution graphique actuelle									*/
/*	(par exemple : une ic“ne de 4 Plans vers 24 Plans TrueColor)					*/
/******************************************************************************/
static void xfix_cicon(uint *col_data,long len,int old_planes,int new_planes,MFDB *s)
{
	long		x,i,old_len,rest_len,mul[32],pos;
	uint		np,*new_data,mask,pixel,bit,color,back[32],old_col[32],maxcol;
	int		dum,got_mem=FALSE;
	MFDB		d;

	len >>= 1;

	if (old_planes == new_planes)
	{
		if (s != NULL)
		{
			if (new_planes == glb.extnd[4])
			{
				d = *s;
				d.fd_stand = FALSE;
				s->fd_addr = col_data;
				if (d.fd_addr == s->fd_addr)
				{
					dum=_mAlloc(len*2*new_planes,MB_NOMOVE,0);
					if (dum!=NO_MEMORY)
					{
						got_mem = TRUE;
						d.fd_addr=(void *)mem.bloc[dum].adr;
					}
					else
						d.fd_addr=s->fd_addr;
				}

				vr_trnfm (glb.hvdi, s, &d);
				if (d.fd_addr != s->fd_addr && got_mem == TRUE)
				{
					memcpy (s->fd_addr, d.fd_addr, len * 2 * new_planes);
					_mSpecFree((long)d.fd_addr);
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
			new_data = &((uint *)s->fd_addr)[old_len];
			memset (new_data, 0, rest_len * 2);
			memcpy (s->fd_addr, col_data, old_len * 2);
			col_data = s->fd_addr;
		}
		else
			new_data = (uint *)&col_data[old_len];

		for (x = 0; x < len; x++)
		{
			mask = 0xffff;
	
			for (i = 0; i < old_len; i += len)
				mask &= (uint)col_data[x+i];

			if (mask)
				for (i = 0; i < rest_len; i += len)
					new_data[x+i] |= mask;
		}

		if (s != NULL)	/* convertir au format universel */
		{
			d = *s;
			d.fd_stand = 0;

			dum=_mAlloc(len*2*new_planes,MB_NOMOVE,0);
			if (dum!=NO_MEMORY)
				d.fd_addr=(void *)mem.bloc[dum].adr;
			else
				d.fd_addr=s->fd_addr;

			vr_trnfm (glb.hvdi, s, &d);
			if (d.fd_addr != s->fd_addr)
			{
				memcpy (s->fd_addr, d.fd_addr, len * 2 * new_planes);
				_mSpecFree((long)d.fd_addr);
			}
		}
	}
	else	/* TrueColor, valeur de points en RVB */
	{
		if (!__xpixel || s == NULL)
		{
			for (i = 0; i < new_planes; i++)
				mul[i] = i * len;

			if (old_planes < 8)
			{
				maxcol = (1 << old_planes) - 1;
				memcpy (old_col, __farb[maxcol], new_planes * sizeof (int));
				memset (__farb[maxcol], 0, new_planes * sizeof (int));
			}

			if (s != NULL)
			{
				new_data = &((uint *)s->fd_addr)[old_len];
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
					{
						pos = mul[np] + x;
						col_data[pos] = (col_data[pos] & ~bit) | (__farb[color][np] & bit);
					}

					bit <<= 1;
				}
			}
			if (old_planes < 8)
				memcpy (__farb[maxcol], old_col, new_planes * sizeof (int));

			if (s != NULL)	/* convertir au format universel */
			{
				d = *s;
				d.fd_stand = 0;

				dum=_mAlloc(len*2*new_planes,MB_NOMOVE,0);
				if (dum!=NO_MEMORY)
					d.fd_addr=(void *)mem.bloc[dum].adr;
				else
					d.fd_addr=s->fd_addr;

				vr_trnfm (glb.hvdi, s, &d);
				if (d.fd_addr != s->fd_addr)
				{
					memcpy (s->fd_addr, d.fd_addr, len * 2 * new_planes);
					_mSpecFree((long)d.fd_addr);
				}
			}
		}
		else
			std_to_byte (col_data, len, old_planes, __farb2, s);
	}
}


/******************************************************************************/
/*	std_to_byte transforme un dessin du format standard au format					*/
/*	universel (pour les r‚solutions >= 16 Plans)											*/
/******************************************************************************/

static void std_to_byte(uint *col_data,long len,int old_planes,ulong *__farb2,MFDB *s)
{
	long		x,i,mul[32],pos;
	uint		np,*new_data,pixel,color,back[32];
	int		dum,memflag=FALSE;
	uchar		*p1,*p2;
	ulong		colback;

	if (s->fd_addr == col_data)
	{
		dum=_mAlloc(len*2*s->fd_nplanes,MB_NOMOVE,0);
		if (dum!=NO_MEMORY)
			col_data=(uint *)mem.bloc[dum].adr;
		else
			return;
		memcpy (col_data, s->fd_addr, len * 2 * s->fd_nplanes);
		memflag = TRUE;
	}
	new_data = (uint *)s->fd_addr;
	p1 = (uchar *)new_data;

	if (old_planes < 8)
	{
		colback = __farb2[(1 << old_planes) - 1];
		__farb2[(1 << old_planes) - 1] = __farb2[255];
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

			switch (__xpixel)
			{
				case 2:
					new_data[pos++] = *(uint *)&__farb2[color];
					break;

				case 3:
					p2 = (uchar *)&__farb2[color];
					*(p1++) = *(p2++);
					*(p1++) = *(p2++);
					*(p1++) = *(p2++);
					break;

				case 4:
					((ulong *)new_data)[pos++] = __farb2[color];
					break;
			}
		}
	}

	if (old_planes < 8)
		__farb2[(1 << old_planes) - 1] = colback;

	if (memflag)
		_mSpecFree((long)col_data);
}


/******************************************************************************/
/*	Dessine l'ic“ne couleur																		*/
/******************************************************************************/

int cdecl _drawCicon(PARMBLK *pb)
{
	int			ob_x,ob_y,x,y,pxy[4],m_mode,i_mode,mskcol,icncol;
	long			ob_spec;
	ICONBLK		*iconblk;
	CICON			*cicn;
	int			*mask,*data,*dark=NULL;
	char			letter[2];
	int			selected,mindex[2],iindex[2],buf,xy[4];
	int			invert=FALSE;
	int			fatr[10],tatr[10],dum;

   vqt_attributes(glb.hvdi,tatr);
   vqf_attributes(glb.hvdi,fatr);

	selected = pb->pb_currstate & SELECTED;

	xrect2array ((GRECT *)&pb->pb_xc, xy);
	vs_clip (glb.hvdi, TRUE, xy);

	ob_spec	= ((UBLK *)pb->pb_parm)->spec;
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
			{
				if (cicn->num_planes > 8)	/* TrueColor, carte couleur en mode RVB? */
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
			{
				if (cicn->num_planes > 8)
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
		{
			if (cicn->num_planes > 8)
				i_mode = S_AND_D;
			else
				i_mode = S_OR_D;
		}
		else
			i_mode = MD_TRANS;
	}

	mindex [0] = ((iconblk->ib_char & 0x0f00) != 0x0100) ? (iconblk->ib_char & 0x0f00) >> 8 : WHITE;
	mindex [1] = WHITE;

	icncol = iindex[0] = (int)(((uint)iconblk->ib_char & 0xf000U) >> 12U);
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

		vswr_mode     (glb.hvdi, MD_REPLACE);		/* dessiner la boŒte texte */
		vsf_color     (glb.hvdi, mskcol);
		vsf_interior  (glb.hvdi, FIS_SOLID);
		vsf_perimeter (glb.hvdi, FALSE);
		v_bar         (glb.hvdi, pxy);
	}

	vswr_mode(glb.hvdi,MD_TRANS);
  	vst_font(glb.hvdi,1);	/* Systemfont */
	vst_height(glb.hvdi,4,&dum,&dum,&dum,&dum);
  	vst_color(glb.hvdi,icncol);
  	vst_effects(glb.hvdi,TXT_NORMAL);
  	vst_alignment(glb.hvdi,ALI_LEFT,ALI_TOP,&dum,&dum);
  	vst_rotation(glb.hvdi,0);

	if (iconblk->ib_ptext[0])
	{
		x += (iconblk->ib_wtext - (int)strlen (iconblk->ib_ptext) * 6) / 2;
		y += (iconblk->ib_htext - 6) / 2;
		v_gtext(glb.hvdi,x,y,iconblk->ib_ptext);
	}

	letter[0] = iconblk->ib_char & 0xff;
	if (letter[0])
	{
		letter[1] = '\0';
		x = ob_x + iconblk->ib_xicon + iconblk->ib_xchar;
		y = ob_y + iconblk->ib_yicon + iconblk->ib_ychar;

		v_gtext (glb.hvdi, x, y, letter);
	}

	vsf_color(glb.hvdi,fatr[1]);
	vsf_interior(glb.hvdi,fatr[0]);
	vsf_perimeter(glb.hvdi,fatr[4]);
  	vst_font(glb.hvdi,tatr[0]);
	vst_height(glb.hvdi,tatr[7],&dum,&dum,&dum,&dum);
  	vst_color(glb.hvdi,tatr[1]);
  	vst_alignment(glb.hvdi,tatr[3],tatr[4],&dum,&dum);
  	vst_rotation(glb.hvdi,tatr[2]);
  	vst_effects(glb.hvdi,TXT_NORMAL);
	vswr_mode(glb.hvdi,MD_REPLACE);

	vs_clip (glb.hvdi, FALSE, xy);
	return (pb->pb_currstate & ~ SELECTED);
} /* draw_userdef */


/******************************************************************************/
/******************************************************************************/
static void draw_bitblk(int *p,int x,int y,int w,int h,int num_planes,int mode,int *index)
{
	int		pxy[8];
	MFDB		s,d;

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
		vro_cpyfm (glb.hvdi, mode, pxy, &s, &d);
	else
		vrt_cpyfm (glb.hvdi, mode, pxy, &s, &d, index);	 /* copy it */
}


/******************************************************************************/
/******************************************************************************/

static void xrect2array(const GRECT *rect,int *array)
{
  *array++ = rect->g_x;
  *array++ = rect->g_y;
  *array++ = rect->g_x + rect->g_w - 1;
  *array   = rect->g_y + rect->g_h - 1;
} /* xrect2array */
