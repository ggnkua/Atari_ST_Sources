
; kreisroutine
; aus: st-computer, falcon-szene ...
; abgeaendert fuer scanner

;* d1: radius
;* d4: farbe
;* a1: screenadresse mittelpunkt

kreis_scan
                movem.l D0-A6,-(SP)

                moveq   #0,D0
                move.w  D1,D2
                subq.w  #1,D2

		cmpi.w	#320,true_offi+2
		beq.s	kreis_scan_now320
		cmpi.w	#512,true_offi+2
		beq	kreis_scan_now512
		bra.s	kreis_scan_now

kreis_scan_out
		movem.l	(sp)+,d0-a6
		rts

;---------------

kreis_scan_now
                tst.w   D2
                bpl.s   kreis_scan_nein
                subq.w  #1,D1
                add.w   D1,D2
                add.w   D1,D2
kreis_scan_nein
                move.w  D0,D3
                add.w   D3,D3
                move.w  D1,D5
                move.w  D1,D6
                lsl.w   #8,D5
                add.w   D5,D5
                lsl.w   #7,D6
                add.w   D5,D6
                movea.l A1,A0
                adda.w  D3,A0
                suba.w  D6,A0
                move.w  D4,(A0)                   ; pixel 3
                movea.l A1,A0
                suba.w  D3,A0
                suba.w  D6,A0
                move.w  D4,(A0)                   ; pixel 4
                move.w  D1,D3
                add.w   D3,D3
                move.w  D0,D5
                move.w  D0,D6
                lsl.w   #8,D5
                add.w   D5,D5
                lsl.w   #7,D6
                add.w   D5,D6
                movea.l A1,A0
                adda.w  D3,A0
                suba.w  D6,A0
                move.w  D4,(A0)                   ; pixel 7
                movea.l A1,A0
                suba.w  D3,A0
                suba.w  D6,A0
                move.w  D4,(A0)                   ; pixel 8

                sub.w   D0,D2
                sub.w   D0,D2
                subq.w  #1,D2
                addq.w  #1,D0
                cmp.w   D1,D0
                ble.s   kreis_scan_now

                bra	kreis_scan_out

;---------------

kreis_scan_now320
                tst.w   D2
                bpl.s   kreis_scan_nein320
                subq.w  #1,D1
                add.w   D1,D2
                add.w   D1,D2
kreis_scan_nein320
                move.w  D0,D3
                add.w   D3,D3
                move.w  D1,D5
                move.w  D1,D6
                lsl.w   #8,D5
;                add.w   D5,D5
                lsl.w   #6,D6
                add.w   D5,D6
                movea.l A1,A0
                adda.w  D3,A0
                suba.w  D6,A0
                move.w  D4,(A0)                   ; pixel 3
                movea.l A1,A0
                suba.w  D3,A0
                suba.w  D6,A0
                move.w  D4,(A0)                   ; pixel 4
                move.w  D1,D3
                add.w   D3,D3
                move.w  D0,D5
                move.w  D0,D6
                lsl.w   #8,D5
;                add.w   D5,D5
                lsl.w   #6,D6
                add.w   D5,D6
                movea.l A1,A0
                adda.w  D3,A0
                suba.w  D6,A0
                move.w  D4,(A0)                   ; pixel 7
                movea.l A1,A0
                suba.w  D3,A0
                suba.w  D6,A0
                move.w  D4,(A0)                   ; pixel 8

                sub.w   D0,D2
                sub.w   D0,D2
                subq.w  #1,D2
                addq.w  #1,D0
                cmp.w   D1,D0
                ble.s   kreis_scan_now320

                bra	kreis_scan_out

;---------------

kreis_scan_now512
                tst.w   D2
                bpl.s   kreis_scan_nein512
                subq.w  #1,D1
                add.w   D1,D2
                add.w   D1,D2
kreis_scan_nein512
                move.w  D0,D3
                add.w   D3,D3
                move.w  D1,D5
                move.w  D1,D6
;                lsl.w   #8,D5
;                add.w   D5,D5
                lsl.w   #8,D6
		add.w	d6,d6
