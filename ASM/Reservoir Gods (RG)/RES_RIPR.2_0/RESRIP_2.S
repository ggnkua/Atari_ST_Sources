*********************************************************************
* Reservoir Ripper II :: Coded by MrPink :: [c] 1998 Reservoir Gods *
*********************************************************************

vars_y	equ	90
regs_y	equ	40
vecs_y	equ	6*7

start_ripper
	move.l  a7,a5
        move.l  4(a5),a5
	lea	$80(a5),a0
	move.l	a0,cmd_adr
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

	move.w	#$59,-(a7)	;get monitor
	trap	#14
	addq.l	#2,a7
	cmp.w	#2,d0
	bne.s	not_vga
	st.b	vga_flag
not_vga
	pea	install_it(pc)
	move.w	#$26,-(a7)
	trap	#14
	addq.l	#6,a7

	move.w	#0,-(a7)
	move.l	#(end_ripper-start_ripper)+$100,-(a7)
	move.w	#$31,-(a7)
	trap	#1

	rts

install_it:
	bsr	save_system
	bsr	do_installation
	rts

do_installation
	move.w	sr,-(a7)
	ori.w	#$0700,sr
	move.l	#new_vbl,my_vector_table+$70
	lea	my_vector_table,a0
	movec	a0,VBR
	move.w	(a7)+,sr
	rts

check_option:
	movem.l	d0-a6,-(a7)
;	not.w	$ffff9800.w
;	not.w	$ffff8240.w
	lea	$ffff9200.w,a0	;extended port address (read only)
	move.w	#$fff7,2(a0)	;write mask
	move.w	(a0),d0		;read fire data
	btst	#1,d0		;check for option
	bne.s	no_option	;if set, option is not pressed
	bsr	init_ripper
no_option:
	movem.l	(a7)+,d0-a6
	rts


init_ripper:
	move.l	a7,old_stack+2
	lea	rip_stack,a7
	move.w	sr,-(a7)
	move.w	#$2700,sr
	clr.b	begin_ripping_flag
	clr.b	new_config
	bsr	save_screen_info
	lea	cur_system_vars,a0
	bsr	save_cur_system
	bsr	restore_system

	clr.b	$fffffa07.w		;iera
	clr.b	$fffffa13.w		;imra
	move.b	#%01000000,$fffffa09.w	;ierb
	move.b	#%01000000,$fffffa15.w	;imrb
	move.l	#temp_vbl,$70.w
	move.w	#$2300,sr
	bsr	save_pal
	bsr	wait_vbl
	bsr	init_screen
	bsr	init_ikbd
	bsr	get_pic_info
	bsr	print_ripper_menu_txt	
	move.b	#3,$fffffc00.w
	move.b	#$96,$fffffc00.w
do_ripper_menu:
	tst.b	key_table+$3b
	bne	show_screen
	tst.b	key_table+$3c
	bne	do_save_videl_file
	tst.b	key_table+$3d
	bne	do_save_file
	tst.b	key_table+$3e
	bne	do_save_god_file
	tst.b	key_table+$3f
	bne	do_save_tga_file
	tst.b	key_table+$44
	beq.s	do_ripper_menu
	bsr	restore_ikbd
	bsr	wait_vbl
	bsr	restore_screen_info	
	bsr	restore_pal
	move.w	#$2700,sr
	lea	cur_system_vars,a0
	bsr	restore_cur_system
	tst.b	new_config
	beq.s	.no_new
	clr.b	check_bit
	bsr	do_installation
	move.b	#1,check_bit
.no_new
	move.w	(a7)+,sr
old_stack
	lea	$12345678,a7
	rts

new_vbl:	bsr	check_option
old_vbl:	jmp	([$70.w])

temp_vbl:	addq.l	#1,$466.w
		rte

print_ripper_menu_txt:

	lea	ripper_txt,a0
	move.l	#320-25*3,d0
	moveq	#0,d1
	bsr	print_string

	lea	coder_txt,a0
	move.l	#320-22*3,d0
	moveq	#10,d1
	bsr	print_string

	lea	rg_txt,a0
	move.l	#320-29*3,d0
	moveq	#20,d1
	bsr	print_string

	lea	menu_txt,a0
	moveq	#0,d0
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


	lea	st_txt,a0
	tst.w	pic_pal
	beq.s	.stpal
	lea	falcon_txt,a0
.stpal	move.l	#45*6,d0
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

