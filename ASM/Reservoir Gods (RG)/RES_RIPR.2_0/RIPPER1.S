**************************
**** RESERVOIR RIPPER ****
**** Coded by Mr Pink ****
* (C)1995 RESERVOIR GODS *
**************************

DEBUG	equ	0
vars_y	equ	80
regs_y	equ	40

start_ripper
	move.l  a7,a5
        move.l  4(a5),a5
        move.l  12(a5),d0
        add.l   20(a5),d0
        add.l   28(a5),d0
        add.l   #$100,d0
        move.l  d0,-(sp)
        move.l  a5,-(sp)
        move    d0,-(sp)
        move    #$4a,-(sp)
        trap    #1
        add.l   #12,sp

	clr.w	-(a7)
	pea	$200000
	trap	#1


	move.w	#$59,-(a7)	;get monitor
	trap	#14
	addq.l	#2,a7
	cmp.w	#2,d0
	bne.s	not_vga
	st.b	vga_flag
not_vga

	bsr	save_system

	IFNE	DEBUG
	bsr	do_test
	clr.w	-(a7)
	trap	#1
	ENDC


	move.l	#start_ripper,$30.w
	move.l	#end_ripper,$432.w

	dc.w	$a00a

	lea	intro_txt(pc),a0
	bsr	gemdos_print
	bsr	show_all_on_off_flags
	bsr	do_menu
	tst.w	d0
	beq.s	do_tsr

	clr.w	-(a7)
	trap	#1

do_tsr
	bsr	save_system

	lea	install_bits,a0
	lea	install_routines,a1
	moveq	#12,d0	
.george	tst.b	(a0,d0.w)
	beq.s	.eq
	movem.l	d0/a0-1,-(a7)
	jsr	([a1,d0.w*4])
	movem.l	(a7)+,d0/a0-1
.eq	dbra	d0,.george

	move.w	#0,-(a7)
	move.l	#end_ripper-start_ripper+$100,-(a7)
	move.w	#$31,-(a7)
	trap	#1

	IFNE	DEBUG
do_test:
	move.w	#$2700,sr
	lea	rip_stack,a7
	bsr	save_screen_info
	bsr	restore_system
	move.w	#$2300,sr
	bsr	save_pal
	bsr	wait_vbl
	bsr	init_screen
	bsr	get_pic_info
	bsr	print_ripper_menu_txt	
	bsr	restore_screen_info
	bsr	restore_system
	rts
	ENDC


do_menu

.loop	bsr	wait_key	
	swap	d0
	cmp.b	#1,d0
	beq	.exit
	cmp.b	#$39,d0
	beq	.install
	cmp.b	#5,d0
	bgt	.fkey
	addq.w	#8,d0
	bra	.toggle
.fkey	sub.b	#$3b,d0
	bmi.s	.loop
	cmp.b	#$a,d0
	bge.s	.loop
.toggle
	bsr	toggle_vector
	bra.s	.loop
.install		
	moveq	#0,d0
	rts
.exit	moveq	#-1,d0
	rts

toggle_vector
	lea	on_txt,a0
	cmp.w	#13,d0
	bne.s	.vec
	eor.b	#1,reinstall_flag
	bra.s	.chk
.vec	lea	install_bits,a1
	eor.b	#1,(a1,d0.w)
.chk	bne.s	.on
	lea	off_txt,a0
.on	add.w	#8+32,d0
	move.b	d0,on_y
	move.b	d0,off_y
	bra	gemdos_print


show_all_on_off_flags
		lea	install_bits,a6
		moveq	#12,d7
		move.b	#15+32,on_x
		move.b	#15+32,off_x
		move.b	#8+32,off_y
		move.b	#8+32,on_y

.loop		lea	off_txt(pc),a0
		tst.b	(a6)+
		beq.s	.on		
		lea	on_txt(pc),a0
.on		bsr	gemdos_print
		addq.b	#1,on_y
		addq.b	#1,off_y
		dbra	d7,.loop
		rts

gemdos_print:	pea	(a0)
		move.w	#9,-(a7)
		trap	#1
		addq.w	#6,a7
		rts

wait_key:	move.w	#$b,-(a7)	;interogate keyboard
		trap	#1
		addq.l	#2,a7
		tst	d0		;is there junk in key buffer?
		beq.s	cnecin		;no, just wait for key
		bsr.s	cnecin		;clear key buffer
		bra.s	wait_key	;check buffer status
cnecin:		move.w	#8,-(a7)	;get key
		trap	#1
		addq.l	#2,a7		;returned in D0
		rts


init_ripper:
	move.l	a7,old_stack+2
	lea	rip_stack,a7
	move.w	sr,-(a7)
	move.w	#$2700,sr
	clr.b	begin_ripping_flag
	bsr	save_screen_info
	lea	cur_system_vars,a0
	bsr	save_cur_system
	bsr	restore_system
	move.w	#$2300,sr
	bsr	save_pal
	bsr	wait_vbl
	bsr	init_screen
	bsr	init_ikbd
	bsr	get_pic_info
	bsr	print_ripper_menu_txt	
do_ripper_menu:
	tst.b	key_table+$3b
	bne	show_screen
	tst.b	key_table+$3c
	bne	do_save_file
	tst.b	key_table+$44
	beq.s	do_ripper_menu
	bsr	restore_ikbd
	bsr	wait_vbl
	bsr	restore_screen_info	
	bsr	restore_pal
	move.w	#$2700,sr
	lea	cur_system_vars,a0
	bsr	restore_cur_system
	move.w	(a7)+,sr
old_stack
	lea	$12345678,a7
	rts

print_ripper_menu_txt:

	lea	ripper_txt,a0
	move.l	#320-16*3,d0
	moveq	#0,d1
	bsr	print_string

	lea	coder_txt,a0
	move.l	#320-16*3,d0
	moveq	#20,d1
	bsr	print_string

	lea	rg_txt,a0
	move.l	#320-23*3,d0
	moveq	#30,d1
	bsr	print_string

	lea	menu_txt,a0
	moveq	#0,d0
	moveq	#40,d1
	bsr	print_string

	lea	entry_txt,a0
	move.l	#320,d0
	moveq	#40,d1
	bsr	print_string

	moveq	#0,d0
	move.b	current_vec,d0
	move.l	(v_txt_adrs,d0.w*4),a0
	move.l	#320+6*15,d0
	moveq	#40,d1
	bsr	print_string

	lea	variables_txt,a0
	moveq	#0,d0
	move.l	#vars_y,d1
	bsr	print_string

	move.w	pic_res,d0
	move.l	(res_txts,d0.w*4),a0
	moveq	#6*6,d0
	move.l	#vars_y,d1
	bsr	print_string


	lea	word_txts,a6
.loop1	move.l	(a6)+,a0
	cmpa.l	#0,a0
	beq.	.el1
	moveq	#0,d0
	move.w	(a0),d0
	bsr	conv_long_ascii
	lea	long_string+6,a0
	moveq	#0,d0
	move.w	(a6)+,d0
	move.w	(a6)+,d1
	mulu	#6,d1
	add.l	#vars_y,d1
	pea	(a6)
	bsr	print_string
	move.l	(a7)+,a6
	bra.s	.loop1	

.el1	lea	byte_txts,a6
.loop2	move.l	(a6)+,a0
	cmpa.l	#0,a0
	beq.	.el2
	moveq	#0,d0
	move.b	(a0),d0
	bsr	conv_long_ascii
	lea	long_string+6,a0
	moveq	#0,d0
	move.w	(a6)+,d0
	move.w	(a6)+,d1
	mulu	#6,d1
	add.l	#vars_y,d1
	pea	(a6)
	bsr	print_string
	move.l	(a7)+,a6
	bra.s	.loop2

.el2	lea	screen_vars+12,a6
	moveq	#7,d7
	moveq	#6*5,d6