;                add.w   D5,D6
                movea.l A1,A0
                adda.w  D3,A0
                suba.w  D6,A0
                move.w  D4,(A0)                   ; pixel 3
                movea.l A1,A0
                suba.w  D3,A0
                suba.w  D6,A0
                move.w  D4,(A0)                   ; pixel 4
                move.w  D1,D3
                add.w   D3,D3
                move.w  D0,D5
                move.w  D0,D6
;                lsl.w   #8,D5
;                add.w   D5,D5
                lsl.w   #8,D6
		add.w	d6,d6
;                add.w   D5,D6
                movea.l A1,A0
                adda.w  D3,A0
                suba.w  D6,A0
                move.w  D4,(A0)                   ; pixel 7
                movea.l A1,A0
                suba.w  D3,A0
                suba.w  D6,A0
                move.w  D4,(A0)                   ; pixel 8

                sub.w   D0,D2
                sub.w   D0,D2
                subq.w  #1,D2
                addq.w  #1,D0
                cmp.w   D1,D0
                ble.s   kreis_scan_now512

                bra	kreis_scan_out


;*******************************************************
;* line_clipping enhanced and corrected (c) mike of stax
;*******************************************************
;* 26.09.1996 *
;**************

; linienroutine fuer truecolor-bildschirm
; mit variablen line-offset
; algorithmus: bresenham

; a0 = screenadresse


; d0 = x1
; d1 = y1
; d2 = x2
; d3 = y2
; d4 = screenoffset (line)
; d7 = color


clip_x_max	equ	319
clip_y_max	equ	199

linie:

* uses d0,d1,d2,d3,d5,d6 / a3,a4


                cmp.w   D0,D2
                beq     clip_vertical
                cmp.w   D1,D3
                beq     clip_horizontal

********** Normale Linie ***************


* window code fuer Punkt 1 nach d5 *

                moveq   #0,D5
* xmin *
                move.w  D0,D5
                add.l   D5,D5
* xmax *
                move.w  #clip_x_max,D5
                sub.w   D0,D5
                add.l   D5,D5
* ymin *
                move.w  D1,D5
                add.l   D5,D5
* ymax *
                move.w  #clip_y_max,D5
                sub.w   D1,D5
                add.l   D5,D5
                swap    D5

* window code fuer Punkt 2 nach d6 *

                moveq   #0,D6
* xmin *
                move.w  D2,D6
                add.l   D6,D6
* xmax *
                move.w  #clip_x_max,D6
                sub.w   D2,D6
                add.l   D6,D6
* ymin *
                move.w  D3,D6
                add.l   D6,D6
* ymax *
                move.w  #clip_y_max,D6
                sub.w   D3,D6
                add.l   D6,D6
                swap    D6

                movea.w D4,A3
                movea.w D7,A4

                move.w  D6,D7

                and.w   D5,D7
                beq.s   do_clip

                move.w  A3,D4
                move.w  A4,D7

                rts

* Bits:
*               0 = unten
*               1 = oben
*               2 = rechts
*               3 = links


do_clip:

************* Punkte clippen (kein Cohen/Sutherland !) **************

****** Punkt 1 clippen *****

                tst.w   D5              * muss der geclippt werden ??
                beq     clip_second_point * nein, ueberspringen ...
                btst    #3,D5
                beq.s   clip_right_1

* Links clippen *

                move.w  D3,D7
                sub.w   D1,D7           * dy

                move.w  D2,D4
                sub.w   D0,D4           * dx

                move.w  D2,D0           * dx `

                muls    D7,D0
                divs    D4,D0

                move.w  D3,D1
                sub.w   D0,D1

                moveq   #0,D0

* After check *
                tst.w   D1
                bmi     clip_failed
                cmp.w   #clip_y_max,D1
                ble.s   clip_up_1
                bra     clip_failed

clip_right_1:   btst    #2,D5
                beq.s   clip_up_1

* Rechts clippen *

                move.w  D3,D7
                sub.w   D1,D7           * dy

                move.w  D0,D4
                sub.w   D2,D4           * dx

                move.w  #clip_x_max,D0  * dx `
                sub.w   D2,D0

                muls    D7,D0
                divs    D4,D0

                move.w  D3,D1
                sub.w   D0,D1

                move.w  #clip_x_max,D0

* After check *
                tst.w   D1
                bmi     clip_failed
                cmp.w   #clip_y_max,D1
                bgt     clip_failed

