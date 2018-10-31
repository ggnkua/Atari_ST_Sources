	include	macro.s
	
scr_width	equ	640
scr_height	equ	480
*scr_width	equ	320
*scr_height	equ	240
FIRE		equ	0
UP		equ	1
DOWN		equ	2
LEFT		equ	3
RIGHT		equ	4


	move.l	a7,a5
	move.l	#ustck,a7
	move.l	4(a5),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp
	

	dc.w	$a00a
	
	print_l	#text

	keyget
	dc.w	$a009

	super_on	old_stack
	
	malloc	#(32+scr_height+32+scr_height+32)*scr_width
	tst.l	d0
	bmi	no_memory
	move.l	d0,block
	add.l	#16,d0
	and.l	#$fffffff0,d0

	move.l	d0,v_scr1	* poczatek 1 ekranu (z ramka)
	add.l	#scr_width*32,d0
	move.l	d0,scr1		* widoczna czesc 1 ekranu
	add.l	#scr_width*scr_height,d0
	move.l	d0,v_scr2	* poczatek 2 ekranu (z ramka)
	add.l	#scr_width*32,d0
	move.l	d0,scr2		* widoczna czesc 2 ekranu


	move.b	#%00100101,$ffff8007.w
	jsr	new_interrupts
	jsr	clr_screens
	jsr	save_video
	jsr	set_new_resolution
	move.l	scr2,scr
	jsr	set_new_screen
	jsr	set_new_colors
	clr.l	$ffff9800.w
	bsr	prepare_ship
	bsr	prepare_level
	moveq	#1,d0
	movec	d0,cacr
	jsr	flush
	jsr	clearmidibuffer
	move.b	#$12,$fffffc02.w

	move.w	#$0203,$ffff8a3a.w

	jsr	make_bonus_block
	jsr	make_points_block
	move.w	#$100,bonus

	move.l	#-1,$ffff9800.w
	neg.l	$ffff9800.w
main_loop
	lea	tab1,a4
	move.l	v_scr1,v_scr
*	neg.l	$ffff9800.w
	bsr	put_sprite
*	neg.l	$ffff9800.w
	lea	ship_tab1,a4
*	neg.l	$ffff9800.w
	bsr	ship_bum
*	neg.l	$ffff9800.w
	bsr	clearmidibuffer
	move.b	#$14,$fffffc02.w
	bsr	joystick
	move.b	keytab+$39,d0
	bne	koniec

	bsr	draw_bar

	move.l	scr1,d0
	bsr	synchro
	lea	tab2,a0
	lea	ship_tab2,a2
	bsr	clr_screen

	lea	tab2,a4
	move.l	v_scr2,v_scr
*	neg.l	$ffff9800.w
	bsr	put_sprite
*	neg.l	$ffff9800.w
	lea	ship_tab2,a4
*	neg.l	$ffff9800.w
	bsr	ship_bum
*	neg.l	$ffff9800.w
	bsr	clearmidibuffer
	move.b	#$14,$fffffc02.w
	bsr.s	joystick
	move.b	keytab+$39,d0
	bne	koniec

	bsr	draw_bar

	move.l	scr2,d0
	bsr	synchro
	lea	tab1,a0
	lea	ship_tab1,a2
	bsr	clr_screen
	
	bra	main_loop
*******************************
* Joystick routine
joystick
	tst.w	ship_state
	bpl.s	joy_1
	lea	ship_table+$d,a6
	move.b	joy2+FIRE,d0
	bne.s	fire_pressed
	clr.b	fire_status
joy_01	move.b	joy2+UP,d0
	bne	gear
joy_0	move.b	joy2+RIGHT,d0
	bne.s	turn_right
	move.b	joy2+LEFT,d0
	bne.s	turn_left
* Joy1 and Joy2 has to be cleared every time you have read them,
* meaning _once in a vbl_ if the game runs 50hz!
	clr.b	(a6)
joy_1	*lea	joy1,a0
	*clr.l	(a0)+
	*clr.b	(a0)
	lea	joy2,a0
	clr.l	(a0)+
	clr.b	(a0)
	rts
********
turn_right
	move.b	#1,(a6)
	bra.s	joy_1
********
turn_left
	move.b	#-1,(a6)
	bra.s	joy_1
********
fire_pressed
	tst.b	fire_status
	bne.s	joy_01
	addq.b	#1,fire_status
	move.w	#19,d7
	move.l	a6,a0
	add.w	d7,a0
fire0	tst.b	(a0)
	bne	fire_next
	lea	ship_table,a1
	lea	gear_table,a2
	lea	missile_tab,a3
	move.b	#$20,(a0)
	clr.l	d0
	move.b	$f(a1),d0
	lsl.w	d0
	move.w	1(a1),d3		* nastawienie x na statkowy
	add.w	d0,a2
	move.w	4(a1),d4		* nastawienie y na statkowy
	add.w	d0,a3
	move.w	(a3),d0
	move.b	d0,d1
	asr.w	#8,d0
	ext.w	d1
	add.w	d1,d4
	move.w	d4,4(a0)
	add.w	d0,d3
	move.w	d3,1(a0)
	move.b	(a2)+,3(a0)		* nastawnie dx dla kierunku statku
	move.b	(a2),6(a0)		* nastawnie dy dla kierunku statku
	bra	joy_01
fire_next
	add.w	#16,a0
	dbf	d7,fire0
	bra	joy_01
********
gear
*	lea	spr_table+$d,a6
	lea	gear_table,a5
	clr.w	d5
	move.b	2(a6),d5
	lsl.l	#1,d5
	move.w	0(a5,d5.w),d1	* dx,dy
	move.b	d1,d2
	lsr.w	#8,d1
	move.w	-$6(a6),d7
	move.b	d7,d6
	lsr.w	#8,d7
* d1=dx(k) d2=dy(k) d6=real dy d7=real dx
	tst.b	d1
	bmi.s	ujemny_x
dodatni_x
	tst.b	d7
	bmi.s	wariant3x

wariant4x			* x+ xr+
	lsl.b	#4,d1
	cmp.b	d7,d1
	beq.s	testuj_y
	bcs.s	wariant4_bx
wariant4_ax			* x>xr
	addq.w	#4,d7
	move.b	d7,-$6(a6)
	asr.b	#4,d7
	move.b	d7,-$a(a6)
	bra.s	testuj_y
wariant4_bx			* x<xr
	subq.w	#4,d7
	move.b	d7,-$6(a6)
	asr.b	#4,d7
	move.b	d7,-$a(a6)
	bra.s	testuj_y
ujemny_x
	tst.b	d7
	bmi.s	wariant1x
warian2x			* x- xr+
	subq.w	#4,d7
	move.b	d7,-$6(a6)
	asr.b	#4,d7
	move.b	d7,-$a(a6)
	bra.s	testuj_y
* warian1 x- xr-
wariant1x
	lsl.b	#4,d1
	cmp.b	d7,d1
	beq.s	testuj_y
	bcc.s	warian1_bx
wariant1_ax			* x->xr-? (x<xr)
	subq.w	#4,d7
	move.b	d7,-$6(a6)
	asr.b	#4,d7
	move.b	d7,-$a(a6)
	bra.s	testuj_y
warian1_bx
	addq.w	#4,d7
	move.b	d7,-$6(a6)
	asr.b	#4,d7
	move.b	d7,-$a(a6)
	bra.s	testuj_y
wariant3x			* x+ xr-
	addq.w	#4,d7
	move.b	d7,-$6(a6)
	asr.b	#4,d7
	move.b	d7,-$a(a6)

testuj_y
	tst.b	d2
	bmi.s	ujemny_y
dodatni_y
	tst.b	d6
	bmi.s	wariant3y

wariant4y			* y+ yr+
	lsl.b	#4,d2
	cmp.b	d6,d2
	beq.s	gear_end
	bcs.s	wariant4_by
wariant4_ay			* y>yr
	addq.w	#4,d6
	move.b	d6,-$5(a6)
	asr.b	#4,d6
	move.b	d6,-$7(a6)
	bra.s	gear_end
