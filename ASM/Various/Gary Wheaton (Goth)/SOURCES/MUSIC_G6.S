* max.s  oct 89
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





skreen 	dc.l 0
super	DC.L 0

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

O=2
G=6*256
P=14*256

c=2
e equ 0
W EQU 2
I EQU 2
H EQU 8
T EQU 8
A EQU 1536
Q EQU 8
d EQU 1
r EQU 512
v EQU 4
u equ 16

SL EQU $FF8800
SD EQU $FF8802


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

;\\\\\\\\\\\\\
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
 MOVE.L #1,PNT5
 MOVE.L #$9000000,SL

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
 DC.L PNT1,NULL
 DC.L PNT4,dong  null
 DC.L PNT2,bass
 DC.L PNT3,DRSM
 DC.B 1,%00001100
 DC.W 511


 DC.L PNT0,bassw
 DC.L PNT4,bass
 DC.L PNT2,null bassw+8
 DC.L PNT3,DRSM
 DC.B 2,%00011110
 DC.W 511

 
 DC.L PNT0,bag
 DC.L PNT4,own
 DC.L PNT2,octb BAssw
 DC.L PNT3,BD
 DC.B 1,%00011110
 DC.W 511

 DC.L PNT4,old
 DC.L PNT0,null
 DC.L PNT2,bass
 DC.L PNT3,DRSM
 DC.B 2,%00011010
 DC.W 511

 DC.L PNT0,own
 DC.L PNT4,dong  bass
 DC.L PNT2,bass null
 DC.L PNT3,DRSM
 DC.B 2,%00011110
 DC.W 511

;EE
;DOTH
 DC.L PNT1,LEAD
 DC.L PNT4,back LEAD 
 DC.L PNT2,bass
 DC.L PNT3,DRSM
 DC.B 2,%00011110
 DC.W 511

 DC.L PNT5,LEAD
 DC.L PNT1,LEAD1 dong
 DC.L PNT2,bass
 DC.L PNT3,DRSM
 DC.B 2,%00011110
 DC.W 511

 DC.L PNT0,own
 DC.L PNT4,BACK
 DC.L PNT2,bass
 DC.L PNT3,DRSM
 DC.B 1,%00011110
 DC.W 511

 DC.L PNT0,own
 DC.L PNT4,BAK1 own
 DC.L PNT2,bass
 DC.L PNT3,DRSM
 DC.B 1,%00011110
 DC.W 511

 DC.L PNT0,bassw
 DC.L PNT4,bass
 DC.L PNT2,back bassw+8
 DC.L PNT3,DRSM
 DC.B 2,%00011110
 DC.W 1023

 DC.L PNT0,bak11
 DC.L PNT4,BAK1 own
 DC.L PNT2,bass
 DC.L PNT3,DRSM
 DC.B 1,%00011110
 DC.W 511

 DC.L PNT0,old
 DC.L PNT4,BAG
 DC.L PNT2,null
 DC.L PNT3,BD
 DC.B 2,%00011110
 DC.W 511

 DC.L PNT0,null
 DC.L PNT4,null
 DC.L PNT2,null
 DC.L PNT3,BD
 DC.B 2,%00001110
 DC.W 7

 DC.L PNT0,bag
 DC.L PNT4,own
 DC.L PNT2,octb BAssw
 DC.L PNT3,Drsm
 DC.B 0,%00011110
 DC.W 511

;ee
;doth
 DC.L PNT4,LEAD12
 DC.L PNT1,back
 DC.L PNT2,bass
 DC.L PNT3,DRSM
 DC.B 2,%00011110
 DC.W 511

 DC.L PNT4,LEAD2
 DC.L PNT1,lEAD3
 DC.L PNT2,bass
 DC.L PNT3,DRSM
 DC.B 2,%00011110
 DC.W 3395 1023


 DC.L PNT0,null
 DC.L PNT4,null
 DC.L PNT2,null
 DC.L PNT3,BD
 DC.B 2,%00001110
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

 DC.L FINK,VIB,WARB,DRUM,slip,WB1,WRP,SLW
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
XX DC.B 0,0
WARB addQ.B #6,4(A1)
 EOR.B #1,XX
SAX 
 Lsr 20(A1)
 ;Lsr 20(A1)
 CMP #30,20(A1)
 BGT.S PLOP
 MOVE 6(A1),20(A1)
PLOP RTS


;3--768--------DRUM-----------
DRUM 
 ;eor.b #1,lil
 ;bne.s junk
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


