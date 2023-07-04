
; THIS MUSIC SOURCE CANNOT BE RUN AS IS.
; IT SHOULD BE ASSEMBLED TO DISK AND USED
; AS SHOWN IN EXAMPLE.S

*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

;This is the format to use when following
;the example.s It is most important
;not to change the positions of the
;2 longwords and 1 word, after the label
;vbi, They are there to reset a tune.



 
VBI  
UPTO DC.L EE-36
RUNT DC.W 0
 DC.L EE-36


 add.b #220,flo
 bcc killer

 lea $FF8800,A3

;\\\\\\\\\\\\\
 MOVE.L UPTO,A2
 MOVE RUNT,D3
 MOVE.B 33(A2),D4

 SUBQ.W #1,D3
 BPL.S PART1

 move.l #1,d1
 MOVE.L d1,PNT1
 MOVE.L d1,PNT2
 MOVE.L d1,PNT3
 MOVE.L d1,PNT4
 MOVE.L d1,PNT5
 MOVE.L #$9000000,(a3)

 LEA 36(A2),A2
 CMP.L #PNT1,A2
 BNE.S L1

 LEA DOTH,A2

L1
 MOVE 34(A2),D3
 MOVE.B 33(A2),D4

PART1
 moveq.w #0,d2
 
 BTST #1,D4
 BEQ.S W1

 MOVE.L (A2),A1
 MOVE.L 4(A2),A0
 BSR.S CHAN0

W1 
 BTST #2,D4
 BEQ.S W2
 MOVE.L 8(A2),A1
 MOVE.L 12(A2),A0
 BSR.S CHAN0

W2 MOVEQ.B #1,D2
 BTST #3,D4
 BEQ.S W3
 MOVE.L 16(A2),A1
 MOVE.L 20(A2),A0
 BSR.S CHAN0

W3 BTST #4,D4
 BEQ.S W4
 MOVE.L 24(A2),A1
 MOVE.L 28(A2),A0
 BSR.S CHAN0

W4 MOVE.L A2,UPTO
 MOVE D3,RUNT

;---EXIT VBI---

killer rts


flo dc.b 0,0


CHAN0
;\\\\\\\\\\\\\\\\\\\\\\
 MOVE (A1),D0
 MOVE.L (A0,D0),D1  ;GET NOTE 0 & DURATION
 bpl.s con2

 CLR (A1)        ;RESET TO START
 MOVE.L (A0),D1

CON2
 SUBQ.B #1,3(A1)	NP0
 BNE STILLON

 MOVE.L D1,6(A1)	D1.W IS DURATION
 MOVE.L D1,20(A1)	HOLD NOTE
 clr 4(A1)		VOL0
 MOVE D1,2(A1)		SET NEW DURATION
 ADDQ.W #4,(A1)		& INC POINTER

STILLON

;------EFFECTS------

 MOVE.B #7,(A3)
 MOVE.B #%11111000,2(A3)

 MOVE.B 2(A1),D0
 BEQ.S MAZ

 LEA EFCT,A6
 AND #31,D0 
 ASL #2,D0
 MOVE.L (A6,D0),A0
 JSR (A0)

MAZ 
 ADDQ.B #1,4(A1)	VOL0
 MOVE.B 11(A1),(a3)
 MOVE.B 21(A1),2(a3)	TMP0+1
 MOVE.B 12(A1),(a3)
 MOVE.B 20(A1),2(a3)	TMP0

 moveq.w #0,D0
 MOVE.B 4(A1),D0
 MOVE.B 10(A1),(a3)
 MOVE.B 24(A1,D0),2(a3)	VOL0
fink rts

EFCT

	DC.L FINK
 	dc.l VIB,WARB
	dc.l DRUM,SLIP
	dc.l am,FM,GM,CM
	dc.l sil


;-------EFFECTS ROUTINES--
;1-256--DELAYED--VIBRATO--

 
VIB 
 moveq.w #0,d1
 move.b 4(a1),d1
 cmp #9,d1
 blt.s sac 

WWQ 
 MOVE 16(A1),D1
 ADD D1,18(A1)
 MOVE 14(A1),D1
 CMP 18(A1),D1
 BLT.S RIST
 NEG D1
 CMP 18(A1),D1
 BGT.S RIST

SAZ MOVE 6(A1),D1
 ADD 18(A1),D1
 MOVE D1,20(A1)
 RTS

