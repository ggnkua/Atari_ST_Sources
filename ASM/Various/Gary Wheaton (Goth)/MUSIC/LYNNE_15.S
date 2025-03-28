; this is Gary Wheaton music driver
; the tune will play during the vertical blank.
; the slot chosen in the v/b queue is fairly high up
; which means that it is immune from interference
; this code is copyright Gary Wheaton  Nov 1989
; Gary Wheaton and the Shapeshifters are members
; of the Budgie UK group.
; Budgie UK Licenceware: the fairer face of PD
;   lynne     January 1990
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

	move.l	#vbi,$4de	start vbi interrupt
	

	MOVE.L SUPER,-(SP)	user mode
	MOVE.W #$20,-(SP)
	TRAP #1
	ADDQ.L #6,SP

	MOVE.W #0,-(SP)		quit and stay
	MOVE.L #1024*10,-(SP)
	MOVE.W #$31,-(SP)
	TRAP #1

SL EQU $FF8800
SD EQU $FF8802
 move.b #7,sl
 move.b #%11111000,sd

 MOVE.B #$08,SL
 MOVE.B #15,SD
 MOVE.B #$0,SL
 MOVE.B #96,SD

 MOVE.B #$01,SL
 MOVE.B #$00,SD


vbi 
	movem.l	d0-d7/a0-a6,-(sp)
	tst.l	$200
	beq	quiet
 	move.b 	#7,sl			added 1/90
	move.b 	#%11111000,sd		added 1/90

	CMP.B #97,$FFFC02
  	Beq	end_it

 MOVE.L UPTO,A2
 MOVE CUNT,D3
 MOVE.B 33(A2),D4
SSU SUBQ.W #1,D3
 BPL.S PART1

COP
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


	movem.l (sp)+,d0-d7/a0-a6
 	RTS
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
return	rts
	even
quiet_flag	
	dc.b	0
	even

super dc.l 0

res	dc.w 0
palette	ds.w 16
SV DC.L 0

 DC.B " (C) G.WHEATON.  45 GOLDRILL AVE BOLTON. LANCS, U.K. "
 DC.B  " TITLE   ****SONG FOR LYNNE****   "
 DC.B  " COMOPOSED BY G.WHEATON. JAN. 1990"

 EVEN
UPTO DC.L EE-36
CUNT DC.W 0
 EVEN
;\\RUNNING ORDER SEQUENCE

doth
ee
 DC.L PNT5,fol
 DC.L PNT0,fol
 DC.L PNT2,pat
 DC.L PNT3,drm
 DC.B 2,%00011110
 DC.W 64*16

 DC.L PNT4,LED
 DC.L PNT0,FOL
 DC.L PNT2,pat
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W 64*16

 DC.L PNT4,Flex
 DC.L PNT0,led
 DC.L PNT2,pat
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W 64*16

 DC.L PNT4,Flex
 DC.L PNT0,flex2
 DC.L PNT2,pat
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W 64*16


 DC.L PNT5,pat
 DC.L PNT0,pat1
 DC.L PNT2,fol
 DC.L PNT3,drm
 DC.B 0,%00011110
 DC.W 64*16

 DC.L PNT5,flex
 DC.L PNT0,pat1
 DC.L PNT2,fol
 DC.L PNT3,drm
 DC.B 0,%00011110
 DC.W 64*16


 DC.L PNT4,lex
 DC.L PNT0,tex
 DC.L PNT2,pat
 DC.L PNT3,drm
 DC.B 0,%00011110
 DC.W 64*16


 DC.L PNT4,lead1
 DC.L PNT0,pat
 DC.L PNT2,fol
 DC.L PNT3,drm
 DC.B 2,%00011110
 DC.W 64*16

 DC.L PNT5,flex
 DC.L PNT0,tex
 DC.L PNT2,pat
 DC.L PNT3,drm
 DC.B 2,%00011110
 DC.W 64*16

 DC.L PNT4,lead1
 DC.L PNT0,flex
 DC.L PNT2,pat
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W 64*16


 DC.L PNT4,flex
 DC.L PNT0,flex2
 DC.L PNT2,pat
 DC.L PNT3,drm
 DC.B 2,%00011110
 DC.W 64*16


 DC.L PNT5,pat1
 DC.L PNT0,pat
 DC.L PNT2,fol
 DC.L PNT3,drmm
 DC.B 0,%00011110
 DC.W 64*16

 DC.L PNT5,pat1
 DC.L PNT0,pat
 DC.L PNT2,tex
 DC.L PNT3,drmm
 DC.B 0,%00011110
 DC.W 64*16

 DC.L PNT5,pat1
 DC.L PNT0,flex
 DC.L PNT2,fol
 DC.L PNT3,drmm
 DC.B 2,%00011110
 DC.W 64*16

 DC.L PNT5,pat1
 DC.L PNT0,pat
 DC.L PNT2,fol
 DC.L PNT3,drmm
 DC.B 1,%00011110
 DC.W 64*16

 DC.L PNT5,pat
 DC.L PNT0,flex
 DC.L PNT2,tex fol
 DC.L PNT3,drmm
 DC.B 3,%00011110
 DC.W 64*16



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