lil dc.b 0,0
;-4--1024-slide up

slip addq.w #2,20(a1)
 rts


;5--1280--WARB CONSTANT VOLUME
WB1 MOVE.B #5,4(A1)
 BRA.s SAX

;6--1536-----WARB UP---------
WRP 
 ;MOVE.B #100,4(A1)
SDX LSR 20(A1)
 CMP #35,20(A1)
 BGT PLAP
 MOVE 6(A1),20(A1)
PLAP RTS


;7--1792---SLIDE-UP--WARBLE
SLW 
 ;ADDQ.B #1,4(A1)
 rts

;--2048---SLIDE UP CONST VOL 
SLR 
 ;ADDQ.B #1,4(A1)
 ADD.W #80,20(A1)
 RTS

YIN DC.B 0,0
;9--2304-------HOLD-------------
HOLD MOVE.B #20,4(A1)
 RTS

;10--2560---HIGH NOTE WARB------
TWERP 
 move.b #3,4(a1)
TETSYFLY BRA VV 

;11-------2816 SLIDE UP WITH ADSR
SLR1
 SUB.W #5,20(A1)
 RTS

;12-------3072  inc up
inup
 move.b #10,4(a1)
 add #53,6(a1)
 bra vib

;13-------3328--HOLD VOL LOW
HOLDLOW
 add.b #161,joe
 bcc.s az
 subq.b #1,4(A1)
az bra vib 

joe dc.b 0,0
;14--------3584 half adsr
half
 ADD.B #30,nije+1
 bCC.s aslef
 subq.b #1,4(a1)
aslef bra vib rts


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
 DC.B 15,15,14,13,12,11,10,9
 REPT  140
 DC.B 7
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
 DC.B 15,15,14,14,13,12,11,11,10,9,9,8
 DC.B 8,8,7,7,6,5,4,3,2,1

 REPT 190
 DC.B 1
 ENDR

 EVEN
;\\\BASS
PNT2 DC.W 0
 DC.W 1          ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0          ;6
 DC.B 10,4,5     ;10(A1) VOL REG
 DC.B 4          ;ADD TO NOTE 13(A1)
 DC.W 2          ;VIB LIMIT
 DC.W 2          ;VIBRATO ADD 16(A1)
 DC.W 2       ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 2,2        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
ADSR
 DC.B 15,15,13,12,15,14,13,12,11,8
 DC.B 7,6,5,4,3,3,2,2

 REPT 180
 DC.B 2
 ENDR

 EVEN
PNT3 DC.W 0
NP3 DC.W 1      ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0          ;6
 DC.B 10,6,11    ;10(A1) VOL REG
 DC.B -1         ;ADD  13(A1)
 DC.W 4         ;VIB LIMIT
 DC.W 1          ;VIBRATO ADD 16(A1)
 DC.W 0          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
 DC.B 15,15,13,10,12,11
 DC.B 11,10,10,9,8,7

 dc.b 8,11,9,11,9,10,9,10,9,10,9
 REPT 20
 DC.B 10
 ENDR


 EVEN
PNT4 DC.W 0
NP4 DC.W 1      ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0
 DC.B 8,0,1      ;10(A1) VOL REG
 DC.B 0          ;ADD 13(A1)
 DC.W 15          ;VIB LIMIT
 DC.W 13          ;VIBRATO ADD 16(A1)
 DC.W 0          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)

 DC.B 15,15,15,14,14,14,13,13,12,12
 REPT 22
 DC.B 11
 ENDR

 REPT 22
 DC.B 9
 ENDR

 REPT 22
 DC.B 8
 ENDR

 REPT 22
 DC.B 7
 ENDR

 REPT 22
 DC.B 5
 ENDR

 REPT 24
 DC.B 3
 ENDR

 REPT 24
 DC.B 2
 ENDR

 REPT 64
 DC.B 1
 ENDR


PNT5 DC.W 0
 DC.W 1       ;EFFECT & DURATION 2(A1)
 DC.B 0,0
 DC.L 0
 DC.B 8,0,1
 DC.B 0       ;ADD  13(A1)
 DC.W 6       ;VIB LIMIT
 DC.W 4       ;VIB ADD 16(A1)
 DC.W 0       ;VIB 18(A1)
 DC.L 0       ;TEMP NOTE 20(A1)
 DC.B 1,1     ;VIB RATE  24)A1)
 DC.B 0,0     ;INITIAL VOL
