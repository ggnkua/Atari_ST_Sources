; little dots example for harekiet
; - one optimiation to save 11.25 scanlines identified
; - another optimization is to move one scree to lower memory, and use 2 bitplanes on 1 screen, and this would reduce 4 cycles for clearing rout
;	from 20 to 16 cycles
; for feedback or questions, #atariscne @ ircnet

max_dots				equ 1920-40

	IFD DEMOSYSTEM
		IFD	STANDALONE
		ELSE
STANDALONE 					equ 1
		ENDC
	ELSE
STANDALONE					equ 0
	ENDC

	IFEQ STANDALONE
TRUE	equ	0
FALSE	equ 1
true	equ 0
false	equ 1

	ENDC

	include	lib/macro.s

    section	TEXT



	IFEQ	STANDALONE
			initAndRun	standalone_init

standalone_init





	jsr		init_syncdots


.x
	
    cmp.b   #$39,$fffffc02.w                                ; spacebar to exit
    bne     .x                                       ;

	rts
	ENDC


wvbl
    addq.w  #1,$466.w
    rte


syncdots_vbl
	addq.w	#1,$466.w
	move.w	#0,$ffff8240
    pushall
	move.l	screenpointer,$ffff8200
			swapscreens

	jsr		clearPixels
	jsr		drawPixel

	move.l	pixelPointer2,d0
	move.l	pixelPointer,pixelPointer2
	move.l	d0,pixelPointer

		
	popall
	move.w	#$300,$ffff8240
	rte


init_syncdots
	move.l	#memBase+65536,d0
	sub.w	d0,d0
	move.l	d0,screenpointer
	add.l	#$20000,d0
	move.l	d0,screenpointer2
	add.l	#$20000,d0
	move.l	d0,x_table_pointer
	move.l	d0,d1
	add.l	#$1000,d1
	move.l	d1,x_dual_pointer
	add.l	#7000,d1
	move.l	d1,y_dual_pointer
	add.l	#4000,d1
	move.l	d1,y_first_pointer
	add.l	#13000,d1
	move.l	d1,x2_pointer
	add.l	#4800,d1
	move.l	d1,clearPixelsPointer
	add.l	#$18500,d1
	move.l	d1,drawPixelsPointer
	add.l	#$20000,d0
	add.l	#$10000,d0
	move.l	d0,pixelPointer
	add.l	#$10000,d0
	move.l	d0,pixelPointer2
	add.l	#$10000,d0


	move.w	#$001,d0
	lea		$ffff8240,a0
	REPT 16
		move.w	d0,(a0)+
	ENDR
	move.w	#$777,$ffff8240+1*2
	move.l	screenpointer,$ffff8200

	jsr		copyTables
	jsr		generateXTab
	jsr		generateClearPixels
	jsr		generateDrawPixels



    move.w  #$2700,sr
    move.l  #wvbl,$70
    move.w  #$2300,sr

    move.w  #0,$466
.w  tst.w   $466.w
    beq     .w

	move.w	#$2700,sr
	move.l	#syncdots_vbl,$70
	move.w	#$2300,sr	

.vbl
	tst.w	$466.w
	beq		.vbl
		move.w	#0,$466.w
		subq.w	#1,.vblcounter
		bge		.vbl

	rts  
.vblcounter		dc.w	49*50-420



clearPixels
	move.l	screenpointer2,d1
	move.l	pixelPointer2,a0
	move.w	#0,d0
	move.l	clearPixelsPointer,a6
	jsr		(a6)
	rts


clearPixelTemplate	; this is the code that is used as a template to generate unrolled code
		move.w	(a0)+,d1				;8	get location					;2
		move.l	d1,a1					;4	screenptr						;2
		move.w	d0,(a1)					;8	clear screen			20		;2		--> 6 1400*6 = 8400
		move.w	(a0)+,d1				;8	get location					;2
		move.l	d1,a1					;4	screenptr						;2
		move.w	d0,(a1)					;8	clear screen			20		;2		--> 6 1400*6 = 8400
		move.w	(a0)+,d1				;8	get location					;2
		move.l	d1,a1					;4	screenptr						;2
		move.w	d0,(a1)					;8	clear screen			20		;2		--> 6 1400*6 = 8400
		move.w	(a0)+,d1				;8	get location					;2
		move.l	d1,a1					;4	screenptr						;2
		move.w	d0,(a1)					;8	clear screen			20		;2		--> 6 1400*6 = 8400
		move.w	(a0)+,d1				;8	get location					;2
		move.l	d1,a1					;4	screenptr						;2
		move.w	d0,(a1)					;8	clear screen			20		;2		--> 6 1400*6 = 8400
		move.w	(a0)+,d1				;8	get location					;2
		move.l	d1,a1					;4	screenptr						;2
		move.w	d0,(a1)					;8	clear screen			20		;2		--> 6 1400*6 = 8400
		move.w	(a0)+,d1				;8	get location					;2
		move.l	d1,a1					;4	screenptr						;2
		move.w	d0,(a1)					;8	clear screen			20		;2		--> 6 1400*6 = 8400
		move.w	(a0)+,d1				;8	get location					;2
		move.l	d1,a1					;4	screenptr						;2
		move.w	d0,(a1)					;8	clear screen			20		;2		--> 6 1400*6 = 8400


generateClearPixels
	lea		clearPixelTemplate,a0
	move.l	clearPixelsPointer,a1								;		8400 +2
	movem.l	(a0),d0-d6/a2-a6		;7+5 = 12*4 = 48	= 8 times
	move.w	#max_dots/40-1,d7
.l				
		movem.l	d0-d6/a2-a6,48*0(a1)				; 35 * 40 = 1400
		movem.l	d0-d6/a2-a6,48*1(a1)
		movem.l	d0-d6/a2-a6,48*2(a1)
		movem.l	d0-d6/a2-a6,48*3(a1)
		movem.l	d0-d6/a2-a6,48*4(a1)
		lea		48*5(a1),a1
	dbra	d7,.l
	move.l	d0,(a1)+
	move.l	d1,(a1)+
	move.l	d2,(a1)+
	move.l	d0,(a1)+
	move.l	d1,(a1)+
	move.l	d2,(a1)+
	move.w	#$4e75,(a1)		;rts
	rts


drawPixel
	move.l	x_table_pointer,d0
	move.l	screenpointer2,d2
	move.l	pixelPointer2,a0

	add.w	#4,x1_off
	and.w	#%11111111110,x1_off
;	and.w	#-512,x1_off

;	lea		x_dual,a2
	move.l	x_dual_pointer,a2
	add.w	x1_off,a2

;	lea		y_first,a3
	move.l	y_first_pointer,a3
	add.w	x1_off,a3
	add.w	x1_off,a3

;	lea		x2,a5
	move.l	x2_pointer,a5
	add.w	x2_off,a5

;	lea		y_dual,a6
	move.l	y_dual_pointer,a6
	add.w	y2_off,a6

	add.w	#2,y2_off
	cmp.w	#600*2,y2_off
	bge		.okk
		move.w	#0,y2_off
