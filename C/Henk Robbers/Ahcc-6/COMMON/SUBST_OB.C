/* subst_ob.c           (c) by H. Robbers Amsterdam.
   ==========
*/

#include <string.h>
#include "aaaa_lib.h"
#include "mallocs.h"
#include "ahcm.h"


extern short	aes_flags,aes_font,MagX_version;
extern bool MagX;

char pri[81];

#if HAVE_IMAGES
static OBJECT	*radio_slct;
static OBJECT	*radio_deslct;
static short	radio_bgcol;
#endif

static short vdi_handle = -1;
extern short hchar,wchar,points;			/* ex main.c */

/*----------------------------------------------------------------------------------------*/
/* USERDEF-Funktion fr Check-Button																		*/
/* Funktionsresultat:	nicht aktualisierte Objektstati												*/
/* parmblock:			Zeiger auf die Parameter-Block-Struktur									*/
/*----------------------------------------------------------------------------------------*/

static void	userdef_text( short x, short y, void *string )
{
	vswr_mode( vdi_handle, MD_TRANS );
	v_gtext( vdi_handle, x, y, string );
	vswr_mode( vdi_handle, MD_REPLACE );
}

static void c_clip(GRECT c)
{
	if (c.x or c.y or c.w or c.h)	/* PROFIBUCH page 565 */
		gsclip( vdi_handle, 1, c);
}

static short	cdecl check_button( PARMBLK *parmblock )
{
	short	rect[4];
	short	 xy[10];
	/* Clipping rectangle: The 1 that is given to objc_draw(). */
	c_clip(parmblock->clip);
	*(GRECT *) rect = parmblock->size;				/* Objekt-Rechteck... */
	rect[2] = rect[0] + hchar - 2;
	rect[3] = rect[1] + hchar - 2;

	xy[0] = rect[0];
	xy[1] = rect[1];
	xy[2] = rect[2];
	xy[3] = rect[1];
	xy[4] = rect[2];
	xy[5] = rect[3];
	xy[6] = rect[0];
	xy[7] = rect[3];
	xy[8] = rect[0];
	xy[9] = rect[1];
	v_pline( vdi_handle, 5, xy );					/* schwarzen Rahmen zeichnen */

	xy[0] = rect[0] + 1;
	xy[1] = rect[1] + 1;
	xy[2] = rect[2] - 1;
	xy[3] = rect[3] - 1;

	vswr_mode( vdi_handle, MD_REPLACE);
	vr_recfl( vdi_handle, xy );						/* weiže Box zeichnen */
	vswr_mode( vdi_handle, MD_TRANS);

	if ( parmblock->currstate & SELECTED )
	{
		parmblock->currstate &= ~SELECTED;			/* Bit l”schen */
		xy[0] = rect[0] + 2;
		xy[1] = rect[1] + 2;
		xy[2] = rect[2] - 2;
		xy[3] = rect[3] - 2;
		v_pline( vdi_handle, 2, xy );

		xy[1] = rect[3] - 2;
		xy[3] = rect[1] + 2;
		v_pline( vdi_handle, 2, xy );
	}

	v_gtext(vdi_handle, parmblock->size.x + hchar + wchar, parmblock->size.y, parmblock->P.text );
	return( parmblock->currstate );
}

/*------------------------------------------------------------------*/
/* USERDEF-Funktion fr Radio-Button								*/
/* Funktionsresultat:	nicht aktualisierte Objektstati				*/
/* parmblock:			Zeiger auf die Parameter-Block-Struktur		*/
/*------------------------------------------------------------------*/

static short	cdecl radio_button( PARMBLK *parmblock )
{
	short	rect[4];
	short	 xy[4];

	c_clip(parmblock->clip);    /* Zeichenoperationen auf gegebenen Bereich beschr„nken */

	*(GRECT *) rect = parmblock->size;				/* Objekt-Rechteck... */
	rect[2] = rect[0] + hchar - 2;
	rect[3] = rect[1] + hchar - 2;

	v_rbox( vdi_handle, rect );						/* schwarzen Round box zeichnen */

	xy[0] = rect[0] + 1;
	xy[1] = rect[1] + 1;
	xy[2] = rect[2] - 1;
	xy[3] = rect[3] - 1;

	vswr_mode( vdi_handle, MD_REPLACE);
	v_rfbox( vdi_handle, xy );						/* weiže Box zeichnen */

	if ( parmblock->currstate & SELECTED )
	{
		parmblock->currstate &= ~SELECTED;			/* Bit l”schen */

		vsf_color( vdi_handle, 1 );					/* schwarz - fr das button */
		xy[0] = rect[0] + 3;
		xy[1] = rect[1] + 3;
		xy[2] = rect[2] - 3;
		xy[3] = rect[3] - 3;
		v_rfbox( vdi_handle, xy );
		vsf_color( vdi_handle, 0 );					/* weiž  */
	}
	vswr_mode( vdi_handle, MD_TRANS);

	v_gtext(vdi_handle, parmblock->size.x + hchar + wchar, parmblock->size.y, parmblock->P.text);

	return( parmblock->currstate );
}

#if HAVE_IMAGES
static short	cdecl radio_button( PARMBLK *parmblock )
{
	BITBLK	*image;
	MFDB	src;
	MFDB	des;
	short	xy[8];
	short	image_colors[2];

	c_clip(parmblock->clip);

	if ( parmblock->currstate & SELECTED )			/* Selektion? */
	{
		parmblock->currstate &= ~SELECTED;			/* Bit l”schen */
		image = radio_slct->spec.bitblk;
	}
	else
		image = radio_deslct->spec.bitblk;

	src.fd_addr = image->data;
	src.fd_w = image->wb * 8;
	src.fd_h = image->hl;
	src.fd_wdwidth = image->wb / 2;
	src.fd_stand = 0;
	src.fd_nplanes = 1;
	src.fd_r1 = 0;
	src.fd_r2 = 0;
	src.fd_r3 = 0;

	des.fd_addr = 0L;

	xy[0] = 0;
	xy[1] = 0;
	xy[2] = src.fd_w - 1;
	xy[3] = src.fd_h - 1;
	xy[4] = parmblock->size.x;
	xy[5] = parmblock->size.y;
	xy[6] = xy[4] + xy[2];
	xy[7] = xy[5] + xy[3];

	image_colors[0] = 1;			/* schwarz als Vordergrundfarbe */
	image_colors[1] = radio_bgcol;	/* Hintergrundfarbe */

	vrt_cpyfm( vdi_handle, MD_REPLACE, xy, &src, &des, image_colors );
	v_gtext(vdi_handle, parmblock->size.x + hchar + wchar, parmblock->size.y, parmblock->P.text );

	return( parmblock->currstate );
}
#endif

/*------------------------------------------------------------------*/
/* USERDEF-Funktion fr Gruppen-Rahmen								*/
/* Funktionsresultat:	nicht aktualisierte Objektstati				*/
/* parmblock:				Zeiger auf die Parameter-Block-Struktur	*/
/*------------------------------------------------------------------*/
static short	cdecl group( PARMBLK *parmblock )
{
	short	ob[4];
	short	xy[12];

	c_clip(parmblock->clip);

	*(GRECT *) ob = *(GRECT *) &parmblock->size.x;		/* Objekt-Rechteck... */
	ob[2] += ob[0] - 1;
	ob[3] += ob[1] - 1;

	xy[0] = ob[0] + wchar;
	xy[1] = ob[1] + hchar / 2;
	xy[2] = ob[0];
	xy[3] = xy[1];
	xy[4] = ob[0];
	xy[5] = ob[3];
	xy[6] = ob[2];
	xy[7] = ob[3];
	xy[8] = ob[2];
	xy[9] = xy[1];
	xy[10] = (short) ( xy[0] + strlen( parmblock->P.text ) * wchar );
	xy[11] = xy[1];

	v_pline( vdi_handle, 6, xy );

	v_gtext(vdi_handle, ob[0] + wchar, ob[1], parmblock->P.text );

	return( parmblock->currstate );
}

/*--------------------------------------------------------------*/
/* USERDEF-Funktion fr šberschrift								*/
/* Funktionsresultat:	nicht aktualisierte Objektstati			*/
/* parmblock:			Zeiger auf die Parameter-Block-Struktur	*/
/*--------------------------------------------------------------*/
static short	cdecl ob_title( PARMBLK *parmblock )
{
	short	xy[4];
	c_clip(parmblock->clip);

	v_gtext(vdi_handle, parmblock->size.x, parmblock->size.y, parmblock->P.text );

	xy[0] = parmblock->size.x;
	xy[1] = parmblock->size.y + parmblock->size.h;
	xy[2] = parmblock->size.x + parmblock->size.w - 1;
	xy[3] = xy[1];
	v_pline( vdi_handle, 2, xy );

	return( parmblock->currstate );
}

extern short	aes_flags,aes_font,MagX_version;
extern bool MagX;

