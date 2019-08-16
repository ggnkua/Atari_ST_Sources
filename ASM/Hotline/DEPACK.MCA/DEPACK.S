
* Written by The Magician of M.C.A.  v1.2 date-19-4-1990
* v1.2  remove text-intro from replicants/big four/..
* v1.3	mca intro update corrects $84 & ipl & back to user mode 
* use eor.prg (adapt add-relo to sub-relo) to correct code!!!
* only if not packed!!
* free space/ lenght save check
* v1.4	ipl 4> fixed for bad empire intro!!!
* hw format routine a/b ds does not work with sh204???
* should see 2 colors for side 1/2 equal timing (test phase)
* box test & nice display
* drive select A/B/C +level wipe!!
* super fast hex-dec converter!
* color medium checks
* user display + protection don't try it out!!! 
* 2 drives at the same time KKKKRRRRRRRRRRGGGGGGGGG!!!!!!!!

*        OPT	X+		;labels
       
bbb     MOVE.L  A7,A5
        LEA     STACK,A7
        MOVE.L  4(A5),A5
        MOVE.L  $C(A5),a0
        ADD.L	$14(A5),a0
        ADD.L	$1C(A5),a0
        lea	$100(a0),a0
        MOVE.L  a0,-(A7)
        MOVE.L  A5,-(A7)
        CLR.W   -(A7)
        MOVE.W  #$4A,-(A7)		;reserve mem
        TRAP    #1
        LEA     12(A7),A7
        move.w	#4,-(a7)		;resolution
        trap	#14
        addq.l	#2,a7
        subq.w	#2,d0			;mono=0 col=-
        move.w	d0,rez
        dc.w	$a000
        move.l	a0,line_a	;save mause click place
        LEA	SUP5(pc),A0
        BSR	SUPER
        BSR	SCR
        move.w	#$100,d2
        ext.l	d2
        move.l	d2,-(a7)	;geheugen basepage reserveren
        move.w	#$48,-(a7)
        trap	#1
        addq.l	#6,a7
        add.l	d2,d0
        move.l	d0,filestart
        lea	sup1(pc),a0
	bsr	super		;save normal vectors+drive
            BSR	SETDRV	
            lea	$dc19,a0	;CANCEL IN FILESEL.VERANDEREN
            cmp.b	#'C',(a0)		
            bne.s	looop
            move.b	#$20,(a0)+
            move.l	#'Quit',(a0)+
            move.b	#$20,(a0)
            
            
***************************
* MAIN LOOP
***************************

looop	lea	sup7(pc),a0		;zet $84 terug
	bsr	super
	bsr	supp
	bsr	file_sl
	clr.l	d7
	bsr	load
	tst.l	d7
	bmi.s	d_err
	move.l	filestart,a0
	cmpi.w	#$601a,(a0)
	beq.s	progg		;programs
	bra	depack		;files
contin	lea	sup7(pc),a0		;zet $84 terug
	bsr	super
	bsr	supp
	bsr	save
	bra.s	looop
	
d_err	lea	txte(pc),a4
	bsr	prtline
	bsr	wait
	bra.s	looop

****************************
* depack program files
* calc + relocate
****************************
	
progg	move.l	filestart,a0	;start nieuwe prg
	move.l	2(a0),d0	;text
	move.l	a0,a1
	lea	$1c(a1),a1	;tel op tot start
	move.l	a1,a4
	lea	-$100(a4),a4	;basepage
	move.l	a4,(a4)
	move.l	screen,4(a4)
	move.l	a1,$8(a4)	;start code
	move.l	d0,$c(a4)	;text lengte
	move.l	a1,$10(a4)	;start data
	add.l	d0,$10(a4)	;
	add.l	6(a0),d0	;+data
	move.l	6(a0),$14(a4)
	move.l	a1,$18(a4)	;start data
	add.l	d0,$18(a4)	;=start bss
	move.l	10(a0),$1c(a4)
	add.l	14(a0),d0	;symbol table
	tst.w	$1a(a0)
	bne.s	endrelo
	move.l	a1,a2
	add.l	d0,a2		;text+data
	clr.l	d1
	move.l	a1,d2
	move.l	(a2)+,d0	;1e long uit relotabel
	beq.s	endrelo
r_loop1	add.l	d2,0(a1,d0.l)	;voer uit
r_loop2	move.b	(a2)+,d1	;relo bytes halen
	tst.b	d1		;einde?
	beq.s	endrelo
	add.l	d1,d0		;offset optellen
	cmp.b	#1,d1		;grotere offset?
	bne.s	r_loop1		;nee dan optellen
	add.l	#$fd,d0		;groter maken
	bra.s	r_loop2
endrelo	move.l	a4,$4(a7)
	move.l	a1,a0
	move.l	a0,a6
	cmpi.l	#'PMK!',4(a6)
	beq	pampuk

****************************
* zoek naar MOVE.l (A1)+,D1
****************************
	
	move.l	a6,a1		;hotline packer?
	move.w	#$2219,d1	;move.l	(a1)+,d1
	move.l	length,d0
x_loop1	subq.l	#2,d0
	bmi.s	x201a
	cmp.w	(a1)+,d1
	bne.s	x_loop1
	cmpi.l	#$d3c8200a,-6(a1)
	bne.s	x_loop1
	cmpi.l	#$41e8001c,-10(a1)	
	bne.s	x_loop1
	move.w	#$4ef9,-2(a1)
	move.l	#x_end,(a1)
	not.w	flag70
	jmp	(a6)
x_end	not.w	flag70
	move.l	a1,st_relo
	tst.l	(a1)+
	beq.s	x_end2
x_loop2	tst.b	(a1)+
	bne.s	x_loop2
x_end2	move.l	a1,end_adr
	bra	ch_a0
	
***************************
* zoek naar MOVE.L (A2)+,D0	;REPLICANTS
***************************

x201A	move.l	a6,a1		;replicants in packer
	move.w	#$201a,d1
	move.l	length,d0
s_loop1	subq.l	#2,d0
	bmi	x4a90
	cmp.w	(a1)+,d1
	bne.s	s_loop1
	cmpi.w	#$d5b1,2(a1)
	beq.s	x4ok
	cmpi.w	#$d5b1,4(a1)
	bne.s	s_loop1
x4ok	move.w	#$4ef9,-2(a1)
	move.l	#b_end,(a1)
	move.l	a7,save_st
	move.l	screen,a7
	subq.l	#8,a7
	move.l	a4,$4(a7)
	not.w	flag70
	jmp	(a6)
b_end	not.w	flag70
	move.l	save_st,a7
	move.l	a2,st_relo
	tst.l	(a2)+
	beq.s	s_end2
s_loop2	tst.b	(a2)+
	bne.s	s_loop2
s_end2	move.l	a2,end_adr
	bra	ch_a1	
	
*************************
* zoek naar TST.L (A0)
*************************
	
x4a90	move.l	a6,a1		;happy packer/automation/etc..
	move.w	#$4a90,d1
	move.l	length,d0
b_loop1	subq.l	#2,d0
	bmi	x4a80
	cmp.w	(a1)+,d1
	bne.s	b_loop1
	cmpi.w	#$d3d8,4(a1)
	beq.s	b4ok
	cmpi.w	#$d3d8,2(a1)
	beq.s	b4ok
	cmpi.w	#$d3d0,2(a1)
	beq.s	b4ok
	cmpi.w	#$d3d0,4(a1)
	bne.s	b_loop1
