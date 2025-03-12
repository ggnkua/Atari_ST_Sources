ENTETE=1		;1=ENLEVE ENTETE .PRG
offset:	equ	$400		; offset

	BRA.S	O
FILE:	DC.B	'C:\IVAN.PRG',0
	EVEN
O:
	CLR	-(SP)
	PEA	FILE(PC)
	MOVE	#$3D,-(SP)
	TRAP	#1
	ADDQ	#8,SP
	MOVE.L	D0,D7
	BMI	ERREUR

	IF	ENTETE=1
	PEA	START-$1C
	ELSE
	PEA	START
	ENDIF
	PEA	200000
	MOVE	D7,-(SP)
	MOVE	#$3F,-(SP)
	TRAP	#1
	LEA	12(SP),SP
	MOVE.L	D0,D6
	BMI	ERREUR
	IF	ENTETE=1
	SUB.L	#$1C,D6
	ENDIF

	MOVE	D7,-(SP)
	MOVE	#$3E,-(SP)
	TRAP	#1
	ADDQ	#4,SP

	lea start,a0	
	move.l a0,a1
	add.l d6,a1
	move.l a1,a2

	move.l	a1,stop

	BSR	s
ERREUR:
;
; A1=PTR DEBUT FICHIER A SAUVER
; A2=PTR FIN FICHIER A SAUVER
;
	illegal


s:
	moveq #1,d2	
	clr.w d1	
	clr.l d7	
	
noteocrunch:
	jsr crunch	
			
	tst.b d0
	beq.S crunched
	addq.w #1,d1
	cmpi.w #265,d1
	bne.S nojmp
	jsr dojmp
	
nojmp:
crunched:
	cmp.l a0,a1
	bgt.S noteocrunch
	
	jsr dojmp	
	
	jsr write1lwd	
	move.l d7,(a2)+	
	
	lea start,a0
	move.l stop,a1
	move.l a1,d2	
			
	sub.l a0,d2
	move.l d2,(a2)+	
	
	clr.l d0
	clr.l d1
	clr.l d2
	clr.l d3
	clr.l d4
	clr.l d5
	lea cnt,a3
	movem.w (a3)+,d0-d5
	move.l a2,a3
	sub.l a0,a3
	move.l stop,a4
	sub.l a2,a4
	rts
	
crunch:
	move.l a0,a3
	add.l #offset,a3
	cmp.l a1,a3	
	ble.S nottop
	move.l a1,a3	
	
nottop:
	moveq #$1,d5	
	move.l a0,a5	
	addq #$1,a5
	
contcrunch:
	
	move.b (a0),d3	
	move.b $1(a0),d4
	
quickfind:
	cmp.b (a5)+,d3	
	bne.S contfind	
	cmp.b (a5),d4
	beq.S lenfind
	
contfind:
	cmp.l a5,a3
	bgt.S quickfind
	jmp endquickfind
	
lenfind:
	subq #1,a5	
	move.l a0,a4	
	
scan:
	move.b (a4)+,d3	
			
	cmp.b (a5)+,d3
	bne.S endequ
	cmp.l a5,a3
	bgt.S scan
	
endequ:
	move.l a4,d3	
	sub.l a0,d3	
	subq.l #1,d3
	cmp.l d3,d5	
	bge.S nocrunch	
	
	move.l a5,d4	
	sub.l a0,d4	
	sub.l d3,d4
	subq #1,d4	
	
	cmp.l #$4,d3
	ble.S small
	
	moveq  #$6,d6	
	cmp.l #$00000101,d3	
	blt.S oksafe
	move.w #$100,d3		
oksafe:
	bra.S cont1
	
small:
	move.w d3,d6	
	subq.w #$2,d6	
	lsl.w #1,d6
	
cont1:
	lea table,a6	
	cmp.w (a6,d6.w),d4	
	bge.S nocrunch		
	move.l d3,d5		
	move.l d4,maxsoffset
	move.b d6,tbloffset
	
nocrunch:
	cmp.l a5,a3	
	bgt.S contcrunch	
	
endquickfind:	
	
	cmp.l #$1,d5		
	beq.S nothingfound
	
	jsr dojmp	
	
	move.b tbloffset,d6
	move.l maxsoffset,d3
	move.w 8(a6,d6.w),d0	
	jsr wd0bits		
	
	move.w 16(a6,d6.w),d0	
	beq.S nolength		
	move.l d5,d3		
	subq #1,d3
	jsr wd0bits
	
nolength:
	move.w 24(a6,d6.w),d0	
	move.w 32(a6,d6.w),d3	
	jsr wd0bits		
	
	addi.w #$1,40(a6,d6.w)
	
	add.l d5,a0	
	clr.b d0	
	rts
	
nothingfound:
	move.b (a0)+,d3
	moveq #$8,d0
	jsr wd0bits
	moveq #$1,d0
	rts
	
maxsoffset: dc.l 0
tbloffset:  dc.w 0
	
table:
offst:	dc.w $0100,$0200,$0400,$1000
lnoff:	dc.w $0008,$0009,$000a,$000c
length:	dc.w $0000,$0000,$0000,$0008
cdlen:	dc.w $0002,$0003,$0003,$0003
code:	dc.w $0001,$0004,$0005,$0006
cnt:    dc.w $0,$0,$0,$0
cntjmp: dc.w $0,$0
	
	
dojmp:
	tst.w d1
	beq.S skipjmp
	move.w d1,d3
	clr.w d1
	cmp.w #9,d3
	bge.S bigjmp
	addq.w #1,cntjmp
	subq.w #1,d3
	;or.b #%00000000,d3	
	moveq #5,d0		
	jmp wd0bits
	
skipjmp: rts
	
bigjmp:
	addq.w #1,cntjmp+2
	subi.w #9,d3
	or.w #%0000011100000000,d3	
	moveq #11,d0			
	jmp wd0bits
	
wd0bits:	
	subq.w #1,d0
	copybits:
	lsr.l #1,d3	
	roxl.l #1,d2	
	bcs.S writelwd	
	dbf d0,copybits
	rts
	write1lwd: clr.w d0	
	
	writelwd: move.l d2,(a2)+	
	eor.l d2,d7			
	moveq #1,d2			
	dbf d0,copybits			
	rts
stop:	dc.l	0
	
	IF	ENTETE=1
	BLK.B	$1C
	ENDIF
START:
