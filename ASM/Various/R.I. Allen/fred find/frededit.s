empty		equ	0
rleft		equ	1
rright		equ	2
ruleft		equ	3
ruright		equ	4
key		equ	5
safe		equ	6
diamond		equ	7
rock		equ	8
plunger		equ	9
bomb		equ	10
exit		equ	11
egg		equ	12
trans		equ	13
fred		equ	14
earth		equ	15
weed		equ	16
capsule		equ	17
skull		equ	18
solid1		equ	19
solid2		equ	20
solid3		equ	21
solid4		equ	22
solid5		equ	23
cage		equ	24
spirit1		equ	25
spirit2		equ	26
spirit3		equ	27
cracked		equ	28
monster1	equ	29
monster2	equ	30
monster3	equ	31
lookleft	equ	32
lookright	equ	33
up_down1	equ	34
up_down2	equ	35
up_down3	equ	36
up_down4	equ	37
left1		equ	38
left2		equ	39
left3		equ	40
left4		equ	41
left5		equ	42
left6		equ	43
right1		equ	44
right2		equ	45
right3		equ	46
right4		equ	47
right5		equ	48
right6		equ	49
cursor		equ	50
fred2		equ	51
cage2		equ	52

delete_key	equ	8
enter_key	equ	13
escape_key	equ	27
num_errs	equ	9
zkey		equ	$2c
xkey		equ	$2d
fslash		equ	$35
quote		equ	$28
space		equ	$39
colours		equ	$ff8240
acia_con	equ	$fffc00
acia_dat	equ	$fffc02

		pea	0
		move.w	#$20,-(sp)		; supervisor mode
		trap	#1
		lea	6(sp),sp
		move.l	d0,old_ssp		; save old stack pointer
		lea	end_stack,a7		; point to my stack

		move.l	#screens+256,d0		; screen start
		and.l	#$ffffff00,d0		; 256 byte boundary
		move.l	d0,scr1			; screen start
		add.l	#38400,d0		; next screen start
		move.l	d0,scr2
			
		move.w	#3,-(sp)		; physbase call
		trap	#14
		lea	2(sp),sp
		move.l	d0,old_scr		; save old screen start
			
		move.w	#4,-(sp)		; get res call
		trap	#14
		lea	2(sp),sp
		move.w	d0,old_res		; save old screen resolution
			
		move.l	$4ba,ran_num		; init random number seed

		dc.w	$a00a			; turn old mouse off

		move.w	#0,-(sp)		; low res screen
		move.l	scr2,-(sp)
		move.l	scr2,-(sp)		; screen start address
		move.w	#5,-(sp)		; set res & screen start
		trap	#14
		lea	12(sp),sp

		move.w	#37,-(sp)		; wait a vbl
		trap	#14
		lea	2(sp),sp

		move.l	$456,a0			; vbl que pointer
		move.w	#7,d7			; 8 entries to check
myvbl		tst.l	(a0)			; install here ?
		beq.s	myvbl000		; skip if we can
		lea	4(a0),a0		; next table entry
		dbra	d7,myvbl		; find an empty entry
myvbl000	move.l	a0,overwrite		; area to clear on exit
		move.l	#vsync,(a0)		; install my routine

		move	#$2700,sr		; disable interupts
		move.b	$fffffa07.w,enablea	; save old status
		move.b	$fffffa09.w,enableb
		move.b	$fffffa13.w,maska
		move.b	$fffffa15.w,maskb
		move.l	$120,old_hsync		; old hsync vector
		or.b	#1,$fffffa13.w		; ebanble timer a 
		move.l	$118,old_key
		move.b	#64,$fffffa09.w		*init interrupts
		move.b	#64,$fffffa15.w
		move.l	#keyvec,$118
		move	#$2300,sr		; interupts on

		movem.l	colours,d0-d7
		movem.l	d0-d7,old_pal		; save old pallette
		movem.l	d0-d7,color_buff	; save old pallette
		jsr	create_fade
		jsr	fade_out

		jsr	init_load		; initialise disk stuff

		movem.l	char_cols,d0-d7
		movem.l	d0-d7,color_buff	; install new pallette
		jsr	create_fade
			
		lea	maps,a0			; map data
		lea	672(a0),a0		; transporter data
		move.w	#7,d7			; 8 maps to setup
map_setup	move.l	#$ffffffff,(a0)
		move.l	#$ffffffff,4(a0)
		move.l	#$ffffffff,8(a0)
		move.l	#$ffffffff,12(a0)
		lea	688(a0),a0		; next transporter data
		dbra	d7,map_setup
			
		jsr	main			; main routine

		move.l	overwrite,a0		; vblque point used
		clr.l	(a0)			; de-install vsync routine
		move	#$2700,sr		; interupts off
		move.b	enablea,$fffffa07.w	; restore setup
		move.b	enableb,$fffffa09.w
		move.b	maska,$fffffa13.w
		move.b	maskb,$fffffa15.w
		move.l	old_key,$118
		move	#$2300,sr

		movem.l	old_pal,d0-d7
		movem.l	d0-d7,color_buff
		jsr	create_fade

		move.w	old_res,-(sp)		; restore resolution
		move.l	old_scr,-(sp)
		move.l	old_scr,-(sp)		; screen start address
		move.w	#5,-(sp)		; set res & screen start
		trap	#14
		lea	12(sp),sp
		jsr	fade_in2

		dc.w	$a009			; turn old mouse on

		movem.l	old_pal,d0-d7
		movem.l	d0-d7,colours
			
		move.l	old_ssp,-(sp)		; back to user mode
		move.w	#$20,-(sp)
		trap	#1
		lea	6(sp),sp

		clr.w	-(sp)
		move.w	#$4c,-(sp)
		trap	#1			; end program


************************************************
* VSync Routine                                *
* Called by the operating system VBL scheduler *
************************************************
vsync		move.l	#hsync,$120.w		; hsync vector address
		move.b	#0,$fffffa1b.w		; timer b off
		move.b	#195,$fffffa21.w	; inturupt on line 198
		move.b	#8,$fffffa1b.w		; timer b on
		bset	#0,$fffffa07.w		; clear interupt flag
		move.w	#1,vsync_tr		; signal vsync int
		rts								; return

***************************************
* HSync routine                       *
* Used to knock out the bottom border *
***************************************
hsync		move	#$2700,sr		; interupts off
		movem.l	d0-d1/a0,-(sp)
		lea	$ff8207,a0
		move.b	$ff8203,d0
		add.w	#124,d0
		move.w	#55,d1
.lp1		subq.w	#1,d1
		beq.s	lp_quit
		cmp.b	(a0),d0
		bne.s	.lp1
lp_quit		lea	2(a0),a0
.lp2		tst.b	(a0)
		bne.s	.lp2
		move.b	(a0),d0
		lsr.w	d0,d0
		dcb.w	7,$4e71			; 7 nops
		clr.b	$ffff820a.w
		dcb.w	10,$4e71
		move.b	#2,$ffff820a.w
		movem.l	(sp)+,d0-d1/a0
		bclr	#0,$fffffa0f.w		; clear int service flag
		bclr	#0,$fffffa07.w		; disable timer a ints
		addq.w	#1,vsync_tr
		rte

**************************************************
* A version of Motleys keyboard interupt routine *
* Modified by Zaborak for his own needs          *
**************************************************
keyvec		movem.l	d0/d1/a0,-(sp)		; save registers used
re_check	lea	acia_con,a0		; point to keyboad acia
		move.b	(a0),d0			; get the control status
		move.b	d0,acia_stat		; save a copy of it
		btst	#7,d0			; interupt enabled ?
		beq	key_exit		; exit if not
		btst	#0,d0			; correct mode ?
		beq	key_exit		; exit if not
		move.b	2(a0),d1		; get the pending character
		tst.b	activity		; assembling a packet ?
		bmi.s	new_code		; skip if were not
		move.l	act_pntr,a0		; points to packet build-up
		move.b	d1,(a0)+		; add to the packet
		subq.b	#1,activity		; count the byte loaded
		bpl.s	more_data		; skip if packet in-complete
		move.l	a1,-(sp)		; save another register
		move.l	pkt_dest,a0		; where to put the data
		lea	build_pkt,a1		; the one we have just made
		clr.w	d0			; for loop
		move.b	build_len,d0		; number of bytes in packet
copy_pkt	move.b	(a1)+,(a0)+		; copy a byte at a time
		dbra	d0,copy_pkt		; copy out completed packet
		move.l	pkt_dest,a0		; was it a mouse packet ?
		cmp.l	#mouse_pkt,a0		; mouse packet ?
		bne.s	cp0000			; skip if not
		jsr	my_mouse
cp0000		move.l	(sp)+,a1		; recover reg
		lea	build_pkt,a0		; reset build pointer
more_data	move.l	a0,act_pntr		; save the new pointer
		bra	key_exit		; exit, all done
new_code	cmp.b	#$f6,d1			; key scan code ?
		blo	key_code		; skip if it is
		lea	build_pkt,a0		; store code
		move.b	d1,(a0)+		; save the character
		move.l	a0,act_pntr		; save the packet pointer
		and.w	#$0f,d1			; to workout packet length
		subq.w	#6,d1			; normalise
		move.b	acia_len(pc,d1.w),d0	; get the packet length
		move.b	d0,build_len		; save the build length
		subq.w	#1,d0			; count the first character
		move.b	d0,activity		; save for packet build-up
		lsl.w	#2,d1			; for long word offset
		move.l	acia_len+10(pc,d1),pkt_dest	; where to put finished packet
		bra	key_exit		; all done
acia_len	dc.b	7,5,2,2,2,2,6,2,1,1	; codes $f6 - $ff
		dc.l	misc_pkt
		dc.l	misc_pkt
		dc.l	mouse_pkt
		dc.l	mouse_pkt
		dc.l	mouse_pkt
		dc.l	mouse_pkt
		dc.l	misc_pkt
		dc.l	misc_pkt
		dc.l	stick0_pkt
		dc.l	stick1_pkt
key_code	cmp.b	#$80,d1			; pressed or released a key ?
		blo.s	pressed
released	lea	keys,a0			; key table data
		and.w	#$007f,d1		; limit range
		clr.b	(a0,d1.w)
		bra.s	key_exit		; all done
pressed		lea	keys,a0			; key table data
		and.w	#$00ff,d1		; limit range
		move.b	#1,(a0,d1.w)
		lea	letters,a0		; convert to asci
		move.b	(a0,d1.w),key_press	; save in buffer
key_exit	and.b	#$20,acia_stat		; ACIA error ?
		beq.s	no_error		; skip if not
		move.b	acia_dat,d0		; clear ACIA error
no_error	btst	#4,$fffffa01.w		; all finished ?
		beq	re_check		; loop if not
		bclr	#6,$fffffa11.w		; clear the int pending flag
		movem.l	(sp)+,d0/d1/a0		; recover registers
		rte

my_mouse	lea	mouse_pkt,a0		; mouse packet
		lea 	mouse_x,a1		; point to mouse data
		clr.w	d0				
		move.b	1(a0),d0		; get x offset
		ext.w	d0			; sign extend to 16 bits
		add.w	d0,(a1)+		; add on offset
		bpl.s	mm000			; skip if data valid
		move.w	#0,-2(a1)		; limit range
mm000		move.w	x_max,d0
		cmp.w	-2(a1),d0		; in x upper range ?
		bge.s	mm010			; skip if ok
		move.w	d0,-2(a1)		; limit range
mm010		clr.w	d0
		move.b	2(a0),d0		; get y offset
		ext.w	d0			; sign extend to 16 bits
		add.w	d0,(a1)+		; add on offset
		bpl.s	mm020			; skip if data valid
		move.w	#0,-2(a1)		; else limit range
mm020		move.w	y_max,d0
		cmp.w	-2(a1),d0		; in upper y range ?
		bge.s	mm030			; skip if ok
		move.w	d0,-2(a1)		; else limit range
mm030		move.b	(a0),d0			; get button status
		move.b	d0,(a1)			; button status byte
		move.w	-2(a1),d1
		cmp.w	y_min,d1		; min y value
		bge.s	plm_ok			; skip if ok
		move.w	y_min,-2(a1)		; set min value
plm_ok		rts				


***************************************
* The new vbl routine to be called    *
***************************************
vsync_wait	jsr	plot_mouse
vw		cmp.w	#2,vsync_tr
		bne.s	vw
		movem.l	scr1,d0-d1		; get screen pointers
		exg.l	d0,d1			; swap them
		movem.l	d0-d1,scr1		; save new orientation
		lsr.l	#8,d1
		move.b	d1,$ff8203		; set screen address
		lsr.w	#8,d1
		move.b	d1,$ff8201		; change screen
		clr.w	vsync_tr
vw000		tst.w	vsync_tr		; had a vsync ?
		beq.s	vw000			; loop if not
		jsr	erase_mouse
		addq.l	#1,v_count		; count a vbl
		rts


*************************************
* Routine plots the mouse on screen *
* After saving the background in a  *
* buffer first.                     *
*************************************
plot_mouse	move.l	scr1,a0			; display acreen
		lea	buffer1,a1		; background buffer
		tst.w	screen			; selected correct buffer ?
		beq.s	plo0000			; skip if we have
		lea	buffer2,a1		; point to the oter buffer
plo0000		move.l	old_x,older_x		; buffer the last screen pos
		movem.w	mouse_x,d0-d1		; current mouse position
		movem.w	d0-d1,old_x
		mulu.w	#160,d1			; y offset to screen
		move.w	d0,d6			; copy x position
		and.w	#$fff0,d0		; multiples of 16
		lsr.w	#1,d0			; x offset
		add.w	d0,d1			; total offset
		add.l	d1,a0			; display screen pointer
		move.w	#7,d7			; 8 lines to copy to buffer
plo0010		movem.l	(a0),d0-d3		; 16 pixel of data
		movem.l	d0-d3,(a1)		; store in the buffer
		lea	160(a0),a0		; next screen line down
		lea	16(a1),a1		; move buffer pointer on
		dbra	d7,plo0010		; buffer all 8 lines
		tst.w	edit_flag		; poitning into e-character ?
		bne	plo0030			; skip if we are
		lea	-1280(a0),a0		; restore screen pointer
		lea	mouse_ch,a1		; mouse graphic data
		and.w	#$000f,d6		; pixel offset
		lsl.w	#5,d6			; offset into graphics
		add.w	d6,a1			; correct graphics
		move.w	#7,d7			; 8 lines to plot
plo0020		movem.w	(a1),d0-d1		; get a line
		or.w	d0,(a0)			; plot 1st 16 bits
		or.w	d0,2(a0)		
		or.w	d0,4(a0)		
		or.w	d0,6(a0)		
		or.w	d1,8(a0)		; plot 2nd 16 bits
		or.w	d1,10(a0)		
		or.w	d1,12(a0)		
		or.w	d1,14(a0)		
		lea	160(a0),a0
		lea	4(a1),a1
		dbra	d7,plo0020		; do all 8 lines
plo0030		not.w	screen
		rts

********************************************
* Erases the mouse from the current screen *
* using the data put in the buffer         *
********************************************
erase_mouse	move.l	scr1,a0			; display acreen
		lea	buffer1,a1		; background buffer
		tst.w	screen			; selected correct buffer ?
		beq.s	era0000			; skip if we have
		lea	buffer2,a1		; point to the oter buffer
era0000		movem.w	older_x,d0-d1		; get the last screen pos
		mulu.w	#160,d1			; y offset to screen
		move.w	d0,d6			; copy x position
		and.w	#$fff0,d0		; multiples of 16
		lsr.w	#1,d0			; x offset
		add.w	d0,d1			; total offset
		add.l	d1,a0			; display screen pointer
		move.w	#7,d7			; 8 lines to copy to screen
era0010		movem.l	(a1)+,d0-d3		; 16 pixel of data
		movem.l	d0-d3,(a0)		; restore the screen
		lea	160(a0),a0		; next screen line down
		dbra	d7,era0010		; copy all 8 lines
		rts

*************************************************
* Creates the faded pallette data from the      *
* original pallette data. Does it in STE format *
*************************************************
create_fade	lea	fade_data,a0		; point to fade data
		lea	fade_data+32,a1		; fade data
		movem.l	color_buff,d0-d7
		movem.l	d0-d7,(a0)		; level 1 data
		move.w	#14,d7			; 15 levels to fade
cf000		move.w	#15,d6			; 16 colours to fade
cf005		move.w	#2,d5			; red,green & blue levels
		move.w	#$f00,d4
		move.w	#$100,d3		; modify amount
		clr.w	(a1)
cf010		move.w	(a0),d0			; get a colour
		and.w	d4,d0			; make colour level
		tst.w	d0			; level to modify ?
		beq.s	cf020			; skip if not
		sub.w	d3,d0			; modify colour level
cf020		or.w	d0,(a1)			; setup the data
		lsr.w	#4,d4			; move mask to next colour
		lsr.w	#4,d3			; move modify amount
		dbra	d5,cf010		; do all 3 colour levels
		lea	2(a0),a0		; next colour
		lea	2(a1),a1		; next colour in buffer
		dbra	d6,cf005		; do all 16 colours
		dbra	d7,cf000		; do all 7 fade levels
		rts
			
fade_out	lea	fade_data,a6		; point to fade data
		move.w	#15,d7
fo000		move.w	d7,-(sp)
		jsr	vsync_wait
		lea	colours,a0
		move.w	#7,d6
fo001		move.l	(a6)+,d0		; colour data
		move.l	d0,d1
		and.l	#$01110111,d1		; lsb of colour data
		lsr.l	d0
		and.l	#$07770777,d0
		lsl.l	#3,d1			; move lsb into correct pos.
		or.l	d1,d0			; put in correct place
		move.l	d0,(a0)+		; install
		dbra	d6,fo001
		move.w	(sp)+,d7
		dbra	d7,fo000
		rts
			
fade_in		lea	fade_data+15*32,a6	; bottom of table
		move.w	#15,d7
fi000		move.w	d7,-(sp)
		jsr	vsync_wait
		lea	colours,a0
		move.w	#7,d6
fi001		move.l	(a6)+,d0		; colour data
		move.l	d0,d1
		and.l	#$01110111,d1		; lsb of colour data
		lsr.l	d0
		and.l	#$07770777,d0
		or.l	d1,d0			; put in correct place
		move.l	d0,(a0)+		; install
		dbra	d6,fi001
		lea	-64(a6),a6		; next set of colours
		move.w	(sp)+,d7
		dbra	d7,fi000
		rts

fade_in2	lea	fade_data+15*32,a6	; bottom of table
		move.w	#15,d7
fi2000		move.w	d7,-(sp)
		move.w	#37,-(sp)
		trap	#14
		lea	2(sp),sp
		lea	colours,a0
		move.w	#7,d6
fi2001		move.l	(a6)+,d0		; colour data
		move.l	d0,d1
		and.l	#$01110111,d1		; lsb of colour data
		lsr.l	d0
		and.l	#$07770777,d0
		lsl.l	#3,d1
		or.l	d1,d0			; put in correct place
		move.l	d0,(a0)+		; install
		dbra	d6,fi2001
		lea	-64(a6),a6		; next set of colours
		move.w	(sp)+,d7
		dbra	d7,fi2000
		rts

col_install	lea	char_cols,a6		; colour data
		lea	colours,a0
		move.w	#7,d6
		move.w	#0,d7
		move.w	d7,-(sp)
		bra	fi2001

*****************************************
*  The main program starts here         *
*****************************************
main		move.w	#191,y_max
		move.w	#1,y_min
		cmp.w	#191,mouse_y		; mouse in range ?
		ble.s	mn0000			; skip if it is
		move.w	#191,mouse_y		; stop off bottom error
mn0000		clr.w	which
		jsr	fade_out
		jsr	draw_map
		jsr	scrn_editor		; do screen editor
		move.w	#8,y_min
		cmp.w	#8,mouse_y		; mouse in range ?
		bge.s	mn0010			; skip if it is
		move.w	#8,mouse_y		; stop off top error
mn0010		move.w	#195,y_max
		tst.w	quit			; quit ?
		bne.s	main_exit		; exit if so
		move.w	#1,which
		jsr	fade_out
		jsr	char_editor		; do character editor
		clr.w	edit_flag
		movem.l	char_cols,d0-d7
		movem.l	d0-d7,color_buff
		jsr	create_fade
		tst.w	quit			; quit editor ?
		bne.s	main_exit
		bra	main
main_exit	jsr	fade_out
		rts


*****************************************************
* The screen editor                                 *
*****************************************************
scrn_editor	jsr	restore_screen
		jsr	fade_in
		tst.w	well_plot		; intro information ?
		beq.s	se000			; skip if not
		jsr	welcome			; do welcome text
se000		jsr	vsync_wait
		jsr	clr_cursor
		jsr	show_transporters
		jsr	scrn_mouse
		jsr	plot_chars
		jsr	ml000
		jsr	spirit_direction
		jsr	plt_cursor
		move.b	key_press,d0
		cmp.b	#'Q',d0			; quit
		beq.s	quit_ed
		cmp.b	#escape_key,d0		; #escape_key,d0
		bne.s	se000
		clr.w	key_press
		clr.w	quit
		rts
quit_ed		move.w	#1,quit
		rts
			
welcome		lea	wellu,a6		; welcome text
		jsr	plot_block
		jsr	vsync_wait
		lea	wellu,a6
		jsr	plot_block
wel0000		jsr	vsync_wait
		move.b	key_press,d0
		tst.b	d0
		beq.s	wel0000
		clr.w	key_press
		jsr	draw_map
		clr.w	well_plot
		rts

smenu		move.l	scr1,a0			; screen pntr
		move.l	scr1,a3
		lea	120(a0),a0		; offset to start
		lea	120(a3),a3		; offset to start
		lea	micons,a1		; character data
		lea	1536(a1),a1		; correct data area
		move.w	#63,d7			; 64 lines to plot
smen		movem.l	(a1)+,d0-d6/a2		; 1 line of data
		movem.l	d0-d6/a2,(a0)
		movem.l	d0-d6/a2,(a3)
		lea	160(a0),a0
		lea	160(a3),a3
		dbra	d7,smen
		rts
			
cmen		move.l	scr1,a0			; screen pntr
		move.l	scr1,a3
		lea	96(a0),a0		; offset to start
		lea	96(a3),a3		; offset to start
		lea	micons,a1		; character data
		move.w	#47,d7			; 32 lines to plot
cmens		movem.l	(a1)+,d0-d6/a2		; 1 line of data
		movem.l	d0-d6/a2,(a0)
		movem.l	d0-d6/a2,(a3)
		lea	160(a0),a0
		lea	160(a3),a3
		dbra	d7,cmens
		rts
			
			
scrn_mouse	movem.w	mouse_x,d0-d1		; mouse co-ords
		lsr.w	#3,d0
		lsr.w	#3,d1
		movem.w	d0-d1,cursor_x
		btst.b	#1,m_buttons		; left button pressed ?
		bne.s	slb000			; skip if pressed
		btst.b	#0,m_buttons		; right button pressed ?
		bne	srb000			; skip if pressed
		movem.w	d0-d1,erase+2		; erase flag for 2nd screen
		cmp.w	#28,d0
		bge.s	sm_exit
		move.w	#1,erase		; set erase flag
sm_exit		rts

* map modifications
slb000		cmp.w	#27,d0			; pointing into map ?
		bls	map_mod1		; skip if we are
* menu options 
		cmp.w	#7,d1			; max y line for menu
		bls	scrn_menu		; skip if we are
* must be icon selection then.
		movem.w	mouse_x,d0-d1
		addq.w	#4,d0			; adjust pointers
		addq.w	#4,d1
		lsr.w	#3,d0
		lsr.w	#3,d1
		cmp.w	#30,d0			; min x value
		bge.s	slb010			; skip if ok
		rts
slb010		cmp.w	#9,d1			; min y value
		bhs.s	slb020			; skip if ok
		rts
slb020		sub.w	#30,d0			; normalise x value
		sub.w	#9,d1			; normalise y value
		lsr.w	#1,d0			; each icon is 2 wide
		lsr.w	#1,d1
		mulu.w	#5,d1
		add.w	d0,d1			; icon number
		cmp.w	#spirit1,d1		; in range ?
		ble.s	slb030			; skip if ok
		rts
slb030		cmp.w	right,d1		; already in use ?
		bne.s	slb040			; skip if not
		rts
slb040		cmp.w	left,d1			; duplication ?
		bne.s	slb050
		rts
slb050		move.w	oleft,ooleft
		move.w	left,oleft
		move.w	d1,left			; change left icon select
		lea	txtlu,a0		; text look up table
		lsl.w	#2,d1			; *4 to make long word offset
		move.l	(a0,d1.w),a0		; pointer to text
		move.l	a0,leftp
		move.b	#25,1(a0)		; y position
		move.w	#2,n2plot
		rts
			
			
map_mod1	move.w	left,d2
		bra.s	mpm000
map_mod2	move.w	right,d2
mpm000		lea	available,a0		; display map ?
		move.w	map,d7
		tst.b	(a0,d7.w)		; map available ?
		beq.s	mpm_ok			; skip if it is
		rts
mpm_ok		move.w	d2,d3			; keep copy
		lea	placed,a0		; count data
		lea	max_icons,a1		; max of each type
		lsl.w	#1,d2			; * 2 for offset
		add.w	d2,a0
		add.w	d2,a1			; adjust pointers
		move.w	(a1),d4
		cmp.w	(a0),d4			; able to place any more ?
		bhi.s	mpm010			; skip if we can
		movem.w	d0-d1,erase+2		; erase flag for 2nd screen
		move.w	#1,erase		; set erase flag
		rts
mpm010		addq.w	#1,(a0)			; count one placed
		move.l	lvl_pntr,a0		; point to level data
		move.w	d1,d4
		mulu.w	#28,d4			; y offset
		add.w	d0,d4			; offset into data
		add.w	d4,a0
		lea	placed,a1		; count data
		clr.w	d4
		move.b	(a0),d4			; get old icon type
		lsl.w	#1,d4			; * 2 for word offset
		subq.w	#1,(a1,d4.w)		; count icon removed
		move.b	d3,(a0)			; new icon
		movem.w	d0-d1,erase+2		; erase flag for 2nd screen
		move.w	#1,erase		; set erase flag
		move.w	d3,-(sp)
		jsr	plot_one		; plot new one
		move.w	(sp)+,d3
		cmp.w	#trans*2,d4		; erased a transporter ?
		beq.s	kill_trans		; skip if we have
		cmp.b	#trans,d3		; placing transporter ?
		beq	new_trans		; skip if we are
		rts
			
kill_trans	move.l	lvl_pntr,a0		; level data
		lea	672(a0),a0		; transporter data
		move.w	erase+2,d0		; x position of transporter
		lsl.w	#8,d0			; get in upper byte
		add.w	erase+4,d0		; y position of transporter
		move.w	#3,d7			; check all 4 transporters
kl000		cmp.w	(a0),d0			; found the transporter ?
		beq.s	kl010			; skip if we have
		lea	4(a0),a0		; next transporter data
		dbra	d7,kl000
		cmp.b	#trans,d3		; placing a transporter
		beq	new_trans		; skip if we are
		rts				; return if invalid
kl010		move.w	2(a0),d0		; destination point
		clr.w	d1
		move.b	d0,d1			; expand
		lsr.w	#8,d0			; used to erase possible letter
		movem.w	d0-d1,erase+6
		move.l	#-1,(a0)		; erase transporter data
		cmp.b	#trans,d3		; placing a transporter ?
		beq	new_trans
		rts
			
new_trans	movem.w	erase+2,d0-d1		; get edit locations
		movem.w	d0-d1,trans1		; save for program
		lea	clit1,a0		; click text
		jsr	print_text
		lea	clit2,a0
		jsr	print_text
		jsr	plt_cursor
nt_wait		jsr	vsync_wait
		jsr	clr_cursor
		jsr	show_transporters
		jsr	spirit_direction
		lea	clit1,a0		; click text
		jsr	print_text
		lea	clit2,a0
		jsr	print_text
		movem.w	mouse_x,d0-d1
		lsr.w	#3,d0
		lsr.w	#3,d1
		movem.w	d0-d1,cursor_x
		movem.w	d0-d1,erase+2
		move.w	#1,erase
		jsr	plt_cursor
		jsr	ml000
		btst.b	#0,m_buttons		; no buttons pressed ?
		bne.s	nt_wait			; loop if not
		btst.b	#1,m_buttons		; no buttons pressed ?
		bne.s	nt_wait			; loop if not
		clr.w	quit
nt_main		jsr	vsync_wait
		jsr	clr_cursor
		jsr	show_transporters
		jsr	spirit_direction
		movem.w	mouse_x,d0-d1
		lsr.w	#3,d0
		lsr.w	#3,d1
		movem.w	d0-d1,cursor_x
		cmp.w	#28,d0
		bge.s	ntnt
		movem.w	d0-d1,erase+2
		move.w	#1,erase
ntnt		jsr	plt_cursor
		jsr	ml000
		jsr	trans_mouse
		tst.w	quit			; quit time ?
		beq.s	nt_main			; skip if not
		move.l	lvl_pntr,a0		; level data
		lea	672(a0),a0		; transporter data
		move.w	#3,d7			; 4 transporter slots
nt_000		move.l	(a0),d0			; get transporter data
		bmi.s	nt_010			; skip if empty slot
		lea	4(a0),a0		; next slot
		dbra	d7,nt_000		; find empty slot
		move.w	#2,n2plot
		jsr	vsync_wait
		jsr	clr_cursor
		rts				; no slot available
nt_010		movem.w	trans1,d0-d1		; source location
		movem.w	trans2,d2-d3		; destination location
		lsl.w	#8,d0
		add.w	d1,d0			; make transporter code
		lsl.w	#8,d2
		add.w	d3,d2			; make transporter code
		movem.w	d0/d2,(a0)		; save transporter data
		clr.b	m_buttons
		move.w	#2,n2plot
		jsr	vsync_wait
		rts


trans_mouse	btst.b	#0,m_buttons		; button pressed ?
		bne.s	trm000			; skip if not
		btst.b	#1,m_buttons
		bne.s	trm000
		cmp.w	#28,d0
		bge.s	tm_exit
		movem.w	mouse_x,d0-d1
		lsr.w	#3,d0
		lsr.w	#3,d1
		movem.w	d0-d1,erase+2		; erase flag for 2nd screen
		move.w	#1,erase		; set erase flag
tm_exit		rts
trm000		movem.w	mouse_x,d0-d1		; get mouse co-ords
		lsr.w	#3,d0
		lsr.w	#3,d1			; normalise
		cmp.w	#28,d0			; max x position
		blo.s	trm010			; skip if destination ok
		rts
trm010		move.w	#1,quit			; signal end
		movem.w	d0-d1,trans2		; save destination co-ords
		movem.w	d0-d1,erase+2		; erase flag for 2nd screen
		move.w	#1,erase		; set erase flag
		rts
			
scrn_menu	cmp.w	#30,d0			; min x pos
		bge.s	sm000
		rts
sm000		cmp.w	#37,d0			; max x pos
		ble.s	sm010
		rts
sm010		cmp.w	#1,d1			; top line of icons ?
		ble.s	tl000
		cmp.w	#3,d1			; change map ?
		ble	map_change		; skip if it is
		cmp.w	#5,d1			; play test ?
		ble	play_test		; skip if it is
		bra	passwords

tl000		cmp.w	#32,d0			; <= means load map 
		bge.s	sm030			; skip if other op
		clr.w	load_save		; loading map
		jsr	disk_operations
		lea	available,a0		; map protection data
		move.w	#7,d7
sm021		clr.b	(a0)+
		dbra	d7,sm021
		tst.b	protect			; check protection ?
		beq.s	sm022			; skip if protection off
		jsr	edit_codes		; do editor codes
sm022		clr.w	map			; map a when loading
		move.l	#maps,lvl_pntr		; reset level pointer
		jsr	draw_map
		rts
sm030		cmp.w	#34,d0			; <= means save map
		bge.s	sm040			; skip if not save
		move.w	#1,load_save		; saving map
		jsr	disk_operations
		jsr	draw_map
		rts
sm040		cmp.w	#36,d0
		blo	map_info		; skip if map information
		bra	level_time		; must be level time
			
map_info	lea	available,a0		; display map ?
		move.w	map,d7
		tst.b	(a0,d7.w)		; map available ?
		beq.s	mpistart		; skip if it is
		rts
mpistart	clr.w	quit
		jsr	indata
		lea	mapilu,a6		; block display
		jsr	plot_block
		jsr	plotics			; plot the icons
		jsr	vsync_wait
		lea	mapilu,a6
		jsr	plot_block
		jsr	plotics
		jsr	vsync_wait
mpi000		jsr	info_mouse
		jsr	vsync_wait
		tst.w	quit
		beq.s	mpi000
		clr.w	quit
		jsr	draw_map
		rts

spirit_direction
		lea	available,a0		; display map ?
		move.w	map,d0
		tst.b	(a0,d0.w)		; map available ?
		beq.s	spd0000			; skip if we do
		rts
spd0000		move.l	lvl_pntr,a0
		lea	pulsator_data,a1	; spirit location data
		clr.w	d0			; start x location
		clr.w	d1			; start y location
		clr.w	d2			; number of spirits
		move.w	#671,d7			; locations to check
mpi020		cmp.b	#spirit1,(a0)		; found a spirit ?
		bne.s	mpi025			; skip if not
		move.w	d0,(a1)+		; x start location
		move.w	d1,(a1)+		; y start location
		jsr	start_dir
		move.w	d5,(a1)+		; spirit direction 0-4
		addq.w	#1,d2			; count a spirit
mpi025		lea	1(a0),a0		; next map position
		addq.w	#1,d0			; next x location
		cmp.w	#28,d0			; end of row ?
		blo.s	mpi030			; skip if not
		clr.w	d0			; new line start
		addq.w	#1,d1			; next line
