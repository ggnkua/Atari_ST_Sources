
; DON'T FUCK ROUND


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


;FF CMP.B #97,$FFFC02
;  BNE.S FF

 
VBI  
 movem.l d0-d3/a0-a6,-(sp)

 add #11,jum
; add.b #180,dri
; BCC FLO




;\\\\\\\\\\\\\
 MOVE.L UPTO,A2
 MOVE CUNT,D3
 MOVE.B 33(A2),D4
SSU SUBQ.W #1,D3
 Bpl.S PART1

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
 clr val

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



jum dc.w 0
SV DC.L 0

 DC.B " (C) G.WHEATON.  45 GOLDRILL AVE BOLTON. LANCS, U.K. "


UPTO DC.L EE-36
CUNT DC.W 0
 EVEN
;\\RUNNING ORDER SEQUENCE
ee
doth
 DC.L PNT5,bast b
 DC.L PNT0,clong
 DC.L PNT2,bb
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+64*4


 DC.L PNT5,bast b
 DC.L PNT1,bb
 DC.L PNT2,gg
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+64*8

 DC.L PNT5,prince
 DC.L PNT1,batman
 DC.L PNT2,bat
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+64*8

 DC.L PNT5,bb
 DC.L PNT1,bbb
 DC.L PNT2,bb
 DC.L PNT3,drm2
 DC.B 1,%00011110
 DC.W -1+64*2

 DC.L PNT5,batman prince
 DC.L PNT1,bat
 DC.L PNT2,prince
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+64*8

 DC.L PNT5,bb
 DC.L PNT1,bbb
 DC.L PNT2,bb
 DC.L PNT3,drm2
 DC.B 1,%00011110
 DC.W -1+64*4





 DC.L PNT5,cc
 DC.L PNT1,ccc
 DC.L PNT2,cc
 DC.L PNT3,drm2
 DC.B 0,%00011110
 DC.W -1+64*4

 DC.L PNT5,bb
 DC.L PNT1,bbb
 DC.L PNT2,bb
 DC.L PNT3,drm2
 DC.B 1,%00011110
 DC.W -1+64*4

 DC.L PNT5,ddd
 DC.L PNT1,bbatman
 DC.L PNT2,dd
 DC.L PNT3,drm2
 DC.B 2,%00011110
 DC.W -1+64*2

 DC.L PNT5,cc
 DC.L PNT1,cbatman
 DC.L PNT2,cc
 DC.L PNT3,drm2
 DC.B 1,%00011110
 DC.W -1+64*2

 DC.L PNT5,bb
 DC.L PNT1,batman
 DC.L PNT2,bat
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+64*4

 DC.L PNT5,clong+4
 DC.L PNT0,clong
 DC.L PNT2,bb
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+64*8

 DC.L PNT4,clon
 DC.L PNT0,clong
 DC.L PNT2,bb
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+64*16

 DC.L PNT6,blr1
 DC.L PNT1,blr
 DC.L PNT2,bl
 DC.L PNT3,drm
 DC.B 2,%00011110
 DC.W -1+64*16







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

 clr rog
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
 dc.l lowt,hag,intdrum,man
 

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
 

VIB moveq #0,d1
 move.b 4(a1),d1
 cmp #12,d1
 blt.s sdc
 

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

 ;SUBQ.B #1,19(A1)
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


;5--1280--
WB1 
 moveq.w #0,d1
 move.b 4(a1),d1
 CMP #32,d1
 BLT.s warp 

 move.b #32,4(a1)
 subq.w #8,20(a1)

warp rts




;6--1536-----WARB UP---------
WRP 
SDX 
 addq.b #4,4(a1)
 LSR 20(A1)
 CMP #65,20(A1)
 BGT PLAP
 MOVE 6(A1),20(A1)
PLAP bra vib


;7--1792---SLIDE-UP--WARBLE
SLW 
 bsr warb
 MOVE.B #4,SL
 MOVE.B 21(A1),SD   ;TMP0+1
 MOVE.B #5,SL
 MOVE.B 20(A1),SD   ;TMP0

 MOVE.B #10,SL
 MOVE.B #13,SD

 MOVE.L (SP)+,D1
 JMP FINK


;--2048---SLIDE UP CONST VOL 
SLR 
 move jum,d1
 and #15,d1
 sub d1,20(A1)
raz RTS



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


;12-------3072  
inup
 add.b #80,m
 bcc wwq
 subq.b #1,4(a1)
 bra vib

m dc.b 0,0

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
 cmp.b #4,4(a1)
 blt.s das
 bra warp

das rts



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


add=4
lim = 216+47
;20


LOWt 
 move fl,d1
 add d1,val

 bpl.s dww

 move #add,fl
 clr val

dww 
 cmp #lim,val
 blt.s hh

 move #-add,fl 
 move #lim,val

hh
 MOVE.B #34,4(A1)
 move val,d1
 move 6(a1),20(a1)
 sub d1,20(A1)

 bra warb
 RTS


