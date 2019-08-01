;----------------------------------------------------------------------------
;File name:	RA_FDC.S			Revision date:	1998.08.15
;Creator:	Ulf Ronald Andersson		Creation date:	1993.01.28
;(c)1993 by:	Ulf Ronald Andersson		All rights reserved
;Released as:	FREEWARE			(commercial sales forbidden!)
;----------------------------------------------------------------------------
;Purpose:	Macro library for low level FDC operations
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	IFND	RA_FDC_defined
RA_FDC_defined	set	1
;
;----------------------------------------------------------------------------
;
	include	RA_TOS.I
	include	RA_XB.I
;
;----------------------------------------------------------------------------
;	Macro list
;
;	install_fdc		installs fdcbios as trap 7
;	remove_fdc		unlinks fdcbios from trap 7
;	install_fdc_code	the actual code of fdcbios
;	fdcbios	function	trap 7 call with 'function' on stack
;
;----------------------------------------------------------------------------
;	fdcbios function numbers
;
fd_init		= $FDC0+$00	;store hardware state & init parms & hardware
fd_reinit	= $FDC0+$01	;reinit parms & hardware
fd_driveside	= $FDC0+$02	;Set drive & side selects
fd_restore	= $FDC0+$03	;Restore drive to track zero
fd_seek		= $FDC0+$04	;Seek fdp_track
fd_step		= $FDC0+$05	;Step in old direction
fd_step_in	= $FDC0+$06	;Step in to higher track
fd_step_out	= $FDC0+$07	;Step out to lower track
fd_read_mult	= $FDC0+$08	;Read  multiple sectors
fd_write_mult	= $FDC0+$09	;Write multiple sectors
fd_read_trk	= $FDC0+$0a	;Read  track
fd_write_trk	= $FDC0+$0b	;Write track (==Format)
fd_read_id	= $FDC0+$0c	;Read multiple id marks
fd_force_int	= $FDC0+$0d	;Force interruption of FDC
fd_rd_reg_trk	= $FDC0+$0e	;Read  track register
fd_wr_reg_trk	= $FDC0+$0f	;Write track register
fd_rd_reg_sect	= $FDC0+$10	;Read  sector register
fd_rd_reg_stat	= $FDC0+$11	;Read  status register
fd_exec_extern	= $FDC0+$12	;Execute external routine
fd_exit		= $FDC0+$13	;restore original hardware state
;
;----------------------------------------------------------------------------
;	Macro definitions:
;
fdcbios	macro	function
	move	#\1&$ffff,-(sp)
	trap	#7
	addq	#2,sp
	endm	;fdcbios
;
;
install_fdc	macro
	bsr	install_fdc_sub
	endm	;install_fdc
;
;
remove_fdc	macro
	bsr	remove_fdc_sub
	endm	;install_fdc
;
;
install_fdc_code	macro
install_fdc_sub:
	XB_install	fdc_trap_7(pc),(ev_trap7).w
	fdcbios		fd_init
	rts
;
remove_fdc_sub:
	fdcbios		fd_exit
	XB_remove	fdc_trap_7(pc),(ev_trap7).w
	rts
;
;
		rsreset
fdp_driveside	rs.w	1	;b2 = ~B_sel  b1 = ~A_sel  b0 = ~Side
fdp_track	rs.w	1
fdp_sector	rs.w	1
fdp_translen	rs.w	1
fdp_id_count	rs.w	1
fdp_fdc_state	rs.w	1
fdp_dma_state	rs.w	1
fdp_dmamode	rs.w	1
fdp_timeout_f	rs.w	1
fdp_translen_2	rs.w	1
fdp_dma_work_f	rs.w	1
fdp_vblres_f	rs.w	1
;
fdp_long_delay	rs.l	1
fdp_short_delay	rs.l	1
fdp_timeout_dly	rs.l	1
;
fdp_dma_start_p	rs.l	1
fdp_dma_end_p	rs.l	1
fdp_track_bf_p	rs.l	1
fdp_sector_bf_p	rs.l	1
fdp_id_bf_p	rs.l	1
fdp_idstat_bf_p	rs.l	1
;
fdp_frametime	rs.w	1
fdp_timeout_tic	rs.l	1
;
fdp_exit_psgport	rs.w	1
fdp_exit_dmamode	rs.w	1
;
fdp_parm_tb_size:	rs.b	0
;
fdp_parm_tb:
	ds.b	fdp_parm_tb_size