mpi030		dbra	d7,mpi020		; check all locations
		move.w	d2,num_pulsators	; save number of spirits
		tst.w	d2
		bne.s	mpi040
		rts
mpi040		subq.w	#1,spirit_t
		bne.s	pdr000
		not.w	spirit_d
		move.w	#25,spirit_t
pdr000		lea	pulsator_data,a1
		tst.w	spirit_d
		beq.s	pd020			; skip if plot spirits
		move.w	num_pulsators,d7	; no of spirits + 1
		subq.w	#1,d7
		lea	s_dirs,a2
pd010		lea	s_txt,a0
		move.b	1(a1),(a0)
		move.b	3(a1),1(a0)
		move.w	4(a1),d0		; spirit direction
		move.b	(a2,d0.w),2(a0)
		jsr	print_text
		lea	6(a1),a1		; next spirit data
		dbra	d7,pd010
		rts
pd020		move.w	num_pulsators,d7
		subq.w	#1,d7
pd030		move.w	(a1)+,d0
		move.w	(a1)+,d1
		lea	2(a1),a1
		movem.l	d7/a1,-(sp)
		jsr	plot_one
		movem.l	(sp)+,d7/a1
		dbra	d7,pd030
		rts
			
info_mouse	move.b	m_buttons,d0
		and.b	#$03,d0
		bne.s	im000
		rts
im000		movem.w	mouse_x,d0-d1
		lsr.w	#3,d0
		lsr.w	#3,d1
		cmp.w	#18,d1
		beq.s	im010
		rts
im010		cmp.w	#5,d0
		bge.s	im020
		rts
im020		cmp.w	#12,d0
		ble.s	im030
		rts
im030		move.w	#1,quit
		rts			
			
*
* plots the screen as seen in the fredfind game
*
full_screen	lea	available,a0		; display map ?
		move.w	map,d7
		tst.b	(a0,d7.w)		; map available ?
		beq.s	fsc000			; skip if it is
		rts
fsc000		jsr	vsync_wait
		jsr	ml000
		jsr	plot_screen
		lea	full_text,a0
		jsr	print_text
		move.b	key_press,d0
		cmp.b	#escape_key,d0		; #escape_key,d0
		bne.s	fsc000
		clr.w	key_press
		jsr	draw_map
		rts

plot_screen	movem.w	fs_x,d0-d1
		cmp.w	#22,d0			; max x value
		blo.s	pls000			; skip if no clip
		move.w	#21,d0			; clip x position
pls000		cmp.w	#19,d1			; max y position
		blo.s	pls010			; skip if ok
		move.w	#18,d1			; clip y position
pls010		movem.w	d0-d1,fs_x
		move.l	scr1,a6			; screen pointer
		move.l	lvl_pntr,a5		; map data
		move.w	#5,d7			; y positions to do
pls020		move.w	#6,d6			; x positions to do
pls030		move.w	d1,d2			; copy y position
		mulu.w	#28,d2			; y offset data
		add.w	d0,d2			; total offset
		clr.w	d3
		move.b	(a5,d2.w),d3		; character icon number
		lsl.w	#8,d3			; * 256
		lsl.w	#1,d3			; total * 512
		lea	chars,a0		; character table
		add.w	d3,a0			; character pntr
		lea	0(a6),a1		; screen pointers
		movem.l	d0-d1/d7,-(sp)
		jsr	plot_it
		movem.l	(sp)+,d0-d1/d7
		addq.w	#1,d0			; next xposition
		lea	16(a6),a6		; next xharacter position
		dbra	d6,pls030		; do all the line
		addq.w	#1,fs_x+2
		movem.w	fs_x,d0-d1
		lea	160*32-7*16(a6),a6	; next character position
		dbra	d7,pls020		; do all 6 lines
		rts

plotics		lea	icnums,a6		; icons to plot
		move.l	lvl_pntr,a5
		move.w	#8,d7			; 9 icons to do
		move.w	#252,d6			; start y pos
		move.w	#9,d1
pli000		move.b	15(a5,d6.w),d4		; copy old pos bit
		move.b	(a6)+,15(a5,d6.w)	; set icon number
		movem.l	d1/d4/d6-d7/a6,-(sp)
		move.w	#15,d0
		jsr	plot_one
		movem.l	(sp)+,d1/d4/d6-d7/a6
		move.b	d4,15(a5,d6.w)
		add.w	#28,d6
		addq.w	#1,d1
		dbra	d7,pli000
		rts
			
indata		lea	mapilu+16,a0		; fred line
		lea	icnums,a1		; icons to plot nums for
		lea	placed,a2
		move.w	#8,d7			; 9 to do
id000		move.l	(a0)+,a3		; destination line
		lea	17(a3),a3		; correct area
		clr.w	d0
		move.b	(a1)+,d0		; icon number
		lsl.w	#1,d0
		move.w	(a2,d0.w),d0		; number in map
		jsr	make_num
		move.b	d2,(a3)			; 100's
		move.b	d1,1(a3)		; 10's
		move.b	d0,2(a3)		; 1's
		dbra	d7,id000
		rts
			
make_num	clr.w	d2
		clr.w	d1
mkn000		cmp.w	#100,d0
		blo.s	mkn010
		sub.w	#100,d0
		addq.w	#1,d2
		bra.s	mkn000
mkn010		cmp.w	#10,d0
		blo.s	mkn020
		sub.w	#10,d0
		addq.w	#1,d1
		bra.s	mkn010
mkn020		add.b	#'0',d0
		add.b	#'0',d1
		add.b	#'0',d2
		cmp.b	#'0',d2
		bne.s	mkexit
		move.b	#' ',d2
		cmp.b	#'0',d1
		bne.s	mkexit
		move.b	#' ',d1
mkexit		rts
			

edit_codes	jsr	calc_codes		; calculate the values
		lea	edclu,a6		; look up table
		jsr	plot_block		; display the table
		jsr	vsync_wait
		lea	edclu,a6
		jsr	plot_block
		clr.w	quit
		move.w	#$ffff,pchar		; cursor on
		move.w	#25,pflash		; reset flash counter
		clr.w	pcursor			; start at position 0
		lea	num_txt+2,a0		; point to characters
		lea	available,a1		; available screens
		move.w	#5,d0			; clear count
edc_clr		move.b	#' ',(a0)+
		move.b	#1,(a1)+		; assume unavailable
		dbra	d0,edc_clr
		move.b	#1,(a1)+		; assume unavailable
		move.b	#1,(a1)+		; assume unavailable
		clr.w	edit_num		; map an editor code
edc000		jsr	vsync_wait
		jsr	num_plot
		jsr	edit_keys
		jsr	edit_mouse
		tst.w	quit			; quit ?
		beq.s	edc000			; loop if not
		rts

num_plot	subq.w	#1,pflash		; flash counter
		bne.s	np_ok			; skip if no change
		move.w	#25,pflash		; reset counter
		not.w	pchar			; change on/off
np_ok		move.w	edit_num,d0		; get number
		add.w	#9,d0			; make line number
		lea	num_txt,a0		; point to text
		move.b	d0,1(a0)		; print on correct line
		move.w	pcursor,d1		; cursor position
		move.b	#' ',2(a0,d1.w)		; assume cursor off
		tst.b	pchar			; cursor on / off
		beq.s	np000			; skip if off
		move.b	#'>',2(a0,d1.w)		; plot the cursor
np000		jsr	print_text		; print the number entered
		rts
			
edit_keys	move.b	key_press,d0
		tst.w	d0			; key pressed ?
		bne.s	ek000			; skip if one has
		rts
ek000		lea	valid2,a0		; characters allowed
		clr.w	key_press
ek020		move.b	(a0)+,d1		; get a valid character
		bne.s	ek030			; skip if not at end
		rts
ek030		cmp.b	d0,d1			; found our character ?
		beq.s	ek040			; skip if we have
		bra.s	ek020			; loop until found or exit
ek040		cmp.b	#delete_key,d0		; delete key ?
		beq.s	edit_del		; skip if it is
		cmp.b	#escape_key,d0		; pressed escape ?
		beq	edit_esc		; skip if it is
		cmp.b	#enter_key,d0		; pressed enter ?
		beq	edit_ent		; skip if it is
		cmp.w	#5,pcursor		; room for another character ?
		blo.s	ek050			; skip if there is
		rts
ek050		move.w	pcursor,d1
		lea	num_txt,a0
		move.b	d0,2(a0,d1.w)		; insert character
		move.w	#$ffff,pchar		; cursor on
		move.w	#25,pflash		; 1/2 sec count
		addq.w	#1,pcursor		; move the cursor
		rts
			
edit_del	tst.w	pcursor			; room to delete ?
		bne.s	ed000			; skip if there is
		rts
ed000		lea	num_txt,a0		; point to text
		move.w	pcursor,d0		; cursor position
		move.b	#' ',2(a0,d0.w)		; erase cursor
		move.w	#$ffff,pchar		; cursor on
		move.w	#25,pflash
		subq.w	#1,pcursor		; move the cursor
		rts
			
edit_ent	lea	num_txt+2,a0		; point to number
		clr.w	d1			; build number in this
		move.w	pcursor,d0		; number of character
		bne.s	ee000			; skip if are characters
		rts
ee000		subq.w	#1,d0			; 1 less for dbra
ee010		clr.w	d2
		move.b	(a0)+,d2		; get a character
		sub.b	#'0',d2			; normalise
		mulu.w	#10,d1			; shift digits
		add.w	d2,d1			; add new number
		dbra	d0,ee010		; build the number
		lea	nums_ent,a0		; numbers entered
		lea	codes,a1		; correct codes
		move.w	edit_num,d0		; line editing on
		lsl.w	#1,d0			; *2 for word offset
		cmp.w	(a1,d0.w),d1		; correct editor code ?
		beq.s	ee020			; skip if it is
		rts
ee020		move.w	d1,(a0,d0.w)		; save number entered
		lea	available,a0		; available screens
		lsr.w	#1,d0			; /2 for byte offset
		clr.b	(a0,d0.w)		; set map available
		add.w	#9,d0			; make line number
		lea	cor_txt,a0		; word correct!
		move.b	d0,1(a0)		; set correct height
		clr.w	pchar
		move.w	#25,pflash		; so cursor is erased
		jsr	print_text		; print it
		jsr	num_plot
		jsr	vsync_wait
		lea	cor_txt,a0
		jsr	print_text
		jsr	num_plot
		move.w	#$ffff,pchar		; cursor on
		move.w	#25,pflash		; reset flash counter
		clr.w	pcursor			; start at position 0
		lea	num_txt+2,a0		; point to characters
		move.w	#5,d0			; clear count
ee030		move.b	#' ',(a0)+
		dbra	d0,ee030
		addq.w	#1,edit_num		; next line
		cmp.w	#8,edit_num		; done them all ?
		blo.s	ee040			; skip if not
		move.w	#1,quit			; signal quit
ee040		rts

edit_esc	move.w	#5,d0
		lea	num_txt+2,a0
ede000		move.b	#' ',(a0)+
		dbra	d0,ede000
		clr.w	pcursor
		move.w	#$ffff,pchar
		move.w	#25,pflash
		rts

edit_mouse	btst.b	#1,m_buttons		; left button ?
		bne.s	em000			; skip if pressed
		rts
em000		movem.w	mouse_x,d0-d1
		lsr.w	#3,d0
		lsr.w	#3,d1
		cmp.w	#17,d1			; cancel line ?
		beq.s	em010			; skip if it is
		rts
em010		cmp.w	#5,d0			; min x pos
		bge.s	em020
		rts
em020		cmp.w	#12,d0			; max x pos
		ble.s	em030
		rts
em030		move.w	#1,quit			; signal quit
		rts

map_change	btst.b	#0,m_buttons	; do full screen instead ?
		bne	full_screen	; skip if we do
		cmp.w	#34,d0		; up a map ?
		bge.s	up_map		; skip if it is
down_map	tst.w	map		; able to change map ?
		bne.s	mc020		; skip if we can
		rts
mc020		subq.w	#1,map		; change map number
mc040		lea	maps,a0		; start of maps
		move.w	map,d0		; map number
		mulu.w	#688,d0		; map offset to pointer
		add.w	d0,a0
		move.l	a0,lvl_pntr	; adjust pointer
		jsr	draw_map	; draw the map
		rts

up_map		cmp.w	#7,map		; able to change map ?
		blo.s	mc030		; skip if we can
		rts
mc030		addq.w	#1,map
		and.w	#$7,map		; just to make sure
		bra.s	mc040
			
passwords	lea	available,a0	; display map ?
		move.w	map,d2
		tst.b	(a0,d2.w)	; map available ?
		beq.s	ps_ok		; skip if not
		rts
ps_ok		cmp.w	#29,d0		; min x position
		bge.s	pass_start	; skip if ok
		rts
pass_start	move.w	map,old_map
		jsr	pass_setup
		lea	passa,a0		; passwords
		lea	pslu+16,a1		; pointers
		lea	available,a6		; available maps
		move.w	#7,d7			; 8 passwords to copy
pass000		move.l	(a1)+,a2		; point to line data
		lea	8(a2),a2		; correct area of line
		tst.b	(a6)+			; map available ?
		beq.s	pass005			; skip if ok
		lea	question,a0		; question marks
pass005		move.w	#7,d6			; 8 bytes to copy
pass010		move.b	(a0)+,(a2)+		; copy a byte
		dbra	d6,pass010
		dbra	d7,pass000
		lea	pslu,a6			; point to passwords look up
		jsr	plot_block		; plot the table
		jsr	vsync_wait
		lea	pslu,a6
		jsr	plot_block
		clr.w	quit
pass020		jsr	vsync_wait
		jsr	pass_key
		jsr	passproc
		jsr	pass_mouse
		tst.w	quit			; quit ?
		beq.s	pass020			; loop if not
		jsr	vsync_wait
		move.w	#25,pflash
		move.w	#$ffff,pchar
		jsr	passproc		; erase possible cursor
		move.w	old_map,map
		jsr	draw_map
		rts

pass_setup	move.w	map,d0
		lea	passa,a0		; map a password
		lsl.w	#3,d0			; offset
		add.w	d0,a0			; correct password
		move.l	a0,passpntr		; store pointer
		lea	pslu+16,a0		; look up table
		lsr.w	#1,d0			; offset for l_word pntr
		move.l	(a0,d0.w),a0		; line pointer
		move.l	a0,paspntr2		; save pointer
		lea	newpass,a0		; build in here
		move.l	passpntr,a1		; current password
		clr.w	pcursor
		move.w	#7,d7			; copy across
pss000		move.b	(a1)+,d0		; get a character			
		cmp.b	#' ',d0			; end of string ?
		beq.s	pss010			; skip if not
		addq.w	#1,pcursor		; else count a character
pss010		move.b	d0,(a0)+		; store in build up
		dbra	d7,pss000		; copy them all
		rts

pass_mouse	btst.b	#1,m_buttons		; left button pressed ?
		bne.s	pm000			; skip if it has
		rts
pm000		movem.w	mouse_x,d0-d1		; mouse co-ords
		lsr.w	#3,d0
		lsr.w	#3,d1
		cmp.w	#16,d1			; cancel line ?
		beq	pm_cancel		; skip if it is
		cmp.w	#8,d1			; min password line
		bge.s	pm010			; skip if ok
		rts
pm010		cmp.w	#15,d1			; max password line
		ble.s	pm020			; skip if ok
		rts
pm020		cmp.w	#6,d0			; min x position
		bge.s	pm030			; skip if ok
		rts
pm030		cmp.w	#20,d0			; max x position
		ble.s	pm040			; skip if ok
		rts
pm040		sub.w	#8,d1			; make map number
		lea	available,a0		; display map ?
		tst.b	(a0,d1.w)		; map available ?
		beq.s	pm050			; skip if not
		rts
pm050		move.w	d1,map
		move.w	#25,pflash		; erase old cursor
		move.w	#$ffff,pchar		; space flag
		jsr	passproc		; setup string
		jsr	vsync_wait
		jsr	passproc
		move.w	#25,pflash		; erase old cursor
		clr.w	pchar			; cursor flag
		jsr	pass_setup
		rts
			
pm_cancel	cmp.w	#6,d0			; min x position
		bge.s	pmc000			; skip if ok
		rts
pmc000		cmp.w	#13,d0			; max x position
		ble.s	pmc010			; skip if ok
		rts
pmc010		move.w	#1,quit			; signal quit
		rts

passproc	lea	newpass,a0		; new password
		move.l	paspntr2,a1		; string position
		lea	8(a1),a1		; correct position
		move.w	pcursor,d7		; cursor position
		beq.s	pp010			; skip if empty string
		subq.w	#1,d7			; 1 less for dbra
pp000		move.b	(a0)+,(a1)+		; move a character
		dbra	d7,pp000		; copy them all
pp010		subq.w	#1,pflash		; invert cursor ?
		bne.s	pp020			; skip if not
		move.w	#25,pflash		; reset counter
		not.w	pchar			; invert flag
pp020		tst.w	pchar
		bne.s	pp030			; skip if inverted
		move.b	#'>',(a1)+		; cursor
		bra.s	pp040
pp030		move.b	#' ',(a1)+
pp040		move.b	#' ',(a1)+		; erase possible old cursor
		move.l	paspntr2,a0		; point to string
		move.b	#'a',17(a0)		; put in the arrow
		jsr	print_text		; and print it
		rts
			
pass_key	move.b	key_press,d0
		tst.w	d0			; key pressed ?
		bne.s	pk000			; skip if one has
		rts
pk000		lea	valid_chars,a0		; characters allowed
		clr.w	key_press
pk020		move.b	(a0)+,d1		; get a valid character
		bne.s	pk030			; skip if not at end
		rts
pk030		cmp.b	d0,d1			; found our character ?
		beq.s	pk040			; skip if we have
		bra.s	pk020			; loop until found or quit
pk040		cmp.b	#delete_key,d0		; delete key ?
		beq.s	pass_del		; skip if it is
		cmp.b	#escape_key,d0		; pressed escape ?
		beq	pass_esc		; skip if it is
		cmp.b	#enter_key,d0		; pressed enter ?
		beq	pass_ent		; skip if it is
		cmp.w	#8,pcursor		; room for another character ?
		blo.s	pk050			; skip if there is
		rts
pk050		lea	newpass,a0		; point to password
		move.l	passpntr,a1		; buffered password
		add.w	pcursor,a0		; correct position
		add.w	pcursor,a1		; correct position
		move.b	d0,(a0)			; insert the new character
		move.b	d0,(a1)			; insert the new character
		addq.w	#1,pcursor		; count the character
		move.w	#25,pflash
		clr.w	pchar
		rts
			
pass_del	tst.w	pcursor			; room to delete ?
		bne.s	pd000			; skip if there is
		rts
pd000		lea	newpass,a0		; point to password
		move.l	passpntr,a1
		subq.w	#1,pcursor		; move cursor
		add.w	pcursor,a0		; make pointer
		add.w	pcursor,a1		; make pointer
		move.b	#' ',(a0)		; insert the character
		move.b	#' ',(a1)		; insert the character
		move.w	#25,pflash
		clr.w	pchar
		rts
			
pass_ent	cmp.w	#7,map			; move to next password ?
		blo.s	pse000			; skip if we can
		move.w	#-1,map			; goto map a
pse000		addq.w	#1,map			; move to next map
		lea	available,a0		; display map ?
		move.w	map,d0
		tst.b	(a0,d0.w)		; map available ?
		beq.s	pse010			; skip if not
		clr.w	map
pse010		move.w	#25,pflash		; erase old cursor
		move.w	#$ffff,pchar		; space flag
		jsr	passproc		; setup string
		jsr	vsync_wait
		jsr	passproc
		jsr	pass_setup
		clr.w	pchar
		rts
			

pass_esc	move.l	passpntr,a0
		lea	newpass,a1
		move.l	paspntr2,a2
		move.w	pcursor,d7		; cursor position
		add.w	d7,a0
		add.w	d7,a1
		add.w	d7,a2
		lea	8(a2),a2		; correct position
		tst.w	d7			; at end already ?
		beq.s	psse010			; skip if we are
		subq.w	#1,d7			; 1 less for dbra
psse000		move.b	#' ',-(a0)		; erase a character
		move.b	#' ',-(a1)
		move.b	#' ',-(a2)
		move.b	#' ',1(a2)
		dbra	d7,psse000		; do them all
psse010		clr.w	pcursor
		move.w	#25,pflash
		clr.w	pchar
		rts

level_time	lea	available,a0		; display map ?
		move.w	map,d0
		tst.b	(a0,d0.w)		; map available ?
		beq.s	tm_ok			; skip if not
		rts
tm_ok		lea	tmlu,a6			; point to passwords look up
		jsr	plot_block		; plot the table
		jsr	vsync_wait
		lea	tmlu,a6
		jsr	plot_block
		clr.w	quit
lt000		jsr	vsync_wait
		jsr	time_mouse
		lea	tm4,a0
		jsr	print_text
		tst.w	quit
		beq.s	lt000
		jsr	vsync_wait
		jsr	draw_map
		rts

time_mouse	btst.b	#1,m_buttons		; left button pressed ?
		bne.s	tmm000			; skip if pressed
		rts
tmm000		movem.w	mouse_x,d0-d1		; mouse co-ords
		lsr.w	#3,d0
		lsr.w	#3,d1
		cmp.w	#14,d1			; cancel line ?
		beq.s	time_cancel		; skip if it is
		subq.w	#1,delay		; time delay between changes
		beq.s	tmm010			; skip if gone
		rts
tmm010		move.w	#5,delay		; setup new delay
		cmp.w	#13,d1			; down arrow line ?
		beq	time_down
		cmp.w	#11,d1			; up arrow line ?
		beq.s	time_up			; skip if it is
		rts

time_cancel	cmp.w	#6,d0			; min x position
		bge.s	tc000			; skip if ok
		rts
tc000		cmp.w	#13,d0			; max x position
		ble.s	tc010			; skip if ok
		rts
tc010		move.w	#1,quit			; signal quit
		rts
			
time_up		clr.w	d1			; assume amount change is 0
		cmp.w	#9,d0			; thousands ?
		bne.s	tu000			; skip if not
		move.w	#1000,d1		; 1000 change
tu000		cmp.w	#11,d0			; hundreds ?
		bne.s	tu010			; skip if not
		move.w	#100,d1			; 100 change
tu010		cmp.w	#13,d0			; tens ?
		bne.s	tu020			; skip if not
		move.w	#10,d1			; 10 change
tu020		cmp.w	#15,d0			; ones ?
		bne.s	tu030			; skip if not
		move.w	#1,d1			; 1 change
tu030		move.l	timepntr,a0		; point to time amount
		add.w	d1,(a0)			; add on the change
		cmp.w	#9999,(a0)		; overflow ?
		ble.s	tu040			; skip if ok
		move.w	#9999,(a0)		; limit to 9999
tu040		jsr	con_time		; convert the time
		rts

time_down	clr.w	d1			; assume amount change is 0
		cmp.w	#9,d0			; thousands ?
		bne.s	td000			; skip if not
		move.w	#1000,d1		; 1000 change
td000		cmp.w	#11,d0			; hundreds ?
		bne.s	td010			; skip if not
		move.w	#100,d1			; 100 change
td010		cmp.w	#13,d0			; tens ?
		bne.s	td020			; skip if not
		move.w	#10,d1			; 10 change
td020		cmp.w	#15,d0			; ones ?
		bne.s	td030			; skip if not
		move.w	#1,d1			; 1 change
td030		move.l	timepntr,a0		; point to time amount
		sub.w	d1,(a0)			; add on the change
		tst.w	(a0)			; negative ?
		bpl.s	td040			; skip if ok
		clr.w	(a0)			; min of 0
td040		jsr	con_time		; convert the time
		rts
			
con_time	move.l	timepntr,a0		; point to amount of time
		move.w	(a0),d0			; time amount - ones
		clr.w	d1			; tens
		clr.w	d2			; hundreds
		clr.w	d3			; thousands			
ct000		cmp.w	#1000,d0		; count thousands
		blo.s	ct010			; skip if none left
		addq.w	#1,d3			; count a thousand
		sub.w	#1000,d0
		bra.s	ct000
ct010		cmp.w	#100,d0			; count hundreds
		blo.s	ct020
		addq.w	#1,d2
		sub.w	#100,d0
		bra.s	ct010
ct020		cmp.w	#10,d0
		blo.s	ct030
		addq.w	#1,d1
		sub.w	#10,d0
		bra.s	ct020
ct030		add.b	#'0',d0			; convert to asci
		add.b	#'0',d1
		add.b	#'0',d2
		add.b	#'0',d3
		lea	timestr+2,a0		; string destination
		move.b	d3,(a0)+		; insert thousands
		move.b	d2,(a0)+		; insert hundreds
		move.b	d1,(a0)+		; insert tens
		move.b	d0,(a0) 		; insert ones
		lea	tm4+6,a0		; table position
		move.b	d3,(a0)			; insert thousands
		move.b	d2,2(a0)		; insert hundreds
		move.b	d1,4(a0)		; insert tens
		move.b	d0,6(a0)		; insert ones
		lea	timeplay+7,a0
		move.b	d3,(a0)+		; insert thousands
		move.b	d2,(a0)+		; insert hundreds
		move.b	d1,(a0)+		; insert tens
		move.b	d0,(a0) 		; insert ones
		rts

srb000		movem.w	mouse_x,d0-d1
		lsr.w	#3,d0
		lsr.w	#3,d1
		cmp.w	#27,d0			; pointing into map ?
		bls	map_mod2		; skip if we are
* menu options 
		cmp.w	#7,d1			; menu options ?
		ble	scrn_menu		; skip if it is
* must be icon selection then.
		cmp.w	#8,d1
		bge.s	srb0001
		rts
srb0001		movem.w	mouse_x,d0-d1
		addq.w	#4,d0			; adjust pointers
		addq.w	#4,d1
		lsr.w	#3,d0
		lsr.w	#3,d1
		cmp.w	#30,d0			; min x value
		bge.s	srb010			; skip if ok
		rts
srb010		cmp.w	#9,d1			; min y value
		bhs.s	srb020			; skip if ok
		rts
srb020		sub.w	#30,d0			; normalise x value
		sub.w	#9,d1			; normalise y value
		lsr.w	#1,d0			; each icon is 2 wide
		lsr.w	#1,d1
		mulu.w	#5,d1
		add.w	d0,d1			; icon number
		cmp.w	#spirit1,d1		; in range ?
		ble.s	srb030			; skip if ok
		rts
srb030		cmp.w	left,d1			; already in use ?
		bne.s	srb040			; skip if not
		rts
srb040		cmp.w	right,d1		; duplication ?
		bne.s	srb050
		rts
srb050		move.w	oright,ooright
		move.w	right,oright
		move.w	d1,right		; change left icon select
		lea	txtlu,a0		; text look up table
		lsl.w	#2,d1			; *4 to make long word offset
		move.l	(a0,d1.w),a0		; pointer to text
srb060		move.l	a0,rightp
		move.b	#26,1(a0)		; y position
		move.w	#2,n2plot
		rts

char_editor	jsr	restore_screen
		jsr	fade_in
ced000		jsr	vsync_wait
		jsr	chclic
		jsr	charic
		jsr	plot_ch
		jsr	plot_exp
		jsr	plot_names
		jsr	erase_colour
		jsr	char_mouse
		jsr	plot_cross
		move.b	key_press,d0
		cmp.b	#'Q',d0
		beq.s	char_quit
		cmp.b	#escape_key,d0		; pressed escape ?
		bne.s	ced000			; loop if not
		clr.w	key_press
		clr.w	quit
		rts
char_quit	move.w	#1,quit
		rts
						
plot_ch		move.l	char_pntr,a0
		move.l	scr1,a1
		lea	1352(a1),a1		; correct position
		jsr	plot_it
		lea	copy,a0			; copy buffer
		move.l	scr1,a1
		lea	1416(a1),a1
		jsr	plot_it
		rts
			
plot_it		move.w	#31,d7			; 32 lines to do
pi000		movem.l	(a0)+,d0-d3		; get 2 lines of data
		movem.l	d0-d3,(a1)
		lea	160(a1),a1
		dbra	d7,pi000
		rts
			
expand		lea	expanded,a0		; expanded data area
		move.l	char_pntr,a1
		move.w	#63,d7			; 32*2*4 = 256 bit planes to do
exp000		move.w	(a1)+,d0		; get a bit plane
		jsr	exp_it			; return in d1-d4
		move.w	d1,(a0)
		move.w	d2,8(a0)
		move.w	d3,16(a0)
		move.w	d4,24(a0)
		move.w	(a1)+,d0
		jsr	exp_it
		move.w	d1,2(a0)
		move.w	d2,10(a0)
		move.w	d3,18(a0)
		move.w	d4,26(a0)
		move.w	(a1)+,d0
		jsr	exp_it
		move.w	d1,4(a0)
		move.w	d2,12(a0)
		move.w	d3,20(a0)
		move.w	d4,28(a0)
		move.w	(a1)+,d0
		jsr	exp_it
		move.w	d1,6(a0)
		move.w	d2,14(a0)
		move.w	d3,22(a0)
		move.w	d4,30(a0)
		lea	32(a0),a0		; next bit plane lot
		dbra	d7,exp000
		rts
			
exp_it		clr.w	d1
		clr.w	d2
		clr.w	d3
		clr.w	d4
		move.w	#$f000,d5		; data to insert
		move.w	#3,d6			; first four pixels
ei000		lsl.w	#1,d0			; get bit status in carry
		bcc.s	ei010			; skip if no data
		or.w	d5,d1			; insert data
ei010		lsr.w	#4,d5			; shift or data
		dbra	d6,ei000		
		move.w	#$f000,d5		; data to insert
		move.w	#3,d6			; first four pixels
ei020		lsl.w	#1,d0			; get bit status in carry
		bcc.s	ei030			; skip if no data
		or.w	d5,d2			; insert data
ei030		lsr.w	#4,d5			; shift or data
		dbra	d6,ei020		
		move.w	#$f000,d5		; data to insert
		move.w	#3,d6			; first four pixels
ei040		lsl.w	#1,d0			; get bit status in carry
		bcc.s	ei050			; skip if no data
		or.w	d5,d3			; insert data
ei050		lsr.w	#4,d5			; shift or data
		dbra	d6,ei040		
		move.w	#$f000,d5		; data to insert
		move.w	#3,d6			; first four pixels
ei060		lsl.w	#1,d0			; get bit status in carry
		bcc.s	ei070			; skip if no data
		or.w	d5,d4			; insert data
ei070		lsr.w	#4,d5			; shift or data
		dbra	d6,ei060		
		rts
			
plot_exp	move.l	scr1,a0
		lea	1280(a0),a0
		lea	expanded,a2
		move.w	#31,d7			; 32 lines of data
ple000		movem.l	(a2)+,d0-d6/a3		; one line of data
		movem.l	d0-d6/a3,(a0)
		movem.l	d0-d6/a3,160(a0)
		movem.l	d0-d6/a3,320(a0)
		movem.l	d0-d6/a3,480(a0)
		movem.l	(a2)+,d0-d6/a3		; one line of data
		movem.l	d0-d6/a3,32(a0)
		movem.l	d0-d6/a3,192(a0)
		movem.l	d0-d6/a3,352(a0)
		movem.l	d0-d6/a3,512(a0)
		lea	640(a0),a0
		dbra	d7,ple000
		rts
			
plot_cross	tst.w	edit_flag		; plot the cursor ?
		bne.s	ptc000			; skip if plot
		lea	pos_ers,a0		; erase ps position stuff
		jsr	print_text
		rts
ptc000		movem.w	edit,d0-d1		; get cross position
		lea	edit_ch,a0		; box sides
		lea	edit_ch2,a1		; box top
		and.w	#3,d0			; range 0 - 4
		lsl.w	#2,d0			; l_word offset
		move.l	(a0,d0.w),d2		; eor data - sides
		move.l	(a1,d0.w),d3		; eor data - top/bottom
		move.w	edit,d0			; x position
		and.w	#$fffc,d0		; make x offset
		lsl.w	#1,d0			; mults of 8
		move.l	scr1,a0
		lea	1280(a0),a0
		add.w	d0,a0			; correct start
		mulu.w	#640,d1			; y offset
		add.w	d1,a0
		eor.l	d3,(a0)			; top & bottom
		eor.l	d3,4(a0)
		eor.l	d3,480(a0)		; sides
		eor.l	d3,484(a0)
		eor.l	d2,160(a0)
		eor.l	d2,164(a0)
		eor.l	d2,320(a0)
		eor.l	d2,324(a0)
		jsr	pos_txt2
		rts

pos_txt2	move.w	edit,d0			; get mouse position
		addq.w	#1,d0			; 1 - 32 range
		lea	pos_txt,a0		; point at text to print
		clr.w	d1			; tens count
pos2010		cmp.w	#10,d0			
		blo.s	pos2020			; skip if none to count
		sub.w	#10,d0			; lose ten
		addq.w	#1,d1			; count a ten
		bra.s	pos2010			; count them all
pos2020		add.b	#'0',d0			; number range
		add.b	#'0',d1			; number range
		move.b	d1,6(a0)		; x tens
		move.b	d0,7(a0)		; x ones
		move.w	edit+2,d0	
		addq.w	#1,d0			; 1 - 32 range
		clr.w	d1			; tens count
pos2030		cmp.w	#10,d0			
		blo.s	pos2040			; skip if none to count
		sub.w	#10,d0			; lose ten
		addq.w	#1,d1			; count a ten
		bra.s	pos2030			; count them all
pos2040		add.b	#'0',d0			; number range
		add.b	#'0',d1			; number range
		move.b	d1,13(a0)		; y tens
		move.b	d0,14(a0)		; y ones
		jsr	print_text
		rts

