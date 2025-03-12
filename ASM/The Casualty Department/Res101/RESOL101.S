*	RES 101 INTRO CODE BY DR DYNAC



	opt	O+,W-

	dc.w	$a00a
	bsr	super
	bsr	play
	bsr	go
	bsr	stop
	BRA	LOAD
	
	bsr	wait
	move.w	#$777,$ffff8240	
	move.w	#$000,$ffff825e
desk	clr.w	-(a7)
	trap	#1


go	lea	cls(pc),a6
	bsr	print
	
	lea	count(pc),a5
	move.l	#counten-count-1,d5
intro	move.b	(a5)+,d6
	moveq	#20,d7
	bsr	conout
	bsr	vsync
	lea	cls(pc),a6
	bsr	print
	dbf	d5,intro		

;	bsr	wait
	lea	enable(pc),a6
	bsr	print

	moveq	#16,d6
	bsr	cright

	
	lea	red(pc),a6
	bsr	print
	lea	tcd(pc),a5
	move.l	#tcdend-tcd-1,d5
	bsr	loop

	moveq	#4,d6
	bsr	cleft

	lea	black(pc),a6
	bsr	print
	lea	pres(pc),a5
	move.l	#presend-pres-1,d5
	bsr	loop
	
	moveq	#3,d6
	bsr	cdown
	moveq	#9,d6
	bsr	cleft
	
	lea	blue(pc),a6
	bsr	print
	lea	apb(pc),a5
	move.l	#apbend-apb-1,d5
	bsr	loop
	bsr	wait
		
	moveq	#5,d6
	bsr	cdown
	moveq	#11,d6
	bsr	cleft

	lea	black(pc),a6
	bsr	print
	lea	crack(pc),a5
	move.l	#cracend-crack-1,d5
	bsr	loop

	moveq	#2,d6
	bsr	cdown
	moveq	#8,d6
	bsr	cleft

	lea	purple(pc),a6
	bsr	print
	lea	dr(pc),a5
	move.l	#drend-dr-1,d5
	bsr	loop

	moveq	#2,d6
	bsr	cdown

	bsr	wait


endseq	moveq	#8,d6
	bsr	cup
	moveq	#2,d6
	bsr	cleft
	moveq	#2,d6
	bsr	cup
	moveq	#9,d6
	bsr	cleft
	moveq	#8,d6
	bsr	cup
	moveq	#9,d6
	bsr	cleft
	bsr	wait

t	moveq	#6,d6
	bsr	cright
	lea	red(pc),a6
	bsr	print	
	lea	cas(pc),a5
	move.l	#casend-cas-1,d5
	bsr	loop
	bsr	wait
	
	moveq	#19,d6
	bsr	cdown
	moveq	#21,d6
	bsr	cleft

	lea	grey(pc),a6
	bsr	print	
	lea	press(pc),a5
	move.l	#pressen-press-1,d5
	bsr	loop
	
	bsr	waitkey

	moveq	#1,d6
	bsr	cdown
	moveq	#21,d6
	bsr	cleft
	lea	black(pc),a6
	bsr	print
	lea	load(pc),a5
	move.l	#loadend-load-1,d5
	bsr	loop
	
d	moveq	#11,d6
	bsr	cup
	moveq	#24,d6
	bsr	cleft
	moveq	#10,d6
	lea	clst(pc),a6
	bsr	print
delete	moveq	#2,d7
	bsr	vsync
	lea	del(pc),a6
	bsr	print
	dbf	d6,delete
	lea	dis(pc),a6
	bsr	print
	
	bsr	fade

	rts

wait	moveq	#3,d6
wait2	moveq	#20,d7
	bsr	vsync
	dbf	d6,wait2
	rts

fade	moveq	#6,d6
fade2	moveq	#5,d7
	bsr	vsync
	sub.w	#$111,$ffff8240
	add.w	#$111,$ffff825e
	dbf	d6,fade2
	rts

	
waitkey	move.b	$fffffc02,d0
	cmp.b	#57,d0
	bne	waitkey
	rts
	

cup	moveq	#2,d7
	lea	up(pc),a6
	bsr	print
	bsr	vsync
	dbf	d6,cup
	rts

cdown	moveq	#2,d7
	lea	down(pc),a6
	bsr	print
	bsr	vsync
	dbf	d6,cdown
	rts
	
