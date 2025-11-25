
; Some of JEFF Minters stuff here !


Make_A_NON_Trasnparent_Object
	Move.w	d7,Num_Pixels(a4)
	Cmp.w	#0,d1
	Bpl.s	.No_Miny
	Sub.w	#0,d1
	Add.w	d1,d3
	Bgt.s	.Height_There
	Rts
.Height_There
	Neg.w	d1
	Mulu	d2,d1
	Lsl.l	#3,d1
	Lea	(a1,d1.l),a1
	Moveq	#0,d1
.No_Miny
	Add.w	#(N_Vdb)/2,d1

;	Add.w	#33,d1
	Asl.w	#1,d1
	Pea	16(a0)			; Next object must take into account the maximum number of phrases for an object header (Scaled=3 phrases)
	Movem.w	d0-d3,-(sp)		; Save coardinates,Phrases wide,Height (in full lines !  not half lines!)
	Clr.l	0(a0)
	Clr.l	4(a0)
	Clr.l	8(a0)
	Clr.l	12(a0)

	Move.l	a0,d5			; Save pointer to object in unused register
	Move.l	a1,d0			; Graphic data in data register
	moveq	#8,d1
	lsl.l	d1,d0			; shift into position
	and.l	#$fffff800,d0		; mask off junk
	move.l	d0,(a0)			; store

; This places the partial result in the correct spot in memory
; Then, in the next part, it 'or's the rest of the data in.
; Doing it all in registers would be faster, but I want to see the results

	Moveq	#16,d0
	Add.l	d5,d0			; Pointer to next object			
	move.l	d0,d2			; Save pointer for bottom half
	moveq	#11,d1
	lsr.l	d1,d0			; shift for top part
	or.l	d0,(a0)+		; or in the new data

; do the bottom half in the next long word

	moveq	#21,d1
	lsl.l	d1,d2			; shift for bottom part
	and.l	#$ff000000,d2		; mask off junk
	move.l	d2,(a0)			; store (prematurely)

; Same comment here about doing this in registers instead of memory

	Move.w	3*2(sp),d0		; Get height of object

	moveq	#14,d1
	lsl.l	d1,d0			; shift it again
	or.l	d0,(a0)			; or in the new data
	Moveq	#0,d0
	Move.w	1*2(sp),d0		; Y in d0
	Ext.l	d0
	Asl.l	#3,d0			; Shift 1 extra coz of halflines-non interlace !
	And.l	#%11111111111000,D0
	Or.l	d0,(a0)+		; Object type is scaled object


; That completes another long word, First phrase done

	Moveq	#0,d0
	Move.w	2*2(sp),d0		; Retreive phrase width
	Move.l	d0,d1
	Lsr.l	#4,d1			; Drop low bits
	move.l	d1,(a0)+
	Tst.b	Reflect_Object_Flag(a4)
	Beq.s	.No_Reflect
	Or.l	#1<<(45-32),-4(a0)	; Set transparent
.No_Reflect
	And.w	#%1111,d0
	Move.l	d0,d5
	Ror.l	#4,d5

; Insert dwidth
	Moveq	#0,d0	
	Move.w	2*2(sp),d1
	Or.w	d1,d0			; DWIDTH ? same as IwIDTH

; Insert pitch
	moveq	#3,d1			; make room for pitch
	lsl.l	d1,d0
	ori.l	#$1,d0

; Insert depth
	moveq	#3,d1			; make room for depth

	lsl.l	d1,d0

	Move.w	Num_Pixels(a4),d1
	Or.w	d1,d0	

; Insert xpos
	moveq	#12,d1			; make room for xpos
	lsl.l	d1,d0
	Move.w	0*2(sp),d1
	And.w	#%111111111111,d1
	Add.w	d1,d0
	
; Finally store the data
	Or.l	d5,d0
	move.l	d0,(a0)+
	Addq.l	#8,sp
	Move.l	(sp)+,a0
	Addq.w	#1,Num_Objects_To_Display(a4)
	rts


Make_An_Object
	Move.w	d7,Num_Pixels(a4)
	Move.w	d6,Pal_Number(a4)
	Cmp.w	#0,d1
	Bpl.s	.No_Miny
	Sub.w	#0,d1
	Add.w	d1,d3
	Bgt.s	.Height_There
	Rts
