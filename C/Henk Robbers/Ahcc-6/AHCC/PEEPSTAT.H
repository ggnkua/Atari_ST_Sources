/* Copyright (c) 1988,1989 by Sozobon, Limited.  Author: Tony Andrews
 *           (c) 1990 - present by H. Robbers.   ANSI upgrade.
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

/*
 * peepstat.h
 */

#ifndef PEEPSTA_H
#define PEEPSTA_H

typedef
struct pcnt
{
	short
		p0_0, p0_1, p0_2, p0_3, p0_4, p0_5,
		      p0_11,p0_12,p0_13,p0_14,p0_15,
		p0_lea, p0_imm,
	    p0_tsf, p0_tst, p0_tsx,
	    
	    s_fasn, d_fasn, p_fpsh, tst_areg,

	    p1_0, p1_reg, p1_1, p1_2, p1_3, p1_4, p1_5,
	    p1_split, p1_shift, p1_ldx,

		p2_0, p2_1, p2_2, p2_3, p2_4a, p2_4b, p2_4c, p2_4d,
		p2_5, p2_6, p2_7, p2_8, p2_9,
		p2_alea, p2_dlea, p2_lmx,
		p2_10, p2_11, p2_12, p2_13, p2_14,
		p2_15, p2_16, p2_17, p2_18, p2_19,
		p2_20, p2_21, p2_22, p2_23, p2_24,
		p2_25, p2_26, p2_27, p2_28, p2_29,
		p2_30, p2_31, p2_32, p2_33, p2_34,
		p2_35,
		p2_combine,
		p2_40, p2_45, p2_46, p2_47,
		p2_91, p2_92, p2_93,
		p2_100, p2_101,

		p3_0, p3_1, p3_2, p3_3, p3_4, p3_5;		
} PEEPC;

#if PCNT_SAMPLE
#define prcnt(a) if (peepcnt.a) console("%-8s%6d\n",#a,peepcnt.a);
#else
#define prcnt(a)
#endif

/* #define prcnt(a) console("%-8s%6d\n",#a,peepcnt.a) */

extern PEEPC peepcnt;

void do_pcnts(void);
void clr_pcnts(void);

#endif
