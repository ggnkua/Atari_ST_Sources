;#########################################################################
;
; Susie by Creator 1995
; z/y rotation
;
; 256*240 double lined, 50Hz
;
;
;
; LIIKERADAN LASKEMINEN EI TOIMI!
;
; LIIKERATA OTETAAN TAULUKOSTA SERAAVASTI:
;
; X_POSITION.L
; Y_POSITION.L
; KATSELUSUUNTA.W (0-$ffff ON TAYSI YMPYRA)
; KALLISTUSKULMA.W (0-$7fff LAIDASTA LAITAAN, $4000 ON VAAKATASO. TAMAN PITAISI EKASSA
;		    FRAMESSA OLLA $4000...)
;

USERCONTROL=0


susie.run		= 1
susie.superpixels	= 1
susie.alltextures	= 0

susie.maxnumoftextures	= 4
susie.linewidth		= 512*2
susie.screenkorkeus	= 120
susie.texturekorkeus	= 128
susie.texturewidth	= 32

susie.points	= 69

	TEXT

	IFNE	susie.run

	INCLUDE	sqrt.x
	*INCLUDE	a:\sqrt.x


	OPT	d+,c-,p=68030,o+,ow-

	IFEQ	susie.alltextures
memory	= 1700*1024
	ELSE
memory	= 2700*1024
	ENDC

Overdose_Beyond_Braindamage
	*include	a:\freeintc.s
	include	freeintx.s
	even

DEMO:
	move.w	activepoint,d0
	move.l	(activelist,pc,d0.w*4),a0
	jsr	(a0)
	rts


activepoint	dc.w	0	
activelist	
	dc.l	susie.precalc

	DC.L	susie.DSP_LOAD
	DC.L	susie.initwillie

	DC.L	susie.willie
	dc.l	dummy
	dc.l	viimeinen

address.screen1:DC.L	0
address.screen2:DC.L	0

viimeinen
	st 	Space_Pressed
dummy	rts
	ENDC

susie.nullvbl:
	rts

;---------------------------------------------

tuomio_write
	lea	$ffffa202.w,a1	
	lea	$ffffa206.w,a0

.lp	btst	#1,(a1)		
	beq.s	.lp		

	move.l	susie.sin_a,-2(a0)			;skriivaa
	move.l	susie.cos_a,-2(a0)			;skriivaa
	moveq	#0,d0
	move.w	susie.x_pos,d0
	move.l	d0,-2(a0)				;skriivaa
	move.w	susie.z_pos,(a0)			;skriivaa
	move.l	susie.perspektiivivakio(pc),-2(a0)
	move.l	susie.seinakorkeus(pc),-2(a0)
	tst.w	susie.feedmap(pc)
	bne.s	.feed
	move.l	#0,-2(a0)
	rts
.feed:
	clr.w	susie.feedmap
	clr.l	d0
	move.w	susie.number_of_walls,d0
	move.l	d0,-2(a0)
	lea	susie.map,a1
	subq.w	#1,d0
.lp2	
	move.w	4(a1),d1
	sub.w	#$2000,d1
	neg.w	d1
	add.w	#$2000,d1
	move.w	d1,(a0)
	move.w	6(a1),(a0)

	move.w	(a1)+,d1
	sub.w	#$2000,d1
	neg.w	d1
	add.w	#$2000,d1
	move.w	d1,(a0)
	move.w	(a1)+,(a0)
	addq.l	#4,a1

	IFEQ	susie.alltextures
	addq.l	#2,a1
	move.w	#0,(a0)
	ELSE
	move.w	(a1)+,(a0)			;x1 z1 x2 z2 txt
	ENDC
	dbf	d0,.lp2
	rts

susie.perspektiivivakio:
	DC.L	277*256
susie.seinakorkeus
	dc.l	277*128
susie.feedmap:
	DC.W	-1
*tuomio_write
*	lea	$ffffa202.w,a1	
*	lea	$ffffa206.w,a0
*
*.lp	btst	#1,(a1)		
*	beq.s	.lp		
*
*	move.l	susie.sin_a(pc),-2(a0)			;skriivaa
*	move.l	susie.cos_a(pc),-2(a0)			;skriivaa
*	moveq	#0,d0
*	move.w	susie.x_pos(pc),d0
*	move.l	d0,-2(a0)				;skriivaa
*	move.w	susie.z_pos(pc),(a0)			;skriivaa
*	move.w	susie.number_of_walls,d0
*	lea	susie.map,a1
*	move.w	d0,(a0)
*	subq.w	#1,d0
*.lp2	
*	movem.w	(a1)+,d1-5
*	move.w	d1,(a0)
*	move.w	d2,(a0)
*	move.w	d3,(a0)
*	move.w	d4,(a0)
*	move.w	d5,(a0)
*	dbf	d0,.lp2
*	rts
*
*; premodifoi karttaa...
*
susie.precmap:
*	lea	susie.map,a1
*	move.w	susie.number_of_walls,d7
*	subq.w	#1,d7
*.lp1:
*	move.w	4(a1),d0
*	sub.w	#$2000,d0
*	neg.w	d0
*	add.w	#$2000,d0
*	move.w	6(a1),d1
*	move.w	(a1),d2
*	sub.w	#$2000,d2
*	neg.w	d2
*	add.w	#$2000,d2
*	move.w	2(a1),d3
*	IFEQ	susie.alltextures
*	move.w	#0,d4
*	ELSE
*	move.w	8(a1),d4
*	ENDC
*	movem.w	d0-4,(a1)	;x1 z1 x2 z2 txt
*	lea	10(a1),a1
*	dbf	d7,.lp1
	rts

;---------------------------------------------

tuomio_read
	lea	$ffffa202.w,a1	
	lea	$ffffa206.w,a0		;read words..
	move.l	address.freemem(pc),a2
	add.l	#susie.z_buffer,a2

.lp	btst	#0,(a1)		
	beq.s	.lp
	move.w	#384-1,d0
.lp2	
	move.w	(a0),(a2)+
	move.w	(a0),(a2)+
	move.w	(a0),(a2)+		;get z,txt,x_off
	dbf	d0,.lp2
	rts

;---------------------------------------------
;  DSP ROUTINES..
;------------------------------------------------------------------------

susie.DSP_LOAD:
	MOVE.W	#1,-(SP)
	move.l	#(susie.dsp_code-susie.dsp_boot)/3,-(sp)
	move.l	#susie.dsp_boot+9,-(sp)		;devpac56:n headereita
	MOVE.W	#$6e,-(SP)
	TRAP	#14
	LEA	12(SP),SP
	tst.l	d0
	bmi	reset			;dsp melted beyond braindamage..
	tst.l	d1
	bmi	reset			;dsp melted beyond braindamage..

	lea	$ffffa202.w,a1	
	lea	$ffffa204.w,a0
;lataa main rout..
	move	#(susie.dsp_end-susie.dsp_code)/3,d0
.war	btst	#1,(a1)		
	beq.s	.war
	move.l	d0,(a0)			;pituus

	subq.w	#1,d0
	lea	susie.dsp_code+9(pc),a2
.gwar
.quark	btst	#1,(a1)		
	beq.s	.quark
	move.b	(a2)+,1(a0)			;feedaa koodia
	move.b	(a2)+,2(a0)			;feedaa koodia
	move.b	(a2)+,3(a0)			;feedaa koodia
	dbf	d0,.gwar

	move.l	#$babe,d0		;testaa varmuuden vuoksi dsp rutiini..
.lp	btst	#1,(a1)		
	beq.s	.lp		
	move.l	d0,(a0)	
.lp2	btst	#0,(a1)		
	beq.s	.lp2		
	move.l	(a0),d1
	lsl.l	#1,d0
	cmp.l	d0,d1
	bne	reset

	addq.w	#1,activepoint
	rts

susie.dsp_boot
	incbin	dsp\booter.p56
	even
susie.dsp_code
	incbin	dsp\hukka14.p56
	*incbin	a:\hukka14.p56
susie.dsp_end
	even

;------------
tuomioTV:
.HHT	SET 	$fe		; Horizontal Hold Timer
.HBB	SET 	$a2-4		; Horizontal Border Begin
.HBE	SET 	$1+32-4		; Horizontal Border End
.HDB	SET 	$1+32-4		; Horizontal Display Begin
.HDE	SET 	$a2-4		; Horizontal Display End

.HSS	SET 	$d8		; Horizontal Synchro Start

.VFT	SET 	$271		; (31250/Hz!1) ; V FREQUENCY
.VBB	SET 	$249-242	; V BORDER BLANK
.VBE	SET 	$59+8+244	; ($265-$02f)/2 = 283 LINES
.VDB	SET 	$49+8		; V DISPLAY SIZE (256 lines..)
.VDE	SET 	$249-8		; ($237-$057)/2 = 240 LINES
.VSS	SET 	$26b		; V SYNCHRO START (<FREQUENCY!)
.VCLK	SET	$182		; Video Clock
.VCO	SET	$001		; Video Control
.WIDE	set	320		; screen wide (words)
.modulo	set	192		; screen modulo
.VMODE	set	$100		; screen mode (true)

	dc.w	.HHT&$1ff,.HBB&$1ff,.HBE&$1ff,.HDB&$1ff,.HDE&$1ff,.HSS&$1ff
	dc.w	.VFT&$3ff,.VBB&$3ff,.VBE&$3ff,.VDB&$3ff,.VDE&$3ff,.VSS&$3ff
	dc.w	.VCLK&$1ff,.VCO&$00f
	dc.l	.wide,.modulo,.vmode

