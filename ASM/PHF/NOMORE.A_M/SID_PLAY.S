; Music by (N)o-more of Animal Mine

; Music either:-

; 1) Ripped by Tronic P.D.L.
; 2) Supplied by (N)o-more to me then onto you lot!!

; N.B. Not all the music is present in these released files as I have been
; asked by (N)o-more not to spread them yet!!

; A lot of files available.  See end of code

; Code by (N)o-more. But I am not sure. 

; Very, Very, Very, Very, Very, Very, Very, Very, GOOD music this!!! 


	PEA	MAIN
	MOVE.W	#$26,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP
	CLR.W	-(SP)
	TRAP	#1
MAIN:
	BSR	MUZAK		; INIT
WAIT:
	MOVE.W	#$25,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	BSR	MUZAK+6		; Call replay rout.
	CMPI.B	#$39+$80,$FFFFFC02.W
	BNE.S	WAIT
	BSR	MUZAK+2		; Call off rout.
	RTS
MUZAK:							   
 INCBIN AM54.SID        ; GSC 54                   ; ripped by Tronic
 incbin	DEEP.SID

	