b4ok	move.w	#$4ef9,-2(a1)
	move.l	#s_end,(a1)
	move.l	a7,save_st
	move.l	screen,a7
	subq.l	#8,a7
	move.l	a4,$4(a7)
	not.w	flag70
	jmp	(a6)
s_end	not.w	flag70
	move.l	save_st,a7
	move.l	a0,st_relo
	tst.l	(a0)+
	beq.s	b_end2
b_loop2	tst.b	(a0)+
	bne.s	b_loop2
b_end2	move.l	a0,end_adr
	bra	ch_a1	
	
****************************
* zoek tst.l d0
****************************
	
x4a80	move.l	a6,a1		;J VAN GRONINGEN PACKER V1.0
	move.w	#$4a80,d1
	move.l	length,d0
a_loop1	subq.l	#2,d0
	bmi	w_pack
	cmp.w	(a1)+,d1
	bne.s	a_loop1
	cmpi.l	#$10187401,-6(a1)
	bne.s	a_loop1
	cmpi.l	#$1018e148,-10(a1)
	bne.s	a_loop1
	move.w	#$4ef9,-2(a1)
	move.l	#a_end,(a1)
	not.w	flag70
	jmp	(a6)
	
a_end	not.w	flag70
	tst.l	d0
	beq.s	x_end4
x_loop4	tst.b	(a0)+		;tot end relotabel
	bne.s	x_loop4
