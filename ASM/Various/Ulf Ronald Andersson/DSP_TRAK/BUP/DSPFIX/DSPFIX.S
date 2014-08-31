;----------------------------------------------------------------------------
;File name:	DSPFIX.S			Revision date:	1999.09.18
;Created by:	Ronald Andersson		Creation date:	1999.09.18
;----------------------------------------------------------------------------
;Credits:
;
;This source was based on information released by 'NoCrew Laboratories' in
;their file 'dsp.s' which I found in the release archive of a mod-player
;named DUMP.  Their comments to that source are reproduced below, on the
;comment lines starting with double semicolons:
;
;----- NoCrew comments start -----
;; COPYRIGHT (c) 1998 by NoCrew Laboratories.
;;
;; Implements:
;;
;;     extern Int dsp_load_program(Byte *program, Int length);
;;
;; Where length is the number of DSP words (e.i. 3 byte tuples).
;; A return value of 1 means that the loading was sucessful. 0
;; means something went wrong.
;;
;; This module will always load the DSP program. It is compatible
;; with the Dsp_ExecProg loader. However, as it reloads the DSP
;; bootstrap code every time -- which the TOS version does not --
;; this one does not freeze up.
;----- NoCrew comments end  -----
;
;Copyright being what it is, it does not apply to the knowledge itself but
;only to a specific rendering of it, so as my program renders it somewhat
;differently, it is a new copyright entity.
;(Some people want it differently, but that requires patent, not copyright.)
;----------------------------------------------------------------------------
	IFND	hw_psgsel
hw_psgsel	=	$ffff8800
hw_psgrd	=	$ffff8800
hw_psgwr	=	$ffff8802
	ENDC
;-------
	IFND	hw_dsp_ic
hw_dsp_ic	=	$ffffa200
hw_dsp_cv	=	$ffffa201
hw_dsp_is	=	$ffffa202	;DSP interface status
hw_dsp_iv	=	$ffffa203
hw_dsp_long	=	$ffffa204	;top byte is ignored
hw_dsp_d2	=	$ffffa205	;byte<<(2*8) == MSB
hw_dsp_d1	=	$ffffa206	;byte<<(1*8)
hw_dsp_d0	=	$ffffa207	;byte<<(0*8) == LSB
	ENDC
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
;The table 'bra_table' below allows this module to be used as a precompiled
;binary, for use with other programming languages.  To ensure compatibility
;all of the functions protect registers compatibly to Pure_C. In fact, except
;for the function dspfix_ExecProg, they actually protect *all* registers. To
;make inline inclusion of this code possible for any program, the functions
;use purely position-independent code, requiring no relocation at all.
;----------------------------------------------------------------------------
bra_table:
	bra.w	dspfix_ExecProg		;offset	 0 => dspfix_ExecProg(short length, char *dsp_program)
	bra.w	dspfix_reinit		;offset  4 => dspfix_reinit()
	bra.w	dspfix_reset		;offset  8 => dspfix_reset()
	bra.w	dspfix_bootstrap	;offset 12 => dspfix_bootstrap()
;----------------------------------------------------------------------------
;Note that the functions use flags intelligently to protect against being
;used in a wrong manner.  So calling dspfix_ExecProg twice in a row will
;automatically invoke 'dspfix_reinit' in the second of the calls, to
;ensure that the DSP bootstrap code is reloaded properly.
;----------------------------------------------------------------------------
dspfix_reinit:
	bsr.s	dspfix_reset
	bsr.s	dspfix_bootstrap
	rts
;-------------------------------------
dspfix_reset:
	movem.l	d0-d1/a0,-(sp)		;push entry registers
	move	sr,d1			;save int_mask in d1
	or	#$0700,sr		;block interrupts
	move.b	#14,(hw_psgsel).w	;select PSG port A
	move.b	(hw_psgrd).w,d0		;d0 = port A data
	and.b	#$EF,d0			;clr DSP bit in d0
	move.b	d0,(hw_psgwr).w		;write d0 to port A
	or.b	#$10,d0			;set DSP bit in d0
	move.b	d0,(hw_psgwr).w		;start DSP power-down
	move	d1,sr			;restore entry int_mask
	move.w	#10000-1,d0		;d0 = power-down
