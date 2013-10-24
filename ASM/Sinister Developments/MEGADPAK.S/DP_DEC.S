	clr.l	not_packed
	
	move.l	load_here(pc),a0
	move.l	a0,save_here

; ATOM packer options

	cmp.l	#'ATOM',(a0)	; is it ATOM ?
	beq	atom_decide

	cmp.l	#'ATOM',538(a0)	; ATOM v3.3 packed prog ?
	beq	a33_prg

	cmp.l	#'ATOM',516(a0)	; ATOM v3.3 packed prog ?
	beq	a31_prg

	cmp.l	#'ATM5',(a0)	; is it ATOM v3.5 packed data ?
	beq	a35_DAT

	cmp.l	#'3.5 ',634(a0)	; ATOM v3.5 packed prog ?
	beq	a35_prg

	cmp.l	#'ACK ',634(a0)	; lame text edited ATOM
	beq	a35_prg

; FIRE packer options

	cmp.l	#'FIRE',(a0)	; is it FIRE packed data
	beq	fire2_DAT

	cmp.l	#'ire!',36(a0)	; is it a FIREv2 packed prog
	beq	fir2_prog

	cmp.l	#'ire ',36(a0)	; is it a FIREv1 packed prog
	beq	fir1_prog

; ICE packer options

	cmp.l	#'Ice!',(a0)	; is it pre 2.3 dat?
	beq	ice_decide

	cmp.l	#$610000a0,70(a0)	; is it 1.1 prog?
	beq	ice_1_1_prg

	cmp.w	#$2e3c,54(a0)	; is it 2.0 prog?
	beq	ice_2_0_prg

	cmp.l	#'Ice!',452(a0)	; is it ICE 2.2 prog ?
	beq	ice_2_2_prg

	cmp.l	#'ICE!',(a0)	; is it ICE 2.4 packed data ?
	beq	I24_3_DAT

	cmp.l	#'ICE!',442(a0)	; is it ICE 2.4 prog ?
	beq	ice_2_4_prg

	cmp.l	#'ICE!',448(a0)	; is it ICE 2.3 prog ?
	beq	ice_2_3_prg

	cmp.l	#$41fa0220,$1c(a0)	; superior prog ?
	beq	sup_prg
	
; All the JAM packed permutations coming up folks

	cmp.l	#'JAM ',672(a0)	; is it a JAM v1 progfile ?
	beq	JAM1_prg

	cmp.l	#'JAM ',674(a0)	; is it a JAM v1 progfile ?
	beq	JAM1_prg

	cmp.l	#'JAM ',706(a0)	; is it a JAM v1 progfile ?
	beq	JAM1_prg

	cmp.l	#'LSD!',758(a0)	; is it v2 & JAM4 progfile ?
	beq	v2JAM4

	cmp.l	#'LZH!',1170(a0)	; is it LZH & JAM3 progfile ?
	beq	LZHJAM3

	cmp.l	#'LZH!',1194(a0)	; is it LZH & JAM4 progfile ?
	beq	LZHJAM4

	cmp.l	#'LZW!',544(a0)	; is it LZW & JAM4 progfile ?
	beq	LZWJAM4

	cmp.l	#'LSD!',1170(a0)	; is it v2 & JAM3 progfile ?
	beq	v2JAM3

	cmp.l	#'Ice!',712(a0)	; is it Ice & JAM4 progfile
	beq	ICEJAM4

	cmp.l	#'LZH!',(a0)	; is it an LZH datafile
	beq	LZH_DAT_dep

	cmp.l	#'LZW!',(a0)	; is it an LZW datafile
	beq	LZW_DAT_dep

; Automation packed things

	cmp.l	#$2e337200,482(a0)	; is it v2.3r prog file
	beq	aut_23r_prg

	cmp.l	#$2e353100,482(a0)	; is it v2.51 prog file
	beq	aut_251_prg

	cmp.l	#$2e357200,482(a0)	; is it v2.51 prog file
	beq	aut_251_prg

	cmp.l	#'LSD!',(a0)	; is it an automation data file
	beq	aut_DAT
	cmp.l	#'LSD$',(a0)	; is it an automation data file
	beq	aut_DAT
	cmp.l	#'AUTM',(a0)	; is it an automation data file
	beq	aut_DAT

	cmp.l	#'LSDC',(a0)	; is it a chunk packed file
	beq	aut_chunky

	cmp.l	#'AU5!',836(a0)	; is it v5.01 prog file
	beq	aut_501_prg

	cmp.l	#'AU5!',(a0)	; is it v5.01 data file
	beq	aut_501_dat

; sentry 2.05 packed stuff
	cmp.l	#'2.05',522(a0)
	beq	sent_205

; LSD 1.2 prog file

	cmp.l	#'PLEA',638(a0)	; is it an LSD 1.2 prog file
	beq	LSD_12_prg

; JEK 1.2d prog file

	cmp.l	#'JEK ',638(a0)	; is it a JEK 1.2d prog file
	beq	JEK_12d_prg

; JEK 1.3d prog file

	cmp.l	#'JEK ',646(a0)	; is it a JEK 1.3d prog file
	beq	JEK_13d_prg

; PFX packer 

	cmp.l	#'-lz5',422(a0)
	beq	pfx_prg1
	cmp.l	#'-lz5',586(a0)
	beq	pfx_prg2
	cmp.l	#'-lz5',1052(a0)
	beq	pfx_prg3

; qpack

	cmp.l	#'2-JM',4(a0)
	beq	qpack_dat

	cmp.l	#'2-JM',52(a0)
	beq	qpack_prg

