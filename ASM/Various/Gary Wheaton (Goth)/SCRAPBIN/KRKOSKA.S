
;       DON'T FUCK ROUND
; the angel of death is my mother.


 CLR.L -(SP)       ; Enter supervisor mode.
 MOVE.W #$20,-(SP) ; Super.
 TRAP #1
 ADDQ.L #6,SP
 MOVE.L D0,SV


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


bi
 MOVE.B $469,D0
FT CMP.B $469,D0
 BEQ.S FT

 bsr vbi


 CMP.B #97,$FFFC02
 BNE BI

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



 
VBI  
 movem.l d0-d3/a0-a6,-(sp)
; add.b #230,dri
; BCC FLO




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
 MOVE.L #1,PNT6
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






flo

 movem.l (sp)+,d0-d3/a0-a6 
killer rts






SV DC.L 0

 DC.B " (C) G.WHEATON.  45 GOLDRILL AVE BOLTON. LANCS, U.K. "


UPTO DC.L EE-36
CUNT DC.W 0
 EVEN
;\\RUNNING ORDER SEQUENCE

ee
doth

 DC.L PNT5,fr
 DC.L PNT1,mb1 en
 DC.L PNT2,mb
 DC.L PNT3,drm3
 DC.B 1,%00011110
 DC.W -1+64*8

 DC.L PNT5,sud
 DC.L PNT1,sud1
 DC.L PNT2,sud
 DC.L PNT3,drm3
 DC.B 1,%00011110
 DC.W -1+64*8




 DC.L PNT5,mb en1
 DC.L PNT1,mb1 en
 DC.L PNT2,mb
 DC.L PNT3,drm3
 DC.B 1,%00011110
 DC.W -1+64*4

 DC.L PNT5,mbc2 
 DC.L PNT1,mbc1 
 DC.L PNT2,mbc2
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+64*4

 DC.L PNT5,mb en1
 DC.L PNT1,mb1 en
 DC.L PNT2,mb
 DC.L PNT3,drm4
 DC.B 1,%00011110
 DC.W -1+64*4


 DC.L PNT5,mbe
 DC.L PNT1,mbe+4 en
 DC.L PNT2,mbe
 DC.L PNT3,drm4
 DC.B 1,%00011110
 DC.W -1+64*2

 DC.L PNT5,mbc1 
 DC.L PNT1,mbc1+4 
 DC.L PNT2,mbc1+8
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+64*2








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

coll 
 addq.b #1,4(a1)
 bra wwq

VV EOR.B #1,MC
 BEQ.S SDC
 

VIB 

WWQ 
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
 ADDQ.B #2,4(A1)
 lSR 20(A1)
 CMP #28,20(A1)
 BGT.S PLOP

 MOVE 6(A1),20(A1)
PLOP RTS


;3--768--------DRUM-----------
DRUM 

 SUBQ.B #1,19(A1)
 MOVE.B #7,SL
 MOVE.B #%11011000,SD
 MOVE.B #6,SL
 MOVE.B 19(A1),SD

 MOVE.B #5,SL
 MOVE.B 32(A2),SD

 MOVE.B #4,SL
 MOVE.B 21(A1),D0
 ASL.B #5,D0
 MOVE.B D0,SD
JUNK RTS


lil dc.b 0,0

;------4 1024
slip 


;5--1280--
WB1 
 moveq.w #0,d1
 move.b 4(a1),d1
 CMP #32,d1
 BLT wwq 

 move.b #32,4(a1)
 subq.w #6,6(a1)
 cmp #81*8,6(a1)
 bgT.s warp

 move #81*8,6(a1) 

warp BRA wwq




;6--1536-----WARB UP---------
WRP 
SDX 
 addq.b #1,4(a1)
 LSR 20(A1)
 CMP #65,20(A1)
 BGT PLAP
 MOVE 6(A1),20(A1)
PLAP bra vib


;7--1792---SLIDE-UP--WARBLE
SLW 
 MOVE.B #15,4(A1)
 ADD.W #49,20(A1)
 RTS


; MOVE.B #7,4(a1)
; BRA wwq

;--2048---SLIDE UP CONST VOL 
SLR 
 MOVE.B #10,4(A1)
 SUB.W #43,20(A1)
 RTS