.okk

	add.w	#2,x2_off
	cmp.w	#320*2,x2_off
	bne		.ok

		move.w	#0,x2_off
.ok

	addq.w	#6,d6
	move.l	drawPixelsPointer,a1

	jmp		(a1)
	; determine x and y
;	REPT 1400
;		move.w	(a2)+,d0				;8								
;		add.w	(a5)+,d0				;8
;
;		move.l	d0,a1					;4	x	
;		move.w	(a1)+,d2				;8	x to screen off
;		move.w	(a1),d3					;8	mask
;
;		add.w	(a3)+,d2				;8
;		add.w	(a6)+,d2				;8
;		add.w	d6,d2					;4
;
;		move.l	d2,a4					;4	screenpointer
;		or.w	d3,(a4)					;12	write pixel to screen
;		move.w	d2,(a0)+				;8	save screenloc				80				;22 bytes 	30800
;	ENDR
;	rts

drawPixelTemplate	; this is the code that is used as a template to generate unrolled code
		move.w	(a2)+,d0				;8							;x1				
;		add.w	(a5)+,d0				;8							;x2		; these 2 tables sohuld be merged for nice dots

		move.l	d0,a1					;4	x	
		move.w	(a1)+,d2				;8	x to screen off
		move.w	(a1),d0					;8	mask

		add.w	(a3)+,d2				;8							;y1
;		add.w	(a6)+,d2				;8									; these 2 tables should be merged for nice dots

		move.l	d2,a4					;4	screenpointer
		or.w	d0,(a4)					;12	write pixel to screen
		move.w	d2,(a0)+				;8	save screenloc				

		move.w	(a2)+,d0				;8								
;		add.w	(a5)+,d0				;8							

		move.l	d0,a1					;4	x	
		move.w	(a1)+,d2				;8	x to screen off
		move.w	(a1),d0					;8	mask

		add.w	(a3)+,d2				;8
;		add.w	(a6)+,d2				;8

		move.l	d2,a4					;4	screenpointer
		or.w	d0,(a4)					;12	write pixel to screen
		move.w	d2,(a0)+				;8	save screenloc				

		;;; optimization here is: movem.w	 x-y,(a0), lea off(a0),a0, to write multiple addresses to screenlocs in one go
		;;; is 4 cycles profit for each register movem.w'ed after the first 3
		; quick survey: regs in use:
		;	a0 - screenlocs
		;	a1 - xoff,mask lookup (can be used to movemw)
		;	a2 - xmove source
		;	a3 - ymove source
		;	a4 - local screen pointer (can be used to movemw)
		;	a5 - free, (can be used to movemw)
		;	a6 - free, (can be used to movemw)
		;	a7 - free, (can be used to movemw) (save stack etc)		

		;	d0 - aligned to xoff, used also for mask
		;	d1 - free, (can be used to movemw)
		;	d2 - aligned to screenhigh (can be used to movemw)
		;	d3 - (can be used to movemw)
		;	d4 - (can be used to movemw)
		;	d5 - (can be used to movemw)
		;	d6 - (can be used to movemw)
		;	d7 - (can be used to movemw)

		; free regs: 12 => for each 12 dots, 36 cycles won --> on 1920 dots --> 5760 cycles won; is 11 scanlines
		;	

generateDrawPixels
	lea		drawPixelTemplate,a0
	move.l	drawPixelsPointer,a1

	movem.l	(a0),d0-d6/a2-a4			;11 = 40
	move.w	#max_dots/40-1,d7
.ll
		movem.l	d0-d6/a2,0*32(a1)			; 20 * 70 = 1400
		movem.l	d0-d6/a2,1*32(a1)
		movem.l	d0-d6/a2,2*32(a1)
		movem.l	d0-d6/a2,3*32(a1)
		movem.l	d0-d6/a2,4*32(a1)
		movem.l	d0-d6/a2,5*32(a1)
		movem.l	d0-d6/a2,6*32(a1)
		movem.l	d0-d6/a2,7*32(a1)
		movem.l	d0-d6/a2,8*32(a1)
		movem.l	d0-d6/a2,9*32(a1)
		movem.l	d0-d6/a2,10*32(a1)
		movem.l	d0-d6/a2,11*32(a1)
		movem.l	d0-d6/a2,12*32(a1)
		movem.l	d0-d6/a2,13*32(a1)
		movem.l	d0-d6/a2,14*32(a1)
		movem.l	d0-d6/a2,15*32(a1)
		movem.l	d0-d6/a2,16*32(a1)
		movem.l	d0-d6/a2,17*32(a1)
		movem.l	d0-d6/a2,18*32(a1)
		movem.l	d0-d6/a2,19*32(a1)
		lea		20*32(a1),a1
	dbra	d7,.ll
	move.w	#$4e75,(a1)
	rts






generateXTab
	move.l	x_table_pointer,a0
	move.w	#20-1,d7
	moveq	#8,d1
	moveq	#0,d2

.ol
	move.w	#16-1,d6
	move.w	#%1<<15,d0	
.il
		move.w	d2,(a0)+
		move.w	d0,(a0)+
		lsr.w	#1,d0
	dbra	d6,.il

	add.w	d1,d2
	dbra	d7,.ol
	rts




x1_off	dc.w	0
y1_off	dc.w	0
x2_off	dc.w	0
y2_off	dc.w	0


x_dual_pointer	ds.l	1
y_dual_pointer	ds.l	1
y_first_pointer	ds.l	1
x2_pointer		ds.l	1

copyTables
	lea		x_dual,a6
	move.l	x_dual_pointer,a1

	move.w	#6-1,d6
.o1
	move.l	a6,a0
	move.w	#512/4-1,d7
.i1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		dbra	d7,.i1
	dbra	d6,.o1

	lea		y_dual,a6
	move.l	y_dual_pointer,a1
	move.w	#3-1,d6
.o2
	move.l	a6,a0
	move.w	#600/4-1,d7
.i2
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		dbra	d7,.i2
	dbra	d6,.o2

	lea		y_first,a6
	move.l	y_first_pointer,a1
	move.w	#12-1,d6
.o3
	move.l	a6,a0
	move.w	#512/4-1,d7
.i3
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		dbra	d7,.i3
	dbra	d6,.o3

	lea		x2,a6
	move.l	x2_pointer,a1
	move.w	#6-1,d6
.o4
	move.l	a6,a0
	move.w	#320/4-1,d7
.i4
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		dbra	d7,.i4
	dbra	d6,.o4


	rts



	section DATA