.Height_There
	Neg.w	d1
	Mulu	d2,d1
	Lsl.l	#3,d1
	Lea	(a1,d1.l),a1
	Moveq	#0,d1
.No_Miny
	Add.w	#(N_Vdb)/2,d1
;	Add.w	#33,d1
	Asl.w	#1,d1
	Pea	16(a0)			; Next object must take into account the maximum number of phrases for an object header (Scaled=3 phrases)
	Movem.w	d0-d3,-(sp)		; Save coardinates,Phrases wide,Height (in full lines !  not half lines!)
	Clr.l	0(a0)
	Clr.l	4(a0)
	Clr.l	8(a0)
	Clr.l	12(a0)

	Move.l	a0,d5			; Save pointer to object in unused register
	Move.l	a1,d0			; Graphic data in data register
	moveq	#8,d1
	lsl.l	d1,d0			; shift into position
	and.l	#$fffff800,d0		; mask off junk
	move.l	d0,(a0)			; store

; This places the partial result in the correct spot in memory
; Then, in the next part, it 'or's the rest of the data in.
; Doing it all in registers would be faster, but I want to see the results

	Moveq	#16,d0
	Add.l	d5,d0			; Pointer to next object			
	move.l	d0,d2			; Save pointer for bottom half
	moveq	#11,d1
	lsr.l	d1,d0			; shift for top part
	or.l	d0,(a0)+		; or in the new data

; do the bottom half in the next long word

	moveq	#21,d1
	lsl.l	d1,d2			; shift for bottom part
	and.l	#$ff000000,d2		; mask off junk
	move.l	d2,(a0)			; store (prematurely)

; Same comment here about doing this in registers instead of memory

	Move.w	3*2(sp),d0		; Get height of object

	moveq	#14,d1
	lsl.l	d1,d0			; shift it again
	or.l	d0,(a0)			; or in the new data
	Moveq	#0,d0
	Move.w	1*2(sp),d0		; Y in d0
	Ext.l	d0
	Asl.l	#3,d0			; Shift 1 extra coz of halflines-non interlace !
	And.l	#%11111111111000,D0
	Or.l	d0,(a0)+		; Object type is scaled object


; That completes another long word, First phrase done

	Moveq	#0,d0
	Move.w	2*2(sp),d0		; Retreive phrase width
	Move.l	d0,d1
	Lsr.l	#4,d1			; Drop low bits
	move.l	d1,(a0)+
	Tst.b	Reflect_Object_Flag(a4)
	Beq.s	.No_Reflect
	Or.l	#1<<(45-32),-4(a0)	; Set transparent
.No_Reflect
	Or.l	#1<<(47-32),-4(a0)	; Set transparent
	And.w	#%1111,d0
	Move.l	d0,d5
	Ror.l	#4,d5

; Insert dwidth
	Moveq	#0,d0	
	Move.w	2*2(sp),d1
	Or.w	d1,d0			; DWIDTH ? same as IwIDTH

; Insert pitch
	moveq	#3,d1			; make room for pitch
	lsl.l	d1,d0
	ori.l	#$1,d0

; Insert depth
	moveq	#3,d1			; make room for depth

	lsl.l	d1,d0

	Move.w	Num_Pixels(a4),d1
	Or.w	d1,d0	

; Insert xpos
	moveq	#12,d1			; make room for xpos
	lsl.l	d1,d0
	Move.w	0*2(sp),d1
	And.w	#%111111111111,d1
	Add.w	d1,d0
	
; Finally store the data
	Or.l	d5,d0
	move.l	d0,(a0)+
	Move.w	Pal_Number(a4),d6
	Lsl.w	#5,d6
	Or.w	d6,-6(a0)
	Addq.l	#8,sp
	Move.l	(sp)+,a0
	Addq.w	#1,Num_Objects_To_Display(a4)
	rts

Make_An_Object2
	Move.w	d7,Num_Pixels2(a4)
	Move.w	d6,Pal_Number2(a4)
	Cmp.w	#0,d1
	Bpl.s	.No_Miny
	Sub.w	#0,d1
	Add.w	d1,d3
	Bgt.s	.Height_There
	Rts
