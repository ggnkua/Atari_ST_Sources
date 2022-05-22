;############################################################
;  BACKFACES culled in shading algorithm
;  Mainly Jose Cummin's work.
;  Includes Russ Payne's polyclip algorithm..
;  Input in Poly (not Perspectived..)
dark	equ	16
bright	equ	15
planeset:
	lea	poly(pc),a0
	jsr	shades
	beq	alok
	rts
alok	move.l	#$4000,d0
	add.w	0(a0),d0	;0..$4000..$8000
	blt	oflow
	lsl.l	#5,d0		;0..15	IN HIGH WORD
	rol.w	#2,d0		;0,1,2,3 in LSB of low word..
	and.w	#$3,d0		;0,1,2,3 in LSB of low word.
	beq	solid
	move.w	d0,d1		;d1=1,2,3 in MSB of low word.
	swap	d0		;0..15 in low word
	move.w	d0,d2		;for *3
	add.w	d0,d0
	add.w	d2,d0		;0..45	 in low word
	add.w	d1,d0		;1..48	in low word..
	add.w	#15,d0		;16..63 in low word..
	bra	ldun
solid	swap	d0
	bra	ldun
oflow	move.w	0(a0),d0
	blt	night
	move.w	#bright,d0
	bra	ldun
night	move.w	#dark,d0
ldun	move.w	d0,0(a0)
;##########
dopoly:				;no shading, so colour must be preset..
	lea	polxy(pc),a6
	move.l	(a0)+,d7	;points
	move.l	d7,(a6)+
;###########	
perspec:	move.w	(a0)+,d5
		move.w	(a0)+,d4
		move.w	(a0)+,d3	;take x,y,z resp.
		add.w	#horizon,d3

		ext.l	D4
		ext.l	D5
		lsl.l	#8,D4		; Scale up.
		lsl.l	#8,D5		; Scale up.
		divs	D3,D5		; And do perspective (/ Z + Horizon).
		divs	D3,D4		; And do perspective (/ Z + Horizon).

		add.w	#scx,D5
		add.w	#scy,D4

		move.w	D5,(A6)+	; Store x.
		move.w	D4,(A6)+	; Store y.

		dbra	D7,perspec	; Next point.

cont_face:
	
		lea	polxy(pc),a6	;ready..
;###############
		jsr	polyclip	;returns no. of edges in d0
		cmp.w	#3,d0
		blt	noface
		move.w	d0,d7		;keep actual no. of faces.
		subq	#1,d0		;for DBRA
		add.w	D7,D7
		add.w	D7,D7		; * 4 for duplicate pointer.
		movea.l A5,A0		; Start of list in A0.
		movea.l A5,A3		; End of list in A3.
		adda.w	D7,A3		; Now duplicate pointer.
;###############################################################
****  RASTER CONVERT POLYGON  ****

		lea	divtab(PC),A2	; Get division table address.

; Find lowest Y and higest Y and make a duplicate points list.
		move.w	D0,D1		; Number of points.
		move.w	#201,D0 	; Dummy high value.
		moveq	#-1,D3		; Dummy low value.
findmin:	move.l	(A0)+,D4	; Get Y coordinate.
		cmp.w	D4,D0		; Compare with high val.
		ble.s	noless		; Not smaller...  Skip.
		move.w	D4,D0		; Smaller...  Now new MinY.
		movea.l A0,A1		; Get address from X.
noless: 	cmp.w	D4,D3		; Check if it's bigger.
		bge.s	nobig		; No...  Skip.
		move.w	D4,D3		; Yep, get this.
nobig:		move.l	D4,(A3)+	; To next coordinates and copy.
		dbra	D1,findmin	; Do for points.
		subq.w	#4,A1		; Adjust A1 because of (A0)+.
* A1 now contains address to right scan of table, from the X.
* D0 contains the minimum Y value.
* D3 contains maximum Y value.

		move.w	D0,starty	; Store beginning Y.
		sub.w	D0,D3		; Make now total Y's.
		move.w	D3,D1		; Duplicate for right edge.

; Point A0 to duplicate coordinates (second list).
		movea.l A1,A0		; Copy start pointer address to A0.
		adda.w	D7,A0		; Now point to duplicate coords.
* A0 now contains address to left scan of table, from the X.
* We now have A0 for delta X L calcs and A1 for delta X R calcs.
***  Process left edge.

		lea	lpoints(PC),A3	; Get left edge table address.

doleft:
; Get number of Y's.
		move.w	-2(A0),D0	; Get destination Y for left.
		sub.w	2(A0),D0	; For left edge get difference.
		blt	noface
		move.w	D0,D7

* D7 now contains the destination Y.
* D0 contains the Y difference for left edge.

