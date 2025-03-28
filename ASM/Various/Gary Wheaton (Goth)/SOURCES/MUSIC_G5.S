;            more music drivers by G.W   Budgie UK
* perry.s

 MOVE.L A7,A5
 MOVE.L 4(A5),A5
 MOVE.L $C(A5),D0
 ADD.L $14(A5),D0
 ADD.L $1C(A5),D0
 ADD.L #$1100,D0
 MOVE.L A5,D1
 ADD.L D0,D1
 AND.L #-2,D1
 MOVE.L D1,A7
 MOVE.L D0,-(SP)
 MOVE.L A5,-(SP)
 MOVE.W D0,-(SP)
 MOVE.W #$4A,-(SP) ; Setblock.
 TRAP #1
 ADD.L #12,SP
;
 CLR.L -(SP)       ; Enter supervisor mode.
 MOVE.W #$20,-(SP) ; Super.
 TRAP #1
 ADDQ.L #6,SP
 MOVE.L D0,SUPER   ; Save old status.


	dc.w	$a000
	MOVEA.L	8(A0),A0
	CLR.W	(A0)
	DC.W	$A00A		hidemouse

	movem.l	$ff8240,d0-d7
	movem.l	d0-d7,palette


getrez	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,res

setlowrez
	CLR.W	-(A7)		0=low res
	MOVE.L	$44e,-(A7)	-1=ignore physbase
	MOVE.L	$44e,-(A7)	-1=ignore logbase
	MOVE.W	#5,-(A7)
	TRAP	#14		
	LEA	$0C(A7),A7	

	clr.l	$200
	not.l	$200		on/off switch
	bclr 	#0,$484		no keyclick
	bclr 	#1,$484		no repeat key

	move.l	#vbi,$4de	start vbi interrupt

* load a degas picture at a specific address 
	MOVE.W	#0,-(A7)
	pea	name(pc)
	MOVE.W	#$3D,-(A7)
	TRAP	#1
	add.l	#8,sp
	MOVE.W	D0,d7	handle

	move.l	$44e,d0		load direct to current screen
	sub.l	#34,d0
	MOVE.L	d0,-(sp) 
	MOVE.L	#34,-(A7)	read it
	MOVE.W	d7,-(A7)	handle
	MOVE.W	#$3F,-(A7)
	TRAP	#1
	ADDA.L	#$C,A7

	move.l	$44e,a0
	sub.l	#32,a0		palette
	MOVE.L	A0,-(SP)  
	MOVE.W	#6,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP

	move.l	$44e,d0		load direct to current screen
	MOVE.L	d0,-(sp) 
	MOVE.L	#32000,-(A7)	read it
	MOVE.W	d7,-(A7)	handle
	MOVE.W	#$3F,-(A7)
	TRAP	#1
	ADDA.L	#$C,A7


	MOVE.W 	d7,-(SP)	close
	MOVE.W 	#$3E,-(SP)
	TRAP 	#1
	ADDQ.L 	#4,SP

	move.l	$44e,a0
	sub.l	#32,a0		palette
	MOVE.L	A0,-(SP)  
	MOVE.W	#6,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP

getkey	MOVE.W	#$07,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	ANDI.W	#$DF,D0		force upper case

* restore res
	move.w	res,-(A7)	
	MOVE.L	$44e,-(A7)	-1=ignore physbase
	MOVE.L	$44e,-(A7)	-1=ignore logbase
	MOVE.W	#5,-(A7)
	TRAP	#14		
	LEA	$0C(A7),A7	

	movem.l	palette,d0-d7
	movem.l	d0-d7,$ff8240


 MOVE.L SUPER,-(SP)
 MOVE.W #$20,-(SP)
 TRAP #1
 ADDQ.L #6,SP

 MOVE.W #0,-(SP)		exit
 MOVE.L #1024*6,-(SP)
 MOVE.W #$31,-(SP)
 TRAP #1

res	dc.w 	0
palette	ds.w	16

*-------------------------
;1 VIBRATO		256
;2 WARBUP		512
;3 DRUM			768
;4 HOLD			1024
;5 WARBHOLD		1280
;6 WARBDWN		1536
;7 SLIDE UP WITH WARB   1792
;8 SLIDE UP           	2048
;9 VIB UP		2304
;10	VIB DOWN	2560