.Height_There
	Neg.w	d1
	Mulu	d2,d1
	Lsl.l	#3,d1
	Lea	(a1,d1.l),a1
	Moveq	#0,d1
.No_Miny
	Add.w	#(N_Vdb)/2,d1
;	Add.w	#33,d1
	Asl.w	#1,d1
	Pea	16(a0)			; Next object must take into account the maximum number of phrases for an object header (Scaled=3 phrases)
	Movem.w	d0-d3,-(sp)		; Save coardinates,Phrases wide,Height (in full lines !  not half lines!)
	Clr.l	0(a0)
	Clr.l	4(a0)
	Clr.l	8(a0)
	Clr.l	12(a0)

	Move.l	a0,d5			; Save pointer to object in unused register
	Move.l	a1,d0			; Graphic data in data register
	moveq	#8,d1
	lsl.l	d1,d0			; shift into position
	and.l	#$fffff800,d0		; mask off junk
	move.l	d0,(a0)			; store

; This places the partial result in the correct spot in memory
; Then, in the next part, it 'or's the rest of the data in.
; Doing it all in registers would be faster, but I want to see the results

	Moveq	#16,d0
	Add.l	d5,d0			; Pointer to next object			
	move.l	d0,d2			; Save pointer for bottom half
	moveq	#11,d1
	lsr.l	d1,d0			; shift for top part
	or.l	d0,(a0)+		; or in the new data

; do the bottom half in the next long word

	moveq	#21,d1
	lsl.l	d1,d2			; shift for bottom part
	and.l	#$ff000000,d2		; mask off junk
	move.l	d2,(a0)			; store (prematurely)

; Same comment here about doing this in registers instead of memory

	Move.w	3*2(sp),d0		; Get height of object

	moveq	#14,d1
	lsl.l	d1,d0			; shift it again
	or.l	d0,(a0)			; or in the new data
	Moveq	#0,d0
	Move.w	1*2(sp),d0		; Y in d0
	Ext.l	d0
	Asl.l	#3,d0			; Shift 1 extra coz of halflines-non interlace !
	And.l	#%11111111111000,D0
	Or.l	d0,(a0)+		; Object type is scaled object


; That completes another long word, First phrase done

	Moveq	#0,d0
	Move.w	2*2(sp),d0		; Retreive phrase width
	Move.l	d0,d1
	Lsr.l	#4,d1			; Drop low bits
	move.l	d1,(a0)+
;	Tst.b	Reflect_Object_Flag(a4)
;	Beq.s	.No_Reflect
;	Or.l	#1<<(45-32),-4(a0)	; Set transparent
;.No_Reflect
	Or.l	#1<<(47-32),-4(a0)	; Set transparent
	And.w	#%1111,d0
	Move.l	d0,d5
	Ror.l	#4,d5

; Insert dwidth
	Moveq	#0,d0	
	Move.w	2*2(sp),d1
	Or.w	d1,d0			; DWIDTH ? same as IwIDTH

; Insert pitch
	moveq	#3,d1			; make room for pitch
	lsl.l	d1,d0
	ori.l	#$1,d0

; Insert depth
	moveq	#3,d1			; make room for depth

	lsl.l	d1,d0

	Move.w	Num_Pixels2(a4),d1
	Or.w	d1,d0	

; Insert xpos
	moveq	#12,d1			; make room for xpos
	lsl.l	d1,d0
	Move.w	0*2(sp),d1
	And.w	#%111111111111,d1
	Add.w	d1,d0
	
; Finally store the data
	Or.l	d5,d0
	move.l	d0,(a0)+
	Move.w	Pal_Number2(a4),d6
	Lsl.w	#5,d6
	Or.w	d6,-6(a0)
	Addq.l	#8,sp
	Move.l	(sp)+,a0
	rts



Insert_Stop_Object
	Clr.l	(a0)+
	Move.l	#4,(a0)+
	Rts


Make_A_Scaled_Object
	Move.w	d7,Num_Pixels(a4)
	Cmp.w	#0,d1
	Bpl.s	.No_Miny
	Sub.w	#0,d1

	Move.w	d3,d6
	Mulu	d5,d6
	Lsr.w	#5,d6
	Add.w	d6,d3
	Bgt.s	.Height_There
	Rts
