

ANIMATEDOORSMAX	equ	32			; maximale anzahl gleichzeitig animierter tueren

ADFLAG		equ	0
ADRELPOINTER	equ	2
ADBYTES		equ	6

ANIMATELIFTSMAX	equ	8

ALFLAG		equ	0
ALRELPOINTER	equ	2
ALBYTES		equ	6






		text



; ---------------------------------------------------------
; tueren animieren
animateDoors
		lea	adData,a0
		movea.l	levelPtr,a1
		moveq	#ANIMATEDOORSMAX-1,d0
adLoop
		tst.w	ADFLAG(a0)
		beq.s	adSkipDoor
		move.l	ADRELPOINTER(a0),d1
		beq.s	adSkipDoor
		movea.l	d1,a2
		adda.l	a1,a2
		bsr.s	adOneDoor
adSkipDoor
		addq.l	#ADBYTES,a0
		dbra	d0,adLoop
adOut
		rts


; ---------------------------------------------------------
; einzelne tuer animieren
; a0 = struktur adData fuer aktuelle tuer
; a1 = levelPtr
; a2 = (absoluter) pointer auf tuer
; belegt: d0
adOneDoor
		move.w	DOORSTATUS(a2),d1
		btst	#1,d1
		bne.s	adOpenDoor
		btst	#2,d1
		bne.s	adCloseDoor
		btst	#3,d1
		bne	adWaitDoor

		rts


; a0 = struktur adData fuer aktuelle tuer
; a1 = levelPtr
; a2 = (absoluter) pointer auf tuer
; d1 = doorstatus
; belegt: d0
adOpenDoor
		bset	#0,d1
		move.w	DOORLINE+10(a2),d2	; h1 ([15..0] von line_flag_1)
		add.w	vblTime20,d2
		cmp.w	DOORH2(a2),d2		; ende erreicht?
		blt.s	adOk

	; tuer ist jetzt ganz geoeffnet worden, zugehoeriges sample abspielen

; todo		movem.l	d0-a6,-(sp)
;                movem.l door_pts(A1),D0-D1
;                moveq   #snd_door_rastet,D2
;                bsr     init_sam_dist
;		movem.l	(sp)+,d0-a6

		bclr	#1,d1			; statusbit "oeffnen" loeschen
		move.w	DOORH2(a2),d2		; aktuelle unterkante auf hoechstmoegliche setzen
		tst.w	DOORAUTOCLOSE(a2)	; soll sich tuer automatisch schliessen?
		bne.s	adSetOTimeDoor		; ja -> dann flags entsprechend setzen

		clr.w	ADFLAG(a0)		; tuer ist fertig animiert -> aus der animationsliste loeschen
		bra.s	adOk			; und aktuelle werte noch festschreiben

adSetOTimeDoor
		bset	#3,d1			; statusbit "warten" setzen
		moveq	#20,d3
		mulu.w	DOOROTIME(a2),d3	; zeit fuer status "warten" holen (zeit auf 50 vbl/sek. bezogen)
		move.w	d3,DOORCOUNT(a2)	; zeit in msek. fuer "warten" setzen
		bra.s	adOk


; a0 = struktur adData fuer aktuelle tuer
; a1 = levelPtr
; a2 = (absoluter) pointer auf tuer
; d1 = doorstatus
; belegt: d0
adCloseDoor
		tst.w	DOORUNDER(a2)
		beq.s	adcdCanClose

		move.w	DOORLINE+10(a2),d2	; h1 (aktuelle hoehe der unterkante)
		subi.w	#PLAYERPIXHEIGHT,d2
		cmp.w	DOORH1(a2),d2
		blt.s	adcdCanClose

		move.w	#%10,DOORSTATUS(a2)
		rts

adcdCanClose
		bclr	#0,d1
		move.w	DOORLINE+10(a2),d2
		sub.w	vblTime20,d2
		cmp.w	DOORH1(a2),d2
		bgt.s	adOk

		move.w	DOORH1(a2),d2
		bclr	#2,d1
		clr.w	ADFLAG(a0)

adOk
		move.w	d2,DOORLINE+10(a2)
		move.w	d2,DOORLINE+10+20(a2)
		move.w	d2,DOORLINE+10+40(a2)
		move.w	d2,DOORLINE+10+60(a2)
		move.w	d1,DOORSTATUS(a2)

		rts


; a0 = struktur adData fuer aktuelle tuer
; a1 = levelPtr
; a2 = (absoluter) pointer auf tuer
; d1 = doorstatus
; belegt: d0
adWaitDoor
		move.w	DOORCOUNT(a2),d2
		sub.w	vblTime1000,d2
		bmi.s	adwdEnd

		move.w	d2,DOORCOUNT(a2)
		bra.s	adwdOut

adwdEnd
		move.w	#%101,DOORSTATUS(a2)

		tst.w	DOORUNDER(a2)
		beq.s	adwdCanClose

	; tuer soll geschlossen werden, spieler ist aber darunter -> sample abspielen

; todo                move.w  D2,-(SP)
;                movem.l door_pts(A1),D0-D1
;                moveq   #snd_door_rastet,D2
;                bsr     init_sam_dist
;                move.w  (SP)+,D2

		bra.s	adwdOut

