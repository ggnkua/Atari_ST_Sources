**************************
**** RESERVOIR RIPPER ****
**************************
**** Coded by Mr Pink ****
**************************
* (C)1995 RESERVOIR GODS *
**************************


; # = $2b (scan code)

DEBUG	equ	0

BSS_DEBUG	equ	1
new_bss_ikbd	equ	0

vars_y	equ	90
regs_y	equ	40
vecs_y	equ	6*7

timer_a_ex	equ	0
timer_b_ex	equ	1
timer_c_ex	equ	2
timer_d_ex	equ	3
vbl_ex		equ	4
vbl_q_ex	equ	5
trap_1_ex	equ	6
trap_2_ex	equ	7
trap_13_ex	equ	8
trap_14_ex	equ	9
ikbd_ex		equ	10
blitter_ex	equ	11
line_a_ex	equ	12
line_f_ex	equ	13
hbl_ex		equ	14
error_ex	equ	15
rs232_ex	equ	16
mono_ex		equ	17
mmu_ex		equ	18
trace_ex	equ	19
alt_help_ex	equ	20
fdi_ex		equ	21
reset_ex	equ	22


	IFNE	BSS_DEBUG
	INCLUDE	"j:\asm\bssdebug\examples\devpac\macros.sh"
	ENDC

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

	clr.w	-(a7)
	pea	$200000
	trap	#1

	IFNE	BSS_DEBUG
	SetBreak	<"convert_god_line">,BREAKSimple,0,<"">
	SetBreak	<"get_god_pal">,BREAKSimple,0,<"">
	SetWatch	<"pic_x">,WATCHWord
	SetWatch	<"pic_y">,WATCHWord
	SetWatch	<"pic_res">,WATCHWord
	SetWatch	<"cur_pic_adr">,WATCHLong
	SetWatch	<"line_length">,WATCHLong

	ENDC

	move.w	#$59,-(a7)	;get monitor
	trap	#14
	addq.l	#2,a7
	cmp.w	#2,d0
	bne.s	not_vga
	st.b	vga_flag
not_vga
	IFEQ	DEBUG
	bsr	save_system
	ENDC

	move.l	#start_ripper,$30.w
	move.l	#end_ripper,$432.w

	dc.w	$a00a

	lea	intro_txt(pc),a0
	bsr	gemdos_print
	bsr	wait_key

	bsr	do_first_menu
	beq.s	do_tsr
term

	clr.w	-(a7)
	trap	#1
do_tsr
	move.w	sr,-(a7)
	move.w	#$2700,sr
	clr.b	check_bit
	bsr	do_installation
	move.b	#1,check_bit
	move.w	(a7)+,sr

	IFNE	DEBUG
	bra	init_ripper
	ENDC

	bsr	get_drive_dir
	move.l	cmd_adr,a2
	move.b	(a2)+,d0
	subq.w	#1,d0
	bmi.s	no_command

.cpy	move.b	(a2)+,(a0)+
	dbra	d0,.cpy

	pea	null(pc)
	pea	null(pc)
	pea	ddir
	pea	$4b0000
	trap	#1
	lea	16(a7),a7

no_command
	move.w	#0,-(a7)
	move.l	#end_ripper-start_ripper+$100,-(a7)
	move.w	#$31,-(a7)
	trap	#1

null	dc.l	0

get_drive_dir
	move.w  #$19,-(sp)      ; Get current drive 
	trap    #1              
        addq.l  #2,sp
        move.w	d0,d1
        add.b   #65,d0          ; alter from number to letter  
        move.b  d0,ddir		; store

	clr.b	ddir+2

	addq.w	#1,d1
	move.w	d1,-(a7)
	pea	ddir+2
	move.w	#$47,-(a7)
	trap	#1
	addq.l	#8,a7

	lea	ddir,a0
.notend	tst.b	(a0)+
	bne.s	.notend
	move.b	#'\',-1(a0)
	clr.b	(a0)
	rts


do_first_menu:
	bsr	save_screen_info
	bsr	save_pal
	bsr	wait_vbl
	bsr	init_screen
	bsr	init_ikbd
	bsr	do_vector_install_menu
	move.w	d0,-(a7)
	bsr	restore_ikbd	
	bsr	restore_screen_info
	bsr	restore_pal
	tst.w	(a7)+
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
	clr.b	new_config
	bsr	save_screen_info
	lea	cur_system_vars,a0
	bsr	save_cur_system
	bsr	get_current_vecs
	IFEQ	DEBUG
	bsr	restore_system
	ENDC
	move.l	mfp_sei,d0
	beq.s	.non_mfp
	move.w	d0,a0
	swap	d0
	bclr.b	d0,(a0)
.non_mfp
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
do_ripper_menu:
	tst.b	key_table+$3b
	bne	show_screen
	tst.b	key_table+$3c
	bne	do_vec_menu
	tst.b	key_table+$3d
	bne	do_save_file
	tst.b	key_table+$3e
	bne	do_save_god_file
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
	bsr	do_installation
.no_new
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
	move.b	vec_family,d0
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

get_current_vecs:
	lea	new_adrs,a0
	lea	install_bits,a1
.loop	moveq	#0,d0
	move.w	(a0)+,d0
	bmi.s	.last
	move.w	(a0)+,a2
	move.l	(a2),d1
	cmp.l	(a0)+,d1
	beq.s	.ok
	bclr	#0,(a1,d0.w)
	bra.s	.loop
.ok	bset	#0,(a1,d0.w)
	bra.s	.loop
.last
	move.l	$456.w,a0
	move.w	$454.w,d2
	move.l	#new_vbl_lister,d0
.find	move.l	(a0)+,d1
	beq.s	.novbl
	cmp.l	d0,d1
	beq.s	.got
	dbra	d2,.find
.novbl	bclr	#0,vbl_q_ex(a1)
	rts
.got	bset	#0,vbl_q_ex(a1)
	rts


do_vec_menu:
	bsr	clear_my_screen

	bsr	do_vector_install_menu
	beq.s	.no_new
	st.b	new_config
.no_new
	bsr	clear_my_screen
	bsr	print_ripper_menu_txt
	bra	do_ripper_menu

do_save_god_file
	st.b	god_mode
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
	IFEQ	DEBUG
	bsr	restore_system
	ELSE
	bsr	restore_ikbd
	ENDC
	IFNE	new_bss_ikbd
	bsr	init_ikbd
	move.l	$84.w,old_bss_trap_1+2
	move.l	#bss_trap_1,$84.w
	move.l	$b4.w,old_bss_trap_13+2
	move.l	#bss_trap_13,$b4.w
	ENDC
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
	add.l	d0,d0			;length in bytes
	move.l	d0,line_length		;save

	bsr	get_pic_res

	move.w	28(a0),d0		;82AA - VDE
	sub.w	26(a0),d0		;82A8 - VDB
	move.w	38(a0),d1		;82C0 - VCO