; Left edge Delta.
		move.w	-4(A0),D4	; Get destination X.
		move.w	(A0),D5 	; Duplicate for start from screen.
		sub.w	D5,D4		; Difference of X's.
; D5 has start lX.

* (A2) Points to division table.
		add.w	D0,D0		; Make word access.
		lsl.w	#3,D4		; Delta X times 8. *new
		muls	0(A2,D0.w),D4	; Nab int and frac parts.
		move.w	D4,D6		; Fraction part in D6.
		swap	D4		; Swap for integer for ADDX.
; D4 contains frac and int.

		add.w	D5,D5		; Start X * 4.		*new
		add.w	D5,D5					*new

		sub.w	D7,D3		; Subtract for number of Y's.

		add.w	D7,D7
		move.w	D7,D0
		add.w	D7,D7
		add.w	D7,D0		; * 6 for each routine.
		lea	erouts(PC),A4	; Get end of routines address.
		suba.w	D0,A4		; And point to proper line.

		moveq	#0,D0		; Make sure D0 is clear.

; A3 points to raster scan convert table to write the left edge to.

		jmp	(A4)		; Jump to routines.

; ...  these routines.
; Fill table with left gradient addition results.
		REPT 199
		move.w	D5,(A3)+
		add.w	D6,D0
		addx.w	D4,D5
		ENDR
erouts:

		tst.w	D3
		ble.s	outl		; Exit if we've reached bottom.
		subq.w	#4,A0		; If not, move on.

		bra	doleft
outl:
		move.w	D5,(A3)+	; Cater for missing line.;Calculates plane coefficients A,B,C,D
		move.w	#319*4,(A3)+	  ; End of list - to fool Hline.


***  Now process right edge.

		lea	rpoints(PC),A3	; Get right edge table address.

doright:
; Get number of Y's.
		move.w	6(A1),D0	; Get destination Y for right.
		sub.w	2(A1),D0	; For left edge get difference.
		blt	noface
		move.w	D0,D7

* D7 now contains the destination Y.
* D0 contains the Y difference for right edge.

; Right edge Delta.
		move.w	4(A1),D4	; Get destination X.
		move.w	(A1),D5 	; Duplicate for start from screen.
		sub.w	D5,D4		; Difference of X's.
; D5 has start rX.

* (A2) Points to division table.
		add.w	D0,D0		; Make word access.
		lsl.w	#3,D4		; Delta X times 8. *new
		muls	0(A2,D0.w),D4	; Nab int and frac parts.
		move.w	D4,D6		; Get fraction.
		swap	D4		; Swap for integer for ADDX.
; D4 contains frac and int.

		add.w	D5,D5		; Start X * 4.	*new
		add.w	D5,D5				*new


		sub.w	D7,D1		; Subtract for number of Y's.

		add.w	D7,D7
		move.w	D7,D0
		add.w	D7,D7
		add.w	D7,D0		; * 6 for each routine.
		lea	rrouts(PC),A4	; Get end of routines.
		suba.w	D0,A4

		moveq	#0,D0		; Make sure D0 is clear.

; A3 points to raster scan convert table to write the right edge to.

		jmp	(A4)		; Jump to routines.

; ...  these routines.
; Fill table with right gradient addition results.
		REPT 199
		move.w	D5,(A3)+
		add.w	D6,D0
		addx.w	D4,D5
		ENDR
rrouts:

		tst.w	D1
		ble.s	outr		; Exit if we've reached bottom.
		addq.w	#4,A1		; If not, move on.

		bra	doright
outr:
		move.w	D5,(A3)+	; Cater for missing line.
		move.w	#1,(A3)+	; Fool Hline drawer X2>X1!
****  DRAW HLINES  ***

		move.w	rpoints+2(pc),d0
		sub.w	lpoints+2(pc),d0
		bmi	noface

; Set routines to colour.
		move.w	0(a6),D0   ; Colour
		cmpi.w	#15,D0
		bgt	a_hash
		add.w	D0,D0		; Word access.
		lea	coltab(PC),A0
		lea	col1(PC),A2
		adda.w	0(A0,D0.w),A2
		move.l	(A2)+,D4
		move.l	(A2)+,D5	; Colour data (8 bytes).
		lea	mcol1(PC),A0
		lea	mcol2(PC),A1
		move.l	(A2)+,D0
		move.l	(A2)+,D1	; Get instructions.
		move.l	D0,(A0)+	; Self modify 1st chunk thing.
		move.l	D1,(A0)+
		move.l	D0,(A1)+	; Self modify special case.
		move.l	D1,(A1)+
		lea	chunk2(PC),A0
		move.l	(A2)+,(A0)+	; Self modify end chunk.
		move.l	(A2)+,(A0)+


		movea.l scrn2(PC),A0
		lea	lpoints(PC),A3
		lea	rpoints(PC),A4
		move.w	starty(PC),D0
		add.w	D0,D0
		lea	yoffs(PC),A1
		adda.w	0(A1,D0.w),A0
		movea.l A0,A5

		lea	lefted(PC),A1
		lea	righted(PC),A2

		moveq	#-4,D7

