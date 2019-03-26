
* ---------------------------------------------
* 'Degas_PC1_Decode'
* This routine decompresses a compressed low
* resolution DEGAS PC1 picture. Entered with
* the following...
*
*	A1 = Picture Start
*	A0 = Target Memory
*

Degas_PC1_Decode

		move.l	a0,-(sp)	* Swap! Bring into line with Pix decode
		move.l	a1,a0		* routines (ie. entry parameters!)
		move.l	(sp)+,a1

		move.l	a1,.target

		LEA		34(a0),a0
		move.l	#199,d7

.loop		

* Bit Plane 0...

		BSR		.bp0

* Bit Plane 1...

		add.l	#2,.target
		BSR		.bp0

* Bit Plane 2...

		add.l	#2,.target
		BSR		.bp0

* Bit Plane 3...

		add.l	#2,.target
		BSR		.bp0

		add.l	#154,.target    * (Next Scan Line)	
		DBRA	d7,.loop
	
		RTS

* - - - - - - - - - - - - - - - - - - - - -

* Bit Plane Decode...

.bp0	LEA		.scanline,a1

.bp0_1	move.l	#0,d0
		move.b	(a0)+,d0	* Command
		cmp.b	#128,d0
		BEQ.s	.bp0_next
		tst.b	d0
		BPL.s	.bp0_2
		neg.b	d0
		BRA.s	.bp0_3		* Replicate?

* Image...

.bp0_2	move.b	(a0)+,(a1)+
		DBRA	d0,.bp0_2
		BRA.s	.bp0_next

* Replicate...

.bp0_3	move.b	(a0),(a1)+
		DBRA	d0,.bp0_3
		LEA		1(a0),a0

.bp0_next
		cmp.l	#.scanline+40,a1
		BMI.s	.bp0_1

* Paste Scan line to target...

		LEA		.scanline,a2
		move.l	.target,a1
		rept	20
		move.w	(a2)+,(a1)
		LEA		8(a1),a1
		endr

		RTS

.target		dc.l	0

.scanline	ds.b	48
