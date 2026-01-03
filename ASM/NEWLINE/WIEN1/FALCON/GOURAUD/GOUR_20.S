ti=0
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


newmode          EQU vertflag|pal|vga|col40|bps16 ;VGA-Monitor

        bra     main

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
main
        bsr     init
	bsr	initintr
	bsr	setintr

	bsr	clrscr

	bsr	init_color_tab
	bsr	generate_code
	bsr	init_yinctab

	bsr     dopolyrouts

	bsr	do_plane

	move.w	#100,xpos
	move.w	#10,ypos
	move.w	#127,width
	move.w	#1023,cols
	move.w	#2047,cole

	move.w	#127,d7
.hl
	add.w	#1,ypos
	add.w	#16,cole
	move.w	d7,-(sp)
*	bsr	hline
	move.w	(sp)+,d7
	dbf	d7,.hl


.mainloop

	move.w	#-1,vsync
.vsync
	tst.w	vsync
	bne	.vsync
	
 IIF ti	move.w	#$300,$ff8240
 IIF ti	move.w	#$030,$ff8240


        move.b  $fffc02,d0
        cmp.b   #$39,d0
        bne     .mainloop

	bsr	clrintr
        bsr     exit

u

	IFNE demo
	clr.w	-(sp)
	trap	#1
	ENDC

	rts
;-------------------------------------------------
x1		dc.w	0
y1		dc.w	0
x2		dc.w	0
y2		dc.w	0
co1		dc.w	1024
co2		dc.w	1024

do_plane
	clr.w	polyheight

	lea     polykoords,A0
	bsr     do_poly


	move.l	scr1,a6
	lea	rout_tab,a2
	lea	linetab,a4

	move.w	polyheight,d7

	move.w	#9,d7
	subq	#1,d7
	bmi	.not
.1
	move.w	(a4)+,d0
	move.w	(a4)+,d1

	move.w	#-1,(a6,d0.w*2)
	move.w	#-1,(a6,d1.w*2)

	lea	(a6,d0.w*2),a1

	movem.l	d7/a4,-(sp)
	bsr	hline
	movem.l	(sp)+,d7/a4
	lea	640(a6),a6
	dbf	d7,.1
.not
	rts
;-------------------------------------------------
xpos	dc.w	0
ypos	dc.w	0
width	dc.w	0
cols	dc.w	1000
cole	dc.w	3000

hline
	movem.l	d0-a6,-(sp)
	sub.w	d0,d1

*	move.w	xpos,d0		; x-Pos
*	move.w	ypos,d1		; y-Pos
	move.w	cols,d2		; start color
	move.w	cole,d3		; end color

	move.w	#0,d2
	move.w	#4095,d3

	lea	blue_tab,a0
	sub.w	d2,d3		; color difference
	bmi	.end

	add.w	d2,d2
	add.w	d2,a0

	lsr.w	#5,d3
	cmp.w	d1,d3
	bgt	.1
	move.w	d1,d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a2,d3.w),a3
	bra	.2
.1
	move.w	d1,d3
	neg	d3
	add.w	#256,d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a2,d3.w),a3
.2

	add.w	d1,d1
	move.w	d1,d2
	add.w	d1,d1
	add.w	d2,d1
	neg.w	d1

*	jsr	(a3,d1.w)
	movem.l	(sp)+,d0-a6

.end
	rts
;-------------------------------------------------
generate_code
	lea	code_buffer,a0
	lea	rout_tab,a1

; ersten Teil des Codes generieren
;   Farbwerte 0-0..31 in 128 Steps

	move.w	#0,d0
.steps1
	add.w	#128*6,a0

 	moveq	#0,d2
	move.w	#127,d1
.1
	add.w	d0,d2
	move.w	d2,d3

	lsr.w	#1,d3	
	and.w	#$fffe,d3

	move.w	c2,-(a0)		; or.w	d0,(a1)+
	move.w	d3,-(a0)		; offset
	move.w	c1,-(a0)		; move.w 0(a0),d0
	dbf	d1,.1

	add.w	#128*6,a0
	move.l	a0,(a1)+		; Adresse der Routine
	move.w	c3,(a0)+		; rts

	addq	#1,d0
	cmp.w	#128,d0
	blt	.steps1

lop


; zweiten Teil des Codes generieren
;   Farbwerte 0-31 in 0..127 Steps

	move.w	#128,d0
