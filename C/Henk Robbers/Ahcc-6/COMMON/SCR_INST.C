/*  Copyright (c) 1990 - present by Henk Robbers Amsterdam.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#define __SCR_INST__
#include <string.h>
#include "aaaa_lib.h"
global
short phys_handle, virt_handle;		/* workstation handles */

typedef struct
{
	union
	{
		short wo[57];
		V_WORKOUT vw;
	}vwk;
	short wi[12];
} V_WORK;


#define VW vwk.vw
#define WO vwk.wo

V_WORK scr;

PALETTE desk[BANKEN];

global
bool scr_intract = false;

global
short _frd,_fp,_fhc,_fwc,_fh,_fw,_fww,
	_nova,_t2w,MagX_version,radio_bgcol;
global
bool MagX,MiNT;
global
long MACH;
global
MAGX_COOKIE	*magic = nil;

global
void *_f_logbase;

global
RECT  screct={0,0,0,0};		/* global GRECT (aes) van scherm voor de handigheid */
global
VRECT scvrect={0,0,0,0};	/*    "   VRECT (vdi)        "               "      */

global
MFDB MFDBnull={nil,0,0,0,0,0,0,0,0},
     instmfdb={nil,0,0,0,0,0,0,0,0};
global
DRBVN instdrb;

global
void copy_gform(short hl, DRBVN pxy, MFDB *van,MFDB *naar)
{
	pxy.pv.w+=pxy.pv.x-1;
	pxy.pv.h+=pxy.pv.y-1;
	pxy.pn.w+=pxy.pn.x-1;
	pxy.pn.h+=pxy.pn.y-1;
	vro_cpyfm(hl,S_ONLY,(short *)&pxy,van,naar);
}

global
short open_vwk(short which, char * s, short *wi, short *wo)
{
	short i, hl, ax, ay, vwi[12], vwo[57];

#if 1
	if (!wi) wi = vwi;
	if (!wo) wo = vwo;
#else
	if (!wi) wi = scr.wi;
	if (!wo) wo = scr.WO;
#endif

	for(i=0;i<=10;wi[i++]=1);
	wi[10]=2;
	hl = phys_handle;
	v_opnvwk(wi,&hl,wo);

	vsf_interior (hl,FIS_SOLID);
	vsf_style    (hl,0);
	vsf_color    (hl,0);
	vsf_perimeter(hl,0);

	vsl_color(hl, 1);		/* sensible defaults independent of VDI authors' opinion (HR: grmbl) */
	vsl_type(hl, 1);

	vst_alignment(hl,0, 5, &ax, &ay);	/* 5 = top line */

	vswr_mode(hl, 1);
	return hl;
}