E EQU 512
F EQU 2
P EQU 1792
R equ 2
J EQU 8
I EQU 4
H EQU 16
W EQU 1
X EQU 8
T EQU 8
Q EQU 2
Z EQU 2
U EQU 2
O EQU 2

SL EQU $FF8800
SD EQU $FF8802

*------------------------
vbi             
	movem.l d0-d7/a0-a6,-(sp)
	lea	$fffc00,a1		acia
	cmp.b	#$61,2(a1)		undo
	beq	end_it
	cmp.b	#$62,2(a1)		help
	beq	on_off

	lea	$200,a0
	tst.l	(a0)
	beq	quiet

 	move.b #7,sl
	move.b #%11111000,sd		mixer


 ADD.B #128,HIT
 BCC tth
 MOVE.L UPTO,A2
 MOVE CUNT,D3
 MOVE.B 33(A2),D4
SSU SUBQ.W #1,D3
 BPL.S PART1
 MOVE.L #2,PNT1
 MOVE.L #2,PNT2
 MOVE.L #2,PNT3
 MOVE.L #2,PNT4

 MOVE.L #$08000000,SL
 MOVE.L #$09000000,SL
 MOVE.L #$0A000000,SL

 ADD.L #38,a2
 CMP.L #CHAN0,A2
 BNE.S LLA
 LEA DOTH,A2
LLA
 MOVE 34(A2),D3
 MOVE.B 33(A2),D4
PART1
 CLR.B D2
 BTST #1,D4
 BEQ.S W1
 MOVE.L (A2),A1
 MOVE.L 4(A2),A0
 BSR CHAN0
W1 BTST #2,D4
 BEQ.S W2
 MOVE.L 8(A2),A1
 MOVE.L 12(A2),A0
 BSR CHAN0
W2 MOVE.B #1,D2
 BTST #3,D4
 BEQ.S W3
 MOVE.L 16(A2),A1
 MOVE.L 20(A2),A0
 BSR CHAN0
W3 BTST #4,D4
 BEQ.S W4
 MOVE.L 24(A2),A1
 MOVE.L 28(A2),A0
 BSR CHAN0
W4 MOVE.L A2,UPTO
 MOVE D3,CUNT

TTH
	movem.l (sp)+,d0-d7/a0-a6
	rts
end_it
	bclr	#6,$fffa11	acknowledge key press interrupt
	lea	$ff8800,a0
	move.b	#7,(a0)
	move.b	#%11111111,2(a0)
	move.l	#0,$4de		end interrupt
	movem.l (sp)+,d0-d7/a0-a6
 	rts
on_off	bclr	#6,$fffa11	
	not.l	$200		toggle on/off
	lea	$ff8800,a0
	move.b	#7,(a0)
	move.b	#%11111111,2(a0)
	movem.l (sp)+,d0-d7/a0-a6
 	rts

quiet	movem.l (sp)+,d0-d7/a0-a6
	rts
	even


 DC.B "  G.WHEATON. 45 GOLDRILL AVE, BOLTON, LANCS, U.K. "

super 	dc.l 	0
handle	dc.w	0,0
hit	dc.b	0,0
name	dc.b	"title2.pi1",0
	even
dosound
	movem.l	a0-a6/d0-d6,-(sp)
	MOVE.L	A0,-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#14                     
	ADDQ.L	#6,SP
	movem.l	(sp)+,a0-a6/d0-d6
	RTS
	EVEN
silence
	DC.B 0,0,1,0,2,0,3,0,4,0,5,0,6,0,7,0,8,0
	DC.B 9,0,10,0,11,0,12,0,13,0,14,0,15,0,255,0
**************************



UPTO DC.L EE-38
CUNT DC.W 0
 EVEN
;\\RUNNING ORDER SEQUENCE

EE
 DC.L PNT4,_NOTE0        NT1
 DC.L PNT1,_NOTE1
 DC.L PNT2,_NOT
 DC.L PNT3,DRMM
 DC.B 2,%0011110
 DC.W 127
 DC.W 0


