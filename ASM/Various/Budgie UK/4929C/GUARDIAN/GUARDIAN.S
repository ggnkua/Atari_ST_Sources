**   August 1989  **** Guardian
*------------------------------------------**
	bra.s	start
	include "a:\includes\macros.s
	even
start	startup
	jsr	superin		go supervisor
	jsr	phys_base	get physbase
	move.l	d0,physbase	used by exit routine
	sub.l	#512,d0
	and.w	#%1111101100000000,d0
	move.l	d0,$45e		initial screen IMPORTANT
	sub.l	#33280,d0	boundary is ok
	move.l	d0,lady_screen	top_screen minus 32K

*-------------------------------------------------------

	DC.W	$A000		initialize A-line
	move.l	a0,a_line_start
	move.l	(a1)+,d0	6*6 font
	move.l	(a1)+,fontaddress_8
	move.l	(a1),fontaddress_16
	dc.w	$a000
	hide_mouse
	btst	#7,$fffa01	mfp monochrome detect
	beq	hide
	mode	0
	
hide	cursor	0

	bclr 	#0,$484		no keyclick
	bclr 	#1,$484		no repeat key

	move.l	#dtaddress,-(sp)	address of 44-byte DTA buffer
	move.w	#$1a,-(sp)	        set DTA address
	trap	#1
	addq.l	#6,sp

* TRAP CALL TO OBTAIN CURRENT KEY SETTINGS:

	move.w	#-1,-(sp)	read current k/b status	
	move.w	#-1,-(sp)
	move.w	#35,-(sp)
	trap	#14
	addq.l	#6,sp

	move.w	d0,d1		and store it away:
	move.w	d0,d2		we'll modify it when key scrolling...
	lsr	#8,d1		...is needed
	and.w	#%0000000011111111,d1
	and.w	#%0000000011111111,d2
	move.w	d1,k_delay	normally 15
	move.w	d2,k_repeat	normally 2


start_prog
	load	a1_font,a1_ptr		font 16 pixels
	load	a2_font,a2_ptr		font  8 pixels

* now install the various v/blank routines if any
 	lea 	music,a5
	bsr	enable_vbi

* THIS ROUTINE IS FOR VIRUS CHECK
	cls
	font	16
	ink	15
	move.w	#$070,$ff825c
	move.w	#$070,$ff825e
	printat	15,0,0,#mess1
	getkey
	cls
	font	8
	move.w	#$070,$ff825c
	move.w	#$007,$ff825e
	ink	15
	printat	15,0,0,#mess2
	getkey
	cls
	printat	15,0,0,#mess3
	getkey
	cls
	font	16
	home	
	string  <type your message>
	string	< 15 characters max>
	jsr	getlin
	move.l	#budg+15,a1
	move.w	#14,d0
.lop	move.b	#32,(a1)+	blank
	dbra	d0,.lop

	move.l	#keybuff+2,a0
	move.l	#budg+15,a1
	move.w	#14,d0
.loop	move.b	(a0)+,d1	copy input
	cmp.b	#32,d1
	bmi	.out
	move.b	d1,(a1)+
	dbra	d0,.loop
.out
boot	cls
	font	16
	ink	15
	printat	15,6,0,#mess5
	getkey
	cls
	bra	create_boot_uk

*-----------------------------------------------------------*

mess1	dc.b "    THE BUDGIE UK",10,10,13
	dc.b "   VIRUS  GUARDIAN",10,13,0
mess2	dc.b "This is a small program used on all",10,13
	dc.b "the latest BUDGIE UK games",10,13
	dc.b "which acts as an anti- virus",10,13
	dc.b "Early Warning System.",10,10,13
	dc.b "    A small friendly piece of code",10,13
	dc.b "will be written on your boot sector.",10,13
	dc.b "It will produce a greeting flash",10,13
	dc.b "each time you boot your disk.",10,13
	dc.b "Should the greeting fail to appear,",10,13
	dc.b "an uninvited virus is present!",10,13
	dc.b "    Simply re-run this program",10,13
	dc.b "and the virus will be erased.",10,13,0
mess3	dc.b "It uses the leap-frog theory:",10,13
	dc.b "the last code to write itself on",10,13
	dc.b "is always the active one.",10,13
	dc.b "    Keeping the write protect on is",10,13
	dc.b "of course very useful. But some",10,13
	dc.b "games (including Budgie's) save",10,13
	dc.b "high scores to disks.",10,10,13
	dc.b "    Finally, do NOT use this program on",10,13
	dc.b "a commercial disk that uses its boot",10,13
	dc.b "sector.  If a commercial disk auto-boots",10,13
	dc.b "without having an AUTO folder, then",10,13
	dc.b "it uses the boot sector: leave it alone",10,13,0
