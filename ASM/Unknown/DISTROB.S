            BRA      MAIN

VSYNH:      MOVEM.L     D0/A0-A1,-(SP)
            MOVE.L      #1,READ
            MOVE.L     #PALETTE1,A0
            MOVE.L     #$FF8240,A1
            MOVE.L      (A0)+,(A1)+
            MOVE.L      (A0)+,(A1)+
            MOVE.L      (A0)+,(A1)+
            MOVE.L      (A0)+,(A1)+
            MOVE.L      (A0)+,(A1)+
            MOVE.L      (A0)+,(A1)+
            MOVE.L      (A0)+,(A1)+
            MOVE.L      (A0)+,(A1)+
            MOVEM.L     (SP)+,D0/A0-A1
            RTS

VSYNC:      JSR      VSYNH
            RTE

RETINTS:    MOVE.W      #$2700,SR
            MOVE.L      OLDVS,$70
            MOVE.W      #$2300,SR
            RTS

SETINTS:    MOVE.W      #37,-(SP)
            TRAP        #14
            ADDQ.L      #2,SP
            MOVE.W      #$2700,SR
            MOVE.L      $70,OLDVS
            MOVE.L      #VSYNC,$70
            MOVE.W      #$2300,SR
            RTS

dist2:
	move.l	CURRPICADD,a1
	lea	19200(a1),a1
	move.l	#shifteddistblocks,a0
	lea	4000(a0),a0
	lea	disttab(pc),a2
	moveq	#24,d1
omd21:	
	add.l	(a2)+,a0
	move.l	a0,a3
	move.l	a1,a4
	lea	-160(a1),a1
	moveq	#19,d0
omd22:	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	lea	-160(a4),a4
	dbra	d0,omd22
	dbra	d1,omd21
	rts	   

dist:
	move.l	CURRPICADD,a1
	lea	4688(a1),a1
	move.l	#shifteddistblocks,a0
	lea	1568(a0),a0
	lea	disttab(pc),a2
	move.l	a0,a3
	add.l	(a2),a3
	move.l	a1,a4
	lea	-160(a1),a1
	moveq	#6,d0
	lea	bendtab(pc),a5
	moveq	#0,d2
omd3:	
	add.l	(a5)+,a4
	move.b	d2,(a4)
	move.b	d2,2(a4)
	move.b	d2,4(a4)
	add.l	(a5)+,a4
	move.b	d2,-3(a4)
	move.b	d2,-1(a4)
	move.b	d2,1(a4)
	dbra	d0,omd3
	moveq	#27,d1
omd1:	
	add.l	(a2)+,a0
	move.l	a0,a3
	move.l	a1,a4
	lea	-160(a1),a1
	lea	bendtab(pc),a5
omd2:	
	add.l	(a5)+,a4
	move.b	(a3),(a4)
	move.b	2(a3),2(a4)
	move.b	4(a3),4(a4)
	add.l	(a5)+,a4
	move.b	1(a3),-3(a4)
	move.b	3(a3),-1(a4)
	move.b	5(a3),1(a4)
	add.l	(a5)+,a4
	move.b	8(a3),(a4)
	move.b	10(a3),2(a4)
	move.b	12(a3),4(a4)
	add.l	(a5)+,a4
	move.b	9(a3),-3(a4)
	move.b	11(a3),-1(a4)
	move.b	13(a3),1(a4)
	add.l	(a5)+,a4
	move.b	16(a3),(a4)
	move.b	18(a3),2(a4)
	move.b	20(a3),4(a4)
	add.l	(a5)+,a4
	move.b	17(a3),-3(a4)
	move.b	19(a3),-1(a4)
	move.b	21(a3),1(a4)
	add.l	(a5)+,a4
	move.b	24(a3),(a4)
	move.b	26(a3),2(a4)
	move.b	28(a3),4(a4)
	add.l	(a5)+,a4
	move.b	25(a3),-3(a4)
	move.b	27(a3),-1(a4)
	move.b	29(a3),1(a4)
	add.l	(a5)+,a4
	move.b	32(a3),(a4)
	move.b	34(a3),2(a4)
	move.b	36(a3),4(a4)
	add.l	(a5)+,a4
	move.b	33(a3),-3(a4)
	move.b	35(a3),-1(a4)
	move.b	37(a3),1(a4)
	add.l	(a5)+,a4
	move.b	40(a3),(a4)
	move.b	42(a3),2(a4)
	move.b	44(a3),4(a4)
	add.l	(a5)+,a4
	move.b	41(a3),-3(a4)
	move.b	43(a3),-1(a4)
	move.b	45(a3),1(a4)
	add.l	(a5)+,a4
	move.b	48(a3),(a4)
	move.b	50(a3),2(a4)
	move.b	52(a3),4(a4)
	add.l	(a5)+,a4
	move.b	49(a3),-3(a4)
	move.b	51(a3),-1(a4)
	move.b	53(a3),1(a4)
	lea	56(a3),a3
	dbra	d1,omd1
	add.l	-4(a2),a0
	move.l	a0,a3
	move.l	a1,a4
	lea	-160(a1),a1
	moveq	#6,d0
	lea	bendtab(pc),a5
	moveq	#0,d2
