
	ttl	'RADAR DEMO'	Program title

	include	h:\devpac\incdir\gemmacro.i
	include	h:\devpac\incdir\tosmacro.s
	
size	equ	16	size of table entry
delay	equ	140	delay period
colour4	equ	$FF8248	COLOUR 4

f_col	equ	0	colour flag
f_blip	equ	1	=1 when blip detected
f_col4	equ	2	toggles coast line colour

;The program proper

start_of_pgm	move.l	4(sp),a3	base page
	move.l	#stack,sp	move SP
	move.l	12(a3),d0	text len
	add.l	20(a3),d0	data len
	add.l	28(a3),d0	BSS len
	add.l	#256,d0	basepage

	move.l	d0,-(sp)	shrink memory
	move.l	a3,-(sp)
	clr	-(sp)
	move	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp

	appl_init		initialise application
	move	d0,ap_id	and store the app ident
	graf_handle		fetch graf handle code
	move	d0,current_handle  and store VDI handle

	lea	intin,a0	initialise intin array
	moveq	#10-1,d0	
shell1	move	#1,(a0)+	most params are 1
	dbra	d0,shell1
	move	#2,(a0)+	use RC system
	v_opnvwk		open work station
	v_hide_c		hide mouse

	vs_clip	#1,#0,#0,#639,#399
	vsl_color	#1

shell2	bsr	main	run main program

	v_show_c	#0	show mouse
shell3	v_clsvwk		close workstation
	appl_exit		close application

	clr	-(sp)	status code
	move	#$4c,-(sp)	P_TERM
	trap	#1	exit pgm


;--------------------- Main program sub-routine ------------------------

main	bsr	getscrn
	v_clrwk		clr screen
	bsr	initneo
	bsr	init
	bsr	set_scrn	set up screens
	graf_mouse	#0
	bsr	ms_show
	move.b	#'1',mode
	bsr	install_int

	bsr	test	test of polyline

	bsr	de_install
	setscreen	#-1,screen,screen

	rts

test	bsr	chk_move	  move blips
	
	lea	co_ords,a6
	move	#159,d2
	move	#31,d3
	bclr	#f_col,flags1
	move	#160,d0	centre
	move	#106,d1

	bsr	draw_line
	lea	blip_list,a5
	
test1	bsr	scr_copy
		
	cmp	#-1,(a6)	end ?
	beq	test
	
	bclr	#f_col,flags1
	move	#160,d0	centre
	move	#106,d1

	bsr	ms_hide
	cmp.b	#'1',mode	skip if not normal
	bne	test3
	
	bsr	draw_line   erase old
test3	bset	#f_col,flags1
	move	(a6)+,d2
	move	(a6)+,d3
	bsr	draw_line   draw next
	bsr	chk_blip	  redraw old blips

	bsr	ms_show
	
	bsr	keyscn
	cmp	#-1,d0
	beq	test1
	cmp	#27,d0
	beq	test2
	move.b	d0,mode	set mode (1,2,3)
	

	bra	test1
	
test2	rts

;Draw line, mode 1 (no clipping)
;ENTRY d0=x co-ord of 1st point x1
;      d1=y co-ord of 1st point y1
;      d2=x co-ord of 2nd point x2
;      d3=y co-ord of 2nd point y2
;      (colour)=colour index (0-15)
;      (screen)=screen address
;EXIT  Line drawn, no regs changed

line1	movem.l	d0-d7/a0-a1,-(sp)
	bclr	#31,d0	clr flag
	move.l	#1,a0	calc dx (end-start)
	move	d2,d4	and x step value
	sub	d0,d4
	bpl	line1_1
	neg	d4	make positive
	move.l	#-1,a0	neg x step

line1_1	move.l	#1,a1	calc dy (end-start)
	move	d3,d5	and y step value
	sub	d1,d5
	bpl	line1_2
	neg	d5	make positive
	move.l	#-1,a1	neg y step

line1_2	cmp	d5,d4	angle pos or neg
	bpl	line1_8	yes
	exg	d4,d5	no so swap dx & dy
	bset	#31,d0	set flag
