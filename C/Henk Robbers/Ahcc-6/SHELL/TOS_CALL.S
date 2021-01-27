
* Copyright (c) 1990 - present by H. Robbers Amsterdam.
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
*

*	Turns the characterstring commandline
*	into an array of pointers to individual arguments

	.data
_module:
	.dc.l	1
_stackp:
	.dc.l   1

EmpStr:
	.dc.b    0
	.even

_savea2:
	.dc.l	0

	.globl	tos_call

	.text
tos_call:						; In this peculiar routine the commandline can be of any length :-)
    move.l  sp,_stackp			; Dont want to know how much stack is to be used
	move.l	a0,_module      	; PC: tos_call(void *proc,COMMAND *cmndlin)

	clr.l	-(sp)				; argv[argc] = nil
	moveq	#0, d1

	move.l	a1, a0
lo:
	move.b (a1)+, d0			; find end of string
	bne.s	lo

* scan commandline

l0:								; MAIN 2 legged loop
	cmpa.l  a0, a1
	ble 	lx
	move.b	-(a1), d0
	cmp.b	#' ', d0			; collapse consecutive spaces
	bne 	l1
	clr.b	(a1)
	bra 	l0

l1:
	cmp.b	#39, d0
	beq 	apo

space:
l2:								; SPACE loop
	cmpa.l  a0, a1
	ble 	lx
	move.b	-(a1), d0
	cmp.b	#' ', d0
	bne 	l2
	pea 	1(a1)
	addq.l	#1,d1				; argc
	clr.b	(a1)				; clear space
	bra 	l0

apo:							; APOSTROPHE loop
	clr.b	(a1)				; clear  apostrophe
l3:
	cmpa.l  a0, a1
	ble 	lx
	move.b	-(a1), d0
	cmp.b	#39, d0
	bne 	l3
	pea 	1(a1)
	addq.l	#1,d1				; argc
	clr.b	(a1)				; clear  apostrophe
	cmpa.l  a0, a1
	ble 	lee					; have them all
	bra 	l0
lx:
	pea 	(a1)				; laatste arg
	addq.l	#1,d1				; argc

lee:
	pea 	EmpStr   		    ; program name (not used)
	addq.l	#1,d1				; argc

******* Execute main program *******************************************
*
* Parameter passing:
*   <d0.w> = Command line argument count (argc)
*   <a0.l> = Pointer to command line argument pointer array (argv)
*   <a1.l> = Pointer to tos environment string (env)

	move.l  d1,d0
	move.l  sp,a0
	suba.l	a1,a1        ; no environment
	move.l	a2,_savea2
	move.l	_module,a2
	jsr     (a2)
	move.l	_savea2,a2
	move.l	_stackp,sp
	rts

