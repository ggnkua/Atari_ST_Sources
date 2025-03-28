
 CLR.L -(SP)       ; Enter supervisor mode.
 MOVE.W #$20,-(SP) ; Super.
 TRAP #1
 ADDQ.L #6,SP
 MOVE.L D0,SV


SL EQU $FF8800
SD EQU $FF8802
 move.b #7,sl
 move.b #%11111000,sd

; MOVE.B #$08,SL
; MOVE.B #15,SD
; MOVE.B #$0,SL
; MOVE.B #96,SD

; MOVE.B #$01,SL
; MOVE.B #$00,SD


FF CMP.B #97,$FFFC02
 ; BNE.S FF

 
VBI  
 movem.l d0-d3/a0-a6,-(sp)
 MOVE.B DRI,D1
 ADD.B D1,DRI+1
 BCC FLO




;\\\\\\\\\\\\\
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
;--END OF VBI
;--------EXIT






FLO
 MOVE.B $469,D0
FT CMP.B $469,D0
 BEQ.S FT


 movem.l (sp)+,d0-d3/a0-a6 
;killer rts


 CMP.B #97,$FFFC02
 BNE VBI


	lea	$ff8800,a0	get sound chip 
	move.b	#7,(a0)
	move.b	#%11111111,2(a0) cut out lingering noise
	move.l #$8000000,$ff8800 
	move.l #$9000000,$ff8800 
	move.l #$a000000,$ff8800 

 MOVE #$777,$FF8240  
 clr $FF8240+30
 MOVE.L SV,-(SP)
 MOVE #$20,-(SP)
 TRAP #1
 ADDQ.L #6,SP
 
 CLR -(SP)
 TRAP #1




SV DC.L 0

 DC.B " (C) G.WHEATON.  45 GOLDRILL AVE BOLTON. LANCS, U.K. "


UPTO DC.L EE-36
CUNT DC.W 0
 EVEN
;\\RUNNING ORDER SEQUENCE

ee
doth
 DC.L PNT5,bull
 DC.L PNT1,null B3
 DC.L PNT2,t2
 DC.L PNT3,drm
 DC.B 1,%00001110
 DC.W -1+64*12


 DC.L PNT5,B2
 DC.L PNT1,B3
 DC.L PNT2,t2
 DC.L PNT3,drm
 DC.B 1,%00001110
 DC.W -1+64*12

 DC.L PNT4,T1
 DC.L PNT1,T2
 DC.L PNT2,b2
 DC.L PNT3,drm
 DC.B 2,%00011110
 DC.W -1+64*12

 DC.L PNT4,T1
 DC.L PNT1,T2
 DC.L PNT2,B1
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+64*12

 DC.L PNT5,T1
 DC.L PNT0,T2
 DC.L PNT2,B1
 DC.L PNT3,drm
 DC.B 0,%00011110
 DC.W -1+64*12





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
 DC.L SLR,HOLD,TWERP,SLR1,inup,wwq,Half
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
VIB CMP.B #15,4(A1)
 BLT warb SDC

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

WARB 
SAX 
 ADDQ.B #1,4(A1)
 Lsr 20(A1)
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
SDX LSR 20(A1)
 CMP #35,20(A1)
 BGT PLAP
 MOVE 6(A1),20(A1)
PLAP bra vib


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
HOLD MOVE.B #50,4(A1)
 RTS

;------10 2560
TWERP 
 MOVE.B #8,4(a1)
 rts


;11-------2816 SLIDE UP WITH ADSR
SLR1
 addq.b #1,4(a1) 
dip rts


tp dc.b 0,0
;12-------3072  
inup
 move.b #8,4(a1)
 bra WWQ


;13-


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

 DC.B 15,15
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
 DC.B 0       ;ADD  13(A1)
 DC.W 3       ;VIB LIMIT
 DC.W 2       ;VIB ADD 16(A1)
 DC.W 0       ;VIB 18(A1)
 DC.L 0       ;TEMP NOTE 20(A1)
 DC.B 1,1     ;VIB RATE  24)A1)
 DC.B 0,0     ;INITIAL VOL
;ADSR  28(A1)

 DCB.B 10,13
 DC.B 12,11,10
 DCB.B 10,0
 DCB.B 10,0

 EVEN
