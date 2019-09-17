
;Demonstration program of Neochrome-Master
;Sprite generator software by Peter D Hibbs
;Please send any comments to me at -
;63 Woolsbridge Road, Ringwood, Dorset BH24 2LX

	ttl	'GRIDLOCK word game'

	include	d:\devpac3\incdir\gemmacro.i	Change as reqd

replay	equ	26	replay button ident
quit	equ	27	quit button ident
tw	equ	19	tile width

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
	v_clrwk		clr screen
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

main	move	#4,-(sp)	chk resolution
	trap	#14
	add	#2,sp
	tst	d0
	bne	main7	bra if not LOW
	
	bsr	savepal	save palette
	
	lea	colours,a0	set new palette
	bsr	palette
	
	bsr	ms_show
	bsr	sprite_init  load sprite file
	bmi	main8	bra if error

	
	graf_mouse	#0	make arrow
	bsr	ms_hide		hide mouse
	
	move	#87,d0	display title
	move	#3,d1
	move	#29,d2
	bsr	s_sprite
	
	move	#10,d0	display 1st row tiles 
	move	#34,d1
	move	#1,d2
	move	#13-1,d3
main2	bsr	s_sprite
	add	#1,d2
	add	#25,d0
	dbra	d3,main2

	move	#10,d0	display 2nd row tiles 
	move	#59,d1
	move	#13-1,d3
main3	bsr	s_sprite
	add	#1,d2
	add	#25,d0
	dbra	d3,main3

	move	#20,d0	display REPLAY button
	move	#160,d1
	move	#30,d2
	bsr	s_sprite
	
	move	#252,d0	display QUIT button
	move	#160,d1
	move	#31,d2
	bsr	s_sprite

main5	move	#97,d0	display board
	move	#84,d1
	move	#28,d2
	bsr	s_sprite
		
	bsr	clr_board	erase board buffer
	
	bsr	ms_show
main1	bsr	ms_posn	fetch mouse posn
	tst	d2	and button state
	beq	main1	
	lea	butn_table,a3	access list
	bsr	box_find	check mouse posn
	cmp	#-1,d4		no buttons clicked
	beq	main1
	cmp	#replay,d4	REPLAY button ?
	beq	main5
	cmp	#quit,d4	QUIT button ?
	beq	exit
	cmp	#25,d4	Tiles A-Z ?
	bgt	main1	No !	
		
	bsr	ms_hide
	add	#1,d4	convert box to sprite
	move	d4,d2	and copy to d2
	bsr	m_sprite	display tile to move
	bsr	ms_rlse	wait for button rlse

main4	bsr	ms_posn	fetch mouse data
	bsr	vsync	wait for V Sync
	move	d2,d7	d2=button state
	move	d4,d2	d4=selctd tile sprite
	bsr	m_sprite	display tile
	tst	d7	any button pressed
	beq	main4	no so loop
	cmp	#2,d7	right button
	beq	main6

	bsr	calc_brd	calc board square
	cmp	#-1,d3	and return in d3
	beq	main4	invalid

	lea	board,a0	access square
	add	d3,a0
	tst.b	(a0)	chk if square free
	bne	main4	bra if not

	and.l	#$ffff,d3	clear high word d3
	divu	#6,d3	calc square co-ords
	move.l	d3,d0	calc x co-ord
	swap	d0
	mulu	#20,d0
	add	#101+9,d0
	
	move	d3,d1	calc y co-ord
	mulu	#18,d1
	add	#88+8,d1

	bsr	m_sprite	copy tile to board
	add	#'A'-1,d4	convert to ASCII
	move.b	d4,(a0)	and store in board buffer

	clr.l	spr_buffer	clr buffer to stop redraw
	bsr	ms_rlse	wait for button rlse
	bsr	ms_show	re-show mouse
	bra	main1	and loop
	
main6	move	#-1,d0	erase sprite
	bsr	m_sprite
	bsr	ms_show
	bsr	ms_rlse	wait for button rlse
	bra	main1	main loop

main7	bsr	ms_show	display wrong rez message
	form_alert	#1,#alert_str
	rts
	
exit	bsr	restpal	restore palette
	rts		exit program

main8	bsr	ms_show
	neg.l	d0
	form_error	d0	display error No
	bra	exit
	
