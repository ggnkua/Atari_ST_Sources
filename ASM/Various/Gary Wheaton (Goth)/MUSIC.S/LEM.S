

 CLR.L -(SP)       ; Enter supervisor mode.
 MOVE.W #$20,-(SP) ; Super.
 TRAP #1
 ADDQ.L #6,SP
 MOVE.L D0,SV


SL EQU $FF8800
SD EQU $FF8802

 LEA SL,A0
 move.b #7,(a0)
 move.b #%11111000,2(a0)
 MOVE.L #$08000000,(A0)
 MOVE.L #$09000000,(A0)
 MOVE.L #$0A000000,(A0)


bi
 MOVE.B $469,D0
FT CMP.B $469,D0
 BEQ.S FT

 bsr vbi

 CMP.B #97,$FFFC02
 BNE BI


 MOVE #$777,$FF8240  
 clr $FF8240+30
 MOVE.L SV,-(SP)
 MOVE #$20,-(SP)
 TRAP #1
 ADDQ.L #6,SP
 
 CLR -(SP)
 TRAP #1


g 
 lea sl,a0
 move.b #8,(a0)
 move.b #13,2(a0)

 move.l #$1000000,(a0)
 move.b #0,(a0)
 move.b #192,2(a0)
 rts 



VBI  

 lea sl,a3


;\\\\\\\\\\\\\
 MOVE.L UPTO,A2
 MOVE CUNT,D3
 MOVE.B 33(A2),D4
SSU SUBQ.W #1,D3
 BPL PART1

COP 
 move.l #1,d1
 MOVE.L d1,PNT1
 MOVE.L d1,PNT2
 MOVE.L d1,PNT3
 MOVE.L d1,PNT5
 MOVE.L #$9000000,(a3)

 Lea 36(a2),a2
 CMP.L #CHAN0,A2
 BNE.S LLA

 LEA DOTH,A2

LLA
 MOVE 34(A2),D3
 MOVE.B 33(A2),D4
PART1

 
 moveq.w #0,d2
 
 BTST #1,D4
 BEQ.S W1
 MOVE.L (A2),A1
 MOVE.L 4(A2),A0
 BSR CHAN0

W1 

 BTST #2,D4
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

;--------EXIT

flo
killer rts




SV DC.L 0


 DC.B " (C) G.WHEATON.  60 NEVIS GROVE BOLTON. LANCS, U.K. "
 
 even

UPTO DC.L EE-36
CUNT DC.W 0


; RUNNING ORDER SEQUENCE

ee
doth

 DC.L PNT5,null
 DC.L PNT1,asharpm
 DC.L PNT2,null
 DC.L PNT3,drm
 DC.B 1,%00001110
 DC.W -1+48*2

 DC.L PNT5,bs2
 DC.L PNT1,asharpm
 DC.L PNT2,bs21
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+48*3


 DC.L PNT5,plink
 DC.L PNT1,asharpm
 DC.L PNT2,null
 DC.L PNT3,drm
 DC.B 1,%00001110
 DC.W -1+48*1

 DC.L PNT5,bs1
 DC.L PNT1,asharpm
 DC.L PNT2,bs21
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+48*4

 DC.L PNT5,bs22
 DC.L PNT1,bs23
 DC.L PNT2,bs20
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+48*8



*******

 DC.L PNT5,test
 DC.L PNT1,asharpm
 DC.L PNT2,bsn
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+48*16



**
 DC.L PNT5,test1
 DC.L PNT1,asharpm
 DC.L PNT2,bsn
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+48*6

 DC.L PNT5,test2
 DC.L PNT1,asharpm
 DC.L PNT2,bsnn
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+48*2




 DC.L PNT5,test
 DC.L PNT1,testt
 DC.L PNT2,bsn
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+48*16

***
 DC.L PNT5,test1
 DC.L PNT1,test11
 DC.L PNT2,bsn
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+48*6

 DC.L PNT5,test22
 DC.L PNT1,test22
 DC.L PNT2,bsnn
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+48*2