DOTH
;DONT LOOK SO SAD, I KNOW IT'S OVER

 DC.L PNT4,V1
 DC.L PNT1,_NOTE1
 DC.L PNT2,_NOTE0 
 DC.L PNT3,DRMM
 DC.B 1,%0011110
 DC.W 63
 DC.W 2

 DC.L PNT2,ARPAMIN
 DC.L PNT1,ARPAM1
 DC.L PNT4,V2
 DC.L PNT3,DRMM
 DC.B 1,%0011110
 DC.W 63
 DC.W 2

 DC.L PNT2,ARPDMIN
 DC.L PNT1,ARPDM1
 DC.L PNT4,V3
 DC.L PNT3,DRMM
 DC.B 0,%0011110
 DC.W 63
 DC.W 2

 DC.L PNT2,_NOTE0        NT1
 DC.L PNT1,_NOTE1
 DC.L PNT4,V4
 DC.L PNT3,DRMM
 DC.B 0,%0011110
 DC.W 63
 DC.W 2


;  BUT LIFE GOES ON



 DC.L PNT2,_NOTE0        NT1
 DC.L PNT1,_NOTE1
 DC.L PNT4,V1
 DC.L PNT3,DRMM
 DC.B 0,%0011110
 DC.W 63
 DC.W 2

 DC.L PNT2,ARPAMIN
 DC.L PNT1,ARPAM1
 DC.L PNT4,B1
 DC.L PNT3,DRMM
 DC.B 0,%0011110
 DC.W 63
 DC.W 2

 DC.L PNT2,ARPDMIN
 DC.L PNT1,ARPDM1
 DC.L PNT4,B2
 DC.L PNT3,DRMM
 DC.B 0,%0011110
 DC.W 63
 DC.W 2

 DC.L PNT2,_NOTE0        NT1
 DC.L PNT1,_NOTE1
 DC.L PNT4,B3
 DC.L PNT3,DRMM
 DC.B 0,%0011110
 DC.W 63
 DC.W 2





CHAN0
;\\\\\\\\\\\\\\\\\\\\\\
 SUBQ.B #2,3(A1)  ;NOTE STILL ON
 BNE STILLON
 
 MOVE (A1),D0
 ADD D0,A0

 MOVE.L (A0),D1  ;GET NOTE 0 & DURATION
 MOVE.B 13(A1),D5
 EXT.W D5
 SWAP D1
 ADD D5,D1
 SWAP D1
 CMP #$FFFF,D1
 BNE CON2
 CLR (A1)        ;RESET TO START
 SUB D0,A0
 MOVE.L (A0),D1
CON2
 MOVE.L D1,6(A1)      ;TMP0 \D1.W IS DURATION
 MOVE.L D1,20(A1)     ;NEW NOTE
 MOVE.B 26(A1),4(A1)  ;VOL0
 MOVE D1,2(A1)        ;NP0  \SET NEW DURATION
 ADDQ.W #4,(A1)       ;& INC POINTER
 MOVE 36(A2),D0


STILLON
;\\VOLUME
RFF
;\\\\\\\\\EFFECTS\\\\\\\\\\
NV0 CMP.B #8,10(A1)
 BNE.S SIT
 MOVE.B 37(A2),D0        ;STANDING EFFECT
 BNE.S FFW

SIT MOVE.B 2(A1),D0
FFW CMP.B #4,D0
 BNE DOIT
 ADDQ.B #1,4(A1)
 RTS
DOIT TST.B D2
 BEQ.S FCC

 MOVE.B #7,SL
 MOVE.B #%11111000,SD
 BRA.S FCC
EFCT
 DC.L FINK,VIB,WARB,DRUM,HOLD,WB1,WRP,SLW
 DC.L SLR,VIB,SLIP
FCC
 AND.L #15,D0
 ASL #2,D0
 MOVE.L EFCT(PC,D0),A0
 JSR (A0)
MAZ CMP #2,20(A1)
 BNE.S DIP
 MOVE.B #35,4(A1)


;---------PLAY NOTES
DIP
 ADDQ.B #1,4(A1)          ;VOL0
 MOVE.B 11(A1),SL
 MOVE.B 21(A1),SD   ;TMP0+1
 MOVE.B 12(A1),SL
 MOVE.B 20(A1),SD   ;TMP0
 CLR D0
 MOVE.B 4(A1),D0
 MOVE.B 10(A1),SL
 MOVE.B 28(A1,D0),SD    ;VOL0
FINK RTS



 DC.B " (C) G.WHEATON.  45 GOLDRILL AVE BOLTON. LANCS, U.K. "