.el2	lea	screen_vars+4,a6
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

	moveq	#5,d7
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

	moveq	#0,d0
	move.w	screen_vars+34,d0		
	bsr	conv_long_ascii
	lea	long_string+6,a0
	move.l	d6,d0
	move.l	#vars_y+6*3,d1
	movem.l	d6-7/a6,-(a7)
	bsr	print_string
	movem.l	(a7)+,d6-7/a6
	add.l	#6*10,d6

	moveq	#0,d0
	move.w	screen_vars+38,d0		
	bsr	conv_long_ascii
	lea	long_string+6,a0
	move.l	d6,d0
	move.l	#vars_y+6*3,d1
	movem.l	d6-7/a6,-(a7)
	bsr	print_string
	movem.l	(a7)+,d6-7/a6
	add.l	#6*10,d6

	rts


show_screen
	bsr	wait_vbl
	bsr	restore_screen_info	
	bsr	restore_pic_pal
.wt	tst.b	key_table+$3b
	bne.s	.wt
show_loop
	tst.b	key_table+$48
	beq.s	.not_up

	lea	screen_vars-1,a0
	move.l	(a0),d0
	move.l	screenline_length,d1
	tst.b	key_table+$1D
	beq.s	.nuc
	move.l	screen_length,d1
.wnot_up
	tst.b	key_table+$48
	bne.s	.wnot_up
.nuc
	sub.l	d1,d0
	bmi.s	.not_up
	move.l	d0,(a0)
	bra	show_screen

.not_up
	tst.b	key_table+$50
	beq.s	.not_down

	lea	screen_vars-1,a0
	move.l	(a0),d0
	move.l	screenline_length,d1
	tst.b	key_table+$1D
	beq.s	.ndc
	move.l	screen_length,d1
.wnot_down
	tst.b	key_table+$50
	bne.s	.wnot_down

.ndc
	add.l	d1,d0
	add.l	screen_length,d0
	cmp.l	mem_top,d0
	bge	.not_up

	move.l	(a0),d0
	add.l	d1,d0
	move.l	d0,(a0)
	bra	show_screen

.not_down
	tst.b	key_table+$4B
	beq.s	.not_left

	tst.b	key_table+$1D
	beq.s	.nlc
.wnot_left
	tst.b	key_table+$4B
	bne.s	.wnot_left
.nlc

	lea	screen_vars-1,a0
	move.l	(a0),d0
	moveq	#2,d1
	sub.l	d1,d0
	bmi.s	.not_left
	move.l	d0,(a0)
	bra	show_screen

.not_left
	tst.b	key_table+$4D
	beq.s	.not_right


	tst.b	key_table+$1D
	beq.s	.nrc
.wnot_right
	tst.b	key_table+$4D
	bne.s	.wnot_right
.nrc

	lea	screen_vars-1,a0
	move.l	(a0),d0
	moveq	#2,d1
	add.l	d1,d0
	add.l	screen_length,d0
	cmp.l	mem_top,d0
	bge.s	.not_right
	move.l	(a0),d0
	add.l	d1,d0
	move.l	d0,(a0)
	bra	show_screen

.not_right
	tst.b	key_table+$3c
	bne.s	start_st_pal
	tst.b	key_table+$3d
	bne.s	start_falc_pal	
	tst.b	key_table+$3b
	beq	show_loop
	

	bsr	wait_vbl
	bsr	set_my_screen
	bsr	set_resolution
	bsr	set_my_pal
.wt	tst.b	key_table+$3b
	bne.s	.wt	
	bra	do_ripper_menu

start_st_pal:
	clr.w	pic_pal
	bsr	restore_pic_pal
	bsr	unset_falc_pal
.wt	tst.b	key_table+$3c
	beq	show_loop
	bra.s	.wt

start_falc_pal:
	move.w	#1,pic_pal
	bsr	restore_pic_pal
	bsr	unset_st_pal
.wt	tst.b	key_table+$3d
	beq	show_loop
	bra.s	.wt

do_save_tga_file
	move.b	#3,god_mode
	bra.s	dosavefile
do_save_videl_file
	move.b	#2,god_mode
	bra.s	dosavefile
do_save_god_file
	move.b	#1,god_mode
	bra.s	dosavefile
do_save_file
	clr.b	god_mode
dosavefile
	lea	enter_file_txt,a0
	moveq	#0,d0
	move.l	#160,d1
	bsr	print_string
	
.wt1	tst.b	key_table+$3c
	bne.s	.wt1

	bsr	enter_file_name
	bmi	.err
	bsr	restore_system
	bsr	save_file
.err	bsr	clear_my_screen
	bsr	print_ripper_menu_txt
	bsr	init_ikbd
	bra	do_ripper_menu


