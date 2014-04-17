;*************************************************************************
;	GEMSTART.S			9/24/92		D.Mui
;	Added sysbase				12/7/90	D.Mui

	.text

	.globl	_d_rezword
	.globl	_main
	.globl	_gl_doitonce
	.globl	_set_up
	.globl	_justretf
	.globl	_drwaddr
	.globl	_tikcod
	.globl	_tikaddr
	.globl	_gl_restype
	.globl	_gl_rschange
	.globl	_clr_theglo
	.globl	_ad_envrn
	.globl	_autoexec	
	.globl	_sh_iscart
	.globl	gemstart
	.globl	_sysbase
	.globl	longframe
	.globl	_cMiNT
;	.globl	_setuser
	.globl	_gl_port
	.globl	_gl_debug
	
long_frame	= $59e			; BIOS system variable...

;
;
;  Must be first object file in link statement
;	Do setblock call to free up memory
;
gemstart:
	move.l	a7,a5		; save stack
	move.l	#ustak, a7	; switch stacks, dos needs a user stack 
	move.l	4(a5),a5	; basepage address
	move.l	a5,_sysbase	; basepage 
;	or.l	#7,$28(a5)	; prgflags in basepage
	move.l	$c(a5),d0	; textlen
	add.l	$14(a5),d0	; datalen
	add.l	$1c(a5),d0	; bsslen
	add.l	#$100,d0	; skip los pageos baseos
	move.l	d0,-(a7)	; size
	move.l	a5,-(a7)	; basepage
	move	d0,-(a7)	; junk word
	move	#$4a,-(a7)	; Mshrink
	trap	#1
	add.l	#12,a7

	clr.l	-(a7)		; Super(0L)
	move.w	#32,-(a7)	; Go into supervisor mode
	trap	#1
	addq	#6,a7
	move.l	d0,oldsuper

	move.w	#2,_gl_port
	clr.w	_gl_debug

;	Check the MiNT cookie at here

	jsr	_cMiNT		; check the MiNt
; Old code: if MiNT not present, print error message and exit
;	bne	g1
;	move.l	#NoMiNt,-(sp)
;	move.w	#9,-(sp)
;	trap	#1
;	addq.l	#6,sp
;	bra	exit
;g1:
;
; There's no need to set exec_os, MiNT or TOS already did so
; ++ERS 2/17/93
;
;	move.l	gemstart,$4fe	; exec_os 6/23/92
;
; Here we munge the environment so the hard disk gets searched, if present,
; by shel_path.  This is for compatibility with the old shel_path, which
; didn't really use the path, but looked on C:\ anyways.
; You're welcome, Allan.
; (880825 kbad)
;
	movea.l	$2c(a5),a0		; save the environment pointer
	move.l	a0,_ad_envrn
	move.l	$4c2,d0			; get drvbits
	and.l	#$4,d0			; drive C there?
	beq.b	not_ours		; nope, leave the env alone
	cmp.l	#'PATH',(a0)+		; check 1st longword
	bne.b	not_ours
	cmp.l	#$3d00413a,(a0)+	; "=0A:"
	bne.b	not_ours

; section changed 8/9/90 AKP

	move.l	(a0),d0			; get last long to d0
	clr.b	d0			; clear last byte so it's "don't care"
	cmp.l	#$5c000000,d0		; check for "\00"
	bne.b	not_ours
	move.b	#'C',-2(a0)		; make it PATH=0C:\00

; end section changed

not_ours:				; only do it once
	move.w	#1,d0
	move.w	d0,_gl_restype		; default resolution
	move.w	d0,_autoexec		; turn on auto exec
	move.w	d0,_gl_doitonce

	clr.w	_gl_rschange		; Clear out resolution globals	
	clr.w	_sh_iscart
	move.w	long_frame,longframe
	move.w	#$82,_d_rezword

	jsr	_set_up			; init all the process
	move.l	d0,a7			; stack pointer
repeat:					; This is a loop
	jsr	_clr_theglo		; clean up THEGLO
	move.l	#_justretf,_drwaddr	; initialize some bss pointers
	move.l	#_tikcod,_tikaddr
	jsr	_main			; go to AES main
	bra	repeat			; loop forever

exit:
	clr.w	-(sp)
	move.w	#$4c,-(sp)		; terminate the AES
	trap	#1			; Bye


;	Go to user mode or supervisor mode
;_setuser:
;	tst.w	4(sp)
;	beq	s_1			; restore to Super mode
;	move.l	sp,savesp
;	move.l	#xxx,-(sp)
;	move.w	#$20,-(sp)
;	trap	#1			; to user mode
;	addq.l	#6,sp
;	rts			
;
;s_1:
;	move.l	savesp,-(sp)
;	move.w	#$20,-(sp)
;	trap	#1
;	rts



	.data

NoMiNt:	dc.b	'No MiNT kernel in the system!',0xa,0xd,0

	.bss
		.ds.l	300
xxx:		.ds.l	1
		.ds.l	300
ustak:		.ds.l	1
_sysbase:	.ds.l	1
longframe:	.ds.w	1
oldsuper:	.ds.l	1
savesp:		.ds.l	1

	.end