.steps2
	move.l	#128*128,d4
	divu	d0,d4
	ext.l	d4

	add.w	#128*6,a0

	moveq	#0,d2
	move.w	#127,d1
.2
	add.l	d4,d2
	move.l	d2,d3

	lsr.w	#1,d3
	and.w	#$fffe,d3

	move.w	c2,-(a0)		; or.w	d0,(a1)+
	move.w	d3,-(a0)		; offset
	move.w	c1,-(a0)		; move.w 0(a0),d0
	dbf	d1,.2

	add.w	#128*6,a0
	move.l	a0,(a1)+		; Adresse der Routine
	move.w	c3,(a0)+		; rts

	subq	#1,d0
	bne	.steps2
	rts


; code
;
;	move.w	$1234(a0),d0	; 12
; 	or.w	d0,(a1)+	;8

c1	move.w	$1234(a0),d0
c2	or.w	d0,(a1)+
c3	rts
;-------------------------------------------------
init_color_tab_normal
	lea	red_tab,a0
	lea	green_tab,a1
	lea	blue_tab,a2

	moveq	#0,d5
	move.w	#31,d6
.1	
	move.w	d5,d0
	move.w	d5,d1
	move.w	d5,d2
	lsl.w	#6,d1
	lsl.w	#8,d0
	lsl.w	#3,d0

	move.w	#127,d7
.2	move.w	d0,(a0)+
	move.w	d1,(a1)+
	move.w	d2,(a2)+
	dbf	d7,.2
	addq	#1,d5
	dbf	d6,.1
	rts
;-------------------------------------------------
init_color_tab
	lea	blue_tab,a0

	moveq	#0,d5
	move.w	#31,d6
.1	
	move.w	d5,d0
	move.w	d5,d1
	addq	#1,d1
	cmp.w	#31,d1
	ble	.fok
	move.w	#31,d1
.fok

	moveq	#0,d2

	moveq	#0,d7
.2	add.w	d7,d2

	cmp.w	#127,d2
	bgt.s	.f2
	move.w	d0,(a0)+
	bra.s	.fe
.f2
	move.w	d1,(a0)+
	sub.w	#128,d2
.fe

	addq	#1,d7
	cmp.w	#128,d7
	blt.s	.2
	addq	#1,d5
	dbf	d6,.1

	lea	blue_tab,a0
	lea	green_tab,a1
	lea	red_tab,a2
	move.w	#32*128-1,d7
.copy	move.w	(a0)+,d0
	lsl.w	#6,d0
	move.w	d0,(a1)+
	lsl.w	#5,d0
	move.w	d0,(a2)+
	dbf	d7,.copy
	rts
;-------------------------------------------------
init_yinctab
	lea	yinc_tab,a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d3

	move.w	#128-1,d7
.pcloop0:
	move.w	#320-1,d6
.pcloop1
	add.w	d0,d3
	bcc.s	.noyinc
	move.w	#640,(a0)
.noyinc	
	addq	#2,a0
	dbf	d6,.pcloop1
	add.w	#$200,d0
	moveq	#0,d3
	dbf	d7,.pcloop0
	rts
;-------------------------------------------------
clrscr
	move.l	scr1,a0
	move.w	#320*240/2-1,d0
.1	clr.l	(a0)+
	dbf	d0,.1
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

        movem.l $ff8240,d0-d7
        movem.l d0-d7,oldcol

	move.w	#2,-(sp)
	trap	#14
	addq	#2,sp
	move.l	d0,oldscr

	move.w	#-1,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq	#4,sp
	move.w	d0,oldmode

	move.l	#screens,d0
	addq	#4,d0
	and.l	#$fffffffc,d0
	move.l	d0,scr1
	

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

;-------------------------------------------------
;-------------------------------------------------
;-------------------------------------------------
;-------------------------------------------------
;===========================================================
;                                Fastest-Polygons-Ever-Coded
;===========================================================
;Ω1991 by Mark Fechtner (The Innovator) of NEWline/GAMES.Software

x:              pea     0
                move.w  #$20,-(SP)
                trap    #1
                addq.w  #6,SP
                move.l  D0,savessp+2

                move.l  $044E.w,screenadr