get_pic_info:
	move.l	#'GRIP',magic
	lea	screen_vars(pc),a0
	bfextu	(a0){0:24},d0
	move.l	d0,pic_adr
	move.l	d0,cur_pic_adr

	moveq	#0,d0
	move.w	40(a0),d0		;line length (words)
	add.w	d0,d0			;length in bytes
	move.w	d0,line_length		;save

	bsr	get_pic_res

	move.w	28(a0),d0		;82AA - VDE
	sub.w	26(a0),d0		;82A8 - VDB
	move.w	38(a0),d1		;82C0 - VCO

	btst	#1,d1			;interlace mode
	bne.s	.nint			;yes
	lsr.w	d0
.nint	btst	#0,d1			;line doubling?
	beq.s	.nol
	lsr.w	d0	
.nol	move.w	d0,pic_y		;store y size
	mulu	40(a0),d0		;line_width*y lines
	add.l	d0,d0			;*2 file length in bytes
	move.l	d0,pic_length

	moveq	#0,d0
	move.w	40(a0),d0
	add.w	42(a0),d0
	add.w	d0,d0
	move.l	d0,screenline_length
	mulu	pic_y,d0
	move.l	d0,screen_length
	rts

get_pic_res:
	move.b	44(a0),d0			;8260
	move.w	36(a0),d1			;8266
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
	move.w	40(a0),d0		;8210 - line width (words)
	lsl.w	#4,d0			;*16
	move.w	d0,pic_x		;x pixels
	rts
.four_colour
	moveq	#62,d0
	tst.b	vga_flag
	beq.s	.nvga
	moveq	#23,d0
.nvga	cmp.w	4(a0),d0		;HHT
	bne	.sixteen_colour
	move.w	#1,pic_res
	move.w	40(a0),d0		;8210 - line width (words)
	lsl.w	#3,d0			;*16
	move.w	d0,pic_x		;x pixels
	rts
.sixteen_colour
	move.w	#2,pic_res
	move.w	40(a0),d0		;8210 - line width (words)
	lsl.w	#2,d0			;*4
	move.w	d0,pic_x		;x pixels
	rts
.eight_colour
	move.w	#3,pic_res
	move.w	40(a0),d0		;8210 - line width (words)
	add.w	d0,d0			;*2
	move.w	d0,pic_x		;x pixels
	rts
.true_colour
	move.w	#4,pic_res
	move.w	40(a0),pic_x
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
	move.l	$42e.w,mem_top
	lea	old_system_vars(pc),a0	
save_cur_system
	move.w	sr,-(a7)
	move.w	#$2700,sr
	movec	cacr,d0
	move.w	d0,(a0)+
	movec	VBR,d0
	move.l	d0,(a0)+
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
	move.l	$466.w,(a0)+			; current vbl clock
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
;	move.b	$fffffa23.w,(a0)+		; Timer C data
	move.b	$fffffa25.w,(a0)+		; Timer D data
	move.b	$ffff8007.w,(a0)+		; 68030 Configuration 
	move.w	(a7)+,sr
	rts


save_screen_info
	lea	screen_vars(pc),a0
	clr.w	-2(a0)

	move.b	$ffff8201.w,(a0)+	; 0 Screen Adr (high)
	move.b	$ffff8203.w,(a0)+	; 1 Screen Adr (medium)
	move.b	$ffff820d.w,(a0)+	; 2 Screen Adr (low)
	move.b	$ffff8265.w,(a0)+	; 3 Horizontal Scroll

	move.w	$ffff8282.w,(a0)+	; 4 Horizontal Hold Timer
	move.w	$ffff8284.w,(a0)+	; 6 Horizontal Border Begin
	move.w	$ffff8286.w,(a0)+	; 8 Horizontal Border End
	move.w	$ffff8288.w,(a0)+	;10 Horizontal Display Begin
	move.w	$ffff828a.w,(a0)+	;12 Horizontal display End 
	move.w	$ffff828c.w,(a0)+	;14 HSS-Synchro
	move.w	$ffff828e.w,(a0)+	;16 HFS
	move.w	$ffff8290.w,(a0)+	;18 HEE
	move.w	$ffff82a2.w,(a0)+	;20 Vertical Frequency Timer
	move.w	$ffff82a4.w,(a0)+	;22 Vertical Border Begin
	move.w	$ffff82a6.w,(a0)+	;24 Vertical Border End
	move.w	$ffff82a8.w,(a0)+	;26 Vertical Display Begin
	move.w	$ffff82aa.w,(a0)+	;28 Vertical Display End
	move.w	$ffff82ac.w,(a0)+	;30 VSS
	move.w	$ffff820a.w,(a0)+	;32 Video Sync Mode
	move.w	$ffff82c0.w,(a0)+	;34 Video Clock
	move.w	$ffff8266.w,(a0)+	;36 SPSHIFT - Falcon res
	move.w	$ffff82c2.w,(a0)+	;38 Video Control
	move.w	$ffff8210.w,(a0)+	;40 Falcon Line Width
	move.w	$ffff820e.w,(a0)+	;42 STe Line Width
	move.b	$ffff8260.w,(a0)+	;44 ST Resolution

	clr.b	(a0)			;st flag	
	move.l	a0,-(a7)
	bsr	get_pic_info
	move.l	(a7)+,a0

	move.w	pic_res,d0
	jmp	([st_check_rout,d0.w*4])

