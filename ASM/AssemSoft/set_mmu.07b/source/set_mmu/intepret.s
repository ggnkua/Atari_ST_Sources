		rsreset
parsd_lstart:	rs.l 1
parsd_pstart:	rs.l 1
parsd_blksize:	rs.l 1
parsd_pdflags:	rs.l 1
parsd_mcpy_s:	rs.l 1
parsd_mcpy_d:	rs.l 1
parsd_mcpy_size:rs.l 1
parsd_ssize:	= __RS

read_config:	movem.l	d0-a6,-(sp)

		lea	readcnff_m(pc),a0
		bsr	print_message		

		lea	fullpath(pc),a0
		jsr	Dgetdrv
		move.b	d0,(a0)
		move.l	#':\'<<16,1(a0)
		lea	mmu_conf_fn(pc),a1
		lea	config_file(pc),a2
		bsr	makepathfile
		bsr.s	.load_it
		bcs.s	.load_ok

		lea	fullpath(pc),a0
		move.l	#'auto',3(a0)
		move.w	#'\'<<8,7(a0)
		lea	mmu_conf_fn(pc),a1
		lea	config_file(pc),a2
		bsr	makepathfile
		bsr.s	.load_it
		bcs.s	.load_ok
		bra	.load_error


.load_it:	movea.l	a2,a0
		lea	mmu_tree(pc),a1
		move.l	#100*1024,d0
		moveq	#0,d1
		bsr	load_file
		rts

.load_error:	lea	loaderr_m(pc),a0
		bsr	print_message
		and.b	#-2,ccr
		bra	.exit

.load_ok:	lea	loaded_m(pc),a6
		lea	config_file(pc),a0
		bsr	print_a0

		lea	parsing_m(pc),a0
		bsr	print_message

		lea	(a1,d0.l),a2
		clr.b	(a2)
		lea	16(a2),a2
		move.l	a2,d0
		and.b	#-4,d0
		move.l	d0,a1

		move.w	#((cnf_cpur_e-cnf_cpur_b)/2)-1,d0
		lea	cnf_cpur_b(pc),a0
.clr_cpur:	clr.w	(a0)+
		dbra	d0,.clr_cpur

		move.l	a1,conf_block
		move.l	a1,conf_blkstart
		clr.w	conf_entries
		clr.l	parsd_lstart(a1)
		clr.l	parsd_pstart(a1)
		clr.l	parsd_blksize(a1)
		clr.l	parsd_pdflags(a1)
		clr.l	parsd_mcpy_s(a1)
		clr.l	parsd_mcpy_d(a1)
		clr.l	parsd_mcpy_size(a1)

		lea	do_conf(pc),a0
		move.l	#mmu_tree,pblk_config(a0)
		move.l	#mmucnf_log,pblk_varibs(a0)
		move.w	#4,pblk_numvars(a0)
		clr.w	pblk_res0(a0)
		move.l	#mmucnf_functs,pblk_functs(a0)
		bsr	parse_block		
		bcc.s	.parse_err

.loop:		bsr.s	.nxt_block
		move.l	pblk_next(a0),d0
		beq.s	.ok_exit
		move.l	d0,pblk_config(a0)
		bsr	parse_block
		bcs.s	.loop

.parse_err:	move.l	pblk_next(a0),a1
.get_le:	move.b	(a1)+,d0
		beq.s	.print_pe
		cmp.b	#Asc_lf,d0
		beq.s	.print_pe
		cmp.b	#Asc_cr,d0
		bne.s	.get_le
.print_pe:	clr.b	(a1)
		move.l	pblk_next(a0),a0
		lea	parse_err_m(pc),a6
		bsr	print_a0
		and.b	#-2,ccr
		bra.s	.exit

.ok_exit:	lea	parsok_m(pc),a0
		bsr	print_message
		or.b	#1,ccr				
.exit:		movem.l	(sp)+,d0-a6
		rts

.nxt_block:	tst.b	parsd_used
		beq.s	.nonxt
		sf.b	parsd_used
		move.l	conf_block(pc),a1
		lea	parsd_ssize(a1),a1
		move.l	a1,conf_block
		addq.w	#1,conf_entries
		clr.l	parsd_lstart(a1)
		clr.l	parsd_pstart(a1)
		clr.l	parsd_blksize(a1)
		clr.l	parsd_pdflags(a1)
		clr.l	parsd_mcpy_s(a1)
		clr.l	parsd_mcpy_d(a1)
		clr.l	parsd_mcpy_size(a1)
.nonxt:		rts

;===========================================================
		data
readcnff_m:	dc.b "Set MMU -> Looking for configuration file....",13,10,0
loaded_m:	dc.b "Set MMU -> Configuration read from ",0
parsing_m:	dc.b "Set MMU -> Parsing...",13,10,0
parsok_m:	dc.b "Set MMU -> Parsing done - no errors.",13,10,0
loaderr_m:	dc.b "Set MMU -> Could not locate configuration file, mmusetup.cnf",13,10,0
parse_err_m:	dc.b "Set MMU -> Parse error!! --> ",0
		text