line1_8	lsl	#1,d5	calc error1

	move	d5,d6	calc initial decision value
	sub	d4,d6
	
 	lsl	#1,d4	calc error2
	move	d5,d7
	sub	d4,d7
	exg	d4,d7

line1_3	bsr	set_pix	plot d0/d1
	cmp	d1,d3
	bne	line1_6
	cmp	d0,d2	check end of line
	beq	line1_4
line1_6	tst	d6	chk decision + or -
	bpl	line1_5
	add	d5,d6	update decision
	btst	#31,d0	pos/neg slope
	bne	line1_7
	add	a0,d0	step x
	bra	line1_3

line1_5	add	d4,d6	update decision
	add	a0,d0	step x
line1_7	add	a1,d1	step y
	bra	line1_3
	
line1_4	movem.l	(sp)+,d0-d7/a0-a1
	rts

;Draws line (mode 2)

draw_line	cmp.b	#'1',mode
	beq	draw_line0
	cmp.b	#'2',mode
	beq	line1

draw_line0	movem.l	d0-d7/a0-a1,-(sp)
	clr	d6
	move	#1,a0
	move	#1,a1
	move	d2,d4
	sub	d0,d4
	bpl	draw_line1
	neg	d4
	move	#-1,a0
draw_line1	move	d3,d5
	sub	d1,d5
	bpl	draw_line2
	neg	d5
	move	#-1,a1
draw_line2	tst	d5
	bne	draw_line3
	move	#-1,d6
draw_line3	bsr	set_pix
	cmp	d0,d2
	bne	draw_line4
	cmp	d1,d3
	beq	draw_line6
draw_line4	tst	d6
	bmi	draw_line5
	add	a1,d1
	sub	d4,d6
	bra	draw_line3
	
draw_line5	add	a0,d0
	add	d5,d6
	bra	draw_line3
	
draw_line6	movem.l	(sp)+,d0-d7/a0-a1
	rts

;Set/Res bit plane 1 pixel
;ENTRY d0=x
;      d1=y
;      f_col=0 clr, =1 set
;EXIT  bit plane 1 set

set_pix	movem.l	d0-d3/a0,-(sp)
	
	btst	#f_col,flags1
	bne	set_pix0
	
	lea	blip_list,a4
set_pix2	cmp	#-1,(a4)
	beq	set_pix0
	
	cmp	8(a4),d0
	bne	set_pix3
	cmp	10(a4),d1
	bne	set_pix3
	move	#3,6(a4)
	move	8(a4),(a4)
	move	10(a4),2(a4)
	move	#delay,4(a4)
	bset	#f_blip,flags1
	bra	set_pix0
	
set_pix3	add	#size,a4
	bra	set_pix2
	
set_pix0	move.l	screen,a0
	mulu	#160,d1	
	add	d1,a0
	move	d0,d1
	lsr	#4,d0
	lsl	#3,d0
	add	d0,a0
	not	d1
	and.l	#$f,d1

	move	2(a0),d0
	bclr	d1,d0
	move	(a0),d2
	bclr	d1,d2
	
	btst	#f_blip,flags1
	bne	set_pix4
	btst	#f_col,flags1
	beq	set_pix1
set_pix4	bset	d1,d0
	bset	d1,d2
set_pix1	move	d0,2(a0)	
	move	d2,(a0)	
	bclr	#f_blip,flags1
	movem.l	(sp)+,d0-d3/a0
	rts

;Checks for current blips and fades them
;ENTRY a5=address of current entry
;EXIT  

chk_blip	movem.l	d0-d3,-(sp)
	lea	blip_list,a5
chk_blip0	sub	#1,4(a5)
	bne	chk_blip1
	move	#delay,4(a5)
	tst	6(a5)
	beq	chk_blip1
	sub	#1,6(a5)
	move	6(a5),d2
	move	(a5),d0
	move	2(a5),d1
	bsr	draw_blip
chk_blip1	add	#size,a5
	cmp	#-1,(a5)
	bne	chk_blip0
	movem.l	(sp)+,d0-d3
	rts