st_check_rout	dc.l	mono_st_check
		dc.l	four_st_check
		dc.l	sixteen_st_check
		dc.l	non_st_check
		dc.l	non_st_check
mono_st_check
non_st_check	
	move.w	#1,pic_pal
	rts

four_st_check
;	cmp.w	#640,pic_x
;	bne	non_st_check
;	cmp.w	#200,pic_y
;	bne	non_st_check
	cmp.b	#1,-1(a0)
	bne	non_st_check
	st.b	(a0)
	clr.w	pic_pal
	rts

sixteen_st_check
	cmp.w	#320,pic_x
	bne	non_st_check
	cmp.w	#200,pic_y
	bne	non_st_check
	st.b	(a0)
	clr.w	pic_pal
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

	clr.b	$ffff8265.w			; Horizontal scroll reg=0
	clr.w	$ffff820e.w

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
;	move.b	$ffff8007.w,d0
;	and.b	#%11,d0
;	cmp.b	#%10,d0
;	bne.s	R_OK				; not VGA	
;	btst.b	#7,$ffff8006.w			; VGA monitor ?
;	Beq.s	R_Ok				; no, rgb
;	tst.b	vga_flag
;	beq.s	R_Ok
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

set_resolution:
	clr.b	$ffff8265.w			; Horizontal scroll reg=0
	clr.w	$ffff820e.w

	tst.b	vga_flag
	beq	set_res_rgb
set_res_vga:
        MOVE.L   #$C6008E,$FFFF8282.W
        MOVE.L   #$160274,$FFFF8286.W
        MOVE.L   #$4D0096,$FFFF828A.W
        MOVE.L   #$41903B9,$FFFF82A2.W
        MOVE.L   #$990099,$FFFF82A6.W
        MOVE.L   #$3B90415,$FFFF82AA.W
        MOVE.W   #$200,$FFFF820A.W
        MOVE.W   #$186,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.W   #$400,$FFFF8266.W
        MOVE.W   #$9,$FFFF82C2.W
        MOVE.W   #$28,$FFFF8210.W
	rts

set_res_rgb:
        MOVE.L   #$1FE0199,$FFFF8282.W
        MOVE.L   #$5003ED,$FFFF8286.W
        MOVE.L   #$9E01B2,$FFFF828A.W
        MOVE.L   #$2710265,$FFFF82A2.W
        MOVE.L   #$2F007F,$FFFF82A6.W
        MOVE.L   #$20F026B,$FFFF82AA.W
        MOVE.W   #$200,$FFFF820A.W
        MOVE.W   #$182,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.W   #$400,$FFFF8266.W
        MOVE.W   #$4,$FFFF82C2.W
        MOVE.W   #$28,$FFFF8210.W
	rts

        MOVE.L   #$1FE0128,$FFFF8282.W
        MOVE.L   #$A803F5,$FFFF8286.W
        MOVE.L   #$A601C5,$FFFF828A.W
        MOVE.L   #$24501DF,$FFFF82A2.W
        MOVE.L   #$4F004F,$FFFF82A6.W
        MOVE.L   #$1DF0237,$FFFF82AA.W
        MOVE.W   #$200,$FFFF820A.W
        MOVE.W   #$186,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.W   #$400,$FFFF8266.W
        MOVE.W   #$4,$FFFF82C2.W
        MOVE.W   #$28,$FFFF8210.W
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
	move.w	sr,-(a7)
	move.w	#$2700,sr
	move.w	(a0)+,d0
	movec	d0,cacr
	move.l	(a0)+,d0
	movec	d0,VBR
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
	move.l	(a0)+,$466.w			; current vbl clock
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
;	move.b	(a0)+,$fffffa23.w		; Timer C data
	move.b	(a0)+,$fffffa25.w		; Timer D data
	move.b	(a0)+,$ffff8007.w		; 68030 Configuration 
	move.w	(a7)+,sr
	rts