.loop3	moveq	#0,d0
	move.w	(a6)+,d0
	bsr	conv_long_ascii
	lea	long_string+6,a0
	move.l	d6,d0
	move.l	#vars_y+6*2,d1
	movem.l	d6-7/a6,-(a7)
	bsr	print_string
	movem.l	(a7)+,d6-7/a6
	add.l	#6*10,d6
	dbra	d7,.loop3

	moveq	#7,d7
	moveq	#6*5,d6
.loop4	moveq	#0,d0
	move.w	(a6)+,d0
	bsr	conv_long_ascii
	lea	long_string+6,a0
	move.l	d6,d0
	move.l	#vars_y+6*3,d1
	movem.l	d6-7/a6,-(a7)
	bsr	print_string
	movem.l	(a7)+,d6-7/a6
	add.l	#6*10,d6
	dbra	d7,.loop4

	rts


show_screen
	bsr	wait_vbl
	bsr	restore_screen_info	
	bsr	restore_pal
.wt	tst.b	key_table+$3b
	bne.s	.wt
.wt2	tst.b	key_table+$3b
	beq.s	.wt2

	bsr	wait_vbl
	bsr	set_my_screen
	bsr	set_resolution
	bsr	set_my_pal
.wt3	tst.b	key_table+$3b
	bne.s	.wt3
	bra	do_ripper_menu


do_save_file
	lea	enter_file_txt,a0
	moveq	#0,d0
	move.l	#160,d1
	bsr	print_string
	
.wt1	tst.b	key_table+$3c
	bne.s	.wt1

	bsr	enter_file_name
	bmi	.err
	bsr	save_file
.err	bsr	clear_my_screen
	bsr	print_ripper_menu_txt
	bra	do_ripper_menu


get_pic_info:
	move.l	#'GRIP',magic
	lea	screen_vars(pc),a0
	bfextu	(a0){0:24},d0
	move.l	d0,pic_adr
	bsr	get_pic_res

	move.w	36(a0),d0		;82AA - VDE
	sub.w	34(a0),d0		;82A8 - VDB
	move.w	42(a0),d1		;82C0 - VCO

	tst.b	vga_flag
	bne.s	.int
	btst	#1,d1			;interlace mode
	bne.s	.int			;yes
	lsr.w	d0
.int
	btst	#3,d1			;quarter pixel mode
	beq.s	.noq
	lsr.w	d0
.noq	btst	#2,d1			;halve pixel mode?
	beq.s	.noh
	lsr.w	d0
.noh	btst	#0,d1			;line doubling?
	beq.s	.nol
	lsr.w	d0	
.nol	
	
;	tst.w	d1			;interlace/double line off?
;	beq.s	.halve			;yes, half size
;	btst	#0,d1			;line doubling?
;	beq.s	.norm			;no
;	lsr.w	d0			;y size/2
;.halve	lsr.w	d0			;y size/2
.norm	move.w	d0,pic_y		;store y size
	mulu	6(a0),d0		;line_width*y lines
	add.l	d0,d0			;*2 file length in bytes
	move.l	d0,pic_length


get_pic_res:
	move.b	8(a0),d0			;8260
	move.w	10(a0),d1			;8266
	btst	#10,d1
	bne	.two_colour
	btst	#8,d1
	bne	.true_colour
	btst	#4,d1
	bne	.eight_colour
	tst.b	d0
	beq	.sixteen_colour
	cmp.b	#1,d0
	beq	.four_colour
.two_colour	
	clr.w	pic_res
	move.w	6(a0),d0		;8210 - line width (words)
	lsl.w	#4,d0			;*16
	move.w	d0,pic_x		;x pixels
	rts
.four_colour
	moveq	#62,d0
	tst.b	vga_flag
	beq.s	.nvga
	moveq	#23,d0
.nvga	cmp.w	12(a0),d0
	bne	.sixteen_colour
	move.w	#1,pic_res
	move.w	6(a0),d0		;8210 - line width (words)
	lsl.w	#3,d0			;*16
	move.w	d0,pic_x		;x pixels
	rts
.sixteen_colour
	move.w	#2,pic_res
	move.w	6(a0),d0		;8210 - line width (words)
	lsl.w	#2,d0			;*4
	move.w	d0,pic_x		;x pixels
	rts
.eight_colour
	move.w	#3,pic_res
	move.w	6(a0),d0		;8210 - line width (words)
	add.w	d0,d0			;*2
	move.w	d0,pic_x		;x pixels
	rts
.true_colour
	move.w	#4,pic_res
	move.w	6(a0),pic_x
.cont	rts


enter_file_name
	clr.w	text_counter

.loop	clr.b	key_pressed
.wk	tst.b	key_pressed
	beq.s	.wk
	move.b	current_key,d1
	cmp.b	#$1c,d1
	beq	.end_entry
	cmp.b	#1,d1
	beq	.quit_entry
	cmp.b	#$e,d1
	bne.s	.nback

	subq.w	#1,text_counter
	bpl.s	.pls
	clr.w	text_counter
.pls	lea	single_string,a0
	move.b	#' ',(a0)
	move.w	text_counter,d0
	mulu	#6,d0
	move.l	#170,d1
	bsr	print_string

	lea	file_name,a0
	move.w	text_counter,d0
	clr.b	(a0,d0.w)
	bra	.loop

.nback	lea	single_string,a0
	move.b	(scan_code_table,d1.w),d1
	move.b	d1,(a0)
	move.w	text_counter,d0
	lea	file_name,a1
	move.b	d1,(a1,d0.w)
	mulu	#6,d0
	move.l	#170,d1
	bsr	print_string

	cmp.w	#640/6-1,text_counter
	bge.s	.ge
	addq.w	#1,text_counter
.ge

	bra	.loop

.quit_entry
	moveq	#-1,d0
	rts

.end_entry
	move.w	text_counter,d0
	clr.b	(file_name+1,d0.w)
	moveq	#0,d0
	rts


wait_vbl:
	move.l	d0,-(a7)
	move.l	$466.w,d0
.wt	cmp.l	$466.w,d0
	beq.s	.wt
	move.l	(a7)+,d0
	rts




************************
* VECTOR SAVE ROUTINES *
*************************

save_system:
	lea	old_system_vars(pc),a0	
save_cur_system
	movec	cacr,d0
	move.w	d0,(a0)+
	move.l	$68.w,(a0)+			; hbl
	move.l	$70.w,(a0)+			; vbl
	move.l	$84.w,(a0)+			; trap #1
	move.l	$b4.w,(a0)+			; trap #13
	move.l	$b8.w,(a0)+			; trap #14
	move.l	$110.w,(a0)+			; Timer D
	move.l	$114.w,(a0)+			; Timer C
	move.l	$118.w,(a0)+			; ikbd
	move.l	$120.w,(a0)+			; Timer B
	move.l	$134.w,(a0)+			; Timer A
	move.l	$13c.w,(a0)+			; mono detect
	move.l	$456.w,(a0)+			; vbl list ptr
	move.l	$502.w,(a0)+			; alt-help vector

	move.w	$ffff8900.w,(a0)+				; Interruptions, Son DMA
	move.b	$ffff8903.w,(a0)+				; Start - High
	move.b	$ffff8905.w,(a0)+				; Start - Med
	move.b	$ffff8907.w,(a0)+				; Start - Low
	move.b	$ffff890f.w,(a0)+				; End - High
	move.b	$ffff8911.w,(a0)+				; End - Med
	move.b	$ffff8913.w,(a0)+				; End - Low
	move.w	$ffff8920.w,(a0)+				; Nb Voies, 8/16, Mono/Stereo
	move.w	$ffff8930.w,(a0)+				; Matrice : Sources
	move.w	$ffff8932.w,(a0)+				; Matrice : Destinations
	move.w	$ffff8934.w,(a0)+				; Prescales d'horloge
	move.w	$ffff8936.w,(a0)+				; Nb Voies Record,source ADDERIN
	move.w	$ffff8938.w,(a0)+				; Source ADC + Volumes entr‚es
	move.w	$ffff893a.w,(a0)+				; Volumes de Sortie


	move.b	$fffffa07.w,(a0)+		; iera
	move.b	$fffffa09.w,(a0)+		; ierb
	move.b	$fffffa13.w,(a0)+		; imra
	move.b	$fffffa15.w,(a0)+		; imrb
	move.b	$fffffa17.w,(a0)+		; vectore register
	move.b	$fffffa19.w,(a0)+		; Timer A control
	move.b	$fffffa1b.w,(a0)+		; Timer B control
	move.b	$fffffa1d.w,(a0)+		; Timer C & D control
	move.b	$fffffa1f.w,(a0)+		; Timer A data
	move.b	$fffffa21.w,(a0)+		; Timer B data
	move.b	$fffffa23.w,(a0)+		; Timer C data
	move.b	$fffffa25.w,(a0)+		; Timer D data
	move.b	$ffff8007.w,(a0)+		; 68030 Configuration 
	rts