wariant4_by			* y<yr
	subq.w	#4,d6
	move.b	d6,-$5(a6)
	asr.b	#4,d6
	move.b	d6,-$7(a6)
	bra.s	gear_end
ujemny_y
	tst.b	d6
	bmi.s	wariant1y
warian2y			* y- yr+
	subq.w	#4,d6
	move.b	d6,-$5(a6)
	asr.b	#4,d6
	move.b	d6,-$7(a6)
	bra.s	gear_end
* warian1 y- yr-
wariant1y
	lsl.b	#4,d2
	cmp.b	d6,d2
	beq.s	gear_end
	bcc.s	warian1_by
wariant1_ay			* y->yr-? (y<yr)
	subq.w	#4,d6
	move.b	d6,-$5(a6)
	asr.b	#4,d6
	move.b	d6,-$7(a6)
	bra.s	gear_end
warian1_by
	addq.w	#4,d6
	move.b	d6,-$5(a6)
	asr.b	#4,d6
	move.b	d6,-$7(a6)
	bra.s	gear_end
wariant3y			* y+ yr-
	addq.w	#4,d6
	move.b	d6,-$5(a6)
	asr.b	#4,d6
	move.b	d6,-$7(a6)
gear_end
	clr.b	joy2+UP
	bra	joy_0

* dla uzyskania ognia, nalezy wyliczyc numer fazy i wstawic ja do
* tablicy ship_table + $16

********************************************************
missile_tab
	dc.b	14,-3		* faza 0 (pion do gory)
	dc.b	17,-3		* faza 1
	dc.b	19,-2		* faza 2
	dc.b	22,-1		* faza 3
	dc.b	23,0		* faza 4
	dc.b	25,1		* faza 5
	dc.b	26,2		* faza 6 45o parwo-gora
	dc.b	27,3		* faza 7
	dc.b	28,4		* faza 8
	dc.b	29,6		* faza 9
	dc.b	30,7		* faza a
	dc.b	32,9		* faza b
	dc.b	32,11		* faza c (poziom w prawo)
	dc.b	32,13		* faza d
	dc.b	32,15		* faza e
	dc.b	32,18		* faza f
	dc.b	32,20		* faza 10
	dc.b	31,22		* faza 11
	dc.b	30,23		* faza 12 45o prawo-dol
	dc.b	28,25		* faza 13
	dc.b	27,27		* faza 14
	dc.b	24,29		* faza 15
	dc.b	21,31		* faza 16
	dc.b	18,32		* faza 17
	dc.b	15,32		* faza 18 (pion do dolu)
	dc.b	11,32		* faza 19
	dc.b	9,31		* faza 1a
	dc.b	7,31		* faza 1b
	dc.b	4,29		* faza 1c
	dc.b	2,27		* faza 1d
	dc.b	0,25		* faza 1e 45o lewo-dol
	dc.b	-2,23		* faza 1f
	dc.b	-3,21		* faza 20
	dc.b	-3,18		* faza 21
	dc.b	-3,16		* faza 22
	dc.b	-3,14		* faza 23
	dc.b	-4,11		* faza 24 (poziom w lewo)
	dc.b	-3,9		* faza 25
	dc.b	-2,7		* faza 26
	dc.b	-1,6		* faza 27
	dc.b	0,5		* faza 28
	dc.b	1,3		* faza 29
	dc.b	2,2		* faza 2a 45o lewo-gora
	dc.b	4,0		* faza 2b
	dc.b	6,0		* faza 2c
	dc.b	8,-1		* faza 2d
	dc.b	10,-2		* faza 2e
	dc.b	12,-3		* faza 2f
fire_tab
* odstepy ognia od statku w pixelach
	dc.w	$09,$1b	* faza 0 (pion do gory)
	dc.w	$06,$19	* faza 1
	dc.w	$03,$18	* faza 2
	dc.w	$0,$15	* faza 3
	dc.w	$0,$16	* faza 4
	dc.w	$ffff,$14	* faza 5
	dc.w	$fffc,$13	* faza 6 45o parwo-gora
	dc.w	$fffb,$0f	* faza 7
	dc.w	$fff8,$0d	* faza 8
	dc.w	$fff7,$0d	* faza 9
	dc.w	$fff6,$0a	* faza a
	dc.w	$fffd,$08	* faza b
	dc.w	$fffa,$05	* faza c (poziom w prawo)
	dc.w	-23,28	* faza d
	dc.w	-23,28	* faza e
	dc.w	-23,28	* faza f
	dc.w	-23,28	* faza 10
	dc.w	-23,38	* faza 11
	dc.w	23,38	* faza 12 45o prawo-dol
	dc.w	23,38	* faza 13
	dc.w	22,38	* faza 14
	dc.w	22,38	* faza 15
	dc.w	21,38	* faza 16
	dc.w	21,38	* faza 17
	dc.w	20,32	* faza 18 (pion do dolu)
	dc.w	-1,38	* faza 19
	dc.w	-1,38	* faza 1a
	dc.w	-2,38	* faza 1b
	dc.w	-2,38	* faza 1c
	dc.w	-3,38	* faza 1d
	dc.w	-3,38	* faza 1e 45o lewo-dol
	dc.w	-3,38	* faza 1f
	dc.w	-3,28	* faza 20
	dc.w	-3,28	* faza 21
	dc.w	-3,18	* faza 22
	dc.w	-3,18	* faza 23
	dc.w	32,28	* faza 24 (poziom w lewo)
	dc.w	-3,28	* faza 25
	dc.w	-3,28	* faza 26
	dc.w	-3,28	* faza 27
	dc.w	-3,28	* faza 28
	dc.w	-3,28	* faza 29
	dc.w	-3,28	* faza 2a 45o lewo-gora
	dc.w	-3,28	* faza 2b
	dc.w	-2,28	* faza 2c
	dc.w	-2,28	* faza 2d
	dc.w	-1,28	* faza 2e
	dc.w	-1,28	* faza 2f
gear_table
* kierunki statku (dx,dy)
	dc.b	0,-6	* faza 0 (pion do gory)
	dc.b	1,-6	* faza 1
	dc.b	2,-6	* faza 2
	dc.b	2,-5	* faza 3
	dc.b	3,-5	* faza 4
	dc.b	4,-5	* faza 5
	dc.b	4,-4	* faza 6 45o parwo-gora
	dc.b	5,-4	* faza 7
	dc.b	5,-3	* faza 8
	dc.b	5,-2	* faza 9
	dc.b	6,-2	* faza a
	dc.b	6,-1	* faza b
	dc.b	6,0	* faza c (poziom w prawo)
	dc.b	6,1	* faza d
	dc.b	6,2	* faza e
	dc.b	5,2	* faza f
	dc.b	5,3	* faza 10
	dc.b	5,4	* faza 11
	dc.b	4,4	* faza 12 45o prawo-dol
	dc.b	4,5	* faza 13
	dc.b	3,5	* faza 14
	dc.b	2,5	* faza 15
	dc.b	2,6	* faza 16
	dc.b	1,6	* faza 17
	dc.b	0,6	* faza 18 (pion do dolu)
	dc.b	-1,6	* faza 19
	dc.b	-2,6	* faza 1a
	dc.b	-2,5	* faza 1b
	dc.b	-3,5	* faza 1c
	dc.b	-4,5	* faza 1d
	dc.b	-4,4	* faza 1e 45o lewo-dol
	dc.b	-5,4	* faza 1f
	dc.b	-5,3	* faza 20
	dc.b	-5,2	* faza 21
	dc.b	-6,2	* faza 22
	dc.b	-6,1	* faza 23
	dc.b	-6,0	* faza 24 (poziom w lewo)
	dc.b	-6,-1	* faza 25
	dc.b	-6,-2	* faza 26
	dc.b	-5,-2	* faza 27
	dc.b	-5,-3	* faza 28
	dc.b	-5,-4	* faza 29
	dc.b	-4,-4	* faza 2a 45o lewo-gora
	dc.b	-4,-5	* faza 2b
	dc.b	-3,-5	* faza 2c
	dc.b	-2,-5	* faza 2d
	dc.b	-2,-6	* faza 2e
	dc.b	-1,-6	* faza 2f