restore_screen_info:
	lea	screen_vars(pc),a0
	move.b	(a0)+,$ffff8201.w	; 0 Screen Adr (high)
	move.b	(a0)+,$ffff8203.w	; 1 Screen Adr (medium)
	move.b	(a0)+,$ffff820d.w	; 2 Screen Adr (low)
	move.b	(a0)+,$ffff8265.w	; 3 Horizontal Scroll

	move.w	(a0)+,$ffff8282.w	; 4 Horizontal Hold Timer
	move.w	(a0)+,$ffff8284.w	; 6 Horizontal Border Begin
	move.w	(a0)+,$ffff8286.w	; 8 Horizontal Border End
	move.w	(a0)+,$ffff8288.w	;10 Horizontal Display Begin
	move.w	(a0)+,$ffff828a.w	;12 Horizontal display End 
	move.w	(a0)+,$ffff828c.w	;14 HSS-Synchro
	move.w	(a0)+,$ffff828e.w	;16 HFS
	move.w	(a0)+,$ffff8290.w	;18 HEE
	move.w	(a0)+,$ffff82a2.w	;20 Vertical Frequency Timer
	move.w	(a0)+,$ffff82a4.w	;22 Vertical Border Begin
	move.w	(a0)+,$ffff82a6.w	;24 Vertical Border End
	move.w	(a0)+,$ffff82a8.w	;26 Vertical Display Begin
	move.w	(a0)+,$ffff82aa.w	;28 Vertical Display End
	move.w	(a0)+,$ffff82ac.w	;30 VSS
	move.w	(a0)+,$ffff820a.w	;32 Video Sync Mode
	move.w	(a0)+,$ffff82c0.w	;34 Video Clock
	move.w	(a0)+,$ffff8266.w	;36 SPSHIFT - Falcon res
	tst.b	7(a0)
	beq.s	.no_st
	move.b	6(a0),$ffff8260.w
.no_st
	move.w	(a0)+,$ffff82c2.w	;38 Video Control
	move.w	(a0)+,$ffff8210.w	;40 Falcon Line Width
	move.w	(a0)+,$ffff820e.w	;42 STe Line Width
	rts


restore_pic_pal
	bsr	wait_vbl
	tst.w	pic_pal
	beq	restore_st_pal
	bra	restore_falc_pal

restore_pal
	bsr	wait_vbl
	bsr	restore_st_pal
	bsr	restore_falc_pal
	rts

restore_st_pal
	lea	pal_space,a0
	lea	$ffff8240.w,a1
	moveq	#15,d0
.save_st_pal
	move.w	(a0)+,(a1)+
	dbra	d0,.save_st_pal
	rts

unset_st_pal
	lea	$ffff8240.w,a0
	moveq	#0,d0
	moveq	#7,d1
.uns	move.l	d0,(a0)+
	dbra	d1,.uns
	rts

restore_falc_pal
	lea	pal_space+32,a0
	lea	$ffff9800.w,a1
	move.w	#255,d0
.save_falc_pal
	move.l	(a0)+,(a1)+
	dbra	d0,.save_falc_pal
	rts

unset_falc_pal
	lea	$ffff9800.w,a0
	moveq	#0,d0
	move.w	#255,d1
.uns	move.l	d0,(a0)+
	dbra	d1,.uns
	rts

 *-------------------*
** KEYBOARD ROUTINES **
 *-------------------*


init_ikbd:	bsr	clear_ikbd
		moveq	#$11,d0
		bsr	send_ikbd
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
;		IFNE	DEBUG
;		movem.l	d0-a6,-(a7)
;		lea	$f96.w,a0
;		jsr	([$1132.w])
;		movem.l	(a7)+,d0-a6
;		ENDC
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

 *------------------------*
** GEMDOS Disk Operations **
 *------------------------*

* A0->filename, A1->address, D1=length


save_file:
		move.l	pic_adr,cur_pic_adr
		cmp.b	#1,god_mode
		beq	save_god_file
		cmp.b	#2,god_mode
		beq	save_videl_file
		cmp.b	#3,god_mode
		beq	save_tga_file
		lea	file_name(pc),a0
		bsr	create_file
		bmi	display_gemdos_error
		lea	magic,a0
		moveq	#16,d7
		bsr	write_file
		bmi	display_gemdos_error		
		move.w	pic_res,d0
		lea	st_pal_sizes,a1
		lea	pal_space,a0
		tst.w	pic_pal
		beq.s	.st_pal
		lea	falc_pal_sizes,a1
		lea	pal_space+32,a0