/*------------------------------------------------------------------*/
/* MagiC-Objekte durch USERDEFs ersetzen							*/
/* Funktionsergebnis:	-											*/
/* obs:			Zeiger auf die Objekte								*/
/*	aes_flags:	Informationen ber das AES							*/
/*	rslct:		Zeiger auf Image fr selektierten Radio-Button		*/
/*	rdeslct:	Zeiger auf Image fr deselektierten Radio-Button	*/
/*------------------------------------------------------------------*/
#if HAVE_IMAGES
global
void *substitute_objects( OBJECT *obs, bool menu, OBJECT *rslct, OBJECT *rdeslct)
#else
global
void *subst_objects( OBJECT *obs, bool menu)
#endif
{
	USERBLK	*ublks = nil;
	OBJECT	*ob;
	short	no_subs;

/*	if (( aes_flags & GAI_MAGIC ) && ( MagX_version >= 0x0300 ))	/* MagiC-AES? */
		return nil;
*/
	if (( aes_flags & GAI_WHITEBAK ) != 0)		/* MagiC objects are there */
		return nil;

	ob = obs;				/* Zeiger auf die Objekte */
	no_subs = 0;

	do{
		if (( ob->state & WHITEBAK ) && ( ob->state & 0x8000 ))	/* MagiC-Objekt? */
			switch ( ob->type & 0xff )
			{			/* Checkbox, Radiobutton oder Gruppenrahmen? */
			case	G_BUTTON:
#if HAVE_IMAGES
				if (   ( ob->flags & RBUTTON ) ne 0		/* Radio-Button? */
					and rslct eq nil )					/* have picture? */
					break;
#endif
				no_subs++;
			break;
			case	G_STRING:	/* šberschrift? */
				no_subs++;
			break;
			}
		if ( ob->flags & LASTOB )
			break;
		ob++;
	}od

	if ( no_subs )		/* sind MagiC-Objekte vorhanden? */
	{
#if HAVE_IMAGES
		radio_slct = rslct;
		radio_deslct = rdeslct;
#endif
		ublks = xmalloc( no_subs * sizeof( USERBLK ), AH_UBBLK);
		if ( ublks )		/* Speicher vorhanden? */
		{
			USERBLK	*tmp; short i, dum;
			short wi[12],
				wo[56];

			if (vdi_handle < 0)
			{
				vdi_handle = phys_handle;
				for(i=0;i<=10;wi[i++]=1);
				wi[10]=2;
				v_opnvwk(wi,&vdi_handle,wo);		/* returns in ref handle virtual workstation's handle */
				vst_font( vdi_handle, aes_font );				/* Font einstellen */
				vst_color( vdi_handle, 1 );						/* schwarz */
				vst_effects( vdi_handle, 0 );					/* keine Effekte */
				vst_alignment( vdi_handle, 0, 5, &dum, &dum );	/* an der Zeichenzellenoberkante ausrichten */
				vst_height( vdi_handle, points, &dum, &dum, &dum, &dum );
				vsl_type( vdi_handle, 1 );
				vsl_color( vdi_handle, 1 );
				vswr_mode( vdi_handle, MD_TRANS );
				vsf_color( vdi_handle, 0 );					/* weiž  */
			}

			tmp = ublks;
			ob = obs;				/* Zeiger auf die Objekte */

			do{
				short	type;
				uint	state;

				type = ob->type & 0x00ff;
				state = (uint) ob->state;

				if (menu and type eq G_STRING and (aes_flags&GAI_GSHORTCUT))
					ob->type = G_SHORTCUT;
				if (( state & WHITEBAK ) && ( state & 0x8000 ))	/* MagiC-Objekt? */
				{
					state &= 0xff00;				/* nur das obere char ist interessant */

					if ( aes_flags & GAI_MAGIC )	/* altes MagiC-AES? */
					{
						if (( type == G_BUTTON ) && ( state == 0xfe00 ))
						{	/* Gruppenrahmen? */
							tmp->ub_parm = (long) ob->spec.free_string;	/* Zeiger auf den Text */
							tmp->ub_code = group;

							ob->type = G_USERDEF;
							ob->flags &= ~FL3DMASK;		/* 3D-Flags l”schen */
							ob->spec.userblk = tmp;		/* Zeiger auf den USERBLK */

							tmp++;
						}
					othw							/* TOS-AES oder sonstiges */
						switch ( type )
						{
							case	G_BUTTON:			/* Checkbox, Radiobutton oder Gruppenrahmen? */
								tmp->ub_parm = (long) ob->spec.free_string;	/* Zeiger auf den Text */

								if ( state == 0xfe00 )			/* Gruppenrahmen? */
									tmp->ub_code = group;
								elif ( ob->flags & RBUTTON )	/* Radio-Button? */
#if HAVE_IMAGES
									if (rslct)					/* had picture ? */
										tmp->ub_code = radio_button;
									else
										break;
#else
									tmp->ub_code = radio_button;
#endif
								else							/* Check-Button */
									tmp->ub_code = check_button;

								ob->type = G_USERDEF;
								ob->flags &= ~FL3DMASK;			/* 3D-Flags l”schen */
								ob->spec.userblk = tmp;			/* Zeiger auf den USERBLK */

								tmp++;
							break;
							case	G_STRING:					/* šberschrift? */
								if ( state == 0xff00 )			/* Unterstreichung auf voller L„nge? */
								{
									tmp->ub_parm = (long) ob->spec.free_string;	/* Zeiger auf den Text */
									tmp->ub_code = ob_title;
									ob->type = G_USERDEF;
									ob->flags &= ~FL3DMASK;		/* 3D-Flags l”schen */
									ob->spec.userblk = tmp;		/* Zeiger auf den USERBLK */
									tmp++;

								}
							break;
						}
					}
				}
				if (ob->flags&LASTOB)
					break;
				ob++;														/* n„chstes Objekt */
			}od
		}
	}
	return ublks;			/* per tree */
}

/*----------------------------------------------*/
/* Speicher fr Resource-Anpassung freigeben	*/
/* Funktionsresultat:	-						*/
/*----------------------------------------------*/
void	subst_free( USERBLK *ublks )
{
	if ( ublks )		/* Speicher vorhanden? */
		free( ublks );
	if (vdi_handle > 0)
		v_clsvwk(vdi_handle),
		vdi_handle = -1;

}