;
fdc_opbase	= $FDC0
;
	XB_define	fdc_trap_7,'fdcT'
	movem.l	d0/a0-a1,-(sp)
	move	USP,a0
	btst	#5,12(sp)
	beq.s	.keep_args_a0
	lea	6(sp),a0
	tst	(_longframe).w
	beq.s	.keep_args_a0
	addq	#2,a0
.keep_args_a0:
	move	(a0)+,d0
	lea	fdc_func_tb(pc),a1
	sub	(a1)+,d0
	blo.s	.go_old_trap_7
	cmp	(a1)+,d0
	blo.s	.use_new_trap_7
.go_old_trap_7:
	movem.l	(sp)+,d0/a0-a1
	XB_gonext_d	fdc_trap_7(pc)
;
.use_new_trap_7:
	ext	d0
	movem.l	d0/a0,fdc_opstate-fdc_func_tb-4(a1)
	movem.l	(sp)+,d0/a0-a1
	movem.l	d1-d7/a0-a6,fdc_regsave
	movem.l	fdc_opstate(pc),d0/a4			;a4->args  d0=function
	lea	fdp_parm_tb(pc),a5			;a5->parms
	lea	fdc_func_tb+4(pc),a1
	lsl	#2,d0
	move.l	(a1,d0),a1
	move	#1,(flock).w
	clr	fdp_timeout_f(a5)
	clr	fdp_dma_work_f(a5)
	clr	fdp_vblres_f(a5)
	move.l	fdp_long_delay(a5),fdp_timeout_dly(a5)
	move.l	(_frclock).w,fdp_timeout_tic(a5)
	move	#dma_srcmd,fdp_dmamode(a5)
	move	#dma_srcmd,(hw_dmamode).w
	jsr	(a1)
	lea	fdp_parm_tb(pc),a5			;a5->parms
	move.l	d0,fdc_opstate-fdp_parm_tb(a5)
	tst	fdp_vblres_f(a5)
	beq.s	.leave_flock
	clr	(flock).w
.leave_flock:
	movem.l	fdc_regsave(pc),d1-d7/a0-a6
	move.l	fdc_opstate(pc),d0
	rte
;
;
fdc_regsave:
	ds.l	16
;
fdc_opstate:
	ds.l	1
fdc_arg_p:
	ds.l	1
fdc_func_tb:
	dc.w	fdc_opbase
	dc.w	(fdc_func_tb_end-fdc_func_tb-4)/4
	dc.l	fdc_init	;op 00	store hardware state & init parms & hardware
	dc.l	fdc_reinit	;op 01	reinit parms & hardware
	dc.l	fdc_driveside	;op 02	Set drive & side selects
	dc.l	fdc_restore	;op 03	Restore drive to track zero
	dc.l	fdc_seek	;op 04	Seek fdp_track
	dc.l	fdc_step	;op 05	Step in old direction
	dc.l	fdc_step_in	;op 06	Step in to higher track
	dc.l	fdc_step_out	;op 07	Step out to lower track
	dc.l	fdc_read_mult	;op 08	Read  multiple sectors
	dc.l	fdc_write_mult	;op 09	Write multiple sectors
	dc.l	fdc_read_trk	;op 0a	Read  track
	dc.l	fdc_write_trk	;op 0b	Write track (==Format)
	dc.l	fdc_read_id	;op 0c	Read multiple id marks
	dc.l	fdc_force_int	;op 0d	Force interruption of FDC
	dc.l	fdc_rd_reg_trk	;op 0e	Read  track register
	dc.l	fdc_wr_reg_trk	;op 0f	Write track register
	dc.l	fdc_rd_reg_sect	;op 10	Read  sector register
	dc.l	fdc_rd_reg_stat	;op 11	Read  status register
	dc.l	fdc_exec_extern	;op 12	Execute external routine
	dc.l	fdc_exit	;op 13	Restore original hardware state