.st_pal		move.l	(a1,d0.w*4),d7
		beq.s	.no_pal
		bsr	write_file
		bmi	display_gemdos_error
.no_pal

save_true
		tst.w	screen_vars+42
		bne	save_pic_lines
		move.l	pic_adr,a0
		move.l	pic_length,d7
		bsr	write_file
		bmi	display_gemdos_error
		bsr	close_file
		rts
save_pic_lines
		move.l	pic_adr,a0
		moveq	#0,d7
		move.w	screen_vars+40,d7
		move.l	d7,d6
		add.w	screen_vars+42,d6
		add.l	d7,d7
		add.l	d6,d6
		
		move.w	pic_y,d5
		subq.w	#1,d5
		bmi.s	.err
.lines		bsr	write_file
		add.l	d6,a0
		dbra	d5,.lines

.err		bsr	close_file
		rts


save_true_tga:
		
		move.w	pic_y,d1
		subq.w	#1,d1
.y_loop:	move.w	pic_x,d0
		subq.w	#1,d0

		move.l	cur_pic_adr,a0
		move.l	physic(pc),a1

.copy_x:	move.w	(a0)+,(a1)+
		dbra	d0,.copy_x		
		bsr	save_tga_line

		moveq	#0,d4
		move.w	screen_vars+40,d4
		add.w	screen_vars+42,d4
		add.l	d4,d4
		add.l	d4,cur_pic_adr

		dbra	d1,.y_loop
		bsr	close_file

		rts



		move.l	pic_adr,a0
		move.w	pic_y,d0
		subq.w	#1,d0	

		moveq	#0,d7
		move.w	screen_vars+40,d7
		move.l	d7,d6
		add.w	screen_vars+42,d6
		add.l	d7,d7
		add.l	d6,d6
		move.w	line_length,d0
		mulu.w	d6,d0
		add.l	d0,a0
		
		move.w	pic_y,d5
		subq.w	#1,d5
		bmi.s	.err
.lines		bsr	write_file
		sub.l	d6,a0
		dbra	d5,.lines

.err		bsr	close_file
		rts


save_god_file:	lea	file_name(pc),a0
		bsr	create_file
		bmi	display_gemdos_error
		lea	god_head,a0
		move.w	#'G4',(a0)
		move.w	pic_x,2(a0)
		move.w	pic_y,4(a0)
		moveq	#6,d7
normal_save:	bsr	write_file
		bmi	display_gemdos_error		
		
		cmp.w	#4,pic_res		;true colour
		beq	save_true		;yes

		bsr	get_god_pal
		
		move.w	pic_y,d0
		subq.w	#1,d0
		bmi	.err
.write_line_loop				
		move.w	d0,-(a7)
		bsr	convert_god_line
		move.l	physic(pc),a0		;line buffer
		moveq	#0,d7
		move.w	pic_x,d7		;x pixels
		add.l	d7,d7			;*2=tc line size
		bsr	write_file
		bmi	display_gemdos_error
		move.w	(a7)+,d0
		dbra	d0,.write_line_loop

.err		bsr	close_file
		rts

save_tga_file:	lea	file_name(pc),a0
		bsr	create_file
		bmi	display_gemdos_error
		lea	god_head,a0
		move.l	#$00000200,(a0)+	; 0-3
		clr.l	(a0)+			; 4-7
		clr.l	(a0)+			; 8-11
		move.w	pic_x,d0
		ror.w	#8,d0
		move.w	d0,(a0)+		; 12
		move.w	pic_y,d0
		ror.w	#8,d0
		move.w	d0,(a0)+		; 14
		move.w	#$1020,(a0)		; 16 bit, origin lower left
		lea	god_head,a0
		moveq	#18,d7			; 18 bytes to save
		bsr	write_file
		bmi	display_gemdos_error		
		
		cmp.w	#4,pic_res		;true colour
		beq	save_true_tga		;yes

		bsr	get_god_pal
		

		move.w	pic_y,d1
		subq.w	#1,d1
.y_loop		bsr	convert_god_line
		bsr	save_tga_line

;		moveq	#0,d2
;		move.w	screen_vars+40,d2
;		add.w	screen_vars+42,d2
;		add.l	d2,d2
;		add.l	d2,cur_pic_adr

		dbra	d1,.y_loop

		bsr	close_file
		
		rts

;		move.w	pic_y,d0
;		subq.w	#1,d0	
;		mulu.w	line_length,d0
;		add.l	d0,cur_pic_adr	
		
		move.w	pic_y,d0
		subq.w	#1,d0
		bmi	.err