RIST NEG 16(A1)
 BRA.S SAZ

sac move 6(a1),20(a1)
 rts


;2---512-WARB DW-
WARB
  RTS


;3---768-DRUM-
DRUM 
 SUBQ.B #1,21(A1)
 MOVE.B #7,(a3)
 MOVE.B #%11011000,2(a3)
 MOVE.B #6,(a3)
 MOVE.B 21(A1),2(a3)

 MOVE.B #5,(a3)
 MOVE.B 32(A2),2(a3)

 MOVE.B #4,(a3)
 MOVE.B 21(A1),D0
 ASL.B #3,D0
 MOVE.B d0,2(a3)
 RTS

;---4 SLIP NOTHING 
SLIP
 MOVE.L (SP)+,D1
 ADDQ.B #1,4(A1)
 RTS


;---5*256
am
 SUBQ.W #2,ROJ
 BPL.S PPE
 MOVE #4,ROJ
PPE
 MOVE ROJ,D1
 MOVE AMIN(PC,D1),20(A1)
 rts

ROJ DC.W 0
AMIN DC.W 192*G,144*G,120*G

;---6*256
FM
 SUBQ.W #2,ROJ
 BPL.S PP1
 MOVE #4,ROJ
PP1
 MOVE ROJ,D1
 MOVE FMAJ(PC,D1),20(A1)
 rts

FMAJ DC.W 182*G,144*G,120*G


;---7*256
GM
 SUBQ.W #2,ROJ
 BPL.S PP2
 MOVE #4,ROJ
PP2
 MOVE ROJ,D1
 MOVE GMAJ(PC,D1),20(A1)
 rts

GMAJ DC.W 162*G,128*G,144*G

;---8*256
CM
 SUBQ.W #2,ROJ
 BPL.S PP3
 MOVE #4,ROJ
PP3
 MOVE ROJ,D1
 MOVE CMAJ(PC,D1),20(A1)
 rts

CMAJ DC.W 96*G,162*G,120*G




;9
sil
 MOVE.B #-1,4(a1)
 rts



ee
Doth
 DC.L PNT1,BASS
 DC.L PNT4,Bass1
 DC.L PNT5,BASS2
 DC.L PNT3,DRM
 DC.B 2,%00011110
 DC.W 511

 DC.L PNT1,PIAN1
 DC.L PNT4,Bass
 DC.L PNT5,PIAN
 DC.L PNT3,DRM
 DC.B 1,%00011110
 DC.W 511

 DC.L PNT1,PIAN1
 DC.L PNT4,Bass
 DC.L PNT5,PIAN2
 DC.L PNT3,DRM
 DC.B 2,%00011110
 DC.W 511

 DC.L PNT1,SS12
 DC.L PNT4,Bass
 DC.L PNT5,NULL
 DC.L PNT3,DRM
 DC.B 1,%00011110
 DC.W 511

 DC.L PNT1,BASS
 DC.L PNT4,SS14
 DC.L PNT5,SS13
 DC.L PNT3,DRM
 DC.B 1,%00011110
 DC.W 511

 DC.L PNT1,NIBBB
 DC.L PNT4,Bass
 DC.L PNT5,BASS
 DC.L PNT3,DRM
 DC.B 1,%00011110
 DC.W 511

 DC.L PNT1,Nib
 DC.L PNT4,Bass
 DC.L PNT2,nibb
 DC.L PNT3,DRM
 DC.B 1,%00011110
 DC.W 511

 DC.L PNT1,Nib
 DC.L PNT4,Bass
 DC.L PNT5,nibb
 DC.L PNT3,DRM
 DC.B 1,%00011110
 DC.W 511

 DC.L PNT1,PIAN1
 DC.L PNT4,NIB
 DC.L PNT2,BASS
 DC.L PNT3,DRMM
 DC.B 1,%00011110
 DC.W 511

 DC.L PNT1,PIAN
 DC.L PNT4,nibb
 DC.L PNT2,PIAN1
 DC.L PNT3,DRM
 DC.B 1,%00011110
 DC.W 511

 DC.L PNT1,PIAN1
 DC.L PNT4,pian3
 DC.L PNT5,PIAN2
 DC.L PNT3,DRM1
 DC.B 1,%00011110
 DC.W 511


 DC.L PNT1,BASS
 DC.L PNT4,null
 DC.L PNT2,BASS
 DC.L PNT3,DRM
 DC.B 2,%00011110
 DC.W 511



