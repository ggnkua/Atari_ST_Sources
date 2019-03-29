* AUTOMATION 2.3 DEPACKER ROUTINES...
* Ripped out of Automation's COMMANDO loader by The Alien.
* Use this when you have packed data files as well as the main prg file
* of a game... just insert your message, the filename of the main prg
* and then load this assembled prg from your menu.
* If you don't understand, I don't care- get lost, lamer!
* I've only had time to put in a few decent labels, and some of this code
* seems pretty redundant so have fun!

* Devpac 2 source, my tabs are set at 13.

	MOVEA.L	4(A7),A5
	MOVE.L	$C(A5),D0
	ADD.L	$14(A5),D0
	ADD.L	$1C(A5),D0
	ADDI.L	#$100,D0
	MOVE.L	D0,-(A7)
	MOVE.L	A5,-(A7)
	MOVE.L	#$4A0000,-(A7)
	TRAP	#1
	LEA	$C(A7),A7
	CLR.L	-(A7)
	MOVE.W	#$20,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	LEA	save_oldsp(PC),A6
	MOVE.L	D0,(A6)
	MOVE.L	$84,oldtrap1+2
	MOVE.L	#newtrap1,$84
	MOVE.L	save_oldsp(PC),-(A7)
	MOVE.W	#$20,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	CLR.W	-(A7)
	PEA	-1
	MOVE.L	(A7),-(A7)
	MOVE.W	#5,-(A7)
	TRAP	#14
	LEA	$C(A7),A7
	PEA	message
	MOVE.W	#9,-(A7)
	TRAP	#1
mystack	CLR.L	$60000
	PEA	$60000
	MOVE.L	(A7),-(A7)
	MOVE.L	#filename,-(A7)
	MOVE.L	#$4B0000,-(A7)
	TRAP	#1
	LEA	$10(A7),A7
	CLR.W	-(A7)
	TRAP	#1
	DS.L	1	unused!
save_oldsp	DS.L	1
newtrap1	MOVEM.L	D0-D7/A0-A6,saveregs
	MOVEA.L	A7,A1
	ADDQ.L	#6,A1
	MOVE.W	(A7),D0
	BTST	#$D,D0
	BNE.S	ssp
	MOVE.L	USP,A1
ssp	CMPI.W	#0,(A1)	p_term?
	BNE.S	not_term
	MOVE.L	oldtrap1+2,$84.W	replace trap 1 vector
not_term	CMPI.W	#$3D,(A1)	f_open?
	BNE.S	not_open
	MOVEA.L	2(A1),A1
	CMPI.B	#$3A,1(A1)	:?	by the looks of this,
	BNE.S	not_semi		he's checking for file
	ADDQ.L	#2,A1		accesses such as A:\???
not_semi	CMPI.B	#$5C,(A1)	\?	and making it use the
	BNE.S	not_slash		current directory!
	ADDQ.L	#1,A1
not_slash	MOVEM.L	saveregs,D0-D7/A0-A6
oldtrap1	jmp	0

read_addr	ds.l	1

sf_filnam	ds.l	1

save_dta	ds.l	1


not_open	CMPI.W	#$4E,(A1)		dunno... weird.
	BNE.S	not_sfirst
	MOVE.L	2(A1),sf_filnam
	BRA.S	not_slash
not_sfirst	CMPI.W	#$2F,(A1)		gibber gibber
	BNE.S	not_getdta
	MOVE.L	2(A7),retaddr+2
	MOVE.L	#newaddr,2(A7)
	BRA	not_slash
newaddr	MOVE.L	D0,save_dta
	ADDI.L	#$1A,save_dta
	MOVE.L	D0,-(A7)
	BSR	L6364E
	MOVE.L	(A7)+,D0
retaddr	JMP	0
not_getdta	CMPI.W	#$3F,(A1)		f_read?
	BNE.S	not_slash
	MOVE.L	8(A1),read_addr
	CMPI.L	#$5E80,4(A1)
	BNE.S	L634E4
	LEA	L634FC(PC),A0
	MOVE.L	(A0),4(A1)
	MOVE.L	4(A0),(A0)
	MOVE.L	8(A0),4(A0)
	MOVE.L	$C(A0),8(A0)
	MOVE.L	4(A1),$C(A0)
