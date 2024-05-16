*		TGen - Texture Generator
*		by -XI-/Satantronic
*		version 1   save:0.06c   date:01.12.2004   time:07:49

*		special version for MOAI 96kB intro 


		section text
;--Routines:---------------------------------------

generate_textures:

		lea	dsp_alpha_tex0,a0
		moveq	#3,d0				; kamen_1
		bsr.w	TextureGen
		
		bsr.w	pic_show_box
		
		lea	dsp_alpha_tex1,a0
		moveq	#1,d0				; trava_1
		bsr.w	TextureGen
		
		bsr.w	pic_show_box
		
		lea	dsp_alpha_tex2,a0
		moveq	#4,d0				; kamen_2
		bsr.w	TextureGen
		
		bsr.w	pic_show_box
		
		lea	dsp_alpha_tex3,a0
		moveq	#2,d0				; trava_2
		bsr.w	TextureGen
		
		bsr.w	pic_show_box
		
		lea	dsp_alpha_tex4,a0
		moveq	#0,d0				; okno_1
		bsr.w	TextureGen
		
		bsr.w	pic_show_box
		
		lea	cpu_tex0,a0
		moveq	#8,d0				; drevo_1
		bsr.w	TextureGen
		
		bsr.w	pic_show_box
		
		lea	cpu_tex1,a0
		moveq	#7,d0				; stena_1
		bsr.w	TextureGen
		
		bsr.w	pic_show_box
		
		lea	cpu_tex2,a0
		moveq	#6,d0				; stena_2
		bsr.w	TextureGen
		
		bsr.w	pic_show_box
		
		lea	cpu_tex3,a0
		moveq	#5,d0				; tehla_1
		bsr.w	TextureGen
		
		bsr.w	pic_show_box
		rts

;--Init:-------------------------------------------
TextureGen:	move.l	a0,mikrobuffer
		move.w	#$1234,RandomNum
		
		cmpi.w	#0,d0
		beq	textura0
		cmpi.w	#1,d0
		beq	textura1
		cmpi.w	#2,d0
		beq	textura2
		cmpi.w	#3,d0
		beq	textura3
		cmpi.w	#4,d0
		beq	textura4
		cmpi.w	#5,d0
		beq	textura5
		cmpi.w	#6,d0
		beq	textura6
		cmpi.w	#7,d0
		beq	textura7
		cmpi.w	#8,d0
		beq	textura8
		rts					;error - blby poziadavok

*************** T_Okna1 64x64
textura0:	move.w	#64-1,Tsize_X			;Size of generated texture
		move.w	#64-1,Tsize_Y

		jsr	MemAlloc		

SqrWindow:	move.w	#400,d5				;->RandomCounter
		move.w	#2,SqrSize			;Size of Square
		move.w	#$a514,Color1
		bsr.w	SquareRandom
		move.w	#500,d5				;->RandomCounter
		move.w	#2,SqrSize			;Size of Square
		move.w	#$8410,Color1
		bsr.w	SquareRandom
		move.w	#2,d3				;->FilterCounter
		jsr	RGB_Filter5

		move.w	#$4208,Color1
		move.w	#20,SqrSize
		move.w	#22,d0				;X
		move.w	#12,d1				;Y
		bsr.w	Square
		move.w	#22,d0				;X
		move.w	#32,d1				;Y
		bsr.w	Square

		move.w	#$2110,Color1
		move.w	#18,SqrSize
		move.w	#23,d0				;X
		move.w	#13,d1				;Y
		bsr.w	Square
		move.w	#23,d0				;X
		move.w	#33,d1				;Y
		bsr.w	Square

		move.w	#1,d3				;->FilterCounter
		jsr	RGB_Filter5		

		jsr	TCto8b

		jsr	CopyToMikro256
		jsr	MemDealloc
		rts

*************** T_Trava1 64x64
textura1:	move.w	#64-1,Tsize_X			;Size of generated texture
		move.w	#64-1,Tsize_Y

		jsr	MemAlloc		

		move.w	#50,d7
		move.w	#$c610,Color1
		move.w	#$4708,Color2
		jsr	DoubleRandom
		move.w	#2,d3
		jsr	RGB_Filter5

		move.w	#30,d7
		move.w	#$8610,Color1
		move.w	#$c610,Color2
		jsr	DoubleRandom
		move.w	#2,d3
		jsr	RGB_Filter5

		jsr	TCto8b

		jsr	CopyToMikro256
		jsr	MemDealloc
		rts