;\\\BASS
PNT2 DC.W 0
 DC.W 1          ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0          ;6
 DC.B 10,4,5     ;10(A1) VOL REG
 DC.B 1          ;ADD TO NOTE 13(A1)
 DC.W 5          ;VIB LIMIT
 DC.W 8          ;VIBRATO ADD 16(A1)
 DC.W 2          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
ADSR

 DC.B 13,13,13,12,12,11,11,10,10

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
 DC.B 15,15,15,12,10
 DC.B 9,8,7,6,5,4,3,2,1



 EVEN
PNT4 DC.W 0
NP4 DC.W 1      ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0
 DC.B 8,0,1      ;10(A1) VOL REG
 DC.B 0          ;ADD 13(A1)
 DC.W 3          ;VIB LIMIT
 DC.W 4          ;VIBRATO ADD 16(A1)
 DC.W 0          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)

 DC.B 11,11,11,11,11,11,12,12,12,12,12,12,12,12

 DCB.B 10,13
 DCB.B 10,12
 DCB.B 10,11
 DCB.B 10,10
 DCB.B 22,5
 DCB.B 22,3





PNT5 DC.W 0
 DC.W 1       ;EFFECT & DURATION 2(A1)
 DC.B 0,0
 DC.L 0
 DC.B 8,0,1
 DC.B 0       ;ADD  13(A1)
 DC.W 2       ;VIB LIMIT
 DC.W 2       ;VIB ADD 16(A1)
 DC.W 0       ;VIB 18(A1)
 DC.L 0       ;TEMP NOTE 20(A1)
 DC.B 1,1     ;VIB RATE  24)A1)
 DC.B 0,0     ;INITIAL VOL
;ADSR  28(A1)
 DC.B 15,15,14,13,12,11,10,10,10
 DC.B 9

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

D=2304

NULL DC.W 2,128+2304
 DC.W $FFFF,$FFFF


drm
 dc.w 0,32+1024
 dc.w 3,4+768
 dc.w 0,12+1024
 DC.W $FFFF,$FFFF


DRMm 
 DC.W 2,16+1024,0,1+768,18,7+768,2,8+1024
 DC.W 2,16+1024,16,4+768,2,12+1024

 DC.W 2,16+1024,4,8+768,2,8+1024
 DC.W 2,16+1024,16,4+768,2,12+1024

 DC.W 2,16+1024,4,8+768,2,8+1024
 DC.W 2,16+1024,16,4+768,2,12+1024

V=256
Q=4
t1

 DC.W 144*Q,48+V
 DC.W 193*Q,48+V
 DC.W 144*Q,48+V

 DC.W 193*Q,16+V
 DC.W 144*Q,16+V
 DC.W 193*Q,16+V

 DC.W 162*Q,48+V
 DC.W 217*Q,48+V
 DC.W 162*Q,48+V

 DC.W 217*Q,16+V
 DC.W 162*Q,16+V
 DC.W 217*Q,16+V


 DC.W 182*Q,48+V
 DC.W 243*Q,48+V
 DC.W 182*Q,48+V

 DC.W 243*Q,16+V
 DC.W 182*Q,16+V
 DC.W 243*Q,16+V

 DC.W 193*Q,48+V
 DC.W 256*Q,48+V
 DC.W 193*Q,48+V

 DC.W 193*Q,8+V
 DC.W 193*Q,8+V
 DC.W 172*Q,8+V
 DC.W 172*Q,8+V
 DC.W 153*Q,8+V
 DC.W 153*Q,8+V



 DC.W $FFFF,$FFFF


W=8

T2
 DC.W 144*W,16
 DC.W 144*W,4
 DC.W 0,12+D
 DC.W 144*W,4
 DC.W 0,12+D

 DC.W 193*W,16
 DC.W 144*W,4
 DC.W 0,12+D
 DC.W 144*W,4
 DC.W 0,12+D

 DC.W 144*W,16
 DC.W 144*W,4
 DC.W 0,12+D
 DC.W 144*W,4
 DC.W 0,12+D

 DC.W 193*W,16
 DC.W 144*W,4
 DC.W 0,12+D
 DC.W 144*W,4
 DC.W 0,12+D