**                clr.b   $FFFF8260.w

	move.w	#0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.w	#12,sp

                bsr     clrscreen
                move.b  #2,$FFFF820A.w

                bsr     dopolyrouts

                move.l  #nono,$14.w
                move.l  #vbl,$70.w
                move    #$2300,SR

w:              cmpi.b  #$39,$FFFFFC02.w
                bne.s   w

	move.w	#2,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.w	#12,sp


savessp:        pea     0
                move.w  #$20,-(SP)
                trap    #1
                addq.w  #6,SP

                clr.w   -(SP)
                trap    #1
nono:           rte

dopolyrouts:
                lea     polypointers,A0
                lea     polyrouts,A1
                lea     pp2,A2
                moveq   #-1,D0          ; Start-Word
                moveq   #0,D1           ; LÑnge
                moveq   #16-1,D7
dpr_loop:       move.w  #320-16,D6
                add.w   D7,D6
                move.l  A0,(A2)+
dpr_loop0:      move.l  A1,(A0)+        ; Pointer sichern
                move.w  D7,D4
                eori.w  #$0F,D4         ; Startbit
                add.w   D1,D4           ; + LÑnge
                cmp.w   #15,D4          ; nur, wenn End-Word
                bgt.s   dpr_start       ; ausserhalb Start-Word liegt
                moveq   #-1,D5
                lsr.w   D4,D5
                eor.w   D0,D5
                move.w  #$3ABC,(A1)+    ; MOVE.W #n,(A5)
                move.w  D5,(A1)+        ; n
                bra.s   dpr_bye

dpr_start:      move.w  #$55,(A1)+      ; OR.L #X,(A5)
                move.w  D0,(A1)+        ; Start-Word
                move.w  D7,D4

                moveq   #8,D5
                move.w  D1,D4
                move.w  D7,D3
                eori.w  #$0F,D3
                add.w   D3,D4
                lsr.w   #4,D4
                subq.w  #2,D4
                bmi.s   dpr_noloop
dpr_loop1:      move.w  #$3B43,(A1)+    ; MOVE.W D3,o(A5)
                move.w  D5,(A1)+        ; o
                addq.w  #8,D5
                dbra    D4,dpr_loop1
dpr_noloop:     move.w  D7,D3
                eori.w  #$0F,D3
                add.w   D1,D3
                and.w   #$0F,D3
                moveq   #-1,D4
                lsr.w   D3,D4
                not.w   D4
                beq.s   dpr_bye
                move.w  #$6D,(A1)+      ; OR.W #n,o(A5)
                move.w  D4,(A1)+        ; n
                move.w  D5,(A1)+        ; o
dpr_bye:        move.w  #$4E75,(A1)+    ; RTS
                addq.w  #1,D1
                move.w  D1,D4
                and.w   #$0F,D4
                beq.s   nextendword
                dbra    D6,dpr_loop0
                bra.s   nextstart
nextendword:    dbra    D6,dpr_loop0
nextstart:      lsr.w   #1,D0
                moveq   #0,D1
                dbra    D7,dpr_loop
                rts

	IFNE 0
vbl:            move.w  #$0300,$FFFF8240.w
                move    #$2700,SR
                movem.l D0-A6,-(SP)
                lea     polykoords,A0
                bsr     do_poly
b1:             move.w  #$00,$FFFF8240.w
                movem.l (SP)+,D0-A6
                rte
	ENDC




do_poly:
		lea	linetab,a6

                moveq   #4-1,D0
                move.w  #1000,D1        ; kleinstes Y in D1
                moveq   #0,D2           ; grîûtes Y in D2
                movea.l A0,A3
                addq.w  #2,A0
dp_getlowy:     move.w  (A0),D3
                cmp.w   D1,D3
                bge.s   dp_nogety0
                move.w  D3,D1
                lea     -2(A0),A1       ; Pointer auf Punkt mit kleinstem Y
dp_nogety0:     cmp.w   D2,D3
                ble.s   dp_nogety1
                move.w  D3,D2           ; grîûtes Y suchen
dp_nogety1:     addq.w  #4,A0
                dbra    D0,dp_getlowy
                sub.w   D1,D2
                move.w  D2,dy           ; Hîhe des Polygons

                lsl.w   #5,D1           ; * 160
                move.w  D1,D3
                add.w   D3,D3
                add.w   D3,D3
                add.w   D3,D1

                movea.l screenadr,A2
