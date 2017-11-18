
	clr.l -(sp)				
	move.w #$20,-(sp)			
	trap #1					
	addq.l #6,sp				
	move.l d0,oldsp			

	bclr #0,$484.w	

	move.l	#$12,d0
	bsr	ikbd

	move.w	#0,-(sp)
	move.l	#$70000,-(sp)
	move.l	#$70000,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	

	move.b	#0,$ffff8260
	move.l	#nops,a1
	move.l	#oldy,a2
	move.l	#NEW,a3
	move.l	#199,d0
loopin	move.l	a1,(a2)+
	move.l	a1,(a3)+
	dbf	d0,loopin

	move.l	#noptab,old
	move.l	#coltab,colpt
	move.l	#wve,a3
	move.l	#$77620,oldline
	lea	$70000,a3
	bsr	cls
	movem.l	logpal,d0-d7
	movem.l	d0-d7,$ffff8240
	bsr	logo
	moveq #1,d0		
	bsr music		

	bsr	hblon

start	move.l	#text,svtxt
scroll	move.l	svtxt,a0
	MOVEQ.L	#0,D4
	MOVE.B	(A0),D4			;next letter
 	TST.B	(A0)+			;end of text
	BNE.S	chr_val
	BRA.S	start

chr_val	move.l	a0,svtxt
	SUBI.B	#32,D4			;where's that character?
	DIVU.W	#20,D4
	MOVEQ.L	#0,D5
	MOVE.W	D4,D5
	ASL	#7,D5
	MULU.W	#10,D5
	CLR.W	D4
	SWAP	D4
	ASL	#3,D4
	LEA	font,A5
	ADD.W	D5,A5
	ADD.W	D4,A5

	MOVEQ.W	#7,D7
	LEA	stc_pad,A6		;copy letter to scratch pad
cpy_chr	MOVE.W	(A5),(A6)
	ADDQ.L	#4,A6
	LEA	160(A5),A5
	DBF	D7,cpy_chr

	MOVEQ.W	#7,D6			;pixels across
pixels  lea	txtspc,a1
	LEA	stc_pad,A6

	MOVEQ.W	#7,D7			;lines to ROXL
lines	MOVE.L	(A6),D0
	LSL.L	D0
	MOVE.L	D0,(A6)+

	ROXL	160(A1)			;lotsa ROXL's
	ROXL	152(A1)			;lotsa ROXL's
	ROXL	144(A1)
	ROXL	136(A1)
	ROXL	128(A1)
	ROXL	120(A1)
	ROXL	112(A1)
	ROXL	104(A1)
	ROXL	96(A1)
	ROXL	88(A1)
	ROXL	80(A1)
	ROXL	72(A1)
	ROXL	64(A1)
	ROXL	56(A1)
	ROXL	48(A1)
	ROXL	40(A1)
	ROXL	32(A1)
	ROXL	24(A1)
	ROXL	16(A1)
	ROXL	8(A1)

	LEA	160(A1),A1		;add 160 (1 line) to screen addr
	DBF	D7,lines
	bsr	screencp
	
	cmp.b	#$39,$fffffc02
	beq	aut

vblc	CMP.L	#1,$462			;wait for vbl
	bne.S	vblc
	clr.l	$462

	DBF	D6,pixels		;rest of the pixels

	bra	scroll

aut	bsr	hbloff

	move.w	#$777,$ffff8240

	move.l #$08080000,$ff8800	
	move.l #$09090000,$ff8800	
	move.l #$0a0a0000,$ff8800	

	bsr	cls
	
	move.l	#$8,d0
	bsr	ikbd

	move.l oldsp,-(sp)
	move.w #$20,-(sp)	
	trap #1			
	addq.l #6,sp  		

	clr.w -(sp)		
	trap #1			
clline	move.l	#7,d5
queer	clr.w	160(A1)			;lotsa clr.w's
	clr.w	152(A1)			;lotsa clr.w's
	clr.w	144(A1)
	clr.w	136(A1)
	clr.w	128(A1)
	clr.w	120(A1)
	clr.w	112(A1)
	clr.w	104(A1)
	clr.w	96(A1)
	clr.w	88(A1)
	clr.w	80(A1)
	clr.w	72(A1)
	clr.w	64(A1)
	clr.w	56(A1)
	clr.w	48(A1)
	clr.w	40(A1)
	clr.w	32(A1)
	clr.w	24(A1)
	clr.w	16(A1)
	clr.w	8(A1)
	adda.l	#160,a1	
	dbf	d5,queer
	rts