cleft	moveq	#2,d7
	lea	left(pc),a6
	bsr	print
	bsr	vsync
	dbf	d6,cleft
	rts

cright	moveq	#2,d7
	lea	right(pc),a6
	bsr	print
	bsr	vsync
	dbf	d6,cright
	rts
	

loop	move.b	(a5)+,d6
	bsr	conout
	moveq	#2,d7
	bsr	vsync
	dbf	d5,loop
	rts
	

conout	move.w	d6,-(a7)
	move.w	#2,-(a7)
	trap	#1
	addq.l	#4,a7
	rts

print	move.l	a6,-(a7)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	rts

vsync	move.w	#37,-(a7)
	trap	#14
	addq.l	#2,a7
	dbf	d7,vsync
	rts

play	bchg	#0,$484
	moveq	#1,d0
	bsr	music
	move.l	#music+8,$4d2
	rts

super	move.w	sr,d7
	btst	#13,d7
	bne	ret
	pea	0
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,oldsp
ret	rts

stop	bchg	#0,$484
	moveq	#0,d0
	bsr	music
	clr.l	$4d2
	rts

********** MAIN PROGRAM LOADER *******



LOAD  MOVE.L    L0006(PC),D0
      BEQ     	L0001 
      ADDQ.L    #8,D0 
      MOVE.L    $42E,D6 
      SUB.L     D0,D6 
      BLE     	L0001 
      MOVEA.L   D0,A5 
      CLR.W     -(A7) 
      PEA       L0003(PC) 
      MOVE.W    #$3D,-(A7)
      TRAP      #1
      ADDQ.W    #8,A7 
      MOVE.W    D0,D7 
      BMI       L0001 
      MOVE.L    A5,-(A7)
      MOVE.L    D6,-(A7)
      MOVE.W    D7,-(A7)
      MOVE.W    #$3F,-(A7)
      TRAP      #1
      LEA       12(A7),A7 
      TST.L     D0
      BMI       L0001 
      LEA       0(A5,D0.L),A6 
      MOVE.W    D7,-(A7)
      MOVE.W    #$3E,-(A7)
      TRAP      #1
      ADDQ.W    #4,A7 
      MOVE.L    A6,-(A5)
      MOVE.L    A5,-(A5)

L0001:
;      MOVE.B    #$12,$FFFFFC02
      CLR.B     $453
      ST        $43E
      MOVEQ     #0,D0 
      MOVE.W    L0004(PC),D1
      MOVE.W    L0005(PC),D2
      MOVEA.L   A7,A0 
      BSR       L0007 
      MOVE      #$2700,SR 
      JMP       (A7)
L0002:DC.B      $1B,'H',$1B,'l',$1B,'Y -' 
      DC.B      'AndyLoad v3.7R',$00,$00

L0003:DC.B      "RESOL101.DYN",$00,$00

L0004:DC.B      $00,$0A 
L0005:DC.B      $00,$0A 
L0006:DC.B      $00,$08,$00,$00 

L0007:MOVEM.L   A0-A6/D1-D7,-(A7) 
      LEA       -$79FA,A5 
      LINK      A6,#-$70
      BTST      #2,D0 
      BEQ     	L0008 
      ADDI.W    #$320,D1
L0008:MOVE.W    D1,-112(A6) 
      MOVE.W    D2,-110(A6) 
      BEQ       L000B 
      MOVE.L    A0,-108(A6) 
      MOVE.L    #$140,-98(A6) 
      BSR       L0013 
      MOVE.L    #$200,D0
      MOVE.L    D0,D1 
      MOVEA.L   -108(A6),A0 
      BSR       L0016 
      MOVEA.L   -108(A6),A0 
      LEA       12(A0),A0 
      MOVE.W    (A0)+,-94(A6) 
      MOVE.W    (A0)+,-92(A6) 
      MOVEQ     #$F,D0
      LEA       -90(A6),A1