;	tst.b	vga_flag
;	bne.s	.int
	btst	#1,d1			;interlace mode
	bne.s	.nint			;yes
	lsr.w	d0
.nint
;	btst	#3,d1			;quarter pixel mode
;	beq.s	.noq
;	lsr.w	d0
;.noq	btst	#2,d1			;halve pixel mode?
;	beq.s	.noh
;	lsr.w	d0
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
	lea	old_system_vars(pc),a0	
save_cur_system
	move.w	sr,-(a7)
	move.w	#$2700,sr
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
	move.b	$fffffa23.w,(a0)+		; Timer C data
	move.b	$fffffa25.w,(a0)+		; Timer D data
	move.b	$ffff8007.w,(a0)+		; 68030 Configuration 
	move.w	(a7)+,sr
	rts

save_screen_info:
;	lea	screen_vars(pc),a0	; Espace de sauvegarde
;	move.b	$ffff8201.w,(a0)+	;0 Vid‚o (poids fort)
;	move.b	$ffff8203.w,(a0)+	;1 Vid‚o (poids moyen)
;	move.b	$ffff820d.w,(a0)+	;2 Vid‚o (poids faible)
;	move.b	$ffff820a.w,(a0)+	;3 Synchronisation vid‚o
;	move.w	$ffff820e.w,(a0)+	;4 Offset pour prochaine ligne
;	move.w	$ffff8210.w,(a0)+	;6 Largeur d'une ligne en mots
;	move.b	$ffff8260.w,(a0)+	;8 R‚solution ST
;	move.b	$ffff8265.w,(a0)+	;9 D‚calage Pixel
;	move.w	$ffff8266.w,(a0)+	;10 R‚solution FALCON
;	move.w	$ffff8282.w,(a0)+	;12 HHT-Synchro
;	move.w	$ffff8284.w,(a0)+	;14 Fin du d‚codage de la ligne
;	move.w	$ffff8286.w,(a0)+	;16 D‚but du d‚codage de la ligne
;	move.w	$ffff8288.w,(a0)+	;18 Overscan gauche
;	move.w	$ffff828a.w,(a0)+	;20 Overscan droit
;	move.w	$ffff828c.w,(a0)+	;22 HSS-Synchro
;	move.w	$ffff828e.w,(a0)+	;24 HFS
;	move.w	$ffff8290.w,(a0)+	;26 HEE
;	move.w	$ffff82a2.w,(a0)+	;28 VFT-Synchro
;	move.w	$ffff82a4.w,(a0)+	;30 Fin du d‚codage de l'image
;	move.w	$ffff82a6.w,(a0)+	;32 D‚but du d‚codage de l'image
;	move.w	$ffff82a8.w,(a0)+	;34 VDB
;	move.w	$ffff82aa.w,(a0)+	;36 VDE
;	move.w	$ffff82ac.w,(a0)+	;38 VSS-Synchro
;	move.w	$ffff82c0.w,(a0)+	;40 Reconnaissance ST/FALCON
;	move.w	$ffff82c2.w,(a0)	;42 VCO

;	move.w	#-1,-(a7)
;	move.w	#$58,-(a7)	
;	trap	#14
;	addq.l	#4,a7
;	move.w	d0,old_vmode
;	rts

save_screen_info2:
	lea	screen_vars(pc),a0

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
	rts

four_st_check
;	cmp.w	#640,pic_x
;	bne	non_st_check
;	cmp.w	#200,pic_y
;	bne	non_st_check
	cmp.b	#1,-1(a0)
	bne	non_st_check
	st.b	(a0)
	rts

sixteen_st_check
	cmp.w	#320,pic_x
	bne	non_st_check
	cmp.w	#200,pic_y
	bne	non_st_check
	st.b	(a0)
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
	move.w	-8(a0),$ffff8210.w		; Falcpm line width
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
	move.w	sr,-(a7)
	move.w	#$2700,sr
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
	move.b	(a0)+,$fffffa23.w		; Timer C data
	move.b	(a0)+,$fffffa25.w		; Timer D data
	move.b	(a0)+,$ffff8007.w		; 68030 Configuration 
	move.w	(a7)+,sr
	rts



restore_screen_info:
;	move.w	sr,-(a7)
;	ori.w	#$0700,sr
;	move.w	old_vmode,-(a7)
;	move.w	#$58,-(a7)
;	trap	#14
;	addq.l	#4,a7
;
;	lea	screen_vars(pc),a0
;	move.b	(a0)+,$ffff8201.w		; Vid‚o (poids fort)
;	move.b	(a0)+,$ffff8203.w		; Vid‚o (poids moyen)
;	move.b	(a0)+,$ffff820d.w		; Vid‚o (poids faible)
;	move.b	(a0)+,$ffff820a.w		; Synchronisation vid‚o
;	move.w	(a0)+,$ffff820e.w		; Offset pour prochaine ligne
;	move.w	(a0)+,$ffff8210.w		; Largeur d'une ligne en mots
;	move.b	(a0)+,d0			; R‚solution ST
;	move.b	(a0)+,$ffff8265.w		; D‚calage Pixel
;	move.w	(a0)+,d1			; R‚solution FALCON
;	move.w	(a0)+,$ffff8282.w		; HHT-Synchro
;	move.w	(a0)+,$ffff8284.w		; Fin du d‚codage de la ligne
;	move.w	(a0)+,$ffff8286.w		; D‚but du d‚codage de la ligne
;	move.w	(a0)+,$ffff8288.w		; Overscan gauche
;	move.w	(a0)+,$ffff828a.w		; Overscan droit
;	move.w	(a0)+,$ffff828c.w		; HSS-Synchro
;	move.w	(a0)+,$ffff828e.w		; HFS
;	move.w	(a0)+,$ffff8290.w		; HEE
;	move.w	(a0)+,$ffff82a2.w		; VFT-Synchro
;	move.w	(a0)+,$ffff82a4.w		; Fin du d‚codage de l'image
;	move.w	(a0)+,$ffff82a6.w		; D‚but du d‚codage de l'image
;	move.w	(a0)+,$ffff82a8.w		; Overscan haut
;	move.w	(a0)+,$ffff82aa.w		; Overscan bas
;	move.w	(a0)+,$ffff82ac.w		; VSS-Synchro
;	move.w	(a0)+,$ffff82c0.w		; Reconnaissance ST/FALCON
;	move.w	(a0),$ffff82c2.w		; Informations r‚solution
;	move.w	d1,$ffff8266.w			; Fixe r‚solution FALCON...
;	btst.b	#0,$ffff82c0.w			; R‚solution FALCON ?
;	bne.s	.Falcon_Rez			; Si oui,saut !
;	move.b	d0,$ffff8260.w			; Fixe r‚solution ST...
;.Falcon_Rez
;	move.w	(a7)+,sr
;	rts

