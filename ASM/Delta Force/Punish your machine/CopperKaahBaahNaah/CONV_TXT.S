;convert ascii to small-scroller
; Copper-Kaahh-Baah-Naah

source = $180000
dest   = $190000

x:
move.l	#source,a0
move.l	#dest,a1
move.l	#contab,a2
prepare:
moveq	#0,d0
move.b	(a0)+,d0
beq.s	convende
cmp.b	#$0a,d0
beq.s	prepare
cmp.b	#$0d,d0
beq.s	prepare
move.b  0(a2,d0.w),(a1)+
bra.s   prepare
convende:
move.b  #-1,(a1)+
illegal


;-----------------------------
contab: dc.b $ff                ;$00
        blk.b 32,45             ;bis $20
        dc.b 40,44              ;!,"
        blk.b 4,45              ;bis $26
        dc.b 44,36,37,45,45,43,38,42,38                ;$27-$2f
        dc.b 26,27,28,29,30,31,32,33,34,35,41,43        ;$30-$3b
        blk.b 3,45              ;$3c-$3e
        dc.b 39,45              ;$3f,$40
        dc.b 00,01,02,03,04,05,06,07                    ;$41-$48
        dc.b 08,09,10,11,12,13,14,15                    ;$49-$50
        dc.b 16,17,18,19,20,21,22,23,24,25              ;$51-$5a
        blk.b 5,45              ;$5b-$5f
        dc.b 44			; $60
	dc.b 00,01,02,03,04,05,06,07                    ;$61-$68
        dc.b 08,09,10,11,12,13,14,15                    ;$69-$70
        dc.b 16,17,18,19,20,21,22,23,24,25              ;$71-$7a
        blk.b 6,45              ;$7b-$80
	blk.b	255-$80,45