screencp
	move.l	oldline,a1
	bsr	clline
	move.l	oldline,a1
	cmpa.l	#$70460,a1
	beq	down
	cmpa.l	#$78ca0,a1
	beq	up
	cmp.l	#1,bncdir
	beq	up
	bra	down
cock	move.l	a1,oldline
	move.l	#txtspc,a5
	move.l	#7,d3
copy	move.w	160(a5),160(a1)	;lotsa move.w's
	move.w	152(a5),152(a1)	;lotsa move.w's
	move.w	144(a5),144(a1)
	move.w	136(a5),136(a1)
	move.w	128(a5),128(a1)
	move.w	120(a5),120(a1)
	move.w	112(a5),112(a1)
	move.w	104(a5),104(a1)
	move.w	96(a5),96(a1)
	move.w	88(a5),88(a1)
	move.w	80(a5),80(a1)
	move.w	72(a5),72(a1)
	move.w	64(a5),64(a1)
	move.w	56(a5),56(a1)
	move.w	48(a5),48(a1)
	move.w	40(a5),40(a1)
	move.w	32(a5),32(a1)
	move.w	24(a5),24(a1)
	move.w	16(a5),16(a1)
	move.w	8(a5),8(a1)
	adda.l	#160,a5
	adda.l	#160,a1
	dbf	d3,copy
	rts
down	move.l	#0,bncdir
	add.l	#320,a1
	bra	cock
up	move.l	#1,bncdir
	sub.l	#320,a1
	bra	cock
			
timer_a	clr.b	$fffffa19.w
	clr.b	$ffff820a.w
	rept	80
	nop
	endr
	move.b	#2,$ffff820a.w
	bclr	#5,$fffffa0f.w
	rte

vbl	move.l	#1,$462
	clr.b	$fffffa19.w	; set timer A
	move.b	#104,$fffffa1f.w
	move.b	#4,$fffffa19.w
	movem.l d0-a6,-(sp)	
	move.l	#timer_b,$120
	clr.b	$fffffa1b
	move.b	#1,$fffffa21
	move.b	#8,$fffffa1b
	bsr (music+8)		
	movem.l (sp)+,d0-a6	
	rte			

timer_b	move.l	#new,a6
	move.l	#oldy,a5
	move.l	old,A4
	cmp.l	#old,A4
	bne	cont
	move.l	#noptab,A4
cont	clr.l	d5
	move.b	(A4)+,d5
	movea.l	#nops,a2
	move.l	a2,d4
	add.l	d5,d4
	move.l	d4,a2
	move.l	A4,old
	move.l	a2,(a6)
	move.b	#1,$fffffa21
	move.l	#timer2,$120
	rte

nops	rept	40
	nop
	endr
	move.l	colpt,a0
	cmp.l	#noptab,a0
	bne.s	shat
	move.l	#coltab,a0
shat	move.l	#1,d7
	bra.s	st
more	rept	10
	nop
	endr
st	move.w	(a0)+,$ffff8240
	move.w	(a0)+,$ffff8240
	move.w	(a0)+,$ffff8240
	move.w	(a0)+,$ffff8240
	move.w	(a0)+,$ffff8240
	move.w	(a0)+,$ffff8240
	move.w	(a0)+,$ffff8240
	move.w	(a0)+,$ffff8240
	move.w	(a0)+,$ffff8240
	move.w	(a0)+,$ffff8240
	move.w	(a0)+,$ffff8240
	move.w	(a0)+,$ffff8240
	move.w	(a0)+,$ffff8240
	move.w	(a0)+,$ffff8240
	move.w	(a0)+,$ffff8240
	dbf	d7,more
	move.l	a0,colpt
	rte
	
