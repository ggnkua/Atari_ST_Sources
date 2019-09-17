*****************************************************************
*								*
*	NOLOCK							*
*								*
* After this program is executed, the CapsLock key will have	*
* no effect, provided the keyboard translation table is set	*
* only by calls to Keytbl() and Bioskeys().  You can still set	*
* the tables by setting pointers into the vector whose address	*
* is returned by Keytbl().					*
*								*
* Written for jas (Sozobon assembler).  Thanks to Abacus's	*
* "Atari ST Internals" for insights.				*
*								*
* Copyright (c) 1989, David Brooks, All Rights Reserved.  Use	*
* and distribute freely.					*
*								*
*****************************************************************
*
*
* Some constant definitions (trap codes mainly)
*

GEMDOS		equ	1
BIOS		equ	13
XBIOS		equ	14
Keytbl		equ	16
Bioskeys	equ	24
Setexec		equ	5
Keep		equ	$31

XBIOSV		equ	46
XBIOSVAD	equ	$b8

sbit		equ	13		* Supervisor status bit

Magicnum	equ	$44424e4c	* 'DBNL' must be just before trapad
*
* Program starts here.  It's all one text section, as we need to
* intermix code and data.  The initialization is at the end, and
* will be handed back to GEMDOS.
*

start:		bra	setup

*
* Static data:
*

transp:		ds.l	1		* Will point to table ptr vector
normp:		ds.l	1		* Default non-shift table
shiftp:		ds.l	1		* Default shifted table
trap14:		ds.l	1		* Replaced xbios vector

magic:		dc.l	Magicnum

*
* Here's the xbios trap
*

trapad:
		lea	6(a7),a0	* Point to args if in super mode
		btst	#sbit,(a7)
		bne	checkcodes
		dc.w	$4e68		* move.l  USP,a0 -- Point to args
					*  if in user mode
checkcodes:
		cmpi.w	#Bioskeys,(a0)
		beq	dobioskeys
		cmpi.w	#Keytbl,(a0)+
		beq	dokeytbl

		move.l	trap14,a0	* Go to standard trap handler
		jmp	(a0)
*
* One of these routines for Bioskeys or Keytbl
*
dobioskeys:
		move.l	transp,a1	* No args, no return.  Just
		move.l	normp,d0	*  set the table to norm, shift, norm
		move.l	d0,(a1)+
		move.l	shiftp,(a1)+
		move.l	d0,(a1)
		rte

dokeytbl:
		move.l	transp,d0	* Three args, returns address of vector
		move.l	d0,a1
		move.l	(a0)+,d1
		bmi	nostd
		move.l	d1,(a1)		* put arg1 into standard and capslock
		move.l	d1,8(a1)
nostd:
		move.l	(a0),d1		* put arg2 into shift
		bmi	noshift
		move.l	d1,4(a1)
noshift:
		rte
keeptop:				* Top of kept memory

*
* Setup code.  The stack will be at tpa, and can be somewhat abused.
* 4(sp) points to the basepage.  All of this can be done in user
* mode.
*

setup:
		move.l	4(sp),a4
*
* First we look for our magic number.
*
		moveq.l	#-1,d5
		move.l	d5,(sp)
		move.w	#XBIOSV,-(sp)
		move.w	#Setexec,-(sp)
		trap	#BIOS		* Setexec(46, -1L)
		move.l	d0,a0		* Check current vector
		cmpi.l	#Magicnum,-(a0)
		beq	quickexit	* Already installed

*
* Locate the original (actually, the current) key table vector and the two
* interesting pointers.  d5 has -1L (see above).
*
		move.l	d5,(sp)
		move.l	d5,-(sp)
		move.l	d5,-(sp)
		move.w	#Keytbl,-(sp)	* addr = Keytbl(-1L, -1L, -1L)
		trap	#XBIOS
		move.l	d0,transp	* Save the vector pointer
		move.l	d0,a0
		move.l	(a0)+,d1	* Save the normal table address
		move.l	d1,normp
		move.l	(a0)+,shiftp	* Save the shift table address
		move.l	d1,(a0)		* Set capslock = normal
*
* Insinuate our code in the trap 14 vector
*
		pea	trapad
		move.w	#XBIOSV,-(sp)
		move.w	#Setexec,-(sp)
		trap	#BIOS		* Setexec(46, trapad)
		move.l	d0,trap14	* Save old vector
*
* Exit, keeping the active code
*
		lea	keeptop,a0
		sub.l	a4,a0		* keeptop - basepage
		clr.w	(sp)
		move.l	a0,-(sp)
		move.w	#Keep,-(sp)
		trap	#GEMDOS		* Keep(nbytes, 0)

*
* Come here if already installed for immediate exit
*
quickexit:
		clr.w	(sp)
		trap	#GEMDOS

		end