save_screen_info:
	lea	screen_vars(pc),a0	; Espace de sauvegarde
	move.b	$ffff8201.w,(a0)+	;0 Vid‚o (poids fort)
	move.b	$ffff8203.w,(a0)+	;1 Vid‚o (poids moyen)
	move.b	$ffff820d.w,(a0)+	;2 Vid‚o (poids faible)
	move.b	$ffff820a.w,(a0)+	;3 Synchronisation vid‚o
	move.w	$ffff820e.w,(a0)+	;4 Offset pour prochaine ligne
	move.w	$ffff8210.w,(a0)+	;6 Largeur d'une ligne en mots
	move.b	$ffff8260.w,(a0)+	;8 R‚solution ST
	move.b	$ffff8265.w,(a0)+	;9 D‚calage Pixel
	move.w	$ffff8266.w,(a0)+	;10 R‚solution FALCON
	move.w	$ffff8282.w,(a0)+	;12 HHT-Synchro
	move.w	$ffff8284.w,(a0)+	;14 Fin du d‚codage de la ligne
	move.w	$ffff8286.w,(a0)+	;16 D‚but du d‚codage de la ligne
	move.w	$ffff8288.w,(a0)+	;18 Overscan gauche
	move.w	$ffff828a.w,(a0)+	;20 Overscan droit
	move.w	$ffff828c.w,(a0)+	;22 HSS-Synchro
	move.w	$ffff828e.w,(a0)+	;24 HFS
	move.w	$ffff8290.w,(a0)+	;26 HEE
	move.w	$ffff82a2.w,(a0)+	;28 VFT-Synchro
	move.w	$ffff82a4.w,(a0)+	;30 Fin du d‚codage de l'image
	move.w	$ffff82a6.w,(a0)+	;32 D‚but du d‚codage de l'image
	move.w	$ffff82a8.w,(a0)+	;34 VDB
	move.w	$ffff82aa.w,(a0)+	;36 VDE
	move.w	$ffff82ac.w,(a0)+	;38 VSS-Synchro
	move.w	$ffff82c0.w,(a0)+	;40 Reconnaissance ST/FALCON
	move.w	$ffff82c2.w,(a0)+	;42 VCO
	rts

save_pal:
	bsr	wait_vbl
	lea	pal_space,a0
	lea	$ffff8240.w,a1
	moveq	#15,d0
.save_st_pal
	move.w	(a1)+,(a0)+
	dbra	d0,.save_st_pal

	lea	$ffff9800.w,a1
	move.w	#255,d0
.save_falc_pal
	move.l	(a1)+,(a0)+
	dbra	d0,.save_falc_pal


	rts

***************************
* SCREEN SETTING ROUTINES *
***************************

set_resolution
	lea	videl_640_200_2(pc),a0

	move.b	#2,$ffff820a.w			; Internal sync
	clr.b	$ffff8265.w			; Horizontal scroll reg=0
	addq.l	#4,a0				; skip screen_length
	move.w	(a0)+,$ffff820e.w		; line width
	move.w	(a0)+,$ffff8210.w		; Falcon line width
	move.w	(a0)+,d0			; Resolution ST
	move.w	(a0)+,d1			; Resolution FALCON

	move.w	d1,$ffff8266.w			; Resolution FALCON
	tst.w	(a0)+				; falcon screen mode?
	beq.s	FalconRez			; yes
	move.b	d0,$ffff8260.w			; Resolution ST
	move.w	-8(a0),$ffff8210.w		; Fa;cpm line width
FalconRez
	btst.b	#7,$ffff8006.w			; VGA monitor ?
	Beq.s	R_Ok				; no, rgb
	adda.w	#16*2,a0			; get to VGA data
R_Ok
	move.w	(a0)+,$ffff8282.w		; HHT - Hold counter
	move.w	(a0)+,$ffff8284.w		; HBB - Border Begin
	move.w	(a0)+,$ffff8286.w		; HBE - Border end
	move.w	(a0)+,$ffff8288.w		; HDB - Display Begin
	move.w	(a0)+,$ffff828a.w		; HDE - Display End
	move.w	(a0)+,$ffff828c.w		; HSS - Synchro
	move.w	(a0)+,$ffff828e.w		; HFS
	move.w	(a0)+,$ffff8290.w		; HEE
	move.w	(a0)+,$ffff82a2.w		; VFT - Synchro
	move.w	(a0)+,$ffff82a4.w		; VBB - Border Begin
	move.w	(a0)+,$ffff82a6.w		; VBE - Border End
	move.w	(a0)+,$ffff82a8.w		; VDB - Display Begin
	move.w	(a0)+,$ffff82aa.w		; VDE - Display End
	move.w	(a0)+,$ffff82ac.w		; VSS-Synchro
	move.w	(a0)+,$ffff82c0.w		; FALCON resoultion indicator
	move.w	(a0),$ffff82c2.w		; resolution info

	rts


init_screen:
	lea	screen_space(pc),a0
	move.l	a0,d0
	clr.b	d0
	lea	physic(pc),a1
	move.l	d0,(a1)
	bsr	wait_vbl
	bsr	set_my_screen
	bsr	set_resolution
	bsr	clear_my_screen
	bsr	set_my_pal
	rts

set_my_screen:
	lea	physic(pc),a1
	movea.w	#$8201,a0	;$fffff8201=screen address
	move.b	1(a1),(a0)
	move.b	2(a1),2(a0)	;$fffff8203
	move.b	3(a1),$C(a0)	;$fffff820d
	rts

	
clear_my_screen
	move.l	physic(pc),a1
	move.l	#(640*200/8)/4-1,d0
.cl	clr.l	(a1)+
	dbra	d0,.cl
	rts

set_my_pal:
	lea	$ffff9800.w,a0
	lea	$ffff8240.w,a1
	moveq	#0,d0
	move.l	d0,(a0)+
	move.w	d0,(a1)+
	moveq	#-1,d0
	move.l	d0,(a0)+
	move.w	d0,(a1)+
	rts

***************************
* VECTOR RESTORE ROUTINES *
***************************

restore_system:
	lea	old_system_vars(pc),a0	