;                lea     160*50(A2),A2
                adda.w  D1,A2
                move.w  D2,D0
                subq.w  #2,A0

;                bset    #6,lchange
;                bset    #6,rchange
		sf 	fuck0
		sf	fuck1

; Steigung der 1. rechten Linie berechnen
                movea.l A1,A4
                moveq   #0,D3
                move.w  (A1)+,D1        ; X1r
                move.w  (A1)+,D2        ; Y1r
                cmpa.l  A0,A1           ; Ende der 4 Punkte erreicht ?
                blt.s   a1ok
                lea     -4*4(A0),A1     ; sonst von vorne
a1ok:           move.w  (A1),D3         ; X2r
                move.w  2(A1),D4        ; Y2r
                sub.w   D2,D4           ; DY dieser Linie
                move.w  D1,D6
                cmp.w   D1,D3           ; DX testen
                bgt.s   dxok
                exg     D1,D3
		sf	fuck0 		; negatives DX
dxok:           sub.w   D1,D3
                divu    D4,D3           ; DX/DY ==> Steigung
                move.w  D3,D5
                swap    D5
                clr.w   D3
                divu    D4,D3
                move.w  D3,D5           ; D5 ==> Longwort-Steigung rechts
                move.w  D6,D1
		tst.b	fuck0
		beq.s	nofuck0
		neg.l	d5
nofuck0	
; Steigung der 1. linken Linie berechnen
b3:
                moveq   #0,D3
                move.w  (A4)+,D0        ; X1l
                move.w  (A4),D2         ; Y1l
                lea     -4-2(A4),A4     ; Pointer Linie links
                cmpa.l  A3,A4           ; wenn am Anfang
                bge.s   a4ok
                lea     -4(A0),A4       ; am Ende weitermachen
a4ok:           move.w  (A4),D3         ; X2l
                move.w  2(A4),D7        ; Y2l
                sub.w   D2,D7           ; DY dieser Linie
                move.w  D0,D2
                cmp.w   D0,D3           ; DX testen
                bgt.s   dxok1
                exg     D0,D3
                move.w  D3,D2
                st	fuck1		; negatives DX
dxok1:          sub.w   D0,D3
                divu    D7,D3           ; DX/DY ==> Steigung
                move.w  D3,D6
                swap    D6
                clr.w   D3
                divu    D7,D3
                move.w  D3,D6           ; D6 ==> Longwort-Steigung links
		tst.b	fuck1
		beq.s	nofuck1
		neg.l	d6
nofuck1	
; Ausgabe : D6-Steigung links    D7-Hîhe Linie 1 links    D2-Start X links
;           D5-Steigung rechts   D4-Hîhe Linie 1 rechts   D1-End   X rechts

                move.w  dy,D0
                bra.s   y_loop
pp2:            DS.L 16
y_loop:
; linke Begrenzung
;**
	IFNE 0
                movea.l A2,A5
                move.w  D2,D3           ; links X
                lsr.w   #1,D3
                and.w   #$FFF8,D3       ; Word-Offset
                adda.w  D3,A5
                move.w  D2,D3
                and.w   #$0F,D3         ; Bit-Offset
                add.w   D3,D3
                add.w   D3,D3
;                movea.l pp2(PC,D3.w),A6 ; Tabelle suchen
                move.w  D1,D3           ; rechts X
                sub.w   D2,D3
                add.w   D3,D3
                add.w   D3,D3
;                movea.l 0(A6,D3.w),A6   ; Routadr aus Tabelle
                moveq   #-1,D3
;                jsr     (A6)            ; Polygonlinie zeichnen
	ENDC
;**

	addq	#1,polyheight
	move.w	d2,(a6)+
	move.w	d1,(a6)+
;                subq.w  #1,D7           ; linke Linie zuende ?
;                bmi     lnl
                dbra    D7,lnext        ; linke Linie zuende ?

;linke Liniensteigung
lnl:            moveq   #0,D1
                move.w  (A4)+,D6        ; X1l
                move.w  (A4),D2         ; Y1l
                lea     -4-2(A4),A4     ; Pointer Linie links
                cmpa.l  A3,A4           ; wenn am Anfang
                bge.s   la4ok
                lea     -4(A0),A4       ; am Ende weitermachen
