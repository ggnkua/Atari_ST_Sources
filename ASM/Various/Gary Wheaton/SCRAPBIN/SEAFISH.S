 CLR.L -(SP)       
 MOVE.W #$20,-(SP) ; Super.
 TRAP #1
 ADDQ.L #6,SP
 MOVE.L D0,SV   ; Save old status.


 MOVE.B #0,SL
 MOVE.B #96,SD
 MOVE.B #8,SL
 MOVE.B #12,SD

DD CMP.B #97,$FFFC02
; BNE.S DD
 

play
******************
 move.b $469,d0  *
ww cmp.b $469,d0 *
 beq.s ww	 *
******************


 bsr vbi


 cmp.b #97,$fffc02
 bne play


	lea	$ff8800,a0	get sound chip 
	move.b	#7,(a0)
	move.b	#%11111111,2(a0) cut out lingering noise
	move.l #$8000000,$ff8800 
	move.l #$9000000,$ff8800 
	move.l #$a000000,$ff8800 


 MOVE.L SV,-(SP)
 MOVE.W #$20,-(SP)
 TRAP #1
 ADDQ.L #6,SP

 CLR -(SP)
 TRAP #1





*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*


SL EQU $FF8800
SD EQU $FF8802
 move.b #7,sl
 move.b #%11111000,sd


 
VBI  
 add.b #240,flo
 bcc killer

 movem.l d0-d3/a0-a6,-(sp)



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
;--END OF VBI
;--------EXIT


 movem.l (sp)+,d0-d3/a0-a6 
killer rts


flo dc.b 0,0
SV DC.L 0

 DC.B " (C) G.WHEATON. 60 NEVIS GROVE. BOLTON. UK. "

 EVEN
UPTO DC.L EE-36
CUNT DC.W 0
 EVEN
;\\RUNNING ORDER SEQUENCE

ee
doth
 DC.L PNT5,b1 null
 DC.L PNT0,bk
 DC.L PNT2,B1
 DC.L PNT3,DRM
 DC.B 2,%00001110
 DC.W -1+4*64

 DC.L PNT5,bb2
 DC.L PNT0,bbk
 DC.L PNT2,Bb2
 DC.L PNT3,DRM
 DC.B 2,%00001110
 DC.W -1+2*64

 DC.L PNT5,b1 null
 DC.L PNT0,bk
 DC.L PNT2,B1
 DC.L PNT3,DRM
 DC.B 2,%00001110
 DC.W 63


 DC.L PNT5,t1
 DC.L PNT0,bk
 DC.L PNT2,B1
 DC.L PNT3,DRM
 DC.B 2,%00001110
 DC.W -1+4*64

 DC.L PNT5,t2
 DC.L PNT0,b2
 DC.L PNT2,Bk1
 DC.L PNT3,DRM
 DC.B 2,%00001110
 DC.W -1+4*64


 DC.L PNT5,t1
 DC.L PNT0,BK
 DC.L PNT2,B1
 DC.L PNT3,DRM
 DC.B 2,%00011110
 DC.W -1+4*64

 DC.L PNT5,t2
 DC.L PNT0,BK1
 DC.L PNT2,B2
 DC.L PNT3,DRM
 DC.B 2,%00011110
 DC.W -1+4*64

 DC.L PNT5,t1
 DC.L PNT0,BK
 DC.L PNT2,B1
 DC.L PNT3,DRM
 DC.B 2,%00011110
 DC.W -1+4*64

 DC.L PNT5,t2
 DC.L PNT0,BK1
 DC.L PNT2,B2
 DC.L PNT3,DRM
 DC.B 2,%00011110
 DC.W -1+4*64




CHAN0
*******************
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
VIB CMP.B #12,4(A1)
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
 eor.b #1,lil
 bne.s junk
 SUB.B #23,21(A1)
 MOVE.B #7,SL
 MOVE.B #%11011000,SD
 MOVE.B #6,SL
 MOVE.B 21(A1),SD
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

 DC.B 9,9,9,8,8,7,7,6,6,5,5
 dcb.b	50,4



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

 DC.B 3,11,10,9
 dcb.b	250,8




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
 DC.B 14,13,12,10
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
 DCB.B 8,8
 DCB.B 8,7
 DCB.B 8,6
 DCB.B 8,5
 DCB.B 8,4
 DCB.B 8,3
 DCB.B 8,2
 DCB.B 8,1
 DCB.B 8,2
 DCB.B 8,3
 DCB.B 8,4
 DCB.B 8,3
 DCB.B 8,2





 EVEN
TE2 DC.W 2,3

