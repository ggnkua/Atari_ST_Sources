;--------------------------------------------------
; Bootsector Installer by MUG U.K for personal use
;--------------------------------------------------
;
; Go to the end of this source code and press 'Alt' & 'I' to insert
; some new bootsector code
;
;
* Ask which drive is to be protected

guard	pea	guardmess
	move.w	#$09,-(sp)
	trap	#1
	addq.l	#6,sp
		
* Wait for the 'a', 'b' and 'esc' keys.

_kloop	move.w	#$07,-(sp)
	trap	#1
	addq.l	#2,sp
	swap	d0
	
	cmp.b	#1,d0	ESC key
	beq.s	_exit
	cmp.b	#$1e,d0	'a' key
	beq.s	guarda
	cmp.b	#$30,d0	'b' key
	bne.s	_kloop
	
guardb	move.w	#1,guarddrv+2
	bra.s	do_guard
	
guarda	clr.w	guarddrv+2

do_guard	pea	guardclr	Display 'Writing'
	move.w	#$09,-(sp)
	trap	#1
	addq.l	#6,sp
		
* Read the current bootsector and insert the main data into ours

	bsr.s	read
		
	move.w	#29,d0
	lea	mybuffer,a1
	lea	bootbuffer,a0
cloop1	move.b	(a0)+,(a1)+
	dbf	d0,cloop1
	move.w	#$601c,mybuffer	 ; Add BSR code
		
* Calculate new checksum

	lea	mybuffer,a0	My bootsector
	clr.w	d7	Clear checksum count
	clr.w	$1fe(a0)	In buffer as well
	move.w	#$ff,d5
calop	add.w	(a0)+,d7	Make checksum in D7
	dbf	d5,calop
	move.w	#$1234,d0
	sub.w	d7,d0
	move.w	d0,$1fe+mybuffer
	
	bsr.s	write
	
	bra	guard
	
_exit	clr.w	-(sp)
	trap	#1

* Subroutines to read and write the bootsector

read	move.w	#$08,d0
	lea	bootbuffer,a0
	bra.s	perform
write	move.w	#$09,d0
	lea	mybuffer,a0
perform	move.w	#$01,-(sp)	Read 1 sector
	clr.w	-(sp)	Side 0
	clr.w	-(sp)	Track 0
	move.w	#$01,-(sp)	Sector 1
guarddrv	move.w	#0,-(sp)	Drive A
	clr.l	-(sp)	Filler
	move.l	a0,-(sp)	Address of buffer
	move.w	d0,-(sp)	Floprd/flopwr
	trap	#14
	add.l	#20,sp
	tst.w	d0
	bne.s	error
	rts

error	pea	fuck_up
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts
		
guardmess	dc.b	27,"E"
	dc.b	"The Wizard Bootsector Installer v1.0",13,10
	dc.b	"-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+",13,10,10
	dc.b	"Coded by: MUG U.K",191," - 30/1/1993",13,10,10
	dc.b	"Insert Disk To Be Installed.",13,10,10
	dc.b	"Press 'A' to write to the disk in drive A",13,10
	dc.b	"      'B' to write to the disk in drive B",13,10
	dc.b	"     'ESC' to abort.",0
	even

guardclr	dc.b	13,10,10,10
	dc.b	"Writing ... Please Wait",0
	even

fuck_up	dc.b	13,10,10,27,"p"
	dc.b	"Error in writing !!",27,"q",0
	even
		
	even
	
* 512 byte buffer for bootsector read from disk
	
bootbuffer	ds.b	512

* Pre constructed boot sector minus statistics

bootst
mybuffer	ds.b	30

* Insert the bootsector source of your choice after 'bootcode'

bootcode
 
;
; Riverdene PDL Large Bouncy Scrolly
; ----------------------------------
;
; De-Encrypted & Disassembled by: MUG U.K(tm)
;
; But probably ripped from Enchanted Lands in the first place !!


	opt	p+

Start	MOVEA.L   #$FF8200,A4 
	MOVEA.L   #$FF8240,A5 
	MOVE.L    (A4),-(A7)
	MOVE.B    $FFFFFA15.W,-(A7) 
	CLR.B     $FFFFFA15.W 

	MOVEA.L   A5,A0 		; Black Out Palette
	MOVEQ     #7,D0 
clr_pal	CLR.L     (A0)+ 
	DBF	D0,clr_pal

	LEA	TEXT(PC),A0	; Print text on screen
	PEA	(A0)
	MOVE.W    #9,-(A7)
	TRAP	#1
	ADDQ.W    #6,A7 

	MOVEA.L   $44E.W,A0 
	LEA	$30000,A1 
	MOVEQ	#7,D0 
