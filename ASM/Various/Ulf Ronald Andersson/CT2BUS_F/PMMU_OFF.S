;----------------------------------------------------------------------------
;File name:	PMMU_OFF.S			Revision date:	1999.03.21
;Created by:	Ulf Ronald Andersson		Creation date:	1997.03.21
;----------------------------------------------------------------------------
	output	.PRG
;----------------------------------------------------------------------------
	include	RA_TOS.I
	include	RA_XB.I
	include	bs_comp\TRACER.I
;----------------------------------------------------------------------------
trace_mode	set	0
;----------------------------------------------------------------------------
	TEXT
;----------------------------------------------------------------------------
rz:
basepage	=	rz-$100
;----------------------------------------------------------------------------
start:
	move.l	4(sp),a5
	lea	locstk_top(pc),sp
	gemdos	Mshrink,!,(a5),#(bss_end-basepage)
	gemdos	Cconws,progtitle_s(pc)
	xbios	Supexec,turn_PMMU_off(pc)
	lea	inform_normal_s(pc),a0
	tst	error_f
	beq.s	inform_user
	lea	inform_error_s(pc),a0
inform_user:
	gemdos	Cconws,(a0)
	gemdos	Pterm0
;----------------------------------------------------------------------------
turn_PMMU_off:
	lea	rz(pc),a5		;a5 -> relative zero point
	jsr	fix_cookies
	cmp.l	#30,4+cookie_CPU-rz(a5)		;68030 CPU installed ?
	sne	error_f				;flag whichever in error_f
	bne.s	done_fixes			;skip fixes if no 68030
	pmove.l	TC_passive-rz(a5),tc		;disable TC translation
	pmove.l	TT0_passive-rz(a5),tt0		;set TT0 passive
	pmove.l	TT1_passive-rz(a5),tt1		;set TT1 passive
done_fixes:
	rts
;----------------------------------------------------------------------------
fix_cookies:
	lea	cookie_t(pc),a1	;a1 -> local cookie table
set_cookies_loop:
	movem.l	(a1)+,d0-d1
	tst.l	d0
	ble.s	done_cookies
;
	lea	(_cookies).w,a0
	tst.l	(a0)
	beq.s	.done_cookie
	move.l	(a0),a0
.cookie_loop:
	tst.l	(a0)
	beq.s	.done_cookie
	cmp.l	(a0),d0
	beq.s	.found
	addq	#8,a0
	bra.s	.cookie_loop
;
.found:
	move.l	4(a0),-4(a1)		;store new cookie locally
.done_cookie:
	bra.s	set_cookies_loop
;
done_cookies:
	rts
;----------------------------------------------------------------------------
code_end:
;----------------------------------------------------------------------------
	SECTION	DATA
;----------------------------------------------------------------------------
TC_passive:	dc.l	0				;passive value for tc
TT0_passive:	dc.l	0				;no TT0 translation
TT1_passive:	dc.l	0				;no TT1 translation
;----------------------------------------------------------------------------
def_cookie	MACRO	name,valid,value,iz_f,iz_v
cookie\1:
	dc.l	'\1',\2
	ENDM	;def_cookie
;
cookie_t:
	def_cookie	_CPU,$0000001E
	def_cookie	_MCH,$00010000
	dc.l	-1
;
	EVEN
map_end:
;----------------------------------------------------------------------------
data_beg:
;------;
progtitle_s:
	dc.b	CR,LF,'  ',ESC,'p'
	dc.b	  ' PMMU_OFF  Version: 1.00 (c)1999 ',ESC,'q','  ',CR,LF
	dc.b	NUL
inform_normal_s:
	dc.b	'  PMMU translation is turned OFF.    ',CR,LF,NUL
inform_error_s:
	dc.b	'  PMMU_OFF did not have any effect,  ',CR,LF
	dc.b	'  as 68030 PMMU is not available !   ',CR,LF
	dc.b	NUL
data_end:
;----------------------------------------------------------------------------
	SECTION	BSS
;----------------------------------------------------------------------------
bss_beg:
error_f:	ds.w	1
		ds.b	$4096
locstk_top:
bss_end:
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	PMMU_OFF.S
;----------------------------------------------------------------------------