********************************************************
* The actual keyboard-interrupt
key_r	movem.l	d0-1/a0,-(sp)
	lea	keytab,a0
	move.b	$fffffc02.w,d0
	spl	d1
	cmp.b	#$fe,d0
	beq.s	.joy1
	cmp.b	#$ff,d0
	beq.s	.joy2
	and.w	#$7f,d0
	move.b	d1,(a0,d0.w)
	movem.l	(sp)+,d0-1/a0
	rte
.joy1	move.l	#joy_r1,$118.w
	movem.l	(sp)+,d0-1/a0
	rte
.joy2	move.l	#joy_r2,$118.w
	movem.l	(sp)+,d0-1/a0
	rte
* Interrupt for joystick 1
joy_r1	movem.l	d0/a0,-(sp)
	move.b	$fffffc02.w,d0
	lea	joy1,a0
	smi	(a0)+
	btst	#0,d0
	sne	(a0)+
	btst	#1,d0
	sne	(a0)+
	btst	#2,d0
	sne	(a0)+
	and.w	#%1000,d0
	sne	(a0)+
	move.l	#key_r,$118.w
	movem.l	(sp)+,d0/a0
	rte
* Interrupt for joystick 2
joy_r2	movem.l	d0/a0,-(sp)
	move.b	$fffffc02.w,d0
	lea	joy2,a0
	smi	(a0)+
	btst	#0,d0
	sne	(a0)+
	btst	#1,d0
	sne	(a0)+
	btst	#2,d0
	sne	(a0)+
	and.w	#%1000,d0
	sne	(a0)+
	move.l	#key_r,$118.w
	movem.l	(sp)+,d0/a0
	rte
* Flush keyboard processor's databuffer
flush	btst.b	#0,$fffffc00.w
	bne.s	jl
	rts
jl	move.b	$fffffc02.w,d7
	bra.s	flush
* Flush keyboard processor's midibuffer
clearmidibuffer
	move.b	$fffffc04.w,d0		* Ensure that the MIDI-buffer
	btst	#0,d0			* is empty
	beq.s	.njet
	move.b	$fffffc06.w,d0
	bra.s	clearmidibuffer
.njet	rts
* Store old values and set up new interrupts
new_interrupts
	move.w	#$2700,sr		* Stop Interrupts
	lea	black_box,a0
	move.l	$70.w,(a0)+		* VBL interrupt
	move.l	$118.w,(a0)+		* Keyboard interrupt
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move.b	$fffffa17.w,(a0)+
* Interrupt enable A ($fffffa07.w)
* bit 7 = I/O port bit 7
* bit 6 = I/O port bit 6
* bit 5 = timer A
* bit 4 = receive buffer full
* bit 3 = receive error
* bit 2 = sender buffer empty
* bit 1 = sender error
* bit 0 = timer B
* Interrupt enable B ($fffffa09.w)
* bit 7 = I/O port bit 5
* bit 6 = I/O port bit 4
* bit 5 = timer C
* bit 4 = timer D
* bit 3 = I/O port bit 3
* bit 2 = I/O port bit 2
* bit 1 = I/O port bit 1
* bit 0 = I/O port bit 0
	move.b	#%11000000,$fffffa07.w	* Enable only keyboard interrupts
	move.b	#%11001111,$fffffa09.w	* Enable only keyboard interrupts
	ori.b	#1,$fffffa13.w
	move.b	#%01000000,$fffffa15.w
	bclr	#3,$fffffa17.w		* Automatic end of interrupts
	move.l	#new_vbl,$70		* Set up new vbl
	move.l	#key_r,$118.w		* keyvector
	move.w	#$2300,sr		* Enable interrupts
	rts
* Restore old registers
old_interrupts
	move.w	#$2700,sr		* Disable interrupts
	lea	black_box,a0
	move.l	(a0)+,$70.w
	move.l	(a0)+,$118.w
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.b	(a0)+,$fffffa17.w
	move.w	#$2300,sr		* Enable interrupts again
	rts
***********************************************
koniec	mfree	block
	bsr	old_interrupts
	bsr	restore_old_colors
	move.b	#$15,$fffffc02.w
	move.b	#$8,$fffffc02.w
	bsr	restore_video
	move.l	old_stack,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp
	quit
*********************************
clr_screen
	move.w	#31,d7
	move.w	d7,d5
	moveq	#0,d4
	move.w	#scr_width-48,d6

clr_screen_ship
 	move.l	(a2)+,a1
	tst.l	a1
	beq.s	clr_fire
	move.w	d5,d0
clr_ship1
	rept	12
	move.l	d4,(a1)+
	endr
	add.w	d6,a1
	dbf	d0,clr_ship1
clr_fire
	move.l	(a2),a1
	add.w	#16,d6
	tst.l	a1
	beq.s	clear_missiles
	move.l	d4,(a2)
	move.w	#15,d0
clr_fire1
	rept	8
	move.l	d4,(a1)+
	endr
	add.w	d6,a1
	dbf	d0,clr_fire1
clear_missiles
	move.w	#19,d7
	moveq.w	#4,d3
clr_mis0
	add.w	d3,a2
	move.l	(a2),a1
	tst.l	a1
	beq.s	clear_next
	move.l	d4,(a2)
	moveq.w	#3,d0
clr_mis1
	rept	8
	move.l	d4,(a1)+
	endr
	add.w	d6,a1
	dbf	d0,clr_mis1
clear_next
	dbf	d7,clr_mis0
	move.w	d5,d7
	sub.w	#16,d6
.clr_s_0
	move.l	(a0),a1
	tst.l	a1
	beq.s	clr_end
	move.l	d4,(a0)+
	move.w	d5,d0
.clr_s_1
	rept	12
	move.l	d4,(a1)+
	endr
	add.w	d6,a1
	dbf	d0,.clr_s_1
	dbf	d7,.clr_s_0
clr_end	rts
*************************************************************
put_sprite
	move.w	#31,d7		* licznik dla tablicy sprajtow
	lea	spr_table,a6
	lea	$ffff8a24.w,a2
	lea	$ffff8a32.w,a3
poczatek_petli_rysujacej
	move.l	(a6),d0
	bmi	petelka
	addq.w	#1,ile_skal
	lea	spr_tab,a0
	clr.b	d0
	rol.l	#8,d0
	move.l	d0,d3
	asl.w	#2,d0
	lea	msk_tab,a1
	add.w	d0,a0		* nastawienie na poczatkowe
	move.l	(a0),a0
	add.w	d0,a1
	move.l	(a1),a1
	tst.w	d0
	beq	maly_objekt
	clr.l	d0
	move.b	$f(a6),d0	* nr fazy
	lsl.w	#7,d0
	move.l	v_scr,a5	* poczatek ekranu
	move.l	d0,d1
	lsl.l	#3,d0
	add.l	d0,a0		* nastawienie na dane sprajta
	clr.l	d0
	move.w	4(a6),d0	* y
	add.w	d1,a1
	swap	d3
	move.l	d0,d2		* mnozenie *640
	lsl.l	#2,d2		*
	add.l	d2,d0		*
	lsl.l	#7,d0		*
	add.l	d0,a5
	move.b	d3,d6		* o ile przesunac x
	and.b	#$f0,d3
	add.w	d3,a5		* gdzie narysowac
	move.l	a5,(a4)+
	and.b	#$0f,d6	
***********************
blitt	move.w	#31,d5
	move.l	(a1)+,d0
	move.l	#$0010ffe2,d0
	move.l	d0,$ffff8a20.w
	move.l	d0,$ffff8a2e.w
	move.l	#$00030008,d4
	move.l	d0,d1
	move.w	#scr_width,d3
	swap	d0
	lsr.w	d6,d0
	clr.l	d2
	move.w	d1,d2
	swap	d2
bl1	lsr.l	d6,d1
	lsr.l	d6,d2
	move.l	a0,(a2)
	move.w	d0,4(a2)
	move.w	d1,6(a2)
	move.w	d2,8(a2)
	move.l	a5,(a3)
	add.w	#32,a0
	move.l	d4,4(a3)
	move.l	(a1)+,d0
	add.w	d3,a5
	move.l	d0,d1
	move.b	d6,$ffff8a3d.w
	swap	d0
	clr.l	d2
	move.b	#$c0,$ffff8a3c.w
	lsr.w	d6,d0
	move.w	d1,d2
	swap	d2
	dbf	d5,bl1