drawit: 	move.w	(A3)+,D0
		and.w	D7,D0
		move.l	0(A1,D0.w),D0
		move.w	(A4)+,D2
		and.w	D7,D2
		move.l	0(A2,D2.w),D2
		add.w	D0,D2		; Number of chunks.
    
		beq	chunk1
		bgt	doned

drawit2:   
		adda.w	D0,A0		; Add screen offset (X)
		swap	D0		; Get mask.

		move.w	D0,D1		; Draw left edge.
		not.w	D1
mcol1:		or.w	D0,(A0)+
		and.w	D1,(A0)+
		and.w	D1,(A0)+
		and.w	D1,(A0)+
		asr.w	#1,D2		; /160 by 2 cos each chunk rout is 8 bytes.
		jmp	jumpit(PC,D2.w)

chunk20:	move.l	D4,(A0)+
		move.l	D5,(A0)+
chunk19:	move.l	D4,(A0)+
		move.l	D5,(A0)+
chunk18:	move.l	D4,(A0)+
		move.l	D5,(A0)+
chunk17:	move.l	D4,(A0)+
		move.l	D5,(A0)+
chunk16:	move.l	D4,(A0)+
		move.l	D5,(A0)+
chunk15:	move.l	D4,(A0)+
		move.l	D5,(A0)+
chunk14:	move.l	D4,(A0)+
		move.l	D5,(A0)+
chunk13:	move.l	D4,(A0)+
		move.l	D5,(A0)+
chunk12:	move.l	D4,(A0)+
		move.l	D5,(A0)+
chunk11:	move.l	D4,(A0)+
		move.l	D5,(A0)+
chunk10:	move.l	D4,(A0)+
		move.l	D5,(A0)+
chunk9: 	move.l	D4,(A0)+
		move.l	D5,(A0)+
chunk8: 	move.l	D4,(A0)+
		move.l	D5,(A0)+
chunk7: 	move.l	D4,(A0)+
		move.l	D5,(A0)+
chunk6: 	move.l	D4,(A0)+
		move.l	D5,(A0)+
chunk5: 	move.l	D4,(A0)+
		move.l	D5,(A0)+
chunk4: 	move.l	D4,(A0)+
		move.l	D5,(A0)+
chunk3: 	move.l	D4,(A0)+
		move.l	D5,(A0)+
		swap	D2
		move.w	D2,D3
jumpit: 	not.w	D3
chunk2: 	or.w	D2,(A0)+
		and.w	D3,(A0)+
		and.w	D3,(A0)+
		and.w	D3,(A0)+

		lea	160(A5),A5
		movea.l A5,A0
		move.w	(A3)+,D0	; (Drawit again) Saves one branch!  Russ.
		and.w	D7,D0
		move.l	0(A1,D0.w),D0
		move.w	(A4)+,D2
		and.w	D7,D2
		move.l	0(A2,D2.w),D2
		add.w	D0,D2		; Number of chunks.
		blt	drawit2
		bgt	doned		; If > 0 then poly crosses.

chunk1: 	adda.w	D0,A0		; Screen offset.
		swap	D0		; Get mask.
		swap	D2		; Get mask.
		and.w	D2,D0		; Combine both edges.
		move.w	D0,D1
		not.w	D1
mcol2:		or.w	D0,(A0)+
		and.w	D1,(A0)+
		and.w	D1,(A0)+
		and.w	D1,(A0)+
		lea	160(A5),A5
		movea.l A5,A0
		move.w	(A3)+,D0	; (Drawit again) Saves one branch!  Russ.
		and.w	D7,D0
		move.l	0(A1,D0.w),D0
		move.w	(A4)+,D2
		and.w	D7,D2
		move.l	0(A2,D2.w),D2
		add.w	D0,D2		; Number of chunks.
		blt	drawit2
		beq.s	chunk1
doned		rts
a_hash:

		add.w	D0,D0		; Word access.
		lea	coltab(PC),A0
		lea	cstart(PC),A2
		adda.w	0(A0,D0.w),A2
		move.l	(A2)+,D4
		move.l	(A2)+,D5	; Colour data (8 bytes).
		move.l	(A2)+,D6
		move.l	(A2)+,D7	; Rotated colour data or second hash.

		movea.l scrn2(PC),A0
		lea	lpoints(PC),A3
		lea	rpoints(PC),A4
		move.w	starty(PC),D0
		btst	#0,D0
		beq.s	h_notodd
		exg	D6,D4
		exg	D7,D5