susie.precalc:
	move.l	address.freemem(pc),d0
	add.l	#susie.ruutu+256,d0
	clr.b	d0
	move.l	d0,address.screen1
	move.l	d0,d1
	add.l	#512*192*2,d1
	move.l	d1,address.screen2

	move.w	#-1,susie.feedmap

	bsr	susie.hdist
	bsr	susie.precmap
	bsr	susie.makefloor
	bsr	susie.createsky
	bsr	susie.prebspline
	bsr	susie.scaletexture

	move.w	#0,susie.liikutus

	addq.w	#1,activepoint
	rts

; willien initointi

susie.initwillie:
*	movec	cacr,d0
*	bset	#0,d0
*	bset	#8,d0
*	movec	d0,cacr

	move.l	address.screen1,a1
	move.l	a1,adr_screen1
	moveq	#0,d1
	move.w	#128*2-1,d6
.ylp1:
	move.w	#512/32-1,d7
.xlp1:
	REPT	16
	move.l	d1,(a1)+
	ENDR
	dbf	d7,.xlp1
	dbf	d6,.ylp1

	move.l	#tuomiotv,pointertv
	jsr	middlesetscreen
	move.w	#$2300,sr

	move.l	#willie_vbl,own_vbl
	move.l	#rastatest,raster_adr
	move.b	#8,raster_control
	move.b	#1,raster_data
	or.l	#$00010001,$fffffa06.w
	or.l	#$00010001,$fffffa12.w

	IFNE	susie.superpixels
	move.w	#$00c7,$ffff8282.w	hht
	move.w	#$00a0-32,$ffff8284.w	hbb
	move.w	#$001f*0,$ffff8286.w	hbe
	move.w	#$02c7-8,$ffff8288.w	hdb
	move.w	#$0096-8,$ffff828a.w	hde
	move.w	#$00aa,$ffff828c.w	hss
	move.w	#$0186,$ffff82c0.w	vclock
	ENDC

	bsr	tuomio_write
	addq.w	#1,activepoint
	rts


; doomien main looppi

susie.willie:
	move.l	address.screen1,d0
	move.l	address.screen2,d1
	move.l	d1,adr_screen1
	move.l	d1,address.screen1
	move.l	d0,address.screen2

	movec	cacr,d0
	bclr	#8,d0
	movec	d0,cacr

	bsr	susie.moveit
	bsr	susie.hdist
	bsr	tuomio_read
	bsr	tuomio_write
	bsr	susie.zrotate
	bsr	susie.scalewalls
	bsr	susie.drawalls

	movec	cacr,d0
	bset	#8,d0
	movec	d0,cacr
	rts
;.tappo
;	move.w	#$40,$ffff8286.w
;	movec	cacr,d0
;	bset	#8,d0
;	movec	d0,cacr
;	rts

willie_vbl:
	move.w	#$00ff,hsyncflag
	move.l	#$0,$ffff9800.w
	move.l	#rastaini,$120.w	;raster_adr
	move.w	firstmodulo(pc),$ffff820e.w

	IFNE	USERCONTROL
	bsr	susie.readkeys
	ENDC

	*move.w	susie.persxsin(pc),d0
	*add.w	#1024,d0
	*move.w	d0,susie.persxsin
	*bsr	xsin
	*ext.l	d1
	*add.l	#227*256,d1
	*move.l	d1,susie.perspektiivivakio

	*move.w	susie.persysin(pc),d0
	*add.w	#673,d0
	*move.w	d0,susie.persysin
	*bsr	xsin
	*ext.l	d1
	*asr.l	#1,d1
	*add.l	#227*128,d1
	*move.l	d1,susie.seinakorkeus

	move.w	susie.dispxbeg(pc),d0
	ble.s	.wok1
	subq.w	#1,d0
	move.w	d0,susie.dispxbeg
.wok1:
	move.w	susie.dispxend(pc),d1
	ble.s	.wok1b
	subq.w	#1,d1
	move.w	d1,susie.dispxend
.wok1b:
	neg.w	d0
*	add.w	#$00a0-32,d0
	add.w	#$a0-8,d0
	move.w	d0,$ffff8284.w	hbb
*	add.w	#$001f*0,d1
	add.w	#$1f+8,d1
	move.w	d1,$ffff8286.w	hbe

	move.w	susie.dispybeg(pc),d2
	ble.s	.wok2
	subq.w	#1,d2
	move.w	d2,susie.dispybeg
.wok2:
	move.w	susie.dispyend(pc),d3
	cmp.w	#6,d3
	ble.s	.wok2b
	subq.w	#1,d3
	move.w	d3,susie.dispyend
.wok2b:
	neg.w	d2

	add.w	d2,d2
	add.w	#$249-8,d2
	move.w	d2,$ffff82a4.w	vbb
	add.w	d3,d3
	add.w	#$49+8,d3
	move.w	d3,$ffff82a6.w	vbe
	rts

susie.dispxbeg:	DC.W	152
susie.dispxend: DC.W	152
susie.dispybeg:	DC.W	123
susie.dispyend: DC.W	123
susie.persxsin:	DC.W	0
susie.persysin:	DC.W	0

	CNOP	0,4

rastaini:
	move.l	#rastatest,$120.w	;raster_adr
	move.w	#$0,hsyncflag
	rte

rastatest2:
	rte
rastatest:
	move.w	#$1234,$ffff820e.w
rastadr:move.l	#$12345678,$120.w
	move.w	#$ff00,hsyncflag
	rte
rastend:
	REPT	119/2
	move.w	#$1234,$ffff820e.w
	move.l	#$12345678,$120.w
	move.w	#$ff00,hsyncflag
	rte

	move.w	#$1234,$ffff820e.w
	move.l	#$12345678,$120.w
	move.w	#$ff00,hsyncflag
	rte
	ENDR
	REPT	128-119
	move.w	#$1234,$ffff820e.w
	move.l	#$12345678,$120.w
	move.w	#$00ff,hsyncflag
	rte
	ENDR

firstmodulo:
	DC.W	0
hsyncflag:
	DC.W	0

turnspd:DC.W	0
suunta	DC.W	0
seinansuunta	DC.W	0
z_spd:	DC.L	0
x_spd:	DC.L	0


susie.moveit:
	lea	susie.liikku,a0
	move.w	susie.liikutus,d0
	add.w	d0,a0
	add.w	#3*4,d0
;	cmp.w	#3*4*4*16,d0
	cmp.w	#3*4*(susie.points)*16/4,d0
	blt.s	.okqq
;	st	space_pressed
	move.l	#.dummy,own_vbl
	addq.w	#1,activepoint

.dummy	rts
	
.okqq:
	move.w	d0,susie.liikutus

	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	d0,susie.x_pos
	move.l	d1,susie.z_pos
	move.w	(a0)+,d0
	move.w	d0,d6
	move.w	d0,seinansuunta
	bsr	xsin
	ext.l	d1
	lsl.l	#8,d1
	move.l	d1,susie.sin_a
	move.w	d6,d0
	bsr	xcos
	ext.l	d1
	lsl.l	#8,d1
	move.l	d1,susie.cos_a
	move.w	(a0)+,d0
	sub.w	#$4000,d0
	move.w	d0,susie.kalsin
	rts


*	move.l	address.freemem,a0
*	add.l	#susie.liikerata,a0
*	move.w	susie.liikepos(pc),d0
*	lea	(a0,d0.w*8),a0
*	addq.w	#3,d0
*	cmp.w	#(susie.points-4)*64,d0
*	blt.s	.posok
*	sub.w	#(susie.points-4)*64,d0
*.posok:
*	move.w	d0,susie.liikepos
*	move.l	(a0)+,d0
*	move.l	d0,susie.x_pos
*	move.l	(a0)+,d1
*	move.l	d1,susie.z_pos
*	neg.l	d0
*	neg.l	d1
*	move.l	address.freemem,a0
*	add.l	#susie.liikerata2,a0
*	move.w	susie.liikepos(pc),d2
*	lea	(a0,d2.w*8),a0
*	add.l	(a0)+,d0	; erotus seuraavaan pisteeseen
*	add.l	(a0)+,d1
*	neg.l	d0
**rts



*	move.w	suunta(pc),d0
*	add.w	#192,d0
*	move.w	d0,suunta
*	move.w	d0,susie.kalsin
*	move.w	d0,d7
*	bsr	xsin
*	move.w	d1,seinansuunta
*	move.w	d1,d0
*	move.w	d0,d7
*	bsr	xsin
*
*	ext.l	d1
*	move.l	d1,d2
*	lsl.l	#8,d2
*	move.l	d2,susie.sin_a
*	move.l	d1,d6
*	move.w	d7,d0
*	bsr	xcos
*	ext.l	d1
*	move.l	d1,d0
*	lsl.l	#8,d0
*	move.l	d0,susie.cos_a
* rts
	OPT p=68882

	fmove.l	d0,fp2
	fmove.l	d1,fp3
	move.l	d0,d2
	move.l	d1,d3
	muls	d0,d0
	muls	d1,d1
	add.l	d0,d1
	sqrt	d1,d0,d3
	tst.w	d1
	bne.s	.okie
	move.l	#$ff000000,$ffff9800.w
	bra	.nope
.okie:
	fmove.l	d1,fp1

	fdiv	fp1,fp2
	fasin	fp2
	fmovecr	#0,fp5
	fadd	fp5,fp5
	fdiv	fp5,fp2
	fmul.l	#1<<16,fp2
	fmove.w	fp2,d4
	move.w	d4,d0
	move.w	suunta(pc),d5
	move.w	d4,suunta
	sub.w	d5,d4
	lsl.w	#4,d4
 clr.w	d4
	move.w	d4,susie.kalsin

	move.w	d0,d6
	bsr	xsin
	and.l	#$ffff,d1
	lsl.l	#8,d1
	move.l	d1,susie.sin_a
	move.l	d6,d0
	bsr	xcos
	and.l	#$ffff,d1
	lsl.l	#8,d1
	move.l	d1,susie.cos_a