mess4	
mess5	dc.b "Insert Disk",10,13
	dc.b "to be protected",10,13,0

*~~~~~~~~~~~~~~~~NOW THE SUBROUTINES~~~~~~~~~~~~~~~~~~~~~~~*

* vbi music system  Gary Wheaton

Q 	EQU 1       *OCTAVES
Z 	EQU 4
U 	EQU 2
SL 	EQU $FF8800
SD 	EQU $FF8802

*-------FLAG FOR MUSIC ON OR OFF move.b #1,musicon
*-------TO SILENCE CHANNELS : sound silence (macro)
music	movem.l	d0-d7/a0-a6,-(sp)

	tst.b musicon
	bne	bypass

	MOVE.B #$7,SL
	MOVE.B #%11111000,SD

	CMP.B #1,FL
	BEQ.S PPP 
	BSR SSET
PPP
**************
	LEA _NOTE0,A0
	LEA _NOTE1,A1
	LEA _NOTE2,A2
CHAN0    
**************
	MOVE PNT0,D0 
	ADD D0,A0
	MOVE.L (A0),D1       *GET NOTE 0 & DURATION   
	CMP #$FFFF,D1
	BNE.S CON2
	CLR PNT0                *RESET TO START
	MOVE.L _NOTE0,D1
CON2 
	SUB #1,NP0
	BNE.S STILLON
	MOVE.L D1,TMP0          *D1.W IS DURATION
	MOVE TMP0,TMP00
	MOVE.B #15,VOL0
	MOVE D1,NP0             *SET NEW DURATION
	ADD #4,PNT0             *& INC POINTER
STILLON
***VOLUME
	CMP #0,TMP00
	BNE.S RFF 
	MOVE TMP0,TMP00

RFF    *LSR #1,TMP00
       *LSR #1,TMP00
	CMP.B #0,VOL0
	BEQ.S NV0
	SUB.B #1,VOL0+1
	BNE.S NV0
	SUB.B #1,VOL0
	MOVE.B #5,VOL0+1
NV0
	MOVE.B #8,SL
	MOVE.B VOL0,SD
	MOVE.B #0,SL
	MOVE.B TMP00+1,SD
	MOVE.B #1,SL
	MOVE.B TMP00,SD
CHAN1 
***********************
	MOVE PNT1,D0 
	ADD D0,A1
	MOVE.L (A1),D1       *GET NOTE 1 & DURATION   
	CMP #$FFFF,D1
	BNE.S BON3
	CLR PNT1                *RESET TO START
	MOVE.L _NOTE1,D1
BON3 
	SUB #1,NP1
	BNE.S STILL
	MOVE.L D1,TMP1          *D1.W IS DURATION
	MOVE.B #14,VOL1
	MOVE D1,NP1             *SET NEW DURATION
	ADD #4,PNT1             *& INC POINTER
STILL
***VOLUME
	CMP.B #0,VOL1
	BEQ.S NV1
	SUB.B #1,VOL1+1
	BNE.S NV1
	SUB.B #1,VOL1
	MOVE.B #3,VOL1+1
NV1
	MOVE.B #9,SL
	MOVE.B VOL1,SD
	MOVE.B #2,SL
	MOVE.B TMP1+1,SD
	MOVE.B #3,SL
	MOVE.B TMP1,SD
	MOVE.B #6,SL
	MOVE.B TMP1+1,D0
	LSR.B #1,D0
	MOVE.B D0,SD
CHAN2
***********************
	MOVE PNT2,D0 
	ADD D0,A2
	MOVE.L (A2),D1       *GET NOTE 1 & DURATION   
	CMP #$FFFF,D1
	BNE.S CON3
	CLR PNT2                *RESET TO START
	MOVE.L _NOTE2,D1
CON3 
	SUB #1,NP2
	BNE.S STI              
	MOVE.L D1,TMP2          *D1.W IS DURATION
	MOVE.B #15,VOL2
	MOVE D1,NP2             *SET NEW DURATION
	ADD #4,PNT2             *& INC POINTER
STI 
***VOLUME
	CMP.B #0,VOL2
	BEQ.S NNN
	SUB.B #1,VOL2+1
	BNE.S NNN
	SUB.B #1,VOL2
	MOVE.B #11,VOL2+1
