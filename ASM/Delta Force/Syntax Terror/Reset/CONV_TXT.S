; convert ascii to 1plane scroller
; for Resetdemo-Scroller (proportional)
; Syntax-Terror-Demo
; 06.09.90 by New Mode/DF
; Seka-Assembler

; Sonderzeichen:
;----------------
; $      Smilie
; #	 1990
; _	 Stinkefinger
; ^	 Slime
; @	 New Mode
; &	 and
; ~	 Delta Force
; |	 Atari-Zeichen



source = $80000
dest   = $90000

x:
move.l	#source,a0
move.l	#dest,a1
move.l	#contab,a2
prepare:
move.b	(a0)+,d0
beq.L	convende
cmp.b	#$0a,d0
beq.s	prepare
cmp.b 	#$0d,d0
beq.s 	prepare
cmp.b 	#' ',d0
beq 	war_space
cmp.b	#'i',d0
beq	war_i
cmp.b	#'I',d0
beq	war_i
cmp.b	#'!',d0
beq	war_ausr
cmp.b	#':',d0
beq	war_dpunkt
cmp.b	#';',d0
beq	war_spunkt
cmp.b	#',',d0
beq	war_komma
cmp.b	#'.',d0
beq	war_punkt
cmp.b	#"'",d0
beq	war_hochkomma
cmp.b	#'"',d0
beq.L	war_anfuehr
cmp.b	#'(',d0
beq.L	war_klammerl
cmp.b	#')',d0
beq.L	war_klammerr
cmp.b	#'1',d0
beq.s	war_eins
cmp.b	#'^',d0
beq.L	war_slime
cmp.b	#'@',d0
beq.L	war_nme
cmp.b	#'~',d0
beq.L	war_df
cmp.b	#'|',d0
beq.L	war_atari

lsl.w 	#1,d0			; da immer 2 Bytes
move.b  0(a2,d0.w),(a1)+
move.b  1(a2,d0.w),(a1)+
bra.L   prepare
convende:
;move.b  #-1,(a1)+
illegal

war_space:
move.b #51,(a1)+
move.b #51,(a1)+
bra prepare
war_hochkomma:
move.b	#78,(a1)+
bra	prepare
war_punkt:
move.b	#71,(a1)+
bra	prepare
war_komma:
move.b	#85,(a1)+
bra	prepare
war_dpunkt:
move.b	#72,(a1)+
bra prepare
war_spunkt:
move.b #73,(a1)+
bra	prepare
war_i:
move.b #16,(a1)+
bra	prepare
war_ausr:
move.b	#74,(a1)+
bra	prepare
war_eins:
move.b	#54,(a1)+
bra	prepare
war_anfuehr:
move.b	#77,(a1)+
bra	prepare
war_klammerl:
move.b	#79,(a1)+
bra	prepare
war_klammerr:
move.b	#80,(a1)+
bra	prepare
war_slime:
move.b	#96,(a1)+
move.b	#97,(a1)+
move.b	#98,(a1)+
bra	prepare
war_nme:
move.b	#99,(a1)+
move.b	#100,(a1)+
move.b	#101,(a1)+
move.b	#102,(a1)+
move.b	#103,(a1)+
bra	prepare
war_df:
move.b	#106,(a1)+
move.b	#107,(a1)+
move.b	#108,(a1)+
move.b	#109,(a1)+
move.b	#110,(a1)+
move.b	#111,(a1)+
move.b	#112,(a1)+
move.b	#113,(a1)+
move.b	#114,(a1)+
bra	prepare
war_atari:
move.b	#117,(a1)+
move.b	#118,(a1)+
move.b	#119,(a1)+
bra	prepare



;-----------------------------
contab: blk.b 66,51	; 0-32
  dc.b 51,51,51,51,92,93,90,91,115,116,104,105,51,51,51,51,51,51 ;!-)
  	dc.b 51,51,81,82,51,51,83,84,51,51,86,87	; *-/
	dc.b 52,53,51,51,55,56,57,58,59,60,61,62,63
	dc.b 64,65,66,67,68,69,70			; 0-9
	dc.b 51,51,51,51,51,51,88,89,51,51,75,76,51,51	; :-@
	dc.b 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15   	; A-H
	dc.b 51,51,17,18 ; i-j
	dc.b 19,20,21,22,23,24,25,26,27,28,29,30,31,32,33 ; K-R
	dc.b 34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50 ; S-Z
	dc.b 51,51,86,87,51,51,51,51,94,95,51,51	; [ - ` 

	dc.b 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15   ; A-H
	dc.b 51,51,17,18 ; i-j
	dc.b 19,20,21,22,23,24,25,26,27,28,29,30,31,32,33 ; K-R
	dc.b 34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50 ; S-Z
	blk.b	270,51
 even	 