fink rts

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

;------4 1024
slip 


;5--1280--WARB CONSTANT VOLUME
WB1 MOVE.B #5,4(A1)
 BRA.s SAX

;6--1536-----WARB UP---------
WRP 
 ;addq.B #2,4(A1)
SDX LSR 20(A1)
 CMP #35,20(A1)
 BGT PLAP
 MOVE 6(A1),20(A1)
PLAP bra vib wwq RTS


;7--1792---SLIDE-UP--WARBLE
SLW 
 MOVE.B #7,4(a1)
 BRA wwq

;--2048---SLIDE UP CONST VOL 
SLR 
 ADD.W #80,20(A1)
 RTS

YIN DC.B 0,0
;9--2304-------HOLD-------------
HOLD MOVE.B #20,4(A1)
 RTS

;------10 2560
TWERP 
 MOVE.B #8,4(a1)
 rts


;11-------2816 SLIDE UP WITH ADSR
SLR1
 CMP #72,6(A1)
 BGT WAQ

 BTST #1,$469
 BEQ.S F1

 MOVE #72,6(A1)
 BRA WWQ

F1 MOVE #36/2,6(A1)
 BRA WWQ


WAQ SUBQ.W #8,6(A1)
 MOVE.B #16,4(A1)
 BRA SDX


tp dc.b 0,0
;12-------3072  
inup
 move.b #8,4(a1)
 bra WWQ


;13-------3328--HOLD VOL LOW
HOLDLOW
 CMP.B #1,4(A1)
 BNE.S DOPL
 ASL 20(A1)
 RTS
DOPL MOVE 6(A1),20(A1)
  BRA VIB WWQ 


;
;14--------dw A
half
 ADDQ.B #1,RONK
 move.b RONK,d1
 and #3,d1
 asl #1,d1
 move dw(pc,d1),20(a1)
 rts

dw dc.w 144,96,72,96/2

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
 ADDQ.B #1,RONK
 move.b RONK,d1
 and #3,d1
 asl #1,d1
 move Eq(pc,d1),20(a1)
 rts

Eq dc.w 121,81,60,40

;17--------DW F
Foll
 ADDQ.B #1,RONK
 move.b RONK,d1
 and #3,d1
 asl #1,d1
 move Rq(pc,d1),20(a1)
 rts

Rq dc.w 182,121,91,60

;18--------DW Am
aoll
 addq.b #1,RONK
 move.b RONK,d1
 and #3,d1
 asl #1,d1
 move aq(pc,d1),20(a1)
 rts

aq dc.w 144,96,72,57,32

;19--------DW E
eoll
 addq.b #1,RONK
 move.b RONK,d1
 and #3,d1
 asl #1,d1
 move eeq(pc,d1),20(a1)
 rts

eeq dc.w 193,128,96,64
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

 DC.B 15,15,13 
 DC.B 14,13,12,11,11,11,11,11,10,10,10,10
 DC.B 9,9,9,9
 DC.B 10,9,8,6,8,7,7,7,7
 dcb.b	50,6
 dcb.b	50,5



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
 DC.B 15,14,12,10,9,8,8,8,9,9,8
 DC.B 8,8,7,7,6,6,7,6,6,5,4,4

 DCB.B 10,5
 DCB.B 10,6
 DCB.B 10,7
 DCB.B 10,8
 DCB.B 10,9
 DCB.B 10,10
 DCB.B 10,12
 DCB.B 10,10
 DCB.B 10,9
 DCB.B 10,7
 DCB.B 10,4

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

 DC.B 15,15,13,13,13,13,13,12,12,11,10,9
 dcb.b	155,9




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
 DC.B 15,15,13,12,11,10
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
 DC.B 2       ;ADD  13(A1)
 DC.W 7       ;VIB LIMIT
 DC.W 4       ;VIB ADD 16(A1)
 DC.W 0       ;VIB 18(A1)
 DC.L 0       ;TEMP NOTE 20(A1)
 DC.B 1,1     ;VIB RATE  24)A1)
 DC.B 0,0     ;INITIAL VOL