L0009:MOVE.L    (A0)+,(A1)+ 
      DBF       D0,L0009
      LEA       432(A0),A1
      MOVE.W    -92(A6),D1
      EXT.L     D1
      MOVEQ     #0,D2 
      MOVE.W    -112(A6),D3 
      MOVE.L    #$400,D4
      BSR       L0030 
      MOVE.L    D1,D0 
      MOVE.W    D2,-26(A6)
      MOVEQ     #0,D1 
      MOVE.W    -110(A6),D3 
      BSR       L0030 
      ADDQ.L    #2,D1 
      MOVE.L    D1,-20(A6)
      MOVEA.L   -108(A6),A0 
      BSR       L0016 
      MOVEQ     #0,D0 
      MOVE.L    #$200,D1
      MOVEA.L   -98(A6),A0
      BSR       L0016 
      MOVE.W    -110(A6),D0 
      MULU      #$200,D0
      ADD.L     -108(A6),D0 
      MOVE.L    D0,-24(A6)
      MOVEA.L   D0,A0 
      MOVEM.L   (A0)+,D0-D3 
      MOVEM.L   D0-D3,-16(A6) 
      MOVEA.L   -108(A6),A1 
      MOVEA.L   A0,A2 
      MOVEA.L   A1,A3 
      ADDA.L    -20(A6),A3
L000A:MOVE.B    -(A3),-(A0) 
      CMPA.L    A1,A3 
      BNE     	L000A 
      BSR       L0033 
      MOVEM.L   -16(A6),D0-D3 
      MOVEM.L   D0-D3,(A1)
L000B:UNLK      A6
      MOVEM.L   (A7)+,A0-A6/D1-D7 
      MOVEQ     #0,D0 
      RTS 
L000C:DC.B      'RESOL101'
      DC.B      'DYN',$00 
L000D:BSR       L0012 
      MOVEQ     #0,D0 
      MOVE.L    #$200,D1
      MOVEA.L   -108(A6),A0 
      BSR       L001C 
      MOVEA.L   -108(A6),A0 
      MOVEQ     #0,D6 
      MOVE.B    24(A0),D6 
      MOVE.W    D6,-100(A6) 
      MOVEQ     #0,D7 
      MOVE.B    16(A0),D6 
      MOVE.B    22(A0),D7 
      MULU      D7,D6 
      ADDQ.W    #1,D6 
      MOVE.B    17(A0),D7 
      LSR.W     #4,D7 
      MOVE.W    D6,D5 
      ADD.W     D7,D5 
L000E:MOVE.W    D6,D0 
      MOVE.L    #$200,D1
      MOVEA.L   -108(A6),A0 
      BSR       L001C 
      MOVEQ     #$F,D0
      MOVEA.L   -108(A6),A0 
      LEA       L000C(PC),A1
L000F:MOVEQ     #$A,D1
L0010:MOVE.B    0(A0,D1.W),D2 
      CMP.B     0(A1,D1.W),D2 
      BNE     	L0011 
      DBF       D1,L0010
      LEA       28(A0),A0 
      MOVE.B    -(A0),D0
      LSL.W     #8,D0 
      MOVE.B    -(A0),D0
      SUBQ.W    #2,D0 
      ADD.W     D0,D0 
      ADD.W     D5,D0 
      RTS 
L0011:LEA       32(A0),A0 
      DBF       D0,L000F
      ADDQ.W    #1,D6 
      SUBQ.W    #1,D7 
      BPL     	L000E 
      RTS 
L0012:MOVE.L    #$E0E0505,-$7800
      MOVE.W    #$80,(A5) 
      MOVEQ     #$F,D6
      BSR       L0029 
      BSR       L002D 
      RTS 
L0013:LEA       $100000,A1
      CMPA.L    (A1)+,A1
      BEQ     	L0014 
      LEA       $80000,A1 
      CMPA.L    (A1)+,A1
      BNE     	L0015 
L0014:MOVE.L    A1,-104(A6) 
      RTS 
L0015:BSR       L000D 
      MOVE.W    #-1,-104(A6)
      MOVE.W    D0,-102(A6) 
      RTS 
L0016:MOVE.L    -104(A6),D2 
      BMI     	L0018 
      MOVEA.L   D2,A1 
      MOVEA.L   (A1)+,A2
      ADDA.L    D0,A1 
L0017:CMPA.W    A1,A2 
      BEQ     	L0018 
      MOVE.W    (A1)+,(A0)+ 
      ADDQ.L    #2,D0 
      SUBQ.L    #2,D1 
      BNE     	L0017 
      MOVEQ     #0,D0 
      RTS 
L0018:MOVEM.L   A0/D1,-(A7) 
      MOVE.L    #$200,D1
      DIVU      D1,D0 
      MOVE.L    D0,D3 
      CLR.W     D3
      SWAP      D3
      ADD.W     -102(A6),D0 
      MOVEA.L   -98(A6),A0
      BSR     	L001C 
      BMI       L0024 
      SUB.L     D3,D2 
      MOVEM.L   (A7)+,A0/D1 
      MOVEA.L   -98(A6),A1
      ADDA.W    D3,A1 