alert_str	dc.b	'[3][| | This program only   |'
	dc.b	'  runs in low rez][ SORRY ]',0
	even

;------- Program Sub-Routines -----------

;Calculate board square from mouse co-ords
;ENTRY d0=x co-ord
;      d1=y co-ord
;EXIT  d3=grid no (0-35) or -1 if not on board

calc_brd	movem.l	d0-d2/a0,-(sp)
	lea	board,a0	set a0 to start of grid buffer
	move	#-1,d3
	sub	#100,d0	chk left edge
	bmi	calc_brd1
	cmp	#20*6,d0	chk right edge
	bgt	calc_brd1
	sub	#87,d1	chk top edge
	bmi	calc_brd1
	cmp	#20*6,d1	chk bottom edge
	bgt	calc_brd1
	and.l	#$ffff,d0
	and.l	#$ffff,d1
	divu	#19+1,d0	d0=horiz square
	divu	#17+1,d1	d1=vert square
	mulu	#6,d1
	move	d1,d3
	add	d0,d3	d3=board square No
calc_brd1	movem.l	(sp)+,d0-d2/a0
	rts

;Clear board buffer
;ENTRY -
;EXIT  board buffer cleared to 0

clr_board	movem.l	d0/a0,-(sp)
	lea	board,a0
	move	#36-1,d0
clr_board1	clr.b	(a0)+
	dbra	d0,clr_board1
	movem.l	(sp)+,d0/a0
	rts
	
;------- Library Sub-Routines -----------

;Initialise sprite data files and table
;For use with .OBJ files from Neochrome Master
;ENTRY 'sprite_file' string holds path and filename of sprite data file
;       Current disk drive and pathname set up
;EXIT  various registers corrupted
;      (screen) holds screen start address
;      (sprite_tab..) buffer holds table of sprite data
;      (sprite_data..) buffer holds sprite data
;      (sprite_mask..) buffer holds sprite mask data
;      d0 = 0 = file loaded OK or
;      d0 = negative value = file error (d0=error code)

sprite_init	move	#3,-(sp)	   fetch screen address
	trap	#14
	addq.l	#2,sp
	move.l	d0,screen	   save screen start address

	move	#2,-(sp)	   open sprite data file
	pea	sprite_file   define path & filename
	move	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	move	d0,file_handle
	tst.l	d0
	bmi	sprite_init3          quit if error

	lea	sprite_mask,a5	a5 points at mask data
	lea	sprite_tab,a1	a1 points at sprite table

	pea	sprite_data	read sprite data
	move.l	#$7fffffff,-(sp)      into sprite data buffer
	move	file_handle,-(sp)
	move	#$3f,-(sp)
	trap	#1
	add.l	#12,sp
	tst.l	d0
	bmi	sprite_init3	quit if error

	move	file_handle,-(sp)     close file
	move	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.l	d0
	bmi	sprite_init3	quit if error

	lea	sprite_data+8,a0	calc No of sprites
	add	(a0),a0
	add	#2+4,a0	set a0 to 1st spr header
	move	(a0)+,d5	fetch No of sprites &
	sub	#1,d5	correct for dbra instr
	move.l	a0,d4	save a0 in d4

sprite_init1	move	10(a0),(a1)+	copy width to sprite table
	move	6(a0),d0	copy height-1 to sprite table
	sub	#1,d0	
	move	d0,(a1)+	
	move.b	16(a0),d0
	and	#$ff,d0
	move	d0,(a1)+	copy x offset to table ?
	move.b	17(a0),d0
	move	d0,(a1)+	copy y offset to table ?
	move.l	(a0),d0	copy sprite data address 
	add.l	d4,d0	to sprite table
	move.l	d0,(a1)+
	move.l	d0,a2	and into a2
	move	10(a0),d0	calc size of sprite data
	mulu	6(a0),d0
	move.l	a5,(a1)+	copy sprite mask address to table
	lsr	#3,d0	calc width of mask-1
	sub	#1,d0
sprite_init2	clr	(a5)	generate mask data
	move	(a2)+,d2
	or	d2,(a5)	and copy to buffer
	move	(a2)+,d2
	or	d2,(a5)
	move	(a2)+,d2
	or	d2,(a5)
	move	(a2)+,d2
	or	d2,(a5)+
	dbra	d0,sprite_init2	repeat
	add.l	#20,a0	access next sprite
	dbra	d5,sprite_init1	repeat for all sprites
	clr.l	d0	file loaded OK (d0=0)