YIN DC.B 0,0
;9--2304-------HOLD-------------
HOLD MOVE.B #50,4(A1)
 RTS

;------10 2560
TWERP 
 MOVE.B #7,SL
 MOVE.B #%11011100,SD
 MOVE.B #6,SL
 MOVE.B 19(A1),SD
 RTS


 rts


;11-------2816 SLIDE UP WITH ADSR
SLR1
 addq.b #1,4(a1) 
dip rts


tp dc.b 0,0
;12-------3072  
inup
 addq.b #3,4(a1)
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

ronk dc.b 0,0

;15--------DW G
holl
 tst.b 4(a1)
 bne VIB

 move.b #20,4(a1) 
 BRA VIB




;17--------DW F
Foll
 move.b #15,4(a1)

;18--------DW Am
aoll

 addq.b #2,4(A1)
 addq.b #1,RONK
 move.b RONK,d1
 and #3,d1
 asl #1,d1
 move aq(pc,d1),20(a1)
 rts

aq dc.w 108,72,54,45


;19--------DW E
eoll
 addq.b #2,4(A1)
 BRA WARB VIB




;\\\\\\\\\\\\\\DATAS\\\\\\\\\\\\\\\
;\\NOTE 1ST WORD. DURATION 2ND WORD
;\\\LEAD
PNT0 DC.W 0
NP0 DC.W 1
 DC.W 0
 DC.L 0
 DC.B 9,2,3
 DC.B 1      ;ADD TO NOTE
 DC.W 5      ;VIB LIMIT
 DC.W 3      ;16(A1)  ADD
 DC.W 0      ;VIB 18(A1)
 DC.L 0      ;TMP NOTE 20(A1)
 DC.B 1,1    ;VIB RATE 24(A1)
 DC.B 0,0    ;INITIAL VOL
;ADSR  28(A1)

 DC.B 15,14,13,13,12,12,12,11,11,11
 DC.B 10,9

 dcb.b	50,9
 dcb.b	50,8
 DCb.B  50,7
 DCb.B  50,6



 EVEN
;\\\MIDDLE
PNT1 DC.W 0
 DC.W 1       ;EFFECT & DURATION 2(A1)
 DC.B 0,0
 DC.L 0
 DC.B 9,2,3
 DC.B 0       ;ADD  13(A1)
 DC.W 4       ;VIB LIMIT
 DC.W 3       ;VIB ADD 16(A1)
 DC.W 0       ;VIB 18(A1)
 DC.L 0       ;TEMP NOTE 20(A1)
 DC.B 1,1     ;VIB RATE  24)A1)
 DC.B 0,0     ;INITIAL VOL
;ADSR  28(A1)

 DC.B 15,15,15,14,14,14,13,13,13,13

 dcb.b 8,12
 dcb.b 8,11
 dcb.b 8,10
 dcb.b 8,9
 dcb.b 120,8
 dcb.b 40,6
 dcb.b 40,5




 EVEN
;\\\BASS
PNT2 DC.W 0
 DC.W 1          ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0          ;6
 DC.B 10,4,5     ;10(A1) VOL REG
 DC.B 1          ;ADD TO NOTE 13(A1)
 DC.W 2          ;VIB LIMIT
 DC.W 3          ;VIBRATO ADD 16(A1)
 DC.W 2          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
ADSR
*-*
 dc.b 15,15,15,14,14,13,12,12

 DCB.B 8,12
 DCB.B 8,11
 DCB.B 20,10
 DCB.B 10,9
 DCB.B 10,8
 DCB.B 20,7
 DCB.B 20,5
 DCB.B 50,4
 DCB.B 150,3




 EVEN
PNT3 DC.W 0
NP3 DC.W 1      ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0          ;6
 DC.B 10,6,11    ;10(A1) VOL REG
 DC.B -1         ;ADD  13(A1)
 DC.W 4          ;VIB LIMIT
 DC.W 3          ;VIBRATO ADD 16(A1)
 DC.W 0          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)


 DC.B 15,15,14,13,12,11,11,11
 DC.B 10,9,8,8,7,7,6,5,4,3,2,1



 EVEN
