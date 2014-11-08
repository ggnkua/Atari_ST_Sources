/*
 * $Id: sysvars.h pdonze Exp $
 * 
 * TOS.LIB - (c) 1998 - 2006 Philipp Donze
 *
 * A replacement for PureC PCTOSLIB.LIB
 *
 * This file is part of TOS.LIB and contains addresses of documented system
 * variables. (access only in supervisor mode!)
 *
 * TOS.LIB is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * TOS.LIB is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with the GNU C Library; see the file COPYING.LIB.  If not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

#ifndef _SYSVARS_H
# define _SYSVARS_H

#define PROC_LIVES_MAGIC 0x12345678L
#define	proc_lives	(unsigned long *)0x0380
#define	proc_dregs	(unsigned long *)0x0384
#define	proc_aregs	(unsigned long *)0x03A4
#define	proc_enum	(unsigned long *)0x03C4
#define	proc_usp	(unsigned long *)0x03C8
#define	proc_stk	(unsigned long *)0x03CC

#define	etv_timer	(void (**)())0x0400
#define	etv_critic	(void (**)())0x0404
#define	etv_term	(void (**)())0x0408
#define	etv_xtra	(unsigned long *)0x040C

#define MEMVALID_MAGIC 0x752019F3L
#define	memvalid	(unsigned long *)0x0420
#define	memcntrl	(unsigned char *)0x0424

#define RESVALID_MAGIC	0x31415926L
#define	resvalid	(unsigned long *)0x0426
#define	resvector	(void (**)())0x042A

#define	phystop		(unsigned long *)0x042E
#define	_membot		(unsigned long *)0x0432
#define	_memtop		(unsigned long *)0x0436
#define MEMVAL2_MAGIC 0x237698AAL
#define	memval2		(unsigned long *)0x043A

#define	flock		(short *)0x043E
#define	seekrate	(short *)0x0440
#define	_timr_ms	(short *)0x0442
#define	_fverify	(short *)0x0444
#define	_bootdev	(short *)0x0446

#define	palmode		(short *)0x0448
#define	defshiftmd	(unsigned char *)0x044A
#define	sshiftmd	(char *)0x044C
#define	_v_bas_ad	(void **)0x044E
#define	vblsem		(short *)0x0452
#define	nvbls		(short *)0x0454
#define	_vblqueue	(void (***)())0x0456
#define	colorptr	(short **)0x045A
#define	screenpt	(void **)0x045E
#define	_vbclock	(unsigned long *)0x0462
#define	_frclock	(unsigned long *)0x0466

#define	hdv_init	(void (**)())0x046A
#define	swv_vec		(void (**)())0x046E
#define	hdv_bpb		(void (**)())0x0472
#define	hdv_rw		(void (**)())0x0476
#define	hdv_boot	(void (**)())0x047A
#define	hdv_mediach	(void (**)())0x047E

#define	_cmdload	(short *)0x0482
#define	conterm		(char *)0x0484
#define	trp14ret	(long *)0x0486	/* undef */
#define	criticret	(long *)0x048A	/* undef */
#define	themd		(void **)0x048E	/* points to MD struct */
#define	_____md		(long *)0x049E	/* undef */
#define	savptr		(unsigned long **)0x04A2
#define	_nflops		(short *)0x04A6
#define	con_state	(long *)0x04A8
#define	sav_row		(short *)0x04AC
#define	sav_context	(long *)0x04AE
#define	_bufl		(void **)0x04B2

#define	_hz_200		(long *)0x04BA

#define	the_env		(long *)0x04BE
#define	_drvbits	(long *)0x04C2
#define	_dskbufp	(long *)0x04C6
#define	_autopath	(long *)0x04CA
#define	_vbl_list	(long *)0x04CE
#define	prt_cnt		(short *)0x04EE
#define	_prtabt		(short *)0x04F0

#define	_sysbase	(long *)0x04F2
#define	_shell_p	(void (**)())0x04F6
#define	end_os		(void **)0x04FA
#define	exec_os		(long *)0x04FE
#define	scr_dump	(void (**)())0x0502
#define	prv_lsto	(void (**)())0x0506
#define	prv_lst		(void (**)())0x050A
#define	prv_auxo	(void (**)())0x050E
#define	prv_aux		(void (**)())0x0512

/* Structure installed by AHDI compatible driver */
typedef struct
{
	short puns;						/* number of devices */
	char pun[16];					/* flags */
	long part_start[16];			/* start of partitions */
	long P_cookie;					/* should be 'AHDI' */
	long *P_cookptr;				/* pointer to previous? */
	unsigned short P_version;		/* 0x0300 or higher */
	unsigned short P_max_sector;	/* maximum sector size */
	long reserved[16];
} PUN_INFO;
#define	pun_ptr		(PUN_INFO **)0x0516

#define MEMVAL3_MAGIC 0x5555AAAAL
#define	memval3		(long *)0x051A

#define	xconstat	(long *)0x051E
#define	xconin		(long *)0x053E
#define	xcostat		(long *)0x055E
#define	xconout		(long *)0x057E
#define	_longframe	(short *)0x059E
#define	_p_cookies	(long **)0x05A0

#define RAMVALID_MAGIC 0x1357BD13L
#define	ramtop		(long *)0x05A4
#define	ramvalid	(long *)0x05A8

#define	bell_hook	(void (**)())0x05AC
#define	kcl_hook	(void (**)())0x05B0

#endif      /* _SYSVARS_H */