sprite_init3	rts

;Draw stationary sprite image 
;ENTRY d0=x co-ord of hot spot (0-319)
;      d1=y co-ord of hot spot (0-199)
;      d2=sprite number (1-n)
;      sprite_tab table initialised by sprite_init
;      (screen) holds screen or buffer addr
;EXIT  No regs changed

s_sprite	movem.l	d0-d5/a0-a3,-(sp)
	lea	sprite_tab,a0	set table pointer
	and.l	#$ffff,d2
	sub	#1,d2
	lsl	#4,d2
	add.l	d2,a0

	move	(a0)+,d2	d2=width in bytes
	move	(a0)+,d5	d5=No of scanlines-1
	sub	(a0)+,d0	x hot spot
	sub	(a0)+,d1	y hot spot
	move.l	(a0)+,a1	a1=sprite data
	move.l	(a0)+,a3	a3=mask data

	move.l	screen,a0	a0=screen start
	move.l	a0,a2
	add	#32000,a2	a2=screen end
	mulu	#160,d1
	add.l	d1,a0	a0=sprite line address
	move	d0,d4
	lsr	#4,d0
	lsl	#3,d0
	add	d0,a0	a0=sprite byte address
	lsr	#3,d2
	subq	#2,d2	d2=corrected width
	and	#$0f,d4	d4=bit shift value
s_sprite6	cmp.l	a2,a0	chk if sprite off bottom of scrn
	bgt	s_sprite2
	cmp.l	screen,a0	chk if sprite off top of scrn
	blt	s_sprite2

	movem.l	d2/a0,-(sp) display left chunk
	moveq	#0,d3
	move	(a3),d3
	lsr.l	d4,d3
	not.l	d3
	move	#4-1,d1
s_sprite8	moveq	#0,d0
	move	(a1)+,d0
	lsr.l	d4,d0
	and	d3,(a0)
	or	d0,(a0)+
	dbra	d1,s_sprite8
	subq.l	#8,a1
	cmp	#-1,d2
	beq	s_sprite1

s_sprite7	move.l	(a3),d3	display centre chunks
	lsr.l	d4,d3
	not.l	d3
	addq.l	#2,a3
	move	#4-1,d1
s_sprite9	move.l	(a1),d0
	move	8(a1),d0
	addq.l	#2,a1
	lsr.l	d4,d0
	and	d3,(a0)
	or	d0,(a0)+
	dbra	d1,s_sprite9
	dbra	d2,s_sprite7

s_sprite1	move.l	(a3),d3	display right chunk
	clr	d3
	addq.l	#2,a3
	lsr.l	d4,d3
	not.l	d3
	move	#4-1,d1
s_sprite0	move.l	(a1),d0
	clr	d0
	addq.l	#2,a1
	lsr.l	d4,d0
	and	d3,(a0)
	or	d0,(a0)+
	dbra	d1,s_sprite0	
	movem.l	(sp)+,d2/a0
	add.l	#160,a0
	dbra	d5,s_sprite6  repeat lines
s_sprite2	movem.l	(sp)+,d0-d5/a0-a3
	rts

;Draw sprite and save backgrnd
;ENTRY d0=x co-ord (0-319)
;      d1=y co-ord (0-199)
;      d2=sprite No (1-nn)
;      (screen) holds screen addr
;      (spr_buffer) clear or holds data
;      (sprite_tab..) holds table
;EXIT  Old sprite restored and 
;      new sprite displayed

m_sprite	movem.l	d0-d5/a0-a4,-(sp)
	lea	sprite_tab,a0	set table pointer
	and.l	#$ffff,d2
	sub	#1,d2
	lsl	#4,d2
	add.l	d2,a0

	move.l	screen,a4	a4=screen limit
	add	#32000,a4	

	move	(a0)+,d2	d2=width in bytes
	move	(a0)+,d5	d5=No of scanlines-1
	sub	(a0)+,d0	x hot spot ??
	sub	(a0)+,d1	y hot spot ??
	move.l	(a0)+,a1	a1=sprite data
	move.l	(a0)+,a3	a3=mask data
	
	lea	spr_buffer,a2
	tst.l	(a2)
	beq	m_sprite1	skip if no image stored
	
	move.l	(a2)+,a0	fetch scrn address
	move	(a2)+,d6	fetch width (bytes)
	move	(a2)+,d3	fetch height
		
