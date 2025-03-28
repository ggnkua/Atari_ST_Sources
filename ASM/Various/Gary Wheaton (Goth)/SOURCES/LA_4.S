* max.s  oct 89  music from Galaxia
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



 move #$700,$ff8240+20

 move.b #7,sl
 move.b #%11111000,sd

 move.l $44e,a0
 add.l #160*169,a0
 move.l a0,skreen


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
skreen	dc.l 	0
***

 move #$5,$ff8240+20

 move.l $44e,a0
 add.l #160*169,a0
 move.l a0,skreen


;1 VIBRATO		256
;2 WARBUP		512
;3 DRUM			768
;4 HOLD			1024
;5 WARBHOLD		1280
;6 WARBDWN		1536
;7 SLIDE UP WITH WARB   1792
;8 SLIDE UP           	2048
;9			2304
;10			2560

e equ 2
J EQU 8
I EQU 4
H EQU 2
T EQU 1
A EQU 2
Q EQU 8
Z EQU 2
f EQU 8
C EQU 1


SL EQU $FF8800
SD EQU $FF8802
 move.b #7,sl
 move.b #%11111000,sd

****


VBI  movem.l d0-d7/a0-a6,-(sp)

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

	LEA TAB,A3
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
 MOVE.L #$8000000,SL

 ADD.L #36,a2
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
W2 MOVEQ.B #1,D2
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

 BSR SHOWBAR

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




 DC.B " (C) G.WHEATON.  45 GOLDRILL AVE BOLTON. LANCS, U.K. "



UPTO DC.L EE-36
CUNT DC.W 0
 EVEN
;\\RUNNING ORDER SEQUENCE
EE
DOTH

 DC.L PNT4,cow1
 DC.L PNT0,cow1
 DC.L PNT2,null y2
 DC.L PNT3,sdum DRSM
 DC.B 0,%00011100
 DC.W 511

 DC.L PNT4,YI
 DC.L PNT1,cow1
 DC.L PNT2,y2
 DC.L PNT3,DRSM
 DC.B 0,%00011110
 DC.W 511

 DC.L PNT4,Y3
 DC.L PNT1,Y2
 DC.L PNT2,YI
 DC.L PNT3,DRSM
 DC.B 2,%00111110
 DC.W 1023

 DC.L PNT4,Y3
 DC.L PNT1,Y3+4
 DC.L PNT2,Y3+8
 DC.L PNT3,DRMM
 DC.B 1,%00001110
 DC.W 1023

 DC.L PNT4,YI
 DC.L PNT1,YI+8
 DC.L PNT2,YI
 DC.L PNT3,SDUM
 DC.B 2,%00011110
 DC.W 511


 DC.L PNT4,Y2
 DC.L PNT1,Y2+8
 DC.L PNT2,RF2 Y2
 DC.L PNT3,SDUM
 DC.B 2,%00111110
 DC.W 1023

;EE
;DOTH
 DC.L PNT4,T2
 DC.L PNT0,RF2
 DC.L PNT2,t2+4
 DC.L PNT3,DRSM
 DC.B 1,%00011110
 DC.W 511

 DC.L PNT0,T2
 DC.L PNT4,RF3
 DC.L PNT2,t2d
 DC.L PNT3,DRSM
 DC.B 1,%00011110
 DC.W 511+511




