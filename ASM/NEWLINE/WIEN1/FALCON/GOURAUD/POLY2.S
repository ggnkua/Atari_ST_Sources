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

vbl:            move.w  #$0300,$FFFF8240.w
                move    #$2700,SR
                movem.l D0-A6,-(SP)
                lea     polykoords,A0
                bsr     do_poly
b1:             move.w  #$00,$FFFF8240.w
                movem.l (SP)+,D0-A6
                rte




do_poly:
                move.l  SP,woodstack+2
                lea     polystack(PC),SP
****????	BASE A7,polystack
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

                bset    #6,lchange
                bset    #6,rchange

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
                bclr    #6,rchange     ; negatives DX
dxok:           sub.w   D1,D3
                divu    D4,D3           ; DX/DY ==> Steigung
                move.w  D3,D5
                swap    D5
                clr.w   D3
                divu    D4,D3
                move.w  D3,D5           ; D5 ==> Longwort-Steigung rechts
                move.w  D6,D1

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
                bclr    #6,lchange  ; negatives DX
dxok1:          sub.w   D0,D3
                divu    D7,D3           ; DX/DY ==> Steigung
                move.w  D3,D6
                swap    D6
                clr.w   D3
                divu    D7,D3
                move.w  D3,D6           ; D6 ==> Longwort-Steigung links

; Ausgabe : D6-Steigung links    D7-Hîhe Linie 1 links    D2-Start X links
;           D5-Steigung rechts   D4-Hîhe Linie 1 rechts   D1-End   X rechts

                move.w  dy,D0
                bra.s   y_loop
pp2:            DS.L 16
y_loop:
; linke Begrenzung
;**
                movea.l A2,A5
                move.w  D2,D3           ; links X
                lsr.w   #1,D3
                and.w   #$FFF8,D3       ; Word-Offset
                adda.w  D3,A5
                move.w  D2,D3
                and.w   #$0F,D3         ; Bit-Offset
                add.w   D3,D3
                add.w   D3,D3
                movea.l pp2(PC,D3.w),A6 ; Tabelle suchen
                move.w  D1,D3           ; rechts X
                sub.w   D2,D3
                add.w   D3,D3
                add.w   D3,D3
                movea.l 0(A6,D3.w),A6   ; Routadr aus Tabelle
                moveq   #-1,D3
                jsr     (A6)            ; Polygonlinie zeichnen
;**
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
                bset    #6,lchange
                cmp.w   D6,D3           ; DX testen
                bgt.s   ldxok1
                exg     D6,D3
                move.w  D3,D2
                bclr    #6,lchange  ; negatives DX
ldxok1:         sub.w   D6,D3
                divu    D7,D3           ; DX/DY ==> Steigung
                move.w  D3,D6
                swap    D6
                clr.w   D3
                divu    D7,D3
                move.w  D3,D6           ; D6 ==> Longwort-Steigung links
                subq.w  #1,D7
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
                bset    #6,rchange
                cmp.w   D1,D3           ; DX testen
                bgt.s   rdxok
                exg     D1,D3
                move.w  D3,D5
                bclr    #6,rchange  ; negatives DX
rdxok:          sub.w   D1,D3
                move.w  D5,D1
                divu    D4,D3           ; DX/DY ==> Steigung
                move.w  D3,D5
                swap    D5
                clr.w   D3
                divu    D4,D3
                move.w  D3,D5           ; D5 ==> Longwort-Steigung rechts
                subq.w  #1,D4
rnext:
                swap    D1              ; sonst weiter
rchange:        add.l   D5,D1           ; Xr+Sr
                swap    D1

                lea     160(A2),A2
                dbra    D0,y_loop
woodstack:      lea     0,SP
                rts

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
                DC.W 40,199     ; Punkt 4
                DC.W 319,99     ; Punkt 3
                DC.L -1
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