m_sprite2	movem.l	d6/a0,-(sp)   copy buffer to scrn
m_sprite3	move	(a2)+,(a0)+
	dbra	d6,m_sprite3
	movem.l	(sp)+,d6/a0
	add.l	#160,a0
	cmp.l	a4,a0
	bgt	m_sprite13
	dbra	d3,m_sprite2
m_sprite13	lea	spr_buffer,a2
	clr.l	(a2)	erase buffer

m_sprite1	cmp	#319,d0	exit if invalid co-ords
	bhi	m_sprite10
	cmp	#199,d1
	bhi	m_sprite10
	
	move.l	screen,a0	calc sprite addr
	mulu	#160,d1
	add.l	d1,a0
	
	move	d0,d4
	lsr	#4,d0
	lsl	#3,d0
	add	d0,a0
	
	move	d2,d3
	lsr	#1,d3
	addq	#4,d3
	
	move.l	a0,(a2)+	copy addr to buffer
	move	d3,(a2)+	copy width to buffer
	move	d5,(a2)+	copy height to buff
	
	movem.l	d5/a0,-(sp)  copy screen data to buffer
m_sprite4	movem.l	d3/a0,-(sp)
m_sprite5	move	(a0)+,(a2)+
	dbra	d3,m_sprite5
	movem.l	(sp)+,d3/a0
	add.l	#160,a0
	cmp.l	a4,a0
	bgt	m_sprite12
	dbra	d5,m_sprite4
m_sprite12	movem.l	(sp)+,d5/a0
	
	lsr	#3,d2	
	subq	#2,d2
	and	#$0f,d4
m_sprite6	cmp.l	a4,a0	chk end of screen	
	bgt	m_sprite10
	cmp.l	screen,a0	chk start of screen
	blt	m_sprite10
	
	movem.l	d2/a0,-(sp)  display sprite
	moveq	#0,d3
	move	(a3),d3
	lsr.l	d4,d3
	not.l	d3
	move	#4-1,d1
m_sprite8	moveq	#0,d0
	move	(a1)+,d0
	lsr.l	d4,d0
	and	d3,(a0)
	or	d0,(a0)+
	dbra	d1,m_sprite8
	subq.l	#8,a1
	cmp	#-1,d2
	beq	m_sprite11
m_sprite7	move.l	(a3),d3
	lsr.l	d4,d3
	not.l	d3
	addq.l	#2,a3
	move	#4-1,d1
m_sprite9	move.l	(a1),d0
	move	8(a1),d0
	addq.l	#2,a1
	lsr.l	d4,d0
	and	d3,(a0)
	or	d0,(a0)+
	dbra	d1,m_sprite9
	dbra	d2,m_sprite7
m_sprite11	move.l	(a3),d3
	clr	d3
	addq.l	#2,a3
	lsr.l	d4,d3
	not.l	d3
	move	#4-1,d1
m_sprite0	move.l	(a1),d0
	clr	d0
	addq.l	#2,a1
	lsr.l	d4,d0
	and	d3,(a0)
	or	d0,(a0)+
	dbra	d1,m_sprite0	
	movem.l	(sp)+,d2/a0
	add.l	#160,a0
	dbra	d5,m_sprite6
m_sprite10	movem.l	(sp)+,d0-d5/a0-a4
	rts

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

;waits till mouse button released

ms_rlse	movem.l	d0-d3,-(sp)
msrlse1	bsr	ms_posn
	tst	d2
	bne	msrlse1
	movem.l	(sp)+,d0-d3
	rts

;waits till mouse button operated

ms_optd	move	d2,-(sp)
msoptd1	bsr	ms_posn
	tst	d2
	beq	msoptd1
	move	(sp)+,d2
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

;save colour palette to RAM
;ENTRY --
;EXIT  current palette in 'colbuff'
;      no regs changed

savepal	movem.l	d0-d2/a0-a2,-(sp)
	clr	d1
	move	#16-1,d2
	lea	colbuff,a0