;-------EFFECTS ROUTINES--------
;1-256---DELAYED--VIBRATO-------
VV EOR.B #1,MC
 BEQ.S SDC

VIB ;CLR D1
 ;MOVE.B 4(A1),D1
 ;CMP.B #12,D1 
 ;BLT SDC
 SUB.B #1,24(A1)
 BNE SDC
 MOVE.B 25(A1),24(A1)
 MOVE 16(A1),D1
 ADD D1,18(A1)
 MOVE 14(A1),D1
 CMP 18(A1),D1
 BLT.S RIST
KJ NEG D1
 CMP 18(A1),D1
 BGT.S RIST
SAZ MOVE 6(A1),D1
 ADD 18(A1),D1
 MOVE D1,20(A1)
SDC BRA WARB RTS
RIST NEG 16(A1)
 BRA.S SAZ
;2-512------WARB DW-----------
WARB 
 ASL 20(A1)
 CMP #800,20(A1)
 BLT.S PLOP
 MOVE 6(A1),20(A1)
PLOP  RTS

NOG DC.B %11011000,1
;3--768--------DRUM-----------
DRUM 
 MOVE.B #7,SL
 EOR.B #%11011000,NOG

 MOVE.B NOG,SD
 MOVE.B #6,SL

 MOVE.B 19(A1),SD
 SUBQ.B #1,19(A1)

 MOVE.B #5,SL
 MOVE.B 32(A2),SD
 MOVE.B #4,SL
 MOVE.B 19(A1),D0
 ASL.B #7,D0
 MOVE.B D0,SD
 RTS

;4 DRUM
;5--1280--WARB CONSTANT VOLUME
WB1 MOVE.B #5,4(A1)

;6--1536-----WARB UP---------
WRP 
 LSR 20(A1)
 CMP #60,20(A1)
 BGT PLAP
 MOVE 6(A1),20(A1)
 LSR 20(A1)
PLAP RTS

;7--1792---SLIDE-UP--WARBLE
SLW MOVE.B #45,4(A1)
 SUBQ.W #2,6(A1)
 BRA.S WRP


;8--2048---SLIDE UP VIB
SLR CMP.B #16,4(A1)
 BLT.S PES
 cmp.b #25,4(a1)
 bgt.s pes

 addq.W #5,20(A1)
PES rts BRA VIB

;9--2304-------HOLD----------
HOLD  SUBQ.B #1,4(A1)
 RTS

;10--2048---SLIDE DOWN VIB
SLIP CMP.B #11,4(A1)
 BLT.S PUS
 ADDQ.W #1,6(A1)
PUS BRA VIB





;\\\\\\\\\\\\\\DATAS\\\\\\\\\\\\\\\
;\\NOTE 1ST WORD. DURATION 2ND WORD
;\\\LEAD

 EVEN
;\\\MIDDLE
PNT1 DC.W 0
 DC.W 1       ;EFFECT & DURATION 2(A1)
 DC.B 0,0
 DC.L 0
 DC.B 9,2,3
 DC.B 1       ;ADD  13(A1)
 DC.W 3       ;VIB LIMIT
 DC.W 4       ;VIB ADD 16(A1)
 DC.W 0       ;VIB 18(A1)
 DC.L 0       ;TEMP NOTE 20(A1)
 DC.B 1,1     ;VIB RATE  24)A1)
 DC.B 0,0     ;INITIAL VOL
;ADSR  28(A1)
 DC.B 15,15,15,14,13,12,15,15,14,14
 DC.B 13,12,11,11,10,10,10,10,10,10
 DC.B 12,12,11,11,10,9,8,7,9,7,10,7,11,10,10,9,10
 DC.B 9,8,7,6,5,4,3,2,1
 REPT 90
 DC.B 1
 ENDR

 EVEN
;\\\BASS
PNT2 DC.W 0
 DC.W 1          ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0          ;6
 DC.B 10,4,5     ;10(A1) VOL REG
 DC.B 2          ;ADD TO NOTE 13(A1)
 DC.W 12          ;VIB LIMIT
 DC.W 3          ;VIBRATO ADD 16(A1)
CC DC.W 2       ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 2,2        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
ADSR
 DC.B 15,14,13,11,14,13,13,13,13,13
 DC.B 13,13,12,12,11,11,10,10,10,9
 DC.B 8,7,6,5,4,3,4,2,1

 REPT 80
 DC.B 1
 ENDR

 EVEN
