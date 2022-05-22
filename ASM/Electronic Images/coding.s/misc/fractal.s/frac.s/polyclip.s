* POLYGON CLIPPER (By Russ Payne, using Sutherland-Hodgman algorithm)
* A5 - Vertex list.
* D0 - Verteces.
** Returns with d0 verteces..
* Writes new coordinates to A5.
* (clipper at label PCLIP)
;#############################################
; NOW input = a6: col, no. of verts, verts..
; And is called polyclip..
;############################################
polyclip	lea	2(a6),A5	; Get polygon pointer.
		move.w	(A5)+,D1	; Get number of points.
		movea.l A5,A0		; Copy to A0.
		move.w	D1,D0		; And number of points.
		move.w	#201,D3 	; Dummy high value.
		move.w	#-1,D4		; Dummy low value.
		move.w	#320,D5 	; Same for X.
		move.w	#-1,D6
; Find X and Y maximums and minimums in poly.
findmic:	move.w	(A0)+,D7	; Get X coordinate.
		cmp.w	D7,D5		; Compare with high val.
		ble.s	nolesc		; Not smaller...  Skip.
		move.w	D7,D5		; Smaller...  Now new Min X.
nolesc: 	cmp.w	D7,D6		; Check if it's bigger.
		bge.s	nobic		; No...  Skip.
		move.w	D7,D6		; Yep, get this Max X.
nobic:		move.w	(A0)+,D7	; Get Y coordinate.
		cmp.w	D7,D3		; Compare with high val.
		ble.s	noles2		; Not smaller...  Skip.
		move.w	D7,D3		; Smaller...  Now new Min Y.
noles2: 	cmp.w	D7,D4		; Check if it's bigger.
		bge.s	clip		; No...  Skip.
		move.w	D7,D4		; Yep, get this Max Y.
clip:		dbra	D1,findmic	; Do for points.

		add.w	D5,D5
		add.w	D5,D5		; Min X * 4.
		add.w	D6,D6
		add.w	D6,D6		; Max X * 4.

		addq.w	#1,D0		; Adjust for clipper.
		move.l	a6,-(sp)
		bsr	clippit
		move.l	(sp)+,a6
		rts
;#################
clippit 	nop
		lea	L0000(PC),A1
		cmp.w	#$C7,D4
		ble.s	L0001
		pea	L001A(PC)
L0001:		tst.w	D3
		bpl.s	L0002
		pea	L000B(PC)
L0002:		cmp.w	#$04FC,D6
		ble.s	L0003
		pea	L003D(PC)
L0003:		tst.w	D5
		bpl.s	L0004
		pea	L002A(PC)
L0004:		cmp.w	D6,D5
		bvs.s	L0005
		cmp.w	D4,D3
		bvc.s	L0006
L0005:		pea	L0007(PC)
L0006:		rts
L0007:		move.w	D0,D6
		add.w	D6,D6
		subq.w	#1,D6
		move.l	#$3FFF,D3
		move.l	#-$3FFF,D4
		moveq	#0,D1
		movea.l A5,A6
L0008:		move.w	(A6)+,D1
		ext.l	D1
		bpl.s	L0009
		cmp.l	D4,D1
		bge.s	L000A
		move.w	D4,-2(A6)
		dbra	D6,L0008
		rts
L0009:		cmp.l	D3,D1
		ble.s	L000A
		move.w	D3,-2(A6)
L000A:		dbra	D6,L0008
		rts
L000B:		subq.w	#2,D0
		bgt.s	L000C
		rts
L000C:		movea.l A1,A6
		move.l	(A5)+,D1
		move.l	D1,D7
L000D:		move.l	(A5)+,D2
		tst.w	D1
		bmi.s	L0010
		tst.w	D2
		bmi.s	L0011
		move.l	D1,(A1)+
L000E:		move.l	D2,D1
		dbra	D0,L000D
		move.l	D7,D2
		tst.w	D1
		bmi.s	L0012
		tst.w	D2
		bmi.s	L0013
		move.l	D1,(A1)+