;ADSR  28(A1)
 DC.B 15,15,14,13,12,12,11,11,10,10,10
 DC.B 8

 DCb.B 10,8
 DCb.B 20,7
 DCb.B 30,6
 DCb.B 140,5




 EVEN
TE2 DC.W 2,3

MAX DC.B 71,32,87,72,69,65,84,79,78
DRI DC.B 251,0
MIN DC.B 0,0
MC DC.B 0,0
 EVEN

;-----------MUSIC DATA



NULL DC.W 2,128+2304
 DC.W $FFFF,$FFFF

s=2304
u=8
f=256

pat
 dc.w 121*u,16
 dc.w 121*u,16
 dc.w 0,8+s
 dc.w 121*u,16
 dc.w 0,8+s
 dc.w 121*u,16
 dc.w 0,24+s

 dc.w 108*u,8
 dc.w 108*u,8
 dc.w 96*u,8



 dc.w 121*u,16
 dc.w 121*u,16
 dc.w 0,8+s
 dc.w 121*u,12
 dc.w 0,4+s
 dc.w 121*u,8
 dc.w 121*u,16
 dc.w 0,24+s


 dc.w 121*u,8
 dc.w 121*u,8
 dc.w 128*u,8

 dc.w 144*u,16
 dc.w 144*u,16
 dc.w 0,8+s
 dc.w 144*u,16
 dc.w 0,8+s
 dc.w 144*u,16
 dc.w 0,16+s

 dc.w 162*u,32+a

 dc.w 144*u,16
 dc.w 144*u,16
 dc.w 0,8+s
 dc.w 144*u,16
 dc.w 0,8+s
 dc.w 144*u,16
 dc.w 0,24+s
  
  
 dc.w 144*u,8
 dc.w 144*u,8
 dc.w 162*u,8

 dc.w 182*u,16
 dc.w 182*u,16
 dc.w 0,8+s
 dc.w 182*u,16
 dc.w 0,8+s
 dc.w 182*u,16
 dc.w 0,48+s

 dc.w 182*u,16
 dc.w 182*u,16
 dc.w 0,8+s
 dc.w 182*u,16
 dc.w 0,8+s
 dc.w 182*u,16
 dc.w 0,16+s

 dc.w 172*4,2
 dc.w 172*u,30+a

 dc.w 162*u,16
 dc.w 162*u,16
 dc.w 0,8+s
 dc.w 162*u,16
 dc.w 0,8+s
 dc.w 162*u,16
 dc.w 0,24+s

 dc.w 144*u,8
 dc.w 144*u,8
 dc.w 128*u,8

 dc.w 162*u,16
 dc.w 162*u,16
 dc.w 0,8+s
 dc.w 162*u,12
 dc.w 0,4+s
 dc.w 162*u,8
 dc.w 162*u,16
 dc.w 0,16+s
 
 dc.w 108*u,16
 dc.w 96*u,16


 DC.W $FFFF,$FFFF


drm
 dc.w 0,32+1024
 dc.w 6,4+768
 dc.w 0,28+1024
 DC.W $FFFF,$FFFF


DRMm 
 DC.W 2,16+1024,0,1+768,18,7+768,2,8+1024
 DC.W 2,16+1024,16,4+768,2,12+1024

 DC.W 2,16+1024,4,8+768,2,8+1024
 DC.W 2,16+1024,16,4+768,2,12+1024

 DC.W 2,16+1024,4,8+768,2,8+1024
 DC.W 2,16+1024,16,4+768,2,12+1024

sholl
 DC.W 2,16+1024,4,8+768,2,8+1024
 DC.W 2,16+1024
 DC.W 8,8+768,8,8+768
 DC.W $FFFF,$FFFF 

t=2
Y=3328

