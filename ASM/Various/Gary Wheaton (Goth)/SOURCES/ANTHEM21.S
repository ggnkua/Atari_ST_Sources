; this is Gary Wheaton music driver
; the tune will play during the vertical blank.
; the slot chosen in the v/b queue is fairly high up
; which means that it is immune from interference
; this code is copyright Gary Wheaton  feb 1990
; Gary Wheaton and the Shapeshifters are members
; of the Budgie UK group.
; Budgie UK Licenceware: the fairer face of PD
;   anthem 21


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

	CLR.L -(SP)       ; Enter supervisor mode.
	MOVE.W #$20,-(SP) ; Super.
	TRAP #1
	ADDQ.L #6,SP
	MOVE.L D0,SUPER   ; Save old status

	clr.l	$200
	not.l	$200		on/off switch
	bclr 	#0,$484		no keyclick
	bclr 	#1,$484		no repeat key


	MOVE.L #VBI,$4de	further down the queue to avoid gem etc.

	MOVE.L SUPER,-(SP)	user mode
	MOVE.W #$20,-(SP)
	TRAP #1
	ADDQ.L #6,SP

	MOVE.l #0,-(SP)		quit and stay
	MOVE.L #1024*10,-(SP)
	MOVE.W #$31,-(SP)
	TRAP #1



ty = 3584
J EQU 8
I EQU 4

Z EQU 4



SL EQU $FF8800
SD EQU $FF8802
 move.b #7,sl
 move.b #%11111000,sd



vbi 
	movem.l	d0-d7/a0-a6,-(sp)
	lea	$fffc00,a1		acia
	cmp.b	#$61,2(a1)		undo
	beq	end_it
	cmp.b	#$62,2(a1)		help
	beq	on_off

	lea	$200,a0
	tst.l	(a0)
	beq	quiet
 move.b #7,sl
 move.b #%11111000,sd


 move.b #13,sl
 move.b #14,sd

 move.l #$c000000,sl
 move.b #11,sl
 move.b #2,sd

;\\\\\\\\\\\\\
 MOVE.L UPTO,A2
 MOVE CUNT,D3
 MOVE.B 33(A2),D4
SSU SUBQ.W #1,D3
 BPL.S PART1

COP
 MOVE.L #1,PNT0
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


exz	movem.l (sp)+,d0-d7/a0-a6
 	RTS
end_it
	bclr	#6,$fffa11	acknowledge key press interrupt
	lea	$ff8800,a0
	move.b	#7,(a0)
	move.b	#%11111111,2(a0)
 	move.l #$8000000,sl
 	move.l #$9000000,sl
 	move.l #$a000000,sl
	move.l	#0,$4de		end interrupt
	movem.l (sp)+,d0-d7/a0-a6
 	rts
on_off	bclr	#6,$fffa11	
	not.l	$200		toggle on/off
	lea	$ff8800,a0
	move.b	#7,(a0)
	move.b	#%11111111,2(a0)
 	move.l #$8000000,sl
 	move.l #$9000000,sl
	 move.l #$a000000,sl
	movem.l (sp)+,d0-d7/a0-a6
 	rts

quiet	movem.l (sp)+,d0-d7/a0-a6
	rts
	even
quiet_flag	
	dc.b	0
	even

 DC.B "  G.WHEATON. 45 GOLDRILL AVE, BOLTON, LANCS, U.K. "
;EVEN

**********************

 
super	dc.l 0
*******************


SV DC.L 0

 DC.B " (C) G.WHEATON.  45 GOLDRILL AVE BOLTON. LANCS, U.K. "
* anthem 21


;--END OF VBI
;--------EXIT


 movem.l (sp)+,d0-d3/a0-a6 
killer rts




 DC.B " (C) G.WHEATON.  45 GOLDRILL AVE BOLTON. LANCS, U.K. "

 EVEN
UPTO DC.L EE-36
CUNT DC.W 0
 EVEN
;\\RUNNING ORDER SEQUENCE