NNN
	MOVE VIB2+2,D0
	ADD D0,VIB2
	CMP #2,VIB2
	BNE.S DD
	NEG VIB2+2
DD 	 CMP #-2,VIB2
	BNE.S NV
	NEG VIB2+2
NV 	MOVE TMP2,TMP22
	MOVE VIB2,D0
	ADD D0,TMP22
	MOVE.B #10,SL
	MOVE.B VOL2,SD
	MOVE.B #4,SL
	MOVE.B TMP22+1,SD
	MOVE.B #5,SL
	MOVE.B TMP22,SD
CD
BYPASS
	movem.l (sp)+,d0-d7/a0-a6
	rts
killer	jmp 0
SSV DC.L 0

**************DATAS***************
***NOTE 1ST WORD. DURATION 2ND WORD 
*START DATA WITH--0,1
*END   DATA WITH-$FFFF,$FFFF,0

_NOTE0                        *lead tune

      DC.W 0,1,108*Z,12,108*Z,6,108*Z,6,108*Z,12,108*Z,6,108*Z,6,108*Z,12
      DC.W 162*Z,12,128*Z,12,108*Z,12

      DC.W 121*Z,12,121*Z,6,121*Z,6,121*Z,12,121*Z,6,121*Z,6,121*Z,12
      DC.W 182*Z,12,144*Z,12,121*Z,12

      DC.W 108*Z,12,108*Z,6,108*Z,6,108*Z,12,108*Z,6,108*Z,6,108*Z,12
      DC.W 96*Z,12,91*Z,12,81*Z,12,91*Z,12,108*Z,12,121*Z,12,144*Z,12,162*Z,24,162*Z,24
********
      DC.W 108*Z,24,108*Z,18,108*Z,6,108*Z,12
      DC.W 162*Z,12,128*Z,12,108*Z,12

      DC.W 121*Z,24,121*Z,18,121*Z,6,121*Z,12
      DC.W 182*Z,12,144*Z,12,121*Z,12

      DC.W 108*Z,24,108*Z,18,108*Z,6,108*Z,12
      DC.W 96*Z,12,91*Z,12,81*Z,12,91*Z,12,108*Z,12,121*Z,12,144*Z,12,162*Z,24,162*Z,24

      DC.W $FFFF,$FFFF,0 *FLAG END

_NOTE2 
      DC.W 0,1,108*8,12,108*16,12,162*8,24
      DC.W 108*8,24,162*8,24

      DC.W 121*8,12,121*16,12,182*8,24
      DC.W 121*8,24,182*8,24


      DC.W 108*8,12,108*16,12,162*8,24
      DC.W 108*8,12,108*8,12,162*8,24

      DC.W 121*8,12,121*8,12,182*8,24,162*8,24,162*8,24
***********

      DC.W 108*8,12,108*16,12,162*8,24
      DC.W 108*8,24,162*8,24

      DC.W 121*8,12,121*16,12,182*8,24
      DC.W 121*8,24,182*8,24


      DC.W 108*8,12,108*16,12,162*8,24
      DC.W 108*8,24,162*8,24

      DC.W 121*8,12,81*8,12,182*8,12,121*8,12,162*8,24,162*8,24

      DC.W $FFFF,$FFFF,0


_NOTE1 
      DC.W 0,1
      DC.W 108*Q,12,96*Q,12,108*Q,12,114*Q,12,108*Q,48
      DC.W 121*Q,12,108*Q,12,121*Q,12,128*Q,12,121*Q,48
      DC.W 108*Q,12,96*Q,12,108*Q,12,114*Q,12,108*Q,48

      DC.W 121*Q,12,144*Q,12,162*Q,12,182*Q,12,162*Q,24,162*Q,24
************
      DC.W 108*U,12,96*U,12,108*U,12,114*U,12,108*U,48
      DC.W 121*U,12,108*U,12,121*U,12,128*U,12,121*U,48
      DC.W 108*U,12,96*U,12,108*U,12,114*U,12,108*U,48

      DC.W 121*U,12,144*U,12,162*U,12,182*U,12,162*U,12,217*U,12,162*U,24

      DC.W $FFFF,$FFFF,0

*------------....here  
SSET
	MOVE _NOTE0+2,NP0
	MOVE _NOTE1+2,NP1
	MOVE _NOTE2+2,NP2
	MOVE.B #1,FL
	RTS