plot_names	move.w	ch_icon,d0		; icon number
		lsl.w	#2,d0			; l_word offset
		lea	ctxtlu,a0		; look up table
		move.l	(a0,d0.w),a0		; pointer to text
		jsr	print_text
		lea	n_txt,a0		; assume normal mode
		tst.w	edit_t			; check edit type
		beq.s	pn010			; skip if normal
		lea	m_txt,a0		; else mirror text
		cmp.w	#1,edit_t		; skip if mirror
		beq.s	pn010
		lea	f_txt,a0		; else is flood fill
pn010		jsr	print_text
		rts


char_mouse	clr.w	edit_flag
		btst.b	#1,m_buttons		; left button pressed ?
		bne.s	chm000			; skip if it has
		btst.b	#0,m_buttons		; right button pressed ?
		bne.s	chm000			; skip if it has
		clr.w	scr_delay
		movem.w	mouse_x,d0-d1
		lsr.w	#2,d0
		lsr.w	#2,d1
		cmp.w	#32,d0			; pointing into character ?
		blo.s	chm001
		rts
chm001		cmp.w	#34,d1
		blo.s	chm002
		rts
chm002		subq.w	#2,d1
		movem.w	d0-d1,edit
		move.w	#1,edit_flag
		rts
chm000		movem.w	mouse_x,d0-d1		; mouse co-ordinates
		lsr.w	#3,d0
		lsr.w	#3,d1
		cmp.w	#20,d1			; colour selection modification ?
		bge 	col_stuff		; skip if it is
		cmp.w	#16,d0			; changing character ?
		ble 	edit_char		; skip if it is
		cmp.w	#5,d1			; menu selection ?
		ble	menu_sel		; skip if it is
* must be icon selection
		movem.w	mouse_x,d0-d1		; get mouse position
		addq.w	#4,d0
		addq.w	#4,d1			; normalise
		lsr.w	#3,d0
		lsr.w	#3,d1
		cmp.w	#7,d1			; min y position
		bge.s	chm010			; skip if ok
		rts
chm010		cmp.w	#18,d0			; min x position
		bge.s	chm020			; skip if ok
		rts
chm020		cmp.w	#18,d1			; max y position
		ble.s	chm030			; skip if ok
		rts
chm030		sub.w	#18,d0			; normalise
		sub.w	#7,d1
		lsr.w	#1,d0			; make x value on line
		lsr.w	#1,d1			; make y position
		mulu.w	#11,d1			; make offset value
		add.w	d0,d1			; icon number
		cmp.w	#right6,d1		; valid icon ?
		ble.s	chm040			; skip if it is
		rts
chm040		cmp.w	ch_icon,d1		; duplication ?
		bne.s	chm050			; skip if not
		rts
chm050		move.w	ch_old,ch_older		; bufered values
		move.w	ch_icon,ch_old
		move.w	d1,ch_icon
		lea	chars,a0
		lsl.l	#8,d1
		lsl.l	#1,d1
		add.l	d1,a0
		move.l	a0,char_pntr
		jsr	expand
		rts

col_stuff	cmp.w	#19,d0			; changing colour ?
		bge	color_mod		; skip if we are
		movem.w	mouse_x,d0-d1
		addq.w	#4,d0
		addq.w	#4,d1
		lsr.w	#3,d0
		lsr.w	#3,d1
		cmp.w	#1,d0			; min x position fo color mod
		bge.s	cst000			; skip if ok
		rts
cst000		cmp.w	#16,d0			; max x position for color mod
		ble.s	cst010			; skip if ok
		rts
cst010		sub.w	#1,d0			; make color number 0 - 7
		lsr.w	#1,d0
		sub.w	#21,d1			; normalise y
		lsr.w	#1,d1			; lose lsb
		lsl.w	#3,d1			; mult of 8
		add.w	d1,d0			; make color number
		cmp.w	#16,d0			; valid colour ?
		blo.s	cst030			; skip if ok
		rts
cst030		cmp.w	colour_num,d0		; same colour ?
		bne.s	cst040
		rts
cst040		move.w	old_num,older_num
		move.w	colour_num,old_num
		move.w	d0,colour_num
		move.w	#2,color_flag
		rts

color_mod	cmp.w	#21,d1			; min y position
		bge.s	cm0000
		rts
cm0000		cmp.w	#23,d1			; max y position
		ble.s	cm0010			; skip if ok
		rts
cm0010		cmp.w	#19,d0			; min x pos
		bge.s	cm0012
		rts
cm0012		cmp.w	#36,d0			; max x position
		ble.s	cm0015
		rts
cm0015		tst.w	colour_num		; colour 0 ?
		bne.s	cm0017			; skip if not
		rts
cm0017		move.w	colour_num,d2		; color 15 ?
		cmp.w	#15,d2
		bne.s	cm0019			; skip if not
		rts
cm0019		lea	red,a0			; assume red
		cmp.w	#22,d1			; green ?
		bne.s	cm0020			; skip if not
		lea	green,a0		; point to green
cm0020		cmp.w	#23,d1			; blue ?
		bne.s	cm0030			; skip if not
		lea	blue,a0
cm0030		cmp.w	#19,d0			; mod by 1 ?
		beq	down_one
		cmp.w	#36,d0			; mod by 1 ?
		bge	up_one
		sub.w	#20,d0			; make colour value
		and.w	#$f,d0

colour_build	lea	red_lvl,a1		; red txt
		lea	green_lvl,a2		; green txt
		lea	blue_lvl,a3		; blue txt
		move.w	red,d1			; old values
		move.w	green,d2
		move.w	blue,d3
		move.b	#'~',2(a1,d1.w)
		move.b	#'~',2(a2,d2.w)
		move.b	#'~',2(a3,d3.w)		; erase old characters
		move.w	d0,(a0)			; save new colour level
		move.w	red,d0			; get red level
		lsl.w	#4,d0			; shift
		add.w	green,d0		; add in green level
		lsl.w	#4,d0			; shift
		add.w	blue,d0			; add in blue level
		move.w	colour_num,d1		; get colour number
		lsl.w	#1,d1			; word offset
		lea	char_cols,a0		; point to colours
		move.w	d0,(a0,d1.w)		; save the new colour
		jsr	col_install
		move.w	#2,color_flag
		rts
			
down_one	tst.w	col_delay		; time for a change ?
		beq.s	dwo000			; skip if it is
		subq.w	#1,col_delay
		rts
dwo000		move.w	#2,col_delay		; reset counter
		move.w	(a0),d0			; get colour level
		beq.s	dwo010			; skip if already 0
		subq.w	#1,d0
dwo010		and.w	#$f,d0
		bra	colour_build		; build the new colour

up_one		tst.w	col_delay		; time for a change ?
		beq.s	upo000			; skip if it is
		subq.w	#1,col_delay
		rts
upo000		move.w	#2,col_delay		; reset counter
		move.w	(a0),d0			; get colour level
		cmp.w	#$f,d0			; at limit ?
		bge.s	upo010			; skip if it is
		addq.w	#1,d0			; else increase
upo010		and.w	#$f,d0
		bra	colour_build		; build the new colour			

edit_char	cmp.w	#16,d0			; up/down arrow ?
		beq	ud_arrs			; skip if it is
		cmp.w	#17,d1			; left/right arrow ?
		beq	lr_arrs			; skip if it is
* else edit character
		blo.s	ec000
		rts
ec000		movem.w	mouse_x,d0-d1		; get mouse co-ordinates
		lsr.w	#2,d0			; normalise
		lsr.w	#2,d1			; normalise
		subq.w	#2,d1			; remove offset
		cmp.w	#2,edit_t		; flood fill ?
		beq	flood_it		; skip if it is
		movem.w	d0-d1,edit		; save edit co-ords
		move.w	#1,edit_flag		; set a flag
		jsr	set_point
		cmp.w	#1,edit_t		; mirror ?
		beq.s	ec010			; skip if we are
		rts
ec010		move.w	#31,d0			; assume full right
		sub.w	edit,d0			; make mirror value
		move.w	edit+2,d1		; get edit co-ordinates
		jsr	set_point
		rts
			
set_point	movem.w	d0-d1,-(sp)
		lea	expanded,a0		; expanded data
		move.l	char_pntr,a1		; character data
		cmp.w	#16,d0			; right half of character ?
		blo.s	sp010			; skip if not
		lea	8(a1),a1
		lea	32(a0),a0		; move pointers
sp010		and.w	#$0f,d0			; make 0 - 15
		move.w	d0,d2			; copy
		and.w	#$0c,d2			; make expanded offset
		lsl.w	#1,d2			; mults of 8 not 4
		add.w	d2,a0			; correct bit plane set
		lea	pixel,a2		; unexpande pixel data
		lea	epixel,a3		; expanded pixel data
		move.w	d0,d2			; copy
		and.w	#$03,d2			; endpande range = 0 - 3
		lsl.w	#1,d0			; word offset for pixel data
		lsl.w	#1,d2			; word offset for epixel data
		move.w	(a2,d0.w),d0		; pixel data
		move.w	(a3,d2.w),d2		; epixel data
		lsl.w	#4,d1			; * 16 for y offset into data
		add.w	d1,a1			; ordinary character pointer
		lsl.w	#2,d1			; expanded character offset
		add.w	d1,a0			; make pointer
		move.w	colour_num,d1		; get colour number
		move.w	#3,d7			; 4 bit planes to modify
		move.w	d0,d3
		not.w	d3			; pixel mask data
		move.w	d2,d4		
		not.w	d4			; epixel mask data
sp020		and.w	d3,(a1)			; assume empty
		and.w	d4,(a0)
		lsr.w	#1,d1			; get bit plane on/off in carry			
		bcc.s	sp030			; skip if no set
		or.w	d0,(a1)			; pixel data
		or.w	d2,(a0)			; epixel data
sp030		lea	2(a0),a0
		lea	2(a1),a1
		dbra	d7,sp020		; do all 4 bit planes			
		movem.w	(sp)+,d0-d1
		rts

flood_it	jsr	pixel_col		; get colour we are overwriting
		cmp.w	colour_num,d2		; same as selected colour ?
		bne.s	fli000			; skip if not
		movem.w	d0-d1,edit		; save edit co-ords
		move.w	#1,edit_flag		; set a flag
		rts				; cannot flood it
fli000		move.w	d2,flood_col		; save colour to flood
		movem.w	d0-d1,edit		; save edit co-ords
		move.w	#1,edit_flag		; set a falg
		jsr	set_point		; set the 1st point
		jsr	do_north
		jsr	do_east
		jsr	do_west
		jsr	do_south
		rts

do_north	tst.w	d1			; check point above ?
		bne.s	dn000			; skip if we can
		rts
dn000		movem.w	d0-d1,-(sp)
		subq.w	#1,d1
		jsr	pixel_col		; get it's colour
		cmp.w	flood_col,d2		; need to change ?
		bne.s	dn010			; skip if not
		jsr	set_point
		jsr	do_north
		jsr	do_east
		jsr	do_west
dn010		movem.w	(sp)+,d0-d1
		rts

do_east		cmp.w	#31,d0			; check point to right ?
		blo.s	de000			; skip if we can
		rts
de000		movem.w	d0-d1,-(sp)
		addq.w	#1,d0
		jsr	pixel_col		; get it's colour
		cmp.w	flood_col,d2		; need to change ?
		bne.s	de010			; skip if not
		jsr	set_point
		jsr	do_north
		jsr	do_south
		jsr	do_east
de010		movem.w	(sp)+,d0-d1
		rts

do_south	cmp.w	#31,d1			; check point to below ?
		blo.s	ds000			; skip if we can
		rts
ds000		movem.w	d0-d1,-(sp)
		addq.w	#1,d1
		jsr	pixel_col		; get it's colour
		cmp.w	flood_col,d2		; need to change ?
		bne.s	ds010			; skip if not
		jsr	set_point
		jsr	do_south
		jsr	do_east
		jsr	do_west
ds010		movem.w	(sp)+,d0-d1
		rts

do_west		tst.w	d0			; check point to left ?
		bne.s	dw000			; skip if we can
		rts
dw000		movem.w	d0-d1,-(sp)
		subq.w	#1,d0
		jsr	pixel_col		; get it's colour
		cmp.w	flood_col,d2		; need to change ?
		bne.s	dw010			; skip if not
		jsr	set_point
		jsr	do_west
		jsr	do_north
		jsr	do_south
dw010		movem.w	(sp)+,d0-d1
		rts


* returns the pixel colour at point (d0,d1) in character at Char_pntr
* colour returned in d2
pixel_col	move.l	char_pntr,a6		; character data
		movem.w	d0-d1,-(sp)
		lsl.w	#4,d1			; line offset
		cmp.w	#16,d0			; 2nd half ?
		blo.s	pic000			; skip if not
		add.w	#8,d1
pic000		and.w	#$000f,d0		; make 0-15 roll amount (inverse)
		movem.w	(a6,d1.w),d2-d5		; get graphic data
pic010		cmp.w	#8,d0			; do an 8 roll ?
		blo.s	pic020			; skip if not
		lsl.w	#8,d2
		lsl.w	#8,d3
		lsl.w	#8,d4
		lsl.w	#8,d5
pic020		and.w	#$0007,d0		; rest of roll
		beq.s	pic030			; skip if 0
		lsl.w	d0,d2
		lsl.w	d0,d3
		lsl.w	d0,d4
		lsl.w	d0,d5
pic030		clr.w	d0			; make colour number in d0
		lsl.w	#1,d5
		roxl.w	#1,d0
		lsl.w	#1,d4
		roxl.w	#1,d0
		lsl.w	#1,d3
		roxl.w	#1,d0
		lsl.w	#1,d2
		roxl.w	#1,d0
		move.w	d0,d2			; colour at point (d0,d1)
		movem.w	(sp)+,d0-d1
		rts

ud_arrs		cmp.w	#1,d1			; up arrow ?
		ble.s	scroll_up		; skip if it is
		cmp.w	#16,d1			; scroll down ?
		beq.s	scroll_down
		rts

scroll_up	move.l	char_pntr,a0
		movem.l	(a0),d0-d3		; get top line of data
		movem.l	d0-d3,-(sp)		; save on stack
		move.w	#30,d7			; 31 lines to scroll by 1
su000		movem.l	16(a0),d0-d3		; line of data
		movem.l	d0-d3,(a0)		; copy up
		lea	16(a0),a0		; next space
		dbra	d7,su000
		movem.l	(sp)+,d0-d3		; top line
		movem.l	d0-d3,(a0)		; insert
		jsr	expand			; expand it
		rts

scroll_down	move.l	char_pntr,a0
		lea	496(a0),a0		; bottom of character
		movem.l	(a0),d0-d3		; get bottom line of data
		movem.l	d0-d3,-(sp)		; save on stack
		move.w	#30,d7			; 31 lines to scroll by 1
sd000		movem.l	-16(a0),d0-d3		; line of data
		movem.l	d0-d3,(a0)		; copy up
		lea	-16(a0),a0		; next space
		dbra	d7,sd000
		movem.l	(sp)+,d0-d3		; bottom line
		movem.l	d0-d3,(a0)		; insert
		jsr	expand			; expand it
		rts
			
lr_arrs		tst.w	d0			; scroll left arrow ?
		beq	scroll_left
		cmp.w	#15,d0			; scroll right arrow ?
		beq	scroll_righ
		rts

scroll_left	move.l	char_pntr,a0
		move.w	#31,d7			; 32 lines to do
scrl000		move.w	#3,d6			; 4 bit planes to do
scrl010		move.w	(a0),d0
		move.w	8(a0),d1
		lsl.w	#1,d1			; get extra bit in carry
		roxl.w	#1,d0			; get bit
		bcc.s	scrl020			; skip if no bit
		or.w	#$1,d1			; last bit
scrl020		move.w	d0,(a0)
		move.w	d1,8(a0)		; save data
		lea	2(a0),a0		; next bit plane
		dbra	d6,scrl010
		lea	8(a0),a0		; next line
		dbra	d7,scrl000		; do all the lines
		jsr	expand
		rts
			
scroll_righ	move.l	char_pntr,a0
		move.w	#31,d7			; 32 lines to do
scr000		move.w	#3,d6			; 4 bit planes to do
scr010		move.w	(a0),d0
		move.w	8(a0),d1
		lsr.w	#1,d1			; get extra bit in carry
		roxr.w	#1,d0			; get bit
		bcc.s	scr020			; skip if no bit
		or.w	#$8000,d1		; last bit
scr020		move.w	d0,(a0)
		move.w	d1,8(a0)		; save data
		lea	2(a0),a0		; next bit plane
		dbra	d6,scr010
		lea	8(a0),a0		; next line
		dbra	d7,scr000		; do all the lines
		jsr	expand
		rts
			
menu_sel	cmp.w	#24,d0			; min x position
		bge.s	ms000			; skip if ok
		rts
ms000		cmp.w	#31,d0			; max y pos
		ble.s	ms010
		rts
ms010		cmp.w	#1,d1			; 1st line of icons ?
		ble.s	fst_lot			; skip if it is
		cmp.w	#3,d1			; 2nd line of icons ?
		ble.s	snd_lot			; skip if it is
* must be third line of icons
		cmp.w	#28,d0			; copy buffer direction ?
		blo.s	ms020			; skip if to character
		jsr	to_buff
		rts
ms020		jsr	from_buff
		rts
			
fst_lot		cmp.w	#25,d0			; load chr file ?
		ble	load_chr		; skip if it is
		cmp.w	#27,d0			; save chr file ?
		ble	save_chr		; skip if it is
		cmp.w	#29,d0			; rotate character ?
		ble	rotate			; skip if it is
		bra	fliph			; else horizontal flip
			
snd_lot		cmp.w	#27,d0			; normal/mirror/flood ?
		ble	mirror			; skip if it is
		cmp.w	#29,d0			; flip vertical ?
		ble	flipv			; skip if it is
		bra	animate			; must be animate

load_chr	move.w	#2,load_save		; load chr file
		jsr	disk_operations		; do disk stuff
		jsr	restore_screen
		jsr	col_install
		rts
			
save_chr	move.w	#3,load_save		; save chr file
		jsr	disk_operations		; do disk stuff
		jsr	restore_screen
		rts
			
to_buff		move.l	char_pntr,a0
		lea	copy,a1			; destination
		move.w	#31,d7			; 32 lines of data
cchr000		movem.l	(a0)+,d0-d3		; line of data
		movem.l	d0-d3,(a1)		; save in buffer
		lea	16(a1),a1
		dbra	d7,cchr000
		rts
from_buff	move.l	char_pntr,a0
		lea	copy,a1			; destination
		move.w	#31,d7			; 32 lines of data
cchr010		movem.l	(a1)+,d0-d3		; line of data
		movem.l	d0-d3,(a0)		; save in character
		lea	16(a0),a0
		dbra	d7,cchr010
		jsr	expand
		rts

animate		clr.w	key_press
		move.w	ch_icon,d0		; get icon number
		cmp.b	#right1,d0		; fred walking right ?
		bge	rig_seq			; skip if it is
		cmp.b	#left1,d0		; fred walking left ?
		bge	lef_seq			; skip if it is
		cmp.b	#up_down1,d0		; fred walking up ?
		bge	up_seq			; skip if it is
		cmp.b	#lookleft,d0		; fred looking ?
		bge	loo_seq			; skip if it is
		cmp.b	#monster1,d0		; monster sequence ?
		bge	mon_seq			; skip if it is
		cmp.b	#cracked,d0		; cracked egg ?
		beq	anim_exit		; skip if it is
		cmp.b	#spirit1,d0		; spirit sequence ?
		bge	spi_seq			; skip if it is
		cmp.b	#fred,d0		; fred looking ?
		beq	loo_seq			; skip if it is
anim_exit	rts
			
rig_seq		move.l	#walk_right,seq_start
		bra	anim000
lef_seq		move.l	#walk_left,seq_start
		bra	anim000
up_seq		move.l	#walk_up,seq_start
		bra	anim000
loo_seq		move.l	#looking,seq_start
		bra	anim000
mon_seq		move.l	#monster,seq_start
		bra	anim000
spi_seq		move.l	#spirits,seq_start

anim000		move.w	ch_icon,old_icon
		move.l	char_pntr,old_pntr
		move.l	seq_start,seq_pntr
anim010		jsr	vsync_wait
		jsr	plot_exp
		jsr	plot_ch
		jsr	plot_names
		jsr	next_frame
		jsr	expand
		rept	3
		jsr	vsync_wait
		jsr	plot_exp
		jsr	plot_ch
		jsr	plot_names
		endr

		move.b	key_press,d0
		beq	anim010
		clr.w	key_press
		move.l	old_pntr,char_pntr
		move.l	old_icon,ch_icon
		jsr	expand
		rts
			
next_frame	move.l	seq_pntr,a0		; next frame pointer
		move.l	(a0)+,d0		; get pointer
		bne.s	nf000			; skip if ok
		move.l	seq_start,a0		; reset pointer
		move.l	(a0)+,d0		; new pointer
nf000		move.l	d0,char_pntr
		sub.l	#chars,d0		; offset from char starts
		lsr.w	#8,d0
		lsr.w	#1,d0			; icon number
		move.w	d0,ch_icon		; to plot name
		move.l	a0,seq_pntr
		rts
			
flipv		subq.w	#1,scr_delay		; time for flip ?
		bmi.s	fv_start		; skip if it is
		rts
fv_start	move.w	#3,scr_delay
		move.l	char_pntr,a0
		lea	496(a0),a1		; bottom line
		move.w	#15,d7			; 32 lines to flip, 2 at a time
vf000		movem.l	(a0),d0-d3 		; top line
		movem.l	(a1),a2-a5		; bottom line
		movem.l	a2-a5,(a0)
		movem.l	d0-d3,(a1)
		lea	16(a0),a0		; next line down
		lea	-16(a1),a1		; next line up
		dbra	d7,vf000		; flip the character
		jsr	expand
		rts

fliph		subq.w	#1,scr_delay		; time for a flip ?
		bmi.s	fh_start		; skip if it is
		rts
fh_start	move.w	#3,scr_delay
		move.l	char_pntr,a0
		lea	0(a0),a1		; copy
		move.w	#255,d7			; 256 words to reverse
fh000		move.w	(a0),d0			; get a bit plane
		clr.w	d1			; destination
		move.w	#15,d6			; bit counter
fh010		lsr.w	#1,d0			; roll out a bit
		roxl.w	#1,d1			; bring in in reverse
		dbra	d6,fh010
		move.w	d1,(a0)+
		dbra	d7,fh000		; do all the words
		move.l	a1,a0			
		move.w	#31,d7			; 32 lines to reverse			
fh020		movem.l	(a0),d0-d3		; get a line
		movem.l	d2-d3,(a0)
		movem.l	d0-d1,8(a0)		; reverse the 16 bits
		lea	16(a0),a0		; next line
		dbra	d7,fh020		; do all the lines
		jsr	expand
		rts

rotate		subq.w	#1,scr_delay
		bmi.s	rot_start
		rts
rot_start	move.w	#3,scr_delay
		move.l	char_pntr,a0
		lea	copy2,a1		; buffered destination
		move.w	#31,d7			; 32 lines to clear
rot000		clr.l	(a1)+
		clr.l	(a1)+
		clr.l	(a1)+
		clr.l	(a1)+
		dbra	d7,rot000
		move.l	a0,-(sp)		; save pointer
		move.w	#31,d7			; 32 lines of data to do
		move.l	#$00000001,d6		; or data			
rot010		clr.l	d0			; bit plane data
		move.w	(a0),d0			; get 1st bit plane
		swap	d0
		add.w	8(a0),d0		; make total
		move.w	#31,d5			; 32 bits to manipulate
		lea	copy2,a1		; destination area
rot020		lsl.l	#1,d0			; get bit status in carry
		bcc.s	rot030			; skip if no or
		or.w	d6,8(a1)		; 2nd half
		swap	d6
		or.w	d6,(a1)			; 1st half
		swap	d6
rot030		lea	16(a1),a1		; next line down
		dbra	d5,rot020		; do all the bits
rot040		clr.l	d0			; bit plane data
		move.w	2(a0),d0		; get 2nd bit plane
		swap	d0
		add.w	10(a0),d0		; make total
		move.w	#31,d5			; 32 bits to manipulate
		lea	copy2,a1		; destination area
rot050		lsl.l	#1,d0			; get bit status in carry
		bcc.s	rot060			; skip if no or
		or.w	d6,10(a1)		; 2nd half
		swap	d6
		or.w	d6,2(a1)		; 1st half
		swap	d6
rot060		lea	16(a1),a1		; next line down
		dbra	d5,rot050		; do all the bits
rot070		clr.l	d0			; bit plane data
		move.w	4(a0),d0		; get 3rd bit plane
		swap	d0
		add.w	12(a0),d0		; make total
		move.w	#31,d5			; 32 bits to manipulate
		lea	copy2,a1		; destination area
rot080		lsl.l	#1,d0			; get bit status in carry
		bcc.s	rot090			; skip if no or
		or.w	d6,12(a1)		; 2nd half
		swap	d6
		or.w	d6,4(a1)		; 1st half
		swap	d6
rot090		lea	16(a1),a1		; next line down
		dbra	d5,rot080		; do all the bits
rot100		clr.l	d0			; bit plane data
		move.w	6(a0),d0		; get 4th bit plane
		swap	d0
		add.w	14(a0),d0		; make total
		move.w	#31,d5			; 32 bits to manipulate
		lea	copy2,a1		; destination area
rot110		lsl.l	#1,d0			; get bit status in carry
		bcc.s	rot120			; skip if no or
		or.w	d6,14(a1)		; 2nd half
		swap	d6
		or.w	d6,6(a1)		; 1st half
		swap	d6
rot120		lea	16(a1),a1		; next line down
		dbra	d5,rot110		; do all the bits
		lea	16(a0),a0		; next line of data
		lsl.l	#1,d6			; shift data
		dbra	d7,rot010		; do all the lines
		lea	copy2,a1		; point to rotated data
		move.l	(sp)+,a0		; destination
		move.w	#31,d7			; 32 lines of data
rot130		movem.l	(a1)+,d0-d3		; line of data
		movem.l	d0-d3,(a0)
		lea	16(a0),a0
		dbra	d7,rot130
		jsr	expand
		rts

mirror		tst.w	mir_delay		; delay up ?
		beq.s	mir000			; skip if it has
		subq.w	#1,mir_delay
		rts
mir000		move.w	#5,mir_delay
		addq.w	#1,edit_t		; change edit type
		cmp.w	#3,edit_t
		blo.s	mir010
		clr.w	edit_t
mir010		rts

set_colors	move.w	#$00ff,d3		; graphic character
		move.w	#0,d0			; x position
		move.w	#21,d1			; y position
		move.w	#0,d7			; colour number
scl000		movem.w	d0-d1/d7,-(sp)		; save vals
		move.l	scr1,a0			; get screen pointers
		move.l	scr1,a1
		mulu.w	#1280,d1		; y offset
		and.w	#$fffe,d0		; lose lsb
		lsl.w	#2,d0			; x offset
		add.w	d0,d1			; total offset
		add.w	d1,a0			; make screen pointer
		add.w	d1,a1			; make second screen pointer
		move.w	#3,d6			; loop counter for each plane
scl010		lsr.w	#1,d7			; get a bit plane on/off in carry
		bcc.s	scl020			; skip if do not set
		or.w	d3,(a0)
		or.w	d3,160(a0)
		or.w	d3,320(a0)
		or.w	d3,480(a0)
		or.w	d3,640(a0)
		or.w	d3,800(a0)
		or.w	d3,960(a0)
		or.w	d3,1120(a0)
		or.w	d3,(a1)
		or.w	d3,160(a1)
		or.w	d3,320(a1)
		or.w	d3,480(a1)
		or.w	d3,640(a1)
		or.w	d3,800(a1)
		or.w	d3,960(a1)
		or.w	d3,1120(a1)
scl020		lea	2(a0),a0		; next bit plane
		lea	2(a1),a1		; next bit plane
		dbra	d6,scl010		; check all 4 bit planes
		movem.w	(sp)+,d0-d1/d7		; recover position
		addq.w	#2,d0			; next colour position
		cmp.w	#16,d0			; end off row ?
		blo.s	scl030			; skip if not
		move.w	#0,d0			; reset x position
		addq.w	#2,d1			; next y position
scl030		addq.w	#1,d7			; next colour
		cmp.w	#16,d7			; done them all ?
		blo	scl000			; loop if not
		rts	


* print string routine.
* pointer to text supplied in a0, 1st byte is x start,2nd byte is
* y start. String terminated by null byte. No end of line wrap.
* writes to background screen and the hidden screen being updated.

print_text	movem.l	d0-d4/a1-a4,-(sp); save registers used
		move.l	scr1,a1		; background screen
		lea	font,a3		; font start
		clr.w	d0		; x location
		clr.w	d1		; y location
		move.b	(a0)+,d0
		move.b	(a0)+,d1	; get print co-ords
		and.w	#$fffe,d0	; clear lsb
		lsl.w	#2,d0		; effective * 8
		mulu.w	#1280,d1	; y offset 8*160 per line down
		add.w	d0,d1		; total offset
		add.l	d1,a1		; make screen pointer
		clr.w	d0
		move.b	-2(a0),d0	; x location
pt010		clr.w	d1		; character buildup
		move.b	(a0)+,d1	; get a character 
		beq.s	pt_end		; exit if no more text
		sub.b	#' ',d1		; normalise it
		lsl.w	#5,d1		; *32 to make character offset
		lea	0(a3),a4	; start of characters
		add.w	d1,a4		; pointer to character
		btst	#0,d0		; get odd/even bit in carry flag
		bne.s	pt020		; skip if in odd position
		jsr	plot_even	; plot the even character
		addq.w	#1,d0		; next x position
		bra.s	pt010		; and loop
pt020		jsr	plot_odd	; plot in odd position
		addq.w	#1,d0		; next x location
		bra.s	pt010		; and loop
pt_end		movem.l	(sp)+,d0-d4/a1-a4
		rts			; return,all done

plot_even	movem.l	(a4)+,d1-d4
		movep.l	d1,(a1)
		movep.l	d2,160(a1)
		movep.l	d3,320(a1)
		movep.l	d4,480(a1)
		movem.l	(a4)+,d1-d4
		movep.l	d1,640(a1)
		movep.l	d2,800(a1)
		movep.l	d3,960(a1)
		movep.l	d4,1120(a1)
		rts			; return, all done

plot_odd	movem.l	(a4)+,d1-d4
		movep.l	d1,1(a1)
		movep.l	d2,161(a1)
		movep.l	d3,321(a1)
		movep.l	d4,481(a1)
		movem.l	(a4)+,d1-d4
		movep.l	d1,641(a1)
		movep.l	d2,801(a1)
		movep.l	d3,961(a1)
		movep.l	d4,1121(a1)
		lea	8(a1),a1
		rts
			
plot_desc	move.l	leftp,a0		; left button text
		jsr	print_text
		move.l	rightp,a0
		jsr	print_text
		rts

* call with pointer to block look up table in a6.
* 1st long word contains no of lines to be plotted
plot_block	move.l	(a6)+,d7		; number of lines to dbra+1
		subq.w	#1,d7
pb000		move.l	(a6)+,a0		; line pointer
		jsr	print_text		; print the line of text
		dbra	d7,pb000		; do them all
		rts

ml000		lea	mouse_loc,a0
		movem.w	mouse_x,d0-d1		; mouse x,y
		move.b	m_buttons,d4
		lsr.w	#3,d0			; / 8
		lsr.w	#3,d1			; / 8
		movem.w	d0-d1,fs_x
		clr.w	d2
		clr.w	d3
		addq.w	#1,d0
		addq.w	#1,d1
		cmp.w	#28,d0			; need to be plotted ?
		bgt.s	lm040			; skip if erase
lm010		cmp.w	#10,d0
		blo.s	lm020
		sub.w	#10,d0
		addq.w	#1,d2
		bra.s	lm010
lm020		cmp.w	#10,d1
		blo.s	lm030
		sub.w	#10,d1
		addq.w	#1,d3
		bra.s	lm020
lm030		add.b	#'0',d0
		add.b	#'0',d1
		add.b	#'0',d2
		add.b	#'0',d3
		move.b	d2,6(a0)		; x tens
		move.b	d0,7(a0)		; x ones
		move.b	d3,13(a0)		; y tens
		move.b	d1,14(a0)		; y ones
		jsr	print_text
		rts
lm040		lea	mouse_ers,a0		; erase text
		jsr	print_text
		rts
						
init_load	move.w	#10,-(sp)		; DRVMAP call
		trap	#13
		lea	2(sp),sp		; restore stack
		lea	ltable+28,a0		; point to table
		move.b	#'A',d1			; drive character
		clr.w	d2			; drives count
il000		lsr.w	#1,d0			; get drive status bit
		bcc.s	il010			; skip if no more drives
		move.l	(a0)+,a1		; pointer to line
		move.b	#'b',24(a1)		; right arrow character
		move.b	d1,25(a1)		; drive character
		move.b	#'a',26(a1)		; left arrow character
		addq.w	#1,d1			; next drive letter
		addq.w	#1,d2			; count an attached drive
		bra.s	il000			; check all drives
il010		move.w	d2,drives		; save number of attached drives
		move.w	#$19,-(sp)		; get current drive
		trap	#1
		lea	2(sp),sp
		add.b	#'A',d0			; make drive letter
		move.b	d0,drive		; save current drive
		move.w	#$2f,-(sp)		; get DTA call
		trap	#1
		lea	2(sp),sp	
		move.l	d0,dta			; dta address start
		clr.w	-(sp)			; current drive
		pea	pathname		; buffer area
		move.w	#$47,-(sp)		; GETDIR call
		trap	#1
		lea	8(sp),sp		; restore stack
		tst.b	pathname		; top directory ?
		bne.s	il020			; skip if not
		move.b	#'\',pathname		; else insert a backslash
		clr.b	pathname+1		; end the string