L0019:MOVE.B    (A1)+,(A0)+ 
      SUBQ.L    #1,D1 
      BEQ     	L001B 
      SUBQ.W    #1,D2 
      BNE     	L0019 
L001A:TST.L     D1
      BLE     	L001B 
      ADDQ.W    #1,D0 
      BSR     	L001C 
      BRA     	L001A 
L001B:MOVEQ     #0,D0 
      RTS 
L001C:MOVEM.L   D3-D7,-(A7) 
      MOVEQ     #0,D3 
      MOVE.W    D0,D3 
      BEQ     	L001D 
      DIVU      -100(A6),D3 
      LSR.W     #1,D3 
      BCS     	L001E 
L001D:MOVE.L    #$E0E0505,-$7800
      BRA     	L001F 
L001E:MOVE.L    #$E0E0404,-$7800
L001F:MOVE.W    #$82,(A5) 
      BSR       L002A 
      CMP.B     D3,D6 
      BEQ     	L0020 
      MOVE.W    #$86,(A5) 
      MOVE.W    D3,D6 
      BSR       L0029 
      MOVE.W    #$80,(A5) 
      MOVEQ     #$1F,D6 
      BSR       L0029 
      BSR       L002D 
      BMI     	L0024 
L0020:SWAP      D3
      ADDQ.W    #1,D3 
      MOVE.W    #$84,(A5) 
      MOVE.W    D3,D6 
      BSR       L0029 
L0021:CMP.L     #$200,D1
      BLT     	L0022 
      MOVE.L    A0,D2 
      MOVE.B    D2,-$79F3 
      LSR.L     #8,D2 
      MOVE.B    D2,-$79F5 
      LSR.W     #8,D2 
      MOVE.B    D2,-$79F7 
      MOVE.L    #$200,D2
      BRA     	L0023 
L0022:MOVE.B    -95(A6),-$79F3
      MOVE.B    -96(A6),-$79F5
      MOVE.B    -97(A6),-$79F7
      MOVEQ     #0,D2 
L0023:MOVE.W    #$90,(A5) 
      MOVE.W    #$190,(A5)
      MOVE.W    #$90,(A5) 
      MOVEQ     #1,D6 
      BSR     	L0029 
      MOVE.W    #$80,(A5) 
      MOVE.W    #$80,D6 
      BSR     	L0029 
      BSR     	L002D 
      BPL     	L0025 
      DBF       D5,L0021
L0024:MOVEM.L   (A7)+,D3-D7 
      MOVEQ     #-1,D7
      RTS 
L0025:TST.W     D2
      BEQ     	L0026 
      SUB.L     D2,D1 
      ADDA.W    D2,A0 
      BRA     	L0028 
L0026:MOVEA.L   -98(A6),A1
      MOVE.W    #$1FF,D7
L0027:MOVE.B    (A1)+,(A0)+ 
      ADDQ.W    #1,D2 
      SUBQ.L    #1,D1 
      BEQ     	L0028 
      DBF       D7,L0027
L0028:MOVEM.L   (A7)+,D3-D7 
      MOVEQ     #0,D7 
      RTS 
L0029:BSR     	L002B 
      MOVE.W    D6,-2(A5) 
      BRA     	L002B 
L002A:BSR     	L002B 
      MOVE.W    -2(A5),D6 
L002B:MOVEQ     #$20,D7 
L002C:DBF       D7,L002C
      RTS 
L002D:MOVEQ     #6,D7 
      SWAP      D7
L002E:BTST      #5,-$5FF
      BEQ     	L002F 
      SUBQ.L    #1,D7 
      BPL     	L002E 
      RTS 
L002F:MOVE      #0,CCR
      RTS 
L0030:TST.W     D3
      BEQ     	L0032 
      CMPA.L    A0,A1 
      BNE     	L0031 
      MOVEA.L   -108(A6),A0 
      MOVEM.L   A0/D0-D4,-(A7)
      MOVE.L    D4,D0 
      MOVE.L    #$200,D1
      BSR       L0016 
      MOVEM.L   (A7)+,A0/D0-D4
      ADDI.L    #$200,D4
      LEA       512(A0),A1