*****
 DC.L PNT5,null
 DC.L PNT1,asharpm
 DC.L PNT2,null
 DC.L PNT3,drm
 DC.B 1,%00001110
 DC.W -1+48*2

 DC.L PNT5,bs2
 DC.L PNT1,asharpm
 DC.L PNT2,bs21
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+48*4

 DC.L PNT5,bs1
 DC.L PNT1,asharpm
 DC.L PNT2,bs21
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+48*4

 DC.L PNT5,bs2
 DC.L PNT1,asharpm
 DC.L PNT2,bs21
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+48*4

 DC.L PNT5,bs2
 DC.L PNT1,asharpm
 DC.L PNT2,bs21
 DC.L PNT3,drm
 DC.B 1,%00011110
 DC.W -1+48*4

; DC.L PNT5,bro
; DC.L PNT1,bro1
; DC.L PNT2,bro2
; DC.L PNT3,drm
; DC.B 1,%00001110
; DC.W -1+48*16

 


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
 MOVE.B #-1,4(A1)   ;VOL0
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
 MOVE.B #7,(a3)
 MOVE.B #%11111000,2(a3)
 BRA FCC
EFCT

	 DC.L FINK
 	 dc.l VIB,WARB
	 dc.l DRUM,slip
	 dc.l silent,mug
 	 dc.l wwq

FCC LEA EFCT,A6
 AND #31,D0 
 ASL #2,D0
 MOVE.L (A6,D0),A0
 JSR (A0)

MAZ ADDQ.B #1,4(A1)          ;VOL0


 MOVE.B 11(A1),(a3)
 MOVE.B 21(A1),2(a3)   ;TMP0+1
 MOVE.B 12(A1),(a3)
 MOVE.B 20(A1),2(a3)   ;TMP0
 moveq.w #0,D0
 MOVE.B 4(A1),D0
 MOVE.B 10(A1),(a3)
 MOVE.B 28(A1,D0),2(a3)    ;VOL0

fink rts

;-------EFFECTS ROUTINES--------
;1-256---DELAYED--VIBRATO-------

 
VIB 

 moveq.w #0,d1
 move.b 4(a1),d1
 cmp #16,d1
 blt.s sac 


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

sac move 6(a1),20(a1)
 rts

;2-512------WARB DW-----------

WARB  
 cmp.b #7,4(a1)
 blt.s plop
 move.b #8,4(a1)
PLOP RTS


;3--768--------DRUM-----------
DRUM 
 SUBQ.B #1,21(A1)
 MOVE.B #7,(a3)
 MOVE.B #%11011000,2(a3)
 MOVE.B #6,(a3)
 MOVE.B 21(A1),2(a3)

 MOVE.B #5,(a3)
 MOVE.B #2,2(a3)

 MOVE.B #4,(a3)
 MOVE.B 21(A1),D0
 ASL.B #4,D0
 MOVE.B d0,2(a3)
 RTS



;------5*256
silent
 tst 6(a1)
 beq.s sile

 move.b #30,4(a1)
 rts 

sile
 move.b #120,4(a1)
slip rts 

mug
 rts


;\\\\\\\\\\\\\\DATAS\\\\\\\\\\\\\\\
;\\NOTE 1ST WORD. DURATION 2ND WORD
;\\\LEAD

;\\\MIDDLE
PNT1 DC.W 0
 DC.W 1       ;EFFECT & DURATION 2(A1)
 DC.B 0,0
 DC.L 0
 DC.B 9,2,3
 DC.B 0       ;ADD  13(A1)
 DC.W 5       ;VIB LIMIT
 DC.W 2       ;VIB ADD 16(A1)
 DC.W 0       ;VIB 18(A1)
 DC.L 0       ;TEMP NOTE 20(A1)
 DC.B 1,1     ;VIB RATE  24)A1)
 DC.B 0,0     ;INITIAL VOL
;ADSR  28(A1)

 DC.B 11,10

 dcb.b 6,9
 dcb.b 6,8
 dcb.b 6,7
 dcb.b 6,6
 dcb.b 6,5
 dcb.b 48,4
 dcb.b 48,3
 dcb.b 48,2



 EVEN
;\\\BASS
PNT2 DC.W 0
 DC.W 1          ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0          ;6
 DC.B 10,4,5     ;10(A1) VOL REG
 DC.B 1          ;ADD TO NOTE 13(A1)
 DC.W 6          ;VIB LIMIT
 DC.W 5          ;VIBRATO ADD 16(A1)
 DC.W 2          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
li DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
ADSR
*-*
 DC.B 14,13,11,13,12,11,10,11
 DCb.B 24,10
 DCb.B 24,9
 DCb.B 24,8
 DCb.B 96,7





 EVEN
PNT3 DC.W 0
NP3 DC.W 1      ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0          ;6
 DC.B 10,6,11    ;10(A1) VOL REG
 DC.B 0          ;ADD  13(A1)
 DC.W 5          ;VIB LIMIT
 DC.W 3          ;VIBRATO ADD 16(A1)
 DC.W 0          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
fluk DC.B 0,0        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)


 DC.B 14,14,13,12,11,11
 DCb.B 6,10
 DCb.B 6,9
 DCb.B 8,8
 DCb.B 8,7


PNT5 DC.W 0
 DC.W 1       ;EFFECT & DURATION 2(A1)
 DC.B 0,0
 DC.L 0
 DC.B 8,0,1
 DC.B 0       ;ADD  13(A1)
 DC.W 1       ;VIB LIMIT
 DC.W 2       ;VIB ADD 16(A1)
 DC.W 0       ;VIB 18(A1)
 DC.L 0       ;TEMP NOTE 20(A1)
 DC.B 1,1     ;VIB RATE  24)A1)
 DC.B 0,0     ;INITIAL VOL
;ADSR  28(A1)

 DC.B 13,12,12,11,11,11,11,10
 DCb.B 8,10
 DCb.B 8,9
 DCb.B 16,7
 DCb.B 16,6
 DCb.B 32,5
 DCb.B 32,4
 DCb.B 32,3
 DCb.B 32,2





MAX DC.B 71,32,87,72,69,65,84,79,78
 EVEN

;-----------MUSIC DATA

D=1024+256
v=256
vv=6*256


NULL DC.W 0,128+5*256
 DC.W $FFFF,$FFFF


drm
 dc.w 0,24+1024
 dc.w 6,4+768
 dc.w 0,20+1024
 DC.W $FFFF,$FFFF

a=8

b=256
bs2
 dc.w 136*4,6+v
 dc.w 136*a,6+v
 dc.w 68*a,6
 dc.w 76*a,24+v

 dc.w 76*a,6+v
 dc.w 76*a,12+v
 dc.w 91*a,12+v

 dc.w 76*a,12+v
 dc.w 91*a,12+v

 dc.w 136*a,6+v
 dc.w 136*a,6+v
 dc.w 68*a,6
 dc.w 76*a,18+v
 dc.w 81*a,6

 dc.w 76*a,6+v
 dc.w 136*a,6+v
 dc.w 136*a,6+v
 dc.w 68*a,6
 dc.w 76*a,6+v
 dc.w 0,18+d
 dc.w 76*a,6+v
 DC.W $FFFF,$FFFF


bs1
 dc.w 136*a,6+v
 dc.w 102*a,6+v
 dc.w 68*a,6
 dc.w 76*a,24+v
***
 dc.w 91*a,6

 dc.w 76*a,12+v
 dc.w 91*a,12+v

 dc.w 102*a,6+v
 dc.w 96*a,6+v
 dc.w 91*a,12+v

*
; dc.w 76*a,12+v
; dc.w 91*a,12+v

; dc.w 76*a,12+v
; dc.w 91*a,12+v
***
 dc.w 136*a,6+v
 dc.w 136*a,6+v
 dc.w 68*a,6
 dc.w 76*a,6+v
 dc.w 0,24+d

 dc.w 136*a,6+v
 dc.w 136*a,6+v
 dc.w 68*a,6
 dc.w 76*a,6+v
 dc.w 0,24+d


 DC.W $FFFF,$FFFF


