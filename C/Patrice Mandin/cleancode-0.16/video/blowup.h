/*
	BlowUp definitions

	Copyright (C) 2002	Patrice Mandin

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
*/

#ifndef _BLOWUP_H
#define _BLOWUP_H

/*--- Types ---*/

typedef struct {
	/* 64 bytes */
	unsigned char enabled[2];		/* Extended mode enabled ? 0=yes, <>0=no */
	unsigned char dummy10[12];
	unsigned char registers_0E[2];	/* value for register 0xffff820e */
	unsigned char registers_10[2];	/* value for register 0xffff8210 */
	unsigned char dummy11[46];

	/* 64 bytes */
	unsigned char width[2];			/* width-1 */
	unsigned char height[2];		/* height-1 */
	unsigned char dummy20[2];
	unsigned char screensize[4];	/* screensize in bytes */
	unsigned char dummy21[16];
	unsigned char virtual[2];		/* Virtual screen ? */
	unsigned char virwidth[2];		/* Virtual screen width */
	unsigned char virheight[2];		/* Virtual screen height */

	unsigned char dummy22[2];
	unsigned char monitor[2];		/* Monitor defined for this mode */
	unsigned char extension[2];		/* Extended mode defined ? 0=yes, 1=no */
	unsigned char dummy23[26];

	/* 64 bytes */
	unsigned char dummy30[2];
	unsigned char registers_82[12];	/* values for registers 0xffff8282-8c */
	unsigned char dummy31[18];

	unsigned char dummy32[2];
	unsigned char registers_A2[12];	/* values for registers 0xffff82a2-ac */
	unsigned char dummy33[18];

	/* 64 bytes */
	unsigned char registers_C0[2];	/* value for register 0xffff82c0 */
	unsigned char registers_C2[2];	/* value for register 0xffff82c2 */
	unsigned char dummy40[60];
} blow_mode_t;

typedef struct {
	blow_mode_t blowup_modes[10];
	unsigned char num_mode[6];
	unsigned char dummy1[4];
	unsigned char montype[2];
} blow_cookie_t;

/*--- Functions prototypes ---*/

#endif /* _BLOWUP_H */
