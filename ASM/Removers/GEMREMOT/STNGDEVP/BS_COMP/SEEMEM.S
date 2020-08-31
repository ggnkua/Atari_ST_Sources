;----------------------------------------------------------------------------
;File name:	SEEMEM.S			Revision date:	1999.01.22
;Created by:	Ulf Ronald Andersson		Creation date:	1997.03.14
;----------------------------------------------------------------------------
	include	RA_TOS.I
;----------------------------------------------------------------------------
seemem:
	movem.l	d0-d2/a0-a2,-(sp)
	move.l	a0,a2
seemem_loop:
	bsr.w	disp_CLS
	bsr.w	disp_crlf
	bsr.w	dump_mem
	lea	seemem_prompt_s(pc),a0
	bsr	disp_s_a0
	bsr	safe_Crawcin
	and	#$DF,d0
	cmp.b	#'N',d0
	beq.s	seemem_loop
	cmp.b	#' ',d0
	beq.s	seemem_loop
	lea	-$100(a2),a2
	cmp.b	#'P',d0
	beq.s	seemem_loop
	lea	$80(a2),a2
;
	cmp.b	#'A',d0
	beq.s	.address_command
	cmp.b	#'E',d0
	beq.s	.edit_command
;
	cmp.b	#ESC,d0
	beq.s	.exit_command
	bra.s	seemem_loop
;
.exit_command:
	movem.l	(sp)+,d0-d2/a0-a2
	rts
;
.address_command:
	lea	address_s(pc),a0
	bsr.s	disp_s_a0
	bsr.w	get_long
	beq.s	seemem_loop
	move.l	d0,a2
	bra.s	seemem_loop
;
.edit_command:
	lea	address_s(pc),a0
	bsr.s	disp_s_a0
	bsr.w	get_long
	beq.s	.go_seemem_loop
	move.l	d0,a1
	lea	.old_val_s(pc),a0
	bsr.s	disp_s_a0
	move.b	(a1),d0
	bsr.w	disp_byte
	lea	.new_val_s(pc),a0
	bsr.s	disp_s_a0
	bsr.w	get_long
	beq.s	.go_seemem_loop
	move.b	d0,(a1)
.go_seemem_loop:
	bra.w	seemem_loop
;
.old_val_s:
	dc.b	' old=',NUL
.new_val_s:
	dc.b	' new=',NUL
	EVEN
;
;----------------------------------------------------------------------------
dump_mem:
	bsr.w	disp_crlf
	moveq	#16-1,d2
dump_loop_1:
	bsr.s	disp_space
	move.l	a2,d0
	bsr.s	disp_adr
	moveq	#8-1,d1
dump_loop_2:
	move.b	(a2)+,d0
	bsr.s	disp_byte
	bsr.s	disp_space
	dbra	d1,dump_loop_2
	bsr.s	disp_crlf
	dbra	d2,dump_loop_1
	bsr.s	disp_crlf
	rts
;----------------------------------------------------------------------------
disp_adr:
	bsr.s	disp_long
	lea	adr_tail_s(pc),a0
disp_s_a0:
	movem.l	d0-d2/a0-a2,-(sp)
	gemdos	Cconws,(a0)
	bra.s	pull_regs_exit
;----------------------------------------------------------------------------
disp_BS:
	lea	BS_s(pc),a0
	bra.s	disp_s_a0
;----------------------------------------------------------------------------
disp_crlf:
	lea	crlf_s(pc),a0
	bra.s	disp_s_a0
;----------------------------------------------------------------------------
disp_space:
	lea	space_s(pc),a0
	bra.s	disp_s_a0
;----------------------------------------------------------------------------
disp_CLS:
	lea	clr_scr_s(pc),a0
	bra.s	disp_s_a0
;----------------------------------------------------------------------------
disp_show_cur:
	lea	show_cur_s(pc),a0
	bra.s	disp_s_a0
;----------------------------------------------------------------------------
disp_hide_cur:
	lea	hide_cur_s(pc),a0
	bra.s	disp_s_a0
;----------------------------------------------------------------------------
disp_long:
	swap	d0
	bsr.s	disp_word
	swap	d0
disp_word:
	ror	#8,d0
	bsr.s	disp_byte
	rol	#8,d0
disp_byte:
	ror.b	#4,d0
	bsr.s	disp_nybl
	rol.b	#4,d0
disp_nybl:
	movem.l	d0-d2/a0-a2,-(sp)
	and	#$0f,d0
	cmp	#10,d0
	blo.s	.normal
	addq	#'A'-('9'+1),d0
.normal:
	add	#'0',d0
	gemdos	Cconout,d0
pull_regs_exit:
	movem.l	(sp)+,d0-d2/a0-a2
	rts
;----------------------------------------------------------------------------
safe_Crawcin:
	movem.l	d0-d2/a0-a2,-(sp)
	gemdos	Crawcin
	move.b	d0,3(sp)
	bra.s	pull_regs_exit
;----------------------------------------------------------------------------
get_long:
	bsr.s	disp_show_cur
	clr.l	d1
	clr	d2
get_long_loop:
	bsr.s	safe_Crawcin
	cmp.b	#' ',d0
	bhi.s	.visible
	cmp.b	#BS,d0
	bne.s	.end_digs
	tst	d2
	ble.s	get_long_loop
	subq	#1,d2
	lsr.l	#4,d1
	bsr.w	disp_BS
	bra.s	get_long_loop
;
.visible:
	cmp.b	#'0',d0
	blo.s	get_long_loop
	cmp.b	#'9',d0
	bls.s	.low_dig
	and.b	#$DF,d0
	cmp.b	#'A',d0
	blo.s	get_long_loop
	cmp.b	#'F',d0
	bhi.s	get_long_loop
.high_dig:
	subq.b	#'A'-('9'+1),d0
.low_dig:
	sub.b	#'0',d0
	bsr.s	disp_nybl
	and.b	#$0F,d0
	asl.l	#4,d1
	or.b	d0,d1
	addq	#1,d2
	bra.s	get_long_loop
;
.end_digs:
	bsr.w	disp_hide_cur
	move.l	d1,d0
	tst	d2
	rts
;----------------------------------------------------------------------------
;string variables follow:
;----------------------------------------------------------------------------
BS_s:
	dc.b	BS,' ',BS,NUL
;
show_cur_s:
	dc.b	ESC,'e',NUL
hide_cur_s:
	dc.b	ESC,'f',NUL
clr_scr_s:
	dc.b	ESC,'E',NUL
;
crlf_s:
	dc.b	CR,LF,NUL
;
address_s:
	dc.b	ESC,'l','Adr = ',NUL
;
adr_tail_s:
	dc.b	':'
space_s:
	dc.b	' ',NUL
;
seemem_prompt_s:
	dc.b	"Cmd = A,N,P,E,Esc ?",NUL
	EVEN
;----------------------------------------------------------------------------
;End of file:	SEEMEM.S
;----------------------------------------------------------------------------
