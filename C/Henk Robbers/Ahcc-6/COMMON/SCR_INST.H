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

#ifndef SCR_INST_H
#define SCR_INST_H

#ifndef VDI_H
#include <np_vdi.h>
#endif

#define BANKEN 16
#define BANK 16

#define ST 2
#define TT 3
#define NANA 1
typedef struct
{
	short r,g,b;
} RGB;

typedef struct
{
	short rgb[3];	/* mainly for use in vs_color/vq_color */
} ARGB;

typedef union
{
	RGB rgb;
	ARGB argb;
} COLOR;

typedef struct
{
	COLOR col[BANK];
} PALETTE;

extern
short phys_handle, virt_handle;		/* workstation handles */

#define v_col(x) col[x].argb.rgb
#define red(x)   col[x].rgb.r
#define green(x) col[x].rgb.g
#define blue(x)  col[x].rgb.b
#define rgb_s(x) col[x].rgb

/*		TT uitbreidingen preliminary
#define _EsetShift(mode) (short)xbios(80,mode)
#define _EgetShift() (short)xbios(81)
#define _EsetBank(num) (short)xbios(82,num)
#define _EsetColor(num,color) (short)xbios(83,num,color)
#define _EsetPalette(num,count,ptr) xbios(84,num,count,ptr)
#define _EgetPalette(num,count,ptr) xbios(85,num,count,ptr)
#define _EsetGrey(switch) (short)xbios(86,switch)
#define _EsetSmear(switch) (short)xbios(87,switch)
 DO NOT USE IN portable programs	*/

#define TT_low (scr.rez == 3)
#define TT_medium (scr.rez == 4)
#define TT_high (scr.rez == 5)
#define KL256 (scr.rez == 6)
#define K32 (scr.rez == 7)
#define M16 (scr.rez == 8)

#define DUOCHROME (ST_high && scr.kleur < 0)

void Getcolor	(short k,COLOR *kl);
short Colnum	(short k);
short  v_color	(short k);
void TsetPalet	(short which,short vhl,PALETTE *pal,short all);

#define ST_low (scr.rez == 0)
#define ST_medium (scr.rez eq 1)
#define ST_high (scr.rez == 2)
#define MONOCHROME (scr.kleur > 0)
#define QUADRUPLOCHROME ST_medium
#define MULTICHROME (scr.kleur < 0)
#define KLEUREN MULTICHROME

#ifndef HAVE_WH
typedef struct
{
	long w,h;
} L_WH;

typedef struct
{
	short w,h;
} WH;
#define HAVE_WH
#endif

typedef union
{
	char  *sc;
	long  *sr;
	long (*sl )  [8000];
	long (*ttsl) [38400L];
	long (*sq )  [400][20];
	long (*ttsq) [480][80];
	char (*sqb)  [400][80];
	char (*ttsqb)[480][320];
} SCR;

typedef struct
{
	short w,h;
	short genau;		/* +2 */
	short pixw;
	short pixh;
	short duma[8];		/* +5  */
	short kleuren;		/* +13 */
	short dumb[21];
	short kleur;		/* +35; 0=zww, 1=kleur */
	short dumc[3];
	short tinten;		/* +39 */
	short dumd[17];
	L_WH  l;				/* +57 */
	short pla;			/* see below */
	short rez;
	long scrl;
	short wchar,hchar;
	short promode;
	short wwidth;
	short rdis;
	short nword;
	short banken;
	short banknr;
	short phl;			/* vdi handle of this physical workstation */
	short hl;			/* vdi handle of this  virtual workstation */

	short scrart,	/* extended inquire */
		bckcols,
		txevec,
		enlarge,
		planes,
		clut,
		ewdum[51];
} V_WORKOUT;

typedef struct { short dx, dy, os, sn;
				 RECT o, r;
               } PRB;
typedef struct { RECT pv, pn;
               } DRBVN;

							/* Gets picture into screen buffer*/
extern
MFDB MFDBnull,instmfdb;
extern
DRBVN instdrb;
#ifndef __SCR_INST__
extern
V_WORKOUT scr;
#endif
extern
RECT screct;
extern
VRECT scvrect;
extern
bool MagX;

typedef void VV(void);

VV	instt_scr,
	old_scr, clr_scr, dump_scr, upsd_scr, switch_scr,
	savedesk, resetdesk,
	marrow;

short open_vwk(short which, char *s, short *wi, short *wo);

#endif