il020		rts

draw_map	jsr	vsync_wait
		lea	available,a0		; display map ?
		move.w	map,d0
		tst.b	(a0,d0.w)		; map available ?
		bne	no_good2		; skip if not
		add.b	#'A',d0			; make map character
		move.b	d0,es+8
		lea	timea,a0		; map times
		add.w	map,a0			; make pointer
		add.w	map,a0
		move.l	a0,timepntr		; save it
		jsr	con_time		; make the string
		move.w	map,d0			; map number
		lsl.w	#3,d0			; *8 to make password offset
		lea	passa,a0		; start of passwords
		add.w	d0,a0			; correct password
		lea	es+21,a1		; where to put the data
		rept	8
		move.b	(a0)+,(a1)+		; copy it in
		endr
		move.l	lvl_pntr,a0		; point to level data
		move.w	#23,d6			; 24 lines to do
dm000		move.w	#23,d1			; y value
		sub.w	d6,d1			; normalise
		jsr	print_icons		; plot a line
		dbra	d6,dm000		; do all the lines

		lea	drm_stuff,a6		; to plot all required
		jsr	plot_block
		jsr	vsync_wait
		move.l	lvl_pntr,a0
		move.w	#23,d6			; 24 lines to do
dm010		move.w	#23,d1			; y value
		sub.w	d6,d1			; normalise
		jsr	print_icons		; plot a line
		dbra	d6,dm010
		lea	drm_stuff,a6
		jsr	plot_block
		jsr	count_level		; count number of each icon
		rts

draw_single	lea	available,a0		; display map ?
		move.w	map,d0
		tst.b	(a0,d0.w)		; map available ?
		bne	no_good			; skip if not
		add.b	#'A',d0			; make map character
		move.b	d0,es+8
		lea	timea,a0		; map times
		add.w	map,a0			; make pointer
		add.w	map,a0
		move.l	a0,timepntr		; save it
		jsr	con_time		; make the string
		move.w	map,d0			; map number
		lsl.w	#3,d0			; *8 to make password offset
		lea	passa,a0		; start of passwords
		add.w	d0,a0			; correct password
		lea	es+21,a1		; where to put the data
		rept	8
		move.b	(a0)+,(a1)+		; copy it in
		endr
		move.l	lvl_pntr,a0		; point to level data
		move.w	#23,d6			; 24 lines to do
dsin000		move.w	#23,d1			; y value
		sub.w	d6,d1			; normalise
		jsr	print_icons		; plot a line
		dbra	d6,dsin000		; do all the lines
		lea	drm_stuff,a6
		jsr	plot_block
		rts
		
no_good		add.b	#'A',d0			; make map character
		lea	question,a0		; question marks
		lea	es+21,a1		; where to put the data
		move.b	d0,-13(a1)
		rept	8
		move.b	(a0)+,(a1)+		; copy it in
		endr
		lea	unlu,a6			; unavailable text
		jsr	plot_block
		rts			

no_good2	add.b	#'A',d0			; make map character
		lea	question,a0		; question marks
		lea	es+21,a1		; where to put the data
		move.b	d0,-13(a1)
		rept	8
		move.b	(a0)+,(a1)+		; copy it in
		endr
		lea	unlu,a6			; unavailable text
		jsr	plot_block
		jsr	vsync_wait
		lea	unlu,a6			; unavailable text
		jsr	plot_block
		rts			

count_level	move.l	lvl_pntr,a0		; level data
		lea	placed,a1		; count data
		move.w	#39,d7			; clear old data
cl000		clr.w	(a1)+
		dbra	d7,cl000
		lea	placed,a1
		move.w	#671,d7			; check all of map
cl010		clr.w	d0			; clear bad data
		move.b	(a0)+,d0		; get icon data
		lsl.w	#1,d0			; * 2 for word offset
		addq.w	#1,(a1,d0.w)		; count the icon type
		dbra	d7,cl010		; count all the icons
		rts

plot_chars	tst.w	n2plot			; need to plot ?
		bne.s	pc_plot			; skip if we do
		rts
pc_plot		subq.w	#1,n2plot		; count a frame of plotting
		lea	chars,a0		; point to character data
		lea	chars,a1		; two characters
		move.w	left,d0			; left character
		move.w	right,d1		; right character
		lsl.w	#8,d0
		lsl.w	#1,d0			; * 512 to make offset
		lsl.w	#8,d1
		lsl.w	#1,d1			; * 512 to make offset
		add.w	d0,a0			; pointer to character 
		add.w	d1,a1			; pointer to character
		move.l	scr1,a2			; background screen
		lea	28432(a2),a2		; correct area
		jsr	plot_it2
		jsr	plot_desc
		jsr	clic
		jsr	scrnic
		rts

plot_it2	move.w	#31,d7			; 32 lines to plot
plc000		movep.l	(a0),d0
		movep.l	d0,1(a2)
		movep.l	(a1),d0			; 2nd characer
		movep.l	d0,25(a2)
		movep.l	1(a0),d0
		movep.l	d0,8(a2)
		movep.l	1(a1),d0
		movep.l	d0,32(a2)
		movep.l	8(a0),d0
		movep.l	d0,9(a2)
		movep.l	8(a1),d0
		movep.l	d0,33(a2)
		movep.l	9(a0),d0
		movep.l	d0,16(a2)
		movep.l	9(a1),d0
		movep.l	d0,40(a2)
		lea	16(a0),a0
		lea	16(a1),a1
		lea	160(a2),a2
		dbra	d7,plc000
		rts

print_icons	move.l	scr1,a1			; background screen
		lea	icons,a3		; font start
		mulu.w	#1280,d1		; y offset 8*160 per line down
		add.w	d1,a1			; make screen pointer
		clr.w	d0
pi010		cmp.w	#28,d0			; finished line ?
		bne.s	pi020
		rts
pi020		clr.w	d1			; character buildup
		move.b	(a0)+,d1		; get a character 
		lsl.w	#5,d1			; *64 to make character offset
		lea	0(a3),a4		; start of characters
		add.w	d1,a4			; pointer to character
		btst	#0,d0			; get odd/even bit in carry flag
		bne.s	pi030			; skip if in odd position
		jsr	plot_even		; plot the even character
		addq.w	#1,d0			; next x position
		bra.s	pi010			; and loop
pi030		jsr	plot_odd		; plot in odd position
		addq.w	#1,d0			; next x location
		bra.s	pi010			; and loop

pr_icons2	move.l	scr1,a1			; background screen
		lea	icons,a3		; font start
		mulu.w	#1280,d1		; y offset 8*160 per line down
		add.w	d1,a1			; make screen pointer
		clr.w	d0
		lea	-1(a5),a5
pi2010		lea	1(a5),a5
		cmp.w	#28,d0			; finished line ?
		blo.s	pi2020
		rts
pi2020		clr.w	d1			; character buildup
		move.b	(a0)+,d1		; get a character 
		cmp.b	(a5),d1			; different ?
		beq.s	pi2040			; skip if not
		move.b	d1,(a5)			; acknoledge change
		lsl.w	#5,d1			; *64 to make character offset
		lea	0(a3),a4		; start of characters
		add.w	d1,a4			; pointer to character
		btst	#0,d0			; get odd/even bit in carry flag
		bne.s	pi2030			; skip if in odd position
		jsr	plot_even		; plot the even character
		addq.w	#1,d0			; next x position
		bra.s	pi2010			; and loop
pi2030		jsr	plot_odd		; plot in odd position
		addq.w	#1,d0			; next x location
		bra.s	pi2010			; and loop
pi2040		addq.w	#1,d0
		move.w	d0,d1
		lsr.w	#1,d1
		bcs	pi2010
		lea	8(a1),a1
		bra	pi2010

scrn_icons	move.l	scr1,a1
		lea	icons,a3
		lea	11640(a1),a1		; correct screen line
		move.w	#spirit1,d7		; max icon number
		clr.w	d6
si000		move.w	#spirit1,d0		; icon number
		sub.w	d7,d0			; adjust
		lsl.w	#5,d0			; *64 for offset
		lea	0(a3),a4		; start of character
		add.w	d0,a4			; correct character
		jsr	plot_even		; plot the icon
		lea	8(a1),a1		; next character position
		addq.w	#1,d6			; count a character
		cmp.w	#5,d6			; time to adjust pointers ?
		blo.s	si010			; skip if not
		lea	2520(a1),a1		; adjust
		clr.w	d6
si010		dbra	d7,si000
		rts

char_icons	move.l	scr1,a1
		lea	icons,a3
		lea	9032(a1),a1		; correct screen line
		move.w	#right6,d7		; max icon number
		clr.w	d6
ci000		move.w	#right6,d0		; icon number
		sub.w	d7,d0			; adjust
		lsl.w	#5,d0			; *64 for offset
		lea	0(a3),a4		; start of character
		add.w	d0,a4			; correct character
		jsr	plot_even		; plot the icon
		lea	8(a1),a1		; next character position
		addq.w	#1,d6			; count a character
		cmp.w	#11,d6			; time to adjust pointers ?
		blo.s	ci010			; skip if not
		lea	2472(a1),a1		; adjust
		clr.w	d6
ci010		dbra	d7,ci000
		rts

scrnic		move.l	scr1,a0
		move.l	scr1,a2			; screen pointers
		move.w	left,d0			; position number
		jsr	convert			; changes to x,y in d0,d1
		move.b	d0,leftc		; x co-ordinate
		move.b	d1,leftc+1		; y co-ordinate
		mulu.w	#1280,d1		; make y offset
		lsl.w	#2,d0			; mults of 8
		add.w	d0,d1			; total offset
		add.w	#632,d1			; adjust for square
		add.w	d1,a0
		move.w	right,d0		; position number
		jsr	convert
		move.b	d0,rightc
		move.b	d1,rightc+1
		mulu.w	#1280,d1
		lsl.w	#2,d0
		add.w	d0,d1
		add.w	#632,d1
		add.w	d1,a2
		jsr	plot_square
		lea	leftc,a0
		jsr	print_text
		lea	rightc,a0
		jsr	print_text
		rts

charic		move.l	scr1,a0
		move.w	ch_icon,d0		; position number
		jsr	conv2			; changes to x,y in d0,d1
		mulu.w	#1280,d1		; make y offset
		lsl.w	#2,d0			; mults of 8
		add.w	d0,d1			; total offset
		add.w	#632,d1			; adjust for square
		add.w	d1,a0
		add.w	d1,a1
		lea	0(a0),a2
		jsr	plot_square
		rts

			
clic		move.l	scr1,a0
		move.l	scr1,a2
		move.w	oleft,d0		; position number
		jsr	convert			; changes to x,y in d0,d1
		move.b	d0,clearch1		; y co-ordinate
		move.b	d1,clearch1+1		; y co-ordinate
		mulu.w	#1280,d1		; make y offset
		lsl.w	#2,d0			; mults of 8
		add.w	d0,d1			; total offset
		add.w	#632,d1			; adjust for square
		add.w	d1,a0
		move.w	oright,d0		; position number
		jsr	convert
		move.b	d0,clearch2
		move.b	d1,clearch2+1
		mulu.w	#1280,d1
		lsl.w	#2,d0
		add.w	d0,d1
		add.w	#632,d1
		add.w	d1,a2
		jsr	clr_square
		lea	clearch1,a0
		jsr	print_text
		lea	clearch2,a0
		jsr	print_text
		move.l	scr1,a0
		move.l	scr1,a2
		move.w	ooleft,d0		; position number
		jsr	convert			; changes to x,y in d0,d1
		move.b	d0,clearch1		; y co-ordinate
		move.b	d1,clearch1+1		; y co-ordinate
		mulu.w	#1280,d1		; make y offset
		lsl.w	#2,d0			; mults of 8
		add.w	d0,d1			; total offset
		add.w	#632,d1			; adjust for square
		add.w	d1,a0
		move.w	ooright,d0		; position number
		jsr	convert
		move.b	d0,clearch2
		move.b	d1,clearch2+1
		mulu.w	#1280,d1
		lsl.w	#2,d0
		add.w	d0,d1
		add.w	#632,d1
		add.w	d1,a2
		jsr	clr_square
		lea	clearch1,a0
		jsr	print_text
		lea	clearch2,a0
		jsr	print_text
		rts

chclic		move.l	scr1,a0
		move.l	scr1,a2
		move.w	ch_older,d0
		jsr	conv2			; changes to x,y in d0,d1
		mulu.w	#1280,d1		; make y offset
		lsl.w	#2,d0			; mults of 8
		add.w	d0,d1			; total offset
		add.w	#632,d1			; adjust for square
		add.w	d1,a0
		move.w	ch_old,d0		; position number
		jsr	conv2
		mulu.w	#1280,d1
		lsl.w	#2,d0
		add.w	d0,d1
		add.w	#632,d1
		add.w	d1,a2
		jsr	clr_square
		rts

convert		clr.w	d1
con000		cmp.w	#5,d0
		blo.s	con010		; skip if no more y counts
		addq.w	#2,d1		; next y position
		sub.w	#5,d0
		bra.s	con000
con010		lsl.w	#1,d0		; * 2
		add.w	#30,d0		; x adjust
		add.w	#08,d1		; y adjust
		rts

conv2		clr.w	d1
con2000		cmp.w	#11,d0
		blo.s	con2010			; skip if no more y counts
		addq.w	#2,d1			; next y position
		sub.w	#11,d0
		bra.s	con2000
con2010		lsl.w	#1,d0			; * 2
		add.w	#18,d0			; x adjust
		add.w	#06,d1			; y adjust
		rts
			
plot_square	movem.l	ic_cursor,d0-d3		; graphic char data
		move.w	#1,d7
ps000		or.l	d0,(a0)
		or.l	d0,4(a0)
		or.l	d0,(a2)
		or.l	d0,4(a2)
		or.l	d1,8(a0)
		or.l	d1,12(a0)
		or.l	d1,8(a2)
		or.l	d1,12(a2)
		lea	160(a0),a0
		lea	160(a2),a2
		dbra	d7,ps000
		move.w	#11,d7
ps010		or.l	d2,(a0)
		or.l	d2,4(a0)
		or.l	d2,(a2)
		or.l	d2,4(a2)
		or.l	d3,8(a0)
		or.l	d3,12(a0)
		or.l	d3,8(a2)
		or.l	d3,12(a2)
		lea	160(a0),a0
		lea	160(a2),a2
		dbra	d7,ps010
		move.w	#1,d7
ps020		or.l	d0,(a0)
		or.l	d0,4(a0)
		or.l	d0,(a2)
		or.l	d0,4(a2)
		or.l	d1,8(a0)
		or.l	d1,12(a0)
		or.l	d1,8(a2)
		or.l	d1,12(a2)
		lea	160(a0),a0
		lea	160(a2),a2
		dbra	d7,ps020
		rts			

clr_square	movem.l	ic_cursor,d0-d3		; graphic char data
		not.l	d0
		not.l	d1
		not.l	d2
		not.l	d3
		move.w	#1,d7
cs000		and.l	d0,(a0)
		and.l	d0,4(a0)
		and.l	d0,(a2)
		and.l	d0,4(a2)
		and.l	d1,8(a0)
		and.l	d1,12(a0)
		and.l	d1,8(a2)
		and.l	d1,12(a2)
		lea	160(a0),a0
		lea	160(a2),a2
		dbra	d7,cs000
		move.w	#11,d7
cs010		and.l	d2,(a0)
		and.l	d2,4(a0)
		and.l	d2,(a2)
		and.l	d2,4(a2)
		and.l	d3,8(a0)
		and.l	d3,12(a0)
		and.l	d3,8(a2)
		and.l	d3,12(a2)
		lea	160(a0),a0
		lea	160(a2),a2
		dbra	d7,cs010
		move.w	#1,d7
cs020		and.l	d0,(a0)
		and.l	d0,4(a0)
		and.l	d0,(a2)
		and.l	d0,4(a2)
		and.l	d1,8(a0)
		and.l	d1,12(a0)
		and.l	d1,8(a2)
		and.l	d1,12(a2)
		lea	160(a0),a0
		lea	160(a2),a2
		dbra	d7,cs020
		rts			
			
show_transporters
		lea	available,a0		; display map ?
		move.w	map,d0
		tst.b	(a0,d0.w)		; map available ?
		beq.s	st_ok			; skip if not
		rts
st_ok		subq.w	#1,tcount		; change from letters to chars ?
		bne.s	st000			; skip if not
		not.w	trans_ch
		move.w	#25,tcount
st000		move.l	lvl_pntr,a6
		add.w	#28*24,a6		; point to transporter data
		move.w	#3,d7			; 4 transporters to do
		tst.w	trans_ch		; letters or icons
		beq.s	st030
		move.b	#'A',d6			; letter for transporter
st010		lea	ts_txt,a0		; transporter text
		move.w	(a6),d0			; get source co-ordinates
		bmi.s	st020			; skip if do not plot
		move.b	d6,2(a0)		; letter to print
		move.w	d0,(a0)			; co-ordinates to print at
		jsr	print_text		; print character
		lea	ts_txt,a0		; transporter text
		move.w	2(a6),(a0)		; destination co-ordinates
		jsr	print_text		; print character
		addq.w	#1,d6			; next letter
st020		lea	4(a6),a6		; next transporter data
		dbra	d7,st010		; do all 4 transporters
		rts
st030		move.w	(a6),d0			; get source location
		bmi.s	st040			; skip if dud
		clr.w	d1
		move.b	d0,d1			; y location
		lsr.w	#8,d0			; x location
		jsr	plot_one		; old character			
		move.w	2(a6),d0		; destination location
		clr.w	d1
		move.b	d0,d1			; y location
		lsr.w	#8,d0			; x location
		jsr	plot_one		; old character			
st040		lea	4(a6),a6
		dbra	d7,st030
		rts
			
plot_one	move.w	d4,-(sp)
		move.w	d1,d2			; copy y location
		mulu.w	#28,d2			; y offset
		add.w	d0,d2			; total offset
		move.l	lvl_pntr,a1		; point to data
		lea	icons,a4		; character dada
		clr.w	d3
		move.b	(a1,d2.w),d3		; icon to plot
		lsl.w	#5,d3			; * 32 for char offset
		add.w	d3,a4
		move.l	scr1,a1
		mulu.w	#1280,d1
		move.w	d0,d2
		and.w	#$fffe,d2
		lsl.w	#2,d2
		add.w	d2,d1
		add.w	d1,a1
		lsr.w	#1,d0
		bcs.s	plo000
		jsr	plot_even
		move.w	(sp)+,d4
		rts
plo000		jsr	plot_odd
		move.w	(sp)+,d4
		rts
			
clr_cursor	lea	available,a0		
		move.w	map,d0
		tst.b	(a0,d0.w)		; map available ?
		beq.s	clc_ok			; skip if not
		rts
clc_ok		movem.w	oocursor,d0-d1
		cmp.w	#28,d0
		bge.s	clc000
		jsr	plot_one
clc000		tst.w	erase			; need to plot change to map ?
		beq.s	clc010			; skip if not
		clr.w	erase
		movem.w	erase+2,d0-d1		; map location
		cmp.w	#28,d0			; in the map ?
		bge.s	clc005			; skip if not
		jsr	plot_one		; plot the correct icon
clc005		movem.w	erase+6,d0-d1		; old transporter letter
		cmp.w	#28,d0			; in the map ?
		bge.s	clc010			; skip if not
		jsr	plot_one
clc010		rts
			
plt_cursor	lea	available,a0		; display map ?
		move.w	map,d0
		tst.b	(a0,d0.w)		; map available ?
		beq.s	pc_ok			; skip if not
		rts
pc_ok		move.l	ocursor,oocursor
		movem.w	cursor_x,d0-d1
		movem.w	d0-d1,ocursor
		cmp.w	#28,d0			; plot it ?
		blo.s	pc000
		rts
pc000		lea	icons+cursor*4*8,a4	; character data
		move.l	scr1,a2
		mulu.w	#1280,d1
		move.w	d0,d2
		and.w	#$fffe,d2
		lsl.w	#2,d2
		add.w	d2,d1
		add.w	d1,a2
		lsr.w	#1,d0
		bcs.s	pc030
		move.w	#7,d7
pc020		move.l	(a4)+,d0
		or.b	d0,(a2)
		or.b	d0,2(a2)
		or.b	d0,4(a2)
		or.b	d0,6(a2)
		lea	160(a2),a2
		dbra	d7,pc020
		rts
pc030		move.w	#7,d7
pc040		move.l	(a4)+,d0
		or.b	d0,1(a2)
		or.b	d0,3(a2)
		or.b	d0,5(a2)
		or.b	d0,7(a2)
		lea	160(a2),a2
		dbra	d7,pc040
		rts

*
* routine calulates the editor codes
*
calc_codes	move.w	#7,d5			; 8 maps to do
		lea	maps,a0			; map data
		lea	codes,a1		; store values here
cc0000		clr.l	d0			; build in d0.l
		move.w	#23,d4			; 24 lines in height
cc0010		move.w	#27,d3			; 28 chars per line
		clr.w	d1
cc0020		clr.w	d2
		move.b	(a0),d2			; get a position value
		mulu.w	d1,d2			; make a value
		add.l	d2,d0			; total it
		move.b	(a0)+,d1		; change mulu value
		dbra	d3,cc0020		; do all 28 in a line
		dbra	d4,cc0010		; do the whole line
		lea	16(a0),a0		; next map start
		tst.w	d0			; is it -ve ?
		bpl.s	cc0030			; skip if ok
		neg.w	d0			; make +ve
cc0030		cmp.w	#30000,d0		; in range ?
		blo.s	cc0040			; skip if ok
		sub.w	#30000,d0		; bring into range
		bra.s	cc0030			; do until ok
cc0040		move.w	d0,(a1)+		; save editor code
		dbra	d5,cc0000		; do them all
		rts
			
* call with setup as follows.
* program load_save as follows :
*   $00 - Load map file.
*   $01 - Save map file.
*   $02 - Load chr file.
*   $03 - Save chr file.
* Used to look up in INSERT for correct strings and file size
* plus destination and source of data.
* i.e pntr1,pntr2,size,pntr3

disk_operations
		lea	ltable,a0		; load text look up table
		move.w	load_save,d0		; get load/save/map/chr setup
		lsl.w	#4,d0			; make correct offset into insert
		lea	insert,a1		; data table
		add.w	d0,a1			; add offset
		move.l	(a1)+,8(a0)		; adjust data pointer
		move.l	(a1),20(a0)		; adjust data pointer
		move.l	(a1)+,f_pntr		; save pointer for filename adjust
		move.l	(a1)+,file_size		; amount of data
		move.l	(a1),destination	; source/destination of data
		lea	map_files,a0		; assume map file
		btst.b	#1,load_save+1		; map or chr ?
		beq.s	do000			; skip if map operation
		lea	chr_files,a0		; adjust pointer
do000		move.l	a0,var_pntr		; save pointer
		jsr	find_files
		jsr	setup_table
		lea	ltable,a6		; point to load look up
		jsr	plot_block		; plot the table
		jsr	vsync_wait
		lea	ltable,a6
		jsr	plot_block
		btst.b	#0,load_save+1		; load or save operation ?
		beq	load_operation

save_operation
		jsr	encode_passwd
		move.l	f_pntr,a1		; screen text
		lea	s_fname,a2		; filename
		lea	15(a1),a1		; correct area
		move.w	#7,d7			; clear count
sop050		move.b	#' ',(a1)+		; erase a character
		move.b	#' ',(a2)+
		dbra	d7,sop050
		move.b	#'.',(a1)		; restore .
		clr.w	scursor
		clr.w	quit
sop000		jsr	vsync_wait
		jsr	new_disk
		jsr	save_keys
		jsr	plot_line
		jsr	save_mouse
		tst.w	quit
		beq.s	sop000
		jsr	vsync_wait
		jsr	decode_passwd
		rts
			
load_operation
		clr.w	file_number		; assume no file
		clr.w	quit			; loop until not zero
lop000		jsr	vsync_wait
		jsr	new_disk
		jsr	re_cat
		jsr	load_mouse
		tst.w	quit
		beq.s	lop000
		jsr	vsync_wait
		rts
			
re_cat		move.b	key_press,d0
		cmp.b	#' ',d0			; recatalog disk ?
		beq	nd010			; skip if we do
		rts
			
new_disk	cmp.b	#'C',drive		; drive A or B active ?
		blo.s	nd000			; skip if they are
		rts
nd000		clr.w	d0
		move.b	drive,d0
		sub.b	#'A',d0			; make drive number
		move.w	d0,-(sp)		; device number
		move.w	#9,-(sp)		; inquire media change
		trap	#13
		lea	4(sp),sp
		cmp.w	#2,d0			; definate diskette change ?
		bge.s	nd010			; skip if it was
		rts
nd010		clr.w	key_press
		jsr	find_files
		jsr	setup_table
		lea	ltable,a6		; point to load look up
		jsr	plot_block		; plot the table
		jsr	vsync_wait
		lea	ltable,a6
		jsr	plot_block
		rts

load_mouse	move.b	m_buttons,d0		; get button status
		lsr.w	#2,d0			; left button in carry
		bcs.s	ldm000			; skip if pressed
		rts
ldm000		movem.w	mouse_x,d0-d1		; get mouse co-ords
		lsr.w	#3,d0			; divide by 8
		lsr.w	#3,d1			; divide by 8
* check for scroll arrows first
		cmp.w	#17,d0			; correct x line ?
		beq	arrows_code		; same code for load/save
* check for cancel line
		cmp.w	#22,d1			; cancel y line ?
		beq	cancel_code		; same code for load/save
* check for change of drives
		cmp.w	#22,d0			; correct x distance
		bhs	drives_code		; same code for load/save
* check for change of directory
		cmp.w	#12,d1			; max y line
		bls	dir_code		; same code for load/save
* check for file selection
		cmp.w	#14,d1			; min y line
		bge.s	ldm010			; skip if ok
		rts
ldm010		move.w	#13,d2			; max y position
		add.w	files,d2		; make max y line
		cmp.w	d2,d1			; vaild line ?
		ble.s	ldm020			; skip if ok
		rts
ldm020		sub.w	#14,d1			; make file number
		add.w	file_offset,d1		; include window scroll
		cmp.w	#4,d0			; min x position
		bge.s	ldm030			; skip if ok
		rts
ldm030		cmp.w	#15,d0			; max x position
		ble.s	ldm040			; skip if ok
		rts
ldm040		move.w	#1,quit
		move.w	d1,file_number		; save filenumber to load
		mulu.w	#14,d1			; make offset
		lea	f_names,a0		; point to files
		add.w	d1,a0			; point to correct filename
* first open the file
		move.w	#$0,-(sp)		; file read only
		move.l	a0,-(sp)		; filename pointer
		move.w	#$3d,-(sp)		; OPEN call
		trap	#1
		lea	8(sp),sp
		tst.l	d0			; error ?
		bmi	load_error		; skip if there is
		move.w	d0,handle		; save file handle
* now read the data
		move.l	destination,-(sp)	; data destination
		move.l	file_size,-(sp)		; amount of data
		move.w	handle,-(sp)		; file handle
		move.w	#$3f,-(sp)		; READ call
		trap	#1
		lea	12(sp),sp
		tst.l	d0			; error ?
		bmi	load_error		; skip if ther is
* now close the file
		move.w	handle,-(sp)		; file handle
		move.w	#$3e,-(sp)		; CLOSE call
		trap	#1
		lea	4(sp),sp
		tst.l	d0			; error ?
		bmi	load_error		; skip if there is
		cmp.l	#5585,file_size		; loaded maps ?
		bne.s	ldm050
		jsr	decode_passwd
ldm050		rts
	
load_error	lea	unk_lu,a6		; assume unknown error
		move.w	#num_errs-1,d7		; loop count
		lea	err_lu,a5		; search table
lse000		cmp.w	2(a5),d0		; found right error ?
		bne.s	lse010			; skip if not
		move.l	4(a5),a6		; correct pointer
		bra.s	lse020			; display code
lse010		lea	8(a5),a5		; next table entry
		dbra	d7,lse000		; search tje whole table
lse020		move.l	a6,-(sp)		; save block pointer
		jsr	plot_block
		jsr	vsync_wait
		move.l	(sp)+,a6		; recover block pointer
		jsr	plot_block
		clr.w	quit
lse030		jsr	vsync_wait
		jsr	lse_mouse
		tst.w	quit
		beq.s	lse030
		clr.w	quit
		jsr	setup_table
		lea	ltable,a6		; point to load look up
		jsr	plot_block		; plot the table
		jsr	vsync_wait
		lea	ltable,a6
		jsr	plot_block
		rts
			
lse_mouse	btst.b	#0,m_buttons		; right button pressed ?
		bne.s	lse_check
		btst.b	#1,m_buttons
		bne.s	lse_check
		rts
lse_check	movem.w	mouse_x,d0-d1		; mouse co-ords
		lsr.w	#3,d0			; scale position
		lsr.w	#3,d1			; scale position
		cmp.w	#10,d1			; cancle line ?
		beq.s	lsec000			; skip if it is
		rts
lsec000		cmp.w	#5,d0			; min x position
		bge.s	lsec010			; skip if ok
		rts
lsec010		cmp.w	#12,d0			; max x position
		ble.s	lsec020			; skip if ok
		rts
lsec020		move.w	#1,quit			; signal comformation
		rts
			
save_mouse	btst.b	#1,m_buttons		; get button status
		bne.s	svm000			; skip if pressed
		rts
svm000		movem.w	mouse_x,d0-d1		; get mouse co-ords
		lsr.w	#3,d0			; divide by 8
		lsr.w	#3,d1			; divide by 8
		tst.w	d0			; protection change ?
		beq	prot_check		; skip if it is
		clr.w	pro_count		; clear counter
* check for scroll arrows first
		cmp.w	#17,d0			; correct x line ?
		beq	arrows_code		; same code for load/save
* check for cancel line
		cmp.w	#22,d1			; cancel y line ?
		beq	cancel_code		; same code for load/save
* check for change of drives
		cmp.w	#22,d0			; correct x distance
		bhs	drives_code		; same code for load/save
* check for change of directory
		cmp.w	#12,d1			; max y line
		bls	dir_code		; same code for load/save
* check for file selection
		cmp.w	#14,d1			; min y line
		bhs	svm010			; skip if valid
		rts
svm010		move.w	#13,d2			; max y position
		add.w	files,d2		; make max y line
		cmp.w	d2,d1			; vaild line ?
		ble.s	svm020			; skip if ok
		rts
svm020		sub.w	#14,d1			; make file number
		add.w	file_offset,d1		; include window scroll
		cmp.w	#4,d0			; min x position
		bge.s	svm030			; skip if ok
		rts
svm030		cmp.w	#15,d0			; max x position
		ble.s	svm040			; skip if ok
		rts
svm040		lea	f_names,a0		; point to filenames
		mulu.w	#14,d1			; make offset
		add.w	d1,a0			; point to selected name
		move.l	f_pntr,a1		; screen text
		lea	s_fname,a2		; filename
		lea	15(a1),a1		; correct area
		move.w	#7,d7			; clear count
svm050		move.b	#' ',(a1)+		; erase a character
		move.b	#' ',(a2)+
		dbra	d7,svm050
svm060		move.l	f_pntr,a1		; recover pointer
		lea	s_fname,a2		; filname
		lea	15(a1),a1		; correct area
		move.b	#'.',8(a1)		; restore .
		clr.w	scursor			; reset cursor count
svm070		move.b	(a0)+,d0		; get a character of filename
		cmp.b	#' ',d0			; at end ?
		beq.s	svm080			; skip if at end
		cmp.b	#'.',d0			; at end ?
		beq.s	svm080			; skip if at end
		move.b	d0,(a1)+		; insert character
		move.b	d0,(a2)+		; insert character
		addq.w	#1,scursor		; move cursor
		bra.s	svm070			; loop until end of string
svm080		rts

prot_check	tst.w	d1			; correct location ?
		beq.s	prc000			; skip if ok
		clr.w	pro_count		; clear counter
		rts
prc000		addq.w	#1,pro_count		; count a 50th of a sec
		cmp.w	#250,pro_count		; timer expired ?
		bge.s	prc010			; skip if it is
		rts
prc010		clr.w	pro_count		; clear counter
		not.b	protect			; change the protection byte
		rts

save_keys	btst.b	#1,load_save+1		; saveing a map ?
		bne.s	sk_start		; skip if not
		lea	lt6_off,a0		; assume protection off
		tst.b	protect			; protection on ?
		beq.s	pro_stat		; skip if off
		lea	lt6_on,a0		; protection text
pro_stat	jsr	print_text		; print status
sk_start	move.b	key_press,d0
		tst.w	d0
		bne.s	sk000			; skip if key 
		rts
sk000		clr.w	key_press
		cmp.b	#' ',d0			; re-catalog disk ?
		beq	nd010			; skip if we do
		lea	valid_chars,a0		; valid characters
sk020		move.b	(a0)+,d1		; get a valid character
		beq.s	sk030			; skip if end of list
		cmp.b	d0,d1			; got a valid character ?
		beq.s	sk040
		bra.s	sk020			; loop until found or exit
sk030		rts
sk040		cmp.w	#enter_key,d0		; pressed enter ?
		beq	sk_enter		; skip if we have
		cmp.w	#delete_key,d0		; pressed delete ?
		beq	sk_delete		; skip if we have
		cmp.w	#escape_key,d0		; pressed escape ?
		beq	sk_escape		; skip if we have
* ordinary character
		lea	s_fname,a0		; point to text
		move.l	f_pntr,a1		; display text
		move.w	scursor,d1		; get cursor position
		cmp.w	#8,d1			; room to insert character ?
		blo.s	sk050			; skip if there is
		rts
sk050		move.b	d0,(a0,d1.w)		; insert the new character
		move.b	d0,15(a1,d1.w)		; on display line as well
		addq.w	#1,scursor		; move the cursor
		clr.w	schar			; make cursor visiable
		move.w	#25,sflash		; reset flash count
		rts
			