;===========================================================
parse_logical:	movem.l	d0-a6,-(sp)

		st.b	parsd_used
		move.l	a3,a0
		bsr	calc_expression
		bcc.s	.exit
		move.l	conf_block(pc),a1
		move.l	d0,parsd_lstart(a1)
		or.b	#1,ccr
.exit:		movem.l	(sp)+,d0-a6
		rts

parse_physical:	movem.l	d0-a6,-(sp)

		st.b	parsd_used
		move.l	a3,a0
		bsr	calc_expression
		bcc.s	.exit
		move.l	conf_block(pc),a1
		move.l	d0,parsd_pstart(a1)
		or.b	#1,ccr
.exit:		movem.l	(sp)+,d0-a6
		rts

parse_size:	movem.l	d0-a6,-(sp)
		st.b	parsd_used
		move.l	a3,a0
		bsr	calc_expression
		bcc.s	.exit
		move.l	conf_block(pc),a1
		move.l	d0,parsd_blksize(a1)
		or.b	#1,ccr
.exit:		movem.l	(sp)+,d0-a6
		rts

parse_pdf:	movem.l	d0-a6,-(sp)
		st.b	parsd_used
		tst.b	(a3)
		beq.s	.ok_exit
		move.l	conf_block(pc),a2
		move.l	a3,a0
		lea	pdf_vars(pc),a1
		jsr	parse_flags
		bcc.s	.error
		move.l	d0,parsd_pdflags(a2)
.ok_exit:	or.b	#1,ccr
		bra.s	.exit
.error:		clr.l	parsd_pdflags(a2)
		and.b	#-2,ccr
.exit:		movem.l	(sp)+,d0-a6
		rts

parse_mcpy_s:	movem.l	d0-a6,-(sp)
		st.b	parsd_used
		move.l	a3,a0
		bsr	calc_expression
		bcc.s	.exit
		move.l	conf_block(pc),a1
		move.l	d0,parsd_mcpy_s(a1)
		or.b	#1,ccr
.exit:		movem.l	(sp)+,d0-a6
		rts

parse_mcpy_d:	movem.l	d0-a6,-(sp)
		st.b	parsd_used
		move.l	a3,a0
		bsr	calc_expression
		bcc.s	.exit
		move.l	conf_block(pc),a1
		move.l	d0,parsd_mcpy_d(a1)
		or.b	#1,ccr
.exit:		movem.l	(sp)+,d0-a6
		rts

parse_mcpy_size:movem.l	d0-a6,-(sp)
		st.b	parsd_used
		move.l	a3,a0
		bsr	calc_expression
		bcc.s	.exit
		move.l	conf_block(pc),a1
		move.l	d0,parsd_mcpy_size(a1)
		or.b	#1,ccr
.exit:		movem.l	(sp)+,d0-a6
		rts


parse_pagesize:	movem.l	d0-a6,-(sp)

		cmp.w	#'8k',(a3)
		beq.s	.8k
		cmp.w	#'4k',(a3)
		beq.s	.4k
		and.b	#-2,ccr
		bra.s	.exit
.8k:		move.w	#8192,page_size
		bra.s	.ok_exit
.4k:		move.w	#4096,page_size
.ok_exit:	or.b	#1,ccr
.exit:		movem.l	(sp)+,d0-a6
		rts

parse_itt0:	movem.l	d0-a6,-(sp)
		move.l	a3,a0
		bsr	calc_expression
		bcc.s	.exit
		move.l	d0,set_itt0
		or.b	#1,ccr
.exit:		movem.l	(sp)+,d0-a6
		rts		

parse_dtt0:	movem.l	d0-a6,-(sp)
		move.l	a3,a0
		bsr	calc_expression
		bcc.s	.exit
		move.l	d0,set_dtt0
		or.b	#1,ccr
.exit:		movem.l	(sp)+,d0-a6
		rts		

parse_itt1:	movem.l	d0-a6,-(sp)
		move.l	a3,a0
		bsr	calc_expression
		bcc.s	.exit
		move.l	d0,set_itt1
		or.b	#1,ccr
.exit:		movem.l	(sp)+,d0-a6
		rts		

parse_dtt1:	movem.l	d0-a6,-(sp)
		move.l	a3,a0
		bsr	calc_expression
		bcc.s	.exit
		move.l	d0,set_dtt1
		or.b	#1,ccr
.exit:		movem.l	(sp)+,d0-a6
		rts		

parse_cacr:	movem.l	d0-a6,-(sp)
		tst.b	(a3)
		beq.s	.ok_exit
		move.l	a3,a0
		cmp.b	#'$',(a3)
		bne.s	.varibs
		bsr	calc_expression
		bcc.s	.exit
		move.l	d0,set_cacr
		bra.s	.ok_exit		
.varibs:	lea	cacr_vars(pc),a1
		jsr	parse_flags
		bcc.s	.exit
		move.l	d0,set_cacr
.ok_exit:	or.b	#1,ccr
.exit:		movem.l	(sp)+,d0-a6
		rts

