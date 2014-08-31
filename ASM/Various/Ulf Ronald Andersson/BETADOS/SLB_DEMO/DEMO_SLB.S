;----------------------------------------------------------------------------
;File name:	DEMO_SLB.S			Revision date:	1998.09.19
;Revised by:	Ronald Andersson		Revision start:	1998.09.14
;----------------------------------------------------------------------------
	include	RA_SLB.I
;----------------------------------------------------------------------------
	output	.SLB
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
	SLB_hd_def	demo_slb,1,3	;version 1 with 3 funcs (0..2)
;----------------------------------------------------------------------------
;long cdecl slb_init (void)
;
slb_init:
	bsr	disp_demo_head
	bsr	disp_slb_init
	bsr	disp_period_crlf
	moveq	#0,d0
	rts
;----------------------------------------------------------------------------
;void cdecl slb_exit (void)
;
slb_exit:
	bsr	disp_demo_head
	bsr	disp_slb_exit
	bsr	disp_period_crlf
	rts
;----------------------------------------------------------------------------
;long cdecl slb_open (BASPAG *bp)
;
slb_open:
	lv_init		a6
	lv_arg.l	bp
;-------
	bsr	disp_demo_head
	bsr	disp_slb_open
	bsr	disp_by_PD
	move.l	bp(a6),d0
	bsr	disp_long
	bsr	disp_period_crlf
	moveq	#0,d0
	lv_exit	a6
	rts
;----------------------------------------------------------------------------
;void cdecl slb_close (BASPAG *bp)
slb_close:
	lv_init		a6
	lv_arg.l	bp
;-------
	bsr	disp_demo_head
	bsr	disp_slb_close
	bsr	disp_by_PD
	move.l	bp(a6),d0
	bsr.s	disp_long
	bsr	disp_period_crlf
	lv_exit	a6
	rts
;----------------------------------------------------------------------------
;long cdecl tst_1st_fn (BASPAG *bp, long fn, int nargs, ...)
;
	SLB_fn_def	tst_1st_fn,0
	lv_init		a6
	lv_arg.l	bp
	lv_arg.l	fn
	lv_arg.w	nargs
;-------
	bsr	disp_demo_head
	bsr	disp_function
	move.l	fn(a6),d0
	bsr.s	disp_long
	bsr	disp_called
	bsr	disp_by_PD
	move.l	bp(a6),d0
	bsr.s	disp_long
	bsr	disp_with
	move.w	nargs(a6),d0
	bsr.s	disp_word
	bsr	disp_bytes_tail
	moveq	#0,d0
	lv_exit	a6
	rts
;----------------------------------------------------------------------------
;long cdecl tst_3rd_fn (BASPAG *bp, long fn, int nargs, ...)
;
	SLB_fn_def	tst_3rd_fn,2
	lv_init		a6
	lv_arg.l	bp
	lv_arg.l	fn
	lv_arg.w	nargs
;-------
	bsr.s	disp_demo_head
	bsr.s	disp_function
	move.l	fn(a6),d0
	bsr.s	disp_long
	bsr.s	disp_called
	bsr.s	disp_by_PD
	move.l	bp(a6),d0
	bsr.s	disp_long
	bsr.s	disp_with
	move.w	nargs(a6),d0
	bsr.s	disp_word
	bsr.s	disp_bytes_tail
	moveq	#0,d0
	lv_exit	a6
	rts
;----------------------------------------------------------------------------
	SLB_patch	demo_slb
;----------------------------------------------------------------------------
disp_long:
	swap	d0
	bsr.s	disp_word
	swap	d0
disp_word:
	rol.w	#8,d0
	bsr.s	disp_byte
	rol.w	#8,d0
disp_byte:
	rol.b	#4,d0
	bsr.s	disp_nybble
	rol.b	#4,d0
disp_nybble:
	movem.l	d0-d2/a0-a2,-(sp)
	and	#$0f,d0
	add	#'0',d0
	cmp	#'9',d0
	bls.s	.have_char
	add	#('A'-'0'-10),d0
.have_char:
	gemdos	Cconout,d0
	movem.l	(sp)+,d0-d2/a0-a2
	rts
;----------------------------------------------------------------------------
disp_slb_init:
	lea	slb_init_s(pc),a0
	bra.s	disp_str_a0
;-------
disp_slb_exit:
	lea	slb_exit_s(pc),a0
	bra.s	disp_str_a0
;-------
disp_slb_open:
	lea	slb_open_s(pc),a0
	bra.s	disp_str_a0
;-------
disp_slb_close:
	lea	slb_close_s(pc),a0
	bra.s	disp_str_a0
;-------
disp_demo_head:
	lea	demo_head_s(pc),a0
	bra.s	disp_str_a0
;-------
disp_function:
	lea	function_s(pc),a0
	bra.s	disp_str_a0
;-------
disp_called:
	lea	called_s(pc),a0
	bra.s	disp_str_a0
;-------
disp_by_PD:
	lea	by_PD_s(pc),a0
	bra.s	disp_str_a0
;-------
disp_with:
	lea	with_s(pc),a0
	bra.s	disp_str_a0
;-------
disp_bytes_tail:
	lea	bytes_tail_s(pc),a0
	bra.s	disp_str_a0
;-------
disp_period_crlf:
	lea	period_crlf_s(pc),a0
	bra.s	disp_str_a0
;-------
disp_crlf:
	lea	crlf_s(pc),a0
disp_str_a0:
	movem.l	d0-d2/a0-a2,-(sp)
	gemdos	Cconws,(a0)
	movem.l	(sp)+,d0-d2/a0-a2
	rts
;----------------------------------------------------------------------------
	SECTION	DATA
;----------------------------------------------------------------------------
slb_init_s:	dc.b	'slb_init() ',NUL
slb_exit_s:	dc.b	'slb_exit() ',NUL
slb_open_s:	dc.b	'slb_open() ',NUL
slb_close_s:	dc.b	'slb_close() ',NUL
demo_head_s:	dc.b	'demo_slb: ',NUL
function_s:	dc.b	'function $',NUL
called_s:	dc.b	' called ',NUL
by_PD_s:	dc.b	'by PD $',NUL
with_s:		dc.b	' with $',NUL
bytes_tail_s:	dc.b	' words of extra function parameters'
period_crlf_s	dc.b	'.'
crlf_s:		dc.b	CR,LF,NUL
		EVEN
;----------------------------------------------------------------------------
	SECTION	BSS
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	DEMO_SLB.S
;----------------------------------------------------------------------------