petelka	add.w	#16,a6
	dbf	d7,poczatek_petli_rysujacej
	bra	zrob_zmiany
********************************************
maly_objekt
	clr.l	d0
	move.b	$f(a6),d0	* nr fazy
	lsl.l	#5,d0
	move.l	v_scr,a5	* poczatek ekranu
	move.l	d0,d1
	lsl.l	#3,d0
	add.l	d0,a0		* nastawienie na dane sprajta
	clr.l	d0
	move.w	4(a6),d0	* y
	add.w	d1,a1
	swap	d3
	move.l	d0,d2		* mnozenie *640
	lsl.l	#2,d2		*
	add.l	d2,d0		*
	lsl.l	#7,d0		*
	add.l	d0,a5
	move.b	d3,d6		* o ile przesunac x
	and.b	#$f0,d3
	add.w	d3,a5		* gdzie narysowac
	move.l	a5,(a4)+
	and.b	#$0f,d6	

	move.w	#15,d5
	move.w	#16,d2
	move.l	#$0010fff2,d0
	move.l	d0,$ffff8a20.w
	move.l	d0,$ffff8a2e.w
	move.w	(a1)+,d0
	swap	d0
	clr.w	d0
	move.l	#$00020008,d4
	move.w	#scr_width,d3
	lsr.l	d6,d0
	move.w	d0,d1
	swap	d0
mobj1	move.l	a0,(a2)
	move.w	d0,4(a2)
	move.w	d1,8(a2)
	clr.w	6(a2)
	move.l	a5,(a3)
	add.w	d2,a0
	move.l	d4,4(a3)
	move.w	(a1)+,d0
	add.w	d3,a5
	move.b	d6,$ffff8a3d.w
	move.b	#$c0,$ffff8a3c.w
	swap	d0
	clr.w	d0
	lsr.l	d6,d0
	move.w	d0,d1
	swap	d0
	dbf	d5,mobj1
	add.w	#16,a6
	dbf	d7,poczatek_petli_rysujacej
************************
zrob_zmiany
	lea	spr_table,a6
	move.w	#31,d7
	move.w	#scr_width,d5
	move.w	#scr_height+32,d6
poczatek_testowania_zmian
	move.l	(a6),d3
	bmi	koniec_petli_1
	move.l	$c(a6),d0
	move.w	d0,d1
	swap	d0
	move.b	d1,d2		* w d2 faza
	lsr.w	#8,d1		* w d1 max faza
	tst.b	d0		* czy spin dodatni, czy ujemny?
	bmi.s	spin_ujemny
	addq.b	#1,d2
	cmp.b	d2,d1
	bcs.s	wiekszy
spin1	move.b	d2,$f(a6)
	bra.s	sprawdzenie_przesuniecia
wiekszy	clr.b	$f(a6)
	bra.s	sprawdzenie_przesuniecia
spin_ujemny
	subq.b	#1,d2
	bpl.s	spin1
	move.b	(a6),d0
	cmp.b	#3,d0
	bne.s	spin_u1
	move.l	#$ff000000,(a6)
	clr.l	d0
	move.l	d0,4(a6)
	move.l	d0,8(a6)
	move.l	d0,$c(a6)
	bra.s	koniec_petli_1
spin_u1	move.b	d1,$f(a6)
sprawdzenie_przesuniecia
*** testowany X
x	move.w	9(a6),d0	* cx
	move.b	d0,d1
	lsr.w	#8,d0
	subq.w	#1,d0
	bmi.s	spr_przes1
	move.b	d0,9(a6)
	bra.s	spr_przes_y
spr_przes1
	move.b	d1,9(a6)
	move.b	d3,d1	* dx
	ext.w	d1
	lsr.l	#8,d3	* x
	add.w	d1,d3
	bmi.s	x_mniejszy_0
	cmp.w	d5,d3
	bcc.b	x_wiekszy_scr_width
	move.w	d3,1(a6)
	bra.s	spr_przes_y
x_mniejszy_0
	add.w	d5,d3
	move.w	d3,1(a6)
	bra.s	spr_przes_y
x_wiekszy_scr_width
	sub.w	d5,d3
	move.w	d3,1(a6)
*** testowany Y
spr_przes_y
y	move.w	$b(a6),d0	* cy
	move.b	d0,d1
	lsr.w	#8,d0
	subq.w	#1,d0
	bmi.s	spr_przes2
	move.b	d0,$b(a6)
	bra.s	koniec_petli_1
spr_przes2
	move.b	d1,$b(a6)
	move.l	3(a6),d0
	move.b	d0,d1	* dy
	ext.w	d1
	lsr.l	#8,d0	* y
	add.w	d1,d0
	bmi.s	y_mniejszy_0
	cmp.w	d6,d0
	bcc.b	y_wiekszy_scr_height_32
	move.w	d0,4(a6)
	bra.s	koniec_petli_1
y_mniejszy_0
	add.w	d6,d0
	move.w	d0,4(a6)
	bra.s	koniec_petli_1
y_wiekszy_scr_height_32
	sub.w	d6,d0
	move.w	d0,4(a6)
koniec_petli_1
	add.w	#16,a6
	dbf	d7,poczatek_testowania_zmian
koniec_petli_rysujacej
	rts
******************************************************
ship_bum
******************************************************
	lea	ship_table,a6
kopiuj_statek
	lea	ship,a0
	lea	ship_m,a1
	clr.l	d0
	move.b	$f(a6),d0	* nr fazy
	rol.w	#7,d0
	move.w	d0,d1
	move.l	v_scr,a5	* poczatek ekranu
	rol.l	#3,d0
	add.l	d0,a0		* nastawienie na dane sprajta
	clr.l	d0
	move.w	4(a6),d0	* y
	add.w	d1,a1
	clr.l	d1
	move.w	1(a6),d1	* x
	move.l	d0,d2
	lsl.l	#2,d2
	add.l	d2,d0
	lsl.l	#7,d0
	add.l	d0,a5
	move.b	d1,d6		* o ile przesunac x
	and.b	#$f0,d1
	add.w	d1,a5		* gdzie narysowac
	move.l	a5,(a4)
	and.b	#$0f,d6	
	tst.w	ship_state
	bmi.s	sh_bum
	bra	put_ship
***********************
sh_bum	lea	spr_table,a0
	move.w	#31,d0
	move.w	#-30,d3
	move.w	#30,d4
sh_bum1
	move.b	(a0),d1
	bmi.s	next_skala
	cmp.b	#3,d1
	beq.s	next_skala
	move.w	1(a6),d1	*! x pocisku
	move.w	1(a0),d2	*! x skaly
test_sp_x
	sub.w	d1,d2
	bmi.s	mniejsx
	cmp.w	d4,d2
	bcc.s	next_skala
test_sp_y
	move.w	4(a6),d1	*! y pocisku
	move.w	4(a0),d2	*! y skaly
	sub.w	d1,d2
	bmi.s	mniejsy
	cmp.w	d4,d2
	bcc.s	next_skala
	bra.s	kop_s20
mniejsy	cmp.w	d3,d2
	bcs.s	next_skala
	bra.s	kop_s20
mniejsx	cmp.w	d3,d2
	bcs.s	next_skala
	bra.s	test_sp_y
next_skala
	add.w	#16,a0
	dbf	d0,sh_bum1
	bra	put_ship

kop_s20	move.w	#31,d7
kop_s2	move.l	(a1)+,d0	* maski
	beq.s	kop_s3
	move.l	d0,d1		*
	clr.w	d0		*
	swap	d0		*
	lsr.w	d6,d0		*
	clr.l	d2		*
	move.w	d1,d2		*
	swap	d2		*
	lsr.l	d6,d1		*
	lsr.l	d6,d2		*
	move.w	(a5)+,d3	* czytanie z ekranu
	rept	7
	or.w	(a5)+,d3
	endr
	move.w	(a5)+,d4
	rept	7
	or.w	(a5)+,d4
	endr
	move.w	(a5)+,d5
	rept	7
	or.w	(a5)+,d5
	endr
	and.w	d0,d3
	bne.s	trafiony
	and.w	d1,d4
	bne.s	trafiony
	and.w	d2,d5
	bne.s	trafiony
	add.w	#scr_width-48,a5
	dbf	d7,kop_s2
	bra.s	put_ship