L000F:		movea.l A6,A5
		move.l	A1,D0
		sub.l	A6,D0
		asr.w	#2,D0
		lea	124(A6),A1
		rts
L0010:		tst.w	D2
		bmi.s	L000E
		bsr.s	L0014
		bra.s	L000E
L0011:		move.l	D1,(A1)+
		bsr.s	L0017
		bra.s	L000E
L0012:		tst.w	D2
		bmi.s	L000F
		bsr.s	L0014
		bra.s	L000F
L0013:		move.l	D1,(A1)+
		bsr.s	L0017
		bra.s	L000F
L0014:		move.w	D2,D3
		beq.s	L0016
		move.w	D1,D4
		sub.w	D1,D3
		neg.w	D4
		swap	D1
		swap	D2
		move.w	D2,D5
		sub.w	D1,D5
		beq.s	L0015
		muls	D5,D4
		divs	D3,D4
		add.w	D1,D4
		cmp.w	#$04FC,D4
		sne	D5
		andi.w	#1,D5
		add.w	D5,D4
		swap	D1
		swap	D2
		move.w	D4,(A1)+
		clr.w	(A1)+
		rts
L0015:		move.w	D1,(A1)+
		swap	D1
		swap	D2
		clr.w	(A1)+
L0016:		rts
L0017:		move.w	D1,D4
		beq.s	L0019
		move.w	D2,D3
		sub.w	D1,D3
		neg.w	D4
		swap	D1
		swap	D2
		move.w	D2,D5
		sub.w	D1,D5
		beq.s	L0018
		muls	D5,D4
		divs	D3,D4
		add.w	D1,D4
		tst.w	D4
		sne	D5
		ext.w	D5
		add.w	D5,D4
		swap	D1
		swap	D2
		move.w	D4,(A1)+
		clr.w	(A1)+
		rts
L0018:		move.w	D1,(A1)+
		swap	D1
		swap	D2
		clr.w	(A1)+
L0019:		rts
L001A:		subq.w	#2,D0
		bgt.s	L001B
		rts
L001B:		movea.l A1,A6
		move.l	(A5)+,D1
		move.l	D1,D7
		move.w	#$C7,D6
L001C:		move.l	(A5)+,D2
		cmp.w	D6,D1
		bgt.s	L001F
		cmp.w	D6,D2
		bgt.s	L0020
		move.l	D1,(A1)+
L001D:		move.l	D2,D1
		dbra	D0,L001C
		move.l	D7,D2
		cmp.w	D6,D1
		bgt.s	L0021
		cmp.w	D6,D2
		bgt.s	L0022
		move.l	D1,(A1)+
L001E:		movea.l A6,A5
		move.l	A1,D0
		sub.l	A6,D0
		asr.w	#2,D0
		lea	124(A6),A1
		rts
L001F:		cmp.w	D6,D2
		bge.s	L001D
		bsr.s	L0023
		bra.s	L001D
L0020:		move.l	D1,(A1)+
		bsr.s	L0026
		bra.s	L001D
L0021:		cmp.w	D6,D2
		bge.s	L001E
		bsr.s	L0023
		bra.s	L001E
L0022:		move.l	D1,(A1)+
		bsr.s	L0026
		bra.s	L001E
L0023:		move.w	D2,D3
		sub.w	D1,D3
		move.w	D1,D4
		sub.w	D6,D4
		move.w	D6,D5
		sub.w	D2,D5
		swap	D1
		swap	D2
		cmp.w	D4,D5
		bgt.s	L0025
		neg.w	D4
		move.w	D2,D5
		sub.w	D1,D5
		beq.s	L0024
		muls	D5,D4
		divs	D3,D4
		add.w	D1,D4
		swap	D1
		swap	D2
		move.w	D4,(A1)+
		move.w	D6,(A1)+
		rts
L0024:		move.w	D2,(A1)+
		move.w	D6,(A1)+
		swap	D1
		swap	D2
		rts
L0025:		move.w	D1,D4
		sub.w	D2,D4
		beq.s	L0024
		neg.w	D3
		muls	D5,D4
		divs	D3,D4
		add.w	D2,D4
		swap	D1
		swap	D2
		move.w	D4,(A1)+
		move.w	D6,(A1)+
		rts
