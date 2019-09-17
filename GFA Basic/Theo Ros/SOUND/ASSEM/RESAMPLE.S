; resample routine to change the frequency of a sample
; 
; Call from GfA:   newlen%=C:resample%(factor,L:src%,L:dest%,L:len%) 
;
; -->          factor 0 to 8000 [CINT((oldhz%*1000)/newhz%)]
;		    <1000 means stepping UP in frequency
;		    >1000 means stepping DOWN in frequency
;                       =1000 no change, sample is copied into dest%
;		  counting in thousands is done to avoid
;		  floating-point arithmatic
;              src%   address of source
;              dest%  address of destination
;              len%   length in BYTES of source
; <--          length in BYTES of new sample (newlen%)
;
;     Theo Ros, 24/10/1997,   RESAMPLE.PRG=106 bytes
;			RESAMPLE.INL= 78 bytes

	move.w	4(sp),d1		; factor
	movem.l	6(sp),a0/a1	; src%, dest%
	move.l	14(sp),d0		; len%
	beq.s	exit
	move.l	d0,d2
	moveq	#0,d3		; counter
	cmpi.w	#1000,d1
	bhi.s	step_dn

; stepping up the frequency (i.e. 6258 to 12517 --> factor=500)

step_up:	subq.l	#1,d2		; DEC len%
	bmi.s	exit
next_up:	move.b	(a0),(a1)+
	addq.l	#1,d0		; INC newlen%
	add.w	d1,d3		; counter+factor
	cmpi.w	#1000,d3
	blt.s	next_up
	subi.w	#1000,d3
	addq.l	#1,a0		; INC src%
	bra.s	step_up
	
exit:	rts

; stepping down the frequency (i.e. 12517 to 6258 --> factor=2000)

step_dn:	subq.l	#1,d2		; DEC len%
	bmi.s	exit
	moveq	#0,d4
	addq.l	#1,d0		; INC newlen%
	add.w	d1,d3		; counter+factor
next_dn:	or.b	(a0)+,d4
	subi.w	#1000,d3
	bgt.s	next_dn
	move.b	d4,(a1)+
	bra.s	step_dn
	