sk_delete	tst.w	scursor			; room to delete ?
		bne.s	skd000			; skip if there is
		rts
skd000		lea	s_fname,a0		; filename
		move.l	f_pntr,a1		; display text
		subq.w	#1,scursor		; pull cursor back one
		move.w	scursor,d0		; cursor position
		move.b	#' ',(a0,d0.w)		; erase oldest character
		move.b	#' ',16(a1,d0.w)	; erase old cursor
		cmp.w	#7,d0			; on the . ?
		blo.s	skd010			; skip if not
		move.b	#'.',16(a1,d0.w)	; restore the .
skd010		move.w	#25,sflash
		clr.w	schar
		rts
			
sk_enter	tst.w	scursor			; > 0 characters in name ?
		bne.s	ske000			; skip if there is
		rts
ske000		move.w	#1,quit			; signal exit
* save the file
		lea	s_fname,a0		; filename
		move.w	scursor,d0		; get cursor position
		add.w	d0,a0			; point to extention start
		move.l	#'PAM.',d1		; assume .map extention
		btst.b	#1,load_save+1		; map operation ?
		beq.s	ske010			; skip if map
		move.l	#'RHC.',d1		; .chr extention
ske010		move.b	d1,(a0)+
		lsr.l	#8,d1
		move.b	d1,(a0)+
		lsr.l	#8,d1
		move.b	d1,(a0)+
		lsr.l	#8,d1
		move.b	d1,(a0)+		; insert extention
		clr.b	(a0)			; terminate with null byte
* first create the file
		move.w	#0,-(sp)		; read/write status
		pea	s_fname			; filename pointer
		move.w	#$3c,-(sp)		; CREATE file call
		trap	#1
		lea	8(sp),sp
		tst.w	d0			; error ?
		bmi	load_error		; skip if there is
		move.w	d0,handle		; save file handle
* write the data
		move.l	destination,-(sp)	; data source
		move.l	file_size,-(sp)		; amount of data
		move.w	handle,-(sp)		; file handle
		move.w	#$40,-(sp)		; WRITE call
		trap	#1
		lea	12(sp),sp
		tst.l	d0			; error ?
		bmi	load_error		; skip if there is
* close the file
		move.w	handle,-(sp)		; file handle
		move.w	#$3e,-(sp)		; CLOSE call
		trap	#1
		lea	4(sp),sp
		tst.l	d0			; error ?
		bmi	load_error		; skip if there is
* else all finished
		rts
			

sk_escape	move.l	f_pntr,a0		; screen text
		lea	s_fname,a1		; filename
		clr.w	scursor
		lea	15(a0),a0
		rept	8
		move.b	#' ',(a1)+
		move.b	#' ',(a0)+		; erase old characters
		endr
		move.b	#'.',(a0)
		move.w	#25,sflash
		clr.w	schar
		rts

plot_line	subq.w	#1,sflash		; time to change cursor ?
		bne.s	pl_ok			; skip if not
		move.w	#25,sflash		; reset count
		not.w	schar			; change cursor
pl_ok		move.l	f_pntr,a0		; get pointer to data
		move.w	scursor,d0		; cursor position
		move.b	#'>',d1			; assume on
		tst.w	schar			; cursor on/off ?
		beq.s	pl000			; skip if on
		move.b	#' ',d1			; else is a space
		cmp.w	#8,d0			; far right ?
		blo.s	pl000			; skip if ok
		move.b	#'.',d1			; else plot a .
pl000		move.b	d1,15(a0,d0.w)		; insert cursor
		jsr	print_text
		rts
			

arrows_code	cmp.w	#7,d1			; directory up arrow ?
		beq.s	dir_ua			; skip if it is
		cmp.w	#12,d1			; directory down arrow ?
		beq.s	dir_da			; skip if it is
		cmp.w	#14,d1			; files up arrow ?
		beq.s	file_ua			; skip if it is
		cmp.w	#21,d1			; files down arrow ?
		beq.s	file_da			; skip if it is
		rts				; not an arrow
			
dir_ua		tst.w	dir_offset		; if zero, cannot scroll
		bne.s	dua000			; skip if scroll
		rts
dua000		subq.w	#1,dir_offset		; change the offset
		bra.s	disk_update		; update the screen
			
dir_da		move.w	dirs,d0			; number of dirs found
		sub.w	dir_offset,d0		; make amount left
		cmp.w	#6,d0			; able to scroll ?
		bhi.s	dda000			; skip if we can
		rts
dda000		addq.w	#1,dir_offset		; change the offset
		bra.s	disk_update		; update the screen
		
file_ua		tst.w	file_offset		; if zero, cannot scroll
		bne.s	fua000			; skip if scroll
		rts
fua000		subq.w	#1,file_offset		; change the offset
		bra.s	disk_update		; update the screen
			
file_da		move.w	files,d0		; number of files found
		sub.w	file_offset,d0		; make amount left
		cmp.w	#8,d0			; able to scroll ?
		bhi.s	fda000			; skip if we can
		rts
fda000		addq.w	#1,file_offset		; change the offset
		bra	disk_update		; update the screen
			
disk_update	jsr	setup_table		; re-draw names etc..
		lea	ltable,a6		; point to load look up
		jsr	plot_block		; plot the table
		jsr	vsync_wait
		lea	ltable,a6		; update 2nd screen
		jsr	plot_block
		rts
			
cancel_code	cmp.w	#8,d0			; beyond word ?
		bls.s	cc000			; skip if ok
		rts
cc000		cmp.w	#1,d0			; in range ?
		bhs.s	cc010			; skip if ok
		rts
cc010		move.w	#1,quit			; signal exit
		rts
			
drives_code	cmp.w	#24,d0			; drive letters ?
		bls.s	dc000			; skip if ok
		rts
dc000		cmp.w	#7,d1			; top line ?
		bhs.s	dc010			; skip if ok
		rts
dc010		sub.w	#6,d1			; make drive number
		cmp.w	drives,d1		; in range ?
		ble.s	dc020			; skip if ok
		rts
dc020		subq.w	#1,d1			; make drive number
		move.w	d1,-(sp)		; selected drive
		move.b	#'\',pathname		; back to root directory
		clr.b	pathname+1		; end the string
		pea	pathname		; buffer area
		move.w	#$3b,-(sp)		; CHDIR call
		trap	#1
		lea	6(sp),sp		; restore stack
		move.w	(sp),d1
		add.b	#'A',d1			; drive letter
		move.b	d1,drive		; set letter in string
		move.w	#$e,-(sp)		; SETDRV call
		trap	#1
		lea	4(sp),sp
		jsr	find_files
		bra	disk_update		; update the screen

dir_code	cmp.w	#4,d0			; start of file/dir name ?
		bhs.s	dcd000			; skip if ok
		rts
dcd000		cmp.w	#15,d0			; end of file/dir name ?
		bls.s	dcd010			; skip if ok
		rts
dcd010		cmp.w	#7,d1			; beggining of dirs ?
		bhs.s	dcd020			; skip if ok
		rts
dcd020		sub.w	#7,d1			; make directory number
		add.w	dir_offset,d1		; add scroll amount
		cmp.w	dirs,d1			; in range ?
		blo.s	dcd030			; skip if valid dir
		rts
dcd030		lea	pathname,a0		; point to path string
dcd040		move.b	(a0)+,d0		; end of string ?
		beq.s	dcd050			; skip if we are
		bra.s	dcd040			; else find end
dcd050		lea	-1(a0),a0		; adjust pointer
		cmp.b	#'\',-1(a0)		; backslash preceding ?
		beq.s	dcd060			; skip if thier is
		move.b	#'\',(a0)+		; else insert one
dcd060		lea	dir_names,a1		; point to directory names
		mulu.w	#14,d1			; offset for correct dir
		add.w	d1,a1			; make pointer
dcd070		move.b	(a1)+,d0		; get a character
		beq.s	dcd080			; skip if end of string
		move.b	d0,(a0)+		; copy a character
		bra.s	dcd070			; do them all
dcd080		move.b	d0,(a0)			; zero byte at end
		pea	pathname			
		move.w	#$3b,-(sp)		; CHDIR call
		trap	#1
		lea	6(sp),sp
		clr.w	-(sp)			; current drive
		pea	pathname		; buffer area
		move.w	#$47,-(sp)		; GETDIR call
		trap	#1
		lea	8(sp),sp		; restore stack
		tst.b	pathname		; top directory ?
		bne.s	dcd090			; skip if not
		move.b	#'\',pathname		; else insert a backslash
		clr.b	pathname+1		; end the string
dcd090		jsr	find_files		; new directory
		bra	disk_update		; update the screen

load_file	move.w	#1,quit			; signal exit
		rts
			
find_files	clr.w	files			; no files yet
		clr.w	dirs			; no directories yet
		clr.w	dir_offset		; no scrolling done
		clr.w	file_offset

* first find and log all the directories
* sfirst for directories

		lea	dir_names,a6		; directory name data area			
		move.w	#$10,-(sp)		; search for dirs with *.*
		pea	star_dot		; search string
		move.w	#$4e,-(sp)		; sfirst call
		trap	#1
		lea	8(sp),sp		; restore stack
		tst.w	d0			; sub-directory found ?
		bmi.s	do_files		; skip if none found
			
		move.l	dta,a0
		lea	21(a0),a0		; point to file attribute
		cmp.b	#$10,(a0)		; is it a sub-directory ?
		bne.s	nextdir2		; skip if it is not
			
		move.l	dta,a0
		lea	30(a0),a0		; point to sub-directory name
		clr.w	d1			; number of characters copied
copy_name	move.b	(a0)+,d0		; get a byte of name
		beq.s	next_dir		; skip if end of filename
		move.b	d0,(a6)+		; save character
		addq.w	#1,d1			; count a character copied
		bra.s	copy_name		; do all characters

next_dir	move.b	d0,(a6)			; zero byte at end or string
		sub.w	d1,a6			; back to start of name
		addq.w	#1,dirs			; count a directory
		lea	14(a6),a6		; next sub-directory data area
* snext call
nextdir2	move.w	#$4f,-(sp)		; snext call
		trap	#1
		lea	2(sp),sp		; restore stack
		tst.w	d0			; found a sub-directory ?
		bmi.s	do_files		; skip if no more
			
		move.l	dta,a0
		lea	21(a0),a0		; point to file attribute
		cmp.b	#$10,(a0)		; is it a sub-directory ?
		bne.s	nextdir2		; skip if not
			
		clr.w	d1			; number of characters copied
		move.l	dta,a0
		lea	30(a0),a0		; point to sub-directry name
copy_name2	move.b	(a0)+,d0		; get a character
		beq.s	next_dir		; skip if end on name
		move.b	d0,(a6)+		; insert into buffer
		addq.w	#1,d1			; count a character
		bra.s	copy_name2		; do all of string

* now find the chr or map files.

do_files	move.w	#0,-(sp)		; normal files only
		move.l	var_pntr,-(sp)		; pointer to *.MAP or *.CHR
		move.w	#$4e,-(sp)		; sfirst call
		trap	#1
		lea	8(sp),sp		; restore stack
			
		tst.w	d0			; found a file ?
		bmi.s	find_exit		; skip if not

		lea	f_names,a6		; file name data
		addq.w	#1,files		; count the file
		move.l	dta,a0
		lea	30(a0),a0		; point to file name
		move.w	#12,d7			; 13 chars to copy
ff000		move.b	(a0)+,(a6)+		; copy a byte
		dbra	d7,ff000		; copy all of it
		lea	-13(a6),a6		; start of filename			

* now find all the other files

ff010		move.w	#$4f,-(sp)		; snext call
		trap	#1
		lea	2(sp),sp		; restore stack
		tst.w	d0			; found a file
		bmi.s	find_exit		; skip if got all
			
		addq.w	#1,files		; count a file
		lea	14(a6),a6		; next filename buffer
		move.l	dta,a0
		lea	30(a0),a0		; point to file name
		move.w	#12,d7			; 13 chars to copy
ff020		move.b	(a0)+,(a6)+		; copy a byte
		dbra	d7,ff020
		lea	-13(a6),a6		; start of filename
		bra.s	ff010			; get the next filename
find_exit	move.w	files,d0		; number of files
		lea	f_names,a0		; data area
		jsr	sort_names
		move.w	dirs,d0
		lea	dir_names,a0
		jsr	sort_names
		rts
			
sort_names	cmp.w	#1,d0			; any names to sort ?
		bgt.s	srtn000			; skip if there is
		rts
srtn000		lea	0(a0),a1		; get pointer to data
		move.w	d0,d7			; loop counter
		subq.w	#2,d7			; 1 less for dbra, 2 at a time
		clr.w	d6			; sort flag
srtn010		lea	0(a1),a2		; first filename
		lea	14(a1),a3		; second filename
		jsr	sort_it
		lea	14(a1),a1		; next filename
		dbra	d7,srtn010		; do all the names
		tst.w	d6			; all in order ?
		bne.s	srtn000			; loop if not
		rts
			
sort_it		move.w	#11,d5			; 12 characters per filename
srti000		move.b	(a2)+,d1		; get a character
		move.b	(a3)+,d2		; get a character
		cmp.b	d1,d2			; need to swap names ?
		blo.s	swap_them		; skip if we do
		cmp.b	d1,d2			; need to swap names ?
		bne.s	srti010
		dbra	d5,srti000		; loop if not
srti010		rts
swap_them	lea	0(a1),a2
		lea	14(a1),a3		; point to beginning again
		move.w	#13,d5			; 13 characters to copy
swt000		move.b	(a2),d1			; get a character
		move.b	(a3),(a2)+
		move.b	d1,(a3)+		; swap 1 character
		dbra	d5,swt000
		move.w	#1,d6			; signal had a swap
		rts
			
* first copy in all the sub-directory names
setup_table	lea	ltable+28,a0		; load table of pointers
		lea	dir_names,a6		; directory names
		clr.w	d1			; number of names plotted
		move.w	dirs,d7			; number of directories found
		beq.s	plot_dashes		; skip if no directories
		subq.w	#1,d7			; one less for dbra
		move.w	dir_offset,d2		; window scroll amount
		mulu.w	#14,d2			; each name assigned 14 chars
		add.w	d2,a6			; point to correct name
stb000		move.l	(a0)+,a1		; get pointer to line data
		move.b	#'q',4(a1)		; directory character
		lea	6(a1),a1		; place for name
		clr.w	d2			; characters copied counter
stb010		addq.w	#1,d2			; count a character copied
		move.b	(a6)+,d0		; get a character of name
		beq.s	stb020			; skip if last character
		move.b	d0,(a1)+		; copy in a character
		bra.s	stb010			; copy until null byte found
stb020		move.w	d2,d3			; stop off counter
stb025		cmp.w	#13,d3			; filled all characters ?
		bge.s	stb027			; skip if we have
		move.b	#' ',(a1)+		; insert a space
		addq.w	#1,d3			; count a character
		bra.s	stb025
stb027		sub.w	d2,a6			; point to start of name
		lea	14(a6),a6		; next name in list
		addq.w	#1,d1			; count a name plotted
		cmp.w	#6,d1			; plotted all 6 lines ?
		bge.s	plot_dashes		; skip if we have
		dbra	d7,stb000		; do all 6 lines
			
plot_dashes	cmp.w	#6,d1			; any blank lines ?
		bge.s	stb050			; skip if not
		move.w	#5,d7			; assume 6 lines to fill
		sub.w	d1,d7			; dbra number of lines to fill
stb030		move.l	(a0)+,a1		; pointer to line
		move.b	#' ',4(a1)		; erase possible dir char
		lea	6(a1),a1		; place for name
		move.w	#11,d2			; characters to copy counter
		lea	dash_line,a6		; characters to copy in
stb040		move.b	(a6)+,(a1)+		; copy a character
		dbra	d2,stb040		; copy a line
		dbra	d7,stb030		; do all blank lines

* now plot the filenames

stb050		lea	ltable+56,a0		; line look up table
		lea	f_names,a6		; filenames to plot
		clr.w	d1			; number of filesnames plotted
		move.w	files,d7		; number of filenames
		beq.s	dash2			; skip if no filenames
		subq.w	#1,d7			; one less for dbra
		move.w	file_offset,d2		; window scroll amount
		mulu.w	#14,d2			; each name is 20 characters
		add.w	d2,a6			; point to correct name
stb060		move.l	(a0)+,a1		; get pointer to line data
		lea	6(a1),a1		; place for filename
		clr.w	d2			; characters copied counter
stb070		addq.w	#1,d2			; count a character copied
		move.b	(a6)+,d0		; get a character of name
		beq.s	stb100			; skip if end of filname
		cmp.b	#'.',d0			; found the period ?
		bne.s	stb090			; skip if not
		move.w	d2,d3			; intermediate counter
stb080		cmp.w	#8,d3			; filled in whole name area ?
		bgt.s	stb090			; skip if we have
		move.b	#' ',(a1)+		; plot a space
		addq.w	#1,d3			; count a character
		bra.s   stb080			; fill in all spaces
stb090		move.b	d0,(a1)+		; copy in a character
		bra.s	stb070			; copy until null byte found
stb100		sub.w	d2,a6			; point to start of filename
		lea	14(a6),a6		; next filename in list
		addq.w	#1,d1			; count a filename plotted
		cmp.w	#8,d1			; plotted all 8 lines ?
		bge.s	dash2			; skip if we have
		dbra	d7,stb060		; do all 8 lines
			
dash2		cmp.w	#8,d1			; any blank lines ?
		bge.s	stb130			; skip if not
		move.w	#7,d7			; assume 8 lines to fill
		sub.w	d1,d7			; dbra number of lines to fill
stb110		move.l	(a0)+,a1		; pointer to line
		lea	6(a1),a1		; place for name
		move.w	#11,d2			; characters to copy counter
		lea	dash_line,a6		; characters to copy in
stb120		move.b	(a6)+,(a1)+		; copy a character
		dbra	d2,stb120		; copy a line
		dbra	d7,stb110		; do all blank lines

* print the path and the number of files.

stb130		btst.b	#0,load_save+1		; load operation ?
		bne.s	stb175			; skip if save operation
		move.w	files,d2		; ones count
		clr.w	d0			; 100's count
		clr.w	d1			; 10's count
stb140		cmp.w	#100,d2			; count the 100's
		blo.s	stb150			; none left ?
		addq.w	#1,d0			; count a 100
		sub.w	#100,d2
		bra.s	stb140			; count them all
stb150		cmp.w	#10,d2			; count the 10's
		blo.s	stb160			; none left ?
		addq.w	#1,d1			; count a ten
		sub.w	#10,d2
		bra.s	stb150			; count them all
stb160		add.b	#'0',d2			; correct character
		add.b	#'0',d1
		add.b	#'0',d0
		cmp.b	#'0',d0			; change leading '0' to space
		bne.s	stb170			; skip if not a zero
		move.b	#' ',d0			; change to space
		cmp.b	#'0',d1			; check next character
		bne.s	stb170			; skip if no change
		move.b	#' ',d1			; change to space
stb170		lea	lm2,a0			; no. files line
		lea	12(a0),a0		; correct area of line
		move.b	d0,(a0)+		; 100's
		move.b	d1,(a0)+		; 10's
		move.b	d2,(a0)			; 1's

stb175		move.w	#$19,-(sp)		; current disk call
		trap	#1
		lea	2(sp),sp		; restore stack
		add.b	#'A',d0			; convert to character
		move.b	d0,drive		; insert into string
			
		lea	lt4+13,a0		; pathname line
		lea	drive,a1		; point to drive letters
		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+		; copy in drive letter
		lea	pathname,a1		; point to pathname
		clr.w	d1
stb180		move.b	(a1)+,d0		; get a character
		beq.s	stb190			; skip if end of pathname
		addq.w	#1,d1			; count a character
		cmp.w	#11,d1			; filled all the space ?
		bhi.s	stb190			; skip if we have
		move.b	d0,(a0)+		; insert into table
		bra.s	stb180
stb190		cmp.w	#11,d1			; filled all the area ?
		bge.s	stb200			; skip if we ahve
		move.b	#' ',(a0)+		; insert a space
		addq.w	#1,d1
		bra.s	stb190
stb200		rts

colour_cursor
		move.w	colour_num,d2		; get colour number to plot around
		move.w	#0,d0			; x position
		move.w	#20,d1			; y poaition
		cmp.w	#7,d2			; colours 0 - 7
		ble.s	ccl000			; skip if it is
		addq.w	#2,d1			; next line down
		sub.w	#8,d2			; change colour number
ccl000		lsl.w	#1,d2			; col num * 2
		add.w	d2,d0			; make x position
		lea	arru,a0			; point to arrow up
		lea	arrd,a1			; point to arrow down
		lea	arrl,a2			; point to arrow left
		lea	arrr,a3			; point to arrow right
		move.b	d0,(a3)			; x position for arr r char
		move.b	d1,1(a1)		; y position for arr d char
		addq.w	#1,d0			; next x position
		addq.w	#1,d1			; next y position
		move.b	d0,(a0)			; x position arr u char
		move.b	d0,(a1)			; x opsition arr d char
		move.b	d1,1(a2)		; y position arr l char
		move.b	d1,1(a3)		; y position arr r char
		addq.w	#1,d0
		addq.w	#1,d1
		move.b	d0,(a2)			; x position arr l char
		move.b	d1,1(a0)		; y position arr u char
		jsr	print_text
		move.l	a1,a0
		jsr	print_text
		move.l	a2,a0
		jsr	print_text
		move.l	a3,a0
		jsr	print_text
		move.w	colour_num,d0
		lsl.w	#1,d0			; make offset
		lea	char_cols,a0		; point to colours
		add.w	d0,a0			; point to correct colour
		lea	red_lvl,a1		; red txt
		lea	green_lvl,a2		; green txt
		lea	blue_lvl,a3		; blue txt
		move.w	red,d0			; old values
		move.w	green,d1
		move.w	blue,d2
		move.b	#'~',2(a1,d0.w)
		move.b	#'~',2(a2,d1.w)
		move.b	#'~',2(a3,d2.w)		; erase old characters
		move.w	(a0),d0			; get colour data
		move.w	(a0),d1
		move.w	(a0),d2
		and.w	#$f00,d0		; red level
		and.w	#$0f0,d1		; green level
		and.w	#$00f,d2		; blue level
		lsr.w	#8,d0			; lower byte
		lsr.w	#4,d1			; lower byte
		movem.w	d0-d2,red		; save new values
		move.b	#'X',2(a1,d0.w)		; insert character
		move.b	#'X',2(a2,d1.w)
		move.b	#'X',2(a3,d2.w)
		lea	red_lvl,a0
		jsr	print_text
		lea	green_lvl,a0
		jsr	print_text
		lea	blue_lvl,a0
		jsr	print_text
		rts
			
erase_colour	tst.w	color_flag		; eraseing ?
		bne.s	ecc01			; skip if we are
		rts
ecc01		subq.w	#1,color_flag
		lea	arru,a0			; point to arrow up
		lea	arrd,a1			; point to arrow down
		lea	arrl,a2			; point to arrow left
		lea	arrr,a3			; point to arrow right
		move.b	#'i',2(a1)		; change arrow character
		move.b	#'i',2(a0)		; change arrow character
		move.b	#'j',2(a2)		; change arrow characters
		move.b	#'j',2(a3)
		move.w	old_num,d2		; get colour number to plot around
		move.w	#0,d0			; x position
		move.w	#20,d1			; y poaition
		cmp.w	#7,d2			; colours 0 - 7
		ble.s	ecc000			; skip if it is
		addq.w	#2,d1			; next line down
		sub.w	#8,d2			; change colour number
ecc000		lsl.w	#1,d2			; col num * 2
		add.w	d2,d0			; make x position
		move.b	d0,(a3)			; x position for arr r char
		move.b	d1,1(a1)		; y position for arr d char
		addq.w	#1,d0			; next x position
		addq.w	#1,d1			; next y position
		move.b	d0,(a0)			; x position arr u char
		move.b	d0,(a1)			; x opsition arr d char
		move.b	d1,1(a2)		; y position arr l char
		move.b	d1,1(a3)		; y position arr r char
		addq.w	#1,d0
		addq.w	#1,d1
		move.b	d0,(a2)			; x position arr l char
		move.b	d1,1(a0)		; y position arr u char
		jsr	print_text
		move.l	a1,a0
		jsr	print_text
		move.l	a2,a0
		jsr	print_text
		move.l	a3,a0
		jsr	print_text
		lea	arru,a0			; point to arrow up
		lea	arrd,a1			; point to arrow down
		lea	arrl,a2			; point to arrow left
		lea	arrr,a3			; point to arrow right
		move.w	older_num,d2		; get colour number to plot around
		move.w	#0,d0			; x position
		move.w	#20,d1			; y poaition
		cmp.w	#7,d2			; colours 0 - 7
		ble.s	ecc020			; skip if it is
		addq.w	#2,d1			; next line down
		sub.w	#8,d2			; change colour number
ecc020		lsl.w	#1,d2			; col num * 2
		add.w	d2,d0			; make x position
		move.b	d0,(a3)			; x position for arr r char
		move.b	d1,1(a1)		; y position for arr d char
		addq.w	#1,d0			; next x position
		addq.w	#1,d1			; next y position
		move.b	d0,(a0)			; x position arr u char
		move.b	d0,(a1)			; x opsition arr d char
		move.b	d1,1(a2)		; y position arr l char
		move.b	d1,1(a3)		; y position arr r char
		addq.w	#1,d0
		addq.w	#1,d1
		move.b	d0,(a2)			; x position arr l char
		move.b	d1,1(a0)		; y position arr u char
		jsr	print_text
		move.l	a1,a0
		jsr	print_text
		move.l	a2,a0
		jsr	print_text
		move.l	a3,a0
		jsr	print_text
		move.b	#'c',arru+2		; restore characters
		move.b	#'d',2(a1)		
		move.b	#'a',2(a2)		
		move.b	#'b',2(a3)		
		jsr	colour_cursor
		rts

*
* Upper left bit 0
* upper bit 1
* upper right bit 2
* left bit 3
* right bit 4
* lower left bit 5
* lower bit 6
* lower right bit 7
*
start_dir	move.w	d1,d4
		mulu.w	#28,d4
		add.w	d0,d4
		move.l	lvl_pntr,a5
		lea	sp_starts,a6
		add.w	d4,a5
		clr.w	d5
		tst.w	d0			; left hand side ?
		bne.s	std000
		or.w	#%00101001,d5
std000		tst.w	d1
		bne.s	std010
		or.w	#%00000111,d5
std010		cmp.w	#27,d0
		blo.s	std020
		or.w	#%10010100,d5
std020		cmp.w	#23,d1
		blo.s	std030
		or.w	#%11100000,d5
std030		btst	#0,d5
		bne.s	std040
		cmp.b	#empty,-29(a5)
		beq.s	std040
		cmp.b	#earth,-29(a5)
		beq.s	std040
		cmp.b	#spirit1,-29(a5)
		beq.s	std040
		or.w	#%00000001,d5
std040		btst	#1,d5
		bne.s	std050
		cmp.b	#empty,-28(a5)
		beq.s	std050
		cmp.b	#earth,-28(a5)
		beq.s	std050
		cmp.b	#spirit1,-28(a5)
		beq.s	std050
		or.w	#%00000010,d5
std050		btst	#2,d5
		bne.s	std060
		cmp.b	#empty,-27(a5)
		beq.s	std060
		cmp.b	#earth,-27(a5)
		beq.s	std060
		cmp.b	#spirit1,-27(a5)
		beq.s	std060
		or.w	#%00000100,d5
std060		btst	#3,d5
		bne.s	std070
		cmp.b	#empty,-1(a5)
		beq.s	std070
		cmp.b	#earth,-1(a5)
		beq.s	std070
		cmp.b	#spirit1,-1(a5)
		beq.s	std070
		or.w	#%00001000,d5
std070		btst	#4,d5
		bne.s	std080
		cmp.b	#empty,1(a5)
		beq.s	std080
		cmp.b	#earth,1(a5)
		beq.s	std080
		cmp.b	#spirit1,1(a5)
		beq.s	std080
		or.w	#%00010000,d5
std080		btst	#5,d5
		bne.s	std090
		cmp.b	#empty,27(a5)
		beq.s	std090
		cmp.b	#earth,27(a5)
		beq.s	std090
		cmp.b	#spirit1,27(a5)
		beq.s	std090
		or.w	#%00100000,d5
std090		btst	#6,d5
		bne.s	std100
		cmp.b	#empty,28(a5)
		beq.s	std100
		cmp.b	#earth,28(a5)
		beq.s	std100
		cmp.b	#spirit1,28(a5)
		beq.s	std100
		or.w	#%01000000,d5
std100		btst	#7,d5
		bne.s	std110
		cmp.b	#empty,29(a5)
		beq.s	std110
		cmp.b	#earth,29(a5)
		beq.s	std110
		cmp.b	#spirit1,29(a5)
		beq.s	std110
		or.w	#%10000000,d5
std110		move.b	(a6,d5.w),d5
		rts

play_test	lea	available,a0		; display map ?
		move.w	map,d7
		tst.b	(a0,d7.w)		; map available ?
		beq.s	play_ok			; skip if it is
		rts
play_ok		jsr	fade_out
		jsr	build_level_data
		lea	test_lu,a6		; screen pointers
		jsr	plot_block		; blot the lot
		jsr	plot_play
		jsr	vsync_wait		; next screen
		lea	test_lu,a6
		jsr	plot_block
		not.w	screen_choice		; change buffers
		jsr	plot_play
		jsr	fade_in
		
play_loop	jsr	vsync_wait
		jsr	move_man
		clr.w	key_press
		cmp.w	#1234,d0		; done an iteration ?
		bne.s	plop0000
		jsr	sort_rocks
		jsr	kill_monsters
		jsr	do_rocks
		jsr	do_weed
		jsr	do_monsters
		jsr	do_pulsators
		jsr	kill_monsters
		tst.w	play_time		; time over ?
		beq.s	plop0000		; skip if 0
		subq.w	#1,play_time
plop0000	jsr	plot_play
		
		not.w	screen_choice		; change buffers
		tst.b	keys+$01		; pressed escape ?
		beq.s	play_loop		; loop if not
		clr.w	key_press

play_exit	jsr	fade_out
		jsr	restore_screen
		jsr	fade_in
		rts

build_level_data
		clr.w	num_rocks
		clr.w	num_weed
		clr.w	num_monsters
		clr.w	num_collect
		move.l	timepntr,a0		; points to time data
		move.w	(a0),play_time
		move.w	(a0),reset_time
*
* Copy the map data into the test level, and setup the rock,
* pulsator, monster and weed tables
*
		lea	copy_level,a0
		lea	copy_level2,a1
		move.w	#671,d7
bld_clear	clr.b	(a0)+
		clr.b	(a1)+
		dbra	d7,bld_clear
		
		move.l	lvl_pntr,a0		; map data
		lea	test_level+31,a1	; test level data
		move.w	#1,d0			; x position
		move.w	#1,d1			; y position
		lea	rock_data,a2		; rock data
		lea	weed_data,a4		; weed data
		lea	monster_data,a5		; monster data
		move.l	#$00010001,man_x	; default fred start
		move.w	#23,d7			; 24 rows to copy
bld0000		move.b	(a0)+,d2		; get a position
		cmp.b	#rock,d2		; found a rock ?
		bne.s	bld0010			; skip if not
		move.w	d0,(a2)+		; save rock position data
		move.w	d1,(a2)+
		move.w	#0,(a2)+
		addq.w	#1,num_rocks		; count the rock
bld0010		
bld0020		cmp.b	#weed,d2		; found some weed ?
		bne.s	bld0030			; skip if not
		move.w	d0,(a4)+
		move.w	d1,(a4)+
		move.w	#$ffff,(a4)+
		addq.w	#1,num_weed
bld0030		cmp.b	#egg,d2			; found an egg ?
		bne.s	bld0040			; skip if not
		move.w	d0,(a5)+
		move.w	d1,(a5)+
		move.w	#0,(a5)+
		addq.w	#1,num_monsters
		addq.w	#1,num_collect		; one to collect
bld0040		cmp.b	#spirit1,d2		; found a pulsator ?
		bne.s	bld0050			; skip if not
		addq.w	#1,num_collect		; one to collect
		clr.w	d2			; dont inster into map
bld0050		cmp.b	#fred,d2		; found fred ?
		bne.s	bld0060			; skip if not
		movem.w	d0-d1,man_x		; fred position
		move.w	#fred2,d2		; invisible fred
bld0060		cmp.b	#diamond,d2		; found a diamond ?
		bne.s	bld0070	
		addq.w	#1,num_collect		; one to collect
bld0070		cmp.b	#safe,d2		; found a safe ?
		bne.s	bld0080
		addq.w	#1,num_collect		; one to collect
bld0080		move.b	d2,(a1)+		; insert into test level
		addq.w	#1,d0			; next x position
		cmp.w	#29,d0			; end of row ?
		blo	bld0000			; loop if not
		move.w	#1,d0			; reset x position
		addq.w	#1,d1			; next y position
		move.b	#$ff,(a1)+		; blocks between
		move.b	#$ff,(a1)+
		dbra	d7,bld0000		; do all rows

		move.l	lvl_pntr,a0
		lea	672(a0),a0		; transporter data
		lea	trans_data,a1		; transporter data area
		move.w	#3,d7			; 4 to copy
bld0090		move.l	(a0)+,d0		; get a transporter
		lsl.l	#2,d0			; *4
		add.l	#$04040404,d0		; normalise to map
		move.l	d0,(a1)+		; save in table
		dbra	d7,bld0090		; do all 4

bld0110		move.l	man_x,d0		; get man start pos
		lsl.l	#2,d0			; normalise
		move.l	d0,man_x		; save

		lea	pulsator_data,a0	; make correct format
		move.w	#7,d7			; 8 to normalise