;Draws 1 blip on screen
;ENTRY d0=x co-ord
;      d1=y co-ord
;      d2=bit pattern
;EXIT  pixel drawn

draw_blip	move.l	screen,a0
	mulu	#160,d1	
	add	d1,a0
	move	d0,d1
	lsr	#4,d0
	lsl	#3,d0
	add	d0,a0
	not	d1
	and.l	#$f,d1

	move	(a0),d0
	move	2(a0),d3
	bclr	d1,d0	black
	bclr	d1,d3
	tst	d2
	beq	drawblip1
	
	bset	d1,d0	col 1
	cmp	#1,d2
	beq	drawblip1
	
	bclr	d1,d0	col 2
	bset	d1,d3
	cmp	#2,d2
	beq	drawblip1
		
	bset	d1,d0	max col

drawblip1	move	d0,(a0)	
	move	d3,2(a0)	
	rts
	
;Move blips
;ENTRY 
;EXIT  

chk_move	movem.l	d0-d3,-(sp)

	lea	blip_list-size,a4
chk_move1	add	#size,a4
	cmp	#-1,(a4)
	beq	chk_move2
	move	12(a4),d0
	add	d0,8(a4)
	move	14(a4),d0
	add	d0,10(a4)

	bra	chk_move1

chk_move2	movem.l	(sp)+,d0-d3
	rts


;Initialise look-up table

init	lea	co_ord2-4,a0
	lea	co_ord2-4,a1
init1	cmp	#160,(a1)
	bne	init2
	cmp	#31,2(a1)
	beq	init3
init2	move	(a1),(a0)	calc x

	move	#210,d0	calc y
	sub	2(a1),d0
	move	d0,2(a0)
	sub	#4,a1
	add	#4,a0
	bra	init1

init3	lea	co_ords,a1
init4	cmp	#234,(a1)
	bne	init5
	cmp	#105,2(a1)
	beq	init6

init5	move	#320,d0	calc x
	sub	(a1),d0
	move	d0,(a0)

	move	#210,d0	calc y
	sub	2(a1),d0
	move	d0,2(a0)

	add	#4,a1
	add	#4,a0
	bra	init4

init6	lea	co_ord2-4,a1
init7	cmp	#160,(a1)
	bne	init8
	cmp	#31,2(a1)
	beq	init10
init8	move	#320,d0
	sub	(a1),d0
	move	d0,(a0)
	
	move	2(a1),2(a0)
	
	add	#4,a0
	sub	#4,a1
	bra	init7

init10	move	#-1,(a0)
	rts

;======== Library Routines =======

;Install interrupt program in vbl queue (at start of pgm)
;ENTRY -
;EXIT  20mS Interrupt vector installed
;      int_add holds vector address

install_int	movem.l	a0-a1/d0-d1,-(sp)

	clr.l	-(sp)	go to supervisor mode
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp	d0=supervisor stack

	move.l	$456,a0	fetch vdu blank vector
install_int1	add.l	#4,a0	next vector
	tst.l	(a0)
	bne	install_int1	find blank vector
	move.l	#intpgm,(a0)	copy routine addr to memory
	move.l	a0,int_add	save interrupt vector

	move.l	d0,-(sp) 	set user mode
	move	#$20,-(sp)
	trap	#1
	add.l	#6,sp

	movem.l	(sp)+,a0-a1/d0-d1
	rts

;Remove interrupt vector and restore vbl queue (at end of pgm)
;ENTRY int_add holds old address of interrupt vector
;EXIT  vbl queue restored

de_install	movem.l	a0-a1/d0-d1,-(sp)

	clr.l	-(sp)	go to supervisor mode
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	move.l	int_add,a0	restore address
	clr.l	(a0)	clr int vector	

	move.l	d0,-(sp)	set user mode
	move	#$20,-(sp)
	trap	#1
	add	#6,sp

	movem.l	(sp)+,a0-a1/d0-d1
	rts

;Interrupt routine (20mS interval)

intpgm	move	#$000,colour4
	bchg	#f_col4,flags1
	beq	int_pgm1
	move	#$0400,colour4
