;----------------------------------------------------------------------------
;File name:	RA_KEY.I			Revision date:	1998.08.15
;Creator:	Ulf Ronald Andersson		Creation date:	1993.07.29
;(c)1993 by:	Ulf Ronald Andersson		All rights reserved
;Released as:	FREEWARE			(commercial sales forbidden!)
;----------------------------------------------------------------------------
;File purpose:	Code library for international keyboard access
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	IFND	RA_KEY_defined
RA_KEY_defined	set	1
;----------------------------------------------------------------------------
;	To generate referred routines use:
;
;	make	KEY_links
;----------------------------------------------------------------------------
	include	RA_TOS.I
;----------------------------------------------------------------------------
KEY_links	MACRO
	_unidef	init_mod_key,gen_key
	ENDM
;------------------------------------
init_mod_key	MACRO
	_uniref	init_mod_key
	gemdos	Supexec,init_mod_key_code
	ENDM
;------------------------------------
init_mod_key_code	MACRO
	move.l	(_sysbase).w,a0
	move.l	os_selfbeg_p(a0),a0
	move.l	$24(a0),a1	;->kbshift variable in modern TOS >= 1.4
	cmp	#$0104,2(a0)	;check OS version
	bhs.s	.got_it
	xbios	Keytbl,?,?,?
	move.l	d0,a1
	lea	-1(a1),a1	;NB: In all old TOS Kbshift is at Keytbl-1
.got_it:
	move.l	a1,kbshift_p
	xbios	Keytbl,?,?,?
	move.l	d0,keytbl_ptp
	xbios	Iorec,#1
	move.l	d0,kbd_iorec_p
;Here Keytbl_ptp, kbd_iorec_p and kbshift_p are valid for all Atari TOS
	rts
	ENDM
;------------------------------------
men_key	MACRO
	swap	d0	;d0 = key:ascii.x:y
	lsr.l	#8,d0	;d0 = 0:key.ascii:x
	lsr	#8,d0	;d0 = 0:key.0:ascii
	gen_key
	ENDM
;------------------------------------
gen_key	MACRO
	_uniref	gen_key
	move.l	d0,-(sp)
	gemdos	Supexec,gen_key_code
	addq	#4,sp
	ENDM
;------------------------------------
gen_key_code	MACRO
	tst.l	kbshift_p
	bne.s	.got_init
	init_mod_key
.got_init:
	move.l	8(sp),d0
	bne.s	.fix_key
	gemdos	Crawio,#$FF
	tst.l	d0		;d0 == x:key.y:ascii
	beq.s	.exit
.fix_key:
	swap	d0			;d0 = y:ascii.x:key
	lsl	#8,d0			;d0 = y:ascii.key:0
	move.l	kbshift_p(pc),a1
	move.b	(a1),d0			;d0 = y:ascii.key:shifts
	rol	#8,d0			;d0 = y:ascii.shifts:key
	move	d0,d1			;d1 = shifts:key
	cmp.b	#$73,d1
	blo.s	.keep_key
	beq.s	.fix_ctl_larrow
	cmp.b	#$77,d1
	bhi.s	.fix_alt_numrow
	beq.s	.fix_ctl_clrhome
	cmp.b	#$74,d1
	bne.s	.keep_key
.fix_ctl_rarrow:	;normalize key code of right arrow + Control
	moveq	#$4D,d1
	bra.s	.keep_key
;
.fix_ctl_larrow:	;normalize key code of left arrow + Control
	moveq	#$4B,d1
	bra.s	.keep_key
;
.fix_ctl_clrhome:	;normalize key code of Clr/Home + Control
	moveq	#$47,d1
	bra.s	.keep_key
;
.fix_alt_numrow:	;normalize key codes of digit row + Alternate
	sub.b	#($78-$02),d1
.keep_key:
	and	#$7F,d1			;d1 = adjusted positive key
	move.b	d1,d0
	lsl.l	#8,d0			;d0 = ascii:kbs(5).key:0
	move.l	keytbl_ptp(pc),a1	;a1 -> -> normal keytbl
	move.l	8(a1),a1		;a1 -> capslock keytbl
	move.b	(a1,d1),d0		;d0 = ascii:kbs(5).key:norm
	rol.l	#8,d0			;d0 = kbs(5):key.norm:ascii
	tst.b	d0
	bne.s	.mark_ascii
	lsr	#8,d0			;d0 = kbs(5):key.0:norm
	bne.s	.mark_coerced
.mark_extended:
	move.l	d0,d1
	swap	d1			;d1 = kbs(5):key
	and	#$FFF,d1		;d1 = kbs(4):key
	or	#$e000,d1		;d1 = $e0+kbs(4):key
	move	d1,d0			;d0 = kbs(5):key.$e0+kbs(4):key
.exit:
	rts
;
.mark_ascii:
	and	#$FF,d0
	or	#$a000,d0		;d0 = kbs(5):key.$a0:ascii
	rts
;
.mark_coerced:
	move.l	d0,d1
	swap	d1			;d1 = kbs(5):key
	and	#$F00,d1		;d1 = kbs(4):0
	or	#$c000,d1		;d1 = c0+kbs(4):0
	or	d1,d0			;d0 = kbs(5):key.kbs(4):norm
	rts
;
keytbl_ptp:	dc.l	0
kbd_iorec_p:	dc.l	0
	IFND	kbshift_p
kbshift_p:	dc.l	0
	ENDC
;
	ENDM
;----------------------------------------------------------------------------
	ENDC	;RA_KEY_defined
;----------------------------------------------------------------------------
;End of file:	RA_KEY.I
;----------------------------------------------------------------------------