val dc.w 0
fl dc.w add




;21--------dw g
hag
 ADDQ.B #1,RONK
 move.b RONK,d1
 and #3,d1
 asl #1,d1
 move ddw(pc,d1),20(a1)
 rts

ddw dc.w 162,108,81,54

;23 

man
;22 
intdrum

 addq.b #8,rog
 bcc vib

 add.b #32,rog+1
 move.b rog+1,4(a1)
  
hex bra vib

rog dc.b 0,0

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
 DC.W 16     ;16(A1)  ADD
 DC.W 0      ;VIB 18(A1)
 DC.L 0      ;TMP NOTE 20(A1)
 DC.B 1,1    ;VIB RATE 24(A1)
 DC.B 0,0    ;INITIAL VOL
;ADSR  28(A1)

 DC.B 15,14,13,13,12,12,12,11,11,11

 DC.B 10,10
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

 DC.B 15,15,14,14,13,13,13,13

 dcb.b 16,12
 dcb.b 16,11
 dcb.b 20,10
 dcb.b 20,9
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
 DC.W 17          ;VIB LIMIT
 DC.W 10          ;VIBRATO ADD 16(A1)
 DC.W 2          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
ADSR
*-*
 dc.b 15,15,14,14,13,13,12,12,11,11

 DCB.B 4,13
 DCB.B 12,11
 DCB.B 16,11
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


 DC.B 15,14,14,13,12,12,12
 DC.B 11,9,10,9,9,9,9,9,8,8,7



 EVEN
PNT4 DC.W 0
NP4 DC.W 1      ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0
 DC.B 8,0,1      ;10(A1) VOL REG
 DC.B 0          ;ADD 13(A1)
 DC.W 162        ;VIB LIMIT
 DC.W 15          ;VIBRATO ADD 16(A1)
 DC.W 0          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)


 DCB.B 10,11
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
 DC.W 3       ;VIB ADD 16(A1)
 DC.W 0       ;VIB 18(A1)
 DC.L 0       ;TEMP NOTE 20(A1)
 DC.B 1,1     ;VIB RATE  24)A1)
 DC.B 0,0     ;INITIAL VOL
;ADSR  28(A1)

 DCb.B 8,14
 DCb.B 8,13
 DCb.B 8,12
 DCb.B 8,11
 DCb.B 8,10
 DCb.B 8,9
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
 DC.B 8,0,1
 DC.B 0       ;ADD  13(A1)
 DC.W 4       ;VIB LIMIT
 DC.W 3       ;VIB ADD 16(A1)
 DC.W 0       ;VIB 18(A1)
 DC.L 0       ;TEMP NOTE 20(A1)
 DC.B 1,1     ;VIB RATE  24)A1)
 DC.B 0,0     ;INITIAL VOL
;ADSR  28(A1)

 DC.B 12,11,10,9,8
 DCb.B 50,7
 DCb.B 50,6
 DCb.B 20,5
 DCb.B 20,4
 DCb.B 80,3
 DCb.B 8,2
 DCb.B 64,1




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
 dc.w 0,16+1024
 dc.w 4,4+768
 dc.w 3,12++1024
 DC.W $FFFF,$FFFF


drm2
 dc.w 0,16+1024
 dc.w 4,4+768
 dc.w 3,12++1024

 dc.w 0,16+1024
 dc.w 4,4+768
 dc.w 3,12++1024

 dc.w 0,16+1024
 dc.w 4,4+768
 dc.w 3,12+1024

 dc.w 1,4+768
 dc.w 0,6+1024
 dc.w 1,1+768
 dc.w 0,5+1024
 dc.w 1,4+768
 dc.w 0,4+1024
 dc.w 1,1+768

 dc.w 3,7++1024

 DC.W $FFFF,$FFFF



e=1536
a=8
prince 
 dc.w 216*a,8+e
 dc.w 172*a,8+e
 dc.w 144*a,8+e
 dc.w 108*a,8+e
 dc.w 121*a,8+e
 dc.w 128*a,8+e
 dc.w 144*a,8+e

 dc.w 216*a,8+e
 dc.w 144*a,8+e
 dc.w 162*a,8+e
 dc.w 172*a,8+e

 dc.w 216*a,8+e
 dc.w 172*a,8+e
 dc.w 192*a,8+e
 dc.w 216*a,16+e
 DC.W $FFFF,$FFFF

cbatman
 dc.w 144,8+21*256
 dc.w 0,8+d
 dc.w 144,48+21*256
 dc.w 0,64+d
 DC.W $FFFF,$FFFF


bbatman
 dc.w 144,8+14*256
 dc.w 0,8+d
 dc.w 144,48+14*256
 dc.w 0,64+d
 DC.W $FFFF,$FFFF


batman
 dc.w 216,8+18*256
 dc.w 0,8+d
 dc.w 216,48+18*256
 dc.w 0,64+d
 DC.W $FFFF,$FFFF

