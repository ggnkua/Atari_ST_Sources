;            more music drivers by G.W   Budgie UK
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

	clr.l	$200
	clr.l	$4de

setlowrez
	CLR.W	-(A7)		0=low res
	MOVE.L	$44e,-(A7)	-1=ignore physbase
	MOVE.L	$44e,-(A7)	-1=ignore logbase
	MOVE.W	#5,-(A7)
	TRAP	#14		
	LEA	$0C(A7),A7	


* load a degas picture at a specific address 
	MOVE.W	#0,-(A7)
	MOVE.L	#name,-(A7)	budgie3.pi1
	MOVE.W	#$3D,-(A7)
	TRAP	#1
	MOVE.W	D0,handle
	move.l	$44e,d0		load direct to current screen
	sub.l	#34,d0
	MOVE.L	d0,-(sp) 
	MOVE.L	#32066,-(A7)	read it
	MOVE.W	HANDLE,-(A7)
	MOVE.W	#$3F,-(A7)
	TRAP	#1
	ADDA.L	#$C,A7

	MOVE.W 	handle,-(SP)	close
	MOVE.W 	#$3E,-(SP)
	TRAP 	#1
	ADDQ.L 	#4,SP

	move.l	$44e,a0
	sub.l	#32,a0		palette
	MOVEM.L	D0-D2/A0-A2,-(SP)
	MOVE.L	A0,-(SP)  
	MOVE.W	#6,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP
	MOVEM.L	(SP)+,D0-D2/A0-A2

	bset	#0,quiet_flag	assume we play
	move.l	#1,$200		assume we play

; $200    0=no play    1=play

 MOVE.L #VBI,$4de	further down the queue to avoid gem etc..

getkey	MOVE.W	#$07,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	ANDI.W	#$DF,D0		force upper case


 MOVE.L SUPER,-(SP)
 MOVE.W #$20,-(SP)
 TRAP #1
 ADDQ.L #6,SP

 MOVE.W #0,-(SP)
 MOVE.L #1024*6,-(SP)
 MOVE.W #$31,-(SP)
 TRAP #1

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
J EQU 16
I EQU 4
H EQU 16
W EQU 1
X EQU 16
T EQU 8
Q EQU 2
Z EQU 8
U EQU 2
O EQU 2

SL EQU $FF8800
SD EQU $FF8802
 move.b #7,sl
 move.b #%11111000,sd


*------------------------
vbi             
	movem.l d0-d7/a0-a6,-(sp)
	lea	$200,a0
	tst.l	(a0)
	beq	quiet
	bset	#0,quiet_flag	ok play
*------------------
 MOVE.L UPTO,A2
 MOVE CUNT,D3
 MOVE.B 33(A2),D4
SSU SUBQ.W #1,D3
 BPL.S PART1
 MOVE.L #1,PNT0
 MOVE.L #1,PNT1
 MOVE.L #1,PNT2
 MOVE.L #1,PNT3
 MOVE.L #1,PNT4

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

*------------------------

TTH
	movem.l (sp)+,d0-d7/a0-a6
 RTS
quiet	
	btst	#0,quiet_flag
	beq	tth		out
	bclr	#0,quiet_flag
	lea	silence,a0
	bsr	dosound

	movem.l (sp)+,d0-d7/a0-a6
	rts
*---------------


UPTO DC.L EE-38
CUNT DC.W 0
 EVEN
;\\RUNNING ORDER SEQUENCE
EE
 DC.L PNT4,NULL      
 DC.L PNT1,_NOTE2
 DC.L PNT2,NULL
 DC.L PNT3,DROM
 DC.B 1,%0011000
 DC.W 64
 DC.W 0

 DC.L PNT4,_NOTE2      
 DC.L PNT1,_NOTE2
 DC.L PNT2,_Note2
 DC.L PNT3,DRMM
 DC.B 1,%0001110
 DC.W 128*2
 DC.W 0

DOTH
 DC.L PNT4,NT      
 DC.L PNT1,_NOTE2
 DC.L PNT2,NULL
 DC.L PNT3,DRMM
 DC.B 1,%0011110
 DC.W 128
 DC.W 4

 DC.L PNT4,NT1      
 DC.L PNT1,_NOTE2
 DC.L PNT2,_NOTE2
 DC.L PNT3,DRMM
 DC.B 1,%0011110
 DC.W 128
 DC.W 0

 DC.L PNT4,NT2      
 DC.L PNT1,_NOTE2
 DC.L PNT2,_NOTE2
 DC.L PNT3,DRMM
 DC.B 1,%0011110
 DC.W 128
 DC.W 0



