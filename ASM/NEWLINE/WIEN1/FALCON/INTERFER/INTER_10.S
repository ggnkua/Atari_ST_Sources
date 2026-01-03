ti=1
demo=1

vertflag        EQU $0100
stmodes         EQU $800
overscan        EQU $40
pal             EQU $20
ntsc            EQU $00
vga             EQU $10
tv              EQU $00
col80           EQU $08
col40           EQU $00
bps16           EQU 4
bps8            EQU 3
bps4            EQU 2
bps2            EQU 1
bps1            EQU 0
getmode         EQU -1


newmode          EQU vertflag|pal|vga|col40|bps8 ;VGA-Monitor


	jmp	main

BLITTER = $ffff8a00

HALFTONE	= 0
SRC_XINC	= 32
SRC_YINC	= 34
SRC_ADDR	= 36
ENDMASK1	= 40
ENDMASK2	= 42
ENDMASK3	= 44
DST_XINC	= 46
DST_YINC	= 48
DST_ADDR	= 50
X_COUNT		= 54
Y_COUNT		= 56
HOP		= 58
OP		= 59
LINE_NUM	= 60
SKEW		= 61

FHOP_SOURCE	= 1
FHOP_HALFTONE	= 0
FSKEWFXSR	= 7
FSKEWNFSR	= 6
FLINEBUSY	= 7
FLINEHOG	= 6
FLINESMUDGE	= 5

MHOP_SOURCE	= $02
MHOP_HALFTONE	= $01
MSKEWFXSR	= $80
MSKEWNFSR 	= $40
MLINEBUSY	= $80
MLINEHOG	= $40
MLINESMUDGE	= $20

left_endmask	dc.w	$ffff,$7fff,$3fff,$1fff
		dc.w	$0fff,$07ff,$03ff,$01ff
		dc.w	$00ff,$007f,$003f,$001f
		dc.w	$000f,$0007,$0003,$0001

right_endmask	dc.w	$0000,$8000,$c000,$e000
		dc.w	$f000,$f800,$fc00,$fe00
		dc.w	$ff00,$ff80,$ffc0,$ffe0
		dc.w	$fff0,$fff8,$fffc,$fffe
;-------------------------------------------------
; Startet den Blitter
; a5 zeigt auf Blitter
; d6,a6 werden zerst”rt
do_blitter MACRO
	lea	LINE_NUM(a5),a6
	move.b	#FLINEBUSY,d6

	move.b	#MLINEBUSY,(a6)
.restart\@
	bset.b d6,(a6)
	nop
	bne.s	.restart\@
	ENDM
;-------------------------------------------------        


;-------------------------------------------------
vbl	clr.b	$fffa1b
	move.b	#255,$fffa21
	move.b	#8,$fffa1b
	move.l	#timerb,$120

        movem.l d0-a6,-(sp)
        movem.l (sp)+,d0-a6

	clr.w	vsync
*	rte

nv      jmp     $0
vsync	dc.w	0
;-------------------------------------------------
timerb
        clr.b   $fffa1b
        move.b  #255,$fffa21
        move.b  #8,$fffa1b
        bclr    #0,$fffa0f
        rte
;-------------------------------------------------
change_screen
	move.l	scr1,d0
	move.l	scr2,scr1
	move.l	d0,scr2

	add.w	#3*4,wave_ptr1
	cmp.w	#5*360*4,wave_ptr1
	blt	.1
	clr.w	wave_ptr1
.1
	lea	wave1,a0
	add.w	wave_ptr1,a0

	move.w	(a0)+,d0
	move.w	(a0)+,d1
	move.w	d0,xoff
	move.w	d1,yoff

	add.w	#320,d0
	add.w	#200,d1

	move.l	scr1,a0
*	add.l	#200*640+320,a0
	muls	#640,d1
	add.l	d1,a0

	move.w	d0,d1
	and.w	#$fff0,d1
	add.w	d1,a0

	move.w	#160-8,d1
	and.w	#$f,d0

	tst.w	d0
	bne	.2
	move.w	#160,d1
.2
	move.b	d1,$ffff820f.w		; Line Offset
	move.b	d0,$ffff8265.w		; Bitweises Scrolling

	move.l	actscr,actscr2
	move.l	a0,actscr


	move.w	#-1,-(sp)
	move.l	a0,-(sp)
	move.l	a0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.w	#12,sp
	rts
;-------------------------------------------------
newcol
	dc.w	$000,$001,$002,$003,$004,$005,$006,$007
	dc.w	$017,$007,$006,$005,$004,$003,$002,$001