.write_line_loop				
		move.w	d0,-(a7)
		bsr	convert_god_line
		sub.l	d4,cur_pic_adr
		sub.l	d4,cur_pic_adr
		move.l	physic(pc),a0		;line buffer
		moveq	#0,d7
		move.w	pic_x,d7		;x pixels
		add.l	d7,d7			;*2=tc line size
		bsr	write_file
		bmi	display_gemdos_error
		move.w	(a7)+,d0
		dbra	d0,.write_line_loop

.err		bsr	close_file
		rts

; GGGBBBBB ARRRRRGG 

save_tga_line:
	movem.l	d0-a6,-(a7)

	move.l	physic(pc),a0	; physic
	move.w	pic_x,d3
	subq.w	#1,d3

.loop	bfextu	(a0){0:7},d0	; 0RRRRR:GG
	bfextu	(a0){7:3},d1	; GGG
	lsl.w	#5,d1		; GGG00000
	bfextu	(a0){11:5},d2	; BBBBB
	or.w	d2,d1		; GGGBBBBB
	lsl.w	#8,d1
	or.w	d1,d0
	move.w	d0,(a0)+	; write back converted word	

	dbra	d3,.loop

	moveq	#0,d7
	move.w	pic_x,d7
	add.l	d7,d7
	move.l	physic(pc),a0
	bsr	write_file
			
	movem.l	(a7)+,d0-a6
	rts

convert_god_line:
		movem.l	d0-a6,-(a7)		

		move.l	cur_pic_adr,a0
		move.l	physic(pc),a1	;buffer space		
		lea	colour_table,a2
		move.w	pic_x,d4	;pixels
		lsr.w	#4,d4		;divide by 16
		subq.w	#1,d4		;-1 for dbra
		bmi	.error

.line		move.w	pic_res,d3	;0,1,2
		move.w	(plane_dbra,d3.w*2),d5 ;get dbra amount
		moveq	#0,d0
.loop1		moveq	#0,d2		;d2=current pixel
		move	#31,d7
		move.l	a0,a3		;screen address
		move.w	d5,d3		;dbra	amount
.get_pix	bfextu	(a3){d0:1},d1	;get bit
		bfins	d1,d2{d7:1}
;		roxr.b	#1,d1		;shift to X flag
;		roxl.b	#1,d2		;shift from X flag
;		lsl.w	d2
;		or.w	d1,d2
		addq.w	#2,a3		;next plane
		subq.w	#1,d7
		dbra	d3,.get_pix						
		move.w	(a2,d2.w*2),(a1)+	;copy pixel	
		addq.l	#1,d0		;next pixel
		cmp.w	#16,d0		;last in plane
		blt.s	.loop1
		move.l	a3,a0
		dbra	d4,.line

;		move.l	a0,cur_pic_adr
		moveq	#0,d4
		move.w	screen_vars+40,d4
		add.w	screen_vars+42,d4
		add.l	d4,d4
		add.l	d4,cur_pic_adr

;		move.l	line_length,d7		;line size in words	
;		add.l	d7,cur_pic_adr		;update ptr

.error
		movem.l	(a7)+,d0-a6
		rts	


get_god_pal:
		lea	pal_space,a0
		lea	colour_table,a1
		move.w	pic_res,d0
		move.w	(cols_dbra,d0.w*2),d0
		cmp.w	#255,d0
		beq	get_256_pal
.loop		bfextu	(a0){4:1},d1	;lowest red bit
		bfextu	(a0){5:3},d2	;other red bits
		lsl.w	d2		;shift up a bit
		or.w	d2,d1		;form red byte
		lsl.w	#1,d1		;->5 bit value
		bfins	d1,(a1){0:5}	;store in table
		bfextu	(a0){8:1},d1	;lowest green bit
		bfextu	(a0){9:3},d2	;other green bits
		lsl.w	d2		;shift up a bit
		or.w	d2,d1		;form green byte
		lsl.w	#2,d1		;->6 bit value
		bfins	d1,(a1){5:6}	;store in table
		bfextu	(a0){12:1},d1	;lowest blue bit
		bfextu	(a0){13:3},d2	;other blue bits
		lsl.w	d2		;shift up a bit
		or.w	d2,d1		;form blue byte
		lsl.w	#1,d1		;->5 bit value
		bfins	d1,(a1){11:5}	;store in table
		addq.w	#2,a0
		addq.w	#2,a1
		dbra	d0,.loop	;loop for all colours
		rts		

get_256_pal:	lea	32(a0),a0
		lea	colour_table,a1