.nope:
	rts

*	bfffo	d0{0:31},d2
*	bfffo	d1{0:31},d3
*	cmp.w	d2,d3
*	ble.s	.joude
*	exg.l	d2,d3
*.joude:
*	sub.w	#8,d3
*	bge.s	.joude2
*	neg.w	d3
*	ext.l	d3
*	asr.l	d3,d0
*	asr.l	d3,d1
*.joude2:
 
	move.l	d0,d2		; a
	move.l	d1,d3		; b
	asr.l	#8,d0
	asr.l	#8,d1
	muls	d0,d0		; aý
	muls	d1,d1		; bý
	asr.l	#8,d0
	asr.l	#8,d1
	add.l	d0,d1		; cý
	SQRT	d1,d0,d4	; c
	and.l	#$ffff,d1
	bne.s	.okh
	moveq	#1,d1
.okh:
	lsl.l	#4,d2
	lsl.l	#4,d3
	divs.l	d1,d2	; a/c = Sin alpha
	divs.l	d1,d3	; b/c = Cos alpha
	lsl.l	#7,d2
	lsl.l	#7,d3
	and.l	#$ffffff,d2
	and.l	#$ffffff,d3
	move.l	d2,susie.sin_a
	move.l	d3,susie.cos_a
	rts

*	move.l	d0,d2		; a
*	move.l	d1,d3		; b
*	asr.l	#8,d0
*	asr.l	#8,d1
*	muls.w	d0,d0		; aý
*	muls.w	d1,d1		; bý
*	asr.l	d0
*	asr.l	d1
*	add.l	d0,d1
*	SQRT	d1,d0,d4	; c
*	and.l	#$ffff,d1
*	bne.s	.ok
*	moveq	#1,d1
*.ok:
*	lsl.l	#8,d2
*	lsl.l	#8,d3
*	divs.l	d1,d2	; a/c = Sin alpha
*	divs.l	d1,d3	; b/c = Cos alpha
*	move.l	d2,susie.sin_a
*	move.l	d3,susie.cos_a

*	swap	d0
*	swap	d1
*
*	divu	d0,d1		; tan Alpha
*
*	move.l	oldx(pc),d2
*	move.l	d0,oldx
*	sub.l	d2,d0		; Dx
*	bpl.s	.xok1
*	neg.l	d0
*.xok1:
*	move.l	oldz(pc),d2
*	move.l	d1,oldz
*	sub.l	d2,d1		; Dz
*	bpl.s	.zok1
*	neg.l	d1
*.zok1:
*
*	asr.l	#8,d0
*	asr.l	#8,d1
*	move.l	d0,d2
*	mulu.l	d2,d2
*	move.l	d1,d3
*	mulu.l	d3,d3
*	add.l	d2,d3
*	sqrt	d3		; c
* ljdfcvkl
	rts

susie.liikepos:
	DC.W	0

susie.scalewalls:
	move.l	address.freemem,d0
	add.l	#susie.htab+4,d0
	and.w	#-4,d0
	move.l	d0,htbaddr+2
	move.l	d0,a5
	lea	512*8-80*8(a5),a5

	move.w	susie.skew(pc),d0
	move.w	d0,d1
	ext.l	d1			; y-offsetin muutos/pystyline
	move.l	d1,a4
	muls	#-192,d0
	asr.l	d0
	move.l	d0,d4 

	move.l	address.freemem(pc),a6
	add.l	#susie.z_buffer,a6
	addq.l	#6,a6
	move.w	susie.cosalpha(pc),d5		; scalea korkeus z-rotaation mukaan
	move.w	#192-1,d7

 move.l	address.screen1,d0
 add.l	#susie.linewidth*2+0*susie.linewidth*susie.screenkorkeus/2-96+32+8,d0

 move.l	address.freemem,a1
 add.l	#susie.sky+15*2,a1
 move.w	seinansuunta(pc),d6
 lsr.w	#7,d6
 and.w	#$ff,d6
 mulu	#320,d6
 asr.l	#8,d6
 sub.w	#320,d6
 neg.w	d6
 muls	#80*2,d6
 add.l	d6,a1

 move.l	#$00020002,$ffff8a20.w
 move.l	#-1,$ffff8a28.w
 move.w	#-1,$ffff8a2c.w
 move.l	#2<<16+((susie.linewidth-2)&$ffff),$ffff8a2e.w
 move.w	#$0203,$ffff8a3a.w

	moveq	#2,d1
	swap	d1
.slp1:
	move.w	(a6)+,d6		; seinan korkeus
	cmp.w	#$7f,d6
	ble.s	.okie
	move.w	#$7f,d6
.okie:
	muls	d5,d6			; scalea korkeus z-rotaation mukaan
	lsr.l	#7,d6
	move.w	d6,(a5)+		; korkeus
	asr.w	d6

	move.w	d6,d1			; seinan korkeus/2
	sub.w	#susie.screenkorkeus/2+2,d1	; taivaan korkeus ilman kallistusta
	neg.w	d1

	neg.w	d6
	lsl.w	#8,d6
	add.w	d4,d6
	move.w	d6,(a5)+			; y-alkukohta

	move.w	(a6)+,d6			; texture id
	move.w	(a6)+,d2			; texture offset

	move.l	d4,d3
	asr.l	#8,d3				; kallistus
	add.w	d3,d1				; taivaan korkeus kallistuksen kanssa
	tst.w	d1
	ble.s	.nooon
	add.w	d3,d3
	ext.l	d3
	neg.l	d3
	add.l	a1,d3
	move.l	d0,a0

	move.l	d3,$ffff8a24.w
	move.l	a0,$ffff8a32.w
	move.l	d1,$ffff8a36.w
	move.w	#$c040,$ffff8a3c.w
.nooon:

	lsl.w	#7,d6
	and.w	#$1f,d2			; Jostain syysta texturen x-position on
					; valilla 1-32 eika 0-31!!!
	or.w	d2,d6
	addq.l	#6,a6
	move.w	d6,(a5)+
	move.w	d4,(a5)+
	add.l	a4,d4
.done:
 lea	80*2(a1),a1
 addq.l	#4,d0
	dbf	d7,.slp1
	rts

; Piirra seinat


susie.hdist:
	move.w	susie.skew(pc),d0
	move.w	d0,d1
	asr.w	#1,d0
	neg.w	d0
	swap	d1
	clr.w	d1
	asr.l	#8,d1			; x-offsetin muutos/vaakaline
	move.w	d1,a5
	move.l	a5,d4
	neg.l	d4
	lea	rastatest(pc),a0
	lea	rastadr+2(pc),a1
	move.w	#192,d0			; modulo
	moveq	#127-1,d7
	add.l	d4,d4
	move.l	d4,d1
	lsl.l	#6-1,d1
	swap	d1
	add.w	d0,d1
	move.w	d1,firstmodulo
	clr.l	d1
	clr.l	d2
.lp1:
	swap	d1
	swap	d2
	sub.w	d1,d2
	add.w	d0,d2

	move.w	d2,2(a0)
	lea	rastend-rastatest(a0),a0
	move.l	a0,(a1)
	lea	rastend-rastatest(a1),a1
	swap	d1
	move.l	d1,d2
	add.l	d4,d1
	dbf	d7,.lp1
	rts


; pyorita z-akselin ympari

susie.zangle:	DC.W	0
susie.adz:	DC.W	1
susie.cosalpha:	DC.W	0
susie.skew:	DC.W	0
susie.kalsin:	DC.W	0

susie.zrotate:
	move.w	susie.kalsin(pc),d0
	bsr	xsin
	asr.w	#3,d1
 move.w	d1,d0
 asr.w	#2,d0
 sub.w	d0,d1
	move.w	d1,d7
	move.w	d1,d0
	bsr	xcos
	asr.w	#8,d1
	move.w	d1,susie.cosalpha
	move.w	d7,d0
	bsr	xsin
	asr.w	#8,d1
	add.w	d1,d1
	move.w	d1,susie.skew
	rts
	

basen	=	$36

susie.drawalls:

; make halftone table and init blitter registers

	lea	$ffff8a00+basen.w,a0
	lea	susie.floor,a2
	lea	32-basen(a0),a1
	moveq	#16-1,d7
.lp1:
	move.w	(a2)+,-(a1)
	dbf	d7,.lp1
	move.l	#2<<16+2,$20-basen(a0)
	moveq	#-1,d1
	move.l	d1,$28-basen(a0)
	move.w	d1,$2c-basen(a0)
	move.w	#$0103,$3a-basen(a0)

	move.l	address.screen1,d3
	add.l	#susie.linewidth*4+susie.linewidth*susie.screenkorkeus/2-96+32+8,d3 +128,d3

htbaddr:move.l	#$12345678,a6
	lea	512*8-80*8(a6),a6
	move.w	#192-1,d7
	move.l	(a6)+,d2
	move.w	(a6)+,d0	; texture xpos
	move.w	(a6)+,d5
	move.l	#2<<16+((susie.linewidth-2)&$ffff),a4
	move.l	#-susie.linewidth<<16+((-susie.linewidth)&$ffff),a5
	move.l	a4,$2e-basen(a0)
	move.l	#$0203c040,a2
	move.w	#$0203,$3a-basen(a0)
	bra.w	cc

	CNOP	0,4
aa:
susie.waitblit:
	tst.w	$38-basen(a0)
	beq.s	nokia
	move.b	#$80,$3c-basen(a0)
	bra.s	susie.waitblit
nokia:
	rts