L634E4	MOVE.L	2(A7),return+2
	MOVE.L	#L6350C,2(A7)
	BRA	not_slash
L634F8	DS.L	1
L634FC	DC.B	0,0,$3C,$68
	DC.B	0,0,$34,$3E,0,0,$36,$10
	DC.B	0,0,$39,$BC
L6350C	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.L	D0,L634F8
	PEA	do_unpack
	MOVE.W	#$26,-(A7)
	TRAP	#14
	ADDQ.L	#6,A7
	MOVEM.L	(A7)+,D0-D7/A0-A6
	MOVE.L	L634F8,D0
return	JMP	0
L63534	DS.W	1
do_unpack	MOVEA.L	read_addr,A1
	CMPI.W	#$FFFF,L63534
	BEQ	L635E2
	CMPI.B	#$4C,(A1)		L
	BNE	not_slash
	CMPI.B	#$53,1(A1)		S
	BNE	not_slash
	CMPI.B	#$44,2(A1)		D
	BNE	not_slash
	CMPI.B	#$21,3(A1)		!
	BNE	not_slash
	MOVE.L	4(A1),L634F8
	SUBA.L	#$20,A1
	LEA	L63620(PC),A0
	MOVEQ	#$1F,D0
L63582	MOVE.B	(A1)+,(A0)+
	DBF	D0,L63582
	MOVEA.L	read_addr,A0
	MOVEA.L	A0,A1
	SUBA.L	#$20,A1
	MOVE.L	A7,save_sp
	LEA	mystack(PC),A7
	MOVE.L	8(A0),D0
	ADDQ.L	#4,D0
L635A6	MOVE.B	(A0)+,(A1)+
	SUBQ.L	#1,D0
	CMP.L	#0,D0
	BNE.S	L635A6
	MOVEA.L	read_addr,A0
	MOVEA.L	A0,A1
	SUBA.L	#$20,A0
	BSR	depack
	MOVEA.L	read_addr,A0
	SUBA.L	#$20,A0
	LEA	L63620(PC),A1
	MOVEQ	#$1F,D0
L635D6	MOVE.B	(A1)+,(A0)+
	DBF	D0,L635D6
	MOVEA.L	save_sp,A7
L635E2	RTS
saveregs	ds.l	15
L63620	DC.W	0,0
	DC.W	0,0,0,0
	DC.W	0,0,0,0
	DC.W	0,0,0,0
	DC.W	0,0
L63640	DS.L	1
L63644	DC.W	0,0,0,0
	DC.W	0
L6364E	MOVEM.L	D1-D7/A0-A6,-(A7)
	CLR.W	-(A7)
	MOVE.L	sf_filnam,-(A7)
	MOVE.W	#$3D,-(A7)
	TRAP	#1
	ADDQ.L	#8,A7
	MOVE.L	D0,D5
	MOVE.W	#$FFFF,L63534
	PEA	L63644
	MOVE.L	#8,-(A7)
	MOVE.W	D5,-(A7)
	MOVE.W	#$3F,-(A7)
	TRAP	#1
	LEA	$C(A7),A7
	MOVE.W	D5,-(A7)
	MOVE.W	#$3E,-(A7)
	TRAP	#1
	ADDQ.L	#4,A7
	LEA	L63644(PC),A0
	CMPI.L	#$4C534421,(A0)
	BNE.S	L636A6
	MOVE.L	4(A0),D0
	MOVEA.L	save_dta,A0
	MOVE.L	D0,(A0)
L636A6	CLR.W	L63534
	MOVEM.L	(A7)+,D1-D7/A0-A6
	RTS
depack	ADDA.L	#4,A0
	MOVE.W	$FF8240,-(A7)
	MOVE.L	A0,L63640
	MOVE.L	(A0)+,D5
	ADDA.L	D5,A1
	ADDA.L	(A0),A0
	SUBQ.L	#4,A0
	TST.W	-(A0)
	BPL.S	L636D2
	SUBQ.L	#1,A0