x_dual		;include x_dual.s			;512 entries	1024 size		256 	-> 6*256	= 6144
	dc.w	640
	dc.w	652
	dc.w	660
	dc.w	672
	dc.w	680
	dc.w	692
	dc.w	700
	dc.w	708
	dc.w	716
	dc.w	728
	dc.w	740
	dc.w	748
	dc.w	756
	dc.w	764
	dc.w	772
	dc.w	780
	dc.w	788
	dc.w	796
	dc.w	804
	dc.w	808
	dc.w	816
	dc.w	820
	dc.w	828
	dc.w	836
	dc.w	840
	dc.w	848
	dc.w	848
	dc.w	856
	dc.w	856
	dc.w	864
	dc.w	864
	dc.w	868
	dc.w	868
	dc.w	872
	dc.w	872
	dc.w	876
	dc.w	872
	dc.w	876
	dc.w	872
	dc.w	876
	dc.w	872
	dc.w	872
	dc.w	868
	dc.w	868
	dc.w	864
	dc.w	864
	dc.w	860
	dc.w	860
	dc.w	852
	dc.w	848
	dc.w	844
	dc.w	840
	dc.w	836
	dc.w	832
	dc.w	828
	dc.w	820
	dc.w	816
	dc.w	808
	dc.w	804
	dc.w	800
	dc.w	792
	dc.w	788
	dc.w	780
	dc.w	772
	dc.w	768
	dc.w	760
	dc.w	756
	dc.w	748
	dc.w	740
	dc.w	736
	dc.w	728
	dc.w	724
	dc.w	720
	dc.w	712
	dc.w	704
	dc.w	700
	dc.w	696
	dc.w	688
	dc.w	688
	dc.w	680
	dc.w	676
	dc.w	672
	dc.w	668
	dc.w	664
	dc.w	664
	dc.w	660
	dc.w	656
	dc.w	652
	dc.w	652
	dc.w	648
	dc.w	648
	dc.w	644
	dc.w	648
	dc.w	644
	dc.w	644
	dc.w	644
	dc.w	648
	dc.w	648
	dc.w	648
	dc.w	648
	dc.w	652
	dc.w	656
	dc.w	660
	dc.w	660
	dc.w	664
	dc.w	668
	dc.w	672
	dc.w	680
	dc.w	684
	dc.w	688
	dc.w	692
	dc.w	696
	dc.w	704
	dc.w	708
	dc.w	716
	dc.w	720
	dc.w	732
	dc.w	736
	dc.w	744
	dc.w	752
	dc.w	760
	dc.w	768
	dc.w	772
	dc.w	780
	dc.w	788
	dc.w	796
	dc.w	804
	dc.w	812
	dc.w	820
	dc.w	828
	dc.w	836
	dc.w	844
	dc.w	852
	dc.w	860
	dc.w	868
	dc.w	872
	dc.w	880
	dc.w	888
	dc.w	896
	dc.w	904
	dc.w	908
	dc.w	912
	dc.w	916
	dc.w	924
	dc.w	928
	dc.w	936
	dc.w	940
	dc.w	944
	dc.w	948
	dc.w	952
	dc.w	952
	dc.w	956
	dc.w	960
	dc.w	964
	dc.w	964
	dc.w	968
	dc.w	964
	dc.w	968
	dc.w	968
	dc.w	968
	dc.w	968
	dc.w	964
	dc.w	964
	dc.w	964
	dc.w	960
	dc.w	956
	dc.w	952
	dc.w	952
	dc.w	948
	dc.w	940
	dc.w	936
	dc.w	932
	dc.w	928
	dc.w	920
	dc.w	916
	dc.w	912
	dc.w	900
	dc.w	896
	dc.w	888
	dc.w	880
	dc.w	872
	dc.w	868
	dc.w	856
	dc.w	848
	dc.w	840
	dc.w	828
	dc.w	824
	dc.w	816
	dc.w	804
	dc.w	796
	dc.w	788
	dc.w	776
	dc.w	768
	dc.w	756
	dc.w	748
	dc.w	740
	dc.w	728
	dc.w	720
	dc.w	708
	dc.w	704
	dc.w	696
	dc.w	684
	dc.w	676
	dc.w	664
	dc.w	660
	dc.w	648
	dc.w	644
	dc.w	632
	dc.w	628
	dc.w	620
	dc.w	612
	dc.w	608
	dc.w	600
	dc.w	596
	dc.w	588
	dc.w	584
	dc.w	576
	dc.w	572
	dc.w	568
	dc.w	564
	dc.w	560
	dc.w	556
	dc.w	552
	dc.w	552
	dc.w	548
	dc.w	548
	dc.w	544
	dc.w	544
	dc.w	544
	dc.w	544
	dc.w	544
	dc.w	544
	dc.w	544
	dc.w	548
	dc.w	548
	dc.w	548
	dc.w	552
	dc.w	552
	dc.w	556
	dc.w	556
	dc.w	564
	dc.w	564
	dc.w	572
	dc.w	572
	dc.w	580
	dc.w	580
	dc.w	588
	dc.w	592
	dc.w	596
	dc.w	604
	dc.w	604
	dc.w	612
	dc.w	616
	dc.w	624
	dc.w	628
	dc.w	636
	dc.w	640
	dc.w	644
	dc.w	652
	dc.w	656
	dc.w	664
	dc.w	668
	dc.w	676
	dc.w	676
	dc.w	684
	dc.w	688
	dc.w	692
	dc.w	700
	dc.w	700
	dc.w	708
	dc.w	708
	dc.w	716
	dc.w	716
	dc.w	724
	dc.w	724
	dc.w	728
	dc.w	728
	dc.w	732
	dc.w	732
	dc.w	732
	dc.w	736
	dc.w	736
	dc.w	736
	dc.w	736
	dc.w	736
	dc.w	736
	dc.w	736
	dc.w	732
	dc.w	732
	dc.w	728
	dc.w	728
	dc.w	724
	dc.w	720
	dc.w	716
	dc.w	712
	dc.w	708
	dc.w	704
	dc.w	696
	dc.w	692
	dc.w	684
	dc.w	680
	dc.w	672
	dc.w	668
	dc.w	660
	dc.w	652
	dc.w	648
	dc.w	636
	dc.w	632
	dc.w	620
	dc.w	616
	dc.w	604
	dc.w	596
	dc.w	584
	dc.w	576
	dc.w	572
	dc.w	560
	dc.w	552
	dc.w	540
	dc.w	532
	dc.w	524
	dc.w	512
	dc.w	504
	dc.w	492
	dc.w	484
	dc.w	476
	dc.w	464
	dc.w	456
	dc.w	452
	dc.w	440
	dc.w	432
	dc.w	424
	dc.w	412
	dc.w	408
	dc.w	400
	dc.w	392
	dc.w	384
	dc.w	380
	dc.w	368
	dc.w	364
	dc.w	360
	dc.w	352
	dc.w	348
	dc.w	344
	dc.w	340
	dc.w	332
	dc.w	328
	dc.w	328
	dc.w	324
	dc.w	320
	dc.w	316
	dc.w	316
	dc.w	316
	dc.w	312
	dc.w	312
	dc.w	312
	dc.w	312
	dc.w	316
	dc.w	312
	dc.w	316
	dc.w	316
	dc.w	320
	dc.w	324
	dc.w	328
	dc.w	328
	dc.w	332
	dc.w	336
	dc.w	340
	dc.w	344
	dc.w	352
	dc.w	356
	dc.w	364
	dc.w	368
	dc.w	372
	dc.w	376
	dc.w	384
	dc.w	392
	dc.w	400
	dc.w	408
	dc.w	412
	dc.w	420
	dc.w	428
	dc.w	436
	dc.w	444
	dc.w	452
	dc.w	460
	dc.w	468
	dc.w	476
	dc.w	484
	dc.w	492
	dc.w	500
	dc.w	508
	dc.w	512
	dc.w	520
	dc.w	528
	dc.w	536
	dc.w	544
	dc.w	548
	dc.w	560
	dc.w	564
	dc.w	572
	dc.w	576
	dc.w	584
	dc.w	588
	dc.w	592
	dc.w	596
	dc.w	600
	dc.w	608
	dc.w	612
	dc.w	616
	dc.w	620
	dc.w	620
	dc.w	624
	dc.w	628
	dc.w	632
	dc.w	632
	dc.w	632
	dc.w	632
	dc.w	636
	dc.w	636
	dc.w	636
	dc.w	632
	dc.w	636
	dc.w	632
	dc.w	632
	dc.w	628
	dc.w	628
	dc.w	624
	dc.w	620
	dc.w	616
	dc.w	616
	dc.w	612
	dc.w	608
	dc.w	604
	dc.w	600
	dc.w	592
	dc.w	592
	dc.w	584
	dc.w	580
	dc.w	576
	dc.w	568
	dc.w	560
	dc.w	556
	dc.w	552
	dc.w	544
	dc.w	540
	dc.w	532
	dc.w	524
	dc.w	520
	dc.w	512
	dc.w	508
	dc.w	500
	dc.w	492
	dc.w	488
	dc.w	480
	dc.w	476
	dc.w	472
	dc.w	464
	dc.w	460
	dc.w	452
	dc.w	448
	dc.w	444
	dc.w	440
	dc.w	436
	dc.w	432
	dc.w	428
	dc.w	420
	dc.w	420
	dc.w	416
	dc.w	416
	dc.w	412
	dc.w	412
	dc.w	408
	dc.w	408
	dc.w	404
	dc.w	408
	dc.w	404
	dc.w	408
	dc.w	404
	dc.w	408
	dc.w	408
	dc.w	412
	dc.w	412
	dc.w	416
	dc.w	416
	dc.w	424
	dc.w	424
	dc.w	432
	dc.w	432
	dc.w	440
	dc.w	444
	dc.w	452
	dc.w	460
	dc.w	464
	dc.w	472
	dc.w	476
	dc.w	484
	dc.w	492
	dc.w	500
	dc.w	508
	dc.w	516
	dc.w	524
	dc.w	532
	dc.w	540
	dc.w	552
	dc.w	564
	dc.w	572
	dc.w	580
	dc.w	588
	dc.w	600
	dc.w	608
	dc.w	620
	dc.w	628
