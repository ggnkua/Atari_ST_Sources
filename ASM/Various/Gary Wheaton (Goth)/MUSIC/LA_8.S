; this is Gary Wheaton music driver
; the tune will play during the vertical blank.
; the slot chosen in the v/b queue is fairly high up
; which means that it is immune from interference
; this code is copyright Gary Wheaton  Aug 1989
; Gary Wheaton and the Shapeshifters are members
; of the Budgie UK group.
; Budgie UK Licenceware: the fairer face of PD

* LA.S   Oct 89

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

	movem.l	$ff8240,d0-d7 save palette
	movem.l	d0-d7,palette

	clr.l	$200
	not.l	$200		on/off switch
	bclr 	#0,$484		no keyclick
	bclr 	#1,$484		no repeat key

	dc.w	$a000
	MOVEA.L	8(A0),A0
	CLR.W	(A0)
	DC.W	$A00A		hidemouse



	MOVE.L #VBI,$4de	further down the queue to avoid gem etc.


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
	MOVE.L	A0,-(SP)  
	MOVE.W	#6,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP


getkey	move.w	#$07,-(sp)
	trap	#1
	addq.l	#2,sp
	andi.w	#$df,d0

	move.w	res,-(A7)	
	MOVE.L	$44e,-(A7)	-1=ignore physbase
	MOVE.L	$44e,-(A7)	-1=ignore logbase
	MOVE.W	#5,-(A7)
	TRAP	#14		
	LEA	$0C(A7),A7	
	
	movem.l	palette,d0-d7
	movem.l	d0-d7,$ff8240

superout
 	MOVE.L SUPER,-(SP)
 	MOVE.W #$20,-(SP)
 	TRAP #1
 	ADDQ.L #6,SP

quit
 	MOVE.W #0,-(SP)
 	MOVE.L #1024*6,-(SP)
 	MOVE.W #$31,-(SP)
 	TRAP #1

res	dc.w 	0
palette ds.w	16

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

E EQU 1
F EQU 2
P EQU 1792
R equ 512
J EQU 8
I EQU 4
H EQU 16
W EQU 1
X EQU 8
T EQU 4
Q EQU 8
Z EQU 4
U EQU 2
O EQU 2

SL EQU $FF8800
SD EQU $FF8802

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


 	ADD.B #135,HIT		slow down
 	BCC tth
***
 MOVE.L UPTO,A2
 MOVE CUNT,D3
 MOVE.B 33(A2),D4
SSU SUBQ.W #1,D3
 BPL.S PART1
 MOVE.L #2,PNT0
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
;--END OF VBI


****
tth
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
;EVEN


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



*-----------------
handle	dc.w 0
name	dc.b "a:\music\budgie3.pi1",0
	even
*---------


SUPER DC.L 0
HIT DC.B 0,0

UPTO DC.L EE-38
CUNT DC.W 0
 EVEN
;\\RUNNING ORDER SEQUENCE

EE
DOTH
 DC.L PNT4,_NOTE0        
 DC.L PNT1,_NOTE0
 DC.L PNT2,_NOTE0
 DC.L PNT3,DRMM
 DC.B 1,%00001110
 DC.W 127
 DC.W 8


 DC.L PNT4,_NOTE0        
 DC.L PNT1,DI1  _NOTE0
 DC.L PNT2,_NOTE0
 DC.L PNT3,DRMM
 DC.B 4,%00011110
 DC.W 127
 DC.W 8


 DC.L PNT4,_NOTE2        
 DC.L PNT1,_NOTE2
 DC.L PNT2,_NOTE0
 DC.L PNT3,DRMM
 DC.B 3,%00011110
 DC.W 255
 DC.W 1

 DC.L PNT4,_NOTE0        
 DC.L PNT1,di1 _NOTE0
 DC.L PNT2,_NOTE0
 DC.L PNT3,DRMM
 DC.B 1,%00001110
 DC.W 255
 DC.W 8


 DC.L PNT4,TUNE        
 DC.L PNT1,DI1 
 DC.L PNT2,_NOTE0
 DC.L PNT3,DRMM
 DC.B 2,%00011110
 DC.W 511
 DC.W 0

 DC.L PNT4,BASSW        
 DC.L PNT1,di1
 DC.L PNT2,BASSW
 DC.L PNT3,DRMM
 DC.B 1,%00001110
 DC.W 127
 DC.W 8

 DC.L PNT4,_NOTE0        
 DC.L PNT1,_NOTE0
 DC.L PNT2,DI
 DC.L PNT3,_NOTE0
 DC.B 1,%00001110
 DC.W 63
 DC.W 8

 DC.L PNT4,BASSW        
 DC.L PNT1,BASSW
 DC.L PNT2,DI
 DC.L PNT3,DRMM
 DC.B 1,%00001110
 DC.W 255
 DC.W 8




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
 DC.L SLR,LIL,LIL,RSE,SLY,SLY
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
 ASL 20(A1)
 CMP #800,20(A1)
 BLT.S PLOP
 MOVE 6(A1),20(A1)