;\\\\\\\\\\\\\\DATAS\\\\\\\\\\\\\\\
PNT1 DC.W 0
 DC.W 1       ;EFFECT & DURATION 2(A1)
 DC.B 0,0
EEW DC.L 0
 DC.B 8,0,1
 DC.B 0       ;ADD  13(A1)
 DC.W 2       ;VIB LIMIT
 DC.W 2       ;VIB ADD 16(A1)
 DC.W 0       ;VIB 18(A1)
 DC.L 0       ;TEMP NOTE 20(A1)

 DC.B 0,14,13,12
 dcb.b 4,12
 dcb.b 4,11
 dcb.b 4,10
 dcb.b 4,9
 dcb.b 8,8
 dcb.b 16,7
 dcb.b 16,6


 EVEN
PNT2 DC.W 0
 DC.W 1         
 DC.B 0,0
 DC.L 0
 DC.B 9,2,3 
 DC.B 1
 DC.W 21	VIB LIMIT
 DC.W 12	V ADD
 DC.W 2
 DC.L 0

****
 dc.b 0,15,15,14,13,12,11
 dcb.b 8,10
 dcb.b 8,9
 dcb.b 8,8
 dcb.b 16,6
 dcb.b 16,5


 EVEN
PNT3 DC.W 0
NP3 DC.W 1      ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0          ;6
 DC.B 10,6,11    ;10(A1) VOL REG
 DC.B 0          ;ADD  13(A1)
 DC.W 1          ;VIB LIMIT
 DC.W 1          ;VIBRATO ADD 16(A1)
 DC.W 0          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)


 DC.B 0,15,14,13,12,11,10,8
 DC.B 0,0,0,0,0,0,0,0

PNT4 DC.W 0
 DC.W 1       ;EFFECT & DURATION 2(A1)
 DC.B 0,0
 DC.L 0
 DC.B 10,4,5
 DC.B 10       ;ADD  13(A1)
 DC.W 4       ;VIB LIMIT
 DC.W 3       ;VIB ADD 16(A1)
 DC.W 0       ;VIB 18(A1)
 DC.L 0       ;TEMP NOTE 20(A1)

;ADSR  24(A1)

 DC.b 0,14,13,12,11
 dcb.b 4,10
 dcb.b 4,9
 dcb.b 4,10
 dcb.b 4,9
 dcb.b 4,8
 dcb.b 4,9
 dcb.b 4,8
 dcb.b 4,9
 dcb.b 16,8
 dcb.b 8,4
 dcb.b 16,3
 DCB.B 16,2


 EVEN
PNT5 DC.W 0
 DC.W 1         
 DC.B 0,0
 DC.L 0
 DC.B 9,2,3 
 DC.B 1
 DC.W 2		VIB LIMIT
 DC.W 2		VIB ADD
 DC.W 2
 DC.L 0

****
;24(A1)
 dc.b 15,14,13,12,11,11,10
 DCB.B 8,9
 DCB.B 16,8
 DCB.B 16,7
 DCB.B 16,6

 DC.B 71,32,87,72,69,65,84,79,78

 EVEN


;-----------MUSIC DATA

D=9*256
v=256

NULL DC.W 2,128+d
 DC.W $FFFF,$FFFF

drmm 
 dc.w 0,16+1024
 dc.w 8,7+768
 dc.w 8,9+768

 dc.w 0,16+1024
 dc.w 8,7+768
 dc.w 8,9+768

 dc.w 0,16+1024
 dc.w 8,7+768
 dc.w 8,9+768

 dc.w 0,16+1024
 dc.w 9,7+768
 dc.w 8,9+1024

 DC.W $FFFF,$FFFF

drm 
 dc.w 0,16+1024
 dc.w 4,3+768
 dc.w 8,13+1024
 DC.W $FFFF,$FFFF

drm1 
 dc.w 0,16+1024
 dc.w 2,1+768
 dc.w 8,15+1024
 DC.W $FFFF,$FFFF