restore_screen_info2:
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
;	move.b	(a0),$ffff8260.w	;44 ST Resolution
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


****************************
* VECTOR INSTALLATION MENU *
****************************

do_vector_install_menu
	lea	vector_menu_txt,a0
	moveq	#0,d0
	moveq	#0,d1
	bsr	print_string
	bsr	display_all_vecs
	clr.b	key_pressed
.loop	tst.b	key_table+$39
	bne	.end
	tst.b	key_table+1
	bne	.quit
	bsr	get_my_key
	cmp.w	#$2b,d0
	bne.s	.non_hash
	bsr	vector_toggle
	bsr	display_all_vecs
	bra.s	.loop
.non_hash
	bsr	convert_my_key
	tst.w	d1
	bmi.s	.loop

	moveq	#2,d0
	tst.b	key_table+$38
	bne.s	.setbit
	moveq	#1,d0
	tst.b	key_table+$2a
	bne.s	.setbit
	tst.b	key_table+$36
	bne.s	.setbit	
	moveq	#0,d0
.setbit
	lea	space_txt,a0
	bchg	d0,(install_bits,d1.w)
	bne.s	.space
	lea	star_txt,a0
.space	move.l	(vecs_x,d0.w*4),d0
	mulu	#6,d1
	add.l	#vecs_y,d1
	bsr	print_string
	bra	.loop
.quit	moveq	#-1,d0
	rts
.end	moveq	#0,d0
	rts	

display_all_vecs:
	moveq	#22,d7			;vecs to check
	moveq	#vecs_y,d1	

	lea	install_bits,a6
.ly	moveq	#2,d6
.lx	move.l	(vecs_x,d6.w*4),d0
	lea	space_txt,a0
	btst.b	d6,(a6)
	beq.s	.space
	lea	star_txt,a0
.space	movem.l	d0-a6,-(a7)
	bsr	print_string
	movem.l	(a7)+,d0-a6
	dbra	d6,.lx
	addq.w	#1,a6
	addq.l	#6,d1
	dbra	d7,.ly

	rts

vector_toggle
	moveq	#2,d0
	tst.b	key_table+$38
	bne.s	.setbit
	moveq	#1,d0
	tst.b	key_table+$2a
	bne.s	.setbit
	tst.b	key_table+$36
	bne.s	.setbit	
	moveq	#0,d0
.setbit	lea	install_bits,a0
	moveq	#22,d1
	bchg	d0,v_toggle_mode
	bne.s	.all_off
.on	bset.b	d0,(a0)+
	dbra	d1,.on
	rts	
.all_off
	bclr.b	d0,(a0)+
	dbra	d1,.all_off
	rts

get_my_key:
	tst.b	key_pressed
	beq.s	get_my_key
	moveq	#0,d0
	move.b	current_key,d0
	clr.b	key_pressed
	rts

convert_my_key
	move.w	d0,d1
	sub.w	#$3b,d1
	bmi.s	.chk2
	cmp.b	#10,d1
	bge.s	.chk2
	rts	
.chk2	move.w	d0,d1
	subq.w	#$2,d1
	bmi.s	.chk3
	cmp.w	#14,d1
	bge.s	.chk3
	add.w	#10,d1	
	rts
.chk3	move.w	d0,d1
	sub.w	#16,d1
	bmi.s	.chk4
	cmp.w	#3,d1
	bge.s	.chk4
	add.w	#20,d1
	rts
.chk4	moveq	#-1,d1
	rts

********************************
* VECTOR INSTALLATION ROUTINES *
********************************

do_installation:
	move.w	sr,-(a7)
	ori.w	#$0700,sr
	bsr	install_normals
	bsr	install_customs
	move.w	(a7)+,sr
	rts

install_normals:
	lea	reinstall_adrs,a0
	lea	install_bits,a1
.loop	move.w	(a0)+,d0		;get vec family num
	bmi	.end			;if minus last
	move.b	check_bit,d1
	btst	d1,(a1,d0.w)		;install/reinstall bit?
	beq	.next			;not set

	move.l	([a0]),d0		;get vector ptr
	beq.s	.install		;if 0, reinstall
	btst	#0,d0			;odd address?
	bne.s	.install		;yes
	cmp.l	4(a0),d0		;my int installed?
	beq.s	.next			;yes
	move.l	d0,([a0,8])		;old ptr is jump
	move.l	4(a0),([a0])		;install my vecor
	add.l	#12,a0			;next ad
	bra.s	.loop			;loop
.install
	move.l	#end_int,([a0,8])	;point to rte
	move.l	4(a0),([a0])		;install my vector
.next	add.l	#12,a0
	bra.s	.loop
.end	rts

install_customs:
	lea	custom_adrs,a0
	lea	install_bits,a1	
.loop	move.w	(a0)+,d0
	bmi	.last
	move.b	check_bit,d1
	btst	d1,(a1,d0.w)
	beq	.next
	pea	(a0)
	jsr	([a0])
	move.l	(a7)+,a0
.next	addq.l	#4,a0
	bra.s	.loop
.last	rts	

reinstall_all:


install_rs232:
	lea	rs232_adrs,a0
	bsr	multi_install
	or.b	#%01011110,$fffffa07.w
	or.b	#%01011110,$fffffa13.w
	or.b	#%111,$fffffa09.w
	or.b	#%111,$fffffa15.w
	rts

install_errors:
	lea	error_adrs,a0
	bra.s	multi_install

install_mmu:
	lea	mmu_adrs,a0
multi_install:

.loop	move.l	(a0),a1			;get vector address
	cmpa.w	#-1,a1			;last?
	beq	.last
	move.l	(a1),d0			;get vector ptr
	beq.s	.install		;if 0, reinstall
	btst	#0,d0			;odd address?
	bne.s	.install		;yes
	cmp.l	4(a0),d0
	beq.s	.next
	move.l	d0,([a0,8])		;old ptr is jump
	move.l	4(a0),(a1)		;install my vecor
	bra.s	.next
.install
	move.l	#end_int,([a0,8])	;point to rte
	move.l	4(a0),(a1)		;install my vector
.next	add.l	#12,a0
	bra.s	.loop

.last	rts