.Height_There
	Neg.w	d1
	Move.w	d1,d6
	Mulu	#32,d6
	Divu	d5,d6
	Move.w	d6,d1
	Mulu	d2,d1
	Lsl.l	#3,d1
	Lea	(a1,d1.l),a1
	Moveq	#0,d1
.No_Miny
	Add.w	#33,d1
	Asl.w	#1,d1
	Pea	32(a0)			; Next object must take into account the maximum number of phrases for an object header (Scaled=3 phrases)
	Movem.w	d4-d5,-(sp)
	Movem.w	d0-d3,-(sp)		; Save coardinates,Phrases wide,Height (in full lines !  not half lines!)
	Clr.l	0(a0)
	Clr.l	4(a0)
	Clr.l	8(a0)
	Clr.l	12(a0)
	Clr.l	16(a0)
	Clr.l	20(a0)
	Clr.l	24(a0)
	Clr.l	28(a0)


	Move.l	a0,d5			; Save pointer to object in unused register
	Move.l	a1,d0			; Graphic data in data register
	moveq	#8,d1
	lsl.l	d1,d0			; shift into position
	and.l	#$fffff800,d0		; mask off junk
	move.l	d0,(a0)			; store

; This places the partial result in the correct spot in memory
; Then, in the next part, it 'or's the rest of the data in.
; Doing it all in registers would be faster, but I want to see the results

	Moveq	#32,d0
	Add.l	d5,d0			; Pointer to next object			
	move.l	d0,d2			; Save pointer for bottom half
	moveq	#11,d1
	lsr.l	d1,d0			; shift for top part
	or.l	d0,(a0)+		; or in the new data

; do the bottom half in the next long word

	moveq	#21,d1
	lsl.l	d1,d2			; shift for bottom part
	and.l	#$ff000000,d2		; mask off junk
	move.l	d2,(a0)			; store (prematurely)

; Same comment here about doing this in registers instead of memory

	Move.w	3*2(sp),d0		; Get height of object

	moveq	#14,d1
	lsl.l	d1,d0			; shift it again
	or.l	d0,(a0)			; or in the new data
	Moveq	#0,d0
	Move.w	1*2(sp),d0		; Y in d0
	Ext.l	d0
	Asl.l	#3,d0			; Shift 1 extra coz of halflines-non interlace !
	And.l	#%11111111111000,D0
	Or.l	#1,d0
	Or.l	d0,(a0)+		; Object type is scaled object


; That completes another long word, First phrase done

	Moveq	#0,d0
	Move.w	2*2(sp),d0		; Retreive phrase width
	Move.l	d0,d1
	Lsr.l	#4,d1			; Drop low bits
	move.l	d1,(a0)+
	Tst.b	Reflect_Object_Flag(a4)
	Beq.s	.No_Reflect
	Or.l	#1<<(45-32),-4(a0)	; Set transparent
.No_Reflect
	Or.l	#1<<(47-32),-4(a0)	; Set transparent
	And.w	#%1111,d0
	Move.l	d0,d5
	Ror.l	#4,d5

; Insert dwidth
	Moveq	#0,d0	
	Move.w	2*2(sp),d1
	Or.w	d1,d0			; DWIDTH ? same as IwIDTH

; Insert pitch
	moveq	#3,d1			; make room for pitch
	lsl.l	d1,d0
	ori.l	#$1,d0

; Insert depth
	moveq	#3,d1			; make room for depth

	lsl.l	d1,d0

	Move.w	Num_Pixels(a4),d1
	Or.w	d1,d0	

; Insert xpos
	moveq	#12,d1			; make room for xpos
	lsl.l	d1,d0
	Move.w	0*2(sp),d1
	And.w	#%111111111111,d1
	Add.w	d1,d0
	
; Finally store the data
	Or.l	d5,d0
	move.l	d0,(a0)+
	Addq.l	#8,sp
	Movem.w	(sp)+,d0-d1
	Lsl.w	#8,d1
	Or.w	d1,d0
	Lsl.w	#8,d1
	Or.l	d1,d0
	Clr.l	(a0)+
	Move.l	d0,(a0)+	
	Move.l	(sp)+,a0
	Addq.w	#2,Num_Objects_To_Display(a4)
	rts



;----------------------------------------------
;----------------------------------------------
;----------------------------------------------

;d2-Image width
;d4-Data width