h_notodd:	add.w	D0,D0
		lea	yoffs(PC),A1
		adda.w	0(A1,D0.w),A0
		movea.l A0,A5

		lea	lefted(PC),A1
		lea	righted(PC),A2

		moveq	#-4,D3

hash_drawit:	move.w	(A3)+,D0
		and.w	D3,D0
		move.l	0(A1,D0.w),D0
		move.w	(A4)+,D2
		and.w	D3,D2
		move.l	0(A2,D2.w),D2
		add.w	D0,D2		; Number of chunks.

		beq	hash_chunk1
		bgt	hash_doned

hash_drawit2:	adda.w	D0,A0		; Add screen offset (X)
		swap	D0		; Get mask.

		move.w	D0,D1		; Draw left edge.
		swap	D0
		move.w	D1,D0

; First chunk...
		move.l	(A0),D1
		eor.l	D4,D1
		and.l	D0,D1
		eor.l	D1,(A0)+
		move.l	(A0),D1
		eor.l	D5,D1
		and.l	D0,D1
		eor.l	D1,(A0)+

		asr.w	#1,D2		; /160 by 2 cos each chunk rout is 8 bytes.
		jmp	hash_jumpit(PC,D2.w)

h_chunk20:	move.l	D4,(A0)+
		move.l	D5,(A0)+
h_chunk19:	move.l	D4,(A0)+
		move.l	D5,(A0)+
h_chunk18:	move.l	D4,(A0)+
		move.l	D5,(A0)+
h_chunk17:	move.l	D4,(A0)+
		move.l	D5,(A0)+
h_chunk16:	move.l	D4,(A0)+
		move.l	D5,(A0)+
h_chunk15:	move.l	D4,(A0)+
		move.l	D5,(A0)+
h_chunk14:	move.l	D4,(A0)+
		move.l	D5,(A0)+
h_chunk13:	move.l	D4,(A0)+
		move.l	D5,(A0)+
h_chunk12:	move.l	D4,(A0)+
		move.l	D5,(A0)+
h_chunk11:	move.l	D4,(A0)+
		move.l	D5,(A0)+
h_chunk10:	move.l	D4,(A0)+
		move.l	D5,(A0)+
h_chunk9:	move.l	D4,(A0)+
		move.l	D5,(A0)+
h_chunk8:	move.l	D4,(A0)+
		move.l	D5,(A0)+
h_chunk7:	move.l	D4,(A0)+
		move.l	D5,(A0)+
h_chunk6:	move.l	D4,(A0)+
		move.l	D5,(A0)+
h_chunk5:	move.l	D4,(A0)+
		move.l	D5,(A0)+
h_chunk4:	move.l	D4,(A0)+
		move.l	D5,(A0)+
h_chunk3:	move.l	D4,(A0)+
		move.l	D5,(A0)+

		move.l	D2,D1		; Draw left edge.
		swap	D1
hash_jumpit:	move.w	D1,D2
; Last chunk...
		move.l	(A0),D1
		eor.l	D4,D1
		and.l	D2,D1
		eor.l	D1,(A0)+
		move.l	(A0),D1
		eor.l	D5,D1
		and.l	D2,D1
		eor.l	D1,(A0)+

		lea	160(A5),A5
		movea.l A5,A0
		move.w	(A3)+,D0	; (Drawit again) Saves one branch!  Russ.
		and.w	D3,D0
		move.l	0(A1,D0.w),D0
		move.w	(A4)+,D2
		and.w	D3,D2
		move.l  0(A2,D2.w),D2
		add.w	D0,D2		; Number of chunks.
		blt	hash_drawit22
		bgt	hash_doned	; If > 0 then poly crosses.

hash_chunk1:	adda.w	D0,A0		; Screen offset.
		swap	D0		; Get mask.
		swap	D2		; Get mask.
		and.w	D2,D0		; Combine both (inverse) edges.
		move.w	D0,D1
		swap	D0
		move.w	D1,D0

; One chunk merge...
		move.l	(A0),D1
		eor.l	D4,D1
		and.l	D0,D1
		eor.l	D1,(A0)+
		move.l	(A0),D1
		eor.l	D5,D1
		and.l	D0,D1
		eor.l	D1,(A0)+

		lea	160(A5),A5
		movea.l A5,A0
		move.w	(A3)+,D0	; (Drawit again) Saves one branch!  Russ.
		and.w	D3,D0
		move.l	0(A1,D0.w),D0
		move.w	(A4)+,D2
		and.w	D3,D2
		move.l	0(A2,D2.w),D2
		add.w	D0,D2		; Number of chunks.
		beq	hash_chunk12
		bgt	hash_doned

********* Alternate second line...  Gets rid of EXG's.