PNT3 DC.W 0
NP3 DC.W 1      ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0          ;6
 DC.B 10,6,11    ;10(A1) VOL REG
 DC.B -1         ;ADD  13(A1)
 DC.W 5          ;VIB LIMIT
 DC.W 2          ;VIBRATO ADD 16(A1)
 DC.W 0          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
 DC.B 15,14,15,13,11,9
 DC.B 7,5,8,7,5,3,1,1,1
 DC.B 1,1,1,1,1,1,1,1,1,1
 
 REPT 	80
 DC.B 1
 ENDR

 EVEN
PNT4 DC.W 0
NP4 DC.W 1      ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0
 DC.B 8,0,1      ;10(A1) VOL REG
 DC.B 0          ;ADD 13(A1)
 DC.W 12          ;VIB LIMIT
 DC.W 6          ;VIBRATO ADD 16(A1)
 DC.W 0          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
 DC.B 14,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
 DC.B 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
 DC.B 13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13
 DC.B 11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11
 DC.B 9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9
 DC.B 8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
 DC.B 8,8,8,9,9,9,10,10,10,10,10
 DC.B 11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11
 DC.B 12,13,14,15,14,13,12,11,10
 DC.B 12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12
 DS.B 20
 EVEN

MC DC.B 1,1
MIN DC.B 1,0
DED
 EVEN



;MUSIC DATA

;-----------MUSIC DATA
_NOTE0 
 DC.W 162*Q,32
 DC.W 64*Q,32
 DC.W 40*Q,32
 DC.W 81*Q,32
 DC.W $FFFF,$FFFF

_NOT DC.W 2,8
_NOTE1 
 DC.W 0,16
 DC.W 128*Q,32
 DC.W 81*Q,32
 DC.W 64*Q,32
 DC.W 108*Q,16

 DC.W $FFFF,$FFFF

;TUNE  DON'T LOOK SO SAD
V1 
 DC.W 0,64+16
 DC.W 162*Z,16,144*Z,16,128*Z,16

 DC.W $FFFF,$FFFF
 
V2 
 DC.W 144*Z,64,0,64
 DC.W $FFFF,$FFFF


; I KNOW IT'S OVER
V3
 DC.W 0,64+16
 DC.W 121*Z,16,128*Z,16,144*Z,16
 DC.W $FFFF,$FFFF
V4 
 DC.W 162*Z,16
 DC.W 128*Z,64
 DC.W 0,256
 DC.W $FFFF,$FFFF

;AND THIS OLD WORLD JUST KEEPS ON TURNING
;AMIN
B1
 DC.W 144*Z,64,2,16
 DC.W 144*Z,16,144*Z,16,121*Z,16
 DC.W $FFFF,$FFFF
;D

B2    
 DC.W 128*Z,16,144*Z,64

;JUST KEEPS ON
 DC.W 217*Z,16,172*Z,16,144*Z,16
 DC.W $FFFF,$FFFF
;G

B3 ;TURNING
 DC.W 121*Z,16
 DC.W 128*Z,64
 DC.W 0,64
 DC.W $FFFF,$FFFF



 

arpamin
 DC.W 144*Q,16
 DC.W 96*Q,16
 DC.W 60*Q,16 
 DC.W 72*Q,16
 DC.W 47*Q,16
 DC.W 60*Q,16 
 DC.W 72*Q,16
 DC.W 96*Q,16
 DC.W $FFFF,$FFFF


ARPAM1 
 DC.W 96*Q,32
 DC.W 72*Q,32
 DC.W 60*Q,32 
 DC.W 96*Q,32
 DC.W $FFFF,$FFFF

ARPDMIN
 DC.W 108*Q,16
 DC.W 72*Q,16
 DC.W 53*Q,16
 DC.W 72*Q,16
 DC.W 42*Q,16
 DC.W 53*Q,16
 DC.W 72*Q,16
 DC.W 108*Q,16
 DC.W $FFFF,$FFFF

ARPDM1
 DC.W 108*Q,16
 DC.W 53*Q,16
 DC.W 42*Q,16
 DC.W 72*Q,16
 DC.W $FFFF,$FFFF 




DRMM 
 DC.W 2,32+1024,6,4+768,2,28+1024
 DC.W $FFFF,$FFFF