doth
ee
 DC.L PNT5,dod
 DC.L PNT0,dod
 DC.L PNT2,dod+16
 DC.L PNT3,drm
 DC.B 3,%00011110
 DC.W 8*64

 DC.L PNT4,god
 DC.L PNT0,dod
 DC.L PNT2,dod+16
 DC.L PNT3,drm
 DC.B 2,%00011110
 DC.W 22*64

 DC.L PNT4,end
 DC.L PNT0,end1
 DC.L PNT2,null
 DC.L PNT3,drm
 DC.B 2,%00001110
 DC.W 2*64

 DC.L PNT5,dod
 DC.L PNT0,dod+12
 DC.L PNT2,dod+16
 DC.L PNT3,drm
 DC.B 2,%00011110
 DC.W 4095


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
 BRA FCC
EFCT

 DC.L FINK,VIB,WARB,DRUM,slip,WB1,WRP,SLW
 DC.L SLR,HOLD,TWERP,SLR1,inup,HOLDLOW,Half
 dc.l holl,coll,foll,aoll,eoll
 REPT 11
 DC.L FINK
 ENDR

FCC LEA EFCT,A6
 AND #31,D0 
 ASL #2,D0
 MOVE.L (A6,D0),A0
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

fink 
  rts

;-------EFFECTS ROUTINES--------
;1-256---DELAYED--VIBRATO-------
VV EOR.B #1,MC
 BEQ.S SDC
VIB CMP.B #8,4(A1)
 BLT SDC

WWQ 

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

WARB addq.b #5,4(A1)
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

slip 


WB1

;6--1536-----WARB UP---------
WRP 
SDX
PLAP


;7--1792---SLIDE-UP--WARBLE
SLW 

;--2048---SLIDE UP CONST VOL 
SLR 

YIN DC.B 0,0
;9--2304-------HOLD-------------
HOLD
 move.b #15,4(a1)
 rts
;------10 2560
TWERP 


;11-------2816 SLIDE UP WITH ADSR
SLR1



tp dc.b 0,0
;12-------3072  
inup
 move.b #8,4(a1)
 bra WWQ


;13-------3328--HOLD VOL LOW
HOLDLOW
DOPL 


;
;14--------dw A
half

;15--------DW G
holl
 ADDQ.B #1,RONK
 move.b RONK,d1
 and #3,d1
 asl #1,d1
 move dq(pc,d1),20(a1)
 rts

dq dc.w 162,108,81,64

;16--------DW C
Coll
wop ADDQ.B #1,RONK+1
 move.b RONK+1,d1
 and #3,d1
 asl #1,d1
 move Eq(pc,d1),20(a1)
 rts
Eq dc.w 60,81,30,40

;17--------DW F
Foll
aoll
eoll
 rts

RONK DC.B 0,0





;\\\\\\\\\\\\\\DATAS\\\\\\\\\\\\\\\
;\\NOTE 1ST WORD. DURATION 2ND WORD
;\\\LEAD
PNT0 DC.W 0
NP0 DC.W 1
 DC.W 0
 DC.L 0
 DC.B 9,2,3
 DC.B 1      ;ADD TO NOTE
 DC.W 11      ;VIB LIMIT
 DC.W 7      ;16(A1)  ADD
 DC.W 0      ;VIB 18(A1)
 DC.L 0      ;TMP NOTE 20(A1)
 DC.B 1,1    ;VIB RATE 24(A1)
 DC.B 0,0    ;INITIAL VOL
;ADSR  28(A1)

 DC.B 12,12,12,11,10,10,10,10
 DC.B 9,9,9,9
 dcb.b	60,9



 EVEN

;\\\BASS
PNT2 DC.W 0
 DC.W 1          ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0          ;6
 DC.B 10,4,5     ;10(A1) VOL REG
 DC.B 0          ;ADD TO NOTE 13(A1)
 DC.W 5          ;VIB LIMIT
 DC.W 2          ;VIBRATO ADD 16(A1)
 DC.W 2          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
ADSR

 DC.B 3,13,13,12,12,11,10,9
 dcb.b	60,9




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
 DC.B 15,15,14,12,10
 DC.B 9,8,7,6,5,4,3,2,1



 EVEN
