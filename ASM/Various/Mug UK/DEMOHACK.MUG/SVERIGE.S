;-------------------------------------------------
;|       DF Goes Sverige by Delta Force          |
;|                                               |
;| Filed by MUG U.K¿ (of The Source) - 17/9/1992 |
;|                                               |
;|    Not bad for a GFA BASIC programmer !!      |
;-------------------------------------------------

	clr.l	-(sp)		; Supervisor Mode - of course
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	jmp	reloc		; Jump past the raw data

raw	incbin	e:\sverige.dat
	even
end	

reloc	move.w	#$000,$ffff8240.w	; alter border colour to black
	move.w	#$777,$ffff825e.w	; alter text colour to white

	move.l	#text,-(sp)	; Print the ego-swelling credits
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	#7,-(sp)		; Wait for a key press
	trap	#1
	addq.l	#2,sp

	move	#$2700,sr		; Full speed ahead captain !!
	lea	raw,a0 		; start address of raw data
	lea	$1000,a1 		; destination address
	move	#(end-raw)/8,d7	; how much to move
coploc	move.l	(a0)+,(a1)+	; move it
	move.l	(a0)+,(a1)+	; move it
	move	a0,$ffff8240.w	; flash the colour register
	dbf	d7,coploc

	move	#$007,$ffff8240.w	; alter border colour to blue
	jmp	$1000		; run the program
;
; Ego Swelling Credits
;
text	dc.b	27,"E"		; cls
	dc.b	27,"f"		; cursor off
	dc.b	'****************************************',13,10
	dc.b	'*                                      *',13,10
	dc.b	'*           MUG U.K¿ presents          *',13,10
	dc.b	'*           -----------------          *',13,10
	dc.b	'*                                      *',13,10
	dc.b	'*            DF GOES SVERIGE           *',13,10
	dc.b	'*                                      *',13,10
	dc.b	'*                  by                  *',13,10
	dc.b	'*                                      *',13,10
	dc.b	'*              DELTA FORCE             *',13,10
	dc.b	'*                                      *',13,10
	dc.b	'****************************************',13,10
	dc.b	'* All cracking & filing by MUG U.K¿ !! *',13,10
	dc.b	'*                                      *',13,10
	dc.b	'*         PRESS ANY KEY TO START       *',13,10
	dc.b	'****************************************',13,10
	dc.b	0
	even