restore_cur_system:
	move.w	(a0)+,d0
	movec	d0,cacr
	move.l	(a0)+,$68.w			; hbl
	move.l	(a0)+,$70.w			; vbl
	move.l	(a0)+,$84.w			; trap #1
	move.l	(a0)+,$b4.w			; trap #13
	move.l	(a0)+,$b8.w			; trap #14
	move.l	(a0)+,$110.w			; Timer D
	move.l	(a0)+,$114.w			; Timer C
	move.l	(a0)+,$118.w			; ikbd
	move.l	(a0)+,$120.w			; Timer B
	move.l	(a0)+,$134.w			; Timer A
	move.l	(a0)+,$13c.w			; mono detect
	move.l	(a0)+,$456.w			; vbl list ptr
	move.l	(a0)+,$502.w			; alt-help vector

	move.w	(a0)+,$ffff8900.w				; Interruptions, Son DMA
	move.b	(a0)+,$ffff8903.w				; Start - High
	move.b	(a0)+,$ffff8905.w				; Start - Med
	move.b	(a0)+,$ffff8907.w				; Start - Low
	move.b	(a0)+,$ffff890f.w				; End - High
	move.b	(a0)+,$ffff8911.w				; End - Med
	move.b	(a0)+,$ffff8913.w				; End - Low
	move.w	(a0)+,$ffff8920.w				; Nb Voies, 8/16, Mono/Stereo
	move.w	(a0)+,$ffff8930.w				; Matrice : Sources
	move.w	(a0)+,$ffff8932.w				; Matrice : Destinations
	move.w	(a0)+,$ffff8934.w				; Prescales d'horloge
	move.w	(a0)+,$ffff8936.w				; Nb Voies Record,source ADDERIN
	move.w	(a0)+,$ffff8938.w				; Source ADC + Volumes entr‚es
	move.w	(a0)+,$ffff893a.w				; Volumes de Sortie


	move.b	(a0)+,$fffffa07.w		; iera
	move.b	(a0)+,$fffffa09.w		; ierb
	move.b	(a0)+,$fffffa13.w		; imra
	move.b	(a0)+,$fffffa15.w		; imrb
	move.b	(a0)+,$fffffa17.w		; vectore register
	move.b	(a0)+,$fffffa19.w		; Timer A control
	move.b	(a0)+,$fffffa1b.w		; Timer B control
	move.b	(a0)+,$fffffa1d.w		; Timer C & D control
	move.b	(a0)+,$fffffa1f.w		; Timer A data
	move.b	(a0)+,$fffffa21.w		; Timer B data
	move.b	(a0)+,$fffffa23.w		; Timer C data
	move.b	(a0)+,$fffffa25.w		; Timer D data
	move.b	(a0)+,$ffff8007.w		; 68030 Configuration 
	rts



restore_screen_info:
	lea	screen_vars(pc),a0
	move.b	(a0)+,$ffff8201.w		; Vid‚o (poids fort)
	move.b	(a0)+,$ffff8203.w		; Vid‚o (poids moyen)
	move.b	(a0)+,$ffff820d.w		; Vid‚o (poids faible)
	move.b	(a0)+,$ffff820a.w		; Synchronisation vid‚o
	move.w	(a0)+,$ffff820e.w		; Offset pour prochaine ligne
	move.w	(a0)+,$ffff8210.w		; Largeur d'une ligne en mots
	move.b	(a0)+,d0			; R‚solution ST
	move.b	(a0)+,$ffff8265.w		; D‚calage Pixel
	move.w	(a0)+,d1			; R‚solution FALCON
	move.w	(a0)+,$ffff8282.w		; HHT-Synchro
	move.w	(a0)+,$ffff8284.w		; Fin du d‚codage de la ligne
	move.w	(a0)+,$ffff8286.w		; D‚but du d‚codage de la ligne
	move.w	(a0)+,$ffff8288.w		; Overscan gauche
	move.w	(a0)+,$ffff828a.w		; Overscan droit
	move.w	(a0)+,$ffff828c.w		; HSS-Synchro
	move.w	(a0)+,$ffff828e.w		; HFS
	move.w	(a0)+,$ffff8290.w		; HEE
	move.w	(a0)+,$ffff82a2.w		; VFT-Synchro
	move.w	(a0)+,$ffff82a4.w		; Fin du d‚codage de l'image
	move.w	(a0)+,$ffff82a6.w		; D‚but du d‚codage de l'image
	move.w	(a0)+,$ffff82a8.w		; Overscan haut
	move.w	(a0)+,$ffff82aa.w		; Overscan bas
	move.w	(a0)+,$ffff82ac.w		; VSS-Synchro
	move.w	(a0)+,$ffff82c0.w		; Reconnaissance ST/FALCON
	move.w	(a0)+,$ffff82c2.w		; Informations r‚solution
	move.w	d1,$ffff8266.w			; Fixe r‚solution FALCON...
	btst.b	#0,$ffff82c0.w			; R‚solution FALCON ?
	bne.s	.Falcon_Rez			; Si oui,saut !
	move.b	d0,$ffff8260.w			; Fixe r‚solution ST...
.Falcon_Rez
	rts

restore_pal
	bsr	wait_vbl
	lea	pal_space,a0
	lea	$ffff8240.w,a1
	moveq	#15,d0
.save_st_pal
	move.w	(a0)+,(a1)+
	dbra	d0,.save_st_pal

	lea	$ffff9800.w,a1
	move.w	#255,d0
.save_falc_pal
	move.l	(a0)+,(a1)+
	dbra	d0,.save_falc_pal

	rts


********************************
* VECTOR INSTALLATION ROUTINES *
********************************


install_trap_1:
	move.l	$84.w,old_trap_1+2
	move.l	#new_trap_1,$84.w
	rts
install_trap_13:
	move.l	$b4.w,old_trap_13+2
	move.l	#new_trap_13,$b4.w
	rts
install_trap_14:
	move.l	$b8.w,old_trap_14+2
	move.l	#new_trap_14,$b8.w
	rts
install_vbl
	move.l	$70.w,old_vbl+2
	move.l	#new_vbl,$70.w
	rts
install_hbl
	move.l	$68.w,old_hbl+2
	move.l	#new_hbl,$68.w
	rts
install_ikbd
	move.l	$118.w,old_ikbd+2
	move.l	#new_ikbd,$118.w
	rts
install_timer_a:
	move.l	#new_timer_a,$134.w
	move.b	#7,$fffffa19.w		;Timer A control (delay mode)
	move.b	#246,$fffffa1f.w	;Timer A data
	bset	#5,$fffffa07.w		;Interrupt Enable Register A
	bset	#5,$fffffa13.w		;Interrupt Mask Register A
	rts
install_timer_b:
	move.l	#new_timer_b,$120.w
	move.b	#7,$fffffa1b.w		;Timer B control (delay mode)
	move.b	#246,$fffffa21.w	;Timer B data
	bset	#0,$fffffa07.w		;Interrupt Enable Register A
	bset	#0,$fffffa13.w		;Interrupt Mask Register A
	rts
install_timer_c
	move.l	$114.w,old_timer_c+2
	move.l	#new_timer_c,$114.w
	rts

install_timer_d:
	move.l	#new_timer_d,$110.w
;	move.b	#7,$fffffa1d.w		;Timer D control (delay mode)
	move.b	#246,$fffffa25.w	;Timer D data
	bset	#4,$fffffa09.w		;Interrupt Enable Register A
	bset	#4,$fffffa15.w		;Interrupt Mask Register A
	rts


install_reset:
	move.l	#$31415926,$426.w	;magic
	move.l	#init_ripper,$42a.w	
	rts

install_alt_help
	move.l	#init_ripper,$502.w
	rts

install_vbl_queue:
	move.l	$456.w,a0
.gvbl	tst.l	(a0)+
	bne.s	.gvbl	
	move.l	#new_vbl_lister,-4(a0)
	clr.l	(a0)
	rts


***********************
* NEW VECTOR ROUTINES *
***********************

new_trap_1:	clr.b	current_vec
		bsr	check_option
		beq	old_trap_1
		movem.l	d0-a6,-(a7)
		bsr	init_ripper
		movem.l	(a7)+,d0-a6
old_trap_1:	jmp	$12345678