hash_drawit22:	adda.w	D0,A0		; Add screen offset (X)
		swap	D0		; Get mask.

		move.w	D0,D1		; Draw left edge.
		swap	D0
		move.w	D1,D0

; First chunk...
		move.l	(A0),D1
		eor.l	D6,D1
		and.l	D0,D1
		eor.l	D1,(A0)+
		move.l	(A0),D1
		eor.l	D7,D1
		and.l	D0,D1
		eor.l	D1,(A0)+

		asr.w	#1,D2		; /160 by 2 cos each chunk rout is 8 bytes.
		jmp	hash_jumpit2(PC,D2.w)

h2_chunk20:	move.l	D6,(A0)+
		move.l	D7,(A0)+
h2_chunk19:	move.l	D6,(A0)+
		move.l	D7,(A0)+
h2_chunk18:	move.l	D6,(A0)+
		move.l	D7,(A0)+
h2_chunk17:	move.l	D6,(A0)+
		move.l	D7,(A0)+
h2_chunk16:	move.l	D6,(A0)+
		move.l	D7,(A0)+
h2_chunk15:	move.l	D6,(A0)+
		move.l	D7,(A0)+
h2_chunk14:	move.l	D6,(A0)+
		move.l	D7,(A0)+
h2_chunk13:	move.l	D6,(A0)+
		move.l	D7,(A0)+
h2_chunk12:	move.l	D6,(A0)+
		move.l	D7,(A0)+
h2_chunk11:	move.l	D6,(A0)+
		move.l	D7,(A0)+
h2_chunk10:	move.l	D6,(A0)+
		move.l	D7,(A0)+
h2_chunk9:	move.l	D6,(A0)+
		move.l	D7,(A0)+
h2_chunk8:	move.l	D6,(A0)+
		move.l	D7,(A0)+
h2_chunk7:	move.l	D6,(A0)+
		move.l	D7,(A0)+
h2_chunk6:	move.l	D6,(A0)+
		move.l	D7,(A0)+
h2_chunk5:	move.l	D6,(A0)+
		move.l	D7,(A0)+
h2_chunk4:	move.l	D6,(A0)+
		move.l	D7,(A0)+
h2_chunk3:	move.l	D6,(A0)+
		move.l	D7,(A0)+

		move.l	D2,D1		; Draw left edge.
		swap	D1
hash_jumpit2:	move.w	D1,D2
; Last chunk...
		move.l	(A0),D1
		eor.l	D6,D1
		and.l	D2,D1
		eor.l	D1,(A0)+
		move.l	(A0),D1
		eor.l	D7,D1
		and.l	D2,D1
		eor.l	D1,(A0)+

		lea	160(A5),A5
		movea.l A5,A0
		move.w	(A3)+,D0	; (Drawit again) Saves one branch!  Russ.
		and.w	D3,D0
		move.l	0(A1,D0.w),D0
		move.w	(A4)+,D2
		and.w	D3,D2
		move.l	0(A2,D2.w),D2
		add.w	D0,D2		; Number of chunks.
		blt	hash_drawit2
		bgt.s	hash_doned	; If > 0 then poly crosses.

hash_chunk12:	adda.w	D0,A0		; Screen offset.
		swap	D0		; Get mask.
		swap	D2		; Get mask.
		and.w	D2,D0		; Combine both (inverse) edges.
		move.w	D0,D1
		swap	D0
		move.w	D1,D0

; One chunk merge...
		move.l	(A0),D1
		eor.l	D6,D1
		and.l	D0,D1
		eor.l	D1,(A0)+
		move.l	(A0),D1
		eor.l	D7,D1
		and.l	D0,D1
		eor.l	D1,(A0)+

		lea	160(A5),A5
		movea.l A5,A0
		move.w	(A3)+,D0	; (Drawit again) Saves one branch!  Russ.
		and.w	D3,D0
		move.l	0(A1,D0.w),D0
		move.w	(A4)+,D2
		and.w	D3,D2
		move.l	0(A2,D2.w),D2
		add.w	D0,D2		; Number of chunks.
		blt	hash_drawit2
		beq	hash_chunk1
hash_doned:				; Here when we've drawn all lines.
noface: 				; Here when no more faces.
		rts
;################################################################
* COLOUR TABLE.
coltab: 	DC.W col1-cstart
		DC.W col2-cstart
		DC.W col3-cstart
		DC.W col4-cstart
		DC.W col5-cstart
		DC.W col6-cstart
		DC.W col7-cstart
		DC.W col8-cstart
		DC.W col9-cstart
		DC.W col10-cstart
		DC.W col11-cstart
		DC.W col12-cstart
		DC.W col13-cstart
		DC.W col14-cstart
		DC.W col15-cstart
		DC.W col16-cstart