install_timer_a:
	btst	#5,$fffffa07.w
	beq.s	.new_a
	move.l	$134.w,d0		;current timer a
	beq.s	.new_a			;must be non zero!
	cmp.l	#new_timer_a,d0		;my timer installed?
	beq.s	.go_a			;yes
	btst	#0,d0			;odd address?
	bne.s	.new_a			;no, even
	move.l	d0,old_timer_a+2	;old timer a
	move.l	#new_timer_a,$134.w	;my timer a
	bra	.go_a			;set timer a on
.new_a	move.l	#end_timer_a,d0		;sei routine
	btst	#3,$fffffa17.w		;aei/sei
	bne.s	.sei			;sei
	move.l	#end_int,d0		;dummy RTE
.sei	move.l	d0,old_timer_a+2	;end interrupt routine
	move.l	#new_timer_a,$134.w	;install timer a
.go_a	tst.b	$fffffa19.w
	bne.s	.ok_a
	move.b	#7,$fffffa19.w		;Timer A control (delay mode)
	move.b	#246,$fffffa1f.w	;Timer A data
.ok_a	bset	#5,$fffffa07.w		;Interrupt Enable Register A
	bset	#5,$fffffa13.w		;Interrupt Mask Register A
	rts


install_timer_b:
	btst	#0,$fffffa07.w
	beq.s	.new_b
	move.l	$120.w,d0		;current timer b
	beq.s	.new_b			;must be non zero!
	cmp.l	#new_timer_b,d0		;my timer installed?
	beq.s	.go_b			;yes
	btst	#0,d0			;odd address?
	bne.s	.new_b			;no, even
	move.l	d0,old_timer_b+2	;old timer a
	move.l	#new_timer_b,$120.w	;my timer a
	bra	.go_b			;set timer a on
.new_b	move.l	#end_timer_b,d0		;sei routine
	btst	#3,$fffffa17.w		;aei/sei
	bne.s	.sei			;sei
	move.l	#end_int,d0		;dummy RTE
.sei	move.l	d0,old_timer_b+2	;end interrupt routine
	move.l	#new_timer_b,$120.w	;install timer a
.go_b	tst.b	$fffffa1b.w
	bne.s	.ok_B
	move.b	#7,$fffffa1b.w		;Timer A control (delay mode)
	move.b	#246,$fffffa21.w	;Timer A data
.ok_b	bset	#0,$fffffa07.w		;Interrupt Enable Register B
	bset	#0,$fffffa13.w		;Interrupt Mask Register B
	rts

install_timer_c:
	btst	#5,$fffffa09.w
	beq.s	.new_c
	move.l	$114.w,d0		;current timer c
	beq.s	.new_c			;must be non zero!
	cmp.l	#new_timer_c,d0		;my timer installed?
	beq.s	.go_c			;yes
	btst	#0,d0			;odd address?
	bne.s	.new_c			;no, even
	move.l	d0,old_timer_c+2	;old timer a
	move.l	#new_timer_c,$114.w	;my timer a
	bra	.go_c			;set timer a on
.new_c	move.l	#end_timer_c,d0		;sei routine
	btst	#3,$fffffa17.w		;aei/sei
	bne.s	.sei			;sei
	move.l	#end_int,d0		;dummy RTE
.sei	move.l	d0,old_timer_c+2	;end interrupt routine
	move.l	#new_timer_c,$114.w	;install timer a
.go_c	tst.b	$fffffa1d.w		;timer c on?
	bne.s	.ok_c			;yes
	move.b	#7,$fffffa1d.w		;Timer C/D control (delay mode)
	move.b	#246,$fffffa23.w	;Timer C data
.ok_c	bset	#5,$fffffa09.w		;Interrupt Enable Register B
	bset	#5,$fffffa15.w		;Interrupt Mask Register B
	rts


install_timer_d:
	btst	#4,$fffffa09.w
	beq.s	.new_d
	move.l	$110.w,d0		;current timer d
	beq.s	.new_d			;must be non zero!
	cmp.l	#new_timer_d,d0		;my timer installed?
	beq.s	.go_d			;yes
	btst	#0,d0			;odd address?
	bne.s	.new_d			;no, even
	move.l	d0,old_timer_d+2	;old timer a
	move.l	#new_timer_d,$110.w	;my timer a
	bra	.go_d			;set timer a on
.new_d	move.l	#end_timer_d,d0		;sei routine
	btst	#3,$fffffa17.w		;aei/sei
	bne.s	.sei			;sei
	move.l	#end_int,d0		;dummy RTE
.sei	move.l	d0,old_timer_d+2	;end interrupt routine
	move.l	#new_timer_d,$110.w	;install timer a
.go_d	tst.b	$fffffa1d.w		;timer d on?
	bne.s	.ok_d			;yes
	move.b	#7,$fffffa1d.w		;Timer C/D control (delay mode)
.ok_d	move.b	#246,$fffffa25.w	;Timer D data
	bset	#4,$fffffa09.w		;Interrupt Enable Register B
	bset	#4,$fffffa15.w		;Interrupt Mask Register B
	rts

install_ikbd:
	move.l	$118.w,d0
	beq.s	.new_i	
	cmp.l	#new_ikbd,d0
	beq	.go_i
	btst	#0,d0
	bne.s	.new_i
	move.l	d0,old_ikbd+2
	move.l	#new_ikbd,$118.w
	bra.s	.go_i
.new_i	move.l	#end_ikbd,old_ikbd+2
	move.l	#new_ikbd,$118.w
.go_i	bset	#6,$fffffa09.w
	bset	#6,$fffffa15.w	
	rts

install_fdi:
	btst	#7,$fffffa09.w
	beq.s	.new_f
	move.l	$11c.w,d0
	beq.s	.new_f
	cmp.l	#new_fdi,d0
	beq	.go_f
	btst	#0,d0
	bne.s	.new_f
	move.l	d0,old_fdi+2
	move.l	#new_fdi,$11c.w
	bra.s	.go_f
.new_f	move.l	#end_fdi,old_fdi+2
	move.l	#new_fdi,$11c.w
.go_f	bset	#7,$fffffa09.w
	bset	#7,$fffffa15.w	
	rts

install_blitter:
	btst	#3,$fffffa09.w
	beq.s	.new_bl
	move.l	$10c.w,d0
	beq.s	.new_bl
	cmp.l	#new_blitter,d0
	beq	.go_bl
	btst	#0,d0
	bne.s	.new_bl
	move.l	d0,old_blitter+2
	move.l	#new_blitter,$10c.w
	bra.s	.go_bl
.new_bl	move.l	#end_blitter,old_blitter+2
	move.l	#new_blitter,$10c.w
.go_bl	bset	#3,$fffffa09.w
	bset	#3,$fffffa15.w	
	rts


