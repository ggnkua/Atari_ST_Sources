/* This file is part of the AHCC GEM Library.

   The AHCC GEM Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public License as
   published by the Free Software Foundation; either version 2 of the
   License, or (at your option) any later version.

   The AHCC GEM Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with the GNU C Library; see the file COPYING.LIB.  If not,
   write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.

   Copyright (c) 2008 by Henk Robbers @ Amsterdam.
*/

#ifndef __VDIPB_H__
#define __VDIPB_H__

#define SMURF 0		/* new bindings according to SMURF */

typedef struct
{
	short
		fu,
		nptsin,
		nptsout,
		nintin,
		nintout,
		escape,
		handle;
	union
	{
		struct
		{ long ct, co;
		} ll;			/* 7,8,9,10 */
		struct
		{ long *src, *des;
		} lp;
		short ii[5];	/* 7,8,9,10,11 */
	} x;
} VCTL;

typedef struct
{
	short control[15],
	      intin  [132],
	      intout [140],
	      ptsin  [145],
	      ptsout [145];
}
VDIPARBLK;

typedef struct
{
    VCTL  * contrl;
    short *	intin;
    short *	ptsin;
    short *	intout;
    short *	ptsout;
} VDIPB;

#define MAX_TXT 256		/* maximum for text output (is truncated) */

/* define as cdecl for parameters on stack */
#define V_decl

#define SETVCTL(h,f,i,p,e) VCTL c; VDIPB pb;\
                           c.handle=h;\
                           c.fu=f;\
                           c.nintin=i;\
                           c.nptsin=p;\
                           c.escape=e

#define TRPVPB(q,r,s,t) pb.contrl=&c;\
                        pb.intin=q;\
                        pb.ptsin=r;\
                        pb.intout=s;\
                        pb.ptsout=t;\
                        VDI(&pb)

#undef nil
#define nil 0L

extern short v_tii[];

#if __AHCC__
void __syscall__(2,115) VDI(VDIPB *);
#elif __PUREC__
void VdiTrap1(VDIPB *) 0x7073;			/* moveq  #115,d0 */
void VdiTrap2(void   ) 0x2208;			/* move.l a0,d1   */
void VdiTrap3(void   ) 0x4E42;			/* trap   #2      */

#define VDI(a) VdiTrap1(a);\
               VdiTrap2();\
               VdiTrap3()
#else
void VDI(VDIPB *);
#endif

short vdi_string(const char *fro, short *to, short max);

#endif