.power_down_loop:			;loop start
	nop					;wait for powerdown to complete
	dbra	d0,.power_down_loop	;loop back
	move	sr,d1			;save int_mask in d1
	or	#$0700,sr		;block interrupts
	move.b	#14,(hw_psgsel).w	;select PSG port A
	move.b	(hw_psgrd).w,d0		;d0 = port A data
	and.b	#$EF,d0			;clr DSP bit in d0
	move.b	d0,(hw_psgwr).w		;start DSP power-up
	move	d1,sr			;restore entry int_mask
	lea	dspfix_ready_f(pc),a0	;a0 -> dspfix_ready_f
	sf	(a0)			;clear dspfix_ready_f (not ready for ExecProg)
	st	1(a0)			;set dspfix_reset_f (ready for bootstrap)
	movem.l	(sp)+,d0-d1/a0		;pull entry registers
	rts				;return
;-------------------------------------
dspfix_bootstrap:			;Load DSP bootstrap code.
	movem.l	d0-d1/a0-a2,-(sp)	;push entry registers
	move.b	dspfix_reset_f(pc),d1	;test dspfix_reset_f (NE means ready for bootstrap)
	bne.s	.DSP_is_ready		;continue directly if DSP is ready for it
	bsr.s	dspfix_reset		;else reset DSP first
.DSP_is_ready:
	lea	bootstrap_beg(pc),a0	;a0 -> bootstrap code for DSP
	lea	(hw_dsp_d2).w,a2	;a2 -> MSB of DSP transfer register
	move	#bootstrap_cnt-1,d0	;d0 = length of non-zero bootstrap head
.copy_loop:				;loop start for copying bootstrap head
	btst.b	#1,(hw_dsp_is).w		;test DSP readiness for data
	beq.s	.copy_loop		;loop back if not ready for data
	move.l	a2,a1				;a1 -> MSB of DSP transfer register
	move.b	(a0)+,(a1)+			;transfer MSB
	move.b	(a0)+,(a1)+			;transfer middle byte
	move.b	(a0)+,(a1)+			;transfer LSB
	dbra	d0,.copy_loop		;loop back to copy entire bootstrap head
	move	#boot_pad_cnt-1,d0	;d0 = length of bootstrap tail (zeroes)
.pad_loop:				;loop start for padding zeroes to bootstrap tail
	btst.b	#1,(hw_dsp_is).w		;test DSP readiness for data
	beq.s	.pad_loop		;loop back if not ready for data
	move.l	a2,a1				;a1 -> MSB of DSP transfer register
	clr.b	(a1)+				;transfer zero MSB
	clr.b	(a1)+				;transfer zero middle byte
	clr.b	(a1)+				;transfer zero LSB
	dbra	d0,.pad_loop		;loop back to pad entire tail
	lea	dspfix_ready_f(pc),a0	;a0 -> dspfix_ready_f
	st	(a0)			;set dspfix_ready_f (ready for ExecProg)
	sf	1(a0)			;clear dspfix_reset_f (not ready for bootstrap)
	movem.l	(sp)+,d0-d1/a0-a2	;pull entry registers
	rts				;return
;-------------------------------------
dspfix_ExecProg:			;a0 -> program,  d0 = length (in DSP words)
	subq.w	#1,d0			;prepare d0 for use as dbra counter
	ble.s	.bad_length		;abort if length <= zero
	move.b	dspfix_ready_f(pc),d1	;test dspfix_ready_f (NE means ready for ExecProg)
	bne.s	.DSP_is_ready		;continue directly if DSP is ready for it
	bsr	dspfix_reinit		;else reinitialize DSP first