clip_up_1:      btst    #1,D5
                beq.s   clip_down_1

* Punkt oben clippen *

                move.w  D3,D7
                sub.w   D1,D7           * dy

                move.w  D2,D4
                sub.w   D0,D4           * dx

                neg.w   D1              * dy `

                muls    D4,D1
                divs    D7,D1

                add.w   D1,D0

                moveq   #0,D1

* After check *
                tst.w   D0
                bmi     clip_failed
                cmp.w   #clip_x_max,D0
                ble.s   clip_second_point
                bra     clip_failed

clip_down_1:
                btst    #0,D5
                beq.s   clip_second_point

* Punkt unten clippen *

                move.w  D1,D7
                sub.w   D3,D7           * dy

                move.w  D2,D4
                sub.w   D0,D4           * dx

                sub.w   #clip_y_max,D1  * dy'

                muls    D4,D1
                divs    D7,D1

                add.w   D1,D0

                move.w  #clip_y_max,D1

* After check *
                tst.w   D0
                bmi     clip_failed
                cmp.w   #clip_x_max,D0
                bgt     clip_failed

***** Punkt 2 clippen *****

clip_second_point:

                tst.w   D6              * muss der geclippt werden ??
                beq     clip_done       * nein, ueberspringen ...

                btst    #3,D6
                beq.s   clip_right_2

* Links clippen *

                move.w  D1,D7
                sub.w   D3,D7           * dy

                move.w  D0,D4
                sub.w   D2,D4           * dx

                move.w  D0,D2           * dx `

                muls    D7,D2
                divs    D4,D2

                move.w  D1,D3
                sub.w   D2,D3

                moveq   #0,D2

* After check *
                tst.w   D3
                bmi     clip_failed
                cmp.w   #clip_y_max,D3
                ble.s   clip_up_2
                bra     clip_failed

clip_right_2:   btst    #2,D6
                beq.s   clip_up_2

* Rechts clippen *

                move.w  D1,D7
                sub.w   D3,D7           * dy

                move.w  D2,D4
                sub.w   D0,D4           * dx

                move.w  #clip_x_max,D2  * dx `
                sub.w   D0,D2

                muls    D7,D2
                divs    D4,D2

                move.w  D1,D3
                sub.w   D2,D3

                move.w  #clip_x_max,D2

* After check *
                tst.w   D3
                bmi.s   clip_failed
                cmp.w   #clip_y_max,D3
                bgt.s   clip_failed

clip_up_2:      btst    #1,D6
                beq.s   clip_down_2