main
        bsr     init
	bsr	initintr
	bsr	setintr

	bsr	init_coltab

	bsr	show_bitmap
	move.l	scr1,d0
	move.l	scr2,scr1
	move.l	d0,scr2
	bsr	show_bitmap

	move.b	#160,$ffff820f.w	; Line Offset
	move.b	#0,$ffff8265.w		; Bitweises Scrolling

.mainloop


	move.w	#-1,vsync
.vsync
	tst.w	vsync
	bne	.vsync

	bsr	change_screen
	
 IIF ti	move.w	#$300,$ff8240
*	bsr	blitter_bitmap
 IIF ti	move.w	#$030,$ff8240


        move.b  $fffc02,d0
        cmp.b   #$39,d0
        bne     .mainloop

	bsr	clrintr
	move.b	#0,$ffff820f.w		; Line Offset
	move.b	#0,$ffff8265.w		; Bitweises Scrolling
        bsr     exit

	IFNE demo
	clr.w	-(sp)
	trap	#1
	ENDC

	rts
;-------------------------------------------------
blitter_bitmap
	add.w	#5*4,wave_ptr2
	cmp.w	#5*360*4,wave_ptr2
	blt	.0
	clr.w	wave_ptr2
.0
	lea	wave2,a0
	add.w	wave_ptr2,a0

	move.w	(a0)+,d0
	sub.w	xoff,d0
	move.w	(a0)+,d1
	sub.w	yoff,d1
*	add.w	#160-50,d0
*	add.w	#100,d1

	move.l	scr2,a1
	addq	#8,a1
	muls	#640,d1
	add.l	d1,a1
	move.w	d0,d1
	and.w	#$fff0,d1
	add.w	d1,a1



	lea	picture,a0

	lea	BLITTER.w,a5

	lea	left_endmask,a4
	move.w	d0,d4
	and.w	#$f,d4
	add.w	d4,d4
	move.w	(a4,d4.w),ENDMASK1(a5)
	move.w	#$ffff,ENDMASK2(a5)
	lea	right_endmask,a4
	move.w	d0,d4
	and.w	#$f,d4
	add.w	d4,d4
	move.w	(a4,d4.w),ENDMASK3(a5)

	move.w	d0,d4
	and.w	#$f,d4
	or.b	#MSKEWNFSR,d4
	move.b	d4,SKEW(a5)
	move.b	#MHOP_SOURCE,HOP(a5)	; nur Source (kein Halftone)

	move.w	#8,SRC_XINC(a5)
	move.w	#16,SRC_YINC(a5)
	move.w	#16,DST_XINC(a5)
	move.w	#320+6*16+16,DST_YINC(a5)

	moveq	#3,d7
.1

	move.w	#14,X_COUNT(a5)
	move.w	#200,Y_COUNT(a5)
	move.l	a0,SRC_ADDR(a5)		; Source-Adresse
	move.l	a1,DST_ADDR(a5)		; Destination-Adresse
	move.b	#3,OP(a5)
	do_blitter

	addq	#2,a0
	addq	#2,a1
	dbf	d7,.1			; Blitter starten

	rts
;-------------------------------------------------
show_bitmap
	lea	picture,a0
	move.l	scr1,a1
	add.l	#200*320+160+32,a1

	move.w	#199,d0
.1	
i set 0
	REPT 14
	move.l	(a0)+,i(a1)
	move.l	(a0)+,i+4(a1)
i set i+16
	ENDR
	lea	640(a1),a1
	dbf	d0,.1
	rts
;-------------------------------------------------
newcols		dc.w	$000,$001,$002,$003,$004,$005,$006,$007
		dc.w	$007,$006,$005,$004,$003,$002,$001,$000


init_coltab
	lea	colbuffer,a2

	lea	newcols,a0
	moveq	#15,d0
.1
	lea	newcols,a1
	moveq	#15,d1
.2
	move.w	(a0),d2
	add.w	(a1)+,d2
	
	lsl.w	#4,d2
	move.b	d2,1(a2)
	addq	#4,a2
	dbf	d1,.2
	addq	#2,a0
	dbf	d0,.1

	lea	colbuffer,a0
	lea	$ffff9800.w,a1
	move.w	#255,d0
.3	move.l	(a0)+,(a1)+
	dbf	d0,.3
	rts

colbuffer	ds.l	256
;-------------------------------------------------
; -> d0 : value
; <- d0 : Sqrt(value)
sqrt
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	
	moveq	#0,d4
	
	moveq	#15,d6
.1
	add.l	d0,d0
	addx.l	d1,d1

	add.l	d0,d0
	addx.l	d1,d1
	
	lsl.l	#1,d2
	lsl.l	#1,d3
	or.l	#1,d3
	sub.l	d3,d1
	tst.l	d1
	bpl	.ok
	add.l	d3,d1
	and.l	#$fffe,d3
	bra	.ok2
