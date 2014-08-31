;----------------------------------------------------------------------------
;File name:	CSim.S			Revision date:	1992.11.16
;Creator:	Ulf Ronald Andersson	Creation date:	1992.11.16
;(c)1992 by:	Ulf Ronald Andersson	All rights reserved
;Released as:	FREEWARE		(NB: commercial sales forbidden!)
;File purpose:	Source for CSim, simulates RAM disk C: as boot device
;----------------------------------------------------------------------------
;
	include	URAn_JAR.S
;
;----------------------------------------------------------------------------
;
	text
;
;----------------------------------------------------------------------------
;
rz:	;relative zero
	bra	mainboot
;
;----------------------------------------------------------------------------
;
set_new_bootdev:
	move	(_bootdev).w,._bootdev_save
	move.l	(resvalid).w,.resvalid_save
	move.l	(resvector).w,.resvector_save
	move.l	#.unbootdev_reset,(resvector).w
	move.l	#$31415926,(resvalid).w
	move	d0,(_bootdev).w		;activate new_jar
	rts
._bootdev_save:		dc.w	0
.resvalid_save:		dc.l	0
			dc.l	'XBRA','CSim'
.resvector_save:	dc.l	0
.unbootdev_reset:
	move	._bootdev_save(pc),(_bootdev).w
	move.l	.resvector_save(pc),(resvector).w
	move.l	.resvalid_save(pc),(resvalid).w
	jmp	(a6)	;NB:reset routine must not use standard linking
;
;----------------------------------------------------------------------------
;
	_uniref	set_new_jar
	make	JAR_links
;
;----------------------------------------------------------------------------
;
resident_lim:	;so all beyond this will eventually be released to system
mainboot:
	moveq	#-1,d6
	lea	refuse_ACC_s(pc),a3
	move.l	a0,d0
	bne	refuse_a3
	move.l	4(sp),a5
	lea	local_st_top(pc),sp
	gemdos	Mshrink,!,(a5),#init_lim-rz+$100
	lea	refuse_ramerr_s(pc),a3
	move.l	d0,d6
	bmi	refuse_a3
	gemdos	Super,!
	move.l	d0,d7
	moveq	#-1,d6
	lea	refuse_cdrive_s(pc),a3
	move	(_bootdev).w,d0
	cmp	#2,d0
	beq.s	show_error_a3
	lea	refuse_nodrive_s(pc),a3
	move.l	_drvbits,d0
	btst	#2,d0
	beq.s	show_error_a3
	eval_cookie	#'CSim'
	bmi.s	try_make
	lea	refuse_repeat_s(pc),a3
	cmp.l	#'URAn',d0
	beq.s	show_error_a3
	lea	refuse_stolen_s(pc),a3
	bra.s	show_error_a3
;
try_make:	
	lea	refuse_cookie_s(pc),a3
	make_cookie	#'CSim',#'URAn'
	move.l	d0,d6
	bmi.s	show_error_a3
	moveq	#2,d0
	bsr	set_new_bootdev
	gemdos	Super|_ind,d7
	lea	boot_ok_s(pc),a3
	bsr.s	display
	gemdos	Ptermres,#resident_lim-rz+$100,!
;
show_error_a3:
	gemdos	Super|_ind,d7
refuse_a3:
	bsr.s	display
	gemdos	Pterm,d6
;
display:
	moveq	#50/2,d3
	gemdos	Cconws,prog_head_s(pc)
	gemdos	Cconws,(a3)
	tst.l	d6
	bpl.s	.no_err
	add	#3*50,d3
	gemdos	Cconws,err_tail_s(pc)
.no_err:
	gemdos	Cconws,prog_tail_s(pc)
	move	#50*2,d3
.loop:	xbios	Vsync
	dbra	d3,.loop
	rts
;
;----------------------------------------------------------------------------
;
	make	JAR_links
;
;----------------------------------------------------------------------------
;
	data
;
;----------------------------------------------------------------------------
;
prog_head_s:
	dc.b	CR,LF," ",ESC,"p"
	dc.b	" CSim 1.0 by Ronald Andersson Nov 1992 ",ESC,"q",CR,LF,NUL
refuse_ACC_s:
	dc.b	"  Sorry, CSim is not an ACC-program!",NUL
refuse_ramerr_s:
	dc.b	"  System will not release CSim's RAM!",NUL
refuse_cdrive_s:
	dc.b	"  System already thinks C: booted.",NUL
refuse_nodrive_s:
	dc.b	"  There is no drive C: active, so to",CR,LF
	dc.b	"  activate CSim now could bomb system.",NUL
refuse_repeat_s:
	dc.b	"  CSim refuses to load twice per boot!",NUL
refuse_stolen_s:
	dc.b	"  Someone has stolen CSim's cookie!",NUL
refuse_cookie_s:
	dc.b	"  CSim's cookie installation failed!",NUL
err_tail_s:
	dc.b	CR,LF
	dc.b	"  Thus CSim will not stay resident.",CR,LF
	dc.b	"  There will now be a brief pause so",CR,LF
	dc.b	"  that you have time to see this text.",NUL
boot_ok_s:
	dc.b	"  CSim is now active, and resident.",CR,LF
	dc.b	"  System now believes that C: booted,",CR,LF
	dc.b	"  but reset will restore true drive.",NUL
prog_tail_s:
	dc.b	CR,LF,CR,LF,NUL
;
;----------------------------------------------------------------------------
;
	bss
;
;----------------------------------------------------------------------------
;
local_stack:
	ds.l	$100
local_st_top:
	ds.l	4
init_lim:
;
;----------------------------------------------------------------------------
;	End of file:	CSim.S