***POINTERS TO NOTES MUST INC BY 4
PNT0       DC.W 0
PNT1       DC.W 0
PNT2       DC.W 0
***TEMP REG
TMP0       DC.L 0
TMP1       DC.L 0
TMP2       DC.L 0

TMP22       DC.W 0
TMP00       DC.W 0
***NOTE IN PROGRESS
NP0       DC.W 0
NP1       DC.W 0
NP2       DC.W 0

FL      DC.B 0   *SE       
	DC.B 0   *GL       
	DC.B 2,0

VOL0       DC.B 15,3
VOL1       DC.B 15,4
VOL2       DC.B 15,2
MUSICON    DC.B  0,0
VIB2       DC.W 0,1

*---------------------------------------------

kwit	

kwi1	lea	music,a5	  
	bsr	disable_vbi  disable the above v/blk routine
	silence
	bra 	quit    restore the palette and official quit
*---------------------------------
create_boot_uk
	jsr	read_sector		read boot sector
	lea	read_buffer,a0		this buffer is 512 bytes long
	move.b	#$60,0(a0)		"bra $3a bytes.. 
	move.b	#$38,1(a0)		..further away"
	add.w	#$3a,a0			put code here
	lea	new_buffer,a1
	move.w	#320,d7			loop
.lll	move.b	(a1)+,(a0)+		transfer to official buffer
	dbra	d7,.lll
	ink	15
	STRING	<OK READY TO WRITE>
	STRING	<PRESS KEY>
	jsr	boot_sector		prepare executionable sector
	getkey
	jsr	write_sector		and write it to disk
	ink	5
	string  <remove disk .....>
	string	<SPACE for another disk>
	getkey
	swap	d0
	cmp.b	#$39,d0
	bne	.exit
	jmp	boot
.exit	bra	kwit	

*----------------------
new_buffer
	lea	budg(pc),a0
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	#200,d7
.lpp	addi.w	#$111,$ff8242
	subi.w	#$222,$ff8240
	bsr	.slow
	dbra	d7,.lpp
	move.w	#230,d7
.lpl	subi.w	#$111,$ff8242
	addi.w	#$111,$ff8240
	bsr	.slow
	dbra	d7,.lpl
	rts
.slow	
	move.w	#1000,d6
.lps	nop
	nop
	dbra	d6,.lps
	rts

budg	dc.b	7,10,10,10
	dc.b	"     ",10,13
	dc.b	"    BUDGIE UK        VIRUS  FREE !",10,10,13
	dc.b	"    All  Circuits  Operational....",10,10,13
	dc.b    "    ------------------------------",10,10,10,10,10,10,13
	dc.b    "    ATARI ST The software Guardian",10,10,13,7,0
	ds.b	500

*~~~~~~~~~~~~~~~~~~~~~~~INCLUDES~~~~~~~~~~~~~~~~~~~~~~~~~~~*
	EVEN
	INCLUDE "a:\includes\include1.s"
	EVEN
	INCLUDE "a:\includes\include2.s"
	EVEN
	INCLUDE "a:\includes\include3.s"
	EVEN
	INCLUDE "a:\includes\include4.s"
	even
	INCLUDE "a:\includes\sounds.s"
	EVEN

*~~~~~~~~~~~~~~~~~VARIABLES AND CONSTANTS~~~~~~~~~~~~~~~~~*

k_repeat	dc.w 0		normally 2
k_delay		dc.w 0		normally 15

a1_font		DC.B 	"a:\fonts\a1_fat.fon",0
a2_font		DC.B 	"a:\fonts\a2_elegant.fon",0
prompt		dc.b 	"bxbxbxbxb",10,13,0
		even
a1_ptr		DC.L 1		16*8 font
a2_ptr		DC.L 1		8*8 font

;physbase	dc.l 0
screen_0	dc.l 0
screen_1	dc.l 0
screen_2	dc.l 0
screen_3	dc.l 0
lady_screen 	DC.L 0
storel		dc.l 0
store		dc.w 0

utility_screen 	DC.L 0
current_screen	dc.l 0
;save_screen	dc.l 0 old screen to protect
;
		EVEN
dtaddress	ds.w 52		needed for disk routines
		

palet		DS.W 16		start up palette 

sbuff     	DS.L 1   this address is the last one on the prog
high_scores	dc.l 0
	EVEN

*~~~~~~~~~~~~~~~~~~~THE STACK~~~~~~~~~~~~~~~~~~~~~~~~~~*

	DS.L	256	about 64 used on average
stack	DC.L	0        


*~~~~~~~THE END~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