i=2
NIB
 dc.w 144*i,16+v
 dc.w 144*i,16+v
 dc.w 144*i,8
 dc.w 128*i,8
 dc.w 144*i,8
 dc.w 162*i,8
 dc.w 144*i,16+v
 dc.w 144*i,8

 dc.w 144*i,8
 dc.w 144*i,8
 dc.w 128*i,8
 dc.w 144*i,8
 dc.w 162*i,8

 dc.w 182*i,16+v
 dc.w 182*i,8
 dc.w 182*i,8
 dc.w 182*i,8
 dc.w 162*i,8
 dc.w 182*i,8
 dc.w 96*i,8
 
 dc.w 91*i,24+v

 dc.w 182*i,8
 dc.w 182*i,8
 dc.w 182*i,8
 dc.w 182*i,8
 dc.w 162*i,8
**48
 dc.w 324*I,16+v
 dc.w 324*I,16
 dc.w 324*i,8
 dc.w 288*i,8
 dc.w 243*i,8
 dc.w 216*i,8

**
; dc.w 324*I,8
; dc.w 324*I,8+v
 dc.w 324*I,8+v
 dc.w 324*I,8
 dc.w 324*I,8
 dc.w 324*I,8
 dc.w 324*I,8
 dc.w 256*I,8
 dc.w 216*I,8
 dc.w 162*I,8

 dc.w 182*i,16+v
 dc.w 182*i,16+v
 dc.w 182*i,8
 dc.w 162*i,8
 dc.w 182*i,8
 dc.w 192*i,8
 dc.w 243*i,24+v

 dc.w 243*i,8
 dc.w 192*i,8
 dc.w 144*i,8
 dc.w 120*i,8
 dc.w 96*i,8
 DC.W $FFFF,$FFFF

G=1

A=5*256
F=6*256
G1=7*256
C=8*256

nibB
 dc.w 0,16+a
 dc.w 0,16+a
 dc.w 0,16+a
 dc.w 0,8+a

 dc.w 0,16+a
 dc.w 0,8+a
 dc.w 0,8+a
 dc.w 0,8+a
 dc.w 0,8+a
 dc.w 0,8+a
 dc.w 0,8+a
 dc.w 0,8+a

 dc.w 0,16+F
 dc.w 0,16+F
 dc.w 0,16+F
 dc.w 0,8+f

 dc.w 0,16+F
 dc.w 0,8+F
 dc.w 0,8+F
 dc.w 0,8+F
 dc.w 0,8+F
 dc.w 0,8+F
 dc.w 0,8+F
 dc.w 0,8+F

 dc.w 0,16+G1
 dc.w 0,16+G1
 dc.w 0,16+G1
 dc.w 0,8+G1

 dc.w 0,16+G1
 dc.w 0,8+G1
 dc.w 0,16+G1
 dc.w 0,8+G1
 dc.w 0,8+G1
 dc.w 0,8+G1
 dc.w 0,8+G1

 dc.w 0,16+F
 dc.w 0,16+g1
 dc.w 0,16+F
 dc.w 0,8+G1

 dc.w 0,16+C
 dc.w 0,8+a
 dc.w 0,16+C
 dc.w 0,8+a
 dc.w 0,8+C
 dc.w 0,8+C
 dc.w 0,8+G1

 DC.W $FFFF,$FFFF

b=8
h=b*2
bass1 dc.w 0,1+d
bass2 dc.w 0,1+d
bass
 dc.w 144*b,24+V
 dc.w 144*b,8
 dc.w 192*b,24+V
 dc.w 162*b,8
 dc.w 144*b,24+V
 dc.w 144*b,8
 dc.w 144*b,8
 dc.w 128*b,8
 dc.w 144*b,8
 dc.w 192*b,8

 dc.w 182*h,8
 dc.w 182*b,8
 dc.w 182*h,8
 dc.w 182*b,8
 dc.w 182*h,8
 dc.w 182*b,8
 dc.w 182*b,8
 dc.w 182*h,8
 dc.w 182*b,8
 dc.w 182*b,8
 dc.w 182*h,8
 dc.w 182*b,8
 dc.w 91*B,24  16
 dc.w 91*B,8  16

 dc.w 162*b,24

 dc.w 162*b,8
 dc.w 216*b,24+V
 dc.w 216*b,8+V


 dc.w 162*b,8
 dc.w 144*b,8
 dc.w 120*b,8
 dc.w 108*b,8
 dc.w 81*b,8
 dc.w 108*b,8
 dc.w 120*b,8
 dc.w 144*b,8