bat
 dc.w 216*2,8
 dc.w 0,8+d
 dc.w 216*2,48+v
 dc.w 216*8,64+2048
 DC.W $FFFF,$FFFF

 
x=8
bb
 dc.w 216*x,8
 dc.w 216*x,8
 
 dc.w 230*x,8
 dc.w 230*x,8

 dc.w 243*x,8
 dc.w 243*x,8

 dc.w 230*x,8
 dc.w 230*x,8
 DC.W $FFFF,$FFFF

f=16
bbb
 dc.w 216*f,8
 dc.w 216*f,8
 
 dc.w 230*f,8
 dc.w 230*f,8

 dc.w 243*f,8
 dc.w 243*f,8

 dc.w 230*f,8
 dc.w 230*f,8
 DC.W $FFFF,$FFFF


cc
 dc.w 162*x,8
 dc.w 162*x,8
 
 dc.w 172*x,8
 dc.w 172*x,8

 dc.w 182*x,8
 dc.w 182*x,8

 dc.w 172*x,8
 dc.w 172*x,8
 DC.W $FFFF,$FFFF

ccc
 dc.w 162*f,8
 dc.w 162*f,8
 
 dc.w 172*f,8
 dc.w 172*f,8

 dc.w 182*f,8
 dc.w 182*f,8

 dc.w 172*f,8
 dc.w 172*f,8
 DC.W $FFFF,$FFFF

dd
 dc.w 144*x,8
 dc.w 144*x,8
 
 dc.w 153*x,8
 dc.w 153*x,8

 dc.w 162*x,8
 dc.w 162*x,8

 dc.w 153*x,8
 dc.w 153*x,8
 DC.W $FFFF,$FFFF

ddd
 dc.w 144*f,8
 dc.w 1442*f,8
 
 dc.w 153*f,8
 dc.w 153*f,8

 dc.w 162*f,8
 dc.w 162*f,8

 dc.w 153*f,8
 dc.w 153*f,8
 DC.W $FFFF,$FFFF


bast
 dc.w 0,8+18*256
 dc.w 0,24+d
 dc.w 54,8+1536
 dc.w 0,24+d

 dc.w 0,8+18*256
 dc.w 0,24+d
 dc.w 54,8+1536
 dc.w 0,8+d
 dc.w 54,8+1536
 dc.w 0,8+d

 DC.W $FFFF,$FFFF


GG 
 DC.W 162*4,64+20*256
 DC.W $FFFF,$FFFF



clon 
 dc.w 172*2,16+v
 dc.w 121*2,8+v

 dc.w 172*2,8+v
 dc.w 121*2,16+v
 dc.w 144*2,16+v
 dc.w 162*2,16+v
 dc.w 108*2,8+v
 dc.w 0,8+d
 dc.w 128*2,8+v
 dc.w 0,8+d

 dc.w 108*4,64+v

 DC.W 54,32+20*256
 DC.W 162,32+20*256
 dc.w 121*4,16+v

 dc.w 172*2,4+v
 dc.w 0,4+d
 dc.w 172*2,8+v
 dc.w 121*2,8+v

 dc.w 172*2,8+v
 dc.w 121*2,16+v
 dc.w 144*2,16+v
 dc.w 162*2,16+v
 dc.w 108*2,8+v
 dc.w 0,8+21*256
 dc.w 128*2,8+v
 dc.w 0,8+14*256

 dc.w 108*2,64+v



clong
 dc.w 108*4,64+v
 dc.w 0,8+18*256
 dc.w 144*4,16+v
 dc.w 108*2,24+v
 dc.w 162*4,32+v
 DC.W $FFFF,$FFFF





v1=22*256

bl
 dc.w 108*16,128+v1
 dc.w 144*8,128+v1
 dc.w 162*8,128+v1
 dc.w 144*8,128+v1
 dc.w 182*8,128+v1
 dc.w 162*8,64+v1
 dc.w 182*8,64+v1
 dc.w 193*8,128-16+v1
 dc.w 144*8,8+v1
 dc.w 136*8,8+v1
 dc.w 144*8,128+v1

blr
 dc.w 108*16,128+v1
 dc.w 144*8,127+v1
 dc.w 162*16,128+v1
 dc.w 144*16,129+v1
 dc.w 182*16,128+v1
 dc.w 162*16,64+v1
 dc.w 182*16,64+v1
 dc.w 193*16,128-16+v1
 dc.w 144*16,8+v1
 dc.w 136*16,8+v1
 dc.w 144*8,128+v1

v2=23*256
blr1
 dc.w 108,128+v2
 dc.w 144,127+v2
 dc.w 162,128+v2
 dc.w 144,129+v2
 dc.w 182,128+v2
 dc.w 162,64+v2
 dc.w 182,64+v2
 dc.w 193,128-15+v2
 dc.w 144,8+v2
 dc.w 136,8+v2
 dc.w 144,128+v





