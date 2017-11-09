	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	move.l d0,-(sp)
	
	movem.l $ffff8240.w,d0-d7
	movem.l d0-d7,-(sp)
	
	move.l #%01010101010101010011001100110011,d6
	move.l #%00001111000011110000000000000000,d7
	
	move.l #$78000+160+230,a0
	move.w #197,d1
fill1:	moveq #25,d4
fill2:	move.l d6,(a0)+
	move.l d7,(a0)+
	not.l d7
	clr.w d7
	not.l d6
	dbf d4,fill2
	lea.l 22(a0),a0
	dbf d1,fill1

	move.l #$70000,a0
	moveq #25,d0
rcop3:	moveq #0,d7
	moveq #7,d5
rcop1:	moveq #1,d2
	move.w #1,a1
rcop5:	moveq #1,d6
rcop2:	move.w d7,d4
	moveq #7,d3
rcop4:	move.w a1,d1
	mulu.w d4,d1
	move.w d1,(a0)+
	addq.l #1,d4
	cmp.b #8,d4
	bne.s p4p8
	moveq #0,d4
p4p8:	dbf d3,rcop4
	dbf d6,rcop2
	move.w #$10,a1
	dbf d2,rcop5
	addq.l #1,d7
	dbf d5,rcop1
	dbf d0,rcop3
	
	move.w sr,-(sp)
	move.w #$2700,sr
	move.l $fffffa06.w,-(sp)
	clr.l $fffffa06.w
	move.l $70.w,-(sp)
	lea vbl(pc),a0
	move.l a0,$70.w
	move.l $ffff8200.w,-(sp)
	move.l #%1110000000010000000,$ffff8200.w
	
	move.w #$2300,sr
	
boucle:	cmp.b #$39,$fffffc02.w
	bne.s boucle

	move.w #$2700,sr
	move.l (sp)+,$ffff8200.w
	move.l (sp)+,$70.w
	move.l (sp)+,$fffffa06.w
	move.w (sp)+,sr
	
	movem.l (sp)+,d0-d7
	movem.l d0-d7,$ffff8240.w
	
	move.l (sp)+,2(sp)
	trap #1
	addq.l #6,sp
	
	clr.w -(sp)
	trap #1
	;rts
	
vbl:	
	move.l #%01010101010101010011001100110011,d6
	move.l #%00001111000011111111111111111111,d7
	move.l d6,d4
	move.l d7,d5
change2:	move.l #$78000+160+230+197*230+8,a0
	lea.l log(pc),a1
	moveq #10,d3
logo3:	move.l (a1)+,d1
	moveq #23,d0
logo:	not.l d4
	not.l d5
	clr.w d5
	btst.l d0,d1
	beq.s endlog
	move.l d6,(a0)
	move.l d7,4(a0)
	not.l d6
	not.l d7
	move.w d2,d7
	move.l d6,8*230(a0)
	move.l d7,8*230+4(a0)
	not.l d6
	not.l d7
	move.w d2,d7
	move.l d4,16*230(a0)
	move.l d5,16*230+4(a0)
endlog:	addq.l #8,a0
	dbf d0,logo
	lea.l 230-24*8+15*230(a0),a0
	dbf d3,logo3

	lea change2+2(pc),a0
	cmp.l #$78000+160+230+13*230+8,(a0)
	beq.s a0p78
	sub.l #230,(a0)
a0p78:
	lea.l change+2(pc),a0
	add.l #2,(a0)
	cmp.l #$70000+2*8,(a0)
	bne.s cou
	sub.l #2*8,(a0)
cou:	
	lea.l $ffff8209.w,a0
sync:	move.b (a0),d0
	beq.s sync
	neg.w d0
	lsr.l d0,d0
	moveq #2,d0
	moveq #0,d1
	lea.l $ffff8260.w,a0
	lea.l $ffff820a.w,a1
	moveq #15+2+1+1,d2
p3:	dbf d2,p3
change:	move.l #$70000,a5
	move.w #198,d3
over:
	move.b d0,(a0)
	nop
	move.b d1,(a0)
	movem.l a2/a3/a4/a6,$ffff8250.w
	moveq #27-3-2-3-2-3+1+1,d2
p1:	dbf d2,p1
	movem.l (a5),d4-d7
	movem.l 32(a5),a2/a3/a4/a6
	lea.l 32*2(a5),a5
	move.b d1,(a1)
	move.b d0,(a1)
	move.w #1,d2
p4:	dbf d2,p4
	move.l d4,$ffff8240.w
	move.b d0,(a0)
	nop
	move.b d1,(a0)
	movem.l d5-d7,$ffff8244.w
	dbf d3,over

	clr.w $ffff8240.w
	rte

log:	dc.l %111011101110111011101111
	dc.l %100010001000010010101001
	dc.l %111011001000010010101111 
	dc.l %001010001000010010101010
	dc.l %111011101110010011101001
	dc.l %0
	dc.l %000000000001100000000000
	dc.l %000000000011100000000000
	dc.l %000000000001100000000000
	dc.l %000000000001100000000000
	dc.l %000000000011110000000000
	dc.b 'DRABOB  1993'