install_mono:
	move.l	#new_mono,$13c.w
	bset	#7,$fffffa07.w
	bset	#7,$fffffa13.w
	rts

install_trace:
	move.l	#check_option,$24.w
	move.w	#$8000,new_sr
	rts

install_reset:
	move.l	#$31415926,$426.w	;magic
	move.l	#new_reset,$42a.w	
	rts

install_alt_help
	move.l	#new_alt_help,$502.w
	rts

install_vbl_queue:
	move.l	$456.w,a0
	move.l	#new_vbl_lister,d0
.gvbl	move.l	(a0)+,d1
	beq.s	.install
	cmp.l	d0,d1
	bne.s	.gvbl	
	rts
.install
	move.l	#new_vbl_lister,-4(a0)
	clr.l	(a0)
	rts


***********************
* NEW VECTOR ROUTINES *
***********************

end_int:	rte


*
** EXCEPTION ERRORS **
*

new_bus_error:	clr.b	current_vec
		move.b	#error_ex,vec_family
		bsr	check_option
old_bus_error	jmp	$12345678

new_address_error:
		move.b	#1,current_vec
		move.b	#error_ex,vec_family
		bsr	check_option
old_address_error
		jmp	$12345678

new_illegal:
		move.b	#2,current_vec
		move.b	#error_ex,vec_family
		bsr	check_option
old_illegal	jmp	$12345678

new_divide0:
		move.b	#3,current_vec
		move.b	#error_ex,vec_family
		bsr	check_option
old_divide0	jmp	$12345678

new_chk:	move.b	#4,current_vec
		move.b	#error_ex,vec_family
		bsr	check_option
old_chk		jmp	$12345678


new_trapv:	move.b	#5,current_vec
		move.b	#error_ex,vec_family
		bsr	check_option
old_trapv	jmp	$12345678


new_priv:	move.b	#6,current_vec
		move.b	#error_ex,vec_family
		bsr	check_option
old_priv	jmp	$12345678

new_coprovi:	move.b	#7,current_vec
		move.b	#error_ex,vec_family
		bsr	check_option
old_coprovi	jmp	$12345678

new_format:	move.b	#8,current_vec
		move.b	#error_ex,vec_family
		bsr	check_option
old_format:	jmp	$12345678

new_uninit:	move.b	#9,current_vec
		move.b	#error_ex,vec_family
		bsr	check_option
old_uninit:	jmp	$12345678

new_spurious:	move.b	#10,current_vec
		move.b	#error_ex,vec_family
		bsr	check_option
old_spurious:	jmp	$12345678


new_trace	move.b	#trace_ex,vec_family
		bsr	check_option
old_trace:	jmp	"RGOD"

*
** MMU ERRORS **
*

new_mmu_config:	clr.b	current_vec
		move.b	#mmu_ex,vec_family
		bsr	check_option
old_mmu_config:	jmp	$12345678

new_mmu_illegal:
		move.b	#1,current_vec
		move.b	#mmu_ex,vec_family
		bsr	check_option
old_mmu_illegal: jmp	$12345678

new_mmu_address:
        	move.b	#2,current_vec
		move.b	#mmu_ex,vec_family
		bsr	check_option
old_mmu_address: jmp	$12345678


*
** RS-232 ERRORS
*

new_rs232_cd:  	clr.b	current_vec
		move.b	#rs232_ex,vec_family
		move.l	#$0001fa11,mfp_sei
		bsr	check_option
old_rs232_cd: 	jmp	$12345678
end_rs232_cd:	bclr.b	#1,$fffffa11.w
		rte

new_rs232_cts: 	move.b	#1,current_vec
		move.b	#rs232_ex,vec_family
		move.l	#$0002fa11,mfp_sei
		bsr	check_option
old_rs232_cts: 	jmp	$12345678
end_rs232_cts:	bclr.b	#2,$fffffa11.w
		rte

new_rs232_te: 	move.b	#2,current_vec
		move.b	#rs232_ex,vec_family
		move.l	#$0001fa0f,mfp_sei
		bsr	check_option
old_rs232_te: 	jmp	$12345678
end_rs232_te:	bclr.b	#1,$fffffa0f.w
		rte


new_rs232_tbe: 	move.b	#3,current_vec
		move.b	#rs232_ex,vec_family
		move.l	#$0002fa0f,mfp_sei
		bsr	check_option
old_rs232_tbe: 	jmp	$12345678
end_rs232_tbe:	bclr.b	#2,$fffffa0f.w
		rte


new_rs232_re: 	move.b	#4,current_vec
		move.b	#rs232_ex,vec_family
		move.l	#$0003fa0f,mfp_sei
		bsr	check_option
old_rs232_re: 	jmp	$12345678
end_rs232_re:	bclr.b	#3,$fffffa0f.w
		rte

new_rs232_rbf: 	move.b	#5,current_vec
		move.b	#rs232_ex,vec_family
		move.l	#$0004fa0f,mfp_sei
		bsr	check_option
old_rs232_rbf: 	jmp	$12345678
end_rs232_rbf:	bclr.b	#4,$fffffa0f.w
		rte


new_rs232_ring:	move.b	#6,current_vec
		move.b	#rs232_ex,vec_family
		move.l	#$0006fa0f,mfp_sei
		bsr	check_option
old_rs232_ring	jmp	$12345678
end_rs232_ring	bclr.b	#6,$ffffffa0f.w
		rte

new_rs232_cb:  	move.b	#7,current_vec
		move.b	#rs232_ex,vec_family
		move.l	#$0000fa11,mfp_sei
		bsr	check_option
old_rs232_cb: 	jmp	$12345678
end_rs232_cb:	bclr.b	#0,$fffffa11.w
		rte

*
*** TRAP EXCEPTIONS
*

new_trap_1:	move.b	#trap_1_ex,vec_family
		bsr	check_option
old_trap_1:	jmp	$12345678

new_trap_2:	move.b	#trap_2_ex,vec_family
		bsr	check_option
old_trap_2:	jmp	$12345678

new_trap_13:	move.b	#trap_13_ex,vec_family
		bsr	check_option
old_trap_13:	jmp	$12345678

new_trap_14:	move.b	#trap_14_ex,vec_family
		bsr	check_option
old_trap_14:	jmp	$12345678

new_line_a	move.b	#line_a_ex,vec_family
		bsr	check_option
old_line_a	jmp	$12345678

new_line_f	move.b	#line_f_ex,vec_family
		bsr	check_option
old_line_f	jmp	$12345678

*
** TIMER EXCEPTIONS
*

new_timer_a	move.b	#timer_a_ex,vec_family
		move.l	#$0005fa0f,mfp_sei
		bsr	check_option