global
VV instt_scr
{
	short dum,hl;

	phys_handle=graf_handle(&_fwc,&_fhc,&dum,&dum);
	scr.VW.phl  = phys_handle;		/* 05'17 HR */

	hl = open_vwk(3,"desk",scr.wi, scr.WO);
	virt_handle = hl;
	scr.VW.hl   = hl;

	scvrect.jx=scr.VW.w;
	scvrect.jy=scr.VW.h;
	scr.VW.w+=1;
	scr.VW.h+=1;
	_fw=scr.VW.w;
	_fh=scr.VW.h;
	screct.w=_fw;
	screct.h=_fh;
	scr.VW.kleur=scr.VW.kleur?-1:1;
	scr.VW.hchar=_fhc;
	scr.VW.wchar=_fwc;

	vq_extnd(hl,1,(short *)&scr.VW.scrart);

	_fp=scr.VW.planes;
	scr.VW.pla=_fp;				/* compatability pre vq_extnd */

	scr.VW.scrl=((long)scr.VW.w*scr.VW.h*_fp)/8;

	_nova = get_cookie('IMNE',nil);
	_t2w  = get_cookie('_T2W',nil);
	MagX  = get_cookie('MagX',nil);
	MiNT  = get_cookie('MiNT',nil);
	        get_cookie('_MCH',&MACH);

	if ( _fp eq 4 and _fhc eq 8)
	{
		scr.VW.rez=0;
		scr.VW.promode=scr.VW.tinten > 512 ? TT :ST;
		scr.VW.banken=scr.VW.tinten > 512 ? BANKEN : 0;
	}
	else
	if (_fp eq 2 and _fhc eq 8)
	{
		scr.VW.rez=1;
		scr.VW.promode=scr.VW.tinten > 512 ? TT :ST;
		scr.VW.banken=scr.VW.tinten > 512 ? BANKEN : 0;
	}
	else
	if (_fp eq 1 and _fhc eq 16)
	{
		if (scr.VW.kleur eq -1)
		{
			scr.VW.promode=TT;		/* duochrome */
			scr.VW.rez=2;
			scr.VW.banken=0;
		othw
			if (scr.VW.w > 1024)
			{
				scr.VW.rez=5;
				scr.VW.promode=TT;
				scr.VW.banken=0;
			othw
				scr.VW.promode=ST;
				scr.VW.rez=2;
				scr.VW.banken=0;
			}
		}
	}
	else
	if (_fp eq 8 and _fhc eq 16)
	{
		if (scr.VW.w > scr.VW.h)
		{
			scr.VW.rez = 6;
			scr.VW.promode=NANA;
		othw
			scr.VW.rez=3;
			scr.VW.promode=TT;
		}
		scr.VW.banken=BANKEN;
	}
	else
	if (_fp eq 4 and _fhc eq 16)
	{
		scr.VW.rez=4;
		scr.VW.promode=TT;
		scr.VW.banken=BANKEN;
	}
	else
	if (_fp > 8 and !scr.VW.clut)
	{
		scr.VW.rez = _fp eq 16 ? 7 : 8;
		scr.VW.promode=NANA;
		scr.VW.banken=BANKEN;
	}
	else
	{
		if (scr_intract)
			form_alert(1,"[3][| Install screen: "
			                 "| Intractable combination "
			                 "| of physical characteristics ]"
			             "[ Oh! ]");
		else
		{
			scr.VW.rez=9;
			scr.VW.promode=NANA;
			scr.VW.banken=BANKEN;
		}
	}

	scr.VW.l.w=scr.VW.w;		/*	voor zachte software */
	scr.VW.l.h=scr.VW.h;

	scr.VW.rdis=(scr.VW.w/_fwc)*_fp;	/* voor harde software (DEGAS) */
	scr.VW.nword =2*(_fp-1);
	scr.VW.wwidth=scr.VW.rdis/2;
	_fww=scr.VW.wwidth;
	_frd=scr.VW.rdis;
	_f_logbase=Logbase();
	instmfdb.fd_w=_fw;		/* all tbv setscreen by copy raster */
	instmfdb.fd_h=_fh;
	instmfdb.fd_wdwidth=_fw/16;
	instmfdb.fd_nplanes=_fp;
	instdrb.pv.x=0;
	instdrb.pv.y=0;
	instdrb.pv.w=_fw;
	instdrb.pv.h=_fh;
	instdrb.pn=instdrb.pv;
}

global
void setscreen(void *s)
{
	hidem;
	instmfdb.fd_addr=s;
	copy_gform(scr.VW.hl,instdrb,&instmfdb,&MFDBnull);
	showm;
}


global
short get_cwch(short vhl, short wi[], short wo[], short *cw, short *ch)
{
	*cw = _fwc;
	*ch = _fhc;
	memmove(wi, scr.wi, sizeof(scr.wi));
	memmove(wo, scr.WO, sizeof(scr.WO));
	return vhl;
}

global
void getscreen(void *s)
{
	hidem;
	instmfdb.fd_addr=s;
	copy_gform(scr.VW.hl,instdrb,&MFDBnull,&instmfdb);
	showm;
}

global
VV resetdesk
{
	short i,j;

	if (scr.VW.planes >= 8)
	{
		loop(i,BANKEN)
			loop(j,BANK)
				vs_color(scr.VW.hl,i*BANKEN+j,desk[i].v_col(j));
	othw
		if (scr.VW.kleur < 0)
			loop(i,BANK)
				vs_color(scr.VW.hl,i,desk[0].v_col(i));
	}
}

global
VV savedesk
{
	short i,j;

	if (scr.VW.planes >= 8)
	{
		loop(i,BANKEN)
			loop(j,BANK)
				vq_color(scr.VW.hl,i*BANKEN+j,0,desk[i].v_col(j));
	othw
		if (scr.VW.kleur < 0)
			loop(i,BANK)
				vq_color(scr.VW.hl,i,0,desk[0].v_col(i));
	}
}

global
void Getcolor(short k,COLOR *kl)
{
	vq_color(scr.VW.hl,k,0,kl->argb.rgb);
}

/* 18'20 HR: v6 vhl */
global
void TsetPalet(short which, short vhl,PALETTE *pal,short all)
{
	short i,j;

	if (all and scr.VW.planes >= 8)
		loop(i,BANKEN)
			loop(j,BANK)
				vs_color(vhl,i*BANKEN+j,pal[i].v_col(j));
	else
		loop(i,BANK)
			vs_color(vhl,i,pal->v_col(i));
}