int_pgm1	rts


;Set up main and aux screen addresses
;ENTRY (screen)=current screen address
;      screen=address of screen buffer
;EXIT  screen_x=second screen buffer
;      current screen copied to aux screen

set_scrn	move.l	#screens+256,d0	calc screen addresses
	clr.b	d0		on 256 byte boundaries
	move.l	d0,screen1
	add.l	#32000,d0
	move.l	d0,screen2
	rts

;Copy screen data to screen1 or screen2
;ENTRY (screen..) holds image
;EXIT  (screen..) copied to screen1 or screen2

scr_copy	move	#148-1,d6		No of lines
	move	#31*160+40,d0
	move.l	screen,a0		copy main to aux
	add	d0,a0
	move.l	screen1,a1
	add	d0,a1
scr_copy3	move	#40-1,d0
scr_copy2	move	(a0)+,(a1)+
	dbra	d0,scr_copy2
	add	#160-80,a0
	add	#160-80,a1
	dbra	d6,scr_copy3
	rts


;get logical screen address
;ENTRY screen store defined (i.e. screen ds.l 1)
;EXIT  (screen) holds screen start addr
;      No regs changed

getscrn	movem.l	d0-d2/a0-a2,-(sp)
	move	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,screen
	movem.l	(sp)+,d0-d2/a0-a2
	rts

;scans keybrd for key press
;& returns immediately
;ENTRY --
;EXIT  d0=-1 if no key pressed
;      d0=key value if key pressed

keyscn	movem.l	d1-d2/a0-a2,-(sp)
	move	#2,-(sp)
	move	#1,-(sp)
	trap	#13
	add.l	#4,sp
	tst	d0
	beq	keyscn1
	move	#2,-(sp)
	move	#2,-(sp)
	trap	#13
	add.l	#4,sp
keyscn2	movem.l	(sp)+,d1-d2/a0-a2
	rts
	
keyscn1	move	#-1,d0
	bra	keyscn2

;Fetch mouse co-ordinates
;EXIT  d0=x co-ords
;      d1=y co-ords
;      d2=mouse buttons status

ms_posn	movem.l	a0-a3,-(sp)
	vq_mouse
	move	ptsout,d0
	move	ptsout+2,d1
	move	intout,d2
	movem.l	(sp)+,a0-a3
	rts


;show mouse cursor
                                                                      
ms_show	movem.l	a0-a4/d0-d4,-(sp)
	v_show_c	#1
	movem.l	(sp)+,a0-a4/d0-d4
	rts

;hide mouse cursor

ms_hide	movem.l	a0-a4/d0-d4,-(sp)
	v_hide_c
	movem.l	(sp)+,a0-a4/d0-d4
	rts

;set up colours
;ENTRY a0=colour data address
;EXIT  No regs changed
;      Colours changed
	
palette	movem.l	d0-d2/a0-a2,-(sp)
	move.l	a0,-(sp)
	move	#6,-(sp)
	trap	#14
	addq.l	#6,sp
	movem.l	(sp)+,d0-d2/a0-a2
	rts

;load neochrome picture to screen
;ENTRY f_out buffer defined with filename
;      disk in drive 

;EXIT  d0=error No (n=minus) or d0=0
;      mouse cursor disabled
;      palette set
;      No other regs changed
;      Neo picture in neo_buf and displayed
;requires f_drive, f_open, f_read
;         getscrn, palette S/Rs

initneo	movem.l	d1-d2/a0-a2,-(sp)
	bsr	getscrn
	bsr	ms_hide	hide mouse
	lea	neo_buf+4,a0
	bsr	palette
	lea	neo_buf+128,a0
	move.l	screen,a1
	move	#32000/4,d0
initneo1	move.l	(a0)+,(a1)+
	dbra	d0,initneo1
	bsr	ms_show
	clr.l	d0
	movem.l	(sp)+,d1-d2/a0-a2
	rts


	SECTION	data	global constants

neo_buf	incbin	'RADAR.NEO',0