old_timer_a	jmp	$12345678
end_timer_a	bclr.b	#5,$fffffa0f.w
		rte

new_timer_b	move.b	#timer_b_ex,vec_family
		move.l	#$0000fa0f,mfp_sei
		bsr	check_option
old_timer_b	jmp	$12345678
end_timer_b	bclr.b	#0,$fffffa0f.w
		rte


new_timer_c:	move.b	#timer_c_ex,vec_family
		move.l	#$0005fa11,mfp_sei
		bsr	check_option
old_timer_c	jmp	$12345678
end_timer_c	bclr.b	#5,$fffffa11.w
		rte

new_timer_d	move.b	#timer_d_ex,vec_family
		move.l	#$0004fa11,mfp_sei
		bsr	check_option
old_timer_d	jmp	$12345678
end_timer_d	bclr.b	#4,$fffffa11.w
		rte

*
** MFP EXCEPTIONS
*

new_ikbd	move.b	#ikbd_ex,vec_family
		move.l	#$0006fa11,mfp_sei
		bsr	check_option
old_ikbd	jmp	$12345678
end_ikbd	bclr.b	#6,$fffffa11.w
		rte

new_fdi		move.b	#fdi_ex,vec_family
		move.l	#$0007fa11,mfp_sei
		bsr	check_option
old_fdi		jmp	$12345678
end_fdi		bclr.b	#7,$fffffa11.w
		rte
new_blitter:	move.b	#blitter_ex,vec_family
		move.l	#$0003fa11,mfp_sei
		bsr	check_option
old_blitter:	jmp	$12345678
end_blitter	bclr.b	#3,$fffffa11.w
		rte

new_mono	move.b	#mono_ex,vec_family
		move.l	#$0007fa0f,mfp_sei
		bsr	check_option
		rte

*
** VBL INTERRUPTS
*

new_vbl:	move.b	#vbl_ex,vec_family
		bsr	check_option
old_vbl:	jmp	$12345678


new_vbl_lister	move.b	#vbl_q_ex,vec_family
		bsr	check_option
.no_rip		rts

new_hbl:	move.b	#hbl_ex,vec_family
		bsr	check_option
old_hbl:	jmp	$12345678


new_reset:	move.b	#reset_ex,vec_family
		clr.l	$42a.w
		clr.l	$426.w
		bsr	init_ripper
		move.w	#$2700,sr
		jmp	([$4.w])
	
new_alt_help	move.b	#alt_help_ex,vec_family
		bsr	check_option
		rts
	

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
	movem.l	d0-a6,-(a7)
	moveq	#0,d0
	move.b	vec_family,d0
	btst	#2,(install_bits,d0.w)
	beq.s	.no_restore
	bsr	do_installation
.no_restore
	lea	$ffff9200.w,a0	;extended port address (read only)
	move.w	#$fff7,2(a0)	;write mask
	move.w	(a0),d0		;read fire data
	btst	#1,d0		;check for option
	bne.s	no_option	;if set, option is not pressed
	bsr	init_ripper
no_option:
	clr.l	mfp_sei
;	tst.b	install_bits+(trace_ex)
;	beq.s	.mvm
;	cmp.b	#vbl_q_ex,vec_family
;	bne.s	.nv
;	move.w	sr,d0
;	or.w	new_sr,d0	
;	move.w	d0,sr
;	bra.s	.mvm
;.nv	move.w	new_sr,d0
;	or.w	d0,16*4(a7)
.mvm	movem.l	(a7)+,d0-a6
	rts


 *------------------------*
** GEMDOS Disk Operations **
 *------------------------*

* A0->filename, A1->address, D1=length


save_file:	tst.b	god_mode
		bne	save_god_file
		lea	file_name(pc),a0
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
.no_pal
save_true	move.l	pic_adr,a0
		move.l	pic_length,d7
		bsr	write_file
		bmi	display_gemdos_error
		bsr	close_file
		rts

save_god_file:	lea	file_name(pc),a0
		bsr	create_file
		bmi	display_gemdos_error
		lea	god_head,a0
		move.w	#'G4',(a0)
		move.w	pic_x,2(a0)
		move.w	pic_y,4(a0)
		moveq	#6,d7
		bsr	write_file
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




* a0=source, a1=dest, a2=colour table

convert_god_line:
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

		move.l	a0,cur_pic_adr

;		move.l	line_length,d7		;line size in words	
;		add.l	d7,cur_pic_adr		;update ptr

.error		rts	


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
	IFNE	new_bss_ikbd
	cmp.b	#$3a,d0
	bne.s	.not_caps
	eor.b	#1,caps_lock
.not_caps
	ENDC
		bra.s	last_key_check		;get key data
setkey		st.b	(a1,d0.w)		;set key pressed
		st.b	key_pressed
		move.b	d0,current_key
	IFNE	new_bss_ikbd
	move.b	d0,bss_key
	ENDC

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
	IFNE	new_bss_ikbd
	cmp.b	#$3a,d0
	bne.s	.not_caps
	eor.b	#1,caps_lock
.not_caps
	ENDC
		rts                             ;return
.setkey		st.b	(key_table,d0.w)	;clear key
		st.b	key_pressed
		move.b	d0,current_key
	IFNE	new_bss_ikbd
	move.b	d0,bss_key
	ENDC
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

		IFNE	new_bss_ikbd

	dc.l	'XBRA'
	dc.l	'BS13'
bss_trap_13:
	move.l	a7,a0			;sp
	move.w	(a0),d0			;get sr
	btst	#13,d0			;super mode?
	beq.s	.user_mode		;no user
	addq.l	#8,a0			;get to parameters
	bra.s	.cont			;continue
.user_mode	
	move.l	USP,a0			;user stack ptr
.cont	cmp.w	#$b,(a0)		;my kbshift
	beq	my_kbshift		;yes
old_bss_trap_13
	jmp	"RGOD"
		
my_kbshift:	move.w	2(a0),d0
		bpl	set_kbshift
		bsr	get_kbshift
		rte
		
get_kbshift		
.read		tst.b	key_table+$36	;right_shift
		beq.s	.nors
		bset	#0,d0
.nors		tst.b	key_table+$2a	;right_shift
		beq.s	.nols
		bset	#1,d0
.nols		tst.b	key_table+$1d
		beq.s	.no_ctl
		bset	#2,d0
.no_ctl		tst.b	key_table+$38	;right_shift
		beq.s	.noalt
		bset	#3,d0
		tst.b	key_table+$47
		beq.s	.no_clr
		bset	#5,d0
.no_clr		tst.b	key_table+$52	
		beq.s	.no_ins
		bset	#6,d0
