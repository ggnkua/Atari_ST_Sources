


* Formatage sous STOS
magic     equ $87654321
filler    equ $e5e5
filler0   equ $0

debut	move.w d0,sdsf		;# de face (0 / 1)
	move.w d1,trsf		;# pistes	 (80 / 81)
	move.w d2,sptf		;# secteurs (9 / 10)
	move.w d3,lwf		;# du drive (0 / 1)
	move.l a0,buffer		;a0---> buffer de 8 k

forma     move trsf,trsf1
          subq #1,trsf1

floop     move sdsf,face

floop1    bsr fmttr
          bne error
          subq #1,face
          bpl floop1
          subq #1,trsf1
          bpl floop

putboot   clr -(sp)
          move #2,d0
          or sdsf,d0
          move d0,-(sp)
          move.l #$11000000,-(sp)
          move.l buffer,-(sp)
          move #$12,-(sp)
          trap #14
          add.l #14,sp

          move.l buffer,a0
          clr.l d0
          cmp.w #9,sptf
          beq ok
          move.b #10,24(a0)
          move trsf,d1
          tst sdsf
          beq sd11
          lsl #1,d1

sd11      bsr addsec

ok        cmp #80,trsf
          beq trok
          move #18,d1
          tst sdsf
          beq sd12
          lsl #1,d1
sd12      bsr addsec
trok:
          move #1,-(sp)
          move.w #0,-(sp)
          move.w #0,-(sp)
          move.w #1,-(sp)
          move lwf,-(sp)
          clr.l -(sp)
          move.l buffer,-(sp)
          move #9,-(sp)
          trap #14
          add.l #20,sp
          tst d0
          bne error
	moveq #0,d0
	rts

addsec    move.b 20(a0,d0),d2
          lsl #8,d2
          move.b 19(a0,d0),d2
          add d1,d2
          move.b d2,19(a0,d0)
          lsr #8,d2
          move.b d2,20(a0,d0)
          rts

error     moveq #1,d0
	rts

fmttr:
          clr -(sp)
apres:
          move.l #magic,-(sp)
          move.w #1,-(sp)
          move face,-(sp)
          move trsf1,-(sp)
          move sptf,-(sp)
          move lwf,-(sp)
          clr.l -(sp)
          move.l buffer,-(sp)
          move #10,-(sp)
          trap #14
          add.l #26,sp
	tst.w d0
	rts

sdsf      dc.w 1
trsf      dc.w 80
trsf1     dc.w 80
sptf      dc.w 9
lwf       dc.w 0
face      dc.w 0
buffer    dc.l 0
         