; bytekiller prog file

	cmp.l	#$7fd00,72(a0)	; is it a bytekiller prog
	beq	bytekiller_prg

	cmp.l	#$224a7053,72(a0)	; is it a bytekiller3 prog
	beq	bytekiller3_prg

	cmp.l	#$487a00aa,$1c(a0)	; is it a russ's bytekiller prog
	beq	rp_bytekiller_prg

; gollum prog file with huffmans encoding

	cmp.l	#$22572c7a,192(a0)	; is it gollum with huff
	beq	gollum_prg_huff

; gollum prog file

	cmp.l	#$42401018,192(a0)	; is it gollum with
	beq	gollum_prg
; BRAS prog file

	cmp.l	#'BRAS',30(a0)
	beq	BRAS_prg

; Dcsquish progs

	cmp.w	#'14',$3a(a0)	; 1.4
	beq	dcs1_4_prg

	cmp.w	#'12',$3a(a0)	; 1.2
	beq	dcs1_2_prg

	cmp.w	#'10',$3a(a0)	; 1.0
	beq	dcs1_0_prg

; 4pak prog file

	cmp.w	#$4ef9,60(a0)	; is it 4pak
	beq	_4pak_prg

; happy prog file

	cmp.l	#'EASY',52(a0)	; is it a happy prog
	beq	happy_prg


; Thunder V1 prog file

	cmp.l	#'ATOM',422(a0)	; is it a thunder v1 prog
	bne.s	.carry_on
	cmp.w	#$601a,(a0)
	beq	thunv1_prg		
; Thunder V2 prog file

.carry_on	cmp.l	#'ATOM',452(a0)	; is it a thunder v2 prog
	beq	thunv2_prg

; Speed packer v2 prog file

	cmp.l	#'SP20',542(a0)	; is it a speed v2 prog
	beq	speed2_prg

; Speed packer v3 prog file

	cmp.l	#$4e417633,$1c(a0)	; is it a speed v2 prog
	beq	speed3_prg

; Speed packer v2 datafile

	cmp.l	#'SP20',(a0)	; is it a speed v2 prog
	beq	speed2_data

; Speed packer v3 datafile

	cmp.l	#'SPv3',(a0)	; is it a speed v2 prog
	beq	speed3_data

; unknown 1
	cmp.l	#$41fa062e,40(a0)
	beq	unknown1

; stos packed progs
	cmp.l	#$7fd00,68(a0)
	beq	stos_prg

; ivory dragon packed progs

	cmp.l	#$610000b2,$60(a0)
	beq	ivory_dragon_prg

	cmp.l	#'PAWN',544(a0)
	beq	ivory_dragon_prg

; vic2/calif2 games

	cmp.l	#'Vic2',(a0)
	beq	v2_cal2_dat

; IFF files
	cmp.l	#'FORM',(a0)
	beq	iff_file
; neo object files
	cmp.l	#'NEOO',(a0)
	beq	neo_object
; lharc files
	cmp.l	#'-lh1',2(a0)
	beq	lharc1_file
	cmp.l	#'-lh5',2(a0)
	beq	lharc5_file
; ZOO files
	cmp.l	#'ZOO ',(a0)
	beq	zoo_file

; pk zip files
	cmp.w	#'PK',(a0)
	beq	zip_file

	cmp.w	#$601a,(a0)	; is it a prog file
	beq.s	.1
.3	move.l	a0,a1
	add.l	file_length(pc),a1
	bra.s	.2
; check for files with header at end.

.1	cmp.b	#0,6(a0)
	bne.s	.3
	move.l	a0,a1
	add.l	2(a0),a1
	add.l	6(a0),a1
	lea	$1c(a1),a1
.2	move.l	a1,d0
	and.w	#$fffe,d0
	move.l	d0,a1
	addq	#4,a1
	lea	-8(a1),a2
.loop	cmp.l	a2,a1
	blt.s	.go_on
	moveq	#0,d7
	move.b	(a1),d7
	lsl.l	#8,d7
	move.b	1(a1),d7
	lsl.l	#8,d7
	move.b	2(a1),d7
	lsl.l	#8,d7
	move.b	3(a1),d7
	cmp.l	#'END!',d7
	beq	LSD_dat_dep
	cmp.l	#'JEK!',d7
	beq	JEK_dat_dep
	cmp.l	#'POPI',d7
	beq	pp_test
	cmp.l	#'popi',d7
	beq	pp_test
	cmp.l	#'PUFF',d7
	beq	pp_test
	cmp.l	#'Fire',d7
	beq	fire1_DAT
	cmp.l	#'Ice!',d7
	beq	ice1_DAT
	cmp.l	#'PAWN',d7
	beq	ivory_drag_dat
	subq	#1,a1
	bra.s	.loop
.go_on	
; spectrum 512 packed file

	cmp.w	#'SP',(a0)
	beq	spec512

; degas PC1 -3

	cmp.w	#$8000,(a0)
	beq	degas
	cmp.w	#$8001,(a0)
	beq	degas
	cmp.w	#$8002,(a0)
	beq	degas

	cmp.w	#$601a,(a0)	; is it a prog file
	bne.s	.DAT_file
	move.l	a0,a1
	add.l	2(a0),a1
	add.l	6(a0),a1
	lea	$1c(a1),a1
	moveq	#0,d0
	move.l	4(a1),d0		; is there a relocation table
	bne.s	.probably_not_packed	; this is not foolproof
	cmp.l	#500,file_length
	ble.s	.probably_not_packed
	lea	exec(pc),a1
	bsr	update_type
	lea	prog_pp(pc),a1
	bsr	a1_2_packer
	bsr	redraw_details
	bra	.exit