.ok
	add.l	#1,d3
	or.l	#1,d2
.ok2
	dbf	d6,.1
	
	move.w	d2,d0
	
	rts
;-------------------------------------------------
initintr
        move.b  $fffa07,old7
        move.b  $fffa09,old9
        move.b  $fffa13,old13
        move.b  $fffa15,old15
        move.b  $fffa19,old19
        move.b  $fffa1b,old1b
        move.b  $fffa1f,old1f

	move.l	$68,old68
        move.l  $70,old70
        move.l  $70,nv+2
        move.l  $120,old120
	move.l	$134,old134
        rts
;-------------------------------------------------
setintr
	move.w	#$2700,sr
	move.b	#1,$fffa07
	clr.b	$fffa09
	move.b	#1,$fffa13
	clr.b	$fffa15
	clr.b	$fffa19
        move.l  #vbl,$70
        move.l  #timerb,$120
	move.w	#$2300,sr
	
	bset	#6,$fffa09
	bset	#6,$fffa15
        rts
;-------------------------------------------------
clrintr
	move.w	#$2700,sr
        move.l  old134,$134
        move.l  old120,$120
        move.l  old70,$70
        move.l  old68,$68

        move.b  old7,$fffa07
        move.b  old9,$fffa09
        move.b  old13,$fffa13
        move.b  old15,$fffa15
        move.b  old19,$fffa19
        move.b  old1b,$fffa1b
        move.b  old1f,$fffa1f
	move.w	#$2300,sr
        rts
;-------------------------------------------------
init
	IFNE demo
        bsr     superon
        bsr     mouseoff
	ENDC

	lea	start_bss,a0
	lea	end_bss,a1
.1	clr.l	(a0)+
	cmp.l	a1,a0
	blt	.1

        movem.l $ff8240,d0-d7
        movem.l d0-d7,oldcol

        move.l  $44e,oldscr

	move.l	#screens+4,d0
	and.l	#$fffffffc,d0
	move.l	d0,scr1
	add.l	#640*240*2,d0
	move.l	d0,scr2

	move.w	#-1,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq	#4,sp
	move.w	d0,oldmode

	move.w	#newmode,-(sp)
	move.w	#3,-(sp)
	move.l	scr1,-(sp)
	move.l	scr1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#14,sp
        rts
;-------------------------------------------------
superon
        move.l  #0,-(sp)
        move.w  #32,-(sp)
        trap    #1
        addq.l  #6,sp
        move.l  d0,ssp
        rts
;-------------------------------------------------
superoff
        move.l  ssp,-(sp)
        move.w  #32,-(sp)
        trap    #1
        addq.l  #6,sp
        rts
;-------------------------------------------------
mouseoff
        dc.w    $a00a

        pea     moff
        move.w  #0,-(sp)
        move.w  #25,-(sp)
        trap    #14
        addq.l  #8,sp
        rts
;-------------------------------------------------
mouseon
        pea     mon
        move.w  #0,-(sp)
        move.w  #25,-(sp)
        trap    #14
        addq.l  #8,sp
        
        dc.w    $a009
        rts
;-------------------------------------------------
exit
        movem.l oldcol,d0-d7
        movem.l d0-d7,$ff8240

       	move.w	oldmode,-(sp)
	move.w  #3,-(sp)
	move.l  oldscr,-(sp)
	move.l  oldscr,-(sp)
	move.w  #5,-(sp)
	trap    #14
	add.l   #14,sp
 
        bsr     mouseon

	IFNE demo
        bsr     superoff
	ENDC
	rts
;-------------------------------------------------

moff            dc.b    $12
mon             dc.b    $8

ssp             dc.l    0

old7            dc.b    0
old9            dc.b    0
old13           dc.b    0
old15           dc.b    0
old19           dc.b    0
old1b           dc.b    0
old1f           dc.b    0
        even
old68           dc.l    0
old70           dc.l    0
old120          dc.l    0
old134          dc.l    0

oldscr          dc.l    0
oldcol          ds.l    8
oldmode		dc.w	0

;-------------------------------------------------

scr1		dc.l	0
scr2		dc.l	0
actscr		dc.l	0
actscr2		dc.l	0

xoff		dc.w	0
yoff		dc.w	0

picture		incbin	piccy.bmp

wave_ptr1	dc.w	0
wave1		incbin	wave1.dat
wave_ptr2	dc.w	0
wave2		incbin	wave2.dat

	section bss


start_bss
screens		ds.b	640*240*2*2
end_bss