bld0120		move.l	(a0),d0
		lsl.l	#2,d0
		add.l	#$40004,d0
		move.l	d0,(a0)
		lea	6(a0),a0
		dbra	d7,bld0120
		rts

plot_play	lea	test_level+31,a0	; data to plot
		lea	copy_level,a5		; copy of plot level
		tst.w	screen_choice		; correct screen ?
		beq.s	plp_start		; skip if it is
		lea	copy_level2,a5		; 2nd screen copy
plp_start	move.w	#23,d7			; 24 lines to plot
plp0000		move.w	#24,d1
		sub.w	d7,d1			; make y position
		move.w	#1,d0			; x position
		jsr	plot_icons
		lea	1(a0),a0		; skip to next block
		dbra	d7,plp0000		; do all 24 lines

		movem.w	man_x,d0-d1		; man position
		move.w	#fred,d2		; fred character
		jsr	plot_offset		; plot him

		tst.w	push_count		; plot pushed object ?
		beq.s	plp0005			; skip if not
		movem.w	man_x,d0-d1		; object source
		add.w	push_offset,d0		; object position
		move.w	push_type,d2		; object being pushed
		jsr	plot_offset		; plot it
		subq.w	#1,push_count
		bne.s	plp0005			; skip if no map update
		move.w	push_type,d2
		lea	test_level,a0		; level data
		movem.w	man_x,d0-d1		; get man location
		lsr.w	#2,d0			; normalise
		lsr.w	#2,d1
		mulu.w	#30,d1			; y offset
		add.w	d0,d1			; offset into grid
		add.w	d1,a0			; location of fred
		lea	2(a0),a0		; assume to right of fred
		cmp.b	#$ff,push_offset
		bne.s	plp0003			; skip if correct
		lea	-3(a0),a0		; adjust to left of fred
plp0003		move.b	d2,(a0)			; insert character
				
plp0005		move.w	num_pulsators,d7	; number to plot
		beq.s	plp0023			; skip if none
		lea	pulsator_data,a6	; direction data etc
		subq.w	#1,d7			; 1 less for dbra
plp0010		move.w	d7,-(sp)
		move.w	(a6)+,d0		; x position
		move.w	(a6)+,d1		; y position
		move.w	(a6)+,d2		; status
		cmp.w	#5,d2			; is it dead ?
		beq.s	plp0020			; skip if dead
		move.w	#spirit1-1,d2		; spirit character
		move.w	spirit_cyc,d3		; character change
		cmp.w	#4,d3			; extra frame ?
		blo.s	plp0015			; skip if not
		move.w	#2,d3			; change chracter
plp0015		add.w	d3,d2			; animate spirit
		jsr	plot_offset
plp0020		move.w	(sp)+,d7
		dbra	d7,plp0010		; do them all

plp0023		move.w	num_monsters,d7		; number to plot
		beq.s	plp0030			; skip if none
		lea	monster_data,a6		; direction data etc
		subq.w	#1,d7			; 1 less for dbra
plp0025		move.w	d7,-(sp)
		move.w	(a6)+,d0		; x position
		move.w	(a6)+,d1		; y position
		move.b	(a6),d2			; status
		cmp.b	#$ff,d2			; monster dead
		beq.s	plp0029			; skip if dead
		cmp.b	#13,d2			; is it hatched ?
		blo.s	plp0029			; skip if not hatched
		move.w	#monster1-1,d2		; monster character
		move.w	spirit_cyc,d3		; character change
		cmp.w	#4,d3			; extra frame ?
		blo.s	plp0027			; skip if not
		move.w	#2,d3			; change chracter
plp0027		add.w	d3,d2			; animate monster
		jsr	plot_offset
plp0029		lea	2(a6),a6		; skip past monster status word
		move.w	(sp)+,d7
		dbra	d7,plp0025		; do them all

plp0030		subq.w	#1,spirit_count		; update spirit char ?
		bne.s	plp0040			; skip if not
		move.w	#10,spirit_count	; reset counter
		subq.w	#1,spirit_cyc		; need to reset cycle ?
		bne.s	plp0040			; skip if not
		move.w	#4,spirit_cyc		; reset cycle counter
plp0040		move.l	#play_time,timepntr
		jsr	con_time
		lea	timeplay,a0
		jsr	print_text
		rts

* print icon routine.
* pointer to text supplied in a0, 1st byte is x start,2nd byte is
* y start. String terminated by null byte. No end of line wrap.
plot_icons	move.l	scr1,a1		; background screen
		lea	icons,a3	; icon start
		move.w	d0,-(sp)
		and.w	#$fffe,d0	; clear lsb
		lsl.w	#2,d0		; effective * 8
		mulu.w	#1280,d1	; y offset 8*160 per line down
		add.w	d0,d1		; total offset
		add.l	d1,a1		; make screen pointer
		move.w	(sp)+,d0
pli010		clr.w	d1		; character buildup
		move.b	(a0)+,d1	; get a character 
		cmp.b	#$ff,d1		; end of string
		beq.s	pli_end		; exit if no more text
		move.b	(a5)+,d4	; copy level icon
		cmp.b	d4,d1		; same ?
		beq.s	no_plot		; skip if it is
		move.b	d1,-1(a5)	; update copy screen
		lsl.w	#5,d1		; *32 to make character offset
		lea	0(a3),a4	; start of characters
		add.w	d1,a4		; pointer to character
		btst	#0,d0		; get odd/even bit in carry flag
		bne.s	pli020		; skip if in odd position
		jsr	plot_even	; plot the even character
		addq.w	#1,d0		; next x position
		bra.s	pli010		; and loop
pli020		jsr	plot_odd	; plot in odd position
		addq.w	#1,d0		; next x location
		bra.s	pli010		; and loop
no_plot		addq.w	#1,d0		; next x position
		btst	#0,d0		; update screen pointer ?
		bne.s	np2		; skip if not
		lea	8(a1),a1	; next screen position
np2		bra.s	pli010
pli_end		rts			; return,all done

move_man	tst.w	move_count	; move underway ?
		bne	man0050		; skip if there is
man0000		move.b	key_press,d0
		cmp.b	#'Z',d0		; man left ?
		bne	man0010		; skip if not
* can we move left ?
		lea	test_level-1,a0	; level data
		movem.w	man_x,d0-d1	; get man location
		lsr.w	#2,d0		; normalise
		lsr.w	#2,d1
		mulu.w	#30,d1		; y offset
		add.w	d0,d1		; offset into grid
* move onto the following icons :
* empty,key,diamond,plunger,transporter,earth and capsule
		add.w	d1,a0		; location to check
		cmp.b	#empty,(a0)	; space ok ?
		beq.s	do_left2	; skip if it is
		cmp.b	#key,(a0)	; space ok ?
		beq	do_left
		cmp.b	#plunger,(a0)
		beq	do_left
		cmp.b	#diamond,(a0)
		beq.s	do_left
		cmp.b	#trans,(a0)
		beq.s	do_left
		cmp.b	#earth,(a0)
		beq.s	do_left
		cmp.b	#capsule,(a0)
		beq.s	do_left
		cmp.b	#rock,(a0)	; trying to push a rock ?
		beq	push_rock_left	; skip if we are
		cmp.b	#egg,(a0)	; trying to push an egg ?
		beq	push_egg_left
		move.w	#1234,d0
		rts
do_left2	move.b	#fred2,(a0)
do_left		subq.w	#1,man_x
		move.l	#$ffff0000,move_amount
		move.w	#3,move_count
		move.w	#1234,d0	; signal iteration
		rts

push_rock_left	cmp.b	#empty,-1(a0)	; empty square to go into ?
		beq.s	prl0000		; skip if there is
		move.w	#1234,d0
		rts
prl0000		lea	rock_data,a1	; data to modify
		move.w	#rock,d2	; type being pushed
		move.l	man_x,d0	; rock position
		sub.l	#$40000,d0	; left of fred
		bra	push_left	; general routine

push_egg_left	cmp.b	#empty,-1(a0)	; square to go into ?
		beq.s	pel0000		; skip if there is
		move.w	#1234,d0
		rts
pel0000		lea	monster_data,a1	; data to modify
		move.w	#egg,d2
		move.l	man_x,d0	; egg position
		sub.l	#$40000,d0	; left of fred
		bra	push_left	; general routine

push_left	lsr.l	#2,d0		; normalise
		and.l	#$3fff3fff,d0	; clear rubbish data
		move.w	d2,push_type	; character being pushed
		move.w	#-4,push_offset	; to plot character correct side
		move.w	#3,push_count	; visible correct length
pl0000		cmp.l	(a1),d0		; correct entry in table ?
		beq.s	pl0010		; skip if it is
		lea	6(a1),a1	; next table entry
		bra.s	pl0000		; loop until found
pl0010		subq.w	#1,(a1)		; adjust x position
		cmp.w	#egg,d2		; just done an egg ?
		beq.s	pl0020		; skip if we have
		move.w	#2,4(a1)	; object full momentum
		bra.s	pl0030
pl0020		move.w	#$10,4(a1)	; egg pushed flag
pl0030		move.b	#fred2,-1(a0)	; square going into
		bra	do_left
		
man0010		cmp.b	#'X',d0		; man right ?
		bne	man0020		; skip if not
		lea	test_level+1,a0	; level data
		movem.w	man_x,d0-d1	; get man location
		lsr.w	#2,d0		; normalise
		lsr.w	#2,d1
		mulu.w	#30,d1		; y offset
		add.w	d0,d1		; offset into grid
* move onto the following icons :
* empty,key,diamond,plunger,transporter,earth and capsule
		add.w	d1,a0		; location to check
		cmp.b	#empty,(a0)	; space ok ?
		beq.s	do_right2	; skip if it is
		cmp.b	#key,(a0)	; space ok ?
		beq	do_right
		cmp.b	#plunger,(a0)
		beq	do_right
		cmp.b	#diamond,(a0)
		beq.s	do_right
		cmp.b	#trans,(a0)
		beq.s	do_right
		cmp.b	#earth,(a0)
		beq.s	do_right
		cmp.b	#capsule,(a0)
		beq.s	do_right
		cmp.b	#rock,(a0)
		beq.s	push_rock_right
		cmp.b	#egg,(a0)
		beq.s	push_egg_right
		move.w	#1234,d0
		rts
do_right2	move.b	#fred2,(a0)
do_right	addq.w	#1,man_x
		move.l	#$00010000,move_amount
		move.w	#3,move_count
		move.w	#1234,d0	; signal iteration
		rts

push_rock_right	cmp.b	#empty,1(a0)	; empty square to go into ?
		beq.s	prr0000		; skip if there is
		move.w	#1234,d0
		rts
prr0000		lea	rock_data,a1	; data to modify
		move.w	#rock,d2	; type being pushed
		move.l	man_x,d0	; rock position
		add.l	#$40000,d0	; right of fred
		bra	push_right	; general routine

push_egg_right	cmp.b	#empty,1(a0)	; square to go into ?
		beq.s	per0000		; skip if there is
		move.w	#1234,d0
		rts
per0000		lea	monster_data,a1	; data to modify
		move.w	#egg,d2
		move.l	man_x,d0	; egg position
		add.l	#$40000,d0	; right of fred
		bra	push_right	; general routine

push_right	lsr.l	#2,d0		; normalise
		and.l	#$3fff3fff,d0	; clear rubbish data
		move.w	d2,push_type	; character being pushed
		move.w	#4,push_offset	; to plot character correct side
		move.w	#3,push_count	; visible correct length
pr0000		cmp.l	(a1),d0		; correct entry ion table ?
		beq.s	pr0010		; skip if it is
		lea	6(a1),a1	; next table entry
		bra.s	pr0000		; loop until found
pr0010		addq.w	#1,(a1)		; adjust x position
		cmp.w	#egg,d2		; just done an egg ?
		beq.s	pr0020		; skip if we have
		move.w	#2,4(a1)	; object full momentum
		bra.s	pr0030
pr0020		move.w	#$10,4(a1)	; egg pushed flag
pr0030		move.b	#fred2,1(a0)	; square going into
		bra	do_right

man0020		cmp.b	#"'",d0		; man up ?
		bne.s	man0030		; skip if not
		lea	test_level-30,a0; level data
		movem.w	man_x,d0-d1	; get man location
		lsr.w	#2,d0		; normalise
		lsr.w	#2,d1
		mulu.w	#30,d1		; y offset
		add.w	d0,d1		; offset into grid
* move onto the following icons :
* empty,key,diamond,plunger,transporter,earth and capsule
		add.w	d1,a0		; location to check
		cmp.b	#empty,(a0)	; space ok ?
		beq.s	do_up2		; skip if it is
		cmp.b	#key,(a0)	; space ok ?
		beq	do_up
		cmp.b	#plunger,(a0)
		beq	do_up
		cmp.b	#diamond,(a0)
		beq.s	do_up
		cmp.b	#trans,(a0)
		beq.s	do_up
		cmp.b	#earth,(a0)
		beq.s	do_up
		cmp.b	#capsule,(a0)
		beq.s	do_up
		move.w	#1234,d0
		rts
do_up2		move.b	#fred2,(a0)
do_up		subq.w	#1,man_y
		move.l	#$0000ffff,move_amount
		move.w	#3,move_count
		move.w	#1234,d0	; signal iteration
		rts
man0030		cmp.b	#'/',d0		; man down ?
		bne.s	man0040		; skip if not
		lea	test_level+30,a0; level data
		movem.w	man_x,d0-d1	; get man location
		lsr.w	#2,d0		; normalise
		lsr.w	#2,d1
		mulu.w	#30,d1		; y offset
		add.w	d0,d1		; offset into grid
* move onto the following icons :
* empty,key,diamond,plunger,transporter,earth and capsule
		add.w	d1,a0		; location to check
		cmp.b	#empty,(a0)	; space ok ?
		beq.s	do_down2	; skip if it is
		cmp.b	#key,(a0)	; space ok ?
		beq	do_down
		cmp.b	#plunger,(a0)
		beq	do_down
		cmp.b	#diamond,(a0)
		beq.s	do_down
		cmp.b	#trans,(a0)
		beq.s	do_down
		cmp.b	#earth,(a0)
		beq.s	do_down
		cmp.b	#capsule,(a0)
		beq.s	do_down
		move.w	#1234,d0
		rts
do_down2	move.b	#fred2,(a0)
do_down		addq.w	#1,man_y
		move.l	#$000000001,move_amount
		move.w	#3,move_count
		move.w	#1234,d0	; signal iteration
		rts
man0040		tst.b	keys+$39
		beq.s	man0045
		move.w	#1234,d0
		rts
man0045		move.b	key_press,d0
		beq.s	man0047
		move.w	#1234,d0
man0047		rts
man0050		movem.w	move_amount,d0-d1
		add.w	d0,man_x	; adjust man position
		add.w	d1,man_y	; adjust man position
		move.w	#1234,d0	; signal iteration
		subq.w	#1,move_count
		beq.s	man0060		; finished moving 		
		rts
man0060		lea	test_level,a0	; level data
		movem.w	man_x,d0-d1	; get man location
		lsr.w	#2,d0		; normalise
		lsr.w	#2,d1
		mulu.w	#30,d1		; y offset
		add.w	d0,d1		; offset into grid
		add.w	d1,a0		; location to check
		cmp.b	#fred2,-30(a0)	; clear space above ?
		bne.s	man0070
		clr.b	-30(a0)
man0070		cmp.b	#fred2,1(a0)	; clear space to right ?
		bne.s	man0080		; skip if not
		clr.b	1(a0)
man0080		cmp.b	#fred2,30(a0)	; clear space below ?
		bne.s	man0090		; skip if not
		clr.b	30(a0)
man0090		cmp.b	#fred2,-1(a0)	; clear space to left ?
		bne.s	man0100		; skip if not
		clr.b	-1(a0)
man0100		cmp.b	#key,(a0)	; space ok ?
		beq	do_key
		cmp.b	#plunger,(a0)
		beq	do_plunger
		cmp.b	#diamond,(a0)
		beq.s	do_score
		cmp.b	#trans,(a0)
		beq.s	do_trans
		cmp.b	#capsule,(a0)
		beq	do_capsule
		move.b	#fred2,(a0)
		move.w	#1234,d0		; signal iteration
		rts
do_score	subq.w	#1,num_collect
		move.b	#fred2,(a0)
		move.w	#1234,d0		; signal iteration
		rts
do_trans	clr.b	(a0)
		cmp.b	#fred2,1(a0)		; clear location to right ?
		bne.s	dt000			; skip if not
		clr.b	1(a0)
dt000		cmp.b	#fred2,-1(a0)
		bne.s	dt010
		clr.b	-1(a0)
dt010		cmp.b	#fred2,-30(a0)
		bne.s	dt020
		clr.b	-30(a0)
dt020		cmp.b	#fred2,30(a0)
		bne.s	dt030
		clr.b	30(a0)		
dt030		lea	trans_data,a0		; transporter data
		movem.w	man_x,d0-d1		; get man co-ords
		lsl.w	#8,d0			; x in upper position
		add.w	d1,d0			; make composite
		move.w	#3,d7			; 4 trans to check
dt0000		cmp.w	(a0),d0			; correct transporter ?
		beq.s	dt0010			; skip if it is
		lea	4(a0),a0		; next transporter data
		dbra	d7,dt0000		; do all 4
		move.w	#1234,d0		; signal iteration
		rts				; un-recognised transporter
dt0010		move.w	2(a0),d1		; destination co-ords
		move.w	d1,d0
		and.w	#$00ff,d1		; d1 = y/4
		lsr.w	#8,d0			; d0 = x
		movem.w	d0-d1,man_x		; new man location
		lea	test_level,a0		; level data
		lsr.w	#2,d0			; normalise
		lsr.w	#2,d1
		mulu.w	#30,d1			; y offset
		add.w	d0,d1			; offset into grid
		add.w	d1,a0			; location to check
		move.b	#fred2,(a0)		
		move.w	#1234,d0		; signal iteration
		rts
do_capsule	move.w	#1234,d0		; signal iteration
		move.w	reset_time,play_time	; reset timer
		move.b	#fred2,(a0)
		rts

do_key		move.b	#fred2,(a0)
		lea	test_level+31,a2	; area to change
		move.w	#24*30-1,d7		; loop count
dk0000		cmp.b	#safe,(a2)		; found a safe ?
		bne.s	dk0010			; skip if not
		move.b	#diamond,(a2)		; change to diamond
dk0010		lea	1(a2),a2
		dbra	d7,dk0000		; check all locations
		move.w	#1234,d0		; signal iteration
		rts
		
do_plunger	move.b	#fred2,(a0)
		lea	test_level+31,a2	; area to change
		move.w	#24*30-1,d7		; loop count
dp0000		cmp.b	#bomb,(a2)		; found a bomb ?
		bne.s	dp0010			; skip if not
		move.b	#empty,(a2)		; change to empty
dp0010		lea	1(a2),a2
		dbra	d7,dp0000		; check all locations
		move.w	#1234,d0		; signal iteration
		rts

do_pulsators	move.w	num_pulsators,d7	; number to do
		bne.s	dpul0000		; skip if there are some
		rts
dpul0000	lea	pulsator_data,a0
		subq.w	#1,d7			; 1 less for dbra
dpul0010	lea	pulsator_routines,a1	; routine pointer look-up
		movem.w	(a0),d0-d2		; d2 = pulsator direction
		cmp.w	#5,d2			; max value
		bgt	pul_error
		lsl.w	#2,d2			; long word offset
		move.l	(a1,d2.w),a1		; routine pointer
		jmp	(a1)			; do it
next_pulsator	lea	6(a0),a0
		dbra	d7,dpul0010
		rts
pul_error	move.w	#$070,colours
		rts
pulsator_routines
		dc.l	pul_up,pul_right,pul_down,pul_left,next_pulsator,next_pulsator

pul_up		move.w	d1,d3		; copy y position
		and.w	#$03,d3		; need to change direction ?
		beq.s	pulu0000	; skip if we do
		subq.w	#1,2(a0)	; adjust y position
		bra	next_pulsator
pulu0000	lea	test_level,a1	; level data
		lsr.w	#2,d0
		lsr.w	#2,d1
		mulu.w	#30,d1		; y offset into array
		add.w	d0,d1
		add.w	d1,a1		; pulsator position
* has the pulsator been killed ?
		cmp.b	#cage2,(a1)	; on a cage ?
		beq	kill_pulsator	; skip if it is
* can the pulsator turn left ?
		cmp.b	#empty,-1(a1)
		beq	pulu_left
		cmp.b	#earth,-1(a1)
		beq	pulu_left
		cmp.b	#cage,-1(a1)
		beq	pulu_left
		cmp.b	#fred2,-1(a1)
		beq	pulu_left
* can the pulsator go straight on ?
		cmp.b	#empty,-30(a1)
		beq	pulu_forward
		cmp.b	#earth,-30(a1)
		beq	pulu_forward
		cmp.b	#cage,-30(a1)
		beq	pulu_forward
		cmp.b	#fred2,-30(a1)
		beq	pulu_forward
* can the pulsator turn right ?
		cmp.b	#empty,1(a1)
		beq	pulu_right
		cmp.b	#earth,1(a1)
		beq	pulu_right
		cmp.b	#cage,1(a1)
		beq	pulu_right
		cmp.b	#fred2,1(a1)
		beq	pulu_right
* pulsator must go back the way it came ?
		bra	pulu_back
pulu_left	cmp.b	#cage,-1(a1)	; moving onto a cage ?
		bne.s	pul0000		; skip if not
		move.b	#cage2,-1(a1)	; stop 2 pulsator same cage
pul0000		subq.w	#1,(a0)		; adjust x position
		move.w	#3,4(a0)	; change direction
		bra	next_pulsator
		
pulu_forward	cmp.b	#cage,-30(a1)	; moving onto cage ?
		bne.s	puf0000		; skip if not
		move.b	#cage2,-30(a1)
puf0000		subq.w	#1,2(a0)	; change y position
		bra	next_pulsator
		
pulu_right	cmp.b	#cage,1(a1)	; moving onto cage ?
		bne.s	pur0000		; skip if not
		move.b	#cage2,1(a1)
pur0000		addq.w	#1,(a0)		; change x position
		move.w	#1,4(a0)	; change direction
		bra	next_pulsator

pulu_back	cmp.b	#cage,30(a1)	; moving onto cage ?
		bne.s	pub0000		; skip if not
		move.b	#cage2,30(a1)
pub0000		addq.w	#1,2(a0)	; change y position
		move.w	#2,4(a0)	; change direction
		bra	next_pulsator

pul_right	move.w	d0,d3		; copy x position
		and.w	#$03,d3		; need to change direction ?
		beq.s	pulr0000	; skip if we do
		addq.w	#1,(a0)		; adjust x position
		bra	next_pulsator
pulr0000	lea	test_level,a1	; level data
		lsr.w	#2,d0
		lsr.w	#2,d1
		mulu.w	#30,d1		; y offset into array
		add.w	d0,d1
		add.w	d1,a1		; pulsator position
* has the pulsator been killed ?
		cmp.b	#cage2,(a1)	; on a cage ?
		beq	kill_pulsator	; skip if it is
* can the pulsator turn left ?
		cmp.b	#empty,-30(a1)
		beq	pulr_left
		cmp.b	#earth,-30(a1)
		beq	pulr_left
		cmp.b	#cage,-30(a1)
		beq	pulr_left
		cmp.b	#fred2,-30(a1)
		beq	pulr_left
* can the pulsator go straight on ?
		cmp.b	#empty,1(a1)
		beq	pulr_forward
		cmp.b	#earth,1(a1)
		beq	pulr_forward
		cmp.b	#cage,1(a1)
		beq	pulr_forward
		cmp.b	#fred2,1(a1)
		beq	pulr_forward
* can the pulsator turn right ?
		cmp.b	#empty,30(a1)
		beq	pulr_right
		cmp.b	#earth,30(a1)
		beq	pulr_right
		cmp.b	#cage,30(a1)
		beq	pulr_right
		cmp.b	#fred2,30(a1)
		beq	pulr_right
* can the pulsator go back the way it came ?
		bra	pulr_back

pulr_left	cmp.b	#cage,-30(a1)	; moving onto a cage ?
		bne.s	prla0000	; skip if not
		move.b	#cage2,-30(a1)	; stop 2 pulsator same cage
prla0000	subq.w	#1,2(a0)	; adjust y position
		move.w	#0,4(a0)	; change direction
		bra	next_pulsator
		
pulr_forward	cmp.b	#cage,1(a1)	; moving onto cage ?
		bne.s	prf0000		; skip if not
		move.b	#cage2,1(a1)
prf0000		addq.w	#1,(a0)		; change x position
		bra	next_pulsator
		
pulr_right	cmp.b	#cage,30(a1)	; moving onto cage ?
		bne.s	prra0000	; skip if not
		move.b	#cage2,30(a1)
prra0000	addq.w	#1,2(a0)	; change y position
		move.w	#2,4(a0)	; change direction
		bra	next_pulsator

pulr_back	cmp.b	#cage,-1(a1)	; moving onto cage ?
		bne.s	prb0000		; skip if not
		move.b	#cage2,-1(a1)
prb0000		subq.w	#1,(a0)		; change x position
		move.w	#3,4(a0)	; change direction
		bra	next_pulsator


pul_down	move.w	d1,d3		; copy y position
		and.w	#$03,d3		; need to change direction ?
		beq.s	puld0000	; skip if we do
		addq.w	#1,2(a0)	; adjust y position
		bra	next_pulsator
puld0000	lea	test_level,a1	; level data
		lsr.w	#2,d0
		lsr.w	#2,d1
		mulu.w	#30,d1		; y offset into array
		add.w	d0,d1
		add.w	d1,a1		; pulsator position
* has the pulsator been killed ?
		cmp.b	#cage2,(a1)	; on a cage ?
		beq	kill_pulsator	; skip if it is
* can the pulsator turn left ?
		cmp.b	#empty,1(a1)
		beq	puld_left
		cmp.b	#earth,1(a1)
		beq	puld_left
		cmp.b	#cage,1(a1)
		beq	puld_left
		cmp.b	#fred2,1(a1)
		beq	puld_left
* can the pulsator go straight on ?
		cmp.b	#empty,30(a1)
		beq	puld_forward
		cmp.b	#earth,30(a1)
		beq	puld_forward
		cmp.b	#cage,30(a1)
		beq	puld_forward
		cmp.b	#fred2,30(a1)
		beq	puld_forward
* can the pulsator turn right ?
		cmp.b	#empty,-1(a1)
		beq	puld_right
		cmp.b	#earth,-1(a1)
		beq	puld_right
		cmp.b	#cage,-1(a1)
		beq	puld_right
		cmp.b	#fred2,-1(a1)
		beq	puld_right
* can the pulsator go back the way it came ?
		bra	puld_back

puld_left	cmp.b	#cage,1(a1)	; moving onto a cage ?
		bne.s	pdl0000		; skip if not
		move.b	#cage2,1(a1)	; stop 2 pulsator same cage
pdl0000		addq.w	#1,(a0)		; adjust x position
		move.w	#1,4(a0)	; change direction
		bra	next_pulsator
		
puld_forward	cmp.b	#cage,30(a1)	; moving onto cage ?
		bne.s	pdf0000		; skip if not
		move.b	#cage2,30(a1)
pdf0000		addq.w	#1,2(a0)	; change y position
		bra	next_pulsator
		
puld_right	cmp.b	#cage,-1(a1)	; moving onto cage ?
		bne.s	pdr0000		; skip if not
		move.b	#cage2,-1(a1)
pdr0000		subq.w	#1,(a0)		; change x position
		move.w	#3,4(a0)	; change direction
		bra	next_pulsator

puld_back	cmp.b	#cage,-30(a1)	; moving onto cage ?
		bne.s	pdb0000		; skip if not
		move.b	#cage2,-30(a1)
pdb0000		subq.w	#1,2(a0)	; change y position
		move.w	#0,4(a0)	; change direction
		bra	next_pulsator

pul_left	move.w	d0,d3		; copy x position
		and.w	#$03,d3		; need to change direction ?
		beq.s	pull0000	; skip if we do
		subq.w	#1,(a0)		; adjust x position
		bra	next_pulsator
pull0000	lea	test_level,a1	; level data
		lsr.w	#2,d0
		lsr.w	#2,d1
		mulu.w	#30,d1		; y offset into array
		add.w	d0,d1
		add.w	d1,a1		; pulsator position
* has the pulsator been killed ?
		cmp.b	#cage2,(a1)	; on a cage ?
		beq	kill_pulsator	; skip if it is
* can the pulsator turn left ?
		cmp.b	#empty,30(a1)
		beq	pull_left
		cmp.b	#earth,30(a1)
		beq	pull_left
		cmp.b	#cage,30(a1)
		beq	pull_left
		cmp.b	#fred2,30(a1)
		beq	pull_left
* can the pulsator go straight on ?
		cmp.b	#empty,-1(a1)
		beq	pull_forward
		cmp.b	#earth,-1(a1)
		beq	pull_forward
		cmp.b	#cage,-1(a1)
		beq	pull_forward
		cmp.b	#fred2,-1(a1)
		beq	pull_forward
* can the pulsator turn right ?
		cmp.b	#empty,-30(a1)
		beq	pull_right
		cmp.b	#earth,-30(a1)
		beq	pull_right
		cmp.b	#cage,-30(a1)
		beq	pull_right
		cmp.b	#fred2,-30(a1)
		beq	pull_right
* can the pulsator go back the way it came ?
		bra	pull_back

pull_left	cmp.b	#cage,30(a1)	; moving onto a cage ?
		bne.s	pll0000		; skip if not
		move.b	#cage2,30(a1)	; stop 2 pulsator same cage
pll0000		addq.w	#1,2(a0)	; adjust y position
		move.w	#2,4(a0)	; change direction
		bra	next_pulsator
		
pull_forward	cmp.b	#cage,-1(a1)	; moving onto cage ?
		bne.s	plf0000		; skip if not
		move.b	#cage2,-1(a1)
plf0000		subq.w	#1,(a0)		; change x position
		bra	next_pulsator
		
pull_right	cmp.b	#cage,-30(a1)	; moving onto cage ?
		bne.s	plr0000		; skip if not
		move.b	#cage2,-30(a1)
plr0000		subq.w	#1,2(a0)	; change y position
		move.w	#0,4(a0)	; change direction
		bra	next_pulsator

pull_back	cmp.b	#cage,1(a1)	; moving onto cage ?
		bne.s	plb0000		; skip if not
		move.b	#cage2,1(a1)
plb0000		addq.w	#1,(a0)		; change x position
		move.w	#1,4(a0)	; change direction
		bra	next_pulsator
	
kill_pulsator	move.b	#diamond,(a1)	; change cage to diamond
		move.w	#5,4(a0)	; kill pulsator
		bra	next_pulsator

* d0=x,d1=y,d2=character number
plot_offset	lea	copy_level,a0		; assume first copy
		tst.w	screen_choice		; correct one ?
		beq.s	poff0000		; skip if it is
		lea	copy_level2,a0		; other screen
poff0000	move.w	d0,d4			; copy x position
		move.w	d1,d3			; copy y position
		lsr.w	#2,d3			; normalise
		move.w	d3,d5			; save y range
		subq.w	#1,d3			; range 0-23
		mulu.w	#28,d3			; y offset into array
		lsr.w	#2,d4			; normalise x
		move.w	d4,d6			; save x range
		subq.w	#1,d4			; range 0-27
		add.w	d4,d3			; total offset
		add.w	d3,a0			; array pointer
		move.b	#$fe,00(a0)		; for character erase
		move.b	#$fe,01(a0)		; for character erase
		move.b	#$fe,28(a0)		; for character erase
		move.l	scr1,a0			; screen pointer
		lsl.w	#3,d5			; make y offset/160
		mulu.w	#160,d5			; screen y offset
		bclr	#0,d6			; multiples of 2
		lsl.w	#2,d6			; x offset into screen
		add.w	d6,d5			; total offset
		add.w	d5,a0			; screen pointer
		lea	icons,a1		; character data
		lsl.w	#5,d2			; character offset
		add.w	d2,a1			; character pointer
		move.w	d0,d2
		and.w	#$03,d2			; x offset to character ?
		bne	x_plot			; skip if there is
		and.w	#$03,d1			; make y offset
		mulu.w	#320,d1			; total screen offset
		add.w	d1,a0			; adjust screen pointer
		btst	#2,d0			; 2nd part of 16 pixels ?
		beq.s	y_plot			; skip if not
		lea	1(a0),a0		; adjust
y_plot		move.w	#7,d7			; 8 lines to or in
yp0000		move.b	(a1)+,d0
		or.b	d0,(a0)
		move.b	(a1)+,d0
		or.b	d0,2(a0)
		move.b	(a1)+,d0
		or.b	d0,4(a0)
		move.b	(a1)+,d0
		or.b	d0,6(a0)
		lea	160(a0),a0		; next screen line
		dbra	d7,yp0000		; do all the lines
		rts				; all done
x_plot		lsl.w	#1,d2			; number of shifts to do
		btst	#2,d0			; 2nd part of 16 pixels ?
		beq.s	xp0000			; skip if not
		lea	1(a0),a0		; adjust
xp0000		move.w	#7,d7			; 8 lines to plot
xp0010		move.b	(a1)+,d1
		lsr.w	d2,d1			; shift data
		or.b	d1,(a0)
		move.b	(a1)+,d1
		lsr.w	d2,d1			; shift data
		or.b	d1,2(a0)
		move.b	(a1)+,d1
		lsr.w	d2,d1			; shift data
		or.b	d1,4(a0)
		move.b	(a1)+,d1
		lsr.w	d2,d1			; shift data
		or.b	d1,6(a0)
		lea	160(a0),a0		; next screen line
		dbra	d7,xp0010
		lea	-1279(a0),a0		; assume other half
		btst	#2,d0			; need to jump to next block ?
		beq.s	xp0020			; skip if not
		lea	6(a0),a0		; next 16 pixel block