kop_s3	add.w	#scr_width,a5
	dbf	d7,kop_s2
	bra.s	put_ship
trafiony
	move.w	#$13,ship_state
	lea	ship_table,a0
	clr.b	3(a0)
	clr.b	6(a0)
	move.b	#1,$d(a0)
	move.w	#$1300,$e(a0)
	subq.w	#1,ile_zyc
******************************************************
put_ship
******************************************************
	move.w	#19,d7		* licznik dla tablicy ship
	lea	ship_table,a6
rysuj_statek
	tst.w	ship_state
	bmi.s	rysuj1
	beq.s	rysuj0
	lea	wybuch1,a0
	lea	wybuch1_m,a1
	subq.w	#1,ship_state
	bra.s	rysuj2
rysuj0	tst.w	ile_zyc
	beq	koniec
	jsr	prepare_ship
	move.w	#-1,ship_state
	bra	ship_bum
rysuj1	lea	ship,a0
	lea	ship_m,a1
rysuj2	clr.l	d0
	move.b	$f(a6),d0	* nr fazy
	rol.w	#7,d0
	move.w	d0,d1
	rol.l	#3,d0
	add.l	d0,a0		* nastawienie na dane sprajta
	add.w	d1,a1
rysuj3	move.l	(a4)+,a5
***********************
rys_s1	move.w	#31,d5
	move.l	#$0010ffe2,d0
	move.l	d0,$ffff8a20.w
	move.l	d0,$ffff8a2e.w
	move.l	#$00030008,d4
	move.w	#scr_width,d3
	move.l	(a1)+,d0
	move.l	d0,d1
	swap	d0
	lsr.w	d6,d0
	clr.l	d2
	move.w	d1,d2
	swap	d2
rys_s2	lsr.l	d6,d1
	lsr.l	d6,d2
	move.l	a0,(a2)
	move.w	d0,4(a2)
	move.w	d1,6(a2)
	move.w	d2,8(a2)
	move.l	a5,(a3)
	add.w	#32,a0
	move.l	d4,4(a3)
	move.l	(a1)+,d0
	add.w	d3,a5
	move.l	d0,d1
	move.b	d6,$ffff8a3d.w
	swap	d0
	clr.l	d2
	move.b	#$c0,$ffff8a3c.w
	lsr.w	d6,d0
	move.w	d1,d2
	swap	d2
	dbf	d5,rys_s2
************************
ogien?
* jak spasuje fazy!!!!!*
	add.w	#16,a6
	add.w	#4,a4
************************
pociski	add.w	#16,a6
	tst.b	(a6)
	beq	czy_inny_strzal
	sub.b	#1,(a6)
	bpl.s	pocisk1
	clr.b	(a6)
	bra	czy_inny_strzal
pocisk1	clr.l	d1
	move.w	4(a6),d1	* y
	clr.l	d0
	move.l	d1,d2
	move.w	1(a6),d0	* x
	lsl.l	#2,d2
	add.l	d2,d1
	lsl.l	#7,d1
	move.b	d0,d6
	and.b	#$f0,d0
	add.l	d0,d1
	move.l	v_scr,a5
	add.l	d1,a5
	move.l	a5,(a4)
	lea	missile,a0
	lea	missile_m,a1
	and.b	#$f,d6

poc_bum	lea	spr_table,a0
	move.w	#31,d0
	move.w	#-30,d3
	move.w	#3,d4
poc_bum1
	move.b	(a0),d1
	bmi.s	nastepna_skala
	cmp.b	d4,d1
	beq.s	nastepna_skala
	move.w	1(a6),d1	*! x pocisku
	move.w	1(a0),d2	*! x skaly
test_p_x
	sub.w	d1,d2
	bmi.s	mniejx
	cmp.w	d4,d2
	bcc.s	nastepna_skala
test_p_y
	move.w	4(a6),d1	*! y pocisku
	move.w	4(a0),d2	*! y skaly
	sub.w	d1,d2
	bmi.s	mniejy
	cmp.w	d4,d2
	bcc.s	nastepna_skala
	bra.s	missile_bum
mniejy	cmp.w	d3,d2
	bcs.s	nastepna_skala
	bra.s	missile_bum
mniejx	cmp.w	d3,d2
	bcs.s	nastepna_skala
	bra.s	test_p_y
nastepna_skala
	add.w	#16,a0
	dbf	d0,poc_bum1
	bra	blittm
missile_bum
	move.w	d4,d5
tst_poc	move.w	(a1)+,d0
	swap	d0
	clr.w	d0
	lsr.l	d6,d0	* maska
	move.w	(a5)+,d1
	rept	7
	or.w	(a5)+,d1
	endr
	swap	d1
	move.w	(a5)+,d1
	rept	7
	or.w	(a5)+,d1
	endr
	add.w	#scr_width-32,a5
	and.l	d0,d1
	bne.s	tst_pas
	dbf	d5,tst_poc
	bra	blittm
tst_pas	move.l	points,d0
	moveq	#1,d1
	ror.l	#8,d0
	abcd	d1,d0
	clr.b	d2
	roxl.b	d2
	beq.s	tst_p_1
	ror.l	#8,d0
	abcd	d1,d0
	clr.b	d2
	roxl.b	d2
	beq.s	tst_p_2
	ror.l	#8,d0
	abcd	d1,d0
	ror.l	#8,d0
	move.l	d0,points
	bra.s	tst_pas0
tst_p_1	rol.l	#8,d0
	move.l	d0,points
	bra.s	tst_pas0
tst_p_2	swap	d0
	move.l	d0,points

tst_pas0
	clr.l	d0
	move.b	(a0),d0
	cmp.b	#3,d0
	beq	czy_inny_strzal
	subq.b	#1,d0
	bmi	tst_pas1
	beq.s	tst_msk
	cmp.b	#1,d0
	beq.s	tst_ssk
	bra	tst_pas1
tst_msk	move.w	#$1300,d4
	move.l	(a0),d0
	and.l	#$00ffffff,d0
	add.b	3(a6),d0
	move.l	4(a0),d1
	clr.w	d2
	move.b	6(a6),d2
	rol.w	#8,d2
	add.w	d2,d1
	clr.b	d1
	move.l	9(a0),d2
	clr.l	d2
	bra.s	tst_ssk1
tst_ssk	move.w	#$2700,d4
	move.l	(a0),d0
	rol.l	#8,d0
	move.b	#1,d0
	ror.l	#8,d0
	move.l	4(a0),d1
	move.l	9(a0),d2
	and.l	#$03030303,d2
tst_ssk1
	move.l	d0,(a0)
	move.l	d1,4(a0)
	move.l	d2,9(a0)
	move.b	#-1,$d(a0)
	move.w	d4,$e(a0)
	lea	spr_table,a1
	move.w	#31,d5
tst_ssk_szukaj
	tst.b	(a1)
	bpl.s	tst_ssk_next
	move.l	a1,a0
	neg.b	d0
	move.l	d0,(a1)
	neg.w	d1
	clr.b	d1
	move.l	d1,4(a1)
*	swap	d2
*	add.w	#$0101,d2
	move.l	d2,9(a1)
	move.b	#1,$d(a1)
	move.w	d4,$e(a1)
tst_ssk_szukaj2
	add.l	#16,a1
	tst.b	(a1)
	bmi.s	tst_pas10
	dbf	d5,tst_ssk_szukaj2
	bra.s	tst_pas2
tst_ssk_next
	add.w	#16,a1
	dbf	d5,tst_ssk_szukaj
	bra.s	tst_pas2
tst_pas1
	move.b	#3,(a0)
	tst.l	d2
	bne.s	tst_p1
	sub.w	#8,1(a0)
	sub.w	#8,4(a0)