.no_ins		
.noalt		tst.b	caps_lock	;right_shift
		beq.s	.nocaps
		bset	#4,d0
.nocaps		rts

set_kbshift	lsr.b	d0
		bcc.s	.no_rs
		st.b	key_table+$36
.no_rs		lsr.b	d0
		bcc.s	.no_ls
		st.b	key_table+$2a
.no_ls		lsr.b	d0
		bcc.s	.no_ctl
		st.b	key_table+$1d
.no_ctl		lsr.b	d0
		bcc.s	.no_alt
		st.b	key_table+$38
.no_alt		lsr.b	d0
		bcc.s	.no_caps
		st.b	caps_lock
.no_caps	lsr.b	d0
		bcc.s	.no_clr
		st.b	key_table+$47
		st.b	key_table+$38
.no_clr		lsr.b	d0
		bcc.s	.no_ins
		st.b	key_table+$52
		st.b	key_table+$38
.no_ins		rte

bss_shift_scan_code_table:
*                0123456789ABCDEF
	dc.b	'!"œ$%^&*()_+'
	dc.b	'QWERTYUIOP{}AS'
	dc.b	'DFGHJKL:@ÿ~ZXCV'
	dc.b	'BNM<>? '
	dc.b	'-+'	
	dc.b	''
	dc.b	'|()/*789456123'
	dc.b	'0.'
	even

bss_scan_code_table:
*                0123456789ABCDEF
	dc.b	'1234567890-='
	dc.b	'qwertyuiop[]as'
	dc.b	"dfghjkl;'`#zxcv"
	dc.b	'bnm,./ '
	dc.b	'-+'	
	dc.b	''
	dc.b	'\()/*789456123'
	dc.b	'0.'
	even

	
caps_lock	ds.b	1
bss_key		ds.b	1
		even

	dc.l	'XBRA'
	dc.l	'BSS1'
bss_trap_1:
	move.l	a7,a0			;sp
	move.w	(a0),d0			;get sr
	btst	#13,d0			;super mode?
	beq.s	.user_mode		;no user
	addq.l	#8,a0			;get to parameters
	bra.s	.cont			;continue
.user_mode	
	move.l	USP,a0			;user stack ptr
.cont	cmp.w	#$6,(a0)		;my kbshift
	bne	bss_trap_1		;yes
	cmp.w	#$ff,2(a0)
	beq	my_crawio
old_bss_trap_1
	jmp	"RGOD"

my_crawio
	moveq	#0,d0
	tst.b	bss_key
	beq	end_crawio
	bsr	get_kbshift
	lea	bss_scan_code_table,a0
	bftst	d0{30:2}
	beq.s	.non_shift
	lea	bss_shift_scan_code_table,a0
.non_shift
	lsl.w	#8,d0
	moveq	#0,d1
	move.b	bss_key,d1
	move.b	d1,d0
	swap	d0
	move.b	(a0,d1.w),d1
	cmp.b	#'',d1
	bne.s	.non_ascii
	move.b	d1,d0
.non_ascii
	clr.b	bss_key
end_crawio
	rte

	ENDC

temp_vbl:	addq.l	#1,$466.w
		rte
		
***************************************************************************
	DATA
***************************************************************************

tiny_font	incbin	g:\ripper\tinyfnt.bin
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
	dc.w	line_a_ex
	dc.l	$28,new_line_a,old_line_a+2
	dc.w	line_f_ex
	dc.l	$2c,new_line_f,old_line_f+2
	dc.w	trap_1_ex
	dc.l	$84,new_trap_1,old_trap_1+2
	dc.w	trap_2_ex
	dc.l	$88,new_trap_2,old_trap_2+2
	dc.w	trap_13_ex
	dc.l	$b4,new_trap_13,old_trap_13+2
	dc.w	trap_14_ex
	dc.l	$b8,new_trap_14,old_trap_14+2
	dc.w	hbl_ex
	dc.l	$68,new_hbl,old_hbl+2
	dc.w	vbl_ex
	dc.l	$70,new_vbl,old_vbl+2
	dc.w	trace_ex
	dc.l	$24,new_trace,old_trace+2
	dc.w	-1


custom_adrs
	dc.w	timer_a_ex
	dc.l	install_timer_a
	dc.w	timer_b_ex
	dc.l	install_timer_b
	dc.w	timer_c_ex
	dc.l	install_timer_c
	dc.w	timer_d_ex
	dc.l	install_timer_d
	dc.w	ikbd_ex
	dc.l	install_ikbd
	dc.w	blitter_ex
	dc.l	install_blitter
	dc.w	fdi_ex
	dc.l	install_fdi
	dc.w	reset_ex
	dc.l	install_reset
	dc.w	vbl_q_ex
	dc.l	install_vbl_queue
	dc.w	alt_help_ex
	dc.l	install_alt_help
	dc.w	mono_ex
	dc.l	install_mono
	dc.w	error_ex
	dc.l	install_errors
	dc.w	rs232_ex
	dc.l	install_rs232
	dc.w	mmu_ex
	dc.l	install_mmu
;	dc.w	trace_ex
;	dc.l	install_trace
	dc.w	-1

error_adrs:
	dc.l	$8,new_bus_error,old_bus_error+2
	dc.l	$c,new_address_error,old_address_error+2
	dc.l	$10,new_illegal,old_illegal+2
	dc.l	$14,new_divide0,old_divide0+2
	dc.l	$18,new_chk,old_chk+2
	dc.l	$1c,new_trapv,old_trapv+2
	dc.l	$20,new_priv,old_priv+2
	dc.l	$34,new_coprovi,old_coprovi+2
	dc.l	$38,new_format,old_format+2
	dc.l	$3c,new_uninit,old_uninit+2
	dc.l	$60,new_spurious,old_spurious+2
	dc.l	-1

rs232_adrs:
	dc.l	$100,new_rs232_cb,old_rs232_cb+2
	dc.l	$104,new_rs232_cd,old_rs232_cd+2
	dc.l	$108,new_rs232_cts,old_rs232_cts+2
	dc.l	$124,new_rs232_te,old_rs232_te+2
	dc.l	$128,new_rs232_tbe,old_rs232_tbe+2
	dc.l	$12c,new_rs232_re,old_rs232_re+2
	dc.l	$130,new_rs232_rbf,old_rs232_rbf+2
	dc.l	$138,new_rs232_ring,old_rs232_ring+2
	dc.l	-1

mmu_adrs:
	dc.l	$e0,new_mmu_config,old_mmu_config+2
	dc.l	$e4,new_mmu_illegal,old_mmu_illegal+2
	dc.l	$e8,new_mmu_address,old_mmu_address+2
	dc.l	-1



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
	dc.b	"[F2]  VECTOR MENU",13
	dc.b	"[F3]  SAVE SCREEN (RIP)",13
	dc.b	"[F4]  SAVE SCREEN (GOD)",13,13
	dc.b	"[F10] EXIT RIPPER",13
	dc.b	0

