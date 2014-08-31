;----------------------------------------------------------------------------
; File name:	SUPX.S				Revision date:	1998.11.21
; Created by:	Ulf Ronald Andersson		Creation date:	1994.08.01
;----------------------------------------------------------------------------
;Remarks:
;
;	This program links into the xbios system vector, to provide a
;	Supexec function which is fully compatible with both MagiX and TOS.
;
;	This is needed because the Supexec function of MagiX does not allow
;	function arguments to be passed on the stack, which all TOS versions
;	from Atari do allow.
;
;	The new function uses XBRA-id 'SupX' and is fully reentrant,
;	to a maximum of 256 Supexec call levels (easily extended).
;
;----------------------------------------------------------------------------
;
	INCLUDE	RA_SYS.I
	INCLUDE	RA_TOS.I
	INCLUDE	RA_XB.I
;
;----------------------------------------------------------------------------
;
link_limit	= 256		;allows 256 Supexec reentrancy levels
link_size	= 12*4		;each level requires 12 longwords
xbra_id		= 'SupX'
;
;NB:	256 levels cost 12288 bytes at 'save_base'
;
;----------------------------------------------------------------------------
;
	section	text
;
;----------------------------------------------------------------------------
rz:				;unique label for local ref's
	bra	bootprog	;this avoids wasting TSR space
;
;----------------------------------------------------------------------------
;	XBRA_linked xbios routine
;
	XB_define	nu_xbios_XB,xbra_id
	Pass_Frame	a0		;a0 = pre_call sp (USP/SSP)
	cmp	#Supexec&$FF,(a0)+	;Supexec ?, a0 = pre_call sp+2
	beq.s	nu_supexec
	XB_gonext_a0	nu_xbios_XB
;
;
nu_supexec:
	sub.l	#12*4,save_p		;reserve link
	move.l	save_p(pc),a1		;a1 -> link
	cmpa.l	#save_base,a1
	bge.s	.have_room
	add.l	#12*4,save_p		;release link
	move.l	nu_xbios_XB+8(pc),a0
	jmp	(a0)
;
;
.have_room:
	movem.l	(sp),d0/d1		;d0/d1 = stack frame, 6 or 8 bytes
	movem.l	d0-d1,10*4(a1)		;save padded stack frame
	movem.l	d3-d7/a3-a7,(a1)	;save 10 registers incl SSP
	move.l	(a0),a1
	move.l	a0,sp			;make pre_call sp+2 into new SSP
;
	jsr	(a1)			;call subroutine in supervisor mode
;
	move.l	save_p(pc),a1		;a1 -> link
	movem.l	(a1)+,d3-d7/a3-a7	;restore 10 registers, incl SSP
	move.l	4(a1),4(sp)		;restore 2'nd long of padded frame
	move.l	(a1),(sp)		;restore 1'st long of padded frame
	add.l	#12*4,save_p		;release link
	rte				;exit and restore callers SR/SP
;
;End of XBRA_linked xbios routine
;----------------------------------------------------------------------------
;	TSR resident data
;
save_p:
	dc.l	save_limit
save_base:
save_limit:	= save_base+link_size*link_limit
;
;----------------------------------------------------------------------------
;End of TSR resident code
;
tsr_end:	= save_limit
;
;----------------------------------------------------------------------------
;
bootprog:
	move.l	4(sp),a5
	lea	stacktop(pc),sp			;sp->local stack top
	lea	rz(pc),a6
	move.l	a5,basepage_p-rz(a6)
	lea	bss_end(pc),a4
	sub.l	a5,a4
	gemdos	Mshrink,!,(a5),a4
	gemdos	Cconws,title_s(pc)
	xbios	Supexec,fix_xbra_supx(pc)
	tst.l	d0
	bmi.s	.error_exit
	gemdos	Cconws,installed_s(pc)
	lea	tsr_end(pc),a4
	sub.l	basepage_p(pc),a4
	gemdos	Ptermres,a4,!
;
.error_exit:
	gemdos	Cconws,duplicate_s(pc)
	moveq	#75,d3