;part 2
 DC.L PNT4,rigel
 DC.L PNT1,bas
 DC.L PNT2,DRIFT
 DC.L PNT3,DRYM
 DC.B 1,%00111110
 DC.W 127

 DC.L PNT4,raz1
 DC.L PNT1,t2
 DC.L PNT2,t2
 DC.L PNT3,DRSM
 DC.B 1,%00011110
 DC.W 511


 DC.L PNT4,RAZ
 DC.L PNT1,RAZ2
 DC.L PNT2,NULL 
 DC.L PNT3,SDUM
 DC.B 1,%000011110
 DC.W 511

 DC.L PNT1,RAZ  TOM
 DC.L PNT4,TOM  2
 DC.L PNT2,T2
 DC.L PNT3,DRSM
 DC.B 2,%00011110
 DC.W 511


 DC.L PNT4,T2
 DC.L PNT1,no2
 DC.L PNT2,T2
 DC.L PNT3,DRMM
 DC.B 2,%00011110
 DC.W 1023

 DC.L PNT4,BAS
 DC.L PNT1,bas1
 DC.L PNT2,BAS
 DC.L PNT3,DRMM
 DC.B 2,%00011110
 DC.W 127

 DC.L PNT4,DL
 DC.L PNT1,GL
 DC.L PNT2,FL
 DC.L PNT3,DRMM
 DC.B 2,%00001110
 DC.W 255

 DC.L PNT4,YI
 DC.L PNT1,cow
 DC.L PNT2,y2
 DC.L PNT3,DRSM
 DC.B 0,%00011110
 DC.W 2047


 DC.L PNT4,rf2
 DC.L PNT0,cow
 DC.L PNT2,cow+4
 DC.L PNT3,DRSM
 DC.B 0,%00011110
 DC.W 511

CHAN0
;\\\\\\\\\\\\\\\\\\\\\\
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
 SUBQ.B #1,3(A1)    ;NP0
 BNE STILLON
 MOVE.L D1,6(A1) ;TMP0  \D1.W IS DURATION
 MOVE.L D1,20(A1);TEMP  HOLD NOTE
 MOVE.B 26(A1),4(A1)   ;VOL0
 MOVE D1,2(A1)   ;NP0  \SET NEW DURATION
 ADDQ.W #4,(A1)        ; & INC POINTER
STILLON
;\\VOLUME
RFF
;\\\\\\\\\EFFECTS\\\\\\\\\\
NV0 
 MOVE.B 2(A1),D0
 CMP.B #4,D0
 BNE DOIT
 ADDQ.B #1,4(A1)
 RTS
DOIT 

DZZ
 MOVE.B #7,SL
 MOVE.B #%11111000,SD
 BRA.S FCC
EFCT

 DC.L FINK,VIB,WARB,DRUM,FINK,WB1,WRP,SLW
 DC.L SLR,HOLD,TWERP,SLR1,inup,HOLDLOW,Half

FCC
 AND.L #15,D0
 ASL #2,D0
 MOVE.L EFCT(PC,D0),A0
 JSR (A0)

MAZ ADDQ.B #1,4(A1)          ;VOL0
 MOVE.B 11(A1),SL
 MOVE.B 21(A1),SD   ;TMP0+1
 MOVE.B 12(A1),SL
 MOVE.B 20(A1),SD   ;TMP0
 CLR D0
 MOVE.B 4(A1),D0
 MOVE.B 10(A1),SL
 MOVE.B 28(A1,D0),D2    ;VOL0
 MOVE.B D2,SD

;----------------BAR CHART SET
 MOVE 20(A1),D1
 AND #255,D1
 LSR #2,D1
 
 CMP #40,D1
 BLT.S DXIT
 SUB #40,D1 
DXIT OR.B D2,(A3,D1)      ;BAR TABLE

FINK RTS

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
 CMP #460,20(A1)
 BLT.S PLOP
 MOVE 6(A1),20(A1)
PLOP BRA.S VV
;RTS


;3--768--------DRUM-----------
DRUM 

 SUBQ.B #4,19(A1)
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

;-4--------DRUM OFF

;5--1280--WARB CONSTANT VOLUME
WB1 MOVE.B #5,4(A1)
 BRA.S SAX

;6--1536-----WARB UP---------
WRP 
 MOVE.B #17,4(A1)
SDX LSR 20(A1)
 CMP #35,20(A1)
 BGT PLAP
 MOVE 6(A1),20(A1)
PLAP BRA VV ;RTS

;7--1792---SLIDE-UP--WARBLE
SLW CMP.B #9,4(A1)
 BLT.S WRP
 ADDQ.W #2,6(A1)
 BRA.S WRP

;--2048---SLIDE UP CONST VOL 
SLR 
 CLR.B 4(A1)
 ADDq.W #6,20(A1)
 RTS

YIN DC.B 0,0
;9--2304-------HOLD-------------
HOLD MOVE.B #29,4(A1)
 RTS