L0026:		cmp.w	D6,D1
		beq.s	L0029
		move.w	D2,D3
		sub.w	D1,D3
		move.w	D6,D4
		sub.w	D1,D4
		move.w	D2,D5
		sub.w	D6,D5
		swap	D1
		swap	D2
		cmp.w	D4,D5
		bgt.s	L0028
		move.w	D2,D5
		sub.w	D1,D5
		beq.s	L0027
		muls	D5,D4
		divs	D3,D4
		add.w	D1,D4
		swap	D1
		swap	D2
		move.w	D4,(A1)+
		move.w	D6,(A1)+
		rts
L0027:		move.w	D2,(A1)+
		move.w	D6,(A1)+
		swap	D1
		swap	D2
		rts
L0028:		move.w	D1,D4
		sub.w	D2,D4
		beq.s	L0027
		neg.w	D5
		neg.w	D3
		muls	D5,D4
		divs	D3,D4
		add.w	D2,D4
		swap	D1
		swap	D2
		move.w	D4,(A1)+
		move.w	D6,(A1)+
L0029:		rts
L002A:		subq.w	#2,D0
		bgt.s	L002B
		rts
L002B:		movea.l A1,A6
		move.l	(A5)+,D1
		move.l	D1,D7
L002C:		move.l	(A5)+,D2
		tst.l	D1
		bmi.s	L002F
		tst.l	D2
		bmi.s	L0030
		move.l	D1,(A1)+
L002D:		move.l	D2,D1
		dbra	D0,L002C
		move.l	D7,D2
		tst.l	D1
		bmi.s	L0031
		tst.l	D2
		bmi.s	L0032
		move.l	D1,(A1)+
L002E:		movea.l A6,A5
		move.l	A1,D0
		sub.l	A6,D0
		asr.w	#2,D0
		lea	124(A6),A1
		rts
L002F:		tst.l	D2
		bmi.s	L002D
		bsr.s	L0033
		bra.s	L002D
L0030:		move.l	D1,(A1)+
		bsr.s	L0038
		bra.s	L002D
L0031:		tst.l	D2
		bmi.s	L002E
		bsr.s	L0033
		bra.s	L002E
L0032:		move.l	D1,(A1)+
		bsr.s	L0038
		bra.s	L002E
L0033:		move.w	D2,D3
		sub.w	D1,D3
		beq.s	L0035
		swap	D2
		move.w	D2,D4
		beq.s	L0037
		swap	D1
		move.w	D1,D5
		neg.w	D5
		cmp.w	D2,D5
		bgt.s	L0034
		neg.w	D3
		neg.w	D4
		muls	D4,D3
		move.w	D1,D4
		sub.w	D2,D4
		divs	D4,D3
		swap	D1
		swap	D2
		add.w	D2,D3
		clr.w	(A1)+
		move.w	D3,(A1)+
		rts
L0034:		muls	D5,D3
		move.w	D2,D4
		sub.w	D1,D4
		divs	D4,D3
		swap	D1
		swap	D2
		add.w	D1,D3
		clr.w	(A1)+
		move.w	D3,(A1)+
		rts
L0035:		swap	D2
		tst.w	D2
		beq.s	L0036
		clr.w	(A1)+
		move.w	D1,(A1)+
L0036:		swap	D2
		rts
L0037:		swap	D2
		rts
L0038:		move.w	D2,D3
		sub.w	D1,D3
		beq.s	L003A
		swap	D1
		move.w	D1,D4
		beq.s	L003C
		swap	D2
		move.w	D2,D5
		neg.w	D5
		cmp.w	D1,D5
		bgt.s	L0039
		neg.w	D4
		muls	D4,D3
		move.w	D2,D4
		sub.w	D1,D4
		divs	D4,D3
		swap	D1
		swap	D2
		add.w	D1,D3
		clr.w	(A1)+
		move.w	D3,(A1)+
		rts