y_dual		;include	y_dual.s			;600 entries	1200 size		-> 	3*600*2 = 3600
	dc.w	19200
	dc.w	19360
	dc.w	19680
	dc.w	20000
	dc.w	20320
	dc.w	20480
	dc.w	20800
	dc.w	20960
	dc.w	21440
	dc.w	21600
	dc.w	21760
	dc.w	22080
	dc.w	22400
	dc.w	22560
	dc.w	22720
	dc.w	23040
	dc.w	23200
	dc.w	23520
	dc.w	23680
	dc.w	23840
	dc.w	24000
	dc.w	24160
	dc.w	24480
	dc.w	24640
	dc.w	24800
	dc.w	24800
	dc.w	24960
	dc.w	25280
	dc.w	25280
	dc.w	25440
	dc.w	25440
	dc.w	25600
	dc.w	25760
	dc.w	25760
	dc.w	25920
	dc.w	25920
	dc.w	25920
	dc.w	26080
	dc.w	26080
	dc.w	26080
	dc.w	26080
	dc.w	26080
	dc.w	26080
	dc.w	26080
	dc.w	26080
	dc.w	25920
	dc.w	25920
	dc.w	25760
	dc.w	25920
	dc.w	25760
	dc.w	25600
	dc.w	25600
	dc.w	25440
	dc.w	25440
	dc.w	25280
	dc.w	25120
	dc.w	24960
	dc.w	24800
	dc.w	24640
	dc.w	24640
	dc.w	24480
	dc.w	24160
	dc.w	24000
	dc.w	23840
	dc.w	23680
	dc.w	23520
	dc.w	23360
	dc.w	23200
	dc.w	22880
	dc.w	22720
	dc.w	22400
	dc.w	22400
	dc.w	22080
	dc.w	21920
	dc.w	21600
	dc.w	21440
	dc.w	21280
	dc.w	20960
	dc.w	20960
	dc.w	20640
	dc.w	20480
	dc.w	20160
	dc.w	20000
	dc.w	19680
	dc.w	19520
	dc.w	19520
	dc.w	19200
	dc.w	19040
	dc.w	18880
	dc.w	18720
	dc.w	18400
	dc.w	18240
	dc.w	18080
	dc.w	18080
	dc.w	17920
	dc.w	17760
	dc.w	17600
	dc.w	17440
	dc.w	17280
	dc.w	17120
	dc.w	17120
	dc.w	16960
	dc.w	16960
	dc.w	16960
	dc.w	16800
	dc.w	16800
	dc.w	16640
	dc.w	16640
	dc.w	16640
	dc.w	16480
	dc.w	16480
	dc.w	16480
	dc.w	16480
	dc.w	16640
	dc.w	16640
	dc.w	16640
	dc.w	16640
	dc.w	16800
	dc.w	16800
	dc.w	16800
	dc.w	16960
	dc.w	16960
	dc.w	17120
	dc.w	17120
	dc.w	17280
	dc.w	17440
	dc.w	17440
	dc.w	17600
	dc.w	17760
	dc.w	18080
	dc.w	18240
	dc.w	18400
	dc.w	18560
	dc.w	18720
	dc.w	18880
	dc.w	19040
	dc.w	19360
	dc.w	19520
	dc.w	19680
	dc.w	19840
	dc.w	20160
	dc.w	20320
	dc.w	20480
	dc.w	20800
	dc.w	20960
	dc.w	21280
	dc.w	21440
	dc.w	21760
	dc.w	21920
	dc.w	22240
	dc.w	22400
	dc.w	22560
	dc.w	22880
	dc.w	23040
	dc.w	23360
	dc.w	23520
	dc.w	23840
	dc.w	24000
	dc.w	24320
	dc.w	24480
	dc.w	24640
	dc.w	24960
	dc.w	25120
	dc.w	25280
	dc.w	25440
	dc.w	25760
	dc.w	25920
	dc.w	26080
	dc.w	26240
	dc.w	26400
	dc.w	26560
	dc.w	26720
	dc.w	26720
	dc.w	26880
	dc.w	27040
	dc.w	27040
	dc.w	27200
	dc.w	27360
	dc.w	27360
	dc.w	27520
	dc.w	27520
	dc.w	27680
	dc.w	27680
	dc.w	27680
	dc.w	27840
	dc.w	27840
	dc.w	27840
	dc.w	27840
	dc.w	27680
	dc.w	27680
	dc.w	27680
	dc.w	27680
	dc.w	27520
	dc.w	27520
	dc.w	27520
	dc.w	27360
	dc.w	27360
	dc.w	27200
	dc.w	27200
	dc.w	26880
	dc.w	26720
	dc.w	26720
	dc.w	26560
	dc.w	26400
	dc.w	26240
	dc.w	26080
	dc.w	25920
	dc.w	25760
	dc.w	25440
	dc.w	25280
	dc.w	25120
	dc.w	24800
	dc.w	24640
	dc.w	24480
	dc.w	24320
	dc.w	24000
	dc.w	23680
	dc.w	23520
	dc.w	23200
	dc.w	23040
	dc.w	22720
	dc.w	22560
	dc.w	22240
	dc.w	21920
	dc.w	21600
	dc.w	21440
	dc.w	21280
	dc.w	20960
	dc.w	20800
	dc.w	20480
	dc.w	20160
	dc.w	19840
	dc.w	19680
	dc.w	19360
	dc.w	19200
	dc.w	19040
	dc.w	18560
	dc.w	18400
	dc.w	18240
	dc.w	18080
	dc.w	17760
	dc.w	17600
	dc.w	17280
	dc.w	17120
	dc.w	16960
	dc.w	16800
	dc.w	16640
	dc.w	16480
	dc.w	16160
	dc.w	16000
	dc.w	16000
	dc.w	15840
	dc.w	15680
	dc.w	15520
	dc.w	15360
	dc.w	15360
	dc.w	15200
	dc.w	15200
	dc.w	15200
	dc.w	14880
	dc.w	14880
	dc.w	14880
	dc.w	14880
	dc.w	14880
	dc.w	14720
	dc.w	14720
	dc.w	14720
	dc.w	14880
	dc.w	14880
	dc.w	14720
	dc.w	14880
	dc.w	14880
	dc.w	15040
	dc.w	15040
	dc.w	15040
	dc.w	15200
	dc.w	15200
	dc.w	15360
	dc.w	15520
	dc.w	15520
	dc.w	15680
	dc.w	15840
	dc.w	16000
	dc.w	16160
	dc.w	16160
	dc.w	16320
	dc.w	16640
	dc.w	16800
	dc.w	16960
	dc.w	16960
	dc.w	17280
	dc.w	17440
	dc.w	17600
	dc.w	17760
	dc.w	17920
	dc.w	18240
	dc.w	18400
	dc.w	18720
	dc.w	18720
	dc.w	19040
	dc.w	19200
	dc.w	19360
	dc.w	19680
	dc.w	19680
	dc.w	20000
	dc.w	20160
	dc.w	20480
	dc.w	20640
	dc.w	20800
	dc.w	20960
	dc.w	21120
	dc.w	21440
	dc.w	21440
	dc.w	21600
	dc.w	21760
	dc.w	22080
	dc.w	22240
	dc.w	22240
	dc.w	22400
	dc.w	22560
	dc.w	22720
	dc.w	22880
	dc.w	22880
	dc.w	23040
	dc.w	23200
	dc.w	23200
	dc.w	23360
	dc.w	23360
	dc.w	23360
	dc.w	23520
	dc.w	23520
	dc.w	23680
	dc.w	23520
	dc.w	23520
	dc.w	23680
	dc.w	23680
	dc.w	23680
	dc.w	23520
	dc.w	23520
	dc.w	23520
	dc.w	23520
	dc.w	23520
	dc.w	23200
	dc.w	23200
	dc.w	23200
	dc.w	23040
	dc.w	23040
	dc.w	22880
	dc.w	22720
	dc.w	22560
	dc.w	22400
	dc.w	22400
	dc.w	22240
	dc.w	21920
	dc.w	21760
	dc.w	21600
	dc.w	21440
	dc.w	21280
	dc.w	21120
	dc.w	20800
	dc.w	20640
	dc.w	20320
	dc.w	20160
	dc.w	20000
	dc.w	19840
	dc.w	19360
	dc.w	19200
	dc.w	19040
	dc.w	18720
	dc.w	18560
	dc.w	18240
	dc.w	17920
	dc.w	17600
	dc.w	17440
	dc.w	17120
	dc.w	16960
	dc.w	16800
	dc.w	16480
	dc.w	16160
	dc.w	15840
	dc.w	15680
	dc.w	15360
	dc.w	15200
	dc.w	14880
	dc.w	14720
	dc.w	14400
	dc.w	14080
	dc.w	13920
	dc.w	13760
	dc.w	13600
	dc.w	13280
	dc.w	13120
	dc.w	12960
	dc.w	12640
	dc.w	12480
	dc.w	12320
	dc.w	12160
	dc.w	12000
	dc.w	11840
	dc.w	11680
	dc.w	11680
	dc.w	11520
	dc.w	11200
	dc.w	11200
	dc.w	11040
	dc.w	11040
	dc.w	10880
	dc.w	10880
	dc.w	10880
	dc.w	10720
	dc.w	10720
	dc.w	10720
	dc.w	10720
	dc.w	10560
	dc.w	10560
	dc.w	10560
	dc.w	10560
	dc.w	10720
	dc.w	10720
	dc.w	10720
	dc.w	10880
	dc.w	10880
	dc.w	11040
	dc.w	11040
	dc.w	11200
	dc.w	11360
	dc.w	11360
	dc.w	11520
	dc.w	11680
	dc.w	11680
	dc.w	11840
	dc.w	12000
	dc.w	12160
	dc.w	12320
	dc.w	12480
	dc.w	12640
	dc.w	12960
	dc.w	13120
	dc.w	13280
	dc.w	13440
	dc.w	13760
	dc.w	13920
	dc.w	14080
	dc.w	14400
	dc.w	14560
	dc.w	14880
	dc.w	15040
	dc.w	15360
	dc.w	15520
	dc.w	15840
	dc.w	16000
	dc.w	16160
	dc.w	16480
	dc.w	16640
	dc.w	16960
	dc.w	17120
	dc.w	17440
	dc.w	17600
	dc.w	17920
	dc.w	18080
	dc.w	18240
	dc.w	18560
	dc.w	18720
	dc.w	18880
	dc.w	19040
	dc.w	19360
	dc.w	19520
	dc.w	19680
	dc.w	19840
	dc.w	20000
	dc.w	20160
	dc.w	20320
	dc.w	20640
	dc.w	20800
	dc.w	20960
	dc.w	20960
	dc.w	21120
	dc.w	21280
	dc.w	21280
	dc.w	21440
	dc.w	21440
	dc.w	21600
	dc.w	21600
	dc.w	21600
	dc.w	21760
	dc.w	21760
	dc.w	21760
	dc.w	21760
	dc.w	21920
	dc.w	21920
	dc.w	21920
	dc.w	21920
	dc.w	21760
	dc.w	21760
	dc.w	21760
	dc.w	21600
	dc.w	21600
	dc.w	21440
	dc.w	21440
	dc.w	21440
	dc.w	21280
	dc.w	21280
	dc.w	21120
	dc.w	20960
	dc.w	20800
	dc.w	20640
	dc.w	20480
	dc.w	20320
	dc.w	20320
	dc.w	20160
	dc.w	20000
	dc.w	19680
	dc.w	19520
	dc.w	19360
	dc.w	19200
	dc.w	18880
	dc.w	18880
	dc.w	18720
	dc.w	18400
	dc.w	18240
	dc.w	17920
	dc.w	17760
	dc.w	17440
	dc.w	17440
	dc.w	17120
	dc.w	16960
	dc.w	16800
	dc.w	16480
	dc.w	16320
	dc.w	16000
	dc.w	16000
	dc.w	15680
	dc.w	15520
	dc.w	15200
	dc.w	15040
	dc.w	14880
	dc.w	14720
	dc.w	14560
	dc.w	14400
	dc.w	14240
	dc.w	13920
	dc.w	13760
	dc.w	13760
	dc.w	13600
	dc.w	13440
	dc.w	13280
	dc.w	13120
	dc.w	12960
	dc.w	12960
	dc.w	12800
	dc.w	12800
	dc.w	12640
	dc.w	12480
	dc.w	12640
	dc.w	12480
	dc.w	12480
	dc.w	12320
	dc.w	12320
	dc.w	12320
	dc.w	12320
	dc.w	12320
	dc.w	12320
	dc.w	12320
	dc.w	12320
	dc.w	12480
	dc.w	12480
	dc.w	12480
	dc.w	12640
	dc.w	12640
	dc.w	12800
	dc.w	12960
	dc.w	12960
	dc.w	13120
	dc.w	13120
	dc.w	13440
	dc.w	13600
	dc.w	13600
	dc.w	13760
	dc.w	13920
	dc.w	14240
	dc.w	14400
	dc.w	14560
	dc.w	14720
	dc.w	14880
	dc.w	15200
	dc.w	15360
	dc.w	15680
	dc.w	15840
	dc.w	16000
	dc.w	16320
	dc.w	16640
	dc.w	16800
	dc.w	16960
	dc.w	17440
	dc.w	17600
	dc.w	17920
	dc.w	18080
	dc.w	18400
	dc.w	18720
	dc.w	19040