tst_p1	clr.b	3(a0)
	clr.b	6(a0)
	clr.l	8(a0)
	move.l	#$00ff0909,$c(a0)
	move.b	#-1,(a6)
	bra	czy_inny_strzal
tst_pas10
	move.l	a1,a0
tst_pas2
	move.l	d0,(a0)
	move.b	#3,(a0)
	tst.l	d2
	bne.s	tst_p2
	add.w	#8,1(a0)
	add.w	#8,4(a0)
tst_p2	clr.b	3(a0)
	move.l	d1,4(a0)
	clr.b	6(a0)
	clr.l	8(a0)
	move.l	#$00ff0909,$c(a0)
	move.b	#-1,(a6)
	bra.s	czy_inny_strzal
***************************
blittm	move.l	(a4)+,a5
	lea	missile_m,a1
	lea	missile,a0
	move.w	d4,d5
	move.w	#16,d2
	move.l	#$0010fff2,d0
	move.l	d0,$ffff8a20.w
	move.l	d0,$ffff8a2e.w
	move.w	(a1)+,d0
	swap	d0
	clr.w	d0
	move.l	#$00020008,d4
	move.w	#scr_width,d3
	lsr.l	d6,d0
	move.w	d0,d1
	swap	d0
bl1m	move.l	a0,(a2)
	move.w	d0,4(a2)
	move.w	d1,8(a2)
	clr.w	6(a2)
	move.l	a5,(a3)
	add.w	d2,a0
	move.l	d4,4(a3)
	move.w	(a1)+,d0
	add.w	d3,a5
	move.b	d6,$ffff8a3d.w
	move.b	#$c0,$ffff8a3c.w
	swap	d0
	clr.w	d0
	lsr.l	d6,d0
	move.w	d0,d1
	swap	d0
	dbf	d5,bl1m
*******************************
czy_inny_strzal
	dbf	d7,pociski
*******************************
licz_nowe_wspolrzedne
	lea	ship_table,a6
	tst.b	$d(a6)
	beq.s	sprawdzenie_przesuniecia_s
	move.l	$c(a6),d0
	move.w	d0,d1
	move.b	d1,d2		* w d2 faza
	ror.w	#8,d1		* w d1 max faza
	swap	d0
	tst.b	d0		* czy spin dodatni, czy ujemny?
	bmi.s	spin_ujemny_s
	beq.s	sprawdzenie_przesuniecia_s
	addq.w	#1,d2
	cmp.b	d2,d1
	bcs.s	wiekszy_s
spin1_s	move.b	d2,$f(a6)
	bra.s	sprawdzenie_przesuniecia_s
wiekszy_s
	clr.b	$f(a6)
	bra.s	sprawdzenie_przesuniecia_s
spin_ujemny_s
	subq.w	#1,d2
	bpl.s	spin1_s
	move.b	d1,$f(a6)
sprawdzenie_przesuniecia_s
*** testowany X
	move.w	#scr_width,d5
	move.w	#scr_height+32,d6
	move.l	(a6),d0
	move.b	d0,d1	* dx
	ext.w	d1
	lsr.l	#8,d0	* x
	add.w	d1,d0
	bmi.s	x_mniejszy_0s
	cmp.w	d5,d0
	bcc.s	x_wiekszy_scr_widths
	move.w	d0,1(a6)
	bra.s	spr_przes_ys
x_mniejszy_0s
	add.w	d5,d0
	move.w	d0,1(a6)
	bra.s	spr_przes_ys
x_wiekszy_scr_widths
	sub.w	d5,d0
	move.w	d0,1(a6)
*** testowany Y
spr_przes_ys
	move.l	3(a6),d0
	move.b	d0,d1	* dy
	ext.w	d1
	lsr.l	#8,d0	* y
	add.w	d1,d0
	bmi.s	y_mniejszy_0s
	cmp.w	d6,d0
	bcc.s	y_wiekszy_scr_height_32s
	move.w	d0,4(a6)
	bra.s	fire_tst
y_mniejszy_0s
	add.w	d6,d0
	move.w	d0,4(a6)
	bra.s	fire_tst
y_wiekszy_scr_height_32s
	sub.w	d6,d0
	move.w	d0,4(a6)
*************************
* tu powinno byc testowanie/zmiana ognia
fire_tst
	add.w	#16,a6
**************************
	move.w	#19,d7
koniec_petli_1s
	add.w	#16,a6
x_m	tst.b	(a6)
	beq	nastepny_pocisk
	move.l	(a6),d0
	move.b	d0,d1
	lsr.l	#8,d0
	ext.w	d1
	add.w	d1,d0
	bmi	x_mniejszy_0m
	cmp.w	d5,d0
	bcc.s	x_wiekszy_scr_widthm
	move.w	d0,1(a6)
	bra.s	spr_przes_ym
x_mniejszy_0m
	add.w	d5,d0
	move.w	d0,1(a6)
	bra.s	spr_przes_ym
x_wiekszy_scr_widthm
	sub.w	d5,d0
	move.w	d0,1(a6)
spr_przes_ym
	move.l	3(a6),d0
	move.b	d0,d1
	lsr.l	#8,d0
	ext.w	d1
	add.w	d1,d0
	bmi.s	y_mniejszy_0m
	cmp.w	d6,d0
	bcc.s	y_wiekszy_scr_height_32m
	move.w	d0,4(a6)
	bra.s	nastepny_pocisk
y_mniejszy_0m
	add.w	d6,d0
	move.w	d0,4(a6)
	bra.s	nastepny_pocisk
y_wiekszy_scr_height_32m
	sub.w	d6,d0
	move.w	d0,4(a6)
nastepny_pocisk
	dbf	d7,koniec_petli_1s
	rts
*************************************
prepare_ship
	lea	ship_table,a6
	move.b	#3,(a6)+	* statek
	move.w	#scr_width,d0
	move.w	#scr_height,d1
	lsr.w	d0
	lsr.w	d1
	move.w	d0,(a6)+	* x
	move.b	#0,(a6)+	* dx
	move.w	d1,(a6)+	* y
	move.b	#0,(a6)+	* dy
	clr.w	(a6)+
	clr.l	(a6)+		* cx=ccx=cy=ccy=0
	clr.b	(a6)+		* spin=0
	move.b	#47,(a6)+	* max faza
	clr.b	(a6)+		* faza
	rts
***************************************
prepare_level
	lea	spr_table,a6
	move.w	#31,d0
pl_1	move.b	#-1,(a6)
	add.w	#16,a6
	dbf	d0,pl_1
	lea	spr_table,a6
	move.w	ile_sprajtow,d7
	subq	#2,d7		* bez 1 na statek
pl_2	move.b	#2,(a6)+	* nr sprajta
	jsr	random
	and.w	#scr_width-32,d0
	move.w	d0,(a6)+	* x.w sprajta
	jsr	random
	and.w	#2,d0
	subq	#1,d0
	move.b	d0,(a6)+	* dx sprajta
	jsr	random
	and.w	#$1,d0
	mulu.w	#32+scr_height,d0
	move.w	d0,(a6)+	* y.w sprajta
	jsr	random
	and.w	#2,d0
	subq	#1,d0
	move.b	d0,(a6)+	* dy.w sprajta
	clr.w	(a6)+
	move.w	max_speed,d6
	jsr	random
	and.w	d6,d0
	move.b	d0,(a6)+	* counter x sprajta (opozniacz)
	move.b	d0,(a6)+	* wartosc counter x
	jsr	random
	and.w	d6,d0
	bne	pl_3
	move.b	-1(a6),d1
	bne	pl_3
	moveq.w	#1,d0
pl_3	move.b	d0,(a6)+	* counter y sprajta (opozniacz)
	move.b	d0,(a6)+	* wartosc counter y
	jsr	random
	and.b	#2,d0
	subq	#1,d0
	move.b	d0,(a6)+	* spin
	lea	faz_tab,a5
	clr.w	d0
	move.b	-$e(a6),d0
	add.w	d0,a5
	move.b	(a5),d6
	move.b	d6,(a6)+	* max faza
	jsr	random
	and.b	d6,d0
	move.b	d0,(a6)+	* faza
	dbf	d7,pl_2
	rts