parse_splitram:	movem.l	d0-a6,-(sp)
		tst.b	(a3)
		beq.s	.ok_exit
		move.l	a3,a0
		lea	yesno_vars(pc),a1
		jsr	parse_flags
		bcc.s	.exit
		move.w	d0,splitram_f
.ok_exit:	or.b	#1,ccr
.exit:		movem.l	(sp)+,d0-a6
		rts

;======================================================
;==========================================================================		
		include	parseblk.s
		include	parsflag.s
		include calcexpr.s

; This is data for the parse_block routine		
		data
parsd_used:	dc.b 0

mmucnf_log:	dc.b "logical=",0
		dc.b 0
mmucnf_phys:	dc.b "physical=",0
		dc.b 1
mmucnf_size:	dc.b "size=",0
		dc.b 2
mmucnf_pdf:	dc.b "pd_flags=",0
		dc.b 3
		dc.b "pagesize=",0
		dc.b 4
		dc.b "itt0=",0
		dc.b 5
		dc.b "dtt0=",0
		dc.b 6
		dc.b "itt1=",0
		dc.b 7
		dc.b "dtt1=",0
		dc.b 8
		dc.b "cacr=",0
		dc.b 9
		dc.b "mcpy_s=",0
		dc.b 10
		dc.b "mcpy_d=",0
		dc.b 11
		dc.b "mcpy_size=",0
		dc.b 12
		dc.b "split_ram=",0
		dc.b 13		
		dc.b 0

		even
mmucnf_functs:	dc.l parse_logical,parse_physical,parse_size,parse_pdf,parse_pagesize
		dc.l parse_itt0,parse_dtt0,parse_itt1,parse_dtt1,parse_cacr
		dc.l parse_mcpy_s,parse_mcpy_d,parse_mcpy_size,parse_splitram


; Flag attribute table for the page descriptor flags
pdf_vars:	dc.b "pdt_iv",0,0,0
		dc.b "pdt_r1",0,0,1
		dc.b "pdt_r2",0,0,3
		dc.b "pdt_id",0,0,2
		dc.b "wp",0,2,1
		dc.b "used",0,3,1
		dc.b "modified",0,4,1
		dc.b "c_wt",0,5,0
		dc.b "c_cb",0,5,1
		dc.b "c_p",0,5,2
		dc.b "c_ip",0,5,3
		dc.b "super",0,7,1
		dc.b "upa_0",0,8,0
		dc.b "upa_1",0,8,1
		dc.b "upa_2",0,8,2
		dc.b "upa_3",0,8,3
		dc.b "global",0,10,1
		dc.b "ur1",0,11,1
		dc.b "ur2",0,12,1
		dc.b 0

cacr_vars:	dc.b "edc",0,31,1
		dc.b "nad",0,30,1
		dc.b "esb",0,29,1
		dc.b "dpi",0,28,1
		dc.b "foc",0,27,1
		dc.b "ebc",0,23,1
		dc.b "cabc",0,22,1
		dc.b "cubc",0,21,1
		dc.b "eic",0,15,1
		dc.b "nai",0,14,1
		dc.b "fic",0,13,1
		dc.b 0

yesno_vars:	dc.b "yes",0,0,1
		dc.b "no",0,0,0
		dc.b 0

		data
crlf_m:		dc.b 13,10,0

		text
print_message:	movem.l	d0-2/a0-2,-(sp)
		move.l	a0,-(sp)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp
		movem.l	(sp)+,d0-2/a0-2
		rts

****************************************************************************************************
*MAKEPATHFILE:	TAKES A SEPARATE PATH AND FILE STRING AND PUTS IT TOGETHER INTO			   *
*	A STRING WHOSE ADDRESS IS PASSED HERE IN A2.						   *
*												   *
*	 A0 = Address to pathname string (Must be null-terminated)				   *
*	 A1 = Address to filename string (Must be null-terminated)				   *
*	 A2 = Address to a buffer containing the full path-filename				   *
*												   *
*	 A2 = Address of the new string containig the merged path and filename			   *
****************************************************************************************************
makepathfile:	movem.l	d0/a0-a2,-(sp)
.mpf1:		move.b	(a0)+,(a2)+
		bne.s	.mpf1
.mpf2:		move.b	-(a2),d0
		cmp.b	#'/',d0
		beq.s	.got_delim
		cmp.b	#'\',d0
		bne.s	.mpf2
.got_delim:	addq.l	#1,a2
.mpf3:		move.b	(a1)+,(a2)+
		bne.s	.mpf3
		movem.l	(sp)+,d0/a0-a2
		rts

		data
mmu_conf_fn:	dc.b "mmusetup.cnf",0
		bss
fullpath:	ds.b 40
config_file:	ds.b 120

		bss
		even
conf_blkstart:	ds.l 1
conf_block:	ds.l 1
conf_entries:	ds.w 1
		ds.w 1
do_conf:	ds.l 10

		text
	include	..\common\loadfile.s
	include	..\common\diskcall.s
;	include	..\common\getcrntp.s
	include	..\common\ahxtobin.s
	include ..\common\abntobin.s
	include ..\common\adctobin.s
	include	..\common\convcase.s