;ADSR  28(A1)
 DC.B 15,15,14,14,13,13,12,11,10,9,8,7
 DC.B 6,6,7,7,8,8,7,7,7,6,6,7,7,6,6,7,6,6

 REPT 10
 DC.B 14
 ENDR




 EVEN
TE2 DC.W 2,3





MIN DC.B 0,0
MC DC.B 0,0
;-----------MUSIC DATA


DRSM
 dc.w 28,4+768
 DC.W 0,28+1024

 dc.w 8,4+768
 DC.W 0,28+1024

 dc.w 18,2+768
 DC.W 0,30+1024

 dc.w 4,4+768
 DC.W 0,28+1024

 dc.w 30,3+768
 DC.W 0,29+1024

 dc.w 4,4+768
 DC.W 0,28+1024

 dc.w 9,3+768
 DC.W 0,29+1024

 dc.w 10,32+768

 DC.W $FFFF,$FFFF



NULL DC.W 2,128+2304
 DC.W $FFFF,$FFFF

bassw dc.w 2,32
bass
 dc.w 144*q,16+256,144*q,16+256,144*q,8+256
 dc.w 193*q,8+256,162*q,8+256

 dc.w 144*q,16+256,144*q,16+256

 dc.w 144*q,8+256,144*q,8+256
 dc.w 193*q,8+256,162*q,8+2816,144*q,8+256
 
 dc.w 162*q,16+256,162*q,16+256,162*q,8
 dc.w 217*q,8,193*q,8,162*q,48+256

; 
 dc.w 162*q,8,162*q,8+2816,144*q,8
 dc.w 217*q,16+256,217*q,16+256,217*q,8
 dc.w 288*q,8,243*q,8,217*q,16+256

 dc.w 217*q,16+256,217*q,8,217*q,8

 dc.w 193*q,8,162*q,8,162*q,8

 dc.w 144*q,16+256,144*q,16+256,144*q,8
 dc.w 193*q,8+2816
 dc.w 162*q,8+2816
 dc.w 144*q,48+24+256
 DC.W $FFFF,$FFFF


gbass
 dc.w 144*q,16,144*q,16,144*q,8
 dc.w 193*q,8,162*q,8

 dc.w 144*q,16+256,144*q,16+256

 dc.w 144*q,8,144*q,8
 dc.w 193*q,8,162*q,8+2816,144*q,8
 
 dc.w 162*q,16,162*q,16,162*q,8
 dc.w 217*q,8,193*q,8,162*q,48+256

; 
 dc.w 162*q,8,162*q,8+2816,144*q,8
 dc.w 217*q,16+256,217*q,16+256,217*q,8
 dc.w 288*q,8,243*q,8,217*q,16+256

 dc.w 217*q,16+256,217*q,8,217*q,8
 dc.w 288*q,8,243*q,8,217*q,8+256
 
 dc.w 288*q,16,288*q,16,288*q,8
 dc.w 193*2*q,8,162*2*q,8,288*q,64
 DC.W $FFFF,$FFFF




own1 dc.w 2,31 
own
 dc.w 144*d,8+a,192*d,8+a,162*d,8+a,144*d,8+a
 dc.w 192*d,8+a,162*d,8+a,144*d,16+a
 dc.w 192*d,8+a,162*d,8+a,144*D,8+A,144*d,40+a
 
 dc.w 162*d,8+a,217*d,8+a,182*d,8+a,162*d,8+a
 dc.w 217*d,8+a,182*d,8+a,162*d,16+a
 dc.w 217*d,8+a,182*d,8+a
 DC.W 162*d,8+A,162*D,40+a
 
 dc.w 217*d,8+a,288*d,8+a,243*d,8+a,217*d,8+a
 dc.w 288*d,8+a,243*d,8+a,217*d,8+a
 dc.w 288*d,8+a,243*d,8+a
 DC.W 217*d,8+a
 DC.W 217*d,8+a
 DC.W 217*d,32+a

 DC.W 162*d,8+a
 dc.w 144*d,8+a,192*d,8+a,162*d,8+a,144*d,8+a
 dc.w 192*d,8+a,162*d,8+a,144*d,16+a
 dc.w 192*d,8+a,162*d,8+a,144*D,8+A,144*d,48+a


 dc.w $ffff,$ffff


