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
short
	v_hl;	/* Virtual workstation handle (scheduled for redundancy) */

global
short phys_handle, virt_handle;		/* workstation handles */

typedef union
{
	short wi[12];
	short wo[57];
	V_WORKOUT vw;
} V_WORK;

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
RECT  scr_grect={0,0,0,0};	/* global GRECT (aes) van scherm voor de handigheid */
global
VRECT scr_vrect={0,0,0,0};	/*    "   VRECT (vdi)        "               "      */

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
short instt_scr(void)
{
	short i,dd,handle;

	phys_handle=graf_handle(&_fwc,&_fhc,&dd,&dd);
	scr.vw.phl = phys_handle;		/* 05'17 HR */
	handle = phys_handle;
	for(i=0;i<=10;scr.wi[i++]=1);
	scr.wi[10]=2;
	v_opnvwk(scr.wi,&handle,scr.wo);
	scr.vw.hl=handle;
	virt_handle = v_hl = handle; /* various applications */
	vsf_interior (handle,FIS_SOLID);
	vsf_style    (handle,0);
	vsf_color    (handle,0);
	vsf_perimeter(handle,0);

	vst_alignment(handle,0,4,&dd,&dd);

	vsl_color(handle, 1);		/* sensible defaults independent of VDI authors' opinion (HR: grmbl) */
	vsl_type(handle, 1);

	vswr_mode(handle, 1);

	scr_vrect.jx=scr.vw.w;
	scr_vrect.jy=scr.vw.h;
	scr.vw.w+=1;
	scr.vw.h+=1;
	_fw=scr.vw.w;
	_fh=scr.vw.h;
	scr_grect.w=_fw;
	scr_grect.h=_fh;
	scr.vw.kleur=scr.vw.kleur?-1:1;
	scr.vw.hchar=_fhc;
	scr.vw.wchar=_fwc;
	i=scr.vw.kleuren;

	vq_extnd(handle,1,(short *)&scr.vw.scrart);

	_fp=scr.vw.planes;
	scr.vw.pla=_fp;				/* compatability pre vq_extnd */

	scr.vw.scrl=((long)scr.vw.w*scr.vw.h*_fp)/8;

	_nova = get_cookie('IMNE',nil);
	_t2w  = get_cookie('_T2W',nil);
	MagX  = get_cookie('MagX',nil);
	MiNT  = get_cookie('MiNT',nil);
	        get_cookie('_MCH',&MACH);

	if ( _fp eq 4 and _fhc eq 8)
	{
		scr.vw.rez=0;
		scr.vw.promode=scr.vw.tinten > 512 ? TT :ST;
		scr.vw.banken=scr.vw.tinten > 512 ? BANKEN : 0;
	}
	else
	if (_fp eq 2 and _fhc eq 8)
	{
		scr.vw.rez=1;
		scr.vw.promode=scr.vw.tinten > 512 ? TT :ST;
		scr.vw.banken=scr.vw.tinten > 512 ? BANKEN : 0;
	}
	else
	if (_fp eq 1 and _fhc eq 16)
	{
		if (scr.vw.kleur eq -1)
		{
			scr.vw.promode=TT;		/* duochrome */
			scr.vw.rez=2;
			scr.vw.banken=0;
		othw
			if (scr.vw.w > 1024)
			{
				scr.vw.rez=5;
				scr.vw.promode=TT;
				scr.vw.banken=0;
			othw
				scr.vw.promode=ST;
				scr.vw.rez=2;
				scr.vw.banken=0;
			}
		}
	}
	else
	if (_fp eq 8 and _fhc eq 16)
	{
		if (scr.vw.w > scr.vw.h)
		{
			scr.vw.rez = 6;
			scr.vw.promode=NANA;
		othw
			scr.vw.rez=3;
			scr.vw.promode=TT;
		}
		scr.vw.banken=BANKEN;
	}
	else
	if (_fp eq 4 and _fhc eq 16)
	{
		scr.vw.rez=4;
		scr.vw.promode=TT;
		scr.vw.banken=BANKEN;
	}
	else
	if (_fp > 8 and !scr.vw.clut)
	{
		scr.vw.rez = _fp eq 16 ? 7 : 8;
		scr.vw.promode=NANA;
		scr.vw.banken=BANKEN;
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
			scr.vw.rez=9;
			scr.vw.promode=NANA;
			scr.vw.banken=BANKEN;
		}
	}

	scr.vw.l.w=scr.vw.w;		/*	voor zachte software */
	scr.vw.l.h=scr.vw.h;

	scr.vw.rdis=(scr.vw.w/_fwc)*_fp;	/* voor harde software (DEGAS) */
	scr.vw.nword =2*(_fp-1);
	scr.vw.wwidth=scr.vw.rdis/2;
	_fww=scr.vw.wwidth;
	_frd=scr.vw.rdis;
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
	return handle;
}

global
void setscreen(void *s)
{
	hidem;
	instmfdb.fd_addr=s;
	copy_gform(scr.vw.hl,instdrb,&instmfdb,&MFDBnull);
	showm;
}

global short get_cwch(int vl, int wi[], int wo[], int *cw, int *ch)
{
	*cw = _fwc;
	*ch = _fhc;
	memmove(wi, scr.wi, sizeof(scr.wi));
	memmove(wo, scr.wo, sizeof(scr.wo));
	return vl;
}

global
void getscreen(void *s)
{
	hidem;
	instmfdb.fd_addr=s;
	copy_gform(scr.vw.hl,instdrb,&MFDBnull,&instmfdb);
	showm;
}

global
void resetdesk(void)
{
	short i,j;

	if (scr.vw.planes >= 8)
	{
		loop(i,BANKEN)
			loop(j,BANK)
				vs_color(scr.vw.hl,i*BANKEN+j,desk[i].v_col(j));
	othw
		if (scr.vw.kleur < 0)
			loop(i,BANK)
				vs_color(scr.vw.hl,i,desk[0].v_col(i));
	}
}

global
void savedesk(void)
{
	short i,j;

	if (scr.vw.planes >= 8)
	{
		loop(i,BANKEN)
			loop(j,BANK)
				vq_color(scr.vw.hl,i*BANKEN+j,0,desk[i].v_col(j));
	othw
		if (scr.vw.kleur < 0)
			loop(i,BANK)
				vq_color(scr.vw.hl,i,0,desk[0].v_col(i));
	}
}

global
void Getcolor(short k,COLOR *kl)
{
	vq_color(scr.vw.hl,k,0,kl->argb.rgb);
}

global
void TsetPalet(PALETTE *pal,short all)
{
	short i,j;

	if (all and scr.vw.planes >= 8)
		loop(i,BANKEN)
			loop(j,BANK)
				vs_color(scr.vw.hl,i*BANKEN+j,pal[i].v_col(j));
	else
		loop(i,BANK)
			vs_color(scr.vw.hl,i,pal->v_col(i));
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
void marrow(void)
{
	if ( _fhc > 8)
		graf_mouse(0,nil);
	else
		graf_mouse(USER_DEF,&lowpijl);
}