; Hash colours...
		dc.w hash17-cstart
		DC.W hash1-cstart
		dc.w hash33-cstart
		dc.w hash18-cstart
		DC.W hash2-cstart
		dc.w hash34-cstart
		dc.w hash19-cstart
		DC.W hash3-cstart
		dc.w hash35-cstart
		dc.w hash20-cstart
		DC.W hash4-cstart
		dc.w hash36-cstart
		dc.w hash21-cstart
		DC.W hash5-cstart
		dc.w hash37-cstart
		dc.w hash22-cstart
		DC.W hash6-cstart
		dc.w hash38-cstart
		dc.w hash23-cstart
		DC.W hash7-cstart
		dc.w hash39-cstart
		dc.w hash24-cstart
		DC.W hash8-cstart
		dc.w hash40-cstart
		dc.w hash25-cstart
		DC.W hash9-cstart
		dc.w hash41-cstart
		dc.w hash26-cstart
		DC.W hash10-cstart
		dc.w hash42-cstart
		dc.w hash27-cstart
		DC.W hash11-cstart
		dc.w hash43-cstart
		dc.w hash28-cstart
		DC.W hash12-cstart
		dc.w hash44-cstart
		dc.w hash29-cstart
		DC.W hash13-cstart
		dc.w hash45-cstart
		dc.w hash30-cstart
		DC.W hash14-cstart
		dc.w hash46-cstart
		dc.w hash31-cstart
		DC.W hash15-cstart
		dc.w hash47-cstart
		dc.w hash32-cstart
		DC.W hash16-cstart
		dc.w hash48-cstart

* COLOUR DATA AND ROUTINES. > 15 is hash colours (and no slef-modifying).
cstart:
col1:		DC.L $00,$00
		and.w	D1,(A0)+
		and.w	D1,(A0)+
		and.w	D1,(A0)+
		and.w	D1,(A0)+
		and.w	D3,(A0)+
		and.w	D3,(A0)+
		and.w	D3,(A0)+
		and.w	D3,(A0)+
col2:		DC.L $FFFF0000,$00
		or.w	D0,(A0)+
		and.w	D1,(A0)+
		and.w	D1,(A0)+
		and.w	D1,(A0)+
		or.w	D2,(A0)+
		and.w	D3,(A0)+
		and.w	D3,(A0)+
		and.w	D3,(A0)+
col3:		DC.L $FFFF,$00
		and.w	D1,(A0)+
		or.w	D0,(A0)+
		and.w	D1,(A0)+
		and.w	D1,(A0)+
		and.w	D3,(A0)+
		or.w	D2,(A0)+
		and.w	D3,(A0)+
		and.w	D3,(A0)+
col4:		DC.L $FFFFFFFF,$00
		or.w	D0,(A0)+
		or.w	D0,(A0)+
		and.w	D1,(A0)+
		and.w	D1,(A0)+
		or.w	D2,(A0)+
		or.w	D2,(A0)+
		and.w	D3,(A0)+
		and.w	D3,(A0)+
col5:		DC.L $00,$FFFF0000
		and.w	D1,(A0)+
		and.w	D1,(A0)+
		or.w	D0,(A0)+
		and.w	D1,(A0)+
		and.w	D3,(A0)+
		and.w	D3,(A0)+
		or.w	D2,(A0)+
		and.w	D3,(A0)+
col6:		DC.L $FFFF0000,$FFFF0000
		or.w	D0,(A0)+
		and.w	D1,(A0)+
		or.w	D0,(A0)+
		and.w	D1,(A0)+
		or.w	D2,(A0)+
		and.w	D3,(A0)+
		or.w	D2,(A0)+
		and.w	D3,(A0)+
col7:		DC.L $FFFF,$FFFF0000
		and.w	D1,(A0)+
		or.w	D0,(A0)+
		or.w	D0,(A0)+
		and.w	D1,(A0)+
		and.w	D3,(A0)+
		or.w	D2,(A0)+
		or.w	D2,(A0)+
		and.w	D3,(A0)+
col8:		DC.L $FFFFFFFF,$FFFF0000
		or.w	D0,(A0)+
		or.w	D0,(A0)+
		or.w	D0,(A0)+
		and.w	D1,(A0)+
		or.w	D2,(A0)+
		or.w	D2,(A0)+
		or.w	D2,(A0)+
		and.w	D3,(A0)+
col9:		DC.L $00,$FFFF
		and.w	D1,(A0)+
		and.w	D1,(A0)+
		and.w	D1,(A0)+
		or.w	D0,(A0)+
		and.w	D3,(A0)+
		and.w	D3,(A0)+
		and.w	D3,(A0)+
		or.w	D2,(A0)+