j=2
asharpm
 dc.w 136*j,2
 dc.w 0,4+d
 dc.w 136*j/2,2
 dc.w 0,4+d
 dc.w 136*j,2
 dc.w 0,4+d
 dc.w 136*j,2
 dc.w 0,4+d
 dc.w 136*j,2
 dc.w 0,4+d
 dc.w 136*j/2,2
 dc.w 0,4+d

 dc.w 136*j,2
 dc.w 0,4+d
 dc.w 136*j,2
 dc.w 0,4+d
 dc.w 136*j/2,4
 dc.w 0,2+d
 dc.w 135*j/2,2
 dc.w 0,4+d
 dc.w 153*j,2
 dc.w 0,4+d
 dc.w 136*j/2,2
 dc.w 0,4+d

 dc.w 136*j,2
 dc.w 0,4+d
 dc.w 136*j,2
 dc.w 0,4+d
 dc.w 136*j/2,2
 dc.w 0,4+d
 dc.w 153*j,2
 dc.w 0,4+d

 DC.W $FFFF,$FFFF

 dc.w 136*j,2
 dc.w 0,4+d
 dc.w 136*j/2,2
 dc.w 0,4+d


 dc.w 136*j/2,2
 dc.w 0,4+d
 dc.w 136*j,2
 dc.w 0,4+d
 dc.w 136*j/2,2
 dc.w 0,4+d
 dc.w 136*j,2
 dc.w 0,4+d
 dc.w 136*j/2,2
 dc.w 0,4+d
 dc.w 136*j,2
 dc.w 0,4+d

 DC.W $FFFF,$FFFF

tk=7*256


test
 dc.w 136*j/2,6+tk
 dc.w 136*j/2,6+tk
 dc.w 136*j/2,6+tk
 dc.w 0,6+d
 dc.w 136*j/2,6+tk
 dc.w 0,6+d
 dc.w 153*j/2,6+tk
 dc.w 136*j/2,6+tk
 dc.w 0,6+d
 dc.w 114*j/2,6+tk
 dc.w 0,30+d
 
 dc.w 114*j,6+tk

 dc.w 102*j,12+tk
 dc.w 102*j,6+tk
 dc.w 102*j,6+tk
 dc.w 102*j,12+tk
 dc.w 114*j,6+tk
 dc.w 102*j,12+tk
 dc.w 102*j,12+tk
 dc.w 102*j,6+tk
 dc.w 114*j,6+tk
 dc.w 102*j,6+tk
 dc.w 91*j,6+tk

 dc.w 91*j,3
 dc.w 91*j,3
*
 dc.w 136*j/2,6+tk
 dc.w 136*j/2,6+tk
 dc.w 136*j/2,6+tk
 dc.w 0,6+d
 dc.w 136*j/2,6+tk
 dc.w 0,6+d
 dc.w 153*j/2,6+tk
 dc.w 136*j/2,6+tk
 dc.w 0,6+d
 dc.w 114*j/2,6+tk
 dc.w 0,30+d

 dc.w 114*j/2,6+tk
 
 dc.w 102*j/2,5+tk
 dc.w 0,1+d
 dc.w 102*j/2,5+tk
 dc.w 0,1+d
 dc.w 102*j/2,5+tk
 dc.w 0,1+d
 dc.w 102*j/2,5+tk
 dc.w 0,1+d
 dc.w 102*j/2,6+tk
 dc.w 102*j/2,6+tk
 dc.w 102*j/2,6+tk
 dc.w 102*j/2,6+tk
 dc.w 102*j/2,6+tk
 dc.w 102*j/2,6+tk
 dc.w 102*j/2,6+tk
 dc.w 102*j/2,6+tk
 dc.w 102*j/2,6+tk
 dc.w 0,6+d
 dc.w 114*j/2,6+tk
 dc.w 0,6+d
 DC.W $FFFF,$FFFF







bsn
 dc.w 136*a,12+v
 dc.w 136*a,24+v

 dc.w 136*a,12+v
 dc.w 114*a,12+v
 dc.w 136*a,24+v

 dc.w 230*a,12+v
 dc.w 204*a,12+v
 dc.w 204*a,24+v

 dc.w 230*a,12+v
 dc.w 204*a,12+v
 dc.w 182*a,24

 dc.w 182*a,12

**
 dc.w 136*a,12+v
 dc.w 136*a,24+v

 dc.w 136*a,12+v
 dc.w 114*a,12+v
 dc.w 136*a,24+v

 dc.w 230*a,12+v
 dc.w 204*a,12+v
 dc.w 204*a,24+v

 dc.w 230*a,12+v
 dc.w 204*a,12+v
 dc.w 204*a,12+v

 dc.w 230*a,6+v
 dc.w 204*a,6+v
 dc.w 182*a,12+v