L0001	MOVEQ     #$1B,D4 
L0002	MOVEQ     #$1B,D1 
	MOVE.L    #$70001,D3
	MOVE.L    D5,-(A7)
	MOVE.L    A0,-(A7)
L0003	MOVEQ     #7,D2 
L0004	CLR.W     (A1)
	BTST      D2,(A0) 
	BEQ.B     L0005 
	MOVE.W    #$770,(A1)
L0005	ADDQ.W    #2,A1 
	DBF       D2,L0004
	ADDA.W    D3,A0 
	SWAP      D3
	DBF       D1,L0003
	MOVEA.L   (A7)+,A0
	MOVE.L    (A7)+,D5
	ADDI.W    #$10,D5 
	DBF	D4,L0002
	ADDQ.W    #1,D5 
	LEA	160(A0),A0
	DBF	D0,L0001
	MOVE.L    #$75A80,D0
	MOVEA.L   D0,A0 
	LSR.W     #8,D0 
	MOVE.L    D0,(A4) 
	MOVE.W    #$2007,D0 
L0006	CLR.L     (A0)+ 
	DBF       D0,L0006
	MOVEQ     #0,D7 
	MOVEQ     #1,D6 
	MOVEQ     #0,D3 
	MOVE.W    #$FF38,D4 
	MOVE.L    $70.W,-(A7) 
	MOVE.L    $68.W,-(A7) 

	LEA	new_70(PC),A0
	MOVE.L    A0,$70.W

	LEA       new_68(PC),A0
	MOVE.L    A0,$68.W

L0007	STOP      #$2300
	LEA       $30000,A6 
	ADD.W     D3,D4 
	TST.W     D3
	BEQ.B     L0008 
	CMP.W     #$28,D3 
	BEQ.B     L0008 
	CMP.W     #$FFD8,D3 
	BNE.B     L0009 
L0008	NEG.W     D3
	ADD.W     D3,D4 
L0009	ADDQ.W    #1,D3 
	MOVE.W    D4,D2 
	MOVEQ     #0,D5 
	ASR.W     #3,D2 
	BPL.B     L000A 
	SUB.W     D2,D5 
	MULS      #$1C0,D2
	SUBA.L    D2,A6 
	CLR.W     D2
L000A	MOVEQ     #1,D0 
	AND.W     D7,D0 
	EORI.W    #1,D0 
	MULU      #6,D0 
	STOP      #$2100
	MOVE      #$2300,SR 
	MOVEQ     #$50,D1 
	ADD.W     D0,D1 
	MOVEQ     #0,D0 
L000B	MOVE.B    $FFFF8209.W,D0
	BEQ.B     L000B 
	SUB.W     D0,D1 
	LSR.W     D1,D1 
	MOVEQ     #$15,D0 
L000C	DBF       D0,L000C
L000D	MOVEQ     #$28,D0 
L000E	DBF       D0,L000E
	DBF       D2,L000D
	MOVE.W    D7,D0 
	ANDI.W    #$FFFE,D0 
	ADDA.W    D0,A6 
	MOVE.W    #$C4,D0 
	SUB.W     D5,D0 
L000F	MOVEQ     #$13,D1 
L0010	MOVE.W    (A6)+,(A5)
	DBF       D1,L0010
	NOP 
	LEA       408(A6),A6
	DBF       D0,L000F
	CLR.W     (A5)
	ADD.W     D6,D7 
	BEQ.B     L0011 
	CMP.W     #$180,D7
	BNE.B     L0012 
L0011	NEG.W     D6

L0012	CMPI.B    #$39,$FFFFFC02.W	; space pressed ??
	BNE       L0007 
	MOVE.L    (A7)+,$68.W 
	MOVE.L    (A7)+,$70.W 
	MOVE.B    (A7)+,$FFFFFA15.W 
	MOVE.L    (A7)+,(A4)
	RTS 			; exit bootsector

new_70	MOVEQ     #$21,D0 
L0014	STOP      #$2100
	DBF       D0,L0014
	MOVEQ     #$17,D0 
L0015	DBF       D0,L0015
	MOVE.B    #0,$FFFF820A.W
	MOVEQ     #6,D0 
L0016	DBF       D0,L0016
	MOVE.B    #2,$FFFF820A.W
new_68	RTE 

TEXT	DC.B      '  THE WIZARD IN 1993 !!  ',0
	EVEN

blanks	ds.b	66