omd4:	
	add.l	(a5)+,a4
	move.b	d2,(a4)
	move.b	d2,2(a4)
	move.b	d2,4(a4)
	add.l	(a5)+,a4
	move.b	d2,-3(a4)
	move.b	d2,-1(a4)
	move.b	d2,1(a4)
	dbra	d0,omd4
	rts	   

distyit2:
	lea	bendtab(pc),a0
	lea	80(a0),a0
	moveq	#4,d0
omdiy1:	move.l	16(a0),20(a0)
	move.l	12(a0),16(a0)
	move.l	8(a0),12(a0)
	move.l	4(a0),8(a0)
	move.l	(a0),4(a0)
	lea	-20(a0),a0
	dbra	d0,omdiy1
	lea	bendtab(pc),a0
	move.w	distypos(pc),d0
	addq.w	#1,d0
	cmp.w	#50,d0
	blt	forbidiy2
	moveq	#0,d0
forbidiy2:
	move.w	d0,distypos
	lea	disttaby(pc),a1
	lsl.w	#1,d0
	move.w	(a1,d0.w),d0
	mulu	#160,d0
	move.l	d0,(a0)+
	sub.l	d0,(a0)
	add.l	#4,(a0)
	rts
distyit:
	lea	disttaby(pc),a0
	lea	bendtab(pc),a1
	lea	tab160(pc),a2
	move.l	distypos,d0
	add.l	#3,d0
	cmp.l	#128,d0
	blt	forbidi31
	sub.l	#128,d0
forbidi31:
	move.l	d0,distypos
	lsl.l	#1,d0
	move.l	#0,d2
	moveq	#14,d1
omdi31:	move.w	(a0,d0.w),d3
	lsr.l	#1,d3
	move.w	d3,d4
	sub.w	d2,d3
	move.w	d4,d2
	add.l	#13,d3
	lsl.l	#2,d3
	move.l	(a2,d3.w),d3
	sub.l	#2076,d3
	move.l	d3,(a1)+
	add.l	#8,d0
	and.l	#255,d0
	dbra	d1,omdi31
	sub.l	#4,bendtab
	rts

distypos:	dc.l	0
disttaby:
	dc.w	12,12,13,13,14,14,15,15
	dc.w	16,16,17,17,18,18,19,19
	dc.w	20,20,20,21,21,21,22,22
	dc.w	22,22,23,23,23,23,23,23
	dc.w	23,23,23,23,23,23,23,22
	dc.w	22,22,22,21,21,21,20,20
	dc.w	20,19,19,18,18,17,17,16
	dc.w	16,15,15,14,14,13,13,12
	dc.w	12,11,10,10, 9, 9, 8, 8
	dc.w	 7, 7, 6, 6, 5, 5, 4, 4
	dc.w	 4, 3, 3, 2, 2, 2, 1, 1
	dc.w	 1, 1, 0, 0, 0, 0, 0, 0
	dc.w	 0, 0, 0, 0, 0, 0, 0, 1
	dc.w	 1, 1, 1, 2, 2, 2, 3, 3
	dc.w	 3, 4, 4, 5, 5, 6, 6, 7
	dc.w	 7, 8, 8, 9, 9,10,10,11
	
	dc.w	12,13,14,16,17,18,19,20,21,22
	dc.w	22,23,23,23,23,22,22,21,20,19
	dc.w	18,17,16,14,13,12,10, 9, 7, 6
	dc.w	 5, 4, 3, 2, 1, 1, 0, 0, 0, 0
	dc.w	 1, 1, 2, 3, 4, 5, 6, 7, 9,10

	dc.w	12,13,14,16,17,18,19,20,21,22
	dc.w	22,23,23,23,23,22,22,21,20,19
	dc.w	18,17,16,14,13,12,10, 9, 7, 6
	dc.w	 5, 4, 3, 2, 1, 1, 0, 0, 0, 0
	dc.w	 1, 1, 2, 3, 4, 5, 6, 7, 9,10

	dc.w	0,1,2,3,4,5,6,7,8,9
	dc.w	10,11,12,13,14,15,16,17,18,19
	dc.w	20,21,22,23,24,24,23,22,21,20
	dc.w	19,18,17,16,15,14,13,12,11,10
	dc.w	9,8,7,6,5,4,3,2,1,0

