;----------------------------------------------------------------------------
;File name:	FDC_STEP.S		Revision date:	1995.08.16
;Creator:	Ulf Ronald Andersson	Creation date:	1993.01.29
;(c)1992 by:	Ulf Ronald Andersson	All rights reserved
;Released as:	SHAREWARE		(NB: commercial sales forbidden!)
;Project:	FDC_test		Revision:	1.00
;File purpose:	Source for low level FDC test monitor
;----------------------------------------------------------------------------
	include	URAn_APP.S
	include	URAn_SIM.S
	include	URAn_FDC.S
;----------------------------------------------------------------------------
	section	data
	_uniref	aes_data
	_uniref	vdi_data
	make	GEM_links
;----------------------------------------------------------------------------
	section	text
;----------------------------------------------------------------------------
init_app:
	tst	d7
	bpl.s	gem_init
tos_init:
	rts
;
gem_init:
	lea	tree1+tree1max*24+8(pc),a0
	or	#lastob,(a0)
	move	#tree1max,d4	;Convert main dialog coordinates.
	move.l	#tree1,addrin-rz(a6)
	bsr	obj_fix
	rts
;
;
exec_app:
	install_FDC
	move.l	d0,fdp_parm_p
	move.l	d0,a5
	move	#2,d0
	move	d0,drive_num
	move	d0,fdp_driveside(a5)
	fdcbios	fd_driveside
	fdcbios	fd_rd_reg_trk
	move	d0,track_num
	tst	d7
	bpl.s	gem_exec
tos_exec:
	moveq	#-1,d0
	bra.s	exit_tos
;
;
exit_app:
	bsr	obj_offset
	move	#3,intin-rz(a6)
	bsr	f_dial
	clr.l	d0
exit_tos:
	move.l	d0,-(sp)
	fdcbios	fd_force_int
	remove_FDC
	move.l	(sp)+,d0
	rts
;
;
gem_exec:
	move	#arrow,intin-rz(a6)
	sub_aes	#graf_mouse
	move.l	#tree1,addrin-rz(a6)
	bsr	f_center
	move	#0,intin-rz(a6)	;Prepare to display dialog.
	bsr	f_dial
waitdraw:
	bsr	obj_offset
	move.l	fdp_parm_p(pc),a5
	move	drive_num(pc),fdp_driveside(a5)
	fdcbios	fd_driveside
	fdcbios	fd_rd_reg_trk
	tst.b	d0
	bpl.s	.use_track
	moveq	#10,d0
	move	d0,fdp_track(a5)
	fdcbios	fd_wr_reg_trk
.use_track:
	move	d0,track_num
	move	fdp_driveside(a5),d0
	and	#6,d0
	beq.s	.keep_data
	move.l	#my_id_buff,fdp_id_bf_p(a5)
	move.l	#my_idstat_buff,fdp_idstat_bf_p(a5)
	move	#16,fdp_id_count(a5)
;;;	fdcbios	fd_read_id
	fdcbios	fd_force_int
.keep_data:
	lea	id_num_s(pc),a0
	lea	my_id_buff(pc),a1
	moveq	#6-1,d2
.conv_id_lp:
	move.b	#' ',-1(a0)
	clr.l	d0
	move.b	(a1)+,d0
	bsr	conv2hex
	addq	#3,a0
	dbra	d2,.conv_id_lp
	move	drive_num(pc),d0
	or	#'0',d0
	move.b	d0,drivenum_s
	clr.l	d0
	move	track_num(pc),d0
	lea	tracknum_s(pc),a0
	move	#10,d1
	bsr	conv3dig
	gemdos	Malloc,#-1
	lsr.l	#8,d0
	lsr.l	#2,d0
	move	#10,d1
	lea	freenums(pc),a0
	bsr.s	conv4dig
	move.l	#tree1,addrin-rz(a6)
	move.w	#0,intin-rz(a6)
	move.w	#3,intin+2-rz(a6)
	bsr	obj_draw		;Redraw dialog box
	move.l	#tree1,addrin-rz(a6)
	bsr	formdo			;await user event (buttons)
	move	d0,d1
	mulu	#24,d1
	lea	tree1(pc),a0
	and	#(-1-selected),10(a0,d1)
	cmp	#2,d0		;"Info" button	?
	beq	infoshow
	cmp	#3,d0		;"Exit" button	?
	beq	exit_app
	cmp	#4,d0		;"ID= ..."	?
	beq	waitdraw
	cmp	#6,d0		;<-- DSnum	?
	beq	dec_drive
	cmp	#8,d0		;    DSnum -->	?
	beq	inc_drive
	cmp	#9,d0		;" Track "	?
	beq	res_track
	cmp	#10,d0		;<-- Trnum	?
	beq	dec_track
	cmp	#12,d0		;    Trnum -->	?
	beq	inc_track
	bra	waitdraw	;Non valid input, return.