old
 dc.w 144*v,16+r
 dc.w 144*v,16+r
 dc.w 144*v,8+r
 dc.w 144*v,16+r
 dc.w 144*v,16+r
 dc.w 144*v,16+r
 dc.w 144*v,8+r
 dc.w 144*v,16+r
 dc.w 144*v,8+r
 dc.w 144*v,8+r

 dc.w 162*v,16+r
 dc.w 162*v,16+r
 dc.w 162*v,8+r
 dc.w 162*v,16+r
 dc.w 162*v,16+r
 dc.w 162*v,16+r
 dc.w 162*v,8+r
 dc.w 162*v,16+r
 dc.w 162*v,8+r
 dc.w 162*v,8+r

 dc.w 217*v,16+r
 dc.w 217*v,16+r
 dc.w 217*v,8+r
 dc.w 217*v,16+r
 dc.w 108*v,16+r
 dc.w 108*v,16+r
 dc.w 108*v,8+r
 dc.w 108*v,16+r
 dc.w 108*v,16+r
 
 dc.w 144*v,16+r
 dc.w 144*v,16+r
 dc.w 144*v,8+r
 dc.w 144*v,16+r
 dc.w 144*v,8+r
 ;dc.w 144*v,16+r


 DC.W 2,64
 dc.w $ffff,$ffff


bd
 dc.w 16,4+768
 dc.w 0,28+1024
 dc.w 8,6+768
 dc.w 0,26+1024

 dc.w 16,4+768
 dc.w 0,28+1024
 dc.w 6,6+768
 dc.w 0,26+1024

 dc.w 16,4+768
 dc.w 16,28+1024
 dc.w 4,6+768
 dc.w 16,26+1024

 dc.w 16,4+768
 dc.w 0,28+1024


 dc.w 16,6+768
 dc.w 0,4+1024

 dc.w 4,6+768
 dc.w 0,4+1024

 dc.w 2,6+768
 dc.w 0,6+1024


 dc.w 31,4+768
 dc.w 0,28+1024
 dc.w 8,6+768
 dc.w 0,26+1024

 dc.w 31,4+768
 dc.w 0,28+1024
 dc.w 8,6+768
 dc.w 0,26+1024

 dc.w 31,4+768
 dc.w 16,28+1024
 dc.w 8,6+768
 dc.w 16,26+1024

 dc.w 31,12+768
 dc.w 16,40+14+1024

 dc.w $ffff,$ffff



 dc.w 8,4+768
 dc.w 8,4+768
 dc.w 0,8+1024
 dc.w 8,4+768
 dc.w 0,12+1024




BAG

 dc.w 162*t,2
 dc.w 162*t,2
 dc.w 162*t,2
 dc.w 160*t,1
 dc.w 159*t,1
 dc.w 158*t,1
 dc.w 157*t,1
 dc.w 156*t,1
 dc.w 155*t,1
 dc.w 154*t,1
 dc.w 153*t,1
 dc.w 150*t,1
 dc.w 147*t,1

 DC.W 144*T,7*16+256

 DC.W 162*T,8*16+256

 DC.W 108*T,8*16+256

 DC.W 288*T,8*16+256

 dc.w $ffff,$ffff




BACK
 DC.W 144*h,8*16+3328
 DC.W 162*h,8*16+3328
 DC.W 217*h,8*16+3328
 DC.W 288*h,8*16+3328
 dc.w $ffff,$ffff

bak11 dc.w 2,4
BAK1
 DC.W 144*I,7*16+256

 DC.W 128*I,4
 DC.W 132*I,2
 DC.W 136*I,2
 DC.W 140*I,2

 DC.W 144*I,8+256



 DC.W 162*I,7*16+256
 DC.W 162*I,5,144*I,5,162*I,6

 DC.W 217*I,8+7*16+256


 DC.W 288*I,8

 DC.W 243*I,4
 DC.W 246*I,1
 DC.W 249*I,1
 DC.W 252*I,2

 DC.W 256*I,3
 DC.W 260*I,1
 DC.W 265*I,1
 DC.W 270*I,1
 DC.W 275*I,1
 DC.W 280*I,1



 DC.W 288*I,7*16+256
 dc.w $ffff,$ffff

dong 
 dc.w 2,224+1,53,128+1792
 dc.w  2,255
 dc.w $ffff,$ffff