la4ok:          moveq   #0,D3
                move.w  (A4),D3         ; X2l
                move.w  2(A4),D7        ; Y2l
                sub.w   D2,D7           ; DY dieser Linie
                move.w  D6,D2	
		sf	fuck0
;                bset    #6,lchange
                cmp.w   D6,D3           ; DX testen
                bgt.s   ldxok1
                exg     D6,D3
		move.w  D3,D2
;		neg.l	d6
		st	fuck0
;                bclr    #6,lchange  ; negatives DX
ldxok1:         sub.w   D6,D3
                divu    D7,D3           ; DX/DY ==> Steigung
                move.w  D3,D6
                swap    D6
                clr.w   D3
                divu    D7,D3
                move.w  D3,D6           ; D6 ==> Longwort-Steigung links
                subq.w  #1,D7
		tst.b	fuck0
		beq.s	lnext
		neg.l	d6
lnext:
                swap    D2              ; sonst weiter
lchange:        add.l   D6,D2           ; Xl+Sl
                swap    D2

;                subq.w  #1,D4           ; rechte Linie zuende ?
;                bmi     rnl
                dbra    D4,rnext        ; rechte Linie zuende ?

; rechte Liniensteigung berechnen
rnl:            moveq   #0,D1
                move.w  (A1)+,D1        ; X1r
                move.w  (A1)+,D5        ; Y1r
                cmpa.l  A0,A1           ; Ende der 4 Punkte erreicht ?
                blt.s   ra1ok
                lea     -4*4(A0),A1     ; sonst von vorne
ra1ok:          moveq   #0,D3
                move.w  (A1),D3         ; X2r
                move.w  2(A1),D4        ; Y2r
                sub.w   D5,D4           ; DY dieser Linie
                move.w  D1,D5
		sf	fuck1
;		neg.l	D5
;                bset    #6,rchange
                cmp.w   D1,D3           ; DX testen
                bgt.s   rdxok
                exg     D1,D3
                move.w  D3,D5
		st	fuck1
;                bclr    #6,rchange  ; negatives DX
rdxok:          sub.w   D1,D3
                move.w  D5,D1
                divu    D4,D3           ; DX/DY ==> Steigung
                move.w  D3,D5
                swap    D5
                clr.w   D3
                divu    D4,D3
                move.w  D3,D5           ; D5 ==> Longwort-Steigung rechts
                subq.w  #1,D4
		tst.b	fuck1
		beq.s	rnext
		neg.l	d5
rnext:
                swap    D1              ; sonst weiter
rchange:        add.l   D5,D1           ; Xr+Sr
                swap    D1

                lea     160(A2),A2
                dbra    D0,y_loop
woodstack:      
                rts

fuck0		dc.b 0
fuck1		dc.b 0	
                DS.L 100
polystack:      DC.L 0

clrscreen:      movea.l screenadr,A0
                move.w  #32000/4-1,D0
clrloop:        clr.l   (A0)+
                dbra    D0,clrloop
                rts




clr:            DS.L 16
screenadr:      DS.L 1
polykoords:     DC.W 0,0        ; Punkt 1
                DC.W 19,0       ; Punkt 2
                DC.W 60,99     ; Punkt 3
                DC.W 40,199     ; Punkt 4
                DC.L -1
pkcols:		dc.w 0,0,1024,0,0,2048,0,0,3072,0,0,4095

polyheight	dc.w	0


	IFNE 0
                BSS
dy:             DS.W 1
minus:          DS.W 1
minus1:         DS.W 1
polybuf:        DS.W 2*200      ; Buffer fÅr xl,xr fÅr Waagerechte
polypointers:   DS.L 320*16
p:
polyrouts:      DS.B 250*1024
eop:
                END
	ENDC

;-------------------------------------------------
;-------------------------------------------------
;-------------------------------------------------
;-------------------------------------------------

	section bss

red_tab		ds.w	32*128
green_tab	ds.w	32*128
blue_tab	ds.w	32*128

rout_tab	ds.l	128*2

code_buffer	ds.b	(128*6+2)*256

linetab		ds.l	400

yinc_tab	ds.l	100000


screens		ds.w	320*240+4

dy:             DS.W 1
minus:          DS.W 1
minus1:         DS.W 1
polybuf:        DS.W 2*200      ; Buffer fÅr xl,xr fÅr Waagerechte
polypointers:   DS.L 320*16
p:
polyrouts:      DS.B 250*1024
eop:

