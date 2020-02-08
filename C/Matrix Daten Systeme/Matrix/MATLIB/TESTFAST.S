/* testfast.s	/	10.7.91	/	MATRIX	/	WA	*/


; extern TEST_TYPE test_pattern ( int i, unsigned long j, TEST_TYPE *p ) ;
;									d0			d1				a0

				.xdef	or_pattern,and_pattern


				.xref	byte_pattern
				.xref	long_pattern
				.xref	word_pattern
			
;--------------------------------------- byte_pattern ----------------
byte_pattern:	lsr		#1,d0
				scs		d2
				ext.w	d2
				ext.l	d2
				add		d1,d0
				swap	d1
				add		d1,d0
				move	d0,d1
				ror		#8,d1
				add.b	d1,d0
				eor.b	#$f0,d0
				bra		andor
				
;--------------------------------------- word_pattern ----------------
word_pattern:	lsr		#1,d0
				scs		d2
				ext.w	d2
				ext.l	d2
				
				add		d1,d0
				rol		#8,d1
				add		d1,d0
				eor		#$ff00,d0
				bra		andor
				
;--------------------------------------- long_pattern ----------------
long_pattern:	and.l	#$0000ffff,d0	; int i !
				
				lsr		#1,d0
				scs		d2
				ext.w	d2
				ext.l	d2			; odd/even invert mask
				
				add.l	d1,d0
				swap	d1
				add.l	d1,d0
				rol.l	#8,d1
				add.l	d1,d0
				eor.l	#$fff00f00,d0
				
andor:			eor.l	d2,d0
				and.l	and_pattern,d0
				or.l	or_pattern,d0

				rts


				.xref	_not
_not:			move.l	d0,(a0)
				not.l	(a0)
				move.l	(a0),d0
				rts
				
				.xref	_eor
_eor:			move.l	d0,(a0)
				eor.l	d1,(a0)
				move.l	(a0),d0
				rts			

				.xref	_nots
_nots:			not.l	(a0)+
				dbra	d0,_nots
				rts
								
				.xref	_eors
_eors:			eor.l	d1,(a0)+
				dbra	d0,_eors
				rts
								
				.end