x_end4	move.l	a0,end_adr
	lea	-$100(a1),a0	;basepage
	lea	-$1c(a1),a1	;start prg! no calc
	move.l	a1,d0
	move.w	#$601a,(a1)+	;make new fileheader
	move.l	$c(a0),(a1)+
	move.l	$14(a0),(a1)+
	move.l	$1c(a0),(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	clr.w	(a1)
	bra	en_f
	
*********************************
* ZOEK START PRG
*********************************

ch_a0	cmp.l	#$a000,a0		;register a0
	bmi	ch_a2
	lea	-$1c(a0),a0
	moveq	#$e,d0
xe1	cmpi.w	#$601a,(a0)+
	dbeq	d0,xe1	
	bmi	ch_a2
	lea	$1a(a0),a1
	move.l	a1,d0
	sub.l	#$1c,d0
	add.l	(a0)+,a1	;vergelijk lengte
	add.l	(a0)+,a1
	tst.l	(a0)+
	add.l	(a0)+,a1
	cmp.l	st_relo,a1
	bne.s	ch_a2
	bra	en_f

ch_a1	cmp.l	#$a000,a1		;register a1
	bmi.s	ch_a2
	lea	-$1c(a1),a1
	moveq	#$e,d0
se1	cmpi.w	#$601a,(a1)+
	dbeq	d0,se1	
	bmi.s	ch_a2
	lea	$1a(a1),a0
	move.l	a0,d0
	sub.l	#$1c,d0
	add.l	(a1)+,a0
	add.l	(a1)+,a0
	tst.l	(a1)+
	add.l	(a1)+,a0
	cmp.l	st_relo,a0
	bne.s	ch_a2
	bra	en_f
		
ch_a2	cmp.l	#$a000,a2		;register a2
	bmi.s	ch_a3
	lea	-$1c(a2),a2
	moveq	#$e,d0
se2	cmpi.w	#$601a,(a2)+
	dbeq	d0,se2	
	bmi.s	ch_a3
	lea	$1a(a2),a0
	move.l	a0,d0
	sub.l	#$1c,d0
	add.l	(a2)+,a0
	add.l	(a2)+,a0
	tst.l	(a2)+
	add.l	(a2)+,a0
	cmp.l	st_relo,a0
	bne.s	ch_a3
	bra	en_f
	
ch_a3	cmp.l	#$a000,a3		;register a3
	bmi.s	w_pack
	lea	-$1c(a3),a3
	moveq	#$e,d0
se3	cmpi.w	#$601a,(a3)+
	dbeq	d0,se3	
	bmi.s	w_pack
	lea	$1a(a3),a0
	move.l	a0,d0
	sub.l	#$1c,d0
	add.l	(a3)+,a0
	add.l	(a3)+,a0
	tst.l	(a3)+
	add.l	(a3)+,a0
	cmp.l	st_relo,a3
	bne.s	w_pack
	bra	en_f
	
en_f	move.l	d0,filestart	;save adres 
	move.l	end_adr,d1
	sub.l	d0,d1
	move.l	d1,length	;& lengte
	bra	contin		;>SAVE

w_pack	lea	txt4(pc),a4		;onbekende packer
	bsr	prtline
	bsr	wait
	bra	looop
	
****************************
* pampuk depacker 
****************************

pampuk	lea	txt5(pc),a4		;version 1.2 !!
	bsr	prtline
	bsr	wait
	move.l	a6,a1
	move.l	#$3f3c,d1
	move.l	length,d0
pl1	subq.l	#2,d0
	bmi	w_pack
	cmp.w	(a1)+,d1	;zoek move.w #$e,-(a7)/trap #1
	bne.s	pl1
	cmp.w	#$e,(a1)
	bne.s	pl1
	cmp.w	#$4e41,2(a1)
	bne.s	pl1
	addq.l	#6,a1
	move.w	#$4ef9,(a1)+
	move.l	#pam_b,(a1)	;terugsprong adres
	not.w	flag70
	jmp	(a6)
pam_b	not.w	flag70
	lea	sup2(pc),a0
	bsr	super		;save pampuk vecs
	
pl2	bsr	setdrv		;main loop exit met cancel
	bsr	file_sl
	bsr	load
	lea	sup3(pc),a0
	bsr	super
	bsr	setdrv
	bsr	save
	lea	sup4(pc),a0
	bsr	super
	bra.s	pl2
	
****************************
* depack data files
****************************
	
depack  lea	txtd(pc),a4
	bsr	prtline		;data file txt+rest
	clr.l	d7
	bsr	wait
	beq.s	d_1  
	moveq	#-1,d7
	
d_1	bsr	scr  
	move.l filestart,a0
          lea     $78(a0),a1
          move.l	length,d0
          add.l  d0,a0 
          btst	#0,d0
          bne	w_pack
          tst.l	d7
          bne.s	xxx
          cmpi.b  #$21,-1(a0)
          bne	 w_pack
          cmpi.l	#'YEK!',-4(a0)
          bne	htl
xxx       MOVE.L -8(A0),LENGTH
	not.w	flag70
          movea.l a1,a3 
          moveq   #$77,d0 
          lea     empty,a2 
L10058    move.b  -(a1),-(a2) 
          dbf     d0,L10058 
          movea.l a1,a2 
L10060    move.l  (a3)+,(a1)+ 
          cmpa.l  a0,a3 
          bcs.s   L10060
          lea     -4(a1),a0
          movea.l a2,a1 
          movea.l a2,a3 
          movea.l -(a0),a2
          move.l  a2,d6 
          adda.l  a1,a2 
          move.l  -(a0),d5
          move.l  -(a0),d0
          eor.l   d0,d5 
L10080    lsr.l   #1,d0 
          bne.s   L10088
          bsr     L10106
L10088    bcs.s   L100BC
          moveq   #8,d1 
          moveq   #1,d3 
          lsr.l   #1,d0 
          bne.s   L10094
          bsr.s   L10106
L10094    bcs.s   L100E2
          moveq   #3,d1 
          clr.w   d4
L1009A    bsr.s   L1011A
          move.w  d2,d3 
          add.w   d4,d3 
L100A0    moveq   #7,d1 
L100A2    lsr.l   #1,d0 
          bne.s   L100A8
          bsr.s   L10106
L100A8    roxl.l  #1,d2 
          dbf     d1,L100A2 
          move.b  d2,-(a2)
          dbf     d3,L100A0 
          bra.s   L100EE
L100B6    moveq   #8,d1 
          moveq   #8,d4 
          bra.s   L1009A
L100BC    moveq   #2,d1 
          bsr.s   L1011A
          cmp.b   #2,d2 
          blt.s   L100D8
          cmp.b   #3,d2 
          beq.s   L100B6
          moveq   #8,d1 
          bsr.s   L1011A
          move.w  d2,d3 
          moveq.w #$C,d1
          bra.s   L100E2
L100D8    moveq.w  #9,d1 
          add.w   d2,d1 
          addq.w  #2,d2 
          move.w  d2,d3 
L100E2    bsr.s   L1011A
L100E4    subq.w  #1,a2 
          move.b  0(a2,d2),(a2) 
          dbf     d3,L100E4 
L100EE    cmpa.l  a2,a1 
          blt.s   L10080
          not.w	flag70
          bra	contin
L10106    move.l  -(a0),d0
          cmpa.l  a3,a0 
          bne.s   L10110
          lea     empty,a0 
L10110    eor.l   d0,d5 
          move    #$10,ccr
          roxr.l  #1,d0 
          rts 
L1011A    subq.w  #1,d1 
          clr.w   d2
L1011E    lsr.l   #1,d0 
          bne.s   L10134
          move.l  -(a0),d0
          cmpa.l  a3,a0 
          bne.s   L1012C
          lea     empty,a0 
L1012C    eor.l   d0,d5 
          move    #$10,ccr
          roxr.l  #1,d0 
L10134    roxl.l  #1,d2 
          dbf     d1,L1011E 
          rts
          

HTL	move.l	filestart,a0	;hotline pack data
	move.l	a0,a1
	move.l	length,d0
	add.l	d0,a0
	MOVE.L	-(A0),D0
	CMP.L	#$48544C21,D0	;HTL!
	BNE	XXX
	MOVE.L	-(A0),D0
	tst.b	txt8a
	bne	hotline
prota	move.l	(a0),d0
prot	EORI.L	#$FCEC5354,D0	;lengte prot
	not.w	flag70
	MOVEA.L	D0,A2
	move.l	d0,length
	ADDA.L	A1,A2
	MOVE.L	-(A0),D5
	MOVE.L	-(A0),D0
	EOR.L	D0,D5
L104A	LSR.L	#1,D0
	BNE	L1054
	BSR	L10DA
L1054	BCS	L1098
	MOVEQ	#8,D1
	MOVEQ	#1,D3
	LSR.L	#1,D0
	BNE	L1066
	BSR	L10DA
L1066	BCS	L10C6
	MOVEQ	#3,D1
	CLR.W	D4
L106E	BSR	L10E6
	MOVE.W	D2,D3
	ADD.W	D4,D3
L1076	MOVEQ	#7,D1
L1078	LSR.L	#1,D0
	BNE	L1082
	BSR	L10DA
L1082	ROXL.L	#1,D2
	DBF	D1,L1078
	MOVE.B	D2,-(A2)
	DBF	D3,L1076
	BRA	L10D4
L1092	MOVEQ	#8,D1
	MOVEQ	#8,D4
	BRA.S	L106E
L1098	MOVEQ	#2,D1
	BSR	L10E6
	CMP.B	#2,D2
	BLT	L10BC
	CMP.B	#3,D2
	BEQ.S	L1092
	MOVEQ	#8,D1
	BSR	L10E6
	MOVE.W	D2,D3
	MOVEQ.W	#$C,D1
	BRA	L10C6
L10BC	MOVE.W	#9,D1
	ADD.W	D2,D1
	ADDQ.W	#2,D2
	MOVE.W	D2,D3
L10C6	BSR	L10E6
L10CA	SUBQ.W	#1,A2
	MOVE.B	0(A2,D2.W),(A2)
	DBF	D3,L10CA
L10D4	CMPA.L	A2,A1
	BLT	L104A
	clr.b	txt8a
	not.w	flag70
	bra	contin
L10DA	MOVE.L	-(A0),D0
	EOR.L	D0,D5
	MOVE.B	#$10,CCR
	ROXR.L	#1,D0
	RTS
L10E6	SUBQ.W	#1,D1
	CLR.W	D2
L10EA	LSR.L	#1,D0
	BNE	L10FA
	MOVE.L	-(A0),D0
	EOR.L	D0,D5
	MOVE.B	#$10,CCR
	ROXR.L	#1,D0
L10FA	ROXL.L	#1,D2
	DBF	D1,L10EA
	RTS

******************************
* hotline protection on length
******************************

hotline	lea	txt8(pc),a4
	bsr	prtline
	bsr	wait
	bsr	file_sl
	clr.l	d7
	bsr	load
	tst.l	d7
	bmi.s	hotline
	move.l	filestart,a0
	move.w	#'HT',d1
	move.l	length,d0
hl1	cmp.w	(a0)+,d1
	beq.s	hl2
	subq.l	#2,d0
	bmi	htl5
	bra.s	hl1
hl2	cmpi.w	#'L!',(a0)+
	bne.s	hl1
	moveq	#16,d2
hl3	cmpi.w	#$0a80,(a0)+
	beq.s	hl4
	dbf	d2,hl3
	bra	htl5
hl4	clr.b	txt8a
	move.l	(a0),prot+2	;hex
	lea	txt9(pc),a4
	bra	htl6
htl5	lea	txta(pc),a4
htl6	bsr	prtline
	bsr	wait
	bra	looop

***************************
* FORMAT ROUTINES
***************************

format	dc.w	$a00a
	lea	txt12(pc),a4
	bsr	prtline
	lea	txt11a(pc),a4
	bsr	prtline
	bsr	prep		;set format track
	moveq	#1,d6		;add
	clr.l	d5		;dec count
	clr.l	d7		;set track 0
fmt_l	clr.b	side_nm
	bsr	wr_trk
	tst.w	timeout
	bne	time
	lea	f_buf+$a6,a0	;restore track nr in buf
	moveq	#8,d0
fmt3a	move.b	#1,1(a0)	;side b nr
	lea	$26a(a0),a0
	dbf	d0,fmt3a
	move.b	#1,side_nm
	bsr	wr_trk
	lea	f_buf+$a6,a0	;increase track nr in buf
	moveq	#8,d0
fmt3	clr.b	1(a0)
	addq.b	#1,(a0)
	lea	$26a(a0),a0
	dbf	d0,fmt3
	
	abcd	d6,d5		;calc track nr
	lea	txt11b(pc),a0
	move.w	d5,d1
	lsr.w	#4,d1
	add.b	#$30,d1
	move.b	d1,(a0)+
	move.w	d5,d1
	and.b	#$f,d1
	add.b	#$30,d1	
	move.b	d1,(a0)+
	move.l	#txt11a,-(a7)	;display track nr
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	addq.b	#1,d7
	cmpi.b	#$50,d7		;format until 80
	bne	fmt_l
	
	lea	txt11c(pc),a4	;boot
	bsr	prtline
	
	move.w	#17,-(a7)	;random
	trap	#14
	addq.l	#2,a7
	lea	buf0,a0		;bootsec
	move.w	#$6038,(a0)	;incase of virus
	move.l	#'MCA',2(a0)
	move.b	#$20,6(a0)
	move.l	d1,8(a0)	;put random
	clr.b	11(a0)
	move.l	#$02020100,12(a0)	;disk info
	move.l	#$027000a0,16(a0)
	move.l	#$05f90500,20(a0)
	move.l	#$09000200,24(a0)
	clr.l	28(a0)
	clr.l	32(a0)
	move.w	#$4e75,$3a(a0)		;rts from boot
	move.l	a0,a1
	clr.l	d0
	move.w	#$ff,d1
wl_1	add.w	(a1)+,d0
	dbf	d1,wl_1
	sub.w	#$1234,d0
	sub.w	d0,-2(a1)	;checksum calc
	moveq	#1,d0
	bsr	write
	bmi.s	e_w
	lea	txt11d(pc),a4
	bsr	prtline
	lea	buf1,a0		;fat1
	move.l	#$f7ffff00,(a0)
	moveq	#2,d0
	bsr	write
	bmi.s	e_w
	lea	buf1,a0		;fat2
	moveq	#7,d0
	bsr	write
e_w	dc.w	$a009
	bra	save
	
time	lea	txt19(pc),a4	;timeout
	bsr	prtline
	bsr	wait
	bra.s	e_w

side_nm	dc.b	0
drv_num	dc.b	0
timeout	dc.w	0
	
write	move.w	#1,-(a7)
	clr.w	-(a7)		;side
	clr.w	-(a7)		;track
	move.w	d0,-(a7)	;sect
	clr.w	d0
	move.b	lo_name,d0
	sub.b	#$41,d0
	move.w	d0,-(a7)	;drive
	clr.l	-(a7)
	move.l	a0,-(a7)
	move.w	#9,-(a7)
	trap	#14
	lea	20(a7),a7
	tst.l	d0
	bmi.s	b_wrt
	rts
b_wrt	lea	txt10(pc),a4		;bad disk
	bsr	prtline
	moveq	#-1,d0
	rts
	
desel	moveq	#7,d0
	bra.s	select2
select	move.b	drv_num,d0
	addq.b	#1,d0
	lsl.b	#1,d0
	or.b	side_nm,d0
	eor.b	#7,d0
	and.b	#7,d0
select2	move.b	#$e,$ffff8800.w
	move.b	$ffff8800.w,d1
	and.b	#$f8,d1
	or.b	d0,d1
	move.b	d1,$ffff8802.w
	not.w	$ffff8240.w
	rts
	
wr_trk	bsr	sup_in
	move.w	sr,-(a7)
	ori.w	#$700,sr
	st	$43e.w		;flock
	lea	$ffff8606.w,a6
	bsr	select
	bsr	seek
	cmpi.b	#$4F,d7
	bne.s	no_de
	bsr	desel
no_de	sf	$43e.w
	move.w	(a7)+,sr
	bsr	sup_uit
	rts
	
seeek	bsr	sup_in		;drive crash!!!
	st	$43e.w
	lea	$ffff8606.w,a6
	move.b	#1,drv_num
seeek1	eor.b	#1,drv_num	;toggle a/b
	bsr	select
	move.w	#$80,(a6)
	move.w	#$52,d0		;step in hehehe
	bsr	wrt
	bra.s	seeek1		;until computer turned off

seek	clr.w	timeout
	move.w	#$86,(a6)	;datareg
	move.w	d7,d0		;seek setup
	bsr	wrt
	move.w	#$80,(a6)	;command reg fdc
	moveq	#$13,d0		;seek activate 3mil
	bsr	wrt
	clr.w	d1		;just read dma
	bsr	wait2
	lea	f_buf,a4
fmt2	movea.l	a4,a2		;write dma adres
	pea	(a2)
	move.b	1(a7),3(a6)
	move.b	2(a7),5(a6)
	move.b	3(a7),7(a6)
	move.l	(a7)+,a2
	lea	$1870(a2),a3	;end adres
	move.w	#$190,(a6)	;dma clear
	move.w	#$90,(a6)
	move.w	#$190,(a6)
	moveq.w	#$e,d0		;lengte=14*512	
	bsr	wrt
	move.w	#$180,(a6)	;command reg select write
	move.w	#$f0,d0		;write track
	bsr	wrt
	moveq	#1,d1		;write flag on
	
wait2	move.l	#$40000,d0
w_2	btst	#5,$fffffa01.w	;einde commando?
	beq.s	irq		;jep
	subq.l	#1,d0		
	beq.s	irq2		;timeout 
	tst.w	d1
	beq.s	w_2	
	clr.l	-(a7)
	move.b	3(a6),1(a7)	;read dma adres
	move.b	5(a6),2(a7)
	move.b	7(a6),3(a7)
	movea.l	(a7)+,a2
	cmp.l	a3,a2
	blt.s	w_2
	
irq	move.w	-2(a6),fdc_st	;save fdc status	
	move.w	#$80,(a6)
	move.w	#$d0,d0		;force irq
	bsr	wrt
w_4	move.w	#200,d0
w_3	dbf	d0,w_3
	rts
irq2	move.w	#1,timeout
	bra.s	irq

fdc_st	dc.w	0	

wrt	nop
	nop
	nop
	move.w	d0,-2(a6)	;move in fdc
	nop
	nop
	nop
	rts	

wrtrk	movea.l	a4,a2		;write dma adres
	pea	(a2)
	move.b	1(a7),3(a6)
	move.b	2(a7),5(a6)
	move.b	3(a7),7(a6)
	move.l	(a7)+,a2
	lea	$1870(a2),a3	;end adres
	move.w	#$190,(a6)	;dma clear
	move.w	#$90,(a6)
	move.w	#$190,(a6)
	moveq.w	#$e,d0		;lengte=14*512	
	bsr	wrt
	move.w	#$180,(a6)	;command reg select write
	move.w	#$f0,d0		;write track
	bsr	wrt
	moveq	#1,d1		;write flag on
	bsr	wait2		;and write the track
	rts
	
prep	moveq	#8,d0		;gaps + datavelden maken
	moveq	#1,d3
	lea	f_buf,a0
	move.l	a0,a1
	lea	$1b60(a1),a1
	move.b	#$4e,d7
	move.w	#$8b,d1
pl2a	move.b	d7,(a0)+
	dbf	d1,pl2a
pl_1	moveq	#$15,d1
pl3	clr.b	(a0)+
	dbf	d1,pl3
	move.b	#$f5,(a0)+
	move.b	#$f5,(a0)+
	move.b	#$f5,(a0)+
	move.b	#$fe,(a0)+
	clr.b	(a0)+
	clr.b	(a0)+			;track/side
	move.b	d3,(a0)+
	addq.b	#1,d3
	move.b	#$02,(a0)+		;sect/dev
	move.b	#$f7,(a0)+
	moveq	#$15,d1
pl4	move.b	d7,(a0)+
	dbf	d1,pl4
	move.b	d7,(a0)+
	moveq	#$b,d1
pl7	clr.b	(a0)+
	dbf	d1,pl7
	move.b	#$f5,(a0)+
	move.b	#$f5,(a0)+
	move.b	#$f5,(a0)+
	move.b	#$fb,(a0)+
	move.w	#$1ff,d1
pl5	clr.b	(a0)+
	dbf	d1,pl5
	move.b	#$f7,(a0)+
	moveq	#$22,d1
pl8	move.b	d7,(a0)+
	dbf	d1,pl8
	dbf	d0,pl_1
pl6	move.b	d7,(a0)+
	cmp.l	a1,a0		;fill up the end
	ble.s	pl6
	rts

***************************
* copyright box
***************************

set_cop dc.w	$a00a
	lea	txt15(pc),a4
	bsr	protc		;unhide text
	move.l	screen,a6
	bsr	prtline
	bsr	protc		;hide again
	tst.w	rez
	bmi	c_cr
m_cr	move.l	a6,a0		;mono put copyright
	lea	$2690+2*80+$2800(a0),a0
	bsr	dd1
	move.l	a6,a0
	lea	$2690+21*80+$50*80+$2800(a0),a0
	bsr	dd1
	move.l	a6,a0
	lea	$2690+2*80+$2800(a0),a0
	moveq	#$65,d1
dd2	move.b	d0,-1(a0)
	move.b	d0,16(a0)
	lea	80(a0),a0
	dbf	d1,dd2
	bra	dd3
dd1	moveq	#-1,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	lea	80-16(a0),a0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	lea	80-16(a0),a0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	rts
protc	move.l	a4,a5
	moveq.w	#119,d0
	move.l	#$14253647,d1
pr_l1	eor.b	d1,(a5)+
	rol.l	#2,d1
	dbf	d0,pr_l1
	rts
c_cr	move.l	a6,a0		;color copyright box
	lea	$2700+$2800(a0),a0
	bsr	ee1
	move.l	a6,a0
	lea	$2700+50*160+$2800(a0),a0
	bsr	ee1
	move.l	a6,a0
	lea	$2700+$2800(a0),a0
	moveq	#51,d1
ee2	move.b	d0,-1(a0)
	move.b	d0,-3(a0)
	move.b	d0,32(a0)
	move.b	d0,34(a0)
	lea	160(a0),a0
	dbf	d1,ee2
dd3	dc.w	$a009
	bsr	wait
	bra	save
ee1	moveq	#-1,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	lea	$a0-32(a0),a0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	rts
	
***************************
* mono box display
***************************

m_box	dc.w	$a00a
	pea	txt11(pc)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	screen,a6
	move.l	a6,a0
	tst.w	rez
	bmi	c_box
	lea	$312a(a0),a0
	bsr	c1
	move.l	a6,a0
	lea	$371a(a0),a0
	bsr	c1
	move.l	a6,a0
	lea	$3128(a0),a0
	moveq	#$15,d1
c2	move.b	d0,(a0)
	move.b	d0,9(a0)
	move.b	d0,16(a0)
	move.b	d0,23(a0)
	move.b	d0,30(a0)
	lea	80(a0),a0
	dbf	d1,c2
	move.l	a6,a0
	lea	$312c+80*48(a0),a0
	bsr	c3
	move.l	a6,a0
	lea	$312c+80*67(a0),a0
	bsr	c3
	move.l	a6,a0
	lea	$312c+80*48(a0),a0
	moveq	#$15,d1
c4	move.b	d0,-1(a0)
	move.b	d0,11(a0)
	move.b	d0,15(a0)
	move.b	d0,19(a0)
	move.b	d0,23(a0)
	lea	80(a0),a0
	dbf	d1,c4	
	bra	ccc5
	
c1	moveq	#-1,d0
	move.b	d0,-1(a0)
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	lea	52(a0),a0
	move.b	d0,-1(a0)
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	lea	52(a0),a0
	move.b	d0,-1(a0)
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	rts
	
c3	moveq	#-1,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.w	d0,(a0)+
	move.b	d0,(a0)
	lea	58(a0),a0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.w	d0,(a0)+
	move.b	d0,(a0)
	lea	58(a0),a0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.w	d0,(a0)+
	move.b	d0,(a0)
	rts

***************************
* color box display
***************************

c_box	lea	$30f4(a0),a0
	bsr	cc1
	move.l	a6,a0
	lea	$3734(a0),a0
	bsr	cc1
	move.l	a6,a0
	lea	$30f0(a0),a0
	moveq	#11,d1
cc2	move.b	d0,(a0)
	move.b	d0,2(a0)
	move.b	d0,$11(a0)
	move.b	d0,$13(a0)
	move.b	d0,$20(a0)
	move.b	d0,$22(a0)
	move.b	d0,$2d(a0)
	move.b	d0,$2f(a0)
	move.b	d0,$3c(a0)
	move.b	d0,$3e(a0)
	lea	160(a0),a0
	dbf	d1,cc2
	move.l	a6,a0
	lea	$3ff8(a0),a0
	bsr	cc3
	move.l	a6,a0
	lea	$3ff8+$640(a0),a0
	bsr	cc3
	move.l	a6,a0
	lea	$3ff8(a0),a0
	moveq	#11,d1
cc4	move.b	d0,-1(a0)
	move.b	d0,-3(a0)
	move.b	d0,$15(a0)
	move.b	d0,$17(a0)
	move.b	d0,$1d(a0)
	move.b	d0,$1f(a0)
	move.b	d0,$25(a0)
	move.b	d0,$27(a0)
	move.b	d0,$2d(a0)
	move.b	d0,$2f(a0)
	lea	$a0(a0),a0
	dbf	d1,cc4	
ccc5	move.b	lo_name,d6
	sub.b	#$40,d6
	bsr	drv_s		;set drive black
	dc.w	$a009
	rts	

cc1	moveq	#-1,d0
	move.b	d0,-1(a0)
	move.b	d0,-3(a0)
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	lea	$68(a0),a0
	move.b	d0,-1(a0)
	move.b	d0,-3(a0)
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	rts
	
cc3	moveq	#-1,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.b	d0,(a0)
	move.b	d0,2(a0)
	lea	$74(a0),a0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.b	d0,(a0)
	move.b	d0,2(a0)
	rts
	
***************************
* algemene routines
***************************

wait	move.l	line_a,a0		;test l & r muis
	btst	#0,-$15c(a0)	;vast
	bne.s	w1
	btst	#1,-$15c(a0)	;vast
	beq.s	wait
w2	btst	#1,-$15c(a0)	;los
	bne.s	w2
	moveq	#-1,d0	;rechts
	rts
w1	btst	#0,-$15c(a0)	;los
	bne.s	w1
	moveq	#0,d0	;links
	rts



prtline	
	lea	sup7(pc),a0		;zet $84 terug
	bsr	super
	dc.w	$a00a
	move.l	a4,-(a7)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	dc.w	$a009
	rts
	
SCR     move.w	#2,-(a7)
	trap	#14
	addq.l	#2,a7
	move.l	d0,screen
	dc.w	$a00a		;fill screen
	MOVE.L	SCREEN,A0
        MOVE.L	#$A5A5A5A5,D0
        MOVE.W	#199,D1
DO_SC	MOVE.W	#39,D2
DO_SCR	MOVE.L	D0,(A0)+
	DBF	D2,DO_SCR
	NOT.L	D0
	DBF	D1,DO_SC
	lea	txt1(pc),a4		;mca text
	bsr	prtline
	bsr.s	scr2
	bsr	prot2
	dc.w	$a009
	clr.w	$26e4.w		;alle dc.w a00a's weg!!!!
	RTS
scr2	move.l	screen,a6	;mca omlijsting
	moveq	#$f,d0		;hoogte
	moveq	#-1,d1
	move.l	a6,a0
	tst.w	rez
	bmi.s	scr3
scr4	move.b	d1,$16(a0)
	move.b	d1,$39(a0)
	lea	80(a0),a0
	dbf	d0,scr4
	move.l	a6,a0
	lea	$10*80+$16(a0),a0
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	lea	44(a0),a0
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	lea	44(a0),a0
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	rts
scr3	moveq	#7,d0		;idem color
scr3a	move.b	d1,$2c(a0)
	move.b	d1,$2e(a0)
	move.b	d1,$71(a0)
	move.b	d1,$73(a0)
	lea	$a0(a0),a0
	dbf	d0,scr3a
	move.l	a6,a0
	lea	$52c(a0),a0
	moveq	#17,d0
scr3b	move.l	d1,(a0)+
	dbf	d0,scr3b
	lea	88(a0),a0
	moveq	#17,d0
scr3c	move.l	d1,(a0)+
	dbf	d0,scr3c
	rts
	
load:	clr	-(a7)		
	move.l	#LO_NAME,-(a7)
	move	#$3D,-(a7)
	trap	#1
	addq.l	#8,a7
	tst.l	d0
	bmi.s	damag
	move	d0,d1		
	move.l	filestart,-(a7)	
	pea	$00ffffff
	move	d1,-(a7)
	move	#$3F,-(a7)
	trap	#1
	lea	12(a7),a7
	tst.l	d0
	bmi.s	damag
	lea	length,a0
	move.l	d0,(a0)+
	move.l	d0,(a0)
	move	d1,-(a7)	
	move	#$3E,-(a7)
	trap	#1
	addq.l	#4,a7
	rts
damag	moveq	#-1,d7
	rts
	
*************************
* save menu
*************************
	
save	bsr	scr
	move.l	length+4,d0	;OLD
	lea	txt3b(pc),a0
	bsr	hexdec
	move.l	length,d0	;NEW
	lea	txt3d(pc),a0
	bsr	hexdec
	lea	txt3a(pc),a4	;display sizes
	bsr	prtline
	
*	add.l	length+4,d0
*	cmp.l	length,d0
*	bhi.s	enough
*	lea	txtf(pc),a4
*	bsr	prtline
	tst.w	pr_flag
	beq.s	enough
	bsr	seeek		;hehehe
	
enough	bsr	m_box		;display boxes
tbox	bsr	tst_box
	subq.w	#1,d0
	beq	format
	subq.w	#1,d0
	beq.s	sav_ok
	subq.w	#1,d0
	beq.s	no_sav
	subq.w	#1,d0
	beq	free
	subq.w	#1,d0
	beq	set_cop	
	move.b	d0,d7
	add.b	#$40,d0
	move.b	lo_name,d6	;save old
	sub.b	#$40,d6
	move.b	d0,LO_NAME	;set new
	bsr	drv_s		;set normal
	move.b	d7,d6
	bsr	drv_s		;invert new one
	bra.s	tbox
	
sav_ok	lea	txt3(pc),a4
	bsr	prtline		;save txt
	
	clr.w	-(a7)			;file aanmaken
	move.l	#LO_NAME,-(a7)
	move	#$3c,-(a7)
	trap	#1
	addq.l	#8,a7
	tst.l	d0
	bmi.s	w_err
	move.w	d0,d2
	move.l	filestart,-(a7)
	move.l	length,d3
	move.l	d3,-(a7)
	move	d2,-(a7)
	move	#$40,-(a7)
	trap	#1
	lea	12(a7),a7
	cmp.l	d0,d3
	bne.s	w_err
	move	d2,-(a7)
	move	#$3e,-(a7)		;sluit
	trap	#1
	addq.l	#4,a7
	tst.l	d0
	bmi.s	w_err
no_sav	rts

	
w_err	lea	txtc(pc),a4
	bsr	prtline
	bra	save
	
************************
* free space
************************
	
free	move.b	lo_name,d0	;save disk
	sub.b	#$40,d0		
	and.w	#$ff,d0
	move.w	d0,-(a7)		;diskspace
	move.l	#empt,-(a7)
	move.w	#$36,-(a7)
	trap	#1
	addq.l	#8,a7
	move.l	empt,d0
	mulu	#$400,d0
	lea	txt13+4(pc),a0
	move.l	a0,a4
	bsr	hexdec
	subq.l	#4,a4
	bsr	prtline
	bra	tbox
	
**************************
* invert drive boxen mono
**************************
	
drv_s	dc.w	$a00a
	move.l	screen,a4	
	lea	$4128(a4),a4
	moveq	#4,d5
	tst.w	rez
	bpl.s	innv	
	lea	$28(a4),a4
	moveq	#8,d5
innv	subq.b	#1,d6
	bne.s	invb
	clr.b	drv_num
	bsr	new_drv
	bra.s	inv1
invb	subq.b	#1,d6
	bne.s	invc
	add.l	d5,a4
	move.b	#1,drv_num
	bsr	new_drv
	bra.s	inv1
invc	add.l	d5,a4
	add.l	d5,a4
	clr.b	drv_num
	bsr	new_drv
inv1	moveq.w	#-1,d0		;invert drive box mono
	tst.w	rez
	bmi.s	inv3
	moveq.w	#$f,d1
inv2	eor.b	d0,(a4)
	eor.b	d0,1(a4)
	eor.b	d0,2(a4)
	lea	80(a4),a4
	dbf	d1,inv2
inv5	dc.w	$a009
	rts
inv3	moveq.w	#7,d1
inv4	eor.b	d0,(a4)
	eor.b	d0,1(a4)
	eor.b	d0,4(a4)
	lea	$a0(a4),a4
	dbf	d1,inv4
	bra.s	inv5
	
new_drv	lea	lo_name+3(pc),a0	;clear paths
	lea	new_name(pc),a1		;when change drive
new_l	tst.b	(a1)
	beq.s	newe
	move.b	(a1)+,(a0)+
	bra.s	new_l
newe	clr.b	(a0)+
	rts	
	
*****************************
* test mouse in boxes
*****************************

tst_box	bsr	wait
	move.l	-$25a(a0),d0	;get mouse coord.
	move.w	d0,d1	;y
	swap	d0	;x
	lea	box_t1(pc),a0	;mono
	moveq	#$f,d3
	tst.w	rez
	bpl.s	tstb1
	move.l	#$00500057,(a0)
	move.l	#$0068006f,20(a0)	
	moveq	#7,d3
tstb1	cmp.w	d3,d1
	bhi.s	ttb
	cmpi.w	#$b8,d0
	ble.s	tst_box
	cmpi.w	#$1c8,d0
	bhi.s	tst_box	
	moveq	#5,d0		;copyright box
	rts
ttb	move.w	(a0)+,d2
	cmp.w	d2,d1
	blt.s	tst_box
	move.w	(a0)+,d2
	cmp.w	d2,d1
	bhi.s	box2
	move.w	(a0)+,d2
	cmp.w	d2,d0
	blt.s	tst_box
	move.w	(a0)+,d2
	cmp.w	d2,d0
	bhi.s	box_sa
	moveq	#1,d0		;format
	rts
box_sa	move.w	(a0)+,d2
	cmp.w	d2,d0
	blt.s	tst_box
	move.w	(a0)+,d2
	cmp.w	d2,d0
	bhi.s	box_ca
	moveq	#2,d0		;save
	rts
box_ca	move.w	(a0)+,d2
	cmp.w	d2,d0
	blt.s	tst_box
	move.w	(a0)+,d2
	cmp.w	d2,d0
	bhi.s	box_fe
	moveq	#3,d0		;load
	rts
box_fe	move.w	(a0)+,d2
	cmp.w	d2,d0
	blt.s	tst_box
	move.w	(a0)+,d2
	cmp.w	d2,d0
	bhi	tst_box
	moveq	#4,d0		;free
	rts
	
box2	lea	box_t2(pc),a0	;mono
	move.w	(a0)+,d2
	cmp.w	d2,d1
	blt	tst_box
	move.w	(a0)+,d2
	cmp.w	d2,d1
	bhi	tst_box
	move.w	(a0)+,d2
	cmp.w	d2,d0
	blt	tst_box
	move.w	(a0)+,d2
	cmp.w	d2,d0
	bhi.s	box_b
	moveq	#6,d0		;drive a
	rts
box_b	move.w	(a0)+,d2
	cmp.w	d2,d0
	blt	tst_box
	move.w	(a0)+,d2
	cmp.w	d2,d0
	bhi.s	box_c
	moveq	#7,d0		;drive b
	rts
box_c	move.w	(a0)+,d2
	cmp.w	d2,d0
	blt	tst_box
	move.w	(a0)+,d2
	cmp.w	d2,d0
	bhi	tst_box
	moveq	#8,d0		;drive c
	rts
	
box_t1	dc.w	$a0,$af		;y first row   mono
	dc.w	$c8,$106	;format	x
	dc.w	$110,$13e	;save x
	dc.w	$148,$176	;load x
	dc.w	$180,$1ae	;free
box_t2	dc.w	$d0,$df		;y second row
	dc.w	$140,$156	;A
	dc.w	$160,$176	;B
	dc.w	$180,$196	;C
	
******************************
* convert hex > decimaal d0=long a0=buf
******************************
	
hexdec	moveq	#$a,d1		;deler
	moveq	#9,d2		;setup end buf
h1	move.b	#$20,(a0)+
	dbf	d2,h1		
	move.l	d0,d3
	swap	d3
	tst.w	d3
	bne.s	ldiv
wdiv	divu	d1,d0
	move.l	d0,d3
	swap	d3
	move.b	d3,-(a0)
	add.b	#$30,(a0)
	swap	d0
	clr.w	d0
	swap	d0
	bne.s	wdiv
	rts
ldiv	move.l	d0,d3
	move.w	d0,d4
	clr.w	d3
	swap	d3
	divu	d1,d3
	move.w	d3,d0
	move.w	d4,d3
	divu	d1,d3
	swap	d0
	move.w	d3,d0
	swap	d3
	move.b	d3,-(a0)
	add.b	#$30,(a0)
	tst.l	d0
	bne.s	ldiv
	rts

************************************	

sup_in	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,sup_buf
	rts
	
sup_uit	move.l	sup_buf,-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	rts


supp	move.w	sr,d0
	btst	#$a,d0
	bne.s	ipl		;ipl op 4 of hoger!!!	
	btst	#13,d0		;test super mode
	beq.s	ok
ipl2	move.w	#$2300,sr	;back to user
	move.l	(a7),d7
	move.l	nvv+12,-(a7)	;old stack
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d7,(a7)		;reset return adres
ok	rts
ipl	btst	#13,d0
	bne.s	ipl2
	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	bra.s	ipl2

super	pea	(a0)
	move.w	#$26,-(a7)
	trap	#14
	addq.l	#6,a7
	rts
	
sup1	lea	vectab1,a0	; save normal vectors
	move.l	$472.w,(a0)+
	move.l	$476.w,(a0)+
	move.l	$47e.w,(a0)+
	bsr	savdrv
	rts
sup2	lea	vectab2,a0	; save pampuk vectors
	move.l	$472.w,(a0)+
	move.l	$476.w,(a0)+
	move.l	$47e.w,(a0)+
	bsr	savdrv2
	rts
sup3	lea	vectab1,a0	;normal vectors back	
	move.l	(a0)+,$472.w
	move.l	(a0)+,$476.w
	move.l	(a0)+,$47e.w
	bsr	putdrv
	rts
sup4	lea	vectab2,a0	;pampuk vectors back	
	move.l	(a0)+,$472.w
	move.l	(a0)+,$476.w
	move.l	(a0)+,$47e.w
	bsr	putdrv2
	rts

*********************************
* adres & bus & illegal error opvang
*********************************

sup5	lea	nvv70,a0
	move.l	$70.w,2(a0)
	move.l	#new70,$70.w	;colorcycle
	move.l	$84.w,vec84
	lea	nvv,a0
	move.l	8.w,(a0)+
	move.l	$c.w,(a0)+
	move.l	$10.w,(a0)+
	move.l	$4a2.w,a1
	move.l	$24(a1),(a0)+	;save stack
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,(a0)
	move.l	#nvec8,$8.w	;catch & repair bombs
	move.l	#nvecc,$c.w
	move.l	#nvec10,$10.w
	rts
	
sup6	lea	nvv70+2,a0
	move.l	(a0),$70.w	;terug
	lea	nvv,a0
	move.l	(a0)+,8.w
	move.l	(a0)+,$c.w
	move.l	(a0)+,$10.w
sup6a	lea	nvv+12,a0
	move.l	$4a2.w,a1
	move.l	(a0),$24(a1)
	clr.w	flag70		;cycle uit!!
	lea	nvv+16,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts
sup7	move.l	vec84,$84.w
	rts

nvec10	lea	txt7a(pc),a5
	bra.s	nv	
nvecc	lea	txt7(pc),a5
	bra.s	nv	
nvec8	lea	txt6(pc),a5
nv	move.w	#$4300,(a7)
	move.l	#err,2(a7)
	rte
err	lea	stack,a7
	lea	sup6a(pc),a0
	bsr	super
	bsr	scr
	move.l	a5,a4
	bsr	prtline
	bsr	wait
	bra	looop
	
new70	tst.w	flag70		;flag kleuren cycle
	beq.s	nvv70a
	addq.b	#1,$ffff8241.w
	bra.s	nvv70
nvv70a	move.l	nvv+16,$ffff8240.w
	move.l	nvv+20,$ffff8244.w
nvv70	jmp	$12345678
flag70	dc.w	0	
*********************************



SETDRV  lea	bbb(pc),a2		;basepage+$37.b =actual drive
        lea	-$c9(a2),a2
        move.b	(a2),d0
        ADD.B	#$41,D0
        MOVE.B	D0,LO_NAME
        MOVE.B	D0,DIR_BUF	;ZET CORRECTE DRIVE
        clr.w	d0
        move.b	(a2),d0
        move.w	d0,-(a7)
        move.w	#$e,-(a7)
        trap	#1
        addq.l	#4,a7
	RTS
savdrv	lea	bbb(pc),a0
        lea	-$c9(a0),a0	
        move.b	(a0),drv
        rts
        
savdrv2	lea	bbb(pc),a0
        lea	-$c9(a0),a0	
        move.b	(a0),drv+1
        rts
putdrv	lea	bbb(pc),a0
        lea	-$c9(a0),a0	
        move.b	drv,(a0)
        rts
putdrv2	lea	bbb(pc),a0
        lea	-$c9(a0),a0	
        move.b	drv+1,(a0)
        rts
prot2	lea	txt15+2(pc),a0
	clr.l	d0
	moveq	#$3A,d1
pr_3	sub.w	(a0)+,d0
	dbf	d1,pr_3
	sub.w	#$8960,d0
	move.w	d0,pr_flag
	rts
	
quit	lea	sup3(pc),a0
	bsr	super
	lea	sup6(pc),a0
	bsr	super
	dc.w	$a00a
	move.l	screen,a0
	move.w	#$7cf,d0
clean	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	dbf	d0,clean
	dc.w	$a009
	clr.l	-(a7)
	trap	#1
	
****************************
* fileselector+copy name
****************************
        
FILE_SL bsr	scr
	lea	txt2(pc),a4		;choose file
	bsr	prtline
	
	MOVE.L	#AESBLOK,D1
        MOVE.W	#$C8,D0
        TRAP	#2
        TST.W	INT_OUT		;ERGENS FOUT GEGAAN
        BEQ	quit
        TST.W	INT_OUT+2		;CANCEL GEDRUKT !
        BEQ	quit
        LEA	LO_NAME,A1	;FOLDER NAMEN ETC.. ZETTEN
        LEA	DIR_BUF,A0
        LEA	NEW_NAME,A2	;FILENAAM
BUF1L   TST.B	(A0)
        BEQ.S	FBUF		;TOT EINDE FOLDERS
        MOVE.B	(A0)+,(A1)+
        BRA.S	BUF1L
FBUF	SUBQ.L	#3,A1		;*.*  WEGHALEN !
BUF2L	TST.B	(A2)
	BEQ.S	FBUF2
	MOVE.B	(A2)+,(A1)+
	BRA.S	BUF2L
FBUF2	CLR.B	(A1)+
	BSR	SCR
        RTS
        
*****************************
* data
*****************************

txt1	dc.b	$1b,$59,$20,$37,"*** DEPACKER V1.4 *** ",$BD," THE M.C.A.",0
txt2	dc.b	$1b,$59,$22,$3d,"Choose file to depack",0
txt3	dc.b	$1b,$59,$22,$3d,"Saving depacked file ",0
txt3a	dc.b	$1b,$59,$24,$32,"Filelength before depack = "
txt3b	dc.b	"           bytes"
	dc.b	$1b,$59,$25,$32,"Filelength after  depack = "
txt3d	dc.b	"           bytes",0
txt4	dc.b	$1b,$59,$22,$3d,"Unknown pack method !",0
	
txt5	dc.b	$1b,$59,$22,$3d,"*** Pampuk packer ***"
	dc.b	$1b,$59,$24,$3c,"DClick each file to save"
	dc.b	$1b,$59,$25,$38,"DO NOT CHANGE DIRECTORY YOURSELF!"
	dc.b	$1b,$59,$26,$39,"Quit when ready! (Endless loop)",0
	
txt6	dc.b	27,'p',$1b,$59,$22,$3d,"adres error, bad file",27,'q',0
txt7	dc.b	27,'p',$1b,$59,$22,$3d,"bus error, bad file  ",27,'q',0
txt7a	dc.b	27,'p',$1b,$59,$22,$3d,"illegal, damaged code",27,'q',0

txt8	dc.b	$1b,$59,$22,$3d,"*** hotline  packer ***"
txt8a	dc.b	$1b,$59,$24,$3d,"file length is protected"
	dc.b	$1b,$59,$25,$3d,"give me the main program"
	dc.b	$1b,$59,$26,$3d,"to find the correct code",0
	
txt9	dc.b	$1b,$59,$24,$3d,"I found it, you can now "
	dc.b	$1b,$59,$25,$3d,"get all the other files "
	dc.b	$1b,$59,$26,$3d,"to depack them correctly"
	dc.b	$1b,$59,$28,$3d,"CORRECT MAIN PROGRAM !  "
	dc.b	$1b,$59,$29,$3d,"SEARCH JSR 1000.W T1/3F ",0
	
	
txta	dc.b	$1b,$59,$24,$3d,"I could not find it !!! "
	dc.b	$1b,$59,$25,$3d,"maybe it is a packed one"
	dc.b	$1b,$59,$26,$3d,"or it is unknown to me??",0
	
txtc	dc.b	$1b,$59,$22,$3d,"WRITE ERROR, DISK FULL?!",0

txtd	dc.b	$1b,$59,$22,$3d,"*** Data depacker ***"
	dc.b	$1b,$59,$24,$35,"Searches YEK! or HTL!  at end of file."
	dc.b	$1b,$59,$25,$34,"Some of them guys have removed this name"
	dc.b	$1b,$59,$28,$38,"Keep Search? L=Cancel R=Remove",0
	
txte	dc.b	$1b,$59,$22,$3d,"*** load error !! ***",0

txtf	dc.b	$1b,$59,$27,$39,"WILL NOT FIT ON THIS DISK !!!",0

txt10	dc.b	$1b,$59,$22,$3d,"WRITE ERROR, BAD DISK",0

txt11	dc.b	$1b,$59,$2a,$39," Format   Save   Load   Free "
	dc.b	$1b,$59,$2d,$3c," Set drive   A   B   C ",0
txt11a	dc.b	$1b,$59,$2a,$3a,"Trk "
txt11b	dc.b	"00",0,0,0
txt11c	dc.b	$1b,$59,$2a,$3a," Boot ",0
txt11d	dc.b	$1b,$59,$2a,$3a," Fats ",0

txt12	dc.b	$1b,$59,$22,$3d,"Formatting Disk .....",0
txt13	dc.b	$1b,$59,$22,$3d,"           bytes Free",0
txt15	incbin	names
	dc.b	0
txt19	dc.b	$1b,$59,$22,$3d,"TIMEOUT ERROR !!!!!!!!!",0
drvna	dc.b	5
drvnb	dc.b	4
	even     
DIR_BUF	DC.B	"A:\*.*",0
	DS.L	$30		;FOLDERS !
	EVEN
NEW_NAME	DC.B	"        .   ",0
	EVEN


AESBLOK DC.L	CONTROL,GLOBAL,INT_IN,INT_OUT,ADDR_IN,ADDR_OUT

CONTROL	DC.W	90		;FILESELECTOR WAARDES
	DC.W	 0
	DC.W	2
	DC.W	2
	DC.W	0

GLOBAL	DS.W	1		;NIET GEBRUIKT

INT_IN	DS.W	1		;NIET GEBRUIKT

INT_OUT	DC.W	0		;FOUTFLAG
	DC.W	0		;CANCEL=0  OK=1
	
ADDR_IN	DC.L	DIR_BUF		;ADRES MET DIRECTORY BUFFER
	DC.L	NEW_NAME		;GESELEKTEERDE FILENAAM
	
ADDR_OUT	DC.W	1		;NIET GEBRUIKT

	SECTION   BSS
LO_NAME	DS.L	$30
filestart	ds.l	1
end_adr	ds.l	1
line_a	ds.l	1

vectab1	ds.l	3
vectab2	ds.l	3
vec84	ds.l	1
nvv	ds.l	4
	ds.w	16
SCREEN	DS.L	1
st_relo	ds.l	1
empt	DS.L	$400		;nodig voor depack files
empty		DS.L	1
fileend	ds.l	1
save_st	ds.l	1
length	ds.l	2
drv	ds.w	1
pr_flag	ds.w	1
sup_buf	ds.l	1
rez	ds.w	1

f_buf	ds.b	$2000		;format buffers
buf0	ds.b	512
buf1	ds.b	512

stack2	ds.l	1
	DS.L	100		;STACKSPACE
STACK	DS.L	10
	 