******************************
random	move.w	#17,-(sp)
	trap	#14
	addq	#2,sp
	rts
******************************************************
clr_screens
	move.l	v_scr1,a0
	move.w	#56320-1,d1
	move.w	d1,d0
cs1	clr.l	(a0)+
	dbf	d0,cs1
	move.w	d1,d0
cs1a	clr.l	(a0)+
	dbf	d0,cs1a
cs1b	clr.l	(a0)+
	dbf	d1,cs1b
	rts
*****************************
synchro	move.b	d0,d2
	ror.l	#8,d0
	move.b	d0,d1
	ror.w	#8,d0
	move.l	$466.w,d3
.rept	move.l	$466.w,d3
.wait	cmp.l	$466.w,d3
	beq.b	.wait
	move.l	vbl_delay,d3
	addq.l	#2,d3
	cmp.l	$466.w,d3
	bgt.s	.rept
	move.l	$466.w,vbl_delay
	move.b	d0,$ffff8201.w
	move.b	d1,$ffff8203.w
	move.b	d2,$ffff820d.w

	move.b	bonus_delay,d0
	sub.b	#$1,d0
	beq.s	snc_b
	move.b	d0,bonus_delay
	rts

snc_b	move.w	ile_skal,d0
	beq	koniec
	clr.w	ile_skal
	move.b	#$20,bonus_delay
	move.w	bonus,d0
	beq.s	snc_q1
	moveq	#1,d1
	sbcd	d1,d0
	clr.b	d2
	roxl.b	d2
	beq.s	snc_q
	move.w	d0,d2
	ror.w	#8,d2
	addi.b	#1,d0
	sbcd	d1,d2
	rol.w	#8,d2
	move.w	d2,bonus
	rts


snc_q	move.w	d0,bonus
snc_q1	rts
vbl_delay	ds.l	1
******************************
set_new_screen
	move.l	scr,d0
	move.b	d0,d2
	ror.l	#8,d0
	move.b	d0,d1
	ror.w	#8,d0
	move.b	d0,$ffff8201.w
	move.b	d1,$ffff8203.w
	move.b	d2,$ffff820d.w
	rts
*******************************
set_new_colors
	lea	col_new,a0
	lea	col_old,a1
	move.l	#$ffff9800,a2
	move.w	#255,d0
snc1	move.l	(a2),(a1)+
	move.l	(a0)+,(a2)+
	dbf	d0,snc1
	rts
*******************************
restore_old_colors
	lea	col_old,a0
	move.l	#$ffff9800,a1
	move.w	#255,d0
roc1	move.l	(a0)+,(a1)+
	dbf	d0,roc1
	rts
*******************************
save_video
	chg_rez	#-1
	move.w	d0,old_rez
	scr_adr
	move.l	d0,old_scr
	rts
********************************
restore_video
	chg_rez	old_rez
	move.l	old_scr,d0
	move.b	d0,$ffff820d.w
	ror.l	#8,d0 
	move.b	d0,$ffff8203.w
	ror.l	#8,d0
	move.b	d0,$ffff8201.w
	rts
********************************
*set_new_resolution
* Screenblaster III, 1993/94 by Christian Cartus & Manuel Hermann
* Monitor: VGA
* 320*240, 256 Farben, 50.0 Hz, 31470 Hz

	move.l   #$c6008d,$ffff8282.w
	move.l   #$15029a,$ffff8286.w
	move.l   #$7b0096,$ffff828a.w
	move.l   #$4eb04d1,$ffff82a2.w
	move.l   #$3f00a5,$ffff82a6.w
	move.l   #$46504e7,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$186,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$10,$ffff8266.w
	move.w   #$5,$ffff82c2.w
	move.w   #$A0,$ffff8210.w
	rts

set_new_resolution
	m_type
	cmp.b	#1,d0
	beq.s	rgb
	cmp.b	#2,d0
	beq	vga
	bra	koniec
* Monitor: VGA
* 640*480, 256 Farben, 50.0 Hz, 31470 Hz
vga	move.l   #$c6008d,$ffff8282.w
	move.l   #$1502ab,$ffff8286.w
	move.l   #$840096,$ffff828a.w
	move.l   #$4eb04d1,$ffff82a2.w
	move.l   #$3f00a7,$ffff82a6.w
	move.l   #$46704e7,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$186,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$10,$ffff8266.w
	move.w   #$8,$ffff82c2.w
	move.w   #$140,$ffff8210.w
	rts
* Monitor: RGB/TV
* 640*480, 256 Farben, 50.0 Hz (intrl.), 15625 Hz
rgb	move.l   #$1fe0199,$ffff8282.w
	move.l   #$500071,$ffff8286.w
	move.l   #$12201b2,$ffff828a.w
	move.l   #$2700265,$ffff82a2.w
	move.l   #$2f0058,$ffff82a6.w
	move.l   #$238026b,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$182,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$10,$ffff8266.w
	move.w   #$6,$ffff82c2.w
	move.w   #$140,$ffff8210.w
	rts
no_memory
	bra	koniec
*******************************************
init_vbl
	move.l	$70.w,old_vbl
	clr.l	$466.w
	move.l	#new_vbl,$70.w
	rts
*******************************************
new_vbl	addq.l	#1,$466.w
	rte
*******************************************
draw_bar
*******************************************
	move.l	v_scr,a0
	add.l	#640*(435+32),a0
* rysuj linie kolor $ff
	move.w	#159,d7
	move.w	d7,d0
	move.l	#-1,d1
kol_ff	move.l	d1,(a0)+
	dbf	d0,kol_ff
* rysuj linie kolor $fe
	move.w	#39,d7
	move.w	d7,d0
	
kol_fe	clr.w	(a0)+
	move.w	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbf	d0,kol_fe
* rysuj kolor fd
	move.w	d7,d0