led

 dc.w 96*t,24+Y
 dc.w 91*t,24
 dc.w 81*t,16+Y
 dc.w 81*t,24
 dc.w 91*t,24+Y
 dc.w 96*t,16+Y

 dc.w 96*t,24+Y
 dc.w 91*t,24+Y
 dc.w 81*t,16+Y
 dc.w 81*t,24+Y
 dc.w 91*t,24+Y
 dc.w 96*t,16+Y

 dc.w 121*t,24+Y
 dc.w 108*t,24+Y
 dc.w 96*t,16+Y
 dc.w 96*t,24+Y
 dc.w 108*t,24+Y
 dc.w 121*t,16+Y

 dc.w 121*t,24+Y
 dc.w 108*t,24
 dc.w 96*t,16+Y
 dc.w 108*t,24
 dc.w 121*t,24+Y
 dc.w 108*t,16

 dc.w 182*t,24+Y
 dc.w 162*t,24
 dc.w 144*t,16+Y
 dc.w 144*t,24+Y
 dc.w 162*t,24+Y
 dc.w 182*t,16

 dc.w 182*t,24+Y
 dc.w 162*t,24
 dc.w 144*t,16+Y
 dc.w 144*t,24+Y
 dc.w 162*t,24+Y
 dc.w 182*t,16

 dc.w 162*t,24+Y
 dc.w 144*t,24+Y
 dc.w 128*t,16+Y
 dc.w 128*t,24+Y
 dc.w 144*t,24+Y
 dc.w 162*t,16+Y

 dc.w 162*t,24+Y
 dc.w 144*t,24+Y
 dc.w 128*t,16+Y
 dc.w 128*t,24+Y
 dc.w 121*t,24+Y
 dc.w 108*t,16+Y
 DC.W $FFFF,$FFFF



lex
 dc.w 96,128+16*256
 dc.w 96,64+16*256
 dc.w 96,32+16*256
 dc.w 108,32+16*256
 dc.w 121,128+18*256
 dc.w 121,64+18*256
 dc.w 121,64+18*256
 dc.w 91,128+17*256
 dc.w 91,64+17*256
 dc.w 81,32+15*256 256
 dc.w 72,32+14*256 256
 dc.w 81,128+15*256 256
 dc.w 81,32+15*256 256
 dc.w 81,32+15*256 256
 dc.w 81,24+14*256 256
 dc.w 0,8+S
 dc.w 81,32+15*256 256
 DC.W $FFFF,$FFFF

Flex
 dc.w 96,128+16*256
 dc.w 96,128+16*256
 dc.w 121,128+18*256
 dc.w 121,128+18*256
 dc.w 91,128+17*256
 dc.w 91,64+17*256
 dc.w 81,32+15*256 256
 dc.w 72,32+14*256 256
 dc.w 81,128+15*256 256
 dc.w 81,128+15*256 256
 DC.W $FFFF,$FFFF

flex2 dc.w 0,3+s
Tex
 dc.w 96,128+256
 dc.w 96,128+256
 dc.w 121,128+256
 dc.w 121,128+256
 dc.w 91,128+256
 dc.w 91,64+256
 dc.w 81,32+256 
 dc.w 72,32+256 
 dc.w 81,128+256 
 dc.w 81,128+256 
 DC.W $FFFF,$FFFF

TT=16
A=3072

FOL
 DC.W 60*TT,2+A 
 DC.W 121*TT,126+A 
 DC.W 60*TT,8+A 
 DC.W 121*TT,104+A 
 
 DC.W 114*TT,2+A 
 DC.W 108*TT,2+A 
 DC.W 102*TT,2+A 
 DC.W 96*TT,2+A 
 DC.W 91*TT,2+A 
 DC.W 85*TT,2+A 
 DC.W 81*TT,2+A 
 DC.W 76*TT,2+A 


 DC.W 72*TT,8+A 
 DC.W 144*TT,120+A 
 DC.W 72*TT,8+A 
 DC.W 144*TT,120+A 
 DC.W 91*TT,8+A 
 DC.W 182*TT,120+A 
 DC.W 91*TT,8+A 
 DC.W 182*TT,112+A 

 DC.W 180*TT,1+A 
 DC.W 178*TT,1+A 
 DC.W 176*TT,1+A 
 DC.W 174*TT,1+A 
 DC.W 172*TT,1+A 
 DC.W 170*TT,1+A 
 DC.W 168*TT,1+A 
 DC.W 166*TT,1+A 


 DC.W 81*TT,16+A 
 DC.W 162*TT,112+A 
 DC.W 81*TT,8+A 
 DC.W 162*TT,104+A 

 DC.W 167*TT,1+A 
 DC.W 172*TT,1+A 
 DC.W 177*TT,1+A 
 DC.W 182*TT,1+A 
 DC.W 187*TT,1+A 
 DC.W 192*TT,1+A 
 DC.W 202*TT,1+A 
 DC.W 207*TT,1+A 
 DC.W 212*TT,1+A 
 DC.W 217*TT,1+A 
 DC.W 222*TT,1+A 
 DC.W 227*TT,1+A 
 DC.W 237*TT,1+A 
 DC.W 243*TT,3+A 

 DC.W $FFFF,$FFFF