bs23
**
 dc.w 136*a,12+v
 dc.w 136*a,18+v
 dc.w 136*a,6

 dc.w 136*a,12+v
 dc.w 114*a,12+v
 dc.w 136*a,18+v

 dc.w 136*a,6

 dc.w 230*a,12+v
 dc.w 204*a,12+v
 dc.w 204*a,18+v

 dc.w 204*a,6

 dc.w 230*a,12+v
 dc.w 204*a,12+v
 dc.w 182*a,24

 dc.w 182*a,12

**
 dc.w 136*a,12+v
 dc.w 136*a,12+v
 dc.w 136*a,6
 dc.w 136*a,6

 dc.w 136*a,12+v
 dc.w 114*a,12+v
 dc.w 136*a,12+v
 dc.w 136*a,6
 dc.w 136*a,6

 dc.w 230*a,12+v
 dc.w 204*a,12+v
 dc.w 204*a,12
 dc.w 204*a,6
 dc.w 204*a,6

 dc.w 230*a,12+v
 dc.w 204*a,12+v
 dc.w 204*a/2,12+v
 dc.w 192*a,12+v
 dc.w 192*a/2,12+v

 DC.W $FFFF,$FFFF


y=2
test11 dc.w 0,2
test1
 dc.w 136*y,6+tk
 dc.w 120*y,6+tk
 dc.w 114*y,6+tk
 dc.w 102*y,6+tk
 dc.w 91*y,6+tk
 dc.w 60*y,6+tk

 dc.w 76*y,6+tk
 dc.w 60*y,6+tk
 dc.w 68*y,24+tk

 dc.w 0,24+d

 dc.w 57*y,6+tk
 dc.w 60*y,6+tk
 dc.w 57*y,6+tk
 dc.w 60*y,6+tk
 dc.w 57*y,6+tk
 dc.w 60*y,6+tk

 dc.w 68*y,6+tk
 dc.w 76*y,6+tk

 dc.w 57*y,6+tk
 dc.w 60*y,6+tk
 dc.w 57*y,6+tk
 dc.w 60*y,6+tk
 dc.w 57*y,6+tk
 dc.w 60*y,6+tk

 dc.w 68*y,6+tk
 dc.w 76*y,6+tk
 
 DC.W $FFFF,$FFFF

test22 dc.w 0,1+d
test2
 dc.w 57*y,6+tk
 dc.w 60*y,6+tk
 dc.w 57*y,6+tk
 dc.w 60*y,6+tk
 dc.w 57*y,6+tk
 dc.w 60*y,6+tk
 dc.w 57*y,6+tk
 dc.w 60*y,6+tk
 dc.w 57*y,6+tk
 dc.w 60*y,6+tk
 dc.w 57*y,6+tk
 dc.w 51*y,12+tk
 dc.w 0,255+d





bsnn
**
 dc.w 102*a,12+v
 dc.w 102*a,24+v
 dc.w 102*a,12

 dc.w 91*a,12+v
 dc.w 2*91*a,12+v
 dc.w 114*a,12
 dc.w 2*114*a,24

 DC.W $FFFF,$FFFF

f=512
s=16

bs22
**
 dc.w 136*s,18+6+12+12+f
 dc.w 114*s,12+f
 dc.w 136*s,24+f

 dc.w 230*s,12+f
 dc.w 204*s,18+18+f

 dc.w 230*s,12+f
 dc.w 204*s,12+f
 dc.w 182*s,36+f
**
 dc.w 136*s,48+f
 dc.w 114*s,12+f
 dc.w 136*s,24+f

 dc.w 230*s,12+f
 dc.w 204*s,36+f

 dc.w 230*s,12+f

 dc.w 204*s,24+f
 dc.w 192*s,24+f

 DC.W $FFFF,$FFFF

plink
 dc.w 0,24+d
 dc.w 162,6+d
 dc.w 153,6+d
 dc.w 0,128+d

bs21 
 dc.w 136*16,1+d
 dc.w 10+136*16,1+d
 dc.w -10+136*16,1+d
 DC.W $FFFF,$FFFF

i=a/2

bs20
**
 dc.w 136*i,12+f
 dc.w 136*i,18+f
 dc.w 136*i,6+f

 dc.w 136*i,12+f
 dc.w 114*i,12+f
 dc.w 136*i,18+f

 dc.w 136*i,6+f

 dc.w 230*i,12+f
 dc.w 204*i,12+f
 dc.w 204*i,18+f

 dc.w 204*i,6+f

 dc.w 230*i,12+f
 dc.w 204*i,12+f
 dc.w 182*i,36+f