xp0020		lea	-32(a1),a1		; restore character pointer
		move.w	#8,d3			; calculate number of shifts
		sub.w	d2,d3			; d3=number of shifts
		move.w	#7,d7			; 8 lines to plot
xp0030		move.b	(a1)+,d1
		lsl.w	d3,d1			; shift data
		or.b	d1,(a0)
		move.b	(a1)+,d1
		lsl.w	d3,d1			; shift data
		or.b	d1,2(a0)
		move.b	(a1)+,d1
		lsl.w	d3,d1			; shift data
		or.b	d1,4(a0)
		move.b	(a1)+,d1
		lsl.w	d3,d1			; shift data
		or.b	d1,6(a0)
		lea	160(a0),a0		; next screen line
		dbra	d7,xp0030
		rts				; return, all done
		
sort_rocks	move.w	num_rocks,d4		; number of rocks
		subq.w	#2,d4			; 2 less in sort loop
		bge.s	sr0000			; skip if rocks to sort
		rts
sr0000		clr.w	d5			; stays 0 if no rock swap
		lea	rock_data,a0		; structure table
sr0020		movem.w	(a0),d0-d2		; rock data
		cmp.w	8(a0),d1		; need to swap ?
		blo.s	sr0025			; skip if so
		bgt.s	sr0030			; skip if no swap
		cmp.w	6(a0),d0		; furthur to the right ?
		bge.s	sr0030			; skip if it isn't
sr0025		move.l	6(a0),(a0)		; swap rock position data
		move.w	10(a0),4(a0)
		movem.w	d0-d2,6(a0)
		moveq.w	#1,d5			; signal a swap
sr0030		lea	6(a0),a0		; next rock position
		dbra	d4,sr0020		; do all the rocks
		tst.w	d5			; swapped any rocks ?
		bne.s	sort_rocks		; do it again if we have
		rts

do_rocks	move.w	num_rocks,d7		; no of rocks to do
		bne.s	dor0000			; skip if there are
		rts
dor0000		lea	rock_data,a0		; rock data
		subq.w	#1,d7			; 1 less for dbra
dor0010		movem.w	(a0),d0-d2
		lea	test_level,a1		; level data
		mulu.w	#30,d1			; y offset
		add.w	d0,d1			; total offset
		add.w	d1,a1			; array pointer
		cmp.b	#rock,(a1)		; is there a rock there ?
		beq.s	check_rock		; skip if there is
next_rock	lea	6(a0),a0		; next rock data
		dbra	d7,dor0010		; do them all
		rts
		
check_rock	cmp.w	#1,d2			; rock in limbo ?
		beq	update_rock		; skip if it is
* rock fall straight down ?
		cmp.b	#empty,30(a1)		; fall down ?
		beq	rock_down		; skip if it can
* can the rock fall left ?
check_left	cmp.b	#empty,-1(a1)		; clear to left ?
		bne.s	check_right		; skip if not
		cmp.b	#empty,29(a1)		; clear to left ?
		bne.s	check_right		; skip if not
		cmp.b	#rleft,30(a1)		; on curved surface ?
		beq	rock_left		; skip if it is
		cmp.b	#diamond,30(a1)		; on curved surface ?
		beq	rock_left		; skip if it is
		cmp.b	#rock,30(a1)		; on curved surface ?
		beq	rock_left		; skip if it is
		cmp.b	#key,30(a1)		; on curved surface ?
		beq	rock_left		; skip if it is
		cmp.b	#egg,30(a1)		; on curved surface ?
		beq	rock_left		; skip if it is
		cmp.b	#plunger,30(a1)		; on curved surface ?
		beq	rock_left		; skip if it is
		cmp.b	#bomb,30(a1)		; on curved surface ?
		beq	rock_left		; skip if it is
		cmp.b	#skull,30(a1)		; on curved surface ?
		beq	rock_left		; skip if it is
		cmp.b	#capsule,30(a1)		; on curved surface ?
		beq	rock_left		; skip if it is
		cmp.b	#exit,30(a1)		; on curved surface ?
		beq	rock_left		; skip if it is
* can it fall right ?
check_right	cmp.b	#empty,1(a1)		; clear to right ?
		bne.s	rock_no_move		; skip if not
		cmp.b	#empty,31(a1)		; clear to left ?
		bne.s	rock_no_move		; skip if not
		cmp.b	#rright,30(a1)		; on curved surface ?
		beq	rock_right		; skip if it is
		cmp.b	#diamond,30(a1)		; on curved surface ?
		beq	rock_right		; skip if it is
		cmp.b	#rock,30(a1)		; on curved surface ?
		beq	rock_right		; skip if it is
		cmp.b	#key,30(a1)		; on curved surface ?
		beq	rock_right		; skip if it is
		cmp.b	#egg,30(a1)		; on curved surface ?
		beq	rock_right		; skip if it is
		cmp.b	#plunger,30(a1)		; on curved surface ?
		beq	rock_right		; skip if it is
		cmp.b	#bomb,30(a1)		; on curved surface ?
		beq	rock_right		; skip if it is
		cmp.b	#skull,30(a1)		; on curved surface ?
		beq	rock_right		; skip if it is
		cmp.b	#capsule,30(a1)		; on curved surface ?
		beq	rock_right		; skip if it is
		cmp.b	#exit,30(a1)		; on curved surface ?
		beq	rock_right		; skip if it is
rock_no_move	clr.w	4(a0)			; reset rock status
		bra	next_rock
rock_down	clr.b	(a1)			; erase rock
		move.b	#rock,30(a1)		; new position
		addq.w	#1,2(a0)		; change y position
		addq.w	#1,4(a0)		; change status
		bra	next_rock
rock_left	clr.b	(a1)			; erase rock
		move.b	#rock,29(a1)		; new position
		subq.w	#1,0(a0)		; change x position
		addq.w	#1,2(a0)		; change y position
		addq.w	#1,4(a0)		; change status
		bra	next_rock
rock_right	clr.b	(a1)			; erase rock
		move.b	#rock,31(a1)		; new position
		addq.w	#1,0(a0)		; change x position
		addq.w	#1,2(a0)		; change y position
		addq.w	#1,4(a0)		; change status
		bra	next_rock
update_rock	addq.w	#1,4(a0)		; change status
		bra	next_rock

do_weed		move.w	num_weed,d7		; amount to do
		bne.s	dw0000			; skip if there is some
		rts
dw0000		lea	weed_data,a0		; weed data
		subq.w	#1,d7			; 1 less for dbra
dw0010		movem.w	(a0),d0-d2		; x,y, grow status
		tst.w	d2			; can it grow ?
		bne.s	check_weed		; skip if not
next_weed	lea	6(a0),a0		; next weed unit
		dbra	d7,dw0010		; do all the weed
		rts
		
check_weed	lea	test_level,a1		; screen data
		move.w	d1,d3			; copy y
		mulu.w	#30,d3			; y offset
		add.w	d0,d3			; total offset
		add.w	d3,a1			; weed location
		clr.w	d2			; reset grow directions
* can it grow into location above ?
		cmp.b	#empty,-30(a1)		; ok to grow into ?
		beq.s	up_ok			; skip if it is
		cmp.b	#fred2,-30(a1)		; ok to grow into ?
		beq.s	up_ok			; skip if it is
		cmp.b	#earth,-30(a1)		; ok to grow into ?
		bne.s	dw0020			; skip if not
up_ok		or.w	#1,d2			; up direction ok
dw0020		cmp.b	#diamond,-30(a1)	; can we possibly grow up ?
		beq.s	pos_up
		cmp.b	#plunger,-30(a1)
		beq.s	pos_up
		cmp.b	#rock,-30(a1)
		beq.s	pos_up
		cmp.b	#bomb,-30(a1)
		beq.s	pos_up
		cmp.b	#cage2,-30(a1)
		beq.s	pos_up
		cmp.b	#cage,-30(a1)
		beq.s	pos_up
		cmp.b	#trans,-30(a1)
		beq.s	pos_up
		cmp.b	#capsule,-30(a1)
		beq.s	pos_up
		cmp.b	#egg,-30(a1)
		beq.s	pos_up
		cmp.b	#safe,-30(a1)
		beq.s	pos_up
		cmp.b	#key,-30(a1)
		beq.s	pos_up
		bra.s	dw0025
pos_up		or.w	#16,d2			; set possible bit
* can we grow to the right ?
dw0025		cmp.b	#empty,1(a1)		; ok to grow into ?
		beq.s	ok_right
		cmp.b	#fred2,1(a1)		; ok to grow into ?
		beq.s	ok_right		; skip if it is
		cmp.b	#earth,1(a1)
		bne.s	dw0030
ok_right	or.w	#2,d2			; right direction ok
dw0030		cmp.b	#diamond,1(a1)		; can we possibly grow right ?
		beq.s	pos_right
		cmp.b	#plunger,1(a1)
		beq.s	pos_right
		cmp.b	#rock,1(a1)
		beq.s	pos_right
		cmp.b	#bomb,1(a1)
		beq.s	pos_right
		cmp.b	#cage2,1(a1)
		beq.s	pos_right
		cmp.b	#cage,1(a1)
		beq.s	pos_right
		cmp.b	#trans,1(a1)
		beq.s	pos_right
		cmp.b	#capsule,1(a1)
		beq.s	pos_right
		cmp.b	#egg,1(a1)
		beq.s	pos_right
		cmp.b	#safe,1(a1)
		beq.s	pos_right
		cmp.b	#key,1(a1)
		beq.s	pos_right
		bra.s	dw0035
pos_right	or.w	#32,d2			; set possible bit
* can we grow down ?
dw0035		cmp.b	#empty,30(a1)		; ok to grow into ?
		beq.s	ok_down			; skip if it is
		cmp.b	#fred2,30(a1)		; ok to grow into ?
		beq.s	ok_down			; skip if it is
		cmp.b	#earth,30(a1)		; ok to grow into ?
		bne.s	dw0040			; skip if not
ok_down		or.w	#4,d2			; down direction ok
dw0040		cmp.b	#diamond,30(a1)		; can we possibly grow down ?
		beq.s	pos_down
		cmp.b	#plunger,30(a1)
		beq.s	pos_down
		cmp.b	#rock,30(a1)
		beq.s	pos_down
		cmp.b	#bomb,30(a1)
		beq.s	pos_down
		cmp.b	#cage2,30(a1)
		beq.s	pos_down
		cmp.b	#cage,30(a1)
		beq.s	pos_down
		cmp.b	#trans,30(a1)
		beq.s	pos_down
		cmp.b	#capsule,30(a1)
		beq.s	pos_down
		cmp.b	#egg,30(a1)
		beq.s	pos_down
		cmp.b	#safe,30(a1)
		beq.s	pos_down
		cmp.b	#key,30(a1)
		beq.s	pos_down
		bra.s	dw0045
pos_down	or.w	#64,d2			; set possible bit
* can we grow to the left ?
dw0045		cmp.b	#empty,-1(a1)		; ok to grow into ?
		beq.s	ok_left
		cmp.b	#fred2,-1(a1)		; ok to grow into ?
		beq.s	ok_left
		cmp.b	#earth,-1(a1)
		bne.s	dw0050
ok_left		or.w	#8,d2			; left direction ok
dw0050		cmp.b	#diamond,-1(a1)		; can we possibly grow left ?
		beq.s	pos_left
		cmp.b	#plunger,-1(a1)
		beq.s	pos_left
		cmp.b	#rock,-1(a1)
		beq.s	pos_left
		cmp.b	#bomb,-1(a1)
		beq.s	pos_left
		cmp.b	#cage2,-1(a1)
		beq.s	pos_left
		cmp.b	#cage,-1(a1)
		beq.s	pos_left
		cmp.b	#trans,-1(a1)
		beq.s	pos_left
		cmp.b	#capsule,-1(a1)
		beq.s	pos_left
		cmp.b	#egg,-1(a1)
		beq.s	pos_left
		cmp.b	#safe,-1(a1)
		beq.s	pos_left
		cmp.b	#key,-1(a1)
		beq.s	pos_left
		bra.s	dw0055
pos_left	or.w	#128,d2			; set possible bit
dw0055		move.w	d2,4(a0)		; new grow data
		tst.w	d2			; can it still grow ?
		beq	next_weed		; skip if not
		jsr	random			; get a random number
		and.w	#$7ff,d6		; limit its range
		cmp.w	#3,d6			; check grow direction ?
		bgt	next_weed		; skip if not
		btst	d6,d2			; can we grow that direction ?
		beq	next_weed		; skip if not
grow_weed	lea	weed_data,a2		; start of weed data
		move.w	num_weed,d3		; current amount of weed
		mulu.w	#6,d3			; 3 words per weed
		add.w	d3,a2			; free slot location
		addq.w	#1,num_weed		; count the new weed
		lsl.w	#2,d6			; long word offset
		lea	weed_routine,a3		; for routien jump
		move.l	(a3,d6.w),a3		; routine pointer
		jmp	(a3)			; do correct routine

weed_routine	dc.l	grow_up,grow_right,grow_down,grow_left

grow_up		move.b	#weed,-30(a1)		; update map
		subq.w	#1,d1			; correct y value
		movem.w	d0-d1,(a2)		; x,y locations
		move.w	#$ffff,4(a2)		; auto check growth
		bra	next_weed		; do the next unit

grow_right	move.b	#weed,1(a1)		; update map
		addq.w	#1,d0			; correct x value
		movem.w	d0-d1,(a2)		; x,y locations
		move.w	#$ffff,4(a2)		; auto check growth
		bra	next_weed		; do the next unit

grow_down	move.b	#weed,30(a1)		; update map
		addq.w	#1,d1			; correct y value
		movem.w	d0-d1,(a2)		; x,y locations
		move.w	#$ffff,4(a2)		; auto check growth
		bra	next_weed		; do the next unit

grow_left	move.b	#weed,-1(a1)		; update map
		subq.w	#1,d0			; correct x value
		movem.w	d0-d1,(a2)		; x,y locations
		move.w	#$ffff,4(a2)		; auto check growth
		bra	next_weed		; do the next unit
		
do_monsters	move.w	num_monsters,d7		; number to do
		bne.s	domon0000		; skip if at least one
		rts
domon0000	subq.w	#1,d7			; 1 less for dbra
		lea	monster_data,a0
domon0010	movem.w	(a0),d0-d2		; x,y status
		tst.w	d2			; =$ffff if dead
		bmi	next_monster		; skip if dead
		move.w	d2,d3			; copy status word
		lsr.w	#6,d3			; normalise for l_word offset
		and.w	#$fffc,d3		; clear 2 lsb's
		lea	mon_routs,a1		; monster routine pointer list
		move.l	(a1,d3.w),a1		; routine pointer
		jmp	(a1)			; do it
next_monster	lea	6(a0),a0		; next monster data
		dbra	d7,domon0010		; do them all
		rts
* monster status first byte as follows :
* 0 - unmoved egg
* 1 - pushed egg
* 2 - egg falling, in limbo
* 3 - egg fast falling
* 4 to 11 - cracked egg
* 12 - hatching monster
* 13 to 23 - Hatched monster
* 24 - active monster
mon_routs	dc.l	still_egg,still_egg,limbo_egg
		dc.l	falling_egg,cracked_egg,cracked_egg
		dc.l	cracked_egg,cracked_egg,cracked_egg
		dc.l	cracked_egg,cracked_egg,cracked_egg
		dc.l	hatching_mon
		dc.l	hatched_mon,hatched_mon,hatched_mon
		dc.l	hatched_mon,hatched_mon,hatched_mon
		dc.l	hatched_mon,hatched_mon,hatched_mon
		dc.l	hatched_mon,hatched_mon,moving_mon

still_egg	mulu.w	#30,d1			; y offset into map
		add.w	d0,d1			; total offset
		lea	test_level,a1		; level data
		add.w	d1,a1			; location pointer
		cmp.b	#egg,(a1)		; is there an egg there ?
		bne	next_monster		; exit if not
* can the egg fall down
		cmp.b	#empty,30(a1)		; can we fall straight down ?
		bne	ch_egg_left		; skip if can't
egg_down	addq.w	#1,2(a0)		; adjust y position
		addq.b	#2,4(a0)		; egg now in limbo
		clr.b	(a1)			; erase the egg
		move.b	#egg,30(a1)		; new egg
		bra	next_monster		; do the next one
* can the egg fall left
ch_egg_left	cmp.b	#empty,-1(a1)		; clear to left ?
		bne	ch_egg_right		; skip if not
		cmp.b	#empty,29(a1)		; clear down and left ?
		bne	ch_egg_right		; skip if not
		cmp.b	#rleft,30(a1)		; on curved surface ?
		beq	egg_left		; skip if it is
		cmp.b	#diamond,30(a1)		; on curved surface ?
		beq	egg_left		; skip if it is
		cmp.b	#rock,30(a1)		; on curved surface ?
		beq	egg_left		; skip if it is
		cmp.b	#key,30(a1)		; on curved surface ?
		beq	egg_left		; skip if it is
		cmp.b	#egg,30(a1)		; on curved surface ?
		beq	egg_left		; skip if it is
		cmp.b	#plunger,30(a1)		; on curved surface ?
		beq	egg_left		; skip if it is
		cmp.b	#bomb,30(a1)		; on curved surface ?
		beq	egg_left		; skip if it is
		cmp.b	#skull,30(a1)		; on curved surface ?
		beq	egg_left		; skip if it is
		cmp.b	#capsule,30(a1)		; on curved surface ?
		bne	ch_egg_right		; skip if not
egg_left	subq.w	#1,(a0)			; adjust x position
		addq.w	#1,2(a0)		; adjust y position
		addq.b	#2,4(a0)		; egg now in limbo
		clr.b	(a1)			; erase the egg
		move.b	#egg,29(a1)		; new egg position
		bra	next_monster		; do the next one
* can the egg fall right
ch_egg_right	cmp.b	#empty,1(a1)		; clear to right ?
		bne	next_monster		; skip if not
		cmp.b	#empty,31(a1)		; clear down and right ?
		bne	next_monster		; skip if not
		cmp.b	#rright,30(a1)		; on curved surface ?
		beq	egg_right		; skip if it is
		cmp.b	#diamond,30(a1)		; on curved surface ?
		beq	egg_right		; skip if it is
		cmp.b	#rock,30(a1)		; on curved surface ?
		beq	egg_right		; skip if it is
		cmp.b	#key,30(a1)		; on curved surface ?
		beq	egg_right		; skip if it is
		cmp.b	#egg,30(a1)		; on curved surface ?
		beq	egg_right		; skip if it is
		cmp.b	#plunger,30(a1)		; on curved surface ?
		beq	egg_right		; skip if it is
		cmp.b	#bomb,30(a1)		; on curved surface ?
		beq	egg_right		; skip if it is
		cmp.b	#skull,30(a1)		; on curved surface ?
		beq	egg_right		; skip if it is
		cmp.b	#capsule,30(a1)		; on curved surface ?
		beq	egg_right
		clr.w	4(a0)			; reset egg status
		bra	next_monster		; exit if not
egg_right	addq.w	#1,(a0)			; adjust x position
		addq.w	#1,2(a0)		; adjust y position
		addq.b	#2,4(a0)		; egg now in limbo
		clr.b	(a1)			; erase the egg
		move.b	#egg,31(a1)		; new egg position
		bra	next_monster		; do the next one

limbo_egg	addq.b	#1,4(a0)		; egg now falling fast
		bra	next_monster
		
falling_egg	mulu.w	#30,d1			; y offset into map
		add.w	d0,d1			; total offset
		lea	test_level,a1		; level data
		add.w	d1,a1			; location pointer
		cmp.b	#egg,(a1)		; is there an egg there ?
		bne	next_monster		; exit if not
* can the egg fall straight down ?
		cmp.b	#empty,30(a1)		; empty below ?
		beq	egg_fall		; skip if it can
* must have hit solid surface
		addq.b	#1,4(a0)		; change to cracked status
		move.b	#cracked,(a1)		; change to cracked character
		bra	next_monster
egg_fall	clr.b	(a1)			; erase the current egg
		move.b	#egg,30(a1)		; new egg position
		addq.w	#1,2(a0)		; change y position
		bra	next_monster
		
cracked_egg	addq.b	#1,4(a0)		; increase cracked counter
		bra	next_monster
		
hatching_mon	addq.b	#1,4(a0)		; change to hatched monster
		clr.b	5(a0)			; no direction at present
		mulu.w	#30,d1			; y offset into map
		add.w	d0,d1			; total offset
		lea	test_level,a1		; level data
		add.w	d1,a1			; location pointer
		clr.b	(a1)			; erase the cracked egg
		move.l	(a0),d0
		lsl.l	#2,d0
		move.l	d0,(a0)			; normalise monster position
		bra	next_monster
		
hatched_mon	addq.b	#1,4(a0)		; next hatch value
		bra	next_monster
		
moving_mon	move.w	d1,d3
		add.w	d0,d3			; compound position
		and.w	#$03,d3			; monster in middle of move ?
		bne	monster_moving		; skip if it is
		lsr.w	#2,d0			; normalise
		lsr.w	#2,d1			; normalise
		mulu.w	#30,d1			; y offset
		add.w	d0,d1			; total offset
		lea	test_level,a1		; level data
		add.w	d1,a1			; position pointer
		movem.w	(a0),d0-d1		; recover monster pos
		movem.w	man_x,d2-d3		; man position
		clr.w	d4			; direction code
* man above monster ?
		cmp.w	d3,d1			; man higher ?
		ble.s	man_below		; skip if not
		bset	#0,d4			; set man above bit
		bra	ch_man_right
man_below	bset	#2,d4			; set man below bit
ch_man_right	cmp.w	d0,d2			; man to right of monster ?
		bge	man_right		; skip if it is
		bset	#3,d4			; set man left bit
		bra	ch_above
man_right	bset	#1,d4			; set man right bit
* is the square above earth,empty or fred ?
ch_above	cmp.b	#fred2,-30(a1)		; ok to move up ?
		beq.s	ch_right		; skip if ok
		cmp.b	#earth,-30(a1)
		beq.s	ch_right		; skip if ok
		cmp.b	#empty,-30(a1)
		beq.s	ch_right		; skip if ok
		bclr	#0,d4			; clear above bit
* is the square right earth,empty or fred ?
ch_right	cmp.b	#fred2,1(a1)		; ok to move right ?
		beq.s	ch_down			; skip if ok
		cmp.b	#earth,1(a1)
		beq.s	ch_down			; skip if ok
		cmp.b	#empty,1(a1)
		beq.s	ch_down			; skip if ok
		bclr	#1,d4			; clear right bit
ch_down		cmp.b	#fred2,30(a1)		; ok to move down ?
		beq.s	ch_left			; skip if ok
		cmp.b	#earth,30(a1)
		beq.s	ch_left			; skip if ok
		cmp.b	#empty,30(a1)
		beq.s	ch_left			; skip if ok
		bclr	#2,d4			; clear down bit
ch_left		cmp.b	#fred2,-1(a1)		; ok to move left ?
		beq.s	ch_direction		; skip if ok
		cmp.b	#earth,-1(a1)
		beq.s	ch_direction		; skip if ok
		cmp.b	#empty,-1(a1)
		beq.s	ch_direction		; skip if ok
		bclr	#3,d4			; clear left bit
* choose the direction
ch_direction	tst.w	d4			; can the monster move ?
		beq	next_monster		; skip if not
ch_dir000	jsr	random			; get random number
		and.l	#$0003,d6		; limit range
		btst	d6,d4			; can we go that direction ?
		bne.s	got_direction		; skip if we can
		bra.s	ch_dir000
got_direction	lsl.w	#2,d6			; make l_word offset
		lea	move_routs,a1		; routine pointers
		move.l	(a1,d6.w),a1
		jmp	(a1)
move_routs	dc.l	monster_up,monster_right,monster_down,monster_left
		dc.l	next_monster,next_monster,next_monster
monster_up	subq.w	#1,2(a0)		; adjust y position
		move.w	#$1800,4(a0)		; moving up
		bra	next_monster
monster_right	addq.w	#1,(a0)			; adjust x position
		move.w	#$1801,4(a0)		; moving right
		bra	next_monster
monster_down	addq.w	#1,2(a0)		; adjust y position
		move.w	#$1802,4(a0)		; moving down
		bra	next_monster
monster_left	subq.w	#1,(a0)			; adjust x
		move.w	#$1803,4(a0)		; moving left
		bra	next_monster
		
monster_moving	clr.w	d6
		move.b	5(a0),d6		; get monster direction
		bra	got_direction		; do move code
		
kill_monsters	move.w	num_monsters,d7		; number to check
		bne.s	kmon0000		; skip if at least one
		rts
kmon0000	subq.w	#1,d7			; 1 less for dbra
		lea	monster_data,a0		; monster data
kmon0010	movem.w	(a0),d0-d2		; x,y status
		cmp.w	#$ffff,d2		; monster dead ?
		beq	next_kill		; skip if dead
		lsr.w	#8,d2			; normalise status byte
		cmp.w	#12,d2			; is it active ?
		ble	next_kill		; skip if not active
		move.w	d0,d2			; copy x
		move.w	d1,d3			; copy y
		lsr.w	#2,d0			; normalise x
		lsr.w	#2,d1			; normalise y
		mulu.w	#30,d1			; y offset
		add.w	d0,d1			; total offset
		lea	test_level,a1		; level data
		add.w	d1,a1			; position pointer
* is the main square filled ?
		cmp.b	#empty,(a1)		; monster ok ?
		beq.s	kmon0020
		cmp.b	#earth,(a1)
		beq.s	kmon0020
		cmp.b	#fred2,(a1)
		beq.s	kmon0020
monster_dead	move.w	#$ffff,4(a0)		; kill the monster
		bra	next_kill

kmon0020	and.w	#$03,d2			; check to right ?
		beq.s	kmon0030		; skip if not
		cmp.b	#empty,1(a1)
		beq	next_kill
		cmp.b	#earth,1(a1)
		beq	next_kill
		cmp.b	#fred2,1(a1)
		beq	next_kill
		bra	monster_dead		; kill the monster
		
kmon0030	and.w	#$03,d3			; check below ?
		beq	next_kill		; skip if not
		cmp.b	#empty,30(a1)
		beq	next_kill
		cmp.b	#earth,30(a1)
		beq	next_kill
		cmp.b	#fred2,30(a1)
		beq	next_kill
		bra	monster_dead
		
next_kill	lea	6(a0),a0		; next monster data
		dbra	d7,kmon0010		; check them all
		rts
****************************************************
*                                                  *
* Random number generator. Returns in d6.          *
*                                                  *
****************************************************
random		movem.l	d4-d5/d7,-(sp)	; save registers
		tst.l	ran_num		; last random number
		bne	ran0000		; skip if not zero
		move.l	v_count,ran_num	; new start value
		move.w	#$700,colours
		move.w	#0,colours
ran0000		move.l	#3141592621,d7	; number 1
		move.l	ran_num,d6	; number 2
* multiply d7 by d6
		move.w	d7,d4
		move.w	d6,d5
		swap	d6
		swap	d7
		mulu	d4,d6
		mulu	d5,d7
		mulu	d5,d4
		add.w	d6,d7
		swap	d7
		clr.w	d7
		add.l	d4,d7		; d7 = d6*d7
		add.l	v_count,d7	; vsync random number
		move.l	d7,ran_num	; save new seed
		asr.l	#8,d7		; >> 8
		and.l	#$00ffffff,d7	; clear bits 24-31
		exg	d6,d7
		movem.l	(sp)+,d4-d5/d7	; restore registers
		rts			; random in d7


restore_screen	tst.w	which		; which screen to restore ?
		bne	res_char	; skip if character editor
res_map		move.w	#2,n2plot
		jsr	vsync_wait
		lea	elu,a6			; intro block
		jsr	plot_block
		jsr	smenu
		jsr	scrn_icons
		jsr	scrnic
		jsr	plot_chars
		jsr	draw_single
		jsr	vsync_wait		; change screens
		lea	elu,a6			; intro block
		jsr	plot_block
		jsr	smenu
		jsr	scrn_icons
		jsr	scrnic
		jsr	plot_chars
		jsr	draw_single
		rts
res_char	jsr	expand
		lea	clu,a6			; intro block
		jsr	plot_block
		jsr	cmen
		jsr	char_icons
		jsr	set_colors
		jsr	colour_cursor
		jsr	plot_ch
		jsr	plot_exp
		jsr	charic
		jsr	plot_names
		jsr	vsync_wait
		lea	clu,a6			; intro block
		jsr	plot_block
		jsr	cmen
		jsr	char_icons
		jsr	set_colors
		jsr	colour_cursor
		jsr	plot_exp
		jsr	plot_ch
		jsr	charic
		jsr	plot_names
		rts

decode_passwd
encode_passwd	lea	passa,a0		; passwords
		move.b	#%00011011,d1
		move.w	#7,d7			; 8 passwords to do
enp0000		move.w	#7,d6			; 8 chars per passwd
enp0010		move.b	(a0),d0			; get a char
		eor.b	d1,d0			; encode charcter
		move.b	d0,(a0)+
		add.b	#%11010010,d1		; change eor mask
		dbra	d6,enp0010
		dbra	d7,enp0000
		rts
		
******************
* play test data *
******************
v_count		dc.l	0
ran_num		dc.l	0
man_x		dc.w	0
man_y		dc.w	0
move_count	dc.w	0
move_amount	dc.l	0
spirit_cyc	dc.w	3
spirit_count	dc.w	10
reset_time	dc.w	0
play_time	dc.w	0
push_type	dc.w	0
push_offset	dc.w	0
push_count	dc.w	0
num_rocks	dc.w	0
num_weed	dc.w	0
num_monsters	dc.w	0
num_pulsators	dc.w	0
num_collect	dc.w	0
timeplay	dc.b	31,14,'TIME 0000',0
rock_data	ds.w	672*3
weed_data	ds.w	672*3
monster_data	ds.w	4*3
pulsator_data	ds.w	8*3
trans_data	ds.w	8*2
test_level	dcb.b	30,$ff
		rept	24
		dc.b	$ff
		dcb.b	28,empty
		dc.b	$ff
		endr
		dcb.b	30,$ff
copy_level	rept	25
		dcb.b	28,empty
		endr
copy_level2	rept	25
		dcb.b	28,empty
		endr
			
**************************************************************************
check_source	dc.l	0
scr1		dc.l	0
scr2		dc.l	0
mouse_x		dc.w	160
mouse_y		dc.w	100
m_buttons	dc.b	0
old_x		dc.w	0
old_y		dc.w	0
old_buttons	dc.b	0
older_x		dc.w	0
older_y		dc.w	0
x_max		dc.w	312
x_min		dc.w	2
y_max		dc.w	191
y_min		dc.w	2
which		dc.w	0
letters		dc.b	0,27,"1234567890_",0,8,0
		dc.b	"QWERTYUIOP",0,0,13,0,"AS"
		dc.b	"DFGHJKL",0,"'",0,0,0,"ZXCV"
		dc.b	"BNM",0,0,"/",0,0,0," ",0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,8,0,0,"_",8,0,0,0,0
		dc.b	0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,8,"h",0,0,0,0,"789456123"
		dc.b	"0",0,13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
keys		ds.b	128
activity	dc.b	$ff
pkt_dest	ds.l	1
act_pntr	ds.l	1
build_len	ds.b	1
build_pkt	ds.b	8
acia_stat	ds.b	1
misc_pkt	ds.b	8
mouse_pkt	ds.b	3
stick0_pkt	ds.b	2
stick1_pkt	ds.b	2
old_key		ds.l	1
key_press	ds.w	1
micons		incbin	menuicon.bin
mouse_ch	incbin	mouse.bin
font		incbin	font.bin
icons		incbin	icons.bin
e1		dc.b	0,00,'                                        ',0
e2		dc.b	0,01,'                                        ',0
e3		dc.b	0,02,'                                        ',0
e4		dc.b	0,03,'                                        ',0
e5		dc.b	0,04,'                                        ',0
e6		dc.b	0,05,'                                        ',0
e7		dc.b	0,06,'                                        ',0
e8		dc.b	0,07,'                                        ',0
e9		dc.b	0,08,'                                        ',0
ea		dc.b	0,09,'                                        ',0
eb		dc.b	0,10,'                                        ',0
ec		dc.b	0,11,'                                        ',0
ed		dc.b	0,12,'                                        ',0
ee		dc.b	0,13,'                                        ',0
ef		dc.b	0,14,'                                        ',0
eg		dc.b	0,15,'                                        ',0
eh		dc.b	0,16,'                                        ',0
ei		dc.b	0,17,'                                        ',0
ej		dc.b	0,18,'                                        ',0
ek		dc.b	0,19,'                                        ',0
el		dc.b	0,20,'                                        ',0
em		dc.b	0,21,'                            elLTkfelRTkf',0
en		dc.b	0,22,'                            j    jj    j',0
eo		dc.b	0,23,'                            j    jj    j',0
ep		dc.b	0,24,'                 TIME XXXX  j    jj    j',0
eq		dc.b	0,25,'LEFT  = EMPTY SQUARE        j    jj    j',0
er		dc.b	0,26,'RIGHT = ROLL DOWN LEFT      glLTkhglRTkh',0
es		dc.b	0,27,'MAP : A PASSWORD : XXXXXXXX p R.I.ALLEN ',0
elu		dc.l	28,e1,e2,e3,e4,e5,e6,e7,e8,e9,ea,eb,ec,ed,ee
		dc.l	ef,eg,eh,ei,ej,ek,el,em,en,eo,ep,eq,er,es