variables_txt:

*                0         1         2         3         4         5         6         7         8
*                 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
	dc.b	"COLS:               X:        Y:",13
	dc.b	"STWIDTH:      FALWIDTH:      ST-SHIFT:      SP-SHIFT:      HSCROLL:      SYNC:",13
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

intro_txt
	dc.b	27,"E"
*                123456789 123456789 12346789 123456789
	dc.b	"           RESERVOIR RIPPER",13,10
	dc.b	"           ----------------",13,10,13,10
	dc.b	"           CODED BY MR PINK",13,10,13,10
	dc.b	"       (C) 1995 RESERVOIR GODS"
	dc.b	0
	even

vecs_x	dc.l	34*6,52*6,69*6


vector_menu_txt:
*                         1         2         3         4         5        6
*                123456789 123456789 123456789 123456789 123456789 123*5789 123456789
	dc.b	"                                         VECTOR INSTALLATION MENU",13
	dc.b	"                                         ------------------------",13,13,13
	dc.b    "KEY  VECTOR                   INSTALL          REINSTALL          RESTORE",13
	dc.b	"---  ------                   -------          -[SHIFT]-          -[ALT]-",13,13
	DC.B	"F1   TIMER A",13
	DC.B	"F2   TIMER B",13
	DC.B	"F3   TIMER C",13
	DC.B	"F4   TIMER D",13
	DC.B	"F5   VBL",13
	DC.B	"F6   VBL QUEUE",13
	DC.B	"F7   TRAP #1",13
	DC.B	"F8   TRAP #2",13
	DC.B	"F9   TRAP #13",13
	DC.B	"F10  TRAP #14",13
	DC.B	"1    IKBD",13
	DC.B	"2    BLiTTER DONE",13
	DC.B	"3    LINE A",13
	DC.B	"4    LINE F",13
	DC.B	"5    HBL",13
	DC.B	"6    ERROR EXEPTIONS",13
	DC.B	"7    RS-232 INTERRUPTS",13
	DC.B	"8    MONO MONITOR DETECT",13
	DC.B	"9    MMU VECTORS",13
	DC.B	"0    TRACE EXCEPTION",13
	DC.B	"Q    ALT HELP",13
	DC.B	"W    FLOPPY/HD INTERRUPT",13
	DC.B	"E    RESET",13,13
*                         1         2         3         4         5        6
*                123456789 123456789 123456789 123456789 123456789 123*5789 123456789 123456789
	dc.b	"         [#] TOGGLE ALL                [SPACE] EXIT MENU            [ESC] CANCEL"
	dc.b	0

space_txt	dc.b	' ',0
star_txt	dc.b	'*',0

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


v0_txt	dc.b	"TIMER A",0
v1_txt	dc.b	"TIMER B",0
v2_txt	dc.b	"TIMER C",0
v3_txt	dc.b	"TIMER D",0
v4_txt	dc.b	"VBL",0
v5_txt	dc.b	"VBL QUEUE",0
v6_txt	dc.b	"TRAP #1",0
v7_txt	dc.b	"TRAP #2",0
v8_txt	dc.b	"TRAP #13",0
v9_txt	dc.b	"TRAP #14",0
v10_txt	dc.b	"IKBD",0
v11_txt	dc.b	"BLITTER",0
v12_txt	dc.b	"LINE A",0
v13_txt	dc.b	"LINE F",0
v14_txt	dc.b	"HBL",0
v15_txt	dc.b	"ERROR",0
v16_txt	dc.b	"RS232",0
v17_txt	dc.b	"MONO",0
v18_txt	dc.b	"MMU",0
v19_txt	dc.b	"TRACE",0
v20_txt	dc.b	"ALT_HELP",0
v21_txt	dc.b	"FDI",0
v22_txt	dc.b	"RESET",0

entry_txt	dc.b	"ENTERED VIA:",0
	even

v_txt_adrs:
	dc.l	v0_txt
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
	dc.l	v14_txt
	dc.l	v15_txt
	dc.l	v16_txt
	dc.l	v17_txt
	dc.l	v18_txt
	dc.l	v19_txt
	dc.l	v20_txt
	dc.l	v21_txt
	dc.l	v22_txt

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

new_adrs:
	dc.w	error_ex,$8
	dc.l	new_bus_error

	dc.w	line_a_ex,$28
	dc.l	new_line_a

	dc.w	line_f_ex,$2c
	dc.l	new_line_f

	dc.w	hbl_ex,$68
	dc.l	new_hbl

	dc.w	vbl_ex,$70
	dc.l	new_vbl

	dc.w	trap_1_ex,$84
	dc.l	new_trap_1

	dc.w	trap_2_ex,$88
	dc.l	new_trap_2

	dc.w	trap_13_ex,$b4
	dc.l	new_trap_13

	dc.w	trap_14_ex,$b8
	dc.l	new_trap_14

	dc.w	mmu_ex,$e0
	dc.l	new_mmu_config
	
	dc.w	rs232_ex,$100
	dc.l	new_rs232_cb

	dc.w	blitter_ex,$10c
	dc.l	new_blitter
	
	dc.w	timer_d_ex,$110
	dc.l	new_timer_d

	dc.w	timer_c_ex,$114
	dc.l	new_timer_c

	dc.w	ikbd_ex,$118
	dc.l	new_ikbd

	dc.w	fdi_ex,$11c
	dc.l	new_fdi

	dc.w	timer_b_ex,$120
	dc.l	new_timer_b

	dc.w	timer_a_ex,$134
	dc.l	new_timer_a

	dc.w	mono_ex,$13c
	dc.l	new_mono

	dc.w	alt_help_ex,$502
	dc.l	new_alt_help
	
	dc.w	reset_ex,$42a
	dc.l	new_reset

	dc.w	trace_ex,$24
	dc.l	new_trace

	dc.w	-1

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

god_head	ds.b	6

pic_adr		ds.l	1
magic		ds.l	1
pic_res		ds.w	1
pic_x		ds.w	1
pic_y		ds.w	1
line_length	ds.l	1

physic		ds.l	1
old118		ds.l	1
mfp_sei		ds.l	1

pic_length	ds.l	1
file_handle	ds.w	1
text_counter	ds.w	1
old_vmode:	ds.w	1

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

colour_table	ds.w	256
install_bits	ds.b	24
		ds.b	1024
rip_stack	ds.l	4
		ds.b	256
screen_space	ds.b	16000
end_ripper