cc:
.xlp1:
	move.w	d2,a3		; y-alkukohta << 8
	move.l	a3,d6		; extendattuna
	clr.b	d6
	lsl.l	#2,d6		; << 2... linen leveys 1024 bytea
	add.l	d3,d6		; screen address
	addq.l	#4,d3

	move.w	#2,d2
	swap	d2		
	move.l	d2,d4		; korkeus
	move.w	d0,d5
	and.w	#$7f,d0
	mulu	d4,d0		; seinan korkeus*texture xpos
	add.l	d0,d0
	move.w	d4,d1
	and.w	#-128,d5
	or.w	d5,d4
	neg.w	d4
	asr.w	d1		; seinan korkeus/2
	sub.w	#64,d1
	neg.w	d1

	swap	d1
	move.l	d1,d5
	move.w	#4,d1

	swap	d1
	addq.w	#3,d1
	asr.w	#2,d1

	clr.w	d5
	asr.l	#6,d5
	neg.l	d5
	add.l	d6,d5			; destination address for roof
	add.l	#64*2*susie.linewidth-512*2,d5

	lea	susie.textureposit+128*4*susie.maxnumoftextures,a3

.hlp:
	tst.w	hsyncflag(pc)
	beq.s	.hlp
	sf	hsyncflag	; Clearaa ylempi byte

; floor [1/2]

	move.l	a5,$2e-basen(a0)
	move.l	d5,$32-basen(a0)
	addq.l	#2,d5
	move.l	d1,$36-basen(a0)
	move.l	#$0103c000,$3a-basen(a0)
	nop

; floor [2/2]

	move.l	d1,$36-basen(a0)
	move.l	d5,$32-basen(a0)
	move.w	#$c000,$3c-basen(a0)
	add.l	(a3,d4.w*4),d0	; scaletun texturen alkuosoite
	nop

; wall

	move.l	d2,d4
	move.l	(a6)+,d2
	move.l	d0,a1
	move.w	(a6)+,d0
	move.w	(a6)+,d5

	tst.w	d4
	beq.s	.nollura
	move.l	a1,$24-basen(a0)
	move.l	d4,$36-basen(a0)
	move.l	a4,$2e-basen(a0)
	move.l	d6,$32-basen(a0)
	move.l	a2,$3a-basen(a0)
.nollura:
	dbf	d7,.xlp1
	rts

bb:
	IFGT	(bb-aa)-(200)
	FAIL
	ENDC


; prescalea tekstuuri wall-rutiinia varten

susie.scaletexture:
	bsr	susie.makeskyfade

	move.l	address.freemem,a2
	add.l	#susie.textures,a2

	move.l	#dualtexturescaletab1,address.dualtexturescaletab
	lea	susie.textureposit+128*4*3,a1
	move.l	#susie.pic1+14,susie.ctexture
	bsr	susie.scale
	IFEQ	susie.alltextures
	rts
	ENDC
	move.l	#dualtexturescaletab2,address.dualtexturescaletab
	lea	susie.textureposit+128*4*2,a1
	move.l	#susie.pic2+14,susie.ctexture
	bsr	susie.scale
	lea	susie.textureposit+128*4*1,a1
	move.l	#susie.pic3+14,susie.ctexture
	bsr	susie.scale
	lea	susie.textureposit,a1
	move.l	#susie.pic4+14,susie.ctexture

susie.scale:
	move.w	#28,.blurcnt
	move.l	a2,(a1)+
	move.w	#127,d6			; seinan korkeus
	move.w	#128-2,d7		; korkeuksien maara
.sizelp1:
	swap	d7
	move.w	(scaletab,d6.l*2),d1
	sub.w	#128-2,d1
	neg.w	d1
	move.w	#197,d0
	mulu	d1,d0
	add.l	d0,d0
	move.l	d0,a3
	move.w	#184,d0
	mulu	d1,d0
	asr.l	#4,d0
	move.w	d0,a4
	move.w	#167,d0
	mulu	d1,d0
	asr.l	#7,d0
	move.w	d0,a5

	move.l	susie.ctexture(pc),a6
	moveq	#susie.texturewidth-1,d4
	move.l	#susie.texturekorkeus<<16,d0
	clr.l	d1
	move.l	a2,(a1)+
	move.l	a1,-(sp)
	divu.l	d6,d1:d0		; texture y step
	cmp.w	#127,([address.dualtexturescaletab],d6.l*2)
	beq.s	.nodouble
	bsr	doubletexture
	bra.s	.nosingle
.nodouble:
	bsr	singletexture
.nosingle:
	subq.l	#1,d6
	swap	d7
	move.w	d7,d2
	and.w	#$3,d2
	bne.s	.ok
	move.w	.blurcnt,d2
	beq.s	.ok
	subq.w	#1,d2
	move.w	d2,.blurcnt
	movem.l	d0-7/a0-6,-(sp)
	bsr	blurtexture
	movem.l	(sp)+,d0-7/a0-6
.ok:
	move.l	(sp)+,a1
	dbf	d7,.sizelp1
	rts
.blurcnt:DC.W	0

singletexture:
	clr.l	d1
	move.w	d6,d5			; linen korkeus
	subq.w	#1,d5
	move.l	a2,-(sp)
.ylp1:
	move.l	d1,d2
	swap	d2			; texture y line
	ext.l	d2
	move.l	d2,d3
	add.l	d2,d2
	add.l	d3,d2			; *3
	lsl.l	#5,d2			; *linen leveys
	lea	(a6,d2.l),a0

	move.w	(scaletab,d6.l*2),d7
	clr.w	d2
	move.b	(a0)+,d2
	mulu	d7,d2
	add.l	d2,d2
	add.l	a3,d2
	and.w	#$f800,d2

	clr.w	d3
	move.b	(a0)+,d3
	mulu	d7,d3
	lsr.l	#4,d3
	add.l	a4,d3
	and.w	#$7e0,d3
	or.w	d3,d2

	clr.w	d3
	move.b	(a0)+,d3
	mulu	d7,d3
	lsr.l	#7,d3
	add.l	a5,d3
	and.w	#$f8,d3
	lsr.w	#3,d3
	or.w	d3,d2
	move.w	d2,(a2)+
	add.l	d0,d1			; texture y pos
	dbf	d5,.ylp1

******* ALALAIDAN EKA BLURLINE *************

	lsr.w	#2,d2
	and.w	#$3800!$1e0!$7,d2
	lea	susie.floor+15*2,a1
	move.w	d6,d3
	asr.w	#3,d3
	neg.w	d3
	move.w	(a1,d3.w*2),d3
	lsr.w	d3
	and.w	#$7800!$3e0!$f,d3
	add.w	d3,d2
	lsr.w	d3
	and.w	#$3800!$1e0!$7,d3
	add.w	d3,d2
	move.w	d2,-2(a2)

******* YLALAIDAN EKA BLURLINE *************
 
	lea	susie.skyshade+63*2(pc),a1
	move.w	d6,d3
	asr.w	#1,d3
	neg.w	d3
	move.w	(a1,d3.w*2),d3
	lsr.w	d3
	and.w	#$7800!$3e0!$f,d3
	move.l	(sp),a1
	move.w	(a1),d2
	lsr.w	#2,d2
	and.w	#$3800!$1e0!$7,d2
	add.w	d3,d2
	lsr.w	d3
	and.w	#$3800!$1e0!$7,d3
	add.w	d3,d2
	move.w	d2,(a1)

******* ALALAIDAN TOINEN BLURLINE *************

	move.w	-4(a2),d2
	lsr.w	d2
	and.w	#$7800!$3e0!$f,d2
	move.w	d2,d3
	lsr.w	d3
	and.w	#$3800!$1e0!$7,d3
	add.w	d3,d2
	lea	susie.floor+15*2,a1
	move.w	d6,d3
	asr.w	#3,d3
	neg.w	d3
	move.w	(a1,d3.w*2),d3
	lsr.w	#2,d3
	and.w	#$3800!$1e0!$7,d3
	add.w	d3,d2
	move.w	d2,-4(a2)

******* YLALAIDAN TOKA BLURLINE *************
 
	lea	susie.skyshade+63*2(pc),a1
	move.w	d6,d3
	asr.w	#1,d3
	neg.w	d3
	move.w	(a1,d3.w*2),d3
	lsr.w	#2,d3
	and.w	#$3800!$1e0!$7,d3
	move.l	(sp)+,a1
	move.w	2(a1),d2
	lsr.w	d2
	and.w	#$7800!$3e0!$f,d2
	add.w	d2,d3
	lsr.w	d2
	and.w	#$3800!$1e0!$7,d2
	add.w	d2,d3
	move.w	d3,2(a1)

	addq.l	#3,a6
	dbf	d4,singletexture
	rts

doubletexture:
	clr.l	d1
	move.w	d6,d5			; linen korkeus
	subq.w	#1,d5
	move.l	a2,-(sp)