.loop		bfextu	(a0){0:5},d1
		bfins	d1,(a1){0:5}
		bfextu	(a0){8:6},d1
		bfins	d1,(a1){5:6}				
		bfextu	(a0){24:5},d1
		bfins	d1,(a1){11:5}				
		addq.w	#4,a0
		addq.w	#2,a1
		dbra	d0,.loop
		rts

cols_dbra	dc.w	0,3,15,255
plane_dbra	dc.w	0,1,3,7

st_pal_sizes	dc.l	4,8,32,0,0
falc_pal_sizes	dc.l	8,16,64,1024,0


save_videl_file:
	lea	file_name(pc),a0
	bsr	create_file
	bmi	display_gemdos_error
	lea	screen_vars+4,a0
	moveq	#42,d7
	bsr	write_file
	bsr	close_file
	rts
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

***************************************************************************
	DATA
***************************************************************************
	even

my_vector_table_name
	dc.l	"PINK"
my_vector_table:
	
o	set	0
	rept	$100
	dc.l	my_vector_jump+o
o	set	o+6
	endr

my_vector_jump:
o	set	0
	rept	$100
	jmp	([o.w])
o	set	o+4
	endr

tiny_font	incbin	d:\gods\ripper\tinyfnt.bin
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


ripper_txt
*                123456789 123456789 12345
	dc.b	"** RESERVOIR RIPPER II **",13,0
coder_txt
	dc.b	"** CODED BY MR PINK **",0
rg_txt
*                123456789 123456789 123456789
	dc.b	"** (C) 1998 RESERVOIR GODS **",0
menu_txt
	dc.b	"[F1]  VIEW SCREEN",13
	dc.b	"[F2]  SAVE VIDEL",13
	dc.b	"[F3]  SAVE SCREEN (RIP)",13
	dc.b	"[F4]  SAVE SCREEN (GOD)",13
	dc.b	"[F5]  SAVE SCREEN (TGA)",13,13
	dc.b	"[F10] EXIT RIPPER",13
	dc.b	0

st_txt		dc.b	"ST",0
falcon_txt	dc.b	"FALCON",0

variables_txt:

*                0         1         2         3         4         5         6         7         8
*                 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
	dc.b	"COLS:               X:        Y:        PAL: ",13
	dc.b	"PXLSKIP:      FALWIDTH:      ST-SHIFT:      SP-SHIFT:      HSCROLL:      SYNC:",13
	dc.b	"HHT:      HBB:      HBE:      HDB:      HDE:      HSS:      HFS:      HEE:",13
	dc.b	"VFT:      VBB:      VBE:      VDB:      VDE:      VSS:      VCL:      VCO:",0
	even

word_txts
	dc.l	pic_x
	dc.w	6*23,0
	dc.l	pic_y
	dc.w	6*33,0

	dc.l	screen_vars+42		;st width
	dc.w	6*9,1
	dc.l	screen_vars+40		;030 width
	dc.w	6*24,1
	dc.l	screen_vars+36		;sp shift
	dc.w	6*54,1
	dc.l	0

byte_txts
	dc.l	screen_vars+44		;st shift
	dc.w	6*39,1
	dc.l	screen_vars+3		;hscroll
	dc.w	6*68,1
	dc.l	screen_vars+32		;sync hz
	dc.w	6*79,1
	dc.l	0


enter_file_txt	dc.b	"ENTER FILENAME:",0
single_string	dc.b	'A',0


	even

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

	even


key_ptr:	dc.l 	key_buffer

ddir:  dc.b    "A:\*.*"
       ds.b    256

***************************************************************************
	BSS
***************************************************************************
god_mode		ds.b	1
new_config		ds.b	1
check_bit		ds.b	1
vec_family		ds.b	1
v_toggle_mode		ds.b	1
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

new_sr		ds.w	1
cur_pic_adr	ds.l	1

cmd_adr		ds.l	1

god_head	ds.b	18

pic_adr		ds.l	1
magic		ds.l	1
rip_ver		ds.w	1
pic_res		ds.w	1
pic_x		ds.w	1
pic_y		ds.w	1
line_length	ds.w	1
pic_pal		ds.w	1

physic		ds.l	1
old118		ds.l	1
mfp_sei		ds.l	1

pic_length	ds.l	1
screenline_length	ds.l	1
screen_length	ds.l	1
mem_top		ds.l	1
file_handle	ds.w	1
text_counter	ds.w	1
old_vmode:	ds.w	1

reset_adr	ds.l	1

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

		ds.b	2
screen_vars	ds.b	50
pal_space	ds.b	(256*4)+(16*2)

colour_table	ds.w	256
install_bits	ds.b	24
		ds.b	1024
rip_stack	ds.l	4
		ds.b	256
screen_space	ds.b	16000
end_ripper