PNT4 DC.W 0
NP4 DC.W 1      ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0
 DC.B 9,2,3      ;10(A1) VOL REG
 DC.B 0          ;ADD 13(A1)
 DC.W 3          ;VIB LIMIT
 DC.W 4          ;VIBRATO ADD 16(A1)
 DC.W 0          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)

 DC.B 11,11,11,12,12,12

 DCB.B 10,13
 DC.B 13,13,12,12,11,11
 DCB.B 5,10
 DCB.B 22,8
 DCB.B 22,6





PNT5 DC.W 0
 DC.W 1       ;EFFECT & DURATION 2(A1)
 DC.B 0,0
 DC.L 0
 DC.B 8,0,1
 DC.B 0       ;ADD  13(A1)
 DC.W 2       ;VIB LIMIT
 DC.W 1       ;VIB ADD 16(A1)
 DC.W 0       ;VIB 18(A1)
 DC.L 0       ;TEMP NOTE 20(A1)
 DC.B 1,1     ;VIB RATE  24)A1)
 DC.B 0,0     ;INITIAL VOL
;ADSR  28(A1)

 dc.b 15,15,14,14,13
 DCb.B 6,12
 DCb.B 6,11
 DCb.B 2,12
 DCb.B 2,11
 DCb.B 2,10
 DCb.B 2,9
 DCb.B 10,8
 DCb.B 50,7
 DCb.B 50,6
 DCb.B 20,5
 DCb.B 20,4
 DCb.B 80,3


PNT6 DC.W 0
 DC.W 1       ;EFFECT & DURATION 2(A1)
 DC.B 0,0
 DC.L 0
 DC.B 9,2,3
 DC.B 0       ;ADD  13(A1)
 DC.W 4       ;VIB LIMIT
 DC.W 5       ;VIB ADD 16(A1)
 DC.W 0       ;VIB 18(A1)
 DC.L 0       ;TEMP NOTE 20(A1)
 DC.B 1,1     ;VIB RATE  24)A1)
 DC.B 0,0     ;INITIAL VOL
;ADSR  28(A1)

 DC.B 15,15,14,14,13,12,13,12,12,12,11,11,11,10,10,10
 DC.B 14,13,13,13,13,12,12,11
 dc.b 13,12,11,11,10,10,9,8
 dc.b 13,12,11,11,10,10,9,8
 dc.b 13,12,11,11,10,10,9,8
 dc.b 13,12,11,11,10,10,9,8
 dc.b 12,12,11,11,10,10,9,8
 dc.b 12,12,11,11,10,10,9,8
 dc.b 12,12,11,11,10,10,9,8
 dc.b 11,11,10,10,9,8,7,6
 dc.b 11,11,10,10,9,8,7,6
 dc.b 11,11,10,10,9,8,7,6
 dc.b 11,11,10,10,9,8,7,6
 dc.b 10,10,9,8,7,6,5,4
 dc.b 10,10,9,8,7,6,5,4
 dc.b 10,10,9,8,7,6,5,4
 dc.b 10,10,9,8,7,6,5,4
 dc.b 8,7,6,5,4,3,2,1
 dc.b 8,7,6,5,4,3,2,1
 dc.b 8,7,6,5,4,3,2,1
 dc.b 8,7,6,5,4,3,2,1
 dc.b 8,7,6,5,4,3,2,1
 dc.b 6,5,4,3,2,1,1,1
 dc.b 6,5,4,3,2,1,1,1
 dc.b 6,5,4,3,2,1,1,1
 dc.b 6,5,4,3,2,1,1,1
 dc.b 5,4,3,2,1,1,1,1
 dc.b 5,4,3,2,1,1,1,1
 dc.b 5,4,3,2,1,1,1,1
 dc.b 5,4,3,2,1,1,1,1
 dc.b 5,4,3,2,1,1,1,1



 EVEN
TE2 DC.W 2,3

MAX DC.B 71,32,87,72,69,65,84,79,78
DRI DC.B 251,0
MIN DC.B 0,0
MC DC.B 0,0
 EVEN

;-----------MUSIC DATA

D=2304
v=256

NULL DC.W 2,128+2304
 DC.W $FFFF,$FFFF


drm
 dc.w 2,1+2560
 dc.w 0,7+1024
 dc.w 2,1+2560
 dc.w 0,7+1024
 dc.w 2,1+2560

 dc.w 0,7+1024
 dc.w 2,1+2560
 dc.w 0,7+1024
 dc.w 2,1+2560
 dc.w 0,7+1024

 dc.w 8,3+768
 dc.w 8,5+1024

 dc.w 2,1+2560
 dc.w 0,7+1024

drm1
 dc.w 2,1+2560
 dc.w 0,7+1024

 DC.W $FFFF,$FFFF

drm3
 dc.w 31,3+768
 dc.w 8,21+1024
 dc.w 2,1+2560
 dc.w 0,7+1024

 dc.w 1,4+768
 dc.w 8,8+12+1024

 dc.w 0,1+768
 dc.w 8,15+1024
 dc.w 0,1+768
 dc.w 8,15+1024
 dc.w 8,3+768
 dc.w 8,5+1024

 dc.w 1,2+768
 dc.w 1,4+1024

 dc.w 8,10+1024

 dc.w 5,16+2560 

 DC.W $FFFF,$FFFF

drm4
 dc.w 31,3+768
 dc.w 8,21+1024
 dc.w 2,1+2560
 dc.w 0,7+1024

 dc.w 1,4+768
 dc.w 8,8+12+1024

 dc.w 0,1+768
 dc.w 0,15+1024
 dc.w 0,1+768
 dc.w 0,15+1024
 dc.w 8,3+768
 dc.w 0,5+1024

 dc.w 1,2+768
 dc.w 0,6+1024

 dc.w 4,2+768
 dc.w 0,6+1024

 dc.w 1,2+768
 dc.w 0,6+1024

 ;dc.w 1,2+768
 dc.w 0,8+1024

 DC.W $FFFF,$FFFF




WOO
 DC.W 0,2*96+D
 DC.W 0,48+D
woo21
 DC.W 162*16,54+2048
 DC.W 162*8,36+1792
 DC.W $FFFF,$FFFF

WOO1
 DC.W 0,2*96+D
 DC.W 0,96+D

woo2
 DC.W 108*4,48+1792
 DC.W $FFFF,$FFFF
e=15*256
s=2

men
 DC.W 216*s,24 +v
 DC.W 108*s,16 +v
 DC.W 121*s,16 +v
 DC.W 128*s,8 + v

 DC.W 144*s,24+v

 DC.W 108*s,16 +v
 DC.W 121*s,16 +v
 DC.W 128*s,8 +v
 DC.W 144*s,24+v

 DC.W 108*s,16 +v
 DC.W 121*s,16 +v
 DC.W 128*s,8 +v
 DC.W 144*s,24+v

 DC.W 108*s,16+v
 DC.W 121*s,16+v
 DC.W 128*s,8+v

 DC.W $FFFF,$FFFF

men1
 DC.W 85*4,1+e
 DC.W 54*4,1+e
 DC.W 72*4,1+e
 DC.W $FFFF,$FFFF


mb
 DC.W 121*16,8+v
 DC.W 108*16,8+v
 DC.W 108*8,8+v
 DC.W 108*16,8+v
 DC.W 108*16,8+v
 DC.W 108*16,8+v
 DC.W 108*16,8+v
 DC.W 108*16,8+v

 DC.W $FFFF,$FFFF

mb1
 DC.W 121*8,8+v
 DC.W 108*8,8+v
 DC.W 108*4,8+v
 DC.W 108*8,8+v
 DC.W 108*16,4+v
 DC.W 108*16,4+v
 DC.W 108*16,4+v
 DC.W 108*16,4+v
 DC.W 108*8,8+v
 DC.W 108*8,8+v

 DC.W $FFFF,$FFFF



mbc2
 DC.W 182*8,8+v
 DC.W 162*8,8+v
 DC.W 162*4,8+v
 DC.W 162*16,8+v
 DC.W 162*8,8+v
 DC.W 162*4,8+v
 DC.W 162*8,8+v
 DC.W 162*8,8+v


 DC.W 182*8,8+v
 DC.W 162*8,8+v
 DC.W 162*4,8+v
 DC.W 162*16,8+v
 DC.W 162*8,8+v
 DC.W 162*1,24+v
