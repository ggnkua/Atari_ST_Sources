	* music player v1.0
	* code by Larry Lamer of B.A.T.
	* uses: a7,$4da,d0
	* .mus files ripped by Zippy of the Medway Boys
 	
	move.w #32,-(sp)
	trap #1
	lea 6(sp),sp
	move.l $4da,old
	moveq #1,d0
	jsr musik
	move.l #musik+8,$4da
	move.w #7,-(sp)
	trap #1
	lea 2(sp),sp
	move.l old,$4da
	clr.l -(sp)
	trap #1
old 	dc.l 0
musik	incbin "rings2.mus"