y_first	;	include	y1.s				;512 entries	1024 size		128		-> 12*128		= 12288
	dc.w	1600
	dc.w	1600
	dc.w	1760
	dc.w	1760
	dc.w	1920
	dc.w	1920
	dc.w	2080
	dc.w	2080
	dc.w	2240
	dc.w	2240
	dc.w	2400
	dc.w	2400
	dc.w	2560
	dc.w	2560
	dc.w	2720
	dc.w	2720
	dc.w	2880
	dc.w	2880
	dc.w	3040
	dc.w	3040
	dc.w	3200
	dc.w	3200
	dc.w	3360
	dc.w	3360
	dc.w	3520
	dc.w	3520
	dc.w	3680
	dc.w	3680
	dc.w	3680
	dc.w	3840
	dc.w	3840
	dc.w	4000
	dc.w	4000
	dc.w	4160
	dc.w	4160
	dc.w	4320
	dc.w	4320
	dc.w	4480
	dc.w	4480
	dc.w	4480
	dc.w	4640
	dc.w	4640
	dc.w	4800
	dc.w	4800
	dc.w	4960
	dc.w	4960
	dc.w	4960
	dc.w	5120
	dc.w	5120
	dc.w	5280
	dc.w	5280
	dc.w	5280
	dc.w	5440
	dc.w	5440
	dc.w	5600
	dc.w	5600
	dc.w	5600
	dc.w	5760
	dc.w	5760
	dc.w	5760
	dc.w	5920
	dc.w	5920
	dc.w	6080
	dc.w	6080
	dc.w	6080
	dc.w	6240
	dc.w	6240
	dc.w	6240
	dc.w	6400
	dc.w	6400
	dc.w	6400
	dc.w	6560
	dc.w	6560
	dc.w	6560
	dc.w	6720
	dc.w	6720
	dc.w	6720
	dc.w	6720
	dc.w	6880
	dc.w	6880
	dc.w	6880
	dc.w	7040
	dc.w	7040
	dc.w	7040
	dc.w	7040
	dc.w	7200
	dc.w	7200
	dc.w	7200
	dc.w	7200
	dc.w	7360
	dc.w	7360
	dc.w	7360
	dc.w	7360
	dc.w	7360
	dc.w	7520
	dc.w	7520
	dc.w	7520
	dc.w	7520
	dc.w	7520
	dc.w	7520
	dc.w	7680
	dc.w	7680
	dc.w	7680
	dc.w	7680
	dc.w	7680
	dc.w	7680
	dc.w	7840
	dc.w	7840
	dc.w	7840
	dc.w	7840
	dc.w	7840
	dc.w	7840
	dc.w	7840
	dc.w	7840
	dc.w	7840
	dc.w	7840
	dc.w	8000
	dc.w	8000
	dc.w	8000
	dc.w	8000
	dc.w	8000
	dc.w	8000
	dc.w	8000
	dc.w	8000
	dc.w	8000
	dc.w	8000
	dc.w	8000
	dc.w	8000
	dc.w	8000
	dc.w	8000
	dc.w	8000
	dc.w	8000
	dc.w	8000
	dc.w	8000
	dc.w	8000
	dc.w	8000
	dc.w	8000
	dc.w	8000
	dc.w	8000
	dc.w	8000
	dc.w	8000
	dc.w	7840
	dc.w	7840
	dc.w	7840
	dc.w	7840
	dc.w	7840
	dc.w	7840
	dc.w	7840
	dc.w	7840
	dc.w	7840
	dc.w	7840
	dc.w	7680
	dc.w	7680
	dc.w	7680
	dc.w	7680
	dc.w	7680
	dc.w	7680
	dc.w	7520
	dc.w	7520
	dc.w	7520
	dc.w	7520
	dc.w	7520
	dc.w	7520
	dc.w	7360
	dc.w	7360
	dc.w	7360
	dc.w	7360
	dc.w	7360
	dc.w	7200
	dc.w	7200
	dc.w	7200
	dc.w	7200
	dc.w	7040
	dc.w	7040
	dc.w	7040
	dc.w	7040
	dc.w	6880
	dc.w	6880
	dc.w	6880
	dc.w	6720
	dc.w	6720
	dc.w	6720
	dc.w	6720
	dc.w	6560
	dc.w	6560
	dc.w	6560
	dc.w	6400
	dc.w	6400
	dc.w	6400
	dc.w	6240
	dc.w	6240
	dc.w	6240
	dc.w	6080
	dc.w	6080
	dc.w	6080
	dc.w	5920
	dc.w	5920
	dc.w	5760
	dc.w	5760
	dc.w	5760
	dc.w	5600
	dc.w	5600
	dc.w	5600
	dc.w	5440
	dc.w	5440
	dc.w	5280
	dc.w	5280
	dc.w	5280
	dc.w	5120
	dc.w	5120
	dc.w	4960
	dc.w	4960
	dc.w	4960
	dc.w	4800
	dc.w	4800
	dc.w	4640
	dc.w	4640
	dc.w	4480
	dc.w	4480
	dc.w	4480
	dc.w	4320
	dc.w	4320
	dc.w	4160
	dc.w	4160
	dc.w	4000
	dc.w	4000
	dc.w	3840
	dc.w	3840
	dc.w	3680
	dc.w	3680
	dc.w	3680
	dc.w	3520
	dc.w	3520
	dc.w	3360
	dc.w	3360
	dc.w	3200
	dc.w	3200
	dc.w	3040
	dc.w	3040
	dc.w	2880
	dc.w	2880
	dc.w	2720
	dc.w	2720
	dc.w	2560
	dc.w	2560
	dc.w	2400
	dc.w	2400
	dc.w	2240
	dc.w	2240
	dc.w	2080
	dc.w	2080
	dc.w	1920
	dc.w	1920
	dc.w	1760
	dc.w	1760
	dc.w	1600
	dc.w	1600
	dc.w	1600
	dc.w	1440
	dc.w	1440
	dc.w	1280
	dc.w	1280
	dc.w	1120
	dc.w	1120
	dc.w	960
	dc.w	960
	dc.w	800
	dc.w	800
	dc.w	640
	dc.w	640
	dc.w	480
	dc.w	480
	dc.w	320
	dc.w	320
	dc.w	160
	dc.w	160
	dc.w	0
	dc.w	0
	dc.w	-160
	dc.w	-160
	dc.w	-320
	dc.w	-320
	dc.w	-480
	dc.w	-480
	dc.w	-480
	dc.w	-640
	dc.w	-640
	dc.w	-800
	dc.w	-800
	dc.w	-960
	dc.w	-960
	dc.w	-1120
	dc.w	-1120
	dc.w	-1280
	dc.w	-1280
	dc.w	-1280
	dc.w	-1440
	dc.w	-1440
	dc.w	-1600
	dc.w	-1600
	dc.w	-1760
	dc.w	-1760
	dc.w	-1760
	dc.w	-1920
	dc.w	-1920
	dc.w	-2080
	dc.w	-2080
	dc.w	-2080
	dc.w	-2240
	dc.w	-2240
	dc.w	-2400
	dc.w	-2400
	dc.w	-2400
	dc.w	-2560
	dc.w	-2560
	dc.w	-2560
	dc.w	-2720
	dc.w	-2720
	dc.w	-2880
	dc.w	-2880
	dc.w	-2880
	dc.w	-3040
	dc.w	-3040
	dc.w	-3040
	dc.w	-3200
	dc.w	-3200
	dc.w	-3200
	dc.w	-3360
	dc.w	-3360
	dc.w	-3360
	dc.w	-3520
	dc.w	-3520
	dc.w	-3520
	dc.w	-3520
	dc.w	-3680
	dc.w	-3680
	dc.w	-3680
	dc.w	-3840
	dc.w	-3840
	dc.w	-3840
	dc.w	-3840
	dc.w	-4000
	dc.w	-4000
	dc.w	-4000
	dc.w	-4000
	dc.w	-4160
	dc.w	-4160
	dc.w	-4160
	dc.w	-4160
	dc.w	-4160
	dc.w	-4320
	dc.w	-4320
	dc.w	-4320
	dc.w	-4320
	dc.w	-4320
	dc.w	-4320
	dc.w	-4480
	dc.w	-4480
	dc.w	-4480
	dc.w	-4480
	dc.w	-4480
	dc.w	-4480
	dc.w	-4640
	dc.w	-4640
	dc.w	-4640
	dc.w	-4640
	dc.w	-4640
	dc.w	-4640
	dc.w	-4640
	dc.w	-4640
	dc.w	-4640
	dc.w	-4640
	dc.w	-4800
	dc.w	-4800
	dc.w	-4800
	dc.w	-4800
	dc.w	-4800
	dc.w	-4800
	dc.w	-4800
	dc.w	-4800
	dc.w	-4800
	dc.w	-4800
	dc.w	-4800
	dc.w	-4800
	dc.w	-4800
	dc.w	-4800
	dc.w	-4800
	dc.w	-4800
	dc.w	-4800
	dc.w	-4800
	dc.w	-4800
	dc.w	-4800
	dc.w	-4800
	dc.w	-4800
	dc.w	-4800
	dc.w	-4800
	dc.w	-4800
	dc.w	-4640
	dc.w	-4640
	dc.w	-4640
	dc.w	-4640
	dc.w	-4640
	dc.w	-4640
	dc.w	-4640
	dc.w	-4640
	dc.w	-4640
	dc.w	-4640
	dc.w	-4480
	dc.w	-4480
	dc.w	-4480
	dc.w	-4480
	dc.w	-4480
	dc.w	-4480
	dc.w	-4320
	dc.w	-4320
	dc.w	-4320
	dc.w	-4320
	dc.w	-4320
	dc.w	-4320
	dc.w	-4160
	dc.w	-4160
	dc.w	-4160
	dc.w	-4160
	dc.w	-4160
	dc.w	-4000
	dc.w	-4000
	dc.w	-4000
	dc.w	-4000
	dc.w	-3840
	dc.w	-3840
	dc.w	-3840
	dc.w	-3840
	dc.w	-3680
	dc.w	-3680
	dc.w	-3680
	dc.w	-3520
	dc.w	-3520
	dc.w	-3520
	dc.w	-3520
	dc.w	-3360
	dc.w	-3360
	dc.w	-3360
	dc.w	-3200
	dc.w	-3200
	dc.w	-3200
	dc.w	-3040
	dc.w	-3040
	dc.w	-3040
	dc.w	-2880
	dc.w	-2880
	dc.w	-2880
	dc.w	-2720
	dc.w	-2720
	dc.w	-2560
	dc.w	-2560
	dc.w	-2560
	dc.w	-2400
	dc.w	-2400
	dc.w	-2400
	dc.w	-2240
	dc.w	-2240
	dc.w	-2080
	dc.w	-2080
	dc.w	-2080
	dc.w	-1920
	dc.w	-1920
	dc.w	-1760
	dc.w	-1760
	dc.w	-1760
	dc.w	-1600
	dc.w	-1600
	dc.w	-1440
	dc.w	-1440
	dc.w	-1280
	dc.w	-1280
	dc.w	-1280
	dc.w	-1120
	dc.w	-1120
	dc.w	-960
	dc.w	-960
	dc.w	-800
	dc.w	-800
	dc.w	-640
	dc.w	-640
	dc.w	-480
	dc.w	-480
	dc.w	-480
	dc.w	-320
	dc.w	-320
	dc.w	-160
	dc.w	-160
	dc.w	0
	dc.w	0
	dc.w	160
	dc.w	160
	dc.w	320
	dc.w	320
	dc.w	480
	dc.w	480
	dc.w	640
	dc.w	640
	dc.w	800
	dc.w	800
	dc.w	960
	dc.w	960
	dc.w	1120
	dc.w	1120
	dc.w	1280
	dc.w	1280
	dc.w	1440
	dc.w	1440
	dc.w	1600