.ylp1:
	move.l	d1,d2
	move.l	d1,-(sp)	
	swap	d2			; texture y line
	ext.l	d2
	move.l	d2,d3
	add.l	d2,d2
	add.l	d3,d2			; *3
	lsl.l	#5,d2			; *linen leveys
	move.l	a6,a0
	add.l	d2,a0
	lea	32*3*128+14(a0),a1
	move.w	(scaletab,d6.l*2),d7
	clr.w	d2
	move.b	(a0)+,d2
	move.w	(dualtexturescaletab1,d6.l*2),d1
	mulu	d1,d2
	sub.w	#128,d1
	neg.w	d1
	clr.w	d3
	move.b	(a1)+,d3
	mulu	d1,d3
	add.w	d3,d2
	asr.l	#7,d2
	mulu	d7,d2
	add.l	d2,d2
	add.l	a3,d2
	and.w	#$f800,d2
	move.w	d2,(a2)

	clr.w	d3
	move.b	(a0)+,d3
	move.w	(dualtexturescaletab1,d6.l*2),d1
	mulu	d1,d3
	sub.w	#128,d1
	neg.w	d1
	clr.w	d2
	move.b	(a1)+,d2
	mulu	d1,d2
	add.w	d2,d3
	asr.l	#7,d3
	mulu	d7,d3
	lsr.l	#4,d3
	add.l	a4,d3
	and.w	#$7e0,d3
	or.w	d3,(a2)

	clr.w	d3
	move.b	(a0)+,d3
	move.w	(dualtexturescaletab1,d6.l*2),d1
	mulu	d1,d3
	sub.w	#128,d1
	neg.w	d1
	clr.w	d2
	move.b	(a1)+,d2
	mulu	d1,d2
	add.w	d2,d3
	asr.l	#7,d3
	mulu	d7,d3
	lsr.l	#7,d3
	add.l	a5,d3
	and.w	#$f8,d3
	lsr.w	#3,d3
	or.w	d3,d2
	move.w	(a2),d2
	or.w	d3,d2
	move.w	d2,(a2)+
	move.l	(sp)+,d1
	add.l	d0,d1			; texture y pos
	dbf	d5,.ylp1

******* ALALAIDAN EKA BLURLINE *************

	lsr.w	#2,d2
	and.w	#$3800!$1e0!$7,d2
	lea	susie.floor+15*2,a1
	move.w	d6,d3
	asr.w	#3,d3
	neg.w	d3
	move.w	(a1,d3.w*2),d3
	lsr.w	d3
	and.w	#$7800!$3e0!$f,d3
	add.w	d3,d2
	lsr.w	d3
	and.w	#$3800!$1e0!$7,d3
	add.w	d3,d2
	move.w	d2,-2(a2)

******* YLALAIDAN EKA BLURLINE *************
 
	lea	susie.skyshade+15*2(pc),a1
	move.w	d6,d3
	asr.w	#3,d3
	neg.w	d3
	move.w	(a1,d3.w*2),d3
	lsr.w	d3
	and.w	#$7800!$3e0!$f,d3
	move.l	(sp),a1
	move.w	(a1),d2
	lsr.w	#2,d2
	and.w	#$3800!$1e0!$7,d2
	add.w	d3,d2
	lsr.w	d3
	and.w	#$3800!$1e0!$7,d3
	add.w	d3,d2
	move.w	d2,(a1)

******* ALALAIDAN TOINEN BLURLINE *************

	move.w	-4(a2),d2
	lsr.w	d2
	and.w	#$7800!$3e0!$f,d2
	move.w	d2,d3
	lsr.w	d3
	and.w	#$3800!$1e0!$7,d3
	add.w	d3,d2
	lea	susie.floor+15*2,a1
	move.w	d6,d3
	asr.w	#3,d3
	neg.w	d3
	move.w	(a1,d3.w*2),d3
	lsr.w	#2,d3
	and.w	#$3800!$1e0!$7,d3
	add.w	d3,d2
	move.w	d2,-4(a2)

******* YLALAIDAN TOKA BLURLINE *************
 
	lea	susie.skyshade+15*2(pc),a1
	move.w	d6,d3
	asr.w	#3,d3
	neg.w	d3
	move.w	(a1,d3.w*2),d3
	lsr.w	#2,d3
	and.w	#$3800!$1e0!$7,d3
	move.l	(sp)+,a1
	move.w	2(a1),d2
	lsr.w	d2
	and.w	#$7800!$3e0!$f,d2
	add.w	d2,d3
	lsr.w	d2
	and.w	#$3800!$1e0!$7,d2
	add.w	d2,d3
	move.w	d3,2(a1)

	addq.l	#3,a6
	dbf	d4,doubletexture
	rts

xtratexture:
	DC.L	0

blurpix:MACRO
	REPT	3
	clr.w	d0
	move.b	\1(a0),d0
	clr.w	d1
	move.b	\2(a0),d1
	add.w	d1,d0
	move.b	\3(a0),d1
	add.w	d1,d0
	move.b	\4(a0),d1
	add.w	d1,d0
	asr.w	#3,d0
	move.b	(a0)+,d1
	add.w	d1,d0
	asr.w	d1
	add.w	d1,d0
	asr.w	d0
	move.b	d0,(a1)+
	ENDR
	ENDM

blurtexture:
	move.l	susie.ctexture(pc),a0
	move.l	address.screen1,a1

	BLURPIX	127*32*3,32*3,31*3,3
	moveq	#30/2-1,d7
.xlpupper:
	BLURPIX	127*32*3,32*3,-3,3
	BLURPIX	127*32*3,32*3,-3,3
	dbf	d7,.xlpupper
	BLURPIX	127*32*3,32*3,-3,-31*3

	moveq	#126-1,d6
.ylp1:
	BLURPIX	-32*3,32*3,31*3,3
	moveq	#30/3-1,d7
.xlp1:
	BLURPIX	-32*3,32*3,-3,3
	BLURPIX	-32*3,32*3,-3,3
	BLURPIX	-32*3,32*3,-3,3
	dbf	d7,.xlp1
	BLURPIX	-32*3,32*3,-3,-31*3
	dbf	d6,.ylp1

	BLURPIX	-32*3,-127*32*3,31*3,3
	moveq	#30/2-1,d7
.xlplower:
	BLURPIX	-32*3,-127*32*3,-3,3
	BLURPIX	-32*3,-127*32*3,-3,3
	dbf	d7,.xlplower
	BLURPIX	-32*3,-127*32*3,-3,-31*3

	move.l	address.screen1,a0
	move.l	susie.ctexture(pc),a1
	move.w	#128*32/4-1,d7
.lp1:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbf	d7,.lp1
	rts

susie.makeskyfade:
	move.l	address.freemem(pc),a0
	add.l	#susie.sky+16*2,a0
	lea	susie.skyshade(pc),a1
	moveq	#64-1,d7
.ylp1:
	move.w	80*2*80(a0),d1
	move.w	80*2*160(a0),d2
	move.w	(80*2*240,a0.l),d3
	move.w	(a0)+,d0
	lsr.w	#2,d0
	lsr.w	#2,d1
	lsr.w	#2,d2
	lsr.w	#2,d3
	and.w	#$3800!$1e0!$7,d0
	and.w	#$3800!$1e0!$7,d1
	and.w	#$3800!$1e0!$7,d2
	and.w	#$3800!$1e0!$7,d3
	add.w	d1,d0
	add.w	d2,d0
	add.w	d3,d0
	move.w	d0,(a1)+
	dbf	d7,.ylp1
	rts

susie.ctexture:
	DC.L	0

address.dualtexturescaletab:
	DC.L	0

dualtexturescaletab1:
	DCB.W	128-31,127
n	SET	127
	REPT	31
	DC.w	n
n	SET	n-4
	ENDR

dualtexturescaletab2:
	DCB.W	128,127

scaletab:
n	SET	0
	REPT	63
	DC.W	n
n	SET	n+2
	ENDR
	REPT	65
	DC.W	n
	ENDR


susie.skyshade:
	DS.W	64

susie.createsky:
	lea	susie.skygfx,a0
	move.l	address.screen1,a1
	move.w	#80-1,d6
.ylp1:
	move.w	#320-1,d7
.xlp1:
	move.w	(a0)+,(a1)
	lea	80*2(a1),a1
	dbf	d7,.xlp1
	sub.l	#80*2*320-2,a1
	dbf	d6,.ylp1

	move.l	address.screen1,a0
	move.l	address.freemem,a1
	add.l	#susie.sky,a1
	move.w	#320-1,d6
.ylp1b:
	move.w	#80-1,d7
.xlp1b:
	move.w	(a0)+,d0
	move.w	d0,(a1)+
	dbf	d7,.xlp1b
	dbf	d6,.ylp1b

	move.l	address.freemem,a0
	add.l	#susie.sky,a0
	move.w	#512-320-1,d6
.ylp1c:
	move.w	#80-1,d7
.xlp1c:
	move.w	(a0)+,d0
	move.w	d0,(a1)+
	dbf	d7,.xlp1c
	dbf	d6,.ylp1c
	rts

; -----	prelaske liikerata ---------------------

	;Dc.w	0

susie.splinecoords:
	Dc.w	340,960
	Dc.w	380,880
	Dc.w	360,800
	Dc.w	280,720
	Dc.w	220,680
	Dc.w	160,640
	Dc.w	140,560
	Dc.w	140,460
	Dc.w	160,400
	Dc.w	200,480
	Dc.w	200,580
	Dc.w	240,660
	Dc.w	300,700
	Dc.w	360,680
	Dc.w	380,600
	Dc.w	340,520
	Dc.w	280,460
	Dc.w	260,400
	Dc.w	320,320
	Dc.w	400,320
	Dc.w	520,340
	Dc.w	580,380
	Dc.w	580,520
	Dc.w	540,600
	Dc.w	520,680
	Dc.w	480,680
	Dc.w	440,660
	Dc.w	420,640
	Dc.w	380,680
	Dc.w	380,760
	Dc.w	420,800
	Dc.w	480,840
	Dc.w	560,860
	Dc.w	620,820
	Dc.w	700,780
	Dc.w	740,740
	Dc.w	760,680
	Dc.w	780,600
	Dc.w	800,540
	Dc.w	820,460
	Dc.w	800,380
	Dc.w	740,340
	Dc.w	640,340
	Dc.w	500,340
	Dc.w	420,340
	Dc.w	400,320
	Dc.w	400,260
	Dc.w	440,200
	Dc.w	500,160
	Dc.w	520,200
	Dc.w	480,240
	Dc.w	440,260
	Dc.w	420,300
	Dc.w	360,380
	Dc.w	360,440
	Dc.w	340,500
	Dc.w	340,560
	Dc.w	340,640
	Dc.w	380,700
	Dc.w	400,740
	Dc.w	460,800
	Dc.w	500,820
	Dc.w	560,860
	Dc.w	580,900
	Dc.w	560,960
	Dc.w	480,1000
	Dc.w	360,1000
	Dc.w	340,960
	Dc.w	380,880
	Dc.w	360,800

