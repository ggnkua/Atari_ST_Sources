; *********************************************************
; * computes the arctan to a given tangens value          *
; * 		- by ray//.tSCc. 2000 -		 	  *
; *********************************************************
; *							  * 
; * input  D0.w  - tan in 8.8 fp			  *
; * output D0.w  - arc in 8.8 fp			  *
; *********************************************************

pi			EQU $0324 		; guess


arctan:			cmp.w  #256,D0		; tan = 1
			beq.s  returnpi4
			bhi.s  adjtan		; adjust tan
			bsr.s  precomp
			rts

adjtan: 		move.l #$FFFF,D1
			divu   D0,D1
			move.w D1,D0		; tan = 1/tan
			bsr.s  precomp

			move.w #pi/2,D1
			sub.w  D0,D1		; arc = PI/2 - arctan(1/tan)
			move.w D1,D0		; (mirrored)
			rts

returnpi4:		move.w #pi/4,D0		; return PI/4
			rts


; *********************************************************
; * precomputes arctan for using a taylor-serie           *
; * at some places i had to cheat a bit to keep the error *
; * as small as possible :)				  *
; *********************************************************
; *							  * 
; * input  D0.w  - tan in 8.8 fp			  *
; * output D0.w  - arc in 8.8 fp			  *
; *							  *
; * D1	  tan^2						  *
; * D2-D7 elements of taylor serie			  *
; *********************************************************

precomp:		movem.l D1-D7,-(SP)

			move.w D0,D1
			mulu   D1,D1
			lsr.w  #8,D1		; D1 = tan^2

			move.w D1,D2
			mulu   D0,D2
			lsr.w  #8,D2
			divu   #3,D2		; D2 = tan^3/3

			move.w D2,D3
			mulu   D1,D3
			lsr.w  #8,D3
			divu   #5,D3		; D3 = tan^5/5

			move.w D3,D4
			mulu   D1,D4
			lsr.w  #8,D4
			divu   #7,D4		; D4 = tan^7/7

			move.w D2,D5
			mulu   D1,D5
			lsr.w  #8,D5
			divu   #9,D5		; D5 = tan^9/9

			move.w D3,D6
			mulu   D1,D6
			lsr.w  #8,D6
			divu   #11,D6		; D6 = tan^11/11

			move.w D2,D7
			mulu   D1,D7
			lsr.w  #8,D7
			divu   #13,D7		; D7 = tan^13/13

; D0 = tan - tan^3/3 + tan^5/5 - tan^7/7 + tan^9/9 - tan^11/11 + tan^13/14
; (taylor-series)

			sub.w  D2,D0
			add.w  D3,D0
			sub.w  D4,D0
			add.w  D5,D0
			sub.w  D6,D0
                        add.w  D7,D0

			ext.l  D0		; to be sure :)
			movem.l (SP)+,D1-D7

			rts