new_trap_13:	move.b	#1,current_vec
		bsr	check_option
		beq	old_trap_13
		movem.l	d0-a6,-(a7)
		bsr	init_ripper
		movem.l	(a7)+,d0-a6
old_trap_13:	jmp	$12345678

new_trap_14:	move.b	#2,current_vec
		bsr	check_option
		beq	old_trap_14
		movem.l	d0-a6,-(a7)
		bsr	init_ripper
		movem.l	(a7)+,d0-a6
old_trap_14:	jmp	$12345678

new_vbl		move.b	#4,current_vec
		bsr	check_option
		beq	old_vbl
		movem.l	d0-a6,-(a7)
		bsr	init_ripper
		movem.l	(a7)+,d0-a6
old_vbl:	jmp	$12345678

new_hbl:	move.b	#3,current_vec
		bsr	check_option
		beq	old_hbl
		movem.l	d0-a6,-(a7)
		bsr	init_ripper
		movem.l	(a7)+,d0-a6
old_hbl:	jmp	$12345678

new_ikbd	move.b	#10,current_vec
		bsr	check_option
		beq	old_ikbd
		bclr	#6,$fffffa11.w
		movem.l	d0-a6,-(a7)
		bsr	init_ripper
		movem.l	(a7)+,d0-a6
		rte
old_ikbd	jmp	$12345678

new_timer_a	move.b	#6,current_vec
		bclr	#5,$fffffa0f.w
		bsr	check_option
		bne	end_trap
		rte

new_timer_a2	move.b	#6,current_vec
		bsr	check_option
		beq	old_timer_a
		bclr	#5,$fffffa0f.w
		movem.l	d0-a6,-(a7)
		bsr	init_ripper
		movem.l	(a7)+,d0-a6
		rte
old_timer_a	jmp	$12345678

new_timer_b	move.b	#7,current_vec
		bclr	#0,$fffffa0f.w
		bsr	check_option
		bne	end_trap
		rte

new_timer_b2	move.b	#7,current_vec
		bsr	check_option
		beq	old_timer_b
		bclr	#0,$fffffa0f.w
		movem.l	d0-a6,-(a7)
		bsr	init_ripper
		movem.l	(a7)+,d0-a6
		rte
old_timer_b	jmp	$12345678

new_timer_c	move.b	#8,current_vec
		bsr	check_option
		beq	old_timer_c
		movem.l	d0-a6,-(a7)
		bsr	init_ripper
		movem.l	(a7)+,d0-a6
		rte
old_timer_c	jmp	$12345678

new_timer_d	move.b	#9,current_vec
		bclr	#4,$fffffa11.w
		bsr	check_option
		bne	end_trap
		rte

new_timer_d2	move.b	#9,current_vec
		bsr	check_option
		beq	old_timer_d
		bclr	#4,$fffffa11.w
		movem.l	d0-a6,-(a7)
		bsr	init_ripper
		movem.l	(a7)+,d0-a6
		rte
old_timer_d	jmp	$12345678


new_vbl_lister	move.b	#5,current_vec
		bsr	check_option
		beq.s	.no_rip
		movem.l	d0-a6,-(a7)
		bsr	init_ripper
		movem.l	(a7)+,d0-a6
.no_rip		rts
	

end_trap
;	move.w	(a7),old_sr+2
;	move.l	2(a7),old_prg+2
;	move.w	#$2700,(a7)
;	move.l	#init_trap_ripper,2(a7)		
;	rte
init_trap_ripper
	movem.l	d0-a6,-(a7)
	bsr	init_ripper
	movem.l	(a7)+,d0-a6
	rte
;old_sr	move.w	#$2300,sr
;old_prg	jmp	$12345678

check_option:
	movem.l	a0-2/d0,-(a7)
	bsr.s	do_reinstall
	lea	$ffff9200.w,a0	;extended port address (read only)
	move.w	#$fff7,2(a0)	;write mask
	move.w	(a0),d0		;read fire data
	btst	#1,d0		;check for option
	bne.s	no_option	;if set, option is not pressed
	st.b	begin_ripping_flag
no_option:
	movem.l	(a7)+,a0-2/d0
	tst.b	begin_ripping_flag
	rts

do_reinstall
	tst.b	reinstall_flag
	beq	.none

	lea	reinstall_adrs,a0
	lea	install_bits,a2
.loop	move.l	(a0),a1
	cmpa.w	#-1,a1
	beq	.last
	tst.b	(a2)+
	beq.s	.next
	cmpa.w	#0,a1
	beq.s	.next
	move.l	(a1),d0
	cmp.l	4(a0),d0
	beq.s	.next
	move.l	d0,([a0,8])
	move.l	4(a0),(a1)
.next	add.l	#12,a0
	bra.s	.loop

.last
	lea	install_bits+6,a0
	tst.b	(a0)+
	beq.s	.no_timer_a
	bset	#5,$fffffa07.w		;TA Interrupt Enable Register A
	bset	#5,$fffffa13.w		;TA Interrupt Mask Register A

.no_timer_a
	tst.b	(a0)+
	beq.s	.no_timer_b

	bset	#0,$fffffa07.w		;TB Interrupt Enable Register A
	bset	#0,$fffffa13.w		;TB Interrupt Mask Register A

.no_timer_b
	tst.b	(a0)+
	beq.s	.no_timer_c

	bset	#5,$fffffa09.w		;TC Interrupt Enable Register A
	bset	#5,$fffffa15.w		;TC Interrupt Mask Register A

.no_timer_c
	tst.b	(a0)+
	beq.s	.no_timer_d

	bset	#4,$fffffa09.w		;TD Interrupt Enable Register A
	bset	#4,$fffffa15.w		;TD Interrupt Mask Register A

.no_timer_d

.none	rts	


 *------------------------*
** GEMDOS Disk Operations **
 *------------------------*

* A0->filename, A1->address, D1=length


save_file:	lea	file_name(pc),a0
		bsr	create_file
		bmi	display_gemdos_error
		lea	magic,a0
		moveq	#10,d7
		bsr	write_file
		bmi	display_gemdos_error		
		move.w	pic_res,d0
		cmp.w	#4,d0
		beq	.no_pal
		lea	(pal_sizes,d0.w*4),a6
		move.l	(a6)+,d7
		beq.s	.no_st
		lea	pal_space,a0		
		bsr	write_file
.no_st		move.l	(a6)+,d7
		beq.s	.no_pal
		lea	pal_space+32,a0		
		bsr	write_file		
		bmi	display_gemdos_error
.no_pal		move.l	pic_adr,a0
		move.l	pic_length,d7
		bsr	write_file
		bmi	display_gemdos_error
		bsr	close_file
		rts

pal_sizes	dc.l	4,8
		dc.l	8,16
		dc.l	16,64
		dc.l	0,256	


display_gemdos_error:
		lea	gemdos_errors,a0
		move.l	#(end_gemdos_errors-gemdos_errors)/8-1,d1
.find_err	cmp.l	(a0)+,d0
		beq	found_gemdos_error
		addq.l	#4,a0
		dbra	d1,.find_err
		lea	unerr,a0
found_gemdos_error
		move.l	(a0),a0
		moveq	#0,d0
		move.l	#180,d1
		bsr	print_string
		rts

create_file:	movem.l	d1-2/a0-2,-(a7)
		clr.w	-(a7)
		pea	(a0)
		move.w	#$3c,-(a7)
		trap	#1
		addq.l	#8,a7
		movem.l	(a7)+,d1-2/a0-a2
		move.w	d0,file_handle
		rts

open_file:	movem.l	d1-2/a0-2,-(a7)
		clr.w	-(a7)
		pea	(a0)
		move.w	#$3d,-(a7)
		trap	#1
		addq.l	#8,a7
		movem.l	(a7)+,d1-2/a0-a2
		move.w	d0,file_handle	
		rts