;
 DC.L PNT4,TUN      
 DC.L PNT1,BAS1 _NOTE2
 DC.L PNT2,TUN
 DC.L PNT3,DRM
 DC.B 1,%0011110
 DC.W 128
 DC.W 0

 DC.L PNT4,TUN      
 DC.L PNT1,BAS1 _NOTE2
 DC.L PNT2,TIN
 DC.L PNT3,DRM
 DC.B 1,%0011110
 DC.W 128
 DC.W 0

 DC.L PNT4,TUN1     
 DC.L PNT1,BAS1
 DC.L PNT2,TUNA
 DC.L PNT3,DRM
 DC.B 1,%0011110
 DC.W 128*2
 DC.W 0

;MID
 DC.L PNT4,SLID      
 DC.L PNT1,_NOTE2
 DC.L PNT2,SLID
 DC.L PNT3,DRMM
 DC.B 1,%0011110
 DC.W 128*2
 DC.W 1

 DC.L PNT4,SLID      
 DC.L PNT1,_NOTE2 
 DC.L PNT2,SWIP _NOTE2
 DC.L PNT3,ROLL  
 DC.B 1,%0011110
 DC.W 128*2
 DC.W 0


 DC.L PNT1,WIZ      
 DC.L PNT0,WIZ
 DC.L PNT2,WIZ
 DC.L PNT3,DROM
 DC.B 0,%0011010
 DC.W 128
 DC.W 0

;---
 DC.L PNT4,TUN      
 DC.L PNT1,BAS1 _NOTE2
 DC.L PNT2,TIN
 DC.L PNT3,DRMM
 DC.B 1,%0011110
 DC.W 128
 DC.B 2,0

 DC.L PNT4,TIN      
 DC.L PNT1,BAS1 _NOTE2
 DC.L PNT2,TUN
 DC.L PNT3,DRMM
 DC.B 10,%0011110
 DC.W 128
 DC.B 1,0

 DC.L PNT4,TUN1     
 DC.L PNT1,BAS1
 DC.L PNT2,TUNA
 DC.L PNT3,DRMM
 DC.B 7,%0011110
 DC.W 128*2
 DC.B 0,0


;------SKID
 DC.L PNT4,_NOTE0      
 DC.L PNT1,_NOTE2
 DC.L PNT2,NULL
 DC.L PNT3,ROLL
 DC.B 1,%0011000
 DC.W 128+16
 DC.W 0

 DC.L PNT4,SKID      
 DC.L PNT1,SKID1
 DC.L PNT2,SKID2
 DC.L PNT3,DRMM
 DC.B 1,%0000010
 DC.W 64
 DC.W 0

 DC.L PNT4,HIY      
 DC.L PNT2,HIY
 DC.L PNT1,NULL
 DC.L PNT3,DRMM
 DC.B 1,%0001010
 DC.W 256
 DC.B 2,0

 DC.L PNT4,HIY      
 DC.L PNT2,HIY
 DC.L PNT1,NULL
 DC.L PNT3,ROLL
 DC.B 1,%0010010
 DC.W 256
 DC.B 2,0

 DC.L PNT4,NULL   TUN      
 DC.L PNT1,BAS1 _NOTE2
 DC.L PNT2,NULL
 DC.L PNT3,DRMM
 DC.B 1,%00110110
 DC.W 256
 DC.B 0,0


;-----------------------
 DC.L PNT1,_NOTE2      
 DC.L PNT4,SLID
 DC.L PNT2,NULL
 DC.L PNT3,ROLL
 DC.B 1,%0011110
 DC.W 128*4
 DC.B 0,0


 DC.L PNT1,WIZ      
 DC.L PNT0,WIZ
 DC.L PNT2,WIZ
 DC.L PNT3,DRAM
 DC.B 1,%0011110
 DC.W 160-32
 DC.W 0

CHAN0
;\\\\\\\\\\\\\\\\\\\\\\
 SUBQ.B #1,3(A1)  ;NOTE STILL ON
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
 MOVE.B 36(A2),D0        ;STANDING EFFECT
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
 DC.L SLR,VIB,SLIP,VIB
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
VIB CMP.B #8,4(A1)
 BLT SDC
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
SDC RTS
RIST NEG 16(A1)
 BRA.S SAZ
;2-512------WARB DW-----------
WARB
 EOR.B #1,MIN
 BEQ SAX
 SUBQ.B #1,4(A1)
SAX ASL 20(A1)
 CMP #660,20(A1)
 BLT.S PLOP
 MOVE 6(A1),20(A1)
PLOP ;BRA VV
 RTS
;3--768--------DRUM-----------
DRUM SUBQ.B #4,19(A1)
 MOVE.B #7,SL
 MOVE.B #%11011000,SD
 MOVE.B #6,SL
 MOVE.B 19(A1),SD
 MOVE.B #5,SL
 MOVE.B 32(A2),SD
 MOVE.B #4,SL
 MOVE.B #255,SD
 RTS

