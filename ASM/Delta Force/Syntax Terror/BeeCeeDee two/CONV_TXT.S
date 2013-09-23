;convert ascii to unreadable background-scroller
; (BCD2)
; (C) by New Mode

convert:
	lea	source(pc),a0
	lea	dest(pc),a1
	lea	contab(pc),a2
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
	move.l	a1,d7
	sub.l	#dest,d7	; Length in Bytes
	
	clr.w	-(a7)
	pea	out_file(pc)
	move.w	#$3c,-(a7)	; F-Create
	trap	#1
	addq.l	#8,a7
	move.w	d0,-(a7)
	pea	dest(pc)
	move.l	d7,-(a7)
	move.w	d0,-(a7)
	move.w	#$40,-(a7)	; F-Write
	trap	#1
	lea	12(a7),a7
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7		; F-Close
	
	clr.w	-(a7)
	trap	#1
	
	

;-----------------------------
contab: dc.b $ff                ;$00
        dcb.b 32,49             ;bis $20
        dc.b 41,49              ;$21,$22
        dcb.b 4,49              ;bis $26
        dc.b 45,37,38,36,54,43,48,39,36                 ;$27-$2f
        dc.b 35,26,27,28,29,30,31,32,33,34,40,44        ;$30-$3b
        dcb.b 3,49              ;$3c-$3e
        dc.b 42,36              ;$3f,$40
        dc.b 00,01,02,03,04,05,06,07                    ;$41-$48
        dc.b 08,09,10,11,12,13,14,15                    ;$49-$50
        dc.b 16,17,18,19,20,21,22,23,24,25              ;$51-$5a
        dcb.b 6,46              ;$5b-$60
        dc.b 00,01,02,03,04,05,06,07                    ;$61-$68
        dc.b 08,09,10,11,12,13,14,15                    ;$69-$70
        dc.b 16,17,18,19,20,21,22,23,24,25              ;$71-$7a
        dcb.b 6,49              ;$7b-$80

        dc.b 49,49,49,49        ;$81-$84
        dcb.b 9,49             ;$85-$8d
        dc.b 49                 ;$8e
        dcb.b 5,49              ;$90-$94
        dcb.b 11,49             ;$95-$9e
        dcb.b 97,49
	EVEN

source:	INCBIN bigtext.txt
	EVEN
source_end:
textlen EQU source_end-source

dest:	ds.b textlen+100	; 100 Bytes more 
	EVEN
out_file:
	dc.b "bigtext.img",0
	EVEN