PNT4 DC.W 0
NP4 DC.W 1      ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0
 DC.B 8,0,1      ;10(A1) VOL REG
 DC.B 0          ;ADD 13(A1)
 DC.W 3          ;VIB LIMIT
 DC.W 2          ;VIBRATO ADD 16(A1)
 DC.W 0          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
 DC.B 3,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)

 DC.B 15,15,14,14,13,13,12,12
 REPT 22
 DC.B 11
 ENDR

 REPT 22
 DC.B 9
 ENDR

 REPT 22
 DC.B 8
 ENDR

 even

PNT5 DC.W 0
 DC.W 1       ;EFFECT & DURATION 2(A1)
 DC.B 0,0
 DC.L 0
 DC.B 8,0,1
 DC.B 2       ;ADD  13(A1)
 DC.W 7       ;VIB LIMIT
 DC.W 4       ;VIB ADD 16(A1)
 DC.W 0       ;VIB 18(A1)
 DC.L 0       ;TEMP NOTE 20(A1)
 DC.B 1,1     ;VIB RATE  24)A1)
 DC.B 0,0     ;INITIAL VOL
;ADSR  28(A1)
 DC.B 12,12,11,11,10,10,10
 DC.B 8





 EVEN
TE2 DC.W 2,3

MAX DC.B 71,32,87,72,69,65,84,79,78
DRI DC.B 251,0
MIN DC.B 0,0
MC DC.B 0,0
 EVEN

;-----------MUSIC DATA

drm
 dc.w 0,32+1024
 dc.w 6,4+768
 dc.w 0,28+1024
 DC.W $FFFF,$FFFF


NULL DC.W 2,128+2304
 DC.W $FFFF,$FFFF
e=256
a=2
c=256
god
 dc.w 121*a,32+c
 dc.w 121*a,32+c
 dc.w 108*a,32+c
 dc.w 128*a,48
 dc.w 121*a,16
 dc.w 108*a,32+c
 
 dc.w 96*a,32+c
 dc.w 96*a,32+c
 dc.w 91*a,32+c
 dc.w 96*a,48+c
 dc.w 108*a,16+c
 dc.w 121*a,32+c

 dc.w 108*a,32+c
 dc.w 121*a,32+c
 dc.w 128*a,32+c
 dc.w 121*a,32+c

 dc.w 121*a,16
 dc.w 108*a,16
 dc.w 96*a,16
 dc.w 91*a,16

 dc.w 81*a,32+c
 dc.w 81*a,32+c
 dc.w 81*a,32+c
 dc.w 81*a,48
 dc.w 91*a,16
 dc.w 96*a,32+c

 dc.w 91*a,32+c
 dc.w 91*a,32+c
 dc.w 91*a,32+c
 dc.w 91*a,48
 dc.w 96*a,16
 dc.w 108*a,32+c


 dc.w 96*a,32+e
 dc.w 91*a,16+e
 dc.w 96*a,16+e
 dc.w 108*a,16+e
 dc.w 121*a,16+e
 dc.w 96*a,48+e
 dc.w 91*a,16+e
 dc.w 81*a,32+e

 dc.w 72*a,16+e
 dc.w 91*a,16+e
 dc.w 96*a,64+e
 dc.w 108*a,64+e
 dc.w 121*a,64+e

 dc.w 0,196
 DC.W $FFFF,$FFFF


b=8
dod
 dc.w 162*b,16
 dc.w 1,8+15*256
 dc.w 162*b,8


 dc.w 121*b,8
 dc.w 121,8 
 dc.w 1,8+16*256
 dc.w 121*b,8

 dc.w 162*b,16
 dc.w 162,8 
 dc.w 121*b,8

t=16
 dc.w 121*t,1
 dc.w 108*t,1
 dc.w 96*t,1
 dc.w 81*t,1
 dc.w 72*t,1


 dc.w 121*b,11
 dc.w 121*2,16+15*256

 DC.W $FFFF,$FFFF


end
 dc.w 121*16,12
 dc.w 0,255+2304

end1
 dc.w 121*8,16
 dc.w 0,255+2304



