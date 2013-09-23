;convert ascii to small-scroller
; Sukka-Screen
; Seka-Assembler

; Sonderzeichen:
;
; # Speed 0 (gefolgt von Zahl von 1-9)
; % Speed 1
; ^ Speed 2
; ` Speed 4
; * Speed 8
; $ Smilie
; < New Mode
; > Slime
; @ Questlord
; [\] Acid
; _ Fuck for Abi


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
	dc.b 37,50,60,55,61,51,49,46,47,64,44,41,43,39,45 ; Sonder
	dc.b 36,27,28,29,30,31,32,33,34,35 ; 0-9
	dc.b 40,42,53,48,52,38,54	; Sonder
	dc.b 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
	dc.b 18,19,20,21,22,23,24,25	; A-Z
	dc.b 56,57,58,62,59,63
	dc.b 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
	dc.b 18,19,20,21,22,23,24,25	; a-z
	blk.b 133,26
 
even	 