bendtab:	dc.l	0
		dc.l	-156
		dc.l	-156
		dc.l	4
		dc.l	-156
		dc.l	4
		dc.l	4
		dc.l	4
		dc.l	164
		dc.l	4
		dc.l	164
		dc.l	164
		dc.l	324
		dc.l	164

		DCB.l	200,-156

tab56:	DCB.l	200,0

distit:
	lea	disttab(pc),a0
	lea	100(a0),a0
	moveq	#5,d0
omdi1:	move.l	16(a0),20(a0)
	move.l	12(a0),16(a0)
	move.l	8(a0),12(a0)
	move.l	4(a0),8(a0)
	move.l	(a0),4(a0)
	lea	-20(a0),a0
	dbra	d0,omdi1
	lea	disttab(pc),a0
	lea	disttabx(pc),a1
	lea	distsorttab(pc),a2
	move.w	distpos(pc),d0
	addq.w	#1,d0
	move.l	d0,d1
	lsl.l	#1,d1	
	move.w	(a1,d1.w),d2
	tst.w	d2
	bge	forbidi2
	addq.w	#1,distsortpos
	and.w	#63,distsortpos
	move.w	distsortpos,d3
	lsl.w	#2,d3
	move.l	(a2,d3.w),d3
	move.l	d3,d0
	sub.l	#disttabx,d0
	lsr.l	#1,d0
forbidi2:
	move.w	d0,distpos
	lsl.w	#1,d0
	move.w	(a1,d0.w),d0
	and.l	#15,d0
	mulu	#1568,d0
	sub.l	#56,d0
	move.l	d0,(a0)+
	sub.l	d0,(a0)
	sub.l	#56,(a0)
	rts

disttab:		dc.l	12544
		DCB.l	50,-56
distpos:		dc.w	0
distsortpos:	dc.w	0
distsorttab:	dc.l	t5,t5,t5,t5,t1,t5,t5,t5
		dc.l	t1,t2,t1,t1,t1,t1,t2,t1
		dc.l	t1,t2,t3,t1,t1,t4,t1,t5
		dc.l	t5,t5,t1,t1,t1,t1,t1,t3	
		dc.l	t6,t5,t1,t2,t3,t2,t1,t5
		dc.l	t1,t6,t1,t1,t1,t2,t1,t5
		dc.l	t5,t5,t6,t5,t1,t4,t3,t1
		dc.l	t1,t1,t1,t4,t1,t1,t1,t3

		dc.l	t1,t1,t1,t1,t2,t1,t1,t2
		dc.l	t1,t1,t1,t2,t3,t2,t2,t1
		dc.l	t1,t3,t1,t2,t2,t3,t3,t3
		dc.l	t1,t1,t1,t1,t1,t1,t2,t1

distsort:	dc.w	0	
disttabx:
t1:
	dc.w	 7, 8, 9,10,11,12,13,13,14,14
	dc.w	15,15,15,15,15,15,14,14,13,13
	dc.w	12,11,10, 9, 8, 8, 7, 6, 5, 4
	dc.w	 3, 2, 2, 1, 1, 0, 0, 0, 0, 0
	dc.w	 0, 1, 1, 2, 2, 3, 4, 5, 6, 7
	dc.w	-1
