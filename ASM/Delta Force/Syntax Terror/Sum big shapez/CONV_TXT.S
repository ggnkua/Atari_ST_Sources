;convert ascii to small-scroller
; "Sum Big Shapes"-Screen
; for Seka-Assembler

source = $80000
dest   = $90000

x:
move.l	#source,a0
move.l	#dest,a1
move.l	#contab,a2
prepare:
moveq #0,d0
move.b	(a0)+,d0
beq.s	convende
cmp.b	#$0a,d0
beq.s	prepare
cmp.b #$0d,d0
beq.s prepare
move.b  0(a2,d0.w),(a1)+
bra.s   prepare
convende:
move.b  #-1,(a1)+
illegal

;-----------------------------
contab: blk.b 33,26	; 0-32
	dc.b 40,42,26,51,26,46,43,44,45,51,46,48,47,37,49; Sonder
	dc.b 27,28,29,30,31,32,33,34,35,36 ; 0-9
	dc.b 38,39,26,50,26,41,26	; Sonder
	dc.b 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
	dc.b 18,19,20,21,22,23,24,25	; A-Z
	dc.b 44,49,45,26,52,48
	dc.b 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
	dc.b 18,19,20,21,22,23,24,25	; a-z
	blk.b 133,26
 
even	 


