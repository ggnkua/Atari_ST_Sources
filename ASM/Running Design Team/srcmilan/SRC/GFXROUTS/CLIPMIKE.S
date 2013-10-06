

CLIPPINGMAXX	equ	0
CLIPPINGMAXY	equ	2


		text


; ---------------------------------------------------------
; lineWithClipping
; ---------------------------------------------------------

; d0 = x1
; d1 = y1
; d2 = x2
; d3 = y2
; d4 = screenoffset (line)
; d7 = color
; a0 = screenadresse
; clippingData

lineWithClipping

		lea	clippingData,a1

		cmp.w	d0,d2
		beq.s	lwcClipVertical
		cmp.w	d1,d3
		beq.s	lwcClipHorizontal

lwcNormalLine

	; window code fuer punkt 1 nach d5

		moveq	#0,d5

		move.w	d0,d5			; xmin
		add.l	d5,d5
		move.w	CLIPPINGMAXX(a1),d5	; xmax
		sub.w	d0,d5
		add.l	d5,d5
		move.w	d1,d5			; ymin
		add.l	d5,d5
		move.w	CLIPPINGMAXY(a1),d5	; ymax
		sub.w	d1,d5
		add.l	d5,d5
		swap	d5

	; window code fuer punkt 2 nach d6

		moveq	#0,d6

		move.w	d2,d6			; xmin
		add.l	d6,d6
		move.w	CLIPPINGMAXX(a1),d6	; xmax
		sub.w	d2,d6
		add.l	d6,d6
		move.w	d3,d6			; ymin
		add.l	d6,d6
		move.w	CLIPPINGMAXY(a1),d6	; ymax
		sub.w	d3,d6
		add.l	d6,d6
		swap	d6

		movea.w	d4,a3			; lineoffset
		move.w	d7,a4			; color

		move.w	d6,d7
		and.w	d5,d7
		bne.s	lwcOut

lwcClippingNow

	; bits:
	; 0 = unten
	; 1 = oben
	; 2 = rechts
	; 3 = links

	; clipping fuer punkt 1

		tst.w	d5			; muss geclippt werden?
		beq.s	lwccnPoint2

		btst	#3,d5
		beq.s	lwccnP1NoLeft

	; links clippen

lwccnP1Left
		move.w	d3,d7		; y2
		subq.w	d1,d7		; d7 = dy
		move.w	d2,d4		; x2
		sub.w	d0,d4		; d4 = dx

		move.w	d2,d0
		muls	d7,d0
		divs	d4,d0

		move.w	d3,d1
		sub.w	d0,d1
		moveq	#0,d0

		tst.w	d1
		bmi.s	lwcOut			; clipping failed
		cmp.w	CLIPPINGMAXY(a1),d1
		ble.s	lwccnP1Up

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






lwcOut

		rts



		data




		bss


clippingData	ds.w	1
		ds.w	1