t2:
	dc.w	 7, 8, 9,10,11,12,12,12,12,11
	dc.w	10, 9, 8, 6, 5, 4, 3, 2, 2, 2
	dc.w	 2, 3, 4, 5, 6
	dc.w	-1
t3:
	dc.w	 7, 9,11,13,14,15,15,15,14,13
	dc.w	12,10, 8, 7, 5, 3, 2, 1, 0, 0
	dc.w	 0, 1, 2, 4, 6
	dc.w	-1

t4:	dc.w	7,8,9,10,11,12,13,14,15
	dc.w	14,13,12,11,10,9,8,7,6
	dc.w	5,4,3,2,1,0,1,2,3,4,5,6
	dc.w	-1

t5:	dc.w	 8, 8, 9,10,10,11,12,12
	dc.w	13,13,14,14,14,15,15,15
	dc.w	15,15,15,15,14,14,14,13
	dc.w	13,12,12,11,10,10, 9, 8
	dc.w	 8, 7, 6, 5, 5, 4, 3, 3
	dc.w	 2, 2, 1, 1, 1, 0, 0, 0
	dc.w	 0, 0, 0, 0, 1, 1, 1, 2
	dc.w	 2, 3, 3, 4, 5, 5, 6, 7
	dc.w	-1

t6:	dc.w	 8, 8, 8, 9, 9, 9,10,10
	dc.w	10,11,11,11,12,12,12,13
	dc.w	13,13,13,14,14,14,14,14
	dc.w	14,15,15,15,15,15,15,15
	dc.w	15,15,15,15,15,15,15,15
	dc.w	14,14,14,14,14,14,13,13
	dc.w	13,13,12,12,12,11,11,11
	dc.w	10,10,10, 9, 9, 9, 8, 8
	dc.w	 8, 7, 7, 6, 6, 6, 5, 5
	dc.w	 5, 4, 4, 4, 3, 3, 3, 2
	dc.w	 2, 2, 2, 1, 1, 1, 1, 1
	dc.w	 1, 0, 0, 0, 0, 0, 0, 0
	dc.w	 0, 0, 0, 0, 0, 0, 0, 0
	dc.w	 1, 1, 1, 1, 1, 1, 2, 2
	dc.w	 2, 2, 3, 3, 3, 4, 4, 4
	dc.w	 5, 5, 5, 6, 6, 6, 7, 7
	dc.w	-1 

shiftdistblocks:
		lea	shifteddistblocks,a1
		moveq	#15,d7
omsdb1: 		move.l	d7,-(sp)
		moveq	#15,d0
		sub.l	d7,d0
		lea	unshifteddistblock(pc),a0
		moveq	#27,d1
omsdb2:
		moveq	#5,d2
		moveq	#0,d3
		moveq	#0,d4
omsdb3:
		moveq	#0,d5
		move.w	(a0)+,d5
		ror.l	d0,d5
		or.w	d3,d5
		move.w	d5,(a1)+
		swap	d5
		move.w	d5,d3
		swap	d3
		moveq	#0,d5
		move.w	(a0)+,d5
		ror.l	d0,d5
		or.w	d3,d5
		move.w	d5,(a1)+
		swap	d5
		move.w	d5,d3
		swap	d3
		moveq	#0,d5
		move.w	(a0)+,D5
		swap	d5
		lsr.l	d0,d5
		move.w	d5,d6
		swap	d5
		or.w	d4,d5
		move.w	d6,d4
		swap	d4
		move.w	d5,(a1)+
		moveq	#0,d5
		move.w	(a0)+,d5
		swap	d5
		lsr.l	d0,d5
		move.w	d5,d6
		swap	d5
		or.w	d4,d5
		move.w	d6,d4
		swap	d4
		move.w	d5,(a1)+
		dbra	d2,omsdb3
		move.w	d3,(a1)+
		swap	d3
		move.w	d3,(a1)+
		move.w	d4,(a1)+
		swap	d4
		move.w	d4,(a1)+
		dbra	d1,omsdb2
		move.l	(sp)+,d7
		dbra	d7,omsdb1
		rts