**
 dc.w 136*i,12+f
 dc.w 136*i,24+f

 dc.w 136*i,12+f
 dc.w 114*i,12+f
 dc.w 136*i,24+f

 dc.w 230*i,12+f
 dc.w 204*i,12+f
 dc.w 204*i,12+f
 dc.w 204*i,6+f
 dc.w 204*i,6+f

 dc.w 230*i,6+f
 dc.w 230*i,6+f

 dc.w 204*i,12+f
 dc.w 204*i/2,12+f
 dc.w 192*i,12+f
 dc.w 192*i/2,12+f

 DC.W $FFFF,$FFFF

p=4
testt dc.w 0,1+d
 dc.w 136*p/2,6+tk
 dc.w 136*p/2,6+tk
 dc.w 136*p/2,6+tk
 dc.w 0,6+d
 dc.w 136*p/2,6+tk
 dc.w 0,6+d
 dc.w 153*p/2,6+tk
 dc.w 136*p/2,6+tk
 dc.w 0,6+d
 dc.w 114*p/2,6+tk
 dc.w 0,30+d
 
 dc.w 114*p,6+tk

 dc.w 102*p,12+tk
 dc.w 102*p,6+tk
 dc.w 102*p,6+tk
 dc.w 102*p,12+tk
 dc.w 114*p,6+tk
 dc.w 102*p,12+tk
 dc.w 102*p,12+tk
 dc.w 102*p,6+tk
 dc.w 114*p,6+tk
 dc.w 102*p,6+tk
 dc.w 91*p,6+tk

 dc.w 91*p,3
 dc.w 91*p,3
*
 dc.w 136*p/2,6+tk
 dc.w 136*p/2,6+tk
 dc.w 136*p/2,6+tk
 dc.w 0,6+d
 dc.w 136*p/2,6+tk
 dc.w 0,6+d
 dc.w 153*p/2,6+tk
 dc.w 136*p/2,6+tk
 dc.w 0,6+d
 dc.w 114*p/2,6+tk
 dc.w 0,30+d

 dc.w 114*p/2,6+tk
 
 dc.w 102*p/2,5+tk
 dc.w 0,1+d
 dc.w 102*p/2,5+tk
 dc.w 0,1+d
 dc.w 102*p/2,5+tk
 dc.w 0,1+d
 dc.w 102*p/2,5+tk
 dc.w 0,1+d
 dc.w 102*p/2,6+tk
 dc.w 102*p/2,6+tk
 dc.w 102*p/2,6+tk
 dc.w 102*p/2,6+tk
 dc.w 102*p/2,6+tk
 dc.w 102*p/2,6+tk
 dc.w 102*p/2,6+tk
 dc.w 102*p/2,6+tk
 dc.w 102*p/2,6+tk
 dc.w 0,6+d
 dc.w 114*p/2,6+tk
 dc.w 0,6+d
 DC.W $FFFF,$FFFF



bro1 
 dc.w 92*8,2+d
 dc.w 91*8,3+d
 dc.w 90*8,2+d
 DC.W $FFFF,$FFFF

bro2 
 dc.w 135*4,2+d
 dc.w 136*4,4+d
 dc.w 137*4,2+d
 DC.W $FFFF,$FFFF


bro 
 dc.w 136*y,24 
 dc.w 120*y,24 
 dc.w 114*y,24 
 dc.w 102*y,24 
 dc.w 91*y,24 
 dc.w 60*y,24 
 dc.w 76*y,24 
 dc.w 60*y,24 
 dc.w 68*y,96 

 dc.w 68*y,24 
 dc.w 60*y,24  

 dc.w 57*y,24 
 dc.w 60*y,24  
 dc.w 57*y,24  
 dc.w 60*y,24  
 dc.w 57*y,24  
 dc.w 60*y,24  

 dc.w 76*y,24  
 dc.w 60*y,24  
 dc.w 68*y,48


 dc.w 91*y,24 
 dc.w 114*y,24 
 dc.w 136*y,48 
 dc.w 182*y,48 
 dc.w 2*136*y,48 
 
 DC.W $FFFF,$FFFF