.probably_not_packed
	lea	exec(pc),a1
	bsr	update_type
	lea	prog_np(pc),a1
	bsr	a1_2_packer
	bsr	redraw_details
	bra	.exit

; check for unpacked dat file

.DAT_file	moveq	#3,d1
	lea	fhdr(pc),a1
.loop1	move.b	(a0)+,d0		; get header
	cmp.b	#' ',d0		; we want to exit if
	blt.s	.not_ascii	; not ascii
	cmp.b	#'z',d0
	bgt.s	.not_ascii
	move.b	d0,(a1)+
	dbf	d1,.loop1

	moveq	#3,d1
.loop2	move.b	(a0)+,d0		; get next 4 bytes
	cmp.b	#' ',d0		; we want to exit
	blt.s	.ascii		; if not ascii
	cmp.b	#'z',d0
	bgt.s	.ascii
	dbf	d1,.loop2

	bra.s	.not_ascii

.ascii	lea	datafil(pc),a1
	bsr	update_type
	lea	dat_mp(pc),a1
	bsr	a1_2_packer
	bsr	redraw_details
	bra.s	.exit

.not_ascii
	cmp.l	#32128,file_length
	beq.s	.poss_neo
	cmp.l	#32034,file_length
	beq.s	.poss_degas
	cmp.l	#32066,file_length
	beq.s	.poss_degas
	move.l	load_here(pc),a0
	cmp.b	#$1a,(a0)
	beq.s	.poss_arc
	lea	datafil(pc),a1
	bsr	update_type
	lea	dat_np(pc),a1
	bsr	a1_2_packer
	bsr	redraw_details
.exit	move.l	#-1,not_packed
	rts
.poss_neo	lea	neo(pc),a1
	bsr	pic_dets	
	bsr	redraw_details
	bra.s	.exit
.poss_degas
	lea	degas_p(pc),a1
	bsr	pic_dets	
	bsr	redraw_details
	bra.s	.exit
.poss_arc
	lea	arc(pc),a1
	bsr	archive_dets	
	bsr	redraw_details
	bra.s	.exit

; Depack ATOM v3.1 packed program file

a31_prg	lea	atom_3_1(pc),a1
	bsr	exec_dets
	move.l	538(a0),unpacked_length
	move.w	#$4e75,98(a0)
	jsr	88(a0)
	move.l	a5,save_here
	rts

; Depack ATOM v3.3 packed program file

a33_prg	lea	atom_3_3(pc),a1
	bsr	exec_dets
	move.l	568(a0),unpacked_length
	move.w	#$4e75,86(a0)
	jsr	76(a0)
	move.l	a5,save_here
	rts

; depack ATOM v3.5 packed prog file

a35_prg	lea	atom_3_5(pc),a1
	bsr	exec_dets
	move.w	#$4e75,86(a0)	; modify depack code

	move.l	656(a0),unpacked_length	; get length
	movem.l	d0-a5,-(a7)	; jump into its depacker
	jsr	76(a0)
	move.l	a0,save_here	; get address
	movem.l	(a7)+,d0-a5

	rts

; Let user decide how to unpack atom data

atom_decide
	kill_form	main_menu
	bsr	mouse2pointer
	show_form	atom_clash	; show menu
	form_do	0
	cmp.b	#thun_butt,d0
	beq	.try_thun
	cmp.b	#v3_1_butt,d0
	beq.s	.try_3_1
	cmp.b	#v3_3_butt,d0
	beq	.try_3_3
	obj_chnge	piss_off_atom,0,0,atom_clash
	move.l	#-1,not_packed
	bsr	mouse2bee
	kill_form	atom_clash
	show_form	main_menu
	rts

.try_3_1	kill_form	atom_clash
	obj_chnge	v3_1_butt,0,0,atom_clash
	show_form	main_menu
	bsr	mouse2bee
	move.l	load_here(pc),a0
	lea	atom_3_1(pc),a1
	bsr	data_dets
	move.l	4(a0),unpacked_length
	move.l	a0,save_here
	bsr	atom_3_1_depack
	rts

.try_3_3	kill_form	atom_clash
	obj_chnge	v3_3_butt,0,0,atom_clash
	show_form	main_menu
	bsr	mouse2bee
	move.l	load_here(pc),a0
	lea	atom_3_3(pc),a1
	bsr	data_dets
	move.l	4(a0),unpacked_length
	move.l	a0,save_here
	bsr	atom_3_3_depack
	rts

.try_thun	kill_form	atom_clash
	obj_chnge	thun_butt,0,0,atom_clash
	show_form	main_menu
	bsr	redraw_main
	bsr	mouse2bee
	move.l	load_here(pc),a0
	lea	thun_2(pc),a1
	bsr	data_dets
	move.l	a0,a2
	move.l	4(a0),unpacked_length
	move.l	a0,a4
	add.l	file_length(pc),a4
	move.l	a4,save_here
	bsr	thunder_depack
	rts

; Depack ATOM v3.5 packed data

a35_DAT	lea	atom_3_5(pc),a1
	bsr	data_dets
	bsr	ATOM_depack_v3.5
	rts

; Depack FIREv1 packed prog

fir1_prog	lea	fire_1(pc),a1
	bsr	exec_dets
	lea	$1c(a0),a1
	add.l	34(a1),a1
	MOVEQ	#3,D0
	moveq	#0,d7
.1	MOVE.B	-(A1),D7
	ROR.L	#8,D7
	DBF	D0,.1
	move.l	d7,unpacked_length
	move.w	#$4e75,74(a0)
	jsr	54(a0)
	move.l	a6,save_here
	rts

; Depack FIREv2 packed prog