INITVARS:   
            	MOVE.L      #tab160,A1
	    	move.l	#tab56,a2
            	MOVE.L      #0,D1
	    	moveq	#0,d3
           	MOVE.L      #199,D2
OMIV1:     
            	MOVE.L      D1,(A1)+
	    	move.l	d3,(a2)+
            	ADD.L       #160,D1
	    	add.l	#56,d3
            	DBRA        D2,OMIV1
            	RTS
            
MAIN:     CLR.L       -(SP)
          MOVE.W      #32,-(SP)
          TRAP        #1
          ADDQ.L      #6,SP
          MOVE.L      D0,SAVSTK

          MOVE.W      #0,-(SP)
          MOVE.L      #-1,-(SP)
          MOVE.L      #-1,-(SP)
          MOVE.W      #5,-(SP)
          TRAP        #14
          ADD.L       #12,SP
          MOVE.L     #OLDPAL,A1
          MOVE.L     #$FF8240,A0
          MOVE.L      (A0)+,(A1)+
          MOVE.L      (A0)+,(A1)+
          MOVE.L      (A0)+,(A1)+
          MOVE.L      (A0)+,(A1)+
          MOVE.L      (A0)+,(A1)+
          MOVE.L      (A0)+,(A1)+
          MOVE.L      (A0)+,(A1)+
          MOVE.L      (A0)+,(A1)+
          JSR         INITVARS
        	BSR shiftdistblocks
          MOVE.W      #3,-(SP)
          TRAP        #14
          ADDQ.L      #2,SP
          MOVE.L      D0,CURRPICADD
          JSR         SETINTS


om1:	bsr	distit
	bsr	distyit
	bsr	dist

OM15:     CMP.L     #1,READ
          BNE       OM15
          MOVE.L    #0,READ
          cmp.b     #185,$fffc02
          beq       ut19
          BRA       om1
ut19:     JSR       RETINTS
          MOVE.L    #$FF8240,A1
          MOVE.L    #OLDPAL,A0
          MOVE.L    (A0)+,(A1)+
          MOVE.L    (A0)+,(A1)+
          MOVE.L    (A0)+,(A1)+
          MOVE.L    (A0)+,(A1)+
          MOVE.L    (A0)+,(A1)+
          MOVE.L    (A0)+,(A1)+
          MOVE.L    (A0)+,(A1)+
          MOVE.L    (A0)+,(A1)+
          MOVE.W    #1,-(SP)
          MOVE.L    #-1,-(SP)
          MOVE.L    #-1,-(SP)
          MOVE.W    #5,-(SP)
          RAP       #14
          ADD.L     #12,SP
          MOVE.L    SAVSTK,-(SP)
          MOVE.W    #32,-(SP)
          TRAP      #1
          ADDQ.L    #6,SP
	RTS

SAVSTK:     	Dc.L      1
OLDPAL:     	DCB.W     16,0
OLDVS:      	Dc.L      1
CURRPICADD: 	Dc.L      1
tab160:     	DS.L      200
TOM:        	DS.L      16
PALETTE1:   
      		dc.w	$0000,$0310,$0420,$0430,$0530,$0540,$0650,$0770
      		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0777

READ:        	Dc.L      1