.DSP_is_ready:
	move.l	a2,-(sp)		;push entry a2
	lea	(hw_dsp_d2).w,a2	;a2 -> MSB of DSP transfer register
.copy_loop:				;loop start for copying
	btst.b	#1,(hw_dsp_is).w		;test DSP readiness for data
	beq.s	.copy_loop		;loop back if not ready for data
	move.l	a2,a1				;a1 -> MSB of DSP transfer register
	move.b	(a0)+,(a1)+			;transfer MSB
	move.b	(a0)+,(a1)+			;transfer middle byte
	move.b	(a0)+,(a1)+			;transfer LSB
	dbra	d0,.copy_loop		;loop back to copy entire program
.launch_loop:				;loop start for launch delay
	btst.b	#1,(hw_dsp_is).w		;test DSP readiness for launch
	beq.s	.launch_loop		;loop back until ready
	move.l	#3,(hw_dsp_long).w	;launch DSP program
	move.l	(sp)+,a2		;pull entry a2
	lea	dspfix_ready_f(pc),a0	;a0 -> dspfix_ready_f
	sf	(a0)			;clear dspfix_ready_f (not ready for new ExecProg)
	sf	1(a0)			;clear dspfix_reset_f (not ready for bootstrap)
	moveq	#1,d0			;d0 = success flag for caller
	rts				;return
;-------
.bad_length:
	moveq	#0,d0			;d0 = failure flag for caller
	rts				;return
;----------------------------------------------------------------------------
dspfix_ready_f:				;flags readiness for ExecProg
	dc.b	$00			;$00 == not_ready  $FF == ready
dspfix_reset_f:				;flags readiness for bootstrap
	dc.b	$00			;$00 == not_ready  $FF == ready
;-------
	EVEN
;----------------------------------------------------------------------------
bootstrap_beg:
		dc.b	$0C,$00,$40,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	$00,$00,$60,$F4,$00,$00,$00,$4F,$61,$F4
		dc.b	$00,$00,$7E,$A9,$06,$2E,$80,$00,$00,$47
		dc.b	$07,$D8,$84,$07,$59,$84,$08,$F4,$A8,$00
		dc.b	$00,$04,$08,$F4,$BF,$00,$0C,$00,$00,$FE
		dc.b	$B8,$0A,$F0,$80,$00,$7E,$A9,$08,$F4,$A0
		dc.b	$00,$00,$01,$08,$F4,$BE,$00,$00,$00,$0A
		dc.b	$A9,$80,$00,$7E,$AD,$08,$4E,$2B,$44,$F4
		dc.b	$00,$00,$00,$03,$44,$F4,$45,$00,$00,$01
		dc.b	$0E,$A0,$00,$0A,$A9,$80,$00,$7E,$B5,$08
		dc.b	$50,$2B,$0A,$A9,$80,$00,$7E,$B8,$08,$46
		dc.b	$2B,$44,$F4,$45,$00,$00,$02,$0A,$F0,$AA
		dc.b	$00,$7E,$C9,$20,$00,$45,$0A,$F0,$AA,$00
		dc.b	$7E,$D0,$06,$C6,$00,$00,$7E,$C6,$0A,$A9
		dc.b	$80,$00,$7E,$C4,$08,$58,$6B,$0A,$F0,$80
		dc.b	$00,$7E,$AD,$06,$C6,$00,$00,$7E,$CD,$0A
		dc.b	$A9,$80,$00,$7E,$CB,$08,$58,$AB,$0A,$F0
		dc.b	$80,$00,$7E,$AD,$06,$C6,$00,$00,$7E,$D4
		dc.b	$0A,$A9,$80,$00,$7E,$D2,$08,$58,$EB,$0A
		dc.b	$F0,$80,$00,$7E,$AD
bootstrap_end:
bootstrap_cnt	=	(bootstrap_end-bootstrap_beg)
boot_pad_cnt	=	512-bootstrap_cnt
;----------------------------------------------------------------------------
;End of file:	DSPFIX.S
;----------------------------------------------------------------------------