fir2_prog	lea	fire_2(pc),a1
	bsr	exec_dets
	move.l	56(a0),unpacked_length
	move.w	#$4e75,64(a0)
	jsr	(a0)
	move.l	a0,save_here	
	rts

; depack FIRE v1 packed data

fire1_DAT	move.l	a1,a4
	lea	fire_1(pc),a1
	bsr	data_dets
	move.l	a4,a1
	move.b	-4(a1),unpacked_length
	move.b	-3(a1),unpacked_length+1
	move.b	-2(a1),unpacked_length+2
	move.b	-1(a1),unpacked_length+3
	addq	#4,a1
	move.l	a1,save_here
	move.l	a1,d0
	sub.l	a0,d0
	bsr	FIRE1_depack
	rts

; depack FIRE v2 packed data

fire2_DAT	lea	fire_2(pc),a1
	bsr	data_dets
	bsr	FIRE2_depack
	rts

; Depack v 1.1 ICE packed prog

ice_1_1_prg
	lea	ice_1_1(pc),a1
	bsr	exec_dets

	move.w	#$4e75,74(a0)	; modify depack code
	move.l	$3e(a0),d0
	lea	$1c(a0),a1
	add.l	d0,a1
	move.b	-4(a1),unpacked_length
	move.b	-3(a1),unpacked_length+1
	move.b	-2(a1),unpacked_length+2
	move.b	-1(a1),unpacked_length+3

	movem.l	d0-a5,-(a7)	; jump into its depacker
	jsr	(a0)
	movem.l	(a7)+,d0-a5

	move.l	a6,save_here	; a6 returns pack address
	rts

; Depack v 2.0 ICE packed prog

ice_2_0_prg
	lea	ice_2_0(pc),a1
	bsr	exec_dets

	move.w	#$4e75,64(a0)	; modify depack code
	move.l	56(a0),unpacked_length	; get length from code

	movem.l	d0-a5,-(a7)	; jump into its depacker
	jsr	(a0)
	movem.l	(a7)+,d0-a5

	move.l	a6,save_here	; a6 returns pack address
	rts

; Depack v 2.2 ICE packed prog

ice_2_2_prg
	lea	ice_2_2(pc),a1
	bsr	exec_dets

	move.w	#$4e75,62(a0)	; modify depack code
	move.l	54(a0),unpacked_length	; get length from code

	movem.l	d0-a5,-(a7)	; jump into its depacker
	jsr	(a0)
	movem.l	(a7)+,d0-a5

	move.l	a6,save_here	; a6 returns pack address
	rts

; Depack ICE 2.3 packed prog

ice_2_3_prg
	lea	ice_2_3(pc),a1
	bsr	exec_dets

	move.w	#$4e75,62(a0)	; rts out depacker
	move.l	54(a0),unpacked_length
	move.l	a4,save_here
	movem.l	d0-a5,-(a7)	; jump into its depacker
	jsr	(a0)
	movem.l	(a7)+,d0-a5
	move.l	a6,save_here	; a6 returns pack address
	rts

; Depack ICE 2.4 packed prog

ice_2_4_prg
	lea	ice_2_4(pc),a1
	bsr	exec_dets
	move.w	#$4e75,62(a0)	; rts out depacker
	move.l	54(a0),unpacked_length
	jsr	(a0)
	move.l	a6,save_here	; a6 returns pack address
	rts

; Depack superior packed prog

sup_prg	lea	sup(pc),a1
	bsr	exec_dets
	move.w	#$4e75,38(a0)	; rts out depacker
	jsr	(a0)
	move.l	a0,save_here	; a6 returns pack address
	move.l	d6,unpacked_length
	rts

; depack ICE v1 packed data

ice1_DAT	move.l	a1,-(a7)
	lea	ice_1(pc),a1
	bsr	data_dets
	move.l	(a7)+,a1
	move.b	-4(a1),unpacked_length
	move.b	-3(a1),unpacked_length+1
	move.b	-2(a1),unpacked_length+2
	move.b	-1(a1),unpacked_length+3
	addq	#4,a1
	move.l	a1,d0
	sub.l	a0,d0
	bsr	ice1_depack
	move.l	a0,save_here
	rts

; Let user decide how to unpack v2.0/2.2 data

ice_decide
	kill_form	main_menu
	bsr	mouse2pointer
	show_form	pack_ice_clash
	form_do	0
	cmp.b	#v2_butt,d0
	beq.s	.try_2_0
	cmp.b	#v2_2_butt,d0
	beq.s	.try_2_2
	move.l	#-1,not_packed
	kill_form	pack_ice_clash
	obj_chnge	ice_piss_off,0,0,pack_ice_clash
	show_form	main_menu
	rts

.try_2_0	kill_form	pack_ice_clash
	obj_chnge	v2_butt,0,0,pack_ice_clash
	show_form	main_menu
	bsr	mouse2bee
	lea	ice_2_0(pc),a1
	bsr	data_dets
	move.l	load_here(pc),a0
	move.l	8(a0),unpacked_length
	move.l	a0,save_here
	bsr	ice_2_0_depack
	rts

.try_2_2	kill_form	pack_ice_clash
	obj_chnge	v2_2_butt,0,0,pack_ice_clash
	show_form	main_menu
	bsr	mouse2bee
	lea	ice_2_2(pc),a1
	bsr	data_dets
	move.l	load_here(pc),a0
	move.l	a0,a1
	add.l	file_length(pc),a1
	move.l	a1,save_here
	move.l	8(a0),unpacked_length
	bsr	ice_2_2_depack
	rts

; Depack ICE 2.4/3 data