fdc_func_tb_end:
;
fdc_cmd_table:
cmd_restore:	dc.w	$01	;Restore	MO, 3ms
cmd_seek:	dc.w	$11	;Seek		MO, 3ms
cmd_step:	dc.w	$31	;Step		MO, 3ms, update track reg
cmd_step_in:	dc.w	$51	;Step in	MO, 3ms, update track reg
cmd_step_out:	dc.w	$71	;Step out	MO, 3ms, update track reg
cmd_read_mult:	dc.w	$90	;Multiple read	MO,
cmd_write_mult:	dc.w	$b0	;Multiple write	MO, Precompensate
cmd_read_id:	dc.w	$c0	;Read id_mark	MO
cmd_read_trk:	dc.w	$e0	;Read track	MO
cmd_write_trk:	dc.w	$f0	;Format track	MO, Precompensate
cmd_force_int:	dc.w	$d0	;Force interrupt
;
;
;----------------------------------------------------------------------------
;		Subroutines for primitive FDC access
;
fdc_delay:
	move	SR,-(sp)
	move	d0,-(sp)
	move	#60,d0
.delay_lp:
	dbra	d0,.delay_lp
	move	(sp)+,d0
	move	(sp)+,SR
	rts
;
;
fdc_motor_off:
	move	#dma_srcmd,(hw_dmamode).w
.delay_lp:
	bsr.s	read_1772
	btst	#7,d0
	bne.s	.delay_lp
	rts
;
;
sub_setdma:
	move.l	d7,fdp_dma_start_p(a5)
	move.b	d7,(hw_dmabase0).w
	ror.l	#8,d7
	move.b	d7,(hw_dmabase1).w
	ror.l	#8,d7
	move.b	d7,(hw_dmabase2).w
	swap	d7
	clr.l	d6
	move	fdp_translen(a5),d6
	add.l	d6,d7
	move.l	d7,fdp_dma_end_p(a5)
	
;
;
sub_setcnt:
	swap	d7
	move	fdp_dmamode(a5),d7
	or	#dma_srcnt,d7
	move	d7,(hw_dmamode).w
	eor	#dma_wr_bit,d7
	move	d7,(hw_dmamode).w
	eor	#dma_wr_bit,d7
	move	d7,(hw_dmamode).w
	swap	d7
	move	#1,fdp_dma_work_f(a5)
write_1772:
	bsr	fdc_delay
	move	d7,(hw_dmadata).w
	bsr	fdc_delay
	rts
;
;
read_1772:
	bsr	fdc_delay
	move	(hw_dmadata).w,d0
	bsr	fdc_delay
	rts
;
;
sub_getcnt:
	move	#dma_srcnt,d0
	or	fdp_dmamode(a5),d0
	move	d0,(hw_dmamode).w
	move	(hw_dmadata).w,d0
	and	#$ff,d0
	move	#dma_srcmd,fdp_dmamode(a5)
	move	#dma_srcmd,(hw_dmamode).w
	move	d0,fdp_id_count(a5)
	rts
;
;End of:	Subroutines for primitive FDC access
;----------------------------------------------------------------------------
;		Subroutines for complex FDC access
;
fdc_exit:
	move	fdp_exit_dmamode(a5),(hw_dmamode).w
	move	fdp_exit_psgport(a5),d0
	xbios	giaccess,#14|$80,d0
	rts