read_file:	movem.l	d1-2/a0-2,-(a7)
		pea	(a0)
		move.l	d7,-(a7)
		move.w	file_handle,-(a7)
		move.w	#$3f,-(a7)
		trap	#1
		lea	12(a7),a7
		movem.l	(a7)+,d1-2/a0-a2
		cmp.l	d7,d0
		beq.s	.rf
		move.l	#-1000,d0
.rf		rts

write_file:	movem.l	d1-2/a0-2,-(a7)
		pea	(a0)
		move.l	d7,-(a7)
		move.w	file_handle,-(a7)
		move.w	#$40,-(a7)	
		trap	#1
		lea	12(a7),a7
		movem.l	(a7)+,d1-2/a0-a2
		cmp.l	d7,d0
		beq.s	.l9
		move.l	#-1001,d0
.l9		rts

file_seek:	movem.l	d1-2/a0-2,-(a7)
		move.w	d0,-(a7)
		move.w	file_handle,-(a7)
		move.l	d1,-(a7)
		move.w	#$42,-(a7)
		trap	#1
		lea	10(a7),a7
		movem.l	(a7)+,d1-2/a0-a2
		rts

close_file:	movem.l	d1-2/a0-2,-(a7)
		move.w	file_handle,-(a7)
		move.w	#$3e,-(a7)
		trap	#1
		addq.l	#4,a7
		movem.l	(a7)+,d1-2/a0-a2
		rts

***************************************
* STRING PRINTING/CONVERSION ROUTINES *
***************************************

print_string
	move.l	physic(pc),a1		;screen
	mulu	#80,d1			;y line * line size
	add.l	d1,a1			;get to y line
	lea	tiny_font(pc),a2	;font data
.line	move.l	d0,d2			;start x
.nxt	moveq	#0,d1			;clear d1
	move.b	(a0)+,d1		;get byte from string
	beq	.last
	cmp.b	#13,d1			;return?
	bne.s	.not_return		;no
	add.l	#80*8*6,d0		;next line
	bra.s	.line			;restore x pos
.not_return
	sub.b	#32,d1		;- first char
	mulu	#36,d1		;* char size
	moveq	#5,d4		;6 y lines
.yl	bfextu	(a2){d1:6},d3	
	bfins	d3,(a1){d2:6}
	addq.l	#6,d1		;next char pos in char
	add.l	#80*8,d2	;next screen line
	dbra	d4,.yl		;loop y times
	sub.l	#80*8*6-6,d2	;next x pos
	bra.s	.nxt
.last	rts

* enter with d0=long value

conv_long_ascii:
	movem.l	d0-3/a0,-(a7)
	lea	long_string,a0
	moveq	#$20,d2
	moveq	#9,d1
.clr	move.b	d2,(a0)+
	dbra	d1,.clr	
	clr.b	(a0)
	tst.l	d0
	beq.s	.endc
	moveq	#10,d2
	moveq	#$30,d3	
.conv	divul.l	d2,d1:d0
	add.b	d3,d1
	move.b	d1,-(a0)
	cmp.w	d2,d0
	bcc.s	.conv
	tst.b	d0
	beq.s	.endc
	add.b	d3,d0
	move.b	d0,-(a0)
.endc	movem.l	(a7)+,d0-3/a0
	rts

 *-------------------*
** KEYBOARD ROUTINES **
 *-------------------*


init_ikbd:	bsr	clear_ikbd
		move.l	$118.w,old118
		move.l	#my_ikbd,$118.w
		lea	key_table,a0
		moveq	#127,d0
.cl		clr.b	(a0)+
		dbra	d0,.cl
		rts

restore_ikbd:	bsr	clear_ikbd
		move.l	old118,$118.w
		rts

clear_ikbd:     btst    #0,$fffffc00.w		;is ikbd data reg full?
                beq.s   ikbd_ok			;its empty so end
                move.b  $fffffc02.w,D0		;get ikbd data
                bra.s   clear_ikbd		;loop
ikbd_ok:        rts                             ;return

send_ikbd:      lea     $fffffc00.w,a0		;ikbd control register
waitkeyready:   btst    #1,(a0)			;is data reg empty?
                beq.s   waitkeyready		;no, wait for empty
                move.b  d0,2(a0)		;write to ikbd data reg
                rts                             ;return

my_ikbd:	move.w	#$2500,sr		;set ipl level

		movem.l	d0/a0-a1,-(a7)		;save registers
		movea.w	#$fffffc00,a0		;ikbd control registers

		move.b	(a0),d0			;read control reg
		btst	#7,d0			;int request?
		beq	endmykey		;no

keyloop		moveq	#0,d0			;clear d0
		move.b	2(a0),d0		;read ikbd data
		tst.b	key_cntr		;is this first byte
		beq	chk_head		;yes, so check for header
		
		move.l	key_ptr(pc),a1		;ptr into key storage area
		move.b	d0,(a1)+		;store keyboard data
		move.l	a1,key_ptr		;update ptr
		subq.b	#1,key_cntr		;decrement data to get
		bne	last_key_check		;more data to get

process_packet:
		lea	key_buffer,a1		;start of key storage data
		moveq	#0,d0			;clear d0
		move.b	(a1),d0			;get first byte
		sub.l	#$f6,d0		;minus default packet header value
		and.w	#$f,d0			;mask off unwanted bits
		cmp.w	#10,d0			;is it a valid packet
		bge.s	.noj			;no
		jsr	([key_handlers,d0.w*4])	;jump to packet handler routine
.noj		bra	last_key_check		;check for more key data

chk_head	cmp.w	#$f6,d0			;is it packer header
		blt.s	store_key		;no, store as a key

		move.b	d0,key_buffer		;store packet header
		move.l	#key_buffer+1,key_ptr	;init key pointer
		lea	packet_table,a1		;packet table
		sub.b	#$f6,d0			;d0 is offset
		move.b	(a1,d0.w),key_cntr	;bytes of data to be read
		bra	last_key_check		;get data

store_key
		IFNE	DEBUG
		movem.l	d0-a6,-(a7)
		lea	$f96.w,a0
		jsr	([$1132.w])
		movem.l	(a7)+,d0-a6
		ENDC
		lea	key_table,a1		;keypress table
		bclr	#7,d0			;check 'release' bit
		beq.s	setkey			;0, so set key press
		clr.b	(a1,d0.w)		;key released
		bra.s	last_key_check		;get key data
setkey		st.b	(a1,d0.w)		;set key pressed
		st.b	key_pressed
		move.b	d0,current_key
last_key_check:	move.b	(a0),d0		;read ikbd control
		btst	#0,d0		;more data to read?
		bne	keyloop		;yes, so process it
endmykey	movem.l	(a7)+,d0/a0-1	;restore registers
		bclr	#6,$fffffa11.w	;signal end of ikbd interrupt
		rte

packet_table:
		dc.b	1	;$f6 - keyboard packet
		dc.b	5	;$f7 - absolute mouse packet
		dc.b	2	;$f8 - relative mouse position / no buttons
		dc.b	2	;$f9 - relative mouse / left button
		dc.b	2	;$fa - relative mouse / right button
		dc.b	2	;$fb - relative mouse / both buttons
		dc.b	6	;$fc - time of day
		dc.b	2	;$fd - joystick report
		dc.b	1	;$fe - joystick 0 event
		dc.b	1	;$ff - joystick 1 event
		even

key_handlers:
		dc.l	keyboard_packet_handler	;$f6
		dc.l	absolute_mouse_handler	;$f7
		dc.l	relative_mouse_handler	;$f8
		dc.l	relative_mouse_handler	;$f9
		dc.l	relative_mouse_handler	;$fa
		dc.l	relative_mouse_handler	;$fb
		dc.l	time_of_day_handler	;$fc
		dc.l	joystick_report_handler	;$fd
		dc.l	joystick0_handler	;$fe
		dc.l	joystick1_handler	;$ff