; DC.W 162*8,8+v
; DC.W 162*8,8+v

 DC.W $FFFF,$FFFF

mbc
 DC.W 162*8,8+v
 DC.W 162*8,8+v
 DC.W 162*4,8+v
 DC.W 0,8+d

 DC.W 162*8,8+v
 DC.W 162*8,8+v
 DC.W 162*16,8+v
 DC.W 81,8+d

 DC.W $FFFF,$FFFF

mbc1
 DC.W 162*16,8+v
 DC.W 162*16,8+v
 DC.W 162*8,8+v
 DC.W $FFFF,$FFFF


mbe
 DC.W 144*8,8+v
 DC.W 144*8,8+v
 DC.W 144*4,8+v
 DC.W 0,8+d

 DC.W 144*8,8+v
 DC.W 144*8,8+v
 DC.W 144*16,8+v
 DC.W 72,8+d

 DC.W $FFFF,$FFFF

 

u=2
man
 DC.W 162*u,24 +v
 DC.W 216*u,16 +v
 DC.W 216*u,16 +v
 DC.W 216*u,8 +v

 DC.W 192*u,24 +v
 DC.W 192*u,16 +v
 DC.W 192*u,16 +v
 DC.W 192*u,8 +v

 DC.W 172*u,24 +v
 DC.W 172*u,16 +v
 DC.W 172*u,16 +v
 DC.W 172*u,8 +v

 DC.W 192*u,24+v
 DC.W 192*u,16+v
 DC.W 192*u,16+v
 DC.W 192*u,8+v
 dc.w 217*u,32

 DC.W $FFFF,$FFFF
j=2
c=0
man1
 DC.W 81*4,1+e
 DC.W 108*4,1+e
 DC.W 128*4,1+e
 DC.W $FFFF,$FFFF



t=512
n=2
fr1
 DC.W 216*s,3 +v


r=1
fr
 dc.w 108/2,4+t
 dc.w 102/2,4+t
 dc.w 96/2,8+t

 dc.w 102/2,4+t
 dc.w 96/2,4+t
 dc.w 91/2,8+t 

 dc.w 96/2,4+t
 dc.w 91/2,4+t 
 dc.w 85/2,8+t

 dc.w 91/2,4+t 
 dc.w 85/2,4+t
 dc.w 81/2,8+t

 dc.w 72/2,4+t
 dc.w 85/2,4+t 
 dc.w 108/2,8+t

 dc.w 81/2,4+t
 dc.w 96/2,4+t 
 dc.w 121/2,8+t

 dc.w 85/2,4+t
 dc.w 102/2,4+t 
 dc.w 128/2,8+t

 dc.w 108/2,4+t
 dc.w 121/2,4+t 
 dc.w 144/2,8+t


 dc.w 108/4,4+t
 dc.w 102/4,4+t
 dc.w 96/4,8+t

 dc.w 102/4,4+t
 dc.w 96/4,4+t
 dc.w 91/4,8+t 

 dc.w 96/4,4+t
 dc.w 91/4,4+t 
 dc.w 85/4,8+t

 dc.w 91/4,4+t 
 dc.w 85/4,4+t
 dc.w 81/4,8+t

 dc.w 72/4,4+t
 dc.w 85/4,4+t 
 dc.w 108/4,8+t

 dc.w 81/4,4+t
 dc.w 96/4,4+t 
 dc.w 121/4,8+t

 dc.w 85/4,4+t
 dc.w 102/4,4+t 
 dc.w 128/4,8+t

 dc.w 108/4,4+t
 dc.w 121/4,4+t 
 dc.w 144/4,8+t

 DC.W $FFFF,$FFFF


sud
 dc.w 121*8,112+v
 dc.w 108*8,8
 dc.w 108*8,8
 dc.w 121*8,56+v
 dc.w 108*8,8
 dc.w 121*8,8
 dc.w 121*8,8
 dc.w 121*16,12
 dc.w 0,4+d
 dc.w 114*8,16
 dc.w 114*16,12
 dc.w 0,4+d
 dc.w 108*8,128+v
 dc.w 121*16,64+d
 dc.w 108*16,128+d

sud1
 dc.w 121*16,255+d
 dc.w 108*16,255+d
 DC.W $FFFF,$FFFF



 