;
;
fdc_init:
	xbios	giaccess,#14,!
	move	d0,fdp_exit_psgport(a5)
	move	(hw_dmamode).w,fdp_exit_dmamode(a5)
fdc_reinit:
	move.l	#2000000,fdp_long_delay(a5)
	move.l	#1000000,fdp_short_delay(a5)
	move.b	(hw_rez).w,d0
	and	#3,d0
	move	#14028,d1	;uSec/mono_frame
	cmp	#2,d0
	bge.s	.got_time
	move	#16637,d1	;uSec/60Hz_frame
	btst	#1,(hw_syn).w
	beq.s	.got_time
	move	#20000,d1	;uSec/50Hz_frame
.got_time:
	move	d1,fdp_frametime(a5)
	move.l	a5,d0
	rts
;
;
fdc_exec_extern:
	move.l	(a4),-(sp)
	rts
;
;
fdc_restore:
	move	cmd_restore(pc),d7
fdc_command:
	move	#dma_srcmd,(hw_dmamode).w
	bsr	write_1772
fdc_wait:
	move.l	#$300,d0
.delay_lp:
	dbra	d0,.delay_lp
.read_mfp:
	btst	#5,(hw_mfp).w
	beq.s	.fdc_ready
	move.l	(_frclock).w,d0
	sub.l	fdp_timeout_tic(a5),d0
	mulu	fdp_frametime(a5),d0
	cmp.l	fdp_timeout_dly(a5),d0
	bhs.s	.timeout
	tst	fdp_dma_work_f(a5)
	beq.s	.read_mfp
	clr.l	d0
	move.b	(hw_dmabase2).w,d0
	lsl.l	#8,d0
	move.b	(hw_dmabase1).w,d0
	lsl.l	#8,d0
	move.b	(hw_dmabase0).w,d0
	cmp.l	fdp_dma_end_p(a5),d0
	blt.s	.read_mfp
	bsr.s	fdc_force_int
	clr	fdp_dma_work_f(a5)
	bra.s	.fdc_ready
;
.timeout:
	bsr	sub_getcnt
	bsr.s	fdc_force_int
	move	#1,fdp_timeout_f(a5)
	rts
;
.fdc_ready:
	bra	sub_getcnt
;
;
fdc_seek:
	move	#dma_srdat,(hw_dmamode).w
	move	fdp_track(a5),d7
	bsr	write_1772
	move	cmd_seek(pc),d7
	bra	fdc_command
;
;
fdc_step:
	move	cmd_step(pc),d7
	bra	fdc_command
;
;
fdc_step_in:
	move	cmd_step_in(pc),d7
	bra	fdc_command
;
;
fdc_step_out:
	move	cmd_step_out(pc),d7
	bra	fdc_command
;
;
fdc_force_int:
	move	cmd_force_int(pc),d7
	bsr	write_1772
	move	#$200,d7
.delay_lp:
	dbra	d7,.delay_lp
	rts
;
;
fdc_read_mult:
	move.l	fdp_sector_bf_p(a5),d7
	bsr	sub_setdma
	move	#12,d7				;12 => 6 Kbytes
	bsr	sub_setcnt
	move	#dma_srsec,(hw_dmamode).w
	move	fdp_sector(a5),d7
	bsr	write_1772
	move	cmd_read_mult(pc),d7
	bsr	fdc_command
fdc_readstat:
	move	(hw_dmamode).w,d0
	and	#7,d0
	move	d0,fdp_dma_state(a5)
	clr.l	d1
	move.b	(hw_dmabase2).w,d1
	lsl.l	#8,d1
	move.b	(hw_dmabase1).w,d1
	lsl.l	#8,d1
	move.b	(hw_dmabase0).w,d1
	move.l	d1,fdp_dma_end_p(a5)
	sub.l	fdp_dma_start_p(a5),d1
	move	d1,fdp_translen_2(a5)
	rts