L0031:MOVE.W    (A0)+,D5
      MOVE.W    D5,D2 
      ANDI.W    #-$1000,D2
      EOR.W     D2,D5 
      EXT.L     D5
      ADD.L     D5,D1 
      ROL.W     #4,D2 
      SUBQ.W    #1,D3 
      BRA     	L0030 
L0032:RTS 
L0033:MOVE.W    $FFFF8240,-(A7)
      MOVE.W    -110(A6),D0 
      MULU      #$200,D0
      LEA       0(A1,D0.L),A2 
      MOVEA.L   -98(A6),A3
      MOVE.W    -94(A6),D6
      MOVEQ     #0,D7 
      MOVE.L    (A0)+,D0
      MOVEQ     #$20,D1 
      MOVE.W    -26(A6),D2
      LSL.L     D2,D0 
      SUB.W     D2,D1 
      MOVEQ     #0,D2 
L0034:MOVEQ     #0,D3 
L0035:MOVE.B    0(A3,D3.W),D7 
      SUBQ.W    #1,D1 
      BPL     	L0036 
      MOVE.L    (A0)+,D0
      MOVEQ     #$1F,D1 
L0036:ADD.L     D0,D0 
      BCC     	L0037 
      ADDQ.W    #1,D7 
L0037:ADD.W     D7,D3 
      MOVE.W    D3,D4 
      LSR.W     #3,D4 
      BTST      D3,-90(A6,D4.W) 
      BEQ     	L0035 
      MOVE.W    D0,$FFFF8240 
      MOVE.B    0(A3,D3.W),D3 
      CMP.W     #1,D2 
      BGE     	L0039 
      CMP.B   	D3,D6 
      BEQ     	L0038 
      MOVE.B    D3,(A1)+
      BRA     	L003E 
L0038:MOVEQ     #1,D2 
      BRA     	L0034 
L0039:BGT     	L003B 
      CMP.B     #1,D3 
      BEQ     	L003C 
      BHI     	L003A 
      MOVE.B    D6,(A1)+
      BRA     	L003E 
L003A:MOVE.B    D3,D2 
      BRA     	L0034 
L003B:MOVE.B    D3,(A1)+
      DBF       D2,L003B
      BRA     	L003E 
L003C:MOVEQ     #$20,D2 
      SUB.W     D1,D2 
      MOVEQ     #$7F,D3 
L003D:MOVE.L    D0,D5 
      MOVE.L    (A0)+,D0
      MOVE.L    D0,D4 
      LSR.L     D1,D4 
      OR.L      D4,D5 
      MOVE.L    D5,(A1)+
      LSL.L     D2,D0 
      DBF       D3,L003D
L003E:MOVEQ     #0,D2 
      CMPA.L    A1,A2 
      BNE     	L0034 
      MOVE.W    (A7)+,$FFFF8240
      RTS 
      DC.B      $00,$00 


	RTS
	
	data

	even	
cls	dc.b	27,"E",0
enable	dc.b	27,"e",0
dis	dc.b	27,"f",0
up	dc.b	27,"A",0
down	dc.b	27,"B",0
right	dc.b	27,"C",0
left	dc.b	27,"D",0
del	dc.b	27,"M",0
clst	dc.b	27,"d",0

red	dc.b	27,"b",1,0	
blue	dc.b	27,"b",4,0
black	dc.b	27,"b",15,0
purple	dc.b	27,"b",5,0
grey	dc.b	27,"b",8,0


count	dc.b	"9876543210 "
counten	even	

tcd	dc.b	"TCD",10,10
tcdend	even

pres	dc.b	"PRESENT"
presend	even

apb	dc.b	"RESOLUTION 101"
apbend	even

crack	dc.b	"CRACKED BY"
cracend	even

dr	dc.b	"DR DYNAC"
drend	even


cas	dc.b	"THE CASUALTY DEPARTMENT"
casend	even

press	dc.b	"PRESS SPACE TO CONTINUE"
pressen	even

load	dc.b	"LOADING...PLEASE WAIT"
loadend	even

message	dc.b	"THIS INTRO WAS WRITTEN BY DR DYNAC ESPECIALLY FOR THIS GAME"
	ds.b	100
	dc.b	"IF YOU WANT THIS INTRO CODE THEN GET IN TOUCH WITH CARDIAC ARREST"

	even
oldsp	ds.l	1
music	incbin "alec5.mus"
musend	even