I24_3_DAT	lea	ice_2_3_4(pc),a1
	bsr	data_dets

	move.l	a0,save_here
	bsr	ICE_depack_23_24
	rts

; unpack JAMpack v1 prog file

JAM1_prg	lea	jam_1(pc),a1
	bsr	exec_dets
	bra	go_on

; unpack JAMpack 3 using v2 compression prog file

v2JAM3	lea	jam_3_v2(pc),a1
	bsr	exec_dets
	move.w	#$4e75,166(a0)
	jsr	102(a0)
	move.l	a3,save_here
	move.l	a6,unpacked_length
	rts

; unpack JAMpack 3 using LZH compression prog file

LZHJAM3	lea	jam_3_lzh(pc),a1
	bsr	exec_dets
	move.w	#$4e75,166(a0)	; modify depack code
	jsr	102(a0)
	move.l	a3,save_here
	move.l	a6,unpacked_length
	rts

; unpack JAMpack 4 using v2 compression prog file

v2JAM4	lea	jam_4_v2(pc),a1
	bsr	exec_dets
	move.w	#$4e75,166(a0)	; modify depack code
	jsr	106(a0)
	move.l	a3,save_here
	move.l	a6,unpacked_length
	rts

; unpack JAMpack 4 using LZH compression prog file

LZHJAM4	lea	jam_4_lzh(pc),a1
	bsr	exec_dets
	move.w	#$4e75,166(a0)	; modify depack code
	jsr	106(a0)
	move.l	a3,save_here
	move.l	a6,unpacked_length
	rts

; unpack JAMpack 4 using LZW compression prog file

LZWJAM4	lea	jam_4_lzw(pc),a1
	bsr	exec_dets
	move.w	#$4e75,166(a0)	; modify depack code
	jsr	106(a0)
	move.l	a3,save_here
	move.l	a6,unpacked_length
	rts

; depack JAMpack 4 using ICE compression prog file

ICEJAM4	lea	jam_4_ice(pc),a1
	bsr	exec_dets
	move.l	720(a0),unpacked_length
	move.w	#$4e75,166(a0)	; modify depack code
	jsr	106(a0)
	move.l	a3,save_here
	rts

; depack LZH packed datafile

LZH_DAT_dep	
	lea	jam_3_4_lzh(pc),a1
	bsr	data_dets
	move.l	4(a0),unpacked_length
	lea	$400(a0),a1
	move.l	a1,save_here
	bsr	unpack_LZH
	rts

; depack LZW packed datafile

LZW_DAT_dep
	lea	jam_4_lzw(pc),a1
	bsr	data_dets
	move.l	4(a0),unpacked_length
	bsr	dp_LZW
	move.l	a1,save_here
	rts

; unpack automation prog file

aut_23r_prg
	lea	aut_2_3r(pc),a1
	bsr	exec_dets
	bra.s	dpboth

aut_251_prg
	lea	aut_2_51(pc),a1
	bsr	exec_dets
dpboth	lea	$1c(a0),a1
	lea	$1c(a0),a3
	add.l	2(a0),a3
	move.l	4(a3),unpacked_length
	move.l	#$4e714e71,32(a0)
	move.l	#$4e714e71,42(a0)
	move.w	#$4e75,202(a0)
	move.w	#$248b,40(a0)
	move.w	#$603c,64(a0)
	jsr	32(a0)
	move.l	a3,save_here
	rts

; unpack automation dat file

aut_DAT	lea	aut_2_3_5(pc),a1
	bsr	data_dets
	move.l	4(a0),unpacked_length
	lea	20(a0),a1
	move.l	a1,save_here
	bsr	depack_aut_23r_251
	rts

; unpack automation chunk packed file

aut_chunky
	lea	aut_chnk(pc),a1
	bsr	data_dets
	move.l	a0,a6
	add.l	file_length(pc),a0
	move.l	a0,d0		; set up buffer address
	and.w	#$fffe,d0
	addq.l	#8,d0
	move.l	d0,a1
	move.l	a1,save_here
	move.l	4(a6),unpacked_length
	lea	12(a6),a6		; start of offsets
.again	move.l	load_here(pc),a0	; start of file
	move.l	(a6)+,d0		; next offset
	cmp.l	#'LSD!',d0	; finished ?
	beq.s	.fin
	add.l	d0,a0		; get next chunk
	movem.l	a0-a6,-(a7)
	bsr	depack_aut_23r_251
	movem.l	(a7)+,a0-a6
	add.l	4(a0),a1		; depack to here next time
	bra.s	.again
.fin	rts

; Depack automation v5.01 packed program file

aut_501_prg
	lea	aut_5_01(pc),a1
	bsr	exec_dets
	lea	$1c(a0),a1
	lea	$1c(a0),a3
	add.l	2(a0),a3
	move.l	8(a3),unpacked_length
	move.l	#$4e714e71,32(a0)
	move.l	#$4e714e71,42(a0)
	move.w	#$4e75,202(a0)
	move.w	#$248b,40(a0)
	move.w	#$603c,64(a0)
	jsr	32(a0)
	move.l	a3,save_here
	rts

; Depack automation v5.01 data

aut_501_dat
	lea	aut_5_01(pc),a1
	bsr	data_dets
	bsr	ICE_depack_23_24
	rts

; depack sentry v2.05 packed programs
	
sent_205	lea	sent_2_05(pc),a1
	bsr	exec_dets
	move.l	a0,a1
	lea	$1c(a1),a6
	add.l	2(a0),a0
	lea	$1c(a0),a0
	move.w	#$4e75,106(a1)
	move.l	258(a1),unpacked_length
	jsr	98(a1)
	move.l	a2,save_here
	rts

; depack LSD packed datafile