kol_fd	move.w	d1,(a0)+
	clr.w	(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbf	d0,kol_fd
* rysuj kolor fc
	move.w	d7,d0
kol_fc	clr.l	(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbf	d0,kol_fc
* rysuj kolor fb
	move.w	d7,d0
kol_fb	move.l	d1,(a0)+
	clr.w	(a0)+
	move.w	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbf	d0,kol_fb
* rysuj kolor fa
	move.w	d7,d0
kol_fa	clr.w	(a0)+
	move.w	d1,(a0)+
	clr.w	(a0)+
	move.w	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbf	d0,kol_fa
* rysuj kolor f9
	move.w	d7,d0
kol_f9	move.w	d1,(a0)+
	clr.l	(a0)+
	move.w	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbf	d0,kol_f9
* rysuj kolor f8
	move.w	d7,d0
kol_f8	clr.l	(a0)+
	clr.w	(a0)+
	move.w	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbf	d0,kol_f8
* rysuj kolor f7
	move.w	d7,d0
kol_f7	move.l	d1,(a0)+
	move.w	d1,(a0)+
	clr.w	(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbf	d0,kol_f7
* rysuj kolor f6
	move.w	d7,d0
kol_f6	clr.w	(a0)+
	move.l	d1,(a0)+
	clr.w	(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbf	d0,kol_f6
* rysuj kolor f5
	move.w	d7,d0
kol_f5	move.w	d1,(a0)+
	clr.w	(a0)+
	move.w	d1,(a0)+
	clr.w	(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbf	d0,kol_f5
	add.w	#640*2,a0
	lea	ship,a1
	move.w	#640-32,d0
	move.w	#31,d1
bar_ship
	rept	8
	move.l	(a1)+,(a0)+
	endr
	add.w	d0,a0
	dbf	d1,bar_ship
	sub.w	#(640*26)-32,a0
	lea	cyferki,a1
	move.w	ile_zyc,d1
	subq.b	#1,d1
	bpl.s	bar_dig1
	clr.w	d1
bar_dig1
	lsl.w	#8,d1
	add.w	d1,a1
	move.w	#640-16,d1
	move.w	#15,d0
bar_digits
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	add.w	d1,a0
	dbf	d0,bar_digits

	sub.w	#(640*16)-48,a0
	move.w	#640-(6*16),d1
	lea	points_napis,a1
	move.w	#15,d0
bar_points_napis
	rept	24
	move.l	(a1)+,(a0)+
	endr
	add.w	d1,a0
	dbf	d0,bar_points_napis

	sub.w	#(640*16)-112,a0
	move.l	points,d0
	move.w	#(640*16)-16,d6
	move.w	#640-16,d5
	move.w	#15,d4
	move.w	#7,d2
bpn_0	move.w	d4,d3
	lea	cyferki,a1
	rol.l	#4,d0
	move.b	d0,d1
	and.w	#$f,d1
	rol.w	#8,d1
	add.w	d1,a1
bpn	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	add.w	d5,a0
	dbf	d3,bpn
	sub.w	d6,a0
	dbf	d2,bpn_0

* draw bonus
	sub.w	#(640)-32,a0
	move.w	#640-(5*16),d1
	lea	bonus_napis,a1
	move.w	#15,d0
bar_bonus_napis
	rept	20
	move.l	(a1)+,(a0)+
	endr
	add.w	d1,a0
	dbf	d0,bar_bonus_napis

	sub.w	#(640*16)-96,a0
	move.w	bonus,d0
	move.w	#(640*16)-16,d6
	move.w	#640-16,d5
	move.w	#15,d4
	move.w	#3,d2
bbn_0	move.w	d4,d3
	lea	cyferki,a1
	rol.w	#4,d0
	move.b	d0,d1
	and.w	#$f,d1
	lsl.w	#8,d1
	add.w	d1,a1
bbn	rept	4
	move.l	(a1)+,(a0)+
	endr
	add.w	d5,a0
	dbf	d3,bbn
	sub.w	d6,a0
	dbf	d2,bbn_0


	rts
*******************************************
make_bonus_block
	lea	bonus_napis,a0
	move.w	#0,d0
	move.w	#15,d7
mbb	lea	literki,a1
	move.w	#256*1,d1
	add.w	d0,d1
	move.l	0(a1,d1.w),(a0)+
	move.l	4(a1,d1.w),(a0)+
	move.l	8(a1,d1.w),(a0)+
	move.l	$c(a1,d1.w),(a0)+
	move.w	#256*14,d1
	add.w	d0,d1
	move.l	0(a1,d1.w),(a0)+
	move.l	4(a1,d1.w),(a0)+
	move.l	8(a1,d1.w),(a0)+
	move.l	$c(a1,d1.w),(a0)+
	move.w	#256*13,d1
	add.w	d0,d1
	move.l	0(a1,d1.w),(a0)+
	move.l	4(a1,d1.w),(a0)+
	move.l	8(a1,d1.w),(a0)+
	move.l	$c(a1,d1.w),(a0)+
	move.w	#256*20,d1
	add.w	d0,d1
	move.l	0(a1,d1.w),(a0)+
	move.l	4(a1,d1.w),(a0)+
	move.l	8(a1,d1.w),(a0)+
	move.l	$c(a1,d1.w),(a0)+
	move.w	#256*18,d1
	add.w	d0,d1
	move.l	0(a1,d1.w),(a0)+
	move.l	4(a1,d1.w),(a0)+
	move.l	8(a1,d1.w),(a0)+
	move.l	$c(a1,d1.w),(a0)+
	add.w	#16,d0
	dbf	d7,mbb
	rts
*******************************************
make_points_block
	lea	points_napis,a0
	move.w	#0,d0
	move.w	#15,d7
mpb	lea	literki,a1
	move.w	#256*15,d1
	add.w	d0,d1
	move.l	0(a1,d1.w),(a0)+
	move.l	4(a1,d1.w),(a0)+
	move.l	8(a1,d1.w),(a0)+
	move.l	$c(a1,d1.w),(a0)+
	move.w	#256*14,d1
	add.w	d0,d1
	move.l	0(a1,d1.w),(a0)+
	move.l	4(a1,d1.w),(a0)+
	move.l	8(a1,d1.w),(a0)+
	move.l	$c(a1,d1.w),(a0)+
	move.w	#256*8,d1
	add.w	d0,d1
	move.l	0(a1,d1.w),(a0)+
	move.l	4(a1,d1.w),(a0)+
	move.l	8(a1,d1.w),(a0)+
	move.l	$c(a1,d1.w),(a0)+
	move.w	#256*13,d1
	add.w	d0,d1
	move.l	0(a1,d1.w),(a0)+
	move.l	4(a1,d1.w),(a0)+
	move.l	8(a1,d1.w),(a0)+
	move.l	$c(a1,d1.w),(a0)+
	move.w	#256*19,d1
	add.w	d0,d1
	move.l	0(a1,d1.w),(a0)+
	move.l	4(a1,d1.w),(a0)+
	move.l	8(a1,d1.w),(a0)+
	move.l	$c(a1,d1.w),(a0)+
	move.w	#256*18,d1
	add.w	d0,d1
	move.l	0(a1,d1.w),(a0)+
	move.l	4(a1,d1.w),(a0)+
	move.l	8(a1,d1.w),(a0)+
	move.l	$c(a1,d1.w),(a0)+
	add.w	#16,d0
	dbf	d7,mpb
	rts
*******************************************
	nop
	dc.l	0
text	dc.b	27,"E",27,"v"
	incbin	datas\text.dat

	dc.l	0
*******************************************
	ds.l	$100
ustck	ds.l	1
old_stack	dc.l	0
block	ds.l	1
*******************************************
col_new	incbin	datas\colors.dat
col_old	ds.l	256
*******************************************
tab1	ds.l	32	* tablice na pozycje sprita do zamazania
tab2	ds.l	32
ship_tab1	ds.l	22
ship_tab2	ds.l	22
*******************************************
* tablica dla statku, plomienia oraz strzalow
ship_table	ds.b	16*22
*******************************************
spr_tab	dc.l	msk,ssk,dsk,wybuch2,0,0,0
msk_tab	dc.l	msk_m,ssk_m,dsk_m,wybuch2_m,0,0,0
faz_tab	dc.b	0,0,59,0,0,0,0,0

dsk		incbin	datas\dskala.dat
dsk_m		incbin	datas\dskala.msk
ssk		incbin	datas\sskala.dat
ssk_m		incbin	datas\sskala.msk
msk		incbin	datas\mskala.dat
msk_m		incbin	datas\mskala.msk
ship		incbin	datas\ship.dat
ship_m		incbin	datas\ship.msk
fire		incbin	datas\ogien.dat
fire_m		incbin	datas\ogien.msk
missile		incbin	datas\missile.dat
missile_m	incbin	datas\missile.msk
wybuch1		incbin	datas\wybuch1.dat
wybuch1_m	incbin	datas\wybuch1.msk
wybuch2		incbin	datas\wybuch2.dat
wybuch2_m	incbin	datas\wybuch2.msk
*******************************************
cyferki		incbin	datas\cyferki.dat
literki		incbin	datas\literki.dat
bonus_napis	ds.b	1280
points_napis	ds.b	1536
*******************************************
* tablica obslugi sprajtow
* nr,x(2),y(2),dx(2),dy(2),cx,ccy,cy,ccy,spin,max_faza,faza
spr_table
	ds.b	16*32
*******************************************
max_speed	dc.w	5
ile_sprajtow	dc.w	10
*******************************************
ile_skal	dc.w	0
ile_zyc		dc.w	4
points		dc.l	0
bonus		dc.w	0
bonus_delay	dc.b	$20
fire_status	dc.w	0
ship_state	dc.w	$ffff
old_vbl		dc.l	0
vbl_counter	dc.w	0
old_rez		dc.b	0
old_scr		dc.l	0
v_scr1		dc.l	0
scr1		dc.l	0
v_scr2		dc.l	0
scr2		dc.l	0
v_scr		dc.l	0
scr		dc.l	0

joy1	* Joystick 1's data
	DCB.B	5,0
	EVEN
joy2	* Joystick 2's data
	DCB.B	5,0
	EVEN
keytab	DCB.B	256,0
sync	DC.W	0
black_box	DS.L	16
	END