*************** T_Trava2 64x64
textura2:	move.w	#64-1,Tsize_X			;Size of generated texture
		move.w	#64-1,Tsize_Y

		jsr	MemAlloc		

		move.w	#80,d7
		move.w	#$2701,Color1
		move.w	#$2701,Color2
		jsr	DoubleRandom
		move.w	#2,d3
		jsr	RGB_Filter5

		move.w	#30,d7
		move.w	#$8610,Color1
		move.w	#$c610,Color2
		jsr	DoubleRandom
		move.w	#2,d3
		jsr	RGB_Filter5

		jsr	TCto8b

		jsr	CopyToMikro256
		jsr	MemDealloc
		rts

*************** T_kamen1 64x64
textura3:	move.w	#64-1,Tsize_X			;Size of generated texture
		move.w	#64-1,Tsize_Y

		jsr	MemAlloc		

		move.w	#5,d7
		move.w	#$ffff,Color1
		move.w	#$c616,Color2
		jsr	DoubleRandom
		move.w	#4,d3
		jsr	RGB_Filter5

		move.w	#20,d7
		move.w	#$ffff,Color1
		move.w	#$ffff,Color2
		jsr	DoubleRandom
		move.w	#2,d3
		jsr	RGB_Filter5

		jsr	TCto8b

		jsr	CopyToMikro256
		jsr	MemDealloc
		rts


*************** T_kamen2 64x64
textura4:	move.w	#64-1,Tsize_X			;Size of generated texture
		move.w	#64-1,Tsize_Y

		jsr	MemAlloc		

		move.w	#5,d7
		move.w	#$ffff,Color1
		move.w	#$e71a,Color2
		jsr	DoubleRandom
		move.w	#1,d3
		jsr	RGB_Filter5

		move.w	#40,d7
		move.w	#$ffff,Color1
		move.w	#$ffff,Color2
		jsr	DoubleRandom
		move.w	#2,d3
		jsr	RGB_Filter5

		jsr	TCto8b

		jsr	CopyToMikro256
		jsr	MemDealloc
		rts



*************** T_tehla1 128x128
textura5:	move.w	#128-1,Tsize_X			;Size of generated texture
		move.w	#128-1,Tsize_Y

		jsr	MemAlloc		

		move.w	#100,d7
		move.w	#$e000,Color1
		move.w	#$f410,Color2
		jsr	DoubleRandom
		move.w	#1,d3
		jsr	RGB_Filter5

		move.w	#80,d7
		move.w	#$f410,Color1
		move.w	#$e000,Color2
		jsr	DoubleRandom
		move.w	#2,d3
		jsr	RGB_Filter5

		jsr	CopyToMikroTC
		jsr	MemDealloc
		rts

*************** T_stena1 128x128
textura6:	move.w	#128-1,Tsize_X			;Size of generated texture
		move.w	#128-1,Tsize_Y

		jsr	MemAlloc
		
		move.w	#200,d5				;->RandomCounter
		move.w	#8,SqrSize			; Size of Square
		move.w	#$a514,Color1
		bsr.w	SquareRandom
		move.w	#2000,d5			;->RandomCounter
		move.w	#2,SqrSize			;Size of Square
		move.w	#$8410,Color1
		bsr	SquareRandom
		move.w	#3,d3				;->FilterCounter
		jsr	RGB_Filter5

		jsr	CopyToMikroTC
		jsr	MemDealloc
		rts

*************** T_stena2 128x128
textura7:	move.w	#128-1,Tsize_X			;Size of generated texture
		move.w	#128-1,Tsize_Y

		jsr	MemAlloc
		
		move.w	#200,d5				;->RandomCounter
		move.w	#8,SqrSize			;Size of Square
		move.w	#$ffff,Color1
		bsr.w	SquareRandom
		move.w	#2000,d5			;->RandomCounter
		move.w	#2,SqrSize			;Size of Square
		move.w	#$8410,Color1
		bsr	SquareRandom
		move.w	#3,d3				;->FilterCounter
		jsr	RGB_Filter5

		jsr	CopyToMikroTC
		jsr	MemDealloc
		rts

*************** T_drevo1 128x128
textura8:	move.w	#128-1,Tsize_X			;Size of generated texture
		move.w	#128-1,Tsize_Y

		jsr	MemAlloc
		
		move.w	#700,d5				;->RandomCounter
		move.w	#4,SqrSize			;Size of Square
		move.w	#$4200,Color1
		bsr.w	SquareRandom
		move.w	#1500,d5			;->RandomCounter
		move.w	#2,SqrSize			;Size of Square
		move.w	#$c610,Color1
		bsr	SquareRandom
		move.w	#3,d3				;->FilterCounter
		jsr	RGB_Filter5

		jsr	CopyToMikroTC
		jsr	MemDealloc
		rts


;----- Routs of Texturegenerator:---------------------