L636D2	MOVE.B	-(A0),D0
L636D4	LSL.B	#1,D0
	BNE.S	L636DC
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L636DC	BCC.S	L63738
	CLR.W	D1
	LSL.B	#1,D0
	BNE.S	L636E8
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L636E8	BCC.S	L6372C
	LEA	L63724(PC),A3
	MOVEQ	#3,D3
L636F0	CLR.W	D1
	MOVE.B	0(A3,D3.W),D2
	EXT.W	D2
	MOVEQ	#-1,D4
	LSL.W	D2,D4
	NOT.W	D4
	SUBQ.W	#1,D2
L63700	LSL.B	#1,D0
	BNE.S	L63708
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L63708	ROXL.W	#1,D1
	DBF	D2,L63700
	TST.W	D3
	BEQ.S	L63718
	CMP.W	D1,D4
	DBNE	D3,L636F0
L63718	MOVE.B	4(A3,D3.W),D2
	EXT.W	D2
	ADD.W	D2,D1
	BRA	L6372C
L63724	DC.B	$A,3,2,2,$E,7,4,1
L6372C	MOVE.B	-(A0),-(A1)
	MOVE.W	D0,$FFFF8240
	DBF	D1,L6372C
L63738	MOVEA.L	L63640,A3
	ADDQ.L	#8,A3
	CMPA.L	A3,A0
	BLE	L6380A
	LEA	L63782(PC),A3
	MOVEQ	#3,D2
L6374C	LSL.B	#1,D0
	BNE.S	L63754
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L63754	BCC.S	L6375A
	DBF	D2,L6374C
L6375A	CLR.W	D1
	ADDQ.W	#1,D2
	MOVE.B	0(A3,D2.W),D3
	BEQ.S	L63776
	EXT.W	D3
	SUBQ.W	#1,D3
L63768	LSL.B	#1,D0
	BNE.S	L63770
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L63770	ROXL.W	#1,D1
	DBF	D3,L63768
L63776	MOVE.B	5(A3,D2.W),D3
	EXT.W	D3
	ADD.W	D3,D1
	BRA	L6378C
L63782	DC.B	$A,2,1,0,0,$A,6,4
	DC.B	3,2
L6378C	CMPI.W	#2,D1
	BEQ.S	L637D2
	LEA	L637C6(PC),A3
	MOVEQ	#1,D3
L63798	LSL.B	#1,D0
	BNE.S	L637A0
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L637A0	BCC.S	L637A6
	DBF	D3,L63798
L637A6	ADDQ.W	#1,D3
	CLR.W	D2
	MOVE.B	0(A3,D3.W),D4
	EXT.W	D4
L637B0	LSL.B	#1,D0
	BNE.S	L637B8
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L637B8	ROXL.W	#1,D2
	DBF	D4,L637B0
	LSL.W	#1,D3
	ADD.W	4(A3,D3.W),D2
	BRA.S	L637F6
L637C6	DC.B	$B,4,7,0,1,$20,0,0
	DC.B	0,$20,0,0
L637D2	CLR.W	D2
	MOVEQ	#5,D3
	CLR.W	D4
	LSL.B	#1,D0
	BNE.S	L637E0
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L637E0	BCC.S	L637E6
	MOVEQ	#8,D3
	MOVEQ	#$40,D4
L637E6	LSL.B	#1,D0
	BNE.S	L637EE
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L637EE	ROXL.W	#1,D2
	DBF	D3,L637E6
	ADD.W	D4,D2
L637F6	LEA	0(A1,D2.W),A2
	EXT.L	D1
	ADDA.L	D1,A2
	SUBQ.W	#1,D1
L63800	MOVE.B	-(A2),-(A1)
	DBF	D1,L63800
	BRA	L636D4
L6380A	MOVE.W	(A7)+,$FF8240
	RTS
save_sp	ds.l	1

* these are the bits you'll wanna change...
filename	dc.b	"program.exe",0
message	dc.b	27,"E",27,"f           WHOEVER PRESENTS..."
	DC.B	13,10,10,"BLAH BLAH BLAH BLAH BLAH BLAH BLAH BLAH"
	DC.B	13,10,10," 2.3 DEPACKER RIPPED OFF BY THE ALIEN!",0