susie.splinecoords2:
	Dc.w	340,940
	Dc.w	380,860
	Dc.w	340,780
	Dc.w	260,700
	Dc.w	200,660
	Dc.w	140,620
	Dc.w	140,540
	Dc.w	140,440
	Dc.w	160,420
	Dc.w	180,480
	Dc.w	220,620
	Dc.w	260,660
	Dc.w	320,680
	Dc.w	360,660
	Dc.w	380,580
	Dc.w	320,500
	Dc.w	260,440
	Dc.w	260,380
	Dc.w	340,320
	Dc.w	420,320
	Dc.w	540,360
	Dc.w	560,400
	Dc.w	580,540
	Dc.w	540,620
	Dc.w	500,680
	Dc.w	460,680
	Dc.w	420,660
	Dc.w	400,660
	Dc.w	380,720
	Dc.w	400,760
	Dc.w	440,800
	Dc.w	500,840
	Dc.w	580,840
	Dc.w	640,800
	Dc.w	700,760
	Dc.w	740,720
	Dc.w	760,660
	Dc.w	780,580
	Dc.w	800,520
	Dc.w	780,420
	Dc.w	760,380
	Dc.w	720,340
	Dc.w	620,340
	Dc.w	500,360
	Dc.w	400,320
	Dc.w	380,300
	Dc.w	400,240
	Dc.w	460,180
	Dc.w	500,180
	Dc.w	500,220
	Dc.w	460,240
	Dc.w	420,280
	Dc.w	400,300
	Dc.w	360,400
	Dc.w	340,460
	Dc.w	340,520
	Dc.w	340,580
	Dc.w	340,660
	Dc.w	380,720
	Dc.w	420,760
	Dc.w	480,820
	Dc.w	520,840
	Dc.w	540,860
	Dc.w	560,900
	Dc.w	540,940
	Dc.w	480,980
	Dc.w	360,980
	Dc.w	340,940
	Dc.w	380,860
	Dc.w	340,780

susie.prebspline:
	lea	susie.splinecoords+4(pc),a0
*	move.l	address.freemem(pc),a5
*	add.l	#susie.liikerata,a5
	lea	susie.liikku,a5

*	bsr	.calcit
*	lea	susie.splinecoords2+4(pc),a0
*	move.l	address.freemem(pc),a5
*	add.l	#susie.liikerata2,a5
.calcit:
	moveq	#susie.points-4,d6
.klp:
	move.w	#16-1,d7
.tlp:
	move.w	d7,d0
 add.w	d0,d0
 add.w	d0,d0
	sub.w	#63,d0
	neg.w	d0		; t
	ext.l	d0
	lsl.l	#2,d0
	lsl.l	#8,d0
	move.l	#1*256*256,d2
	move.l	#4*256*256,d3
	move.l	#1*256*256,d4

	REPT	3
	sub.l	d0,d2
	add.l	d0,d4
	ENDR

	move.l	d0,-(sp)
	mulu.l	d0,d0		; t^2
	clr.w	d0
	swap	d0
	REPT	3
	add.l	d0,d2
	add.l	d0,d4
	ENDR
	REPT	6
	sub.l	d0,d3
	ENDR

	mulu.l	(sp)+,d0		; t^3
	clr.w	d0
	swap	d0
	sub.l	d0,d2
	REPT	3
	add.l	d0,d3
	sub.l	d0,d4
	ENDR
	move.l	d0,d5

	clr.l	d0
	divs.l	#6,d0:d2		; d2 = k1
	clr.l	d0
	divs.l	#6,d0:d3		; d3 = k2
	clr.l	d0
	divs.l	#6,d0:d4		; d4 = k3
	clr.l	d0
	divs.l	#6,d0:d5		; d5 = k4

; x = k1*px(k-1)+k2*px(k)+k3*px(k+1)+k4*px(k+2)
; y = k1*py(k-1)+k2*py(k)+k3*py(k+1)+k4*py(k+2)

	move.w	-4(a0),d0
	ext.l	d0
	mulu.l	d2,d0
	move.l	d0,d1
	move.w	(a0),d0
	ext.l	d0
	mulu.l	d3,d0
	add.l	d0,d1
	move.w	4(a0),d0
	ext.l	d0
	mulu.l	d4,d0
	add.l	d0,d1
	move.w	8(a0),d0
	ext.l	d0
	mulu.l	d5,d0
	add.l	d0,d1		; x
	move.l	d1,a4

	move.w	-4+2(a0),d0
	ext.l	d0
	mulu.l	d2,d0
	move.l	d0,d1
	move.w	2(a0),d0
	ext.l	d0
	mulu.l	d3,d0
	add.l	d0,d1
	move.w	4+2(a0),d0
	ext.l	d0
	mulu.l	d4,d0
	add.l	d0,d1
	move.w	8+2(a0),d0
	ext.l	d0
	mulu.l	d5,d0
	add.l	d0,d1		; x
	move.l	a4,d0

	neg.l	d0
	lsl.l	#2,d0
	lsl.l	#2,d1
	add.l	#$2800<<16,d0
	add.l	#$1800<<16,d1
	move.l	d0,(a5)+
	move.l	d1,(a5)+
	move.w	.ang,d0
	move.w	d0,d5
	bsr	xsin
	move.w	d1,(a5)+
	sub.w	#128,.ang
	move.w	d1,(a5)+

	dbf	d7,.tlp
*	lea	-8(a5),a5
	addq.l	#4,a0
	dbf	d6,.klp
	rts
.ang:	DC.W	0

susie.readkeys:
	move.w	suunta(pc),d0
	move.w	d0,d7
	bsr	xsin
	ext.l	d1
	move.l	d1,d2
	lsl.l	#8,d2
	move.l	d2,susie.sin_a
	move.l	d1,d6
	move.w	d7,d0
	bsr	xcos
	ext.l	d1
	move.l	d1,d0
	lsl.l	#8,d0
	move.l	d0,susie.cos_a
	lsl.l	#2,d1
	move.l	d6,d2
	lsl.l	#2,d2
	move.b	$fffffc02.w,d0
	move.l	z_spd(pc),d3
	move.l	x_spd(pc),d4


	IFNE	USERCONTROL
	tst.b	keytab+$2a
	bne.s	.up
	tst.b	keytab+$48
	beq.s	.no_up
.up:
	add.l	d1,d3
	sub.l	d2,d4
.no_up
	tst.b	keytab+$38
	bne.s	.down
	tst.b	keytab+$50
	beq.s	.no_down
.down:
	sub.l	d1,d3
	add.l	d2,d4
.no_down
	ENDC

	move.l	d3,d5
	asr.l	#3,d5
	sub.l	d5,d3
	move.l	d3,z_spd

	move.l	d4,d5
	asr.l	#3,d5
	sub.l	d5,d4
	move.l	d4,x_spd
	add.l	susie.z_pos,d3
	and.l	#$7fffffff,d3
	move.l	d3,susie.z_pos
	add.l	susie.x_pos,d4
	and.l	#$7fffffff,d4
	move.l	d4,susie.x_pos

	move.w	turnspd(pc),d1
	move.w	susie.kalsin(pc),d2
	
	IFNE	USERCONTROL
	tst.b	keytab+$4b
	beq.s	.no_vasen
	add.w	#64,d1
	add.w	#256,d2
.no_vasen
	tst.b	keytab+$4d
	beq.s	.no_oikea
	sub.w	#64,d1
	sub.w	#256,d2
.no_oikea
	ENDC

	move.w	d2,susie.kalsin
	move.w	d1,d2
	asr.w	#3,d2
	sub.w	d2,d1
	move.w	d1,turnspd

	asr.w	d1
	add.w	d1,suunta

	move.w	susie.kalsin(pc),d2
	move.w	d2,d1
	asr.w	#6,d1
	sub.w	d1,d2
	move.w	d2,susie.kalsin
	rts

susie.makefloor:
	lea	susie.floordata+16*6,a0
	lea	susie.floor,a1
	moveq	#16-1,d6
.clp1:
	subq.l	#6,a0
	movem.w	(a0),d0-2
	lsl.w	#8,d0
	and.w	#$f800,d0
	lsl.w	#3,d1
	and.w	#$0fe0,d1
	or.w	d1,d0
	lsr.w	#3,d2
	and.w	#$1f,d2
	or.w	d2,d0
	move.w	d0,(a1)+
	dbf	d6,.clp1
	rts
	
******* Susien datat **************************************************

		DATA

splinedrawn:	DC.W	0
curcor:		DC.W	0

susie.floor:
		DC.W	11<<11+10<<6+12
		DC.W	10<<11+9<<6+11
		DC.W	9<<11+8<<6+10
		DC.W	8<<11+7<<6+9
		DC.W	7<<11+6<<6+8
		DC.W	6<<11+5<<6+7
		DC.W	5<<11+4<<6+6
		DC.W	4<<11+3<<6+5
		DC.W	3<<11+2<<6+4
		DC.W	2<<11+1<<6+3
		DC.W	1<<11+0<<6+2
		DC.W	0<<11+0<<6+2
		DC.W	0<<11+0<<6+1
		DC.W	0<<11+0<<6+1
		DC.W	0<<11+0<<6+0
		DC.W	12<<11+11<<6+13

