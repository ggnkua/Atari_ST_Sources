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

#ifndef __AESPB_H__
#define __AESPB_H__

#define SMURF 0		/* new bindings according to SMURF */

#define G_decl					/* define as cdecl if parameters on stack */
#define __WGS_ELLIPSISD__ 1 	/* define this as 1 if you use the 'ellipsis'd version of wind_get & wind_set */
#define DYNAMIC 0

typedef union
{
	void *spec;			/* PC_GEM */
	long l;
	short pi[2];
} private;

/* At last give in to the fact that it is a struct, NOT an array */
typedef struct aes_global
{
	short		version,
				count,
				id;
	private *	pprivate;
	void **		ptree;
	void * 		pmem;
	short		lmem,
				nplanes,
				res1, res2,
				bvdisk, bvhard;
} GLOBAL;

#define pglob (_GemParBlk.glob)

typedef struct
{
	short fu,
	      nintin,
	      nintout,
	      naddrin,
	      naddrout;
} ACTL;

typedef struct
{
	ACTL *   contrl;
	GLOBAL * pglobal;
	short *  intin;
	short *  intout;
	void *   addrin;
	void *   addrout;
} AESPB;

/* #define G_c(f,ii,io,ai,ao) static G_i c[]={f,ii,io,ai,ao} */

#if DYNAMIC
#define SETACTL(f, ii, io, ai, ao) ACTL c;\
                               AESPB pb;\
                               c.fu = f;\
                               c.nintin=ii;\
                               c.nintout=io;\
                               c.naddrin=ai;\
                               c.naddrout=ao
#else	/* static */
#define SETACTL(f, ii, io, ai, ao) static ACTL c={f,ii,io,ai,ao}; AESPB pb
#endif

#define G_trap(c,p,q,r,s,t) pb.contrl=&c,\
                            pb.pglobal=&p,\
                            pb.intin=q,\
                            pb.intout=r,\
                            pb.addrin=s,\
                            pb.addrout=t,\
                            AES(&pb);

typedef struct
{
	short	x, y, bstate, kstate;
} EVNTDATA;

typedef struct grect
{
	short x, y, w, h;
} RECT;

typedef struct
{
	short out, x, y, w, h;
} MOBLK;

typedef enum
{
	MU_KEYBD =0x0001,
	MU_BUTTON=0x0002,
	MU_M1	 =0x0004,
	MU_M2	 =0x0008,
	MU_MESAG =0x0010,
	MU_TIMER =0x0020
} EVENT_TY;

typedef struct
{
	short	contrl[15];
	GLOBAL	glob;
	short	intin[132];
	short	intout[140];
	void   *addrin[16];
	void   *addrout[16];
} GEMPARBLK;				/* For Pure C */

extern  GEMPARBLK _GemParBlk;

extern  short _app, gl_apid, gl_version;

short vq_aes( void );

#if __AHCC__
void __syscall__(2,200)AES(AESPB *);
#elif __PUREC__
void  AesTrap1(AESPB *) 0x303C;			/* move  #200,d0 */
void  AesTrap2(void   ) 0x00C8;
void  AesTrap3(void   ) 0x2208;			/* move.l a0,d1   */
short AesTrap4(void   ) 0x4E42;			/* trap   #2      */

#define AES(a) AesTrap1(a);\
               AesTrap2();\
               AesTrap3();\
               AesTrap4()
#else
void AES(AESPB *);
#endif

#endif
