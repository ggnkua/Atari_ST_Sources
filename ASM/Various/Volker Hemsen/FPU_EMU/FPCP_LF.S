; PRTKL881 - Protokoll fÅr M68881 - Version 2.0
; programmiert von Volker Hemsen, August 1993, Public Domain

; Dieses Programm ist Public Domain! Es ist unverkÑuflich und darf von jeder-
; man benutzt und kopiert werden. Es ist unverkÑuflich!
; Hiermit wird ausdrÅcklich erlaubt, den Quellcode zu verÑndern und zu
; erweitern!
; verwendete Literatur: Atari Profibuch ST-STE-TT, Sybex Verlag

; 1995 H.Robbers; Verwendete Literatur:
;		MOTOROLA
;		MC68881/MC68882 Floating point Coprocessor User's Manual

;		Prentice Hall   ISBN 0-13-566936-7

		globl	FPEM_lineF,FPEM_oldF,linef_on,linef_off

LINE_F	equ		0x2c

		data
cookval:
		dc.l	1

already:
		dc.b	'But already installed',0xd,0xa,0
niet:
		dc.b	'But no suitable environment',0xd,0xa,0
hallo:
		dc.b	0xd,0xa,0x1b,'pFPEM - line F interface for peripheral type '
		dc.b	'MC68881',0xd,0xa,0x1b,'q'
		dc.b	'by Volker Hemsen & Henk Robbers 1993/1995 PD',0xd,0xa,0

		bss
retain:
		ds.l	1

		text
		movea.l	4(sp),a0		; Adresse der Basepage
		move.l	#$0100,d0		; LÑnge der Basepage
		add.l	$0C(a0),d0		; LÑnge des Textsegmentes
		add.l	$14(a0),d0		; LÑnge des Datasegmentes
		add.l	$1C(a0),d0		; LÑnge der BSS
		move.l	d0,retain

		pea		hallo
		move  	#9,-(sp)
		trap	#1
		addq.l	#6,sp

		move.l	#'_FPU',d0
		lea		cookval,a0
		jsr		get_cookie
		tst		d0
		beq		NEE
; If there is NO _FPU cookie AT all,
; there may be a peripheral type FPU, but there is surely NO TOS 2.0x or higher
; in the machine. So line F is engaged by the TOS

		andi.l	#0x10000,cookval
		cmpi.l	#0x10000,cookval	; Is it a SFP 004 or compatible
		bne		NEE

		move.l	#1,d1			; cookie anlegen (Pure C call) value 2 is for the software emulater; Later
		move.l	#'FPCP',d0
		jsr		new_cookie
		tst		d0
		bne		JA
		pea		already
		bra		NEEE

NEE:	pea		niet
NEEE:	move  	#9,-(sp)		; Cconws
		trap	#1
		addq.l	#6,sp

		move.l	#0x20002,-(sp)	; Bconin(2)
		trap	#13
		addq.l	#4,sp

		move	#1,-(sp)		; Pterm
		move	#0x4c,-(sp)
		trap	#1
		
JA:
;		move.l	#0x20002,-(sp)	; Bconin(2)
;		trap	#13
;		addq.l	#4,sp

		bsr 	linef_on

		clr  	-(sp)			; Returnparameter
		move.l	retain,-(sp)	; LÑnge Åbergeben
		move  	#$31,-(sp)		; Ptermres()
		trap	#1


linef_patch:
		move.l	LINE_F,FPEM_oldF
		move.l	#FPEM_lineF,LINE_F
		rts

linef_unpatch:
		move.l  FPEM_oldF,LINE_F
		rts

linef_on:
		pea		linef_patch(pc)
		move  	#$26,-(sp)		; XBIOS 38 Supexec
		trap	#14
		addq.l	#6,sp
		rts

linef_off:
		pea		linef_unpatch(pc)
		move  	#$26,-(sp)		; XBIOS 38 Supexec
		trap	#14
		addq.l	#6,sp
		rts