susie.floordata:
	dc.w	110,91,72	; vika arvo
	dc.w	185,171,153	; eka arvo
	dc.w	177,163,144
	dc.w	170,155,135
	dc.w	161,145,127
	dc.w	155,138,121
	dc.w	151,133,116
	dc.w	148,130,112
	dc.w	144,127,106
	dc.w	138,121,100
	dc.w	133,116,95
	dc.w	129,111,91
	dc.w	125,106,86
	dc.w	121,102,82
	dc.w	118,99,79
	dc.w	114,95,75

susie.sin_a:		DC.l	$0
susie.cos_a:		DC.l	$7fffff
susie.x_pos:		DC.W	8248,0 $4000,0
susie.z_pos:		DC.W	7196,0 $3800,0
susie.number_of_walls:
	dc.w	345
	dc.w	116
	dc.w	70
	dc.w	44
	DC.W	8*12
	dc.w	35

susie.map:
; doom-map RAM:circle.s
;	dc.w	345
	dc.w	7965,7711,8029,7711,1
	dc.w	8029,7711,8093,7711,1
	dc.w	8093,7711,8157,7711,1
	dc.w	8157,7711,8157,7775,1
	dc.w	8157,7775,8157,7839,1
	dc.w	8157,7839,8212,7870,2
	dc.w	8157,7903,8157,7967,1
	dc.w	8157,7967,8157,8031,1
	dc.w	8157,8031,8214,8064,2
	dc.w	8214,8064,8157,8095,2
	dc.w	8212,7870,8157,7903,2
	dc.w	8157,8095,8157,8159,1
	dc.w	8157,8159,8157,8223,1
	dc.w	8157,8223,8213,8255,2
	dc.w	8213,8255,8157,8287,2
	dc.w	8157,8287,8157,8351,1
	dc.w	8157,8351,8157,8415,1
	dc.w	8157,8415,8213,8447,2
	dc.w	8157,8479,8157,8543,1
	dc.w	8157,8543,8157,8607,1
	dc.w	8157,8607,8093,8607,1
	dc.w	8093,8607,8029,8607,1
	dc.w	8029,8607,7965,8607,1
	dc.w	7965,8607,7965,8543,1
	dc.w	7965,8543,7965,8479,1
	dc.w	7965,8479,7965,8415,1
	dc.w	7965,8415,7937,8354,1
	dc.w	7937,8354,7915,8291,1
	dc.w	7915,8291,7901,8226,1
	dc.w	7901,8226,7895,8159,1
	dc.w	7895,8159,7901,8093,1
	dc.w	7901,8093,7914,8027,1
	dc.w	7914,8027,7935,7963,1
	dc.w	7935,7963,7965,7903,1
	dc.w	7965,7903,7965,7839,1
	dc.w	7965,7839,7965,7775,1
	dc.w	7965,7775,7965,7711,1
	dc.w	8213,8447,8157,8479,2
	dc.w	8861,7711,8861,7775,3
	dc.w	8861,7775,8861,7839,3
	dc.w	8861,7839,8861,7903,3
	dc.w	8861,7903,8892,7963,3
	dc.w	8892,7963,8912,8027,3
	dc.w	8912,8027,8924,8092,3
	dc.w	8924,8092,8927,8160,3
	dc.w	8927,8160,8925,8226,3
	dc.w	8925,8226,8911,8291,3
	dc.w	8911,8291,8891,8355,3
	dc.w	8891,8355,8861,8415,3
	dc.w	8861,8415,8861,8479,3
	dc.w	8861,8479,8861,8543,3
	dc.w	8861,8543,8861,8607,3
	dc.w	8861,8607,8797,8607,3
	dc.w	8797,8607,8733,8607,3
	dc.w	8733,8607,8669,8607,3
	dc.w	8669,8607,8669,8543,3
	dc.w	8669,8543,8669,8479,3
	dc.w	8607,8431,8669,8415,0
	dc.w	8669,8415,8669,8351,3
	dc.w	8669,8351,8669,8287,3
	dc.w	8669,8287,8607,8271,0
	dc.w	8607,8271,8545,8255,0
	dc.w	8545,8255,8607,8239,0
	dc.w	8607,8239,8669,8223,0
	dc.w	8669,8479,8607,8463,0
	dc.w	8607,8463,8545,8447,0
	dc.w	8545,8447,8607,8431,0
	dc.w	8669,8223,8669,8159,3
	dc.w	8669,8159,8669,8095,3
	dc.w	8669,8095,8607,8079,0
	dc.w	8607,8079,8545,8063,0
	dc.w	8545,8063,8607,8047,0
	dc.w	8607,8047,8669,8031,0
	dc.w	8669,8031,8669,7967,3
	dc.w	8669,7967,8669,7903,3
	dc.w	8669,7903,8607,7887,0
	dc.w	8607,7887,8545,7871,0
	dc.w	8545,7871,8607,7855,0
	dc.w	8607,7855,8669,7839,0
	dc.w	8669,7839,8669,7775,3
	dc.w	8669,7775,8669,7711,3
	dc.w	8669,7711,8733,7711,3
	dc.w	8733,7711,8797,7711,3
	dc.w	8797,7711,8861,7711,3
	dc.w	8407,8849,8466,8875,0
	dc.w	8466,8875,8497,8932,0
	dc.w	8497,8932,8559,8951,0
	dc.w	8559,8951,8619,8927,0
	dc.w	8619,8927,8662,8879,0
	dc.w	8662,8879,8724,8862,0
	dc.w	8724,8862,8781,8892,0
	dc.w	8781,8892,8792,8956,0
	dc.w	8792,8956,8765,9015,0
	dc.w	8765,9015,8719,9060,0
	dc.w	8719,9060,8667,9098,0
	dc.w	8667,9098,8613,9134,0
	dc.w	8613,9134,8557,9166,0
	dc.w	8557,9166,8498,9191,0
	dc.w	8498,9191,8437,9212,0
	dc.w	8437,9212,8373,9216,0
	dc.w	8373,9216,8320,9179,0
	dc.w	8320,9179,8291,9121,0
	dc.w	8291,9121,8227,9111,0
	dc.w	8227,9111,8166,9131,0
	dc.w	8166,9131,8116,9171,0
	dc.w	8116,9171,8053,9186,0
	dc.w	8053,9186,7995,9156,0
	dc.w	7995,9156,7995,9092,0
	dc.w	7995,9092,8033,9040,0
	dc.w	8033,9040,8094,9020,0
	dc.w	8094,9020,8158,9018,0
	dc.w	8158,9018,8222,9013,0
	dc.w	8222,9013,8275,8976,0
	dc.w	8275,8976,8315,8926,0
	dc.w	8315,8926,8346,8869,0
	dc.w	8346,8869,8407,8849,0
	dc.w	8155,7288,8155,7224,0
	dc.w	8155,7224,8219,7224,0
	dc.w	8219,7224,8219,7288,0
	dc.w	8219,7288,8155,7288,0
	dc.w	8411,7288,8411,7224,0
	dc.w	8411,7224,8475,7224,0
	dc.w	8475,7224,8475,7288,0
	dc.w	8475,7288,8411,7288,0
	dc.w	8667,7288,8667,7224,0
	dc.w	8667,7224,8731,7224,0
	dc.w	8731,7224,8731,7288,0
	dc.w	8731,7288,8667,7288,0
	dc.w	8923,7288,8923,7224,0
	dc.w	8923,7224,8987,7224,0
	dc.w	8987,7224,8987,7288,0
	dc.w	8987,7288,8923,7288,0
	dc.w	9179,7288,9179,7224,3
	dc.w	9179,7224,9243,7224,3
	dc.w	9243,7224,9243,7288,3
	dc.w	9243,7288,9179,7288,3
	dc.w	6929,7568,6945,7630,3
	dc.w	6945,7630,6961,7692,3
	dc.w	6961,7692,6977,7754,3
	dc.w	6977,7754,6993,7816,3
	dc.w	6993,7816,7009,7878,3
	dc.w	7009,7878,7025,7940,3
	dc.w	7025,7940,7042,8002,3
	dc.w	7042,8002,7058,8064,3
	dc.w	7058,8064,7074,8126,3
	dc.w	7074,8126,7091,8188,3
	dc.w	7091,8188,7106,8251,3
	dc.w	7106,8251,7123,8313,3
	dc.w	7123,8313,7139,8375,3
	dc.w	7139,8375,7155,8437,3
	dc.w	7155,8437,7171,8499,3
	dc.w	7171,8499,7187,8561,3
	dc.w	7187,8561,7125,8578,0
	dc.w	7125,8578,7109,8516,3
	dc.w	7109,8516,7092,8454,3
	dc.w	7092,8454,7076,8392,3
	dc.w	7076,8392,7060,8330,3
	dc.w	7060,8330,7044,8268,3
	dc.w	7044,8268,7028,8206,3
	dc.w	7028,8206,7012,8144,3
	dc.w	7012,8144,6995,8082,3
	dc.w	6995,8082,6979,8020,3
	dc.w	6979,8020,6963,7958,3
	dc.w	6963,7958,6947,7896,3
	dc.w	6947,7896,6931,7834,3
	dc.w	6931,7834,6915,7772,3
	dc.w	6915,7772,6898,7710,3
	dc.w	6898,7710,6883,7647,3
	dc.w	6883,7647,6866,7583,3
	dc.w	6866,7583,6929,7568,0
	dc.w	7632,6954,7600,7010,3
	dc.w	7600,7010,7569,7066,3
	dc.w	7569,7066,7538,7122,3
	dc.w	7538,7122,7506,7178,3
	dc.w	7506,7178,7475,7235,3
	dc.w	7475,7235,7443,7291,3
	dc.w	7443,7291,7412,7348,3
	dc.w	7412,7348,7355,7317,0
	dc.w	7355,7317,7386,7260,3
	dc.w	7386,7260,7418,7204,3
	dc.w	7418,7204,7449,7148,3
	dc.w	7449,7148,7481,7092,3
	dc.w	7481,7092,7513,7036,3
	dc.w	7513,7036,7544,6980,3
	dc.w	7544,6980,7577,6921,3
	dc.w	7577,6921,7632,6954,0
	dc.w	8840,9632,8899,9606,1
	dc.w	8899,9606,8958,9579,1
	dc.w	8958,9579,9016,9548,1
	dc.w	9016,9548,9071,9515,1
	dc.w	9071,9515,9123,9477,1
	dc.w	9123,9477,9174,9437,1
	dc.w	9174,9437,9224,9397,1
	dc.w	9224,9397,9272,9354,1
	dc.w	9272,9354,9318,9309,1
	dc.w	9318,9309,9360,9260,1
	dc.w	9360,9260,9400,9209,1
	dc.w	9400,9209,9439,9158,1
	dc.w	9439,9158,9477,9106,1
	dc.w	9477,9106,9513,9052,1
	dc.w	9513,9052,9546,8997,1
	dc.w	9546,8997,9577,8941,1
	dc.w	9577,8941,9634,8971,2
	dc.w	9634,8971,9690,9002,2
	dc.w	9690,9002,9746,9033,2
	dc.w	7153,6942,7112,6892,2
	dc.w	7112,6892,7071,6842,2
	dc.w	9746,9033,9712,9091,1
	dc.w	9712,9091,9677,9147,1
	dc.w	9677,9147,9639,9203,1
	dc.w	9639,9203,9601,9258,1
	dc.w	9601,9258,9559,9311,1
	dc.w	9559,9311,9514,9361,1
	dc.w	9514,9361,9468,9411,1
	dc.w	9468,9411,9421,9459,1
	dc.w	9421,9459,9373,9505,1
	dc.w	9373,9505,9322,9549,1
	dc.w	9322,9549,9269,9591,1
	dc.w	9269,9591,9215,9630,1
	dc.w	9215,9630,9160,9669,1
	dc.w	9160,9669,9102,9707,1
	dc.w	9102,9707,9044,9743,1
	dc.w	9044,9743,8983,9777,1
	dc.w	8983,9777,8922,9808,1
	dc.w	8922,9808,8894,9750,2
	dc.w	8894,9750,8867,9691,2
	dc.w	8867,9691,8840,9632,2
	dc.w	9715,8625,9733,8563,1
	dc.w	9733,8563,9751,8501,1
	dc.w	9751,8501,9763,8438,1
	dc.w	9763,8438,9768,8374,1
	dc.w	9768,8374,9772,8310,1
	dc.w	9772,8310,9775,8246,1
	dc.w	9775,8246,9775,8182,1
	dc.w	9775,8182,9773,8120,1
	dc.w	9773,8120,9768,8056,1
	dc.w	9768,8056,9762,7992,1
	dc.w	9762,7992,9754,7928,1
	dc.w	9754,7928,9743,7864,1
	dc.w	9743,7864,9730,7801,1
	dc.w	9730,7801,9715,7738,1
	dc.w	9715,7738,9777,7721,2
	dc.w	9777,7721,9839,7703,2
	dc.w	9839,7703,9901,7685,0
	dc.w	9901,7685,9963,7667,2
	dc.w	9963,7667,10025,7649,2
	dc.w	10025,8715,9963,8697,2
	dc.w	9963,8697,9901,8679,2
	dc.w	9901,8679,9839,8661,2
	dc.w	9839,8661,9777,8643,2
	dc.w	9777,8643,9715,8625,2
	dc.w	9427,7178,9386,7128,1
	dc.w	9386,7128,9343,7080,1
	dc.w	9343,7080,9300,7032,1
	dc.w	9300,7032,9253,6988,1
	dc.w	9253,6988,9204,6946,1
	dc.w	9204,6946,9154,6906,1
	dc.w	9154,6906,9102,6868,1
	dc.w	9102,6868,9049,6832,1
	dc.w	9049,6832,8993,6800,1
	dc.w	8993,6800,8935,6771,1
	dc.w	8935,6771,8966,6715,2
	dc.w	8966,6715,8996,6658,2
	dc.w	8996,6658,9027,6602,2
	dc.w	9027,6602,9057,6545,2
	dc.w	9629,7019,9578,7058,2
	dc.w	9578,7058,9528,7098,2
	dc.w	9528,7098,9478,7138,2
	dc.w	9478,7138,9427,7178,2
	dc.w	8606,6635,8544,6617,1
	dc.w	8544,6617,8481,6603,1
	dc.w	8481,6603,8417,6595,1
	dc.w	8417,6595,8353,6590,1
	dc.w	8353,6590,8289,6586,1
	dc.w	8289,6586,8225,6584,1
	dc.w	8225,6584,8161,6581,1
	dc.w	8161,6581,8097,6580,1
	dc.w	8097,6580,8033,6581,1
	dc.w	8033,6581,7969,6583,1
	dc.w	7969,6583,7904,6588,1
	dc.w	7904,6588,7841,6602,1
	dc.w	7841,6602,7779,6619,1
	dc.w	7779,6619,7717,6638,1
	dc.w	7717,6638,7656,6659,1
	dc.w	7656,6659,7596,6682,1
	dc.w	7596,6682,7537,6708,1
	dc.w	7537,6708,7478,6735,1
	dc.w	7478,6735,7420,6763,1
	dc.w	7420,6763,7363,6793,1
	dc.w	7363,6793,7306,6824,1
	dc.w	7306,6824,7253,6861,1
	dc.w	7253,6861,7202,6900,1
	dc.w	7202,6900,7153,6942,1
	dc.w	8642,6511,8624,6573,2
	dc.w	8624,6573,8606,6635,2
	dc.w	6954,7141,6912,7190,1
	dc.w	6912,7190,6873,7241,1
	dc.w	6873,7241,6835,7293,1
	dc.w	6835,7293,6801,7348,1
	dc.w	6801,7348,6770,7404,1
	dc.w	6770,7404,6739,7461,1
	dc.w	6739,7461,6711,7519,1
	dc.w	6711,7519,6688,7579,1
	dc.w	6688,7579,6668,7640,1
	dc.w	6668,7640,6648,7701,1
	dc.w	6648,7701,6631,7763,1
	dc.w	6631,7763,6616,7826,1
	dc.w	6616,7826,6604,7889,1
	dc.w	6604,7889,6596,7953,1
	dc.w	6596,7953,6588,8017,1
	dc.w	6588,8017,6582,8081,1
	dc.w	6582,8081,6579,8145,1
	dc.w	6579,8145,6579,8209,1
	dc.w	6579,8209,6583,8273,1
	dc.w	6583,8273,6588,8337,1
	dc.w	6588,8337,6595,8401,1
	dc.w	6595,8401,6604,8465,1
	dc.w	6604,8465,6617,8528,1
	dc.w	6617,8528,6554,8542,2
	dc.w	6554,8542,6491,8556,2
	dc.w	6491,8556,6428,8571,2
	dc.w	6428,8571,6365,8586,2
	dc.w	6365,8586,6302,8600,2
	dc.w	6707,6933,6757,6974,2
	dc.w	6757,6974,6806,7016,2
	dc.w	6806,7016,6856,7057,2
	dc.w	6856,7057,6905,7099,2
	dc.w	6905,7099,6954,7141,2
	dc.w	6774,8955,6807,9010,1
	dc.w	6807,9010,6842,9064,1
	dc.w	6842,9064,6878,9117,1
	dc.w	6878,9117,6917,9168,1
	dc.w	6917,9168,6956,9219,1
	dc.w	6956,9219,6908,9262,2
	dc.w	6908,9262,6858,9303,2
	dc.w	6858,9303,6809,9345,2
	dc.w	6606,9050,6661,9017,2
	dc.w	6661,9017,6718,8986,2
	dc.w	6718,8986,6774,8955,2
	dc.w	6809,9345,6771,9298,1
	dc.w	6771,9298,6734,9250,1
	dc.w	6734,9250,6698,9202,1
	dc.w	6698,9202,6662,9153,1
	dc.w	6662,9153,6632,9103,1
	dc.w	6632,9103,6606,9050,1