timer2	move.l	(a5),a2
	move.l	(a6)+,(a5)+
	move.l	a2,(a6)
	cmp.l	#old2,a3
	bne	go
	move.l	#wve,a3
	suba.l	(a3)+,a2
go	jmp	(a2)
	
cls	move.l	#15000,d1
bogey2	clr.l	(a3)+
	dbra	d1,bogey2
	rts
logo	lea	piccy,a0
	lea	$70462,a1	
	move.l	#2800,d0
bogey	move.l	(a0)+,(a1)+
	dbra	d0,bogey
	rts

hblon:	move    SR,-(A7)
        ori     #$0700,SR
        lea     storage,A0
        move.l  $0118.w,(A0)+
        move.l  $0120.w,(A0)+
        move.l  $70.w,(A0)+
        move.b  $fffffa09.w,(A0)+    ; Werte retten
        move.b  $fffffa07.w,(A0)+
        move.b  $fffffa13.w,(A0)+
        move.b  $fffffa1b.w,(A0)+
        move.b  $fffffa15.w,(A0)+
        move.b  $fffffa21.w,(A0)+
        move.b  $fffffa17.w,(A0)+
        andi.b  #$df,$fffffa09.w 
        andi.b  #$fe,$fffffa07.w 
        move.l  #vbl,$70.w
        move.l  #timer_b,$0120.w
	move.l	#timer_a,$134.w
	bset	#5,$fffffa07.w	; timer A on
	bset	#5,$fffffa13.w
        ori.b   #1,$fffffa07.w   
        ori.b   #1,$fffffa13.w
        bclr    #3,$fffffa17.w   
        bset    #6,$fffffa09.w
        bset    #6,$fffffa15.w
        move    (A7)+,SR
        rts

hbloff: move    SR,-(A7)
        ori     #$0700,SR
        lea     storage,A0          
        move.l  (A0)+,$0118.w
        move.l  (A0)+,$0120.w
        move.l  (A0)+,$70.w
        move.b  (A0)+,$fffffa09.w
        move.b  (A0)+,$fffffa07.w
        move.b  (A0)+,$fffffa13.w
        move.b  (A0)+,$fffffa1b.w
        move.b  (A0)+,$fffffa15.w
        move.b  (A0)+,$fffffa21.w
        move.b  (A0)+,$fffffa17.w
        move    (A7)+,SR
        rts

ikbd	lea	$fffffc00,a0
ikloop	move.b (a0),d1
	btst #1,d1
	beq.s ikloop
	move.b d0,2(a0)
	rts

coltab	dc.w	$101,$202,$303,$404,$505
	dc.w	$606,$707,$717,$727,$737
	dc.w	$747,$757,$767,$777,$676
	dc.w	$575,$474,$373,$272,$171
	dc.w	$070,$060,$050,$040,$030
	dc.w	$020,$010,$000,$000,$000

noptab	dc.b	0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30
	dc.b	32,34,36,38,40,42,44,46,48,50
	dc.b	66,64,62,60,58,56,54,52,50,48,46,44,42,40,38,36,34,32,30,28,26,24,22,20,18,16,14,12,10,8,6,4,2


old	dc.l	0

wve	dc.l	0,2,4,6,8,10,8,6,4,2,0,20

old2	dc.l	0

oldsp	dc.l	0

oldvb	dc.l	0

storage	ds.l	10

oldy	ds.l	200

new	ds.l	200

colpt	dc.l	1
old_sp	DS.L	1
old_rez	DS.W	1
def_pal	DS.W	16
stc_pad	DS.L	32
bncdir	dc.l	0
oldline	dc.l	0
text
	DC.B	"GREETINGS TO ALL YOU PEOPLE READING THIS TEXT"
	DC.B	"                                                           "
	 
	
	DC.B	0		;terminator
	EVEN

logpal	dc.w	$0000,$0116,$0226,$0336,$0446,$0000,$0000,$0000
	dc.w	$0777,$0116,$0226,$0336,$0446,$0000,$0000,$0777
svtxt	dc.l	0
	even
music	incbin 	"a:\disk_2\source\magz_1\medusa_1.mus"
font	INCBIN	"font2.FNT"
	ds.b	160
piccy	incbin	"spi.dat"
txtspc	ds.l	16*320			