octb
 dc.w 144*u,8,72*u,8 
 dc.w 144*u,8,72*u,8 
 dc.w 144*u,8,72*u,8 
 dc.w 144*u,8,72*u,8 
 dc.w 144*u,8,72*u,8 
 dc.w 144*u,8,72*u,8 
 dc.w 144*u,8,72*u,8 
 dc.w 144*u,8,72*u,8 
 dc.w 162*u,8,81*u,8 
 dc.w 162*u,8,81*u,8 
 dc.w 162*u,8,81*u,8 
 dc.w 162*u,8,81*u,8 
 dc.w 162*u,8,81*u,8 
 dc.w 162*u,8,81*u,8 
 dc.w 162*u,8,81*u,8 
 dc.w 162*u,8,81*u,8 
 dc.w 217*u,8,108*u,8 
 dc.w 217*u,8,108*u,8 
 dc.w 217*u,8,108*u,8 
 dc.w 217*u,8,108*u,8 
 dc.w 217*u,8,109*u,8 
 dc.w 217*u,8,108*u,8 
 dc.w 217*u,8,108*u,8 
 dc.w 217*u,8,108*u,8 
 dc.w $ffff,$ffff




lead1 DC.W 2,4+1536
lead
 dc.w 144*O,8+P,121*O,16+P,108*O,8+P
 DC.W 96*O,16+P,81*O,8+P,72*O,16+P
 DC.W 81*O,8+P,96*O,16
 DC.W 81*O,8+P,72*O,8+P
 DC.W 96*O,8+P,81*O,32+P

 DC.W 2,64+16+2304

 DC.W 81*O,8,81*O,8,72*O,8
 DC.W 108*O,16,108*O,8,108*O,8,108*O,8
 DC.W 144*O,8,121*O,8,108*O,16
 DC.W 108*O,16,108*O,8,108*O,8
 DC.W 96*O,8,81*O,8,72*O,32+P,2,104+2304
 dc.w $ffff,$ffff


lead2
 DC.W 144*O,24+G
 DC.W 108*O,24+G
 DC.W 81*O,24+G
 DC.W 81*O,24+G
 DC.W 81*O,16+G
 DC.W 96*O,12+G
 DC.W 81*O,28+G

 DC.W 2,64+8+2304
 DC.W 108*4,32+3072

 DC.W 108*O,16+g
 DC.W 108*O,8+g
 DC.W 108*O,8+g
 DC.W 108*O,8+g
 DC.W 144*O,8+g
 DC.W 121*O,8+g
 DC.W 108*O,16+g
 DC.W 108*O,16+g
 DC.W 108*O,8+g
 DC.W 108*O,8+g
 DC.W 96*O,8+g
 DC.W 81*O,8+g
 DC.W 72*O,32+G


 DC.W 2,64+8+2304
 DC.W 144*8,32+2048

 DC.W $ffff,$ffff


lead3
 dc.w 2,8+2304
 dc.w 121*O,24+G
 DC.W 96*O,24+G
 dc.w 72*O,24+G
 dc.w 96*O,24+g
 dc.w 72*O,16+G
 dc.w 81*O,32+G

 DC.W 2,64+8+2304
 dc.w 108*2,32+3072

 dc.w 2,256-152
 dc.w 2,256-40-64
 dc.w $ffff,$ffff


lead12a dc.w 2,1 
lead12 
 dc.w 108*c,16+2560,107*c,1,106*c,1
 dc.w 105*c,1,104*c,1,103*c,1
 dc.w 102*c,1,101*c,1,100*c,1
 dc.w 99*c,1,98*c,1,97*c,1
 dc.w 96*c,64+34+256

 dc.w 96*c,16+2560,97*c,1,98*c,1,98*c,1
 dc.w 99*c,1,100*c,1,101*c,1,102*c,1
 dc.w 103*c,1,104*c,1,105*c,1,106*c,1
 dc.w 107*c,1,108*c,64+36+256

 dc.w 96*c,16+2560,97*c,1,98*c,1,98*c,1
 dc.w 99*c,1,100*c,1,101*c,1,102*c,1
 dc.w 103*c,1,104*c,1,105*c,1,106*c,1
 dc.w 107*c,1,108*c,8+256
 dc.w 108*c,17+1024,144*c,64 +256

 dc.w 162*c,8,144*c,8
 dc.w 121*c,8,120*c,1,121*c,1,119*c,1,121*c,1,118*c,1
 dc.w 117*c,1,116*c,1,115*c,1,114*c,4,115*c,1,116*c,1
 dc.w 144*c,64+24+16
;476

 dc.w 2,255+2304
 dc.w 2,255+2304
 

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