susie.textureposit:
		DCB.L	128*susie.maxnumoftextures,0		; osoitteet joista eri kokoiset texturet loytyy

susie.pic1:	*INCBIN	a:\tmap6.ppm
		INCBIN	susie\tmap1.ppm
susie.pic2:	*INCBIN	a:\tmap2.ppm
		INCBIN	susie\tmap2.ppm
susie.pic3:	*INCBIN	a:\tmap5.ppm
		INCBIN	susie\tmap9.ppm
susie.pic4:	*INCBIN	a:\tmap6.ppm
		INCBIN	susie\tmap6.ppm
		INCBIN	susie\tmap11.ppm
		EVEN

susie.skygfx:
		*INCBIN	a:\t320x80.bin
		INCBIN	susie\t320x80.bin
		EVEN

susie.liikutus:DC.W	0
susie.liikku:	DCB.L	susie.points*16*3,0
susie.liikend:

		RSRESET

		RS.W	128*512
susie.ruutu:	RS.W	512*192*2+128

		IFEQ	susie.alltextures
susie.textures:	RS.W	2*susie.texturewidth*128*128/2
		ELSE
susie.textures:	RS.W	4*susie.texturewidth*128*128/2
		ENDC
*susie.liikerata:RS.L	susie.points*64*2+2
*susie.liikerata2:RS.L	susie.points*64*2+2
susie.sky:	RS.W	512*80
susie.z_buffer:	RS.W	384*3			; korkeus 0-128,sein„ id 0,txt offset 0-128 
susie.htab:	RS.L	256*5*2+1
susie.memend:	RS.W	0

		IFGE	susie.memend-memory
		FAIL
		ENDC

*******************************************************************