;10--2560---HIGH NOTE WARB------
TWERP 
 MOVE.B #17,4(A1)
 LSR 20(A1)
 CMP #8,20(A1)
 BGT TETSYFLY
 MOVE 6(A1),20(A1)
TETSYFLY BRA VV 

;11-------2816 SLIDE UP WITH ADSR
SLR1
 SUBQ.W #6,20(A1)
 RTS

;12-------3072  inc up
inup
 sub.b #1,nije
 bne.s pod
 sub.w #4,6(a1)
 move.b #5,nije
 sub.b #6,4(a1)
pod bra wrp rts

;13-------3328--HOLD VOL LOW
HOLDLOW
 MOVE.B #32,4(A1)
 RTS 

;1--------3584 half adsr
half
 ADD.B #50,nije+1
 bCC.s aslef
 subq.b #1,4(a1)
aslef rts


nije dc.b 1,0

;\\\\\\\\\\\\\\DATAS\\\\\\\\\\\\\\\
;\\NOTE 1ST WORD. DURATION 2ND WORD
;\\\LEAD
PNT0 DC.W 0
NP0 DC.W 1
 DC.W 0
 DC.L 0
 DC.B 9,2,3
 DC.B 1      ;ADD TO NOTE
 DC.W 144      ;VIB LIMIT
 DC.W 72      ;16(A1)  ADD
 DC.W 0      ;VIB 18(A1)
 DC.L 0      ;TMP NOTE 20(A1)
 DC.B 1,1    ;VIB RATE 24(A1)
 DC.B 0,0    ;INITIAL VOL
;ADSR  28(A1)
 DC.B 15,15,14,14,13
 REPT  40
 DC.B 12
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
 DC.B 15,14,9,13,12,14,14,13,12,12
 DC.B 12,12,12,12

 REPT 190
 DC.B 10
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
ADSR
 DC.B 15,15,14,14,14,13,13,13,13,13
 DC.B 13,13,12,12,11,11,10,10,10,9
 DC.B 8,7,6,5,4,3,4,2

 REPT 180
 DC.B 3
 ENDR

 EVEN
PNT3 DC.W 0
NP3 DC.W 1      ;2(A1) DURATION
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
 DC.B 11,11,11,11,10
 DC.B 11,11,11,11,10
 

 EVEN
PNT4 DC.W 0
NP4 DC.W 1      ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0
 DC.B 8,0,1      ;10(A1) VOL REG
 DC.B 0          ;ADD 13(A1)
 DC.W 5          ;VIB LIMIT
 DC.W 7          ;VIBRATO ADD 16(A1)
 DC.W 0          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)

 DC.B 15,15,15,14,14,14,13,13
 REPT 32
 DC.B 13
 ENDR

 REPT 32
 DC.B 12
 ENDR

 REPT 32
 DC.B 11
 ENDR

 REPT 32
 DC.B 9
 ENDR

 REPT 32
 DC.B 8
 ENDR

 REPT 64
 DC.B 7
 ENDR

 EVEN
TE2 DC.W 2,3





MIN DC.B 0,0
MC DC.B 0,0
;-----------MUSIC DATA
Y3 
 DC.W 144*H,64+1536,121*H,64+1536
 DC.W 108*H,64+1536,96*H,32+1536
 DC.W 108*H,16+1536,96*H,16+1536

 DC.W 144*T,64+1536,121*T,64+1536
 DC.W 108*T,64+1536,96*T,32+1536
 DC.W 108*T,16+1536,96*T,16+1536

 DC.W 144/2,64+2560,121/2,64+2560
 DC.W 108/2,64+2560,96/2,32+2560
 DC.W 108/2,16+2560,96/2,16+2560

 DC.W 144*H,64+1536,121*H,64+1536
 DC.W 108*H,64+1536,96*H,64+1792
 DC.W 108*H,16+1536,96*H,16+1536
 DC.W $FFFF,$FFFF