LSD_dat_dep
	move.l	a1,-(a7)
	lea	lsd_1_2_3(pc),a1
	bsr	data_dets
	move.l	(a7)+,a1
	move.l	-4(a1),unpacked_length
	bra.s	lsd_datafil

; depack JEK packed datafile

JEK_dat_dep
	move.l	a1,-(a7)
	lea	jek_jam(pc),a1
	bsr	data_dets
	move.l	(a7)+,a1
	move.l	-4(a1),unpacked_length
	bra.s	lsd_datafil

; depack LSD & JEK packed program

LSD_12_prg
	lea	lsd_1_2(pc),a1
	bsr	exec_dets
	bra.s	go_on
JEK_12d_prg
	lea	jek_1_2d(pc),a1
	bsr	exec_dets
	bra.s	go_on
JEK_13d_prg
	lea	jek_1_3d(pc),a1
	bsr	exec_dets

go_on	move.l	a0,a1
	add.l	file_length(pc),a1
	move.l	a1,d0
	and.w	#$fffe,d0
	move.l	d0,a1
	addq	#4,a1
.again	cmp.w	#0,(a1)
	bne.s	.at_end
	subq	#2,a1
	bra.s	.again
.at_end	move.l	-2(a1),unpacked_length
	lea	2(a1),a1
lsd_datafil
	move.l	a1,store_end
	lea	926(a0),a1
	move.l	a1,save_add
	move.l	a1,save_here
	bsr	LSD_depack
	rts

; is it a pompey prog or dat file

pp_test	cmp.w	#$601a,(a0)
	bne	.pp_dat
	cmp.b	#0,6(a0)
	bne	.pp_dat
; depack pp prog file
	
	cmp.w	#$4e41,292(a0)
	beq.s	.1
	cmp.w	#$4e41,330(a0)
	beq	.2
	cmp.w	#$4e41,188(a0)
	beq	.3
	cmp.w	#$4e41,348(a0)
	beq	.4
	cmp.w	#$4e41,266(a0)
	beq	.5
	cmp.w	#$4e41,284(a0)
	beq	.6
	cmp.w	#$4e41,306(a0)
	beq	.7

	bra	.unknown
.1	
	move.l	a1,-(a7)
	lea	pompey(pc),a1
	bsr	exec_dets
	move.l	(a7)+,a4
	cmp.l	#$00ff8240,70(a0)
	bne.s	.11
	move.l	-4(a4),unpacked_length
	addq	#4,a4
	move.w	#$4e75,296(a0)
	lea	$1c(a0),a2
	jsr	38(a0)
	move.l	a2,save_here
	rts
.11	move.l	-4(a4),unpacked_length
	addq	#4,a4
	move.w	#$4e75,296(a0)
	move.w	#$4e71,52(a0)
;	lea	$1c(a0),a2
	jsr	32(a0)
	move.l	a2,save_here
	rts

.2	move.l	a1,-(a7)
	lea	pompey(pc),a1
	bsr	exec_dets
	move.l	(a7)+,a4
	move.l	-4(a4),unpacked_length
	addq	#4,a4
	move.l	a0,a1
	move.l	#$4ee90060,44(a0)
	move.w	#$4e75,334(a0)
	jsr	32(a0)
	move.l	a2,save_here
	rts

.3	move.l	a1,-(a7)
	lea	pompey(pc),a1
	bsr	exec_dets
	move.l	(a7)+,a4
	move.l	-4(a4),unpacked_length
	addq	#4,a4
	move.l	#$6000003a,108(a0)
	move.w	#$4e71,176(a0)
	move.w	#$4e75,192(a0)
	jsr	96(a0)
	move.l	a2,save_here
	rts

.4	move.l	a1,-(a7)
	lea	pompey(pc),a1
	bsr	exec_dets
	move.l	(a7)+,a4
	move.l	-4(a4),unpacked_length
	addq	#4,a4
	move.w	#$6036,44(a0)
	move.w	#$4e75,352(a0)
	lea	$1c(a0),a2
	jsr	38(a0)
	move.l	a2,save_here
	rts

.5	move.l	a1,-(a7)
	lea	pompey(pc),a1
	bsr	exec_dets
	move.l	(a7)+,a4
	move.l	-4(a4),unpacked_length
	addq	#4,a4
	move.w	#$4e71,52(a0)
	move.w	#$4e75,270(a0)
	jsr	32(a0)
	move.l	a2,save_here
	rts

.6	move.l	a1,-(a7)
	lea	pompey(pc),a1
	bsr	exec_dets
	move.l	(a7)+,a4
	move.l	-4(a4),unpacked_length
	addq	#4,a4
	move.w	#$4e71,52(a0)
	move.w	#$4e75,288(a0)
	jsr	32(a0)
	move.l	a2,save_here
	rts

.7	move.l	a1,-(a7)
	lea	pompey(pc),a1
	bsr	exec_dets
	move.l	(a7)+,a4
	move.l	-4(a4),unpacked_length
	clr.b	unpacked_length
	addq	#4,a4
	move.w	#$4e71,52(a0)
	move.w	#$4e75,310(a0)
	jsr	32(a0)
	move.l	a2,save_here
	clr.b	save_here
	rts

.unknown	lea	un_pompey(pc),a1
	bsr	a1_2_packer
	lea	exec(pc),a1
	bsr	update_type
	bsr	redraw_details
	move.l	#-1,not_packed
	rts

; Let user decide how to unpack pompey data