SquareRandom:	*move.w	RandomCounter,d5
.loop1		bsr.s	Random
		move.w	d0,d1
		and.w	Tsize_Y,d1			;and.w	#$ff,d1	;Y
		bsr.s	Random
		and.w	Tsize_X,d0			;and.w	#$ff,d0	;X
		bsr.s	Square
		dbra.w	d5,.loop1
		rts
		

Square:		move.l	T_place,a5
		move.l	T_LineTab,a4	

		move.w	SqrSize,d7
.loop2		move.w	SqrSize,d6
		move.w	d7,d3
		add.w	d1,d3
		and.w	#$ff,d3

.loop1		move.w	d6,d2
		add.w	d0,d2
		and.w	#$ff,d2
		move.l	a5,a6
		add.l	(a4,d3.w*4),a6
		lea	(a6,d2.w*2),a0			;v a0 je adresa pixelu
		move.w	Color1,(a0)

		dbra.w	d6,.loop1
		dbra.w	d7,.loop2
		rts


Random:		move.w	RandomNum,d0
		divu.w	#$8765,d0
		move.w	d0,RandomNum
		rts


DoubleRandom:	move.l	T_place,a5
		move.l	T_LineTab,a4
		
*		move.w	RandomCounter,d7
.loop2		move.w	#63,d6				;move.w	#1000-1,d6

.loop1		bsr.s 	Random
		move.w	d0,d5
		and.w	Tsize_Y,d5			;and.w	#$ff,d5
		bsr.s	Random
		move.w	d0,d4
		and.w	Tsize_X,d4			;and.w	#$ff,d4

		move.l	a5,a6
		add.l	(a4,d5.w*4),a6
		lea	(a6,d4.w*2),a0
		move.w	Color1,(a0)

		bsr.s 	Random
		move.w	d0,d5
		and.w	Tsize_Y,d5			;and.w	#$ff,d5
		bsr.s	Random
		move.w	d0,d4
		and.w	Tsize_X,d4			;and.w	#$ff,d4

		move.l	a5,a6
		add.l	(a4,d5.w*4),a6
		lea	(a6,d4.w*2),a0
		move.w	Color2,(a0)
		
		dbra.w	d6,.loop1
		dbra.w	d7,.loop2
		rts


RGB_Filter5:	move.l	T_place,a5
		move.l	T_LineTab,a4

*		move.w	FilterCounter,d3
.loop3		move.w	Tsize_Y,d7			;move.w	#256-1,d7
.loop2		move.w	Tsize_X,d6			;move.w	#256-1,d6

.loop1		move.w	d7,d5
		sub.w	#1,d5				;posun na pixel o riadok vyssie
		and.w	Tsize_Y,d5			;and.w	#$00ff,d5
		move.l	a5,a6
		add.l	(a4,d5.w*4),a6
		lea	(a6,d6.w*2),a0			;v a0 je adresa 1. pixelu

		move.w	d6,d4
		subq.w	#1,d4				;posun o jeden pixel vlavo
		and.w	Tsize_X,d4			;and.w	#$00ff,d4
		move.l	a5,a6
		add.l	(a4,d7.w*4),a6
		lea	(a6,d4.w*2),a1			;v a1 je adresa 2. pixelu

		move.w	d6,d4
		addq.w	#1,d4				;posun o jeden pixel vpravo
		and.w	Tsize_X,d4			;and.w	#$00ff,d4
		move.l	a5,a6
		add.l	(a4,d7.w*4),a6
		lea	(a6,d4.w*2),a2			;v a2 je adresa 3. pixelu

		move.w	d7,d5
		add.w	#1,d5				;posun na pixel o riadok nizsie
		and.w	Tsize_Y,d5			;and.w	#$00ff,d5
		move.l	a5,a6
		add.l	(a4,d5.w*4),a6
		lea	(a6,d6.w*2),a3			;v a3 je adresa 4. pixelu

		move.l	a5,a6				;aktualny pixel v texture
		add.l	(a4,d7.w*4),a6
		lea	(a6,d6.w*2),a6			;v a6 je adresa 5. pixelu

		move.w	(a0),d0
		and.w	#$f79e,d0			;vyhodim z kazdej RGB zlozky bit s najnizsou vahou
		lsr.w	#1,d0

		move.w	(a1),d1
		and.w	#$f79e,d1
		lsr.w	#1,d1
		add.w	d1,d0
		and.w	#$f79e,d0
		lsr.w	#1,d0
		
		move.w	(a2),d1
		and.w	#$f79e,d1
		lsr.w	#1,d1
		add.w	d1,d0
		and.w	#$f79e,d0
		lsr.w	#1,d0

		move.w	(a3),d1
		and.w	#$f79e,d1
		lsr.w	#1,d1
		add.w	d1,d0
		and.w	#$f79e,d0
		lsr.w	#1,d0

		move.w	(a6),d1
		and.w	#$f79e,d1
		lsr.w	#1,d1
		add.w	d1,d0

		move.w	d0,(a6)

		dbra.w	d6,.loop1
		dbra.w	d7,.loop2
		dbra.w	d3,.loop3
		rts