/*----------------------------------------------------------------------------------*/
/* Informationen ber die AES-Funktionen zurckliefern								*/
/* Funktionsergebnis:	diverse Flags												*/
/*	font_id:			ID des AES-Fonts											*/
/*	font_height:		H”he des AES-Fonts (fr vst_height())						*/
/*	hor_3d:				zus„tzlicher horizontaler beidseitiger Rand fr 3D-Objekte	*/
/*	ver_3d:				zus„tzlicher vertikaler beidseitiger Rand fr 3D-Objekte	*/
/*----------------------------------------------------------------------------------*/

global
short get_aes_info(short version, short *font_id, short *font_height, short *hor_3d, short *ver_3d )
{
	short work_out[58];
	short attrib[10];
#if USYSV
	short pens;
#endif
	short flags;

	vq_extnd( phys_handle, 0, work_out );
	vqt_attributes( phys_handle, attrib );

	flags = 0;
#if USYSV
	pens = work_out[13];				/* Anzahl der Farbstifte */
#endif
	if (font_id)     *font_id     = attrib[0];		/* Standardfont */
	if (font_height) *font_height = attrib[7];		/* Standardh”he */
	*hor_3d     = 0;
	*ver_3d     = 0;
	radio_bgcol = 0;

	if ( appl_find( "?AGI" ) == 0 )		/* appl_getinfo() vorhanden? */
		flags |= GAI_INFO;

	if (version >= 0x0401 )				/* mindestens AES 4.01? (includes N_AES???) */
		flags |= GAI_INFO;

	MagX_version = 0;

	MagX  = get_cookie('MagX', (long *)&magic);

	if ( magic )						/* MagiC vorhanden? */
		if ( magic->aesvars )			/* MagiC-AES aktiv? */
		{
			MagX_version = magic->aesvars->version;	/* MagiC-Versionsnummer */
			flags |= GAI_MAGIC + GAI_INFO;
		}

	if ( flags & GAI_INFO )				/* ist appl_getinfo() vorhanden? */
	{
		short ag1, ag2, ag3, ag4;

		if ( appl_getinfo( 0, &ag1, &ag2, &ag3, &ag4 ))			/* Unterfunktion 0, Large onts */
		{
			if (font_id)     *font_id     = ag2;
			if (font_height) *font_height = ag1;
		}
		if ( appl_getinfo( 2, &ag1, &ag2, &ag3, &ag4 ) && ag3 )	/* Unterfunktion 2, Farben */
			flags |= GAI_CICN;

		if ( appl_getinfo( 7, &ag1, &ag2, &ag3, &ag4 ))			/* Unterfunktion 7 ??? */
			flags |= ag1 & 0x0f;

		if ( appl_getinfo( 12, &ag1, &ag2, &ag3, &ag4 ) && ( ag1 & 8 ))	/* AP_TERM? */
			flags |= GAI_APTERM;

		if ( appl_getinfo( 13, &ag1, &ag2, &ag3, &ag4 ))		/* Unterfunktion 13, Objekte */
		{
		/*	if ( flags & GAI_MAGIC )			   MagiC spezifische Funktion! */
				if ( ag4 & 0x08 )				/* G_SHORTCUT untersttzt ? */
					flags |= GAI_GSHORTCUT;
				if ( ag4 & 0x04 )				/* MagiC (WHITEBAK) objects */
					flags |= GAI_WHITEBAK;

#if USYSV		/* Not really needed (My code only does mono) */
			if ( ag1 && ag2 )					/* 3D-Objekte und objc_sysvar() vorhanden? */
				if ( objc_sysvar( 0, AD3DVALUE, 0, 0, hor_3d, ver_3d ))	/* 3D-Look eingeschaltet? */
					if ( pens >= 16 )			/* mindestens 16 Farben? */
					{
						short dummy;

						flags |= GAI_3D;
						objc_sysvar( 0, BACKGRCOL, 0, 0, &radio_bgcol, &dummy );
					}
#endif
		}
	}

	return  flags;
}

MFORM lowpijl =
{
	3,3,1,0,1,
  { 0x0000, 0x0000, 0x3800, 0x3E00,
	0x3F80, 0x3FE0, 0x3FF8, 0x3FFC,
	0x3FF8, 0x3FE0, 0x39F0, 0x38F8,
	0x0078, 0x0000, 0x0000, 0x0000 },
  { 0x0000, 0x0000, 0x0000, 0x1800,
	0x1E00, 0x1F80, 0x1FE0, 0x1FF8,
	0x1F80, 0x1DC0, 0x10E0, 0x0070,
	0x0000, 0x0000, 0x0000, 0x0000 }
};

global
VV marrow
{
	if ( _fhc > 8)
		graf_mouse(0,nil);
	else
		graf_mouse(USER_DEF,&lowpijl);
}