Make_A_Clipped_Object
	Move.w	d2,Iwidth(a4)
	Move.w	d4,Dwidth(a4)
	Move.w	d7,Num_Pixels(a4)
	Move.w	d6,Pal_Number(a4)
	Cmp.w	#0,d1
	Bpl.s	.No_Miny
	Sub.w	#0,d1
	Add.w	d1,d3
	Bgt.s	.Height_There
	Rts
.Height_There
	Neg.w	d1
	Mulu	d4,d1
	Lsl.l	#3,d1
	Lea	(a1,d1.l),a1
	Moveq	#0,d1
.No_Miny
	Add.w	#(N_Vdb)/2,d1
;	Add.w	#33,d1
	Asl.w	#1,d1
	Pea	16(a0)			; Next object must take into account the maximum number of phrases for an object header (Scaled=3 phrases)
	Movem.w	d0-d3,-(sp)		; Save coardinates,Phrases wide,Height (in full lines !  not half lines!)
	Clr.l	0(a0)
	Clr.l	4(a0)
	Clr.l	8(a0)
	Clr.l	12(a0)

	Move.l	a0,d5			; Save pointer to object in unused register
	Move.l	a1,d0			; Graphic data in data register
	moveq	#8,d1
	lsl.l	d1,d0			; shift into position
	and.l	#$fffff800,d0		; mask off junk
	move.l	d0,(a0)			; store

; This places the partial result in the correct spot in memory
; Then, in the next part, it 'or's the rest of the data in.
; Doing it all in registers would be faster, but I want to see the results

	Moveq	#16,d0
	Add.l	d5,d0			; Pointer to next object			
	move.l	d0,d2			; Save pointer for bottom half
	moveq	#11,d1
	lsr.l	d1,d0			; shift for top part
	or.l	d0,(a0)+		; or in the new data

; do the bottom half in the next long word

	moveq	#21,d1
	lsl.l	d1,d2			; shift for bottom part
	and.l	#$ff000000,d2		; mask off junk
	move.l	d2,(a0)			; store (prematurely)

; Same comment here about doing this in registers instead of memory

	Move.w	3*2(sp),d0		; Get height of object

	moveq	#14,d1
	lsl.l	d1,d0			; shift it again
	or.l	d0,(a0)			; or in the new data
	Moveq	#0,d0
	Move.w	1*2(sp),d0		; Y in d0
	Ext.l	d0
	Asl.l	#3,d0			; Shift 1 extra coz of halflines-non interlace !
	And.l	#%11111111111000,D0
	Or.l	d0,(a0)+		; Object type is scaled object


; That completes another long word, First phrase done

	Moveq	#0,d0
	Move.w	Iwidth(a4),d0		; Retreive phrase width
	Move.l	d0,d1
	Lsr.l	#4,d1			; Drop low bits
	move.l	d1,(a0)+
	Tst.b	Reflect_Object_Flag(a4)
	Beq.s	.No_Reflect
	Or.l	#1<<(45-32),-4(a0)	; Set transparent
.No_Reflect
	Or.l	#1<<(47-32),-4(a0)	; Set transparent
	And.w	#%1111,d0
	Move.l	d0,d5
	Ror.l	#4,d5

; Insert dwidth
	Moveq	#0,d0	
	Move.w	DWidth(a4),d1
	Or.w	d1,d0			; DWIDTH ? same as IwIDTH

; Insert pitch
	moveq	#3,d1			; make room for pitch
	lsl.l	d1,d0
	ori.l	#$1,d0

; Insert depth
	moveq	#3,d1			; make room for depth

	lsl.l	d1,d0

	Move.w	Num_Pixels(a4),d1
	Or.w	d1,d0	

; Insert xpos
	moveq	#12,d1			; make room for xpos
	lsl.l	d1,d0
	Move.w	0*2(sp),d1
	And.w	#%111111111111,d1
	Add.w	d1,d0
	
; Finally store the data
	Or.l	d5,d0
	move.l	d0,(a0)+
	Move.w	Pal_Number(a4),d6
	Lsl.w	#5,d6
	Or.w	d6,-6(a0)
	Addq.l	#8,sp
	Move.l	(sp)+,a0
	Addq.w	#1,Num_Objects_To_Display(a4)
	rts

