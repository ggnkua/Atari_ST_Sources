;This source code was written by Greg Garner on a Commodore Amiga.
;I release this source code to the public domain with the restraint
;that my name be included in any source this is used in.  


;Binary to decimal
;convertor.			;Call this with word to convert in D0.
				;And address of Free memory to put BCD
				;String at in A0.
Bindec	Move.b	#' ',D1		;Assume we have a positive binary value.
	Tst.l	D0		;See if we have a negatice number.
	Bpl	Notneg
	Move.b	#'-',D1		;Put a minus sign in front of number.
	Neg.l	D0		;Convert it to a positive number.
Notneg	Move.b	D1,(A0)+	;Save the sign of the BCD number.
	Adda.l	#$0A,A0		;Point to 1 past end of string area.
	Move.b  #$00,(A0)	;Make sure the string is NULL terminated.
	Move.w	#$09,D6		;Count register for highest number digits.
Bcdloop	Move.l	#10,D1		;Divide by ten to find remainder.
	Bsr     Londivu		;D0=D0/D1. Remainder in D1, ans in D0.
	Move.b	D1,-(A0)	;Move Binary remainder to BCD area.
	Add.b	#'0',(A0)	;Adjust it to ASCII.
	Dbra	D6,Bcdloop	;Do the division until done.
	Rts

;Binary to ASCII hex string. Call with long word in D0 and string addr in A0.

Binhex	Move.l	#$07,D1		;Do 8 Hex digits.
	Move.b	#$20,(a0)+	;Start with ascii spaces.
	Move.b	#$20,(a0)+
	Add.l	#8,A0		;Point to end of string.
	Move.b	#$00,(a0)	;Terminate with a 0 hex.
Hexloop	Move.b	D0,D2		;Get lo byte.
	And.b	#$0F,D2		;Look at lo order nibble.
	Cmpi.b	#$0a,D2		;Is the nibble>=A?
	Bcc	Hexalph
	Ori.b	#'0',D2		;Convert it to 0-9 ascii.
	Bra	Hexskip
Hexalph	Add.b	#'A'-10,D2	;Convert it to Alpha digit.
Hexskip	Move.b  D2,-(A0)	;Save digit
	Asr.l	#$04,D0		;Shift it right 4 bits.
	Dbra	D1,Hexloop	
	Rts


;32 bit division. D0/D1, answer in D0, remainder in D1.
;This routine uses the shift and subtract algorythm.

;Unsigned division.

Londivu	Move.l	#$00,D7 	;Start with a positive number.
	Bra	Postiv		

;Signed division.

Londivs	Move.l	#$00,D7 	;Assume we have two positive numbers.	
	Tst.l	D1		;See if we are dividing by zero.
	Beq	Badexit
	Bpl	Posone		;At least this number is positive.
	Not.l	D7		;Show that we have a negative number.
	Neg.l	D1		;Change D1 to a positive number.
Posone	Tst.l	D0		
	Bpl	Postiv		;Is this a positive number?
	Not.l	D7		;Two negs make positive.
	Neg.l	D0		;Turn it into a positive number.
Postiv	Move.l	#32,D4		;Number of bits-1 in quotient.
	Clr.l	D2		;Clear two temporary registers.
	Clr.l	D3	 
Clrcr 	Move.b  #0,Ccr		;Clear carry for first time.
Dv	Roxl.l	#$01,D0         ;Rotate the left bit into the Extend bit.
	Roxl.l	#$01,D2		;Rotate the Extend bit into temp register.
	Move.l	D2,D3		;Move D2 into temporary D3.
	Sub.l	D1,D3		;D3=D3-D1. Is D3>D1?
	Eori.b	#$ff,Ccr	;Invert the carry.
	Bcc	Dccnt		;No, shift some more into D2. Extend=0.
	Move.l	D3,D2		;Save the remainder.          Extend=1.

Dccnt	Move.b  Sr,D5		;Save the Extend bit.
	Subq.l  #$01,D4 	;Decrement the bit count.
	Beq	Okexit		;If we are done, then leave.
	Move.b  D5,Ccr		;Get the Extend bit back.
	Bra     Dv		
	
Okexit	Move.b  D5,Ccr		;Get last Extend bit.
	Roxl.l	#$01,D0 	;Rotate it into the answer.
	Move.l	D2,D1		;Put the remainder in D1.
	Move.b	#$00,Ccr	;Clear the carry to show success.
Exend	Tst.l	D7		;Is the answer positive or negative?
	Bpl	Goodby
	Neg.l	D0		;Change the answer to a negative number.
Goodby	Rts

Badexit	Move.b	#$ff,Ccr	;Set the carry to show failure.
	Bra     Exend		;Leave via single rts.

;Add a decimal point to the string pointed to by A0. # of dec places is in D0.

Decpt	Cmp.b	#$00,(A0)+	;Are we at the end of the string yet?
	Bne	Decpt 		;Look some more if we haven't found end.
Mcloop	Move.b	-(A0),1(A0)	;Move each byte over one.
	Dbra    D0,Mcloop	;Have we done all the digits?
	Move.b	#'.',(A0)	;Move the decimal point into the string.
	Rts

;Clear all leading zero places in string.

Killz	Adda.l	#$01,A0		;Skip the first place.
Killp	Cmp.b	#'0',(A0)	;Is this a zero?
	Bne	Killrt		;No zero here, we are done.
	Move.b	#' ',(A0)+	;Move a blank into string.
	Bra	Killp		;Do another byte.
Killrt	Rts