.pp_dat	move.l	a1,a4
	move.l	a4,-(a7)
	kill_form	main_menu
	bsr	mouse2pointer
	show_form	pompey_clash
	form_do	0
	cmp.b	#v1_5_butt,d0
	beq.s	.try_1_5
	cmp.b	#v1_9_butt,d0
	beq	.try_1_9
	cmp.b	#v2_6_butt,d0
	beq	.try_2_6
	move.l	(a7)+,a4
	kill_form	pompey_clash
	obj_chnge	dunno,0,0,pompey_clash
	show_form	main_menu
	bsr	mouse2pointer
	move.l	#-1,not_packed
	rts

.try_1_5	kill_form	pompey_clash
	obj_chnge	v1_5_butt,0,0,pompey_clash
	show_form	main_menu
	bsr	mouse2bee
	lea	pomp_1_5(pc),a1
	bsr	data_dets
	move.l	(a7)+,a4
	lea	4(a4),a2
	move.l	-4(a4),unpacked_length
	bsr	pp_1_5_depack
	move.l	a0,save_here
	rts

.try_1_9	kill_form	pompey_clash
	obj_chnge	v1_9_butt,0,0,pompey_clash
	show_form	main_menu
	bsr	mouse2bee
	lea	pomp_1_9(pc),a1
	bsr	data_dets
	move.l	(a7)+,a4
	move.l	a4,a3
	move.l	-4(a4),unpacked_length
	bsr	pp_1_9_depack
	move.l	a0,save_here
	rts

.try_2_6	kill_form	pompey_clash
	obj_chnge	v2_6_butt,0,0,pompey_clash
	show_form	main_menu
	bsr	mouse2bee
	lea	pomp_2_6(pc),a1
	bsr	exec_dets
	move.l	(a7)+,a4
	lea	4(a4),a0
	move.l	-8(a0),unpacked_length
	bsr	pp_2_6_depack
	move.l	a0,save_here
	rts

; Depack BRAS packed progs

BRAS_prg	lea	bapack(pc),a1
	bsr	exec_dets
	move.w	#$4e75,340(a0)
	move.l	52(a0),2(a0)
	move.l	56(a0),6(a0)
	move.l	60(a0),10(a0)
	move.l	64(a0),14(a0)
 	move.l	40(a0),unpacked_length
	jsr	(a0)
	rts

; Depack qpack program file

qpack_prg	lea	qpack_2(pc),a1
	bsr	exec_dets
	lea	48(a0),a0
	move.l	16(a0),unpacked_length
	move.l	a0,a1
	add.l	file_length(pc),a1
	move.l	a1,save_here
	bsr	dp_qpak		
	rts

; Depack qpack data file

qpack_dat	lea	qpack_2(pc),a1
	bsr	data_dets
	move.l	16(a0),unpacked_length
	move.l	a0,a1
	add.l	file_length(pc),a1
	move.l	a1,save_here
	bsr	dp_qpak		
	rts

; Depack DCSquish packed program file

dcs1_0_prg	
	lea	dcs_1_0(pc),a1
	bsr	exec_dets
	move.l	30(a0),unpacked_length
	lea	752(a0),a3
	move.l	a3,a5
	add.l	file_length(pc),a5
	move.l	a5,save_here
	bsr	DCsquish_1_0_unpack
	rts
dcs1_2_prg
	lea	dcs_1_2(pc),a1
	bsr	exec_dets
	move.l	30(a0),unpacked_length
	lea	900(a0),a3
	move.l	a3,a5
	add.l	file_length(pc),a5
	move.l	a5,save_here
	bsr	DCsquish_1_2_unpack
	rts
dcs1_4_prg
	lea	dcs_1_4(pc),a1
	bsr	exec_dets
	move.l	30(a0),unpacked_length
	lea	900(a0),a3
	move.l	a3,a5
	add.l	file_length(pc),a5
	move.l	a5,save_here
	bsr	DCsquish_1_4_unpack
	rts

; Depack 4pak packed program file

_4pak_prg	lea	_4pak(PC),a1
	bsr	exec_dets
	move.l	a0,a3
	lea	$1c(a3),a0
	lea	$1c(a3),a1
	add.l	30(a3),a0
	add.l	36(a3),a1
	move.w	46(a3),d1
	move.w	58(a3),.wibble
	moveq	#0,d0
.1	move.l	-(a0),-(a1)
	dbf	d1,.1
	dbf	d0,.1
.wibble	nop
	move.l	62(a3),a4
	lea	$1c(a3),a0
	add.l	a0,a4
	move.l	64(a4),2(a3)
	move.l	78(a4),6(a3)
	move.l	92(a4),10(a3)
	bsr	_4pak_depack
	lea	$1c(a3),a2
	add.l	2(a3),a2
	add.l	6(a3),a2

	move.b	(a2)+,d0
	lsl.w	#8,d0
	move.b	(a2)+,d0
	swap	d0
	move.b	(a2)+,d0
	lsl.w	#8,d0
	move.b	(a2)+,d0
	moveq	#1,d2
	tst.l	d0
	beq.s	.2
	moveq	#0,d0
.3	move.b	(a2)+,d0
	cmp.b	d2,d0
	bhi.s	.3
	beq.s	.3
.2	sub.l	a3,a2		; unpacked length
	move.l	a2,unpacked_length
	rts

; Depack PFX packer prog file

pfx_prg1	lea	420(a0),a4
	bra.s	uppfx
pfx_prg2	lea	584(a0),a4
	bra.s	uppfx
pfx_prg3	lea	1050(a0),a4

uppfx	move.l	a0,a6
	add.l	file_length(pc),a6
	lea	pfx(pc),a1
	bsr	exec_dets
	bsr	pfx2_1_depack
	rts

; Depack bytekiller packed program file