* Punkt oben clippen *

                move.w  D1,D7
                sub.w   D3,D7           * dy

                move.w  D2,D4
                sub.w   D0,D4           * dx

                move.w  D1,D3           * dy `

                muls    D4,D3
                divs    D7,D3

                move.w  D0,D2
                add.w   D3,D2

                moveq   #0,D3

* After check *
                tst.w   D2
                bmi.s   clip_failed
                cmp.w   #clip_x_max,D2
                ble.s   clip_done
                bra.s   clip_failed

clip_down_2:
                btst    #0,D6
                beq.s   clip_done

* Punkt unten clippen *

                move.w  D3,D7
                sub.w   D1,D7           * dy

                move.w  D0,D4
                sub.w   D2,D4           * dx

                sub.w   #clip_y_max,D3  * dy'

                muls    D4,D3
                divs    D7,D3

                add.w   D3,D2

                move.w  #clip_y_max,D3

* After check *
                tst.w   D2
                bmi.s   clip_failed
                cmp.w   #clip_x_max,D2
                bgt.s   clip_failed

clip_done:
                move.w  A3,D4
                move.w  A4,D7

                bsr.s   linie_now
                rts

clip_failed:
                move.w  A3,D4
                move.w  A4,D7
                rts
                

********** Vertikale Linie ***************

                *

clip_vertical:
* Links draussen ? *
                tst.w   D0
                bpl.s   not_left_v1
                rts

not_left_v1:
* Rechts draussen ? *
                cmp.w   #clip_x_max,D0
                ble.s   not_right_v1
                rts

not_right_v1:

* beide oben ? *
                tst.w   D1
                bpl.s   not_up_v1
                moveq   #0,D1
                tst.w   D3
                bpl.s   not_up_v2
                rts

not_up_v1:      tst.w   D3
                bpl.s   not_up_v2
                moveq   #0,D3
not_up_v2:

* beide unten draussen ? *
                move.w  #clip_y_max,D5

                cmp.w   D1,D5
                bge.s   not_down_v1
                move.w  D5,D1
                cmp.w   D3,D5
                bge.s   not_down_v2
                rts

not_down_v1:    cmp.w   D3,D5
                bge.s   not_down_v2
                move.w  D5,D3
not_down_v2:

                bsr.s   linie_now
                rts
                

********** Horizontale Linie **************

                *
clip_horizontal:

* oben draussen ? *

                tst.w   D1
                bpl.s   not_up_h2
                rts

not_up_h2:
* unten draussen ? *
                cmp.w   #clip_y_max,D1
                ble.s   not_down_h2
                rts

not_down_h2:
* beide Links draussen ? *
                tst.w   D0
                bpl.s   not_left_h1
                moveq   #0,D0
                tst.w   D2
                bpl.s   not_left_h2
                rts

not_left_h1:    tst.w   D2
                bpl.s   not_left_h2
                moveq   #0,D2
not_left_h2:

* beide rechts draussen ? *

                move.w  #clip_x_max,D5

                cmp.w   D0,D5
                bge.s   not_right_h1
                move.w  D5,D0
                cmp.w   D2,D5
                bge.s   not_right_h2
                rts

not_right_h1:   cmp.w   D2,D5
                bge.s   not_right_h2
                move.w  D5,D2
not_right_h2:

                bsr.s   linie_now
                rts
                

;--------- Mike leaves the building -----------------


linie_now:
                movem.l D4-D5/D7-A0,-(SP)

                cmp.w   D0,D2
                bgt.s   no_change

                exg     D0,D2
                exg     D1,D3
no_change:
                move.w  D1,D5
                mulu    D4,D5
                adda.l  D5,A0
                adda.w  D0,A0
                adda.w  D0,A0                     ; a0 = anfangsadresse

                sub.w   D0,D2                     ; dx (immer positiv)
                beq.s   vertical
                sub.w   D1,D3                     ; dy
                bpl.s   raufwaerts
                neg.w   D3
                neg.l   D4
raufwaerts:                                       ; dx,dy jetzt positiv
                cmp.w   D2,D3
                bge.s   steile
sanfte:
                move.w  D3,D1
                sub.w   D2,D1
                add.w   D1,D1                     ; inc2 = 2*(dy-dx)

                add.w   D3,D3                     ; inc1 = 2*dy

                move.w  D3,D0
                sub.w   D2,D0                     ; g = 2*dy - dx

sanfte_loop:
                move.w  D7,(A0)+
                tst.w   D0
                bmi.s   sanfte_min
                beq.s   sanfte_min

                adda.l  D4,A0
                add.w   D1,D0

                dbra    D2,sanfte_loop
                movem.l (SP)+,D4-D5/D7-A0
                rts

sanfte_min:
                add.w   D3,D0

                dbra    D2,sanfte_loop
                movem.l (SP)+,D4-D5/D7-A0
                rts

;---------------

steile:
                move.w  D2,D1
                sub.w   D3,D1
                add.w   D1,D1                     ; inc2 = 2*(dx-dy)

                add.w   D2,D2                     ; inc1 = 2*dx

                move.w  D2,D0
                sub.w   D3,D0                     ; g = 2*dx - dy

steile_loop:
                move.w  D7,(A0)
                adda.l  D4,A0
                tst.w   D0
                bmi.s   steile_min
                beq.s   steile_min

                addq.l  #2,A0
                add.w   D1,D0

                dbra    D3,steile_loop
                movem.l (SP)+,D4-D5/D7-A0
                rts

steile_min:
                add.w   D2,D0

                dbra    D3,steile_loop
                movem.l (SP)+,D4-D5/D7-A0
                rts

;---------------

vertical:
                sub.w   D1,D3
                bpl.s   vert_up

                neg.w   D3
                neg.l   D4
vert_up:
                move.w  D7,(A0)
                adda.l  D4,A0

                dbra    D3,vert_up
                movem.l (SP)+,D4-D5/D7-A0
                rts