x2		;	include	x2.s				;320 entries	640	size		6*320*2		= 	3840
	dc.w	0
	dc.w	4
	dc.w	12
	dc.w	16
	dc.w	24
	dc.w	28
	dc.w	36
	dc.w	40
	dc.w	48
	dc.w	52
	dc.w	60
	dc.w	64
	dc.w	72
	dc.w	76
	dc.w	80
	dc.w	88
	dc.w	92
	dc.w	100
	dc.w	104
	dc.w	108
	dc.w	116
	dc.w	120
	dc.w	124
	dc.w	132
	dc.w	136
	dc.w	140
	dc.w	148
	dc.w	152
	dc.w	156
	dc.w	160
	dc.w	168
	dc.w	172
	dc.w	176
	dc.w	180
	dc.w	184
	dc.w	192
	dc.w	196
	dc.w	200
	dc.w	204
	dc.w	208
	dc.w	212
	dc.w	216
	dc.w	220
	dc.w	224
	dc.w	228
	dc.w	232
	dc.w	236
	dc.w	240
	dc.w	244
	dc.w	248
	dc.w	248
	dc.w	252
	dc.w	256
	dc.w	260
	dc.w	260
	dc.w	264
	dc.w	268
	dc.w	268
	dc.w	272
	dc.w	276
	dc.w	276
	dc.w	280
	dc.w	280
	dc.w	284
	dc.w	284
	dc.w	288
	dc.w	288
	dc.w	292
	dc.w	292
	dc.w	292
	dc.w	296
	dc.w	296
	dc.w	296
	dc.w	296
	dc.w	296
	dc.w	300
	dc.w	300
	dc.w	300
	dc.w	300
	dc.w	300
	dc.w	300
	dc.w	300
	dc.w	300
	dc.w	300
	dc.w	300
	dc.w	300
	dc.w	296
	dc.w	296
	dc.w	296
	dc.w	296
	dc.w	296
	dc.w	292
	dc.w	292
	dc.w	292
	dc.w	288
	dc.w	288
	dc.w	284
	dc.w	284
	dc.w	280
	dc.w	280
	dc.w	276
	dc.w	276
	dc.w	272
	dc.w	268
	dc.w	268
	dc.w	264
	dc.w	260
	dc.w	260
	dc.w	256
	dc.w	252
	dc.w	248
	dc.w	248
	dc.w	244
	dc.w	240
	dc.w	236
	dc.w	232
	dc.w	228
	dc.w	224
	dc.w	220
	dc.w	216
	dc.w	212
	dc.w	208
	dc.w	204
	dc.w	200
	dc.w	196
	dc.w	192
	dc.w	184
	dc.w	180
	dc.w	176
	dc.w	172
	dc.w	168
	dc.w	160
	dc.w	156
	dc.w	152
	dc.w	148
	dc.w	140
	dc.w	136
	dc.w	132
	dc.w	124
	dc.w	120
	dc.w	116
	dc.w	108
	dc.w	104
	dc.w	100
	dc.w	92
	dc.w	88
	dc.w	80
	dc.w	76
	dc.w	72
	dc.w	64
	dc.w	60
	dc.w	52
	dc.w	48
	dc.w	40
	dc.w	36
	dc.w	28
	dc.w	24
	dc.w	16
	dc.w	12
	dc.w	4
	dc.w	0
	dc.w	-4
	dc.w	-12
	dc.w	-16
	dc.w	-24
	dc.w	-28
	dc.w	-36
	dc.w	-40
	dc.w	-48
	dc.w	-52
	dc.w	-60
	dc.w	-64
	dc.w	-72
	dc.w	-76
	dc.w	-80
	dc.w	-88
	dc.w	-92
	dc.w	-100
	dc.w	-104
	dc.w	-108
	dc.w	-116
	dc.w	-120
	dc.w	-124
	dc.w	-132
	dc.w	-136
	dc.w	-140
	dc.w	-148
	dc.w	-152
	dc.w	-156
	dc.w	-160
	dc.w	-168
	dc.w	-172
	dc.w	-176
	dc.w	-180
	dc.w	-184
	dc.w	-192
	dc.w	-196
	dc.w	-200
	dc.w	-204
	dc.w	-208
	dc.w	-212
	dc.w	-216
	dc.w	-220
	dc.w	-224
	dc.w	-228
	dc.w	-232
	dc.w	-236
	dc.w	-240
	dc.w	-244
	dc.w	-248
	dc.w	-248
	dc.w	-252
	dc.w	-256
	dc.w	-260
	dc.w	-260
	dc.w	-264
	dc.w	-268
	dc.w	-268
	dc.w	-272
	dc.w	-276
	dc.w	-276
	dc.w	-280
	dc.w	-280
	dc.w	-284
	dc.w	-284
	dc.w	-288
	dc.w	-288
	dc.w	-292
	dc.w	-292
	dc.w	-292
	dc.w	-296
	dc.w	-296
	dc.w	-296
	dc.w	-296
	dc.w	-296
	dc.w	-300
	dc.w	-300
	dc.w	-300
	dc.w	-300
	dc.w	-300
	dc.w	-300
	dc.w	-300
	dc.w	-300
	dc.w	-300
	dc.w	-300
	dc.w	-300
	dc.w	-296
	dc.w	-296
	dc.w	-296
	dc.w	-296
	dc.w	-296
	dc.w	-292
	dc.w	-292
	dc.w	-292
	dc.w	-288
	dc.w	-288
	dc.w	-284
	dc.w	-284
	dc.w	-280
	dc.w	-280
	dc.w	-276
	dc.w	-276
	dc.w	-272
	dc.w	-268
	dc.w	-268
	dc.w	-264
	dc.w	-260
	dc.w	-260
	dc.w	-256
	dc.w	-252
	dc.w	-248
	dc.w	-248
	dc.w	-244
	dc.w	-240
	dc.w	-236
	dc.w	-232
	dc.w	-228
	dc.w	-224
	dc.w	-220
	dc.w	-216
	dc.w	-212
	dc.w	-208
	dc.w	-204
	dc.w	-200
	dc.w	-196
	dc.w	-192
	dc.w	-184
	dc.w	-180
	dc.w	-176
	dc.w	-172
	dc.w	-168
	dc.w	-160
	dc.w	-156
	dc.w	-152
	dc.w	-148
	dc.w	-140
	dc.w	-136
	dc.w	-132
	dc.w	-124
	dc.w	-120
	dc.w	-116
	dc.w	-108
	dc.w	-104
	dc.w	-100
	dc.w	-92
	dc.w	-88
	dc.w	-80
	dc.w	-76
	dc.w	-72
	dc.w	-64
	dc.w	-60
	dc.w	-52
	dc.w	-48
	dc.w	-40
	dc.w	-36
	dc.w	-28
	dc.w	-24
	dc.w	-16
	dc.w	-12
	dc.w	-4

    IFEQ    STANDALONE
        include     lib/lib.s
    ENDC




	section BSS
pixelPointer		ds.l		1
pixelPointer2		ds.l		1

drawPixelsPointer	ds.l		1
clearPixelsPointer	ds.l		1
x_table_pointer		ds.l		1
y_table_pointer		ds.l		1

    rsreset



    IFEQ    STANDALONE
memBase             ds.b    1024*1024
screenpointer		ds.l	1
screenpointer2		ds.l	1
screen1             ds.l    1
screen2             ds.l    1
    ENDC