;----- Routs of TC to 8bit convert:

TCto8b:		move.l	T_place,a0
		move.l	T_Palette,a1
		move.l	T_8b_place,a2
		
.init:		clr.l	d0
		clr.l	d7
		move.w	Tsize_X,d0
		addq.w	#1,d0
		move.w	Tsize_Y,d7
		addq.w	#1,d7
		mulu.w	d0,d7				;lenght of 8b texture		
		subq.l	#1,d7

		move.w	(a0),(a1)
		move.w	#1-1,Pal_cnt			;v palete je urcite aspon jedna farba
				

.loop2		move.w	(a0)+,d4			;natiahne aktualny pixel z TC palety do d6	

		move.w	Pal_cnt,d6			;Find in palette

.loop1		cmp.w	(a1,d6.w*2),d4
		beq	.writeIndex
		dbra.w	d6,.loop1

		addq.w	#1,Pal_cnt			;v existujucej palete som nenasiel, zvecsim paletu o jedna
		move.w	Pal_cnt,d6
		move.w	d4,(a1,d6.w*2)			;a zapisem do palety novu farbu

.writeIndex	move.b	d6,(a2)+
		dbra.w	d7,.loop2
		rts

;----- Other routs: -------------------------------
CopyToMikroTC:	move.l	mikrobuffer,a0
		move.l	T_place,a1
		subq.l	#8,a1
		move.w	#128*128+4-1,d7
		
.loop1		move.w	(a1)+,(a0)+
		dbra.w	d7,.loop1
		rts
		
CopyToMikro256:	move.l	mikrobuffer,a0
		move.l	T_Palette,a1
		subq.l	#8,a1
		move.w	#64*64+512+8-1,d7
		
.loop1		move.b	(a1)+,(a0)+
		dbra.w	d7,.loop1
		rts

MemDealloc:	move.l	memoryplace,-(sp)
		move.w	#$49,-(sp)
		trap	#1
		addq.l	#6,sp
		rts

MemAlloc:	move.w	#3,-(sp)			;mxalloc() - with FastRAM preference
		move.l	#$20200+$400+$300+$10000,-(sp)	;space for 256x256 TC texture + space for file header + $400-space pre zaciatky riadkov
							;+ $200+$100 for Texture palete(+file header) + $10000+$100 space 256x256 8bit texture(+file header)
		move.w	#$44,-(sp)
		trap	#1
		addq.l	#8,sp
		
		tst.l	d0				; ramcheck
		bne.b	.ok				; ok
		move.l	#exit_noram_text,error_adr	; error message
		bra.w	exit				;

.ok:		move.l	d0,memoryplace
		add.l	#$200,d0
		clr.b	d0
		move.l	d0,d1
		move.l	d0,T_place
		add.l	#$20000,d0
		move.l	d0,T_LineTab
		add.l	#$400+$100,d0
		move.l	d0,T_Palette
		add.l	#$200+$000,d0
		move.l	d0,T_8b_place

		move.l	d1,a0				;clear RAM
		move.l	#$20000+$400+$300+$10000,d0

clearRAM:	adda.l	d0,a0
		lsr.l	#2,d0
		subq.l	#1,d0
.clr_loop:	clr.l	-(a0)
		dbra	d0,.clr_loop

		move.l	T_LineTab,a0			;genlinetab
		clr.l	d0
		clr.l	d1
		move.w	Tsize_Y,d7			;move.w	#256-1,d7				
.loop1		move.l	d0,(a0)+
		move.w	Tsize_X,d1
		rol.w	#1,d1
		add.l	d1,d0
		add.l	#2,d0				;korekcia za 2x -1
		dbra.w	d7,.loop1
		rts



;--Data:-------------------------------------------
		section data
		even
RandomNum	dc.w	$1234

		section bss
		even
T_place		ds.l	1
T_LineTab	ds.l	1
T_Palette	ds.l	1
T_8b_place	ds.l	1
Color1		ds.w	1
Color2		ds.w	1
SqrSize		ds.w	1

Counter		ds.w	1
Pal_cnt		ds.w	1

Tsize_X		ds.w	1
Tsize_Y		ds.w	1

memoryplace	ds.l	1
mikrobuffer	ds.l	1


*RandomCounter	ds.w	1
*FilterCounter	ds.w	1

		section	text