co_ords	dc.w	160,31
	dc.w	161,31
	dc.w	162,31
	dc.w	163,31
	dc.w	164,31
	dc.w	165,31
	dc.w	166,31
	dc.w	167,31
	dc.w	168,31
	dc.w	169,32
	dc.w	170,32
	dc.w	171,32
	dc.w	172,32
	dc.w	173,32
	dc.w	174,32
	dc.w	175,33
	dc.w	176,33
	dc.w	177,33
	dc.w	178,33
	dc.w	179,33
	dc.w	180,34
	dc.w	181,34
	dc.w	182,34
	dc.w	183,35
	dc.w	184,35
	dc.w	185,35
	dc.w	186,36
	dc.w	187,36
	dc.w	188,36
	dc.w	189,37
	dc.w	190,37
	dc.w	191,38
	dc.w	192,38
	dc.w	193,39
	dc.w	194,39
	dc.w	195,40
	dc.w	196,40
	dc.w	197,41
	dc.w	198,41
	dc.w	199,42
	dc.w	200,43
	dc.w	201,43
	dc.w	202,44
	dc.w	203,45
	dc.w	204,45
	dc.w	205,46
	dc.w	206,47
	dc.w	207,48
	dc.w	208,48
	dc.w	209,49
	dc.w	210,50
	dc.w	211,51
	dc.w	212,52
	dc.w	213,53
	dc.w	214,54
	dc.w	215,55
	dc.w	216,56
	dc.w	217,57
	dc.w	217,58
	dc.w	218,59
	dc.w	219,60
	dc.w	220,61
	dc.w	220,62
	dc.w	221,63
	dc.w	222,64
	dc.w	222,65
	dc.w	223,66
	dc.w	224,67
	dc.w	224,68
	dc.w	225,69
	dc.w	225,70
	dc.w	226,71
	dc.w	226,72
	dc.w	227,73
	dc.w	227,74
	dc.w	228,75
	dc.w	228,76
	dc.w	229,77
	dc.w	229,78
	dc.w	229,79
	dc.w	230,80
	dc.w	230,81
	dc.w	230,82
	dc.w	231,83
	dc.w	231,84
	dc.w	231,85
	dc.w	232,86
	dc.w	232,87
	dc.w	232,88
	dc.w	232,89
	dc.w	232,90
	dc.w	233,91
	dc.w	233,92
	dc.w	233,93
	dc.w	233,94
	dc.w	233,95
	dc.w	233,96
	dc.w	234,97
	dc.w	234,98
	dc.w	234,99
	dc.w	234,100
	dc.w	234,101
	dc.w	234,102
	dc.w	234,103
	dc.w	234,104
	dc.w	234,105
co_ord2	ds.w	2000

;List of blip locations (x,y,delay,brightnes,x,y,x offset,y offset)

blip_list	dc.w	138,66,1,0,138,66,1,1
	dc.w	209,76,1,0,209,76,3,1
	dc.w	148,46,1,0,148,46,-1,-3
	dc.w	99,131,1,0,99,131,2,-2
	dc.w	118,166,1,0,118,166,-3,-3
	dc.w	105,113,1,0,105,113,4,2
	dc.w	188,145,1,0,188,145,-4,1
	dc.w	196,133,1,0,196,133,-2,3
	dc.w	190,109,1,0,190,109,-1,-1
	dc.w	200,94,1,0,200,94,-3,2
	dc.w	182,67,1,0,182,67,2,-2
	dc.w	198,151,1,0,198,151,1,3
	dc.w	149,101,1,0,149,101,3,-3
	dc.w	177,86,1,0,177,86,2,4

	dc.w	-1
	
		
	SECTION	bss	temporary data

screen	ds.l	1
colour	ds.w	1	pix colour
flags1	ds.b	1
mode	ds.b	1
int_add	ds.l	1	queue addr

screens	ds.b	64000+256
screen1	ds.l	1
screen2	ds.l	1

ap_id	ds.w 	1	application ident

	ds.l	100	stack space (400 bytes)
stack	ds.w	1	(stacks go backwards)

	include	h:\devpac\incdir\aeslib.s
	include	h:\devpac\incdir\vdilib.s

	