savepl1	movem.l	d1/d2/a0,-(sp)
	move	#-1,-(sp)
	move	d1,-(sp)
	move	#7,-(sp)
	trap	#14
	add.l	#6,sp
	movem.l	(sp)+,d1/d2/a0
	move	d0,(a0)+
	add	#1,d1
	dbra	d2,savepl1
	movem.l	(sp)+,d0-d2/a0-a2
	rts
	
;restore colour palette
;ENTRY  colours saved in colbuff
;EXIT   palette restored

restpal	move.l	a0,-(sp)
	lea	colbuff,a0
	bsr	palette		
	move.l	(sp)+,a0
	rts
		
;Finds a predefined box with mouse cursor
;ENTRY  a3=address of box list
;       d0=x co-ord of mouse
;       d1=y co-ord of mouse
;EXIT   d4=-1 (not valid) or box number (0-n)

box_find	move.l	a3,-(sp)	save a3
	move	#-1,d4	set counter
	sub.l	#8,a3	dec list pointer
box_find1	add.l	#8,a3	inc list pointer
	addq	#1,d4	inc counter
	cmp	#-1,(a3)	end of list ?
	beq	box_find2	bra if so
	cmp	(a3),d0	
	ble	box_find1	loop if to left
	cmp	4(a3),d0
	bge	box_find1	loop if to right
	cmp	2(a3),d1
	ble	box_find1	loop if above
	cmp	6(a3),d1
	bge	box_find1	loop if below
box_find3	move.l	(sp)+,a3	must be in box, d4=box No
	rts
	
box_find2	move	#-1,d4	d4=-1 if no box found
	bra	box_find3

;Waits for vertical sync pulse

vsync	movem.l	d0-d2/a0-a2,-(sp)
	move	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d2/a0-a2
	rts

	
	SECTION	data	global constants

sprite_file	dc.b	'D:\NEOCHROM.E\PICTURES\GRIDLOCK.OBJ',0	change as reqd
	even

colours	dc.w	$0000,$0000,$0730,$0656,$0576,$0554,$0070,$0555
	dc.w	$0764,$0057,$0111,$0633,$0775,$0444,$0423,$0700

butn_table	dc.w	0,25,0+tw,41	tile A
	dc.w	25,25,25+tw,41	tile B
	dc.w	50,25,50+tw,41	tile C
	dc.w	75,25,75+tw,41	tile D
	dc.w	100,25,100+tw,41	tile E
	dc.w	125,25,125+tw,41	tile F
	dc.w	150,25,150+tw,41	tile G
	dc.w	175,25,175+tw,41	tile H
	dc.w	200,25,200+tw,41	tile I
	dc.w	225,25,225+tw,41	tile J
	dc.w	250,25,250+tw,41	tile K
	dc.w	275,25,275+tw,41	tile L
	dc.w	300,25,300+tw,41	tile M
	
	dc.w	0,50,0+tw,66	tile N
	dc.w	25,50,25+tw,66	tile O
	dc.w	50,50,50+tw,66	tile P
	dc.w	75,50,75+tw,66	tile Q
	dc.w	100,50,100+tw,66	tile R
	dc.w	125,50,125+tw,66	tile S
	dc.w	150,50,150+tw,66	tile T
	dc.w	175,50,175+tw,66	tile U
	dc.w	200,50,200+tw,66	tile V
	dc.w	225,50,225+tw,66	tile W
	dc.w	250,50,250+tw,66	tile X
	dc.w	275,50,275+tw,66	tile Y
	dc.w	300,50,300+tw,66	tile Z
		
	dc.w	20,160,20+48,160+13	REPLAY
	dc.w	252,160,252+48,160+13	QUIT
	
	dc.w	-1

	SECTION	bss	temporary data

ap_id		ds.w 	1	application ident
screen		ds.l	1	screen address
colbuff		ds.w	16	palette data
board		ds.b	6*6	board buffer

file_handle	ds.w	1	file handle
sprite_data	ds.b	16698	sprite data size
sprite_mask	ds.b	16698/4	sprite data divided by 4
sprite_tab		ds.b	32*16	No of sprites=32
spr_buffer		ds.b	2000	generous buffer for moveable spr

		ds.l	100	stack space (400 bytes)
stack		ds.w	1	(stacks go backwards)

	include	d:\devpac3\incdir\aeslib.s	Change as reqd
	include	d:\devpac3\incdir\vdilib.s	Change as reqd
