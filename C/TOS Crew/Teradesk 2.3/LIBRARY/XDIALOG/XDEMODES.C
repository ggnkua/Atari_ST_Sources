/*
 * Xdialog Library. Copyright (c) 1993, 1994, 2002 W. Klaren.
 *
 * This file is part of Teradesk.
 *
 * Teradesk is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Teradesk is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Teradesk; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifdef __PUREC__
 #include <np_aes.h>
 #include <vdi.h>
#else
 #include <aesbind.h>
 #include <vdibind.h>
#endif

#include <stddef.h>

#include "xdialog.h"
#include "xscncode.h"
#include "internal.h"

unsigned char xd_emode_specs[XD_EMODECOUNT] =
{
	0,							/* (0) */
	0,							/* (1) */
	0,							/* (2) */
	0,							/* (3) */
	0,							/* (4) */
	__XD_IS_ELEMENT,			/* XD_DRAGBOX(5): button rechtsboven waarmee dialoogbox verplaatst kan worden. */
	__XD_IS_ELEMENT |
	  __XD_IS_SELTEXT,			/* XD_ROUNDRB(6): ronde radiobutton. */
	__XD_IS_ELEMENT |
	  __XD_IS_SELTEXT,			/* XD_RECTBUT(7): rechthoekige button. */
	__XD_IS_ELEMENT |
	  __XD_IS_SELTEXT,			/* XD_BUTTON(8): gewone button (met toetsbediening! I_A). */
	__XD_IS_ELEMENT,			/* XD_RBUTPAR(9): Rechthoek met titel. */
	__XD_IS_ELEMENT,			/* XD_RBUTTITLE(10): IA: Underlined title */
	__XD_IS_ELEMENT |
	  __XD_IS_SELTEXT,			/* XD_RECTBUTTRI(11): IA: rectangle button: tri-state! */
	__XD_IS_ELEMENT |
	  __XD_IS_SELTEXT,			/* XD_CYCLBUT(12): IA: cycling button. used with pop-ups mostly. */
	__XD_IS_ELEMENT,			/* XD_SCRLEDIT(13): HR 021202: scrollable editable texts. */
	__XD_IS_NOTYETDEF,			/* (14) */
	__XD_IS_NOTYETDEF,			/* (15) */
	__XD_IS_NOTYETDEF,			/* (16) */
	__XD_IS_NOTYETDEF,			/* (17) */
	__XD_IS_NOTYETDEF,			/* (18) */
	__XD_IS_NOTYETDEF,			/* (19) */
	__XD_IS_NOTYETDEF,			/* (20) */
	__XD_IS_NOTYETDEF,			/* (21) */
	__XD_IS_NOTYETDEF,			/* (22) */
	__XD_IS_NOTYETDEF,			/* (23) */
	__XD_IS_NOTYETDEF,			/* (24) */
	__XD_IS_NOTYETDEF,			/* (25) */
	__XD_IS_NOTYETDEF,			/* (26) */
	__XD_IS_NOTYETDEF,			/* (27) */
	__XD_IS_NOTYETDEF,			/* (28) */
	__XD_IS_NOTYETDEF,			/* (29) */
	__XD_IS_NOTYETDEF,			/* (30) */
	__XD_IS_NOTYETDEF,			/* (31) */
	__XD_IS_NOTYETDEF,			/* (32) */
	__XD_IS_NOTYETDEF,			/* (33) */
	__XD_IS_NOTYETDEF,			/* (34) */
	__XD_IS_NOTYETDEF,			/* (35) */
	__XD_IS_NOTYETDEF,			/* (36) */
	__XD_IS_NOTYETDEF,			/* (37) */
	__XD_IS_NOTYETDEF,			/* (38) */
	__XD_IS_NOTYETDEF,			/* (39) */
	__XD_IS_NOTYETDEF,			/* (40) */
	__XD_IS_NOTYETDEF,			/* (41) */
	__XD_IS_NOTYETDEF,			/* (42) */
	__XD_IS_NOTYETDEF,			/* (43) */
	__XD_IS_NOTYETDEF,			/* (44) */
	__XD_IS_NOTYETDEF,			/* (45) */
	__XD_IS_NOTYETDEF,			/* (46) */
	__XD_IS_NOTYETDEF,			/* (47) */
	__XD_IS_NOTYETDEF,			/* (48) */
	__XD_IS_NOTYETDEF,			/* (49) */
	__XD_IS_NOTYETDEF,			/* (50) */
	__XD_IS_NOTYETDEF,			/* (51) */
	__XD_IS_SPECIALKEY,			/* XD_UP(52): Codes voor buttons met bediening cursortoetsen */
	__XD_IS_SPECIALKEY,			/* XD_DOWN(53) */
	__XD_IS_SPECIALKEY,			/* XD_LEFT(54) */
	__XD_IS_SPECIALKEY,			/* XD_RIGHT(55) */
	__XD_IS_SPECIALKEY,			/* XD_SUP(56) */
	__XD_IS_SPECIALKEY,			/* XD_SDOWN(57) */
	__XD_IS_SPECIALKEY,			/* XD_SLEFT(58) */
	__XD_IS_SPECIALKEY,			/* XD_SRIGHT(59) */
	__XD_IS_SPECIALKEY,			/* XD_CUP(60) */
	__XD_IS_SPECIALKEY,			/* XD_CDOWN(61) */
	__XD_IS_SPECIALKEY,			/* XD_CLEFT(62) */
	__XD_IS_SPECIALKEY			/* XD_CRIGHT(63) */
};

int ckeytab[] =
{
	CURUP,						/* XD_UP */
	CURDOWN,
	CURLEFT,
	CURRIGHT,
	SHFT_CURUP,
	SHFT_CURDOWN,
	SHFT_CURLEFT,
	SHFT_CURRIGHT,
	CTL_CURUP,
	CTL_CURDOWN,
	CTL_CURLEFT,
	CTL_CURRIGHT
};