Y2D DC.W 2,6
Y2
 DC.W 144*Q,8,72*Q,8,144*Q,8,72*Q,8
 DC.W 144*Q,8,72*Q,8,144*Q,8,72*Q,8

 DC.W 121*Q,16,121*Q,16,121*Q,16,121*Q,16

 DC.W 108*Q,8,217*Q,8,108*Q,8,217*Q,8
 DC.W 108*Q,8,53*Q,8,108*Q,8,53*Q,8
 
 DC.W 108*Q,16,108*Q,16,108*Q,32+2048
 DC.W $FFFF,$FFFF
  

YI
 DC.W 144*Q,8,144*Q,8,72*Q,8
 DC.W 144*Q,8,144*Q,8
 DC.W 144*Q,8,144*Q,8,72*Q,8

 DC.W 121*Q,8,121*Q,8,60*Q,8
 DC.W 121*Q,8,121*Q,8
 DC.W 121*Q,8,121*Q,8,60*Q,8

 DC.W 108*Q,8,108*Q,8,53*Q,8
 DC.W 108*Q,8,108*Q,8
 DC.W 108*Q,8,108*Q,8,53*Q,8

 DC.W 108*Q,8,108*Q,8,53*Q,8
 DC.W 108*Q,8,108*Q,8
 DC.W 108*Q,8,108*Q,8,53*Q,8

 DC.W $FFFF,$FFFF


DRMM
 dc.w 8,1+768
 DC.W 0,7+1024
 dc.w 8,1+768
 DC.W 0,7+1024
 dc.w 8,1+768
 DC.W 0,7+1024
 dc.w 8,1+768
 DC.W 0,7+1024

 dc.w 31,8+768
 DC.W 0,8+1024
 

 dc.w 18,2+768
 DC.W 0,6+1024
 dc.w 14,2+768
 DC.W 0,6+1024
 dc.w 10,1+768
 DC.W 0,7+1024
 dc.w 8,1+768
 DC.W 0,7+1024
 dc.w 8,1+768
 DC.W 0,7+1024
 dc.w 8,1+768
 DC.W 0,7+1024

 dc.w 31,10+768
 DC.W 0,6+1024

 DC.W 0,16+1024

 DC.W $FFFF,$FFFF

 


SDUM
 DC.W 0,16+1024
 dc.w 16,8+768
 DC.W 0,8+1024
 DC.W $FFFF,$FFFF



DRSM
 DC.W 0,16+1024
 dc.w 8,4+768
 DC.W 0,4+1024
 DC.W 2,2+768
 DC.W 0,6+1024


 DC.W 0,16+1024
 dc.w 8,4+768
 DC.W 0,12+1024

 DC.W 0,16+1024
 dc.w 8,4+768
 DC.W 0,12+1024

 DC.W 0,16+1024
 dc.w 8,4+768
 DC.W 0,12+1024


 DC.W 0,16+1024
 dc.w 8,4+768
 DC.W 0,4+1024
 DC.W 2,2+768
 DC.W 0,6+1024


 DC.W 0,16+1024
 dc.w 8,4+768
 DC.W 0,12+1024


 DC.W 0,16+1024
 dc.w 8,4+768
 DC.W 0,4+1024
 dc.w 4,6+768
 DC.W 0,6+1024

 DC.W 0,12+1024
 dc.w 31,4+768
 DC.W 0,12+1024

 DC.W $FFFF,$FFFF



SLOG
 DC.W 72,255+512
 DC.W $FFFF,$FFFF


T2D DC.W 2,1
T2
 DC.W 144*Q,8,72*Q,8,144*Q,8,72*Q,8+2816
 DC.W 144*Q,8,72*Q,8,144*Q,8,72*Q,8 +2816

 DC.W 121*Q,8,60*Q,8,121*Q,8,60*Q,8+2816
 DC.W 121*Q,8,60*Q,8,121*Q,8,60*Q,8 +2816

 DC.W 217*Q,8,108*Q,8,217*Q,8,108*Q,8+2816
 DC.W 217*Q,8,108*Q,8,217*Q,8,108*Q,8 +2816
 
 DC.W 108*Q,8,53*Q,8,108*Q,8,53*Q,8+2816
 DC.W 108*Q,8,53*Q,8,108*Q,8,53*Q,8 +2816
 DC.W $FFFF,$FFFF