full_text	dc.b	0,24,'ESCAPE TO EXIT   ',0
ch1		dc.b	0,00,'                 eiiiif          eiiiifB',0
ch2		dc.b	0,01,'                cj    j         pj    jU',0
ch3		dc.b	0,02,'                jj    j         Oj    jF',0
ch4		dc.b	0,03,'                jj    j         Pj    jF',0
ch5		dc.b	0,04,'                jj    j         Yj    jE',0
ch6		dc.b	0,05,'                jgiiiih          giiiihR',0
ch7		dc.b	0,06,'                j                       ',0
ch8		dc.b	0,07,'                j                       ',0
ch9		dc.b	0,08,'                j                       ',0
ch10		dc.b	0,09,'                j                       ',0
ch11		dc.b	0,10,'                j                       ',0
ch12		dc.b	0,11,'                j                       ',0
ch13		dc.b	0,12,'                j                       ',0
ch14		dc.b	0,13,'                j                       ',0
ch15		dc.b	0,14,'                j                       ',0
ch16		dc.b	0,15,'                j                       ',0
ch17		dc.b	0,16,'                d                       ',0
ch18		dc.b	0,17,'aiiiiiiiiiiiiiib                        ',0
ch19		dc.b	0,18,'                                        ',0
ch20		dc.b	0,19,'COLOURS                                 ',0
ch21		dc.b	0,20,'einininininininif   0123456789ABCDEF    ',0
ch22		dc.b	0,21,'j j j j j j j j j Ra~~~~~~~~~~~~~~~~bR  ',0
ch23		dc.b	0,22,'kioioioioioioioil Ga~~~~~~~~~~~~~~~~bG  ',0
ch24		dc.b	0,23,'j j j j j j j j j Ba~~~~~~~~~~~~~~~~bB  ',0
ch25		dc.b	0,24,'gimimimimimimimih   0123456789ABCDEF    ',0
ch26		dc.b	0,25,'DRAWING MODE :                          ',0
ch27		dc.b	0,26,'                                        ',0
ch28		dc.b	0,27,'p R.I.ALLEN 1993 - RIGAMORTIS SOFTWARE! ',0
clu		dc.l	28,ch1,ch2,ch3,ch4,ch5,ch6,ch7,ch8,ch9,ch10
		dc.l	ch11,ch12,ch13,ch14,ch15,ch16,ch17,ch18
		dc.l	ch19,ch20,ch21,ch22,ch23,ch24,ch25,ch26,ch27,ch28
test01		dc.b	0,00,'swwwwwwwwwwwwwwwwwwwwwwwwwwwwt          ',0
test02		dc.b	0,01,"x                            z     '    ",0
test03		dc.b	0,02,'x                            z          ',0
test04		dc.b	0,03,'x                            z     c    ',0
test05		dc.b	0,04,'x                            z     j    ',0
test06		dc.b	0,05,'x                            z Z aioib X',0
test07		dc.b	0,06,'x                            z     j    ',0
test08		dc.b	0,07,'x                            z     d    ',0
test09		dc.b	0,08,'x                            z          ',0
test10		dc.b	0,09,'x                            z     /    ',0
test11		dc.b	0,10,'x                            z          ',0
test12		dc.b	0,11,'x                            z  KEYS AS ',0
test13		dc.b	0,12,'x                            z   ABOVE  ',0
test14		dc.b	0,13,'x                            z          ',0
test15		dc.b	0,14,'x                            z          ',0
test16		dc.b	0,15,'x                            z          ',0
test17		dc.b	0,16,'x                            z          ',0
test18		dc.b	0,17,'x                            z          ',0
test19		dc.b	0,18,'x                            z          ',0
test20		dc.b	0,19,'x                            z          ',0
test21		dc.b	0,20,'x                            z          ',0
test22		dc.b	0,21,'x                            z          ',0
test23		dc.b	0,22,'x                            z          ',0
test24		dc.b	0,23,'x                            z          ',0
test25		dc.b	0,24,'x                            z          ',0
test26		dc.b	0,25,'uyyyyyyyyyyyyyyyyyyyyyyyyyyyyv          ',0
test27		dc.b	0,26,'ESCAPE TO EXIT                          ',0
test28		dc.b	0,27,'p RIGAMORTIS SOFTWARE                   ',0
test_lu		dc.l	28,test01,test02,test03,test04,test05
		dc.l	test06,test07,test08,test09,test10
		dc.l	test11,test12,test13,test14,test15
		dc.l	test16,test17,test18,test19,test20
		dc.l	test21,test22,test23,test24,test25
		dc.l	test26,test27,test28
u1		dc.b	0,00,'eiiiiiiiiiiiiiiiiiiiiiiiiiif',0
u2		dc.b	0,01,'j                          j',0
u3		dc.b	0,02,'j                  st      j',0
u4		dc.b	0,03,'j   swt swt swt wwt v swt  j',0
u5		dc.b	0,04,'j   x   x v x   z z   x    j',0
u6		dc.b	0,05,'j   xww xw  xww z z   uwt  j',0
u7		dc.b	0,06,'j   x   x t x   z z     z  j',0
u8		dc.b	0,07,'j   x   x z uyv yyv   uyv  j',0
u9		dc.b	0,08,'j                          j',0
ua		dc.b	0,09,'j      swt x swt wwt       j',0
ub		dc.b	0,10,'j      x   x x z z z       j',0
uc		dc.b	0,11,'j      xww x x z z z       j',0
ud		dc.b	0,12,'j      x   x x z z z       j',0
ue		dc.b	0,13,'j      x   x x z yyv       j',0
uf		dc.b	0,14,'j                          j',0
ug		dc.b	0,15,'j        THIS MAP IS       j',0
uh		dc.b	0,16,'j        UNAVAILABLE       j',0
ui		dc.b	0,17,'j                          j',0
uj		dc.b	0,18,'j                          j',0
uk		dc.b	0,19,'j                          j',0
ul		dc.b	0,20,'j                          j',0
um		dc.b	0,21,'j                          j',0
un		dc.b	0,22,'j                          j',0
uo		dc.b	0,23,'giiiiiiiiiiiiiiiiiiiiiiiiiih',0
up		dc.b	0,24,'                 TIME XXXX  ',0
unlu		dc.l	26,u1,u2,u3,u4,u5,u6,u7,u8,u9,ua,ub,uc
		dc.l	ud,ue,uf,ug,uh,ui,uj,uk,ul,um,un,uo,up,es
wel1		dc.b	0,00,'eiiiiiiiiiiiiiiiiiiiiiiiiiif',0
wel2		dc.b	0,01,'j                          j',0
wel3		dc.b	0,02,'j      WELCOME TO THE      j',0
wel4		dc.b	0,03,'j                          j',0
wel5		dc.b	0,04,"j       FRED'S  FIND       j",0
wel6		dc.b	0,05,'j                          j',0
wel7		dc.b	0,06,'j     MAP & CHARACTER      j',0
wel8		dc.b	0,07,'j                          j',0
wel9		dc.b	0,08,'j       EDITOR  V3.0       j',0
wela		dc.b	0,09,'j                          j',0
welb		dc.b	0,10,'j   WRITTEN BY R.I.ALLEN   j',0
welc		dc.b	0,11,'j                          j',0
weld		dc.b	0,12,'j  p  RIGAMORTIS SOFTWARE  j',0
wele		dc.b	0,13,'j                          j',0
welf		dc.b	0,14,'j ESCAPE TO TOGGLE BETWEEN j',0
welg		dc.b	0,15,'j  CHARACTER / MAP EDITOR  j',0
welh		dc.b	0,16,'j                          j',0
weli		dc.b	0,17,'j   CYBERPUNKS SOFTWARE!   j',0
welj		dc.b	0,18,'j                          j',0
welk		dc.b	0,19,'j         Q TO QUIT        j',0
well		dc.b	0,20,'j                          j',0
welm		dc.b	0,21,'j                          j',0
weln		dc.b	0,22,'j   ANY KEY TO CONTINUE!   j',0
welo		dc.b	0,23,'giiiiiiiiiiiiiiiiiiiiiiiiiih',0
welp		dc.b	0,24,'                 TIME XXXX  ',0
wellu		dc.l	25,wel1,wel2,wel3,wel4,wel5,wel6,wel7,wel8,wel9,wela,welb,welc
		dc.l	weld,wele,welf,welg,welh,weli,welj,welk,well,welm,weln,welo,welp
well_plot	dc.w	1
ts_txt		dc.b	0,0,'A',0
handle		dc.w	0
valid_chars	dc.b	'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_',8,27,13,0
valid2		dc.b	'0123456789',8,27,13,0
map_files	dc.b	'*.MAP',0
chr_files	dc.b	'*.CHR',0
star_dot	dc.b	'*.*',0
var_pntr	dc.l	map_files
lm1		dc.b	0,02,'j LOAD MAP FILE.           j',0
lm2		dc.b	0,05,'j FILES  =                 j',0
sm1		dc.b	0,02,'j SAVE MAP FILE.           j',0
sm2		dc.b	0,05,'j FILENAME :         .MAP  j',0
lc1		dc.b	0,02,'j LOAD CHARACTER FILE.     j',0
sc1		dc.b	0,02,'j SAVE CHARACTER FILE.     j',0
sc2		dc.b	0,05,'j FILENAME :         .CHR  j',0
lt1		dc.b	0,01,'eiiiiiiiiiiiiiiiiiiiiiiiiiif',0
lt3		dc.b	0,03,'kiiiiiiiiiiiiiiiiiiiiiiiiiil',0
lt4		dc.b	0,04,'j PATH   =                 j',0
lt6		dc.b	0,06,'kiiiiiiiiiiiiiiiiiiniiiiiiil',0
lt6_on		dc.b	4,03,'lMAP PROTECTION ONk',0
lt6_off		dc.b	4,03,'iiiiiiiiiiiiiiiiiii',0
lt7		dc.b	0,07,'j   --------.--- c j       j',0
lt8		dc.b	0,08,'j   --------.--- | j       j',0
lt9		dc.b	0,09,'j   --------.--- | j       j',0
lta		dc.b	0,10,'j   --------.--- | j       j',0
ltb		dc.b	0,11,'j   --------.--- | j       j',0
ltc		dc.b	0,12,'j   --------.--- d j       j',0
ltd		dc.b	0,13,'kiiiiiiiiiiiiiiiiiil       j',0
lte		dc.b	0,14,'j   --------.--- c j       j',0
ltf		dc.b	0,15,'j   --------.--- | j       j',0
ltg		dc.b	0,16,'j   --------.--- | j       j',0
lth		dc.b	0,17,'j   --------.--- | j       j',0
lti		dc.b	0,18,'j   --------.--- | j       j',0
ltj		dc.b	0,19,'j   --------.--- | j       j',0
ltk		dc.b	0,20,'j   --------.--- | j       j',0
ltl		dc.b	0,21,'j   --------.--- d j       j',0
ltm		dc.b	0,22,'gbCANCELaiiiiiiiiiimiiiiiiih',0
ltable		dc.l	22,lt1,lm1,lt3,lt4,lm2,lt6,lt7,lt8,lt9,lta,ltb,ltc
		dc.l	ltd,lte,ltf,ltg,lth,lti,ltj,ltk,ltl,ltm
mdesc01		dc.b	8,25,'EMPTY SQUARE     ',0
mdesc02		dc.b	8,26,'ROLL LEFT        ',0
mdesc03		dc.b	8,25,'ROLL RIGHT       ',0
mdesc04		dc.b	8,25,'SOLID BLOCK      ',0
mdesc05		dc.b	8,25,'SOLID BLOCK      ',0
mdesc06		dc.b	8,25,'KEY              ',0
mdesc07		dc.b	8,25,'SAFE             ',0
mdesc08		dc.b	8,25,'DIAMOND          ',0
mdesc09		dc.b	8,25,'ROCK             ',0
mdesc10		dc.b	8,25,'PLUNGER          ',0
mdesc11		dc.b	8,25,'BOMB             ',0
mdesc12		dc.b	8,25,'LEVEL EXIT       ',0
mdesc13		dc.b	8,25,'EGG              ',0
mdesc14		dc.b	8,25,'TRANSPORTER      ',0
mdesc15		dc.b	8,25,'FRED THE HERO!   ',0
mdesc16		dc.b	8,25,'EARTH            ',0
mdesc17		dc.b	8,25,'THE WEED         ',0
mdesc18		dc.b	8,25,'TIME CAPSULE     ',0
mdesc19		dc.b	8,25,'SKULL            ',0
mdesc20		dc.b	8,25,'SOLID BLOCK      ',0
mdesc21		dc.b	8,25,'SOLID BLOCK      ',0
mdesc22		dc.b	8,25,'SOLID BLOCK      ',0
mdesc23		dc.b	8,25,'SOLID BLOCK      ',0
mdesc24		dc.b	8,25,'SOLID BLOCK      ',0
mdesc25		dc.b	8,25,'PULSATOR TRAP    ',0
mdesc26		dc.b	8,25,'PULSATOR         ',0
clit1		dc.b	8,25,'CLICK DESTINATION',0
clit2		dc.b	8,26,'CLICK DESTINATION',0
txtlu		dc.l	mdesc01,mdesc02,mdesc03,mdesc04,mdesc05,mdesc06
		dc.l	mdesc07,mdesc08,mdesc09,mdesc10,mdesc11,mdesc12
		dc.l	mdesc13,mdesc14,mdesc15,mdesc16,mdesc17,mdesc18
		dc.l	mdesc19,mdesc20,mdesc21,mdesc22,mdesc23,mdesc24
		dc.l	mdesc25,mdesc26
drm_stuff	dc.l	2,es,timestr
f_pntr		dc.l	0
scursor		dc.w	0
sflash		dc.w	25
schar		dc.w	0
s_fname		dc.b	'                ',0
ps0		dc.b	5,05,'eiiiiiiiiiiiiiiif',0
ps1		dc.b	5,06,'j MAP PASSWORDS j',0
ps2		dc.b	5,07,'kiiiiiiiiiiiiiiil',0
ps3		dc.b	5,08,'jbA : ........ aj',0
ps4		dc.b	5,09,'jbB : ........ aj',0
ps5		dc.b	5,10,'jbC : ........ aj',0
ps6		dc.b	5,11,'jbD : ........ aj',0
ps7		dc.b	5,12,'jbE : ........ aj',0
ps8		dc.b	5,13,'jbF : ........ aj',0
ps9		dc.b	5,14,'jbG : ........ aj',0
psa		dc.b	5,15,'jbH : ........ aj',0
psb		dc.b	5,16,'gbCANCELaiiiiiiih',0
pslu		dc.l	12,ps0,ps1,ps2,ps3,ps4,ps5
		dc.l	ps6,ps7,ps8,ps9,psa,psb
newpass		dc.b	'           ',0
passpntr	dc.l	passa
paspntr2	dc.l	ps3
pcursor		dc.w	0
pchar		dc.w	0
pflash		dc.w	25
tm0		dc.b	5,08,'eiiiiiiiiiiiiif',0
tm1		dc.b	5,09,'j LEVEL TIME. j',0
tm2		dc.b	5,10,'kiiiiiiiiiiiiil',0
tm3		dc.b	5,11,'j   c c c c   j',0
tm4		dc.b	5,12,'j   9 9 9 9   j',0
tm5		dc.b	5,13,'j   d d d d   j',0
tm6		dc.b	5,14,'gbCANCELaiiiiih',0
tmlu		dc.l	7,tm0,tm1,tm2,tm3,tm4,tm5,tm6
timepntr	dc.l	timea
timestr		dc.b	22,24,'9999',0
edc0		dc.b	4,06,'eiiiiiiiiiiiiiiiiiiiif',0
edc1		dc.b	4,07,'j ENTER EDITOR CODES j',0
edc2		dc.b	4,08,'kiiiiiiiiiiiiiiiiiiiil',0
edc3		dc.b	4,09,'j A :                j',0
edc4		dc.b	4,10,'j B :                j',0
edc5		dc.b	4,11,'j C :                j',0
edc6		dc.b	4,12,'j D :                j',0
edc7		dc.b	4,13,'j E :                j',0
edc8		dc.b	4,14,'j F :                j',0
edc9		dc.b	4,15,'j G :                j',0
edca		dc.b	4,16,'j H :                j',0
edcb		dc.b	4,17,'gbCANCELaiiiiiiiiiiiih',0
edclu		dc.l	12,edc0,edc1,edc2,edc3,edc4,edc5,edc6
		dc.l	edc7,edc8,edc9,edca,edcb
cor_txt		dc.b	16,00,'CORRECT!',0
num_txt		dc.b	10,00,'      ',0
delay		dc.w	5
mapi0		dc.b	4,06,'eiiiiiiiiiiiiiiiiiiif',0
mapi1		dc.b	4,07,'j  MAP INFORMATION  j',0
mapi2		dc.b	4,08,'kiiiiiiiiiiiiiiiiiiil',0
mapi3		dc.b	4,09,'j FRED       = 000  j',0
mapi4		dc.b	4,10,'j EXIT       = 000  j',0
mapi5		dc.b	4,11,'j PLUNGERS   = 000  j',0
mapi6		dc.b	4,12,'j BOMBS      = 000  j',0
mapi7		dc.b	4,13,'j PULSATORS  = 000  j',0
mapi8		dc.b	4,14,'j TRAPS      = 000  j',0
mapi9		dc.b	4,15,'j KEYS       = 000  j',0
mapia		dc.b	4,16,'j SAFES      = 000  j',0
mapib		dc.b	4,17,'j MONSTERS   = 000  j',0
mapic		dc.b	4,18,'gbCANCELaiiiiiiiiiiih',0
mapilu		dc.l	13,mapi0,mapi1,mapi2,mapi3,mapi4,mapi5,mapi6,mapi7,mapi8,mapi9,mapia,mapib,mapic
icnums		dc.b	fred,exit,plunger,bomb,spirit1,cage,key,safe,egg
top_line	dc.b	4,06,'eiiiiiiiiiiiiiiiiiiif',0
unk01		dc.b	4,07,'j    DISK  ERROR    j',0
unk02		dc.b	4,08,'j AN UN-KNOWN ERROR j',0
unk03		dc.b	4,09,'j    HAS OCCURED    j',0
bot_line	dc.b	4,10,'gbCANCELaiiiiiiiiiiih',0
fnf02		dc.b	4,08,'j  FILE NOT FOUND.  j',0
fnf03		dc.b	4,09,'j                   j',0
pnf02		dc.b	4,08,'j INVALID  PATHNAME j',0
gen02		dc.b	4,08,'j   GENERAL ERROR   j',0
dnr02		dc.b	4,08,'j  DRIVE NOT READY  j',0
wri02		dc.b	4,08,'j WRITE DATA ERROR  j',0
rea02		dc.b	4,08,'j  READ DATA ERROR  j',0
drp02		dc.b	4,08,'j     DISK WRITE    j',0
drp03		dc.b	4,09,'j     PROTECTED!    j',0
nod02		dc.b	4,08,'j  DRIVE NOT READY  j',0
unk_lu		dc.l	5,top_line,unk01,unk02,unk03,bot_line
fnf_lu		dc.l	5,top_line,unk01,fnf02,fnf03,bot_line
pnf_lu		dc.l	5,top_line,unk01,pnf02,fnf03,bot_line
gen_lu		dc.l	5,top_line,unk01,gen02,fnf03,bot_line
dnr_lu		dc.l	5,top_line,unk01,dnr02,fnf03,bot_line
wri_lu		dc.l	5,top_line,unk01,wri02,fnf03,bot_line
rea_lu		dc.l	5,top_line,unk01,rea02,fnf03,bot_line
drp_lu		dc.l	5,top_line,unk01,drp02,drp03,bot_line
nod_lu		dc.l	5,top_line,unk01,nod02,fnf03,bot_line
err_lu		dc.l	-33,fnf_lu
		dc.l	-34,pnf_lu
		dc.l	-01,gen_lu
		dc.l	-02,dnr_lu
		dc.l	-10,wri_lu
		dc.l	-11,rea_lu
		dc.l	-12,gen_lu
		dc.l	-13,drp_lu
		dc.l	-17,nod_lu
dash_line	dc.b	'--------.---',0
drive		dc.b	'A:',0
mouse_loc	dc.b	0,24,'X = 00 Y = 00 ',0
pos_txt		dc.b	0,26,'X = 00 Y = 00 ',0
mouse_ers	dc.b	0,24,'              ',0
pos_ers		dc.b	0,26,'              ',0
insert		dc.l	lm1,lm2,5585,maps
		dc.l	sm1,sm2,5585,maps
		dc.l	lc1,lm2,25632,char_cols
		dc.l	sc1,sc2,25632,char_cols
max_icons	dc.w	672,672,672,672,672
		dc.w	672,672,672,672
		dc.w	672,672,001,004,004
		dc.w	001,672,672,672,672
		dc.w	672,672,672,672,672
		dc.w	008,008
placed		ds.w	40
lvl_pntr	dc.l	maps
left		dc.w	0
right		dc.w	1
oleft		dc.w	0
oright		dc.w	1
ooleft		dc.w	0
ooright		dc.w	1
leftp		dc.l	mdesc01
rightp		dc.l	mdesc02
ic_cursor	dc.w	%0000000000001111,%0000000000001111
		dc.w	%1111111111110000,%1111111111110000
		dc.w	%0000000000001100,%0000000000001100
		dc.w	%0000000000110000,%0000000000110000
edit_ch		dc.w	%1001000000000000,%1001000000000000
		dc.w	%0000100100000000,%0000100100000000
		dc.w	%0000000010010000,%0000000010010000
		dc.w	%0000000000001001,%0000000000001001
edit_ch2	dc.w	%1111000000000000,%1111000000000000
		dc.w	%0000111100000000,%0000111100000000
		dc.w	%0000000011110000,%0000000011110000
		dc.w	%0000000000001111,%0000000000001111
pixel		dc.w	%1000000000000000,%0100000000000000
		dc.w	%0010000000000000,%0001000000000000
		dc.w	%0000100000000000,%0000010000000000
		dc.w	%0000001000000000,%0000000100000000
		dc.w	%0000000010000000,%0000000001000000
		dc.w	%0000000000100000,%0000000000010000
		dc.w	%0000000000001000,%0000000000000100
		dc.w	%0000000000000010,%0000000000000001
epixel		dc.w	%1111000000000000,%0000111100000000
		dc.w	%0000000011110000,%0000000000001111
ch_icon		dc.w	0
ch_old		dc.w	0
ch_older	dc.w	0
desc01		dc.b	0,0,'  EMPTY SQUARE  ',0
desc02		dc.b	0,0,'   ROLL LEFT    ',0
desc03		dc.b	0,0,'   ROLL RIGHT   ',0
desc04		dc.b	0,0,'  SOLID BLOCK   ',0
desc05		dc.b	0,0,'  SOLID BLOCK   ',0
desc06		dc.b	0,0,'      KEY       ',0
desc07		dc.b	0,0,'      SAFE      ',0
desc08		dc.b	0,0,'     DIAMOND    ',0
desc09		dc.b	0,0,'      ROCK      ',0
desc10		dc.b	0,0,'     PLUNGER    ',0
desc11		dc.b	0,0,'      BOMB      ',0
desc12		dc.b	0,0,'      EXIT      ',0
desc13		dc.b	0,0,'      EGG       ',0
desc14		dc.b	0,0,'   TRANSPORTER  ',0
desc15		dc.b	0,0,'      FRED      ',0
desc16		dc.b	0,0,'      EARTH     ',0
desc17		dc.b	0,0,'    THE WEED    ',0
desc18		dc.b	0,0,'  TIME CAPSULE  ',0
desc19		dc.b	0,0,'      SKULL     ',0
desc20		dc.b	0,0,'   SOLID BLOCK  ',0
desc21		dc.b	0,0,'   SOLID BLOCK  ',0
desc22		dc.b	0,0,'   SOLID BLOCK  ',0
desc23		dc.b	0,0,'   SOLID BLOCK  ',0
desc24		dc.b	0,0,'   SOLID BLOCK  ',0
desc25		dc.b	0,0,'  PULSATOR TRAP ',0
desc26		dc.b	0,0,'   PULSATOR #1  ',0
desc27		dc.b	0,0,'   PULSATOR #2  ',0
desc28		dc.b	0,0,'   PULSATOR #3  ',0
desc29		dc.b	0,0,'   CRACKED EGG  ',0
desc30		dc.b	0,0,'   MONSTER #1   ',0
desc31		dc.b	0,0,'   MONSTER #2   ',0
desc32		dc.b	0,0,'   MONSTER #3   ',0
desc33		dc.b	0,0,'  LOOKING LEFT  ',0
desc34		dc.b	0,0,'  LOOKING RIGHT ',0
desc35		dc.b	0,0,'   UP/DOWN #1   ',0
desc36		dc.b	0,0,'   UP/DOWN #2   ',0
desc37		dc.b	0,0,'   UP/DOWN #3   ',0
desc38		dc.b	0,0,'   UP/DOWN #4   ',0
desc39		dc.b	0,0,'  WALK LEFT #1  ',0
desc40		dc.b	0,0,'  WALK LEFT #2  ',0
desc41		dc.b	0,0,'  WALK LEFT #3  ',0
desc42		dc.b	0,0,'  WALK LEFT #4  ',0
desc43		dc.b	0,0,'  WALK LEFT #5  ',0
desc44		dc.b	0,0,'  WALK LEFT #6  ',0
desc45		dc.b	0,0,'  WALK RIGHT #1 ',0
desc46		dc.b	0,0,'  WALK RIGHT #2 ',0
desc47		dc.b	0,0,'  WALK RIGHT #3 ',0
desc48		dc.b	0,0,'  WALK RIGHT #4 ',0
desc49		dc.b	0,0,'  WALK RIGHT #5 ',0
desc50		dc.b	0,0,'  WALK RIGHT #6 ',0
ctxtlu		dc.l	desc01,desc02,desc03,desc04,desc05,desc06,desc07
		dc.l	desc08,desc09,desc10,desc11,desc12,desc13,desc14
		dc.l	desc15,desc16,desc17,desc18,desc19,desc20,desc21
		dc.l	desc22,desc23,desc24,desc25,desc26,desc27,desc28
		dc.l	desc29,desc30,desc31,desc32,desc33,desc34,desc35
		dc.l	desc36,desc37,desc38,desc39,desc40,desc41,desc42
		dc.l	desc43,desc44,desc45,desc46,desc47,desc48,desc49
		dc.l	desc50
walk_left	dc.l	chars+left1*512,chars+left2*512
		dc.l	chars+left3*512,chars+left4*512
		dc.l	chars+left5*512,chars+left6*512
		dc.l	0
walk_right	dc.l	chars+right1*512,chars+right2*512
		dc.l	chars+right3*512,chars+right4*512
		dc.l	chars+right5*512,chars+right6*512
		dc.l	0
walk_up		dc.l	chars+up_down1*512,chars+up_down2*512
		dc.l	chars+up_down3*512,chars+up_down4*512
		dc.l	chars+up_down3*512,chars+up_down2*512
		dc.l	0
looking		dc.l	chars+lookleft*512,chars+lookleft*512
		dc.l	chars+lookleft*512,chars+lookleft*512
		dc.l	chars+fred*512,chars+fred*512
		dc.l	chars+fred*512,chars+fred*512
		dc.l	chars+lookright*512,chars+lookright*512
		dc.l	chars+lookright*512,chars+lookright*512
		dc.l	chars+fred*512,chars+fred*512
		dc.l	chars+fred*512,chars+fred*512
		dc.l	0
monster		dc.l	chars+monster1*512,chars+monster2*512
		dc.l	chars+monster3*512,chars+monster2*512
		dc.l	0
spirits		dc.l	chars+spirit1*512,chars+spirit2*512
		dc.l	chars+spirit3*512,chars+spirit2*512
		dc.l	0
seq_start	dc.l	0
seq_pntr	dc.l	0
char_pntr	dc.l	chars
old_pntr	dc.l	0
tcount		dc.w	25
leftc		dc.b	0,0,'L',0
rightc		dc.b	0,0,'R',0
clearch1	dc.b	0,0,' ',0
clearch2	dc.b	0,0,' ',0
arru		dc.b	0,0,'c',0
arrd		dc.b	0,0,'d',0
arrl		dc.b	0,0,'a',0
arrr		dc.b	0,0,'b',0
s_txt		dc.b	0,0,' ',0
s_dirs		dc.b	'cbdaq'
red_lvl		dc.b	20,21,'~~~~~~~~~~~~~~~~',0
green_lvl	dc.b	20,22,'~~~~~~~~~~~~~~~~',0
blue_lvl	dc.b	20,23,'~~~~~~~~~~~~~~~~',0
red		dc.w	0
green		dc.w	0
blue		dc.w	0
colour_num	dc.w	0
old_num		dc.w	0
older_num	dc.w	0
cursor_x	dc.w	0
cursor_y	dc.w	0
fs_x		ds.w	2
n_txt		dc.b	15,25,'NORMAL    ',0
m_txt		dc.b	15,25,'MIRROR    ',0
f_txt		dc.b	15,25,'FLOOD FILL',0
sp_starts	dc.b	0,1,1,1,2,1,1,1,0,0,1,1,0,0,1,1
		dc.b	2,2,2,2,2,2,2,2,2,0,2,2,2,2,2,2
		dc.b	0,1,1,1,0,1,1,1,0,0,1,1,0,0,1,1
		dc.b	2,2,2,2,2,2,2,2,0,0,2,2,2,0,2,2
		dc.b	3,3,1,1,3,3,1,1,0,0,1,1,0,0,1,1
		dc.b	3,3,3,3,3,3,3,3,0,0,2,0,0,0,2,0
		dc.b	3,3,3,1,3,3,1,1,0,0,1,1,0,0,1,1
		dc.b	3,3,3,3,3,3,3,3,0,0,2,3,0,0,2,0
		dc.b	3,1,1,1,2,1,1,1,0,0,1,1,0,0,1,1
		dc.b	2,2,2,2,2,2,2,2,2,0,2,2,2,2,2,2
		dc.b	0,1,1,1,0,1,1,1,0,0,1,1,0,0,1,1
		dc.b	2,2,2,2,2,2,2,2,0,0,2,2,2,0,2,2
		dc.b	3,3,3,1,3,3,1,1,0,0,1,1,0,0,1,1
		dc.b	3,3,3,3,3,3,3,3,0,0,2,1,0,0,2,1
		dc.b	3,3,3,1,3,3,1,1,0,0,1,1,0,0,1,1
		dc.b	3,3,3,3,3,3,3,3,0,0,2,3,0,0,2,0
spirit_d	dc.w	0		; spirit flash flag on/off
spirit_t	dc.w	25		; spirit flash timer
ocursor		dc.l	0
oocursor	dc.l	0
old_map		dc.w	0
available	ds.w	8
nums_ent	ds.w	8
codes		ds.w	8
question	dc.b	'????????'
map		dc.w	0
maps		ds.b	8*688
passa		dc.b	'A       '
passb		dc.b	'B       '
passc		dc.b	'C       '
passd		dc.b	'D       '
passe		dc.b	'E       '
passf		dc.b	'F       '
passg		dc.b	'G       '
passh		dc.b	'H       '
timea		dc.w	9999
timeb		dc.w	9999
timec		dc.w	9999
timed		dc.w	9999
timee		dc.w	9999
timef		dc.w	9999
timeg		dc.w	9999
timeh		dc.w	9999
protect		dc.b	0
char_cols	incbin	fredfind.chr
chars		equ	char_cols+32
		section	bss
old_ssp		ds.l	1		; old supervisor stack pointer
old_scr		ds.l	1		; old screen start
old_res		ds.w	1		; old resolution
old_hsync	ds.l	1		; old hblank int vector
overwrite	ds.l	1		; vbl routien list pointer
old_icon	ds.w	1		; anim character buffer
vsync_tr	ds.w	1		; to signal vbl interupt
enablea		ds.b	1		; old iera enable
enableb		ds.b	1		; old ierb enable
maska		ds.b	1		; old iera mask
maskb		ds.b	1		; old ierb mask
old_pal		ds.w	16		; initial pallette
color_buff	ds.w	16		; colours to fade
flood_col	ds.w	1		; flood fill colour
quit		ds.w	1		; <>0 then exit current routine
n2plot		ds.w	1		; character update flag
erase		ds.w	5		; plot data
trans_ch	ds.w	1		; transporter flash flag on/off
edit_flag	ds.w	1		; disables mouse pointer in expanded
color_flag	ds.w	1		; colour update
col_delay	ds.w	1		; update delay for arrows
mir_delay	ds.w	1		; nmf update display
scr_delay	ds.w	1		; expanded scroll/flip delay
pro_count	ds.w	1		; protection on/off counter
edit_num	ds.w	1
edit_t		ds.w	1
edit		ds.w	2
dta		ds.l	1		; pntr 2 disk transfer buffer
dir_offset	ds.w	1		; dir number scrolls
file_offset	ds.w	1		; file number scrolls
load_save	ds.w	1		; save/load flag,0 lm 1 sm 2 lc 3 sc
files		ds.w	1		; number of *.map's/*.chr's
file_num	ds.w	1		; filenumber to load
dirs		ds.w	1		; number of sub-directories
drives		ds.w	1		; number of attached drives
fcursor		ds.w	1		; cursor position for filename text
trans1		ds.w	2
trans2		ds.w	2
file_size	ds.l	1		; number of bytes to load/save
destination	ds.l	1		; pointer to map or char data
file_number	ds.w	1		; file number to load
pathname	ds.b	64		; disk pathname
expanded	ds.b	2048		; expanded character data
copy		ds.b	512		; copy buffer
copy2		ds.b	512		; rotate space
fade_data	ds.b	32*16
buffer1		ds.w	8*8
buffer2		ds.w	8*8
screen		ds.w	1		; flag for visible screen
screen_choice	ds.w	1
screens		ds.b	84480		; screen data
dir_names	ds.b	14*50		; directory names
f_names		ds.b	14*50		; filenames
my_stack	ds.b	16000
end_stack




