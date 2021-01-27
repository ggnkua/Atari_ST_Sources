/* This file is part of the AHCC C Library.

   The AHCC C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public License as
   published by the Free Software Foundation; either version 2 of the
   License, or (at your option) any later version.

   The AHCC C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with the GNU C Library; see the file COPYING.LIB.  If not,
   write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.
*/


/*	AHCSTART.C	Startup module for C programs using AHCCLIB	*/

#ifndef __AHCC__
#error This file can only be compiled by AHCC
#endif

typedef void VpV(void);
#define nil 0L

#include <basepage.h>

short __bss;
BASEPAGE *_base, *_BasPag;
short _app, errno;
void *etext, *edata, *ebss, *_break;

short __data = 0;
short _argc = 0;
char **_argv = nil,
     *_envp = nil,
     *_StkLim,
     EmpStr[2] = "";
long _PgmSize;

VpV *_AtExitVec = nil, *_FilSysVec = nil;
char **__EnvStrPtr = nil;

enum
{
	MINSTK = 4096,
	MARGIN = 512
};

#define BP BASEPAGE

void __asm__ __text(void)
{
	import _StkSize
	export exit, __exit
*
* save initial stack and basepage pointers
*
	move.l	a0,a3
	move.l	a3,d0
	bne 	ACC
	move.l	4(sp),a3		; a3 = basepage address
	moveq	#1,d0			; program is application
	bra.s	APP
ACC:
	clr 	d0				; program is accessory
APP:
	move	d0,_app

	move.l	a3,_base
	move.l	a3,_BasPag
	move.l	BP @ p_tbase(a3),a0
	add.l	BP @ p_tlen(a3),a0
	move.l	a0,etext		; end of text segment
	move.l	BP @ p_dbase(a3),a0
	add.l	BP @ p_dlen(a3),a0
	move.l	a0,edata		; end of data segment
	move.l	BP @ p_bbase(a3),a0
	add.l	BP @ p_blen(a3),a0
	move.l	a0,ebss			; end of BSS (end of program)
	sub.l	#_StkSize,a0
	move.l	a0,_break;		; set initial _break value
	move.l	a0,_PgmSize
	move.l	BP @ p_env(a3),d0
	move.l	d0,_envp	; save environment pointer
	move.l	d0,__EnvStrPtr  ; Pure C

* Setup longword aligned application stack

	move.l	BP @ p_tlen(a3),a0
	add.l	BP @ p_dlen(a3),a0
	add.l	BP @ p_blen(a3),a0
	add.l	#sizeof(BASEPAGE),a0
	nop					; sometimes strange behaviour
	move.l	a3,d0
	add.l	a0,d0
	and.l	#-4,d0
	move.l	d0,sp

* check application flag

	tst.w	_app
	beq 	CallMain		;  No environment and no arguments

* Free not required memory

	move.l	a0,-(sp)
	move.l	a3,-(sp)
	move.w	#0,-(sp)
	move.w	#74,-(sp)
	trap	#1				; Mshrink
	lea.l	12(sp),sp

* scan environment

	move.l	sp, d0
	sub.l	#_StkSize-4, d0
	and.l	#-4, d0
	move.l	d0, a1
	move.l	a1, a4			; this is envp
	move.l	BP @ p_env(a3), a2
	move.b	BP @ p_cmdlin(a3), d5
	move.b	#'=', d6
	move.l	#'VGRA', d7
	movea.l	sp, a6

ScanEnvLoop:
	move.l  a2, (a1)+
	movea.l	a2, a5
	tst.b	(a2)+
	beq		ScanEnvExit
Start1:
	tst.b	(a2)+
	bne 	Start1

	move.b	(a5)+, -(a6)
	move.b	(a5)+, -(a6)
	move.b	(a5)+, -(a6)
	move.b	(a5)+, -(a6)
	cmp.l	(a6)+, d7		; ARGV ?
	bne		ScanEnvLoop
	cmp.b	(a5), d6		; ARGV= ?
	bne		ScanEnvLoop
	cmp.b	#127, d5		; commandLength == 127 ?
	bne		ScanEnvLoop

	* now we have found extended arguments
	clr.b	-4(a5)
	clr.l	-4(a1)
	move.l	a1, a5			; this is argv
	clr.l	d3				; this is argc
	move.l	a2, (a1)+

xArgLoop:
	tst.b	(a2)+
	bne		xArgLoop
	move.l	a2, (a1)+
	addq.l	#1, d3
	tst.b	(a2)
	bne		xArgLoop
	move.l	a1, a6			; stack limit
	clr.l	-(a1)
	bra		CallMain		; we don't need to parse basepage's tail

ScanEnvExit:
	move.l	a1, a6			; stack limit
	clr.l	-(a1)

* scan commandline
	lea 	BP @ p_cmdlin(a3), a0
	moveq	#1, d3
	moveq	#0, d1
	move.b	(a0), d1
	lea 	1(a0, d1.l), a1
	clr.b	(a1)
	clr.l	-(sp)			; argv[argc] = 0
	bra 	Start5

Start2:						; testing blank (seperator)
	moveq	#' '+1, d0
	cmp.b	(a1), d0
	bls 	Start3
	clr.b	(a1)
	tst.b	1(a1)
	beq 	Start3
	pea 	1(a1)
	addq.l	#1, d3
	bra 	Start5

Start3:						; testing quotation mark
	moveq	#0,d7
	moveq	#'"', d0
	cmp.b	(a1), d0
	beq 	Stx3
	moveq	#39, d0
	cmp.b	(a1), d0		; apostrophe
	bne 	Start5
Stx3:
	move.b	(a1), d7		; remember
	move.b	#0, (a1)

Start4:						; scan previous
	subq.l	#1, a1
	cmp.b	(a1), d7		; remembered quotation " or '
Stx4:
	beq.s	B1
	subq.l	#1, d1
	cmp.l	#-1, d1
	bne 	Start4
B1:
	subq.l	#1, d1
	bmi 	Start6
	pea 	1(a1)
	addq.l	#1, d3
	clr.b	(a1)

Start5:
	subq.l	#1, a1
	subq.l	#1, d1
	cmp.l	#-1, d1
	bne 	Start2

Start6:
	tst.b	1(a1)
	beq 	Start7
	pea 	1(a1)
	addq.l	#1, d3

Start7:
	pea 	EmpStr
	movea.l sp, a5

* calculate stack limit

CallMain:
	LEA		256(A6), A6		; minimum stacksize to call library
	MOVE.L	A6, _StkLim

*	Init stdio

	move.l	init_streams, d0
	beq 	Exite

	move.l	d0,a0
	jsr 	(a0)

Exite:

* Execute main program
*
* Parameter passing:
*   <D0.W> = Command line argument count (argc)
*   <A0.L> = Pointer to command line argument pointer array (argv)
*   <A1.L> = Pointer to tos environment string (env)

	move.l	d3, d0
	move.l	a5, a0
	move.l	a4, a1
	jsr 	main

*
* Terminate program
*
* Entry parameters:
*   <D0.W> = Termination status : Integer

exit:
	move.w	d0,-(sp)

* Execute all registered atexit procedures

	move.l	_AtExitVec,d0
	beq 	__exit

	move.l	d0,a0
	jsr 	(a0)


* Deinitialize file system

__exit:
	move.l	_FilSysVec,d0
	beq 	Exit1

	move.l	d0,a0
	jsr 	(a0)


Exit1:
	move.l	end_streams, d0
	beq 	Exit2

	move.l	d0,a0
	jsr 	(a0)

* Deallocate all heap blocks

Exit2:
*	jsr 	_FreeAll



* Program termination with return code

	move.w	#76,-(sp)
	trap	#1
}

#if REDIRECT
VpV *init_streams = nil;
static VpV split {}
VpV *end_streams  = nil;
#endif