keyboard_packet_handler:
		moveq	#0,d0			;clear d0
		move.b	1(a0),d0		;get key
		bclr	#7,d0			;key pressed?
		beq.s	.setkey			;yes, set it
		clr.b	(key_table,d0.w)	;indicate key release
		rts                             ;return
.setkey		st.b	(key_table,d0.w)	;clear key
		st.b	key_pressed
		move.b	d0,current_key
		rts                             ;return

absolute_mouse_handler:			;no absolute mouse handler!
time_of_day_handler:			;no time of day handler!
joystick_report_handler:
		move.b	1(a1),j1_packet		;get joystick 1 packet
		move.b	2(a1),j2_packet		;get joystick 2 packet
		rts                             ;return

joystick0_handler:
		move.b	1(a1),j1_packet		;save joystick 1 packet
		rts                             ;return

joystick1_handler:
		move.b	1(a1),j2_packet		;save joystick 2 packet
		rts                             ;return

relative_mouse_handler:
		st.b	mouse_moved		;indicate mouse moved

		move.b	(a1),d0			;get mouse key info
		and.w	#%11,d0			;isolate l+r buttons
		move.b	d0,mousek		;save mouse key info

.nolimits	move.b	1(a1),d0		;mouse x movement
		ext.w	d0			;extend to signed word
		add.w	d0,mousex		;update mouse x position
		move.b	2(a1),d0		;mouse y movement
		ext.w	d0			;extedn to signed word
		add.w	d0,mousey		;update mouse y position
;		rts                             ;return

		move.w	mousex,d0
		cmp.w	mousex_min,d0
		bgt.s	.xok1
		move.w	mousex_min,mousex
		bra.s	.xok2
.xok1		cmp.w	mousex_max,d0
		blt.s	.xok2
		move.w	mousex_max,mousex
.xok2		move.w	mousey,d0
		cmp.w	mousey_min,d0
		bgt.s	.yok1
		move.w	mousey_min,mousey
		bra.s	.yok2
.yok1		cmp.w	mousey_max,d0
		blt.s	.yok2
		move.w	mousey_max,mousey
.yok2		rts


***************************
* ERROR HANDLING ROUTINES *
***************************

	movem.l	d0-a7,registers
	move.w	#$2700,sr
	lea	rip_stack,a7
	move.l	#temp_vbl,$70.w
	bsr	init_screen
	bsr	set_angry_pal
	
	lea	registers,a5
;	lea	reg_txts,a6
	move.l	#regs_y,d1
	moveq	#1,d6
	moveq	#7,d7
.loop1	move.l	d5,d0
	move.l	(a5)+,d0	
;	bsr	conv_word_ascii
	move.w	(a6)+,d2
	bsr	reg_print
	moveq	#6*5,d0	
	lea	long_string,a0
	bsr	dum_print
	addq.l	#6,d1
	dbra	d7,.loop1
	move.l	#6*10,d1
	rts

reg_print
	lea	reg_string,a0
	move.w	d2,(a0)
dum_print
	movem.l	d0-a6,-(a7)
	bsr	print_string
	movem.l	(a7)+,d0-a6
	rts

set_angry_pal:
	bsr	wait_vbl
	lea	$ffff9800.w,a0
	lea	$ffff8240.w,a1
	moveq	#63,d0
	ror.l	#6,d0
	move.l	d0,(a0)+
	move.w	#$700,(a1)+
	moveq	#0,d0
	move.l	d0,(a0)+
	move.w	d0,(a1)+
	rts
	


temp_vbl:	addq.l	#1,$466.w
		rte
		
***************************************************************************
	DATA
***************************************************************************

tiny_font	incbin	a:\tinyfnt.bin
		even

Videl_640_200_2
	dc.l	640*200/8+256			* General
	dc.w	0,40,0,$400
	dc.w	0										* Flag Ordre

	dc.w	510,409,80,1007,160,434,0,0	* RGB
	dc.w	625,613,47,127,527,619
	dc.w	$181,%0100

	dc.w	198,141,21,627,80,150,0,0	* VGA 47 Hz
 	dc.w	1337,1300,100,315,1115,1333
	dc.w	$186,%1001

reinstall_adrs:
;	dc.l	$84,new_trap_1,old_trap_1+2
;	dc.l	$b4,new_trap_13,old_trap_13+2
;	dc.l	$b8,new_trap_14,old_trap_14+2
	dc.l	0,0,0
	dc.l	0,0,0
	dc.l	0,0,0
	dc.l	$68,new_hbl,old_hbl+2
	dc.l	$70,new_vbl,old_vbl+2
	dc.l	0,0,0
	dc.l	$134,new_timer_a2,old_timer_a+2
	dc.l	$120,new_timer_b2,old_timer_b+2
	dc.l	$114,new_timer_c,old_timer_c+2
	dc.l	$110,new_timer_d2,old_timer_d+2
	dc.l	$118,new_ikbd,old_ikbd+2
	dc.l	-1

install_routines:
	dc.l	install_trap_1
	dc.l	install_trap_13
	dc.l	install_trap_14
	dc.l	install_hbl
	dc.l	install_vbl
	dc.l	install_vbl_queue
	dc.l	install_timer_a
	dc.l	install_timer_b
	dc.l	install_timer_c
	dc.l	install_timer_d
	dc.l	install_ikbd
	dc.l	install_alt_help
	dc.l	install_reset


ripper_txt
*                123456789 123456
	dc.b	"RESERVOIR RIPPER",13
	dc.b	"----------------",0
coder_txt
	dc.b	"CODED BY MR PINK",0
rg_txt
*                123456789 123456789 123
	dc.b	"(C) 1995 RESERVOIR GODS",0
menu_txt
	dc.b	"[F1]  VIEW SCREEN",13
	dc.b	"[F2]  SAVE SCREEN",13,13
	dc.b	"[F10] EXIT RIPPER"
	dc.b	0

variables_txt:

*                0         1         2         3         4         5         6         7         8
*                 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
	dc.b	"COLS:               X:        Y:",13
	dc.b	"STWIDTH:      FALWIDTH:      ST-SHIFT:      SP-SHIFT:      HSCROLL:      SYNC:",13
	dc.b	"HHT:      HBB:      HBE:      HDB:      HDE:      HSS:      HFS:      HEE:",13
	dc.b	"VFT:      VBB:      VBE:      VDB:      VDE:      VSS:      VCL:      VCO:",0

word_txts
	dc.l	pic_x
	dc.w	6*23,0
	dc.l	pic_y
	dc.w	6*33,0

	dc.l	screen_vars+4		;st width
	dc.w	6*9,1
	dc.l	screen_vars+6		;030 width
	dc.w	6*24,1
	dc.l	screen_vars+10		;sp shift
	dc.w	6*54,1
	dc.l	0

byte_txts
	dc.l	screen_vars+8		;st shift
	dc.w	6*39,1
	dc.l	screen_vars+9
	dc.w	6*68,1
	dc.l	screen_vars+3		;sync hz
	dc.w	6*79,1
	dc.l	0

intro_txt
	dc.b	27,"E"