adwdCanClose
		nop
; todo                move.w  D2,-(SP)
;                movem.l door_pts(A1),D0-D1
;                moveq   #snd_door_close,D2
;                bsr     init_sam_dist
;                move.w  (SP)+,D2

adwdOut
		rts





; ---------------------------------------------------------
; lifte animieren
animateLifts
		lea	alData,a0
		movea.l	levelPtr,a1
		moveq	#ANIMATELIFTSMAX-1,d0
alLoop
		tst.w	ALFLAG(a0)
		beq.s	alSkipLift
		move.l	ALRELPOINTER(a0),d1
		beq.s	alSkipLift
		movea.l	d1,a2
		adda.l	a1,a2
		bsr.s	alOneLift
alSkipLift
		addq.l	#ADBYTES,a0
		dbra	d0,alLoop
alOut
		rts


; ---------------------------------------------------------
; einzelnen lift animieren
; a0 = struktur alData fuer aktuellen lift
; a1 = levelPtr
; a2 = (absoluter) pointer auf lift
; belegt: d0
alOneLift
		move.w	LIFTSTATUS(a2),d1
		btst	#1,d1
		bne.s	alOpenLift
		btst	#2,d1
		bne.s	alCloseLift
		btst	#3,d1
		bne	alWaitLift

		rts


; a0 = struktur alData fuer aktuellen lift
; a1 = levelPtr
; a2 = (absoluter) pointer auf lift
; d1 = doorstatus
; belegt: d0
alOpenLift
		bset	#0,d1
		move.w	LIFTLINE+12(a2),d2	; aktuelles h2
		move.b	LIFTLINE+19(a2),d5	; aktuelles yoffset
		move.w	vblTime20,d4
		add.w	d4,d2
		sub.b	d4,d5			; yoffset angleichen
		cmp.w	LIFTH2(a2),d2
		blt.s	alOk

	; der lift hat seine obere position erreicht ...

; todo		movem.l	d0-a6,-(sp)
;                movem.l door_pts(A1),D0-D1
;                moveq   #snd_door_rastet,D2
;                bsr     init_sam_dist
;		movem.l	(sp)+,d0-a6

		move.w	LIFTT1(a2),d5		; original yoffset holen
		move.w	LIFTH2(a2),d2
		bclr	#1,d1
		tst.w	LIFTOTIME(a2)
		bne.s	alSetOTimeLift

		clr.w	ALFLAG(a0)
		bra.s	alOk

alSetOTimeLift
		bset	#3,d1
		moveq	#20,d3
		mulu.w	LIFTOTIME(a2),d3
		move.w	d3,LIFTCOUNT(a2)
		bra.s	alOk


; a0 = struktur alData fuer aktuellen lift
; a1 = levelPtr
; a2 = (absoluter) pointer auf lift
; d1 = doorstatus
; belegt: d0
alCloseLift
		bclr	#0,d1
		move.w	LIFTLINE+12(a2),d2	; aktuelles h2
		move.b	LIFTLINE+19(a2),d5	; akutelles yoffset

		move.w	vblTime20,d3
		sub.w	d3,d2
		add.w	d3,d5
		cmp.w	LIFTH1(a2),d2
		bgt.s	alOk

		move.w	LIFTH1(a2),d2
		sub.w	LIFTH2(a2),d5
		add.w	LIFTT1(a2),d5
		bclr	#2,d1
		clr.w	ALFLAG(a0)

alOk
		move.w	d2,LIFTLINE+12(a2)
		move.w	d2,LIFTLINE+12+20(a2)
		move.w	d2,LIFTLINE+12+40(a2)
		move.w	d2,LIFTLINE+12+60(a2)
		move.b	d5,LIFTLINE+19(a2)
		move.b	d5,LIFTLINE+19+20(a2)
		move.b	d5,LIFTLINE+19+40(a2)
		move.b	d5,LIFTLINE+19+60(a2)
		move.w	d1,LIFTSTATUS(a2)

	; jetzt die hoehe des zugehoerigen sector fields anpassen...

		add.w	d2,d2
		addi.w	#PLAYERPIXHEIGHT*2,d2
		movea.l	LIFTSECPTR(a2),a2
		adda.l	levelPtr,a2
		neg.w 	d2
		move.w	d2,SFSH(a2)

		rts


; a0 = struktur alData fuer aktuellen lift
; a1 = levelPtr
; a2 = (absoluter) pointer auf lift
; d1 = doorstatus
; belegt: d0
alWaitLift
		move.w	LIFTCOUNT(a2),d2
		sub.w	vblTime1000,d2
		bmi.s	alwlEnd

		move.w	d2,LIFTCOUNT(a2)
		bra.s	alwlOut
alwlEnd
		move.w	#%101,LIFTSTATUS(a2)

; todo                move.w  D2,-(SP)
;                movem.l door_pts(A1),D0-D1
;                moveq   #snd_door_close,D2
;                bsr     init_sam_dist
;                move.w  (SP)+,D2
alwlOut
		rts





		data




		bss



adData		ds.b	ADBYTES*ANIMATEDOORSMAX
alData		ds.b	ALBYTES*ANIMATELIFTSMAX