col10:		DC.L $FFFF0000,$FFFF
		or.w	D0,(A0)+
		and.w	D1,(A0)+
		and.w	D1,(A0)+
		or.w	D0,(A0)+
		or.w	D2,(A0)+
		and.w	D3,(A0)+
		and.w	D3,(A0)+
		or.w	D2,(A0)+
col11:		DC.L $FFFF,$FFFF
		and.w	D1,(A0)+
		or.w	D0,(A0)+
		and.w	D1,(A0)+
		or.w	D0,(A0)+
		and.w	D3,(A0)+
		or.w	D2,(A0)+
		and.w	D3,(A0)+
		or.w	D2,(A0)+
col12:		DC.L $FFFFFFFF,$FFFF
		or.w	D0,(A0)+
		or.w	D0,(A0)+
		and.w	D1,(A0)+
		or.w	D0,(A0)+
		or.w	D2,(A0)+
		or.w	D2,(A0)+
		and.w	D3,(A0)+
		or.w	D2,(A0)+
col13:		DC.L $00,$FFFFFFFF
		and.w	D1,(A0)+
		and.w	D1,(A0)+
		or.w	D0,(A0)+
		or.w	D0,(A0)+
		and.w	D3,(A0)+
		and.w	D3,(A0)+
		or.w	D2,(A0)+
		or.w	D2,(A0)+
col14:		DC.L $FFFF0000,$FFFFFFFF
		or.w	D0,(A0)+
		and.w	D1,(A0)+
		or.w	D0,(A0)+
		or.w	D0,(A0)+
		or.w	D2,(A0)+
		and.w	D3,(A0)+
		or.w	D2,(A0)+
		or.w	D2,(A0)+
col15:		DC.L $FFFF,$FFFFFFFF
		and.w	D1,(A0)+
		or.w	D0,(A0)+
		or.w	D0,(A0)+
		or.w	D0,(A0)+
		and.w	D3,(A0)+
		or.w	D2,(A0)+
		or.w	D2,(A0)+
		or.w	D2,(A0)+
col16:		DC.L $FFFFFFFF,$FFFFFFFF
		or.w	D0,(A0)+
		or.w	D0,(A0)+
		or.w	D0,(A0)+
		or.w	D0,(A0)+
		or.w	D2,(A0)+
		or.w	D2,(A0)+
		or.w	D2,(A0)+
		or.w	D2,(A0)+

; HASH DEFINITIONS - Second hash is the 'rotated' hash.  Coukld do ROR's to get
; the other hash, but this allows weirdo hashes.
hstart
hash1:		dc.l	$55550000,$00000000,$aaaa0000,$00000000 
hash2:		dc.l	$aaaa5555,$00000000,$5555aaaa,$00000000
hash3:		dc.l	$5555ffff,$00000000,$aaaaffff,$00000000
hash4:		dc.l	$aaaaaaaa,$55550000,$55555555,$aaaa0000
hash5:		dc.l	$55550000,$ffff0000,$aaaa0000,$ffff0000
hash6:		dc.l	$aaaa5555,$ffff0000,$5555aaaa,$ffff0000
hash7:		dc.l	$5555ffff,$ffff0000,$aaaaffff,$ffff0000
hash8:		dc.l	$aaaaaaaa,$aaaa5555,$55555555,$5555aaaa
hash9:		dc.l	$55550000,$0000ffff,$aaaa0000,$0000ffff
hash10: 	dc.l	$aaaa5555,$0000ffff,$5555aaaa,$0000ffff
hash11: 	dc.l	$5555ffff,$0000ffff,$aaaaffff,$0000ffff
hash12: 	dc.l	$aaaaaaaa,$5555ffff,$55555555,$aaaaffff
hash13: 	dc.l	$55550000,$ffffffff,$aaaa0000,$ffffffff
hash14: 	dc.l	$aaaa5555,$ffffffff,$5555aaaa,$ffffffff
hash15: 	dc.l	$5555ffff,$ffffffff,$aaaaffff,$ffffffff
hash16: 	dc.l	$ffffffff,$ffffffff,$ffffffff,$ffffffff

hash17: 	dc.l	$00000000,$00000000,$aaaa0000,$00000000 
hash18: 	dc.l	$ffff0000,$00000000,$5555aaaa,$00000000
hash19: 	dc.l	$0000ffff,$00000000,$aaaaffff,$00000000
hash20: 	dc.l	$ffffffff,$00000000,$55555555,$aaaa0000
hash21: 	dc.l	$00000000,$ffff0000,$aaaa0000,$ffff0000
hash22: 	dc.l	$ffff0000,$ffff0000,$5555aaaa,$ffff0000
hash23: 	dc.l	$0000ffff,$ffff0000,$aaaaffff,$ffff0000
hash24: 	dc.l	$ffffffff,$ffff0000,$55555555,$5555aaaa
hash25: 	dc.l	$00000000,$0000ffff,$aaaa0000,$0000ffff
hash26: 	dc.l	$ffff0000,$0000ffff,$5555aaaa,$0000ffff
hash27: 	dc.l	$0000ffff,$0000ffff,$aaaaffff,$0000ffff
hash28: 	dc.l	$ffffffff,$0000ffff,$55555555,$aaaaffff
hash29: 	dc.l	$00000000,$ffffffff,$aaaa0000,$ffffffff
hash30: 	dc.l	$ffff0000,$ffffffff,$5555aaaa,$ffffffff
hash31: 	dc.l	$0000ffff,$ffffffff,$aaaaffff,$ffffffff
hash32: 	dc.l	$ffffffff,$ffffffff,$ffffffff,$ffffffff