;4 DRUM
;5--1280--WARB CONSTANT VOLUME
WB1 MOVE.B #5,4(A1)
 BRA.S SAX
;6--1536-----WARB UP---------
WRP EOR.B #1,MIN+1
 BEQ SDX
 SUBQ.B #1,4(A1)
SDX LSR 20(A1)
 CMP #35,20(A1)
 BGT PLAP
 MOVE 6(A1),20(A1)
PLAP BRA VV ;RTS
;7--1792---SLIDE-UP--WARBLE
SLW CMP.B #17,4(A1)
 BLT.S WRP
 SUBQ.W #3,6(A1)
 BRA.S WRP

;8--2048---SLIDE UP VIB
SLR ;EOR.B #1,FIG
 ;BEQ.S PES
 CMP.B #3,4(A1)
 BLT.S PES
 SUBQ.W #1,20(A1)
PES RTS 

FIG DC.B 0,0
;9--2304-------HOLD----------
HOLD  SUBQ.B #1,4(A1)
 RTS

;10--2048---SLIDE DOWN VIB
SLIP ;CMP.B #1,4(A1)
 ;BLT.S PUS
 ADD.W #90,20(A1)
PUS     BRA VIB


;\\\\\\\\\\\\\\DATAS\\\\\\\\\\\\\\\
;\\NOTE 1ST WORD. DURATION 2ND WORD
;\\\LEAD
PNT0 DC.W 0
 DC.W 1
 DC.W 0
 DC.L 0
 DC.B 8,0,1
 DC.B 0      ;ADD TO NOTE
 DC.W 6      ;VIB LIMIT
 DC.W 3      ;16(A1)  ADD
 DC.W 0      ;VIB 18(A1)
 DC.L 0      ;TMP NOTE 20(A1)
 DC.B 1,1    ;VIB RATE 24(A1)
 DC.B 0,0    ;INITIAL VOL
;ADSR  28(A1)
 DC.B 15,15,14,13,12,11,9,8,9
 DC.B 10,12,10,8,10,12,10,8,10,10
 DC.B 11,10,10,9,8,7,5,5,6,7,7
 DC.B 6,5,4,3,2,1 
 REPT 70
 DS.B 1
 ENDR

 EVEN
;\\\MIDDLE
PNT1 DC.W 0
 DC.W 1       ;EFFECT & DURATION 2(A1)
 DC.B 0,0
 DC.L 0
 DC.B 9,2,3
 DC.B 1       ;ADD  13(A1)
 DC.W 6       ;VIB LIMIT
 DC.W 2       ;VIB ADD 16(A1)
 DC.W 0       ;VIB 18(A1)
 DC.L 0       ;TEMP NOTE 20(A1)
 DC.B 1,1     ;VIB RATE  24)A1)
 DC.B 0,0     ;INITIAL VOL
;ADSR  28(A1)
 DC.B 15,15,15,14,14,13,13,13,12,12
 DC.B 11,11,11,11,10,10,10,10,10,10
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
 DC.W 6          ;VIB LIMIT
 DC.W 2          ;VIBRATO ADD 16(A1)
 DC.W 2       ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 2,2        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
 DC.B 15,15,14,14,14,13,13,13,13,13
 DC.B 13,13,12,12,11,11,10,10,10,9
 DC.B 8,7,6,5,4,3,4,2,1

 REPT 80
 DC.B 1
 ENDR

 EVEN
PNT3 DC.W 0
 DC.W 1      ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0          ;6
 DC.B 10,6,11    ;10(A1) VOL REG
 DC.B -1         ;ADD  13(A1)
 DC.W 10         ;VIB LIMIT
 DC.W 4          ;VIBRATO ADD 16(A1)
 DC.W 0          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
 DC.B 15,15,15,14,13,12
 DC.B 11,10,9,8,7,5,3,1,1,1
 DC.B 1,1,1,1,1,1,1,1,1,1
 
 REPT 	80
 DC.B 1
 ENDR

 EVEN
PNT4 DC.W 0
 DC.W 1      ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0
 DC.B 8,0,1      ;10(A1) VOL REG
 DC.B 0          ;ADD 13(A1)
 DC.W 5          ;VIB LIMIT
 DC.W 3          ;VIBRATO ADD 16(A1)
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



;-----------MUSIC DATA
_NOTE0 
 DC.W 108*Q,32+e,102*Q,32+e,108*Q,64+e

NT
 DC.W 144*Q,32+E,108*Q,32+E,81*Q,48+e,76*Q,16+e

NT1
 DC.W 108*Q,32+e,102*Q,32+e,108*Q,64+e


NT2
 DC.W 144*Q,32+e,108*Q,30+e
 DC.W 81*Q,46+e,68*Q,15+e,102*Q,6+e
 DC.W $FFFF,$FFFF