L0039:		neg.w	D3
		muls	D5,D3
		move.w	D1,D4
		sub.w	D2,D4
		divs	D4,D3
		swap	D1
		swap	D2
		add.w	D2,D3
		clr.w	(A1)+
		move.w	D3,(A1)+
		rts
L003A:		swap	D1
		tst.w	D1
		beq.s	L003B
		clr.w	(A1)+
		move.w	D2,(A1)+
L003B:		swap	D1
		rts
L003C:		swap	D1
		rts
L003D:		subq.w	#2,D0
		bgt.s	L003E
		rts
L003E:		movea.l A1,A6
		move.l	(A5)+,D1
		move.l	D1,D7
		movea.w #$04FC,A2
		moveq	#-1,D6
		move.w	A2,D6
		swap	D6
L003F:		move.l	(A5)+,D2
		cmp.l	D6,D1
		bgt.s	L0042
		cmp.l	D6,D2
		bgt.s	L0043
		move.l	D1,(A1)+
L0040:		move.l	D2,D1
		dbra	D0,L003F
		move.l	D7,D2
		cmp.l	D6,D1
		bgt.s	L0044
		cmp.l	D6,D2
		bgt.s	L0045
		move.l	D1,(A1)+
L0041:		movea.l A6,A5
		move.l	A1,D0
		sub.l	A6,D0
		asr.w	#2,D0
		lea	124(A6),A1
		rts
L0042:		cmp.l	D6,D2
		bgt.s	L0040
		bsr.s	L0046
		bra.s	L0040
L0043:		move.l	D1,(A1)+
		bsr.s	L004B
		bra.s	L0040
L0044:		cmp.l	D6,D2
		bgt.s	L0041
		bsr.s	L0046
		bra.s	L0041
L0045:		move.l	D1,(A1)+
		bsr.s	L004B
		bra.s	L0041
L0046:		move.w	D2,D3
		sub.w	D1,D3
		beq.s	L0049
		swap	D2
		swap	D1
		move.w	A2,D5
		sub.w	D2,D5
		beq.s	L0048
		move.w	D1,D4
		sub.w	A2,D4
		cmp.w	D4,D5
		bgt.s	L0047
		neg.w	D4
		muls	D4,D3
		move.w	D2,D4
		sub.w	D1,D4
		divs	D4,D3
		swap	D1
		swap	D2
		add.w	D1,D3
		move.w	A2,(A1)+
		move.w	D3,(A1)+
		rts
L0047:		neg.w	D3
		muls	D5,D3
		move.w	D1,D4
		sub.w	D2,D4
		divs	D4,D3
		swap	D1
		swap	D2
		add.w	D2,D3
		move.w	A2,(A1)+
		move.w	D3,(A1)+
		rts
L0048:		swap	D1
		swap	D2
		rts
L0049:		swap	D2
		cmp.w	A2,D2
		beq.s	L004A
		move.w	A2,(A1)+
		move.w	D1,(A1)+
L004A:		swap	D2
		rts
L004B:		move.w	D2,D3
		sub.w	D1,D3
		beq.s	L004E
		swap	D2
		swap	D1
		move.w	A2,D4
		sub.w	D1,D4
		beq.s	L004D
		move.w	D2,D5
		sub.w	A2,D5
		cmp.w	D4,D5
		bgt.s	L004C
		muls	D4,D3
		move.w	D2,D4
		sub.w	D1,D4
		divs	D4,D3
		swap	D1
		swap	D2
		add.w	D1,D3
		move.w	A2,(A1)+
		move.w	D3,(A1)+
		rts
L004C:		neg.w	D3
		neg.w	D5
		muls	D5,D3
		move.w	D1,D4
		sub.w	D2,D4
		divs	D4,D3
		swap	D1
		swap	D2
		add.w	D2,D3
		move.w	A2,(A1)+
		move.w	D3,(A1)+
		rts
L004D:		swap	D1
		swap	D2
		rts
L004E:		swap	D1
		cmp.w	A2,D1
		beq.s	L004F
		move.w	A2,(A1)+
		move.w	D2,(A1)+
L004F:		swap	D1
		rts
L0000:		ds.w	310
