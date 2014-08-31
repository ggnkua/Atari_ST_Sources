;----------------------------------------------------------------------------
;	File select subroutine
;
;arg1 -> path string, possibly with unwanted filename attached
;arg2 -> file mask, null => "*.*"
;arg3 -> initial file name
;arg4 -> prompt string
;
;returns d0 -> path string (arg1) with selected filename, or null on CANCEL
;-------------------------------------
;
fselect_sub:
	link	a6,#0
	movem.l	d1-d2/a0-a2,-(sp)
	clr.l	addrin
	clr	intin
	move.l	#$4E010101,d0	;graf_mouse
	bsr	.call_aes
	move.l	8(a6),a1
	tst.b	(a1)
	bne.s	.restart_name_1
	bsr	getdrvpath_ia1
.restart_name_1:
	move.l	a1,a2		;a2 -> prel name_start
.test_name_1:
	move.b	(a1)+,d0
	beq.s	.have_name_1
	cmp.b	#'\',d0
	bne.s	.test_name_1
	bra.s	.restart_name_1
;
.stars_s:
	dc.b	'*.*',NUL		;NB: 4 bytes
.curr_drive:
	dc.w	-1
;
.have_name_1:
	move.l	12(a6),a1
	bgt.s	.make_mask
	lea	.stars_s(pc),a1
.make_mask:
	move.b	(a1)+,(a2)+
	bne.s	.make_mask
	clr.b	(a2)
	lea	addrin(pc),a0
	move.l	8(a6),(a0)+		;addrin[0] -> path buffer
	move.l	16(a6),(a0)+		;addrin[1] -> name buffer
	move.l	20(a6),(a0)+		;addrin[2] -> prompt string
	bsr.s	try_fsel_exinput	;call AES fsel_exinput or fsel_input
	clr.l	d0
	tst	intout
	beq.s	.exit			;exit on error
	tst	intout+2
	beq.s	.exit			;exit on [CANCEL] button
	lea	fsel_path(pc),a0
	clr	d0
	move.b	(a0)+,d0		
	cmp	#'z',d0
	bgt.s	.no_upper
	cmp	#'a',d0
	blt.s	.no_upper
	bclr	#5,d0
.no_upper:
	cmp	#'Z',d0
	bgt.s	.no_drivespec
	sub	#'A',d0
	blt.s	.no_drivespec
	cmp.b	#':',(a0)
	beq.s	.have_drivespec
.no_drivespec:
	gemdos	Dgetdrv
.have_drivespec:
	move	d0,curr_drive		;use same drive after success
	move.l	8(a6),a0
.restart_name_2:
	move.l	a0,a2		;a2 -> prel name_start after path
.test_name_2:
	move.b	(a0)+,d0
	beq.s	.have_name_2
	cmp.b	#'\',d0
	bne.s	.test_name_2
	bra.s	.restart_name_2
;
.have_name_2:
	move.l	16(a6),a1	;a1 -> file name
.copy_name:
	move.b	(a1)+,(a2)+
	bne.s	.copy_name
	move.l	8(a6),d0	;return path with name
.exit:
	movem.l	d1-d2/a0-a2,-(sp)
	unlk	a6
	rts
;
;-------------------------------------
;
try_fsel_exinput:
	move.l	addrin+2*4,d0
	ble.s	.use_fileselector
	move.l	#$5A000202,d1	;AES fsel_input
	move.l	#'FSEL',d0
	bsr.s	seek_cookie_d0
	bpl.s	.use_new_selector
	bsr.s	what_TOS_version
	cmp	#$0104,d0
	blt.s	.use_fileselector
.use_new_selector:
	move.l	#$5B000203,d1	;AES fsel_exinput
.use_fileselector:
	move.l	d1,d0
	bsr	call_aes
	rts
;
;-------------------------------------
;
what_TOS_version:
	movem.l	d1-d7/a0-a6,-(sp)
	gemdos	super|_ind,#1
	move.l	d0,d7
	bmi.s	.sup_seek_1
	gemdos	super,!
	move.l	d0,d7
.sup_seek_1:
	move.l	(_sysbase).w,a0
	move.l	os_version(a0),d0
	bra.s	super_return
;
;-------------------------------------
;
seek_cookie_d0:
	movem.l	d1-d7/a0-a6,-(sp)
	move.l	d0,d3
	gemdos	super|_ind,#1
	move.l	d0,d7
	bmi.s	.sup_seek_1
	gemdos	super,!
	move.l	d0,d7
.sup_seek_1:
	moveq	#-34,d0		;prep 'path not found' error
	move.l	(_cookies).w,d1
	beq.s	.super_return
	move.l	d1,a0
	moveq	#-33,d0		;prep 'file not found' error
.seek_cookie_loop:
	tst.l	(a0)
	beq.s	.super_return
	cmp.l	(a0),d3
	beq.s	.seek_cookie_found
	addq.l	#8,a0
	bra.s	.seek_cookie_loop
;
.seek_cookie_found:
	move.l	a0,d0
super_return:
	exg	d0,d7
	tst.l	d0
	bmi.s	.keep_super
	gemdos	Super|_ind,d0
.keep_super:
	move.l	d7,d0
	movem.l	(sp)+,d1-d7/a0-a6
	rts
;
;-------------------------------------
;
call_aes:
	movem.l	d1-d7/a0-a6,-(sp)
	lea	contrl(pc),a0
	clr.l	(a0)+
	clr.l	(a0)+
	clr	(a0)
	movep.l	d0,-7(a0)
	cmpi.b	#$70,-7(a0)
	bne.s	.done_saddrout
	move.b	#1,1(a0)
.done_saddrout:
	lea	aes_pb(pc),a0
	move.l	a0,d1
	move	#$C8,d0			;aes code
	trap	#2			;xgemdos
	moveq	#0,d0
	move	intout(pc),d0
	movem.l	(sp)+,d1-d7/a0-a6
	rts
;
;-------------------------------------
;
getdrvpath_ia1:
	movem.l	d0-d2/a0-a2,-(sp)
	move.l	a1,-(sp)
	move	curr_drive,d0
	bmi.s	.get_drive
	gemdos	Mediach,d0
	tst.l	d0
	bne.s	.get_drive
	move	curr_drive(pc),d0
	bra.s	.put_drive
;
.get_drive:
	gemdos	Dgetdrv
.put_drive:
	move.b	d0,curr_drive
	add	#'A',d0
	move.l	(sp),a1
	move.b	d0,(a1)+
	move.b	#':',(a1)+
	sub	#'A',d0
.get_path:
	addq	#1,d0
	gemdos	Dgetpath,(a1),d0
	move.l	(sp)+,a0
.pass_str:
	tst.b	(a0)+
	bne.s	.pass_str
	subq	#1,a0
	move.b	#'\',(a0)+
	move.b	#'*',(a0)+
	move.b	#'.',(a0)+
	move.b	#'*',(a0)+
	clr.b	(a0)
	movem.l	(sp)+,d0-d2/a0-a2
	rts
;
;
;----------------------------------------------------------------------------