**
 dc.w 182*b,16+V
 dc.w 182*b,16
 dc.w 182*b,8
 dc.w 162*b,8
 dc.w 182*b,8

 dc.w 192*b,8
 dc.w 243*b,24+V +2560

 dc.w 288*b,8
 dc.w 192*b,8
 dc.w 144*b,8
 dc.w 120*b,8

 dc.w 96*b,32

 DC.W $FFFF,$FFFF



Ii=4
NIBBB
 dc.w 144,1+v
 dc.w 144*II,7+v
 DC.W 0,8+D
 dc.w 144*II,8+v
 dc.w 144*II,8+v
 dc.w 144*II,8+v
 dc.w 192*II,8+v
 DC.W 162*II,8
 dc.w 144,1+v

 dc.w 144*II,15+v
 dc.w 144*II,8
 dc.w 144*II,8
 dc.w 144*II,8
 dc.w 144*II,8
 dc.w 128*II,8
 dc.w 144*II,8
 dc.w 162*II,8

 dc.w 182*II,16+v
 dc.w 182*II,16+v
 dc.w 182*II,16+v
 dc.w 182*II,8
 dc.w 182*II,8
 dc.w 91*II,24+v
 dc.w 182*II,8
 dc.w 182*II,8
 dc.w 182*II,8
 dc.w 182*II,8
 dc.w 162*II,8

 dc.w 324*II,16+v
 dc.w 324*II,8+v
 dc.w 324*II,8+v
 dc.w 432*II,16+v
 dc.w 432*II,8
 dc.w 432*II,9

; dc.w 0,64+d
 dc.w 162*4,8
 dc.w 144*4,8
 dc.w 120*4,8
 dc.w 108*4,7
 dc.w 81*4,8
 dc.w 108*4,8
 dc.w 120*4,8
 dc.w 144*4,8


 dc.w 182*II,16+v
 dc.w 182*II,16+v
 dc.w 182*II,8
 dc.w 162*II,8
 dc.w 182*II,8
 dc.w 192*II,8+v

 dc.w 0,7*8+d
 ;dc.w 243*II,24+v
 ;dc.w 192*II,8
 ;dc.w 192*II,8
 ;dc.w 192*II,8
 ;dc.w 192*II,8
 dc.w 216*II,24
 DC.W $FFFF,$FFFF

U=2

PIAN1
 DC.W 72*U,24
 DC.W 72*U,8
 DC.W 96*U,24
 DC.W 81*U,8
 DC.W 72*U,24
 DC.W 72*U,24
 DC.W 60*U,16

 DC.W 91*U,32
 DC.W 72*U,32
 DC.W 91*U,32
 DC.W 0,32+D


 DC.W 81*U,32
 DC.W 54*U,32
 DC.W 81*U,24
 DC.W 81*U,8
 DC.W 64*U,32

 DC.W 72*U,32
 DC.W 91*U,32

 DC.W 121*U,64

PIAN
 DC.W 96*U,32
 DC.W 72*U,32
 DC.W 96*U,32
 DC.W 96*U,8
 DC.W 72*U,8
 DC.W 47*U,16 

 DC.W 91*U,24
 DC.W 91*U,8
 DC.W 91*U,24
 DC.W 91*U,8
 DC.W 45*U,24
 DC.W 45*U,8
 DC.W 60*U,8
 DC.W 72*U,8
 DC.W 91*U,16

 DC.W 81*U,24
 DC.W 81*U,8
 DC.W 64*U,32
 DC.W 54*U,32
 DC.W 81*U,8
 DC.W 64*U,8
 DC.W 54*U,16

 DC.W 91*U,32
 DC.W 91*U,8
 DC.W 81*U,8
 DC.W 60*U,16

 DC.W 60*U,32
; DC.W 60*U,8
 DC.W 120*U,8
 DC.W 96*U,8
 DC.W 81*U,8
 DC.W 60*U,32






E=1
SS12
 DC.W 72*E,26

 DC.W 91*E,3
 DC.W 96*E,3
 DC.W 72*E,26

 DC.W 91*E,3
 DC.W 96*E,3
 DC.W 72*E,26


 DC.W 91*E,3
 DC.W 96*E,3
 DC.W 120*E,8
 DC.W 108*E,8
 DC.W 96*E,8
 DC.W 81*E,8


 DC.W 91*E,24
 DC.W 108*E,3
 DC.W 121*E,3
 DC.W 91*E,26
 DC.W 108*E,3
 DC.W 121*E,3
 DC.W 91*E,26
 DC.W 108*E,3
 DC.W 121*E,3
 DC.W 91*E,26

 DC.W 64*E,3
 DC.W 72*E,3
 DC.W 81*E,26

 DC.W 64*E,3
 DC.W 72*E,3
 DC.W 81*E,26

 DC.W 64*E,3
 DC.W 72*E,3
 DC.W 81*E,26