_NOTE2 
 DC.W 108*T,8,91*T,8,96*T,8,102*T,8
 DC.W 108*T,8,217*T,8,204*T,8,102*T,8
 DC.W 193*T,8,96*T,8,204*T,8,102*T,8
 DC.W 108*T,8,217*T,8,193*T,8,96*T,8

 DC.W $FFFF,$FFFF

DRMM DC.W 31,8+768,0,8+1024
 DC.W 8,8+768,0,24+1024
 DC.W 8,8+768,0,8+1024
 DC.W 31,8+768,0,8+1024
 DC.W 8+768,8,31,8+768,0,8+1024
 DC.W 31,8+768,8,8+768,0,8+1024
 DC.W $FFFF,$FFFF 

NULL DC.W 2,68
 DC.W $FFFF,$FFFF

DROM 
 DC.W 9,2+768,0,2+1024
 DC.W 7,2+768,0,2+1024
 DC.W 5,2+768,0,2+1024
 DC.W $FFFF,$FFFF

DRIM 
 DC.W 8,8+768,0,24+1024
 DC.W 8,8+768,0,24+1024
 DC.W $FFFF,$FFFF

DRAM 
 DC.W 12,8+768,0,24+1024
 DC.W $FFFF,$FFFF

DRM
 DC.W 8,8+768,0,8+1024
 DC.W 14,8+768,0,8+1024
 DC.W $FFFF,$FFFF




WIZ1 DC.W 2,4
wiz 
 DC.W 217*X,8,108*X,8
 DC.W 193*X,8,96*X,8
 DC.W 182*X,8,91*X,8
 DC.W 162*X,8,81*X,8
 DC.W 153*X,8,76*X,8
 DC.W 144*X,8,72*X,8
 DC.W 128*X,8,64*X,8
 DC.W 121*X,8,60*X,8
 ;DC.W 114*X,8,57*X,8
 ;DC.W 108*X,8,53*X,8

TIN DC.W 0,4
TUN
 DC.W 2,8,121*O,8,108*O,8,144*O,8
 DC.W 121*O,8,108*O,8,2,8
 DC.W 108*O,8
 DC.W 81*O,8,85*O,8
 DC.W 108*O,8,121*O,8
 DC.W 85*O,8,2,8,121*O,8
 DC.W 2,16
 DC.W $FFFF,$FFFF

TUNA DC.W 1,22
TUN1
 DC.W 72*U,16,85*U,16,121*U,16
 DC.W 144*U,16,108*U,64+256

 DC.W 2,16,85*U,16,121*U,16
 DC.W 144*U,16,108*U,24+256  ;128-48
 DC.W 85*U,8,108*U,48
 DC.W $FFFF,$FFFF

WOO DC.W 108,128+2560
WIN DC.W 108*Q,128

SKID1 DC.W 1,1
SKID2 DC.W 1,1
SKID
 DC.W 108*Q,96+256
 DC.W $FFFF,$FFFF

ROLL DC.W 31,16+768,4,8+768 
 DC.W 0,24+1024
 DC.W 31,16+768,20,16+768
 DC.W 31,8+768,20,16+768
 DC.W 8,8+768,8,8+768,8,8+768
; DC.W 31,8+768,20,16+768
 DC.W $FFFF,$FFFF

HIY
 DC.W 108*W,8,108*W,8,108*W,16
 DC.W 72*W,8,72*W,8,72*W,16
 DC.W 96*W,8,91*W,8,91*W,16+32

 DC.W 182*T,8,91*T,8,182*T,8,91*T,8
 DC.W 162*T,8,81*T,8,162*T,8,81*T,8
 DC.W 217*T,8,108*T,8,217*T,8,108*T,8

 DC.W 217*T,8,108*T,8
 DC.W 217*T,8,108*T,12
 DC.W $FFFF,$FFFF 


BAS1
 DC.W 217*T,8,108*T,8
 DC.W $FFFF,$FFFF 

SLID DC.W 2,128 
 DC.W 108*W,16+2048
 DC.W 108*W,16+2048
 DC.W 108*W,16+2048
 DC.W 108*W,16+2048
 DC.W 108*W,16+2048
 DC.W 108*W,16+2048
 DC.W 108*W,16+2048
 DC.W 2,15
 DC.W $FFFF,$FFFF

SWIP DC.W 2,128 
 DC.W 2,16
 DC.W 108*W,32+2048
 DC.W 108*W,32+2048
 DC.W 108*W,20+2048
 DC.W 2,12
 DC.W $FFFF,$FFFF  




*-----------------
quiet_flag	
	dc.b	0
	even

 DC.B "  G.WHEATON. 45 GOLDRILL AVE, BOLTON, LANCS, U.K. "

super 	dc.l 	0
handle	dc.w	0
name	dc.b	"budgie3.pi1",0
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