**** G

 DC.W 162*W,16
 DC.W 162*W,4
 DC.W 0,12+D
 DC.W 162*W,4
 DC.W 0,12+D

 DC.W 217*W,16
 DC.W 162*W,4
 DC.W 0,12+D
 DC.W 162*W,4
 DC.W 0,12+D

 DC.W 162*W,16
 DC.W 162*W,4
 DC.W 0,12+D
 DC.W 162*W,4
 DC.W 0,12+D

 DC.W 217*W,16
 DC.W 162*W,4
 DC.W 0,12+D
 DC.W 162*W,4
 DC.W 0,12+D
****** F

 DC.W 182*W,16
 DC.W 182*W,4
 DC.W 0,12+D
 DC.W 182*W,4
 DC.W 0,12+D

 DC.W 243*W,16
 DC.W 182*W,4
 DC.W 0,12+D
 DC.W 182*W,4
 DC.W 0,12+D


 DC.W 182*W,16
 DC.W 182*W,4
 DC.W 0,12+D
 DC.W 182*W,4
 DC.W 0,12+D

 DC.W 243*W,16
 DC.W 182*W,4
 DC.W 0,12+D
 DC.W 182*W,4
 DC.W 0,12+D

******* C


 DC.W 193*W,16
 DC.W 193*W,4
 DC.W 0,12+D
 DC.W 193*W,4
 DC.W 0,12+D

 DC.W 256*W,16
 DC.W 193*W,4
 DC.W 0,12+D
 DC.W 193*W,4
 DC.W 0,12+D

 DC.W 193*W,16
 DC.W 193*W,4
 DC.W 0,12+D
 DC.W 193*W,4
 DC.W 0,12+D

 DC.W 193*W,16
 DC.W 172*W,16
 DC.W 153*W,16



 DC.W $FFFF,$FFFF

g=13*256
B=1
B1
 DC.W 144*B,48*2+g
 DC.W 144*B,48*2+g
 DC.W 162*B,48*2+g
 DC.W 162*B,48*2+g
 DC.W 243*B,48*2+g
 DC.W 243*B,48*2+g
 DC.W 256*B,48*2+g
 DC.W 256*B,48*2+g



I=2
R=1536
B3 DC.W 0,5+2304
B2
 DC.W 144/I,48+R
 DC.W 193/I,48+R
 DC.W 144/I,48+R

 DC.W 193/I,16+R
 DC.W 144/I,16+R
 DC.W 193/I,16+R

 DC.W 162/I,48+R
 DC.W 217/I,48+R
 DC.W 162/I,48+R

 DC.W 217/I,16+R
 DC.W 162/I,16+R
 DC.W 217/I,16+R


 DC.W 182/I,48+R
 DC.W 243/I,48+R
 DC.W 182/I,48+R

 DC.W 243/I,16+R
 DC.W 182/I,16+R
 DC.W 243/I,16+R

 DC.W 193/I,48+R
 DC.W 256/I,48+R
 DC.W 193/I,48+R

 DC.W 193/I,16+R
 DC.W 172/I,16+R
 DC.W 153/I,16+R



 DC.W $FFFF,$FFFF

XB=512
wb=1536
*-*
bull
 DC.W 144*W,128+wb
 dc.w 0,16
 dc.w 193,8+Xb
 dc.w 193,8+Xb
 dc.w 144,8+Xb
 dc.w 144,8+Xb
 dc.w 193,8+Xb
 dc.w 193,8+Xb


**** G
 DC.W 162*W,128+wb
 dc.w 0,16
 dc.w 217,8+Xb
 dc.w 217,8+Xb
 dc.w 162,8+Xb
 dc.w 162,8+Xb
 dc.w 217,8+Xb
 dc.w 217,8+Xb


****** F
 DC.W 182*W,128+wb
 dc.w 0,16
 dc.w 243,1+Xb
 dc.w 0,7
 dc.w 243,1+Xb
 dc.w 0,7
 dc.w 182,1+Xb
 dc.w 0,7
 dc.w 182,1+Xb
 dc.w 0,7
 dc.w 243,16+Xb

*******E
 DC.W 193*W,128+wb
 dc.w 0,64

 DC.W $FFFF,$FFFF
