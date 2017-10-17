*************************************************************************************************
*parse_block	This routine is used to parse configuration files that contains configration	*
*		"blocks", i.e., several blocks of variables with the same name. This routine	*
*		was written for the "set_mmu.prg" project, and the config file used by that	*
*		program is the best example to illustrate what "configuration blocks" means.	*
*												*
* logical=$100											*
* physical=$200											*
* size=1000											*
* pdf_flags=c_wt										*
*												*
* logical=$400											*
* physical=$400											*
* size=1000											*
* pdf_flags=c_cb										*
*												*
*		This illustrates two configuration blocks which contains the same configuration	*
*		variables. So, this routine is used to parse one block at a time. The routine	*
*		will use cr/lf,cr/lf or lf,lf as a "block delimiter". That is, an empty line is	*
*		interpreted as the end of a block, and the address to this empty line is passed	*
*		back if no errors occured during the parsing. It takes the address of a		*
*		"block-parse" structure in A0, which contains the necessary information.	*
*		This structure is defined in parseblk.h						*
*												*
*************************************************************************************************
parse_block:	movem.l	d0-a6,-(sp)

		move.l	pblk_config(a0),a1		
		clr.b	.starting

	;1st skip trailing cr or cr/lf. That is, empty lines
.skip_trailing:	move.b	(a1)+,d1
		beq	.config_done
.skip_trail1:	cmp.b	#Asc_lf,d1
		beq.s	.skip_trailing
		cmp.b	#Asc_cr,d1
		bne.s	.start_pass
		move.b	(a1),d1
		cmp.b	#Asc_lf,d1
		beq.s	.skip_trailing

	;This line is not empty, check if it starts with a #, space or tab, in which
	;case we skip the line entirely
.start_pass:	cmp.b	#'#',d1
		beq.s	.do_remark
		cmp.b	#' ',d1
		beq.s	.do_remark
		cmp.b	#Asc_tab,d1
		bne.s	.no_remark
.do_remark:	bsr	.get_nextline
	;Now, we have skipped the line, A1 points to the next line. Check if we are still
	;skipping preceeding emtpy/remarked lines. If we have started the config search
	;already, we then have to check if the line following a remarked line is emtpy, and
	;then  terminate this "block" 
		tst.b	.starting
		bne	.skip_remarks	;We've started the config, so we're not skipping preceeding
					;lines, and have to check for empty lines after remarked lines

	;Still skipping preceeding empty/remarked lines..
		move.b	(a1)+,d1
		beq	.config_done
		cmp.b	#Asc_lf,d1
		beq.s	.skip_trail1
		cmp.b	#Asc_cr,d1
		beq.s	.skip_trail1
		bra.s	.start_pass
.no_remark:	lea	.cnf_temp(pc),a3
		st.b	.starting
		move.b	d1,(a3)+
		move.l	a1,d1
		subq.l	#1,d1
		move.l	d1,pblk_next(a0)

.next_char:	move.b	(a1)+,d1
		beq.s	.got_entry_end
		cmp.b	#'#',d1
		beq.s	.got_entry_rem
		cmp.b	#' ',d1
		beq.s	.got_entry_rem
		cmp.b	#Asc_tab,d1
		beq.s	.got_entry_rem
		cmp.b	#Asc_cr,d1
		beq.s	.got_entry_cr
		cmp.b	#Asc_lf,d1
		beq.s	.got_entry
		bsr	charto_lowerc
		move.b	d1,(a3)+
		bra.s	.next_char

.got_entry_rem:	bsr	.get_nextline
		bra.s	.got_entry

.got_entry_end:	subq.l	#1,a1
		bra.s	.got_entry

.got_entry_cr:	cmp.b	#Asc_lf,(a1)
		bne.s	.got_entry
		addq.l	#1,a1

.got_entry:	clr.b	(a3)

	;The current config entry is now in temp buffer, and A0 points to the next line in cnf
		move.l	pblk_varibs(a0),a2
		lea	.cnf_temp(pc),a3
		move.w	pblk_numvars(a0),d7
		subq	#1,d7

.cmp_next:	move.b	(a2)+,d1
		beq.s	.match
		cmp.b	(a3)+,d1
		beq.s	.cmp_next
	;No match, try next config variable
		;dbra	d7,.try_nxtcnfv	;This config variable is not understood.
		;bra	.parse_error

.try_nxtcnfv:	lea	.cnf_temp(pc),a3
.nxt_cnfvar:	tst.b	(a2)+
		bne.s	.nxt_cnfvar
		addq.l	#1,a2		;Get past the number of the entry
		tst.b	(a2)
		bne.s	.cmp_next
		bra	.parse_error

	;When we get here, we got a match up to the null terminator in the config variable.
	;The stuff following should be the variables value.
	;A3 will then point to the value of the variable in cnf_temp buffer, and
	;A2 will point to the byte following the zero
	;So, now get the address of the routine to execute for this config variable
	;based on the value pointed to by A3. 
.match:		moveq	#0,d1
		move.b	(a2),d1
		lsl.l	#2,d1
		move.l	pblk_functs(a0),a4
		move.l	(a4,d1.l),a4

		jsr	(a4)
		bcc.s	.parse_error

	;Then check the next byte in the config file
.skip_remarks:	move.b	(a1)+,d1
		beq.s	.config_done
		cmp.b	#Asc_cr,d1
		beq	.end_block
		cmp.b	#Asc_lf,d1
		beq.s	.end_block

		bra	.start_pass

	;Here we have found the start of a new config-block.
	;The routine to execute for a "set of config variables" is the second
	;routine in the function table
.end_block:	subq.l	#1,a1
		move.l	a1,pblk_next(a0)
		or.b	#1,ccr
		bra.s	.exit
	;Here we have reached the end of the config file
.config_done:	clr.l	pblk_next(a0)
		or.b	#1,ccr
		bra.s	.exit
.parse_error:	and.b	#-2,ccr
		bra.s	.exit
.ok_done:	or.b	#1,ccr		
.exit:		movem.l	(sp)+,d0-a6
		rts

		bss
.starting:	ds.b 1
.cnf_temp:	ds.b 401
		text

.get_nextline:	move.b	(a1)+,d1
		beq.s	.got_nxtline_q
		cmp.b	#Asc_lf,d1
		beq.s	.got_nxtline
		cmp.b	#Asc_cr,d1
		bne.s	.get_nextline
		addq.l	#1,a1
.got_nxtline:	rts
.got_nxtline_q:	subq.l	#1,a1
		rts
;----------------------------------------------------------------------