*                123456789 123456789 12346789 123456789
	dc.b	"           RESERVOIR RIPPER",13,10
	dc.b	"           ----------------",13,10,13,10
	dc.b	"           CODED BY MR PINK",13,10,13,10
	dc.b	"       (C) 1995 RESERVOIR GODS",13,10,13,10

	dc.b	"VECTORS TO HOOK ONTO:",13,10

	dc.b	"F1 - TRAP #1",13,10
	dc.b	"F2 - TRAP #13",13,10
	dc.b	"F3 - TRAP #14",13,10
	dc.b	"F4 - HBL",13,10
	dc.b	"F5 - VBL",13,10
	dc.b	"F6 - VBL QUEUE",13,10
	dc.b	"F7 - TIMER A",13,10
	dc.b	"F8 - TIMER B",13,10
	dc.b	"F9 - TIMER C",13,10
	dc.b	"F10- TIMER D",13,10
	dc.b	"1) - IKBD",13,10
	dc.b	"2) - ALT-HELP",13,10
	dc.b	"3) - RESET",13,10
	dc.b	"[4] - RESTORE",13,10,13,10

*                123456789 123456789 12346789 123456789
	dc.b	"[SPACE] Install Ripper / [ESC] Quit",0


	DC.B	"TIMER A",13
	DC.B	"TIMER B",13
	DC.B	"TIMER D",13
	DC.B	"TIMER C",13
	DC.B	"VBL",13
	DC.B	"VBL QUEUE",13
	DC.B	"TRAP #1",13
	DC.B	"TRAP #2",13
	DC.B	"TRAP #13",13
	DC.B	"TRAP #14",13
	DC.B	"IKBD",13
	DC.B	"BLiTTER DONE",13
	DC.B	"LINE A",13
	DC.B	"LINE F",13
	DC.B	"HBL",13
	DC.B	"ERROR EXEPTIONS",13
	DC.B	"RS-232 INTERRUPTS",13
	DC.B	"MONO MONITOR DETECT",13
	DC.B	"RESET VECTOR",13
	DC.B	"TRACE EXCEPTION",13
	DC.B	"ALT HELP",13
	DC.B	"FLOPPY/HD INTERRUPT",13
	DC.B	"RESET",13

on_txt	dc.b	27,"Y"
on_y	dc.b	32
on_x	dc.b	32
	dc.b	"[ON] ",0
off_txt	dc.b	27,"Y"
off_y	dc.b	32
off_x	dc.b	32
	dc.b	"[OFF]",0

enter_file_txt	dc.b	"ENTER FILENAME:",0
single_string	dc.b	'A',0


v1_txt	dc.b	"TRAP #1",0
v2_txt	dc.b	"TRAP #13",0
v3_txt	dc.b	"TRAP #14",0
v4_txt	dc.b	"HBL",0
v5_txt	dc.b	"VBL",0
v6_txt	dc.b	"VBL QUEUE",0
v7_txt	dc.b	"TIMER A",0
v8_txt	dc.b	"TIMER B",0
v9_txt	dc.b	"TIMER C",0
v10_txt	dc.b	"TIMER D",0
v11_txt	dc.b	"IKBD",0
v12_txt	dc.b	"ALT-HELP",0
v13_txt	dc.b	"RESET",0

entry_txt	dc.b	"ENTERED VIA:",0
	even

v_txt_adrs:
	dc.l	v1_txt
	dc.l	v2_txt
	dc.l	v3_txt
	dc.l	v4_txt
	dc.l	v5_txt
	dc.l	v6_txt
	dc.l	v7_txt
	dc.l	v8_txt
	dc.l	v9_txt
	dc.l	v10_txt
	dc.l	v11_txt
	dc.l	v12_txt
	dc.l	v13_txt

gemdos_errors:
	dc.l	-1000,frerr
	dc.l	-1001,fwerr

	dc.l	-32,einvfn
	dc.l	-33,efilnf
	dc.l	-34,epthnf
	dc.l	-36,eaccdn
	dc.l	-37,eihndl
	dc.l	-39,ensmem
	dc.l	-40,eimba
	dc.l	-46,edrive
	dc.l	-48,ensame
	dc.l	-49,enmfil
	dc.l	-58,elocked
	dc.l	-59,enslock
	dc.l	-64,erange
	dc.l	-65,eintrn
	dc.l	-66,eplfmt
	dc.l	-67,egsbf
	dc.l	-80,eloop
	dc.l	-200,emount
end_gemdos_errors

einvfn:	dc.b	"INVALID FUNCTION",0
efilnf:	dc.b	"FILE NOT FOUND",0
epthnf:	dc.b	"PATH NOT FOUND",0
eaccdn: dc.b	"ACCESS DENIED",0
eihndl: dc.b	"INVALID HANDLE",0
enhndl:	dc.b	"NO MORE HANDLES",0
ensmem:	dc.b	"OUT OF MEMORY",0
eimba:	dc.b	"INVALID MEMORY BLOCK ADDRESS",0
edrive:	dc.b	"INVALID DRIVE",0
ensame:	dc.b	"CROSS DEVICE RENAME",0
enmfil:	dc.b	"NO MORE FILES",0
elocked: dc.b	"RECORD IS ALREADY LOCKED",0
enslock: dc.b	"INVALID LOCK REMOVAL REQUEST",0
erange:	dc.b	"RANGE ERROR",0
eintrn: dc.b	"INTERNAL ERROR",0
eplfmt: dc.b	"INVALID PROGRAM LOAD FORMAT",0
egsbf: dc.b	"MEMORY BLOCK GROWTH FAILURE",0
eloop: dc.b	"TOO MANY SYMBOLIC LINKS",0
emount: dc.b	"MOUNT POINT CROSSED",0
frerr:	dc.b	"FILE READ ERROR",0
fwerr:	dc.b	"FILE WRITE ERROR",0
unerr:	dc.b	"UNKNOWN ERROR",0

scan_code_table:
*                0123456789ABCDEF
	dc.b	'**1234567890_=**'
	dc.b	'QWERTYUIOP[]**AS'
	dc.b	'DFGHJKL:,`*#ZXCV'
	dc.b	'BNM,./*** ******'
	dc.b	'**********-***+*'	
	dc.b	'****************'
	dc.b	'\**()/*789456123'
	dc.b	'0.*'
	even

res_txts:
	dc.l	two_colour_txt
	dc.l	four_colour_txt
	dc.l	sixteen_colour_txt
	dc.l	ep_colour_txt
	dc.l	t_colour_txt

two_colour_txt:
	dc.b	"2 COLOUR",0
four_colour_txt:
	dc.b	"4 COLOUR",0
sixteen_colour_txt:
	dc.b	"16 COLOUR",0
ep_colour_txt
	dc.b	"256 COLOUR",0
t_colour_txt
	dc.b	"TRUE COLOUR",0

long_string
	dc.b	'0123456789',0

reg_string	dc.b	"A0 =",0

	even

key_ptr:	dc.l 	key_buffer

***************************************************************************
	BSS
***************************************************************************
vga_flag		ds.b	1
current_vec		ds.b	1
begin_ripping_flag	ds.b	1
reinstall_flag		ds.b	1
mouse_moved	ds.b	1
key_pressed	ds.b	1
current_key	ds.b	1
j1_packet:	ds.b	1
j2_packet:	ds.b	1
		even

registers	ds.l	16*4

pic_adr		ds.l	1
magic		ds.l	1
pic_res		ds.w	1
pic_x		ds.w	1
pic_y		ds.w	1


physic		ds.l	1
old118		ds.l	1

pic_length	ds.l	1
file_handle	ds.w	1
text_counter	ds.w	1

mousek:			ds.w	1
mouse_key:		ds.w	1
mousex:			ds.w	1
mousey:			ds.w	1
mousex_min:		ds.w	1
mousex_max:		ds.w	1
mousey_min:		ds.w	1
mousey_max:		ds.w	1
key_cntr:		ds.w	1
key_table:		ds.b	128
key_buffer:      	ds.b 	256

file_name:		ds.b	256

old_system_vars	ds.b	256
cur_system_vars	ds.b	256

screen_vars	ds.b	50
pal_space	ds.b	(256*4)+(16*2)

install_bits
		ds.b	1024
rip_stack	ds.l	4
		ds.b	256
screen_space	ds.b	16000
end_ripper