tr=1
yy=256

lead1 dc.w 0,1
lead
 dc.w 96*tr,24+yy
 dc.w 91*tr,24
 dc.w 81*tr,16+yy
 dc.w 81*tr,24
 dc.w 91*tr,24+yy
 dc.w 96*tr,16+yy

 dc.w 96*tr,24+yy
 dc.w 91*tr,24+yy
 dc.w 81*tr,16+yy
 dc.w 81*tr,24+yy
 dc.w 91*tr,24+yy
 dc.w 96*tr,16+yy

 dc.w 121*tr,24+yy
 dc.w 108*tr,24+yy
 dc.w 96*tr,16+yy
 dc.w 96*tr,8+yy
 dc.w 96*tr,8+yy
 dc.w 96*tr,8+yy
 dc.w 108*tr,24+yy
 dc.w 121*tr,16+yy

 dc.w 121*tr,24+yy
 dc.w 108*tr,24
 dc.w 96*tr,16+yy
 dc.w 108*tr,8
 dc.w 121*tr,8
 dc.w 108*tr,8
 dc.w 121*tr,24+yy
 dc.w 128*tr,16

 dc.w 182*tr,24+yy
 dc.w 162*tr,24
 dc.w 158*tr,4+yy 2560
 dc.w 154*tr,4+yy 2560
 dc.w 150*tr,4+yy 2560
 dc.w 146*tr,4+yy 2560
 dc.w 144*tr,24+yy
 dc.w 162*tr,24+yy
 dc.w 182*tr,16

 dc.w 182*tr,24+yy
 dc.w 162*tr,24
 dc.w 144*tr,16+yy
 dc.w 144*tr,24+yy
 dc.w 162*tr,24+yy

 dc.w 182*tr,8
 dc.w 0,8+s
 dc.w 162*tr,24+yy
 dc.w 144*tr,8+yy
 dc.w 0,16+s

 dc.w 162*tr,8
 dc.w 0,8+s
 dc.w 144*tr,24+yy
 dc.w 128*tr,8+yy
 dc.w 0,16+s

 dc.w 144*tr,8
 dc.w 0,8+s
 dc.w 128*tr,24+yy
 dc.w 121*tr,16+yy
 dc.w 108*tr,24 +yy
 dc.w 108*tr,24+yy
 dc.w 121*tr,24+yy
 dc.w 108*tr,32+yy



 DC.W $FFFF,$FFFF


i=2
j=1536

pat1

 dc.w 121*i,16+j
 dc.w 121*i,16+j
 dc.w 121*i,16+j
 dc.w 81*i,64+j

 dc.w 81*i,8+j
 dc.w 96*i,8+j
 ;dc.w 121*i,16+j

 dc.w 121*i,16+j
 dc.w 121*i,16+j
 dc.w 121*i,16+j
 dc.w 81*i,64+j

 dc.w 121*i,16+j

 dc.w 144*i,16+j
 dc.w 144*i,16+j
 dc.w 144*i,16+j
 dc.w 96*i,64+j

 dc.w 144*4,8
 dc.w 193*4,8

 dc.w 144*i,16+j
 dc.w 144*i,16+j
 dc.w 144*i,16+j
 dc.w 96*i,64+j

 dc.w 144*4,8
 dc.w 193*4,8

 dc.w 182*i,16+j
 dc.w 182*i,16+j
 dc.w 182*i,16+j
 dc.w 121*i,64+j


 dc.w 193*4,8
 dc.w 193,8+j

 dc.w 121*i,16+j
 dc.w 121*i,16+j
 dc.w 121*i,16+j
 dc.w 144*i,64+j
 dc.w 162*i,16+j

 dc.w 121*i,16+j
 dc.w 121*i,16+j
 dc.w 121*i,16+j
 dc.w 144*i,48+j
 dc.w 162*i,32+j


 dc.w 121*i,16+j
 dc.w 121*i,16+j
 dc.w 121*i,16+j
 dc.w 144*i,32+j
 dc.w 162*i,32+j
 dc.w 144*i,32+j

 DC.W $FFFF,$FFFF