bytekiller_prg
	lea	426(a0),a6
	move.l	4(a6),unpacked_length
	lea	36(a6),a5
	move.l	a5,save_here
	lea	bkill_2(pc),a1
	bsr	exec_dets
	bsr	bytekiller_depack
	rts

; Depack bytekiller3 packed program file

bytekiller3_prg
	lea	416(a0),a6
	move.l	4(a6),unpacked_length
	lea	36(a6),a5
	move.l	a5,save_here
	lea	bkill_3(pc),a1
	bsr	exec_dets
	bsr	bytekiller_depack
	rts

rp_bytekiller_prg
	lea	rpbkill(pc),a1
	bsr	exec_dets
	move.l	$1c6(a0),unpacked_length
	move.w	#$4e75,$28(a0)
	jsr	(a0)
	move.l	a2,save_here	
	rts

; Depack gollum packed program file with huffing

gollum_prg_huff
	lea	gollum(pc),a1
	bsr	exec_dets
	bsr	gollum_depacker_huff
	rts

; Depack gollum packed program file

gollum_prg
	lea	gollum(pc),a1
	bsr	exec_dets
	bsr	gollum_depacker
	move.l	d2,save_here
	rts

; Depack happy packed program file

happy_prg
	lea	happy(pc),a1
	bsr	exec_dets
	bsr	happy_depacker
	rts

thunv1_prg
	lea	thun_1(pc),a1
	bsr	exec_dets
	lea	422+12(a0),a2
	move.w	#$4e75,130(a0)
	move.l	-8(a2),unpacked_length
	move.l	a0,a4
	add.l	-8(a2),a4
	move.l	a4,save_here
	jsr	64(a0)
	rts
thunv2_prg
	lea	thun_2(pc),a1
	bsr	exec_dets
	lea	$1c(a0),a2
	add.l	2(a0),a2
	move.l	a2,a4
	add.l	6(a0),a4
	move.l	4(a2),unpacked_length
	move.w	#$4e75,110(a0)
	jsr	42(a0)
	move.l	a3,save_here
	rts

; Speed packer depacking

speed2_prg
	lea	speed_2(pc),a1
	bsr	exec_dets
	lea	542(a0),a5
	move.l	#$4e714e71,212(a0)
	move.w	#$6014,250(a0)
	move.l	12(a5),unpacked_length
	lea	$50(a5),a1
	move.l	a1,save_here
	jsr	212(a0)
	rts

speed3_prg
	lea	speed_3(pc),a1
	bsr	exec_dets
	lea	$1c(a0),a0
	move.l	#'SPv3',(a0)
	move.l	12(a0),unpacked_length
	add.l	#$1c,unpacked_length
	bsr	speed3_depack
	lea	-$1c(a0),a1
	move.l	a1,save_here
	addq	#2,a1
	add.l	d0,a0
	move.l	-(a0),(a1)+
	move.l	-(a0),(a1)+
	move.l	-(a0),(a1)+
	rts

speed2_data
	lea	speed_2(pc),a1
	bsr	data_dets
	move.l	a0,save_here
	move.l	12(a0),unpacked_length
	bsr	speed2_depack
	rts

speed3_data
	lea	speed_3(pc),a1
	bsr	data_dets
	move.l	a0,save_here
	move.l	12(a0),unpacked_length
	bsr	speed3_depack
	rts

; Depack spectrum 512 picture file

spec512	lea	spec_512(pc),a1
	bsr	pic_dets

	bsr	spec_depack
	rts

; Depack DEGAS file

degas	lea	degas_e(pc),a1
	bsr	pic_dets
	bsr	degas_depack
	rts

; Unpack packed progs , the name of which i don't know
; but its a pretty bad packer.  

unknown1	lea	unknown_1(pc),a1
	bsr	exec_dets
	bsr	un1dp
	move.l	a2,save_here
	rts

; Unpack stos packed progs 

stos_prg	lea	stos(pc),a1
	bsr	exec_dets
	bsr	stos_dp
	rts

; Unpack Ivory Dragon packed progs 

ivory_dragon_prg	
	lea	idrag(pc),a1
	bsr	exec_dets
	movea.l	a0,a1
	adda.l	$1E(a0),a1
	move.l	a1,save_here	
	adda.l	2(a0),a0
	adda.w	#$1C,a0
	bsr	depack_ivd
	rts

; Unpack Ivory Dragon packed data

ivory_drag_dat	
	move.l	a1,a4
	lea	idrag(pc),a1
	bsr	data_dets
	move.l	a0,a1	; start
	move.l	a4,a0	; end 
	move.l	a1,save_here
	bsr	depack_ivd
	rts

; unpack vic2/calif2 data
v2_cal2_dat
	lea	v2_cal2(pc),a1
	bsr	data_dets
	move.l	a0,save_here
	move.l	4(a0),unpacked_length
	bsr	depack_v2
	rts

; Info on IFF 

iff_file	lea	iff(pc),a1
	bsr	pic_dets
	move.l	#-1,not_packed	
	rts
; info on lharc files

lharc1_file
	lea	lharc1(pc),a1
	bsr	archive_dets
	move.l	#-1,not_packed
	rts
lharc5_file
	lea	lharc5(pc),a1
	bsr	archive_dets
	move.l	#-1,not_packed
	rts
; info on zoo files

zoo_file	lea	zoo(pc),a1	
	bsr	archive_dets
	move.l	#-1,not_packed
	rts
; info on pk zip files

zip_file	lea	zip(pc),a1	
	bsr	archive_dets
	move.l	#-1,not_packed
	rts

; Info on NEO object

neo_object
	lea	neo_obj(pc),a1
	bsr	pic_dets
	move.l	#-1,not_packed	
	rts