MAX DC.B 71,32,87,72,69,65,84,79,78
DRI DC.B 251,0
MIN DC.B 0,0
MC DC.B 0,0
 EVEN

;-----------MUSIC DATA
V=256
drm
 dc.w 0,24+1024
 dc.w 1,1+768
 dc.w 0,7+1024

 dc.w 6,4+768
 dc.w 0,12+1024
 dc.w 2,6+768
 dc.w 0,10+1024

 dc.w 0,32+1024
 dc.w 6,4+768
 dc.w 0,12+1024
 dc.w 0,16+1024

 dc.w 0,32+1024
 dc.w 6,4+768
 dc.w 0,12+1024
 dc.w 0,16+1024

 dc.w 0,32+1024
 dc.w 6,4+768
 dc.w 0,12+1024
 dc.w 0,16+1024

 DC.W $FFFF,$FFFF



NULL DC.W 2,128+2304
 DC.W $FFFF,$FFFF

q=2
t1 
 DC.W 0,40+2304
 dc.w 144*q,8
 dc.w 128*q,8
 dc.w 121*q,8
 dc.w 96*q,40+V

 dc.w 144*q,8
 dc.w 128*q,8
 dc.w 121*q,8
 dc.w 96*q,16+V

 dc.w 108*q,8
 dc.w 121*q,8
 dc.w 108*q,16
 dc.w 96*q,8
 dc.w 144*q,24+48+V
 DC.W 0,64+2304

 DC.W $FFFF,$FFFF

t2 
 DC.W 0,40+2304
 dc.w 144*q,8
 dc.w 128*q,8
 dc.w 121*q,8
 dc.w 108*q,40+V

 dc.w 144*q,8
 dc.w 128*q,8
 dc.w 121*q,8
 dc.w 108*q,16+V

 dc.w 121*q,8
 dc.w 128*q,8
 dc.w 121*q,16
 dc.w 108*q,8
 dc.w 144*q,24+48+V
 DC.W $FFFF,$FFFF



B1
 DC.W 162*8,8
 DC.W 144*8,8
 DC.W 144*8,8
 DC.W 144*8,8
 DC.W 144*8,8
 DC.W 144*8,8
 DC.W 144*8,16
; DC.W 144*8,8
 DC.W $FFFF,$FFFF

B2

 DC.W 162*8,8
 DC.W 144*8,8
 DC.W 144*8,8
 DC.W 144*8,8
 DC.W 144*8,8
 DC.W 144*8,8
 DC.W 144*8,8
 DC.W 144*8,8

bb2
 DC.W 121*8,8
 DC.W 108*8,8
 DC.W 108*8,8
 DC.W 108*8,8
 DC.W 108*8,8
 DC.W 108*8,8
 DC.W 108*8,8
 DC.W 108*8,8

 DC.W 121*8,8
 DC.W 108*8,8
 DC.W 108*8,8
 DC.W 108*8,8
 DC.W 108*8,8
 DC.W 108*8,8
 DC.W 108*8,8
 DC.W 108*8,8
 DC.W $FFFF,$FFFF

I=1
bk
 DC.W 144*I,8
 DC.W 121*I,8
 DC.W 96*I,8
 DC.W 121*I,8
 DC.W 108*I,8
 DC.W 121*I,8
 DC.W 144*I,8
 DC.W 121*I,8

 DC.W 144*I,8
 DC.W 121*I,8
 DC.W 96*I,8
 DC.W 121*I,8
 DC.W 108*I,8
 DC.W 121*I,8
 DC.W 144*I,8
 DC.W 121*I,8

 DC.W 144*I,8
 DC.W 121*I,8
 DC.W 96*I,8
 DC.W 121*I,8
 DC.W 108*I,8
 DC.W 121*I,8
 DC.W 144*I,8
 DC.W 121*I,8

 DC.W $FFFF,$FFFF

bk1
 DC.W 144*I,8
 DC.W 121*I,8
 DC.W 96*I,8
 DC.W 121*I,8
 DC.W 108*I,8
 DC.W 121*I,8
 DC.W 144*I,8
 DC.W 121*I,8

bbk
 DC.W 144*I,8
 DC.W 108*I,8
 DC.W 121*I,8
 DC.W 144*I,8
 DC.W 121*I,8
 DC.W 144*I,8
 DC.W 162*I,8
 DC.W 144*I,8

 DC.W 144*I,8
 DC.W 108*I,8
 DC.W 121*I,8
 DC.W 144*I,8
 DC.W 121*I,8
 DC.W 144*I,8
 DC.W 162*I,8
 DC.W 144*I,8

 DC.W $FFFF,$FFFF

