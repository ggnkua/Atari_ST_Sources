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
	clr.l	$ffff9800.w
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