unshifteddistblock:
	dc.w	$FFF0,$FFFF,$FFFF,$0000,$7FFF,$FFFF,$FFFF,$0000
	dc.w	$87F8,$07FF,$87FF,$0000,$1FF8,$FFF8,$FFF8,$0000
	dc.w	$E7F8,$FFFF,$FFFF,$0000,$1FF8,$FFF8,$FFF8,$0000
	dc.w	$FFFF,$FFFF,$FFFF,$0000,$FFFF,$FFFE,$FFFF,$0000
	dc.w	$BFFF,$3FFF,$3FFF,$0000,$FFFA,$FFFC,$FFFE,$0000
	dc.w	$FFFF,$FFFF,$FFFF,$0000,$FFF8,$FFFE,$FFFC,$0000
	dc.w	$ECBD,$E3C1,$DFFE,$0000,$FC03,$FC3E,$03FE,$0000
	dc.w	$FCBD,$7BC1,$7FFE,$0000,$FC07,$FC39,$03FE,$0001
	dc.w	$ECBD,$E3C1,$DFFE,$0000,$FC05,$FC3A,$03FC,$0000
	dc.w	$CFBB,$C7C3,$FFFC,$0000,$DAE3,$D81E,$27FE,$0000
	dc.w	$EFBB,$E7C3,$FFFC,$0000,$DAE1,$D81F,$27FE,$0000
	dc.w	$CFBB,$C7C3,$FFFC,$0000,$DAE3,$D81E,$27FC,$0000
	dc.w	$D733,$CFC3,$FFFC,$0000,$C7C7,$C03E,$3FFE,$0000
	dc.w	$D733,$CFC3,$FFFC,$0000,$C7C7,$C03F,$3FFE,$0000
	dc.w	$D733,$CFC3,$FFFC,$0000,$C7C5,$C03E,$3FFE,$0000
	dc.w	$DE7F,$FF8F,$FFF0,$0000,$4597,$027E,$FFFE,$0000
	dc.w	$DE7F,$FF8F,$FFF0,$0000,$4596,$027F,$FFFE,$0000
	dc.w	$DE7F,$FF8F,$FFF0,$0000,$4597,$027E,$FFFE,$0000
	dc.w	$FFCF,$FE0E,$FFF1,$0000,$781F,$07FE,$FFFE,$0000
	dc.w	$FFCF,$FE0E,$FFF1,$0000,$781E,$07FF,$FFFE,$0000
	dc.w	$FFCF,$FE0E,$FFF1,$0000,$781F,$07FE,$FFFE,$0000
	dc.w	$F9DC,$FE5C,$FFA3,$0000,$F97F,$07FE,$FFFE,$0000
	dc.w	$F9DC,$FE5C,$FFA3,$0000,$F97F,$07FE,$FFFE,$0000
	dc.w	$F9DC,$FE5C,$FFA3,$0000,$F979,$07FE,$FFFE,$0000
	dc.w	$FFFF,$8000,$C00F,$0000,$CFFF,$3000,$F000,$0000
	dc.w	$E77F,$F840,$FF80,$0000,$FFFF,$01FE,$01FE,$0000
	dc.w	$E70F,$F870,$FF80,$0000,$F9F1,$07FA,$01FE,$0000
	dc.w	$FFFF,$0008,$801F,$0000,$DFFF,$3000,$F000,$0000
	dc.w	$5CFF,$E080,$FF00,$0000,$FF3F,$01FE,$02FE,$0000
	dc.w	$DC40,$E0BF,$FF7F,$0000,$3BF9,$FFF0,$FCFE,$0000
	dc.w	$001E,$0019,$001F,$0000,$7C00,$F000,$F000,$0000
	dc.w	$53E0,$E380,$FC00,$0000,$03FF,$0200,$0100,$0000
	dc.w	$D39F,$E3FF,$FC7F,$0000,$F3E5,$FFF0,$FFFE,$0000
	dc.w	$0018,$001F,$001F,$0000,$3C00,$F000,$F000,$0000
	dc.w	$66E0,$C680,$F900,$0000,$03FF,$0000,$0200,$0000
	dc.w	$66D0,$C68F,$F97F,$0000,$3F89,$FFFA,$FFF4,$0000
	dc.w	$0018,$001F,$001F,$0000,$FC00,$F000,$F000,$0000
	dc.w	$6D60,$CD00,$F280,$0000,$0000,$0000,$0000,$0000
	dc.w	$6D50,$CD0F,$F2FF,$0000,$FE3F,$FFCC,$FFF0,$0000
	dc.w	$001D,$001F,$001F,$0000,$FC00,$F000,$F000,$0000
	dc.w	$5960,$D800,$E780,$0000,$0000,$0000,$0000,$0000
	dc.w	$5945,$D83F,$E7FF,$0000,$FF6E,$FF80,$FFF0,$0000
	dc.w	$001F,$001F,$001F,$0000,$FC00,$F000,$F000,$0000
	dc.w	$64E0,$E000,$DF80,$0000,$0000,$0000,$0000,$0000
	dc.w	$648F,$E07F,$DFFF,$0000,$F19E,$FE10,$FFE8,$0000
	dc.w	$000F,$001F,$001F,$0000,$FC00,$F000,$F000,$0000
	dc.w	$EE60,$E180,$DF80,$0000,$0000,$0000,$0000,$0000
	dc.w	$6E0F,$E1FF,$DFFF,$0000,$F6E3,$F8E4,$FF1C,$0000
	dc.w	$000F,$001F,$001F,$0000,$CC00,$F000,$F000,$0000
	dc.w	$E840,$C7A0,$FF80,$0000,$03FF,$03FF,$03FF,$0000
	dc.w	$683F,$C7FF,$FFFF,$0000,$8CC5,$F0C2,$FF3C,$0000
	dc.w	$000F,$001F,$001F,$0000,$1C00,$E000,$F000,$0000
	dc.w	$F220,$CFE0,$FF80,$0000,$03FF,$03FE,$03FF,$0000
	dc.w	$727F,$CF80,$FF80,$0000,$FFFB,$01E6,$001C,$0000
	dc.w	$000F,$001F,$001F,$0000,$9C00,$E000,$F000,$0000
	dc.w	$E3F7,$DFCF,$FFBF,$0000,$FF03,$FF3E,$FFFE,$0000
	dc.w	$E3EC,$DF9F,$FFFF,$0000,$03C5,$FCDC,$FF3E,$0000
	dc.w	$0019,$001F,$001F,$0000,$7C00,$8000,$F000,$0000
	dc.w	$CFEF,$FFDF,$FFFF,$0000,$FFE3,$FF1E,$FEFE,$0000
	dc.w	$CFF7,$FFCF,$FFFF,$0000,$FF0D,$F91E,$FEFE,$0000
	dc.w	$001D,$001E,$001F,$0000,$EC00,$0000,$F000,$0000
	dc.w	$EFF5,$DFFE,$FFFF,$0000,$E73B,$0706,$F8FE,$0000
	dc.w	$EFF7,$DFFC,$FFFF,$0000,$CE79,$0E1E,$F1FE,$0000
	dc.w	$0019,$001E,$001F,$0000,$EC00,$2000,$D000,$0000
	dc.w	$FFE9,$FFFE,$FFFF,$0000,$E8E7,$281E,$D7FE,$0000
	dc.w	$FFEB,$FFFC,$FFFF,$0000,$D1C7,$503E,$AFFE,$0000
	dc.w	$001A,$001C,$001F,$0000,$1C00,$1000,$E000,$0000
	dc.w	$FFC2,$FFFC,$FFFF,$0000,$196D,$18BE,$E7FE,$0000
	dc.w	$FFC2,$FFFC,$FFFF,$0000,$196D,$18BE,$E7FE,$0000
	dc.w	$0018,$0018,$001F,$0000,$3C00,$3000,$C000,$0000
	dc.w	$DF18,$FFE0,$FFFF,$0000,$33B9,$307E,$CFFE,$0000
	dc.w	$FF18,$FFE0,$FFFF,$0000,$33B9,$307E,$CFFE,$0000
	dc.w	$0018,$0018,$001F,$0000,$4C00,$4000,$B000,$0000
	dc.w	$3070,$DF80,$FFFF,$0000,$46EF,$4170,$BFFC,$0000
	dc.w	$F070,$FF80,$FFFF,$0000,$46EF,$4170,$BFFC,$0000
	dc.w	$0019,$0019,$001E,$0000,$1C00,$0000,$F000,$0000
	dc.w	$70A1,$0F41,$77FE,$0000,$102F,$03F0,$FFF0,$0000
	dc.w	$E8A1,$FF41,$FFFE,$0000,$102E,$03F0,$FFF0,$0000
	dc.w	$001F,$0010,$0018,$0000,$FC00,$0000,$0000,$0000
	dc.w	$21FF,$1E00,$2000,$0000,$FFFE,$0000,$0000,$0000
	dc.w	$FFFF,$8000,$C000,$0000,$FFFC,$0000,$0000,$0000
	dc.w	$001F,$0000,$0010,$0000,$FC00,$0000,$0000,$0000
	dc.w	$03FF,$0400,$0000,$0000,$FFF0,$0000,$0000,$0000
	dc.w	$FFFF,$0000,$8000,$0000,$FFF0,$0000,$0000,$0000

shifteddistblocks:	dc.l	0