rigel 
 dc.w 144,128+3072
 DC.W $FFFF,$FFFF


TOM DC.W 2,64*4+3328
 DC.W 144*C,64+512,121*C,64+512,108*C,128+512


NO2 
 DC.W 108*e,8+256,91*e,8+256,96*e,8+256,102*e,8+256
 DC.W 108*e,8+256,217*e,8+256,204*e,8,102*e,8+256
 DC.W 193*e,8+256,96*e,8+256,204*e,8+256,102*e,8+256
 DC.W 108*e,8+256,217*e,8+256,193*e,8+256,96*e,8+256
 dc.w 2,128
 DC.W $FFFF,$FFFF


DRYM
 DC.W 12,4+768,8,4+768
 DC.W $FFFF,$FFFF

BAS1 DC.W 0,5
bas dc.w 144*f,8,72*f,8,128*f,8,64*f,8
    dc.w 121*f,8,60*f,8,114*f,8,57*f,8
    dc.w 108*f,8,53*f,8
    dc.w 96*f,8,47*f,8,91*f,8,45*f,8
    dc.w 81*f,8,81*f,2,40*f,8

NULL DC.W 2,128
 DC.W $FFFF,$FFFF

RF2 DC.W 0,255+3328,0,192+3328
 DC.W 144*2,16+512,144,16+512,72,32+512
 DC.W $FFFF,$FFFF

RF3 DC.W 0,255+3328,0,192+3328
 DC.W 144*2,16+512,144,16+512,72,255+512
 DC.W $FFFF,$FFFF



RAZ2 DC.W 0,2 
raz 
 dc.w 36*q,24+1536,2,8+3328
 dc.w 36*q,24+1536,2,8+3328
 dc.w 2,128+64+3328

 dc.w 36*q,24+1536,2,8+3328
 dc.w 36*q,24+1536,2,8+3328
 dc.w 2,128+3328

 DC.W 144*2,16+2304,144,16+2304,72,24+2304,0,8
 DC.W $FFFF,$FFFF

RAZ1 
 dc.w 36*q,24+1536,2,8+3328
 dc.w 36*q,24+1536,2,8+3328
 dc.w 2,128+64+3328

 dc.w 36*q,24+1536,2,8+3328
 dc.w 36*q,24+1536,2,8+3328
 dc.w 2,255+3328

 DC.W $FFFF,$FFFF

cow
 dc.w 96,4,2,4+2304
 dc.w 144,4,2,4+2304
 dc.w 36,4,2,4+2304
 dc.w 72,4,2,4+2304
 dc.w 47,4,2,4+2304
 dc.w 60,4,2,4+2304
 DC.W $FFFF,$FFFF

cow1
 dc.w 72,4,2,12+2304
 DC.W $FFFF,$FFFF



    
DRIFT DC.W 144/4,128+512,0,255+3328


DL DC.W 144*A,255+3584
FL DC.W 193*A,255+3584
GL DC.W 114*A,255+3584




TAB DS.B 64
DO DC.B 0,0


showbar 
;----make---BAR CHARTS
 move.l skreen,a2 

;------rout to show bars
 MOVEQ.W #39,D3
 moveq.w #7,d6
 moveq.b #%01111110,d7

MLP MOVE.L A2,A0

LP2 
 MOVE.B (A3)+,D1
 BEQ.S LP
 SUBQ.B #1,-1(A3)

 
lp	AND #15,D1 	
  	MOVEQ.W #15,d2
  	SUB D1,D2

LP1	clr.b 6(A0)
	clr.b 166(A0)
	lea 320(A0),a0
	DBRA D2,LP1

DID 	MOVE.B d7,6(A0)  
	MOVE.B d7,166(A0)  
	lea 320(A0),a0
 	DBRA D1,DID

 EOR #6,D6
 ADD.W D6,A2
 DBRA D3,MLP
DONT RTS
handle	dc.l 0
quiet_flag dc.w 0
super	dc.l 0
name	dc.b "budgii3.pi1",0
	even





