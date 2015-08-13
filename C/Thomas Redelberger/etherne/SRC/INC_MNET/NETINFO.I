*********************************************************************************
* Declarations for call interface of functions above MIF/XIF in			*
* MagicNet/MintNet								*
*										*
*	Copyright 2001-2002 Dr. Thomas Redelberger				*
*	Use it under the terms of the GNU General Public License		*
*	(See file COPYING.TXT)							*
*										*
* Credits:									*
* Although written in 68000 assembler this source code is based on the source	*
* module netinfo.h of MintNet originally due to Kay Roemer			*
*										*
* Tabsize 8, developed with DEVPAC assembler 2.0.				*
*********************************************************************************
* $Id: netinfo.i 1.1 2002/03/24 14:06:12 Thomas Exp Thomas $
*



* struct netinfo
		OFFSET	0

buf_alloc	DS.l	1
buf_free	DS.l	1
buf_reserve	DS.l	1
buf_deref	DS.l	1

if_enqueue	DS.l	1
if_dequeue	DS.l	1
if_register	DS.l	1
if_input	DS.l	1
if_flushq	DS.l	1

in_chksum	DS.l	1
if_getfreeunit	DS.l	1

eth_build_hdr	DS.l	1
eth_remove_hdr	DS.l	1

ni_fname	DS.l	1

bpf_input	DS.l	1

*
* macro definitions
* Assume the global var netinfo to point to the MNet function structure
*


If_getfreeunit	MACRO
		pea	\1			; name
		move.l	netinfo,a0
		move.l	if_getfreeunit(a0),a0
		jsr	(a0)
		addq	#4,sp			; pop arg
		ENDM


If_register	MACRO
		pea	\1			; nif
		move.l	netinfo,a0
		move.l	if_register(a0),a0
		jsr	(a0)
		addq	#4,sp			; pop arg
		ENDM


If_dequeue	MACRO
		pea	\1			; buf
		move.l	netinfo,a0
		move.l	if_dequeue(a0),a0
		jsr	(a0)
		addq	#4,sp			; pop arg
		ENDM


Buf_alloc	MACRO
		move	\3,-(sp)	; mode
		move.l	\2,-(sp)		; padding front
		move.l	\1,-(sp)		; length
		move.l	netinfo,a0
		movea.l	buf_alloc(a0),a0
		jsr	(a0)
		lea	10(sp),sp		; pop args
		ENDM


Buf_deref	MACRO
		move	\2,-(sp)		; mode
		pea	\1			; buf
		move.l	netinfo,a0
		move.l	buf_deref(a0),a0
		jsr	(a0)
		addq	#6,sp			; pop args
		ENDM


Eth_build_hdr	MACRO
		move	\4,-(sp)		; pktype
		pea	\3			; hwaddr
		pea	\2			; nif
		pea	\1			; buf
		move.l	netinfo,a0
		move.l	eth_build_hdr(a0),a0
		jsr	(a0)
		lea	14(sp),sp		; pop args
		ENDM


Eth_remove_hdr	MACRO
		move.l	RrpBuf,-(sp)		; buf
		move.l	netinfo,a0
		movea.l	eth_remove_hdr(a0),a0	; returns packet type
		jsr	(a0)
		addq.l	#4,sp			; pop arg
		ENDM


Bpf_input	MACRO
		pea	\2			; buf
		pea	\1			; nif
		move.l	netinfo,a0
		move.l	bpf_input(a0),a0
		jsr	(a0)
		addq	#8,sp			; pop args
		ENDM


If_enqueue	MACRO
		move	\3,-(sp)		; info
		pea	\2			; buf
		pea	\1			; if_snd
		move.l	netinfo,a0
		move.l	if_enqueue(a0),a0
		jsr	(a0)
		lea	10(sp),sp		; pop args
		ENDM


If_input	MACRO
		move	\4,-(sp)		; packet type
		move.l	\3,-(sp)		; delay
		pea	\2			; buf
		pea	\1			; nif
		move.l	netinfo,a0
		movea.l	if_input(a0),a0
		jsr	(a0)
		lea	14(sp),sp		; pop args
		ENDM