;
;
fdc_read_id:
	move.l	fdp_short_delay(a5),fdp_timeout_dly(a5)
	move.l	fdp_idstat_bf_p(a5),a4
	move.l	fdp_id_bf_p(a5),d7
	bsr	sub_setdma
	move	#1,d7				;1 => 512 bytes
	bsr	sub_setcnt
	move	fdp_id_count(a5),d4
	subq	#1,d4
	bgt.s	.use_id_count
	move	#1,fdp_id_count(a5)
	clr	d4
.use_id_count:
	and	#$7f,d4
.id_loop:
	move	cmd_read_id(pc),d7
	bsr	fdc_command
	move.b	d0,(a4)+
	tst	fdp_timeout_f(a5)
	dbne	d4,.id_loop
	bra	fdc_readstat
;
;
fdc_read_trk:
	move.l	fdp_track_bf_p(a5),d7
	bsr	sub_setdma
	move	#16,d7				;16 => 8 Kbytes
	bsr	sub_setcnt
	move	cmd_read_trk(pc),d7
	bsr	fdc_command
	bra	fdc_readstat
;
fdc_write_mult:
	move.l	fdp_sector_bf_p(a5),d7
	bsr	sub_setdma
	move	#dma_swcmd,fdp_dmamode(a5)
	move	#12,d7				;12 => 6 Kbytes
	bsr	sub_setcnt
	move	#dma_swsec,(hw_dmamode).w
	move	fdp_sector(a5),d7
	bsr	write_1772
	move	cmd_write_mult(pc),d7
	bsr	fdc_command
	bra	fdc_readstat
;
;
fdc_write_trk:
	move.l	fdp_track_bf_p(a5),d7
	bsr	sub_setdma
	move	#dma_swcmd,fdp_dmamode(a5)
	move	#16,d7				;16 => 8 Kbytes
	bsr	sub_setcnt
	move	cmd_write_trk(pc),d7
	bsr	fdc_command
	bra	fdc_readstat
;
;
fdc_rd_reg_sect:
	move	#dma_srsec,(hw_dmamode).w
	bsr	read_1772
	and	#$ff,d0
	move	d0,fdp_sector(a5)
	move	#dma_srcmd,(hw_dmamode).w
	rts
;
;
fdc_rd_reg_trk:
	move	#dma_srtrk,(hw_dmamode).w
	bsr	read_1772
	and	#$ff,d0
	move	d0,fdp_track(a5)
	move	#dma_srcmd,(hw_dmamode).w
	rts
;
;
fdc_rd_reg_stat:
	move	#dma_srcmd,(hw_dmamode).w
	bsr	read_1772
	and	#$ff,d0
	move	d0,fdp_fdc_state(a5)
	rts
;
;
fdc_wr_reg_trk:
	move	#dma_srtrk,(hw_dmamode).w
	move	fdp_track(a5),d7
	bsr	write_1772
	move	#dma_srcmd,(hw_dmamode).w
	rts
;
;
fdc_driveside:
	clr.l	d7
	move	fdp_driveside(a5),d7	;b2 = ~B_sel  b1 = ~A_sel  b0 = ~Side
	bne.s	.keep_motor
	bsr	fdc_motor_off
	move	#1,fdp_vblres_f(a5)
.keep_motor:
	eor.b	#7,d7
	and	#7,d7
	move	SR,-(sp)
	or	#$0700,SR
	move.b	#14,(hw_giselect).w
	move.b	(hw_giselect).w,d0
	and.b	#$f8,d0
	or.b	d0,d7
	move.b	d7,(hw_giwrite).w
	move	(sp)+,SR
	rts
;
;
;End of:	Subroutines for complex FDC access
;----------------------------------------------------------------------------
	endm	;install_fdc_code
;----------------------------------------------------------------------------
	ENDC	;RA_FDC_defined
;----------------------------------------------------------------------------
;End of file:	RA_FDC.S
;----------------------------------------------------------------------------