;
;
conv4dig:
	movem.l	a0/a1,-(sp)
	swap	d1
	move	#4,d1
	bra.s	convxdig
;
conv3dig:
	movem.l	a0/a1,-(sp)
	swap	d1
	move	#3,d1
	bra.s	convxdig
;
conv2hex:
	moveq	#16,d1
conv2dig:
	movem.l	a0/a1,-(sp)
	swap	d1
	move	#2,d1
convxdig:
	move.l	a0,a1
	add	d1,a0
	clr.b	(a0)
	subq	#1,d1
	andi.l	#$FFFF,d0
convxdiglp1:
	swap	d1
	divu	d1,d0
	swap	d1
	swap	d0
	cmp	#10,d0
	blo.s	convxlodig
	addq	#7,d0
convxlodig:
	add	#'0',d0
	move.b	d0,-(a0)
	clr	d0
	swap	d0
	dbeq	d1,convxdiglp1
	subq	#1,d1
	blt.s	convxdigexit
convxdiglp2:
	move.b	#' ',-(a0)
	dbra	d1,convxdiglp2
convxdigexit:
	swap	d1
	movem.l	(sp)+,a0/a1
	rts
;
;
convhdig0:
	move	#16,d1
convdig0:
	swap	d0
convdig:
	clr	d0
	swap	d0
	divu	d1,d0
	swap	d0
	cmp	#10,d0
	blo.s	convlodig
	addq	#7,d0
convlodig:
	add	#'0',d0
	rts
;
;
infoshow:
	clr	d4
	lea	infotab(pc),a4
.infoshowlp:
	cmp	#infomax,d4
	bls.s	.infoshowok
	clr	d4
.infoshowok:
	move	#1,intin-rz(a6)	;Show 'about' alert box.
	move.l	(a4,d4),addrin-rz(a6)
	sub_aes	#form_alert
	cmp	#3,d0		;"Ok" button ?
	beq	waitdraw	;If so, exit
	addq	#4,d4
	cmp	#1,d0		;"More" button ?
	beq.s	.infoshowlp
	subq	#8,d4		;oh, it was "Back" button !
	bhs.s	.infoshowlp
	moveq	#infomax,d4
	bra.s	.infoshowlp
;
;
dec_drive:
	moveq	#-1,d0
	bra.s	add_drive
;
inc_drive:
	moveq	#1,d0
add_drive:
	add	d0,drive_num-rz(a6)
	and	#7,drive_num-rz(a6)
	bra	waitdraw
;
;
scalestep:
	move	d0,-(sp)
	move	d1,-(sp)
	bios	Kbshift,?
	swap	d0
	move	(sp)+,d0
	swap	d0
	moveq	#1,d1
	and	#$0f,d0
	beq.s	scalestep1
	swap	d0
	mulu	d0,d1
	cmp.l	#$40000,d0
	blo.s	scalestep1
	mulu	d0,d1
scalestep1:
	move	(sp)+,d0
	muls	d1,d0
	rts
;
;
dec_track:
	moveq	#-1,d0
	bra.s	find_track
;
res_track:
	clr	track_num
	clr	d3
	bra.s	restore_track
;
inc_track:
	moveq	#1,d0
find_track:
	moveq	#16,d1
	bsr	scalestep
	move	track_num(pc),d3
	add	d0,d3
	ble.s	restore_track
	and	#$7f,d3
	bne.s	seek_track
restore_track:
	clr	track_num
	clr	fdp_track(a5)
	fdcbios	fd_restore
	bra	waitdraw
;
seek_track:
	move	d3,fdp_track(a5)
	fdcbios	fd_seek
	bra	waitdraw
;
;
;	*******************************
;	* Operating system functions. *
;	*******************************
;
obj_draw:
	move.l	fcx+0(pc),intin+4-rz(a6)	;form X,Y
	move.l	fcx+4(pc),intin+8-rz(a6)	;form W,H
	sub_aes	#objc_draw
	rts
;
;
obj_fix:
	move	d4,intin-rz(a6)	;Repeat for all objects in tree.
	sub_aes	#rsrc_obfix
	dbra	d4,obj_fix
	rts
;
;
obj_offset:
	clr	intin-rz(a6)
	move.l	#tree1,addrin-rz(a6)
	sub_aes	#objc_offset
	move.l	intout+2(pc),fcx+0-rz(a6)	;form X,Y
	rts
;
;
formdo:
	clr	intin-rz(a6)
	sub_aes	#form_do
	rts
;
;
f_center:
	sub_aes	#form_center
	move.l	intout+2(pc),fcx+0-rz(a6)	;form X,Y
	move.l	intout+6(pc),fcx+4-rz(a6)	;form W,H
	rts
;
;
f_dial:
	lea	intin+2(pc),a0
	clr.l	(a0)+		;origo X,Y
	clr.l	(a0)+		;origo W,H
	move.l	fcx+0(pc),(a0)+	;form X,Y
	move.l	fcx+4(pc),(a0)+	;form W,H
	sub_aes	#form_dial
	rts
