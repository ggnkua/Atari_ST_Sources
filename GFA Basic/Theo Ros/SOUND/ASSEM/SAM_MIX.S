; SAM_MIX mixes two soundsamples into one, by ORing the
; bytes or words together, or by interweaving bytes from two
; samples (thus creating a new sample of twice the size)
;
; ORing can be used as a way to create echo-effects or adding
; music to a voice or something. 
; Since no bytes are added, the destination address CAN be
; the same as one of the source addresses. If you do mix
; 'in place', always use the LONGEST sample as the destination.
; If you choose to create a new buffer, make sure it has the 
; appropriate length: MALLOC(MAX(len_sam1%,len_sam2%))
;
; WEAVING can be used as a way to combine two monosamples
; into one stereo sample, where each of the original samples
; will be played at either the left or the right channel.
; The calling program must first provide a buffer of the
; appropriate length: MALLOC(MAX(len_sam1%,len_sam2%)*2)
; because if one sample is shorter than the other, the
; remainder will be padded with zero's. 
; With this method, you CANNOT mix samples 'in place'.

; In both cases, you must make sure that the source samples
; are of the same nature: don't mix 8-bit with 16 bit or a
; mono with a stereo sample, because the resulting mix will
; sound awfull. Also keep in mind that both samples should
; use the same playback frequency.
; No error checking is performed, so make sure your addresses
; are EVEN.

; Call this function from GfA: 
;    ~C:sam_mix%(L:src1%,L:src2%,L:dest%,L:len2%,L:len2%,size&)

; parameters: src1% and src2%   the addresses of the SOURCE samples
;             dest%             the address of the buffer to store
;             len1% and len2%   the length in bytes of both samples
;                               the mixed sound in
;             size&             0: mix using OR  
;                               1: interleave BYTES (mono-8)
;			  2: interleave WORDS (mono-16)
;
; Theo Ros, 10/10/1997
; 
; This source will compile into Atari Executable SAM_MIX.PRG=170 bytes
; Stripping off the first 28 bytes results in    SAM_MIX.INL=142 bytes


mix_samples:	movem.l	4(sp),a0-a2	; src1%,src2% and dest%
		movem.l	16(sp),d0-d1	; len1% and len2%
		
		move.l	d0,d3		; get MAX(len1%,len2%)
		cmp.l	d1,d3
		bge.s	mix_size
		move.l	d1,d3

mix_size:		move.w	24(sp),d2		; size&
		beq.s	mix_or		; 0 --> OR samples together

; =====================================================================
; mix samples by interleaving the bytes or words
; =====================================================================

		subq	#1,d2		; bytes or words?
		beq.s	mix_bytes

mix_words:	subq.l	#2,d3
		bmi.s	mix_exit
		subq.l	#2,d0		; keep track of length
		bmi.s	mix_zero		; for src1%
		move.w	(a0)+,(a2)+
		bra.s	mix_word2
mix_zero:		clr.w	(a2)+	
mix_word2:	subq.l	#2,d1		; lengthcheck src2%
		bmi.s	mix_zero2
		move.w	(a1)+,(a2)+
		bra.s	mix_words
mix_zero2:	clr.w	(a2)+
		bra.s	mix_words
		
mix_bytes:	subq.l	#1,d3
		bmi.s	mix_exit	
		subq.l	#1,d0
		bmi.s	mix_null
		move.b	(a0)+,(a2)+
		bra.s	mix_byte2
mix_null:		clr.b	(a2)+
mix_byte2:	subq.l	#1,d1
		bmi.s	mix_null2
		move.b	(a1)+,(a2)+
		bra.s	mix_bytes
mix_null2:	clr.b	(a2)+
		bra.s	mix_bytes
		
mix_exit:		rts

; =====================================================================
; mixing samples by ORing the bytes together
; =====================================================================

mix_or:		move.l	d3,d2
		andi.l	#-2,d2		; test if we can do words
		beq.s	or_bytes
		sub.l	d2,d3

or_words:		moveq	#0,d4
		subq.l	#2,d0		; keep track of length
		bmi.s	or_word2		; for src1%
		move.w	(a0)+,d4
or_word2:		subq.l	#2,d1		; length for src2%
		bmi.s	write_word
		or.w	(a1)+,d4		; or with src2%
write_word:	move.w	d4,(a2)+
		subq.l	#2,d2
		bne.s	or_words
		
or_bytes:		subq.l	#1,d3
		bmi.s	mix_exit
		moveq	#0,d4
		subq.l	#1,d0
		bmi.s	or_byte2
		move.b	(a0)+,d4
or_byte2:		subq.l	#1,d1
		bmi.s	write_byte
		or.b	(a1)+,d4
write_byte:	move.b	d4,(a2)+
		bra.s	or_bytes