.err_delay:
	xbios	Vsync
	dbra	d3,.err_delay
	gemdos	Pterm0
;
;
fix_xbra_supx:
	moveq	#E_ERROR,d7
	lea	xbra_list(pc),a3
	lea	vect_list(pc),a2
.loop_1:
	move.l	(a3)+,a1
	move.l	(a2)+,a0
	move.l	a0,d0
	bmi.s	.not_found
	move.l	4(a1),d1		;d1 = xbra id_code of new routine
	move.l	(a0),a0			;a0 -> first routine in old chain
.loop_2:
	lea	-12(a0),a0
	cmp.l	#'XBRA',(a0)
	bne.s	.chain_end
	cmp.l	4(a0),d1
	beq.s	.found
	move.l	8(a0),a0
	move.l	a0,d0
	bne.s	.loop_2
.chain_end:
	bra.s	.loop_1
;
.not_found:
	lea	xbra_list(pc),a3
	lea	vect_list(pc),a2
	move	SR,d1			;push interrupt mask
	or	#$0700,SR		;disable interrupts
.loop_3:
	move.l	(a3)+,a1		;a1 -> new xbra structure
	move.l	(a2)+,a0		;a0 -> system vector
	move.l	a0,d0			;done ?
	bmi.s	.chained
	addq	#8,a1			;a1 -> link in structure
	move.l	(a0),(a1)+		;store old vector in link
	move.l	a1,(a0)			;store new system vector
	bra.s	.loop_3
;
.chained:
	move	d1,SR			;restore interrupt mask
	clr.l	d7
.found:
	move.l	d7,d0
	rts
;
;----------------------------------------------------------------------------
;
	section	data	;resident during init only
;
;----------------------------------------------------------------------------
;
xbra_list:
	dc.l	nu_xbios_XB
	dc.l	-1
;
vect_list:
	dc.l	ev_xbios
	dc.l	-1
;
title_s:
	dc.b	CR,ESC,'q',ESC,'K',CR,LF
	dc.b	ESC,'K',HT,ESC,'p','                       ',ESC,'q',CR,LF
	dc.b	ESC,'K',HT,ESC,'p','   SupX  Version 1.1   ',ESC,'q',CR,LF
	dc.b	ESC,'K',HT,ESC,'p','                       ',ESC,'q',CR,LF
	dc.b	ESC,'K',HT,ESC,'p','       (c)1998 by      ',ESC,'q',CR,LF
	dc.b	ESC,'K',HT,ESC,'p','       Ulf Ronald      ',ESC,'q',CR,LF
	dc.b	ESC,'K',HT,ESC,'p','       Andersson       ',ESC,'q',CR,LF
	dc.b	ESC,'K',HT,ESC,'p','                       ',ESC,'q',CR,LF
	dc.b	NUL
;
installed_s:
	dc.b	ESC,'K',HT,ESC,'p',' Installation complete ',ESC,'q',CR,LF
	dc.b	ESC,'K',HT,ESC,'p','                       ',ESC,'q',CR,LF
	dc.b	ESC,'K',CR,LF
	dc.b	CR,LF
	dc.b	NUL
;
duplicate_s:
	dc.b	ESC,'K',CR,LF,BEL
	dc.b	CR,LF,BEL
	dc.b	'XBRA link "SupX" was already installed',CR,LF,BEL
	dc.b	'in a vector chain, so the SupX program',CR,LF,BEL
	dc.b	'was not reinstalled at this time.',CR,LF,BEL
	dc.b	'A small pause follows, so you can read',CR,LF,BEL
	dc.b	'this message, and decide what to do.',CR,LF,BEL
	dc.b	CR,LF
	dc.b	NUL
	even
;
;----------------------------------------------------------------------------
;
	section	bss	;resident during init only
;
;----------------------------------------------------------------------------
dummy_base:	ds.b	link_limit*link_size
basepage_p:	ds.l	1
stackbase:	ds.l	128
stacktop:	ds.l	1
bss_end:
;----------------------------------------------------------------------------
	end
;----------------------------------------------------------------------------
;END of file:	SUPX.S
;----------------------------------------------------------------------------