;
;----------------------------------------------------------------------------
;
	install_fdc_code
;
;----------------------------------------------------------------------------
;
	make	SIM_links
;
;----------------------------------------------------------------------------
;
	section	data
;
infoalert0:
	dc.b	"[0]["
	dc.b	" FDC_test 1.0 of 1993.01.29  |"
	dc.b	" by Ulf Ronald Andersson|"
	dc.b	"][ More | Back | ok ]",0
;
infoalert1:
infoalert2:
infoalert3:
infoalert4:
infoalert5:
infoalert6:
	dc.b	"[0]["
	dc.b	"                             |"
	dc.b	"][ More | Back | ok ]",0
	even
;
infotab:
	dc.l	infoalert0
infoend:
	dc.l	NUL
;
infomax	=	infoend-infotab-4
;
;----------------------------------------------------------------------------
;
;	*********************************
;	* Data for the main dialog box. *
;	*********************************
;
fcx:	ds.w	4		;Storage for form center.
;
tree1:
.obj_0	dc.w	-1,1,tree1max
	dc.w	g_box,none,outlined
	dc.l	$21100,$000000,$22000a
.obj_1	dc.w	2,-1,-1
	dc.w	g_string,none,normal
	dc.l	formname_1_s,$010001,$000001
.obj_2	dc.w	3,-1,-1
	dc.w	g_button,selectable|exit,normal
	dc.l	infobutt_s,$190001,$060001
.obj_3	dc.w	4,-1,-1
	dc.w	g_button,selectable|exit|default,normal
	dc.l	exitbutt_s,$190008,$060001
.obj_4	dc.w	5,-1,-1
	dc.w	g_string,selectable|exit,normal
	dc.l	id_mark_s,$010003,$160001
.obj_5	dc.w	6,-1,-1
	dc.w	g_string,none,normal
	dc.l	drive_s,$010006,$000001
.obj_6	dc.w	7,-1,-1
	dc.w	g_button,selectable|exit,normal
	dc.l	leftbutt_s,$080006,$020001
.obj_7	dc.w	8,-1,-1
	dc.w	g_button,exit,normal
	dc.l	drivenum_s,$0a0006,$040001
.obj_8	dc.w	9,-1,-1
	dc.w	g_button,selectable|exit,normal
	dc.l	rightbutt_s,$0e0006,$020001
.obj_9	dc.w	10,-1,-1
	dc.w	g_string,selectable|exit,normal
	dc.l	track_s,$110006,$070001
.obj_10	dc.w	11,-1,-1
	dc.w	g_button,selectable|exit,normal
	dc.l	leftbutt_s,$190006,$020001
.obj_11	dc.w	12,-1,-1
	dc.w	g_button,exit,normal
	dc.l	tracknum_s,$1b0006,$040001
.obj_12	dc.w	13,-1,-1
	dc.w	g_button,selectable|exit,normal
	dc.l	rightbutt_s,$1f0006,$020001
.obj_13	dc.w	0,-1,-1
	dc.w	g_string,none,normal
	dc.l	freeramstr,$010008,$000001
tree1end:
;
tree1max	=	(tree1end-tree1)/24-1
;
;
;	Dialog data
;
drive_num:	ds.w	1
track_num:	ds.w	1
;
;
;	* Text for dialog box.
;
infobutt_s:	dc.b	'Info',NUL
exitbutt_s:	dc.b	'Exit',NUL
leftbutt_s:	dc.b	'<',NUL
rightbutt_s:	dc.b	'>',NUL
id_mark_s:	dc.b	'ID = '
ID_num_s:	dc.b	'00 00 00 00 00 00',NUL
drive_s:	dc.b	'DrSide',NUL
track_s:	dc.b	' Track ',NUL
drivenum_s:	dc.b	'7',NUL
tracknum_s:	dc.b	'777',NUL
freeramstr:	dc.b	'KB free RAM = '	;NB: unterminated
freenums:	dc.b	'4096',NUL
;
formname_1_s:	dc.b	'FDC_test Version 1.00',NUL
acc_name:	dc.b	'  FDC_test 1.00',NUL
	even
;
;----------------------------------------------------------------------------
;
	section	bss
;
message:	ds.b	16	;Message pipe.
intin:		ds.w	30
ptsin:		ds.w	30
ptsout:		ds.w	12
intout:		ds.w	45
		ds.l	100
mystack:	ds.w	1	;User defined stack (goes backwards).
;
fdp_parm_p:	ds.l	1	;	fdcbios parameter pointer
my_idstat_buff:	ds.b	128
my_id_buff:	ds.b	128*6
;
;----------------------------------------------------------------------------
	end
;----------------------------------------------------------------------------
;End of	file:	FDC_STEP.S
;----------------------------------------------------------------------------