**
 DC.W 64*E,3
 DC.W 72*E,3

 DC.W 108*E,8
 DC.W 96*E,8

 DC.W 91*E,8
 DC.W 81*E,8
 DC.W 91*E,48

 DC.W 96*E,8
 DC.W 108*E,8
 DC.W 96*E,26

 DC.W 96*E,3
 DC.W 108*E,3
 DC.W 120*E,40




ss14 dc.w 0,1+d
SS13
 DC.W 72*E,26

 DC.W 60*E,3
 DC.W 64*E,3
 DC.W 72*E,26

 DC.W 60*E,3
 DC.W 64*E,3
 DC.W 72*E,26

 DC.W 60*E,3
 DC.W 64*E,3
 DC.W 72*E,26


 DC.W 72*E,3
 DC.W 81*E,3
 DC.W 91*E,24
 DC.W 72*E,3
 DC.W 81*E,3
 DC.W 91*E,26
 DC.W 72*E,3
 DC.W 81*E,3
 DC.W 91*E,26
 DC.W 72*E,3
 DC.W 81*E,3
 DC.W 91*E,26

 DC.W 64*E,3
 DC.W 72*E,3
 DC.W 81*E,26
 DC.W 64*E,3
 DC.W 72*E,3
 DC.W 81*E,26
 DC.W 64*E,3
 DC.W 72*E,3
 DC.W 81*E,26
 DC.W 64*E,3
 DC.W 72*E,3
 DC.W 81*E,26

 DC.W 72*E,3
 DC.W 81*E,3
 DC.W 91*E,26

 DC.W 72*E,3
 DC.W 81*E,3
 DC.W 91*E,26

 DC.W 81*E,3
 DC.W 91*E,3
 DC.W 96*E,26

 DC.W 96*E,3
 DC.W 108*E,3
 DC.W 120*E,48








PIAN2
 DC.W 96*U,32
 DC.W 72*U,32
 DC.W 96*U,32
 DC.W 96*U,8
 DC.W 72*U,8
 DC.W 48*U,16 +V

 DC.W 91*U,24
 DC.W 91*U,8
 DC.W 72*U,24	
 DC.W 60*U,8	

 DC.W 36*U,24


 DC.W 60*U,4
 DC.W 72*U,4
 DC.W 91*U,24

 DC.W 91*U,8
 DC.W 81*U,24
 DC.W 81*U,8
 DC.W 64*U,24
 DC.W 64*U,8

t=2
***
 dc.w 81*t,8
 dc.w 72*t,8
 dc.w 60*t,8
 dc.w 54*t,8
 dc.w 40*t,8
 dc.w 54*t,8
 dc.w 60*t,8
 dc.w 72*t,8

***

; DC.W 54*U,24
; DC.W 54*U,8
; DC.W 81*U,8
; DC.W 64*U,8
; DC.W 54*U,16

 DC.W 91*U,24
 DC.W 91*U,8
 DC.W 91*U,8
 DC.W 81*U,8
 DC.W 60*U,16

 DC.W 96*U,24


 DC.W 96*U,4
 DC.W 108*U,4
 DC.W 120*U,64





o=8
PIAN3
 DC.W 96*o,32
 DC.W 72*o,32
 DC.W 96*o,32
 DC.W 96*o,8
 DC.W 72*o,8
 DC.W 48*o,16 

 DC.W 91*o,24
 DC.W 91*o,8
 DC.W 91*o,24
 DC.W 91*o,8
 DC.W 45*o,24
 DC.W 45*o,8
 DC.W 60*o,8
 DC.W 72*o,8
 DC.W 91*o,16

 DC.W 81*o,24
 DC.W 81*o,8
 DC.W 64*o,32
 DC.W 54*o,32
 DC.W 81*o,8
 DC.W 64*o,8
 DC.W 54*o,16

 DC.W 91*o,32
 DC.W 91*o,8
 DC.W 81*o,8
 DC.W 60*o,16

 DC.W 60*o,32
 DC.W 120*1,8
 DC.W 96*1,8
 DC.W 81*1,8
 DC.W 60*1,32