PLOP  RTS

;3--768--------DRUM-----------
DRUM 

 ;SUBQ.B #8,19(A1)
 MOVE.B #7,SL
 MOVE.B #%11011000,SD
 MOVE.B #6,SL
 MOVE.B 19(A1),SD
 MOVE.B #5,SL
 MOVE.B 32(A2),SD
 MOVE.B #4,SL
 MOVE.B 19(A1),D0
 ASL.B #5,D0
 MOVE.B D0,SD
JUNK RTS

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
PES RTS BRA VIB WARB



;9--2048---SLIDE DOWN VIB
SLIP CMP.B #11,4(A1)
 BLT.S PUS
 ADDQ.W #1,6(A1)
PUS BRA VIB

;10--2304-------HOLD----------
HOLD  SUBQ.B #1,4(A1)
 RTS


;11 2560
LIL MOVE.B #20,4(A1)
 BRA WARB

;12--2816 RAIS
RSE MOVE.B #17,4(A1)
 CMP #217*2,20(A1)
 BLT.S TXAS
 SUB.W #12,20(A1)
 RTS

TXAS MOVE #217*2,20(A1)
 RTS

;13--3072---SLIDE UP VIB
SLY CLR D1
 MOVE.B 4(A1),D1
 CMP.B #30,D1
 BLT.S PWS
 MOVE.B #30,4(A1)
 ADDQ.W #2,6(A1)
PWS BRA WARB



;\\\\\\\\\\\\\\DATAS\\\\\\\\\\\\\\\
;\\NOTE 1ST WORD. DURATION 2ND WORD
;\\\LEAD
PNT0 DC.W 0
NP0 DC.W 1
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
 DC.W 12          ;VIB LIMIT
 DC.W 3          ;VIBRATO ADD 16(A1)
CC DC.W 2       ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 2,2        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
ADSR
 DC.B 15,15,14,14,13,13,14,14,12,12
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
 DC.B 15,15,14,12,10,9
 DC.B 7,5,4,3,2,1,1,1,1,1
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



;MUSIC DATA

;-----------MUSIC DATA

_NOTE0 
 DC.W 217*Q,16,144*Q,8
 DC.W 162*Q,8,162*Q,8,144*Q,24
 DC.W $FFFF,$FFFF

_NOTE1 DC.W 2,2
 DC.W $FFFF,$FFFF


_NOTE2 
 DC.W 144*T,16,91*T,8,81*T,8,72*T,16
 DC.W 53*T,16,68*T,8,72*T,8,81*T,32

 DC.W 72*T,8,81*T,8,91*T,16,108*T,16
 DC.W 96*T,8,108*T,8,121*T,16,108*T,48+16
 DC.W $FFFF,$FFFF

DRMM 
 DC.W 0,16+1024
 DC.W 8,4+768
 DC.W 0,4+1024
 DC.W 4,2+768
 DC.W 0,6+1024

 DC.W 0,16+1024
 DC.W 31,8+768
 DC.W 0,8+1024

 DC.W $FFFF,$FFFF


BASSW
 DC.W 217*Q,16,144*Q,8
 DC.W 162*Q,8,162*Q,8,144*Q,16

 DC.W 162*Q,8,162*Q,8,144*Q,8
 DC.W 162*Q,8,144*Q,8
 DC.W 162*Q,8,144*Q,16
 DC.W 144*Q,8
 
 DC.W $FFFF,$FFFF


DI 
 DC.W 108,8+2560,2,8
 DC.W 72,8+2560,2,8
 DC.W 72,8+2560,2,8
 DC.W 72,8+2560,2,8

 DC.W 108,8+2560,2,8
 DC.W 72,8+2560,2,8
 DC.W 72,8+2560,2,8
 DC.W 72,8+2560,2,8

 DC.W 108,8+2560,2,8
 DC.W 72,8+2560,2,8
 DC.W 72,8+2560,2,8
 DC.W 72,8+2560,2,8

 DC.W 108,8+2560,2,8
 DC.W 2,255
 DC.W $FFFF,$FFFF


DI1 
 DC.W 108,8+2560,2,8
 DC.W $FFFF,$FFFF


NULL DC.W 2,255
 DC.W $FFFF,$FFFF

TUNE 
 DC.W 144*E,16+R,91*E,8+R,81*E,8+R,72*E,16+R
 DC.W 53*E,16+R,68*E,8+R,72*E,8+R,81*E,32+R

 DC.W 72*E,8+R,81*E,8+R,91*E,16+R,108*E,32+R
 DC.W 72*E,8+R,81*E,8+R,91*E,16+R,108*E,32+R	
 DC.W 72*E,8+R,81*E,8+R,91*E,16+R,108*E,16+R
 DC.W 96*E,8+R,108*E,8+R,121*E,16+R
 DC.W 108*E,64+3072
 DC.W 2,255
 DC.W $FFFF,$FFFF