hash33: 	dc.l	$ffff0000,$00000000,$aaaa0000,$00000000 
hash34: 	dc.l	$0000ffff,$00000000,$5555aaaa,$00000000
hash35: 	dc.l	$ffffffff,$00000000,$aaaaffff,$00000000
hash36: 	dc.l	$00000000,$ffff0000,$55555555,$aaaa0000
hash37: 	dc.l	$ffff0000,$ffff0000,$aaaa0000,$ffff0000
hash38: 	dc.l	$0000ffff,$ffff0000,$5555aaaa,$ffff0000
hash39: 	dc.l	$ffffffff,$ffff0000,$aaaaffff,$ffff0000
hash40: 	dc.l	$00000000,$0000ffff,$55555555,$5555aaaa
hash41: 	dc.l	$ffff0000,$0000ffff,$aaaa0000,$0000ffff
hash42: 	dc.l	$0000ffff,$0000ffff,$5555aaaa,$0000ffff
hash43: 	dc.l	$ffffffff,$0000ffff,$aaaaffff,$0000ffff
hash44: 	dc.l	$00000000,$ffffffff,$55555555,$aaaaffff
hash45: 	dc.l	$ffff0000,$ffffffff,$aaaa0000,$ffffffff
hash46: 	dc.l	$0000ffff,$ffffffff,$5555aaaa,$ffffffff
hash47: 	dc.l	$ffffffff,$ffffffff,$aaaaffff,$ffffffff
hash48: 	dc.l	$ffffffff,$ffffffff,$ffffffff,$ffffffff

;#################################################################
yoffs:
yoff		SET 0
		REPT 200
		DC.W yoff
yoff		SET yoff+160
		ENDR


sxsy:		DS.W 1
cxsy:		DS.W 1
maxy:		DC.W 0

mankl:		DC.W 0
mankr:		DC.W 0
divtab:
		DC.W 0
dival		SET 1
		REPT 200
		DC.W 32767/dival
dival		SET dival+1
		ENDR


; For edge and chunk calculations.

; Left edge masks & offsets.
lefted:
cchunk		SET 0
		REPT 20
		DC.W %1111111111111111,cchunk
		DC.W %111111111111111,cchunk
		DC.W %11111111111111,cchunk
		DC.W %1111111111111,cchunk
		DC.W %111111111111,cchunk
		DC.W %11111111111,cchunk
		DC.W %1111111111,cchunk
		DC.W %111111111,cchunk
		DC.W %11111111,cchunk
		DC.W %1111111,cchunk
		DC.W %111111,cchunk
		DC.W %11111,cchunk
		DC.W %1111,cchunk
		DC.W %111,cchunk
		DC.W %11,cchunk
		DC.W %1,cchunk
cchunk		SET cchunk+8
		ENDR
; Right edge masks & offsets.
righted:
cchunk		SET 0
		REPT 20
		DC.W %1000000000000000,-cchunk
		DC.W %1100000000000000,-cchunk
		DC.W %1110000000000000,-cchunk
		DC.W %1111000000000000,-cchunk
		DC.W %1111100000000000,-cchunk
		DC.W %1111110000000000,-cchunk
		DC.W %1111111000000000,-cchunk
		DC.W %1111111100000000,-cchunk
		DC.W %1111111110000000,-cchunk
		DC.W %1111111111000000,-cchunk
		DC.W %1111111111100000,-cchunk
		DC.W %1111111111110000,-cchunk
		DC.W %1111111111111000,-cchunk
		DC.W %1111111111111100,-cchunk
		DC.W %1111111111111110,-cchunk
		DC.W %1111111111111111,-cchunk
cchunk		SET cchunk+8
		ENDR

; For raster scan convert.
starty: 	DS.W 1		; Y start value.
lpoints:	DS.W 208	; Space for 200 X pairs left edge.
rpoints:	DS.W 208	; Space for 200 X pairs right edge.
poly		ds.w	60	; col,verts,x1,y1,z1....
polxy		ds.w	32	; col,verts,x1,y1,x2,y2.. etc
